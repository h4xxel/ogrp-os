MAKEFLAGS += --no-print-directory
AS = nasm
CC = gcc
LD = ld

CFLAGS = -c -nostdlib -nostartfiles -nodefaultlibs  -Iinclude/ \
		-Wall -Wextra -pedantic -Wshadow -Wpointer-arith -Wcast-align \
		-Wwrite-strings -Wmissing-prototypes -Wmissing-declarations \
		-Wredundant-decls -Wnested-externs -Winline -Wno-long-long \
		-Wconversion -Wstrict-prototypes

LDFLAGS	= --architecture i386 --noinhibit-exec -T link.ld
ASFLAGS	= -f aout

OBJFILES = general.o main.o portio.o drivers/teletype.o

FILENAME	= ckernel-bin

.PHONY: all clean

all: $(OBJFILES)
	@echo " [ LD ]	$(OBJFILES)"
	@$(LD) $(LDFLAGS) -o $(FILENAME) $(OBJFILES)
	@echo " Done. Your kernel binary is located at:"
	@echo " src/ckernel/$(FILENAME)"
	@echo

clean:
	@echo " [ CLEAN ]"
	@echo " Objectfiles:	$(OBJFILES)"
	@echo " Binaries:	$(FILENAME)"
	@rm $(OBJFILES)
	@rm $(FILENAME)
	@echo " Done."
	@echo

.c.o:
	@echo " [ CC ]		$<"
	@$(CC) $(CFLAGS) -o $@ $< 

.s.o:
	@echo " [ AS ]		$<"
	@$(AS) $(ASFLAGS) -o $@ $<
