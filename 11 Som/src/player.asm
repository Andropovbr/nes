PLAYER_MIN_X = $07                               ; Configura a constante PLAYER_MIN_X
PLAYER_MAX_X = $E8                               ; Configura a constante PLAYER_MAX_X
PLAYER_MIN_Y = $00                               ; Configura a constante PLAYER_MIN_Y
PLAYER_MAX_Y = $D8                               ; Configura a constante PLAYER_MAX_Y
update_player:                                   ; Define o ponto de entrada update_player
    LDA player_alive                             ; Carrega o valor no acumulador
    BNE update_living_player                     ; Desvia quando o resultado anterior nao e zero
    LDA #$00                                     ; Carrega o valor no acumulador
    STA player_moving                            ; Armazena o acumulador no destino
    RTS                                          ; Retorna para a rotina chamadora
update_living_player:                            ; Define o ponto de entrada update_living_player
    LDA #$00                                     ; Carrega o valor no acumulador
    STA player_moving                            ; Armazena o acumulador no destino
check_right:                                     ; Define o ponto de entrada check_right
    LDA controller1                              ; Carrega o valor no acumulador
    AND #%00000001                               ; Aplica uma mascara de bits ao acumulador
    BEQ check_left                               ; Desvia quando o resultado anterior e zero
    LDA #$00                                     ; Carrega o valor no acumulador
    STA player_direction                         ; Armazena o acumulador no destino
    LDA player_x                                 ; Carrega o valor no acumulador
    CMP #PLAYER_MAX_X                            ; Compara o acumulador com o operando
    BCS check_left                               ; Desvia quando o carry esta ativo
    INC player_x                                 ; Incrementa o valor armazenado
    JSR check_fence_collision                    ; Executa a rotina indicada
    LDA collision                                ; Carrega o valor no acumulador
    BNE undo_move_right                          ; Desvia quando o resultado anterior nao e zero
    LDA #$01                                     ; Carrega o valor no acumulador
    STA player_moving                            ; Armazena o acumulador no destino
    JMP check_left                               ; Continua a execucao no rotulo indicado
undo_move_right:                                 ; Define o ponto de entrada undo_move_right
    DEC player_x                                 ; Decrementa o valor armazenado
    JMP check_left                               ; Continua a execucao no rotulo indicado
check_left:                                      ; Define o ponto de entrada check_left
    LDA controller1                              ; Carrega o valor no acumulador
    AND #%00000010                               ; Aplica uma mascara de bits ao acumulador
    BEQ check_down                               ; Desvia quando o resultado anterior e zero
    LDA #$01                                     ; Carrega o valor no acumulador
    STA player_direction                         ; Armazena o acumulador no destino
    LDA player_x                                 ; Carrega o valor no acumulador
    CMP #PLAYER_MIN_X                            ; Compara o acumulador com o operando
    BEQ check_down                               ; Desvia quando o resultado anterior e zero
    DEC player_x                                 ; Decrementa o valor armazenado
    JSR check_fence_collision                    ; Executa a rotina indicada
    LDA collision                                ; Carrega o valor no acumulador
    BNE undo_move_left                           ; Desvia quando o resultado anterior nao e zero
    LDA #$01                                     ; Carrega o valor no acumulador
    STA player_moving                            ; Armazena o acumulador no destino
    JMP check_down                               ; Continua a execucao no rotulo indicado
undo_move_left:                                  ; Define o ponto de entrada undo_move_left
    INC player_x                                 ; Incrementa o valor armazenado
    JMP check_down                               ; Continua a execucao no rotulo indicado
check_down:                                      ; Define o ponto de entrada check_down
    LDA controller1                              ; Carrega o valor no acumulador
    AND #%00000100                               ; Aplica uma mascara de bits ao acumulador
    BEQ check_up                                 ; Desvia quando o resultado anterior e zero
    LDA player_y                                 ; Carrega o valor no acumulador
    CMP #PLAYER_MAX_Y                            ; Compara o acumulador com o operando
    BCS check_up                                 ; Desvia quando o carry esta ativo
    INC player_y                                 ; Incrementa o valor armazenado
    JSR check_fence_collision                    ; Executa a rotina indicada
    LDA collision                                ; Carrega o valor no acumulador
    BNE undo_move_down                           ; Desvia quando o resultado anterior nao e zero
    LDA #$01                                     ; Carrega o valor no acumulador
    STA player_moving                            ; Armazena o acumulador no destino
    JMP check_up                                 ; Continua a execucao no rotulo indicado
undo_move_down:                                  ; Define o ponto de entrada undo_move_down
    DEC player_y                                 ; Decrementa o valor armazenado
    JMP check_up                                 ; Continua a execucao no rotulo indicado
check_up:                                        ; Define o ponto de entrada check_up
    LDA controller1                              ; Carrega o valor no acumulador
    AND #%00001000                               ; Aplica uma mascara de bits ao acumulador
    BEQ update_player_done                       ; Desvia quando o resultado anterior e zero
    LDA player_y                                 ; Carrega o valor no acumulador
    CMP #PLAYER_MIN_Y                            ; Compara o acumulador com o operando
    BEQ update_player_done                       ; Desvia quando o resultado anterior e zero
    DEC player_y                                 ; Decrementa o valor armazenado
    JSR check_fence_collision                    ; Executa a rotina indicada
    LDA collision                                ; Carrega o valor no acumulador
    BNE undo_move_up                             ; Desvia quando o resultado anterior nao e zero
    LDA #$01                                     ; Carrega o valor no acumulador
    STA player_moving                            ; Armazena o acumulador no destino
    JMP update_player_done                       ; Continua a execucao no rotulo indicado
undo_move_up:                                    ; Define o ponto de entrada undo_move_up
    INC player_y                                 ; Incrementa o valor armazenado
update_player_done:                              ; Define o ponto de entrada update_player_done
    RTS                                          ; Retorna para a rotina chamadora
update_player_animation:                         ; Define o ponto de entrada update_player_animation
    LDA player_alive                             ; Carrega o valor no acumulador
    BNE update_living_player_animation           ; Desvia quando o resultado anterior nao e zero
    RTS                                          ; Retorna para a rotina chamadora
update_living_player_animation:                  ; Define o ponto de entrada update_living_player_animation
    LDA player_moving                            ; Carrega o valor no acumulador
    BNE player_is_moving                         ; Desvia quando o resultado anterior nao e zero
player_is_stopped:                               ; Define o ponto de entrada player_is_stopped
    LDA #$00                                     ; Carrega o valor no acumulador
    STA anim_counter                             ; Armazena o acumulador no destino
    STA anim_frame                               ; Armazena o acumulador no destino
    RTS                                          ; Retorna para a rotina chamadora
player_is_moving:                                ; Define o ponto de entrada player_is_moving
    INC anim_counter                             ; Incrementa o valor armazenado
    LDA anim_counter                             ; Carrega o valor no acumulador
    CMP #$08                                     ; Compara o acumulador com o operando
    BCC animation_done                           ; Desvia quando o carry esta limpo
    LDA #$00                                     ; Carrega o valor no acumulador
    STA anim_counter                             ; Armazena o acumulador no destino
    INC anim_frame                               ; Incrementa o valor armazenado
    LDA anim_frame                               ; Carrega o valor no acumulador
    CMP #$02                                     ; Compara o acumulador com o operando
    BCC animation_done                           ; Desvia quando o carry esta limpo
    LDA #$00                                     ; Carrega o valor no acumulador
    STA anim_frame                               ; Armazena o acumulador no destino
animation_done:                                  ; Define o ponto de entrada animation_done
    RTS                                          ; Retorna para a rotina chamadora
