; ============================================================
; SPRITE DO JOGADOR
; ============================================================
;
; Esta tabela descreve a aparência inicial do jogador.
;
; Cada sprite de hardware do NES ocupa 4 bytes:
;
;   Byte 0 -> Coordenada Y
;   Byte 1 -> Índice do tile na CHR
;   Byte 2 -> Atributos
;   Byte 3 -> Coordenada X
;
; O personagem é formado por uma grade de 3x3 sprites de 8x8,
; totalizando uma área de 24x24 pixels.
;
; Durante o jogo, esta tabela é copiada para a Shadow OAM e as
; rotinas de atualização alteram as posições e os tiles conforme
; a animação e a direção do personagem.
;
; ============================================================

biker_sprite:

    ; Linha superior

    .byte $40, $00, $00, $80
    .byte $40, $01, $00, $88
    .byte $40, $02, $00, $90

    ; Linha central

    .byte $48, $03, $00, $80
    .byte $48, $04, $00, $88
    .byte $48, $05, $00, $90

    ; Linha inferior

    .byte $50, $06, $00, $80
    .byte $50, $07, $00, $88
    .byte $50, $08, $00, $90
