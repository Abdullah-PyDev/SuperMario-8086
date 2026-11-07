
@echo off

echo Building Super Mario...

tools\nasm.exe -f bin src\mario.asm -o build\MARIO.COM

if errorlevel 1 (
    echo Build failed!
    pause
    exit /b 1
)

echo Build successful!
echo Output: build\MARIO.COM

pause
