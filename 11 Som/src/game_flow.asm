; ============================================================
; GAME_FLOW.ASM
; ============================================================
;
; Controla o fluxo principal da partida.
;
; Este arquivo é responsável por:
;
;   - inicializar as variáveis do jogo;
;   - aguardar o início de cada novo frame;
;   - ler o controle;
;   - atualizar jogador, inimigo e projétil;
;   - verificar colisões;
;   - encerrar a partida quando alguém é atingido;
;   - reiniciar o jogo quando START é pressionado.
;
; A variável game_over define o estado geral da partida:
;
;   game_over = 0 -> partida em andamento
;   game_over = 1 -> partida encerrada
;
; ============================================================

.segment "CODE"


; ============================================================
; INICIALIZA A PARTIDA
; ============================================================
;
; Coloca todas as variáveis em seus estados iniciais.
;
; A rotina:
;
;   - limpa o estado de fim de jogo;
;   - remove qualquer projétil ativo;
;   - posiciona jogador e inimigo;
;   - reinicia contadores de movimento e animação;
;   - marca jogador e inimigo como vivos;
;   - atualiza os sprites na Shadow OAM.
;
; Esta rotina é chamada:
;
;   - durante a inicialização do programa;
;   - quando o jogador pressiona START após o fim da partida.
;
; ============================================================

initialize_game:

    ; --------------------------------------------------------
    ; ESTADO GERAL DA PARTIDA
    ; --------------------------------------------------------

    LDA #$00
    STA game_over
    STA projectile_active
    STA controller_pressed


    ; Usa o estado atual do controle como referência inicial.
    ;
    ; Isso evita que um botão que já esteja segurado seja
    ; interpretado imediatamente como um novo pressionamento.

    LDA controller1
    STA previous_controller1


    ; --------------------------------------------------------
    ; ESTADO INICIAL DO JOGADOR
    ; --------------------------------------------------------
    ;
    ; Posição inicial:
    ;
    ;   X = $80
    ;   Y = $40
    ;
    ; O jogador começa vivo, parado e olhando para a direita.
    ;
    ; --------------------------------------------------------

    LDA #$80
    STA player_x

    LDA #$40
    STA player_y

    LDA #$00
    STA player_direction
    STA player_moving
    STA anim_counter
    STA anim_frame

    LDA #$01
    STA player_alive


    ; --------------------------------------------------------
    ; ESTADO INICIAL DO INIMIGO
    ; --------------------------------------------------------
    ;
    ; Posição inicial:
    ;
    ;   X = $20
    ;   Y = $B0
    ;
    ; O inimigo começa vivo, parado e olhando para a direita.
    ;
    ; --------------------------------------------------------

    LDA #$20
    STA enemy_x

    LDA #$B0
    STA enemy_y

    LDA #$00
    STA enemy_direction
    STA enemy_moving
    STA enemy_move_counter
    STA enemy_anim_counter
    STA enemy_anim_frame

    LDA #$01
    STA enemy_alive


    ; --------------------------------------------------------
    ; ESTADO INICIAL DO PROJÉTIL
    ; --------------------------------------------------------
    ;
    ; O projétil começa inativo. Suas coordenadas e direção são
    ; zeradas para deixar o estado completamente conhecido.
    ;
    ; --------------------------------------------------------

    LDA #$00
    STA projectile_x
    STA projectile_y
    STA projectile_direction


    ; Atualiza imediatamente a Shadow OAM com o estado inicial de
    ; todos os objetos.

    JSR update_biker_sprite
    JSR update_enemy_sprite
    JSR update_projectile_sprite

    RTS


; ============================================================
; LOOP PRINCIPAL DO JOGO
; ============================================================
;
; O programa permanece neste loop durante toda a execução.
;
; A cada iteração:
;
;   1. espera a NMI indicar que um novo frame começou;
;   2. lê o controle;
;   3. identifica novos pressionamentos;
;   4. atualiza a partida ou o estado de game over;
;   5. prepara os sprites para o próximo frame.
;
; ============================================================

forever:


; ============================================================
; AGUARDA O PRÓXIMO FRAME
; ============================================================
;
; A rotina de NMI define frame_ready como 1.
;
; Enquanto isso não acontecer, o processador permanece neste
; pequeno loop de espera.
;
; Quando o sinal chega, frame_ready é zerado para que o próximo
; frame possa ser aguardado.
;
; ============================================================

wait_frame:

    LDA frame_ready
    BEQ wait_frame

    LDA #$00
    STA frame_ready


    ; Lê o estado atual do controle e identifica quais botões
    ; foram pressionados exatamente neste frame.

    JSR read_controller
    JSR update_controller_pressed


    ; Decide qual estado do jogo deve ser atualizado.

    LDA game_over
    BNE update_game_over


; ============================================================
; ATUALIZA UMA PARTIDA EM ANDAMENTO
; ============================================================
;
; Executa a lógica principal do frame enquanto game_over for zero.
;
; Ordem da atualização:
;
;   1. jogador;
;   2. animação do jogador;
;   3. entrada de disparo;
;   4. projétil;
;   5. inimigo;
;   6. animação do inimigo;
;   7. colisões;
;   8. sprites.
;
; A ordem importa. Por exemplo, as colisões são verificadas depois
; que as posições dos objetos já foram atualizadas neste frame.
;
; ============================================================

update_running_game:

    JSR update_player
    JSR update_player_animation

    JSR check_projectile_input
    JSR update_projectile

    JSR update_enemy
    JSR update_enemy_animation


    ; --------------------------------------------------------
    ; COLISÃO ENTRE PROJÉTIL E INIMIGO
    ; --------------------------------------------------------
    ;
    ; Se o projétil atingir o inimigo:
    ;
    ;   - o projétil é desativado;
    ;   - o inimigo é marcado como morto;
    ;   - a partida é encerrada.
    ;
    ; --------------------------------------------------------

    JSR check_projectile_enemy_collision

    LDA collision
    BEQ check_enemy_player_collision

    LDA #$00
    STA projectile_active
    STA enemy_alive

    LDA #$01
    STA game_over

    JMP update_game_sprites


; ============================================================
; COLISÃO ENTRE INIMIGO E JOGADOR
; ============================================================
;
; Esta verificação só é necessária quando o inimigo ainda está
; vivo.
;
; Se os dois colidirem:
;
;   - o jogador é marcado como morto;
;   - qualquer projétil ativo é removido;
;   - a partida é encerrada.
;
; ============================================================

check_enemy_player_collision:

    LDA enemy_alive
    BEQ update_game_sprites

    JSR check_player_enemy_collision

    LDA collision
    BEQ update_game_sprites

    LDA #$00
    STA player_alive
    STA projectile_active

    LDA #$01
    STA game_over


; ============================================================
; ATUALIZA OS SPRITES DO JOGO
; ============================================================
;
; Converte o estado atual das variáveis do jogo em dados para a
; Shadow OAM.
;
; As rotinas podem:
;
;   - reposicionar os sprites;
;   - trocar tiles de animação;
;   - aplicar flip horizontal;
;   - esconder objetos mortos ou inativos.
;
; Depois disso, o loop volta a esperar o próximo frame.
;
; ============================================================

update_game_sprites:

    JSR update_biker_sprite
    JSR update_enemy_sprite
    JSR update_projectile_sprite

    JMP forever


; ============================================================
; ATUALIZA O ESTADO DE GAME OVER
; ============================================================
;
; Quando a partida não está ativa, a lógica de movimento e colisão
; deixa de ser executada.
;
; A rotina espera um novo pressionamento do botão START.
;
; controller_pressed é usado em vez de controller1 para que o
; reinício aconteça apenas uma vez, no instante em que o botão é
; pressionado.
;
; Máscara do botão START:
;
;   %00010000
;
; ============================================================

update_game_over:

    LDA controller_pressed
    AND #%00010000
    BEQ update_game_over_sprites


    ; Reinicia todas as variáveis e redesenha o estado inicial.

    JSR initialize_game

    JMP forever


; ============================================================
; MANTÉM OS SPRITES ATUALIZADOS DURANTE O GAME OVER
; ============================================================
;
; Mesmo sem atualizar movimento e colisões, os sprites continuam
; sendo preparados a cada frame.
;
; Isso garante que:
;
;   - o jogador morto permaneça escondido;
;   - o inimigo morto permaneça escondido;
;   - o projétil desativado não reapareça.
;
; ============================================================

update_game_over_sprites:

    JSR update_biker_sprite
    JSR update_enemy_sprite
    JSR update_projectile_sprite

    JMP forever
