; ============================================================
; ENEMY.ASM
; ============================================================
;
; Controla o comportamento, a animação e a exibição do inimigo.
;
; O inimigo utiliza uma lógica simples de perseguição:
;
;   - compara sua posição com a posição do jogador;
;   - move um pixel no eixo horizontal;
;   - move um pixel no eixo vertical;
;   - repete o movimento após um pequeno intervalo.
;
; O personagem é formado por uma grade de 3x3 sprites de hardware,
; totalizando 24x24 pixels.
;
; O arquivo também é responsável por:
;
;   - controlar a velocidade da perseguição;
;   - atualizar os quadros da animação;
;   - inverter horizontalmente o sprite;
;   - esconder o inimigo quando ele morre;
;   - copiar posição, tiles e atributos para a Shadow OAM.
;
; ============================================================


; ============================================================
; VELOCIDADE DE MOVIMENTO
; ============================================================
;
; Define quantos frames precisam passar antes de o inimigo mover
; novamente.
;
; Com o valor $03, o inimigo desloca um pixel a cada três chamadas
; da rotina update_enemy.
;
; Valores maiores deixam o inimigo mais lento.
;
; ============================================================

ENEMY_MOVE_DELAY = $03


; ============================================================
; ATUALIZA O COMPORTAMENTO DO INIMIGO
; ============================================================
;
; Decide se o inimigo deve perseguir o jogador, permanecer parado
; ou deixar de ser atualizado.
;
; Quando o inimigo está vivo:
;
;   1. verifica se já alcançou a posição do jogador;
;   2. marca o inimigo como estando em movimento;
;   3. atualiza o contador de atraso;
;   4. move o inimigo quando o contador atinge o limite.
;
; Quando o inimigo está morto, enemy_moving é zerado e a rotina
; termina imediatamente.
;
; Entrada:
;
;   enemy_alive
;   enemy_x
;   enemy_y
;   player_x
;   player_y
;
; Saída:
;
;   enemy_x
;   enemy_y
;   enemy_direction
;   enemy_moving
;   enemy_move_counter
;
; ============================================================

update_enemy:

    ; Um inimigo morto não deve continuar perseguindo o jogador.

    LDA enemy_alive
    BNE update_living_enemy

    LDA #$00
    STA enemy_moving

    RTS


; ------------------------------------------------------------
; VERIFICA SE O INIMIGO JÁ ALCANÇOU O JOGADOR
; ------------------------------------------------------------
;
; O inimigo só fica parado quando as coordenadas X e Y forem
; exatamente iguais às coordenadas do jogador.
;
; ------------------------------------------------------------

update_living_enemy:

    LDA enemy_x
    CMP player_x
    BNE enemy_is_chasing

    LDA enemy_y
    CMP player_y
    BEQ enemy_stopped


; ------------------------------------------------------------
; CONTROLA O INTERVALO ENTRE OS MOVIMENTOS
; ------------------------------------------------------------
;
; enemy_moving indica que o inimigo está tentando alcançar o
; jogador, mesmo nos frames em que sua posição não é alterada.
;
; enemy_move_counter impede que ele se mova em todos os frames.
;
; ------------------------------------------------------------

enemy_is_chasing:

    LDA #$01
    STA enemy_moving

    INC enemy_move_counter

    LDA enemy_move_counter
    CMP #ENEMY_MOVE_DELAY
    BCC update_enemy_done


    ; O intervalo foi concluído.
    ; Zera o contador e executa um passo da perseguição.

    LDA #$00
    STA enemy_move_counter

    JMP enemy_chase_horizontal


; ------------------------------------------------------------
; INIMIGO PARADO
; ------------------------------------------------------------
;
; Quando as duas coordenadas coincidem com as do jogador, o
; inimigo interrompe o movimento e reinicia seu contador.
;
; ------------------------------------------------------------

enemy_stopped:

    LDA #$00
    STA enemy_moving
    STA enemy_move_counter

update_enemy_done:

    RTS


; ============================================================
; MOVE O INIMIGO NO EIXO HORIZONTAL
; ============================================================
;
; Compara enemy_x com player_x para decidir a direção:
;
;   enemy_x > player_x -> move para a esquerda
;   enemy_x < player_x -> move para a direita
;   enemy_x = player_x -> não move horizontalmente
;
; Depois do movimento horizontal, a rotina continua para a
; verificação do eixo vertical.
;
; ============================================================

enemy_chase_horizontal:

    LDA enemy_x
    CMP player_x

    ; Se as posições X já forem iguais, pula diretamente para o
    ; movimento vertical.

    BEQ enemy_chase_vertical

    ; Carry limpo significa enemy_x < player_x.

    BCC enemy_move_right


; ------------------------------------------------------------
; MOVE PARA A ESQUERDA
; ------------------------------------------------------------
;
; enemy_direction recebe 1 para indicar que o inimigo deve ser
; exibido olhando para a esquerda.
;
; ------------------------------------------------------------

enemy_move_left:

    DEC enemy_x

    LDA #$01
    STA enemy_direction

    JMP enemy_chase_vertical


; ------------------------------------------------------------
; MOVE PARA A DIREITA
; ------------------------------------------------------------
;
; enemy_direction recebe 0 para indicar que o inimigo deve ser
; exibido olhando para a direita.
;
; ------------------------------------------------------------

enemy_move_right:

    INC enemy_x

    LDA #$00
    STA enemy_direction


; ============================================================
; MOVE O INIMIGO NO EIXO VERTICAL
; ============================================================
;
; Compara enemy_y com player_y para decidir o movimento:
;
;   enemy_y > player_y -> move para cima
;   enemy_y < player_y -> move para baixo
;   enemy_y = player_y -> não move verticalmente
;
; Como os valores de Y aumentam de cima para baixo na tela:
;
;   DEC enemy_y -> sobe
;   INC enemy_y -> desce
;
; ============================================================

enemy_chase_vertical:

    LDA enemy_y
    CMP player_y

    BEQ update_enemy_done

    ; Carry limpo significa enemy_y < player_y.

    BCC enemy_move_down


; ------------------------------------------------------------
; MOVE PARA CIMA
; ------------------------------------------------------------

enemy_move_up:

    DEC enemy_y
    JMP update_enemy_done


; ------------------------------------------------------------
; MOVE PARA BAIXO
; ------------------------------------------------------------

enemy_move_down:

    INC enemy_y
    JMP update_enemy_done


; ============================================================
; ATUALIZA A ANIMAÇÃO DO INIMIGO
; ============================================================
;
; Controla a alternância entre os dois quadros da animação.
;
; A animação só é atualizada quando:
;
;   - o inimigo está vivo;
;   - o inimigo está se movimentando.
;
; enemy_anim_counter controla a duração de cada quadro.
; enemy_anim_frame indica o quadro atual:
;
;   0 -> tiles $06, $07 e $08 nos pés
;   1 -> tiles $09, $0A e $0B nos pés
;
; ============================================================

update_enemy_animation:

    ; Um inimigo morto não precisa ter sua animação atualizada.

    LDA enemy_alive
    BNE update_living_enemy_animation

    RTS


update_living_enemy_animation:

    LDA enemy_moving
    BNE enemy_is_moving


; ------------------------------------------------------------
; REINICIA A ANIMAÇÃO QUANDO O INIMIGO PARA
; ------------------------------------------------------------
;
; O inimigo parado sempre volta ao primeiro quadro.
;
; ------------------------------------------------------------

enemy_is_stopped:

    LDA #$00
    STA enemy_anim_counter
    STA enemy_anim_frame

    RTS


; ------------------------------------------------------------
; AVANÇA O CONTADOR DA ANIMAÇÃO
; ------------------------------------------------------------
;
; Cada quadro permanece ativo durante oito chamadas desta rotina.
;
; ------------------------------------------------------------

enemy_is_moving:

    INC enemy_anim_counter

    LDA enemy_anim_counter
    CMP #$08
    BCC enemy_animation_done


    ; O quadro atual terminou.

    LDA #$00
    STA enemy_anim_counter

    INC enemy_anim_frame


    ; Existem apenas dois quadros: 0 e 1.
    ; Ao chegar em 2, retorna para o quadro 0.

    LDA enemy_anim_frame
    CMP #$02
    BCC enemy_animation_done

    LDA #$00
    STA enemy_anim_frame

enemy_animation_done:

    RTS


; ============================================================
; ESCONDE O SPRITE DO INIMIGO
; ============================================================
;
; O inimigo utiliza nove entradas consecutivas da Shadow OAM,
; começando em $0224.
;
; Cada entrada ocupa quatro bytes:
;
;   Y, tile, atributos, X
;
; Para esconder um sprite, basta colocar sua coordenada Y fora da
; área visível da tela.
;
; O valor $FE é gravado no byte Y das nove partes do inimigo.
;
; ============================================================

hide_enemy_sprite:

    LDA #$FE

    STA $0224
    STA $0228
    STA $022C

    STA $0230
    STA $0234
    STA $0238

    STA $023C
    STA $0240
    STA $0244

    RTS


; ============================================================
; ATUALIZA O SPRITE COMPOSTO DO INIMIGO
; ============================================================
;
; Atualiza as nove partes de 8x8 pixels que formam o inimigo.
;
; Para cada parte, a rotina grava na Shadow OAM:
;
;   Byte 0 -> coordenada Y
;   Byte 1 -> tile
;   Byte 2 -> atributos
;   Byte 3 -> coordenada X
;
; O registrador Y percorre as tabelas de dados do sprite.
; O registrador X percorre os bytes da Shadow OAM.
;
; Ao final, a rotina atualiza os tiles dos pés de acordo com o
; quadro atual da animação.
;
; ============================================================

update_enemy_sprite:

    ; Se o inimigo estiver morto, remove suas nove partes da tela.

    LDA enemy_alive
    BNE update_visible_enemy_sprite

    JSR hide_enemy_sprite

    RTS


update_visible_enemy_sprite:

    ; X começa no primeiro byte da área do inimigo na Shadow OAM.
    ;
    ; Como o endereço base já aparece nas instruções $0224,x,
    ; X começa em zero.

    LDX #$00


    ; Y indica qual das nove partes está sendo processada.

    LDY #$00


update_enemy_sprite_loop:

    ; --------------------------------------------------------
    ; COORDENADA Y
    ; --------------------------------------------------------
    ;
    ; Soma a posição principal do inimigo ao deslocamento vertical
    ; da parte atual.
    ;
    ; --------------------------------------------------------

    LDA enemy_y_offsets, y
    CLC
    ADC enemy_y
    STA $0224, x


    ; --------------------------------------------------------
    ; TILE
    ; --------------------------------------------------------
    ;
    ; Carrega o tile base correspondente à parte atual.
    ;
    ; Os tiles da linha inferior poderão ser substituídos depois
    ; pela rotina de animação.
    ;
    ; --------------------------------------------------------

    LDA enemy_tiles, y
    STA $0225, x


    ; --------------------------------------------------------
    ; ATRIBUTOS
    ; --------------------------------------------------------
    ;
    ; $01 = paleta de sprites 1, sem inversão horizontal
    ; $41 = paleta de sprites 1, com inversão horizontal
    ;
    ; O bit 6 controla o flip horizontal do sprite.
    ;
    ; --------------------------------------------------------

    LDA enemy_direction
    BEQ enemy_attribute_right

enemy_attribute_left:

    LDA #$41
    JMP store_enemy_attribute

enemy_attribute_right:

    LDA #$01

store_enemy_attribute:

    STA $0226, x


    ; --------------------------------------------------------
    ; COORDENADA X
    ; --------------------------------------------------------
    ;
    ; O deslocamento horizontal depende da direção.
    ;
    ; Para olhar para a esquerda, além do flip horizontal, a ordem
    ; das colunas também é invertida:
    ;
    ;   direita:  $00, $08, $10
    ;   esquerda: $10, $08, $00
    ;
    ; Isso mantém cada tile na posição correta dentro do sprite
    ; composto depois da inversão.
    ;
    ; --------------------------------------------------------

    LDA enemy_direction
    BEQ enemy_position_right

enemy_position_left:

    LDA enemy_x_offsets_left, y
    JMP calculate_enemy_x

enemy_position_right:

    LDA enemy_x_offsets_right, y

calculate_enemy_x:

    CLC
    ADC enemy_x
    STA $0227, x


    ; Avança quatro bytes na Shadow OAM, chegando à próxima
    ; entrada de sprite.

    INX
    INX
    INX
    INX


    ; Avança para a próxima parte nas tabelas.

    INY
    CPY #$09
    BNE update_enemy_sprite_loop


    ; Depois de posicionar as nove partes, troca os tiles da linha
    ; inferior conforme o quadro atual da animação.

    JSR update_enemy_animation_tiles

    RTS


; ============================================================
; ATUALIZA OS TILES ANIMADOS DOS PÉS
; ============================================================
;
; Apenas a linha inferior do inimigo é animada.
;
; As duas linhas superiores permanecem com os mesmos tiles.
;
; Endereços dos tiles da última linha na Shadow OAM:
;
;   $023D -> parte inferior esquerda
;   $0241 -> parte inferior central
;   $0245 -> parte inferior direita
;
; Quadros:
;
;   quadro 0 -> $06, $07, $08
;   quadro 1 -> $09, $0A, $0B
;
; ============================================================

update_enemy_animation_tiles:

    LDA enemy_anim_frame
    BEQ enemy_anim_frame_0


; ------------------------------------------------------------
; QUADRO 1
; ------------------------------------------------------------

enemy_anim_frame_1:

    LDA #$09
    STA $023D

    LDA #$0A
    STA $0241

    LDA #$0B
    STA $0245

    RTS


; ------------------------------------------------------------
; QUADRO 0
; ------------------------------------------------------------

enemy_anim_frame_0:

    LDA #$06
    STA $023D

    LDA #$07
    STA $0241

    LDA #$08
    STA $0245

    RTS


; ============================================================
; TILES BASE DO INIMIGO
; ============================================================
;
; Define os nove tiles usados pelo sprite composto em uma grade
; de 3x3.
;
; Organização:
;
;   $00  $01  $02
;   $03  $04  $05
;   $06  $07  $08
;
; A linha inferior representa o primeiro quadro da animação.
;
; ============================================================

enemy_tiles:

    .byte $00, $01, $02
    .byte $03, $04, $05
    .byte $06, $07, $08


; ============================================================
; DESLOCAMENTOS VERTICAIS
; ============================================================
;
; Define a posição Y de cada parte em relação a enemy_y.
;
; As três primeiras partes ficam na linha superior.
; As três seguintes ficam oito pixels abaixo.
; As três últimas ficam dezesseis pixels abaixo.
;
; ============================================================

enemy_y_offsets:

    .byte $00, $00, $00
    .byte $08, $08, $08
    .byte $10, $10, $10


; ============================================================
; DESLOCAMENTOS HORIZONTAIS — OLHANDO PARA A DIREITA
; ============================================================
;
; Distribui as três colunas nas posições:
;
;   0, 8 e 16 pixels em relação a enemy_x.
;
; ============================================================

enemy_x_offsets_right:

    .byte $00, $08, $10
    .byte $00, $08, $10
    .byte $00, $08, $10


; ============================================================
; DESLOCAMENTOS HORIZONTAIS — OLHANDO PARA A ESQUERDA
; ============================================================
;
; Inverte a ordem das colunas para acompanhar o flip horizontal:
;
;   16, 8 e 0 pixels em relação a enemy_x.
;
; Sem essa inversão, cada tile seria espelhado individualmente,
; mas a disposição geral das partes continuaria na ordem original.
;
; ============================================================

enemy_x_offsets_left:

    .byte $10, $08, $00
    .byte $10, $08, $00
    .byte $10, $08, $00
