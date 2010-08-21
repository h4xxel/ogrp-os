FILENAME	= image.img

.PHONY: all clean

all: stage2

test: stage2
	@echo " [ APPEND ]	stage1/boot > $(FILENAME)"
	@cat stage1/boot >> $(FILENAME)
	@echo " [ APPEND ]	stage2/stage2 > $(FILENAME)"
	@cat stage2/stage2 >> $(FILENAME)
	@echo " [ APPEND ]	../ckernel/ckernel-bin >> $(FILENAME)"
	@cat ../ckernel/ckernel-bin >> $(FILENAME)
	@echo " Done. Your image is located at:"
	@echo " src/boot/$(FILENAME)"
	@echo

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
