[BITS 32]
global entry
extern main
extern bss_start
extern bss_end

entry:
    ; Configura os registradores para limpar a BSS
    mov edi, bss_start
    mov ecx, bss_end
    sub ecx, edi        ; Agora a subtração ocorre em tempo de execução na CPU
    
    xor eax, eax
    cld
    rep stosb           ; Preenche a BSS com zeros

    call main           ; Chama sua função C
    jmp $               ; Loop infinito de segurança

