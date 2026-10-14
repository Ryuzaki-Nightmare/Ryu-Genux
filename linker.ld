ENTRY(start) 

SECTIONS
{   
    
    .text :
    {       

           *(.text*) 
    }
    .data :
    {
        *(.data*)    
    }
    .bss :
    {
       
        *(COMMON)
        *(.bss*)
       
    }
}
