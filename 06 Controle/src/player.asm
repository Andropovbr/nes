; ------------------------------------------------------------
; ATUALIZA JOGADOR
; ------------------------------------------------------------

update_player:

    LDA #$00
    STA player_moving

check_right:

    LDA controller1
    AND #%00000001
    BEQ check_left

    INC player_x

    LDA #$01
    STA player_moving
    
    ;Vira personagem para a direita
    LDA #$00
    STA player_direction

check_left:

    LDA controller1
    AND #%00000010
    BEQ check_down

    DEC player_x

    LDA #$01
    STA player_moving

    ;Vira personagem para a esquerda
    STA player_direction

check_down:

    LDA controller1
    AND #%00000100
    BEQ check_up

    INC player_y

    LDA #$01
    STA player_moving

check_up:

    LDA controller1
    AND #%00001000
    BEQ update_player_done

    DEC player_y

    LDA #$01
    STA player_moving

update_player_done:

    RTS

; ------------------------------------------------------------
; ATUALIZA ANIMAÇÃO DO JOGADOR
; ------------------------------------------------------------
;
; A animação só avança quando o jogador está se movendo.
; ------------------------------------------------------------

update_player_animation:

    LDA player_moving
    BNE player_is_moving

player_is_stopped:

    LDA #$00
    STA anim_counter
    STA anim_frame

    RTS

player_is_moving:

    INC anim_counter

    LDA anim_counter
    CMP #$08                ; velocidade da animação
    BCC animation_done

    LDA #$00
    STA anim_counter

    INC anim_frame

    LDA anim_frame
    CMP #$02                ; temos 2 frames de animação
    BCC animation_done

    LDA #$00
    STA anim_frame

animation_done:

    RTS