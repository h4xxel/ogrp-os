[GLOBAL Int25]
;Begin Interrupt 25
;	File System Access
Int25:

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

Int25ah0:
cmp	ah, 0
jne	Int25ah1
	;Create File
	;al - Attributes, [es:bx] - points to null terminated file name
	;ah=01 on error, al=Error code
	
	;Error Codes
	;01h:	Drive not ready
	;02h:	Disk full
	;04h:	File already exists
	
	push	ax
	push	bx
	push	es
	

	call Int25FileTable
	
	;The whole file table is now loaded in memory
	mov	si, bx
	pop	es
	pop	bx
	mov	di, bx
	mov	ax, es
	push	bx
	push	es
	mov	cx, 0800h
	
	Int25ah0CheckForNullNextChar:
		mov	es, ax
		mov	dl, [es:di]
		mov	es, cx
		cmp	[es:si],dl
		jne	Int25ah0CheckForNullFirstChar
			push	si
			push	di
			dec	si
			cmp	[es:si], byte 0
			jne	Int25ah0CheckFileNotExist
			Int25ah0CheckFileExists:
				inc	si
				mov	es, ax
				mov	dl, [es:di]
				inc	di
				mov	es, cx
				cmp	[es:si],dl
			jne	Int25ah0CheckFileNotExist
			cmp	[es:si], byte 0
			je	Int25ah0CheckFileNullMatch
			jmp	Int25ah0CheckFileExists
			Int25ah0CheckFileNullMatch:
			pop	di
			pop	si
			pop	es
			pop	bx
			pop	ax
			jmp	Int25ah0FileExists
			Int25ah0CheckFileNotExist:
			pop	di
			pop	si
		
	Int25ah0CheckForNullFirstChar:
	cmp	[es:si], word 0h
	jne	Int25ah0NoNullChar
	add	si, 2
	cmp	[es:si], word 0h
	je	Int25ah0NullCharFound
	sub	si, 2
	Int25ah0NoNullChar:
		cmp	si, 7000h
		je	Int25ah0DiskFull
		inc	si
	jmp	Int25ah0CheckForNullNextChar
	
	Int25ah0NullCharFound:
	pop	es
	pop	bx
	
	Int25ah0PutNextFileNameChar:
	mov	dl, [es:bx]
	cmp	dl, 0
	
	je	Int25ah0FileNamePutFinished
		mov	dl, [es:bx]
		push	es
		mov	ax, 0800h
		mov	es, ax
		mov	[es:si], dl
		pop	es
		inc	bx
		inc	si
	jmp	Int25ah0PutNextFileNameChar
	
	Int25ah0FileNamePutFinished:
	
	inc	bx
	inc	si
	
	mov	ax, 0800h
	mov	es, ax
	
	pop	ax
	mov	[es:si], al
	inc	si
	
	
	
	;Find a vacant cluster to use as start cluster
	
	mov	cx, 0ah
	mov	di, KernelTempData
	Int25ah0FindClusterLoop:
		
		Int25ah0FindClusterSkipName:
			mov	bx, cx
			inc	cx
			cmp	[es:bx], byte 0
		jne	Int25ah0FindClusterSkipName
		
		inc	cx
		
		Int25ah0FindClusterAddWord:
			mov	bx, cx
			mov	ax, [es:bx]
			mov	[cs:di], ax
			add	di, 2
			add	cx, 2
			cmp	[es:bx], word 0
		jne Int25ah0FindClusterAddWord
		
		sub	di, 2
		add	cx, 2
		cmp	cx, si
		jge	Int25ah0FindClusterEnd
		
	jmp	Int25ah0FindClusterLoop
	
	Int25ah0FindClusterEnd:
	add	di, 2
	
	
	mov	dh, 0			;head
	mov	ch, 0			;cylinder
	mov	cl, byte [es:0008h]	;size of file table
	add	cl, 2			;the first file cluster
	
	Int25ah0FindVacantLoop:
		mov	di, KernelTempData
		mov	al, dh
		shl	al, 7
		add	al, ch
		mov	ah, cl
		sub	di, 2
		Int25ah0FindVacantSubLoop:
			add	di, 2
			cmp	[cs:di], ax
			je	Int25ah0FindVacantSubLoopEnd
			cmp	[cs:di], word 0
		jne Int25ah0FindVacantSubLoop
		
		jmp	Int25ah0FindVacantLoopEnd
		
		Int25ah0FindVacantSubLoopEnd:
		inc	cl
		
		cmp	cl, 19d
		jne	Int25ah0FindVacantSectorOK
			dec	cl
			inc	ch
		Int25ah0FindVacantSectorOK:
		cmp	ch,80
		jne	Int25ah0FindVacantCylinderOK
			dec	ch
			inc	dh
		Int25ah0FindVacantCylinderOK:
		cmp	dh, 2
		jne	Int25ah0FindVacantHeadOK
			dec	dh
			jmp	Int25ah0DiskFull
		Int25ah0FindVacantHeadOK:
		
	jmp	Int25ah0FindVacantLoop
	
	Int25ah0FindVacantLoopEnd:
	
	
	
	
	;xchg	al, ah
	mov	[es:si], ax
	
	
	mov	al, [es:0008h]
	;sub	al, 2		; Number of sectors to write
	mov	ah, 3h		; BIOS drive write function
	mov	ch, 0		; Write to cylinder 0
	mov	cl, 2		; Write to sector 2
	mov	dh, 0		; Write to head 0
	mov	dl, 0		; Write to floppy drive
	mov	bx, 0x0800	;
	mov	es, bx		; Write from segment 0x0800
	mov	bx, 0x0000	; And offset 0x0000
	
	int	0x13
	jc Int25ah0LoadError
	
	
	mov	ax, 0000h
	jmp	Int25ahEnd
	
	Int25ah0LoadError:
		mov	ah, 01h
		mov	al, 01h
		jmp	Int25ahEnd		
	Int25ah0DiskFull:
		mov	ah, 01h
		mov	al, 02h
		jmp	Int25ahEnd
	Int25ah0FileExists:
		mov	ah, 01h
		mov	al, 04h
		jmp	Int25ahEnd
	

Int25ah1:
cmp	ah, 1
jne	Int25ah2
	;Delete 
	;[es:bx] - points to null terminated file name (Whole filename required, including all keywords!)
	;ah=01 on error, al=Error code
	
	;Error Codes
	;01h:	Drive not ready
	;03h:	File does not exist
	;07h:	File is write-protected
	
	push	bx
	push	es
	

	call Int25FileTable
	
	
	xor	cx, cx
	pop	es
	pop	bx
	Int25ah1FileFindLoop:
		mov	dl, [es:bx]
		mov	si, cx
		push	es
		mov	ax, 0800h
		mov	es, ax
		cmp	[es:si], dl
		pop	es
		jne	Int25ah1FileFindLoopContinue
			push	cx
			push	bx
			Int25ah1FileFindSubLoop:
				dec	cx
				mov	si, cx
				push	es
				mov	ax, 0800h
				mov	es, ax
				cmp	[es:si], byte 0
				pop	es
				pushf
				inc	cx
				popf
				jne	Int25ah1FileFindSuperRet
				Int25ah1FileFindSubLoopContinue:
					inc	cx
					inc	bx
					mov	dl, [es:bx]
					mov	si, cx
					push	es
					mov	ax, 0800h
					mov	es, ax
					cmp	cx, 07000h
					je	Int25ah1NoFile
					cmp	[es:si], dl
					pop	es
			je	Int25ah1FileFindSubLoopNullCheck
			Int25ah1FileFindSuperRet:
			pop	bx
			pop	cx
			jmp	Int25ah1FileFindLoopContinue
			Int25ah1FileFindSubLoopNullCheck:
			push	es
			mov	ax, 0800h
			mov	es, ax
			cmp	[es:si], byte 0
			pop	es
			jne	Int25ah1FileFindSubLoopContinue
			pop	bx
			pop	cx
			jmp	Int25ah1FileFindLoopEnd
		Int25ah1FileFindLoopContinue:
		cmp	cx, 07000h
		je	Int25ah1NoFile
		inc	cx
		jmp	Int25ah1FileFindLoop
	Int25ah1FileFindLoopEnd:
	
	mov	dx, 0800h
	mov	es, dx
	mov	bx, cx
	inc	si
	mov	dh, [es:si]
	and	dh, 0000_0100b
	cmp	dh, 0000_0100b
	jne	Int25ah1NoWrite
	inc	si
	Int25ah1FindNextLoop:
		cmp	[es:si], word 0
		je	Int25ah1FindNextLoopEnd
		
		cmp	si, 7000h
		pushf
		add	si, 2
		popf
		je	Int25ah1NoFile
	
	Int25ah1FindNextLoopEnd:
	
	add	si, 2
	
	Int25ah1DefragFiletableLoop:
		mov	dx, [es:si]
		mov	[es:bx], dx
		cmp	si, 07000h
		pushf
		inc	si
		inc	bx
		popf
	jne	Int25ah1DefragFiletableLoop
	
	
	mov	al, [es:0008h]
	;sub	al, 2		; Number of sectors to write
	mov	ah, 3h		; BIOS drive write function
	mov	ch, 0		; Write to cylinder 0
	mov	cl, 2		; Write to sector 2
	mov	dh, 0		; Write to head 0
	mov	dl, 0		; Write to floppy drive
	mov	bx, 0x0800	;
	mov	es, bx		; Write from segment 0x0800
	mov	bx, 0x0000	; And offset 0x0000
	
	int	0x13
	jc Int25ah1LoadError
	
	
	jmp Int25ahEnd
	
	Int25ah1LoadError:
		mov	ah, 01h
		mov	al, 01h
		jmp	Int25ahEnd
	Int25ah1NoFile:
		mov	ah, 01h
		mov	al, 03h
		jmp	Int25ahEnd
	Int25ah1NoWrite:
		mov	ah, 01h
		mov	al, 07h
		jmp	Int25ahEnd

Int25ah2:
cmp	ah, 2
jne	Int25ah3
	;Exists File/Get File's Attributes
	;[es:bx] points to null terminated file name
	;Sets ah=00 if File Exists, al=Attribute
	;Sets ah=01 on error, al=Error Code
	
	;Error Codes
	;01h:	Drive not ready
	;03h:	File does not exist
	
	push	bx
	push	es
		
	call Int25FileTable
	
	
	
	mov	cx, 0
	pop	es
	pop	bx
	Int25ah2FileFindLoop:
		mov	dl, [es:bx]
		mov	si, cx
		push	es
		mov	ax, 0800h
		mov	es, ax
		cmp	[es:si], dl
		pop	es
		jne	Int25ah2FileFindLoopContinue
			push	cx
			push	bx
			Int25ah2FileFindSubLoop:
				dec	cx
				mov	si, cx
				push	es
				mov	ax, 0800h
				mov	es, ax
				cmp	[es:si], byte 0
				pop	es
				pushf
				inc	cx
				popf
				jne	Int25ah2FileFindSuperRet
				Int25ah2FileFindSubLoopContinue:
					inc	cx
					inc	bx
					mov	dl, [es:bx]
					mov	si, cx
					push	es
					mov	ax, 0800h
					mov	es, ax
					cmp	cx, 07000h
					je	Int25ah2NoFile
					cmp	[es:si], dl
					pop	es
			je	Int25ah2FileFindSubLoopNullCheck
			Int25ah2FileFindSuperRet:
			pop	bx
			pop	cx
			jmp	Int25ah2FileFindLoopContinue
			Int25ah2FileFindSubLoopNullCheck:
			push	es
			mov	ax, 0800h
			mov	es, ax
			cmp	[es:si], byte 0
			pop	es
			jne	Int25ah2FileFindSubLoopContinue
			pop	bx
			pop	cx
			jmp	Int25ah2FileFindLoopEnd
		Int25ah2FileFindLoopContinue:
		cmp	cx, 07000h
		je	Int25ah2NoFile
		inc	cx
		jmp	Int25ah2FileFindLoop
	Int25ah2FileFindLoopEnd:
	
	mov	ax, 0800h
	mov	es, ax
	
	inc	si
	
	mov	al, [es:si]
	
	mov	ah, 0
	jmp	Int25ahEnd

	
	Int25ah2LoadError:
		mov	ah, 1
		mov	al, 1
		pop	es
		pop	bx
		jmp	Int25ahEnd
	Int25ah2NoFile:
		mov	ah, 1
		mov	al, 3
		jmp	Int25ahEnd
		

Int25ah3:
cmp	ah, 3
jne 	Int25ah4
	;Execute file
	;Searches for the specified null-terminated filename in the file table
	;and if executable attribute is set, load and call it.
	;[es:bx] points to filename, [dx:si] can pass a null terminated parameter string to program
	;
	;ah=01 on error, al=Error code
	;Error Codes:
	;01h:	Drive not ready
	;03h:	File does not exist
	;05h:	File not executable
	
	push	si
	push	dx
	push	bx
	push	es
		
	call Int25FileTable
	
	
	mov	cx, 0
	pop	es
	pop	bx
	Int25ah3FileFindLoop:
		;mov	bx, Kernel
		mov	dl, [es:bx]
		mov	si, cx
		push	es
		mov	ax, 0800h
		mov	es, ax
		cmp	[es:si], dl
		pop	es
		jne	Int25ah3FileFindLoopContinue
			push	cx
			push	bx
			Int25ah3FileFindSubLoop:
				dec	cx
				mov	si, cx
				push	es
				mov	ax, 0800h
				mov	es, ax
				cmp	[es:si], byte 0
				pop	es
				pushf
				inc	cx
				popf
				jne	Int25ah3FileFindSuperRet
				Int25ah3FileFindSubLoopContinue:
					inc	cx
					inc	bx
					mov	dl, [es:bx]
					mov	si, cx
					push	es
					mov	ax, 0800h
					mov	es, ax
					cmp	cx, 07000h
					je	Int25ah3NoFile
					cmp	[es:si], dl
					pop	es
			je	Int25ah3FileFindSubLoopNullCheck	
			Int25ah3FileFindSuperRet:
			pop	bx
			pop	cx
			jmp	Int25ah3FileFindLoopContinue
			Int25ah3FileFindSubLoopNullCheck:
			push	es
			mov	ax, 0800h
			mov	es, ax
			cmp	[es:si], byte 0
			pop	es
			jne	Int25ah3FileFindSubLoopContinue
			pop	bx
			pop	cx
			jmp	Int25ah3FileFindLoopEnd
		Int25ah3FileFindLoopContinue:
		cmp	cx, 07000h
		je	Int25ah3NoFile
		inc	cx
		jmp	Int25ah3FileFindLoop
	Int25ah3FileFindLoopEnd:
	
	mov	ax, 0800h
	mov	es, ax
	
	inc	si
	
	mov	ch, [es:si]
	and	ch, 0000_0001b
	cmp	ch, 0000_0001b
	jne	Int25ah3NoExec
	
	inc	si
	mov	ch, [es:si]
	mov	dh, ch
	and	ch, 0111_1111b
	
	and	dh, 1000_0000b
	shr	dh, 7
	
	inc	si
	mov	cl, [es:si]
	dec	si
	
	xor	bx, bx
	
	Int25ah3CopyLoop:
		push	es
		push	bx
		mov	ax, 0201h
		mov	dl, 0		; Read from floppy drive
		mov	bx, 1200h	;
		mov	es, bx		; Read to segment 0x1200
		pop	bx
		
		int	13h
		pop	es
		jc	Int25ah3LoadError
		
		add	bx, 0200h
		add	si, 2
		
		mov	ch, [es:si]
		mov	dh, ch
		and	ch, 0111_1111b
		
		and	dh, 1000_0000b
		shr	dh, 7
		
		inc	si
		mov	cl, [es:si]
		dec	si
		cmp	[es:si], word 0000h
		;inc	si
	jne	Int25ah3CopyLoop
	
	;mov	[es:si], word 0000h
	
	
	pop	dx
	mov	es, dx
	pop	si
	; Call the program
	call	1200h:0000h
	
	mov	ax, 0
	jmp	Int25ahEnd
	
	Int25ah3LoadError:
		mov	ah, 01h
		mov	al, 01h
		pop	es
		pop	bx
		pop	dx
		pop	si
		jmp	Int25ahEnd
	Int25ah3NoFile:
		mov	ah, 01h
		mov	al, 03h
		pop	dx
		pop	si
		jmp	Int25ahEnd
	Int25ah3NoExec:
		mov	ah, 01h
		mov	al, 05h
		pop	dx
		pop	si
		jmp	Int25ahEnd


Int25ah4:
cmp	ah, 4
jne	Int25ah5
	;Change Attributes
	;al - attribute
	;[es:bx] - points to null terminated file name (Whole filename required, including all keywords!)
	;ah=01 on error, al=Error code
	
	;Error Codes
	;01h:	Drive not ready
	;03h:	File does not exist
	
	push	ax
	push	bx
	push	es
	

	call Int25FileTable
	
	
	xor	cx, cx
	pop	es
	pop	bx
	Int25ah4FileFindLoop:
		mov	dl, [es:bx]
		mov	si, cx
		push	es
		mov	ax, 0800h
		mov	es, ax
		cmp	[es:si], dl
		pop	es
		jne	Int25ah4FileFindLoopContinue
			push	cx
			push	bx
			Int25ah4FileFindSubLoop:
				dec	cx
				mov	si, cx
				push	es
				mov	ax, 0800h
				mov	es, ax
				cmp	[es:si], byte 0
				pop	es
				pushf
				inc	cx
				popf
				jne	Int25ah4FileFindSuperRet
				Int25ah4FileFindSubLoopContinue:
					inc	cx
					inc	bx
					mov	dl, [es:bx]
					mov	si, cx
					push	es
					mov	ax, 0800h
					mov	es, ax
					cmp	cx, 07000h
					je	Int25ah4NoFile
					cmp	[es:si], dl
					pop	es
			je	Int25ah4FileFindSubLoopNullCheck
			Int25ah4FileFindSuperRet:
			pop	bx
			pop	cx
			jmp	Int25ah4FileFindLoopContinue
			Int25ah4FileFindSubLoopNullCheck:
			push	es
			mov	ax, 0800h
			mov	es, ax
			cmp	[es:si], byte 0
			pop	es
			jne	Int25ah4FileFindSubLoopContinue
			pop	bx
			pop	cx
			jmp	Int25ah4FileFindLoopEnd
		Int25ah4FileFindLoopContinue:
		cmp	cx, 07000h
		je	Int25ah4NoFile
		inc	cx
		jmp	Int25ah4FileFindLoop
	Int25ah4FileFindLoopEnd:
	
	mov	dx, 0800h
	mov	es, dx
	mov	bx, cx
	inc	si
	pop	ax
	mov	[es:si], al
	
	mov	al, [es:0008h]
	;sub	al, 2		; Number of sectors to write
	mov	ah, 3h		; BIOS drive write function
	mov	ch, 0		; Write to cylinder 0
	mov	cl, 2		; Write to sector 2
	mov	dh, 0		; Write to head 0
	mov	dl, 0		; Write to floppy drive
	mov	bx, 0x0800	;
	mov	es, bx		; Write from segment 0x0800
	mov	bx, 0x0000	; And offset 0x0000
	
	int	0x13
	jc Int25ah4LoadError
	
	jmp Int25ahEnd
	
	Int25ah4LoadError:
		mov	ah, 01h
		mov	al, 01h
		jmp	Int25ahEnd
	Int25ah4NoFile:
		mov	ah, 01h
		mov	al, 03h
		jmp	Int25ahEnd
		
Int25ah5:
cmp	ah, 5
jne	Int25ah6	
	;Rename File
	;[es:bx] - points to null terminated file name (old name)
	;[dx:di] - points to null terminated file name (new name)
	;ah=01 on error, al=Error code
	
	;Error Codes
	;01h:	Drive not ready
	;03h:	File does not exist
	;04h:	New file already exsts
	
	push	di
	push	dx
	push	bx
	push	es
	

	call Int25FileTable
	
	
	xor	cx, cx
	pop	es
	pop	bx
	Int25ah5FileFindLoop:
		mov	dl, [es:bx]
		mov	si, cx
		push	es
		mov	ax, 0800h
		mov	es, ax
		cmp	[es:si], dl
		pop	es
		jne	Int25ah5FileFindLoopContinue
			push	cx
			push	bx
			Int25ah5FileFindSubLoop:
				dec	cx
				mov	si, cx
				push	es
				mov	ax, 0800h
				mov	es, ax
				cmp	[es:si], byte 0
				pop	es
				pushf
				inc	cx
				popf
				jne	Int25ah5FileFindSuperRet
				Int25ah5FileFindSubLoopContinue:
					inc	cx
					inc	bx
					mov	dl, [es:bx]
					mov	si, cx
					push	es
					mov	ax, 0800h
					mov	es, ax
					cmp	cx, 07000h
					je	Int25ah1NoFile
					cmp	[es:si], dl
					pop	es
			je	Int25ah5FileFindSubLoopNullCheck
			Int25ah5FileFindSuperRet:
			pop	bx
			pop	cx
			jmp	Int25ah5FileFindLoopContinue
			Int25ah5FileFindSubLoopNullCheck:
			push	es
			mov	ax, 0800h
			mov	es, ax
			cmp	[es:si], byte 0
			pop	es
			jne	Int25ah5FileFindSubLoopContinue
			pop	bx
			pop	cx
			jmp	Int25ah5FileFindLoopEnd
		Int25ah5FileFindLoopContinue:
		cmp	cx, 07000h
		je	Int25ah5NoFile
		inc	cx
		jmp	Int25ah5FileFindLoop
	Int25ah5FileFindLoopEnd:
	
	mov	dx, 0800h
	mov	es, dx
	mov	bx, cx
	inc	si
	mov	dh, [es:si]
	and	dh, 0000_0100b
	cmp	dh, 0000_0100b
	;jne	Int25ah5NoWrite
	inc	si
	Int25ah5FindNextLoop:
		cmp	[es:si], word 0
		je	Int25ah5FindNextLoopEnd
		
		cmp	si, 7000h
		pushf
		add	si, 2
		popf
		je	Int25ah5NoFile
	
	Int25ah5FindNextLoopEnd:
	
	add	si, 2
	
	Int25ah5DefragFiletableLoop:
		mov	dx, [es:si]
		mov	[es:bx], dx
		cmp	si, 07000h
		pushf
		inc	si
		inc	bx
		popf
	jne	Int25ah5DefragFiletableLoop
	
	jmp Int25ahEnd
	
	Int25ah5LoadError:
		mov	ah, 01h
		mov	al, 01h
		jmp	Int25ahEnd
	Int25ah5NoFile:
		mov	ah, 01h
		mov	al, 03h
		jmp	Int25ahEnd
	Int25ah5NewExists:
		mov	ah, 01h
		mov	al, 04h
		jmp	Int25ahEnd

Int25ah6:
cmp	ah, 6
jne	Int25ah7
	;Read File
	;[es:bx] - points to null terminated file name (old name)
	;[ds:di] - points to recieving buffer
	;ah=01 on error, al=Error code
	
	;Error Codes
	;01h:	Drive not ready
	;03h:	File does not exist
	;06h:	File not readable
	push	di
	push	ds
	push	bx
	push	es
	
	call Int25FileTable
	
	xor	cx, cx
	pop	es
	pop	bx
	Int25ah6FileFindLoop:
		;mov	bx, Kernel
		mov	dl, [es:bx]
		mov	si, cx
		push	es
		mov	ax, 0800h
		mov	es, ax
		cmp	[es:si], dl
		pop	es
		jne	Int25ah6FileFindLoopContinue
			push	cx
			push	bx
			Int25ah6FileFindSubLoop:
				dec	cx
				mov	si, cx
				push	es
				mov	ax, 0800h
				mov	es, ax
				cmp	[es:si], byte 0
				pop	es
				pushf
				inc	cx
				popf
				jne	Int25ah6FileFindSuperRet
				Int25ah6FileFindSubLoopContinue:
					inc	cx
					inc	bx
					mov	dl, [es:bx]
					mov	si, cx
					push	es
					mov	ax, 0800h
					mov	es, ax
					cmp	cx, 07000h
					je	Int25ah6PreNoFile
					cmp	[es:si], dl
					pop	es
			je	Int25ah6FileFindSubLoopNullCheck	
			Int25ah6FileFindSuperRet:
			pop	bx
			pop	cx
			jmp	Int25ah6FileFindLoopContinue
			Int25ah6FileFindSubLoopNullCheck:
			push	es
			mov	ax, 0800h
			mov	es, ax
			cmp	[es:si], byte 0
			pop	es
			jne	Int25ah6FileFindSubLoopContinue
			pop	bx
			pop	cx
			jmp	Int25ah6FileFindLoopEnd
		Int25ah6FileFindLoopContinue:
		cmp	cx, 07000h
		je	Int25ah6PreNoFile
		inc	cx
		jmp	Int25ah6FileFindLoop
	Int25ah6FileFindLoopEnd:

	
	mov	ax, 0800h
	mov	es, ax
	
	inc	si
	
	mov	ch, [es:si]
	and	ch, 0000_0010b
	cmp	ch, 0000_0010b
	jne	Int25ah6PreNoRead
	
	inc	si
	mov	ch, [es:si]
	mov	dh, ch
	and	ch, 0111_1111b
	
	and	dh, 1000_0000b
	shr	dh, 7
	
	inc	si
	mov	cl, [es:si]
	dec	si
	
	pop	ds
	pop	di
	
	Int25ah6CopyLoop:
		push	es
		mov	ax, 0201h
		mov	dl, 0		; Read from floppy drive
		push	ds
		pop	es
		mov	bx, di
		
		int	13h
		pop	es
		jc	Int25ah6LoadError
		
		add	di, 0200h
		add	si, 2
		
		mov	ch, [es:si]
		mov	dh, ch
		and	ch, 0111_1111b
		
		and	dh, 1000_0000b
		shr	dh, 7
		
		inc	si
		mov	cl, [es:si]
		dec	si
		cmp	[es:si], word 0000h
		;inc	si
	jne	Int25ah6CopyLoop
	
	mov	ax, di
	div	word [BlockSize]
	xor	ah, ah
	jmp	Int25ahEnd
	
	Int25ah6PreNoFile:
		pop	ds
		pop	di
		jmp Int25ah6NoFile
	Int25ah6PreNoRead:
		pop	ds
		pop	di
		jmp Int25ah6NoRead
	Int25ah6LoadError:
		mov	ah, 01h
		mov	al, 01h
		jmp	Int25ahEnd
	Int25ah6NoFile:
		mov	ah, 01h
		mov	al, 03h
		jmp	Int25ahEnd
	Int25ah6NoRead:
		mov	ah, 01h
		mov	al, 06h
		jmp	Int25ahEnd
		
		
Int25ah7:
cmp	ah, 7
jne	Int25ahEnd
	;Write to file
	;al - Nuber of sectors to write
	;[es:bx] - points to null terminated file name (Whole filename required, including all keywords!)
	;[ds:di] - points to memmory buffer
	;ah=01 on error, al=Error code
	
	;Error Codes
	;01h:	Drive not ready
	;03h:	File does not exist
	;07h:	File is write-protected
	
	push	di
	push	dx
	push	ax
	push	bx
	push	es
	

	call Int25FileTable
	
	
	xor	cx, cx
	pop	es
	pop	bx
	Int25ah7FileFindLoop:
		mov	dl, [es:bx]
		mov	si, cx
		push	es
		mov	ax, 0800h
		mov	es, ax
		cmp	[es:si], dl
		pop	es
		jne	Int25ah7FileFindLoopContinue
			push	cx
			push	bx
			Int25ah7FileFindSubLoop:
				dec	cx
				mov	si, cx
				push	es
				mov	ax, 0800h
				mov	es, ax
				cmp	[es:si], byte 0
				pop	es
				pushf
				inc	cx
				popf
				jne	Int25ah7FileFindSuperRet
				Int25ah7FileFindSubLoopContinue:
					inc	cx
					inc	bx
					mov	dl, [es:bx]
					mov	si, cx
					push	es
					mov	ax, 0800h
					mov	es, ax
					cmp	cx, 07000h
					je	Int25ah7NoFile
					cmp	[es:si], dl
					pop	es
			je	Int25ah7FileFindSubLoopNullCheck
			Int25ah7FileFindSuperRet:
			pop	bx
			pop	cx
			jmp	Int25ah7FileFindLoopContinue
			Int25ah7FileFindSubLoopNullCheck:
			push	es
			mov	ax, 0800h
			mov	es, ax
			cmp	[es:si], byte 0
			pop	es
			jne	Int25ah7FileFindSubLoopContinue
			pop	bx
			pop	cx
			jmp	Int25ah7FileFindLoopEnd
		Int25ah7FileFindLoopContinue:
		cmp	cx, 07000h
		je	Int25ah7NoFile
		inc	cx
		jmp	Int25ah7FileFindLoop
	Int25ah7FileFindLoopEnd:
	
	mov	dx, 0800h
	mov	es, dx
	;mov	bx, cx
	inc	si
	mov	dh, [es:si]
	and	dh, 0000_0100b
	cmp	dh, 0000_0100b
	jne	Int25ah7NoWrite
	inc	si
	mov	bx, si
	
	
	
	
	Int25ah7FindNextLoop:
		cmp	[es:si], word 0
		je	Int25ah7FindNextLoopEnd
		
		cmp	si, 7000h
		pushf
		add	si, 2
		popf
		je	Int25ah7NoFile
	
	Int25ah7FindNextLoopEnd:
	
	mov	dx, si
	sub	dx, bx
	pop	ax
	mul	byte [Two]
	
	cmp	ax, dx
	jg	Int25ah7ExpandFileTable
	je	Int25ah7WriteFileClusters
	
	xor	ah, ah
	add	bx, ax
	
	Int25ah7DefragFiletableLoop:
		mov	dx, [es:si]
		mov	[es:bx], dx
		cmp	si, 07000h
		pushf
		inc	si
		inc	bx
		popf
	jne	Int25ah7DefragFiletableLoop
	jmp	Int25ah7WriteTable
	
	Int25ah7ExpandFileTable:
	
	
	
	Int25ah7WriteTable:
	mov	al, [es:0008h]
	;sub	al, 2		; Number of sectors to write
	mov	ah, 3h		; BIOS drive write function
	mov	ch, 0		; Write to cylinder 0
	mov	cl, 2		; Write to sector 2
	mov	dh, 0		; Write to head 0
	mov	dl, 0		; Write to floppy drive
	mov	bx, 0x0800	;
	mov	es, bx		; Write from segment 0x0800
	mov	bx, 0x0000	; And offset 0x0000
	
	int	0x13
	jc Int25ah7LoadError
	
	Int25ah7WriteFileClusters:
	
	
	jmp Int25ahEnd
	
	Int25ah7LoadError:
		mov	ah, 01h
		mov	al, 01h
		jmp	Int25ahEnd
	Int25ah7NoFile:
		mov	ah, 01h
		mov	al, 03h
		jmp	Int25ahEnd
	Int25ah7NoWrite:
		mov	ah, 01h
		mov	al, 07h
		jmp	Int25ahEnd

Int25ahEnd:

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
;End Interrupt 25

Int25FileTable:
	mov	ah, 0x02	; BIOS drive load function
	mov	al, 1		; Number of sectors to read
	mov	ch, 0		; Read from cylinder 0
	mov	cl, 2		; Read from sector 2
	mov	dh, 0		; Read from head 0
	mov	dl, 0		; Read from floppy drive
	mov	bx, 0x0800	;
	mov	es, bx		; Read to segment 0x0800
	mov	bx, 0x0000	; And offset 0x0000

	; Load First sector of file table to determine its size
	int	0x13
	jc Int25LoadError
	
	mov	ax, 0800h
	mov	es, ax
	mov	al, [es:0008h]
	sub	al, 2		; Number of sectors to read
	mov	ah, 0x02	; BIOS drive load function
	mov	ch, 0		; Read from cylinder 0
	mov	cl, 2		; Read from sector 2
	mov	dh, 0		; Read from head 0
	mov	dl, 0		; Read from floppy drive
	mov	bx, 0x0800	;
	mov	es, bx		; Read to segment 0x0800
	mov	bx, 0x0000	; And offset 0x0000
	
	int	0x13
	jc Int25LoadError
	ret
Int25LoadError:
	mov	ah, 01h
	mov	al, 01h
	jmp	Int25ahEnd

BlockSize dw 512d
Two	db 2d