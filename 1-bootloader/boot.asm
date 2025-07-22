; boot.asm
org 0x7C00                ; BIOS loads us here

start:
    mov si, msg
    mov ax, 0xB800       ; VGA Memory first 16bits
    mov es, ax           ; Have to load into ES from a general purpose register e.g. AX   
    mov bx, 0x0000       ; Second 16 bits
    mov ah, 0x07         ; Light grey on black?
    mov al, 0x20         ; Blank space for clearing the screen

.clear_screen:
    cmp bx, 0xFA0
    jz .reset_screen
    mov word [es:bx], ax
    add bx, 2
    jmp .clear_screen

.reset_screen:
    mov bx, 0x0000       ; Reset BX to point at the start of the VGA buffer

.print_char:
    lodsb                 ; Load next byte from [SI] into AL
    or al, al             ; Check for null terminator
    jz .hang
    mov word [es:bx], ax
    add bx, 2
    jmp .print_char

.hang:
    cli
    hlt
    jmp .hang

msg db 'Hello, world!', 0

times 510 - ($ - $$) db 0 ; Pad the rest with 0s
dw 0xAA55                 ; Boot signature
