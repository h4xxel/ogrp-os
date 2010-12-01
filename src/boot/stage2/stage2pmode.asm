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
resetdone db "reset done",0

jmp	ContinueC
omg db 'THIS',0
omg2 db 'IS  ',0
omg3 db 'SPARTA!',0
msg_hang db 2,'hang',1,0
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
	; edx	screen offset (160*line)+(col*2)
	mov	edi, 0B8000h
	add	edi, edx
	.next:
	mov	al, [ds:ebx]
	cmp	al,0
	je	.end
		mov	[es:edi], ax
		add	edi, 2
		inc	ebx
	jmp	.next
	;End
.end:
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