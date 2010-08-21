; * This file is a part of the ogrp-os project
; * Version: 0.1 20 Aug 2010
;
; * Authors: jockepockee, mr3d (jockepockee.com, h4xxel.ath.cx)
; * Email: jocke@h4xx.org h4xxel@h4xx.org
;
; * Copyright 2010 ogrp
; * License: see COPYING file	

pmode:
[bits 32]
;Fucking pmode, baby! :DD
call	io_wait
mov	eax, 10h
mov	ds, ax
mov	es, ax
mov	ss, ax
mov	[0xB800e], word 'dd'


jmp	ContinueC

io_wait:
	push	cx
	mov	cx, 10h
	io_wait_loop:
		times	5 nop
	loop	io_wait_loop
	pop	cx
ret

%include	'interrupts.asm'

ContinueC:
;Commented out to continue to c-kernel
cli
hlt
