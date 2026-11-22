#include <stdbool.h>
#include <stdlib.h>

int auto_guard_reference(bool cond, int *memory, int x);
int auto_guard_fused(bool cond, int *memory, int x);

int main(void) {
  for (int cond = 0; cond < 2; ++cond) {
    for (int x = -32; x <= 32; ++x) {
      int baseline = x + 99, fused = baseline;
      int expected = auto_guard_reference(cond, &baseline, x);
      int actual = auto_guard_fused(cond, &fused, x);
      if (actual != expected || fused != baseline)
        return EXIT_FAILURE;
    }
  }
  return EXIT_SUCCESS;
}
