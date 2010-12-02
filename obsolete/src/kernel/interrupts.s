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
%include "include/templabel.inc"
[GLOBAL IntDef]
; Interrupt definer
IntDef:
	; Interrupt number in cl
	; Offset in dx
	xor	ax, ax
	mov	es, ax		; We use the extra segment register to point to the segment of the interrupt table (0000h)

	mov	al, cl

	; Calculate interrupt
	; position
	mov	bl, 4h 		; Each interrupt vector is 2 words (4 bytes) long
	mul	bl		; The position is the interrupt number times four
	mov	bx, ax		; We use bx as offset register to point to the offset of the interrupt vector

	mov	si, dx
	mov	[es:bx], si 	; The high word contains the offset of the actual interrupt, it is here written to the table
	
	add	bx, 2		; We add 2 to get to the low word
	mov	ax, cs		; We temporarily store the segment of the actual interrupt in ax
		
	mov	[es:bx], ax 	; The low word contains the segment of the actual interrupt, here we write it to the table
	
	ret


%include "interrupts/int25.s"
%include "interrupts/int26.s"
