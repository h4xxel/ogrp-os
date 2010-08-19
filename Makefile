all: make_dirs boot install

boot:
	nasm -fbin -o bin/boot src/boot/boot.s

make_dirs:
	$(MAKE) -C src/kernel/
	$(MAKE) -C src/user/


install:
	@#dd if=/dev/zero of=image.img bs=512 count=2880
	@#sudo losetup /dev/loop0 image.img
	@#sudo dd if=bin/boot of=/dev/loop0
	@#sudo dd if=bin/filetable of=/dev/loop0 seek=1
	@#sudo dd if=bin/kernel of=/dev/loop0 seek=4
	@#sudo losetup -d /dev/loop0
	@echo Installing will be availble when ogrp-fs driver for linux is released!

clean:
	rm bin/*
