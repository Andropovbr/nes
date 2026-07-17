.segment "CODE"                                  ; Seleciona o segmento "CODE"
initialize_game:                                 ; Define o ponto de entrada initialize_game
    LDA #$00                                     ; Carrega o valor no acumulador
    STA game_over                                ; Armazena o acumulador no destino
    STA projectile_active                        ; Armazena o acumulador no destino
    STA controller_pressed                       ; Armazena o acumulador no destino
    LDA controller1                              ; Carrega o valor no acumulador
    STA previous_controller1                     ; Armazena o acumulador no destino
    LDA #$80                                     ; Carrega o valor no acumulador
    STA player_x                                 ; Armazena o acumulador no destino
    LDA #$40                                     ; Carrega o valor no acumulador
    STA player_y                                 ; Armazena o acumulador no destino
    LDA #$00                                     ; Carrega o valor no acumulador
    STA player_direction                         ; Armazena o acumulador no destino
    STA player_moving                            ; Armazena o acumulador no destino
    STA anim_counter                             ; Armazena o acumulador no destino
    STA anim_frame                               ; Armazena o acumulador no destino
    LDA #$01                                     ; Carrega o valor no acumulador
    STA player_alive                             ; Armazena o acumulador no destino
    LDA #$20                                     ; Carrega o valor no acumulador
    STA enemy_x                                  ; Armazena o acumulador no destino
    LDA #$B0                                     ; Carrega o valor no acumulador
    STA enemy_y                                  ; Armazena o acumulador no destino
    LDA #$00                                     ; Carrega o valor no acumulador
    STA enemy_direction                          ; Armazena o acumulador no destino
    STA enemy_moving                             ; Armazena o acumulador no destino
    STA enemy_move_counter                       ; Armazena o acumulador no destino
    STA enemy_anim_counter                       ; Armazena o acumulador no destino
    STA enemy_anim_frame                         ; Armazena o acumulador no destino
    LDA #$01                                     ; Carrega o valor no acumulador
    STA enemy_alive                              ; Armazena o acumulador no destino
    LDA #$00                                     ; Carrega o valor no acumulador
    STA projectile_x                             ; Armazena o acumulador no destino
    STA projectile_y                             ; Armazena o acumulador no destino
    STA projectile_direction                     ; Armazena o acumulador no destino
    JSR update_biker_sprite                      ; Executa a rotina indicada
    JSR update_enemy_sprite                      ; Executa a rotina indicada
    JSR update_projectile_sprite                 ; Executa a rotina indicada
    RTS                                          ; Retorna para a rotina chamadora
forever:                                         ; Define o ponto de entrada forever
wait_frame:                                      ; Define o ponto de entrada wait_frame
    LDA frame_ready                              ; Carrega o valor no acumulador
    BEQ wait_frame                               ; Desvia quando o resultado anterior e zero
    LDA #$00                                     ; Carrega o valor no acumulador
    STA frame_ready                              ; Armazena o acumulador no destino
    JSR read_controller                          ; Executa a rotina indicada
    JSR update_controller_pressed                ; Executa a rotina indicada
    LDA game_over                                ; Carrega o valor no acumulador
    BNE update_game_over                         ; Desvia quando o resultado anterior nao e zero
update_running_game:                             ; Define o ponto de entrada update_running_game
    JSR update_player                            ; Executa a rotina indicada
    JSR update_player_animation                  ; Executa a rotina indicada
    JSR check_projectile_input                   ; Executa a rotina indicada
    JSR update_projectile                        ; Executa a rotina indicada
    JSR update_enemy                             ; Executa a rotina indicada
    JSR update_enemy_animation                   ; Executa a rotina indicada
    JSR check_projectile_enemy_collision         ; Executa a rotina indicada
    LDA collision                                ; Carrega o valor no acumulador
    BEQ check_enemy_player_collision             ; Desvia quando o resultado anterior e zero
    LDA #$00                                     ; Carrega o valor no acumulador
    STA projectile_active                        ; Armazena o acumulador no destino
    LDA #$00                                     ; Carrega o valor no acumulador
    STA enemy_alive                              ; Armazena o acumulador no destino
    LDA #$01                                     ; Carrega o valor no acumulador
    STA game_over                                ; Armazena o acumulador no destino
    JMP update_game_sprites                      ; Continua a execucao no rotulo indicado
check_enemy_player_collision:                    ; Define o ponto de entrada check_enemy_player_collision
    LDA enemy_alive                              ; Carrega o valor no acumulador
    BEQ update_game_sprites                      ; Desvia quando o resultado anterior e zero
    JSR check_player_enemy_collision             ; Executa a rotina indicada
    LDA collision                                ; Carrega o valor no acumulador
    BEQ update_game_sprites                      ; Desvia quando o resultado anterior e zero
    LDA #$00                                     ; Carrega o valor no acumulador
    STA player_alive                             ; Armazena o acumulador no destino
    STA projectile_active                        ; Armazena o acumulador no destino
    LDA #$01                                     ; Carrega o valor no acumulador
    STA game_over                                ; Armazena o acumulador no destino
update_game_sprites:                             ; Define o ponto de entrada update_game_sprites
    JSR update_biker_sprite                      ; Executa a rotina indicada
    JSR update_enemy_sprite                      ; Executa a rotina indicada
    JSR update_projectile_sprite                 ; Executa a rotina indicada
    JMP forever                                  ; Continua a execucao no rotulo indicado
update_game_over:                                ; Define o ponto de entrada update_game_over
    LDA controller_pressed                       ; Carrega o valor no acumulador
    AND #%00010000                               ; Aplica uma mascara de bits ao acumulador
    BEQ update_game_over_sprites                 ; Desvia quando o resultado anterior e zero
    JSR initialize_game                          ; Executa a rotina indicada
    JMP forever                                  ; Continua a execucao no rotulo indicado
update_game_over_sprites:                        ; Define o ponto de entrada update_game_over_sprites
    JSR update_biker_sprite                      ; Executa a rotina indicada
    JSR update_enemy_sprite                      ; Executa a rotina indicada
    JSR update_projectile_sprite                 ; Executa a rotina indicada
    JMP forever                                  ; Continua a execucao no rotulo indicado
