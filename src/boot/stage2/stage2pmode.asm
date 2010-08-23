; * This file is a part of the ogrp-os project
; * Version: 0.1 20 Aug 2010
;
; * Authors: jockepockee, mr3d (jockepockee.com, h4xxel.ath.cx)
; * Email: jocke@h4xx.org h4xxel@h4xx.org
;
; * Copyright 2010 ogrp
; * License: see COPYING file	

pmode:
[bits 32]
;Fucking pmode, baby! :DD
mov	eax, 18h
mov	ds, ax
mov	eax, 10h
mov	es, ax
mov	ss, ax

call	RemapPIC
call	LoadIDT
mov	eax, 0h
mov	ebx, ISRDiv0
call	RegisterISR

call	floppy_detect_drive

;sti

;xor	ax, ax
;div	ax

jmp	$

jmp	ContinueC

ISRDiv0:
	pusha
	mov	ebx, MSGDiv0
	jmp	panic
	popa
ret
MSGDiv0 db "Divide by zero",0h

io_wait:
	push	cx
	mov	cx, 10h
	io_wait_loop:
		times	5 nop
	loop	io_wait_loop
	pop	cx
ret

print32:
	; Print NULL-termiated string
	; ebx	string pointer
	; ah	attribute
	; edx	screen offset (160*line)+(col*2)
	mov	edi, 0B8000h
	add	edi, edx
	Print32Next:
	mov	al, [ds:ebx]
	cmp	al,0
	je	Print32End
		mov	[es:edi], ax
		add	edi, 2
		inc	ebx
	jmp	Print32Next
	;End
Print32End:
ret

panic:
	push	ebx
	xor	edx, edx
	mov	ebx, MSGPanic
	call	print32
	pop	ebx
	mov	edx, 0Eh
	call	print32
	cli
	hlt
	jmp	$
MSGPanic	db "PANIC: ", 0h

%include	'interrupts.asm'
%include	'driver_floppy.asm'

ContinueC:
;Commented out to continue to c-kernel
cli
hlt
