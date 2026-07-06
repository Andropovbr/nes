; ------------------------------------------------------------
; ATUALIZA JOGADOR
; ------------------------------------------------------------

update_player:

    LDA #$00                    ; Começa assumindo que o jogador está parado
    STA player_moving           ; player_moving = 0

check_right:

    LDA controller1             ; Carrega os botões pressionados
    AND #%00000001              ; Testa o bit 0: Direita
    BEQ check_left              ; Se Direita não foi pressionado, testa Esquerda

    INC player_x                ; Move o jogador 1 pixel para a direita

    LDA #$01                    ; Marca que o jogador está se movendo
    STA player_moving           ; player_moving = 1
    
    LDA #$00                    ; Direção 0 = direita
    STA player_direction        ; Vira o personagem para a direita

check_left:

    LDA controller1             ; Carrega os botões pressionados
    AND #%00000010              ; Testa o bit 1: Esquerda
    BEQ check_down              ; Se Esquerda não foi pressionado, testa Baixo

    DEC player_x                ; Move o jogador 1 pixel para a esquerda

    LDA #$01                    ; Marca que o jogador está se movendo
    STA player_moving           ; player_moving = 1

    STA player_direction        ; Direção 1 = esquerda

check_down:

    LDA controller1             ; Carrega os botões pressionados
    AND #%00000100              ; Testa o bit 2: Baixo
    BEQ check_up                ; Se Baixo não foi pressionado, testa Cima

    INC player_y                ; Move o jogador 1 pixel para baixo

    LDA #$01                    ; Marca que o jogador está se movendo
    STA player_moving           ; player_moving = 1

check_up:

    LDA controller1             ; Carrega os botões pressionados
    AND #%00001000              ; Testa o bit 3: Cima
    BEQ update_player_done      ; Se Cima não foi pressionado, termina

    DEC player_y                ; Move o jogador 1 pixel para cima

    LDA #$01                    ; Marca que o jogador está se movendo
    STA player_moving           ; player_moving = 1

update_player_done:

    RTS                         ; Retorna ao loop principal

; ------------------------------------------------------------
; ATUALIZA ANIMAÇÃO DO JOGADOR
; ------------------------------------------------------------
;
; A animação só avança quando o jogador está se movendo.
; Se ele estiver parado, a animação volta para o frame inicial.
; ------------------------------------------------------------

update_player_animation:

    LDA player_moving           ; Verifica se o jogador se moveu neste frame
    BNE player_is_moving        ; Se player_moving != 0, atualiza animação

player_is_stopped:

    LDA #$00                    ; Jogador parado usa o frame inicial
    STA anim_counter            ; Zera o contador da animação
    STA anim_frame              ; Zera o frame atual da animação

    RTS                         ; Retorna sem avançar animação

player_is_moving:

    INC anim_counter            ; Incrementa contador da animação

    LDA anim_counter            ; Carrega o valor atual do contador
    CMP #$08                    ; A animação só avança a cada 8 frames
    BCC animation_done          ; Se ainda não chegou em 8, termina

    LDA #$00                    ; Reinicia o contador
    STA anim_counter            ; anim_counter = 0

    INC anim_frame              ; Avança para o próximo frame da animação

    LDA anim_frame              ; Carrega o frame atual
    CMP #$02                    ; Temos 2 frames: 0 e 1
    BCC animation_done          ; Se ainda for menor que 2, mantém

    LDA #$00                    ; Se passou do último frame, volta ao frame 0
    STA anim_frame              ; anim_frame = 0

animation_done:

    RTS                         ; Retorna ao loop principal