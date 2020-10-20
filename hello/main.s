org     0x7E00
bits    32

%define VGA_BUF 0xB8000 ; VGA buffer linear address

main:   mov     ax, 0x0F20   ; empty VGA entry (white text on black background)
        mov     edi, VGA_BUF
        mov     ecx, 2000    ; VGA buffer length in entries
        rep     stosw        ; clear the screen

.hello: mov     edi, VGA_BUF
        mov     esi, hello

; print string while character pointed to
;   by ESI is not equal to zero
.loop:  mov     al, [esi]
        test    al, al
        jz      .hlt
        mov     [edi], al
        add     edi, 2 ; every VGA entry is 2 bytes in size
        inc     esi
        jmp     .loop

.hlt:   hlt

hello db "Hello, World!", 0