; ----------------------------------------------------------------------------
; helloworld.asm
;
; This is a Win32 console program that writes "Hello, World" on one line and
; then exits.  It needs to be linked with a C library.
; ----------------------------------------------------------------------------

    global  _main
    extern  _printf

    section .text



_main:

    mov     eax, [number]
    push    eax
    push    message
    call    _printf
    add      esp,8
    mov     eax, 69
    ret
section .data  ; initialized and constant data 
number: dd 22
number2: db 5

message:
    db  '%i', 10, 0