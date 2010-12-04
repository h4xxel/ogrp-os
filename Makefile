MAKEFLAGS += --no-print-directory
FILENAME	= out.bin
IMAGE = ogrp-os.img

all: make_dirs

clean: clean_dirs

image: all
	@touch $(FILENAME)
	@rm $(FILENAME)
	@echo " [ APPEND ]	src/boot/stage1/boot > $(FILENAME)"
	@cat src/boot/stage1/boot >> $(FILENAME)
	@echo " [ APPEND ]	src/boot/stage2/stage2 > $(FILENAME)"
	@cat src/boot/stage2/stage2 >> $(FILENAME)
	@echo " [ APPEND ]	src/ckernel/ckernel-bin >> $(FILENAME)"
	@cat src/ckernel/ckernel-bin >> $(FILENAME)
	@touch $(IMAGE)
	@rm $(IMAGE)
	@dd if=/dev/zero of=$(IMAGE) bs=512 count=2880
	@dd if=$(FILENAME) of=$(IMAGE) conv=notrunc bs=512
	@echo " Done. Your image is located at:"
	@echo " $(IMAGE)"
	@echo
	
clean_dirs:
	@echo " Cleaning src"
	@$(MAKE) -C src/ clean

make_dirs:
	@echo " Building src"
	@$(MAKE) -C src/
