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

    LDA #$00                    ; Começa assumindo que o jogador está parado
    STA player_moving           ; player_moving = 0


check_right:

    LDA controller1             ; Carrega os botões pressionados
    AND #%00000001              ; Testa o bit 0: Direita
    BEQ check_left              ; Se não pressionou Direita, testa Esquerda

    LDA player_x                ; Carrega a posição horizontal
    CMP #PLAYER_MAX_X           ; Compara com o limite direito
    BCS check_left              ; Se player_x >= limite, não movimenta

    INC player_x                ; Move 1 pixel para a direita

    LDA #$01                    ; Marca que o jogador realmente se moveu
    STA player_moving

    LDA #$00                    ; Direção 0 = direita
    STA player_direction


check_left:

    LDA controller1             ; Carrega os botões pressionados
    AND #%00000010              ; Testa o bit 1: Esquerda
    BEQ check_down              ; Se não pressionou Esquerda, testa Baixo

    LDA player_x                ; Carrega a posição horizontal
    CMP #PLAYER_MIN_X           ; Compara com o limite esquerdo
    BEQ check_down              ; Se já está no limite, não movimenta

    DEC player_x                ; Move 1 pixel para a esquerda

    LDA #$01                    ; Marca que o jogador realmente se moveu
    STA player_moving
    STA player_direction        ; Direção 1 = esquerda


check_down:

    LDA controller1             ; Carrega os botões pressionados
    AND #%00000100              ; Testa o bit 2: Baixo
    BEQ check_up                ; Se não pressionou Baixo, testa Cima

    LDA player_y                ; Carrega a posição vertical
    CMP #PLAYER_MAX_Y           ; Compara com o limite inferior
    BCS check_up                ; Se player_y >= limite, não movimenta

    INC player_y                ; Move 1 pixel para baixo

    LDA #$01                    ; Marca que o jogador realmente se moveu
    STA player_moving


check_up:

    LDA controller1             ; Carrega os botões pressionados
    AND #%00001000              ; Testa o bit 3: Cima
    BEQ update_player_done      ; Se não pressionou Cima, termina

    LDA player_y                ; Carrega a posição vertical
    CMP #PLAYER_MIN_Y           ; Compara com o limite superior
    BEQ update_player_done      ; Se já está no limite, não movimenta

    DEC player_y                ; Move 1 pixel para cima

    LDA #$01                    ; Marca que o jogador realmente se moveu
    STA player_moving


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