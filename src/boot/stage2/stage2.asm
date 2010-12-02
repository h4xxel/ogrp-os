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
mov	ah, 07h
call	print16
call	ProgressStep

cli
call	LoadGDT
mov	eax, cr0
or	eax, 1
mov	cr0,eax
jmp	8h:pmode

;Hang
call	LoadError
cli
hlt
jmp	$


print16:
	; Print NULL-termiated string
	; ebx	string pointer
	; ah	attribute
	mov	di, [cursor_pos16]
	mov	dx, 0B800h
	mov	es, dx
	.next:
	mov	al, [bx]
	cmp	al,0
	je	.end
	cmp	al, 10d
	jne	.check_cr
		;Line Break
		add	di, 0A0h
		inc	bx
		jmp	.next
	.check_cr:
	cmp	al, 13d
	jne	.print
		call	carriage_return16
		inc	bx
		jmp	.next
	.print:
		mov	[es:di], ax
		add	di, 2
		inc	bx
	jmp	.next
.end:
mov	[cursor_pos16], di
call	update_hw_cursor16
ret

carriage_return16:
	push	ax
	mov	ax, di
	xor	dx, dx
	mov	cx, 0A0h
	div	cx
	mul	cx
	mov	di, ax
	pop	ax
ret

cursor_pos16	dw (0A0h*4)

update_hw_cursor16:
	mov	ax, [cursor_pos16]
	xor	dx, dx
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

ProgressStep:
	mov	ah, 02h
	mov	bx, MSGDone
	call	print16
	mov	bx, MSGEnd
	mov	ah, 07h
	call	print16
ret

LoadError:
	mov	bx, MSGFail
	mov	ah, 04h
	call	print16
	mov	bx, MSGEnd
	mov	ah, 07h
	call	print16
	cli
	hlt

%include 'gdt.asm'

MSGPmode	db "Entering pmode.........[", 0h
MSGFail		db "FAIL",0h
MSGDone		db "DONE",0h
MSGEnd		db "]",13d,10d,0

%include 'stage2pmode.asm'

; Just make it fill a whole sector
times 2560 - ($ - $$) nop