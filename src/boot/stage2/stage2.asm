; * This file is a part of the ogrp-os project
; * Version: 0.1 20 Aug 2010
;
; * Authors: jockepockee, mr3d (jockepockee.com, h4xxel.ath.cx)
; * Email: jocke@h4xx.org h4xxel@h4xx.org
;
; * Copyright 2010 ogrp
; * License: see COPYING file									;

[BITS 16]	; We are still in realmode :)
[ORG 0000h]

jmp stage2
db	"STAGE2"
stage2:
push	cs
pop	ds
;Print Boot Messages
mov	bx, MSGPmode
call	Print
call	ProgressStep

cli
call	LoadGDT
mov	eax, cr0
or	eax, 1
mov	cr0,eax
jmp	8h:pmode

;Hang
mov	bx, MSGFail
call	Print
mov	bx, MSGEnd
call	Print
cli
hlt
jmp	$


Print:
	;Print NULL-termiated string
	mov	ah, 0eh
	.next:
	mov	al, [cs:bx]
	cmp	al,0
	je	.end
		int	10h
		inc	bx
	jmp	.next
	;End
.end:
ret

ProgressStep:
	mov	bx, MSGDone
	call	Print
	mov	bx, MSGEnd
	call	Print
ret

LoadError:
	mov	bx, MSGFail
	call	Print
	mov	bx, MSGEnd
	call	Print
	cli
	hlt

%include 'gdt.asm'

MSGPmode	db "Entering pmode.....[", 0h
MSGFail		db "FAIL",0h
MSGDone		db "DONE",0h
MSGEnd		db "]",13d,10d,0

%include 'stage2pmode.asm'

; Just make it fill a whole sector
times 2048 - ($ - $$) nop