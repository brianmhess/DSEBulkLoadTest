# DSEBulkLoadTest

To set up, run
```
make clean
make dirs
make compile
```

To create the data, run
```
make data
```

To run the TestSSTableWriter test, run
```
/usr/bin/time make -j10 -f Makefile.test test100b
```

You can also use the other targets:
```
/usr/bin/time make -j10 -f Makefile.test test10kb
/usr/bin/time make -j10 -f Makefile.test test1mb
/usr/bin/time make -j10 -f Makefile.test test10
```
