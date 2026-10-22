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
	mkdir -p esp/EFI/BOOT
	cp $(BUILD)/boot.efi esp/EFI/BOOT/BOOTX64.EFI
	mv esp $(BUILD)
	rm boot.o
KERNEL_COMPILE:Compile
		$(CC) $(KERNEL) $(CCFLAGS) -o $(BUILD)/kernel.bin 
run: KERNEL_COMPILE
	qemu-system-x86_64                        \
    -enable-kvm                           \
    -m 16G                                \
    -smp 8                                \
    -bios /usr/share/edk2/x64/OVMF.4m.fd  \
    -drive format=raw,file=fat:rw:esp     \
    -vga std                              \
    -D qemu.log                           \
    -d int,cpu_reset	
clean: 
	rm -rf $(BUILD)
