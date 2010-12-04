[bits 32]

keyboard_setup:
	mov	eax, 21h
	mov	ebx, keyboard_isr
	call	isr_register
	; Unmask IRQ
	in	al, 021h
	and	al, 11111101b
	out	021h, al
ret

keyboard_isr:
	pusha
	in	al, 60h
	mov	[keyboard_last_scancode], al
	
	; print scancode (for debugging)
	; xor	ebx,	ebx
	; mov	bl, al
	; mov	ah, 06h
	; mov	ecx, 16
	; call	print_int
	
	cmp	al, 80h
	ja	.check_mod
		xor	ebx, ebx
		mov	bl, al
		mov	cl, [keyboard_mod_mask]
		and	cl, 1
		cmp	cl, 1
		je	.shifted
			add	ebx, keymap_en_us
			jmp	.print
		.shifted:
			add	ebx, keymap_en_us.shift
		.print:
		mov	dl, [ebx]
		cmp	dl, 0
		je	.check_mod
			mov	[keyboard_last_char], dl
		
	.check_mod:
		cmp	al, 2Ah
		je	.set_shift
		cmp	al, 0AAh
		je	.clear_shift
		cmp	al, 36h
		je	.set_shift
		cmp	al, 0B6h
		je	.clear_shift
		
		cmp	al, 1Dh
		je	.set_ctrl
		cmp	al, 09Dh
		je	.clear_ctrl
		cmp	al, 38h
		je	.set_alt
		cmp	al, 0B8h
		je	.clear_alt
		jmp	.check_ctrl_alt_del
		
	.set_shift:
		mov	cl, [keyboard_mod_mask]
		or	cl, key_mod_shift
		mov	[keyboard_mod_mask], cl
		jmp	.end
	.clear_shift:
		mov	cl, [keyboard_mod_mask]
		and	cl, (~key_mod_shift)
		mov	[keyboard_mod_mask], cl
		jmp	.end
		
	.set_ctrl:
		mov	cl, [keyboard_mod_mask]
		or	cl, key_mod_ctrl
		mov	[keyboard_mod_mask], cl
		jmp	.end
	.clear_ctrl:
		mov	cl, [keyboard_mod_mask]
		and	cl, (~key_mod_ctrl)
		mov	[keyboard_mod_mask], cl
		jmp	.end
		
	.set_alt:
		mov	cl, [keyboard_mod_mask]
		or	cl, key_mod_alt
		mov	[keyboard_mod_mask], cl
		jmp	.end
	.clear_alt:
		mov	cl, [keyboard_mod_mask]
		and	cl, (~key_mod_alt)
		mov	[keyboard_mod_mask], cl
		jmp	.end

	.check_ctrl_alt_del:
	cmp	al, 53h
	jne	.end
	cmp	[keyboard_mod_mask], byte 00000110b
	jne	.end
		mov	al, 20h
		mov	[keyboard_last_char], byte 0
		mov	[keyboard_last_scancode], byte 0
		out	20h, al
		call reboot
		popa
		iret
.end:
mov	al, 20h
out	20h, al
popa
iret

msg_scancode		db "KBD: 0x", 0
space			db ' ',0

keyboard_last_scancode	db 0
keyboard_last_char	db 0
keyboard_mod_mask	db 0

key_mod_shift		equ 1
key_mod_ctrl		equ 2
key_mod_alt		equ 4


keymap_en_us:
	db 0,27
	db '1','2','3','4','5','6','7','8','9','0','-','=',8
	db 9, 'q','w','e','r','t','y','u','i','o','p','[',']', 13, 0
	db 'a','s','d','f','g','h','j','k','l',';',"'", '`', 0, '\'
	db 'z','x','c','v','b','n','m',',','.','/',0
	db 0,0,' ',0
	dq 0,0,0
	db 127
	dq 0,0,0,0,0
	db 0
	.shift:
	db 0,27
	db '!','@','#','$','%','^','&','*','(',')','_','+',8
	db 9, 'Q','W','E','R','T','Y','U','I','O','P','{','}', 13d, 0
	db 'A','S','D','F','G','H','J','K','L',':','"', '~', 0, '|'
	db 'Z','X','C','V','B','N','M','<','>','?',0
	db 0,0,' ',0
	dq 0,0,0
	db 127
	dq 0,0,0,0,0
	db 0

getc:
	; Waits for a key press and returns the keychar and scancode
	; Returns:
	;	al	char
	;	ah	scancode
	mov	[keyboard_last_char], byte 0
	sti
	.l1:
		hlt
		mov	al, [keyboard_last_char]
	cmp	al, 0
	je	.l1
	mov	ah, [keyboard_last_scancode]
ret

print:
	; Print NULL-termiated string
	; ebx	string pointer
	; ah	attribute
	mov	edi, [cursor_pos]
	
	;add	edi, edx
	.next:
	mov	al, [ds:ebx]
	cmp	al,0
	je	.end
	cmp	al, 10d
	jne	.check_cr
		;Line Break
		call	line_break
		inc	ebx
		jmp	.next
	.check_cr:
	cmp	al, 13d
	jne	.print
		call	carriage_return
		inc	ebx
		jmp	.next
	.print:
		;Make sure we don't overflow
		cmp	edi, (0B8000h+(0A0h*25d))
		jb .normal
			call	scroll_down
			sub	edi, 0A0h
		.normal:
		mov	[es:edi], ax
		add	edi, 2
		inc	ebx
		;cmp	edi, (0B8000h+(0A0h*25d))
	jmp	.next
.end:
mov	[cursor_pos], edi
call	update_hw_cursor
ret

print_int:
	; Print 32bit integer value
	; ebx	int
	; ah	attribute
	; ecx	base
	mov	esi, print_int_buf_end
	mov	edx, ebx
	mov	bh, ah
	mov	eax, edx
	mov	edi, ecx
	xor	edx, edx
	.next:
		div	edi
		mov	bl, dl
		cmp	bl, 9
		jna	.d
			; For numbers with a base higher than 10
			add bl, 7
		.d:
		add	bl, 30h
		dec	esi
		mov	[esi], bl
		xor	edx, edx
	cmp	ax, 0
	jne	.next
	mov	edi, [cursor_pos]

	mov	ah, bh
	mov	ebx, esi
	call	print
.end:
mov	[cursor_pos], edi
call	update_hw_cursor
ret

print_int_buf		dq 0,0,0,0,0,0,0,0
print_int_buf_end	db 0

line_break:
	cmp	edi, (0B8000h+(0A0h*24d))
	jb	.move
		call	scroll_down
		jmp	.end
	.move:
	add	edi, 0A0h
.end:
ret

carriage_return:
	push	ax
	mov	edx, edi
	sub	edx, 0B8000h
	mov	ax, dx
	shr	edx, 16
	mov	cx, 0A0h
	div	cx
	mul	cx
	mov	di, dx
	shl	edi, 16
	mov	di, ax
	add	edi, 0B8000h
	pop	ax
ret

scroll_down:
	pusha
	mov	edi, 0B8000h
	mov	esi, (0B8000h+0A0h)
	mov	ecx, ((80*24)/2)
	.l1:
		mov	eax, [es:esi]
		mov	[es:edi], eax
		add	edi, 4
		add	esi, 4
	loop	.l1
	mov	cx, 40
	.l2:
		mov	[es:edi], dword 0
		add	edi, 4
	loop	.l2
	popa
ret

update_hw_cursor:
	pusha
	mov	edx, [cursor_pos]
	sub	edx, 0B8000h
	mov	ax, dx
	shr	edx, 16
	mov	cx, 2
	div	cx
	mov	cx, ax
	mov	dx, 3D4h
	mov	al, 0Fh
	out	dx, al
	inc	dx
	mov	al, cl
	out	dx, al
	dec	dx
	mov	al, 0Eh
	out	dx, al
	inc	dx
	mov	al, ch
	out	dx, al
	popa
ret
cursor_pos dd 0B8320h


[bits 16]
; 16 bit code for real mode
print16:
	; Print NULL-termiated string
	; ebx	string pointer
	; ah	attribute
	mov	di, [cursor_pos16]
	mov	dx, 0B800h
	mov	es, dx
	.next:
	mov	al, [bx]
	cmp	al,0
	je	.end
	cmp	al, 10d
	jne	.check_cr
		;Line Break
		add	di, 0A0h
		inc	bx
		jmp	.next
	.check_cr:
	cmp	al, 13d
	jne	.print
		call	carriage_return16
		inc	bx
		jmp	.next
	.print:
		mov	[es:di], ax
		add	di, 2
		inc	bx
	jmp	.next
.end:
mov	[cursor_pos16], di
call	update_hw_cursor16
ret

carriage_return16:
	push	ax
	mov	ax, di
	xor	dx, dx
	mov	cx, 0A0h
	div	cx
	mul	cx
	mov	di, ax
	pop	ax
ret

cursor_pos16	dw (0A0h*4)

update_hw_cursor16:
	mov	ax, [cursor_pos16]
	xor	dx, dx
	mov	cx, 2
	div	cx
	mov	cx, ax
	mov	dx, 3D4h
	mov	al, 0Fh
	out	dx, al
	inc	dx
	mov	al, cl
	out	dx, al
	dec	dx
	mov	al, 0Eh
	out	dx, al
	inc	dx
	mov	al, ch
	out	dx, al
ret