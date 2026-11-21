from pathlib import Path
w = Path(__file__).resolve().parent
replay = Path('runner/replay.cpp').read_text()
replay = '#include "output_check.hpp"\n#include "window.hpp"\n' + replay
replay = replay.replace('std::ofstream addresses;', '''const char* requested = std::getenv("SRAD_MEASURE");
 need(requested && std::string(requested).size() == 2, "diagnostic measurement method");
 int method = requested[1] - '0';
 need(method >= 1 && method <= 3 && measurement.paired(), "invalid diagnostic method");
 const int count = std::stoi(std::getenv("SRAD_LAUNCHES"));
 const bool restoreBetween = std::getenv("SRAD_RESTORE_BETWEEN");
 TimedWindow timer(stream);
 std::ofstream summary(fs::path(o.output)/"windows.csv");
 summary<<"window,role,angle,microseconds,total_ms,launches\\n"<<std::setprecision(10);
 std::ofstream addresses;''')
begin = replay.index('Graph graph{}')
end = replay.index(' if(measurement.reallocate()||window+1==measurement.windows())',begin)
replay = replay[:begin] + '''
 auto ptr = [](Ptr p) {return reinterpret_cast<void *>(p);};
 const int snapshots = method == 3 ? (count / 50 + 2) : 0;
 std::map<std::string, Ptr> initialGpu;
 std::map<std::string, std::vector<Ptr>> checkpoints;
 for(auto &[name,b]:buffers) {
  std::vector<unsigned char> padded(b.initial.size()+2*guardBytes,0xa5);
  std::copy(b.initial.begin(),b.initial.end(),padded.begin()+guardBytes);
  initialGpu[name]=alloc(padded.size());
  upload(initialGpu[name],padded.data(),padded.size());
  upload(b.base,padded.data(),padded.size());
  for(int i=0; i<snapshots; ++i) checkpoints[name].push_back(alloc(padded.size()));
 }
 auto reset=[&] {
  for(auto &[name,b]:buffers)
   if(b.check!="readonly")
    copyDevice(ptr(b.base),ptr(initialGpu.at(name)),b.initial.size()+2*guardBytes,stream);
 };
 auto capture=[&](int slot) {
  for(auto &[name,b]:buffers)
   copyDevice(ptr(checkpoints.at(name).at(slot)),ptr(b.base),b.initial.size()+2*guardBytes,stream);
 };
 auto check=[&](int slot) {
  for(auto &[name,b]:buffers) {
   std::vector<unsigned char> padded(b.initial.size()+2*guardBytes);
   download(padded.data(),slot<0?b.base:checkpoints.at(name).at(slot),padded.size());
   auto *payload=padded.data()+guardBytes;
   b.got.assign(payload,payload+b.initial.size());
   bool pass=guardsMatch(padded)&&(b.exact.empty()||b.got==b.exact);
   if(b.check=="readonly") pass&=b.got==b.initial;
   else if(b.check=="exact") pass&=b.got==b.reference;
   else if(b.check=="f32") pass&=floatingOutputMatches<float>(payload,b.reference,b.atol,b.rtol);
   else if(b.check=="f64") pass&=floatingOutputMatches<double>(payload,b.reference,b.atol,b.rtol);
   else need(b.check=="geometry","unsupported diagnostic buffer "+name);
   if(!pass) {
    writebytes(fs::path(o.output)/(name+"-failure.bin"),padded);
    throw std::runtime_error("output/guard failure "+name+" checkpoint "+std::to_string(slot));
   }
  }
  if(geo) geometry(buffers,dims,nodes);
 };
 for(int position=0;position<measurement.roles();++position){
  const int role=measurement.role(window,position);
  auto invoke=[&]{launch(functions[role],grid,block,stream,argvp.data());};
  auto checkOutput=[&]{check(-1);};
  auto resetHost=[&] {
   for(auto &[name,b]:buffers) {
    std::vector<unsigned char> padded(b.initial.size()+2*guardBytes,0xa5);
    std::copy(b.initial.begin(),b.initial.end(),padded.begin()+guardBytes);
    upload(b.base,padded.data(),padded.size());
   }
  };
  timer.warm(reset,invoke);
  WindowResult stats;
  if(method==1) {
   std::vector<float> times;
   for(int i=0;i<o.repeat;++i)times.push_back(timer.single(resetHost,invoke,checkOutput));
   stats=summarizeWindow(std::move(times));
  } else if(method==2) {
   auto total=timer.batch(count,restoreBetween,reset,invoke,checkOutput);
   stats={total/count,total,count};
  } else {
   stats=summarizeWindow(timer.asynchronous(count,reset,invoke,capture,check));
  }
  summary<<window<<','<<Measurement::names[role]<<",0,"<<stats.median*1000<<','<<stats.total<<','<<stats.launches<<'\\n';
  summary.flush();
 }
 for(auto &[name,ptr]:initialGpu)release(ptr);
 for(auto &[name,slots]:checkpoints)for(auto slot:slots)release(slot);
''' + replay[end:]
(w/'replay.cpp').write_text(replay)
tigre=Path('cases/tigre-siddon/harness/bench.hip').read_text().replace('#include "../../../runner/measurement.hpp"','#include "measurement.hpp"\n#include "window.hpp"')
tigre=tigre.replace('auto launch=[&](Variant&v,int b)', 'hipStream_t stream;CK(hipStreamCreateWithFlags(&stream,hipStreamNonBlocking));\n auto launch=[&](Variant&v,int b)').replace('0,nullptr,args,nullptr','0,stream,args,nullptr')
start=tigre.index(' }else{need(options.mode=="benchmark"')
end=tigre.index(' for(auto&v:vars)CK(hipModuleUnload',start)
tigre=tigre[:start]+'''
 }else{
  const int method=std::getenv("SRAD_MEASURE")[1]-'0';
  const int count=std::stoi(std::getenv("SRAD_LAUNCHES"));
  need(measurement.paired(),"expected paired windows");
  TimedWindow timer(stream);
  std::ofstream times(out+"/windows.csv");
  times<<"window,role,angle,microseconds,total_ms,launches\\n";
  const size_t bytes=initial.size()*sizeof(float);
  void *initialGpu;
  CK(hipMalloc(&initialGpu,bytes));CK(hipMemcpy(initialGpu,initial.data(),bytes,hipMemcpyHostToDevice));
  std::vector<void*> checkpoints(method==3?count/50+2:0);
  for(auto &slot:checkpoints)CK(hipMalloc(&slot,bytes));
  auto reset=[&]{copyDevice(raw,initialGpu,bytes,stream);};
  auto capture=[&](int slot){copyDevice(checkpoints.at(slot),raw,bytes,stream);};
  auto resetHost=[&]{CK(hipMemcpy(raw,initial.data(),bytes,hipMemcpyHostToDevice));};
  for(int window=0;window<measurement.windows();++window){
   for(int position=0;position<measurement.roles();++position){
    auto &v=vars[measurement.role(window,position)];
    loadparams(v,0);
    timer.warm(reset,[&]{launch(v,0);});
    for(int b=0;b<6;++b){
     loadparams(v,b);
     auto invoke=[&]{launch(v,b);};
     auto checkOutput=[&]{check(v,b);};
     auto checkSlot=[&](int slot){
      CK(hipMemcpy(gpu.data(),checkpoints.at(slot),bytes,hipMemcpyDeviceToHost));
      if(!equal(gpu,b)) {
       writebin(out+"/failed-checkpoint.bin",gpu.data(),bytes);
       need(false,"TIGRE checkpoint output/guard mismatch");
      }
     };
     WindowResult stats;
     if(method==1){
      std::vector<float> samples;
      for(int i=0;i<options.repeat;++i)samples.push_back(timer.single(resetHost,invoke,checkOutput));
      stats=summarizeWindow(std::move(samples));
     }else if(method==2){
      auto total=timer.batch(count,false,reset,invoke,checkOutput);
      stats={total/count,total,count};
     }else{
      stats=summarizeWindow(timer.asynchronous(count,reset,invoke,capture,checkSlot));
     }
     times<<window<<','<<v.name<<','<<b<<','<<stats.median*1000<<','<<stats.total<<','<<stats.launches<<'\\n';
     times.flush();
    }
   }
  }
  for(auto slot:checkpoints)CK(hipFree(slot));
  CK(hipFree(initialGpu));
 }
''' + tigre[end:]
tigre=tigre.replace('release();printf("COMPLETE','release();CK(hipStreamDestroy(stream));printf("COMPLETE')
(w/'tigre.hip').write_text(tigre)
