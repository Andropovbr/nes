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

    LDA #$01
    STA enemy_moving

    ; Incrementa o contador de velocidade.

    INC enemy_move_counter

    ; Ainda não chegou ao frame de movimento?

    LDA enemy_move_counter
    CMP #ENEMY_MOVE_DELAY
    BCC update_enemy_done

    ; Chegou ao delay: zera o contador e permite um passo.

    LDA #$00
    STA enemy_move_counter

    JMP enemy_chase_horizontal


enemy_stopped:

    LDA #$00
    STA enemy_moving
    STA enemy_move_counter


update_enemy_done:

    RTS


; ------------------------------------------------------------
; PERSEGUE NO EIXO X
; ------------------------------------------------------------

enemy_chase_horizontal:

    LDA enemy_x
    CMP player_x
    BEQ enemy_chase_vertical
    BCC enemy_move_right

enemy_move_left:

    DEC enemy_x

    LDA #$01
    STA enemy_direction

    JMP enemy_chase_vertical

enemy_move_right:

    INC enemy_x

    LDA #$00
    STA enemy_direction


; ------------------------------------------------------------
; PERSEGUE NO EIXO Y
; ------------------------------------------------------------

enemy_chase_vertical:

    LDA enemy_y
    CMP player_y
    BEQ update_enemy_done
    BCC enemy_move_down

enemy_move_up:

    DEC enemy_y
    JMP update_enemy_done

enemy_move_down:

    INC enemy_y
    JMP update_enemy_done                 ; Aumenta Y para descer


; ------------------------------------------------------------
; ATUALIZA A ANIMAÇÃO DO INIMIGO
; ------------------------------------------------------------

update_enemy_animation:

    LDA enemy_moving
    BNE enemy_is_moving

enemy_is_stopped:

    LDA #$00
    STA enemy_anim_counter
    STA enemy_anim_frame

    RTS

enemy_is_moving:

    INC enemy_anim_counter

    LDA enemy_anim_counter
    CMP #$08
    BCC enemy_animation_done

    LDA #$00
    STA enemy_anim_counter

    INC enemy_anim_frame

    LDA enemy_anim_frame
    CMP #$02
    BCC enemy_animation_done

    LDA #$00
    STA enemy_anim_frame

enemy_animation_done:

    RTS


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

    LDA enemy_y_offsets, y
    CLC
    ADC enemy_y
    STA $0224, x

    ; --------------------------------------------------------
    ; Tile
    ; --------------------------------------------------------

    LDA enemy_tiles, y
    STA $0225, x

    ; --------------------------------------------------------
    ; Atributos
    ; --------------------------------------------------------
    ;
    ; $01 = paleta 1, sem flip
    ; $41 = paleta 1, com flip horizontal
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
    ; Coordenada X
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

    ; Próximo sprite: cada entrada da OAM possui quatro bytes.

    INX
    INX
    INX
    INX

    INY
    CPY #$09
    BNE update_enemy_sprite_loop

    JSR update_enemy_animation_tiles

    RTS


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