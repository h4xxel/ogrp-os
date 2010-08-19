;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OGRP-OS Commands - Change attributes for files				;
;										;
; This package is free software; you can redistribute it and/or modify		;
; it under the terms of the GNU General Public License as published by		;
; the Free Software Foundation; either version 2 of the License, or		;
; (at your option) any later version.						;
;										;
; This package is distributed in the hope that it will be useful,		;
; but WITHOUT ANY WARRANTY; without even the implied warranty of		;
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the			;
; GNU General Public License for more details.					;
;										;
; You should have received a copy of the GNU General Public License		;
; along with this package; if not, write to the Free Software			;
; Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA	;
;										;
; Version 0.1									;
; Copyright 2009 JockePockee Mr3D						;
; Email: jockpockee@gmail.com, alson@passagen.se				;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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