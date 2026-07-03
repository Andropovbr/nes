; ------------------------------------------------------------
; CARREGA PALETAS
; ------------------------------------------------------------

load_palettes:

    JSR load_bg_palette
    JSR load_sprite_palette

    RTS

; ------------------------------------------------------------
; CARREGA PALETA DE BACKGROUND
; ------------------------------------------------------------

load_bg_palette:

    LDA $2002

    LDA #$3F
    STA $2006

    LDA #$00
    STA $2006

    LDX #$00

load_bg_palette_loop:

    LDA bg_palette, x
    STA $2007

    INX
    CPX #$04
    BNE load_bg_palette_loop

    RTS

; ------------------------------------------------------------
; CARREGA PALETA DE SPRITES
; ------------------------------------------------------------

load_sprite_palette:

    LDA $2002

    LDA #$3F
    STA $2006

    LDA #$10
    STA $2006

    LDX #$00

load_sprite_palette_loop:

    LDA sprite_palette, x
    STA $2007

    INX
    CPX #$04
    BNE load_sprite_palette_loop

    RTS

; ------------------------------------------------------------
; COPIA DADOS INICIAIS DO SPRITE COMPOSTO PARA A OAM
; ------------------------------------------------------------

load_biker_sprite:

    LDX #$00

load_biker_sprite_loop:

    LDA biker_sprite, x
    STA $0200, x

    INX
    CPX #$24
    BNE load_biker_sprite_loop

    RTS

; ------------------------------------------------------------
; ATUALIZA POSIÇÃO DO SPRITE COMPOSTO
; ------------------------------------------------------------

; ------------------------------------------------------------
; ATUALIZA POSIÇÃO DO SPRITE COMPOSTO
; ------------------------------------------------------------

update_biker_sprite:

    LDA player_direction
    BEQ update_biker_sprite_right

    JMP update_biker_sprite_left

update_biker_sprite_right:

    ; Linha 1

    LDA player_y
    STA $0200
    STA $0204
    STA $0208

    LDA player_x
    STA $0203

    CLC
    ADC #$08
    STA $0207

    CLC
    ADC #$08
    STA $020B

    ; Linha 2

    LDA player_y
    CLC
    ADC #$08
    STA $020C
    STA $0210
    STA $0214

    LDA player_x
    STA $020F

    CLC
    ADC #$08
    STA $0213

    CLC
    ADC #$08
    STA $0217

    ; Linha 3

    LDA player_y
    CLC
    ADC #$10
    STA $0218
    STA $021C
    STA $0220

    LDA player_x
    STA $021B

    CLC
    ADC #$08
    STA $021F

    CLC
    ADC #$08
    STA $0223

    JSR update_biker_animation_tiles
    JSR update_biker_attributes_right

    RTS

update_biker_sprite_left:

    ; Linha 1

    LDA player_y
    STA $0200
    STA $0204
    STA $0208

    LDA player_x
    CLC
    ADC #$10
    STA $0203

    LDA player_x
    CLC
    ADC #$08
    STA $0207

    LDA player_x
    STA $020B

    ; Linha 2

    LDA player_y
    CLC
    ADC #$08
    STA $020C
    STA $0210
    STA $0214

    LDA player_x
    CLC
    ADC #$10
    STA $020F

    LDA player_x
    CLC
    ADC #$08
    STA $0213

    LDA player_x
    STA $0217

    ; Linha 3

    LDA player_y
    CLC
    ADC #$10
    STA $0218
    STA $021C
    STA $0220

    LDA player_x
    CLC
    ADC #$10
    STA $021B

    LDA player_x
    CLC
    ADC #$08
    STA $021F

    LDA player_x
    STA $0223

    JSR update_biker_animation_tiles
    JSR update_biker_attributes_left

    RTS

update_biker_attributes_right:

    LDA #$00

    STA $0202
    STA $0206
    STA $020A

    STA $020E
    STA $0212
    STA $0216

    STA $021A
    STA $021E
    STA $0222

    RTS

update_biker_attributes_left:

    LDA #$40                ; flip horizontal

    STA $0202
    STA $0206
    STA $020A

    STA $020E
    STA $0212
    STA $0216

    STA $021A
    STA $021E
    STA $0222

    RTS

; ------------------------------------------------------------
; ATUALIZA TILES DE ANIMAÇÃO DO SPRITE COMPOSTO
; ------------------------------------------------------------
;
; Apenas a linha 3 muda durante a caminhada.
; ------------------------------------------------------------

update_biker_animation_tiles:

    LDA anim_frame
    CMP #$00
    BEQ biker_anim_frame_0

    JMP biker_anim_frame_1

biker_anim_frame_0:

    LDA #$20
    STA $0219

    LDA #$21
    STA $021D

    LDA #$22
    STA $0221

    RTS

biker_anim_frame_1:

    LDA #$23
    STA $0219

    LDA #$24
    STA $021D

    LDA #$25
    STA $0221

    RTS