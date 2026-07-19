; ============================================================
; PALETTES.ASM
; ============================================================
;
; Contém as paletas de cores utilizadas pelo jogo.
;
; O NES possui áreas separadas para as paletas de background e
; para as paletas de sprites.
;
; Cada paleta é composta por quatro entradas:
;
;   Cor 0 -> cor compartilhada
;   Cor 1
;   Cor 2
;   Cor 3
;
; Os valores armazenados aqui correspondem aos índices da paleta
; de cores do NES.
;
; ============================================================


; ============================================================
; PALETAS DE BACKGROUND
; ============================================================
;
; Cada linha representa uma paleta completa de background.
;
; Nesta demo:
;
;   Paleta 0 -> gramado
;   Paleta 1 -> cerca
;
; As paletas são associadas aos blocos da nametable através da
; tabela de atributos da PPU.
;
; ============================================================

bg_palettes:

    ; Paleta 0 - Gramado

    .byte $29, $19, $2B, $39

    ; Paleta 1 - Cerca

    .byte $29, $17, $27, $37


; ============================================================
; PALETAS DE SPRITES
; ============================================================
;
; Cada linha representa uma paleta completa de sprites.
;
; Nesta demo:
;
;   Paleta 0 -> jogador
;   Paleta 1 -> inimigo
;
; O número da paleta utilizada por cada sprite é definido pelos
; dois bits menos significativos do byte de atributos da OAM.
;
; ============================================================

sprite_palette:

    ; Paleta 0 - Jogador

    .byte $29, $0C, $21, $32

    ; Paleta 1 - Inimigo

    .byte $29, $15, $06, $26