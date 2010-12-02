MAKEFLAGS += --no-print-directory
FILENAME	= image.img

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
	@echo " Done. Your image is located at:"
	@echo " $(FILENAME)"
	@echo
	
clean_dirs:
	@echo " Cleaning src"
	@$(MAKE) -C src/ clean

make_dirs:
	@echo " Building src"
	@$(MAKE) -C src/
