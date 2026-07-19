; ============================================================
; COLLISION.ASM
; ============================================================
;
; Contém as rotinas de detecção de colisão da demo.
;
; As colisões são verificadas usando retângulos alinhados aos
; eixos da tela, técnica normalmente chamada de AABB:
;
;   Axis-Aligned Bounding Box
;
; Cada objeto é representado por:
;
;   - posição X;
;   - posição Y;
;   - largura;
;   - altura.
;
; Para existir colisão, os retângulos precisam se sobrepor tanto
; no eixo horizontal quanto no eixo vertical.
;
; Todas as rotinas retornam o resultado pela variável collision:
;
;   collision = 0 -> não houve colisão
;   collision = 1 -> houve colisão
;
; ============================================================


; ============================================================
; LIMITES DA CERCA
; ============================================================
;
; Define o retângulo ocupado pela cerca na tela.
;
; Os valores representam as coordenadas dos extremos:
;
;   FENCE_LEFT   -> limite esquerdo
;   FENCE_RIGHT  -> limite direito
;   FENCE_TOP    -> limite superior
;   FENCE_BOTTOM -> limite inferior
;
; ============================================================

FENCE_LEFT   = $68
FENCE_RIGHT  = $A7
FENCE_TOP    = $70
FENCE_BOTTOM = $7F


; ============================================================
; DIMENSÕES DAS CAIXAS DE COLISÃO
; ============================================================
;
; Jogador e inimigo são formados por sprites compostos de 24x24
; pixels.
;
; O projétil utiliza uma caixa de colisão de 8x8 pixels.
;
; Essas dimensões não precisam obrigatoriamente ser iguais ao
; desenho visível do objeto. Em jogos maiores, é comum utilizar
; caixas um pouco menores para deixar as colisões mais naturais.
;
; ============================================================

PLAYER_WIDTH  = $18
PLAYER_HEIGHT = $18

ENEMY_WIDTH  = $18
ENEMY_HEIGHT = $18

PROJECTILE_WIDTH  = $08
PROJECTILE_HEIGHT = $08


; ============================================================
; VERIFICA COLISÃO ENTRE O JOGADOR E A CERCA
; ============================================================
;
; Compara o retângulo de 24x24 pixels do jogador com os limites
; fixos da cerca.
;
; A rotina testa quatro situações que descartam a colisão:
;
;   1. jogador está completamente à direita da cerca;
;   2. jogador está completamente à esquerda da cerca;
;   3. jogador está completamente abaixo da cerca;
;   4. jogador está completamente acima da cerca.
;
; Caso nenhuma dessas situações seja verdadeira, os dois
; retângulos estão sobrepostos.
;
; Entrada:
;
;   player_x
;   player_y
;
; Saída:
;
;   collision = 0 -> jogador não encosta na cerca
;   collision = 1 -> jogador encosta na cerca
;
; ============================================================

check_fence_collision:

    ; Começa assumindo que não existe colisão.

    LDA #$00
    STA collision


    ; --------------------------------------------------------
    ; TESTE HORIZONTAL: jogador à direita da cerca
    ; --------------------------------------------------------
    ;
    ; Se o lado esquerdo do jogador estiver depois do limite
    ; direito da cerca, não existe sobreposição horizontal.
    ;
    ; FENCE_RIGHT + 1 representa a primeira coordenada depois
    ; da cerca.
    ;
    ; --------------------------------------------------------

    LDA player_x
    CMP #FENCE_RIGHT + 1
    BCS no_fence_collision


    ; --------------------------------------------------------
    ; TESTE HORIZONTAL: jogador à esquerda da cerca
    ; --------------------------------------------------------
    ;
    ; Calcula a coordenada do último pixel do jogador:
    ;
    ;   player_x + PLAYER_WIDTH - 1
    ;
    ; Se esse pixel ainda estiver antes do limite esquerdo da
    ; cerca, não existe sobreposição horizontal.
    ;
    ; --------------------------------------------------------

    LDA player_x
    CLC
    ADC #PLAYER_WIDTH - 1
    CMP #FENCE_LEFT
    BCC no_fence_collision


    ; --------------------------------------------------------
    ; TESTE VERTICAL: jogador abaixo da cerca
    ; --------------------------------------------------------
    ;
    ; Se o topo do jogador estiver depois do limite inferior da
    ; cerca, não existe sobreposição vertical.
    ;
    ; --------------------------------------------------------

    LDA player_y
    CMP #FENCE_BOTTOM + 1
    BCS no_fence_collision


    ; --------------------------------------------------------
    ; TESTE VERTICAL: jogador acima da cerca
    ; --------------------------------------------------------
    ;
    ; Calcula a coordenada do último pixel vertical do jogador:
    ;
    ;   player_y + PLAYER_HEIGHT - 1
    ;
    ; Se esse pixel ainda estiver antes do topo da cerca, não
    ; existe sobreposição vertical.
    ;
    ; --------------------------------------------------------

    LDA player_y
    CLC
    ADC #PLAYER_HEIGHT - 1
    CMP #FENCE_TOP
    BCC no_fence_collision


    ; Nenhum dos testes descartou a colisão.
    ; Portanto, jogador e cerca estão sobrepostos.

    LDA #$01
    STA collision

no_fence_collision:

    RTS


; ============================================================
; VERIFICA COLISÃO ENTRE O JOGADOR E O INIMIGO
; ============================================================
;
; Compara as caixas de colisão do jogador e do inimigo.
;
; Antes dos testes de posição, a rotina verifica se os dois
; personagens estão ativos. Não faz sentido detectar colisão
; quando um deles já está morto ou removido da partida.
;
; A colisão é descartada quando:
;
;   1. o inimigo está completamente à esquerda do jogador;
;   2. o jogador está completamente à esquerda do inimigo;
;   3. o inimigo está completamente acima do jogador;
;   4. o jogador está completamente acima do inimigo.
;
; Caso nenhuma dessas condições seja verdadeira, existe
; sobreposição nos dois eixos.
;
; Entrada:
;
;   player_x
;   player_y
;   player_alive
;   enemy_x
;   enemy_y
;   enemy_alive
;
; Saída:
;
;   collision = 0 -> jogador e inimigo não colidiram
;   collision = 1 -> jogador e inimigo colidiram
;
; ============================================================

check_player_enemy_collision:

    ; Começa assumindo que não existe colisão.

    LDA #$00
    STA collision


    ; Ignora a verificação caso o jogador esteja morto.

    LDA player_alive
    BEQ no_player_enemy_collision


    ; Ignora a verificação caso o inimigo esteja morto.

    LDA enemy_alive
    BEQ no_player_enemy_collision


    ; --------------------------------------------------------
    ; TESTE HORIZONTAL: inimigo à esquerda do jogador
    ; --------------------------------------------------------
    ;
    ; Calcula a primeira coordenada depois do lado direito do
    ; inimigo:
    ;
    ;   enemy_x + ENEMY_WIDTH
    ;
    ; Se esse valor for menor ou igual a player_x, o inimigo
    ; termina antes de o jogador começar.
    ;
    ; O BCC trata o caso em que o resultado é menor.
    ; O BEQ trata o caso em que os objetos apenas se encostam.
    ;
    ; --------------------------------------------------------

    LDA enemy_x
    CLC
    ADC #ENEMY_WIDTH
    CMP player_x
    BCC no_player_enemy_collision
    BEQ no_player_enemy_collision


    ; --------------------------------------------------------
    ; TESTE HORIZONTAL: jogador à esquerda do inimigo
    ; --------------------------------------------------------
    ;
    ; Calcula o último pixel horizontal do jogador:
    ;
    ;   player_x + PLAYER_WIDTH - 1
    ;
    ; Se esse pixel estiver antes de enemy_x, não existe
    ; sobreposição horizontal.
    ;
    ; --------------------------------------------------------

    LDA player_x
    CLC
    ADC #PLAYER_WIDTH - 1
    CMP enemy_x
    BCC no_player_enemy_collision


    ; --------------------------------------------------------
    ; TESTE VERTICAL: inimigo acima do jogador
    ; --------------------------------------------------------
    ;
    ; Calcula a primeira coordenada depois da parte inferior do
    ; inimigo:
    ;
    ;   enemy_y + ENEMY_HEIGHT
    ;
    ; Se esse valor for menor ou igual a player_y, o inimigo
    ; termina antes de o jogador começar no eixo vertical.
    ;
    ; --------------------------------------------------------

    LDA enemy_y
    CLC
    ADC #ENEMY_HEIGHT
    CMP player_y
    BCC no_player_enemy_collision
    BEQ no_player_enemy_collision


    ; --------------------------------------------------------
    ; TESTE VERTICAL: jogador acima do inimigo
    ; --------------------------------------------------------
    ;
    ; Calcula o último pixel vertical do jogador:
    ;
    ;   player_y + PLAYER_HEIGHT - 1
    ;
    ; Se esse pixel estiver antes de enemy_y, não existe
    ; sobreposição vertical.
    ;
    ; --------------------------------------------------------

    LDA player_y
    CLC
    ADC #PLAYER_HEIGHT - 1
    CMP enemy_y
    BCC no_player_enemy_collision


    ; Existe sobreposição horizontal e vertical.

    LDA #$01
    STA collision

no_player_enemy_collision:

    RTS


; ============================================================
; VERIFICA COLISÃO ENTRE O PROJÉTIL E O INIMIGO
; ============================================================
;
; Compara a caixa de 8x8 pixels do projétil com a caixa de 24x24
; pixels do inimigo.
;
; A rotina só realiza os testes quando:
;
;   - existe um projétil ativo;
;   - o inimigo ainda está vivo.
;
; A colisão é descartada quando um dos objetos está completamente
; separado do outro em qualquer um dos eixos.
;
; Entrada:
;
;   projectile_x
;   projectile_y
;   projectile_active
;   enemy_x
;   enemy_y
;   enemy_alive
;
; Saída:
;
;   collision = 0 -> projétil não atingiu o inimigo
;   collision = 1 -> projétil atingiu o inimigo
;
; ============================================================

check_projectile_enemy_collision:

    ; Começa assumindo que não existe colisão.

    LDA #$00
    STA collision


    ; Não verifica colisão quando não existe projétil na tela.

    LDA projectile_active
    BEQ no_projectile_enemy_collision


    ; Não verifica colisão quando o inimigo já está morto.

    LDA enemy_alive
    BEQ no_projectile_enemy_collision


    ; --------------------------------------------------------
    ; TESTE HORIZONTAL: inimigo à esquerda do projétil
    ; --------------------------------------------------------
    ;
    ; Calcula a primeira coordenada depois do lado direito do
    ; inimigo:
    ;
    ;   enemy_x + ENEMY_WIDTH
    ;
    ; Se esse valor for menor ou igual a projectile_x, os objetos
    ; não se sobrepõem horizontalmente.
    ;
    ; --------------------------------------------------------

    LDA enemy_x
    CLC
    ADC #ENEMY_WIDTH
    CMP projectile_x
    BCC no_projectile_enemy_collision
    BEQ no_projectile_enemy_collision


    ; --------------------------------------------------------
    ; TESTE HORIZONTAL: projétil à esquerda do inimigo
    ; --------------------------------------------------------
    ;
    ; Calcula o último pixel horizontal do projétil:
    ;
    ;   projectile_x + PROJECTILE_WIDTH - 1
    ;
    ; Se esse pixel estiver antes de enemy_x, não existe colisão.
    ;
    ; --------------------------------------------------------

    LDA projectile_x
    CLC
    ADC #PROJECTILE_WIDTH - 1
    CMP enemy_x
    BCC no_projectile_enemy_collision


    ; --------------------------------------------------------
    ; TESTE VERTICAL: inimigo acima do projétil
    ; --------------------------------------------------------
    ;
    ; Calcula a primeira coordenada depois da parte inferior do
    ; inimigo:
    ;
    ;   enemy_y + ENEMY_HEIGHT
    ;
    ; Se esse valor for menor ou igual a projectile_y, não existe
    ; sobreposição vertical.
    ;
    ; --------------------------------------------------------

    LDA enemy_y
    CLC
    ADC #ENEMY_HEIGHT
    CMP projectile_y
    BCC no_projectile_enemy_collision
    BEQ no_projectile_enemy_collision


    ; --------------------------------------------------------
    ; TESTE VERTICAL: projétil acima do inimigo
    ; --------------------------------------------------------
    ;
    ; Calcula o último pixel vertical do projétil:
    ;
    ;   projectile_y + PROJECTILE_HEIGHT - 1
    ;
    ; Se esse pixel estiver antes de enemy_y, não existe colisão.
    ;
    ; --------------------------------------------------------

    LDA projectile_y
    CLC
    ADC #PROJECTILE_HEIGHT - 1
    CMP enemy_y
    BCC no_projectile_enemy_collision


    ; Existe sobreposição horizontal e vertical.

    LDA #$01
    STA collision

no_projectile_enemy_collision:

    RTS