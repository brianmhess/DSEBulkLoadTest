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

  srand48(seed);
  for (i = 0; i < numrecs; i++) {
    printf("%lld,%lld,%lld", (long long)(drand48() * keyrange), i, (long long)(drand48() * range[0]));
    for (j = 1; j < numcols; j++)
      printf("%c%lld", delim, (long long)(drand48() * range[j]));
    printf("\n");
  }

  return 0;
}
