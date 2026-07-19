; ============================================================
; PLAYER.ASM
; ============================================================
;
; Controla o movimento e a animação do jogador.
;
; Este módulo é responsável por:
;
;   - verificar se o jogador está vivo;
;   - ler as direções do controle;
;   - limitar o movimento às bordas da tela;
;   - impedir que o jogador atravesse a cerca;
;   - armazenar a direção em que o jogador está olhando;
;   - indicar se houve movimento no frame;
;   - atualizar a animação de caminhada.
;
; O desenho do sprite composto é realizado pelas rotinas
; localizadas em ppu.asm.
;
; ============================================================


; ============================================================
; LIMITES DE MOVIMENTO DO JOGADOR
; ============================================================
;
; O jogador possui um sprite composto de 24x24 pixels.
;
; Estes valores limitam a posição da coordenada superior esquerda
; do personagem, impedindo que ele saia da região jogável.
;
; ============================================================

PLAYER_MIN_X = $07
PLAYER_MAX_X = $E8

PLAYER_MIN_Y = $00
PLAYER_MAX_Y = $D8


; ============================================================
; ATUALIZA O JOGADOR
; ============================================================
;
; A rotina verifica inicialmente se o jogador está vivo.
;
; Caso esteja morto:
;
;   - nenhum movimento é processado;
;   - player_moving recebe zero;
;   - a rotina termina.
;
; Caso esteja vivo, o código verifica as quatro direções.
;
; Como cada direção é processada separadamente, duas direções
; podem ser aceitas no mesmo frame, permitindo movimento diagonal.
;
; ============================================================

update_player:

    ; Jogadores mortos não podem se mover.

    LDA player_alive
    BNE update_living_player

    LDA #$00
    STA player_moving

    RTS


; ============================================================
; ATUALIZA UM JOGADOR VIVO
; ============================================================
;
; player_moving é zerado no início de cada frame.
;
; A variável só volta a receber 1 caso pelo menos um movimento
; seja realmente aceito.
;
; Um movimento pode ser rejeitado por:
;
;   - limite da tela;
;   - colisão com a cerca.
;
; ============================================================

update_living_player:

    LDA #$00
    STA player_moving


; ============================================================
; MOVIMENTO PARA A DIREITA
; ============================================================
;
; O movimento segue estas etapas:
;
;   1. verifica o botão;
;   2. atualiza a direção visual;
;   3. verifica o limite da tela;
;   4. move um pixel;
;   5. testa a colisão;
;   6. desfaz o movimento caso necessário.
;
; A direção do personagem é atualizada mesmo quando o movimento
; acaba bloqueado.
;
; ============================================================

check_right:

    ; Bit 0:
    ;
    ;   1 -> direita pressionada
    ;   0 -> direita solta

    LDA controller1
    AND #%00000001
    BEQ check_left


    ; O jogador passa a olhar para a direita.

    LDA #$00
    STA player_direction


    ; Impede que a coordenada ultrapasse o limite direito.

    LDA player_x
    CMP #PLAYER_MAX_X
    BCS check_left


    ; Tenta mover um pixel para a direita.

    INC player_x


    ; Verifica se a nova posição sobrepõe a cerca.

    JSR check_fence_collision

    LDA collision
    BNE undo_move_right


    ; O movimento foi aceito.

    LDA #$01
    STA player_moving

    JMP check_left


; ============================================================
; DESFAZ O MOVIMENTO PARA A DIREITA
; ============================================================
;
; A colisão é testada depois da mudança de posição.
;
; Se a nova posição for inválida, o incremento realizado
; anteriormente é revertido.
;
; ============================================================

undo_move_right:

    DEC player_x

    JMP check_left


; ============================================================
; MOVIMENTO PARA A ESQUERDA
; ============================================================

check_left:

    ; Bit 1:
    ;
    ;   1 -> esquerda pressionada
    ;   0 -> esquerda solta

    LDA controller1
    AND #%00000010
    BEQ check_down


    ; O jogador passa a olhar para a esquerda.

    LDA #$01
    STA player_direction


    ; Impede que a coordenada ultrapasse o limite esquerdo.

    LDA player_x
    CMP #PLAYER_MIN_X
    BEQ check_down


    ; Tenta mover um pixel para a esquerda.

    DEC player_x


    ; Verifica se a nova posição sobrepõe a cerca.

    JSR check_fence_collision

    LDA collision
    BNE undo_move_left


    ; O movimento foi aceito.

    LDA #$01
    STA player_moving

    JMP check_down


; ============================================================
; DESFAZ O MOVIMENTO PARA A ESQUERDA
; ============================================================

undo_move_left:

    INC player_x

    JMP check_down


; ============================================================
; MOVIMENTO PARA BAIXO
; ============================================================
;
; O movimento vertical não altera player_direction.
;
; Dessa forma, ao andar para cima ou para baixo, o personagem
; continua olhando para a última direção horizontal utilizada.
;
; ============================================================

check_down:

    ; Bit 2:
    ;
    ;   1 -> baixo pressionado
    ;   0 -> baixo solto

    LDA controller1
    AND #%00000100
    BEQ check_up


    ; Impede que a coordenada ultrapasse o limite inferior.

    LDA player_y
    CMP #PLAYER_MAX_Y
    BCS check_up


    ; Tenta mover um pixel para baixo.

    INC player_y


    ; Verifica se a nova posição sobrepõe a cerca.

    JSR check_fence_collision

    LDA collision
    BNE undo_move_down


    ; O movimento foi aceito.

    LDA #$01
    STA player_moving

    JMP check_up


; ============================================================
; DESFAZ O MOVIMENTO PARA BAIXO
; ============================================================

undo_move_down:

    DEC player_y

    JMP check_up


; ============================================================
; MOVIMENTO PARA CIMA
; ============================================================

check_up:

    ; Bit 3:
    ;
    ;   1 -> cima pressionada
    ;   0 -> cima solta

    LDA controller1
    AND #%00001000
    BEQ update_player_done


    ; Impede que a coordenada ultrapasse o limite superior.

    LDA player_y
    CMP #PLAYER_MIN_Y
    BEQ update_player_done


    ; Tenta mover um pixel para cima.

    DEC player_y


    ; Verifica se a nova posição sobrepõe a cerca.

    JSR check_fence_collision

    LDA collision
    BNE undo_move_up


    ; O movimento foi aceito.

    LDA #$01
    STA player_moving

    JMP update_player_done


; ============================================================
; DESFAZ O MOVIMENTO PARA CIMA
; ============================================================

undo_move_up:

    INC player_y


; ============================================================
; FINALIZA A ATUALIZAÇÃO DO JOGADOR
; ============================================================

update_player_done:

    RTS


; ============================================================
; ATUALIZA A ANIMAÇÃO DO JOGADOR
; ============================================================
;
; A animação só é atualizada enquanto o jogador está vivo.
;
; Se estiver morto, o quadro atual permanece congelado.
;
; ============================================================

update_player_animation:

    LDA player_alive
    BNE update_living_player_animation

    RTS


; ============================================================
; ATUALIZA A ANIMAÇÃO DE UM JOGADOR VIVO
; ============================================================
;
; player_moving indica se pelo menos um movimento foi aceito no
; frame atual.
;
; Se o jogador estiver parado, a animação retorna ao quadro
; inicial.
;
; Se estiver andando, o contador da animação avança.
;
; ============================================================

update_living_player_animation:

    LDA player_moving
    BNE player_is_moving


; ============================================================
; JOGADOR PARADO
; ============================================================
;
; Ao parar:
;
;   anim_counter = 0
;   anim_frame   = 0
;
; Isso garante que o personagem sempre retorne à posição neutra
; dos pés.
;
; ============================================================

player_is_stopped:

    LDA #$00

    STA anim_counter
    STA anim_frame

    RTS


; ============================================================
; JOGADOR EM MOVIMENTO
; ============================================================
;
; anim_counter é incrementado uma vez por frame.
;
; Quando chega a 8, o quadro visual é alterado.
;
; Portanto, cada quadro da caminhada permanece visível durante
; oito frames.
;
; ============================================================

player_is_moving:

    INC anim_counter

    LDA anim_counter
    CMP #$08

    ; Se o contador ainda for menor que 8, mantém o quadro atual.

    BCC animation_done


    ; Reinicia o contador antes de avançar o quadro.

    LDA #$00
    STA anim_counter


    ; Alterna para o próximo quadro da animação.

    INC anim_frame

    LDA anim_frame
    CMP #$02

    ; Os valores válidos são 0 e 1.

    BCC animation_done


    ; Depois do quadro 1, retorna ao quadro 0.

    LDA #$00
    STA anim_frame


; ============================================================
; FINALIZA A ANIMAÇÃO
; ============================================================
;
; Embora visualmente a caminhada possa parecer ter três posições:
;
;   centro -> afastado -> centro
;
; somente dois quadros precisam ser armazenados.
;
; O quadro central é reutilizado quando anim_frame volta para 0.
;
; ============================================================

animation_done:

    RTS