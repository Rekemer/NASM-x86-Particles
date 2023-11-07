nasm -f win32  hello.asm
start GoLink.exe /console /entry _main  hello.obj kernel32.dll user32.dll Gdi32.dll 