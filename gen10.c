#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
  int numcols = 8;
  long long range[8] = {100, 100, 100, 100, 200, 200, 200, 200};
  long long keyrange = 10000;
  char delim = ',';
  long long j;
  long long i;

  if (3 != argc) {
    fprintf(stderr, "Usage: %s <number of points> <rand seed>\n", argv[0]);
    return 1;
  }

  char *endptr;
  long long numrecs = strtoll(argv[1], &endptr, 10);
  int seed = atoi(argv[2]);

  struct drand48_data lcg;
  srand48_r(seed, &lcg);
  double rval;
  for (i = 0; i < numrecs; i++) {
    drand48_r(&lcg, &rval);
    printf("%lld,%lld", (long long)(rval * keyrange), i);
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
