; ============================================================
; RAM.INC
; ============================================================
;
; Declara as variáveis armazenadas na RAM comum do NES.
;
; Este arquivo é incluído dentro do segmento BSS, definido em
; memory_layout.asm.
;
; A diretiva:
;
;   .res 1
;
; reserva um byte de memória para a variável.
;
; Importante:
;
;   .res não inicializa o valor.
;
; As variáveis precisam receber valores adequados durante a
; inicialização do jogo.
;
; ============================================================


; ============================================================
; ANIMAÇÃO DO JOGADOR
; ============================================================
;
; anim_counter:
;
;   Conta quantos frames o quadro atual permanece visível.
;
; anim_frame:
;
;   Indica qual quadro da animação dos pés está sendo utilizado.
;
;   0 -> primeiro quadro
;   1 -> segundo quadro
;
; ============================================================

anim_counter: .res 1
anim_frame:   .res 1


; ============================================================
; MOVIMENTO E ANIMAÇÃO DO INIMIGO
; ============================================================
;
; enemy_move_counter:
;
;   Controla o intervalo entre os movimentos do inimigo.
;   Isso permite que ele se mova mais lentamente que o jogador.
;
; enemy_anim_counter:
;
;   Conta quantos frames o quadro atual da animação do inimigo
;   permanece visível.
;
; enemy_anim_frame:
;
;   Indica o quadro atual da animação do inimigo.
;
; ============================================================

enemy_move_counter: .res 1
enemy_anim_counter: .res 1
enemy_anim_frame:   .res 1


; ============================================================
; ESTADO DO PROJÉTIL
; ============================================================
;
; projectile_x:
;
;   Coordenada horizontal do projétil.
;
; projectile_y:
;
;   Coordenada vertical do projétil.
;
; projectile_direction:
;
;   Direção em que o projétil se move:
;
;     0 -> direita
;     1 -> esquerda
;
; projectile_active:
;
;   Informa se existe um projétil ativo:
;
;     0 -> inativo
;     1 -> ativo
;
; ============================================================

projectile_x:         .res 1
projectile_y:         .res 1
projectile_direction: .res 1
projectile_active:    .res 1


; ============================================================
; RESULTADO DE COLISÃO
; ============================================================
;
; Variável temporária utilizada pelas rotinas de colisão.
;
; Depois de uma verificação:
;
;   0 -> não houve colisão
;   1 -> houve colisão
;
; Seu valor pode ser sobrescrito por cada nova chamada de rotina
; de colisão.
;
; ============================================================

collision: .res 1


; ============================================================
; ESTADO DA PARTIDA
; ============================================================
;
; Indica se a partida atual foi encerrada:
;
;   0 -> partida em andamento
;   1 -> partida encerrada
;
; Nesta demo, o nome game_over não significa necessariamente que
; o jogador perdeu.
;
; A variável também recebe 1 quando o inimigo é derrotado.
;
; Em um jogo maior, esse estado poderia ser substituído por uma
; variável game_state com valores separados para:
;
;   - partida ativa;
;   - vitória;
;   - derrota;
;   - pausa;
;   - tela inicial.
;
; ============================================================

game_over: .res 1