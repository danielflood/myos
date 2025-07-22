ISO = iso
BUILD = build
KERNEL = kernel

C_SOURCES := $(wildcard $(KERNEL)/*.c)
OBJ_FILES := $(patsubst $(KERNEL)/%.c, $(BUILD)/%.o, $(C_SOURCES))

all: $(BUILD)/kernel.bin

# Compile each .c file into build/*.o
$(BUILD)/%.o: $(KERNEL)/%.c
	mkdir -p $(BUILD)
	gcc -Iinclude -m32 -ffreestanding -fno-pic -fno-pie -g -c $< -o $@

# Build the full kernel
$(BUILD)/kernel.bin: kernel.asm $(OBJ_FILES)
	mkdir -p $(BUILD)
	nasm -f elf32 kernel.asm -o $(BUILD)/kernel_asm.o
	ld -m elf_i386 -T linker.ld $(BUILD)/kernel_asm.o $(OBJ_FILES) -o $@

# Make ISO
iso: all
	cp $(BUILD)/kernel.bin iso/boot/kernel
	grub-mkrescue -o $(BUILD)/myos.iso iso

run: iso
	qemu-system-i386 -cdrom $(BUILD)/myos.iso

debug: iso
	qemu-system-i386 -cdrom $(BUILD)/myos.iso -s -S

clean:
	rm -rf $(BUILD)
