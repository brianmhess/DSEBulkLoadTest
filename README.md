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

To create the data, run
```
make data
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




