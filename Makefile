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


### DATA
data: dirs data100B data10KB data1MB data10

LIST = 0 1 2 3 4 5 6 7 8 9
### DATA100B
data100Btargets = $(addprefix data100B., $(LIST))
data100B: $(data100Btargets)

$(data100Btargets): data100B.%: 
	./gen 10485760 100 $* > in/data100B/data100B_$*.csv

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
dirstarget0 = $(addprefix out/data100B/, $(LIST))
dirstarget = $(addsuffix /test/test100b, $(dirstarget0))
dirs: $(dirstarget) indirs

$(dirstarget): out/data100B/%/test/test100b:
	- mkdir -p out/data100B/$*/test/test100b
	- mkdir -p out/data10KB/$*/test/test10kb
	- mkdir -p out/data1MB/$*/test/test1mb
	- mkdir -p out/data10/$*/test/test10

indirs: in/data10

in/data10:
	- mkdir -p in/data100B
	- mkdir -p in/data10KB
	- mkdir -p in/data1MB
	- mkdir -p in/data10


### CQLSH
ddl:
	cqlsh -e "CREATE KEYSPACE IF NOT EXISTS test WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '3'};"
	cqlsh -e "CREATE TABLE IF NOT EXISTS test.test100b(pkey TEXT, ccol BIGINT, data TEXT, PRIMARY KEY ((pkey), ccol));"
	cqlsh -e "CREATE TABLE IF NOT EXISTS test.test10kb(pkey TEXT, ccol BIGINT, data TEXT, PRIMARY KEY ((pkey), ccol));"
	cqlsh -e "CREATE TABLE IF NOT EXISTS test.test1mb(pkey TEXT, ccol BIGINT, data TEXT, PRIMARY KEY ((pkey), ccol));"
	cqlsh -e "CREATE TABLE IF NOT EXISTS test.test10(pkey BIGINT, ccol BIGINT, c1 BIGINT, c2 BIGINT, c3 BIGINT, c4 BIGINT, c5 BIGINT, c6 BIGINT, c7 BIGINT, c8 BIGINT, PRIMARY KEY ((pkey), ccol));"

trunncate: clean100b clean10kb clean1mb clean10

trunncate100b:
	- cqlsh -e "TRUNCATE TABLE test.test100b;"

trunncate10kb:
	- cqlsh -e "TRUNCATE TABLE test.test10kb;"

trunncate1mb:
	- cqlsh -e "TRUNCATE TABLE test.test1mb;"

trunncate10:
	- cqlsh -e "TRUNCATE TABLE test.test10;"




### CLEAN
clean:
	- rm gen gen10
	- rm *.class

cleanall: clean
	- rm -rf in/*
	- rm -rf out/*
