cmake_minimum_required(VERSION 3.18)
project(KernelBenchmarkArtifact LANGUAGES CXX)

find_program(LLVM_CONFIG NAMES llvm-config-12 llvm-config REQUIRED)
function(llvm_config output)
  execute_process(COMMAND "${LLVM_CONFIG}" ${ARGN}
    RESULT_VARIABLE status OUTPUT_VARIABLE value OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(NOT status EQUAL 0)
    message(FATAL_ERROR "llvm-config ${ARGN} failed")
  endif()
  set("${output}" "${value}" PARENT_SCOPE)
endfunction()
llvm_config(llvm_version --version)
if(NOT llvm_version MATCHES "^12[.]")
  message(FATAL_ERROR "The artifact requires LLVM 12")
endif()
llvm_config(llvm_include --includedir)
llvm_config(llvm_libraries --link-shared --libfiles)
separate_arguments(llvm_libraries NATIVE_COMMAND "${llvm_libraries}")

set(DARM_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../tools/darm_artifact")
set(DARM_UNITS CFMelderUtils InstructionMatch RegionAnalyzer RegionMelder
    RegionReplicator)
set(DARM_PATCH "${CMAKE_CURRENT_SOURCE_DIR}/patches/cfmelder-determinism.patch")
set(PATCHED_DARM_DIR "${CMAKE_CURRENT_BINARY_DIR}/cfmelder-patched")
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${DARM_PATCH}")

file(GLOB DARM_HEADERS CONFIGURE_DEPENDS "${DARM_DIR}/*.h")
foreach(header IN LISTS DARM_HEADERS)
  get_filename_component(name "${header}" NAME)
  configure_file("${header}" "${PATCHED_DARM_DIR}/${name}" COPYONLY)
endforeach()
foreach(unit IN LISTS DARM_UNITS)
  configure_file("${DARM_DIR}/${unit}.cpp"
    "${PATCHED_DARM_DIR}/${unit}.cpp" COPYONLY)
endforeach()

find_program(PATCH_EXECUTABLE NAMES patch REQUIRED)
execute_process(COMMAND "${PATCH_EXECUTABLE}" --batch --forward -p3 -i "${DARM_PATCH}"
  WORKING_DIRECTORY "${PATCHED_DARM_DIR}" RESULT_VARIABLE patch_result
  OUTPUT_VARIABLE patch_output ERROR_VARIABLE patch_error)
if(NOT patch_result EQUAL 0)
  message(FATAL_ERROR "CFMelder determinism patch failed:
${patch_output}${patch_error}")
endif()

function(add_cfmelder_plugin target sources)
  add_library("${target}" MODULE CFMelder.cpp PassRegistration.cpp)
  foreach(unit IN LISTS DARM_UNITS)
    target_sources("${target}" PRIVATE "${sources}/${unit}.cpp")
  endforeach()
  target_compile_features("${target}" PRIVATE cxx_std_17)
  target_include_directories("${target}" PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}" "${sources}")
  target_include_directories("${target}" SYSTEM PRIVATE "${llvm_include}")
  target_compile_options("${target}" PRIVATE -include "${CMAKE_CURRENT_SOURCE_DIR}/PassRegistration.h")
  target_link_libraries("${target}" PRIVATE ${llvm_libraries})
endfunction()

add_cfmelder_plugin(kbs-darm "${PATCHED_DARM_DIR}")
add_cfmelder_plugin(kbs-darm-pristine "${DARM_DIR}")

find_package(ZLIB REQUIRED)
set(TOOLS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../tools")
set(RUNTIME "${CMAKE_CURRENT_BINARY_DIR}/runtime")

# Reuse the source preparation for the isolated DARM strategy compiled into
# fusion-search. The separately loaded opt plug-ins above use upstream names.
set(ISOLATED_DARM_DIR "${CMAKE_CURRENT_BINARY_DIR}/cfmelder-isolated")
foreach(header IN LISTS DARM_HEADERS)
  get_filename_component(name "${header}" NAME)
  configure_file("${header}" "${ISOLATED_DARM_DIR}/${name}" COPYONLY)
endforeach()
foreach(unit IN LISTS DARM_UNITS)
  configure_file("${DARM_DIR}/${unit}.cpp"
    "${ISOLATED_DARM_DIR}/${unit}.cpp" COPYONLY)
endforeach()
foreach(patch 01-bf6a290.patch 02-isolate-symbols.patch)
  set(path "${DARM_DIR}/patches/${patch}")
  set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${path}")
  execute_process(COMMAND "${PATCH_EXECUTABLE}" --batch --forward -p1 -i "${path}"
    WORKING_DIRECTORY "${ISOLATED_DARM_DIR}" RESULT_VARIABLE status)
  if(NOT status EQUAL 0)
    message(FATAL_ERROR "Cannot prepare isolated DARM sources: ${patch}")
  endif()
endforeach()

function(use_llvm target)
  target_compile_features("${target}" PRIVATE cxx_std_17)
  target_compile_options("${target}" PRIVATE -UNDEBUG -O2)
  target_include_directories("${target}" PRIVATE "${TOOLS_DIR}")
  target_include_directories("${target}" SYSTEM PRIVATE "${llvm_include}")
  target_link_libraries("${target}" PRIVATE ${llvm_libraries})
endfunction()

add_library(kbs-isolated-darm STATIC "${DARM_DIR}/bridge.cpp")
foreach(unit IN LISTS DARM_UNITS)
  target_sources(kbs-isolated-darm PRIVATE "${ISOLATED_DARM_DIR}/${unit}.cpp")
endforeach()
use_llvm(kbs-isolated-darm)
target_include_directories(kbs-isolated-darm PRIVATE "${ISOLATED_DARM_DIR}")
target_compile_options(kbs-isolated-darm PRIVATE -include "${DARM_DIR}/llvm12_compat.h")

add_library(kbs-fusion STATIC "${TOOLS_DIR}/ir_pressure.cpp" "${TOOLS_DIR}/fusion_search.cpp"
  "${TOOLS_DIR}/b2b_anchor.cpp" "${TOOLS_DIR}/b2b_anchor_observe.cpp")
foreach(unit IN LISTS DARM_UNITS)
  target_sources(kbs-fusion PRIVATE "${TOOLS_DIR}/darm_pair_engine/${unit}.cpp")
endforeach()
use_llvm(kbs-fusion)
target_compile_definitions(kbs-fusion PUBLIC FUSION_PACKAGED_LLVM12 FUSION_DETERMINISTIC_REGION_ORDER)
target_include_directories(kbs-fusion PUBLIC "${TOOLS_DIR}/darm_pair_engine")
target_link_libraries(kbs-fusion PUBLIC kbs-isolated-darm)

add_executable(fusion-search-llvm24 "${TOOLS_DIR}/fusion_search_llvm24_main.cpp")
use_llvm(fusion-search-llvm24)
target_link_libraries(fusion-search-llvm24 PRIVATE kbs-fusion)
set_target_properties(fusion-search-llvm24 PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${RUNTIME}/build/llvm24-tti")

add_executable(decision-greedy "${TOOLS_DIR}/decision_model.cpp" "${TOOLS_DIR}/decision_greedy_main.cpp")
use_llvm(decision-greedy)
target_link_libraries(decision-greedy PRIVATE kbs-fusion)
set_target_properties(decision-greedy PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${RUNTIME}/build/decision-fuse")

add_executable(kbs-tti tti_replay.cpp)
use_llvm(kbs-tti)
set_target_properties(kbs-tti PROPERTIES OUTPUT_NAME "run-llvm24-tti" RUNTIME_OUTPUT_DIRECTORY "${RUNTIME}/tools")

llvm_config(llvm_bindir --bindir)
add_executable(kbs kbs.cpp)
use_llvm(kbs)
target_link_libraries(kbs PRIVATE ZLIB::ZLIB)
target_compile_definitions(kbs PRIVATE KBS_LLVM_BIN="${llvm_bindir}"
  KBS_DATA_DIR="${CMAKE_CURRENT_SOURCE_DIR}")
add_dependencies(kbs decision-greedy fusion-search-llvm24 kbs-tti kbs-darm kbs-darm-pristine)

option(KBS_GPU_RUNNERS "Build the gfx906 timing runners" OFF)
if(KBS_GPU_RUNNERS)
  find_program(KBS_HIPCC NAMES hipcc HINTS /opt/rocm-6.3.3/bin /opt/rocm/bin REQUIRED)
  set(runners "${CMAKE_CURRENT_SOURCE_DIR}/runners")
  set(repo "${CMAKE_CURRENT_SOURCE_DIR}/..")
  file(GLOB runner_headers CONFIGURE_DEPENDS "${runners}/*.h" "${runners}/*.hpp"
    "${repo}/runner/*.hpp" "${repo}/regression/srad_measurement/*.hpp"
    "${repo}/cases/tigre-siddon/harness/*.hpp" "${repo}/cases/tigre-siddon/harness/*.inc")
  foreach(runner generic ced-graph srad-graph lud-window nqu sort tigre tpacf environment)
    set(source "${runners}/${runner}.hip")
    if(runner STREQUAL "generic")
      set(source "${runners}/generic.cpp")
    endif()
    set(output "${CMAKE_CURRENT_BINARY_DIR}/kbs-${runner}")
    add_custom_command(OUTPUT "${output}"
      COMMAND "${KBS_HIPCC}" -O2 -std=c++17 -DBENCH_HIP --offload-arch=gfx906
        -I "${repo}/runner" -I "${repo}/regression/srad_measurement"
        -I "${repo}/cases/tigre-siddon/harness" -x hip "${source}" -o "${output}"
      DEPENDS "${source}" ${runner_headers} VERBATIM)
    list(APPEND timing_runners "${output}")
  endforeach()
  add_custom_target(kbs-gpu-runners ALL DEPENDS ${timing_runners})

  add_executable(kbs-lud-fixture runners/lud-fixture.cpp)
  add_executable(kbs-sort-fixtures runners/sort-fixtures.cpp)
  add_executable(kbs-nqu-fixtures runners/nqu-fixtures.cpp)
  add_executable(kbs-srad-stage2-fixtures "${repo}/cases/srad-stage2/make_fixtures.cpp")
  set(fixture_source "${repo}/regression/generators/generated_fixtures.cpp")
  add_executable(kbs-vllm-fixtures "${fixture_source}")
  add_executable(kbs-mapairy-fixtures "${fixture_source}")
  target_compile_definitions(kbs-mapairy-fixtures PRIVATE MAPAIRY BOOST_MATH_STANDALONE)
  target_include_directories(kbs-mapairy-fixtures PRIVATE
    "${repo}/cases/boost-mapairy/source/boost-math/include")
  foreach(generator lud-fixture sort-fixtures nqu-fixtures srad-stage2-fixtures vllm-fixtures mapairy-fixtures)
    target_compile_features(kbs-${generator} PRIVATE cxx_std_17)
    target_compile_options(kbs-${generator} PRIVATE -O2 -ffp-contract=off -fno-fast-math)
  endforeach()
  add_dependencies(kbs kbs-gpu-runners kbs-lud-fixture kbs-sort-fixtures
    kbs-nqu-fixtures kbs-srad-stage2-fixtures kbs-vllm-fixtures kbs-mapairy-fixtures)
endif()
