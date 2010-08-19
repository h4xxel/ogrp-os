;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OGRP-OS Commands - Create File						;
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
cmp	[es:bx], byte 0
je	CreateEnd

mov	ah, 0
mov	al, 0eh
int	25h

cmp	ah, 1
je	ErrorOccured

push	cs
pop	es
mov	ah, 0
mov	bx, FileCreatedMSG
int	26h

jmp	CreateEnd

AlreadyExists:
	push	cs
	pop	es
	mov	ah, 0
	mov	bx, AlreadyExistsMSG
	int	26h
	jmp	CreateEnd
	
DriveNotReady:
	push	cs
	pop	es
	mov	ah, 0
	mov	bx, DriveNotReadyMSG
	int	26h
	jmp	CreateEnd
	
DiskFull:
	push	cs
	pop	es
	mov	ah, 0
	mov	bx, DiskFullMSG
	int	26h
	jmp	CreateEnd

ErrorOccured:
cmp	al, 1
je	DriveNotReady
cmp	al, 2
je	DiskFull
cmp	al, 3
je	AlreadyExists

push	cs
pop	es
mov	ah, 0
mov	bx, UnknownErrorMSG
int	26h
	
CreateEnd:
retf

FileCreatedMSG		db "File created!",13d,10d,0
DriveNotReadyMSG	db "Error: Drive not ready!",13d,10d,0
DiskFullMSG		db "Error: Disk full!",13d,10d,0
AlreadyExistsMSG	db "Error: File already exists!",13d,10d,0
UnknownErrorMSG		db "Error: Unknown error!",13d,10d,0