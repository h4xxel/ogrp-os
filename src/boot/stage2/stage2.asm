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
call	ProgressStep
call	MoveClear
mov	bx, MSGPmode
call	Print

cli
call	LoadGDT
mov	eax, cr0
or	eax, 1
mov	cr0,eax
jmp	8h:pmode

;Hang
call	MoveFail
mov	bx, MSGFail
call	Print
cli
hlt
jmp	$


Print:
	;Print NULL-termiated string
	mov	ah, 0eh
	PrintNext:
	mov	al, [cs:bx]
	cmp	al,0
	je	PrintEnd
		int	10h
		inc	bx
	jmp	PrintNext
	;End
PrintEnd:
ret

MoveClear:
	mov	ah, 2
	xor	bh, bh
	mov	dx, 0301h
	int	10h
	mov	bx, MSGNone
	call	Print
	mov	ah, 2
	xor	bh, bh
	mov	dx, 0301h
	int	10h
ret
MoveFail:
	mov	ah, 2
	xor	bh, bh
	mov	dx, 0314h
	int	10h
ret
ProgressStep:
	mov	ah, 2
	xor	bh, bh
	mov	dx, 0101h
	add	dl, [Prog]
	int	10h
	mov	ah, 0eh
	mov	al, [CHRProg]
	int	10h
	inc	byte [Prog]
ret

LoadError:
	call	MoveFail
	mov	bx, MSGFail
	call	Print
	cli
	hlt

%include 'gdt.asm'

Prog	db 2h

MSGNone	times 28 db 20h
		db 0h
MSGPmode	db "Entering pmode", 0h
MSGFail		db " ..failed",0h
CHRProg		db 0DBh

%include 'stage2pmode.asm'

; Just make it fill a whole sector
times 1536 - ($ - $$) nop