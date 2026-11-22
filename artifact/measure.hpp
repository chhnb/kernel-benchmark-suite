using llvm::json::Array;
using Strings = std::vector<std::string>;
using Samples = std::vector<std::vector<double>>;
constexpr const char *RunVariants[] = {"base", "bf", "darm", "darm-best", "anchor"};

double seconds(Clock::time_point start) {
  return std::chrono::duration<double>(Clock::now() - start).count();
}

void writeJSON(const fs::path &path, llvm::json::Value value) {
  fs::path temporary = path;
  temporary += ".tmp";
  std::error_code error;
  {
    llvm::raw_fd_ostream stream(temporary.string(), error);
    if (error)
      throw std::runtime_error(error.message());
    stream << llvm::formatv("{0:2}\n", value);
    stream.close();
    if (stream.has_error())
      throw std::runtime_error("cannot write " + temporary.string());
  }
  fs::rename(temporary, path);
}

std::string program(StringRef name) {
  auto path = llvm::sys::findProgramByName(name);
  if (!path)
    throw std::runtime_error(name.str() + " is required");
  return *path;
}

Strings strings(const Array &array) {
  Strings values;
  for (const auto &value : array)
    values.push_back(value.getAsString()->str());
  return values;
}

std::string identifier(std::string scene) {
  std::replace(scene.begin(), scene.end(), '/', '-');
  return scene;
}

double median(std::vector<double> values) {
  if (values.empty())
    throw std::runtime_error("empty timing sample");
  std::sort(values.begin(), values.end());
  return (values[values.size() / 2] + values[(values.size() - 1) / 2]) / 2;
}

struct Ratio {
  double point, lower, upper, spread;

  Object receipt() const {
    return Object{{"median", point}, {"lower", lower}, {"upper", upper}, {"spread", spread}};
  }
};

Ratio ratio(const Samples &samples, size_t numerator, size_t denominator) {
  std::vector<double> paired;
  for (const auto &row : samples)
    paired.push_back(row.at(numerator) / row.at(denominator));
  std::mt19937 random(20261121);
  std::uniform_int_distribution<size_t> index(0, paired.size() - 1);
  std::vector<double> bootstrap;
  bootstrap.reserve(10000);
  std::vector<double> selection(paired.size());
  for (int rep = 0; rep < 10000; ++rep) {
    for (auto &sample : selection)
      sample = paired[index(random)];
    bootstrap.push_back(median(selection));
  }
  std::sort(bootstrap.begin(), bootstrap.end());
  const auto extremes = std::minmax_element(paired.begin(), paired.end());
  return {median(paired), bootstrap[249], bootstrap[9749], *extremes.second / *extremes.first - 1};
}

struct GpuLock {
  int descriptor;
  explicit GpuLock(const fs::path &path) : descriptor(open(path.c_str(), O_CREAT | O_CLOEXEC | O_RDWR, 0664)) {
    if (descriptor < 0)
      throw std::runtime_error("cannot open GPU lock " + path.string());
    if (flock(descriptor, LOCK_EX) != 0) {
      close(descriptor);
      throw std::runtime_error("cannot lock GPU " + path.string());
    }
  }
  ~GpuLock() { close(descriptor); }
  GpuLock(const GpuLock &) = delete;
};

struct Modules {
  Strings paths, digests;
  std::map<std::string, size_t> roles;
  Object builds;

  void add(const std::string &name, const fs::path &path, const std::string &digest) {
    auto match = std::find(digests.begin(), digests.end(), digest);
    roles.emplace(name, std::distance(digests.begin(), match));
    if (match == digests.end()) {
      digests.push_back(digest);
      paths.push_back(path.string());
    }
  }
};

struct Measurement {
  const Artifact &artifact;
  fs::path output, objects;
  llvm::json::Value manifest;
  const Array *scenes;
  Object environment;
  bool quick;
  int windows;

  Measurement(const Artifact &artifact, fs::path output, fs::path objects, bool quick)
      : artifact(artifact), output(std::move(output)), objects(std::move(objects)),
        manifest(json(artifact.data / "run-manifest.json")),
        scenes(manifest.getAsObject() ? manifest.getAsObject()->getArray("scenarios") : nullptr),
        quick(quick), windows(quick ? 3 : 12) {
    if (!scenes || manifest.getAsObject()->getInteger("schema").getValueOr(0) != 1)
      throw std::runtime_error("invalid run manifest");
  }

  fs::path executable(const std::string &tool) const {
    auto path = artifact.bin / ("kbs-" + tool);
    if (!fs::is_regular_file(path))
      throw std::runtime_error("missing " + path.string() + ", configure with -DKBS_GPU_RUNNERS=ON");
    return path;
  }

  void inspectEnvironment() {
    const auto path = executable("environment");
    run({path.string()}, output / "hip.txt", output / "hip.log");
    auto rocmVersion = artifact.rocm / ".info/version";
    environment = Object{{"device", read(output / "hip.txt")},
                   {"rocm", fs::exists(rocmVersion) ? read(rocmVersion) : artifact.rocm.string()},
                   {"kernel_driver", fs::exists("/sys/module/amdgpu/version") ?
                       read("/sys/module/amdgpu/version") : "amdgpu in the running Linux kernel"},
                   {"kbs_sha256", sha(artifact.bin / "kbs", output)}};
    run({program("uname"), "-sr"}, output / "kernel.txt", output / "kernel.log");
    environment["kernel"] = read(output / "kernel.txt");
  }

  fs::path fixtures(const Object &scene, const fs::path &dir) const {
    const auto root = dir / "fixtures";
    auto verified = [&](const fs::path &path) {
      for (const auto &entry : *scene.getObject("files")) {
        const auto file = path / entry.first.str();
        const auto *meta = entry.second.getAsObject();
        if (!fs::is_regular_file(file) || fs::file_size(file) != uintmax_t(*meta->getInteger("bytes")) ||
            sha(file, dir) != req(*meta, "sha256"))
          throw std::runtime_error("frozen fixture SHA-256/size mismatch " + file.string());
      }
    };
    if (fs::is_directory(root)) {
      verified(root);
      return root;
    }
    auto pending = dir / "fixtures.pending";
    fs::remove_all(pending);
    auto archive = dir / req(scene, "archive");
    auto url = req(scene, "archive_url");
    if (const char *mirror = std::getenv("KBS_ARCHIVE_DIR"))
      url = "file://" + (fs::absolute(mirror) / req(scene, "archive")).string();
    if (!fs::exists(archive) || sha(archive, dir) != req(scene, "archive_sha256")) {
      const auto download = archive.string() + ".partial";
      if (StringRef(url).startswith("file://") && fs::exists(url.substr(7)))
        fs::copy_file(url.substr(7), download, fs::copy_options::overwrite_existing);
      else
        run({program("curl"), "--fail", "--location", "--output", download, url},
            dir / "download.stdout", dir / "download.log");
      if (sha(download, dir) != req(scene, "archive_sha256"))
        throw std::runtime_error("archive SHA-256 mismatch " + url);
      fs::rename(download, archive);
    }
    auto archived = strings(*scene.getArray("archived"));
    const auto *generator = scene.getObject("generator");
    const bool afterExtract = generator && generator->getBoolean("after_extract").getValueOr(false);
    auto generate = [&] {
      const auto tool = req(*generator, "program");
      auto target = pending;
      if (tool == "lud-fixture") {
        fs::create_directory(pending);
        target /= "lud-input.bin";
      }
      Strings command{executable(tool).string(), target.string()};
      auto args = strings(*generator->getArray("args"));
      command.insert(command.end(), args.begin(), args.end());
      run(command, dir / "generate.stdout", dir / "generate.log");
    };
    if (generator && !afterExtract) {
      generate();
      // A generator may reproduce only a subset of the frozen files.
      for (const auto &filename : archived)
        fs::remove(pending / filename);
    } else {
      fs::create_directory(pending);
    }
    Strings tar{program("tar"), "--extract", "--zstd", "--file", archive.string(),
              "--directory", pending.string(), "--no-same-owner", "--no-same-permissions", "--"};
    for (const auto &filename : archived)
      tar.push_back("./" + filename);
    run(tar, dir / "extract.stdout", dir / "extract.log");
    if (afterExtract)
      generate();
    verified(pending);
    fs::rename(pending, root);
    return root;
  }

  Modules modules(const Object &scene, const fs::path &fixture, const fs::path &dir,
                  const std::string &only) const {
    const auto name = req(scene, "case");
    const auto &row = *artifact.cases.at(name);
    const auto &frozen = *row.getObject("frozen");
    Modules modules;
    for (const std::string variant : RunVariants) {
      if ((!only.empty() && only != variant) || (variant == "bf" && row.getString("bf_unavailable")))
        continue;
      if (variant == "darm-best") {
        const auto path = fixture / "darm-best.hsaco";
        modules.add(variant, path, req(*scene.getObject("recorded_best"), "sha256"));
        continue;
      }
      auto build = objects / (name + "-" + variant);
      if (!fs::exists(build / "build.json"))
        artifact.build(name, variant, build, false, false);
      const auto binary = build / "kernel.hsaco";
      const auto digest = sha(binary, dir);
      if (digest != req(frozen, variant))
        throw std::runtime_error("device object differs from frozen SHA-256: " + binary.string());
      modules.add(variant, binary, digest);
      modules.builds[variant] = json(build / "build.json");
    }
    return modules;
  }

  Samples launch(const Object &scene, const fs::path &fixture, const Strings &paths,
                 const fs::path &dir, int count, int rep) const {
    fs::create_directories(dir);
    auto name = req(scene, "case");
    auto runner = req(scene, "runner");
    auto tool = executable(runner);
    auto stdoutPath = dir / "stdout.txt";
    auto csv = dir / "samples.csv";
    int group = 1;
    bool millis = true;
    auto input = fixture / reqOrEmpty(scene, "spec");
    Strings command{tool.string()};
    auto add = [&](const Strings &args) { command.insert(command.end(), args.begin(), args.end()); };
    if (runner == "lud-window") {
      add({(fixture / "lud-input.bin").string(), (fixture / "lud-reference.bin").string(),
           std::to_string(rep), csv.string()});
      add(paths);
    } else if (runner == "ced-graph") {
      add({input.string()});
      add(paths);
      add({std::to_string(rep), csv.string()});
    } else if (runner == "srad-graph") {
      add({fixture.string(), std::to_string(rep), csv.string()});
      add(paths);
    } else if (runner == "sort" || runner == "nqu") {
      csv = stdoutPath;
      if (runner == "sort") {
        millis = false;
        add({name, std::to_string(rep), "0", (fixture / "input").string(),
             (fixture / "reference").string()});
      } else {
        group = rep;
        add({(fixture / "input").string(), (fixture / "reference").string(),
             std::to_string(count * group), "timed"});
      }
      add(paths);
    } else {
      millis = false;
      const auto target = dir / "runner";
      csv = target / (runner == "tigre" ? "timing.csv" : "samples.csv");
      if (runner == "tpacf")
        group = rep;
      add({"--kernel", paths.front(), "--reference", paths.front(), "--candidate", paths.back(),
           "--input", input.string(), "--output", target.string(), "--mode", "benchmark",
           "--warmup", "0", "--repeat", std::to_string(runner == "tpacf" ? 1 : rep),
           "--windows", std::to_string(count * group)});
      const auto moduleList = dir / "modules.txt";
      {
        std::ofstream list(moduleList);
        for (const auto &path : paths)
          list << path << '\n';
        if (!list)
          throw std::runtime_error("cannot write resident module list");
      }
      setenv("ACCEPT_BATCH_OBJECTS", moduleList.c_str(), 1);
    }
    setenv("KBS_WINDOWS", std::to_string(count).c_str(), 1);
    Array argv;
    for (const auto &argument : command)
      argv.push_back(argument);
    writeJSON(dir / "command.json", std::move(argv));
    run(command, stdoutPath, dir / "runner.log");
    return parseSamples(csv, runner, count, rep, group, millis, paths.size());
  }

  static std::string reqOrEmpty(const Object &row, StringRef key) {
    return row.getString(key).getValueOr("").str();
  }

  static Samples parseSamples(const fs::path &path, const std::string &runner,
                              int count, int rep, int group, bool millis, size_t roles) {
    auto split = [](const std::string &row) {
      llvm::SmallVector<StringRef, 12> fields;
      StringRef(row).split(fields, ',');
      return fields;
    };
    std::ifstream file(path);
    std::string line;
    std::getline(file, line);
    const auto headers = split(line);
    std::map<std::string, size_t> cols;
    for (size_t i = 0; i < headers.size(); ++i)
      cols.emplace(headers[i].trim().str(), i);
    using Series = std::map<std::string, std::vector<double>>;
    std::vector<std::vector<Series>> rows(count, std::vector<Series>(roles));
    while (std::getline(file, line)) {
      const auto fields = split(line);
      auto get = [&](const std::string &field) {
        const auto position = cols.at(field);
        if (position >= fields.size())
          throw std::runtime_error("incomplete row in " + path.string());
        return fields[position].trim().str();
      };
      if (runner == "nqu") {
        if (get("solutions") != "2279184" || get("input_fingerprint") != "dce970f2732b8f02" ||
            get("output_fingerprint") != "3fa1162a3cadaeea")
          throw std::runtime_error("NQU64 output differs from frozen reference");
      } else if (runner != "tigre" && get("full_output_passed") != "1") {
        throw std::runtime_error("full output validation failed in " + path.string());
      }
      int window = std::stoi(get(cols.count("window") ? "window" : "round"));
      if (runner == "sort")
        --window;
      const auto roleName = get(runner == "tigre" ? "variant" : "role");
      size_t role;
      if (runner == "sort" && !StringRef(roleName).startswith("state")) {
        const Strings order{"baseline", "A", "D", "Dprime", "E", "F", "G", "H"};
        role = std::distance(order.begin(), std::find(order.begin(), order.end(), roleName));
      } else {
        auto index = StringRef(roleName);
        index.consume_front("state");
        role = std::stoul(index.str());
      }
      const double us = std::stod(get(runner == "tigre" ? "ms" : millis ? "milliseconds" : "microseconds")) * (millis || runner == "tigre" ? 1000 : 1);
      if (!std::isfinite(us) || us <= 0)
        throw std::runtime_error("invalid sample in " + path.string());
      rows.at(window / group).at(role)[runner == "tigre" ? get("batch") : "0"].push_back(us);
    }
    const size_t expected = runner == "sort" ? 1 : rep;
    Samples results(count, std::vector<double>(roles));
    for (size_t window = 0; window < rows.size(); ++window)
      for (size_t role = 0; role < roles; ++role) {
        const auto &series = rows[window][role];
        if (series.size() != (runner == "tigre" ? 6 : 1))
          throw std::runtime_error("missing sample series in " + path.string());
        for (const auto &[angle, values] : series) {
          if (values.size() != expected)
            throw std::runtime_error("unexpected sample count in " + path.string());
          results[window][role] += median(values);
        }
      }
    return results;
  }

  Object runScene(const Object &scene, const std::string &only) const {
    const auto start = Clock::now();
    auto name = req(scene, "name");
    auto dir = output / identifier(name);
    fs::create_directories(dir);
    const auto fixture = fixtures(scene, dir);
    auto objectsForCase = modules(scene, fixture, dir, only);
    const auto runner = executable(req(scene, "runner"));
    Object result{{"scenario", name}, {"quick", quick},
                  {"runner_sha256", sha(runner, dir)}, {"environment", Object(environment)},
                  {"compile", std::move(objectsForCase.builds)}};
    Object hashes;
    for (const auto &[variant, role] : objectsForCase.roles)
      hashes[variant] = objectsForCase.digests[role];
    result["sha256"] = std::move(hashes);
    auto uniqueAttempt = dir / ("attempt-" + std::to_string(Clock::now().time_since_epoch().count()));
    if (!only.empty()) {
      auto sample = launch(scene, fixture, objectsForCase.paths, uniqueAttempt / "run", 1, 1);
      result["status"] = "verified";
      result["microseconds"] = sample.at(0).at(0);
      result["raw_directory"] = (uniqueAttempt / "run").string();
    } else {
      Strings control(2, objectsForCase.paths.at(objectsForCase.roles.at("base")));
      Array aa;
      int rep = 0;
      const auto *protocol = scene.getArray("repetitions");
      for (size_t attempt = 0; attempt < (quick ? 1 : protocol->size()); ++attempt) {
        int setting = *(*protocol)[attempt].getAsInteger();
        int samples = setting ? setting : *scene.getInteger("release_repetitions");
        if (quick)
          samples = *scene.getInteger("quick_repetitions");
        const auto summary = ratio(launch(scene, fixture, control,
                                    uniqueAttempt / ("aa-" + std::to_string(attempt + 1)),
                                    windows, samples), 1, 0);
        auto receipt = summary.receipt();
        receipt["repetitions"] = samples;
        aa.push_back(std::move(receipt));
        if (std::abs(summary.point - 1) <= 0.01 && summary.spread <= 0.03) {
          rep = samples;
          break;
        }
      }
      result["aa"] = std::move(aa);
      result["raw_directory"] = uniqueAttempt.string();
      if (rep) {
        auto samples = launch(scene, fixture, objectsForCase.paths, uniqueAttempt / "compare", windows, rep);
        Object ratios;
        const auto &roles = objectsForCase.roles;
        for (const auto &[variant, role] : roles)
          if (variant != "base")
            ratios["base/" + variant] = ratio(samples, roles.at("base"), role).receipt();
        for (const std::string variant : {"darm", "darm-best"})
          ratios["anchor/" + variant] = ratio(samples, roles.at("anchor"), roles.at(variant)).receipt();
        result["ratios"] = std::move(ratios);
        Object windowSamples;
        for (const auto &[variant, role] : roles) {
          Array values;
          for (const auto &batch : samples)
            values.push_back(batch[role]);
          windowSamples[variant] = std::move(values);
        }
        result["window_microseconds"] = std::move(windowSamples);
        result["repetitions"] = rep;
      }
      result["status"] = rep ? "measured" : "unreliable";
    }
    result["seconds"] = seconds(start);
    return result;
  }
};

std::string decimal(double value, unsigned digits = 5) {
  std::ostringstream stream;
  stream << std::fixed << std::setprecision(digits) << value;
  return stream.str();
}

constexpr const char *Speedups[] = {"base/bf", "base/darm", "base/darm-best", "base/anchor"};
constexpr const char *DarmRatios[] = {"anchor/darm", "anchor/darm-best"};

std::string interval(const Object *metrics) {
  if (!metrics)
    return "—";
  return decimal(*metrics->getNumber("median")) + " [" + decimal(*metrics->getNumber("lower")) +
      ", " + decimal(*metrics->getNumber("upper")) + "]";
}

void writeReport(const Measurement &m) {
  auto mode = m.quick ? "quick" : "full";
  std::ofstream md(m.output / "report.md"), csv(m.output / "report.csv");
  md << "# KBS gfx906 performance results\n\n"
     << (m.quick ? "**快速模式，区间仅供参考**\n\n" : "**完整协议**\n\n");
  std::map<std::string, llvm::json::Value> rows;
  Strings missing;
  for (const auto &value : *m.scenes) {
    auto name = req(*value.getAsObject(), "name");
    const auto file = m.output / identifier(name) / "compare.json";
    if (fs::exists(file))
      rows.emplace(name, json(file));
    else
      missing.push_back(name);
  }
  csv << "table,input,mode,status,variant,estimate,lower95,upper95\n";
  auto render = [&](const char *heading, const char *table, const auto &keys, bool means) {
    md << "## " << heading << "\n\n| Frozen input |";
    for (const auto *key : keys)
      md << ' ' << key << " |";
    md << "\n|---|";
    for (size_t i = 0; i < std::size(keys); ++i)
      md << "---:|";
    md << '\n';
    std::map<std::string, std::vector<double>> geomean;
    for (const auto &[name, value] : rows) {
      const auto &receipt = *value.getAsObject();
      const auto *measurements = receipt.getObject("ratios");
      md << "| " << name << " |";
      for (const auto *key : keys) {
        const auto *datum = measurements ? measurements->getObject(key) : nullptr;
        const bool bfException = StringRef(key) == "base/bf" && StringRef(name).startswith("vllm/");
        md << ' ' << (bfException ? "Unavailable [^bf]" :
                       measurements ? interval(datum) : "Unreliable [^aa]");
        if (StringRef(name).startswith("vllm/") && StringRef(key).contains("darm"))
          md << " [^darm]";
        md << " |";
        csv << table << ',' << name << ',' << mode << ',' << (bfException ? "unavailable" :
               req(receipt, "status")) << ',' << key << ',';
        if (datum) {
          const auto point = *datum->getNumber("median");
          geomean[key].push_back(std::log(point));
          csv << decimal(point, 9) << ',' << decimal(*datum->getNumber("lower"), 9)
              << ',' << decimal(*datum->getNumber("upper"), 9);
        } else {
          csv << ",,";
        }
        csv << '\n';
      }
      md << '\n';
    }
    if (means) {
      md << "| Geometric mean (measured inputs) |";
      for (const auto *key : keys) {
        const auto &values = geomean[key];
        if (values.empty()) {
          md << " — |";
          continue;
        }
        const auto point = std::exp(std::accumulate(values.begin(), values.end(), 0.0) / values.size());
        md << ' ' << decimal(point) << " (n=" << values.size() << ") |";
        csv << table << ",geomean," << mode << ",measured," << key << ',' << decimal(point, 9) << ",,\n";
      }
      md << '\n';
    }
    md << '\n';
  };
  render("1. Speedup relative to base, with paired 95% intervals", "speedup", Speedups, true);
  render("2. Anchor execution-time ratios, with paired 95% intervals", "ratio", DarmRatios, false);
  md << "The external comparison uses the fastest measured pristine DARM object. "
        "Where 14a did not establish reliable pristine timing, its registered pristine object is identified below.\n\n";
  md << "## 3. Build time in seconds\n\n| Case | base | bf | darm | anchor |\n|---|---:|---:|---:|---:|\n";
  std::set<std::string> cases;
  std::map<std::string, double> elapsed;
  for (const auto &[name, value] : rows) {
    auto &receipt = *value.getAsObject();
    const auto caseName = StringRef(name).split('/').first.str();
    elapsed[caseName] += *receipt.getNumber("seconds");
    if (!cases.insert(caseName).second)
      continue;
    md << "| " << caseName << " |";
    for (const auto *variant : Variants) {
      auto *build = receipt.getObject("compile")->getObject(variant);
      md << ' ' << (build ? decimal(*build->getNumber("seconds"), 3) :
                          caseName == "vllm" ? "Unavailable [^bf]" : "—") << " |";
      csv << "compile," << caseName << ',' << mode << ',' << (build ? "measured" : "unavailable")
          << ',' << variant << ',' << (build ? decimal(*build->getNumber("seconds"), 6) : "") << ",,\n";
    }
    md << '\n';
  }
  md << "\nDARM-best is an archived object and has no artifact build time.\n\n"
     << "## Inputs and receipts\n\n";
  double total = 0;
  for (const auto &[name, time] : elapsed)
    total += time;
  md << "Elapsed work for completed inputs: " << decimal(total, 2) << " s. "
     << rows.size() << '/' << m.scenes->size() << " inputs completed. ";
  std::vector<std::pair<std::string, double>> durations(elapsed.begin(), elapsed.end());
  std::sort(durations.begin(), durations.end(),
            [](const auto &a, const auto &b) { return a.second > b.second; });
  if (!durations.empty()) {
    md << "Longest cases: ";
    for (size_t i = 0; i < std::min<size_t>(3, durations.size()); ++i)
      md << (i ? ", " : "") << durations[i].first << ' ' << decimal(durations[i].second, 2) << " s";
    md << '.';
  }
  md << "\n\nMissing:";
  if (missing.empty())
    md << " none";
  for (const auto &name : missing)
    md << ' ' << name;
  md << ".\n\n";
  std::set<std::string> environments;
  for (const auto &[name, value] : rows) {
    const auto &receipt = *value.getAsObject();
    md << "<details><summary>" << name << " ("
       << req(receipt, "status") << ")</summary>\n\n"
       << "- Runner SHA-256 " << req(receipt, "runner_sha256") << "\n";
    for (const auto &[variant, hash] : *receipt.getObject("sha256"))
      md << "- " << variant.str() << ' ' << hash.getAsString()->str() << "\n";
    for (const auto &entry : *receipt.getArray("aa")) {
      const auto *aa = entry.getAsObject();
      md << "- A/A, " << *aa->getInteger("repetitions") << " samples/window: " << interval(aa)
         << ", spread " << decimal(100 * *aa->getNumber("spread"), 3) << "%\n";
    }
    auto &env = *receipt.getObject("environment");
    if (environments.insert(req(env, "kbs_sha256")).second)
      md << "\n" << req(env, "device") << "ROCm: " << req(env, "rocm")
         << "Linux: " << req(env, "kernel") << "Driver module: " << req(env, "kernel_driver")
         << "\nKBS SHA-256: " << req(env, "kbs_sha256") << "\n";
    md << "\n</details>\n\n";
  }
  md << "[^bf]: Upstream branch fusion on vLLM emits IR rejected by the verifier in the original opt, pristine plugin, and patched plugin.\n"
     << "[^aa]: The input exceeded its registered A/A tolerance. Its results are excluded from the geometric mean.\n"
     << "[^darm]: vLLM darm uses -disable-region-replication. The original exceeded 360 seconds.\n\n"
     << "SRAD-stage2/1024 is included in compilation verification only. "
        "CED/110 and SW2D/258x259 use the registered pristine object; 14a did not establish reliable fastest-object timings for these inputs.\n";
  if (!md || !csv)
    throw std::runtime_error("cannot write reports");
  std::cout << m.output / "report.md" << '\n' << m.output / "report.csv" << '\n';
}

int measurementCommand(const Artifact &artifact, StringRef command, int argc, char **argv) {
  const auto start = Clock::now();
  std::set<std::string> names;
  std::string variant;
  bool quick = false, force = false;
  fs::path root, objects;
  for (int i = 2; i < argc; ++i) {
    StringRef option(argv[i]);
    if (option == "--quick") quick = true;
    else if (option == "--force") force = true;
    else if (i + 1 < argc && (option == "--out" || option == "--case" ||
                              option == "--variant" || option == "--objects")) {
      std::string value = argv[++i];
      if (option == "--out") root = value;
      else if (option == "--objects") objects = value;
      else if (option == "--case") names.insert(value);
      else variant = value;
    } else throw std::runtime_error("invalid option: " + option.str());
  }
  if (command == "run" && (quick || names.size() != 1 || !llvm::is_contained(RunVariants, variant)))
    throw std::runtime_error("run requires one --case and one --variant");
  if (command != "run" && !variant.empty())
    throw std::runtime_error("--variant is only valid for run");
  if (command == "report" && (force || !names.empty() || !objects.empty()))
    throw std::runtime_error("report accepts --out and --quick");
  if (root.empty())
    root = "kbs-results";
  root = fs::absolute(root);
  if (objects.empty())
    objects = root / "objects";
  const auto output = root / (command == "run" ? "single" : quick ? "quick" : "full");
  fs::create_directories(output);
  Measurement measure(artifact, output, fs::absolute(objects), quick);
  if (command == "report") {
    writeReport(measure);
    return 0;
  }
  std::vector<const Object *> selected;
  std::set<std::string> matched;
  for (const auto &entry : *measure.scenes) {
    const auto &scene = *entry.getAsObject();
    const auto name = req(scene, "name"), caseName = req(scene, "case");
    if (names.empty() || names.count(name) || names.count(caseName)) {
      selected.push_back(&scene);
      if (names.count(name)) matched.insert(name);
      if (names.count(caseName)) matched.insert(caseName);
    }
  }
  if (matched != names)
    throw std::runtime_error("unknown case or input");
  if (command == "run" && variant == "bf") {
    const auto &row = *artifact.cases.at(req(*selected.front(), "case"));
    if (row.getString("bf_unavailable"))
      throw CommandFailure(Unavailable, req(row, "bf_unavailable"));
  }
  GpuLock lock(setting("KBS_GPU_LOCK", "/tmp/kbs-gfx906.lock"));
  fs::create_directories(measure.objects);
  measure.inspectEnvironment();
  for (const auto *scene : selected) {
    auto name = req(*scene, "name");
    auto file = output / identifier(name) / (command == "run" ? variant + ".json" : "compare.json");
    if (command == "compare" && !force && fs::is_regular_file(file)) {
      std::cout << name << " already complete\n";
      continue;
    }
    std::cout << "Running " << name << std::endl;
    auto receipt = measure.runScene(*scene, variant);
    std::cout << name << ' ' << req(receipt, "status") << ' '
              << decimal(*receipt.getNumber("seconds"), 2) << " s";
    if (auto sample = receipt.getNumber("microseconds"))
      std::cout << ' ' << *sample << " us";
    std::cout << ' ' << file << std::endl;
    writeJSON(file, std::move(receipt));
  }
  writeJSON(output / "provenance.json", Object{{"environment", Object(measure.environment)},
                                               {"last_invocation_seconds", seconds(start)}});
  std::cout << "Total: " << decimal(seconds(start), 3) << " s\n";
  return 0;
}
