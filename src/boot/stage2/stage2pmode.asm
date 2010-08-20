pmode:
[bits 32]
;Fucking pmode, baby! :DD
mov	eax, 10h
mov	ds, ax
mov	es, ax
mov	ss, ax
mov	[0xB800e], word 'dd'
cli
hlt