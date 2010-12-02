; * This file is a part of the ogrp-os project
; * Version: 0.1 20 Aug 2010
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
mov	bx, MSGVer
call	Print
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

mov	bx, MSGVrfy
call	Print

call	Stage2Verify
call	ProgressStep


jmp 1000h:0000h

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

Stage2Verify:
	mov	bx, 1000h
	mov	es, bx
	mov	bx, SIGstg2+8d
	mov	cx, 8
	.l1:
		mov	si, cx
		mov	ah, [es:si]
		cmp	ah, [cs:bx]
		jne	LoadError
		dec	bx
	loop	.l1
ret

LoadError:
	mov	bx, MSGFail
	call	Print
	mov	bx, MSGEnd
	call	Print
	cli
	hlt

BData	db "BootData:"
BSec	db 2h	;Sector number for stage2
BCyl	db 0h	;Cylinder number for stage2
BDrive	db 0h	;Drive number for stage2
BHead	db 0h	;Head number for stage2
BSize	db 18d	;Size of stage2 in sectors

MSGVer	db "OGRP Operating System version 0.1", 13d, 10d, 13d, 10d, 0
MSGBoot	db "Loading stage2.....[", 0h
MSGVrfy	db "Verifying stage2...[", 0h
MSGFail	db "FAIL",0h
MSGDone	db "DONE",0h
MSGEnd	db "]",13d,10d,0

SIGstg2	db 0E9h, 06h, 0h, "STAGE2" 

; Boot Sector 512 bytes big + boot signature
times 510 - ($ - $$) db 0
signature db 055h, 0AAh