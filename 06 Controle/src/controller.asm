; ------------------------------------------------------------
; LÊ CONTROLE 1
; ------------------------------------------------------------
;
; Ordem lida pelo NES:
;
; A, B, Select, Start, Cima, Baixo, Esquerda, Direita
;
; Resultado em controller1:
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

    LDA #$01
    STA $4016

    LDA #$00
    STA $4016

    LDA #$00
    STA controller1

    LDX #$08

read_controller_loop:

    LDA $4016
    LSR A
    ROL controller1

    DEX
    BNE read_controller_loop

    RTS