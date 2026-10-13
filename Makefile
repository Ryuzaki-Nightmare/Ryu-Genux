CC = gcc
ASM = nasm
ASMFLAGS = -f bin
BUILD = build
SRC  = boot/stage1.s
SRC2 = boot/stage2.s
SRC3 = boot/kernel_entry.s
OUT  = build/bootloader.bin
log  = qemu.log


Compile:
	mkdir -p $(BUILD)
	nasm $(ASMFLAGS) $(SRC)  -o $(BUILD)/stage1.bin
	nasm $(ASMFLAGS) $(SRC2) -o $(BUILD)/stage2.bin
	nasm -f elf32 $(SRC3)    -o $(BUILD)/kernel_entry.o
	gcc -m32 -ffreestanding -nostdlib -nostdinc -fno-pic -c boot/main.c -o $(BUILD)/main.o
	ld -m elf_i386 -T linker.ld -o $(BUILD)/kernel.elf $(BUILD)/kernel_entry.o $(BUILD)/main.o
	objcopy -O binary $(BUILD)/kernel.elf $(BUILD)/kernel.bin
	cat $(BUILD)/stage1.bin $(BUILD)/stage2.bin $(BUILD)/kernel.bin > $(OUT)

run: Compile
	qemu-system-x86_64 -drive format=raw,file=$(OUT) -D qemu.log -d int,cpu_reset

clean:
	rm -rf $(BUILD)
	rm -f qemu.log
