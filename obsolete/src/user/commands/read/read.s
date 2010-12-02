; * This file is a part of the ogrp-os project
; * Version: 0.1 19 Aug 2010
;
; * Authors: jockepockee, mr3d (jockepockee.com, h4xxel.ath.cx)
; * Email: jocke@h4xx.org h4xxel@h4xx.org
;
; * Copyright 2010 ogrp
; * License: see COPYING file

mov	bx, si
push	cs
pop	ds
mov	di, Receive
mov	ah, 6
cmp	[es:bx], byte 0
je	ReadEnd
int	25h

cmp	ah, 0
jne	FileError

mov	ah, 0
push	cs
pop	es
mov	bx, Receive
int	26h

mov	ah, 0
mov	bx, newline
int	26h


jmp	ReadEnd

FileError:
	cmp	al, 6
	je	NoRead
	cmp	al, 3
	je	NotExist
	jmp	ReadEnd
	
NoRead:
	mov	ah, 0
	push	cs
	pop	es
	mov	bx, NoReadMSG
	int	26h
	jmp	ReadEnd
NotExist:
	mov	ah, 0
	push	cs
	pop	es
	mov	bx, NotExistMSG
	int	26h
	jmp	ReadEnd


ReadEnd:
retf

NotExistMSG db "File does not exist!",13d,10d,0
NoReadMSG db "File is not readable!",13d,10d,0
newline db 13d,10d,0
Receive:
db 0
