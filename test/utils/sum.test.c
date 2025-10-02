#include <assert.h>
#include <stdlib.h>
#include <utils/sum.h>

int main(void) {
  assert(3 == sum_int(1, 2));
  return EXIT_SUCCESS;
}