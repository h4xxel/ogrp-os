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

mov	eax, 1
mov	ebx, UnhandledInterrupt
mov	cx, 30h
register_dummy:
	call	RegisterISR
	inc	ax
loop	register_dummy

call	timer_setup

call	floppy_detect_drive

mov	eax, 1024d
call	sleep

mov	ebx, omg
mov	ah, 1
xor	edx, edx
call	print32

mov	eax, 1024d
call	sleep

mov	ebx, omg2
mov	ah, 1
call	print32

mov	eax, 1024d
call	sleep

mov	ebx, omg3
mov	ah, 1
call	print32

;xor	ax, ax
;div	ax		;Test divide by zero handler

call	floppy_driver_init
call	floppy_controller_reset
mov	ebx, resetdone
mov	ah, 1
xor	edx, edx
call	print32
mov	ch, 0
call	floppy_track_read

mov	ebx, 14A00h
mov	ah, 06h
mov	edi, 0B8000h
add edi, 80*2*16
mov	cx, 21d
lollol:
	mov	al, [es:ebx]
	mov	[es:edi], ax
	inc ebx
	add edi, 2
loop	lollol

mov	ebx, msg_hang
mov	edx, 240h
mov	ah, 03h
call	print32
jmp	$
resetdone db "reset done", 13d, 10d, 0

jmp	ContinueC
omg db 'THIS', 13d, 10d, 0
omg2 db 'IS', 13d, 10d, 0
omg3 db 'SPARTA!', 13d, 10d, 0
msg_hang db 'hang',0
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
	.l1:
		times	5 nop
	loop	.l1
	pop	cx
ret

print32:
	; Print NULL-termiated string
	; ebx	string pointer
	; ah	attribute
	mov	edi, [cursor_pos]
	;add	edi, edx
	.next:
	mov	al, [ds:ebx]
	cmp	al,0
	je	.end
	cmp	al, 10d
	jne	.check_cr
		;Line Break
		add	edi, 0A0h
		inc	ebx
		jmp	.next
	.check_cr:
	cmp	al, 13d
	jne	.print
		call	carriage_return
		inc	ebx
		jmp	.next
	.print:
		mov	[es:edi], ax
		add	edi, 2
		inc	ebx
	jmp	.next
.end:
mov	[cursor_pos], edi
call	update_hw_cursor
ret

carriage_return:
	mov	edx, edi
	sub	edx, 0B8000h
	mov	ax, dx
	shr	edx, 16
	mov	cx, 0A0h
	div	cx
	mul	cx
	mov	di, dx
	shl	edi, 16
	mov	di, ax
	add	edi, 0B8000h
ret

update_hw_cursor:
	mov	edx, [cursor_pos]
	sub	edx, 0B8000h
	mov	ax, dx
	shr	edx, 16
	mov	cx, 2
	div	cx
	mov	cx, ax
	mov	dx, 3D4h
	mov	al, 0Fh
	out	dx, al
	inc	dx
	mov	al, cl
	out	dx, al
	dec	dx
	mov	al, 0Eh
	out	dx, al
	inc	dx
	mov	al, ch
	out	dx, al
ret
cursor_pos dd 0B8320h

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
%include	'time.asm'
%include	'driver_floppy.asm'

ContinueC:
;Commented out to continue to c-kernel
cli
hlt

; Compatibility code
push	es
pop	ds
arst: