#include <hip/hip_runtime.h>
#include <iostream>
#include <string>

int main() {
  hipDeviceProp_t properties{};
  int driver, runtime;
  if (hipGetDeviceProperties(&properties, 0) != hipSuccess ||
      hipDriverGetVersion(&driver) != hipSuccess ||
      hipRuntimeGetVersion(&runtime) != hipSuccess) {
    std::cerr << "Cannot query HIP device and runtime\n";
    return 1;
  }
  std::string arch(properties.gcnArchName);
  if (arch.substr(0, arch.find(':')) != "gfx906" || properties.warpSize != 64) {
    std::cerr << "Expected gfx906 wave64, found " << arch << '\n';
    return 1;
  }
  std::cout << "GPU: " << properties.name << " (" << arch << ")\n"
            << "HIP driver: " << driver << "\nHIP runtime: " << runtime << '\n';
}
