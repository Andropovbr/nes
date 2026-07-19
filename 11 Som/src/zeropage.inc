; ============================================================
; ZEROPAGE.INC
; ============================================================
;
; Declara as variáveis armazenadas na Zero Page do processador
; 6502.
;
; A Zero Page ocupa os endereços:
;
;   $0000-$00FF
;
; O 6502 possui modos de endereçamento especiais para essa região,
; produzindo instruções menores e mais rápidas.
;
; Por isso, variáveis acessadas constantemente durante a execução
; do jogo costumam ser armazenadas aqui.
;
; Assim como no arquivo ram.inc, a diretiva:
;
;   .res 1
;
; apenas reserva um byte de memória.
;
; Nenhum valor inicial é gravado.
;
; ============================================================


; ============================================================
; CONTROLE
; ============================================================
;
; controller1:
;
;   Estado atual dos oito botões do controle.
;
; previous_controller1:
;
;   Estado do controle no frame anterior.
;
; controller_pressed:
;
;   Botões que foram pressionados exatamente neste frame.
;
; Essa variável é calculada a partir de:
;
;   controller1 AND (NOT previous_controller1)
;
; permitindo detectar apenas a transição entre "solto" e
; "pressionado".
;
; ============================================================

controller1:          .res 1
previous_controller1: .res 1
controller_pressed:   .res 1


; ============================================================
; SINCRONIZAÇÃO COM A NMI
; ============================================================
;
; frame_ready:
;
;   Flag utilizada para sincronizar o loop principal com a
;   interrupção NMI.
;
; A NMI grava:
;
;   frame_ready = 1
;
; O loop principal espera esse valor para iniciar a atualização do
; próximo frame.
;
; ============================================================

frame_ready: .res 1


; ============================================================
; ESTADO DO JOGADOR
; ============================================================
;
; player_x:
;
;   Coordenada horizontal do jogador.
;
; player_y:
;
;   Coordenada vertical do jogador.
;
; player_direction:
;
;   Direção em que o personagem está olhando:
;
;     0 -> direita
;     1 -> esquerda
;
; player_moving:
;
;   Indica se houve movimento durante o frame atual:
;
;     0 -> parado
;     1 -> em movimento
;
; Essa variável é utilizada pela rotina de animação.
;
; player_alive:
;
;   Estado do jogador:
;
;     0 -> morto
;     1 -> vivo
;
; ============================================================

player_x:         .res 1
player_y:         .res 1
player_direction: .res 1
player_moving:    .res 1
player_alive:     .res 1


; ============================================================
; ESTADO DO INIMIGO
; ============================================================
;
; enemy_x:
;
;   Coordenada horizontal do inimigo.
;
; enemy_y:
;
;   Coordenada vertical do inimigo.
;
; enemy_direction:
;
;   Direção em que o inimigo está olhando:
;
;     0 -> direita
;     1 -> esquerda
;
; player_direction e enemy_direction utilizam a mesma convenção,
; simplificando as rotinas que manipulam sprites.
;
; enemy_moving:
;
;   Indica se o inimigo se moveu durante o frame atual.
;
; Essa variável é utilizada pela rotina de animação do inimigo.
;
; enemy_alive:
;
;   Estado do inimigo:
;
;     0 -> morto
;     1 -> vivo
;
; ============================================================

enemy_x:         .res 1
enemy_y:         .res 1
enemy_direction: .res 1
enemy_moving:    .res 1
enemy_alive:     .res 1