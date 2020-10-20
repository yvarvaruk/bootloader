; Parameters:
;   al - number of sectors to read
;   es:bx - base for buffer
;   cl - start sector (1-based)
;   dl - drive index
; Return value(AX):
;   1 if everything's OK, 0 if some error occurred
read_disk:
        push    cx
        push    dx
        mov     ah, 0x02
        xor     ch, ch ; 0th cylinder
        xor     dh, dh ; 0th head
        int     0x13
        mov     ax, 1 ; mov doesn't affect any flags
        jnc     .exit
        dec     ax
.exit:  pop     dx
        pop     cx
        ret

; Parameters:
;   si - pointer to null-terminated string
print:  push    ax
        push    bx
        push    si
        mov     ah, 0x0E
        xor     bh, bh           ; 0th page number
        mov     bl, SCREEN_COLOR ; 0x07 screen color
.loop:  mov     al, BYTE [si]
        test    al, al
        jz      .exit
        int     0x10
        inc     si
        jmp     .loop
.exit:  pop     si
        pop     bx
        pop     ax
        ret

; Prints out message pointed to by si and
;   general message, then halts the system
; Function can be both 'call'-ed and 'jmp'-ed to
; Parameters:
;   si - pointer to null-terminated error message
error:  call    print
        mov     si, generr
        call    print
        hlt

generr  db "Halting system...", 0
diskerr db "Error reading data from disk. ", 0
a20err  db "Error enabling A20 line. ", 0
