; ------------------------------------------------------------
; DADOS DAS PALETAS
; ------------------------------------------------------------

; Paleta 0 do Background
; $0F = Cor universal de fundo
; $19 = Verde escuro
; $2B = Verde médio
; $39 = Verde claro

bg_palette:

    .byte $0F, $19, $2B, $39

; Paleta dos Sprites
; $0F = Preto (transparente para sprites)
; $0C = Azul
; $21 = Azul claro
; $32 = Lilás

sprite_palette:

    .byte $0F, $0C, $21, $32