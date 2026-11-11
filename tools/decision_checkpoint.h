#pragma once

#include "llvm/Support/JSON.h"
#include <stdexcept>

namespace decision {
struct BackendResources {
 int64_t vgpr, sgpr, vgprSpills, sgprSpills, occupancy;

 static BackendResources parse(const llvm::json::Value &value) {
  auto *object=value.getAsObject();
  auto required=[&](llvm::StringRef name) {
   auto number=object?object->getInteger(name):llvm::None;
   if(!number||*number<0)
    throw std::runtime_error("invalid checkpoint metric: "+name.str());
   return *number;
  };
  BackendResources resources{required("vgpr_count"),required("sgpr_count"),
    required("vgpr_spill_count"),required("sgpr_spill_count"),
    required("active_blocks_per_cu")};
  if(!resources.occupancy)throw std::runtime_error("checkpoint occupancy is zero");
  return resources;
 }

 bool passes(const BackendResources &initial) const {
  return vgprSpills<=initial.vgprSpills&&sgprSpills<=initial.sgprSpills&&
         occupancy>=initial.occupancy;
 }

 llvm::json::Object report() const {
  return llvm::json::Object{{"vgpr_count",vgpr},{"sgpr_count",sgpr},{"vgpr_spill_count",vgprSpills},
          {"sgpr_spill_count",sgprSpills},{"active_blocks_per_cu",occupancy}};
 }
};
}
