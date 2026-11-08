org 100h

jmp start

%include "src/const.asm"
%include "src/data/variable.asm"
%include "src/data/levels.asm"
%include "src/modules/drawing.asm"
%include "src/modules/map.asm"

; PROGRAM ENTRY

start:
    ; Initialize DS with the program's code segment
    push cs
    pop ds

    ; Switch display to VGA Mode 13h
    ; Resolution: 320 x 200 pixels
    ; Colour depth: 256 colours
    mov ax, 0013h
    int 10h
    
    ; Set ES to VGA video memory segment
    ; All pixel drawing operations will use this segment
    mov ax, 0A000h
    mov es, ax
    
    ; Restore original level into working map
    call ResetMap
    push word 0
    call DrawMap

    ; Wait for a keyboard key press
    ; This keeps the graphics screen visible
    mov ah, 00h
    int 16h

    ; Restore the normal 80 x 25 text display
    mov ax, 0003h
    int 10h

    ; Terminate the program and return to DOS
    mov ax, 4C00h
    int 21h

