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
    BIT $2002
    BPL vblankwait2

    ; --------------------------------------------------------
    ; INICIALIZA A ENGINE DE EFEITOS SONOROS
    ; --------------------------------------------------------
    ;
    ; O arquivo exportado pelo FamiStudio normalmente cria
    ; um label chamado "sounds".
    ;
    ; X recebe o byte baixo do endereço.
    ; Y recebe o byte alto do endereço.
    ;
    ; --------------------------------------------------------

    LDX #<sounds
    LDY #>sounds
    JSR famistudio_sfx_init

    JSR load_palettes       ; Carrega as paletas de cores na PPU
    JSR clear_nametable     ; Limpa o mapa de tiles na PPU
    JSR draw_background     ; Desenha o gramado e o chão na PPU
    JSR load_bg_attributes  ; Carrega os atributos do mapa de tiles na PPU

    JSR load_biker_sprite   ; Copia os dados iniciais do personagem
    JSR initialize_game     ; Inicializa jogador, inimigo e projétil

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

    ; A inicialização terminou.
    ; Salta explicitamente para o loop principal.
    ;
    ; Isso evita que a execução caia acidentalmente na rotina
    ; initialize_game, que termina com RTS e deve ser chamada
    ; somente através de JSR.

    JMP forever

; ------------------------------------------------------------
; CÓDIGO PRINCIPAL
; ------------------------------------------------------------

.segment "CODE"

; ------------------------------------------------------------
; INICIALIZA UMA NOVA PARTIDA
; ------------------------------------------------------------
;
; Esta rotina reinicia somente o estado do jogo.
;
; Ela não:
;
; - limpa a RAM inteira;
; - recarrega paletas;
; - redesenha a nametable;
; - reinicializa a PPU;
;
; Portanto, pode ser chamada quando o jogador pressionar Start
; sem executar novamente todo o processo de RESET do console.
;
; ------------------------------------------------------------

initialize_game:

    ; --------------------------------------------------------
    ; ESTADO GERAL
    ; --------------------------------------------------------

    LDA #$00
    STA game_over

    ; Nenhum projétil ativo.

    STA projectile_active

    ; Limpa o estado do controle.

    STA controller_pressed

    ; Copia o estado atual do controle.
    ;
    ; Assim o jogador pode manter Start pressionado sem provocar
    ; reinicializações sucessivas.

    LDA controller1
    STA previous_controller1


    ; --------------------------------------------------------
    ; JOGADOR
    ; --------------------------------------------------------

    LDA #$80
    STA player_x

    LDA #$40
    STA player_y

    LDA #$00
    STA player_direction
    STA player_moving
    STA anim_counter
    STA anim_frame

    LDA #$01
    STA player_alive


    ; --------------------------------------------------------
    ; INIMIGO
    ; --------------------------------------------------------

    LDA #$20
    STA enemy_x

    LDA #$B0
    STA enemy_y

    LDA #$00
    STA enemy_direction
    STA enemy_moving
    STA enemy_move_counter
    STA enemy_anim_counter
    STA enemy_anim_frame

    LDA #$01
    STA enemy_alive


    ; --------------------------------------------------------
    ; PROJÉTIL
    ; --------------------------------------------------------
    ;
    ; As coordenadas não seriam utilizadas enquanto o projétil
    ; estivesse inativo, mas são zeradas para manter um estado
    ; inicial bem definido.
    ;
    ; --------------------------------------------------------

    LDA #$00
    STA projectile_x
    STA projectile_y
    STA projectile_direction


    ; --------------------------------------------------------
    ; ATUALIZA A OAM SHADOW
    ; --------------------------------------------------------

    JSR update_biker_sprite
    JSR update_enemy_sprite
    JSR update_projectile_sprite

    RTS

forever:

wait_frame:

    LDA frame_ready
    BEQ wait_frame

    LDA #$00
    STA frame_ready

    ; --------------------------------------------------------
    ; LEITURA DO CONTROLE
    ; --------------------------------------------------------

    JSR read_controller
    JSR update_controller_pressed


    ; --------------------------------------------------------
    ; VERIFICA O ESTADO DO JOGO
    ; --------------------------------------------------------
    ;
    ; Se game_over for diferente de zero, não atualiza mais
    ; jogador, inimigo ou projétil.
    ;
    ; Apenas espera o jogador pressionar Start.
    ;
    ; --------------------------------------------------------

    LDA game_over
    BNE update_game_over


; ------------------------------------------------------------
; JOGO EM ANDAMENTO
; ------------------------------------------------------------

update_running_game:

    ; --------------------------------------------------------
    ; JOGADOR
    ; --------------------------------------------------------

    JSR update_player
    JSR update_player_animation


    ; --------------------------------------------------------
    ; PROJÉTIL
    ; --------------------------------------------------------

    JSR check_projectile_input
    JSR update_projectile


    ; --------------------------------------------------------
    ; INIMIGO
    ; --------------------------------------------------------

    JSR update_enemy
    JSR update_enemy_animation


    ; --------------------------------------------------------
    ; COLISÃO ENTRE PROJÉTIL E INIMIGO
    ; --------------------------------------------------------

    JSR check_projectile_enemy_collision

    LDA collision
    BEQ check_enemy_player_collision

    ; --------------------------------------------------------
    ; O projétil atingiu o inimigo.
    ; --------------------------------------------------------

    LDA #$00
    STA projectile_active      ; Remove o projétil

    LDA #$00
    STA enemy_alive            ; Marca o inimigo como morto

    ; --------------------------------------------------------
    ; A partida terminou.
    ;
    ; O jogador venceu.
    ; --------------------------------------------------------

    LDA #$01
    STA game_over

    JMP update_game_sprites


; ------------------------------------------------------------
; COLISÃO ENTRE INIMIGO E JOGADOR
; ------------------------------------------------------------

check_enemy_player_collision:

    ; Se o inimigo morreu neste frame, não pode também matar
    ; o jogador no mesmo frame.

    LDA enemy_alive
    BEQ update_game_sprites

    JSR check_player_enemy_collision

    LDA collision
    BEQ update_game_sprites

    ; O inimigo atingiu o jogador.

    LDA #$00
    STA player_alive
    STA projectile_active

    ; Entra no estado de fim de jogo.

    LDA #$01
    STA game_over


; ------------------------------------------------------------
; ATUALIZA A OAM SHADOW
; ------------------------------------------------------------

update_game_sprites:

    JSR update_biker_sprite
    JSR update_enemy_sprite
    JSR update_projectile_sprite

    JMP forever


; ------------------------------------------------------------
; PARTIDA ENCERRADA
; ------------------------------------------------------------
;
; Enquanto game_over = 1:
;
; • jogador não se move
; • inimigo não se move
; • projétil não se move
;
; O único botão aceito é Start.
;
; ------------------------------------------------------------

update_game_over:

    ; Verifica se Start acabou de ser pressionado.

    LDA controller_pressed
    AND #%00010000
    BEQ update_game_over_sprites

    ; --------------------------------------------------------
    ; Reinicia toda a partida.
    ; --------------------------------------------------------

    JSR initialize_game

    JMP forever


; ------------------------------------------------------------
; MANTÉM A OAM SHADOW CONSISTENTE DURANTE O GAME OVER
; ------------------------------------------------------------

update_game_over_sprites:

    JSR update_biker_sprite
    JSR update_enemy_sprite
    JSR update_projectile_sprite

    JMP forever

; ------------------------------------------------------------
; CONFIGURAÇÃO DA FAMISTUDIO SOUND ENGINE
; ------------------------------------------------------------
;
; A configuração externa permite manter o arquivo original da
; engine sem modificações.
;
; ------------------------------------------------------------

FAMISTUDIO_CFG_EXTERNAL = 1

; ------------------------------------------------------------
; SEGMENTOS DO LINKER
; ------------------------------------------------------------

.define FAMISTUDIO_CA65_ZP_SEGMENT   ZEROPAGE
.define FAMISTUDIO_CA65_RAM_SEGMENT  BSS
.define FAMISTUDIO_CA65_CODE_SEGMENT CODE

; ------------------------------------------------------------
; PADRÃO DE VÍDEO
; ------------------------------------------------------------
;
; A demo utiliza NTSC.
;
; ------------------------------------------------------------

FAMISTUDIO_CFG_NTSC_SUPPORT = 1
FAMISTUDIO_CFG_PAL_SUPPORT  = 0

; ------------------------------------------------------------
; EFEITOS SONOROS
; ------------------------------------------------------------

FAMISTUDIO_CFG_SFX_SUPPORT = 1

; Apenas um efeito será reproduzido simultaneamente por enquanto.

FAMISTUDIO_CFG_SFX_STREAMS = 1

; ------------------------------------------------------------
; ACESSO ENTRE LOOP PRINCIPAL E NMI
; ------------------------------------------------------------
;
; O efeito será iniciado pelo loop principal, enquanto a engine
; será atualizada dentro da NMI.
;
; Por isso, habilitamos a proteção para chamadas feitas por
; contextos diferentes.
;
; ------------------------------------------------------------

FAMISTUDIO_CFG_THREAD = 1

; ------------------------------------------------------------
; DPCM
; ------------------------------------------------------------
;
; Os efeitos atuais não utilizam amostras digitalizadas.
;
; ------------------------------------------------------------

FAMISTUDIO_CFG_DPCM_SUPPORT = 0

; ------------------------------------------------------------
; ARQUIVOS DO PROJETO
; ------------------------------------------------------------

; Dados e engine de áudio.

.include "../audio/sfx.inc"
.include "../audio/sfx.s"
.include "../audio/famistudio_ca65.s"

; Código do jogo.

.include "ppu.asm"
.include "controller.asm"
.include "collision.asm"
.include "player.asm"
.include "enemy.asm"
.include "projectile.asm"
.include "palettes.asm"
.include "biker.asm"

; ------------------------------------------------------------
; NMI
; ------------------------------------------------------------

NMI:

    ; --------------------------------------------------------
    ; PRESERVA OS REGISTRADORES
    ; --------------------------------------------------------
    ;
    ; A NMI pode acontecer no meio de qualquer rotina do jogo.
    ; Por isso, preservamos A, X e Y antes de utilizá-los.
    ;
    ; --------------------------------------------------------

    PHA

    TXA
    PHA

    TYA
    PHA

    LDA #$00
    STA $2003              ; Define o início da OAM como $00

    LDA #$02
    STA $4014              ; Faz DMA de $0200-$02FF para a OAM

     ; --------------------------------------------------------
    ; ATUALIZA O ÁUDIO
    ; --------------------------------------------------------
    ;
    ; Deve ser chamada exatamente uma vez por frame.
    ;
    ; --------------------------------------------------------

    JSR famistudio_update


    ; --------------------------------------------------------
    ; LIBERA O PRÓXIMO FRAME
    ; --------------------------------------------------------

    LDA #$01
    STA frame_ready


    ; --------------------------------------------------------
    ; RESTAURA OS REGISTRADORES
    ; --------------------------------------------------------

    PLA
    TAY

    PLA
    TAX

    PLA

    RTI

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