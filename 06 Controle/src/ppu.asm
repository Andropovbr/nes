; ------------------------------------------------------------
; CARREGA PALETAS
; ------------------------------------------------------------

load_palettes:

    JSR load_bg_palette            ; Carrega a paleta do background
    JSR load_sprite_palette        ; Carrega a paleta dos sprites

    RTS                            ; Retorna para quem chamou

; ------------------------------------------------------------
; CARREGA PALETA DE BACKGROUND
; ------------------------------------------------------------

load_bg_palette:

    LDA $2002                      ; Reseta o latch de endereço da PPU

    LDA #$3F                       ; Primeiro byte do endereço $3F00
    STA $2006                      ; Escreve byte alto do endereço da PPU

    LDA #$00                       ; Segundo byte do endereço $3F00
    STA $2006                      ; Escreve byte baixo do endereço da PPU

    LDX #$00                       ; X será o índice da paleta

load_bg_palette_loop:

    LDA bg_palette, x              ; Lê uma cor da paleta de background
    STA $2007                      ; Escreve essa cor na memória da PPU

    INX                            ; Avança para a próxima cor
    CPX #$04                       ; Já carregou 4 cores?
    BNE load_bg_palette_loop       ; Se não, continua o loop

    RTS                            ; Retorna para quem chamou

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
    CPX #$04                       ; Já carregou 4 cores?
    BNE load_sprite_palette_loop   ; Se não, continua o loop

    RTS                            ; Retorna para quem chamou

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

    LDA #$20                       ; Tile do pé esquerdo no frame 0
    STA $0219                      ; Atualiza tile do sprite 7

    LDA #$21                       ; Tile do pé central no frame 0
    STA $021D                      ; Atualiza tile do sprite 8

    LDA #$22                       ; Tile do pé direito no frame 0
    STA $0221                      ; Atualiza tile do sprite 9

    RTS                            ; Retorna para quem chamou

biker_anim_frame_1:

    LDA #$23                       ; Tile do pé esquerdo no frame 1
    STA $0219                      ; Atualiza tile do sprite 7

    LDA #$24                       ; Tile do pé central no frame 1
    STA $021D                      ; Atualiza tile do sprite 8

    LDA #$25                       ; Tile do pé direito no frame 1
    STA $0221                      ; Atualiza tile do sprite 9

    RTS                            ; Retorna para quem chamou