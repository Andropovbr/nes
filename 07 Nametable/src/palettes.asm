; ------------------------------------------------------------
; DADOS DAS PALETAS
; ------------------------------------------------------------

; Paleta 0 do Background
; $29 = Verde-limão (Cor universal de fundo)
; $19 = Verde escuro
; $2B = Verde médio
; $39 = Verde claro

; Paleta 1 do Background
; $29 = Verde-limão (Cor universal de fundo)
; $17 = Marrom
; $27 = Verde médio
; $37 = Verde claro

bg_palettes:

    ; Paleta 0: gramado
    .byte $29, $19, $2B, $39

    ; Paleta 1: chão
    .byte $29, $17, $27, $37

; Paleta dos Sprites
; $29 = Verde-limão (transparente para sprites)
; $0C = Azul
; $21 = Azul claro
; $32 = Lilás

sprite_palette:

    .byte $29, $0C, $21, $32