;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OGRP-OS Kernel - Interrupts							;
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
