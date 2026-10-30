/*
 * this is test of kernel, just print an res Screen
 * */
#include "../boot/boot.h"
void  kernel_main(EFI_GOP_INFORMATION *Gop,GENUX_TIME time,BootInfo Info){
uint32_t *fb = (uint32_t *)Gop->FrameBufferBase;
    uint32_t totalPixels = Gop->PixelsPerScanLine * Gop->HeightResolution;
    for (uint32_t i = 0; i < totalPixels; i++) {
        fb[i] = 0x00FF0000; //red
    }
    while (1) { asm volatile("hlt"); }
}

