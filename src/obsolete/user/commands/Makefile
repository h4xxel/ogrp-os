all: make_create make_exists make_echo make_clear make_reboot make_delete make_attribute make_read

make_clear:
	nasm -fbin -o ../../../bin/clear clear/clear.s
	
make_reboot:
	nasm -fbin -o ../../../bin/reboot reboot/reboot.s

make_create:
	nasm -fbin -o ../../../bin/create create/create.s

make_exists:
	nasm -fbin -o ../../../bin/exists exists/exists.s

make_echo:
	nasm -fbin -o ../../../bin/echo echo/echo.s
	
make_delete:
	nasm -fbin -o ../../../bin/delete delete/delete.s
	
make_attribute:
	nasm -fbin -o ../../../bin/attribute attribute/attribute.s

make_read:
	nasm -fbin -o ../../../bin/read read/read.s
	
