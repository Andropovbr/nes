; ============================================================
; MEMORY_LAYOUT.ASM
; ============================================================
;
; Define a organização da ROM e da memória utilizada pelo jogo.
;
; Este arquivo contém três partes principais:
;
;   - cabeçalho iNES da ROM;
;   - variáveis da Zero Page;
;   - variáveis da RAM comum.
;
; A distribuição física desses segmentos é definida pelo arquivo
; nes.cfg utilizado pelo linker.
;
; ============================================================


; ============================================================
; CABEÇALHO iNES
; ============================================================
;
; Toda ROM de NES no formato iNES começa com um cabeçalho de
; 16 bytes.
;
; Esse cabeçalho informa ao emulador ou ao flashcart diversas
; características da ROM, como:
;
;   - quantidade de PRG ROM;
;   - quantidade de CHR ROM;
;   - mapper utilizado;
;   - espelhamento das nametables;
;   - presença de bateria, trainer etc.
;
; ============================================================

.segment "HEADER"


    ; Assinatura obrigatória do formato iNES:
    ;
    ;   'N' 'E' 'S' $1A

    .byte "NES"
    .byte $1A


    ; Quantidade de bancos de PRG ROM.
    ;
    ; Cada banco possui 16 KB.
    ;
    ; Valor $02 = 32 KB de código.

    .byte $02


    ; Quantidade de bancos de CHR ROM.
    ;
    ; Cada banco possui 8 KB.
    ;
    ; Valor $01 = 8 KB de gráficos.

    .byte $01


    ; Flags 6
    ;
    ; %00000000 significa:
    ;
    ;   - Mapper 0 (NROM)
    ;   - Espelhamento horizontal
    ;   - Sem SRAM com bateria
    ;   - Sem trainer
    ;   - Sem memória de quatro telas
    ;
    ; Os quatro bits superiores também fazem parte do número do
    ; mapper.

    .byte %00000000


    ; Bytes restantes do cabeçalho.
    ;
    ; Permanecem zerados nesta demo.

    .byte $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00


; ============================================================
; ZERO PAGE
; ============================================================
;
; A Zero Page ocupa os primeiros 256 bytes da RAM:
;
;   $0000-$00FF
;
; O processador 6502 possui instruções especiais para essa região,
; que são menores e mais rápidas do que os acessos normais à RAM.
;
; Por esse motivo, variáveis muito acessadas costumam ficar aqui.
;
; Exemplos:
;
;   - posições dos sprites;
;   - estados do controle;
;   - contadores;
;   - ponteiros.
;
; As variáveis propriamente ditas estão declaradas em
; zeropage.inc.
;
; ============================================================

.segment "ZEROPAGE"

.include "zeropage.inc"


; ============================================================
; RAM GERAL (BSS)
; ============================================================
;
; Este segmento reúne as variáveis que não precisam ocupar a
; Zero Page.
;
; O segmento BSS armazena apenas espaço reservado para variáveis.
; Nenhum dado inicial é gravado na ROM.
;
; Durante a inicialização do programa, essas variáveis recebem os
; valores definidos pelas rotinas do jogo.
;
; As declarações estão no arquivo ram.inc.
;
; ============================================================

.segment "BSS"

.include "ram.inc"