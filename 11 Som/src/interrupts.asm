NMI:                                             ; Define o ponto de entrada NMI
    PHA                                          ; Salva o acumulador na pilha
    TXA                                          ; Copia o registrador X para o acumulador
    PHA                                          ; Salva o acumulador na pilha
    TYA                                          ; Copia o registrador Y para o acumulador
    PHA                                          ; Salva o acumulador na pilha
    LDA #$00                                     ; Carrega o valor no acumulador
    STA $2003                                    ; Armazena o acumulador no destino
    LDA #$02                                     ; Carrega o valor no acumulador
    STA $4014                                    ; Armazena o acumulador no destino
    JSR famistudio_update                        ; Executa a rotina indicada
    LDA #$01                                     ; Carrega o valor no acumulador
    STA frame_ready                              ; Armazena o acumulador no destino
    PLA                                          ; Restaura o acumulador a partir da pilha
    TAY                                          ; Copia o acumulador para o registrador Y
    PLA                                          ; Restaura o acumulador a partir da pilha
    TAX                                          ; Copia o acumulador para o registrador X
    PLA                                          ; Restaura o acumulador a partir da pilha
    RTI                                          ; Retorna da interrupcao e restaura o estado
IRQ:                                             ; Define o ponto de entrada IRQ
    RTI                                          ; Retorna da interrupcao e restaura o estado
.segment "VECTORS"                               ; Seleciona o segmento "VECTORS"
    .word NMI                                    ; Grava os enderecos ou palavras desta tabela na ROM
    .word RESET                                  ; Grava os enderecos ou palavras desta tabela na ROM
    .word IRQ                                    ; Grava os enderecos ou palavras desta tabela na ROM
.segment "CHARS"                                 ; Seleciona o segmento "CHARS"
    .incbin "game.chr"                           ; Inclui os dados binarios de "game.chr"
