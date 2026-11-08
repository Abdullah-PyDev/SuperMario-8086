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
