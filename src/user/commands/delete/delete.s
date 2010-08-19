;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OGRP-OS Commands - Delete File						;
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
je	DeleteEnd

mov	ah, 1
mov	bx, si
int	25h

cmp	ah, 1
je	ErrorOccured

push	cs
pop	es
mov	ah, 0
mov	bx, FileDeletedMSG
int	26h

jmp	DeleteEnd

NoWrite:
	push	cs
	pop	es
	mov	ah, 0
	mov	bx, NoWriteMSG
	int	26h
	jmp	DeleteEnd
	
DriveNotReady:
	push	cs
	pop	es
	mov	ah, 0
	mov	bx, DriveNotReadyMSG
	int	26h
	jmp	DeleteEnd
	
NoFile:
	push	cs
	pop	es
	mov	ah, 0
	mov	bx, NoFileMSG
	int	26h
	jmp	DeleteEnd

ErrorOccured:
cmp	al, 1
je	DriveNotReady
cmp	al, 2
je	NoFile
cmp	al, 3
je	NoWrite

push	cs
pop	es
mov	ah, 0
mov	bx, UnknownErrorMSG
int	26h
	
DeleteEnd:
retf

FileDeletedMSG		db "File deleted!",13d,10d,0
DriveNotReadyMSG	db "Error: Drive not ready!",13d,10d,0
NoFileMSG		db "Error: No such file!",13d,10d,0
NoWriteMSG		db "Error: File is write-protected!",13d,10d,0
UnknownErrorMSG		db "Error: Unknown error!",13d,10d,0