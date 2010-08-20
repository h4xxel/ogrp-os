; * This file is a part of the ogrp-os project
; * Version: 0.1 19 Aug 2010
;
; * Authors: jockepockee, mr3d (jockepockee.com, h4xxel.ath.cx)
; * Email: jocke@h4xx.org h4xxel@h4xx.org
;
; * Copyright 2010 ogrp
; * License: see COPYING file

[BITS 32]
SECTION .text

extern ckmain
extern ckprint

global kentry
kentry:
	mov	ax, 0x10	  ; Enter right data segment
	mov	ds, ax		  ; must go through ax

	mov	esp, sys_stack__  ; new stack area

	call	ckmain		  ; c-coded kernel main

	mov	eax, [ck_quitmsg] ; quitmessage
	call	ckprint		  ; print it!

	cli			  ; clear interrupts
	hlt			  ; halt
	jmp $			  ; fallthrough

SECTION .data
ck_quitmsg	db 0ah, "Kernel FUCKUP!1one", 0ah, "ur kenrel has quitted for some reason... :/", 0h

SECTION .bss
	resb 8192
sys_stack__:
