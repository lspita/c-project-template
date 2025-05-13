#include <stdio.h>
#include <stdlib.h>

#include "utils/sum.h"

int main(void) {
  printf("Hello, world!\n");
  printf("1 + 2 = %d\n", sum_int(1, 2));
  return EXIT_SUCCESS;
}
