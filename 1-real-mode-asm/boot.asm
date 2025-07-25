; boot.asm
org 0x7C00                ; BIOS loads us here

start:
    mov si, msg
    mov ax, 0x0000       ; Setup stack segment
    mov ss, ax           ; SS == Stack Segment register
    mov sp, 0x7C00       ; Stack pointer, grows downwards 
    mov ax, 0xB800       ; VGA Memory first 16bits
    mov es, ax           ; Have to load into the Extra Segment register (ES) from a general purpose register e.g. AX   
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
    mov cx, 0x0000       ; Counter that will be used for tracking the cursor
    call set_cursor      ; Calls the set_cursor subroutine to reset it to the start

.print_char:
    lodsb                 ; Load next byte from [SI] into AL
    or al, al             ; Check for null terminator
    jz .hang
    mov word [es:bx], ax
    add bx, 2
    inc cx
    call set_cursor
    jmp .print_char

.hang:
    cli
    hlt
    jmp .hang

; set_cursor - sets the hardware text cursor position
; Input:
;   CX = linear cursor index (0–1999)
; Clobbers:
;   AX, DX (preserved internally)
; Output:
;   Cursor updated
set_cursor:
    push ax
    push dx
    ; Set cursor position to the current index of the characters stored in CX
    ; Select low byte register
    mov dx, 0x3D4
    mov al, 0x0F
    out dx, al

    ; Write low byte
    inc dx          ; dx = 0x3D5
    mov al, cl
    out dx, al

    ; Select high byte register
    mov dx, 0x3D4
    mov al, 0x0E
    out dx, al

    ; Write high byte
    inc dx
    mov al, ch
    out dx, al
    pop dx
    pop ax
    ret

msg db 'Hello, world!', 0

times 510 - ($ - $$) db 0 ; Pad the rest with 0s
dw 0xAA55                 ; Boot signature
