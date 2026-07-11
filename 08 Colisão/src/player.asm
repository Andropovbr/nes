; ------------------------------------------------------------
; LIMITES DO JOGADOR
; ------------------------------------------------------------

PLAYER_MIN_X = $07
PLAYER_MAX_X = $E8       ; 256 - 24 pixels

PLAYER_MIN_Y = $00
PLAYER_MAX_Y = $D8       ; 240 - 24 pixels


; ------------------------------------------------------------
; ATUALIZA JOGADOR
; ------------------------------------------------------------

update_player:

    LDA #$00
    STA player_moving           ; Começa assumindo que não houve movimento


; ------------------------------------------------------------
; MOVIMENTO PARA A DIREITA
; ------------------------------------------------------------

check_right:

    LDA controller1
    AND #%00000001
    BEQ check_left

    ; Mesmo bloqueado, o personagem passa a olhar para a direita.

    LDA #$00
    STA player_direction

    ; Verifica o limite direito da tela.

    LDA player_x
    CMP #PLAYER_MAX_X
    BCS check_left

    ; Tenta mover um pixel.

    INC player_x

    ; Verifica se a nova posição encosta na cerca.

    JSR check_fence_collision

    LDA collision
    BNE undo_move_right

    ; Movimento aceito.

    LDA #$01
    STA player_moving

    JMP check_left


undo_move_right:

    DEC player_x                ; Desfaz o movimento

    JMP check_left


; ------------------------------------------------------------
; MOVIMENTO PARA A ESQUERDA
; ------------------------------------------------------------

check_left:

    LDA controller1
    AND #%00000010
    BEQ check_down

    ; Mesmo bloqueado, olha para a esquerda.

    LDA #$01
    STA player_direction

    ; Verifica o limite esquerdo da tela.

    LDA player_x
    CMP #PLAYER_MIN_X
    BEQ check_down

    ; Tenta mover um pixel.

    DEC player_x

    ; Verifica a nova posição.

    JSR check_fence_collision

    LDA collision
    BNE undo_move_left

    ; Movimento aceito.

    LDA #$01
    STA player_moving

    JMP check_down


undo_move_left:

    INC player_x                ; Desfaz o movimento

    JMP check_down


; ------------------------------------------------------------
; MOVIMENTO PARA BAIXO
; ------------------------------------------------------------

check_down:

    LDA controller1
    AND #%00000100
    BEQ check_up

    ; Verifica o limite inferior da tela.

    LDA player_y
    CMP #PLAYER_MAX_Y
    BCS check_up

    ; Tenta mover um pixel.

    INC player_y

    ; Verifica a nova posição.

    JSR check_fence_collision

    LDA collision
    BNE undo_move_down

    ; Movimento aceito.

    LDA #$01
    STA player_moving

    JMP check_up


undo_move_down:

    DEC player_y                ; Desfaz o movimento

    JMP check_up


; ------------------------------------------------------------
; MOVIMENTO PARA CIMA
; ------------------------------------------------------------

check_up:

    LDA controller1
    AND #%00001000
    BEQ update_player_done

    ; Verifica o limite superior da tela.

    LDA player_y
    CMP #PLAYER_MIN_Y
    BEQ update_player_done

    ; Tenta mover um pixel.

    DEC player_y

    ; Verifica a nova posição.

    JSR check_fence_collision

    LDA collision
    BNE undo_move_up

    ; Movimento aceito.

    LDA #$01
    STA player_moving

    JMP update_player_done


undo_move_up:

    INC player_y                 ; Desfaz o movimento


update_player_done:

    RTS

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