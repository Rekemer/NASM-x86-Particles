; ----------------------------------------------------------------------------
; helloworld.asm
;
; This is a Win32 console program that writes "Hello, World" on one line and
; then exits.  It needs to be linked with a C library.
; ----------------------------------------------------------------------------

    global  _main
    extern  _printf

    section .text


 sum:
    push ebp
    mov  ebp, esp  ; potentially we can allocate memory on stack for function
    mov eax, [ebp + 8]
    mov ebx, [ebp + 12]
    add eax, ebx
    ;mov eax, ebx
    mov esp, ebp
    pop ebp
    ret

_main:

    mov     eax, [number2]
    push    eax
    mov     eax, [number]
    push    eax
    call    sum
    add      esp,8
    ;mov     eax, ebx
    ret
section .data  ; initialized and constant data 
number: dd 22
number2: dd 5

message:
    db  '%i', 10, 0