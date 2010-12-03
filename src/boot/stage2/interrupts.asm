[bits 32]
idt_load:
	mov	edi, 12000h
	mov	cx, 0FFFFh
	.l1:
		mov	[es:edi], dword 0h
		add	edi, 4h
	loop	.l1
	lidt	[ds:idtr]
ret
idtr	dw 0FFFFh
	dd 12000h

isr_register:
	; ebx: ISR linear address
	; eax: Interrupt Number
	push	ebx
	push	eax
	mov	edi, 12000h
	mul	word [ds:int_size]
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
	pop	eax
	pop	ebx
ret
int_size	dw 8

isr_get:
	nop
ret

unhandled_int:
	pusha
	; mov	ebx, msg_unhandled
	; mov	ah, 07h
	; call	print
	mov	al, 20h
	out	20h, al
	out	0Ah, al
	popa
iret
msg_unhandled	db "Unhandled Interrupt", 13d, 10d, 0

pic_remap:
	;Save IRQ masks
	in	al, 021h
	mov	ah, al
	in	al, 0A1h
	push	ax
	
	call	io_wait
	
	;Send init+ICW4
	mov	al, 11h
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
	mov	ax, 0FFh		;;;;;;REMOVE
	out	0A1h, al
	mov	al, ah
	out	021h, al
ret
