;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OGRP-OS Commands - Draw Graphical User Interface					;
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

; Change to graphic mode 12h (640x480, 16 colours)
push	cs
pop	ds
mov	ah, 0
mov	al, 12h
int	10h

;--------------------

mov	al, 1
call	clear_screen
;call	draw_screen
mov	al, 2
call	clear_screen
;call	draw_screen

jmp	$

mov	ah, 0
mov	al, 3
int	10h



retf

clear_screen:	
	mov	dx, 0A000h
	mov	es, dx
	
	mov	ah, al
	mov	al, 2	
	mov	dx, 03c4h
	out	dx, al		;Output 2 to prepare the card for recieving info about the active plane(s)
	
	mov	al, 0000_1111b
	mov	dx, 03c5h
	out	dx, al		;Here we send info about the active plane, each plane is a bit in low nibble
	
	
	mov	bx, 0
	clear_loop:
		mov	[es:bx], word 00000h
		add	bx, 2
	cmp	bx, 38402d
	jne	clear_loop
	
	mov	al, 2	
	mov	dx, 03c4h
	out	dx, al		;Output 2 to prepare the card for recieving info about the active plane(s)
	
	mov	al, ah
	mov	dx, 03c5h
	out	dx, al		;Here we send info about the active plane, each plane is a bit in low nibble
	
	mov	bx, 0
	color_loop:
		mov	[es:bx], word 0FFFFh
		add	bx, 2
	cmp	bx, 38402d
	jne	color_loop
ret

draw_pixel:
;CX, DX - X, Y
;AL - colour (0d to 15d)
mov	[TMPal], al
; push	bx
mov	[TMPcx], cx
mov	[TMPdx], dx
; push	es	;Slowdown


mov	[Colour], al
mov	ax, 320d ;[Line]
mul	dx
mov	bx, 10h
div	bx
add	ax, 07a80h
mov	es, ax
mov	bx, ax
mov	ax, cx
xor	dx, dx
div	word [Two]
mov	bx, ax
mov	cl, dl		;Modulus from divide gives nibble offset
mov	al, [Colour]
shl	al, cl

mov	ch, [es:bx]
and	ch, cl
mov	[es:bx], ch


; pop	es	;Slowdown
mov	dx, [TMPdx]
mov	cx, [TMPcx]
; pop	bx
mov	al, [TMPal]
ret

draw_screen:
	;Here the backbuffer will be copied to the framebuffer att 0A000h
	push	ds
	mov	ax, 0A000h
	mov	es, ax			;Video Memmory Segment
	
		
		mov	ax, 0960h
		add	ax, 7A80h
		mov	ds, ax
		
		mov	al, 2	
		mov	dx, 03c4h
		out	dx, al		;Output 2 to prepare the card for recieving info about the active plane(s)
		
		mov	al, 0000_0001b
		mov	dx, 03c5h
		out	dx, al		;Here we send info about the active plane, each plane is a bit in low nibble
		
		
		
		PlaneCopy:
		xor	bx, bx
		CopyLoop:
			mov	ax, [ds:bx]
			mov	[es:bx], ax
			add	bx, 2
		cmp	bx, 38402d
		jne	CopyLoop
		
		pop	cx
	loop	PlaneCopy
	pop	ds
ret


Line		dw 80d ;(640/8)
Two		dw 2
Eight		db 8
Colour		db 0
BitOffset	db 0
TMPal		db 0
TMPcx		dw 0
TMPdx		dw 0
TMPloopcx	dw 0