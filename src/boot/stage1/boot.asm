; * This file is a part of the ogrp-os project
; * Version: 0.1 19 Aug 2010
;
; * Authors: jockepockee, mr3d (jockepockee.com, h4xxel.ath.cx)
; * Email: jocke@h4xx.org h4xxel@h4xx.org
;
; * Copyright 2010 ogrp
; * License: see COPYING file									;

[BITS 16]	; We are in realmode :)
[ORG 7C00h]	; BIOS loads us to 0x0000:0x7c00
	
;Clear Screen
mov	ax, 0700h
mov	bh, 07h
mov	dx, 02480h
int	10h

mov	ah, 2
xor	bh, bh
xor	dx, dx
int	10h

;Disable cursor
;mov ch, 32
;mov ah, 1
;int 10h

;Print Boot Messages
mov	bx, Window
call	Print
call	MoveClear
mov	bx, MSGBoot
call	Print

mov	ah, 02		; BIOS drive load function
mov	al, [BSize]	; Number of sectors to read
mov	cx, [BSec]	; Read from cylinder 0 and Read from sector 2
mov	dx, [BDrive]	; Read from head 0 and Read from floppy drive 0
mov	bx, 1000h	;
mov	es, bx		; Read to segment 0x1000
xor	bx, bx		; And offset 0x0000


; Load Stage 2
int	13h
jc	LoadError
call	ProgressStep

call	MoveClear
mov	bx, MSGVrfy
call	Print
call	Stage2Verify
call	ProgressStep


jmp 1000h:0000h

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
	push	ax
	push	bx
	push	cx
	push	dx
	mov	ah, 2
	xor	bh, bh
	mov	dx, 0101h
	add	dl, [Prog]
	int	10h
	mov	ah, 0eh
	mov	al, [CHRProg]
	int	10h
	inc	byte [Prog]
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	
ret

Stage2Verify:
	mov	bx, 1000h
	mov	es, bx
	mov	bx, SIGstg2+8d
	mov	cx, 8
	VerifyLoop:
		mov	si, cx
		mov	ah, [es:si]
		cmp	ah, [cs:bx]
		jne	LoadError
		dec	bx
	loop	VerifyLoop
ret

LoadError:
	call	MoveFail
	mov	bx, MSGFail
	call	Print
	cli
	hlt

BData	db "BootData:"
BSec	db 2h	;Sector number for stage2
BCyl	db 0h	;Cylinder number for stage2
BDrive	db 0h	;Drive number for stage2
BHead	db 0h	;Head number for stage2
BSize	db 1h	;Size of stage2 in sectors

Prog	db 0h

Window	db 0C9h
	db 0CDh, 0B9h, "OGRP-OS", 0CCh
	times 18 db 0CDh
	db 0BBh, 0Ah, 0Dh
	
	db 0BAh
	times 28 db 20h
	db 0BAh, 0Ah, 0Dh
	
	db 0CCh
	times 28 db 0CDh
	db 0B9h, 0Ah, 0Dh
	
	db 0BAh
	times 28 db 20h
	db 0BAh, 0Ah, 0Dh
	
	db 0C8h
	times 28 db 0CDh
	db 0BCh, 0Ah, 0Dh, 0h

MSGNone	times 28 db 20h
	db 0h
MSGBoot	db "Loading stage2", 0h
MSGVrfy	db "Verifying stage2", 0h
MSGFail	db " ..failed",0h
CHRProg	db 0DBh
SIGstg2	db 0E9h, 06h, 0h, "STAGE2" 

; Boot Sector 512 bytes big + boot signature
times 510 - ($ - $$) db 0
signature db 055h, 0AAh