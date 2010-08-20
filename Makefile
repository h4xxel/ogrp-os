MAKEFLAGS += --no-print-directory

all: make_dirs

clean: clean_dirs

clean_dirs:
	@$(MAKE) -C src/ckernel clean

make_dirs:
	@$(MAKE) -C src/ckernel
