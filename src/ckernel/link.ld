OUTPUT_FORMAT(binary)
ENTRY(kentry)

SECTIONS {
	.text : {
		code = .; _code = .; __code = .;
		*(.text)
	}

	.data : {
		data = .; _data = .; __data = .;
		*(.data)
		*(.rodata)
	}

	.bss : {
		bss = .; _bss = .; __bss = .;
		*(.bss)
	}
} 
