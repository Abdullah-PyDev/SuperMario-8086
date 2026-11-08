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


; ============================================
; DrawSprite
;
; Purpose:
; Draws a sprite at the given screen position.
;
; Inputs (stack):
;   x       - horizontal position
;   y       - vertical position
;   address - sprite data address
;   flags   - drawing options
;
; Output:
;   Sprite drawn to VGA memory.
;
; ============================================
; ============================================
; Procedure: DrawSprite
;
; Purpose:
; Draws a 16x16 sprite at the given position.
;
; Stack parameters:
;   [bp+4]  = X coordinate
;   [bp+6]  = Y coordinate
;   [bp+8]  = Sprite address
;   [bp+10] = Flags (reserved for now)
;
; Transparent pixels are skipped.
; Pixels outside the screen are skipped.
;
; ============================================

DrawSprite:

    push bp
    mov bp, sp

    ; Preserve registers
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; SI points to the sprite data
    mov si, [bp+8]

    ; Starting Y coordinate
    mov dx, [bp+6]

    ; Start at row zero
    xor di, di

.row_loop:

    ; Reset X for every new row
    mov bx, [bp+4]

    ; Start at column zero
    xor cx, cx

.column_loop:

    ; Read one pixel from sprite data
    mov al, [si]
    inc si

    ; Skip transparent pixels
    cmp al, COLOR_TRANSPARENT
    je .next_pixel

    ; Check left boundary
    cmp bx, 0
    jl .next_pixel

    ; Check right boundary
    cmp bx, SCREEN_WIDTH
    jge .next_pixel

    ; Check top boundary
    cmp dx, 0
    jl .next_pixel

    ; Check bottom boundary
    cmp dx, SCREEN_HEIGHT
    jge .next_pixel

    ; Draw the pixel using PutPixel
    xor ah, ah

    push ax
    push dx
    push bx
    call PutPixel

.next_pixel:

    ; Move to next column
    inc bx
    inc cx

    cmp cx, SPRITE_WIDTH
    jb .column_loop

    ; Move to next row
    inc dx
    inc di

    cmp di, SPRITE_HEIGHT_SMALL
    jb .row_loop

.done:

    ; Restore registers
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp

    ; Remove four word parameters
    ret 8