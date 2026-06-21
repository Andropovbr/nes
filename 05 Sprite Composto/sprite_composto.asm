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

; ------------------------------------------------------------
; CARREGA PALETA DE BACKGROUND
; ------------------------------------------------------------

    LDA $2002            ; Reseta o latch interno da PPU

    LDA #$3F             ; Byte alto do endereço $3F00
    STA $2006            ; Escreve endereço alto

    LDA #$00             ; Byte baixo do endereço $3F00
    STA $2006            ; Escreve endereço baixo

    LDX #$00             ; Índice da tabela

load_bg_palette:

    LDA bg_palette, x    ; Lê uma cor da paleta
    STA $2007            ; Escreve na memória da PPU

    INX                  ; Próxima cor

    CPX #$04             ; Já copiou 4 cores?
    BNE load_bg_palette  ; Se não, continua

; ------------------------------------------------------------
; CARREGA PALETA DE SPRITES
; ------------------------------------------------------------

    LDA $2002            ; Reseta o latch interno da PPU

    LDA #$3F             ; Byte alto do endereço $3F10
    STA $2006            ; Escreve endereço alto

    LDA #$10             ; Byte baixo do endereço $3F10
    STA $2006            ; Escreve endereço baixo

    LDX #$00             ; Índice da tabela

load_sprite_palette:

    LDA sprite_palette, x ; Lê uma cor da paleta
    STA $2007             ; Escreve na memória da PPU

    INX                   ; Próxima cor

    CPX #$04              ; Já copiou 4 cores?
    BNE load_sprite_palette ; Se não, continua

; ------------------------------------------------------------
; CONFIGURA PRIMEIRO SPRITE
; ------------------------------------------------------------

load_sprite:

    LDX #$00

copy_biker:
    LDA biker_sprite, x
    STA $0200, x

    INX
    CPX #$20
    BNE copy_biker

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

; Cada paleta possui 4 entradas:
;
; Cor 0 = cor universal (ou transparente para sprites)
; Cor 1 = índice de cor 1
; Cor 2 = índice de cor 2
; Cor 3 = índice de cor 3
;
; Background Palette 0 -> $3F00-$3F03
; Sprite Palette 0     -> $3F10-$3F13

bg_palette:
    .byte $0F, $01, $11, $31

sprite_palette:
    .byte $0F, $27, $15, $3D

; ------------------------------------------------------------
; DADOS DO SPRITE COMPOSTO
; ------------------------------------------------------------
;
; Cada entrada possui 4 bytes:
;
; .byte Y, TILE, ATRIBUTOS, X
;
; TILE       -> Índice do tile na CHR-ROM
; ATRIBUTOS  -> Paleta, flip horizontal e flip vertical
;
; Este personagem utiliza 8 sprites 8x8,
; formando uma área de 16x32 pixels.
; ------------------------------------------------------------

biker_sprite:

    ; Linha 1 (cabeça)
    .byte $60, $00, $00, $80
    .byte $60, $01, $00, $88

    ; Linha 2 (tronco superior)
    .byte $68, $02, $00, $80
    .byte $68, $03, $00, $88

    ; Linha 3 (tronco inferior)
    .byte $70, $04, $00, $80
    .byte $70, $05, $00, $88

    ; Linha 4 (pernas)
    .byte $78, $06, $00, $80
    .byte $78, $07, $00, $88

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

    .incbin "sprites.chr"