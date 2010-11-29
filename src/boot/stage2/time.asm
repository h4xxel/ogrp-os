[bits 32]
sleep:
	pushf
	mov	[ds:TimerSemaphore], eax
	sti
	.loop:
		hlt
		cmp	dword [ds:TimerSemaphore], 0
	jne	.loop
	popf
ret

timer_setup:
	pushf
	mov	eax, 28h
	mov	ebx, ISRTimer
	call	RegisterISR
	in	al, 0A1h
	and	al, 0FEh
	out	0A1h, al
	cli
	mov	al, 0Bh
	out	70h, al
	in	al, 71h
	mov	dh, al
	mov	al, 0Bh
	out	70h, al
	mov	al, 40h
	or	al, dh
	out	71h, al
	popf
ret

ISRTimer:
	pusha
	cmp	dword [ds:TimerSemaphore], 0
	je	.end
		dec	dword [ds:TimerSemaphore]
	.end:
	mov	al, 0Ch
	out	70h, al
	in	al, 71h
	mov	al, 20h
	out	20h, al
	out	0A0h, al
	popa
iret
TimerSemaphore	dd 0
