; ------------------------------------------------------------
; LIMITES DA CERCA
; ------------------------------------------------------------
;
; A cerca começa no endereço $21CD:
;
; coluna 13 = 13 * 8 = 104 pixels = $68
; linha  14 = 14 * 8 = 112 pixels = $70
;
; A cerca possui:
;
; largura = 4 blocos * 16 pixels = 64 pixels
; altura  = 16 pixels
;
; Portanto:
;
; X = $68 até $A7
; Y = $70 até $7F
;
; ------------------------------------------------------------

FENCE_LEFT   = $68
FENCE_RIGHT  = $A7
FENCE_TOP    = $70
FENCE_BOTTOM = $7F

PLAYER_WIDTH  = $18              ; 24 pixels
PLAYER_HEIGHT = $18              ; 24 pixels


; ------------------------------------------------------------
; VERIFICA COLISÃO ENTRE O JOGADOR E A CERCA
; ------------------------------------------------------------
;
; A rotina verifica quatro situações em que não existe colisão:
;
; 1. Jogador totalmente à direita da cerca
; 2. Jogador totalmente à esquerda da cerca
; 3. Jogador totalmente abaixo da cerca
; 4. Jogador totalmente acima da cerca
;
; Se nenhuma delas ocorrer, os retângulos estão sobrepostos.
;
; Saída:
;
; collision = 0: não houve colisão
; collision = 1: houve colisão
;
; ------------------------------------------------------------

check_fence_collision:

    LDA #$00
    STA collision                 ; Começa assumindo que não há colisão

    ; --------------------------------------------------------
    ; Jogador está totalmente à direita da cerca?
    ;
    ; Se player_x > FENCE_RIGHT, não existe colisão.
    ; Como FENCE_RIGHT = $A7, testamos player_x >= $A8.
    ; --------------------------------------------------------

    LDA player_x
    CMP #FENCE_RIGHT + 1
    BCS no_fence_collision

    ; --------------------------------------------------------
    ; Jogador está totalmente à esquerda da cerca?
    ;
    ; Calcula a coordenada do último pixel à direita:
    ;
    ; player_right = player_x + 23
    ;
    ; Se player_right < FENCE_LEFT, não existe colisão.
    ; --------------------------------------------------------

    LDA player_x
    CLC
    ADC #PLAYER_WIDTH - 1
    CMP #FENCE_LEFT
    BCC no_fence_collision

    ; --------------------------------------------------------
    ; Jogador está totalmente abaixo da cerca?
    ;
    ; Se player_y > FENCE_BOTTOM, não existe colisão.
    ; --------------------------------------------------------

    LDA player_y
    CMP #FENCE_BOTTOM + 1
    BCS no_fence_collision

    ; --------------------------------------------------------
    ; Jogador está totalmente acima da cerca?
    ;
    ; Calcula o último pixel inferior:
    ;
    ; player_bottom = player_y + 23
    ;
    ; Se player_bottom < FENCE_TOP, não existe colisão.
    ; --------------------------------------------------------

    LDA player_y
    CLC
    ADC #PLAYER_HEIGHT - 1
    CMP #FENCE_TOP
    BCC no_fence_collision

    ; Nenhuma condição de separação foi encontrada.
    ; Portanto, os retângulos estão sobrepostos.

    LDA #$01
    STA collision

no_fence_collision:

    RTS