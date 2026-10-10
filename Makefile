CC = gcc
ASM = nasm
ASMFLAGS = -f bin
BUILD = build
#DEFINE ARCHIVES
SRC = boot/stage1.s
SRC2 = boot/stage2.s
SRC3 = boot/kernel_entry.s
OUT = build/bootloader.bin # DEFINE OUTPUT
log = qemu.log

all: $(OUT)

Compile:
	mkdir -p $(BUILD) 
	nasm $(ASMFLAGS) $(SRC) -o $(BUILD)/stage1.bin
	nasm $(ASMFLAGS) $(SRC2) -o $(BUILD)/stage2.bin
	nasm  -f bin $(SRC3) -o $(BUILD)/kernel_entry.bin
	gcc   -m32 -ffreestanding -nostdlib -nostdinc -c boot/main.c -o $(BUILD)/main.elf
	objcopy -O binary $(BUILD)/main.elf $(BUILD)/main.bin

Main: Compile

	cat build/stage1.bin build/stage2.bin build/main.bin build/kernel_entry.bin > build/bootloader.bin
run: Main
	qemu-system-x86_64 -drive format=raw,file=$(OUT) -D  qemu.log -d int,cpu_reset

clean:
	rm -rf $(BUILD)
	rn  qemu.log

