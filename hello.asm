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
    extern WriteConsoleA
    extern GetStdHandle 
    extern GetCursorPos 
    extern WriteFile 
    extern ScreenToClient 
    extern SetPixel 
    extern GetDC 

    
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

;repne scasb: The repne prefix is used to repeat the scasb instruction.
; It keeps executing scasb until the null terminator (0x00) is found.
;  The scasb instruction compares the byte at the memory location pointed to by EDI with the value in AL (which is 0x00).
;   If they are not equal, it increments EDI (since the direction flag is cleared) and decrements ECX. 
;This process continues until the null terminator is found.

StringLength:
    mov edi,ecx

    xor eax,eax		; Set the value that scasb will search for. In this case it is zero (the null terminator byte)
    mov ecx,-1		; Store -1 in rcx so that scasb runs forever (or until it finds a null terminator). scasb DECREMENTS rcx each iteration
    cld			; Clear the direction flag so scasb iterates forward through the input string

    repne scasb		; Execute the scasb instruction. This leaves rdi pointing at the base of the null terminator.

    not ecx		; Invert the value of rcx so that we get the two's complement value of the count. E.g, a count of -25 results in 24.
    mov eax,ecx		; Move the length of the string into rax

    ret
itoa:
    push ebp		
    mov ebp,esp
    sub esp,8		; Align the stack to 16 bytes (8 for return address + another 8 = 16)

    mov eax,ecx		; Move the passed in argument to rax
    lea edi,[numbuf+13]	; load the end address of the buffer (past the very end)
    mov ecx,10		; divisor
    mov dword [ebp-8],0	; rbp-8 will contain 8 bytes representing the length of the string - start at zero
.divloop:
    xor edx, edx      ; Zero out edx (where our remainder goes after idiv)
    idiv ecx          ; Divide eax (the number) by 10 (the remainder is placed in edx)
    add dl, 0x30      ; Add 0x30 to the remainder so we get the correct ASCII value
    dec edi           ; Move the pointer backwards in the buffer
    mov byte [edi], dl ; Move the character into the buffer
    inc dword [ebp-8]  ; Increase the length

    cmp eax, 0        ; Was the result zero?
    jnz .divloop      ; No it wasn't, keep looping

    mov eax, edi      ; edi now points to the beginning of the string - move it into eax
    mov ecx, [ebp-8]  ; ebp-8 contains the length - move it into ecx

    leave             ; Clean up our stack
    ret
write:
    push ebp
    mov ebp, esp
    sub esp, 64     ; Allocate space for local variables and shadow space

    ; Store our message and its length in local variables
    mov [ebp - 8], ecx
    mov [ebp - 12], edx
    
    ; Get the handle to StdOut
    push STD_OUTPUT_HANDLE
    call GetStdHandle

    ; Write the message, passing the local variable values to the WinAPI
    push 0
    push empty
    push dword[ebp - 12]
    push dword[ebp - 8]
    push eax
    call WriteFile
    
    
    add esp, 20     ; Deallocate the parameters pushed on the stack

    mov esp, ebp
    pop ebp
    ret
; eax is a number
printNumber:
   
    call itoa
   
    ;ecx is length and eax is begin address of content
    
    ; The order of the two below instructions is important. RCX
    ; contains the length of the string returned from itoa, but
    ; its also a requirement that the first argument to write
    ; be passed via rcx. So we need to move rcx in to rdx before
    ; we overwrite rcx with rax.
    
    mov edx,ecx
    lea ecx,[eax]
    call write
    ret
; 1 - size
; 2 - posX
; 3 - posY
; 4 - color
SetColorOfArea:
    push ebp
    mov ebp,esp

    sub esp, 20
    mov eax, [ebp+16]
    shr eax, 1
    mov [esp+4],eax  ; total size
    neg eax
    mov [esp], eax ; begin of iterationX size
    mov dword[esp+12], eax ; begin of iterationY size
  
     

    mov ebx, [ebp+12]
    mov dword[esp+8], 0 ; iteratorX
    mov dword[esp+16], 0 ; iteratorY

    
   
loop:
    
    

   

    
    mov edx,3
    lea ecx,[newLine]

    call write

    mov ebx, [cursorPos]
    mov ecx, [cursorPos+4]

    
 
   
    inc eax
    add ebx, [esp] ; new x pos
    
loopY:
    
   ;mov edx,3
   ;lea ecx,[newLine]

   ;call write

   
    
    add ecx, [esp+12]

;    call printNumber

    push 0xFF0000
    push ecx  ; y pos
    push ebx ; x pos
    push dword[DeviceContext]
    call SetPixel

    inc dword[esp+12]
    inc dword[esp+16]
    mov eax, [esp+16]
    cmp eax, [ebp+16]
    je endLoopX
    jmp loopY


endLoopX: 
    mov eax, [esp+8]
    mov dword[esp+16],0
    inc dword[esp] ; increment x Size
    inc dword [esp+8] ; increment i
    mov eax, [esp+8]
    cmp eax, [ebp+16]
    je end
    jmp loop


end:
    mov esp, ebp
    pop ebp
    ret

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

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    mov [outHandle], eax

    push dword [WindowHandle]
    call GetDC
    mov [DeviceContext], eax

    mov esp,ebp

    
; Write the message, passing the local
    ; variable values to the WinAPI

     ; Put the number in rdi
   ; sub esp,0x28
   
    
    
  ;  add esp,0x28
    

messloop:
    
    ;sub esp, 16
    ;push dword[esp-16]
    
    ;call GetCursorPos 
; print string
;    push 0
;    sub esp, 32
;    lea eax, [esp-32]
;    push eax
;    mov ecx, string
;    call StringLength
;    push eax
;    push string
;    push dword [outHandle]
;    call WriteConsoleA 
;    mov esp, ebp
;----------------------
  
    sub esp, 8                              ; allocate memory for POINT
    mov dword ebx, esp
    push ebx        
    call GetCursorPos
    mov eax, [esp]
    mov dword[cursorPos], eax
    mov eax, [esp+4]
    mov dword[cursorPos+4], eax
    mov esp,ebp

    push cursorPos
    push dword [WindowHandle]
    call ScreenToClient
    ;push eax
    ;call ExitProcess

   ; mov ecx,[cursorPos]
    ; call printNumber


  ; mov ecx,[cursorPos+4]
    ;call printNumber

    
     mov edx,3
    lea ecx,[newLine]

    call write

    push 6 
    push dword [cursorPos]
    push dword [cursorPos+4]
    call SetColorOfArea
    
  ;push 22
  ;call ExitProcess
    
   


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
    Windowclassname db "MyClass", 0
    WindowName  db "Basic Window 64", 0
    ClassName   db "Window", 0
    string db "Hello, Ilia!",0
    newLine db 13,10,0
    ;equ The equ directive can be used to define a symbol. Symbols are named
    ;constants that can be used in the assembly program
    WINDOW_WIDTH equ 640 
    WINDOW_HEIGHT equ 480
    crlf db 10, 13, 0 ; Newline and carriage return
    number		dd 1234567890

message:
    db  '%i', 10, 0
section .bss
     alignb 8
     hInstance resb 4
     outHandle resb 4
     MessageBuffer resb 28
     OurWindowclass resb 48
     WindowHandle resb 4
     DeviceContext resb 4
    numBuffer resb 12 ; Buffer for the number as a string (up to 10 digits + null terminator)
    empty resb 1
    numbuf resb 11
    cursorPos resb 8