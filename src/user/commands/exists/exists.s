; * This file is a part of the ogrp-os project
; * Version: 0.1 19 Aug 2010
;
; * Authors: jockepockee, mr3d (jockepockee.com, h4xxel.ath.cx)
; * Email: jocke@h4xx.org h4xxel@h4xx.org
;
; * Copyright 2010 ogrp
; * License: see COPYING file

mov	bx, si
mov	ah, 2
cmp	[es:bx], byte 0
je	ExistsEnd
int	25h

mov	dh, al
cmp	ah, 0
jne	NotExist

mov	ah, 0
push	cs
pop	es
mov	bx, ExistsMSG
int	26h

mov	ah, 0
mov	bx, AttributesMSG
int	26h

A1:
	mov	dl, dh
	and	dl, 0000_0001b
	cmp	dl, 0000_0001b
	jne	A2
	mov	bx, A1MSG
	mov	ah, 0
	int	26h

A2:
	mov	dl, dh
	and	dl, 0000_0010b
	cmp	dl, 0000_0010b
	jne	A3
	mov	bx, A2MSG
	mov	ah, 0
	int	26h
	
A3:
	mov	dl, dh
	and	dl, 0000_0100b
	cmp	dl, 0000_0100b
	jne	A4
	mov	bx, A3MSG
	mov	ah, 0
	int	26h
A4:
	mov	dl, dh
	and	dl, 0000_1000b
	cmp	dl, 0000_1000b
	jne	AddNewLine
	mov	bx, A4MSG
	mov	ah, 0
	int	26h

AddNewLine:
mov	ah, 0
mov	bx, newline
int	26h

jmp	ExistsEnd
NotExist:
mov	ah, 0
push	cs
pop	es
mov	bx, NotExistMSG
int	26h
jmp	ExistsEnd


ExistsEnd:
retf

ExistsMSG db "File exists!",13d,10d,0
NotExistMSG db "File does not exist!",13d,10d,0
AttributesMSG db "Attributes: ",0
A1MSG db "x",0
A2MSG db "r",0
A3MSG db "w",0
A4MSG db "v",0
newline db 13d,10d,0
