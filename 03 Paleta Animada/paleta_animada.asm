; ------------------------------------------------------------
; HEADER iNES
; ------------------------------------------------------------

.segment "HEADER"

    .byte "NES"
    .byte $1A
    .byte $02        ; 2 bancos PRG ROM = 32 KB
    .byte $01        ; 1 banco CHR ROM = 8 KB
    .byte %00000000  ; Mapper 0, mirroring horizontal
    .byte $00, $00, $00, $00, $00, $00, $00, $00, $00

; ------------------------------------------------------------
; SEGMENTOS
; ------------------------------------------------------------

.segment "ZEROPAGE"

frame_counter: .res 1
color_index:   .res 1

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

load_palette:

    ; Reseta o latch da PPU
    LDA $2002

    ; Define endereço $3F00 (início da RAM de paletas)
    LDA #$3F
    STA $2006

    LDA #$00
    STA $2006

    ; X será o índice da tabela de cores
    LDX #$00

load_palette_loop:

    ; Lê uma cor da tabela
    LDA palette_data, x

    ; Escreve na RAM de paletas
    STA $2007

    ; Próxima cor
    INX

    ; Copia 4 bytes
    CPX #$04
    BNE load_palette_loop

    ; Habilita NMI no VBlank
    ;
    ; $2000 = PPUCTRL
    ; Bit 7 = NMI enable
    ;
    ; %10000000 liga apenas o bit 7.
    ; A partir daqui, a PPU chamará a rotina NMI
    ; no início de cada VBlank.
    LDA #%10000000
    STA $2000

    ; Liga a renderização do background
    ;
    ; $2001 = PPUMASK
    ; Bit 3 = background enable
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
; $3F00 = cor universal de fundo
; $3F01-$3F03 = cores da paleta
; ------------------------------------------------------------

palette_data:
    .byte $21, $01, $11, $31

background_colors:
    ; Cores que serão usadas na animação
    .byte $21, $16, $2A, $28
; ------------------------------------------------------------
; INTERRUPÇÕES
; ------------------------------------------------------------

NMI:
    ; Conta mais um frame
    INC frame_counter

    ; Já passaram 30 frames?
    LDA frame_counter
    CMP #$1E        ; $1E = 30 em decimal
    BNE nmi_done    ; Se ainda não chegou em 30, sai da NMI

    ; Zera contador de frames
    LDA #$00
    STA frame_counter

    ; Avança para a próxima cor
    INC color_index

    ; color_index chegou em 4?
    LDA color_index
    CMP #$04
    BNE update_background_color

    ; Se chegou em 4, volta para 0
    LDA #$00
    STA color_index

update_background_color:

    ; Reseta latch da PPU antes de escrever endereço em $2006
    LDA $2002

    ; Define endereço $3F00
    LDA #$3F
    STA $2006

    LDA #$00
    STA $2006

    ; Usa color_index como índice na tabela
    LDX color_index
    LDA background_colors, x

    ; Escreve nova cor de fundo em $3F00
    STA $2007

nmi_done:
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