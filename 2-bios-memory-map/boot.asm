;boot.asm
org 0x7C00

start:
    ;Clear Screen
    call clear_screen

    ;Setup the stack
    mov ax, 0x0000       ; Setup stack segment
    mov ss, ax           ; SS == Stack Segment register
    mov sp, 0x7C00       ; Stack pointer, grows downwards

    ;Setup the registers for storing the memory map in buffer
    mov ax, 0x07C0
    mov es, ax
    mov ax, 0x07C0
    mov ds, ax
    mov di, buffer
    mov si, buffer

.loop:
    ;Get the entry
    call get_memory_map_entry

    ;Print the entry
    call print_memory_map_entry

    ;Check if there is anymore data to receive
    ;cmp ebx, 0
    ;jnz .loop

.hang:
    cli
    hlt
    jmp .hang

get_memory_map_entry:
    ;Setup registers for calling the BIOS interrupt
    mov ebx, 0          ; Start from beginning
    mov ecx, 20         ; Size of the buffer (in bytes)
    mov eax, 0xE820     ; The standard we want to use
    mov edx, 0x534D4150 ; 'SMAP' magic, kinda like a password
    
    int 0x15            ; Call the interrupt
    
    ;Check that what got returned is valid.
    jc .error            ; carry set = error
    cmp eax, 'SMAP'
    jne .error           ; invalid response
    cmp ecx, 20
    jb .error            ; too short
    ret

.error:
    mov edx, 0
    ret

print_memory_map_entry:
    ;Setup VGA
    mov ax, 0xB800       ; VGA Memory first 16bits
    mov es, ax           ; Have to load into the Extra Segment register (ES) from a general purpose register e.g. AX 
    mov bx, 0x0000       ; Second 16 bits
    mov dh, 0x07         ; Light grey on black?
    
    push baseStr - 0x7C00
    call .print_string
    pop ax

    push si
    push 8
    call .print_memory_chunk
    pop ax
    pop ax

    push lengthStr - 0x7C00
    call .print_string
    pop ax

    add si, 8
    push si
    push 8
    call .print_memory_chunk
    pop ax
    pop ax

    push typeStr - 0x7C00
    call .print_string
    pop ax

    add si, 8
    push si
    push 4
    call .print_memory_chunk
    pop ax
    pop ax

    ret

.print_string: 
    push si
    push bp
    mov bp, sp

    mov si, [bp+6]

    .loop2:
        lodsb
        or al, al
        jz .end2
        mov dl, al
        call .print_char
        jmp .loop2
    
    .end2:
    pop bp
    pop si
    ret

.print_memory_chunk:
    push si
    push bp
    mov bp, sp

    mov cx, [bp + 6] ;arg2: Length of the chunk in bytes
    mov ax, [bp + 8] ;arg1: Address

    .loop1:
        mov si, ax
        add si, cx
        sub si, 1
        mov dl, [si]
        shr dl, 4
        call .print_hex
        mov dl, [si]
        and dl, 0x0F
        call .print_hex
        mov dl, 0x20
        call .print_char
        dec cx
        or cx, cx
        jnz .loop1
    
    pop bp
    pop si
    ret

.print_hex:
    cmp dl, 10
    jl .digit
    add dl, 55
    jmp .print
    .digit:
    add dl, 48
    .print:
    mov word [es:bx], dx
    add bx, 2 
    ret

.print_char:
    mov word [es:bx], dx
    add bx, 2 
    ret

clear_screen:
    mov ax, 0xB800       ; VGA Memory first 16bits
    mov es, ax           ; Have to load into the Extra Segment register (ES) from a general purpose register e.g. AX   
    mov bx, 0x0000       ; Second 16 bits
    mov ah, 0x07
    mov al, 0x20

.loop:
    cmp bx, 0xFA0
    jz .reset_screen
    mov word [es:bx], ax
    add bx, 2
    jmp .loop

.reset_screen:
    mov bx, 0x0000       ; Reset BX to point at the start of the VGA buffer
    mov cx, 0x0000       ; Counter that will be used for tracking the cursor
    call set_cursor      ; Calls the set_cursor subroutine to reset it to the start
    ret

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

buffer: times 20 db 0

baseStr db "Base: ", 0
lengthStr db "Length: ", 0
typeStr db "Type: ", 0

times 510 - ($ - $$) db 0 ; Pad the rest with 0s
dw 0xAA55                 ; Boot signature