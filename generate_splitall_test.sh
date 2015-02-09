#!/bin/sh

nodetool status | grep "^UN" | awk '{printf("%s ", $2)}' | awk '{printf("###Splitall100b\nsplitall100b:"); for(i=1; i<=NF; i++) { for (j=0; j<10; j++) { printf(" splitall100b_%d_%s", j, $i); } } printf("\n\n"); for (i=1; i<=NF; i++) { for (j=0; j<10; j++) { printf("splitall100b_%d_%s:\n\t- mkdir -p out/split100b/%s/%d/test/test100b\n\tjava -cp `./cassandra-classpath` TestSSTableWriterSplit in/data100b_%d.csv out/split100b/%s/%d/test/test100b test test100b %s\n\n", j, $i, $i, j, j, $i, j, $i); } } } END {printf("\n\n\n")}' > Makefile.splits
nodetool status | grep "^UN" | awk '{printf("%s ", $2)}' | awk '{printf("###Splitall10kb\nsplitall10kb:"); for(i=1; i<=NF; i++) { for (j=0; j<10; j++) { printf(" splitall10kb_%d_%s", j, $i); } } printf("\n\n"); for (i=1; i<=NF; i++) { for (j=0; j<10; j++) { printf("splitall10kb_%d_%s:\n\t- mkdir -p out/split10kb/%s/%d/test/test10kb\n\tjava -cp `./cassandra-classpath` TestSSTableWriterSplit in/data10kb_%d.csv out/split10kb/%s/%d/test/test10kb test test10kb %s\n\n", j, $i, $i, j, j, $i, j, $i); } } } END {printf("\n\n\n")}' >> Makefile.splits
nodetool status | grep "^UN" | awk '{printf("%s ", $2)}' | awk '{printf("###Splitall1mb\nsplitall1mb:"); for(i=1; i<=NF; i++) { for (j=0; j<10; j++) { printf(" splitall1mb_%d_%s", j, $i); } } printf("\n\n"); for (i=1; i<=NF; i++) { for (j=0; j<10; j++) { printf("splitall1mb_%d_%s:\n\t- mkdir -p out/split1mb/%s/%d/test/test1mb\n\tjava -cp `./cassandra-classpath` TestSSTableWriterSplit in/data1mb_%d.csv out/split1mb/%s/%d/test/test1mb test test1mb %s\n\n", j, $i, $i, j, j, $i, j, $i); } } } END {printf("\n\n\n")}' >> Makefile.splits
nodetool status | grep "^UN" | awk '{printf("%s ", $2)}' | awk '{printf("###Splitall10\nsplitall10:"); for(i=1; i<=NF; i++) { for (j=0; j<10; j++) { printf(" splitall10_%d_%s", j, $i); } } printf("\n\n"); for (i=1; i<=NF; i++) { for (j=0; j<10; j++) { printf("splitall10_%d_%s:\n\t- mkdir -p out/split10/%s/%d/test/test10\n\tjava -cp `./cassandra-classpath` TestSSTableWriterSplit in/data10_%d.csv out/split10/%s/%d/test/test10 test %s\n\n", j, $i, $i, j, j, $i, j, $i); } } } END {printf("\n\n\n")}' >> Makefile.splits
