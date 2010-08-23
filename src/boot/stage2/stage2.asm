; * This file is a part of the ogrp-os project
; * Version: 0.1 20 Aug 2010
;
; * Authors: jockepockee, mr3d (jockepockee.com, h4xxel.ath.cx)
; * Email: jocke@h4xx.org h4xxel@h4xx.org
;
; * Copyright 2010 ogrp
; * License: see COPYING file									;

[BITS 16]	; We are still in realmode :)
[ORG 0000h]	; BIOS loads us to 0x0000:0x7c00

jmp stage2
db	"STAGE2"
stage2:
push	cs
pop	ds
;Print Boot Messages
call	ProgressStep
call	MoveClear
mov	bx, MSGBoot
call	Print

cli
;mov	ax, 10h
;mov	ds, ax
;mov	ss, ax
;mov	es, ax
call	LoadGDT
;mov	[es:0000h], word 'aa'
mov	eax, cr0
;mov	[es:0002h], word 'bb'
or	eax, 1
mov	cr0,eax
;mov	[es:0004h], word 'cc'
jmp	8h:pmode

;Hang
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
MSGBoot	db "stage2 loaded", 0h
MSGFail	db " ..failed",0h
CHRProg	db 0DBh

%include 'stage2pmode.asm'

; Just make it fill a whole sector
times 1024 - ($ - $$) nop