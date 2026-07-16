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

ENEMY_WIDTH  = $18              ; 24 pixels
ENEMY_HEIGHT = $18              ; 24 pixels

PROJECTILE_WIDTH  = $08         ; Caixa de colisão de 8 pixels
PROJECTILE_HEIGHT = $08         ; Caixa de colisão de 8 pixels

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

; ------------------------------------------------------------
; VERIFICA COLISÃO ENTRE JOGADOR E INIMIGO
; ------------------------------------------------------------
;
; Jogador e inimigo são tratados como retângulos de 24x24.
;
; A rotina procura quatro situações em que os retângulos
; certamente estão separados:
;
; 1. Jogador está totalmente à direita do inimigo
; 2. Jogador está totalmente à esquerda do inimigo
; 3. Jogador está totalmente abaixo do inimigo
; 4. Jogador está totalmente acima do inimigo
;
; Se nenhuma dessas condições ocorrer, houve sobreposição.
;
; Saída:
;
; collision = 0: não houve colisão
; collision = 1: houve colisão
;
; A rotina não mata diretamente o jogador. Ela apenas informa
; se ocorreu a colisão. A consequência será tratada no main.
;
; ------------------------------------------------------------

check_player_enemy_collision:

    LDA #$00
    STA collision

    ; Se o jogador já estiver morto, não há colisão válida.

    LDA player_alive
    BEQ no_player_enemy_collision

    ; Se o inimigo já estiver morto, não há colisão válida.

    LDA enemy_alive
    BEQ no_player_enemy_collision


    ; --------------------------------------------------------
    ; Jogador está totalmente à direita do inimigo?
    ;
    ; enemy_right = enemy_x + 23
    ;
    ; Se player_x > enemy_right, os retângulos estão separados.
    ;
    ; Testamos:
    ;
    ; player_x >= enemy_x + 24
    ;
    ; --------------------------------------------------------

    LDA enemy_x
    CLC
    ADC #ENEMY_WIDTH
    CMP player_x
    BCC no_player_enemy_collision
    BEQ no_player_enemy_collision


    ; --------------------------------------------------------
    ; Jogador está totalmente à esquerda do inimigo?
    ;
    ; player_right = player_x + 23
    ;
    ; Se player_right < enemy_x, não existe colisão.
    ;
    ; --------------------------------------------------------

    LDA player_x
    CLC
    ADC #PLAYER_WIDTH - 1
    CMP enemy_x
    BCC no_player_enemy_collision


    ; --------------------------------------------------------
    ; Jogador está totalmente abaixo do inimigo?
    ;
    ; enemy_bottom = enemy_y + 23
    ;
    ; Se player_y > enemy_bottom, não existe colisão.
    ;
    ; Testamos:
    ;
    ; player_y >= enemy_y + 24
    ;
    ; --------------------------------------------------------

    LDA enemy_y
    CLC
    ADC #ENEMY_HEIGHT
    CMP player_y
    BCC no_player_enemy_collision
    BEQ no_player_enemy_collision


    ; --------------------------------------------------------
    ; Jogador está totalmente acima do inimigo?
    ;
    ; player_bottom = player_y + 23
    ;
    ; Se player_bottom < enemy_y, não existe colisão.
    ;
    ; --------------------------------------------------------

    LDA player_y
    CLC
    ADC #PLAYER_HEIGHT - 1
    CMP enemy_y
    BCC no_player_enemy_collision


    ; Nenhuma condição de separação foi encontrada.

    LDA #$01
    STA collision


no_player_enemy_collision:

    RTS

; ------------------------------------------------------------
; VERIFICA COLISÃO ENTRE PROJÉTIL E INIMIGO
; ------------------------------------------------------------
;
; O projétil usa uma caixa de 8x8 pixels.
; O inimigo usa uma caixa de 24x24 pixels.
;
; A rotina segue a mesma estratégia das demais colisões:
; procura situações em que os retângulos estão separados.
;
; Saída:
;
; collision = 0: não houve colisão
; collision = 1: houve colisão
;
; A rotina não remove o projétil nem mata o inimigo.
; Essas consequências serão tratadas no main.
;
; ------------------------------------------------------------

check_projectile_enemy_collision:

    LDA #$00
    STA collision

    ; Não existe colisão se o projétil estiver inativo.

    LDA projectile_active
    BEQ no_projectile_enemy_collision

    ; Não existe colisão se o inimigo já estiver morto.

    LDA enemy_alive
    BEQ no_projectile_enemy_collision


    ; --------------------------------------------------------
    ; Projétil está totalmente à direita do inimigo?
    ;
    ; Testa:
    ;
    ; enemy_x + 24 <= projectile_x
    ;
    ; --------------------------------------------------------

    LDA enemy_x
    CLC
    ADC #ENEMY_WIDTH
    CMP projectile_x
    BCC no_projectile_enemy_collision
    BEQ no_projectile_enemy_collision


    ; --------------------------------------------------------
    ; Projétil está totalmente à esquerda do inimigo?
    ;
    ; projectile_right = projectile_x + 7
    ;
    ; Se projectile_right < enemy_x, não existe colisão.
    ;
    ; --------------------------------------------------------

    LDA projectile_x
    CLC
    ADC #PROJECTILE_WIDTH - 1
    CMP enemy_x
    BCC no_projectile_enemy_collision


    ; --------------------------------------------------------
    ; Projétil está totalmente abaixo do inimigo?
    ;
    ; Testa:
    ;
    ; enemy_y + 24 <= projectile_y
    ;
    ; --------------------------------------------------------

    LDA enemy_y
    CLC
    ADC #ENEMY_HEIGHT
    CMP projectile_y
    BCC no_projectile_enemy_collision
    BEQ no_projectile_enemy_collision


    ; --------------------------------------------------------
    ; Projétil está totalmente acima do inimigo?
    ;
    ; projectile_bottom = projectile_y + 7
    ;
    ; Se projectile_bottom < enemy_y, não existe colisão.
    ;
    ; --------------------------------------------------------

    LDA projectile_y
    CLC
    ADC #PROJECTILE_HEIGHT - 1
    CMP enemy_y
    BCC no_projectile_enemy_collision


    ; Nenhuma condição de separação foi encontrada.

    LDA #$01
    STA collision


no_projectile_enemy_collision:

    RTS