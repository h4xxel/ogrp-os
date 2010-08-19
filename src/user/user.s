;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OGRP-OS User Mode								;
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

mov	bx, 0a000h
mov	es, bx
xor	bx, bx
mov	[es:bx], byte 'a'

call unreal_mode



user:
	

	mov	ah, 0
	mov	bx, Prompt
	int	26h

	mov	ah, 2
	mov	bx, InputBuf
	int	26h

	jmp	user

unreal_mode:
	cli

	push	ds

	lgdt	[gdt_ptr]

	mov	eax, cr0
	or	al, 1
	mov	cr0, eax

	mov	bx, 0x08
	mov	ds, bx

	and	al, 0xFE
	mov	cr0, eax

	pop	ds

	call	fast_a20

	sti

	ret

; NEED TO USE THE REAL METHOD IF BIOS REPORTED THAT FAST A20 IST'NT AVAILABLE!!!!!
fast_a20:			; NEED TO USE THE REAL METHOD IF BIOS REPORTED THAT FAST A20 IST'NT AVAILABLE!!!!!
	xor	ax, ax		; NEED TO USE THE REAL METHOD IF BIOS REPORTED THAT FAST A20 IST'NT AVAILABLE!!!!!
				; NEED TO USE THE REAL METHOD IF BIOS REPORTED THAT FAST A20 IST'NT AVAILABLE!!!!!
	in	al, 2		; NEED TO USE THE REAL METHOD IF BIOS REPORTED THAT FAST A20 IST'NT AVAILABLE!!!!!
	or	al, 2		; NEED TO USE THE REAL METHOD IF BIOS REPORTED THAT FAST A20 IST'NT AVAILABLE!!!!!
	out	0x92, al	; NEED TO USE THE REAL METHOD IF BIOS REPORTED THAT FAST A20 IST'NT AVAILABLE!!!!!
				; NEED TO USE THE REAL METHOD IF BIOS REPORTED THAT FAST A20 IST'NT AVAILABLE!!!!!
	ret			; NEED TO USE THE REAL METHOD IF BIOS REPORTED THAT FAST A20 IST'NT AVAILABLE!!!!!
; NEED TO USE THE REAL METHOD IF BIOS REPORTED THAT FAST A20 IST'NT AVAILABLE!!!!!

gdt_ptr:
	dw gdt_end - gdt - 1
	dd gdt

gdt:
	dummy 	dd 0, 0
	flat	db 0xff, 0xff, 0x00, 0x00, 0x00, 10010010b, 11001111b, 0x00
gdt_end:

Prompt	db "User: ", 0

InputBuf:
