CC = gcc
CCFLAGS = -m64 -ffreestanding -nostdlib -no-pie
BUILD = build
SRC = boot/boot.c
KERNEL = boot/kernel.c
OUT = $(BUILD)/BOOTX64.EFI
LD = linker
all : clean
#The compile Function compile "boot.c" to "BOOTX64.EFI"
Compile:
		mkdir -p $(BUILD)
		$ gcc boot/boot.c                            \
      -c                                 \
      -fno-stack-protector               \
      -fpic                              \
      -fshort-wchar                      \
      -mno-red-zone                      \
      -I /usr/include/efi     \
      -I /usr/include/efi/x86_64\
      -DEFI_FUNCTION_WRAPPER             \
      -o boot.o
	  $ ld boot.o                                    \
      /usr/lib/crt0-efi-x86_64.o          \
      -nostdlib                                \
      -znocombreloc                            \
      -T /usr/lib/elf_x86_64_efi.lds        \
      -shared                                  \
      -Bsymbolic                               \
      -L /usr/lib                        \
      -l:libgnuefi.a                           \
      -l:libefi.a                              \
      -o $(BUILD)/boot.so
	$ objcopy -j .text                             \
          -j .sdata                            \
          -j .data                             \
          -j .rodata                           \
          -j$ .dynamic                          \
          -j .dynsym                           \
          -j .rel                              \
          -j .rela                             \
          -j .reloc                            \
          --output-target=efi-app-x86_64       \
          $(BUILD)/boot.so                              \
          $(BUILD)/boot.efi
	mkdir -p build/esp/EFI/BOOT
	cp $(BUILD)/boot.efi build/esp/EFI/BOOT/BOOTX64.EFI
	
KERNEL_COMPILE:Compile
		$(CC) $(KERNEL) $(CCFLAGS) -o $(BUILD)/esp/kernel.bin 
run: KERNEL_COMPILE
	#in "-m 16G" put how many memory ram you want use in qemu, in -smp is how many cores you want use in Qemu
	qemu-system-x86_64                        \
    -enable-kvm                           \
    -m 16G                                \
    -smp 8                                \
    -bios /usr/share/edk2/x64/OVMF.4m.fd  \
    -drive format=raw,file=fat:rw:build/esp     \
    -vga std                              \
    -D qemu.log                           \
    -d int,cpu_reset	
clean: 
	rm -rf $(BUILD)
