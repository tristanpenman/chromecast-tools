OPENCRYPTO_LIB=libOpenCrypto.so
OPENCRYPTO_OBJ=\
	OpenCrypto/open_crypto.o

GTVCA_LIB=libGtvCa.so
GTVCA_OBJ=\
	GtvCa/gtv_ca.o

OSAL_LIB=libOSAL.so
OSAL_OBJ=\
	OSAL/osal.o

all: $(GTVCA_LIB) $(OPENCRYPTO_LIB) $(OSAL_LIB)

$(OPENCRYPTO_LIB): $(OPENCRYPTO_OBJ)
	$(CC) -DDLLEXPORTS -DC_EXPORTS $(CFLAGS) -shared -Wl,-soname,$(OPENCRYPTO_LIB) \
		-o $(OPENCRYPTO_LIB) $(OPENCRYPTO_OBJ)

$(GTVCA_LIB): $(GTVCA_OBJ)
	$(CC) -DDLLEXPORTS $(CFLAGS) -shared -Wl,-soname,$(GTVCA_LIB) \
		-o $(GTVCA_LIB) $(GTVCA_OBJ)

$(OSAL_LIB): $(OSAL_OBJ)
	$(CC) -DDLLEXPORTS $(CFLAGS) -shared -Wl,-soname,$(OSAL_LIB) \
		-o $(OSAL_LIB) $(OSAL_OBJ)

clean:
	rm -rf $(GTVCA_OBJ) $(OPENCRYPTO_OBJ)
	rm *.so
