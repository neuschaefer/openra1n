CFLAGS = -I./include -Wall -Wno-pointer-sign
CFLAGS += -Os
BIN = openra1n
SOURCE = openra1n.c common.c checkm8.c usb.c usb_iokit.c usb_libusb.c lz4/lz4.c lz4/lz4hc.c
OBJECTS = $(subst .c,.o,$(SOURCE))
PAYLOADS=payloads/lz4dec.bin payloads/Pongo.bin \
	 payloads/s8000.bin payloads/s8001.bin payloads/s8003.bin \
	 payloads/t7000.bin payloads/t7001.bin \
	 payloads/t8010.bin payloads/t8011.bin payloads/t8012.bin payloads/t8015.bin
PAYLOAD_HEX=$(subst .bin,.c,$(PAYLOADS))
PAYLOAD_OBJ=$(subst .bin,.o,$(PAYLOADS))

ifeq ($(LIBUSB),1)
	CC = gcc
	CFLAGS += -DHAVE_LIBUSB
	LDFLAGS += -lusb-1.0
else
	CC = xcrun -sdk macosx gcc
	CFLAGS += -arch x86_64 -arch arm64
	LDFLAGS += -framework IOKit -framework CoreFoundation
endif

.PHONY: all clean payloads openra1n

all: payloads openra1n

payloads/%.c: payloads/%.bin
	@echo " XXD    $@"
	@xxd -i $< > $@

payloads/%.o: payloads/%.c
	@echo " CC     $@"
	@$(CC) $(CFLAGS) -c $< -o $@

%.o: %.c
	@echo " CC     $@"
	@$(CC) $(CFLAGS) -c $< -o $@

openra1n: $(OBJECTS) $(PAYLOAD_OBJ)
	@echo " LD     $(BIN)"
	@$(CC) $(OBJECTS) $(PAYLOAD_OBJ) $(LDFLAGS) -o $(BIN)
	strip $(BIN)

clean:
	@echo " CLEAN  $(OBJECTS)"
	@rm -f $(OBJECTS)
	@echo " CLEAN  $(PAYLOAD_OBJ)"
	@rm -f $(PAYLOAD_OBJ) $(PAYLOAD_HEX)
	@echo " CLEAN  $(BIN)"
	@rm -f $(BIN)
	@echo " CLEAN  include/payloads"
	@rm -rf include/payloads
