org     0x7E00
bits    32

main:   mov     ax, 0x0F20   ; empty VGA entry (white text on black background)
        mov     edi, 0xB8000 ; VGA buffer linear address
        mov     ecx, 2000    ; VGA buffer length in entries
        rep     stosw        ; clear the screen
.hlt:   hlt
