org 100h

jmp start

%include "src/const.asm"
%include "src/data/variable.asm"
%include "src/data/levels.asm"
%include "src/modules/drawing.asm"
%include "src/modules/map.asm"
%include "src/data/sprites.asm"

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

    ; Mario 1
    push word 0
    push word small_mario_stand
    push word 40
    push word 240
    call DrawSprite

    ; Mario 2
    push word 0
    push word small_mario_stand
    push word 80
    push word 140
    call DrawSprite

    ; Mario 3
    push word 0
    push word small_mario_stand
    push word 120       ; Y
    push word 60        ; X
    call DrawSprite
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

