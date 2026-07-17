load_palettes:                                   ; Define o ponto de entrada load_palettes
    JSR load_bg_palettes                         ; Executa a rotina indicada
    JSR load_sprite_palette                      ; Executa a rotina indicada
    RTS                                          ; Retorna para a rotina chamadora
load_bg_palettes:                                ; Define o ponto de entrada load_bg_palettes
    LDA $2002                                    ; Carrega o valor no acumulador
    LDA #$3F                                     ; Carrega o valor no acumulador
    STA $2006                                    ; Armazena o acumulador no destino
    LDA #$00                                     ; Carrega o valor no acumulador
    STA $2006                                    ; Armazena o acumulador no destino
    LDX #$00                                     ; Carrega o valor no registrador X
load_bg_palettes_loop:                           ; Define o ponto de entrada load_bg_palettes_loop
    LDA bg_palettes, x                           ; Carrega o valor no acumulador
    STA $2007                                    ; Armazena o acumulador no destino
    INX                                          ; Incrementa o registrador X
    CPX #$08                                     ; Compara o registrador X com o operando
    BNE load_bg_palettes_loop                    ; Desvia quando o resultado anterior nao e zero
    RTS                                          ; Retorna para a rotina chamadora
load_sprite_palette:                             ; Define o ponto de entrada load_sprite_palette
    LDA $2002                                    ; Carrega o valor no acumulador
    LDA #$3F                                     ; Carrega o valor no acumulador
    STA $2006                                    ; Armazena o acumulador no destino
    LDA #$10                                     ; Carrega o valor no acumulador
    STA $2006                                    ; Armazena o acumulador no destino
    LDX #$00                                     ; Carrega o valor no registrador X
load_sprite_palette_loop:                        ; Define o ponto de entrada load_sprite_palette_loop
    LDA sprite_palette, x                        ; Carrega o valor no acumulador
    STA $2007                                    ; Armazena o acumulador no destino
    INX                                          ; Incrementa o registrador X
    CPX #$08                                     ; Compara o registrador X com o operando
    BNE load_sprite_palette_loop                 ; Desvia quando o resultado anterior nao e zero
    RTS                                          ; Retorna para a rotina chamadora
BLANK_TILE = $18                                 ; Configura a constante BLANK_TILE
clear_nametable:                                 ; Define o ponto de entrada clear_nametable
    LDA $2002                                    ; Carrega o valor no acumulador
    LDA #$20                                     ; Carrega o valor no acumulador
    STA $2006                                    ; Armazena o acumulador no destino
    LDA #$00                                     ; Carrega o valor no acumulador
    STA $2006                                    ; Armazena o acumulador no destino
    LDA #BLANK_TILE                              ; Carrega o valor no acumulador
    LDX #$00                                     ; Carrega o valor no registrador X
clear_nametable_page_1:                          ; Define o ponto de entrada clear_nametable_page_1
    STA $2007                                    ; Armazena o acumulador no destino
    INX                                          ; Incrementa o registrador X
    BNE clear_nametable_page_1                   ; Desvia quando o resultado anterior nao e zero
    LDX #$00                                     ; Carrega o valor no registrador X
clear_nametable_page_2:                          ; Define o ponto de entrada clear_nametable_page_2
    STA $2007                                    ; Armazena o acumulador no destino
    INX                                          ; Incrementa o registrador X
    BNE clear_nametable_page_2                   ; Desvia quando o resultado anterior nao e zero
    LDX #$00                                     ; Carrega o valor no registrador X
clear_nametable_page_3:                          ; Define o ponto de entrada clear_nametable_page_3
    STA $2007                                    ; Armazena o acumulador no destino
    INX                                          ; Incrementa o registrador X
    BNE clear_nametable_page_3                   ; Desvia quando o resultado anterior nao e zero
    LDX #$00                                     ; Carrega o valor no registrador X
clear_nametable_remaining:                       ; Define o ponto de entrada clear_nametable_remaining
    STA $2007                                    ; Armazena o acumulador no destino
    INX                                          ; Incrementa o registrador X
    CPX #$C0                                     ; Compara o registrador X com o operando
    BNE clear_nametable_remaining                ; Desvia quando o resultado anterior nao e zero
    RTS                                          ; Retorna para a rotina chamadora
load_bg_attributes:                              ; Define o ponto de entrada load_bg_attributes
    LDA $2002                                    ; Carrega o valor no acumulador
    LDA #$23                                     ; Carrega o valor no acumulador
    STA $2006                                    ; Armazena o acumulador no destino
    LDA #$C0                                     ; Carrega o valor no acumulador
    STA $2006                                    ; Armazena o acumulador no destino
    LDA #$00                                     ; Carrega o valor no acumulador
    LDX #$20                                     ; Carrega o valor no registrador X
load_grass_attributes:                           ; Define o ponto de entrada load_grass_attributes
    STA $2007                                    ; Armazena o acumulador no destino
    DEX                                          ; Decrementa o registrador X
    BNE load_grass_attributes                    ; Desvia quando o resultado anterior nao e zero
    LDA #$55                                     ; Carrega o valor no acumulador
    LDX #$20                                     ; Carrega o valor no registrador X
load_floor_attributes:                           ; Define o ponto de entrada load_floor_attributes
    STA $2007                                    ; Armazena o acumulador no destino
    DEX                                          ; Decrementa o registrador X
    BNE load_floor_attributes                    ; Desvia quando o resultado anterior nao e zero
    RTS                                          ; Retorna para a rotina chamadora
draw_background:                                 ; Define o ponto de entrada draw_background
    LDA $2002                                    ; Carrega o valor no acumulador
    LDA #$20                                     ; Carrega o valor no acumulador
    STA $2006                                    ; Armazena o acumulador no destino
    LDA #$00                                     ; Carrega o valor no acumulador
    STA $2006                                    ; Armazena o acumulador no destino
    JSR draw_grass                               ; Executa a rotina indicada
    JSR draw_floor                               ; Executa a rotina indicada
    JSR draw_fence                               ; Executa a rotina indicada
    RTS                                          ; Retorna para a rotina chamadora
draw_grass:                                      ; Define o ponto de entrada draw_grass
    LDY #$08                                     ; Carrega o valor no registrador Y
draw_grass_block:                                ; Define o ponto de entrada draw_grass_block
    LDX #$10                                     ; Carrega o valor no registrador X
draw_grass_top_row:                              ; Define o ponto de entrada draw_grass_top_row
    LDA #$10                                     ; Carrega o valor no acumulador
    STA $2007                                    ; Armazena o acumulador no destino
    LDA #$11                                     ; Carrega o valor no acumulador
    STA $2007                                    ; Armazena o acumulador no destino
    DEX                                          ; Decrementa o registrador X
    BNE draw_grass_top_row                       ; Desvia quando o resultado anterior nao e zero
    LDX #$10                                     ; Carrega o valor no registrador X
draw_grass_bottom_row:                           ; Define o ponto de entrada draw_grass_bottom_row
    LDA #$12                                     ; Carrega o valor no acumulador
    STA $2007                                    ; Armazena o acumulador no destino
    LDA #$13                                     ; Carrega o valor no acumulador
    STA $2007                                    ; Armazena o acumulador no destino
    DEX                                          ; Decrementa o registrador X
    BNE draw_grass_bottom_row                    ; Desvia quando o resultado anterior nao e zero
    DEY                                          ; Decrementa o registrador Y
    BNE draw_grass_block                         ; Desvia quando o resultado anterior nao e zero
    RTS                                          ; Retorna para a rotina chamadora
draw_floor:                                      ; Define o ponto de entrada draw_floor
    LDY #$07                                     ; Carrega o valor no registrador Y
draw_floor_block:                                ; Define o ponto de entrada draw_floor_block
    LDX #$10                                     ; Carrega o valor no registrador X
draw_floor_top_row:                              ; Define o ponto de entrada draw_floor_top_row
    LDA #$14                                     ; Carrega o valor no acumulador
    STA $2007                                    ; Armazena o acumulador no destino
    LDA #$15                                     ; Carrega o valor no acumulador
    STA $2007                                    ; Armazena o acumulador no destino
    DEX                                          ; Decrementa o registrador X
    BNE draw_floor_top_row                       ; Desvia quando o resultado anterior nao e zero
    LDX #$10                                     ; Carrega o valor no registrador X
draw_floor_bottom_row:                           ; Define o ponto de entrada draw_floor_bottom_row
    LDA #$16                                     ; Carrega o valor no acumulador
    STA $2007                                    ; Armazena o acumulador no destino
    LDA #$17                                     ; Carrega o valor no acumulador
    STA $2007                                    ; Armazena o acumulador no destino
    DEX                                          ; Decrementa o registrador X
    BNE draw_floor_bottom_row                    ; Desvia quando o resultado anterior nao e zero
    DEY                                          ; Decrementa o registrador Y
    BNE draw_floor_block                         ; Desvia quando o resultado anterior nao e zero
    RTS                                          ; Retorna para a rotina chamadora
draw_fence:                                      ; Define o ponto de entrada draw_fence
    LDA $2002                                    ; Carrega o valor no acumulador
    LDA #$21                                     ; Carrega o valor no acumulador
    STA $2006                                    ; Armazena o acumulador no destino
    LDA #$CD                                     ; Carrega o valor no acumulador
    STA $2006                                    ; Armazena o acumulador no destino
    LDX #$04                                     ; Carrega o valor no registrador X
draw_fence_top:                                  ; Define o ponto de entrada draw_fence_top
    LDA #$0C                                     ; Carrega o valor no acumulador
    STA $2007                                    ; Armazena o acumulador no destino
    LDA #$0D                                     ; Carrega o valor no acumulador
    STA $2007                                    ; Armazena o acumulador no destino
    DEX                                          ; Decrementa o registrador X
    BNE draw_fence_top                           ; Desvia quando o resultado anterior nao e zero
    LDA $2002                                    ; Carrega o valor no acumulador
    LDA #$21                                     ; Carrega o valor no acumulador
    STA $2006                                    ; Armazena o acumulador no destino
    LDA #$ED                                     ; Carrega o valor no acumulador
    STA $2006                                    ; Armazena o acumulador no destino
    LDX #$04                                     ; Carrega o valor no registrador X
draw_fence_bottom:                               ; Define o ponto de entrada draw_fence_bottom
    LDA #$0E                                     ; Carrega o valor no acumulador
    STA $2007                                    ; Armazena o acumulador no destino
    LDA #$0F                                     ; Carrega o valor no acumulador
    STA $2007                                    ; Armazena o acumulador no destino
    DEX                                          ; Decrementa o registrador X
    BNE draw_fence_bottom                        ; Desvia quando o resultado anterior nao e zero
    RTS                                          ; Retorna para a rotina chamadora
load_biker_sprite:                               ; Define o ponto de entrada load_biker_sprite
    LDX #$00                                     ; Carrega o valor no registrador X
load_biker_sprite_loop:                          ; Define o ponto de entrada load_biker_sprite_loop
    LDA biker_sprite, x                          ; Carrega o valor no acumulador
    STA $0200, x                                 ; Armazena o acumulador no destino
    INX                                          ; Incrementa o registrador X
    CPX #$24                                     ; Compara o registrador X com o operando
    BNE load_biker_sprite_loop                   ; Desvia quando o resultado anterior nao e zero
    RTS                                          ; Retorna para a rotina chamadora
hide_biker_sprite:                               ; Define o ponto de entrada hide_biker_sprite
    LDA #$FE                                     ; Carrega o valor no acumulador
    STA $0200                                    ; Armazena o acumulador no destino
    STA $0204                                    ; Armazena o acumulador no destino
    STA $0208                                    ; Armazena o acumulador no destino
    STA $020C                                    ; Armazena o acumulador no destino
    STA $0210                                    ; Armazena o acumulador no destino
    STA $0214                                    ; Armazena o acumulador no destino
    STA $0218                                    ; Armazena o acumulador no destino
    STA $021C                                    ; Armazena o acumulador no destino
    STA $0220                                    ; Armazena o acumulador no destino
    RTS                                          ; Retorna para a rotina chamadora
update_biker_sprite:                             ; Define o ponto de entrada update_biker_sprite
    LDA player_alive                             ; Carrega o valor no acumulador
    BNE update_visible_biker_sprite              ; Desvia quando o resultado anterior nao e zero
    JSR hide_biker_sprite                        ; Executa a rotina indicada
    RTS                                          ; Retorna para a rotina chamadora
update_visible_biker_sprite:                     ; Define o ponto de entrada update_visible_biker_sprite
    LDA player_direction                         ; Carrega o valor no acumulador
    BEQ update_biker_sprite_right                ; Desvia quando o resultado anterior e zero
    JMP update_biker_sprite_left                 ; Continua a execucao no rotulo indicado
update_biker_sprite_right:                       ; Define o ponto de entrada update_biker_sprite_right
    LDA player_y                                 ; Carrega o valor no acumulador
    STA $0200                                    ; Armazena o acumulador no destino
    STA $0204                                    ; Armazena o acumulador no destino
    STA $0208                                    ; Armazena o acumulador no destino
    LDA player_x                                 ; Carrega o valor no acumulador
    STA $0203                                    ; Armazena o acumulador no destino
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #$08                                     ; Soma o operando ao acumulador com o carry
    STA $0207                                    ; Armazena o acumulador no destino
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #$08                                     ; Soma o operando ao acumulador com o carry
    STA $020B                                    ; Armazena o acumulador no destino
    LDA player_y                                 ; Carrega o valor no acumulador
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #$08                                     ; Soma o operando ao acumulador com o carry
    STA $020C                                    ; Armazena o acumulador no destino
    STA $0210                                    ; Armazena o acumulador no destino
    STA $0214                                    ; Armazena o acumulador no destino
    LDA player_x                                 ; Carrega o valor no acumulador
    STA $020F                                    ; Armazena o acumulador no destino
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #$08                                     ; Soma o operando ao acumulador com o carry
    STA $0213                                    ; Armazena o acumulador no destino
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #$08                                     ; Soma o operando ao acumulador com o carry
    STA $0217                                    ; Armazena o acumulador no destino
    LDA player_y                                 ; Carrega o valor no acumulador
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #$10                                     ; Soma o operando ao acumulador com o carry
    STA $0218                                    ; Armazena o acumulador no destino
    STA $021C                                    ; Armazena o acumulador no destino
    STA $0220                                    ; Armazena o acumulador no destino
    LDA player_x                                 ; Carrega o valor no acumulador
    STA $021B                                    ; Armazena o acumulador no destino
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #$08                                     ; Soma o operando ao acumulador com o carry
    STA $021F                                    ; Armazena o acumulador no destino
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #$08                                     ; Soma o operando ao acumulador com o carry
    STA $0223                                    ; Armazena o acumulador no destino
    JSR update_biker_animation_tiles             ; Executa a rotina indicada
    JSR update_biker_attributes_right            ; Executa a rotina indicada
    RTS                                          ; Retorna para a rotina chamadora
update_biker_sprite_left:                        ; Define o ponto de entrada update_biker_sprite_left
    LDA player_y                                 ; Carrega o valor no acumulador
    STA $0200                                    ; Armazena o acumulador no destino
    STA $0204                                    ; Armazena o acumulador no destino
    STA $0208                                    ; Armazena o acumulador no destino
    LDA player_x                                 ; Carrega o valor no acumulador
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #$10                                     ; Soma o operando ao acumulador com o carry
    STA $0203                                    ; Armazena o acumulador no destino
    LDA player_x                                 ; Carrega o valor no acumulador
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #$08                                     ; Soma o operando ao acumulador com o carry
    STA $0207                                    ; Armazena o acumulador no destino
    LDA player_x                                 ; Carrega o valor no acumulador
    STA $020B                                    ; Armazena o acumulador no destino
    LDA player_y                                 ; Carrega o valor no acumulador
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #$08                                     ; Soma o operando ao acumulador com o carry
    STA $020C                                    ; Armazena o acumulador no destino
    STA $0210                                    ; Armazena o acumulador no destino
    STA $0214                                    ; Armazena o acumulador no destino
    LDA player_x                                 ; Carrega o valor no acumulador
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #$10                                     ; Soma o operando ao acumulador com o carry
    STA $020F                                    ; Armazena o acumulador no destino
    LDA player_x                                 ; Carrega o valor no acumulador
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #$08                                     ; Soma o operando ao acumulador com o carry
    STA $0213                                    ; Armazena o acumulador no destino
    LDA player_x                                 ; Carrega o valor no acumulador
    STA $0217                                    ; Armazena o acumulador no destino
    LDA player_y                                 ; Carrega o valor no acumulador
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #$10                                     ; Soma o operando ao acumulador com o carry
    STA $0218                                    ; Armazena o acumulador no destino
    STA $021C                                    ; Armazena o acumulador no destino
    STA $0220                                    ; Armazena o acumulador no destino
    LDA player_x                                 ; Carrega o valor no acumulador
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #$10                                     ; Soma o operando ao acumulador com o carry
    STA $021B                                    ; Armazena o acumulador no destino
    LDA player_x                                 ; Carrega o valor no acumulador
    CLC                                          ; Limpa o carry antes da operacao aritmetica
    ADC #$08                                     ; Soma o operando ao acumulador com o carry
    STA $021F                                    ; Armazena o acumulador no destino
    LDA player_x                                 ; Carrega o valor no acumulador
    STA $0223                                    ; Armazena o acumulador no destino
    JSR update_biker_animation_tiles             ; Executa a rotina indicada
    JSR update_biker_attributes_left             ; Executa a rotina indicada
    RTS                                          ; Retorna para a rotina chamadora
update_biker_attributes_right:                   ; Define o ponto de entrada update_biker_attributes_right
    LDA #$00                                     ; Carrega o valor no acumulador
    STA $0202                                    ; Armazena o acumulador no destino
    STA $0206                                    ; Armazena o acumulador no destino
    STA $020A                                    ; Armazena o acumulador no destino
    STA $020E                                    ; Armazena o acumulador no destino
    STA $0212                                    ; Armazena o acumulador no destino
    STA $0216                                    ; Armazena o acumulador no destino
    STA $021A                                    ; Armazena o acumulador no destino
    STA $021E                                    ; Armazena o acumulador no destino
    STA $0222                                    ; Armazena o acumulador no destino
    RTS                                          ; Retorna para a rotina chamadora
update_biker_attributes_left:                    ; Define o ponto de entrada update_biker_attributes_left
    LDA #$40                                     ; Carrega o valor no acumulador
    STA $0202                                    ; Armazena o acumulador no destino
    STA $0206                                    ; Armazena o acumulador no destino
    STA $020A                                    ; Armazena o acumulador no destino
    STA $020E                                    ; Armazena o acumulador no destino
    STA $0212                                    ; Armazena o acumulador no destino
    STA $0216                                    ; Armazena o acumulador no destino
    STA $021A                                    ; Armazena o acumulador no destino
    STA $021E                                    ; Armazena o acumulador no destino
    STA $0222                                    ; Armazena o acumulador no destino
    RTS                                          ; Retorna para a rotina chamadora
update_biker_animation_tiles:                    ; Define o ponto de entrada update_biker_animation_tiles
    LDA anim_frame                               ; Carrega o valor no acumulador
    CMP #$00                                     ; Compara o acumulador com o operando
    BEQ biker_anim_frame_0                       ; Desvia quando o resultado anterior e zero
    JMP biker_anim_frame_1                       ; Continua a execucao no rotulo indicado
biker_anim_frame_0:                              ; Define o ponto de entrada biker_anim_frame_0
    LDA #$06                                     ; Carrega o valor no acumulador
    STA $0219                                    ; Armazena o acumulador no destino
    LDA #$07                                     ; Carrega o valor no acumulador
    STA $021D                                    ; Armazena o acumulador no destino
    LDA #$08                                     ; Carrega o valor no acumulador
    STA $0221                                    ; Armazena o acumulador no destino
    RTS                                          ; Retorna para a rotina chamadora
biker_anim_frame_1:                              ; Define o ponto de entrada biker_anim_frame_1
    LDA #$09                                     ; Carrega o valor no acumulador
    STA $0219                                    ; Armazena o acumulador no destino
    LDA #$0A                                     ; Carrega o valor no acumulador
    STA $021D                                    ; Armazena o acumulador no destino
    LDA #$0B                                     ; Carrega o valor no acumulador
    STA $0221                                    ; Armazena o acumulador no destino
    RTS                                          ; Retorna para a rotina chamadora
