all: build run
	
build:
	nasm -f bin boot.asm -o boot.img

run:
	qemu-system-i386 -drive file=boot.img,format=raw,index=0,if=floppy