.segment "HEADER"                                ; Seleciona o segmento "HEADER"
    .byte "NES"                                  ; Grava os bytes desta tabela na ROM
    .byte $1A                                    ; Grava os bytes desta tabela na ROM
    .byte $02                                    ; Grava os bytes desta tabela na ROM
    .byte $01                                    ; Grava os bytes desta tabela na ROM
    .byte %00000000                              ; Grava os bytes desta tabela na ROM
    .byte $00, $00, $00, $00                     ; Grava os bytes desta tabela na ROM
    .byte $00, $00, $00, $00, $00                ; Grava os bytes desta tabela na ROM
.segment "ZEROPAGE"                              ; Seleciona o segmento "ZEROPAGE"
.include "zeropage.inc"                          ; Inclui o modulo "zeropage.inc"
.segment "BSS"                                   ; Seleciona o segmento "BSS"
.include "ram.inc"                               ; Inclui o modulo "ram.inc"
