[bits 32]

floppy_irq_wait:
	pushf
	sti
	floppy_irq_wait_loop:
		hlt
		cmp	[DriveReady], byte 0
	je	floppy_irq_wait_loop
	popf
ret

floppy_driver_init:
	mov	eax, 26h
	mov	ebx, IRQ6Handler
	call	RegisterISR
	; Unmask IRQ
	in	al, 021h
	and	al, 10111111b
	out	021h, al
ret

IRQ6Handler:
	pusha
	mov	[DriveReady], byte 1h
	mov	al, 20h
	out	20h, al
	popa
iret
DriveReady	db 0

floppy_check_interrupt:
	mov	ah, floppy_cmd_sense_interrupt
	call	floppy_issue_command
	call	floppy_read_command
	mov	[floppy_st0], al
	call	floppy_read_command
	mov	[floppy_cyl], al
ret
floppy_st0	db 0
floppy_cyl	db 0

floppy_issue_command:
; AH=Command
	push	ax
	mov	ecx, 300d
	floppy_issue_command_test_RQM:
		mov	eax, 0Ah
		call	sleep
		mov	dx, floppy_reg_base+floppy_reg_MSR
		in	al, dx	; Read MSR
		and	al, 80h
		cmp	al, 80h	; Check RQM
		je	floppy_issue_command_quit
	loop	floppy_issue_command_test_RQM
	
	mov	ebx, ERRFloppy_cmd
	pop	ax
	call	panic
	
	floppy_issue_command_quit:
	pop	ax
	mov	al, ah
	mov	dx, floppy_reg_base+floppy_reg_FIFO
	out	dx, al	;Write FIFO
ret

floppy_read_command:
; Returns AL=return data
	mov	ecx, 300d
	floppy_read_command_test_RQM:
		mov	eax, 0Ah
		call	sleep
		mov	dx, floppy_reg_base+floppy_reg_MSR
		in	al, dx	; Read MSR
		and	al, 80h
		cmp	al, 80h	; Check RQM
		je	floppy_read_command_quit
	loop	floppy_read_command_test_RQM
	
	mov	ebx, ERRFloppy_cmd
	call	panic
	
	floppy_read_command_quit:
	mov	dx, floppy_reg_base+floppy_reg_FIFO
	in	al, dx	;Read FIFO
ret

ERRFloppy_cmd	db 'error in floppy subsystem'

floppy_controller_reset:
	xor	al, al
	mov	dx, floppy_reg_base+floppy_reg_DOR
	out	dx, al
	call	io_wait
	mov	al, 00001100b
	out	dx, al
	call	io_wait
	call	floppy_irq_wait
	call	floppy_check_interrupt
	mov	dx, floppy_reg_base+floppy_reg_CCR
	mov	al, 0	; Disk transfer speed. fix later
	
	mov	ah, floppy_cmd_specify
	call	floppy_issue_command
	mov	ah, 0DFh	;steprate 3ms, unload time 240ms
	call	floppy_issue_command
	mov	ah, 02h		;load tame 16ms. no-DMA 0
	call	floppy_issue_command
	
	call	floppy_calibrate
ret

floppy_calibrate:
	call	floppy_motor_on
	mov	ecx, 0Ah
	floppy_calibrate_loop:
		mov	ah, floppy_cmd_recalibrate
		call	floppy_issue_command
		mov	ah, 0	;Drive number, fix later
		call	floppy_issue_command
		
		call	floppy_irq_wait
		call	floppy_check_interrupt
		
		cmp	[floppy_cyl], byte 0
		je	floppy_calibrate_end
	loop	floppy_calibrate_loop
	xor	edx, edx
	mov	ah, 04h
	mov	ebx, floppy_CalibrateError
floppy_calibrate_end:
call	floppy_motor_off
ret

floppy_CalibrateError	db 'Floppy Calibration Error',0

floppy_motor_on:
	mov	dx, floppy_reg_base+floppy_reg_DOR
	mov	al, 1Ch
	out	dx, al
	mov	eax, 512d
	call	sleep
ret

floppy_motor_off:
	mov	dx, floppy_reg_base+floppy_reg_DOR
	mov	al, 0Ch
	out	dx, al
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
