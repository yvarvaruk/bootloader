; Return value(AX):
;   1 if enabled, 0 otherwise
test_a20:
        push    si                   ; here i use memory wraparound 
        xor     ax, ax               ;   trick to check whether A20
        mov     ds, ax               ;   line is enabled or not
        mov     si, 0x7DFE           ; bootloader tries to write 0x6158 (arbitrary number)
        mov     WORD [ds:si], 0x6158 ;   to 0x0:0x7DFE where boot signature resides,
        not     ax                   ;   so it won't harm any actual code
        mov     ds, ax
        add     si, 0x10             ; then it tries to write different number
        mov     WORD [ds:si], 0x5239 ;   (0x5239), but now to 0xFFFF:0x7E0E
        not     ax
        mov     ds, ax
        sub     si, 0x10             ; if A20 line isn't enabled, then 0xFFFF:0x7E0E
        mov     ax, WORD [ds:si]     ;   addresses the same 0x0:0x7DFE, so it will contain
        cmp     ax, 0x5239           ;   0x5239, and if not - then A20 is already enabled
        mov     ax, 1 ; mov instruction does
        jne     .exit ;   not affect any flags
        dec     ax
.exit:  pop     si
        ret

; Return value(AX):
;   1 if enabled, 0 otherwise
enable_a20:
        call    _bios_a20 ; try BIOS interrupt method
        call    test_a20    
        test    ax, ax
        jnz     .exit
        call    _8042_a20 ; try 8042 keyboard controller method
        call    test_a20    
        test    ax, ax
        jnz     .exit
        call    _fast_a20 ; try fast A20 method
        call    test_a20    
.exit:  ret

_bios_a20:
        mov     ax, 0x2401
        int     0x15
        ret

_8042_a20:
        call    .wait1
        mov     al, 0xAD ; send command 0xAD
        out     0x64, al ;   (disable keyboard)
        call    .wait1
        mov     al, 0xD0 ; send command 0xD0
        out     0x64, al ;   (read from input)
        call    .wait2
        in      al, 0x60 ; read input from
        push    ax       ;   keyboard and save it
        call    .wait1
        mov     al, 0xD1 ; send command 0xD1
        out     0x64, al ;   (write to output)
        call    .wait1
        pop     ax       ; write input
        or      al, 2    ;   back with
        out     0x60, al ;   2nd bit set
        call    .wait1
        mov     al, 0xAE ; write command 0xAE
        out     0x64, al ;   (enable keyboard)
        call    .wait1
        ret
.wait1: in      al, 0x64 ; this function waits
        test    al, 2    ;   until keyboard 
        jnz     .wait1   ;   controller is
        ret              ;   ready for command
.wait2: in      al, 0x64 ; this function waits
        test    al, 1    ;   until keyboard
        jnz     .wait2   ;   controller has
        ret              ;   some data ready

_fast_a20:
        in      al, 0x92
        or      al, 0x02
        out     0x92, al
        ret
