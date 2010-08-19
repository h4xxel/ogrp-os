; * This file is a part of the ogrp-os project
; * Version: 0.1 19 Aug 2010
;
; * Authors: jockepockee, mr3d (jockepockee.com, h4xxel.ath.cx)
; * Email: jocke@h4xx.org h4xxel@h4xx.org
;
; * Copyright 2010 ogrp
; * License: see COPYING file

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
