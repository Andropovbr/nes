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

; ------------------------------------------------------------
; IDENTIFICA BOTÕES RECÉM-PRESSIONADOS
; ------------------------------------------------------------
;
; A rotina compara o estado atual do controle com o estado
; do frame anterior.
;
; Exemplo:
;
; Frame anterior:
;     A = 0
;
; Frame atual:
;     A = 1
;
; Nesse caso, o bit de A será colocado em controller_pressed.
;
; Se o jogador continuar segurando A no próximo frame:
;
; Frame anterior:
;     A = 1
;
; Frame atual:
;     A = 1
;
; controller_pressed será zero para esse botão.
;
; Operação realizada:
;
; controller_pressed = controller1 AND NOT previous_controller1
;
; ------------------------------------------------------------

update_controller_pressed:

    ; Inverte o estado anterior.
    ;
    ; Botões que estavam soltos passam a possuir bit 1.

    LDA previous_controller1
    EOR #$FF

    ; Mantém somente os botões que:
    ;
    ; 1. Estavam soltos no frame anterior
    ; 2. Estão pressionados no frame atual

    AND controller1
    STA controller_pressed

    ; O estado atual passa a ser o estado anterior
    ; para a comparação do próximo frame.

    LDA controller1
    STA previous_controller1

    RTS