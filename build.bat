nasm -f win32  particles.asm
start GoLink.exe /console /entry _main  particles.obj kernel32.dll user32.dll Gdi32.dll support.dll