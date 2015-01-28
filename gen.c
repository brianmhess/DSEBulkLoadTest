#include <stdio.h>
#include <stdlib.h>

char map(int idx) {
  if (idx < 0)
    return 'a';
  if (idx > 63)
    return 'z';
  if (idx < 26)
    return 'a' + idx;
  if (idx < 52)
    return 'A' + idx - 26;
  if (idx < 62)
    return '0' + idx - 52;
  if (idx == 62)
    return '+';
  if (idx == 63)
    return '=';
  return '=';
}

int main(int argc, char **argv) {
  if (argc != 4) {
    fprintf(stderr, "Usage: %s <number of points> <size of record> <rand seed>\n", argv[0]);
    return 1;
  }
  char *endptr;
  long long numrecs = strtoll(argv[1], &endptr, 10);
  long long recsize = strtoll(argv[2], &endptr, 10);
  if (recsize < 21) {
    fprintf(stderr, "record size must be at least 21 bytes\n");
    return 1;
  }
  int seed = atoi(argv[3]);
  char delim = ',';
  long long i;
  int j;
  double rval;

  struct drand48_data lcg;
  srand48_r(seed, &lcg);

  for (i = 0; i < numrecs; i++) {
    for (j = 0; j < 12; j++) {
      drand48_r(&lcg, &rval);
      printf("%c", map((int)(rval * 64)));
    }
    printf(",%lld,", i);
    for (j = 1; j < recsize - 20; j++) {
      drand48_r(&lcg, &rval);
      printf("%c", map((int)(rval * 64)));
    }
    printf("\n");
  }

  return 0;
}

