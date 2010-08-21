RemapPIC:
	;Save IRQ masks
	in	al, 021h
	mov	ah, al
	in	al, 0A1h
	push	ax
	
	call	io_wait
	
	;Send init+ICW4
	mov	al,	11h
	out	020h, al
	call	io_wait
	out	0A0h, al
	call	io_wait
	
	;Send offsets
	mov	al, 020h
	out	021h, al
	call	io_wait
	mov	al, 028h
	out	0A1h, al
	call	io_wait
	
	;Continue init
	mov	al, 4h
	out	021h, al
	call	io_wait
	mov	al, 2h
	out	0A1h, al
	call	io_wait
	
	;Send ICW4_8086
	mov	al, 1h
	out	021h, al
	call	io_wait
	out	0A1h, al
	call	io_wait
	
	;Restore IRQ masks
	pop	ax
	out	0A1h, al
	mov	al, ah
	out	021h, al
ret
