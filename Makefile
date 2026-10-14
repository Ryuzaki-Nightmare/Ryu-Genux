CC = gcc
ASM = nasm
ASMFLAGS = -f bin
BUILD = build
SRC  = boot/stage1.s
SRC2 = boot/stage2.s
SRC3 = boot/kernel_entry.s
OUT  = build/bootloader.bin
log  = qemu.log


run:
	mkdir -p $(BUILD)
	nasm $(ASMFLAGS) $(SRC)  -o $(BUILD)/stage1.bin
	nasm $(ASMFLAGS) $(SRC2) -o $(BUILD)/stage2.bin
	cat $(BUILD)/stage1.bin  $(BUILD)/stage2.bin > $(OUT)
	qemu-system-x86_64 -drive format=raw,file=$(OUT) -D qemu.log -d int,cpu_reset

clean:
	rm -rf $(BUILD)
	rm -f qemu.log
