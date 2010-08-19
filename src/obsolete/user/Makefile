all: make_user make_dirs

make_user:
	nasm -fbin -o ../../bin/user user.s

make_dirs:
	$(MAKE) -C gui/
	$(MAKE) -C commands/
