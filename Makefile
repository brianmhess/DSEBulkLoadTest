all: compile


### COMPILE
compile: gen gen10 TestSSTableWriter.class TestSSTableWriter10.class ExecAsync.class ExecAsync10.class TestSSTableWriterSplit.class TestSSTableWriterSplit10.class

gen: gen.c
	gcc -o gen gen.c

gen10: gen10.c
	gcc -o gen10 gen10.c

TestSSTableWriter.class: TestSSTableWriter.java
	javac -cp `./cassandra-classpath` TestSSTableWriter.java

TestSSTableWriter10.class: TestSSTableWriter10.java
	javac -cp `./cassandra-classpath` TestSSTableWriter10.java

ExecAsync.class: ExecAsync.java
	javac -cp `./cassandra-classpath` ExecAsync.java

ExecAsync10.class: ExecAsync10.java
	javac -cp `./cassandra-classpath` ExecAsync10.java

TestSSTableWriterSplit.class: TestSSTableWriterSplit.java
	javac -cp `./cassandra-classpath` TestSSTableWriterSplit.java

TestSSTableWriterSplit10.class: TestSSTableWriterSplit10.java
	javac -cp `./cassandra-classpath` TestSSTableWriterSplit10.java

TestSSTableWriterSplitAll.class: TestSSTableWriterSplitAll.java
	javac -cp `./cassandra-classpath` TestSSTableWriterSplitAll.java



### DATA
data: dirs data100B data1KB data10KB data1MB data10

LIST = 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99
### DATA100B
data100Btargets = $(addprefix data100B., $(LIST))
data100B: $(data100Btargets)

$(data100Btargets): data100B.%: 
	./gen 10485760 100 $* > in/data100B/data100B_$*.csv

### DATA1KB
data1KBtargets = $(addprefix data1KB., $(LIST))
data1KB: $(data1KBtargets)

$(data1KBtargets): data1KB.%: 
	./gen 1024000 1024 $* > in/data1KB/data1KB_$*.csv


### DATA10KB
data10KBtargets = $(addprefix data10KB., $(LIST))
data10KB: $(data10KBtargets)

$(data10KBtargets): data10KB.%: 
	./gen 102400 10240 $* > in/data10KB/data10KB_$*.csv


### DATA1MB
data1MBtargets = $(addprefix data1MB., $(LIST))
data1MB: $(data1MBtargets)

$(data1MBtargets): data1MB.%:
	./gen 1000 1048576 $* > in/data1MB/data1MB_$*.csv


### DATA10
data10targets = $(addprefix data10., $(LIST))
data10: $(data10targets)

$(data10targets): data10.%:
	./gen10 13107200 $* > in/data10/data10_$*.csv


### DIRS
dirstarget0 = $(addprefix out/data10/, $(LIST))
dirstarget = $(addsuffix /test/test10, $(dirstarget0))
dirs: $(dirstarget) indirs

$(dirstarget): out/data10/%/test/test10:
	- mkdir -p out/data100B/$*/test/test100b
	- mkdir -p out/data1KB/$*/test/test1kb
	- mkdir -p out/data10KB/$*/test/test10kb
	- mkdir -p out/data1MB/$*/test/test1mb
	- mkdir -p out/data10/$*/test/test10

indirs: in/data10

in/data10:
	- mkdir -p in/data100B
	- mkdir -p in/data10KB
	- mkdir -p in/data1KB
	- mkdir -p in/data1MB
	- mkdir -p in/data10


### CQLSH
ddl:
	cqlsh -e "CREATE KEYSPACE IF NOT EXISTS test WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '3'};"
	cqlsh -e "CREATE TABLE IF NOT EXISTS test.test100b(pkey TEXT, ccol BIGINT, data TEXT, PRIMARY KEY ((pkey), ccol));"
	cqlsh -e "CREATE TABLE IF NOT EXISTS test.test1kb(pkey TEXT, ccol BIGINT, data TEXT, PRIMARY KEY ((pkey), ccol));"
	cqlsh -e "CREATE TABLE IF NOT EXISTS test.test10kb(pkey TEXT, ccol BIGINT, data TEXT, PRIMARY KEY ((pkey), ccol));"
	cqlsh -e "CREATE TABLE IF NOT EXISTS test.test1mb(pkey TEXT, ccol BIGINT, data TEXT, PRIMARY KEY ((pkey), ccol));"
	cqlsh -e "CREATE TABLE IF NOT EXISTS test.test10(pkey BIGINT, ccol BIGINT, c1 BIGINT, c2 BIGINT, c3 BIGINT, c4 BIGINT, c5 BIGINT, c6 BIGINT, c7 BIGINT, c8 BIGINT, PRIMARY KEY ((pkey), ccol));"

truncate: truncate100b truncate1kb truncate10kb truncate1mb truncate10

truncate100b:
	- cqlsh -e "TRUNCATE test.test100b;"

truncate1kb:
	- cqlsh -e "TRUNCATE test.test1kb;"

truncate10kb:
	- cqlsh -e "TRUNCATE test.test10kb;"

truncate1mb:
	- cqlsh -e "TRUNCATE test.test1mb;"

truncate10:
	- cqlsh -e "TRUNCATE test.test10;"




### CLEAN
clean:
	- rm gen gen10
	- rm *.class

cleanall: clean
	- rm -rf in/*
	- rm -rf out/*
