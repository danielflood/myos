# My OS Kernel

A simple operating system kernel written in Assembly and C.

## Building

Requirements:
- NASM
- GCC
- Make
- GRUB
- QEMU

To build and run:
```make run```

## Structure

- `kernel.asm`: Assembly entry point and multiboot header
- `kernel.c`: C kernel code
- `Makefile`: Build configuration
- `linker.ld`: Linker script
