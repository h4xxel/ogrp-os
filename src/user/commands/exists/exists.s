;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OGRP-OS Commands - Check for file's existance					;
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
