;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OGRP-OS Commands - Reboot							;
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

;If parameter cold is given, system will preform a cold reboot, otherwise a warm
;reboot.

cmp	[es:si], byte 0
je	DoWarm

mov	ax, si

mov	cx, 4
CheckParamLoop:
	mov	dx, 4
	sub	dx, cx
	mov	bx, ColdReboot
	mov	si, ax
	add	si, dx
	add	bx, dx
	
	mov	dx, [es:si]
	cmp	[cs:bx], dx
	jne	DoWarm

loop	CheckParamLoop

mov	ax, 0040h
mov	es, ax
mov	[es:0072h], word 0h
jmp	0ffffh:0000h

DoWarm:
mov	ax, 0040h
mov	es, ax
mov	[es:0072h], word 1234h
jmp	0ffffh:0000h

retf

ColdReboot	db "cold",0