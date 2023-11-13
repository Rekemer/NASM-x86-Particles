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
    extern AllocConsole 
    extern WriteConsoleA
    extern GetStdHandle 
    extern GetCursorPos 
    extern WriteFile 
    extern ScreenToClient 
    extern SetPixel 
    extern GetDC 
    extern SwapBuffers 
    extern FillRect 
    extern CreateSolidBrush 
    extern GetClientRect 
    extern UpdateWindow 
    extern RedrawWindow 
    extern BeginPaint 
    extern EndPaint 
    extern SetTimer 
    extern InvalidateRect 
    extern DeleteObject 
    extern mySin 
    extern printFloat 
    extern printString 
    extern printInteger 
    extern random 
    extern randomColor 
    
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
pushad
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
    popad
    ret

; eax is a number
printNewLine:

    mov edx,3
    lea ecx,[newLine]
    call write
    ret  
printNumber:
   
    pushad
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
    popad
    ret
; 0 - color
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

    mov ebx, [ebp+12]
    mov ecx, [cursorPos+4]
    
    inc eax
    add ebx, [esp] ; new x pos
    
loopY:
    
 

   
    mov ecx,[ebp+8]
    add ecx, [esp+12]
    
    push dword[ebp+20]
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
    mov dword[esp+12],-12
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



lerp:
push ebp
mov ebp,esp
%define a dword[ebp+8]
%define b dword[ebp+12]
%define t dword[ebp+16]
sub esp,4
%define res dword[esp]
fild b
fild a
fsub
fabs
fist res

;push res
;call printInteger
;add esp,4

fld t
fmul 


fild a
fadd 

fist res


mov eax, res
 


mov esp,ebp
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

     ; Create a solid brush for the clear color
    push    0xff0000
    call    CreateSolidBrush
    mov dword[windowBrush],eax




    push windowRect
    push dword[WindowHandle]
    call GetClientRect


    call timer
    
   ;movl	$4, _a
	;movl	_a, %eax
	;movl	%eax, 28(%esp)
	;fildl	28(%esp)

    mov esp,ebp
   
   ;push 0x3f000000 
   ;push 200 
   ;push 50
   ;call lerp
    ; 0x3f000000 0.5
    ;0x4048f5c3  pi
    ;FLD dword[floatNumber]
  
    mov eax, 0 
    sub esp,12
    %define iterator dword[esp]
    %define t dword[esp+4]
    %define t1 dword[esp+8]
    mov iterator,0

    sub esp, 8                              ; allocate memory for POINT
    mov dword ebx, esp
    push ebx        
    call GetCursorPos
    mov eax, [esp]
    mov dword[cursorPos], eax
    mov eax, [esp+4]
    mov dword[cursorPos+4], eax
    add esp,8

initParticles:
    
    mov dword[exeTime],0
    mov ebx, iterator
    imul ebx, particleSize
    %define offset dword[ebx]
    %define index particles+ebx
    %define xPos dword[index]
    %define yPos dword[index+4]
    %define xVel dword[index+8]
    %define yVel dword[index+12]
    %define time dword[index+16]
    %define currentTime dword[index+20]
    %define startColor dword[index+24]
    %define finalColor dword[index+28]
  
    mov ecx,dword[cursorPos]
    add ecx, iterator 
    push ecx
    add ecx, iterator 
    push ecx
    call random
    add esp,8
    fstp t
    
    mov ecx,dword[cursorPos+4]
    inc ecx
    add ecx, iterator 
    push ecx
    add ecx, iterator 
    push ecx
    call random
    add esp,8
    
    fstp t1
  
    
    fld dword[maxVel]
    fld t1 
    fmul
    fstp yVel

    fld dword[maxVel]
    fld t 
    fmul
    fstp xVel

    fld dword[maxTime]
    fld t 
    fld dword[float_one]
    fadd 
    fdiv dword[float_two]
    fmul
    fstp time

    mov eax,   dword[cursorPos]
    mov xPos, eax
    mov eax,   dword[cursorPos+4]
    mov yPos, eax
    mov currentTime , 0


    push t
    call randomColor
    add esp,4
    mov startColor,eax
    
   push t1
   call randomColor
   add esp,4
   mov finalColor,eax
   ; push t
   ; call printFloat
   ;add esp,4

   ;push startColor
   ;call printInteger
   ;add esp,4
   ;push eax
   ;call printInteger
   ;add esp,4

   ; push finalColor
   ;call printInteger
   ;add esp,4
    
    inc iterator
    mov eax, iterator
    cmp eax, [particleAmount]
    je messloop
    jmp initParticles
    

   

messloop:
    
    ;call ExitProcess
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
    
    ; push  RDW_ERASE | RDW_INTERNALPAINT
    ; push  0
    ; push  0
    ; push  dword[WindowHandle]
    ; call RedrawWindow
    

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
    jne otherProcedures
    push 0 
    call PostQuitMessage
    
     mov esp, ebp
     pop ebp
     ret

resize:
    push windowRect
    push dword[WindowHandle]
    call GetClientRect
    jmp defaultProc

;using eax as handle to brush
;using ebx as handle to device context
;0 - radius
;1 - position x
;2 - position y
;2 - device context
;4 - brush
drawQuad:
    push ebp
    mov ebp,esp
    ; right
    ; bottom
    ; left
    ; top
    %define radius dword[ebp+24]
    %define x dword[ebp+20]
    %define y dword[ebp+16]
    %define deviceContext dword[ebp+12]
    %define brush dword[ebp+8]
    mov ecx, x
    add ecx,radius
    push ecx 
    mov ecx, y
    add ecx, radius
    push ecx  
    mov ecx, x
    sub ecx, radius
    push ecx  
    mov ecx, y
    sub ecx, radius
    push ecx   

    
    push brush

    lea  edx, [esp+4]
    push edx  
    
    push  deviceContext
    call   [FillRect]
   
    ;push eax
    ;call ExitProcess
   
    mov esp,ebp
    pop ebp
    ret
draw:
    %define iterator dword[esp]
    
    mov iterator, 0 
    mov eax, 0
updateParticles:


    mov ebx, iterator
    imul ebx, particleSize
    %define offset dword[ebx]
    %define index particles+ebx
    %define xPos dword[index]
    %define yPos dword[index+4]
    %define xVel dword[index+8]
    %define yVel dword[index+12]
    %define time dword[index+16]
    %define currentTime dword[index+20]
    ; push xVel
    ; call printFloat
    ; add esp,4
    ; call ExitProcess
    fld currentTime
    fld dword[deltaTime]
    fadd st1
    fstp currentTime

    fild  dword[exeTime]
    fld dword[float_one]
    fadd st1
    fistp  dword[exeTime]
    fstp st0
    ;push currentTime
    ;call printFloat
    ;add esp,4
    ;call printString
   ;push currentTime
   ;call printFloat
   ;add esp,4
   
   fcomp time ; compare STO and y
   fstsw ax ; move C bits into FLAGS
   sahf
   jb particleAlive ; if current <= time 
   jmp particleDead
particleDead:

; push time
; call printFloat
; add esp,4
mov eax, dword[cursorPos+4]
mov xPos, eax
mov eax, dword[cursorPos]
mov yPos, eax
mov currentTime,0
sub esp,12
%define t dword[esp]
%define t1 dword[esp+4]
%define seed dword[esp+8]



 mov ecx,dword[cursorPos]
    add ecx, dword[exeTime] 
    push ecx
    add ecx,  dword[exeTime] 
    push ecx
    call random
    add esp,8
    fstp t
    
    mov ecx,dword[cursorPos+4]
    inc ecx
    add ecx,  dword[exeTime] 
    push ecx
    add ecx,  dword[exeTime] 
    push ecx
    call random
    add esp,8
    
    fstp t1
  
    
    fld dword[maxVel]
    fld t1 
    fmul
    fstp yVel
    fstp st0
    fld dword[maxVel]
    fld t 
    fmul
    fstp xVel
    fstp st0
add esp,12

particleAlive:

    fild xPos
    fld dword[deltaTime]
    fld xVel
    fmul
    fadd
    fistp xPos
    fstp st0
    
    fild yPos
    fld dword[deltaTime]
    fld yVel
    fmul
    fadd
    fistp yPos
    fstp st0
    
    
   push  xPos
   call printInteger
   add esp,4
   push  yPos
   call printInteger
   add esp,4
;    push  currentTime
;    call printFloat
;    add esp,4
;    call printString
;    push  time
;    call printFloat
;    add esp,4
    
  ; push xVel
  ;call printFloat
  ;add esp,4
  ;push xPos
  ;call printInteger
  ;add esp,4
   ;
   
    ;call ExitProcess
    ;call ExitProcess
    inc iterator
    mov eax, iterator 
    cmp eax, [particleAmount]
    je _draw
    jmp updateParticles
_draw:
   ; call ExitProcess
    sub esp,4
    push paintStruct
    push dword[WindowHandle]
    call BeginPaint
    mov ebx,eax
    push  dword[windowBrush] 
    lea dword edx, [paintStruct+8]
    push edx  
    push  eax
    call   [FillRect]
    
    sub esp,4
    push dword[cursorPos+4]
    push dword[cursorPos]
    call random
    fmul dword[floatNumber]
    fst dword[esp]
    
   
    
   ; push    0xffffff
    sub esp,12
    %define iterator dword[esp]
    %define brush dword[esp+4]
    %define deviceContext dword[esp+8]
    mov iterator,0
    mov deviceContext,ebx
renderLoop:
    mov ebx, iterator
    imul ebx, particleSize
    %define offset dword[ebx]
    %define index particles+ebx
    %define xPos dword[index]
    %define yPos dword[index+4]
    %define xVel dword[index+8]
    %define yVel dword[index+12]
    %define time dword[index+16]
    %define currentTime dword[index+20]
    %define startColor dword[index+24]
    %define finalColor dword[index+28]
    sub esp,4

    fld currentTime 
    fld time
    fdiv 
    fstp dword[esp]

    ;push time
    ;call printFloat 
    ;add esp,4
    ;push currentTime
    ;call printFloat 
    ;add esp,4
    ;push dword[esp]
    ;call printFloat
    ;add esp,4
    ;call printString
    
    push dword[esp]
    push startColor
    push finalColor
    call lerp
    add esp,12
    add esp,4
    
    
    push eax
    call    CreateSolidBrush
    mov edx,eax

  
   
   
  ;push  xPos
  ;call printInteger
  ;add esp,4
  ;push  yPos
  ;call printInteger
  ;add esp,4
    push 5
    push xPos
    push yPos
    push dword[esp+20] ; device context
    push edx ; brush
    call drawQuad
    add esp, 20
   
    push edx
    call DeleteObject

    ;push iterator
    ;call printInteger
    
    
    inc iterator
   
    mov eax, iterator
    cmp eax, [particleAmount]
    je endRender
    jmp renderLoop
endRender:
    lea dword edx, [paintStruct]
    push edx
    push dword[WindowHandle]
    call EndPaint
   ; push 22 
   ; call ExitProcess

    jmp defaultProc

timer:
    push 0
    push 20
    push 1
    push dword[WindowHandle]
    call SetTimer
    ret
invalidate:
    push 0
    push 0
    push dword[WindowHandle]
    call InvalidateRect
    jmp defaultProc
otherProcedures:
    cmp dword[ebp+12], WM_SIZE
    je resize
    cmp dword[ebp+12], WM_TIMER
    je invalidate
    cmp dword[ebp+12], WM_PAINT
    je draw
     

defaultProc:
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
    floatNumber dd 2.302
    intNumber dd 42
    particleAmount dd 7
    maxVel dd 20.0
    maxTime dd 5.0
    minVel dd 5
    deltaTime dd 0.1
    particleSize equ 32
    float_one dd 1.0
    float_two dd 2.0
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
    windowRect resb 16
    windowBrush resb 4
    paintStruct resb 64
    exeTime resb 4
    
    particles resb (particleSize *particleAmount)