#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
  int numcols = 98;
  long long range[98] = {};
  long long keyrange = 10000;
  char delim = ',';
  long long j;
  long long i;

  if (4 != argc) {
    fprintf(stderr, "Usage: %s <number of points> <start> <rand seed>\n", argv[0]);
    return 1;
  }

  char *endptr;
  long long numrecs = strtoll(argv[1], &endptr, 10);
  long long start = strtoll(argv[2], &endptr, 10) * numrecs;
  int seed = atoi(argv[3]);

  for (i = 0; i < 49; i++)
    range[i] = 1000;
  for (i = 49; i < 98; i++)
    range[i] = 2000;

  struct drand48_data lcg;
  srand48_r(seed, &lcg);
  double rval;
  for (i = 0; i < numrecs; i++) {
    drand48_r(&lcg, &rval);
    printf("%lld,%lld", (long long)(rval * keyrange), i + start);
    drand48_r(&lcg, &rval);
    printf(",%lld", (long long)(rval * range[0]));
    for (j = 1; j < numcols; j++) {
      drand48_r(&lcg, &rval);
      printf("%c%lld", delim, (long long)(rval * range[j]));
    }
    printf("\n");
  }

  return 0;
}
