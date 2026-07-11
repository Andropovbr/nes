; ------------------------------------------------------------
; DADOS DAS PALETAS
; ------------------------------------------------------------

; Paleta do Background
; $0F = Preto
; $01 = Azul
; $11 = Azul claro
; $31 = Branco

bg_grass:

    .byte $0F, $01, $11, $31

; Paleta dos Sprites
; $0F = Preto (transparente para sprites)
; $0C = Verde
; $21 = Azul
; $32 = Branco

sprite_palette:

    .byte $0F, $0C, $21, $32