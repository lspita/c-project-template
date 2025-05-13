#include "utils/sum.h"

#include <assert.h>
#include <stdlib.h>

#include "test_utils.h"

int main(void) {
  assert(3 == sum_int(1, 2));
  assert(0 == test_sin(0));
  return EXIT_SUCCESS;
}