biker_sprite:

    ; -----------------------------
    ; Linha 1 (cabeça)
    ; Formato de cada sprite:
    ; Y, Tile, Atributos, X
    ; -----------------------------

    .byte $60, $00, $00, $80    ; Sprite superior esquerdo
    .byte $60, $01, $00, $88    ; Sprite superior central
    .byte $60, $02, $00, $90    ; Sprite superior direito

    ; -----------------------------
    ; Linha 2 (tronco)
    ; -----------------------------

    .byte $68, $03, $00, $80    ; Sprite do meio esquerdo
    .byte $68, $04, $00, $88    ; Sprite do meio central
    .byte $68, $05, $00, $90    ; Sprite do meio direito

    ; -----------------------------
    ; Linha 3 (pés)
    ; Frame inicial da animação.
    ; Estes tiles serão alterados
    ; durante a caminhada.
    ; -----------------------------

    .byte $70, $06, $00, $80    ; Pé esquerdo
    .byte $70, $07, $00, $88    ; Pé central
    .byte $70, $08, $00, $90    ; Pé direito