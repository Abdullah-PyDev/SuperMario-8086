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