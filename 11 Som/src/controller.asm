read_controller:                                 ; Define o ponto de entrada read_controller
    LDA #$01                                     ; Carrega o valor no acumulador
    STA $4016                                    ; Armazena o acumulador no destino
    LDA #$00                                     ; Carrega o valor no acumulador
    STA $4016                                    ; Armazena o acumulador no destino
    LDA #$00                                     ; Carrega o valor no acumulador
    STA controller1                              ; Armazena o acumulador no destino
    LDX #$08                                     ; Carrega o valor no registrador X
read_controller_loop:                            ; Define o ponto de entrada read_controller_loop
    LDA $4016                                    ; Carrega o valor no acumulador
    LSR A                                        ; Desloca os bits uma posicao para a direita
    ROL controller1                              ; Rotaciona os bits uma posicao para a esquerda
    DEX                                          ; Decrementa o registrador X
    BNE read_controller_loop                     ; Desvia quando o resultado anterior nao e zero
    RTS                                          ; Retorna para a rotina chamadora
update_controller_pressed:                       ; Define o ponto de entrada update_controller_pressed
    LDA previous_controller1                     ; Carrega o valor no acumulador
    EOR #$FF                                     ; Combina os bits usando OU exclusivo
    AND controller1                              ; Aplica uma mascara de bits ao acumulador
    STA controller_pressed                       ; Armazena o acumulador no destino
    LDA controller1                              ; Carrega o valor no acumulador
    STA previous_controller1                     ; Armazena o acumulador no destino
    RTS                                          ; Retorna para a rotina chamadora
