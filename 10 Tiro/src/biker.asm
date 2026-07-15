biker_sprite:

    ; -----------------------------
    ; Linha 1 (cabeça)
    ; Formato de cada sprite:
    ; Y, Tile, Atributos, X
    ; -----------------------------

    .byte $40, $00, $00, $80    ; Sprite superior esquerdo
    .byte $40, $01, $00, $88    ; Sprite superior central
    .byte $40, $02, $00, $90    ; Sprite superior direito

    ; -----------------------------
    ; Linha 2 (tronco)
    ; -----------------------------

    .byte $48, $03, $00, $80    ; Sprite do meio esquerdo
    .byte $48, $04, $00, $88    ; Sprite do meio central
    .byte $48, $05, $00, $90    ; Sprite do meio direito

    ; -----------------------------
    ; Linha 3 (pés)
    ; Frame inicial da animação.
    ; Estes tiles serão alterados
    ; durante a caminhada.
    ; -----------------------------

    .byte $50, $06, $00, $80    ; Pé esquerdo
    .byte $50, $07, $00, $88    ; Pé central
    .byte $50, $08, $00, $90    ; Pé direito