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

;%include "WIN32N.INC"
                             
%define WS_OVERLAPPED       0x00000000
%define WS_POPUP            0x80000000
%define WS_CHILD            0x40000000
%define WS_MINIMIZE         0x20000000
%define WS_VISIBLE          0x10000000
%define WS_DISABLED         0x08000000
%define WS_CLIPSIBLINGS     0x04000000
%define WS_CLIPCHILDREN     0x02000000
%define WS_MAXIMIZE         0x01000000
%define WS_CAPTION          0x00C00000
%define WS_BORDER           0x00800000
%define WS_DLGFRAME         0x00400000
%define WS_VSCROLL          0x00200000
%define WS_HSCROLL          0x00100000
%define WS_SYSMENU          0x00080000
%define WS_THICKFRAME       0x00040000
%define WS_GROUP            0x00020000
%define WS_TABSTOP          0x00010000

%define WS_MINIMIZEBOX      0x00020000
%define WS_MAXIMIZEBOX      0x00010000

%define WS_TILED            WS_OVERLAPPED
%define WS_ICONIC           WS_MINIMIZE
%define WS_SIZEBOX          WS_THICKFRAME
%define WS_TILEDWINDOW      WS_OVERLAPPEDWINDOW

; Common Window Styles 

%define WS_OVERLAPPEDWINDOW (WS_OVERLAPPED     | \
							 WS_CAPTION        | \
							 WS_SYSMENU        | \
							 WS_THICKFRAME     | \
							 WS_MINIMIZEBOX    | \
							 WS_MAXIMIZEBOX)
                             
%define PM_REMOVE 1h

%define WM_QUIT                         0x0012
%define WM_PAINT                        0x000F
%define WM_CLOSE                        0x0010

; Class styles 

%define CS_VREDRAW          0x0001
%define CS_HREDRAW          0x0002
%define CS_DBLCLKS          0x0008
%define CS_OWNDC            0x0020
%define CS_CLASSDC          0x0040
%define CS_PARENTDC         0x0080
%define CS_NOCLOSE          0x0200
%define CS_SAVEBITS         0x0800
%define CS_BYTEALIGNCLIENT  0x1000
%define CS_BYTEALIGNWINDOW  0x2000
%define CS_GLOBALCLASS      0x4000

; Standard Icon IDs 

%define IDI_APPLICATION     32512
%define IDC_ARROW 32512
                           
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
    extern PeekMessageA
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
    ;sub esp, 8
    ;sub esp, 32
    ;xor ecx,ecx
    push 0
    call [GetModuleHandleA]
    mov [hInstance], eax
    ;add esp, 32
    ;add esp, 8

    
    
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

    mov dword[OurWindowclass+32], 5 ; .hbrBackground, 5 is COLOR_WINDOW
    mov dword[OurWindowclass+36], 0 ; .lpszMenuName
    mov dword[OurWindowclass+40], Windowclassname ; .lpszClassName
    mov dword[OurWindowclass+44], 0 ; ..hIconSm
    lea eax, [OurWindowclass]
    push eax
    call RegisterClassExA
    
    ;add esp, 4
    
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
    push Windowclassname
    push 0        ; Extended style
    call CreateWindowExA
    
    
    mov dword[WindowHandle], eax
    push 1 
    push dword[WindowHandle]
    call ShowWindow
    push dword[WindowHandle]
    call UpdateWindow  

messloop:
    
	push PM_REMOVE
	push 0
	push 0
	push 0
	push MessageBuffer
	call PeekMessageA
    
    ; See if the return value is zero
    cmp eax, 0
    je nextloop
        
    ; If the 'message' is WM_QUIT then we have to QUIT!
    cmp dword[MessageBuffer+4], WM_QUIT
    je exit
    
    push MessageBuffer
    call TranslateMessage
    
    push MessageBuffer
	call DispatchMessageA
    
nextloop:
    jmp near messloop

exit:
    push dword 0
    call ExitProcess

	ret

global WindowProc
WindowProc:
    push ebp
    mov ebp, esp
    cmp dword[ebp+12], WM_CLOSE
    jne Ldefault
    push 0 
    call PostQuitMessage
    
    push 22
    call ExitProcess
    ; mov esp, ebp
    ; pop ebp
    ; ret

Ldefault:
	push dword[ebp+20]	; LPARAM
    push dword[ebp+16]	; WPARAM
    push dword[ebp+12]	; Msg
    push dword[ebp+8]	; hWnd
	call DefWindowProcA

    mov esp, ebp
    pop ebp
	ret

section .data  ; initialized and constant data 
    number: dd 22
    number2: dd 5
    Windowclassname db "MyClass", 0
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
     MessageBuffer resb 28
     OurWindowclass resb 48
     WindowHandle resb 4
