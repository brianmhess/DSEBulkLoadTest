all: compile


### COMPILE
CLASSPATH := $(shell ./cassandra-classpath)
HOST := 172.31.30.222
CQLSH := /home/automaton/cassandra/bin/cqlsh

compile: gen gen10 TestSSTableWriter.class TestSSTableWriter10.class ExecAsync.class ExecAsync10.class TestSSTableWriterSplit.class TestSSTableWriterSplit10.class cppexec cppexecall

gen: gen.c
	gcc -o gen gen.c

gen10: gen10.c
	gcc -o gen10 gen10.c

gen100: gen100.c
	gcc -o gen100 gen100.c

TestSSTableWriter.class: TestSSTableWriter.java
	javac -cp $(CLASSPATH) TestSSTableWriter.java

TestSSTableWriter10.class: TestSSTableWriter10.java
	javac -cp $(CLASSPATH) TestSSTableWriter10.java

ExecAsync.class: ExecAsync.java
	javac -cp $(CLASSPATH) ExecAsync.java

ExecAsync10.class: ExecAsync10.java
	javac -cp $(CLASSPATH) ExecAsync10.java

TestSSTableWriterSplit.class: TestSSTableWriterSplit.java
	javac -cp $(CLASSPATH) TestSSTableWriterSplit.java

TestSSTableWriterSplit10.class: TestSSTableWriterSplit10.java
	javac -cp $(CLASSPATH) TestSSTableWriterSplit10.java

cppexec: cppexec.c
	g++ -o cppexec cppexec.c -L/usr/lib/x86_64-linux-gnu/ `pkg-config --libs cassandra`

cppexecall: cppexecall.c
	g++ -o cppexecall cppexecall.c -L/usr/lib/x86_64-linux-gnu/ `pkg-config --libs cassandra` -lpthread

TestSSTableWriterSplitAll.class: TestSSTableWriterSplitAll.java
	javac -cp `./cassandra-classpath` TestSSTableWriterSplitAll.java



### DATA
data: dirs data100B data1KB data10KB data1MB data10

##LIST = 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99
LIST = 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19

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


### DATA100
data100targets = $(addprefix data100., $(LIST))
data100: $(data100targets)

$(data100targets): data100.%:
	./gen100 500000 $* $* > in/data100/data100_$*.csv


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
	- mkdir -p out/data100/$*/test/test100

indirs: in/data10

in/data10:
	- mkdir -p in/data100B
	- mkdir -p in/data1KB
	- mkdir -p in/data10KB
	- mkdir -p in/data1KB
	- mkdir -p in/data1MB
	- mkdir -p in/data10
	- mkdir -p in/data100


### CQLSH
ddl:
	$(CQLSH) $(HOST) -e "CREATE KEYSPACE IF NOT EXISTS test WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '3'};"
	$(CQLSH) $(HOST) -e "CREATE TABLE IF NOT EXISTS test.test100b(pkey TEXT, ccol BIGINT, data TEXT, PRIMARY KEY ((pkey), ccol));"
	$(CQLSH) $(HOST) -e "CREATE TABLE IF NOT EXISTS test.test1kb(pkey TEXT, ccol BIGINT, data TEXT, PRIMARY KEY ((pkey), ccol));"
	$(CQLSH) $(HOST) -e "CREATE TABLE IF NOT EXISTS test.test10kb(pkey TEXT, ccol BIGINT, data TEXT, PRIMARY KEY ((pkey), ccol));"
	$(CQLSH) $(HOST) -e "CREATE TABLE IF NOT EXISTS test.test1mb(pkey TEXT, ccol BIGINT, data TEXT, PRIMARY KEY ((pkey), ccol));"
	$(CQLSH) $(HOST) -e "CREATE TABLE IF NOT EXISTS test.test100(pkey BIGINT, ccol BIGINT, col0 BIGINT, col1 BIGINT, col2 BIGINT, col3 BIGINT, col4 BIGINT, col5 BIGINT, col6 BIGINT, col7 BIGINT, col8 BIGINT, col9 BIGINT, col10 BIGINT, col11 BIGINT, col12 BIGINT, col13 BIGINT, col14 BIGINT, col15 BIGINT, col16 BIGINT, col17 BIGINT, col18 BIGINT, col19 BIGINT, col20 BIGINT, col21 BIGINT, col22 BIGINT, col23 BIGINT, col24 BIGINT, col25 BIGINT, col26 BIGINT, col27 BIGINT, col28 BIGINT, col29 BIGINT, col30 BIGINT, col31 BIGINT, col32 BIGINT, col33 BIGINT, col34 BIGINT, col35 BIGINT, col36 BIGINT, col37 BIGINT, col38 BIGINT, col39 BIGINT, col40 BIGINT, col41 BIGINT, col42 BIGINT, col43 BIGINT, col44 BIGINT, col45 BIGINT, col46 BIGINT, col47 BIGINT, col48 BIGINT, col49 BIGINT, col50 BIGINT, col51 BIGINT, col52 BIGINT, col53 BIGINT, col54 BIGINT, col55 BIGINT, col56 BIGINT, col57 BIGINT, col58 BIGINT, col59 BIGINT, col60 BIGINT, col61 BIGINT, col62 BIGINT, col63 BIGINT, col64 BIGINT, col65 BIGINT, col66 BIGINT, col67 BIGINT, col68 BIGINT, col69 BIGINT, col70 BIGINT, col71 BIGINT, col72 BIGINT, col73 BIGINT, col74 BIGINT, col75 BIGINT, col76 BIGINT, col77 BIGINT, col78 BIGINT, col79 BIGINT, col80 BIGINT, col81 BIGINT, col82 BIGINT, col83 BIGINT, col84 BIGINT, col85 BIGINT, col86 BIGINT, col87 BIGINT, col88 BIGINT, col89 BIGINT, col90 BIGINT, col91 BIGINT, col92 BIGINT, col93 BIGINT, col94 BIGINT, col95 BIGINT, col96 BIGINT, col97 BIGINT, PRIMARY KEY ((pkey), ccol));"
	$(CQLSH) $(HOST) -e "CREATE TABLE IF NOT EXISTS test.test10(pkey BIGINT, ccol BIGINT, col0 BIGINT, col1 BIGINT, col2 BIGINT, col3 BIGINT, col4 BIGINT, col5 BIGINT, col6 BIGINT, col7 BIGINT, PRIMARY KEY ((pkey), ccol));"

truncate: truncate100b truncate1kb truncate10kb truncate1mb truncate10 truncate100

truncate100b:
	- $(CQLSH) $(HOST) -e "TRUNCATE test.test100b;"

truncate1kb:
	- $(CQLSH) $(HOST) -e "TRUNCATE test.test1kb;"

truncate10kb:
	- $(CQLSH) $(HOST) -e "TRUNCATE test.test10kb;"

truncate1mb:
	- $(CQLSH) $(HOST) -e "TRUNCATE test.test1mb;"

truncate10:
	- $(CQLSH) $(HOST) -e "TRUNCATE test.test10;"

truncate100:
	- $(CQLSH) $(HOST) -e "TRUNCATE test.test100;"




### CLEAN
clean:
	- rm gen gen10 cppexec cppexecall
	- rm *.class

cleanall: clean
	- rm -rf in/*
	- rm -rf out/*
