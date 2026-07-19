; ============================================================
; INTERRUPTS.ASM
; ============================================================
;
; Contém as rotinas de interrupção e os vetores do programa.
;
; A NMI é executada automaticamente pelo NES no início do
; VBlank, período em que a PPU pode receber atualizações com
; segurança.
;
; Nesta demo, a NMI é responsável por:
;
;   - preservar os registradores da CPU;
;   - transferir a Shadow OAM para a OAM da PPU;
;   - atualizar a engine de áudio do FamiStudio;
;   - avisar ao loop principal que um novo frame começou;
;   - restaurar os registradores;
;   - retornar da interrupção.
;
; O arquivo também define:
;
;   - a rotina de IRQ;
;   - os vetores de NMI, RESET e IRQ;
;   - os dados gráficos da CHR ROM.
;
; ============================================================


; ============================================================
; INTERRUPÇÃO NMI
; ============================================================
;
; A NMI ocorre uma vez por frame, no início do VBlank.
;
; Como ela pode interromper o código principal em qualquer ponto,
; os registradores usados dentro da rotina precisam ser salvos na
; pilha antes de qualquer alteração.
;
; Ao final, os valores originais são restaurados na ordem inversa.
;
; ============================================================

NMI:

    ; --------------------------------------------------------
    ; PRESERVA OS REGISTRADORES
    ; --------------------------------------------------------
    ;
    ; O 6502 possui instrução direta para empilhar apenas o
    ; acumulador.
    ;
    ; Para salvar X e Y, seus valores são primeiro transferidos
    ; para A e depois enviados à pilha.
    ;
    ; Ordem de salvamento:
    ;
    ;   A
    ;   X
    ;   Y
    ;
    ; --------------------------------------------------------

    PHA

    TXA
    PHA

    TYA
    PHA


    ; --------------------------------------------------------
    ; TRANSFERE A SHADOW OAM PARA A PPU
    ; --------------------------------------------------------
    ;
    ; $2003 define o endereço inicial da OAM da PPU.
    ;
    ; O valor zero faz a transferência começar na primeira
    ; entrada de sprite.
    ;
    ; --------------------------------------------------------

    LDA #$00
    STA $2003


    ; --------------------------------------------------------
    ; OAM DMA
    ; --------------------------------------------------------
    ;
    ; Escrever $02 em $4014 inicia uma transferência DMA de
    ; 256 bytes a partir da página $0200.
    ;
    ; Portanto, os dados armazenados entre $0200 e $02FF são
    ; copiados diretamente para a OAM da PPU.
    ;
    ; Essa área da RAM funciona como Shadow OAM:
    ;
    ;   $0200-$02FF -> Shadow OAM
    ;
    ; Cada sprite ocupa quatro bytes:
    ;
    ;   Y, tile, atributos, X
    ;
    ; --------------------------------------------------------

    LDA #$02
    STA $4014


    ; --------------------------------------------------------
    ; ATUALIZA O ÁUDIO
    ; --------------------------------------------------------
    ;
    ; A engine FamiStudio precisa ser atualizada uma vez por
    ; frame para avançar músicas, efeitos e envelopes.
    ;
    ; Como a NMI ocorre em ritmo estável, ela é um bom local para
    ; chamar famistudio_update.
    ;
    ; --------------------------------------------------------

    JSR famistudio_update


    ; --------------------------------------------------------
    ; LIBERA O LOOP PRINCIPAL
    ; --------------------------------------------------------
    ;
    ; frame_ready funciona como uma sinalização entre a NMI e o
    ; código principal.
    ;
    ; A NMI coloca o valor 1.
    ; O loop principal detecta esse valor, executa um frame e
    ; depois volta a zerá-lo.
    ;
    ; --------------------------------------------------------

    LDA #$01
    STA frame_ready


    ; --------------------------------------------------------
    ; RESTAURA OS REGISTRADORES
    ; --------------------------------------------------------
    ;
    ; A pilha trabalha em ordem inversa.
    ;
    ; Como os registradores foram salvos na ordem A, X, Y, eles
    ; precisam ser restaurados na ordem Y, X, A.
    ;
    ; --------------------------------------------------------

    PLA
    TAY

    PLA
    TAX

    PLA


    ; Retorna da interrupção e restaura automaticamente o
    ; registrador de status e o contador de programa.

    RTI


; ============================================================
; INTERRUPÇÃO IRQ
; ============================================================
;
; Esta demo não utiliza IRQ.
;
; Mesmo assim, o vetor precisa apontar para uma rotina válida.
; Por isso, a implementação apenas retorna imediatamente.
;
; ============================================================

IRQ:

    RTI


; ============================================================
; VETORES DE INTERRUPÇÃO
; ============================================================
;
; Os últimos seis bytes da ROM contêm três endereços de 16 bits:
;
;   vetor de NMI
;   vetor de RESET
;   vetor de IRQ/BRK
;
; Quando cada evento ocorre, a CPU consulta o endereço
; correspondente nesta tabela.
;
; ============================================================

.segment "VECTORS"

    .word NMI
    .word RESET
    .word IRQ


; ============================================================
; DADOS GRÁFICOS DA CHR ROM
; ============================================================
;
; Seleciona o segmento reservado aos gráficos e inclui o arquivo
; binário contendo os tiles do jogo.
;
; O arquivo game.chr possui os padrões de pixels usados pela PPU
; para desenhar backgrounds e sprites.
;
; O posicionamento final desse segmento é definido pelo arquivo
; de configuração do linker.
;
; ============================================================

.segment "CHARS"

    .incbin "game.chr"