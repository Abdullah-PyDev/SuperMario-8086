
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
COLOR_COIN          equ 14
COLOR_MUSHROOM      equ 10

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
; Level maps

; Original level map (60 columns x 12 rows)
original_map:

; Row 0 - HUD
times 60 db 0

; Row 1 - Sky
times 60 db 0

; Row 2 - Sky
times 60 db 0

; Row 3 - One high coin
times 30 db 0
db 11
times 29 db 0

; Row 4 - Three separated free coins
times 10 db 0
db 11
times 3 db 0
db 11
times 3 db 0
db 11
times 41 db 0

; Row 5 - Two groups of bricks
times 10 db 0
times 3 db 2
times 12 db 0
times 3 db 2
times 32 db 0

; Row 6 - Two mushroom/coin question blocks
times 10 db 0
db 4
times 4 db 0
db 3
times 4 db 0
db 4
times 9 db 0
db 3
times 4 db 0
db 3
times 24 db 0

; Row 7 - Top of the 3-tile-high pipe
times 25 db 0
db 6, 7
times 33 db 0

; Row 8 - Pipe sections and six separated coins
times 8 db 0
db 6, 7
times 4 db 0
db 11
db 0
db 11
db 0
db 11
times 6 db 0
db 8, 9
times 12 db 0
db 11
db 0
db 11
db 0
db 11
times 16 db 0

; Row 9 - Bodies of both pipes
times 8 db 0
db 8, 9
times 15 db 0
db 8, 9
times 33 db 0

; Ground with two 3-tile pits
times 15 db 1
times 3 db 0
times 22 db 1
times 3 db 0
times 17 db 1

; Ground with two 3-tile pits
times 15 db 1
times 3 db 0
times 22 db 1
times 3 db 0
times 17 db 1


; Working copy of the level
working_map:
times MAP_WIDTH * MAP_HEIGHT db 0

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



; --------------------------------
; DrawMap
; Draws 20 columns from a selected
; starting column of working_map.
;
; Parameter:
; [BP+4] = Starting map column
; Valid range: 0 to 40
; --------------------------------

DrawMap:
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    ; Begin at the requested map column
    mov si, [bp+4]
    
    xor bx, bx              ; Current row = 0

draw_row:
    mov dx, bx
    shl dx, 4               ; Screen Y = row * 16

    xor di, di              ; Screen column = 0
    mov cx, 20              ; Draw 20 columns

draw_column:
    push dx

    ; Get tile code
    xor ax, ax
    mov al, [working_map + si]
    push ax

    ; Screen Y
    push dx

    ; Screen X = column * 16
    mov ax, di
    shl ax, 4
    push ax

    call DrawTile

    pop dx

    inc si
    inc di

    loop draw_column

    ; Skip the remaining 40 map columns
    add si, 40

    inc bx
    cmp bx, 12
    jne draw_row

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp

    ret 2
; ResetMap
; Copies original_map into working_map
; --------------------------------

ResetMap:
    push ax
    push cx
    push si
    push di
    push es

    ; Temporarily make ES point to our data segment
    push ds
    pop es

    cld

    mov si, original_map
    mov di, working_map
    mov cx, MAP_WIDTH * MAP_HEIGHT

    ; Copy all 720 bytes
    rep movsb

    ; Restore original ES (video memory segment)
    pop es

    pop di
    pop si
    pop cx
    pop ax

    ret


; --------------------------------
; GetTile
; Converts pixel coordinates into
; a map index and returns its tile code.
;
; Parameters:
; [BP+4] = Pixel X
; [BP+6] = Pixel Y
;
; Returns:
; AL = Tile code
; --------------------------------

GetTile:
    push bp
    mov bp, sp

    push bx
    push cx
    push dx
    push si

    ; Calculate column = X / 16
    mov bx, [bp+4]
    mov cl, 4
    shr bx, cl

    ; Calculate row = Y / 16
    mov ax, [bp+6]
    shr ax, cl

    ; Calculate index = row * 60 + column
    mov cx, 60
    mul cx
    add ax, bx

    ; Read tile code
    mov si, working_map
    add si, ax
    mov al, [si]

    pop si
    pop dx
    pop cx
    pop bx
    pop bp

    ret 4
; --------------------------------
; DrawTile
; Draws one 16x16 tile
;
; Parameters:
; [BP+4] = Screen X
; [BP+6] = Screen Y
; [BP+8] = Tile code
; --------------------------------
DrawTile:
    push bp
    mov bp, sp

    push ax

    ; Select colour according to tile code
    mov ax, COLOR_SKY

    cmp byte [bp+8], 0
    je tile_ready

    cmp byte [bp+8], 1
    je tile_ground

    cmp byte [bp+8], 2
    je tile_brick

    cmp byte [bp+8], 3
    je tile_coin_block

    cmp byte [bp+8], 4
    je tile_mushroom_block

    cmp byte [bp+8], 5
    je tile_brick

    cmp byte [bp+8], 6
    je tile_pipe

    cmp byte [bp+8], 7
    je tile_pipe

    cmp byte [bp+8], 8
    je tile_pipe

    cmp byte [bp+8], 9
    je tile_pipe

    cmp byte [bp+8], 10
    je tile_brick

    cmp byte [bp+8], 11
    je tile_coin

    cmp byte [bp+8], 12
    je tile_flag

    jmp tile_ready

tile_ground:
    mov ax, COLOR_GROUND
    jmp tile_ready

tile_brick:
    mov ax, COLOR_BRICK
    jmp tile_ready

tile_pipe:
    mov ax, COLOR_PIPE
    jmp tile_ready

tile_coin_block:
    mov ax, COLOR_COIN
    jmp tile_ready

tile_mushroom_block:
    mov ax, COLOR_MUSHROOM
    jmp tile_ready

tile_coin:
    mov ax, COLOR_COIN
    jmp tile_ready
tile_flag:
    mov ax, COLOR_HERO


tile_ready:
    ; FillRect parameters: colour, height, width, Y, X
    push ax
    push word TILE_SIZE
    push word TILE_SIZE
    push word [bp+6]
    push word [bp+4]
    call FillRect

    pop ax
    pop bp
    ret 6
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