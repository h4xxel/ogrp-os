; * This file is a part of the ogrp-os project
; * Version: 0.1 19 Aug 2010
;
; * Authors: jockepockee, mr3d (jockepockee.com, h4xxel.ath.cx)
; * Email: jocke@h4xx.org h4xxel@h4xx.org
;
; * Copyright 2010 ogrp
; * License: see COPYING file

[BITS 16]

;;;;;;;;;;;;;;;;;;;;;;;;;
; Code			;
;;;;;;;;;;;;;;;;;;;;;;;;;
[SECTION .text]

%include "include/externs.inc"
[GLOBAL main]
main:
	; Set stack
	mov	ax, 07e0h
	mov	ss, ax
	mov	sp, 0200h
	
	; Define interrupts
	xor	ax, ax
	mov	cl, 0x25
	mov	dx, Int25
	call	IntDef
	
	xor 	ax, ax
	mov	cl, 0x26
	mov	dx, Int26
	call	IntDef
	
	
	
	; Print welcome messsage
	
	push	cs
	pop	es
	
	mov	ah, 0
	mov	bx, BootMSG1
	int	26h
	
	mov	ah, 0
	mov	bx, BootMSG2
	int	26h
	
	mov	ah, 0
	mov	bx, BootMSG3
	int	26h
	
	; The prompt
KernelPromptLoop:
	push	cs
	pop	es
	
	mov	ah, 0
	mov	bx, Prompt
	int	26h
	
	mov	ah, 2
	push	cs
	pop	es
	mov	bx, KernelTempData
	int	26h
	
		
	mov	bx, KernelTempData
	ParameterCheckLoop:
		cmp	[cs:bx], byte ':'
		je	Parameter
		cmp	[cs:bx], byte 0
		je	ParameterCheckLoopEnd
		inc	bx
	jne	ParameterCheckLoop
	Parameter:
	mov	[cs:bx], byte 0
	inc	bx
	mov	dx, cs
	mov	si, bx
	jmp	ParameterEnd
	ParameterCheckLoopEnd:
	inc	bx
	mov	[cs:bx], byte 0
	mov	dx, cs
	mov	si, bx
	ParameterEnd:
	
	mov	ah, 3
	mov	bx, KernelTempData
	push	cs
	pop	es
	int	25h
	
	cmp	ah, 01h
	je	ExecError
	
jmp	KernelPromptLoop

ExecError:
	push	cs
	pop	es
	
	ExecError1:
	cmp	al, 01h
	jne	ExecError2
		mov	ah, 0
		mov	bx, ExecError1MSG
		int	26h
		jmp	ExecErrorEnd
	ExecError2:
	cmp	al, 03h
	jne	ExecError3
		mov	ah, 0
		mov	bx, ExecError2MSG
		int	26h
		jmp	ExecErrorEnd
	ExecError3:
	cmp	al, 05h
	jne	ExecErrorUnknown
		mov	ah, 0
		mov	bx, ExecError3MSG
		int	26h
		jmp	ExecErrorEnd
	ExecErrorUnknown:
		mov	ah, 0
		mov	bx, ExecErrorUnknownMSG
		int	26h
	ExecErrorEnd:
	mov	ax, 0
jmp KernelPromptLoop

;;;;;;;;;;;;;;;;;;;;;;;;;
; Data			;
;;;;;;;;;;;;;;;;;;;;;;;;;
[SECTION .data]
BootMSG1 db 13d,10d,13d,10d,"Open Group Operating System",13d,10d,0h
BootMSG2 db "An open source hobby project operating system",13d,10d,0h
BootMSG3 db 13d,10d,"Authors:",13d,10d,"  Bootloader: JockePockee, Mr3D",13d,10d,"  Kernel: Jockepockee, Mr3D",13d,10d,13d,10d,13d,10d,0h

Prompt db "Kernel: ",0

ExecError1MSG db "Error: Disk not ready!",13d,10d,0
ExecError2MSG db "Error: File does not exist!",13d,10d,0
ExecError3MSG db "Error: File is not executable!",13d,10d,0
ExecErrorUnknownMSG db "Error: Unknown error!",13d,10d,0


;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel End		;
;;;;;;;;;;;;;;;;;;;;;;;;;
[SECTION .bss]
;Store any keybord input right after the kernel
[GLOBAL	KernelTempData]
KernelTempData:
