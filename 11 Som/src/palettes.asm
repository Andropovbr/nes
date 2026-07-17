bg_palettes:                                     ; Define o ponto de entrada bg_palettes
    .byte $29, $19, $2B, $39                     ; Grava os bytes desta tabela na ROM
    .byte $29, $17, $27, $37                     ; Grava os bytes desta tabela na ROM
sprite_palette:                                  ; Define o ponto de entrada sprite_palette
    .byte $29, $0C, $21, $32                     ; Grava os bytes desta tabela na ROM
    .byte $29, $15, $06, $26                     ; Grava os bytes desta tabela na ROM
