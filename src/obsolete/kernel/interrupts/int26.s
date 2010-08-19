; * This file is a part of the ogrp-os project
; * Version: 0.1 19 Aug 2010
;
; * Authors: jockepockee, mr3d (jockepockee.com, h4xxel.ath.cx)
; * Email: jocke@h4xx.org h4xxel@h4xx.org
;
; * Copyright 2010 ogrp
; * License: see COPYING file

[GLOBAL Int26]
;Begin Interrupt 26
;	Operating System Functions
Int26:

push	bx
push	cx
push	dx
push	ss
push	sp
push	bp
push	si
push	di
push	ds
push	es

Int26ah0:
cmp	ah, 0
jne Int26ah1

	;ah 0: Print NULL-termiated string
	;es - Segment, bx - Offset
	mov	ah, 0eh
	Int26ah0NextChar:
	mov	al, [es:bx]
	cmp	al, 0
	je	Int26ahEnd
	
		int	10h
		inc	bx
		
	jmp	Int26ah0NextChar
	;End

Int26ah1:
cmp	ah, 1
jne	Int26ah2
	
	; ah 1: Clear screen
	mov	ah, 7h
	mov	al, 0
	mov	bh, 7h
	mov	ch, 0
	mov	cl, 0
	mov	dh, 24
	mov	dl, 80
	int	10h
	
	mov	ah, 2
	mov	bh, 0
	mov	dh, 0
	mov	dl, 0
	int	10h
	
	jmp	Int26ahEnd

cmp	ah, 2
jne	Int26ah3
Int26ah2:

	; ah 2: Get keyboard string
	xor cl, cl
	
	getNext:
		mov	ah, 0
		int	16h
	
		cmp	al, 13
		je	Int26ah2Ret
	
		cmp	al, 8
		je	Int26ah2BS
	
		mov	ah, 0eh
		int	10h
	
		mov	[es:bx], al
		inc	bx
		inc	cl
			
		jmp	getNext
	
	Int26ah2BS:
		cmp	cl, 0
		je	getNext
	
		mov	ah, 0eh
		mov	al, 8
		int	10h
	
		mov	al, 0
		int	10h
	
		mov	al, 8
		int	10h
	
		;mov	ah, 2
		;int	0x10
	
		dec	bx
		mov	byte [es:bx], 0
		dec	cl
			
		jmp	getNext

	Int26ah2Ret:
		cmp	cl, 0
		jna	getNext
	
	Int26ah2End:
		mov	byte [es:bx], 0
	
		mov	ah, 0Eh
		mov	al, 13d
		int	10h
		mov	al, 10d
		int	10h

		

		jmp	Int26ahEnd	

cmp	ah, 3
jne	Int26ah4
Int26ah3:

Int26ah4:
cmp	ah, 4
jne	Int26ahEnd


Int26ahEnd:

pop	es
pop	ds
pop	di
pop	si
pop	bp
pop	sp
pop	ss
pop	dx
pop	cx
pop	bx

iret
;End Interrupt 26
