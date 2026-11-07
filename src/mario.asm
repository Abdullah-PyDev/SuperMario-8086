
org 100h

jmp start


; Display
SCREEN_WIDTH        equ 320
SCREEN_HEIGHT       equ 200
SCREEN_SIZE         equ 64000
VIDEO_SEG           equ 0A000h

; Tiles
TILE_SIZE           equ 16
MAP_WIDTH           equ 60
MAP_HEIGHT          equ 12

; VGA colours (our selected palette indices)
COLOR_TRANSPARENT   equ 0
COLOR_SKY           equ 9
COLOR_GROUND        equ 6
COLOR_BRICK         equ 4
COLOR_PIPE          equ 2
COLOR_HERO          equ 12
COLOR_ENEMY         equ 4
COLOR_TEXT          equ 15
COLOR_HUD           equ 14

; Keyboard scan codes (Appendix A.3)
KEY_ESC             equ 01h
KEY_ENTER           equ 1Ch
KEY_P                equ 19h
KEY_SPACE           equ 39h
KEY_SHIFT           equ 2Ah
KEY_UP              equ 48h
KEY_DOWN            equ 50h
KEY_LEFT            equ 4Bh
KEY_RIGHT           equ 4Dh

; Game limits (Appendix A.4)
STARTING_LIVES      equ 3
MAX_LIVES           equ 99
MAX_HP              equ 2
STARTING_TIME       equ 300
MAX_SCORE           equ 999999
MAX_ENEMIES         equ 8

; Game states (internal numeric assignments)
STATE_TITLE         equ 0
STATE_PLAYING       equ 1
STATE_PAUSED        equ 2
STATE_DYING         equ 3
STATE_LIFE_LOST     equ 4
STATE_WIN           equ 5
STATE_LEVEL_COMPLETE equ 6
STATE_GAME_OVER     equ 7
STATE_EXIT          equ 8


; VARIABLES

; Game state and camera
game_state          db STATE_TITLE
camera_x            dw 0

; Hero
hero_x              dw 0
hero_y              dw 0
hero_vx             dw 0
hero_vy             dw 0

hero_form           db 0
hero_hp             db 1
hero_on_ground      db 0
hero_invuln_timer   dw 0
hero_stomp_chain    db 0

; Keyboard
key_state           times 128 db 0

; Timer
tick_count          dw 0

; Enemies
enemy_count         db 0

; Score and statistics
score_low           dw 0
score_high          dw 0
coins               dw 0
lives               db STARTING_LIVES
game_time           dw STARTING_TIME

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

    ; Draw a hero-coloured pixel at screen centre
    push word COLOR_HERO  ; Colour parameter
    push word 1000         ; Y coordinate
    push word 160         ; X coordinate
    call PutPixel
    
    push word COLOR_BRICK
    push word 30
    push word 100
    push word 40
    push word 50
    call FillRect

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


; ==========================================
; Procedure: PutPixel
;
; Purpose:
; Draws a single pixel at a specified
; screen coordinate using a given colour.
;
; Input parameters (stack):
; x       - Horizontal screen coordinate
; y       - Vertical screen coordinate
; colour  - VGA colour index
;
; Output:
; One pixel is drawn on the screen.

PutPixel:
    ; Save the base pointer and establish
    ; a reference point for stack parameters
    push bp
    mov bp, sp

    ; Preserve registers used by this procedure
    push ax
    push bx
    push dx
    ;We must check if (x,y) if x and y are valid screen coordinate
    ; Check X boundary
    cmp word [bp+4], SCREEN_WIDTH
    jae .done

    ; Check Y boundary
    cmp word [bp+6], SCREEN_HEIGHT
    jae .done


    ; Get the Y coordinate from the stack
    mov bx, [bp+6]

    ; Make a copy of Y for the second calculation
    mov dx, bx

    ; Calculate Y * 256
    shl bx, 8

    ; Calculate Y * 64
    shl dx, 6

    ; Add both results to calculate Y * 320
    add bx, dx

    ; Add X to get the final video memory offset
    ; Offset = (Y * 320) + X
    add bx, [bp+4]

    ; Get the colour parameter
    mov ax, [bp+8]

    ; Write the colour index into video memory
    ; ES points to segment A000h
    mov [es:bx], al

.done:
    ; Restore the original register values
    pop dx
    pop bx
    pop ax
    pop bp

    ; Remove the three word parameters
    ; from the stack and return
    ret 6


FillRect:
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; Ignore rectangles with zero width or height
    cmp word [bp+8], 0
    je .done

    cmp word [bp+10], 0
    je .done

    ; Start at the given Y coordinate
    mov di, [bp+6]

    ; Number of rows
    mov dx, [bp+10]

.y_loop:
    ; Start at the given X coordinate
    mov si, [bp+4]

    ; Number of pixels in this row
    mov cx, [bp+8]

.x_loop:
    ; Call PutPixel(x, y, colour)
    push word [bp+12]
    push di
    push si
    call PutPixel

    inc si
    dec cx
    jnz .x_loop

    ; Move to next row
    inc di
    dec dx
    jnz .y_loop

.done:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 10