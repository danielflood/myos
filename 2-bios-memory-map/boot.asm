;boot.asm
org 0x7C00

start:
    ;Setup the stack
    mov ax, 0x0000       ; Setup stack segment
    mov ss, ax           ; SS == Stack Segment register
    mov sp, 0x7C00       ; Stack pointer, grows downwards

    ;Setup the registers for storing the memory map in buffer
    mov ax, 0x07C0
    mov es, ax
    mov ds, ax
    mov di, buffer
    mov si, buffer

.loop:
    ;Get the entry
    call get_memory_map_entry

    ;Print the entry
    call print_array

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

print_array:
    ;Setup VGA
    mov ax, 0xB800       ; VGA Memory first 16bits
    mov es, ax           ; Have to load into the Extra Segment register (ES) from a general purpose register e.g. AX   
    mov bx, 0x0000       ; Second 16 bits
    mov ah, 0x07         ; Light grey on black?
    mov cx, 20

.print_hex:
    lodsb                 ; Load next byte from [SI] into AL
    mov dl, al
    shr dl, 4
    cmp dl, 10
    jl .digit
    add dl, 55
    jmp .print
    .digit:
    add dl, 48
    .print:
    mov al, dl
    mov word [es:bx], ax
    add bx, 2
    mov dl, al
    and dl, 0x0F
    cmp dl, 10
    jl .digits
    add dl, 55
    jmp .prints
    .digits:
    add dl, 48
    .prints:
    mov al, dl
    mov word [es:bx], ax
    add bx, 2 
    dec cx
    or cx, cx
    jnz .print_hex
    ret


buffer: times 20 db 0

times 510 - ($ - $$) db 0 ; Pad the rest with 0s
dw 0xAA55                 ; Boot signature