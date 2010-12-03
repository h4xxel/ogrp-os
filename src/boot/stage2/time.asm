[bits 32]
sleep:
	pushf
	mov	[ds:timer_semaphore], eax
	sti
	.loop:
		hlt
		cmp	dword [ds:timer_semaphore], 0
	jne	.loop
	popf
ret

timer_setup:
	pushf
	mov	eax, 28h
	mov	ebx, timer_isr
	call	isr_register
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

timer_isr:
	pusha
	cmp	dword [ds:timer_semaphore], 0
	je	.end
		dec	dword [ds:timer_semaphore]
	.end:
	mov	al, 0Ch
	out	70h, al
	in	al, 71h
	mov	al, 20h
	out	20h, al
	out	0A0h, al
	popa
iret
timer_semaphore	dd 0

io_wait:
	push	cx
	mov	cx, 10h
	.l1:
		times	5 nop
	loop	.l1
	pop	cx
ret