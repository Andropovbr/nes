; ------------------------------------------------------------
; HEADER iNES
; ------------------------------------------------------------

.segment "HEADER"

    .byte "NES"            ; Identifica o arquivo como uma ROM NES
    .byte $1A              ; Byte obrigatório do formato iNES
    .byte $02              ; 2 bancos de PRG ROM = 32 KB
    .byte $01              ; 1 banco de CHR ROM = 8 KB
    .byte %00000000        ; Mapper 0, mirroring horizontal
    .byte $00              ; Flags 7
    .byte $00              ; Flags 8
    .byte $00              ; Flags 9
    .byte $00              ; Flags 10
    .byte $00, $00, $00, $00, $00 ; Preenchimento do header

; ------------------------------------------------------------
; VARIÁVEIS
; ------------------------------------------------------------

.segment "ZEROPAGE"

.include "zeropage.inc"    ; Declara variáveis rápidas na página zero

; ------------------------------------------------------------
; RESET / INICIALIZAÇÃO
; ------------------------------------------------------------

.segment "STARTUP"

RESET:

    SEI                    ; Desabilita interrupções IRQ
    CLD                    ; Desabilita modo decimal do 6502

    LDX #$40
    STX $4017              ; Desabilita IRQ do APU frame counter

    LDX #$FF
    TXS                    ; Inicializa a pilha em $01FF

    INX                    ; X passa de $FF para $00

    STX $2000              ; Desabilita NMI
    STX $2001              ; Desabilita renderização
    STX $4010              ; Desabilita IRQ do DMC

vblankwait1:
    BIT $2002              ; Verifica o status da PPU
    BPL vblankwait1        ; Espera entrar no primeiro VBlank

clearmem:
    LDA #$00               ; Valor usado para limpar a RAM

    STA $0000, x           ; Limpa página $0000
    STA $0100, x           ; Limpa página da pilha
    STA $0300, x           ; Limpa RAM
    STA $0400, x           ; Limpa RAM
    STA $0500, x           ; Limpa RAM
    STA $0600, x           ; Limpa RAM
    STA $0700, x           ; Limpa RAM

    LDA #$FE               ; Y = $FE esconde sprites fora da tela
    STA $0200, x           ; Limpa/Oculta OAM shadow em RAM

    INX                    ; Avança para o próximo byte
    BNE clearmem           ; Repete até X voltar para zero

vblankwait2:
    BIT $2002              ; Verifica novamente o status da PPU
    BPL vblankwait2        ; Espera o segundo VBlank

    JSR load_palettes       ; Carrega as paletas de cores na PPU
    JSR clear_nametable     ; Limpa o mapa de tiles na PPU
    JSR draw_background     ; Desenha o gramado e o chão na PPU
    JSR load_bg_attributes  ; Carrega os atributos do mapa de tiles na PPU

    JSR load_biker_sprite      ; Copia os dados iniciais do personagem

    LDA #$80
    STA player_x           ; Posição X inicial do personagem

    LDA #$60
    STA player_y           ; Posição Y inicial do personagem

    LDA #$00
    STA anim_counter       ; Zera contador da animação
    STA anim_frame         ; Zera frame atual da animação
    STA player_moving      ; Começa com o personagem parado

    JSR update_biker_sprite ; Atualiza a OAM shadow com posição/animação

enable_ppu:

    LDA $2002                  ; Reseta o latch da PPU

    LDA #$00
    STA $2005                  ; Scroll horizontal = 0
    STA $2005                  ; Scroll vertical = 0

    LDA #%10000000
    STA $2000                  ; Liga NMI
                               ; Background usa pattern table $0000
                               ; Sprites usam pattern table $0000

    LDA #%00011110
    STA $2001                  ; Liga background e sprites

; ------------------------------------------------------------
; CÓDIGO PRINCIPAL
; ------------------------------------------------------------

.segment "CODE"

forever:

wait_frame:
    LDA frame_ready        ; Verifica se a NMI marcou um novo frame
    BEQ wait_frame         ; Enquanto não houver frame novo, espera

    LDA #$00
    STA frame_ready        ; Consome o frame atual

    JSR read_controller    ; Lê o controle
    JSR update_player      ; Atualiza posição/movimento do jogador
    JSR update_player_animation ; Atualiza frame da animação
    JSR update_biker_sprite ; Atualiza sprites na OAM shadow

    JMP forever            ; Repete para o próximo frame

; ------------------------------------------------------------
; ARQUIVOS DO PROJETO
; ------------------------------------------------------------

.include "ppu.asm"         ; Rotinas relacionadas à PPU/OAM
.include "controller.asm"  ; Leitura do controle
.include "player.asm"      ; Movimento e animação do personagem
.include "palettes.asm"    ; Dados e carregamento de paletas
.include "biker.asm"       ; Dados do sprite composto

; ------------------------------------------------------------
; NMI
; ------------------------------------------------------------

NMI:

    LDA #$00
    STA $2003              ; Define o início da OAM como $00

    LDA #$02
    STA $4014              ; Faz DMA de $0200-$02FF para a OAM

    LDA #$01
    STA frame_ready        ; Marca que um novo frame pode ser processado

    RTI                    ; Retorna da interrupção

; ------------------------------------------------------------
; IRQ
; ------------------------------------------------------------

IRQ:

    RTI                    ; IRQ não usada neste exemplo

; ------------------------------------------------------------
; VETORES
; ------------------------------------------------------------

.segment "VECTORS"

    .word NMI              ; Vetor da NMI
    .word RESET            ; Vetor de RESET
    .word IRQ              ; Vetor da IRQ/BRK

; ------------------------------------------------------------
; CHR ROM
; ------------------------------------------------------------

.segment "CHARS"

    .incbin "game.chr"   ; Inclui os tiles gráficos do jogo