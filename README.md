# DSEBulkLoadTest

## Setup

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
make truncate10kb
make truncate1mb
make truncate10
```

## Data

There are 4 data sets we are going to consider:
1. 100 Bytes/record
2. 10KB/record
3. 1MB/record
4. 10 BIGINT columns

For data sets 1, 2, and 3, we have 3 columns.  The first is the partition key and is a 12-byte TEXT field.  
The second is a BIGINT clustering column.  The third is a TEXT field to fill up the rest of the bytes.
They all have the same schema: `(pkey TEXT, ccol BIGINT, data TEXT)`

Data set 4 is 10 BIGINT columns.  
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




