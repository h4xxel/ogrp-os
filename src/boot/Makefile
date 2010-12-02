MAKEFLAGS += --no-print-directory

.PHONY: all clean

all: stage2

clean:
	@echo " [ CLEANING ]"
	@echo " Binaries:	stage1/boot stage2/stage2 $(FILENAME)"
	@rm stage1/boot stage2/stage2 $(FILENAME)
	@echo " Done."
	@echo

boot:
	@$(MAKE) -C stage1/

stage2: boot
	@$(MAKE) -C stage2/
	@nasm -o arst arst.asm
