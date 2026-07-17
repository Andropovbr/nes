FENCE_LEFT   = $68                               ; Configura a constante FENCE_LEFT
FENCE_RIGHT  = $A7                               ; Configura a constante FENCE_RIGHT
FENCE_TOP    = $70                               ; Configura a constante FENCE_TOP
FENCE_BOTTOM = $7F                               ; Configura a constante FENCE_BOTTOM
PLAYER_WIDTH  = $18                              ; Configura a constante PLAYER_WIDTH
PLAYER_HEIGHT = $18                              ; Configura a constante PLAYER_HEIGHT
ENEMY_WIDTH  = $18                               ; Configura a constante ENEMY_WIDTH
ENEMY_HEIGHT = $18                               ; Configura a constante ENEMY_HEIGHT
PROJECTILE_WIDTH  = $08                          ; Configura a constante PROJECTILE_WIDTH
PROJECTILE_HEIGHT = $08                          ; Configura a constante PROJECTILE_HEIGHT
check_fence_collision:                           ; Define o ponto de entrada check_fence_collision
    LDA #$00                                     ; Carrega o valor no acumulador
    STA collision                                ; Armazena o acumulador no destino
    LDA player_x                                 ; Carrega o valor no acumulador
    CMP #FENCE_RIGHT + 1                         ; Compara o acumulador com o operando
    BCS no_fence_collision                       ; Desvia quando o carry esta ativo
    LDA player_x                                 ; Carrega o valor no acumulador
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #PLAYER_WIDTH - 1                        ; Soma o operando ao acumulador com o carry
    CMP #FENCE_LEFT                              ; Compara o acumulador com o operando
    BCC no_fence_collision                       ; Desvia quando o carry esta limpo
    LDA player_y                                 ; Carrega o valor no acumulador
    CMP #FENCE_BOTTOM + 1                        ; Compara o acumulador com o operando
    BCS no_fence_collision                       ; Desvia quando o carry esta ativo
    LDA player_y                                 ; Carrega o valor no acumulador
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #PLAYER_HEIGHT - 1                       ; Soma o operando ao acumulador com o carry
    CMP #FENCE_TOP                               ; Compara o acumulador com o operando
    BCC no_fence_collision                       ; Desvia quando o carry esta limpo
    LDA #$01                                     ; Carrega o valor no acumulador
    STA collision                                ; Armazena o acumulador no destino
no_fence_collision:                              ; Define o ponto de entrada no_fence_collision
    RTS                                          ; Retorna para a rotina chamadora
check_player_enemy_collision:                    ; Define o ponto de entrada check_player_enemy_collision
    LDA #$00                                     ; Carrega o valor no acumulador
    STA collision                                ; Armazena o acumulador no destino
    LDA player_alive                             ; Carrega o valor no acumulador
    BEQ no_player_enemy_collision                ; Desvia quando o resultado anterior e zero
    LDA enemy_alive                              ; Carrega o valor no acumulador
    BEQ no_player_enemy_collision                ; Desvia quando o resultado anterior e zero
    LDA enemy_x                                  ; Carrega o valor no acumulador
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #ENEMY_WIDTH                             ; Soma o operando ao acumulador com o carry
    CMP player_x                                 ; Compara o acumulador com o operando
    BCC no_player_enemy_collision                ; Desvia quando o carry esta limpo
    BEQ no_player_enemy_collision                ; Desvia quando o resultado anterior e zero
    LDA player_x                                 ; Carrega o valor no acumulador
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #PLAYER_WIDTH - 1                        ; Soma o operando ao acumulador com o carry
    CMP enemy_x                                  ; Compara o acumulador com o operando
    BCC no_player_enemy_collision                ; Desvia quando o carry esta limpo
    LDA enemy_y                                  ; Carrega o valor no acumulador
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #ENEMY_HEIGHT                            ; Soma o operando ao acumulador com o carry
    CMP player_y                                 ; Compara o acumulador com o operando
    BCC no_player_enemy_collision                ; Desvia quando o carry esta limpo
    BEQ no_player_enemy_collision                ; Desvia quando o resultado anterior e zero
    LDA player_y                                 ; Carrega o valor no acumulador
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #PLAYER_HEIGHT - 1                       ; Soma o operando ao acumulador com o carry
    CMP enemy_y                                  ; Compara o acumulador com o operando
    BCC no_player_enemy_collision                ; Desvia quando o carry esta limpo
    LDA #$01                                     ; Carrega o valor no acumulador
    STA collision                                ; Armazena o acumulador no destino
no_player_enemy_collision:                       ; Define o ponto de entrada no_player_enemy_collision
    RTS                                          ; Retorna para a rotina chamadora
check_projectile_enemy_collision:                ; Define o ponto de entrada check_projectile_enemy_collision
    LDA #$00                                     ; Carrega o valor no acumulador
    STA collision                                ; Armazena o acumulador no destino
    LDA projectile_active                        ; Carrega o valor no acumulador
    BEQ no_projectile_enemy_collision            ; Desvia quando o resultado anterior e zero
    LDA enemy_alive                              ; Carrega o valor no acumulador
    BEQ no_projectile_enemy_collision            ; Desvia quando o resultado anterior e zero
    LDA enemy_x                                  ; Carrega o valor no acumulador
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #ENEMY_WIDTH                             ; Soma o operando ao acumulador com o carry
    CMP projectile_x                             ; Compara o acumulador com o operando
    BCC no_projectile_enemy_collision            ; Desvia quando o carry esta limpo
    BEQ no_projectile_enemy_collision            ; Desvia quando o resultado anterior e zero
    LDA projectile_x                             ; Carrega o valor no acumulador
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #PROJECTILE_WIDTH - 1                    ; Soma o operando ao acumulador com o carry
    CMP enemy_x                                  ; Compara o acumulador com o operando
    BCC no_projectile_enemy_collision            ; Desvia quando o carry esta limpo
    LDA enemy_y                                  ; Carrega o valor no acumulador
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #ENEMY_HEIGHT                            ; Soma o operando ao acumulador com o carry
    CMP projectile_y                             ; Compara o acumulador com o operando
    BCC no_projectile_enemy_collision            ; Desvia quando o carry esta limpo
    BEQ no_projectile_enemy_collision            ; Desvia quando o resultado anterior e zero
    LDA projectile_y                             ; Carrega o valor no acumulador
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #PROJECTILE_HEIGHT - 1                   ; Soma o operando ao acumulador com o carry
    CMP enemy_y                                  ; Compara o acumulador com o operando
    BCC no_projectile_enemy_collision            ; Desvia quando o carry esta limpo
    LDA #$01                                     ; Carrega o valor no acumulador
    STA collision                                ; Armazena o acumulador no destino
no_projectile_enemy_collision:                   ; Define o ponto de entrada no_projectile_enemy_collision
    RTS                                          ; Retorna para a rotina chamadora
