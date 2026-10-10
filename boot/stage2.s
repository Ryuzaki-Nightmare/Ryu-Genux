[ORG 0x7E00]
[Bits 16] ; 16 Bits :D
;This archive is Just 16 to 32 bits, if you want 64bits you can fork to make transition :D
jmp main_16 ;Call Main Function
KERNEL_LOCATION equ 0x1000
get_a20_state:
	pushf
	push si
	push di
	push ds
	push es
	cli

	mov ax, 0x0000					;	0x0000:0x0500(0x00000500) -> ds:si
	mov ds, ax
	mov si, 0x0500

	not ax						    ;	0xffff:0x0510(0x00100500) -> es:di
	mov es, ax
	mov di, 0x0510

	mov al, [ds:si]					;	save old values
	mov byte [.BufferBelowMB], al
	mov al, [es:di]
	mov byte [.BufferOverMB], al

	mov ah, 1
	mov byte [ds:si], 0
	mov byte [es:di], 1
	mov al, [ds:si]
	cmp al, [es:di]					;	check byte at address 0x0500 != byte at address 0x100500
	jne .exit
	dec ah
    call enable_A20
.exit:
	mov al, [.BufferBelowMB]
	mov [ds:si], al
	mov al, [.BufferOverMB]
	mov [es:di], al
	shr ax, 8					    ;	move result from ah to al register and clear ah
	pop es
	pop ds
	pop di
	pop si
	popf
	ret
	
	.BufferBelowMB:	db 0
	.BufferOverMB	db 0

;NMIs HERE 
TurnOffNMI:
    ; Disable NMI
    mov   al,80h
    out   70h,al
    ret
    
TurnOnNMI:
    ; Enable NMI -> Use in 32 Bits
    xor   al,al
    ret

;GDT CODE
gdtr:
    dw gdt_end - gdt_start -1
    dd gdt_start

gdt_start:
    ;null segment
    dq 0x0000000000000000
    ;code segment
    dw 0xffff
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

    ;data segment
    dw 0xffff
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00
gdt_end:

enable_A20: ; from https://wiki.osdev.org/A20_Line
cli                     ; disable interrupts

call    a20wait
mov     al,0xAD
out     0x64,al         ; disable keyboard

call    a20wait
mov     al,0xD0
out     0x64,al         ; read controller output port

call    a20wait2
in      al,0x60         ; save response byte
push    eax

call    a20wait
mov     al,0xD1
out     0x64,al         ; write next byte into controller output port

call    a20wait
pop     eax
or      al,2            ; set controller output bit for A20 on
out     0x60,al         ; activate A20

call    a20wait
mov     al,0xAE
out     0x64,al         ; reactivate keyboard

call    a20wait
sti                     ; reactivate interrupts
ret

a20wait:                        ; wait until input buffer is clear
in      al,0x64
test    al,2
jnz     a20wait
ret


a20wait2:                       ; wait until response byte has arrived
in      al,0x64
test    al,1
jz      a20wait2
ret
;MEMORY MAP functions, FROM OS-WIKI DEV !!!!
mmap_ent equ 0x8000             ; the number of entries will be stored at 0x8000
do_e820:
    mov di, 0x8004          ; Set di to 0x8004. Otherwise this code will get stuck in `int 0x15` after some entries are fetched 
	xor ebx, ebx		; ebx must be 0 to start
	xor bp, bp		; keep an entry count in bp
	mov edx, 0x0534D4150	; Place "SMAP" into edx
	mov eax, 0xe820
	mov [es:di + 20], dword 1	; force a valid ACPI 3.X entry
	mov ecx, 24		; ask for 24 bytes
	int 0x15
	jc short .failed	; carry set on first call means "unsupported function"
	mov edx, 0x0534D4150	; Some BIOSes apparently trash this register?
	cmp eax, edx		; on success, eax must have been reset to "SMAP"
	jne short .failed
	test ebx, ebx		; ebx = 0 implies list is only 1 entry long (worthless)
	je short .failed
	jmp short .jmpin
.e820lp:
	mov eax, 0xe820		; eax, ecx get trashed on every int 0x15 call
	mov [es:di + 20], dword 1	; force a valid ACPI 3.X entry
	mov ecx, 24		; ask for 24 bytes again
	int 0x15
	jc short .e820f		; carry set means "end of list already reached"
	mov edx, 0x0534D4150	; repair potentially trashed register
.jmpin:
	jcxz .skipent		; skip any 0 length entries
	cmp cl, 20		; got a 24 byte ACPI 3.X response?
	jbe short .notext
	test byte [es:di + 20], 1	; if so: is the "ignore this data" bit clear?
	je short .skipent
.notext:
	mov ecx, [es:di + 8]	; get lower uint32_t of memory region length
	or ecx, [es:di + 12]	; "or" it with upper uint32_t to test for zero
	jz .skipent		; if length uint64_t is 0, skip entry
	inc bp			; got a good entry: ++count, move to next storage spot
	add di, 24
.skipent:
	test ebx, ebx		; if ebx resets to 0, list is complete
	jne short .e820lp
.e820f:
	mov [es:mmap_ent], bp	; store the entry count
	clc			; there is "jc" on end of list to this point, so the carry must be cleared
	ret
.failed:
	stc			; "function unsupported" error exit
	ret



main_16:
    ;16 bits Main funcion
    ;Disable ALL INTERRUPTS in cli and  TurnOFFNMI
    cli
    call TurnOffNMI
    call get_a20_state ; Get A20 State And Active A20 if cpu can active :D
    call do_e820
    xor ax,ax
    mov ds,ax
    lgdt [gdtr] ;Load initial gdt, Bye bye IVT, Hello World Gdt!
    
    ;Initial Segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov eax,cr0 
    or al,1
    mov cr0,eax
    jmp 08h:PreModeMain ;Go to 32 bits


;Bits 32 Finally Bro :)
[BITS 32]


PreModeMain:

    ;Load Segments
    mov ax,0x10
    mov es,ax
    mov ds,ax
    mov ss,ax
    mov fs,ax
    mov gs,ax


    mov esp,0x900000 ; UPD stack poiter to secure area!!!
    jmp Main32 ;Go to Main Function 32 bits
Main32: 
    ;MAIN FUNCTION 32 BITS HERE
    sti
    call  TurnOnNMI; Turn ON NMI
    jmp KERNEL_LOCATION
   ;Use iret to interrupts!!!
;0x08 to load cs
;0x10 to load ds,ss,es,fs,gs

