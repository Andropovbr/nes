; ============================================================
; PROJECTILE.ASM
; ============================================================
;
; Controla o disparo do jogador.
;
; Este módulo é responsável por:
;
;   - detectar o pressionamento do botão A;
;   - impedir mais de um projétil simultâneo;
;   - criar o projétil na frente do jogador;
;   - armazenar a direção do disparo;
;   - mover o projétil;
;   - desativá-lo ao sair da tela;
;   - reproduzir o efeito sonoro;
;   - atualizar seu sprite na Shadow OAM.
;
; O estado lógico e o estado visual são separados:
;
;   projectile_active = 1 -> projétil existe
;   projectile_active = 0 -> projétil está inativo
;
; A rotina update_projectile_sprite transforma esse estado em
; dados para a OAM.
;
; ============================================================


; ============================================================
; CONFIGURAÇÃO DO PROJÉTIL
; ============================================================

; Tile utilizado para desenhar o projétil.

PROJECTILE_TILE = $19


; Quantidade de pixels percorridos por frame.
;
; Como o valor é 3, o projétil se move mais rapidamente que o
; jogador, que se desloca um pixel por frame.

PROJECTILE_SPEED = $03


; Máscara do botão A no formato usado por controller_pressed.

BUTTON_A = %10000000


; ============================================================
; ENDEREÇOS DO PROJÉTIL NA SHADOW OAM
; ============================================================
;
; O projétil utiliza um único sprite de hardware.
;
; Cada entrada da OAM possui quatro bytes:
;
;   Y
;   tile
;   atributos
;   X
;
; O projétil ocupa a entrada iniciada em $0248.
;
; ============================================================

PROJECTILE_OAM_Y          = $0248
PROJECTILE_OAM_TILE       = $0249
PROJECTILE_OAM_ATTRIBUTES = $024A
PROJECTILE_OAM_X          = $024B


; ============================================================
; VERIFICA A ENTRADA DE DISPARO
; ============================================================
;
; Um novo projétil só pode ser criado quando:
;
;   - o jogador está vivo;
;   - o botão A foi pressionado neste frame;
;   - não existe outro projétil ativo.
;
; controller_pressed é utilizado em vez de controller1.
;
; Dessa forma, segurar o botão A não cria um novo projétil a cada
; frame. O disparo acontece apenas no instante do pressionamento.
;
; ============================================================

check_projectile_input:

    ; Jogadores mortos não podem disparar.

    LDA player_alive
    BEQ check_projectile_input_done


    ; Verifica se o botão A foi pressionado neste frame.

    LDA controller_pressed
    AND #BUTTON_A
    BEQ check_projectile_input_done


    ; Esta demo permite apenas um projétil por vez.

    LDA projectile_active
    BNE check_projectile_input_done


    ; Todas as condições foram atendidas.

    JSR spawn_projectile


check_projectile_input_done:

    RTS


; ============================================================
; CRIA UM NOVO PROJÉTIL
; ============================================================
;
; O projétil herda a direção atual do jogador.
;
; Sua posição inicial é calculada para que ele apareça próximo ao
; centro vertical do personagem e ligeiramente à frente do sprite.
;
; player_direction:
;
;   0 -> direita
;   1 -> esquerda
;
; ============================================================

spawn_projectile:

    ; Guarda a direção no momento do disparo.
    ;
    ; Depois de lançado, o projétil continua nessa direção mesmo
    ; que o jogador se vire.

    LDA player_direction
    STA projectile_direction


    ; --------------------------------------------------------
    ; POSIÇÃO VERTICAL
    ; --------------------------------------------------------
    ;
    ; O jogador possui 24 pixels de altura.
    ;
    ; Somar 8 posiciona o projétil na linha central do sprite.
    ;
    ; --------------------------------------------------------

    LDA player_y

    CLC
    ADC #$08

    STA projectile_y


    ; Escolhe a posição horizontal com base na direção.

    LDA projectile_direction
    BNE spawn_projectile_left


; ============================================================
; POSICIONA O DISPARO À DIREITA
; ============================================================
;
; O jogador possui 24 pixels de largura.
;
; O deslocamento $14, equivalente a 20 pixels, posiciona o
; projétil próximo à frente direita do personagem.
;
; ============================================================

spawn_projectile_right:

    LDA player_x

    CLC
    ADC #$14

    STA projectile_x

    JMP activate_projectile


; ============================================================
; POSICIONA O DISPARO À ESQUERDA
; ============================================================
;
; O deslocamento de 4 pixels posiciona o projétil um pouco antes
; da borda esquerda do personagem.
;
; ============================================================

spawn_projectile_left:

    LDA player_x

    SEC
    SBC #$04

    STA projectile_x


; ============================================================
; ATIVA O PROJÉTIL
; ============================================================
;
; Marca o projétil como ativo e reproduz seu efeito sonoro.
;
; O efeito é enviado ao canal de efeitos sonoros 0 da engine
; FamiStudio.
;
; ============================================================

activate_projectile:

    LDA #$01
    STA projectile_active


    ; Reproduz o efeito associado ao disparo.

    LDA #sfx_megamanhit
    LDX #FAMISTUDIO_SFX_CH0

    JSR famistudio_sfx_play

    RTS


; ============================================================
; ATUALIZA O MOVIMENTO DO PROJÉTIL
; ============================================================
;
; A rotina só executa movimento quando projectile_active é 1.
;
; O projétil avança PROJECTILE_SPEED pixels por frame:
;
;   direita  -> soma à coordenada X
;   esquerda -> subtrai da coordenada X
;
; Ao alcançar uma das bordas, ele é desativado.
;
; ============================================================

update_projectile:

    ; Projéteis inativos não precisam ser atualizados.

    LDA projectile_active
    BEQ update_projectile_done


    ; Seleciona a direção do movimento.

    LDA projectile_direction
    BNE move_projectile_left


; ============================================================
; MOVE O PROJÉTIL PARA A DIREITA
; ============================================================
;
; Antes da soma, a posição é comparada com $FD.
;
; Isso evita que a adição de PROJECTILE_SPEED ultrapasse $FF e
; cause overflow, fazendo o projétil reaparecer no lado esquerdo.
;
; ============================================================

move_projectile_right:

    LDA projectile_x

    CMP #$FD
    BCS deactivate_projectile

    CLC
    ADC #PROJECTILE_SPEED

    STA projectile_x

    JMP update_projectile_done


; ============================================================
; MOVE O PROJÉTIL PARA A ESQUERDA
; ============================================================
;
; Antes da subtração, a posição é comparada com a velocidade.
;
; Se projectile_x for menor que PROJECTILE_SPEED, a próxima
; subtração causaria underflow e faria o valor voltar para perto
; de $FF.
;
; Nesse caso, o projétil é desativado.
;
; ============================================================

move_projectile_left:

    LDA projectile_x

    CMP #PROJECTILE_SPEED
    BCC deactivate_projectile

    SEC
    SBC #PROJECTILE_SPEED

    STA projectile_x

    JMP update_projectile_done


; ============================================================
; DESATIVA O PROJÉTIL
; ============================================================
;
; O projétil deixa de participar da lógica do jogo.
;
; A rotina update_projectile_sprite perceberá esse estado e
; esconderá seu sprite no próximo update.
;
; ============================================================

deactivate_projectile:

    LDA #$00
    STA projectile_active


update_projectile_done:

    RTS


; ============================================================
; ATUALIZA O SPRITE DO PROJÉTIL
; ============================================================
;
; Quando o projétil está ativo, seus quatro bytes são gravados na
; Shadow OAM:
;
;   Y
;   tile
;   atributos
;   X
;
; Quando está inativo, apenas sua coordenada Y é movida para fora
; da tela.
;
; ============================================================

update_projectile_sprite:

    LDA projectile_active
    BEQ hide_projectile_sprite


    ; --------------------------------------------------------
    ; COORDENADA Y
    ; --------------------------------------------------------

    LDA projectile_y
    STA PROJECTILE_OAM_Y


    ; --------------------------------------------------------
    ; TILE
    ; --------------------------------------------------------

    LDA #PROJECTILE_TILE
    STA PROJECTILE_OAM_TILE


    ; --------------------------------------------------------
    ; ATRIBUTOS
    ; --------------------------------------------------------
    ;
    ; $00 significa:
    ;
    ;   - paleta de sprite 0;
    ;   - sem flip;
    ;   - sprite à frente do background.
    ;
    ; --------------------------------------------------------

    LDA #$00
    STA PROJECTILE_OAM_ATTRIBUTES


    ; --------------------------------------------------------
    ; COORDENADA X
    ; --------------------------------------------------------

    LDA projectile_x
    STA PROJECTILE_OAM_X

    RTS


; ============================================================
; ESCONDE O SPRITE DO PROJÉTIL
; ============================================================
;
; O valor $FE coloca o sprite fora da região visível.
;
; Não é necessário apagar os demais bytes da entrada da OAM,
; porque um sprite com Y fora da tela não será desenhado.
;
; ============================================================

hide_projectile_sprite:

    LDA #$FE
    STA PROJECTILE_OAM_Y

    RTS