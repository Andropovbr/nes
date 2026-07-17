ENEMY_MOVE_DELAY = $03                           ; Configura a constante ENEMY_MOVE_DELAY
update_enemy:                                    ; Define o ponto de entrada update_enemy
    LDA enemy_alive                              ; Carrega o valor no acumulador
    BNE update_living_enemy                      ; Desvia quando o resultado anterior nao e zero
    LDA #$00                                     ; Carrega o valor no acumulador
    STA enemy_moving                             ; Armazena o acumulador no destino
    RTS                                          ; Retorna para a rotina chamadora
update_living_enemy:                             ; Define o ponto de entrada update_living_enemy
    LDA enemy_x                                  ; Carrega o valor no acumulador
    CMP player_x                                 ; Compara o acumulador com o operando
    BNE enemy_is_chasing                         ; Desvia quando o resultado anterior nao e zero
    LDA enemy_y                                  ; Carrega o valor no acumulador
    CMP player_y                                 ; Compara o acumulador com o operando
    BEQ enemy_stopped                            ; Desvia quando o resultado anterior e zero
enemy_is_chasing:                                ; Define o ponto de entrada enemy_is_chasing
    LDA #$01                                     ; Carrega o valor no acumulador
    STA enemy_moving                             ; Armazena o acumulador no destino
    INC enemy_move_counter                       ; Incrementa o valor armazenado
    LDA enemy_move_counter                       ; Carrega o valor no acumulador
    CMP #ENEMY_MOVE_DELAY                        ; Compara o acumulador com o operando
    BCC update_enemy_done                        ; Desvia quando o carry esta limpo
    LDA #$00                                     ; Carrega o valor no acumulador
    STA enemy_move_counter                       ; Armazena o acumulador no destino
    JMP enemy_chase_horizontal                   ; Continua a execucao no rotulo indicado
enemy_stopped:                                   ; Define o ponto de entrada enemy_stopped
    LDA #$00                                     ; Carrega o valor no acumulador
    STA enemy_moving                             ; Armazena o acumulador no destino
    STA enemy_move_counter                       ; Armazena o acumulador no destino
update_enemy_done:                               ; Define o ponto de entrada update_enemy_done
    RTS                                          ; Retorna para a rotina chamadora
enemy_chase_horizontal:                          ; Define o ponto de entrada enemy_chase_horizontal
    LDA enemy_x                                  ; Carrega o valor no acumulador
    CMP player_x                                 ; Compara o acumulador com o operando
    BEQ enemy_chase_vertical                     ; Desvia quando o resultado anterior e zero
    BCC enemy_move_right                         ; Desvia quando o carry esta limpo
enemy_move_left:                                 ; Define o ponto de entrada enemy_move_left
    DEC enemy_x                                  ; Decrementa o valor armazenado
    LDA #$01                                     ; Carrega o valor no acumulador
    STA enemy_direction                          ; Armazena o acumulador no destino
    JMP enemy_chase_vertical                     ; Continua a execucao no rotulo indicado
enemy_move_right:                                ; Define o ponto de entrada enemy_move_right
    INC enemy_x                                  ; Incrementa o valor armazenado
    LDA #$00                                     ; Carrega o valor no acumulador
    STA enemy_direction                          ; Armazena o acumulador no destino
enemy_chase_vertical:                            ; Define o ponto de entrada enemy_chase_vertical
    LDA enemy_y                                  ; Carrega o valor no acumulador
    CMP player_y                                 ; Compara o acumulador com o operando
    BEQ update_enemy_done                        ; Desvia quando o resultado anterior e zero
    BCC enemy_move_down                          ; Desvia quando o carry esta limpo
enemy_move_up:                                   ; Define o ponto de entrada enemy_move_up
    DEC enemy_y                                  ; Decrementa o valor armazenado
    JMP update_enemy_done                        ; Continua a execucao no rotulo indicado
enemy_move_down:                                 ; Define o ponto de entrada enemy_move_down
    INC enemy_y                                  ; Incrementa o valor armazenado
    JMP update_enemy_done                        ; Continua a execucao no rotulo indicado
update_enemy_animation:                          ; Define o ponto de entrada update_enemy_animation
    LDA enemy_alive                              ; Carrega o valor no acumulador
    BNE update_living_enemy_animation            ; Desvia quando o resultado anterior nao e zero
    RTS                                          ; Retorna para a rotina chamadora
update_living_enemy_animation:                   ; Define o ponto de entrada update_living_enemy_animation
    LDA enemy_moving                             ; Carrega o valor no acumulador
    BNE enemy_is_moving                          ; Desvia quando o resultado anterior nao e zero
enemy_is_stopped:                                ; Define o ponto de entrada enemy_is_stopped
    LDA #$00                                     ; Carrega o valor no acumulador
    STA enemy_anim_counter                       ; Armazena o acumulador no destino
    STA enemy_anim_frame                         ; Armazena o acumulador no destino
    RTS                                          ; Retorna para a rotina chamadora
enemy_is_moving:                                 ; Define o ponto de entrada enemy_is_moving
    INC enemy_anim_counter                       ; Incrementa o valor armazenado
    LDA enemy_anim_counter                       ; Carrega o valor no acumulador
    CMP #$08                                     ; Compara o acumulador com o operando
    BCC enemy_animation_done                     ; Desvia quando o carry esta limpo
    LDA #$00                                     ; Carrega o valor no acumulador
    STA enemy_anim_counter                       ; Armazena o acumulador no destino
    INC enemy_anim_frame                         ; Incrementa o valor armazenado
    LDA enemy_anim_frame                         ; Carrega o valor no acumulador
    CMP #$02                                     ; Compara o acumulador com o operando
    BCC enemy_animation_done                     ; Desvia quando o carry esta limpo
    LDA #$00                                     ; Carrega o valor no acumulador
    STA enemy_anim_frame                         ; Armazena o acumulador no destino
enemy_animation_done:                            ; Define o ponto de entrada enemy_animation_done
    RTS                                          ; Retorna para a rotina chamadora
hide_enemy_sprite:                               ; Define o ponto de entrada hide_enemy_sprite
    LDA #$FE                                     ; Carrega o valor no acumulador
    STA $0224                                    ; Armazena o acumulador no destino
    STA $0228                                    ; Armazena o acumulador no destino
    STA $022C                                    ; Armazena o acumulador no destino
    STA $0230                                    ; Armazena o acumulador no destino
    STA $0234                                    ; Armazena o acumulador no destino
    STA $0238                                    ; Armazena o acumulador no destino
    STA $023C                                    ; Armazena o acumulador no destino
    STA $0240                                    ; Armazena o acumulador no destino
    STA $0244                                    ; Armazena o acumulador no destino
    RTS                                          ; Retorna para a rotina chamadora
update_enemy_sprite:                             ; Define o ponto de entrada update_enemy_sprite
    LDA enemy_alive                              ; Carrega o valor no acumulador
    BNE update_visible_enemy_sprite              ; Desvia quando o resultado anterior nao e zero
    JSR hide_enemy_sprite                        ; Executa a rotina indicada
    RTS                                          ; Retorna para a rotina chamadora
update_visible_enemy_sprite:                     ; Define o ponto de entrada update_visible_enemy_sprite
    LDX #$00                                     ; Carrega o valor no registrador X
    LDY #$00                                     ; Carrega o valor no registrador Y
update_enemy_sprite_loop:                        ; Define o ponto de entrada update_enemy_sprite_loop
    LDA enemy_y_offsets, y                       ; Carrega o valor no acumulador
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC enemy_y                                  ; Soma o operando ao acumulador com o carry
    STA $0224, x                                 ; Armazena o acumulador no destino
    LDA enemy_tiles, y                           ; Carrega o valor no acumulador
    STA $0225, x                                 ; Armazena o acumulador no destino
    LDA enemy_direction                          ; Carrega o valor no acumulador
    BEQ enemy_attribute_right                    ; Desvia quando o resultado anterior e zero
enemy_attribute_left:                            ; Define o ponto de entrada enemy_attribute_left
    LDA #$41                                     ; Carrega o valor no acumulador
    JMP store_enemy_attribute                    ; Continua a execucao no rotulo indicado
enemy_attribute_right:                           ; Define o ponto de entrada enemy_attribute_right
    LDA #$01                                     ; Carrega o valor no acumulador
store_enemy_attribute:                           ; Define o ponto de entrada store_enemy_attribute
    STA $0226, x                                 ; Armazena o acumulador no destino
    LDA enemy_direction                          ; Carrega o valor no acumulador
    BEQ enemy_position_right                     ; Desvia quando o resultado anterior e zero
enemy_position_left:                             ; Define o ponto de entrada enemy_position_left
    LDA enemy_x_offsets_left, y                  ; Carrega o valor no acumulador
    JMP calculate_enemy_x                        ; Continua a execucao no rotulo indicado
enemy_position_right:                            ; Define o ponto de entrada enemy_position_right
    LDA enemy_x_offsets_right, y                 ; Carrega o valor no acumulador
calculate_enemy_x:                               ; Define o ponto de entrada calculate_enemy_x
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC enemy_x                                  ; Soma o operando ao acumulador com o carry
    STA $0227, x                                 ; Armazena o acumulador no destino
    INX                                          ; Incrementa o registrador X
    INX                                          ; Incrementa o registrador X
    INX                                          ; Incrementa o registrador X
    INX                                          ; Incrementa o registrador X
    INY                                          ; Incrementa o registrador Y
    CPY #$09                                     ; Compara o registrador Y com o operando
    BNE update_enemy_sprite_loop                 ; Desvia quando o resultado anterior nao e zero
    JSR update_enemy_animation_tiles             ; Executa a rotina indicada
    RTS                                          ; Retorna para a rotina chamadora
update_enemy_animation_tiles:                    ; Define o ponto de entrada update_enemy_animation_tiles
    LDA enemy_anim_frame                         ; Carrega o valor no acumulador
    BEQ enemy_anim_frame_0                       ; Desvia quando o resultado anterior e zero
enemy_anim_frame_1:                              ; Define o ponto de entrada enemy_anim_frame_1
    LDA #$09                                     ; Carrega o valor no acumulador
    STA $023D                                    ; Armazena o acumulador no destino
    LDA #$0A                                     ; Carrega o valor no acumulador
    STA $0241                                    ; Armazena o acumulador no destino
    LDA #$0B                                     ; Carrega o valor no acumulador
    STA $0245                                    ; Armazena o acumulador no destino
    RTS                                          ; Retorna para a rotina chamadora
enemy_anim_frame_0:                              ; Define o ponto de entrada enemy_anim_frame_0
    LDA #$06                                     ; Carrega o valor no acumulador
    STA $023D                                    ; Armazena o acumulador no destino
    LDA #$07                                     ; Carrega o valor no acumulador
    STA $0241                                    ; Armazena o acumulador no destino
    LDA #$08                                     ; Carrega o valor no acumulador
    STA $0245                                    ; Armazena o acumulador no destino
    RTS                                          ; Retorna para a rotina chamadora
enemy_tiles:                                     ; Define o ponto de entrada enemy_tiles
    .byte $00, $01, $02                          ; Grava os bytes desta tabela na ROM
    .byte $03, $04, $05                          ; Grava os bytes desta tabela na ROM
    .byte $06, $07, $08                          ; Grava os bytes desta tabela na ROM
enemy_y_offsets:                                 ; Define o ponto de entrada enemy_y_offsets
    .byte $00, $00, $00                          ; Grava os bytes desta tabela na ROM
    .byte $08, $08, $08                          ; Grava os bytes desta tabela na ROM
    .byte $10, $10, $10                          ; Grava os bytes desta tabela na ROM
enemy_x_offsets_right:                           ; Define o ponto de entrada enemy_x_offsets_right
    .byte $00, $08, $10                          ; Grava os bytes desta tabela na ROM
    .byte $00, $08, $10                          ; Grava os bytes desta tabela na ROM
    .byte $00, $08, $10                          ; Grava os bytes desta tabela na ROM
enemy_x_offsets_left:                            ; Define o ponto de entrada enemy_x_offsets_left
    .byte $10, $08, $00                          ; Grava os bytes desta tabela na ROM
    .byte $10, $08, $00                          ; Grava os bytes desta tabela na ROM
    .byte $10, $08, $00                          ; Grava os bytes desta tabela na ROM
