LoadIDT:
	mov	edi, 12000h
	mov	cx, 0FFFFh
	ClearIDTLoop:
		mov	[es:edi], dword 0h
		add	edi, 4h
	loop	ClearIDTLoop
	lidt	[ds:idtr]
ret
idtr	dw 0FFFFh
	dd 12000h

RegisterISR:
	; ebx: ISR linear address
	; eax: Interrupt Number
	mov	edi, 12000h
	mul	word [ds:IntSize]
	shl	dx, 16
	or	ax, dx
	add	edi, eax
	
	mov	[es:edi], bx
	add	edi, 2h
	mov	[es:edi], word 8h
	add	edi, 2h
	mov	[es:edi], byte 0h
	inc	edi
	mov	[es:edi], byte 8Eh
	inc	edi
	shr	ebx, 16
	mov	[es:edi], bx
ret
IntSize	dw 8

GetISR:
	nop
ret

UnhandledInterrupt:
pusha
	mov	ebx, MSGUnhandled
	mov	ah, 07h
	xor	edx, edx
	call	print32
	mov	al, 20h
	out	20h, al
	out	0Ah, al
popa
iret
MSGUnhandled	db "Unhandled Interrupt", 0

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
