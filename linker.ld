ENTRY(kernel_main)
SECTION{
    . = 0x100000; 
    .text:
    {
        *(.text)
    }
    .rodata:
    {
        *(.rodata)
    }
    .data:
    {
        *(.data)
    }
    .bss:
    {
        *(.bss)
    }
}

