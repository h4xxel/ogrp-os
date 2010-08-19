LDFLAGS = --architecture i386 --noinhibit-exec -T ../../link.ld
OBJS = kernel.o interrupts.o

all: $(OBJS) link

link:
	ld $(LDFLAGS) -o $(CURDIR)/../../bin/kernel $(OBJS)
.s.o:
	nasm -faout $<
