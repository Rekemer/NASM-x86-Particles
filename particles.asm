

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
extern GetDC 
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

section .text
global  _main

_main:

    push 0
    call [GetModuleHandleA]
    mov [hInstance], eax

   
    
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
    push    0xc7723e
    call    CreateSolidBrush
    mov dword[windowBrush],eax




    push windowRect
    push dword[WindowHandle]
    call GetClientRect


    call timer
    

    mov esp,ebp
   
  
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
    
    inc iterator
    mov eax, iterator
    cmp eax, [particleAmount]
    je messloop
    jmp initParticles
    
messloop:
    
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
   
   
    mov esp,ebp
    pop ebp
    ret
draw:
    mov esp,ebp
    %define iterator dword[esp]
    
    mov iterator, 0 
    mov eax, 0
updateParticles:


    mov ebx, iterator
    imul ebx, particleSize
    
    fld currentTime
    fld dword[deltaTime]
    fadd st1
    fstp currentTime

    fild  dword[exeTime]
    fld dword[float_one]
    fadd st1
    fistp  dword[exeTime]
    fstp st0
   
    fcomp time ; compare STO and y
    fstsw ax ; move C bits into FLAGS
    sahf
    jb particleAlive ; if current <= time 
    jmp particleDead
particleDead:
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
    
    
    inc iterator
    mov eax, iterator 
    cmp eax, [particleAmount]
    je _draw
    jmp updateParticles
_draw:
   mov esp,ebp
    push paintStruct
    push dword[WindowHandle]
    call BeginPaint
    mov ebx,eax
    push  dword[windowBrush] 
    lea dword edx, [paintStruct+8]
    push edx  
    push  eax
    call   [FillRect]
    
    
   
    
    sub esp,12
    %define iterator dword[esp]
    %define brush dword[esp+4]
    %define deviceContext dword[esp+8]
    mov iterator,0
    mov deviceContext,ebx
renderLoop:
    mov ebx, iterator
    imul ebx, particleSize
    
    
    
    

    sub esp,4

    fld currentTime 
    fld time 
    fdiv 
    fmul dword[float_two]
    fsub dword[float_one]

    fstp dword[esp]
    fstp st0
    push dword[esp]
    call randomColor
    add esp,4

    
    push eax
    call    CreateSolidBrush
    mov dword[windowBrush1],eax
    add esp,4
    

  
   
   
    push 5
    push xPos
    push yPos
    push dword[esp+20] ; device context
    push dword[windowBrush1] ; brush
    mov eax,edx
    call drawQuad
    add esp, 20
   
    push dword[windowBrush1]
    call DeleteObject
    
    inc iterator
   
    mov eax, iterator
    cmp eax, [particleAmount]
    je endRender
    jmp renderLoop
endRender:
    mov esp,ebp
    lea dword edx, [paintStruct]
    push edx
    push dword[WindowHandle]
    call EndPaint

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
    WindowName  db "Particles", 0
    ClassName   db "Window", 0
    string db "Hello, Ilia!",0
    newLine db 13,10,0
    ;equ The equ directive can be used to define a symbol. Symbols are named
    ;constants that can be used in the assembly program
    WINDOW_WIDTH equ 640 
    WINDOW_HEIGHT equ 480
    particleAmount dd 100
    maxVel dd 20.0
    maxTime dd 5.0
    minVel dd 5
    deltaTime dd 0.1
    particleSize equ 32
    float_one dd 1.0
    float_two dd 2.0
section .bss
    hInstance resb 4
    outHandle resb 4
    MessageBuffer resb 28
    OurWindowclass resb 48
    WindowHandle resb 4
    DeviceContext resb 4
    cursorPos resb 8
    windowRect resb 16
    windowBrush resb 4
    paintStruct resb 64
    exeTime resb 4
    windowBrush1 resb 4 
    particles resb (particleSize *particleAmount)