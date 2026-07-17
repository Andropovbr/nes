PROJECTILE_TILE  = $19                           ; Configura a constante PROJECTILE_TILE
PROJECTILE_SPEED = $03                           ; Configura a constante PROJECTILE_SPEED
BUTTON_A = %10000000                             ; Configura a constante BUTTON_A
PROJECTILE_OAM_Y          = $0248                ; Configura a constante PROJECTILE_OAM_Y
PROJECTILE_OAM_TILE       = $0249                ; Configura a constante PROJECTILE_OAM_TILE
PROJECTILE_OAM_ATTRIBUTES = $024A                ; Configura a constante PROJECTILE_OAM_ATTRIBUTES
PROJECTILE_OAM_X          = $024B                ; Configura a constante PROJECTILE_OAM_X
check_projectile_input:                          ; Define o ponto de entrada check_projectile_input
    LDA player_alive                             ; Carrega o valor no acumulador
    BEQ check_projectile_input_done              ; Desvia quando o resultado anterior e zero
    LDA controller_pressed                       ; Carrega o valor no acumulador
    AND #BUTTON_A                                ; Aplica uma mascara de bits ao acumulador
    BEQ check_projectile_input_done              ; Desvia quando o resultado anterior e zero
    LDA projectile_active                        ; Carrega o valor no acumulador
    BNE check_projectile_input_done              ; Desvia quando o resultado anterior nao e zero
    JSR spawn_projectile                         ; Executa a rotina indicada
check_projectile_input_done:                     ; Define o ponto de entrada check_projectile_input_done
    RTS                                          ; Retorna para a rotina chamadora
spawn_projectile:                                ; Define o ponto de entrada spawn_projectile
    LDA player_direction                         ; Carrega o valor no acumulador
    STA projectile_direction                     ; Armazena o acumulador no destino
    LDA player_y                                 ; Carrega o valor no acumulador
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #$08                                     ; Soma o operando ao acumulador com o carry
    STA projectile_y                             ; Armazena o acumulador no destino
    LDA projectile_direction                     ; Carrega o valor no acumulador
    BNE spawn_projectile_left                    ; Desvia quando o resultado anterior nao e zero
spawn_projectile_right:                          ; Define o ponto de entrada spawn_projectile_right
    LDA player_x                                 ; Carrega o valor no acumulador
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #$14                                     ; Soma o operando ao acumulador com o carry
    STA projectile_x                             ; Armazena o acumulador no destino
    JMP activate_projectile                      ; Continua a execucao no rotulo indicado
spawn_projectile_left:                           ; Define o ponto de entrada spawn_projectile_left
    LDA player_x                                 ; Carrega o valor no acumulador
    SEC                                          ; Ativa o carry antes da operacao aritmetica
    SBC #$04                                     ; Subtrai o operando do acumulador
    STA projectile_x                             ; Armazena o acumulador no destino
activate_projectile:                             ; Define o ponto de entrada activate_projectile
    LDA #$01                                     ; Carrega o valor no acumulador
    STA projectile_active                        ; Armazena o acumulador no destino
    LDA #sfx_megamanhit                          ; Carrega o valor no acumulador
    LDX #FAMISTUDIO_SFX_CH0                      ; Carrega o valor no registrador X
    JSR famistudio_sfx_play                      ; Executa a rotina indicada
    RTS                                          ; Retorna para a rotina chamadora
update_projectile:                               ; Define o ponto de entrada update_projectile
    LDA projectile_active                        ; Carrega o valor no acumulador
    BEQ update_projectile_done                   ; Desvia quando o resultado anterior e zero
    LDA projectile_direction                     ; Carrega o valor no acumulador
    BNE move_projectile_left                     ; Desvia quando o resultado anterior nao e zero
move_projectile_right:                           ; Define o ponto de entrada move_projectile_right
    LDA projectile_x                             ; Carrega o valor no acumulador
    CMP #$FD                                     ; Compara o acumulador com o operando
    BCS deactivate_projectile                    ; Desvia quando o carry esta ativo
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #PROJECTILE_SPEED                        ; Soma o operando ao acumulador com o carry
    STA projectile_x                             ; Armazena o acumulador no destino
    JMP update_projectile_done                   ; Continua a execucao no rotulo indicado
move_projectile_left:                            ; Define o ponto de entrada move_projectile_left
    LDA projectile_x                             ; Carrega o valor no acumulador
    CMP #PROJECTILE_SPEED                        ; Compara o acumulador com o operando
    BCC deactivate_projectile                    ; Desvia quando o carry esta limpo
    SEC                                          ; Ativa o carry antes da operacao aritmetica
    SBC #PROJECTILE_SPEED                        ; Subtrai o operando do acumulador
    STA projectile_x                             ; Armazena o acumulador no destino
    JMP update_projectile_done                   ; Continua a execucao no rotulo indicado
deactivate_projectile:                           ; Define o ponto de entrada deactivate_projectile
    LDA #$00                                     ; Carrega o valor no acumulador
    STA projectile_active                        ; Armazena o acumulador no destino
update_projectile_done:                          ; Define o ponto de entrada update_projectile_done
    RTS                                          ; Retorna para a rotina chamadora
update_projectile_sprite:                        ; Define o ponto de entrada update_projectile_sprite
    LDA projectile_active                        ; Carrega o valor no acumulador
    BEQ hide_projectile_sprite                   ; Desvia quando o resultado anterior e zero
    LDA projectile_y                             ; Carrega o valor no acumulador
    STA PROJECTILE_OAM_Y                         ; Armazena o acumulador no destino
    LDA #PROJECTILE_TILE                         ; Carrega o valor no acumulador
    STA PROJECTILE_OAM_TILE                      ; Armazena o acumulador no destino
    LDA #$00                                     ; Carrega o valor no acumulador
    STA PROJECTILE_OAM_ATTRIBUTES                ; Armazena o acumulador no destino
    LDA projectile_x                             ; Carrega o valor no acumulador
    STA PROJECTILE_OAM_X                         ; Armazena o acumulador no destino
    RTS                                          ; Retorna para a rotina chamadora
hide_projectile_sprite:                          ; Define o ponto de entrada hide_projectile_sprite
    LDA #$FE                                     ; Carrega o valor no acumulador
    STA PROJECTILE_OAM_Y                         ; Armazena o acumulador no destino
    RTS                                          ; Retorna para a rotina chamadora
