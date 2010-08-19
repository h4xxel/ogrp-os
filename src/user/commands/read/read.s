;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OGRP-OS Commands - Read file to memmory					;
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