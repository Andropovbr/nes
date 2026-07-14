; ------------------------------------------------------------
; CARREGA PALETAS
; ------------------------------------------------------------

load_palettes:

    JSR load_bg_palettes          ; Carrega as paletas de background
    JSR load_sprite_palette        ; Carrega a paleta dos sprites

    RTS                            ; Retorna para quem chamou

; ------------------------------------------------------------
; CARREGA PALETAS DE BACKGROUND
; ------------------------------------------------------------
;
; $3F00-$3F03 = paleta 0: gramado
; $3F04-$3F07 = paleta 1: chão
; ------------------------------------------------------------

load_bg_palettes:

    LDA $2002                    ; Reseta o latch da PPU

    LDA #$3F
    STA $2006                    ; Byte alto de $3F00

    LDA #$00
    STA $2006                    ; Byte baixo de $3F00

    LDX #$00

load_bg_palettes_loop:

    LDA bg_palettes, x
    STA $2007

    INX
    CPX #$08                    ; Duas paletas = 8 bytes
    BNE load_bg_palettes_loop

    RTS

; ------------------------------------------------------------
; CARREGA PALETA DE SPRITES
; ------------------------------------------------------------

load_sprite_palette:

    LDA $2002                      ; Reseta o latch de endereço da PPU

    LDA #$3F                       ; Primeiro byte do endereço $3F10
    STA $2006                      ; Escreve byte alto do endereço da PPU

    LDA #$10                       ; Segundo byte do endereço $3F10
    STA $2006                      ; Escreve byte baixo do endereço da PPU

    LDX #$00                       ; X será o índice da paleta

load_sprite_palette_loop:

    LDA sprite_palette, x          ; Lê uma cor da paleta de sprites
    STA $2007                      ; Escreve essa cor na memória da PPU

    INX                            ; Avança para a próxima cor
    CPX #$08                       ; Duas paletas = 8 bytes
    BNE load_sprite_palette_loop   ; Se não, continua o loop

    RTS                            ; Retorna para quem chamou

; ------------------------------------------------------------
; CONSTANTES DO BACKGROUND
; ------------------------------------------------------------

BLANK_TILE = $18                  ; Tile vazio usado no background


; ------------------------------------------------------------
; LIMPA A NAMETABLE
; ------------------------------------------------------------
;
; Preenche as 960 posições visíveis da Nametable 0 com um
; tile vazio.
;
; A Nametable começa em $2000:
;
; $2000-$23BF = 960 tiles
; $23C0-$23FF = tabela de atributos
;
; ------------------------------------------------------------

clear_nametable:

    LDA $2002                     ; Reseta o latch de endereço da PPU

    LDA #$20                      ; Byte alto do endereço $2000
    STA $2006

    LDA #$00                      ; Byte baixo do endereço $2000
    STA $2006

    LDA #BLANK_TILE               ; Tile usado para limpar a tela

    ; 960 bytes = 3 páginas completas de 256 bytes
    ;             + 192 bytes

    LDX #$00

clear_nametable_page_1:

    STA $2007                     ; Escreve um tile vazio
    INX
    BNE clear_nametable_page_1    ; Escreve 256 bytes

    LDX #$00

clear_nametable_page_2:

    STA $2007
    INX
    BNE clear_nametable_page_2    ; Mais 256 bytes

    LDX #$00

clear_nametable_page_3:

    STA $2007
    INX
    BNE clear_nametable_page_3    ; Mais 256 bytes

    LDX #$00

clear_nametable_remaining:

    STA $2007
    INX
    CPX #$C0                      ; Mais 192 bytes
    BNE clear_nametable_remaining

    RTS

; ------------------------------------------------------------
; LIMPA A TABELA DE ATRIBUTOS
; ------------------------------------------------------------
;
; A tabela de atributos da Nametable 0 ocupa 64 bytes:
;
; $23C0-$23FF
;
; Cada grupo de 2 bits seleciona uma das quatro paletas
; de background. O valor $00 faz toda a tela usar a paleta 0.
;
; ------------------------------------------------------------

load_bg_attributes:

    LDA $2002

    LDA #$23
    STA $2006

    LDA #$C0
    STA $2006

    ; Parte superior: paleta 0
    LDA #$00
    LDX #$20

load_grass_attributes:

    STA $2007

    DEX
    BNE load_grass_attributes

    ; Parte inferior: paleta 1
    LDA #$55
    LDX #$20

load_floor_attributes:

    STA $2007

    DEX
    BNE load_floor_attributes

    RTS

; ------------------------------------------------------------
; DESENHA O GRAMADO
; ------------------------------------------------------------
;
; Os quatro tiles formam um bloco de 2x2:
;
;     $10 $11
;     $12 $13
;
; O bloco é repetido 16 vezes horizontalmente e
; 8 vezes verticalmente.
;
; Resultado:
;
;     32 tiles de largura = 256 pixels
;     16 tiles de altura  = 128 pixels
;
; ------------------------------------------------------------

draw_background:

    LDA $2002

    LDA #$20
    STA $2006

    LDA #$00
    STA $2006

    JSR draw_grass
    JSR draw_floor
    JSR draw_fence

    RTS

draw_grass:

    LDY #$08                      ; 8 blocos de altura
                                  ; Cada bloco possui duas linhas
                                  ; Total: 16 linhas de tiles

draw_grass_block:

    ; -----------------------------
    ; Linha superior do bloco
    ; -----------------------------

    LDX #$10                      ; 16 blocos na horizontal

draw_grass_top_row:

    LDA #$10                      ; Tile superior esquerdo
    STA $2007

    LDA #$11                      ; Tile superior direito
    STA $2007

    DEX
    BNE draw_grass_top_row

    ; -----------------------------
    ; Linha inferior do bloco
    ; -----------------------------

    LDX #$10                      ; 16 blocos na horizontal

draw_grass_bottom_row:

    LDA #$12                      ; Tile inferior esquerdo
    STA $2007

    LDA #$13                      ; Tile inferior direito
    STA $2007

    DEX
    BNE draw_grass_bottom_row

    DEY
    BNE draw_grass_block          ; Repete o bloco na vertical

    RTS

; ------------------------------------------------------------
; DESENHA O CHÃO
; ------------------------------------------------------------
;
; Os quatro tiles formam um bloco de 2x2:
;
;     $14 $15
;     $16 $17
;
; O bloco é repetido 16 vezes horizontalmente e
; 7 vezes verticalmente.
;
; Resultado:
;
;     32 tiles de largura = 256 pixels
;     14 tiles de altura  = 112 pixels
;
; ------------------------------------------------------------

draw_floor:

    LDY #$07                      ; 7 blocos de altura
                                  ; Cada bloco possui duas linhas
                                  ; Total: 14 linhas de tiles

draw_floor_block:

    ; -----------------------------
    ; Linha superior do bloco
    ; -----------------------------

    LDX #$10                      ; 16 blocos na horizontal

draw_floor_top_row:

    LDA #$14                      ; Tile superior esquerdo
    STA $2007

    LDA #$15                      ; Tile superior direito
    STA $2007

    DEX
    BNE draw_floor_top_row

    ; -----------------------------
    ; Linha inferior do bloco
    ; -----------------------------

    LDX #$10                      ; 16 blocos na horizontal

draw_floor_bottom_row:

    LDA #$16                      ; Tile inferior esquerdo
    STA $2007

    LDA #$17                      ; Tile inferior direito
    STA $2007

    DEX
    BNE draw_floor_bottom_row

    DEY
    BNE draw_floor_block          ; Repete o bloco na vertical

    RTS

; ------------------------------------------------------------
; DESENHA UMA CERCA
; ------------------------------------------------------------
;
; Cada bloco da cerca possui 2x2 tiles:
;
;     $0C $0D
;     $0E $0F
;
; Neste exemplo, a cerca começa na linha 6, coluna 10
; e possui 4 blocos de largura.
;
; Posição em pixels:
;
;     X = 10 * 8 = 80
;     Y = 6 * 8  = 48
;
; Tamanho:
;
;     largura = 4 * 16 = 64 pixels
;     altura  = 16 pixels
;
; ------------------------------------------------------------

draw_fence:

    ; --------------------------------
    ; Linha superior da cerca
    ; Endereço: $2100 + (6 * 32) + 10
    ;          $2100 + $C0 + $0A
    ;          $21CD
    ; --------------------------------

    LDA $2002                     ; Reseta o latch da PPU

    LDA #$21
    STA $2006

    LDA #$CD
    STA $2006

    LDX #$04                      ; 4 blocos de largura

draw_fence_top:

    LDA #$0C
    STA $2007

    LDA #$0D
    STA $2007

    DEX
    BNE draw_fence_top

    ; --------------------------------
    ; Linha inferior da cerca
    ; Uma linha abaixo = +32 bytes
    ; $21CD + $20 = $21ED
    ; --------------------------------

    LDA $2002

    LDA #$21
    STA $2006

    LDA #$ED
    STA $2006

    LDX #$04

draw_fence_bottom:

    LDA #$0E
    STA $2007

    LDA #$0F
    STA $2007

    DEX
    BNE draw_fence_bottom

    RTS

; ------------------------------------------------------------
; COPIA DADOS INICIAIS DO SPRITE COMPOSTO PARA A OAM SHADOW
; ------------------------------------------------------------

load_biker_sprite:

    LDX #$00                       ; Começa copiando do byte 0

load_biker_sprite_loop:

    LDA biker_sprite, x            ; Lê um byte da tabela biker_sprite
    STA $0200, x                   ; Copia para a OAM shadow em RAM

    INX                            ; Avança para o próximo byte
    CPX #$24                       ; Copiou 36 bytes? 9 sprites * 4 bytes
    BNE load_biker_sprite_loop     ; Se não, continua copiando

    RTS                            ; Retorna para quem chamou

; ------------------------------------------------------------
; ATUALIZA POSIÇÃO DO SPRITE COMPOSTO
; ------------------------------------------------------------

update_biker_sprite:

    LDA player_direction           ; Carrega a direção atual do jogador
    BEQ update_biker_sprite_right  ; Se for 0, personagem olha para a direita

    JMP update_biker_sprite_left   ; Caso contrário, olha para a esquerda

; ------------------------------------------------------------
; ATUALIZA SPRITE OLHANDO PARA A DIREITA
; ------------------------------------------------------------

update_biker_sprite_right:

    ; -----------------------------
    ; Linha 1
    ; -----------------------------

    LDA player_y                   ; Carrega posição Y base do jogador
    STA $0200                      ; Y do sprite 1
    STA $0204                      ; Y do sprite 2
    STA $0208                      ; Y do sprite 3

    LDA player_x                   ; Carrega posição X base do jogador
    STA $0203                      ; X do sprite 1

    CLC                            ; Limpa o carry antes da soma
    ADC #$08                       ; Soma 8 pixels
    STA $0207                      ; X do sprite 2

    CLC                            ; Limpa o carry antes da soma
    ADC #$08                       ; Soma mais 8 pixels
    STA $020B                      ; X do sprite 3

    ; -----------------------------
    ; Linha 2
    ; -----------------------------

    LDA player_y                   ; Carrega posição Y base
    CLC                            ; Limpa o carry antes da soma
    ADC #$08                       ; Linha 2 fica 8 pixels abaixo
    STA $020C                      ; Y do sprite 4
    STA $0210                      ; Y do sprite 5
    STA $0214                      ; Y do sprite 6

    LDA player_x                   ; Carrega posição X base
    STA $020F                      ; X do sprite 4

    CLC                            ; Limpa o carry antes da soma
    ADC #$08                       ; Soma 8 pixels
    STA $0213                      ; X do sprite 5

    CLC                            ; Limpa o carry antes da soma
    ADC #$08                       ; Soma mais 8 pixels
    STA $0217                      ; X do sprite 6

    ; -----------------------------
    ; Linha 3
    ; -----------------------------

    LDA player_y                   ; Carrega posição Y base
    CLC                            ; Limpa o carry antes da soma
    ADC #$10                       ; Linha 3 fica 16 pixels abaixo
    STA $0218                      ; Y do sprite 7
    STA $021C                      ; Y do sprite 8
    STA $0220                      ; Y do sprite 9

    LDA player_x                   ; Carrega posição X base
    STA $021B                      ; X do sprite 7

    CLC                            ; Limpa o carry antes da soma
    ADC #$08                       ; Soma 8 pixels
    STA $021F                      ; X do sprite 8

    CLC                            ; Limpa o carry antes da soma
    ADC #$08                       ; Soma mais 8 pixels
    STA $0223                      ; X do sprite 9

    JSR update_biker_animation_tiles ; Atualiza tiles dos pés
    JSR update_biker_attributes_right ; Remove flip horizontal

    RTS                            ; Retorna para quem chamou

; ------------------------------------------------------------
; ATUALIZA SPRITE OLHANDO PARA A ESQUERDA
; ------------------------------------------------------------

update_biker_sprite_left:

    ; -----------------------------
    ; Linha 1
    ; -----------------------------

    LDA player_y                   ; Carrega posição Y base do jogador
    STA $0200                      ; Y do sprite 1
    STA $0204                      ; Y do sprite 2
    STA $0208                      ; Y do sprite 3

    LDA player_x                   ; Carrega posição X base
    CLC                            ; Limpa o carry antes da soma
    ADC #$10                       ; Sprite 1 vai para a direita
    STA $0203                      ; X do sprite 1

    LDA player_x                   ; Recarrega posição X base
    CLC                            ; Limpa o carry antes da soma
    ADC #$08                       ; Sprite 2 fica no meio
    STA $0207                      ; X do sprite 2

    LDA player_x                   ; Recarrega posição X base
    STA $020B                      ; Sprite 3 vai para a esquerda

    ; -----------------------------
    ; Linha 2
    ; -----------------------------

    LDA player_y                   ; Carrega posição Y base
    CLC                            ; Limpa o carry antes da soma
    ADC #$08                       ; Linha 2 fica 8 pixels abaixo
    STA $020C                      ; Y do sprite 4
    STA $0210                      ; Y do sprite 5
    STA $0214                      ; Y do sprite 6

    LDA player_x                   ; Carrega posição X base
    CLC                            ; Limpa o carry antes da soma
    ADC #$10                       ; Sprite 4 vai para a direita
    STA $020F                      ; X do sprite 4

    LDA player_x                   ; Recarrega posição X base
    CLC                            ; Limpa o carry antes da soma
    ADC #$08                       ; Sprite 5 fica no meio
    STA $0213                      ; X do sprite 5

    LDA player_x                   ; Recarrega posição X base
    STA $0217                      ; Sprite 6 vai para a esquerda

    ; -----------------------------
    ; Linha 3
    ; -----------------------------

    LDA player_y                   ; Carrega posição Y base
    CLC                            ; Limpa o carry antes da soma
    ADC #$10                       ; Linha 3 fica 16 pixels abaixo
    STA $0218                      ; Y do sprite 7
    STA $021C                      ; Y do sprite 8
    STA $0220                      ; Y do sprite 9

    LDA player_x                   ; Carrega posição X base
    CLC                            ; Limpa o carry antes da soma
    ADC #$10                       ; Sprite 7 vai para a direita
    STA $021B                      ; X do sprite 7

    LDA player_x                   ; Recarrega posição X base
    CLC                            ; Limpa o carry antes da soma
    ADC #$08                       ; Sprite 8 fica no meio
    STA $021F                      ; X do sprite 8

    LDA player_x                   ; Recarrega posição X base
    STA $0223                      ; Sprite 9 vai para a esquerda

    JSR update_biker_animation_tiles ; Atualiza tiles dos pés
    JSR update_biker_attributes_left  ; Aplica flip horizontal

    RTS                            ; Retorna para quem chamou

; ------------------------------------------------------------
; ATRIBUTOS DO SPRITE OLHANDO PARA A DIREITA
; ------------------------------------------------------------

update_biker_attributes_right:

    LDA #$00                       ; Sem flip, paleta 0, prioridade padrão

    STA $0202                      ; Atributos do sprite 1
    STA $0206                      ; Atributos do sprite 2
    STA $020A                      ; Atributos do sprite 3

    STA $020E                      ; Atributos do sprite 4
    STA $0212                      ; Atributos do sprite 5
    STA $0216                      ; Atributos do sprite 6

    STA $021A                      ; Atributos do sprite 7
    STA $021E                      ; Atributos do sprite 8
    STA $0222                      ; Atributos do sprite 9

    RTS                            ; Retorna para quem chamou

; ------------------------------------------------------------
; ATRIBUTOS DO SPRITE OLHANDO PARA A ESQUERDA
; ------------------------------------------------------------

update_biker_attributes_left:

    LDA #$40                       ; Ativa flip horizontal nos sprites

    STA $0202                      ; Atributos do sprite 1
    STA $0206                      ; Atributos do sprite 2
    STA $020A                      ; Atributos do sprite 3

    STA $020E                      ; Atributos do sprite 4
    STA $0212                      ; Atributos do sprite 5
    STA $0216                      ; Atributos do sprite 6

    STA $021A                      ; Atributos do sprite 7
    STA $021E                      ; Atributos do sprite 8
    STA $0222                      ; Atributos do sprite 9

    RTS                            ; Retorna para quem chamou

; ------------------------------------------------------------
; ATUALIZA TILES DE ANIMAÇÃO DO SPRITE COMPOSTO
; ------------------------------------------------------------
;
; Apenas a linha 3 muda durante a caminhada.
; As duas primeiras linhas ficam sempre iguais.
; ------------------------------------------------------------

update_biker_animation_tiles:

    LDA anim_frame                 ; Carrega o frame atual da animação
    CMP #$00                       ; O frame atual é o frame 0?
    BEQ biker_anim_frame_0         ; Se sim, usa tiles $20, $21 e $22

    JMP biker_anim_frame_1         ; Caso contrário, usa tiles $23, $24 e $25

biker_anim_frame_0:

    LDA #$06                       ; Tile do pé esquerdo no frame 0
    STA $0219                      ; Atualiza tile do sprite 7

    LDA #$07                       ; Tile do pé central no frame 0
    STA $021D                      ; Atualiza tile do sprite 8

    LDA #$08                       ; Tile do pé direito no frame 0
    STA $0221                      ; Atualiza tile do sprite 9

    RTS                            ; Retorna para quem chamou

biker_anim_frame_1:

    LDA #$09                       ; Tile do pé esquerdo no frame 1
    STA $0219                      ; Atualiza tile do sprite 7

    LDA #$0A                       ; Tile do pé central no frame 1
    STA $021D                      ; Atualiza tile do sprite 8

    LDA #$0B                       ; Tile do pé direito no frame 1
    STA $0221                      ; Atualiza tile do sprite 9

    RTS                            ; Retorna para quem chamou