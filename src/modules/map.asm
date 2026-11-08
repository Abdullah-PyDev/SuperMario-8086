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