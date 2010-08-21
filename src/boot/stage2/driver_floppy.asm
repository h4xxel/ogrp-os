[bits 32]

floppy_issue_command:
	in	al, 3F4h	; Read MSR
	or	al, 11000000b
	cmp	al, 10000000b	; Check RQM and DIO
	je	floppy_issue_command_quit
	mov	ah, al
	out	3F5h, al
	floppy_issue_command_test_RQM:
		in	al, 3F4h	; Read MSR
		or	al, 10000000b
		cmp	al, 10000000b	; Check RQM
	jne	floppy_issue_command_test_RQM
	
floppy_issue_command_quit:
ret

floppy_controller_reset:

ret
