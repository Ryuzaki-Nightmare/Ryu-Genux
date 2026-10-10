[BITS 16]; We are in 16 bits on this Moment :D
[org 0x7c00] ;Boot sector endress
;This Archive is just Stage 1 Bootloader
jmp start
clear:
    ;This function clear Screen
    mov ah,00h
    mov al,03h
    int 10h
    ret ; Use iret to interrupt bios

print_in_screen:

    mov ah,13h
    mov bp,message ;  ES:BP,endress of string
    mov cx,16 ; number size of string (in this case is "message")
    mov dx,0 ; position of string (cursor)
    mov bh,0 ; page number
    mov al, 0x01 ; attribute mode
    mov bl,0x0f ; BL atribbute (if al == 0 or al == 1)
    push cs
    pop es
    int 0x10
    ret
sleep:
    mov ah, 0x86       
    mov cx, 0x000F      
    mov dx, 0x4240      
    int 0x15
    ret
message DB "Tapix Loader Run"
;Start Main funcion
start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    call clear
    call print_in_screen
    call sleep
    call clear
    mov ah, 0x02        ; function, read sector
    mov al, 4           ; How much sectors to read
    mov ch, 0           ; cylinder
    mov cl, 2           ; sector, start in 2 ( first sector is this function)
    mov dh, 0           ; cabeça
    mov bx, 0x7E00      ; Where put in the memory (Ram)
    int 0x13
    jmp 0x7E00  
   
times 510 - ($ -$$) db 0
dw 0xAA55   
