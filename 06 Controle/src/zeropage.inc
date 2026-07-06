player_x:           .res 1    ; Posição X do personagem na tela
player_y:           .res 1    ; Posição Y do personagem na tela

controller1:        .res 1    ; Estado dos botões do controle 1

frame_ready:        .res 1    ; Indica que a NMI terminou e há um novo frame

anim_counter:       .res 1    ; Contador usado para controlar a velocidade da animação
anim_frame:         .res 1    ; Frame atual da animação dos pés

player_moving:      .res 1    ; 0 = parado, 1 = em movimento
player_direction:   .res 1    ; 0 = direita, 1 = esquerda