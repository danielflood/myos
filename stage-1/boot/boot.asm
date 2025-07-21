; boot.asm
org 0x7C00                ; BIOS loads us here

start:
    mov si, msg

.print_char:
    lodsb                 ; Load next byte from [SI] into AL
    or al, al             ; Check for null terminator
    jz .hang
    mov ah, 0x0E          ; Teletype BIOS function
    int 0x10              ; Call BIOS to print AL
    jmp .print_char

.hang:
    cli
    hlt
    jmp .hang

msg db 'Hello, world!', 0

times 510 - ($ - $$) db 0 ; Pad the rest with 0s
dw 0xAA55                 ; Boot signature
