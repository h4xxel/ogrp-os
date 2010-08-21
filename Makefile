MAKEFLAGS += --no-print-directory

all: make_dirs

clean: clean_dirs

clean_dirs:
	@echo " Cleaning src/ckernel/"
	@$(MAKE) -C src/ckernel/ clean
	@echo " Cleaning src/boot/"
	@$(MAKE) -C src/boot/ clean

make_dirs:
	@echo " Building src/ckernel/"
	@$(MAKE) -C src/ckernel/
	@echo " Building src/boot/	(test target)"
	@$(MAKE) -C src/boot/ test
