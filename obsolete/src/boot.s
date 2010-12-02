; * This file is a part of the ogrp-os project
; * Version: 0.1 19 Aug 2010
;
; * Authors: jockepockee, mr3d (jockepockee.com, h4xxel.ath.cx)
; * Email: jocke@h4xx.org h4xxel@h4xx.org
;
; * Copyright 2010 ogrp
; * License: see COPYING file

;Supports filesystem OGRP-FS version 1

[BITS 16]	; We are still in realmode :)
[ORG 7C00h]	; BIOS loads us to 0x7C0. CPU need to know it D:

; Bootup code.
boot:
	
	;Clear Screen
	mov	ax, 0700h
	mov	bh, 07h
	mov	dx, 02480h
	int	10h
	
	mov	ah, 2
	mov	bh, 0
	xor	dx, dx
	int	10h
	
	;Print Boot Messages
	mov	bx, LoaderMSG1
	call	Print
	mov	bx, LoaderMSG2
	call	Print

	mov	ax, 0201h	; BIOS drive load function and Number of sectors to read
	mov	cx, 0002h	; Read from cylinder 0 and Read from sector 2
	xor	dx, dx		; Read from head 0 and Read from floppy drive 0
	mov	bx, 0800h	;
	mov	ds, bx		; Just for later
	mov	es, bx		; Read to segment 0x0800
	xor	bx, bx		; And offset 0x0000

	
	; Load First sector of file table to loacate kernel
	int	13h
	jc	LoadError
	
	mov	bx, LoaderMSG3
	call	Print
	
	;mov	bx, 0800h
	;mov	es, bx
	mov	ah, 2
	mov	al, [es:0008h]
	mov	cx, 0002h
	xor	dx, dx
	;mov	es, bx
	xor	bx, bx
	;Load
	int	13h
	jc	LoadError
	
	
	xor	cx, cx
	FSCheckLoop:
		mov	bx, cx
		add	bx, FSHeader
		mov	dl, [cs:bx]
		mov	bx, cx
		cmp	[es:bx], dl
		jne	FSError
		inc	cx
		cmp	cx, 7
	jne	FSCheckLoop
	
	mov	bx, LoaderMSG5
	call	Print		;Print that file system is OK
	
	
	xor	cx, cx
	KernelFindLoop:
		mov	bx, Kernel
		mov	dl, [cs:bx]
		mov	si, cx
		cmp	[es:si], dl
		jne	KernelFindLoopContinue
			push	cx
			push	bx
			KernelFindSubLoop:
				dec	cx
				mov	si, cx
				cmp	[es:si], byte 0
				pushf
				inc	cx
				popf
				jne	KernelFindSuperRet
				KernelFindSubLoopContinue:
					inc	cx
					inc	bx
					mov	dl,[cs:bx]
					mov	si, cx
					cmp	[es:si], dl
			je	KernelFindSubLoopNullCheck	
			KernelFindSuperRet:
			pop	bx
			pop	cx
			jmp	KernelFindLoopContinue
			KernelFindSubLoopNullCheck:
			cmp	[es:si], byte 0
			jne	KernelFindSubLoopContinue
			pop	bx
			pop	cx
			jmp	KernelFindLoopEnd
		KernelFindLoopContinue:
		cmp	cx, 0ffffh
		je	KernelError
		inc	cx
		jmp	KernelFindLoop
	KernelFindLoopEnd:
	
	mov	bx, LoaderMSG7
	call	Print
	
	add	si, 2
	mov	ch, [ds:si]
	mov	dh, ch
	and	ch, 0111_1111b
	
	and	dh, 1000_0000b
	shr	dh, 7
	
	inc	si
	mov	cl, [es:si]
	dec	si
	
	xor	bx, bx
	
	CopyLoop:
		push	bx
		mov	ax, 0201h
		mov	dl, 0		; Read from floppy drive
		mov	bx, 1000h	;
		mov	es, bx		; Read to segment 0x1000
		pop	bx
		
		int	13h
		jc	LoadError
		
		add	bx, 0200h
		add	si, 2
		
		mov	ch, [ds:si]
		mov	dh, ch
		and	ch, 0111_1111b
		
		and	dh, 1000_0000b
		shr	dh, 7
		
		inc	si
		mov	cl, [ds:si]
		dec	si
		cmp	[ds:si], word 0000h
		;inc	si
	jne	CopyLoop
	
	;mov	[es:si], word 0000h
	
	; Jump to the kernel poition
	jmp	1000h:0000h
	
	LoadError:
		mov	bx, LoaderMSG4
		call	Print
		jmp	FailLoop
	
	
	FSError:
		mov	bx, LoaderMSG6
		call	Print
		jmp	FailLoop
		
	KernelError:
		mov	bx, LoaderMSG8
		call	Print
		jmp	FailLoop
	
	
	FailLoop: jmp	 FailLoop
	
	LoaderMSG1	db "OGRP-OS Bootloader",13d,10d,0
	LoaderMSG2	db "Initializing filesystem",13d,10d,0
	LoaderMSG3	db " -Filetable loaded",13d,10d,0
	LoaderMSG4	db "Disk read failure!",13d,10d,0
	LoaderMSG5	db " -Filesystem is OGRP-FS 1",13d,10d,0
	LoaderMSG6	db "Wrong filesystem version!",13d,10d,0
	LoaderMSG7	db " -Kernel located",13d,10d,0
	LoaderMSG8	db "Kernel not found!",13d,10d,0
	
	FSHeader	db "OGRP-FS1"
	Kernel		db "KERNEL",0
	
Print:
	;Print NULL-termiated string
	mov	ah, 0eh
	PrintNext:
	mov	al, [cs:bx]
	cmp	al,0
	je	PrintEnd
		int	10h
		inc	bx
	jmp	PrintNext
	;End
PrintEnd:
ret


; Boot Sector 512 bytes big + boot signature
times 510 - ($ - $$) db 0
signature db 055h, 0AAh