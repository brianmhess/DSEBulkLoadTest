# DSEBulkLoadTest

## Setup

You will need to update the CLASSPATH variable in the Makefile.
I have created a simple shell script that prints out the classpath
for the machine I did development on - called cassandra-classpath.
You can either alter that script or simply edit it in the Makefile.
The Makefile.test gets its CLASSPATH from Makefile, so you only need
to change it once.

To set up, run
```
make clean
make dirs
make compile
```

To see the command being run, you can run make with "-n"
```
make -n compile
```

## Cassandra Setup

To create the Cassandra keyspace and tables, run
```
make ddl
```

To truncate the Cassandra tables, run
```
make truncate
```

Or
```
make truncate100b
make truncate1kb
make truncate10kb
make truncate1mb
make truncate10
```

## Data

There are 5 data sets we are going to consider:
1. 100 Bytes/record
2. 1KB/record
3. 10KB/record
4. 1MB/record
5. 10 BIGINT columns

For data sets 1, 2, 3, and 4, we have 3 columns.  The first is the partition key and is a 12-byte TEXT field.  
The second is a BIGINT clustering column.  The third is a TEXT field to fill up the rest of the bytes.
They all have the same schema: `(pkey TEXT, ccol BIGINT, data TEXT)`

Data set 5 is 10 BIGINT columns.  
The schema is: `(pkey BIGINT, ccol BIGINT, c1 BIGINT, c2 BIGINT, c3 BIGINT, c4 BIGINT, c5 BIGINT, c6 BIGINT, c7 BIGINT, c8 BIGINT)`

All data is generated randomly using the `gen` or `gen10` program.  They each take a random seed. 
All of the data is comma-separated.  The TEXT fields are pseudo-base64 (that is, they are randomly generated
strings where the characters of the strings are random characters taken from `A-Za-z0-0+=`).

To create the data, run
```
make data
```


## SSTableWriter Test

To run the TestSSTableWriter test, run
```
/usr/bin/time make -j10 -f Makefile.test test100b
```

You can configure the parallelism with different "-j" value

You can also use the other targets:
```
/usr/bin/time make -j10 -f Makefile.test test10kb
/usr/bin/time make -j10 -f Makefile.test test1mb
/usr/bin/time make -j10 -f Makefile.test test10
```

## sstableloader Test

To run the sstableloader test, run
```
/usr/bin/time make -j10 sstable100b
```

You can also use the other targets:
```
/usr/bin/time make -j10 sstable10kb
/usr/bin/time make -j10 sstable1mb
/usr/bin/time make -j10 sstable10
```

## executeAsync Test

To run the ExecAsync test, run
```
/usr/bin/time make -j10 exec100b
```

You can also use the other targets:
```
/usr/bin/time make -j10 exec10kb
/usr/bin/time make -j10 exec1mb
/usr/bin/time make -j10 exec10
```

## C-based executeAsync Test

This test is a little different.  There
are 3 ways to run this test, with 3 different
levels of parallelism - 3, 4, and 5 runs.

To run it, rut
```
/usr/bin/time make cppall3
```

You can also use the other parallelisms:
```
/usr/bin/time make cppall4
/usr/bin/time make cppall5
```

## COPY FROM Test

To run the COPY FROM test, run
```
/usr/bin/time make -j10 copy100b
```

You can also use the other targets:
```
/usr/bin/time make -j10 copy10kb
/usr/bin/time make -j10 copy1mb
/usr/bin/time make -j10 copy10
```




