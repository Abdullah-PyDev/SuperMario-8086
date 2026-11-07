
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

    ; Set data segment
    push cs
    pop ds

    ; Set extra segment
    push cs
    pop es

    ; Return to text mode
    mov ax, 0003h
    int 10h

    ; Exit to DOS
    mov ax, 4C00h
    int 21h
