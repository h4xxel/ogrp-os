; * This file is a part of the ogrp-os project
; * Version: 0.1 20 Aug 2010
;
; * Authors: jockepockee, mr3d (jockepockee.com, h4xxel.ath.cx)
; * Email: jocke@h4xx.org h4xxel@h4xx.org
;
; * Copyright 2010 ogrp
; * License: see COPYING file	

LoadGDT:
	push	cs
	pop	ds
	lgdt	[ds:gdtr]
ret

gdtr:
	dw	gdt_end - gdt_data
	dd	10000h+gdt_data
gdt_data:
	dq 0h
	
	dw 0FFFFh
	dw 0h
	db 1h
	db 9Ah
	db 1100_1111b
	db 0h
	
	dw 0FFFFh
	dw 0h
	db 0h
	db 92h
	db 1100_1111b
	db 0h
gdt_end: