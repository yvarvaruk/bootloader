%define SCREEN_COLOR    0x07   ; default VGA screen color - white text on black background
%define BUF_BASE_SEG    0x0    ; base address segment of memory buffer for loading executable
%define BUF_BASE_OFF    0x7E00 ; base address offset of memory buffer for loading executable
%define BUF_BASE_LINEAR 0x7E00 ; base linear address of memory buffer for loading executable
%define GDT_BASE        0x800  ; base address for GDT buffer

; Create new global descriptor
; es:di - descriptor address
; %1 - base (32 bits), %2 - limit (20 bits)
; %3 - access byte,    %4 - flags (4 bits)
; All parameters must be raw constant numbers
%macro GDESCR 4
        mov     WORD [es:di], (%2 & 0xFFFF)
        mov     WORD [es:di+2], (%1 & 0xFFFF)
        mov     BYTE [es:di+4], ((%1>>16) & 0xFF)
        mov     BYTE [es:di+5], %3
        mov     BYTE [es:di+6], ((%2>>16) & 0x0F) | ((%4<<4) & 0xF0)
        mov     BYTE [es:di+7], ((%1>>24) & 0xFF)
%endmacro