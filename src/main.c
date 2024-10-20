#include "greeting.h"
#include <stdio.h>
#include <stdlib.h>

int main(void) {
  const char *const greeting = get_greeting();
  printf("%s\n", greeting);

  return EXIT_SUCCESS;
}
