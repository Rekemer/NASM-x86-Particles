; ----------------------------------------------------------------------------
; helloworld.asm
;
; This is a Win32 console program that writes "Hello, World" on one line and
; then exits.  It needs to be linked with a C library.
; ----------------------------------------------------------------------------



    COLOR_WINDOW        EQU 5                       ; Constants
    CS_BYTEALIGNWINDOW  EQU 2000h
    CS_HREDRAW          EQU 2
    CS_VREDRAW          EQU 1
    CW_USEDEFAULT       EQU 80000000h
    IDC_ARROW           EQU 7F00h
    IDI_APPLICATION     EQU 7F00h
    IMAGE_CURSOR        EQU 2
    IMAGE_ICON          EQU 1
    LR_SHARED           EQU 8000h
    NULL                EQU 0
    SW_SHOWNORMAL       EQU 1
    WM_DESTROY          EQU 2
    WS_EX_COMPOSITED    EQU 2000000h
    WS_OVERLAPPEDWINDOW EQU 0CF0000h

    extern CreateWindowExA                          ; Import external symbols
    extern DefWindowProcA                           ; Windows API functions, not decorated
    extern DispatchMessageA
    extern ExitProcess
    extern GetMessageA
    extern GetModuleHandleA
    extern IsDialogMessageA
    extern LoadImageA
    extern PostQuitMessage
    extern RegisterClassExA
    extern ShowWindow
    extern TranslateMessage
    extern UpdateWindow
    extern AllocConsole 
    
    ; import AllocConsole kernel32.dll
    ; import GetModuleHandleA kernel32.dll
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
global  _main
extern  _printf
_main:
    sub esp, 8
    sub esp, 32
    xor ecx,ecx
    call [GetModuleHandleA]
    ;mov [REL hInstance], eax
    add esp, 32
    add esp, 12
    push 3
    call [ExitProcess]
    ret
section .data  ; initialized and constant data 
    number: dd 22
    number2: dd 5

    WindowName  db "Basic Window 64", 0
    ClassName   db "Window", 0

    ;equ The equ directive can be used to define a symbol. Symbols are named
    ;constants that can be used in the assembly program
    WINDOW_WIDTH equ 640 
    WINDOW_HEIGHT equ 480
message:
    db  '%i', 10, 0
section .bss
     hInstance resb 1
