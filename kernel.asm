; kernel.asm
MBALIGN     equ 1<<0
MEMINFO     equ 1<<1
FLAGS       equ MBALIGN | MEMINFO
MAGIC       equ 0x1BADB002
CHECKSUM    equ -(MAGIC + FLAGS)

section .multiboot
align 4
    dd MAGIC
    dd FLAGS
    dd CHECKSUM

section .bss
align 16
stack_bottom:
    resb 16384 ; 16 KB
stack_top:

section .text
global start
extern main

start:
    mov esp, stack_top   ; Set up stack
    call main
    cli
.hang: hlt
    jmp .hang
