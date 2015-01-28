all: compile


### COMPILE
compile: gen gen10 TestSSTableWriter.class

gen: gen.c
	gcc -o gen gen.c

gen10: gen10.c
	gcc -o gen10 gen10.c

TestSSTableWriter.class: TestSSTableWriter.java
	javac -cp `./cassandra-classpath` TestSSTableWriter.java



### DATA
data: dirs data100B data10KB data1M data10

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
	./gen 13107200 $* > in/data10/data10_$*.csv


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
	- mkdir -p in/data100B
	- mkdir -p in/data10KB
	- mkdir -p in/data1MB
	- mkdir -p in/data10


### CLEAN
clean:
	- rm gen gen10
	- rm *.class
	- rm -rf in/*
	- rm -rf out/*
