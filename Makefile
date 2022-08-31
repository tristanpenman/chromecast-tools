PREFIX ?= arm-unknown-linux-gnueabi
export LD=$(PREFIX)-ld
export CC=$(PREFIX)-gcc
export CXX=$(PREFIX)-g++
export AR=$(PREFIX)-ar
export RANLIB=$(PREFIX)-ranlib

MOCKS ?= $(shell pwd)/mocks
SRC ?= $(shell pwd)/src
INCPATH ?= $(shell pwd)/includes
OUTDIR ?= bin
TOOLCHAIN ?= $(shell pwd)/toolchain
TOOLCHAIN_BIN := $(TOOLCHAIN)/arm-unknown-linux-gnueabi-4.5.3-glibc/bin

PATH := $(TOOLCHAIN_BIN):$(PATH)

export C_INCLUDE_PATH=$(MOCKS):$(TOOLCHAIN)/arm-unknown-linux-gnueabi-4.5.3-glibc/target-arm-unknown-linux-gnueabi/usr/include
export CPLUS_INCLUDE_PATH=$(C_INCLUDE_PATH)
export LIBPATH=-L$(MOCKS) -L$(TOOLCHAIN)/arm-unknown-linux-gnueabi-4.5.3-glibc/target-arm-unknown-linux-gnueabi/usr/lib
export CFLAGS= -fPIC -Wall -Wextra -DNDEBUG -DEUREKA -DPOSIX -DLINUX -Wno-unused-parameter -Wno-missing-field-initializers

GTV_CA_SIGN_LIBS=\
	-lGtvCa \
	-lOpenCrypto \
	-lOSAL \
	-lstdc++ \
	-lc \
	-lpthread \
	-lrt

GTV_CA_SIGN_OBJS=\
	$(SRC)/gtv-ca-sign.o

$(OUTDIR)/gtv-ca-sign: $(MOCKS) $(GTV_CA_SIGN_OBJS)
	mkdir -p $(OUTDIR)
	$(CXX) $(CFLAGS) $(LIBPATH) \
		-o $(OUTDIR)/gtv-ca-sign $(GTV_CA_SIGN_OBJS) $(GTV_CA_SIGN_LIBS)

.cpp.o:
	$(CXX) $(CFLAGS) -c $< -o $@

$(MOCKS):
	make -C $(MOCKS)

clean:
	make -C $(MOCKS) clean
	rm -f $(GTV_CA_SIGN_OBJS) $(OUTDIR)/gtv-ca-sign

.PHONY: all $(MOCKS)
