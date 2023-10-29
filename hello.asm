; ----------------------------------------------------------------------------
; helloworld.asm
;
; This is a Win32 console program that writes "Hello, World" on one line and
; then exits.  It needs to be linked with a C library.
; ----------------------------------------------------------------------------


; Remember that labels can be used to refer to data in code. There are two
; ways that a label can be used. If a plain label is used, it is interpreted as the
; address (or offset) of the data. If the label is placed inside square brackets
; ([]), it is interpreted as the data at the address. In other words, one should
; think of a label as a pointer to the data and the square brackets dereferences
; the pointer just as the asterisk does in C.

%include "WIN32N.INC"
                             
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
    extern LoadIconA
    extern LoadCursorA
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
    mov [hInstance], eax
    add esp, 32
    add esp, 8

    
    
    mov dword[OurWindowclass], 48 ; .cbSize
    mov dword[OurWindowclass+4], CS_OWNDC|CS_HREDRAW|CS_VREDRAW 
    mov dword[OurWindowclass+8], WindowProc    ; lpfnWndProc
    mov dword[OurWindowclass+12], 0
    mov dword[OurWindowclass+16], 0
    mov dword eax, [hInstance]
    mov dword[OurWindowclass+20], eax ; .hInstance

    push IDI_APPLICATION
    push 0
    call LoadIconA
	mov dword[OurWindowclass+24], eax ; .hIcon
    
    push IDI_APPLICATION
    push 0
    call LoadCursorA
    mov dword[OurWindowclass+28], eax ; .hCursor

    mov dword[OurWindowclass+32], 0 ; .hbrBackground, 5 is COLOR_WINDOW
    mov dword[OurWindowclass+36], 5 ; .lpszMenuName
    mov dword[OurWindowclass+40], "a" ; .lpszClassName
    mov dword[OurWindowclass+44], 0 ; .lpszClassName
    lea eax, [OurWindowclass]
    push eax
    call RegisterClassExA
    add esp, 4
   
    ;mov eax, dword[Instance]

    push 0
    push dword[hInstance]
    push 0
    push 0
    push 362    ;  Height
    push 362    ;  Width
    push 140    ;  Top
    push 360    ;  Left
    push WS_VISIBLE+WS_OVERLAPPEDWINDOW ; Style
    push WindowName
    push ClassName
    push 0        ; Extended style
    call CreateWindowExA
    mov dword[Windowhandle], eax
    
    
    push 69
    call ExitProcess 

    ret
CreateWindow: 
    
WindowProc:
    push ebp
    mov ebp, esp

    mov esp, ebp
    pop ebp
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
     alignb 8
     hInstance resb 4
     OurWindowclass resb 48
     Windowhandle resb 4
