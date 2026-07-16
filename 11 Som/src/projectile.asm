; ------------------------------------------------------------
; CONFIGURAÇÕES DO PROJÉTIL
; ------------------------------------------------------------

PROJECTILE_TILE  = $19          ; Tile do projétil na CHR ROM
PROJECTILE_SPEED = $03          ; Velocidade horizontal: 3 pixels por frame

BUTTON_A = %10000000            ; Bit do botão A em controller_pressed


; ------------------------------------------------------------
; POSIÇÃO DO PROJÉTIL NA OAM SHADOW
; ------------------------------------------------------------
;
; Jogador:
;
;     $0200-$0223
;
; Inimigo:
;
;     $0224-$0247
;
; O projétil utiliza o próximo sprite disponível:
;
;     $0248 = coordenada Y
;     $0249 = número do tile
;     $024A = atributos
;     $024B = coordenada X
;
; ------------------------------------------------------------

PROJECTILE_OAM_Y          = $0248
PROJECTILE_OAM_TILE       = $0249
PROJECTILE_OAM_ATTRIBUTES = $024A
PROJECTILE_OAM_X          = $024B


; ------------------------------------------------------------
; VERIFICA SE O JOGADOR DISPAROU
; ------------------------------------------------------------
;
; O disparo acontece somente quando:
;
; 1. O jogador está vivo
; 2. O botão A acabou de ser pressionado
; 3. Não existe outro projétil ativo
;
; Apenas um projétil pode existir por vez.
;
; ------------------------------------------------------------

check_projectile_input:

    ; Jogador morto não pode disparar.

    LDA player_alive
    BEQ check_projectile_input_done

    ; Verifica se A acabou de ser pressionado.

    LDA controller_pressed
    AND #BUTTON_A
    BEQ check_projectile_input_done

    ; Verifica se já existe um projétil na tela.

    LDA projectile_active
    BNE check_projectile_input_done

    ; Cria o novo projétil.

    JSR spawn_projectile

check_projectile_input_done:

    RTS


; ------------------------------------------------------------
; CRIA UM NOVO PROJÉTIL
; ------------------------------------------------------------
;
; O projétil nasce aproximadamente no centro vertical do
; jogador.
;
; Horizontalmente, ele nasce próximo à frente do personagem,
; dependendo da direção para a qual o jogador está olhando.
;
; player_direction:
;
;     0 = olhando para a direita
;     1 = olhando para a esquerda
;
; ------------------------------------------------------------

spawn_projectile:

    ; Copia a direção atual do jogador.
    ;
    ; Depois de disparado, o projétil continua seguindo essa
    ; direção mesmo que o jogador vire para o outro lado.

    LDA player_direction
    STA projectile_direction

    ; --------------------------------------------------------
    ; Coordenada Y
    ; --------------------------------------------------------
    ;
    ; O jogador possui 24 pixels de altura.
    ;
    ; Somamos 8 para posicionar o projétil aproximadamente
    ; no meio do personagem.
    ;
    ; --------------------------------------------------------

    LDA player_y
    CLC
    ADC #$08
    STA projectile_y

    ; --------------------------------------------------------
    ; Coordenada X
    ; --------------------------------------------------------

    LDA projectile_direction
    BNE spawn_projectile_left

; ------------------------------------------------------------
; DISPARO PARA A DIREITA
; ------------------------------------------------------------
;
; O projétil nasce 20 pixels depois da coordenada base do
; jogador.
;
; O jogador tem 24 pixels de largura. Usamos 20 para manter
; o projétil próximo da frente sem correr o risco de a soma
; ultrapassar $FF quando o jogador estiver no limite direito.
;
; ------------------------------------------------------------

spawn_projectile_right:

    LDA player_x
    CLC
    ADC #$14
    STA projectile_x

    JMP activate_projectile


; ------------------------------------------------------------
; DISPARO PARA A ESQUERDA
; ------------------------------------------------------------
;
; O projétil nasce quatro pixels antes da coordenada base
; do jogador.
;
; PLAYER_MIN_X atualmente é $07, portanto a subtração de
; quatro pixels não causa underflow.
;
; ------------------------------------------------------------

spawn_projectile_left:

    LDA player_x
    SEC
    SBC #$04
    STA projectile_x


; ------------------------------------------------------------
; ATIVA O PROJÉTIL
; ------------------------------------------------------------

activate_projectile:

    LDA #$01
    STA projectile_active

    ; --------------------------------------------------------
    ; TOCA O EFEITO DO DISPARO
    ; --------------------------------------------------------
    ;
    ; A recebe o índice do efeito.
    ; X recebe o canal lógico de SFX da engine.
    ;
    ; O nome da constante depende do arquivo .inc exportado.
    ;
    ; --------------------------------------------------------

    LDA #SFX_MUSHROOM
    LDX #FAMISTUDIO_SFX_CH0
    JSR famistudio_sfx_play

    RTS


; ------------------------------------------------------------
; ATUALIZA O PROJÉTIL
; ------------------------------------------------------------
;
; Move o projétil horizontalmente conforme a direção salva
; em projectile_direction.
;
; Se não houver projétil ativo, a rotina termina sem fazer
; nenhuma alteração.
;
; ------------------------------------------------------------

update_projectile:

    LDA projectile_active
    BEQ update_projectile_done

    LDA projectile_direction
    BNE move_projectile_left


; ------------------------------------------------------------
; MOVE O PROJÉTIL PARA A DIREITA
; ------------------------------------------------------------
;
; Antes de somar a velocidade, verificamos se o projétil
; está próximo da borda direita.
;
; Como a velocidade é 3, qualquer posição maior ou igual
; a $FD causaria overflow na soma.
;
; Nessa situação, o projétil é desativado.
;
; ------------------------------------------------------------

move_projectile_right:

    LDA projectile_x
    CMP #$FD
    BCS deactivate_projectile

    CLC
    ADC #PROJECTILE_SPEED
    STA projectile_x

    JMP update_projectile_done


; ------------------------------------------------------------
; MOVE O PROJÉTIL PARA A ESQUERDA
; ------------------------------------------------------------
;
; Se projectile_x for menor que a velocidade, a subtração
; causaria underflow e o projétil reapareceria no lado direito.
;
; Por isso, nesses casos o projétil é desativado.
;
; ------------------------------------------------------------

move_projectile_left:

    LDA projectile_x
    CMP #PROJECTILE_SPEED
    BCC deactivate_projectile

    SEC
    SBC #PROJECTILE_SPEED
    STA projectile_x

    JMP update_projectile_done


; ------------------------------------------------------------
; DESATIVA O PROJÉTIL
; ------------------------------------------------------------

deactivate_projectile:

    LDA #$00
    STA projectile_active


update_projectile_done:

    RTS


; ------------------------------------------------------------
; ATUALIZA O SPRITE DO PROJÉTIL
; ------------------------------------------------------------
;
; Quando o projétil está ativo, escreve seus dados na OAM
; shadow.
;
; Quando está inativo, coloca sua coordenada Y em $FE,
; escondendo o sprite fora da tela.
;
; O tile pode possuir somente 2x2 pixels desenhados, mas
; continua ocupando uma célula de sprite de 8x8 pixels.
;
; Os demais pixels do tile precisam estar transparentes.
;
; ------------------------------------------------------------

update_projectile_sprite:

    LDA projectile_active
    BEQ hide_projectile_sprite

    ; Coordenada Y.

    LDA projectile_y
    STA PROJECTILE_OAM_Y

    ; Tile gráfico.

    LDA #PROJECTILE_TILE
    STA PROJECTILE_OAM_TILE

    ; Atributos:
    ;
    ; bit 0-1 = paleta 0
    ; sem prioridade especial
    ; sem flip horizontal
    ; sem flip vertical

    LDA #$00
    STA PROJECTILE_OAM_ATTRIBUTES

    ; Coordenada X.

    LDA projectile_x
    STA PROJECTILE_OAM_X

    RTS


; ------------------------------------------------------------
; ESCONDE O SPRITE DO PROJÉTIL
; ------------------------------------------------------------

hide_projectile_sprite:

    LDA #$FE
    STA PROJECTILE_OAM_Y

    RTS