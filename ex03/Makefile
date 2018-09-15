XENO_CONFIG := /usr/xenomai/bin/xeno-config

CFLAGS := $(shell $(XENO_CONFIG)   --posix --alchemy --cflags)
LDFLAGS := $(shell $(XENO_CONFIG)  --posix --alchemy --ldflags)

CC := gcc   
EXECUTABLE := ex03a ex03br ex03crbroadcast ex03crv

all: $(EXECUTABLE)

%: %.c
	$(CC) -o $@ $< $(CFLAGS) $(LDFLAGS)

clean: 
	rm -f $(EXECUTABLE)
