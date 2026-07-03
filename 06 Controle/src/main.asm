; ------------------------------------------------------------
; HEADER iNES
; ------------------------------------------------------------

.segment "HEADER"

    .byte "NES"
    .byte $1A
    .byte $02
    .byte $01
    .byte %00000000
    .byte $00
    .byte $00
    .byte $00
    .byte $00
    .byte $00, $00, $00, $00, $00

; ------------------------------------------------------------
; VARIÁVEIS
; ------------------------------------------------------------

.segment "ZEROPAGE"

.include "zeropage.inc"

; ------------------------------------------------------------
; RESET / INICIALIZAÇÃO
; ------------------------------------------------------------

.segment "STARTUP"

RESET:

    SEI
    CLD

    LDX #$40
    STX $4017

    LDX #$FF
    TXS

    INX

    STX $2000
    STX $2001
    STX $4010

vblankwait1:
    BIT $2002
    BPL vblankwait1

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
    STA $0200, x

    INX
    BNE clearmem

vblankwait2:
    BIT $2002
    BPL vblankwait2

    JSR load_palettes
    JSR load_biker_sprite

    LDA #$80
    STA player_x

    LDA #$60
    STA player_y

    LDA #$00
    STA anim_counter
    STA anim_frame
    STA player_moving

    JSR update_biker_sprite

enable_ppu:

    LDA #%10000000
    STA $2000

    LDA #%00010000
    STA $2001

; ------------------------------------------------------------
; CÓDIGO PRINCIPAL
; ------------------------------------------------------------

.segment "CODE"

forever:

wait_frame:
    LDA frame_ready
    BEQ wait_frame

    LDA #$00
    STA frame_ready

    JSR read_controller
    JSR update_player
    JSR update_player_animation
    JSR update_biker_sprite

    JMP forever

; ------------------------------------------------------------
; ARQUIVOS DO PROJETO
; ------------------------------------------------------------

.include "ppu.asm"
.include "controller.asm"
.include "player.asm"
.include "palettes.asm"
.include "biker.asm"

; ------------------------------------------------------------
; NMI
; ------------------------------------------------------------

NMI:

    LDA #$00
    STA $2003

    LDA #$02
    STA $4014

    LDA #$01
    STA frame_ready

    RTI

; ------------------------------------------------------------
; IRQ
; ------------------------------------------------------------

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

    .incbin "player.chr"