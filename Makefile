CFLAGS = -I./include -Wall -Wno-pointer-sign
CFLAGS += -Os
BIN = openra1n
SOURCE = openra1n.c common.c checkm8.c usb.c usb_iokit.c usb_libusb.c lz4/lz4.c lz4/lz4hc.c
OBJECTS = $(subst .c,.o,$(SOURCE))
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

payloads:
	@mkdir -p include/payloads
	@for file in payloads/*; do \
		echo " XXD    $$file"; \
		xxd -i $$file > include/$$file.h; \
	done

%.o: %.c | payloads
	@echo " CC     $@"
	@$(CC) $(CFLAGS) -c $< -o $@

openra1n: $(OBJECTS)
	@echo " LD     $(BIN)"
	@$(CC) $(OBJECTS) $(LDFLAGS) -o $(BIN)
	strip $(BIN)

clean:
	@echo " CLEAN  $(OBJECTS)"
	@rm -f $(OBJECTS)
	@echo " CLEAN  $(BIN)"
	@rm -f $(BIN)
	@echo " CLEAN  include/payloads"
	@rm -rf include/payloads
