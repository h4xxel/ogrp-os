; * This file is a part of the ogrp-os project
; * Version: 0.1 19 Aug 2010
;
; * Authors: jockepockee, mr3d (jockepockee.com, h4xxel.ath.cx)
; * Email: jocke@h4xx.org h4xxel@h4xx.org
;
; * Copyright 2010 ogrp
; * License: see COPYING file

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
