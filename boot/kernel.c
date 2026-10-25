/*
 *  This arquive is archive c test, just print Hello World!
 * */

void  kernel_main(){
    asm("sti");
    asm("hlt"); 
    while(1);
}

