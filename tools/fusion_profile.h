#pragma once
#include "llvm/Support/JSON.h"
#include <chrono>
#include <map>
#include <string>
#include <type_traits>
namespace fusion {
// Per-request inclusive timings. Parent/child scopes overlap: do not sum them.
struct ProfileValue { double ms=0; long calls=0; };
inline thread_local std::map<std::string,ProfileValue> requestProfile;
struct ProfileScope {
 std::string name;std::chrono::steady_clock::time_point start;
 explicit ProfileScope(const char *n):name(n),start(std::chrono::steady_clock::now()){}
 ~ProfileScope(){auto &v=requestProfile[name];++v.calls;v.ms+=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-start).count();}
};
template<class F> auto profileCall(const char *name,F &&f) {
 ProfileScope scope(name);
 if constexpr(std::is_void_v<std::invoke_result_t<F>>) { f(); }
 else { return f(); }
}
inline llvm::json::Object profileJSON(){llvm::json::Object result;for(auto &kv:requestProfile)result[kv.first]=llvm::json::Object{{"calls",int64_t(kv.second.calls)},{"inclusive_ms",kv.second.ms}};return result;}
}
