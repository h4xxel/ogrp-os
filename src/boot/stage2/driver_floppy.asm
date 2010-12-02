[bits 32]

floppy_irq_wait:
	pushf
	sti
	.l1:
		hlt
		cmp	[floppy_ready], byte 0
	je	.l1
	mov	[floppy_ready], byte 0
	popf
ret

floppy_driver_init:
	mov	eax, 26h
	mov	ebx, floppy_irq_handler
	call	RegisterISR
	; Unmask IRQ
	in	al, 021h
	and	al, 10111111b
	out	021h, al
ret

floppy_irq_handler:
	pusha
	
	mov	[floppy_ready], byte 1h
	mov	al, 20h
	out	20h, al
	popa
iret
floppy_ready db 0

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
	pusha
	push	ax
	mov	ecx, 300d
	.test_rqm:
		mov	eax, 0Ah
		call	sleep
		mov	dx, floppy_reg_base+floppy_reg_MSR
		in	al, dx	; Read MSR
		and	al, 80h
		cmp	al, 80h	; Check RQM
		je	.end
	loop	.test_rqm
	
	mov	ebx, floppy_cmd_error
	pop	ax
	call	panic
	
	.end:
	pop	ax
	mov	al, ah
	mov	dx, floppy_reg_base+floppy_reg_FIFO
	out	dx, al	;Write FIFO
	popa
ret

floppy_read_command:
; Returns AL=return data
	mov	ecx, 300d
	.test_rqm:
		mov	eax, 0Ah
		call	sleep
		mov	dx, floppy_reg_base+floppy_reg_MSR
		in	al, dx	; Read MSR
		and	al, 80h
		cmp	al, 80h	; Check RQM
		je	.end
	loop	.test_rqm
	
	mov	ebx, floppy_cmd_error
	call	panic
	
	.end:
	mov	dx, floppy_reg_base+floppy_reg_FIFO
	in	al, dx	;Read FIFO
ret

floppy_cmd_error	db 'error in floppy subsystem', 13d, 10d, 0

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
	.calibrate_loop:
		mov	ah, floppy_cmd_recalibrate
		call	floppy_issue_command
		mov	ah, 0	;Drive number, fix later
		call	floppy_issue_command
		
		call	floppy_irq_wait
		call	floppy_check_interrupt
		
		cmp	[floppy_cyl], byte 0
		je	.end
	loop	.calibrate_loop
	mov	ah, 04h
	mov	ebx, MSGFail
	call	print
	mov	ah, 07h
	mov	ebx, MSGEnd
	call	print
.end:
call	floppy_motor_off
ret

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

floppy_seek:
	; CH=Cylinder
	; CL=Sector
	; DH=Head
	; DL=Drive
	pusha
	call	floppy_motor_on
	
	mov	ah, floppy_cmd_seek
	call	floppy_issue_command
	
	mov	ah, dh
	shl	ah, 2
	call	floppy_issue_command
	
	mov	ah, ch
	call	floppy_issue_command
	
	call	floppy_irq_wait
	call	floppy_check_interrupt
	
	call	floppy_motor_off
.end:
popa
ret

floppy_dma_init_read:
	mov	al, 6h
	out	0ah, al	;mask chanel 2
	mov	al, 0ffh
	out	0ch, al	;reset dma flip-flop
	mov	al, [floppy_dma_mem]
	out	4h, al	;write low address byte
	mov	al, [floppy_dma_mem+1]
	out	4h, al	;write high address byte
	mov	al, [floppy_dma_mem+2]
	out	81h, al	;write external page register
	
	mov	al, 0ffh
	out	0ch, al	;reset dma flip-flop
	mov	al, [floppy_dma_size]
	out	5h, al	;write low size byte
	mov	al, [floppy_dma_size+1]
	out	5h, al	;write high size byte
	
	mov	al, floppy_dir_read
	out	0bh, al	;read
	mov	al, 2h
	out	0ah, al	;unmask chanel 2
ret

floppy_track_read:
	; CH: cylinder
	push	cx
	mov	dh, 0
	call	floppy_seek
	mov	dh, 1
	call	floppy_seek
	
	call	floppy_motor_on
	call	floppy_dma_init_read
	
	mov	eax, 0Ah
	call	sleep
	
	mov	ah, floppy_cmd_read_data
	or	ah, 0C0h	;flags for multitrack and MFM
	call	floppy_issue_command
	
	mov	ah, 0	;head 0, drive 0
	call	floppy_issue_command
	pop	cx
	mov	ah, ch	;cylinder
	call	floppy_issue_command
	mov	ah, 0	;head 0
	call	floppy_issue_command
	mov	ah, 1	;sector 1
	call	floppy_issue_command
	mov	ah, 2	;Bytes per sector *128
	call	floppy_issue_command
	mov	ah, 18	;Number of tracks
	call	floppy_issue_command
	mov	ah, 1bh	;hard coded GAP3 length
	call	floppy_issue_command
	mov	ah, 0FFh	;data length (0xff if B/S != 0)
	call	floppy_issue_command
	
	call	floppy_irq_wait
	
	;Read status
	call	floppy_read_command
	call	floppy_read_command
	call	floppy_read_command
	
	;more status
	call	floppy_read_command
	call	floppy_read_command
	call	floppy_read_command
	call	floppy_read_command
	
	call	floppy_motor_off
	
ret

floppy_detect_drive:
	xor	eax, eax
	mov	al, 10h
	out	70h, al
	call	io_wait
	in	al, 71h
	mov	ah, 14d
	push	ax
	shr	al, 4
	mul	ah
	push	eax
	mov	ah, 03h
	mov	ebx, floppy_msg_primary_drive
	call	print
	mov	ebx, floppy_drive_types
	pop	eax
	add	ebx, eax
	mov	ah, 03h
	call	print
	pop	ax
	and	al, 0Fh
	mul	ah
	push	eax
	mov	ah, 03h
	mov	ebx, floppy_msg_secondary_drive
	call	print
	mov	ebx, floppy_drive_types
	pop	eax
	add	ebx, eax
	mov	ah, 03h
	call	print
ret

floppy_msg_primary_drive	db	"    Primary drive:   ", 0
floppy_msg_secondary_drive	db	"    Secondary drive: ", 0

floppy_drive_types:
	db	'NONE', 13d, 10d, 0,0,0,0,0,0,0, 0h
	db	'5.25" 360kB', 13d, 10d, 0h
	db	'5.25" 1.2MB', 13d, 10d, 0h
	db	'3.5" 720kB', 13d, 10d, 0, 0h
	db	'3.5" 1.44MB', 13d, 10d, 0h
	db	'3.5" 2.88MB', 13d, 10d, 0h
	db	'UNKNOWN', 13d, 10d, 0,0,0,0, 0h
	db	'UNKNOWN', 13d, 10d, 0,0,0,0, 0h

floppy_reg_base	equ	03f0h

floppy_dma_mem	dd 14000h
floppy_dma_size	dw 4800h-1

floppy_dir_read		equ 46h
floppy_dir_write		equ 4ah

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
