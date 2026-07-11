; ------------------------------------------------------------
; LÊ O ESTADO DO CONTROLE 1
; ------------------------------------------------------------
;
; Ordem em que o NES fornece os botões:
;
; A, B, Select, Start, Cima, Baixo, Esquerda, Direita
;
; Após a leitura, a variável controller1 fica organizada assim:
;
; bit 0 = Direita
; bit 1 = Esquerda
; bit 2 = Baixo
; bit 3 = Cima
; bit 4 = Start
; bit 5 = Select
; bit 6 = B
; bit 7 = A
; ------------------------------------------------------------

read_controller:

    LDA #$01              ; Ativa o strobe do controle
    STA $4016             ; Faz o controle capturar o estado atual dos botões

    LDA #$00              ; Desativa o strobe
    STA $4016             ; A partir daqui os botões serão lidos um a um

    LDA #$00
    STA controller1       ; Limpa a variável que armazenará os botões

    LDX #$08              ; Serão lidos os 8 botões do controle

read_controller_loop:

    LDA $4016             ; Lê o próximo botão

    LSR A                 ; Move o bit lido para o Carry

    ROL controller1       ; Rotaciona o Carry para dentro de controller1

    DEX                   ; Decrementa o contador
    BNE read_controller_loop ; Continua até ler os 8 botões

    RTS                   ; Retorna ao programa principal