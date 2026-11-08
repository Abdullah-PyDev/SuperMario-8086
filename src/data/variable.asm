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