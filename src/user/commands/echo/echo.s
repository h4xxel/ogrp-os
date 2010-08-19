; * This file is a part of the ogrp-os project
; * Version: 0.1 19 Aug 2010
;
; * Authors: jockepockee, mr3d (jockepockee.com, h4xxel.ath.cx)
; * Email: jocke@h4xx.org h4xxel@h4xx.org
;
; * Copyright 2010 ogrp
; * License: see COPYING file

mov	bx, si
mov	ah, 0
cmp	[es:bx], byte 0
je	NoParameter
int	26h
NoParameter:
mov	ah, 0
push	cs
pop	es
mov	bx, newline
int	26h
retf
newline db 13d,10d,0
