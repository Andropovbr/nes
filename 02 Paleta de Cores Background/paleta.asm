; ------------------------------------------------------------
; HEADER iNES
; ------------------------------------------------------------

.segment "HEADER"

    .byte "NES"
    .byte $1A
    .byte $02        ; 2 bancos PRG ROM = 32 KB
    .byte $01        ; 1 banco CHR ROM = 8 KB
    .byte %00000000  ; Mapper 0, mirroring horizontal
    .byte $00
    .byte $00
    .byte $00
    .byte $00
    .byte $00, $00, $00, $00, $00

; ------------------------------------------------------------
; SEGMENTOS
; ------------------------------------------------------------

.segment "ZEROPAGE"

.segment "STARTUP"

; ------------------------------------------------------------
; RESET / INICIALIZAÇÃO
; ------------------------------------------------------------

RESET:

    SEI             ; Desabilita IRQs
    CLD             ; Desabilita modo decimal

    LDX #$40
    STX $4017       ; Desabilita IRQ do frame counter da APU

    LDX #$FF
    TXS             ; Inicializa stack

    INX             ; X = $00

    STX $2000       ; Desabilita NMI
    STX $2001       ; Desabilita renderização
    STX $4010       ; Desabilita IRQ do DMC

; ------------------------------------------------------------
; ESPERA PELO PRIMEIRO VBLANK
; ------------------------------------------------------------

vblankwait1:
    BIT $2002
    BPL vblankwait1

; ------------------------------------------------------------
; LIMPEZA DA RAM
; ------------------------------------------------------------

clearmem:
    LDA #$00

    STA $0000, x
    STA $0100, x
    STA $0300, x
    STA $0400, x
    STA $0500, x
    STA $0600, x
    STA $0700, x

    LDA #$FE
    STA $0200, x    ; Move sprites para fora da tela

    INX
    BNE clearmem

; ------------------------------------------------------------
; ESPERA PELO SEGUNDO VBLANK
; ------------------------------------------------------------

vblankwait2:
    BIT $2002
    BPL vblankwait2

; ------------------------------------------------------------
; CARREGA PALETA DE BACKGROUND
; ------------------------------------------------------------
; Este bloco escreve uma paleta de background na RAM de
; paletas da PPU.
;
; A RAM de paletas começa no endereço $3F00.
;
; Neste exemplo, vamos copiar 4 bytes:
;
; $3F00 = cor universal de fundo
; $3F01 = cor 1 da paleta de background
; $3F02 = cor 2 da paleta de background
; $3F03 = cor 3 da paleta de background
;
; Como ainda não temos tiles desenhados na tela, apenas a cor
; universal de fundo ficará visível por enquanto.
; ------------------------------------------------------------

load_palette:

    ; Lê PPUSTATUS ($2002).
    ; Isso reseta o latch interno da PPU.
    ;
    ; Antes de escrever um endereço em $2006,
    ; normalmente fazemos essa leitura.
    LDA $2002

    ; Define o endereço da PPU para $3F00,
    ; que é o início da RAM de paletas.
    ;
    ; O endereço é escrito em duas partes:
    ; primeiro o byte alto ($3F)...
    LDA #$3F
    STA $2006

    ; ...depois o byte baixo ($00).
    LDA #$00
    STA $2006

    ; X será usado como índice para acessar
    ; os bytes da tabela palette_data.
    LDX #$00

load_palette_loop:

    ; Carrega em A o byte palette_data + X.
    ;
    ; Na primeira volta:
    ; X = 0, então lê palette_data[0].
    ;
    ; Na segunda volta:
    ; X = 1, então lê palette_data[1].
    ;
    ; E assim por diante.
    LDA palette_data, x

    ; Escreve o valor carregado em $2007.
    ;
    ; Como antes definimos o endereço da PPU como $3F00,
    ; a primeira escrita vai para $3F00.
    ;
    ; Depois de cada escrita em $2007, a PPU incrementa
    ; automaticamente o endereço interno.
    STA $2007

    ; Avança para o próximo byte da tabela.
    INX

    ; Compara X com 4.
    ;
    ; Queremos copiar exatamente 4 bytes:
    ; índices 0, 1, 2 e 3.
    CPX #$04

    ; Se X ainda não chegou em 4,
    ; volta para copiar o próximo byte.
    BNE load_palette_loop

    ; Liga a renderização de background.
    ;
    ; Bit 3 de PPUMASK ($2001):
    ; 0 = background desligado
    ; 1 = background ligado
    ;
    ; Neste exemplo usamos apenas esse bit.
    LDA #%00001000
    STA $2001

.segment "CODE"

; ------------------------------------------------------------
; LOOP PRINCIPAL
; ------------------------------------------------------------

forever:

    ; Como este exemplo não tem lógica de jogo,
    ; o programa fica preso neste loop infinito.
    JMP forever

; ------------------------------------------------------------
; DADOS DA PALETA
; ------------------------------------------------------------
; Cada byte representa uma cor da paleta do NES.
;
; A primeira cor ($21) será usada como cor universal
; de fundo e, por isso, já aparece na tela.
;
; As outras três cores já são carregadas na PPU,
; mas só serão usadas quando desenharmos tiles.
; ------------------------------------------------------------

palette_data:
    .byte $21, $01, $11, $31

; ------------------------------------------------------------
; INTERRUPÇÕES
; ------------------------------------------------------------

NMI:
    RTI

IRQ:
    RTI

; ------------------------------------------------------------
; VETORES
; ------------------------------------------------------------

.segment "VECTORS"

    .word NMI
    .word RESET
    .word IRQ

; ------------------------------------------------------------
; CHR ROM
; ------------------------------------------------------------

.segment "CHARS"