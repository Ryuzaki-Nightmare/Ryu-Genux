[BITS 32]
global entry
extern main
extern _bss_start
extern _bss_end

entry: ;ENTRY IN C FUNCTION
    mov edi, _bss_end
    mov ecx, _bss_start
    sub ecx,edi
    xor eax,eax
    ;resets to zero BSS SECTION 
    cld 
    rep stosb
    call main ; call main function in main.c
    jmp $ ; infinit loop after jmp
