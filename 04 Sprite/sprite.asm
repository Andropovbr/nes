; ------------------------------------------------------------
; HEADER iNES
; ------------------------------------------------------------

.segment "HEADER"

    .byte "NES"              ; Assinatura iNES
    .byte $1A                ; Fim da assinatura
    .byte $02                ; 2 bancos PRG ROM = 32 KB
    .byte $01                ; 1 banco CHR ROM = 8 KB
    .byte %00000000          ; Mapper 0, mirroring horizontal
    .byte $00                ; Flags 7
    .byte $00                ; PRG RAM
    .byte $00                ; TV system
    .byte $00                ; TV system
    .byte $00, $00, $00, $00, $00 ; Bytes reservados

; ------------------------------------------------------------
; SEGMENTOS
; ------------------------------------------------------------

.segment "ZEROPAGE"

.segment "STARTUP"

; ------------------------------------------------------------
; RESET / INICIALIZAÇÃO
; ------------------------------------------------------------

RESET:

    SEI                      ; Desabilita IRQs
    CLD                      ; Desabilita modo decimal

    LDX #$40                 ; Valor para o frame counter
    STX $4017                ; Desabilita IRQ do frame counter

    LDX #$FF                 ; Topo da stack
    TXS                      ; Inicializa a stack

    INX                      ; X = $00

    STX $2000                ; Desabilita NMI
    STX $2001                ; Desabilita renderização
    STX $4010                ; Desabilita IRQ do DMC

; ------------------------------------------------------------
; ESPERA PELO PRIMEIRO VBLANK
; ------------------------------------------------------------

vblankwait1:
    BIT $2002                ; Lê status da PPU
    BPL vblankwait1          ; Aguarda VBlank

; ------------------------------------------------------------
; LIMPEZA DA RAM
; ------------------------------------------------------------

clearmem:
    LDA #$00                 ; Valor zero

    STA $0000, x             ; Limpa página $00
    STA $0100, x             ; Limpa página $01
    STA $0300, x             ; Limpa página $03
    STA $0400, x             ; Limpa página $04
    STA $0500, x             ; Limpa página $05
    STA $0600, x             ; Limpa página $06
    STA $0700, x             ; Limpa página $07

    LDA #$FE                 ; Posição Y fora da tela
    STA $0200, x             ; Esconde sprites

    INX                      ; Próximo byte
    BNE clearmem             ; Repete até X voltar a zero

; ------------------------------------------------------------
; ESPERA PELO SEGUNDO VBLANK
; ------------------------------------------------------------

vblankwait2:
    BIT $2002                ; Lê status da PPU
    BPL vblankwait2          ; Aguarda VBlank

; ------------------------------------------------------------
; CARREGA PALETAS
; ------------------------------------------------------------

load_palette:

    LDA $2002                ; Reseta latch da PPU

    LDA #$3F                 ; Byte alto de $3F00
    STA $2006                ; Define endereço alto

    LDA #$00                 ; Byte baixo de $3F00
    STA $2006                ; Define endereço baixo

    LDX #$00                 ; Índice da paleta

load_palette_loop:

    LDA palette_data, x      ; Lê cor da tabela
    STA $2007                ; Escreve na PPU

    INX                      ; Próxima cor
    CPX #$08                 ; Copiou 8 cores?
    BNE load_palette_loop    ; Continua se não copiou

; ------------------------------------------------------------
; CONFIGURA PRIMEIRO SPRITE
; ------------------------------------------------------------

load_sprite:

    LDA #$70                 ; Posição Y do sprite
    STA $0200                ; Byte 0: Y

    LDA #$00                 ; Tile número 0
    STA $0201                ; Byte 1: tile

    LDA #$00                 ; Paleta 0, sem flip
    STA $0202                ; Byte 2: atributos

    LDA #$80                 ; Posição X do sprite
    STA $0203                ; Byte 3: X

; ------------------------------------------------------------
; HABILITA PPU
; ------------------------------------------------------------

enable_ppu:

    LDA #%10000000           ; Habilita NMI
    STA $2000                ; Escreve em PPUCTRL

    LDA #%00010000           ; Liga sprites
    STA $2001                ; Escreve em PPUMASK

.segment "CODE"

; ------------------------------------------------------------
; LOOP PRINCIPAL
; ------------------------------------------------------------

forever:

    JMP forever              ; Aguarda indefinidamente

; ------------------------------------------------------------
; DADOS DAS PALETAS
; ------------------------------------------------------------

palette_data:
    .byte $0F, $01, $11, $31 ; Paleta de background
    .byte $21, $0F, $16, $30 ; Paleta de sprite

; ------------------------------------------------------------
; INTERRUPÇÃO NMI
; ------------------------------------------------------------

NMI:

    LDA #$00                 ; Endereço inicial da OAM
    STA $2003                ; Define OAMADDR como zero

    LDA #$02                 ; Página $0200 da RAM
    STA $4014                ; Copia RAM para OAM via DMA

    RTI                      ; Retorna da interrupção

; ------------------------------------------------------------
; INTERRUPÇÃO IRQ
; ------------------------------------------------------------

IRQ:

    RTI                      ; Retorna da interrupção

; ------------------------------------------------------------
; VETORES
; ------------------------------------------------------------

.segment "VECTORS"

    .word NMI                ; Vetor NMI
    .word RESET              ; Vetor RESET
    .word IRQ                ; Vetor IRQ

; ------------------------------------------------------------
; CHR ROM
; ------------------------------------------------------------

.segment "CHARS"

; Tile 0: quadrado simples 8x8
; Cada tile usa 16 bytes:
; - 8 bytes para o bitplane 0
; - 8 bytes para o bitplane 1

    .byte %00111100          ; Linha 0, bitplane 0
    .byte %01111110          ; Linha 1, bitplane 0
    .byte %11111111          ; Linha 2, bitplane 0
    .byte %11111111          ; Linha 3, bitplane 0
    .byte %11111111          ; Linha 4, bitplane 0
    .byte %11111111          ; Linha 5, bitplane 0
    .byte %01111110          ; Linha 6, bitplane 0
    .byte %00111100          ; Linha 7, bitplane 0

    .byte %00000000          ; Linha 0, bitplane 1
    .byte %00000000          ; Linha 1, bitplane 1
    .byte %00000000          ; Linha 2, bitplane 1
    .byte %00000000          ; Linha 3, bitplane 1
    .byte %00000000          ; Linha 4, bitplane 1
    .byte %00000000          ; Linha 5, bitplane 1
    .byte %00000000          ; Linha 6, bitplane 1
    .byte %00000000          ; Linha 7, bitplane 1