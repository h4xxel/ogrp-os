; * This file is a part of the ogrp-os project
; * Version: 0.1 20 Aug 2010
;
; * Authors: jockepockee, mr3d (jockepockee.com, h4xxel.ath.cx)
; * Email: jocke@h4xx.org h4xxel@h4xx.org
;
; * Copyright 2010 ogrp
; * License: see COPYING file									;

[bits 16]	; We are still in realmode :)
[org 0000h]

jmp stage2
db	"STAGE2"
stage2:
push	cs
pop	ds
;Print Boot Messages
mov	bx, msg_pmode
mov	ah, 07h
call	print16
call	progress_step

cli
call	gdt_load
mov	eax, cr0
or	eax, 1
mov	cr0,eax
jmp	8h:pmode

;Hang
call	load_error
cli
hlt
jmp	$

progress_step:
	mov	ah, 02h
	mov	bx, msg_done
	call	print16
	mov	bx, msg_end
	mov	ah, 07h
	call	print16
ret

load_error:
	mov	bx, msg_fail
	mov	ah, 04h
	call	print16
	mov	bx, msg_end
	mov	ah, 07h
	call	print16
	cli
	hlt

%include 'gdt.asm'

msg_pmode	db "Entering pmode.........[", 0h
msg_fail		db "FAIL",0h
msg_done		db "DONE",0h
msg_end		db "]",13d,10d,0

%include 'stage2pmode.asm'

; Just make it fill a whole sector
times 512 - (($ - $$) % 512) nop