player_x:           .res 1    ; Posição X do personagem na tela
player_y:           .res 1    ; Posição Y do personagem na tela

controller1:        .res 1    ; Estado dos botões do controle 1

frame_ready:        .res 1    ; Indica que a NMI terminou e há um novo frame

anim_counter:       .res 1    ; Contador usado para controlar a velocidade da animação
anim_frame:         .res 1    ; Frame atual da animação dos pés

player_moving:      .res 1    ; 0 = parado, 1 = em movimento
player_direction:   .res 1    ; 0 = direita, 1 = esquerda

collision:          .res 1    ; 0 = sem colisão, 1 = houve colisão

; ------------------------------------------------------------
; INIMIGO
; ------------------------------------------------------------

enemy_x:              .res 1    ; Posição X do inimigo
enemy_y:              .res 1    ; Posição Y do inimigo

enemy_direction:      .res 1    ; 0 = direita, 1 = esquerda
enemy_moving:         .res 1    ; 0 = parado, 1 = em movimento

enemy_move_counter:   .res 1    ; Controla a velocidade da perseguição

enemy_anim_counter:   .res 1    ; Controla a velocidade da animação
enemy_anim_frame:     .res 1    ; Frame atual da animação dos pés

; ------------------------------------------------------------
; ESTADOS DOS PERSONAGENS E DO JOGO
; ------------------------------------------------------------

player_alive:           .res 1    ; 0 = jogador morto, 1 = jogador vivo
enemy_alive:            .res 1    ; 0 = inimigo morto, 1 = inimigo vivo

game_over:              .res 1    ; 0 = jogo em andamento, 1 = fim de jogo


; ------------------------------------------------------------
; CONTROLE — BOTÕES RECÉM-PRESSIONADOS
; ------------------------------------------------------------
;
; controller1 guarda os botões atualmente pressionados.
;
; previous_controller1 guarda os botões do frame anterior.
;
; controller_pressed possui somente os botões que passaram
; de soltos para pressionados no frame atual.
;
; Isso evita repetir um disparo ou reinício enquanto o botão
; continua sendo segurado.
;
; ------------------------------------------------------------

previous_controller1:   .res 1
controller_pressed:     .res 1


; ------------------------------------------------------------
; PROJÉTIL
; ------------------------------------------------------------

projectile_active:      .res 1    ; 0 = projétil inativo, 1 = ativo

projectile_x:           .res 1    ; Posição X do projétil
projectile_y:           .res 1    ; Posição Y do projétil

projectile_direction:   .res 1    ; 0 = direita, 1 = esquerda