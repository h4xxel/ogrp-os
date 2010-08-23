[bits 32]

driver_init:
	mov	eax, 26h
	mov	ebx, IRQ6Handler
	call	RegisterISR
	; Unmask IRQ
ret

IRQ6Handler:
	pusha
	mov	[DriveReady], byte 1h
	mov	al, 20h
	out	20h, al
	popa
iret
DriveReady	db 1

floppy_issue_command:
; AH=Command
	;in	al, floppy_reg_base+floppy_reg_MSR	; Read MSR
	;or	al, 11000000b
	;cmp	al, 10000000b	; Check RQM and DIO
	;je	floppy_issue_command_quit
	;mov	al, ah
	;out	floppy_reg_base+floppy_reg_FIFO, al	;Write FIFO
	floppy_issue_command_test_RQM:
		in	al, floppy_reg_base+floppy_reg_MSR	; Read MSR
		or	al, 10000000b
		cmp	al, 10000000b	; Check RQM
	jne	floppy_issue_command_test_RQM
	mov	al, ah
	out	floppy_reg_base+floppy_reg_FIFO, al	;Write FIFO
	ret
	
floppy_issue_command_quit:
mov	ah, 0h
ret

floppy_controller_reset:
	xor	al, al
	out	floppy_reg_base+floppy_reg_DOR, al
	call	io_wait
	mov	al, 00001100b
	out	floppy_reg_base+floppy_reg_DOR, al
	call	io_wait
ret

floppy_detect_drive:
	xor	eax, eax
	mov	al, 10h
	out	70h, al
	call	io_wait
	in	al, 71h
	mov	ah, 12d
	push	ax
	shr	al, 4
	mul	ah
	mov	bx, floppy_drive_types
	add	ebx, eax
	mov	edx, 800d
	mov	ah, 04h
	call	print32
	pop	ax
	and	al, 0Fh
	mul	ah
	mov	bx, floppy_drive_types
	add	ebx, eax
	mov	edx, 960d
	mov	ah, 04h
	call	print32
ret

floppy_drive_types:
	db	'NONE       ', 0h
	db	'5.25" 360kB', 0h
	db	'5.25" 1.2MB', 0h
	db	'3.5" 720kB ', 0h
	db	'3.5" 1.44MB', 0h
	db	'3.5" 2.88MB', 0h
	db	'UNKNOWN    ', 0h
	db	'UNKNOWN    ', 0h

floppy_reg_base	equ	03f0h

; Floppy Registers
	floppy_reg_SRA	equ 0h
	floppy_reg_SRB	equ 1h
	floppy_reg_DOR	equ 2h
	floppy_reg_TDR	equ 3h
	floppy_reg_MSR	equ 4h
	floppy_reg_DSR	equ 4h
	floppy_reg_FIFO equ 5h
	floppy_reg_DIR	equ 7h
	floppy_reg_CCR	equ 7h

; Floppy Commands
	floppy_cmd_read_track		equ 2d
	floppy_cmd_specify		equ 3d
	floppy_cmd_sense_drive_status	equ 4d
	floppy_cmd_write_data		equ 5d
	floppy_cmd_read_data		equ 6d
	floppy_cmd_recalibrate		equ 7d
	floppy_cmd_sense_interrupt	equ 8d
	floppy_cmd_write_deleted_data	equ 9d
	floppy_cmd_read_id		equ 10d
	floppy_cmd_read_deleted_data	equ 12d
	floppy_cmd_format_track		equ 13d
	floppy_cmd_seek			equ 15d
	floppy_cmd_version		equ 16d
	floppy_cmd_scan_equal		equ 17d
	floppy_cmd_perpendicular_mode	equ 18d
	floppy_cmd_configure		equ 19d
	floppy_cmd_lock			equ 20d
	floppy_cmd_verify		equ 22d
	floppy_cmd_scan_low_or_equal	equ 25d
	floppy_cmd_scan_high_or_equal	equ 29d
