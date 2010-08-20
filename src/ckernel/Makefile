AS = nasm
CC = gcc
LD = ld

CFLAGS = -c -std=c99 -nostdlib -nostartfiles -nodefaultlibs  -Iinclude/ \
		-Wall -Wextra -pedantic -Wshadow -Wpointer-arith -Wcast-align \
		-Wwrite-strings -Wmissing-prototypes -Wmissing-declarations \
		-Wredundant-decls -Wnested-externs -Winline -Wno-long-long \
		-Wconversion -Wstrict-prototypes

LDFLAGS	= --architecture i386 --noinhibit-exec -T link.ld
ASFLAGS	= -f aout

OBJFILES = general.o main.o portio.o drivers/teletype.o

FILENAME = ckernel

.PHONY: all clean

all: $(OBJFILES)
	$(LD) $(LDFLAGS) -o $(FILENAME) $(OBJFILES)

clean:
	@rm $(OBJFILES)
	@rm $(FILENAME)

.c.o:
	$(CC) $(CFLAGS) -o $@ $< 
	@echo

.s.o:
	$(AS) $(ASFLAGS) -o $@ $<
	@echo
