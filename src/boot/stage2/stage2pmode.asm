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

mov	ebx, msg_interrupts
mov	ah, 07h
call	print

call	pic_remap
call	idt_load

mov	eax, 0h
mov	ebx, isr_div0
call	isr_register

mov	eax, 1
mov	ebx, unhandled_int
mov	cx, 30h
register_dummy:
	call	isr_register
	inc	ax
loop	register_dummy

mov	ebx, msg_done
mov	ah, 02h
call	print
mov	ebx, msg_end
mov	ah, 07h
call	print

mov	ebx, msg_timer
mov	ah, 07h
call	print

call	timer_setup

mov	ebx, msg_done
mov	ah, 02h
call	print
mov	ebx, msg_end
mov	ah, 07h
call	print

mov	ebx, msg_keyboard
mov	ah, 07h
call	print

call	keyboard_setup

mov	ebx, msg_done
mov	ah, 02h
call	print
mov	ebx, msg_end
mov	ah, 07h
call	print

;xor	ax, ax
;div	ax		;Test divide by zero handler

mov	ebx, msg_floppy
mov	ah, 07h
call	print

call	floppy_driver_init
call	floppy_controller_reset
mov	ebx, msg_done
mov	ah, 02h
call	print
mov	ebx, msg_end
mov	ah, 07h
call	print
call	floppy_detect_drive
mov	ch, 0
call	floppy_track_read

mov	ebx, 14A00h
mov	ah, 06h
mov	edi, 0B8000h
add edi, 80*2*16
mov	cx, 21d

mov	ecx, 1d
omgloop:
	push	ecx
	mov	ebx, omg
	mov	ah, 0dh
	call	print
	mov	eax, 1024d
	call	sleep
	
	mov	ebx, omg2
	mov	ah, 0dh
	call	print
	mov	eax, 1024d
	call	sleep
	
	mov	ebx, omg3
	mov	ah, 0dh
	call	print
	mov	eax, 1024d
	call	sleep
	
	pop	ecx
loop omgloop


; lollol:
	; mov	al, [es:ebx]
	; mov	[es:edi], ax
	; inc ebx
	; add edi, 2
; loop	lollol

;Testing keyboard input :))
prompt:
	mov	ebx, msg_prompt
	mov	ah, 07h
	call	print
	mov	[buf_len], word 0
	.readchar:
		call	getc
		mov	[charbuf], al
		cmp	al, 13d
		je	prompt
		cmp	al, 8
		jne	.printchar
		cmp	[buf_len], word 0
		je	.readchar
			sub	dword [cursor_pos], 2
			call	update_hw_cursor
			mov	edi, [cursor_pos]
			mov	[es:edi], word 0700h
			dec	word [buf_len]
			jmp	.readchar
		.printchar:
		inc	word [buf_len]
		mov	ebx, charbuf
		mov	ah, 07h
		call	print
jmp	.readchar

buf_len	dw 0
charbuf	db 0,0

jmp	$

jmp	continue_ckernel
omg db 'Testing', 13d, 10d, 0
omg2 db 'timing', 13d, 10d, 0
omg3 db 'functions!', 13d, 10d, 0
msg_prompt db 13d, 10d, 'test>',0
msg_floppy	db "Initializing floppy....[", 0h
msg_interrupts	db "Setting up interrupts..[", 0h
msg_timer	db "Setting up timer.......[", 0h
msg_keyboard	db "Initializing keyboard..[", 0h
isr_div0:
	pusha
	mov	ebx, msg_div0
	jmp	panic
	popa
ret
msg_div0 db "Divide by zero",0h


panic:
	push	ebx
	mov	ah, 04h
	mov	ebx, MSGPanic
	call	print
	pop	ebx
	mov	ah, 07h
	call	print
	cli
	hlt
	jmp	$
MSGPanic	db 13d, 10d,"PANIC: ", 0h

%include	'interrupts.asm'
%include	'time.asm'
%include	'driver_io.asm'
%include	'driver_floppy.asm'

continue_ckernel:
;Commented out to continue to c-kernel
cli
hlt

; Compatibility code
push	es
pop	ds
arst: