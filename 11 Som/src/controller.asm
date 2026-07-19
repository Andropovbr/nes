; ============================================================
; CONTROLLER.ASM
; ============================================================
;
; Contém as rotinas responsáveis pela leitura do controle 1.
;
; O NES disponibiliza os botões do controle de forma serial:
; cada leitura de $4016 retorna o estado de apenas um botão.
;
; A rotina read_controller lê os oito botões e monta um único
; byte na variável controller1.
;
; A rotina update_controller_pressed compara o estado atual com
; o estado do frame anterior para identificar quais botões foram
; pressionados exatamente neste frame.
;
; ============================================================


; ============================================================
; LÊ O ESTADO ATUAL DO CONTROLE 1
; ============================================================
;
; Primeiro, envia uma sequência 1 -> 0 para $4016.
;
; Essa sequência captura o estado atual dos botões e prepara o
; registrador interno do controle para a leitura serial.
;
; Depois disso, a rotina realiza oito leituras de $4016, uma para
; cada botão:
;
;   A, B, Select, Start, Cima, Baixo, Esquerda, Direita
;
; Cada bit lido é inserido em controller1.
;
; Ao final, controller1 contém todos os botões em um único byte.
;
; Saída:
;
;   controller1 = estado atual dos oito botões
;
; ============================================================

read_controller:

    ; --------------------------------------------------------
    ; CAPTURA O ESTADO DOS BOTÕES
    ; --------------------------------------------------------
    ;
    ; Escrever 1 ativa o strobe do controle.
    ; Escrever 0 encerra o strobe e inicia a leitura serial.
    ;
    ; --------------------------------------------------------

    LDA #$01
    STA $4016

    LDA #$00
    STA $4016


    ; Limpa o byte que receberá os estados dos botões.

    LDA #$00
    STA controller1


    ; Serão feitas oito leituras, uma para cada botão.

    LDX #$08

read_controller_loop:

    ; O estado do próximo botão aparece no bit 0 de $4016.

    LDA $4016


    ; Move o bit 0 para o Carry.
    ;
    ; Os outros bits lidos de $4016 não interessam para esta
    ; rotina.

    LSR A


    ; Insere o bit do Carry em controller1.
    ;
    ; Como os bits são rotacionados para a esquerda, ao final das
    ; oito leituras eles ficam organizados nesta ordem:
    ;
    ;   bit 7 -> A
    ;   bit 6 -> B
    ;   bit 5 -> Select
    ;   bit 4 -> Start
    ;   bit 3 -> Cima
    ;   bit 2 -> Baixo
    ;   bit 1 -> Esquerda
    ;   bit 0 -> Direita
    ;
    ; Isso permite testar cada botão usando máscaras de bits.

    ROL controller1


    ; Repete até que os oito botões tenham sido lidos.

    DEX
    BNE read_controller_loop

    RTS


; ============================================================
; IDENTIFICA BOTÕES PRESSIONADOS NESTE FRAME
; ============================================================
;
; controller1 informa quais botões estão pressionados agora.
;
; Porém, algumas ações devem acontecer apenas no instante em que
; o botão é pressionado, e não durante todos os frames em que ele
; permanece segurado.
;
; Exemplos:
;
;   - disparar um projétil;
;   - iniciar ou reiniciar a partida;
;   - abrir um menu;
;   - confirmar uma opção.
;
; Para encontrar apenas os novos pressionamentos, a rotina usa:
;
;   controller_pressed =
;       controller1 AND NOT previous_controller1
;
; Assim, um bit será 1 somente quando:
;
;   - o botão estiver pressionado no frame atual;
;   - o mesmo botão não estava pressionado no frame anterior.
;
; Entrada:
;
;   controller1
;   previous_controller1
;
; Saída:
;
;   controller_pressed   = botões pressionados neste frame
;   previous_controller1 = estado atual salvo para o próximo frame
;
; ============================================================

update_controller_pressed:

    ; Inverte o estado anterior.
    ;
    ; Depois do EOR #$FF:
    ;
    ;   botão antes solto      -> bit 1
    ;   botão antes pressionado -> bit 0

    LDA previous_controller1
    EOR #$FF


    ; Mantém apenas os botões que estão pressionados agora e que
    ; estavam soltos no frame anterior.

    AND controller1
    STA controller_pressed


    ; Salva o estado atual para ser usado na próxima comparação.

    LDA controller1
    STA previous_controller1

    RTS
