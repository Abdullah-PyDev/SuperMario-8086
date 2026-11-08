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
