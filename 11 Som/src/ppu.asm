; ============================================================
; PPU.ASM
; ============================================================
;
; Contém as rotinas relacionadas à preparação dos gráficos do
; jogo.
;
; Este módulo é responsável por:
;
;   - carregar as paletas de background;
;   - carregar as paletas de sprites;
;   - limpar a Nametable 0;
;   - configurar a tabela de atributos;
;   - desenhar o gramado;
;   - desenhar o chão;
;   - desenhar a cerca;
;   - carregar o sprite inicial do jogador;
;   - esconder o jogador;
;   - atualizar posição, direção e animação do jogador.
;
; As escritas na VRAM são feitas pelos registradores:
;
;   $2006 -> endereço da PPU
;   $2007 -> dado enviado para a PPU
;
; Antes de escrever um endereço em $2006, a leitura de $2002
; reinicia o latch interno usado pela PPU.
;
; ============================================================


; ============================================================
; CARREGA TODAS AS PALETAS
; ============================================================
;
; Centraliza a inicialização das cores do jogo.
;
; Primeiro são carregadas as paletas utilizadas pelo background.
; Depois são carregadas as paletas utilizadas pelos sprites.
;
; ============================================================

load_palettes:

    JSR load_bg_palettes
    JSR load_sprite_palette

    RTS


; ============================================================
; CARREGA AS PALETAS DE BACKGROUND
; ============================================================
;
; A memória de paletas do background começa em:
;
;   $3F00
;
; Nesta demo são copiados 8 bytes:
;
;   4 bytes -> paleta 0
;   4 bytes -> paleta 1
;
; Os dados vêm da tabela bg_palettes, definida em palettes.asm.
;
; ============================================================

load_bg_palettes:

    ; Reinicia o latch de endereço da PPU.

    LDA $2002

    ; Define o endereço inicial como $3F00.

    LDA #$3F
    STA $2006

    LDA #$00
    STA $2006

    LDX #$00

load_bg_palettes_loop:

    ; Copia uma cor da tabela para a memória de paletas da PPU.

    LDA bg_palettes, x
    STA $2007

    INX

    ; Duas paletas de quatro cores totalizam oito bytes.

    CPX #$08
    BNE load_bg_palettes_loop

    RTS


; ============================================================
; CARREGA AS PALETAS DE SPRITES
; ============================================================
;
; A memória de paletas dos sprites começa em:
;
;   $3F10
;
; Nesta demo são copiadas duas paletas:
;
;   paleta 0 -> jogador
;   paleta 1 -> inimigo
;
; Os dados vêm de sprite_palette, definida em palettes.asm.
;
; ============================================================

load_sprite_palette:

    ; Reinicia o latch de endereço da PPU.

    LDA $2002

    ; Define o endereço inicial como $3F10.

    LDA #$3F
    STA $2006

    LDA #$10
    STA $2006

    LDX #$00

load_sprite_palette_loop:

    LDA sprite_palette, x
    STA $2007

    INX

    ; Duas paletas de quatro cores totalizam oito bytes.

    CPX #$08
    BNE load_sprite_palette_loop

    RTS


; ============================================================
; TILE UTILIZADO PARA LIMPAR A NAMETABLE
; ============================================================
;
; O tile $18 é usado como tile vazio do cenário.
;
; Em vez de preencher a Nametable com o tile $00, esta demo
; utiliza um tile específico da CHR como fundo neutro.
;
; ============================================================

BLANK_TILE = $18


; ============================================================
; LIMPA A NAMETABLE 0
; ============================================================
;
; A Nametable 0 ocupa 960 bytes de tiles:
;
;   $2000-$23BF
;
; A rotina preenche toda essa região com BLANK_TILE.
;
; O total é dividido em:
;
;   256 bytes
;   256 bytes
;   256 bytes
;   192 bytes
;
; Total:
;
;   256 + 256 + 256 + 192 = 960 bytes
;
; A tabela de atributos, localizada em $23C0-$23FF, não é limpa
; aqui. Ela é configurada separadamente por load_bg_attributes.
;
; ============================================================

clear_nametable:

    ; Reinicia o latch de endereço.

    LDA $2002

    ; Define o endereço inicial da Nametable 0: $2000.

    LDA #$20
    STA $2006

    LDA #$00
    STA $2006

    ; Mantém o tile vazio no acumulador durante toda a limpeza.

    LDA #BLANK_TILE


    ; --------------------------------------------------------
    ; PRIMEIROS 256 BYTES
    ; --------------------------------------------------------

    LDX #$00

clear_nametable_page_1:

    STA $2007

    INX
    BNE clear_nametable_page_1


    ; --------------------------------------------------------
    ; SEGUNDOS 256 BYTES
    ; --------------------------------------------------------

    LDX #$00

clear_nametable_page_2:

    STA $2007

    INX
    BNE clear_nametable_page_2


    ; --------------------------------------------------------
    ; TERCEIROS 256 BYTES
    ; --------------------------------------------------------

    LDX #$00

clear_nametable_page_3:

    STA $2007

    INX
    BNE clear_nametable_page_3


    ; --------------------------------------------------------
    ; ÚLTIMOS 192 BYTES
    ; --------------------------------------------------------

    LDX #$00

clear_nametable_remaining:

    STA $2007

    INX

    CPX #$C0
    BNE clear_nametable_remaining

    RTS


; ============================================================
; CARREGA A TABELA DE ATRIBUTOS
; ============================================================
;
; A tabela de atributos da Nametable 0 ocupa:
;
;   $23C0-$23FF
;
; Cada byte controla as paletas de quatro regiões de 16x16 pixels
; dentro de uma área de 32x32 pixels.
;
; Cada região usa dois bits:
;
;   00 -> paleta 0
;   01 -> paleta 1
;   10 -> paleta 2
;   11 -> paleta 3
;
; Nesta demo:
;
;   primeiros 32 bytes -> valor $00
;   últimos 32 bytes   -> valor $55
;
; $00 = %00000000
;
; Todas as regiões usam a paleta 0.
;
; $55 = %01010101
;
; Todas as regiões usam a paleta 1.
;
; Dessa forma, a metade superior utiliza a paleta do gramado e a
; metade inferior utiliza a paleta do chão.
;
; ============================================================

load_bg_attributes:

    ; Reinicia o latch de endereço da PPU.

    LDA $2002

    ; Define o início da tabela de atributos: $23C0.

    LDA #$23
    STA $2006

    LDA #$C0
    STA $2006


    ; --------------------------------------------------------
    ; METADE SUPERIOR: PALETA 0
    ; --------------------------------------------------------

    LDA #$00
    LDX #$20

load_grass_attributes:

    STA $2007

    DEX
    BNE load_grass_attributes


    ; --------------------------------------------------------
    ; METADE INFERIOR: PALETA 1
    ; --------------------------------------------------------

    LDA #$55
    LDX #$20

load_floor_attributes:

    STA $2007

    DEX
    BNE load_floor_attributes

    RTS


; ============================================================
; DESENHA O BACKGROUND
; ============================================================
;
; Posiciona o endereço de escrita no início da Nametable 0 e
; chama as rotinas que constroem o cenário.
;
; Ordem:
;
;   1. gramado;
;   2. chão;
;   3. cerca.
;
; As rotinas draw_grass e draw_floor escrevem sequencialmente na
; Nametable.
;
; A cerca utiliza endereços próprios, pois é desenhada sobre uma
; região específica do cenário.
;
; ============================================================

draw_background:

    ; Reinicia o latch.

    LDA $2002

    ; Inicia a escrita em $2000.

    LDA #$20
    STA $2006

    LDA #$00
    STA $2006

    JSR draw_grass
    JSR draw_floor
    JSR draw_fence

    RTS


; ============================================================
; DESENHA O GRAMADO
; ============================================================
;
; O gramado utiliza um padrão de 2x2 tiles:
;
;   $10 $11
;   $12 $13
;
; Cada linha da Nametable possui 32 tiles.
;
; O registrador X começa com $10, ou seja, 16 repetições.
; Como cada repetição escreve dois tiles:
;
;   16 x 2 = 32 tiles
;
; Portanto, cada loop interno preenche uma linha completa.
;
; O registrador Y começa com 8.
;
; Cada bloco escreve duas linhas, totalizando:
;
;   8 blocos x 2 linhas = 16 linhas
;
; ============================================================

draw_grass:

    LDY #$08

draw_grass_block:

    ; --------------------------------------------------------
    ; LINHA SUPERIOR DO PADRÃO
    ; --------------------------------------------------------

    LDX #$10

draw_grass_top_row:

    LDA #$10
    STA $2007

    LDA #$11
    STA $2007

    DEX
    BNE draw_grass_top_row


    ; --------------------------------------------------------
    ; LINHA INFERIOR DO PADRÃO
    ; --------------------------------------------------------

    LDX #$10

draw_grass_bottom_row:

    LDA #$12
    STA $2007

    LDA #$13
    STA $2007

    DEX
    BNE draw_grass_bottom_row


    ; Repete o bloco de duas linhas oito vezes.

    DEY
    BNE draw_grass_block

    RTS


; ============================================================
; DESENHA O CHÃO
; ============================================================
;
; O chão utiliza outro padrão de 2x2 tiles:
;
;   $14 $15
;   $16 $17
;
; Assim como o gramado, cada linha é formada por 16 repetições
; de dois tiles, preenchendo as 32 colunas da Nametable.
;
; O registrador Y começa com 7:
;
;   7 blocos x 2 linhas = 14 linhas
;
; Somando:
;
;   16 linhas de gramado
;   14 linhas de chão
;
; Total:
;
;   30 linhas visíveis da Nametable
;
; ============================================================

draw_floor:

    LDY #$07

draw_floor_block:

    ; --------------------------------------------------------
    ; LINHA SUPERIOR DO PADRÃO
    ; --------------------------------------------------------

    LDX #$10

draw_floor_top_row:

    LDA #$14
    STA $2007

    LDA #$15
    STA $2007

    DEX
    BNE draw_floor_top_row


    ; --------------------------------------------------------
    ; LINHA INFERIOR DO PADRÃO
    ; --------------------------------------------------------

    LDX #$10

draw_floor_bottom_row:

    LDA #$16
    STA $2007

    LDA #$17
    STA $2007

    DEX
    BNE draw_floor_bottom_row

    DEY
    BNE draw_floor_block

    RTS


; ============================================================
; DESENHA A CERCA
; ============================================================
;
; A cerca é formada por uma composição de 8x2 tiles:
;
; Linha superior:
;
;   $0C $0D $0C $0D $0C $0D $0C $0D
;
; Linha inferior:
;
;   $0E $0F $0E $0F $0E $0F $0E $0F
;
; A linha superior começa em:
;
;   $21CD
;
; A linha inferior começa 32 bytes depois:
;
;   $21ED
;
; Como uma linha da Nametable possui 32 tiles, essa diferença
; posiciona a segunda metade da cerca exatamente uma linha abaixo.
;
; ============================================================

draw_fence:

    ; --------------------------------------------------------
    ; LINHA SUPERIOR DA CERCA
    ; --------------------------------------------------------

    LDA $2002

    LDA #$21
    STA $2006

    LDA #$CD
    STA $2006

    LDX #$04

draw_fence_top:

    LDA #$0C
    STA $2007

    LDA #$0D
    STA $2007

    DEX
    BNE draw_fence_top


    ; --------------------------------------------------------
    ; LINHA INFERIOR DA CERCA
    ; --------------------------------------------------------

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


; ============================================================
; CARREGA O SPRITE INICIAL DO JOGADOR
; ============================================================
;
; Copia a tabela biker_sprite para a Shadow OAM.
;
; O jogador é formado por nove sprites de hardware:
;
;   3 colunas x 3 linhas
;
; Cada sprite utiliza quatro bytes:
;
;   Y
;   tile
;   atributos
;   X
;
; Total:
;
;   9 sprites x 4 bytes = 36 bytes = $24
;
; A Shadow OAM começa em $0200.
;
; ============================================================

load_biker_sprite:

    LDX #$00

load_biker_sprite_loop:

    LDA biker_sprite, x
    STA $0200, x

    INX

    CPX #$24
    BNE load_biker_sprite_loop

    RTS


; ============================================================
; ESCONDE O SPRITE DO JOGADOR
; ============================================================
;
; Para esconder um sprite no NES, sua coordenada Y pode ser
; colocada fora da região visível.
;
; O valor $FE é gravado no byte Y de cada um dos nove sprites que
; compõem o jogador.
;
; Endereços Y na Shadow OAM:
;
;   $0200, $0204, $0208
;   $020C, $0210, $0214
;   $0218, $021C, $0220
;
; ============================================================

hide_biker_sprite:

    LDA #$FE

    STA $0200
    STA $0204
    STA $0208

    STA $020C
    STA $0210
    STA $0214

    STA $0218
    STA $021C
    STA $0220

    RTS


; ============================================================
; ATUALIZA O SPRITE DO JOGADOR
; ============================================================
;
; Converte o estado lógico do jogador em dados para a Shadow OAM.
;
; A rotina:
;
;   - esconde o sprite se o jogador estiver morto;
;   - escolhe a orientação do personagem;
;   - atualiza as nove posições;
;   - atualiza os tiles animados dos pés;
;   - aplica ou remove o flip horizontal.
;
; ============================================================

update_biker_sprite:

    LDA player_alive
    BNE update_visible_biker_sprite

    JSR hide_biker_sprite

    RTS


update_visible_biker_sprite:

    ; player_direction:
    ;
    ;   0 -> direita
    ;   1 -> esquerda

    LDA player_direction
    BEQ update_biker_sprite_right

    JMP update_biker_sprite_left


; ============================================================
; ATUALIZA O JOGADOR OLHANDO PARA A DIREITA
; ============================================================
;
; O sprite composto possui 24x24 pixels:
;
;   três colunas de 8 pixels
;   três linhas de 8 pixels
;
; Coordenadas X:
;
;   player_x
;   player_x + 8
;   player_x + 16
;
; Coordenadas Y:
;
;   player_y
;   player_y + 8
;   player_y + 16
;
; ============================================================

update_biker_sprite_right:

    ; --------------------------------------------------------
    ; PRIMEIRA LINHA: Y
    ; --------------------------------------------------------

    LDA player_y

    STA $0200
    STA $0204
    STA $0208


    ; --------------------------------------------------------
    ; PRIMEIRA LINHA: X
    ; --------------------------------------------------------

    LDA player_x
    STA $0203

    CLC
    ADC #$08
    STA $0207

    CLC
    ADC #$08
    STA $020B


    ; --------------------------------------------------------
    ; SEGUNDA LINHA: Y
    ; --------------------------------------------------------

    LDA player_y

    CLC
    ADC #$08

    STA $020C
    STA $0210
    STA $0214


    ; --------------------------------------------------------
    ; SEGUNDA LINHA: X
    ; --------------------------------------------------------

    LDA player_x
    STA $020F

    CLC
    ADC #$08
    STA $0213

    CLC
    ADC #$08
    STA $0217


    ; --------------------------------------------------------
    ; TERCEIRA LINHA: Y
    ; --------------------------------------------------------

    LDA player_y

    CLC
    ADC #$10

    STA $0218
    STA $021C
    STA $0220


    ; --------------------------------------------------------
    ; TERCEIRA LINHA: X
    ; --------------------------------------------------------

    LDA player_x
    STA $021B

    CLC
    ADC #$08
    STA $021F

    CLC
    ADC #$08
    STA $0223


    ; Atualiza apenas os tiles usados na animação dos pés.

    JSR update_biker_animation_tiles


    ; Remove o flip horizontal.

    JSR update_biker_attributes_right

    RTS


; ============================================================
; ATUALIZA O JOGADOR OLHANDO PARA A ESQUERDA
; ============================================================
;
; Para virar o personagem horizontalmente, não basta ativar o bit
; de flip.
;
; Cada sprite de hardware é espelhado individualmente.
;
; Por isso, as posições das colunas também precisam ser invertidas:
;
; Orientação normal:
;
;   esquerda  centro  direita
;   X         X+8     X+16
;
; Orientação invertida:
;
;   direita   centro  esquerda
;   X+16      X+8     X
;
; ============================================================

update_biker_sprite_left:

    ; --------------------------------------------------------
    ; PRIMEIRA LINHA: Y
    ; --------------------------------------------------------

    LDA player_y

    STA $0200
    STA $0204
    STA $0208


    ; --------------------------------------------------------
    ; PRIMEIRA LINHA: X INVERTIDO
    ; --------------------------------------------------------

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


    ; --------------------------------------------------------
    ; SEGUNDA LINHA: Y
    ; --------------------------------------------------------

    LDA player_y

    CLC
    ADC #$08

    STA $020C
    STA $0210
    STA $0214


    ; --------------------------------------------------------
    ; SEGUNDA LINHA: X INVERTIDO
    ; --------------------------------------------------------

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


    ; --------------------------------------------------------
    ; TERCEIRA LINHA: Y
    ; --------------------------------------------------------

    LDA player_y

    CLC
    ADC #$10

    STA $0218
    STA $021C
    STA $0220


    ; --------------------------------------------------------
    ; TERCEIRA LINHA: X INVERTIDO
    ; --------------------------------------------------------

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


    ; Mantém os tiles da animação de caminhada atualizados.

    JSR update_biker_animation_tiles


    ; Ativa o flip horizontal em todos os nove sprites.

    JSR update_biker_attributes_left

    RTS


; ============================================================
; ATRIBUTOS DO JOGADOR OLHANDO PARA A DIREITA
; ============================================================
;
; O byte de atributos da OAM possui o seguinte formato:
;
;   bit 7 -> flip vertical
;   bit 6 -> flip horizontal
;   bit 5 -> prioridade atrás do background
;   bits 1-0 -> número da paleta de sprite
;
; O valor $00 significa:
;
;   - paleta de sprite 0;
;   - sem flip horizontal;
;   - sem flip vertical;
;   - sprite à frente do background.
;
; ============================================================

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


; ============================================================
; ATRIBUTOS DO JOGADOR OLHANDO PARA A ESQUERDA
; ============================================================
;
; O valor $40 ativa o bit 6 do byte de atributos:
;
;   $40 = %01000000
;
; Isso aplica flip horizontal em cada sprite de 8x8 pixels.
;
; As posições X das colunas já foram invertidas pela rotina
; update_biker_sprite_left, fazendo o conjunto completo parecer
; corretamente espelhado.
;
; ============================================================

update_biker_attributes_left:

    LDA #$40

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


; ============================================================
; ATUALIZA OS TILES DA ANIMAÇÃO DO JOGADOR
; ============================================================
;
; As duas linhas superiores do personagem permanecem estáticas.
;
; Apenas a terceira linha, correspondente aos pés, é animada.
;
; anim_frame pode conter:
;
;   0 -> tiles $06, $07 e $08
;   1 -> tiles $09, $0A e $0B
;
; Os bytes de tile dos três sprites inferiores estão em:
;
;   $0219
;   $021D
;   $0221
;
; ============================================================

update_biker_animation_tiles:

    LDA anim_frame

    CMP #$00
    BEQ biker_anim_frame_0

    JMP biker_anim_frame_1


; ============================================================
; QUADRO 0 DA ANIMAÇÃO
; ============================================================

biker_anim_frame_0:

    LDA #$06
    STA $0219

    LDA #$07
    STA $021D

    LDA #$08
    STA $0221

    RTS


; ============================================================
; QUADRO 1 DA ANIMAÇÃO
; ============================================================

biker_anim_frame_1:

    LDA #$09
    STA $0219

    LDA #$0A
    STA $021D

    LDA #$0B
    STA $0221

    RTS
