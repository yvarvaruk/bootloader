%include "include.s"

org     0x7C00
bits    16

boot:   cli
        cld
        jmp     0x0:.setcs ; initializing
.setcs: xor     ax, ax     ;   segment
        mov     ds, ax     ;   registers
        mov     ss, ax     ; setting up
        mov     sp, 0x7C00 ;   stack

.a20:   call    test_a20   ; testing if a20 line is enabled,
        test    ax, ax     ;   if it is, skip the rest
        jnz     .rdisk     ;   of this section
        call    enable_a20 ; enable A20 line. If A20 line
        test    ax, ax     ;   somehow wasn't enabled, suppose
        jnz     .rdisk     ;   there is no actual A20 line on 
        mov     si, a20err ;   this machine. Print out error
        jmp     error      ;   message and halt the system

.rdisk: mov     ax, BUF_BASE_SEG    ; reading data
        mov     es, ax              ;   from the
        mov     cl, 2               ;   disk and
        mov     al, EXECUTABLE_SIZE ;   storing it
        mov     bx, BUF_BASE_OFF    ;   in buffer at
        call    read_disk           ;   BUF_BASE_SEG:BUF_BASE_OFF
        test    ax, ax      ; display error
        jnz     .gdt        ;   message if
        mov     si, diskerr ;   something
        jmp     error       ;   went wrong

.gdt:   xor     ax, ax
        mov     es, ax
        mov     di, GDT_BASE
        mov     [di], DWORD 0   ; NULL
        mov     [di+4], DWORD 0 ;   descriptor
        add     di, 8
        GDESCR  0x0,0xFFFFF,0x9A,0xC ; code descriptor
        add     di, 8
        GDESCR  0x0,0xFFFFF,0x92,0xC ; data descriptor
        mov     si, gdt_ptr            ; initialize GDT pointer structure:
        mov     [si], WORD 24          ;   GDT size
        mov     [si+2], DWORD GDT_BASE ;   linear address of GDT
        lgdt    [si]

.pmode: mov     eax, cr0 ; switch to protected mode
        or      eax, 0x1 ;   by turning on 1st bit
        mov     cr0, eax ;   in CR0 register
        jmp     init ; prefetch input queue
        nop ; make sure that
        nop ;   input queue
        nop ;   is prefetched

bits  32

init:   mov     eax, 0x10 ; initializing
        mov     ds, eax   ;   segment
        mov     ss, eax   ;   registers
        mov     es, eax   ;   with
        mov     fs, eax   ;   GDT
        mov     gs, eax   ;   entries
.setcs: dw      0xEA66    ; setting cs to
        dd      .jump     ;   point to code
        dw      0x8       ;   descriptor at 0x8
.jump:  jmp     BUF_BASE_LINEAR
.hlt:   hlt

gdt_ptr dw  0 ; uninitialized GDT
        dd  0 ;   pointer structure

bits    16

%include "a20.s"
%include "io.s"

times   510-($-$$) db 0 ; clearing the rest 1st sector bytes with zero
db      0x55 ; setting up BIOS
db      0xAA ;   boot signature
