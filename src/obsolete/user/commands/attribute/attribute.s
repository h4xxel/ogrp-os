; * This file is a part of the ogrp-os project
; * Version: 0.1 19 Aug 2010
;
; * Authors: jockepockee, mr3d (jockepockee.com, h4xxel.ath.cx)
; * Email: jocke@h4xx.org h4xxel@h4xx.org
;
; * Copyright 2010 ogrp
; * License: see COPYING file
s
mov	bx, si

	ParameterCheckLoop:
		cmp	[es:si], byte ':'
		je	Parameter
		cmp	[es:si], byte 0
		je	NoAttrib
		inc	si
	jmp	ParameterCheckLoop
	Parameter:
	
mov	[es:si], byte 0
inc	si
xor	al, al	
AddAttribs:
mov	dh, [es:si]
cmp	dh, 0
je	AddAttribFinished
AddAttribX:
	cmp	dh, 'x'
	jne	AddAttribR
	mov	dl, al
	and	dl, 0000_0001b
	cmp	dl, 0000_0001b
	je	NoAttrib
	add	al, 0000_0001b
	inc	si
	jmp	AddAttribs
AddAttribR:
	cmp	dh, 'r'
	jne	AddAttribW
	mov	dl, al
	and	dl, 0000_0010b
	cmp	dl, 0000_0010b
	je	NoAttrib
	add	al, 0000_0010b
	inc	si
	jmp	AddAttribs
AddAttribW:
	cmp	dh, 'w'
	jne	AddAttribV
	mov	dl, al
	and	dl, 0000_0100b
	cmp	dl, 0000_0100b
	je	NoAttrib
	add	al, 0000_0100b
	inc	si
	jmp	AddAttribs
AddAttribV:
	cmp	dh, 'v'
	jne	NoAttrib
	mov	dl, al
	and	dl, 0000_1000b
	cmp	dl, 0000_1000b
	je	NoAttrib
	add	al, 0000_1000b
	inc	si
	jmp	AddAttribs


AddAttribFinished:
xor	dx, dx
xor	cx, cx
mov	ah, 4
cmp	[es:bx], byte 0
je	AttribEnd
int	25h

cmp	ah, 1
je	ErrorOccured

push	cs
pop	es
xor	dx, dx
xor	cx, cx
mov	ah, 0
mov	bx, AttribChangedMSG
int	26h

jmp	AttribEnd

NoAttrib:
	push	cs
	pop	es
	mov	ah, 0
	mov	bx, NoAttribMSG
	int	26h
	jmp	AttribEnd
	
DriveNotReady:
	push	cs
	pop	es
	mov	ah, 0
	mov	bx, DriveNotReadyMSG
	int	26h
	jmp	AttribEnd
	
NoFile:
	push	cs
	pop	es
	mov	ah, 0
	mov	bx, NoFileMSG
	int	26h
	jmp	AttribEnd

ErrorOccured:
cmp	al, 1
je	DriveNotReady
cmp	al, 2
je	NoFile

push	cs
pop	es
mov	ah, 0
mov	bx, UnknownErrorMSG
int	26h


AttribEnd:
retf

AttribChangedMSG	db "Attributes changed!",13d,10d,0
DriveNotReadyMSG	db "Error: Drive not ready!",13d,10d,0
NoFileMSG		db "Error: No such file!",13d,10d,0
NoAttribMSG		db "Error: Invalid attribute string!",13d,10d,0
UnknownErrorMSG		db "Error: Unknown error!",13d,10d,0
