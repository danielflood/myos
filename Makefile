ISO = iso
BUILD = build
KERNEL = kernel

all: $(BUILD)/kernel.bin

$(BUILD)/kernel.bin: kernel.asm kernel.c
	mkdir -p $(BUILD)
	nasm -f elf32 kernel.asm -o $(BUILD)/kernel_asm.o
	gcc -m32 -ffreestanding -fno-pic -fno-pie -c kernel.c -o $(BUILD)/kernel_c.o
	ld -m elf_i386 -T linker.ld $(BUILD)/kernel_asm.o $(BUILD)/kernel_c.o -o $(BUILD)/kernel.bin

iso: all
	cp $(BUILD)/kernel.bin iso/boot/kernel
	grub-mkrescue -o $(BUILD)/myos.iso iso

run: iso
	qemu-system-i386 -cdrom $(BUILD)/myos.iso

clean:
	rm -rf $(BUILD)
