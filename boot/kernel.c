/*
 *  This arquive is archive c test, just print Hello World!
 * */
#include "boot.h"
void  kernel_main(){
    asm("sti");
    asm("hlt"); 
    while(1);
}

