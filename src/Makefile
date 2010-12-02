MAKEFLAGS += --no-print-directory

all: make_dirs

clean: clean_dirs

clean_dirs:
	@echo "Cleaning ckernel"
	@$(MAKE) -C ckernel/ clean
	@echo "Cleaning boot"
	@$(MAKE) -C boot/ clean

make_dirs:
	@echo " Building ckernel/"
	@$(MAKE) -C ckernel/
	@echo " Building boot/"
	@$(MAKE) -C boot/
