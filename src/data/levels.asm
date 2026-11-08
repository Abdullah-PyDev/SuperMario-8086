original_map:

; Row 0 - HUD
times 60 db 0

; Row 1 - Sky
times 60 db 0

; Row 2 - Upper flagpole
times 56 db 0
db 12
times 3 db 0

; Row 3 - Coin and flagpole
times 30 db 0
db 11
times 25 db 0
db 12
times 3 db 0

; Row 4 - Three coins and flagpole
times 10 db 0
db 11
times 3 db 0
db 11
times 3 db 0
db 11
times 37 db 0
db 12
times 3 db 0

; Row 5 - Brick groups and flagpole
times 10 db 0
times 3 db 2
times 12 db 0
times 3 db 2
times 28 db 0
db 12
times 3 db 0

; Row 6 - Question blocks, stair and flagpole
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
times 13 db 0
db 10
times 6 db 0
db 12
times 3 db 0

; Row 7 - Pipe and stairs
times 25 db 0
db 6, 7
times 21 db 0
db 10, 10
times 6 db 0
db 12
times 3 db 0

; Row 8 - Pipes, coins and stairs
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
times 3 db 0
times 3 db 10
times 6 db 0
db 12
times 3 db 0

; Row 9 - Pipe bodies, stairs and flagpole base
times 8 db 0
db 8, 9
times 15 db 0
db 8, 9
times 19 db 0
times 4 db 10
times 6 db 0
db 10
times 3 db 0

; Row 10 - Ground and pits
times 15 db 1
times 3 db 0
times 22 db 1
times 3 db 0
times 17 db 1

; Row 11 - Ground and pits
times 15 db 1
times 3 db 0
times 22 db 1
times 3 db 0
times 17 db 1

working_map:
times MAP_WIDTH * MAP_HEIGHT db 0