; ------------------------------------------------------------
; CONFIGURAÇÕES DO INIMIGO
; ------------------------------------------------------------

ENEMY_MOVE_DELAY = $03          ; Inimigo anda a cada 3 frames


; ------------------------------------------------------------
; ATUALIZA A IA DO INIMIGO
; ------------------------------------------------------------
;
; O inimigo compara sua posição com a posição do jogador.
;
; Se estiver à esquerda, anda para a direita.
; Se estiver à direita, anda para a esquerda.
; Se estiver acima, anda para baixo.
; Se estiver abaixo, anda para cima.
;
; ------------------------------------------------------------

update_enemy:

    ; O inimigo continua sendo considerado em movimento
    ; enquanto ainda não alcançou o jogador.

    LDA enemy_x
    CMP player_x
    BNE enemy_is_chasing

    LDA enemy_y
    CMP player_y
    BEQ enemy_stopped


enemy_is_chasing:

    LDA #$01                    ; O inimigo ainda está perseguindo o jogador
    STA enemy_moving            ; Marca que ele está em movimento

    INC enemy_move_counter      ; Conta mais um frame desde o último passo

    LDA enemy_move_counter      ; Carrega o valor atual do contador
    CMP #ENEMY_MOVE_DELAY       ; Já esperou a quantidade de frames desejada?
    BCC update_enemy_done       ; Se ainda não, termina a rotina sem mover

    LDA #$00                    ; Reinicia o contador de velocidade
    STA enemy_move_counter      ; Começa a contar novamente

    JMP enemy_chase_horizontal  ; Agora o inimigo pode dar um passo


enemy_stopped:

    LDA #$00
    STA enemy_moving
    STA enemy_move_counter


update_enemy_done:

    RTS


; ------------------------------------------------------------
; PERSEGUE O JOGADOR NO EIXO X
; ------------------------------------------------------------

enemy_chase_horizontal:

    LDA enemy_x                 ; Carrega a posição X do inimigo
    CMP player_x                ; Compara com a posição X do jogador

    BEQ enemy_chase_vertical    ; Se estiverem alinhados no eixo X,
                                ; passa para a perseguição vertical

    BCC enemy_move_right        ; Se enemy_x < player_x,
                                ; move o inimigo para a direita

; ------------------------------------------------------------
; MOVE O INIMIGO PARA A ESQUERDA
; ------------------------------------------------------------

enemy_move_left:

    DEC enemy_x                 ; Diminui a coordenada X em 1 pixel

    LDA #$01                    ; 1 = personagem olhando para a esquerda
    STA enemy_direction         ; Atualiza a direção do inimigo

    JMP enemy_chase_vertical    ; Depois verifica se também precisa
                                ; mover no eixo Y

; ------------------------------------------------------------
; MOVE O INIMIGO PARA A DIREITA
; ------------------------------------------------------------

enemy_move_right:

    INC enemy_x                 ; Aumenta a coordenada X em 1 pixel

    LDA #$00                    ; 0 = personagem olhando para a direita
    STA enemy_direction         ; Atualiza a direção do inimigo


; ------------------------------------------------------------
; PERSEGUE O JOGADOR NO EIXO Y
; ------------------------------------------------------------

enemy_chase_vertical:

    LDA enemy_y                 ; Carrega a posição Y do inimigo
    CMP player_y                ; Compara com a posição Y do jogador

    BEQ update_enemy_done       ; Se estiverem alinhados no eixo Y,
                                ; não é necessário mover

    BCC enemy_move_down         ; Se enemy_y < player_y,
                                ; move o inimigo para baixo

; ------------------------------------------------------------
; MOVE O INIMIGO PARA CIMA
; ------------------------------------------------------------

enemy_move_up:

    DEC enemy_y                 ; Diminui a coordenada Y em 1 pixel,
                                ; movendo o inimigo para cima

    JMP update_enemy_done       ; Finaliza a atualização deste frame

; ------------------------------------------------------------
; MOVE O INIMIGO PARA BAIXO
; ------------------------------------------------------------

enemy_move_down:

    INC enemy_y                 ; Aumenta a coordenada Y em 1 pixel,
                                ; movendo o inimigo para baixo

    JMP update_enemy_done       ; Finaliza a atualização deste frame


; ------------------------------------------------------------
; ATUALIZA A ANIMAÇÃO DO INIMIGO
; ------------------------------------------------------------
;
; A animação só avança enquanto o inimigo estiver perseguindo
; o jogador. Se ele parar, a animação volta para o frame
; inicial.
;
; ------------------------------------------------------------

update_enemy_animation:

    LDA enemy_moving            ; Verifica se o inimigo está se movendo
    BNE enemy_is_moving         ; Se estiver, atualiza a animação

enemy_is_stopped:

    LDA #$00                    ; Inimigo parado usa o frame inicial
    STA enemy_anim_counter      ; Reinicia o contador da animação
    STA enemy_anim_frame        ; Reinicia o frame atual

    RTS                         ; Retorna sem avançar a animação

enemy_is_moving:

    INC enemy_anim_counter      ; Incrementa o contador da animação

    LDA enemy_anim_counter      ; Carrega o valor atual do contador
    CMP #$08                    ; A animação só avança a cada 8 frames
    BCC enemy_animation_done    ; Se ainda não chegou em 8, termina

    LDA #$00                    ; Reinicia o contador da animação
    STA enemy_anim_counter

    INC enemy_anim_frame        ; Avança para o próximo frame

    LDA enemy_anim_frame        ; Carrega o frame atual
    CMP #$02                    ; Existem apenas dois frames: 0 e 1
    BCC enemy_animation_done    ; Se ainda for menor que 2, mantém

    LDA #$00                    ; Se passou do último frame,
    STA enemy_anim_frame        ; volta para o frame inicial

enemy_animation_done:

    RTS                         ; Retorna para quem chamou


; ------------------------------------------------------------
; ATUALIZA OS SPRITES DO INIMIGO
; ------------------------------------------------------------
;
; Jogador:
;     $0200-$0223
;
; Inimigo:
;     $0224-$0247
;
; X = deslocamento dentro da área da OAM do inimigo
; Y = índice do sprite, de 0 até 8
;
; ------------------------------------------------------------

update_enemy_sprite:

    LDX #$00                    ; Deslocamento na OAM
    LDY #$00                    ; Índice do sprite

update_enemy_sprite_loop:

    ; --------------------------------------------------------
    ; Coordenada Y
    ; --------------------------------------------------------

    LDA enemy_y_offsets, y      ; Carrega o deslocamento vertical do sprite atual
    CLC                         ; Limpa o carry antes da soma
    ADC enemy_y                 ; Soma o deslocamento à posição Y base do inimigo
    STA $0224, x                ; Armazena a coordenada Y na OAM shadow

    ; --------------------------------------------------------
    ; Tile
    ; --------------------------------------------------------

    LDA enemy_tiles, y          ; Carrega o número do tile do sprite atual
    STA $0225, x                ; Armazena o tile na OAM shadow

    ; --------------------------------------------------------
    ; Atributos
    ; --------------------------------------------------------
    ;
    ; $01 = paleta 1, sem flip
    ; $41 = paleta 1, com flip horizontal
    ;
    ; --------------------------------------------------------

    LDA enemy_direction         ; Carrega a direção horizontal do inimigo
    BEQ enemy_attribute_right   ; Se for 0, o inimigo está olhando para a direita

enemy_attribute_left:

    LDA #$41                    ; Seleciona a paleta 1 e ativa o flip horizontal
    JMP store_enemy_attribute   ; Pula para o armazenamento do atributo

enemy_attribute_right:

    LDA #$01                    ; Seleciona a paleta 1 sem aplicar flip horizontal

store_enemy_attribute:

    STA $0226, x                ; Armazena os atributos do sprite na OAM shadow

    ; --------------------------------------------------------
    ; Coordenada X
    ; --------------------------------------------------------

    LDA enemy_direction         ; Verifica novamente a direção do inimigo
    BEQ enemy_position_right    ; Se for 0, usa a tabela para olhar à direita

enemy_position_left:

    LDA enemy_x_offsets_left, y ; Carrega o deslocamento X para o sprite invertido
    JMP calculate_enemy_x       ; Pula para o cálculo da posição final

enemy_position_right:

    LDA enemy_x_offsets_right, y ; Carrega o deslocamento X para o sprite normal

calculate_enemy_x:

    CLC                         ; Limpa o carry antes da soma
    ADC enemy_x                 ; Soma o deslocamento à posição X base do inimigo
    STA $0227, x                ; Armazena a coordenada X na OAM shadow

    ; Cada sprite da OAM possui quatro bytes:
    ;
    ; byte 0 = Y
    ; byte 1 = tile
    ; byte 2 = atributos
    ; byte 3 = X

    INX                         ; Avança um byte na OAM shadow
    INX                         ; Avança mais um byte
    INX                         ; Avança mais um byte
    INX                         ; Total de 4 bytes: próximo sprite

    INY                         ; Avança para o próximo item das tabelas
    CPY #$09                    ; Já processou os 9 sprites do inimigo?
    BNE update_enemy_sprite_loop ; Se não, continua o loop

    JSR update_enemy_animation_tiles ; Ajusta os tiles dos pés conforme o frame

    RTS                         ; Retorna para quem chamou


; ------------------------------------------------------------
; ATUALIZA OS TILES DOS PÉS DO INIMIGO
; ------------------------------------------------------------

update_enemy_animation_tiles:

    LDA enemy_anim_frame
    BEQ enemy_anim_frame_0

enemy_anim_frame_1:

    LDA #$09
    STA $023D                  ; Tile do sprite 7

    LDA #$0A
    STA $0241                  ; Tile do sprite 8

    LDA #$0B
    STA $0245                  ; Tile do sprite 9

    RTS

enemy_anim_frame_0:

    LDA #$06
    STA $023D

    LDA #$07
    STA $0241

    LDA #$08
    STA $0245

    RTS


; ------------------------------------------------------------
; TILES DO INIMIGO
; ------------------------------------------------------------
;
; Os tiles são os mesmos usados pelo jogador.
; Os três últimos serão alterados pela animação.
;
; ------------------------------------------------------------

enemy_tiles:

    .byte $00, $01, $02
    .byte $03, $04, $05
    .byte $06, $07, $08


; ------------------------------------------------------------
; DESLOCAMENTOS VERTICAIS
; ------------------------------------------------------------

enemy_y_offsets:

    .byte $00, $00, $00        ; Linha 1
    .byte $08, $08, $08        ; Linha 2
    .byte $10, $10, $10        ; Linha 3


; ------------------------------------------------------------
; DESLOCAMENTOS HORIZONTAIS — DIREITA
; ------------------------------------------------------------

enemy_x_offsets_right:

    .byte $00, $08, $10
    .byte $00, $08, $10
    .byte $00, $08, $10


; ------------------------------------------------------------
; DESLOCAMENTOS HORIZONTAIS — ESQUERDA
; ------------------------------------------------------------
;
; As posições são invertidas porque todos os tiles recebem
; flip horizontal.
;
; ------------------------------------------------------------

enemy_x_offsets_left:

    .byte $10, $08, $00
    .byte $10, $08, $00
    .byte $10, $08, $00