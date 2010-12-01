[org 0h]
[bits 32]

db "Hai thar from floppy!",0
times (512*2880)-(2048+512) - ($ - $$) db 0