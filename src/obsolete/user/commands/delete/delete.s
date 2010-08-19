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
