; ============================================================
; STARTUP.ASM
; ============================================================
;
; Contém a rotina de inicialização executada quando o NES é
; ligado ou quando a ROM é reiniciada.
;
; O endereço de RESET, definido na tabela de vetores, aponta para
; a rotina RESET deste arquivo.
;
; A inicialização segue estas etapas:
;
;   1. configura o processador;
;   2. desliga temporariamente a renderização e as interrupções;
;   3. espera a PPU estabilizar;
;   4. limpa a RAM;
;   5. espera um segundo VBlank;
;   6. inicializa música e efeitos sonoros;
;   7. prepara paletas, cenário e sprites;
;   8. inicializa o estado lógico do jogo;
;   9. configura o scroll;
;  10. liga a PPU e entra no loop principal.
;
; ============================================================


.segment "STARTUP"


; ============================================================
; VETOR DE RESET
; ============================================================
;
; Esta é a primeira rotina executada pela CPU depois que o NES é
; ligado ou reiniciado.
;
; Nesse momento, não se deve assumir que a RAM, a PPU ou os
; registradores estejam em um estado conhecido.
;
; ============================================================

RESET:

    ; --------------------------------------------------------
    ; CONFIGURAÇÃO INICIAL DA CPU
    ; --------------------------------------------------------

    ; Desativa interrupções mascaráveis do tipo IRQ.
    ;
    ; A NMI da PPU é controlada separadamente pelo registrador
    ; $2000 e continua desligada neste momento.

    SEI


    ; Desativa o modo decimal.
    ;
    ; O processador 2A03 do NES não implementa aritmética decimal,
    ; mas esta instrução faz parte da sequência tradicional de
    ; inicialização do 6502.

    CLD


    ; --------------------------------------------------------
    ; DESATIVA O FRAME IRQ DA APU
    ; --------------------------------------------------------
    ;
    ; O bit 6 de $4017 desativa a geração de IRQ pelo frame
    ; counter da APU.
    ;
    ; --------------------------------------------------------

    LDX #$40
    STX $4017


    ; --------------------------------------------------------
    ; INICIALIZA A PILHA
    ; --------------------------------------------------------
    ;
    ; A pilha do 6502 ocupa:
    ;
    ;   $0100-$01FF
    ;
    ; TXS copia o valor de X para o ponteiro da pilha.
    ;
    ; Com X = $FF, a pilha começa no topo dessa página.
    ;
    ; --------------------------------------------------------

    LDX #$FF
    TXS


    ; INX transforma $FF em $00.
    ;
    ; Esse zero será utilizado para desligar a PPU e também como
    ; índice durante a limpeza da RAM.

    INX


    ; --------------------------------------------------------
    ; DESLIGA A PPU E O DMC
    ; --------------------------------------------------------
    ;
    ; $2000 = 0:
    ;
    ;   - NMI desligada;
    ;   - incremento padrão de VRAM;
    ;   - outras opções da PPU zeradas.
    ;
    ; $2001 = 0:
    ;
    ;   - background desligado;
    ;   - sprites desligados.
    ;
    ; $4010 = 0:
    ;
    ;   - IRQ do canal DMC desativada.
    ;
    ; --------------------------------------------------------

    STX $2000
    STX $2001
    STX $4010


; ============================================================
; PRIMEIRA ESPERA PELO VBLANK
; ============================================================
;
; A PPU precisa de algum tempo para estabilizar após o console
; ser ligado.
;
; O bit 7 de $2002 fica ativo durante o VBlank.
;
; BIT copia esse bit para a flag negativa do processador:
;
;   bit 7 = 0 -> resultado positivo
;   bit 7 = 1 -> resultado negativo
;
; BPL repete o loop enquanto o VBlank ainda não começou.
;
; ============================================================

vblankwait1:

    BIT $2002
    BPL vblankwait1


; ============================================================
; LIMPA A RAM
; ============================================================
;
; A RAM interna do NES ocupa:
;
;   $0000-$07FF
;
; O registrador X percorre todos os valores de $00 a $FF.
;
; Em cada iteração, um byte é limpo em várias páginas da RAM.
;
; A página $0200 é tratada de maneira diferente, pois ela é usada
; como Shadow OAM.
;
; Em vez de receber zero, seus bytes recebem $FE para esconder
; todos os sprites inicialmente.
;
; ============================================================

clearmem:

    ; --------------------------------------------------------
    ; LIMPA A RAM COM ZERO
    ; --------------------------------------------------------
    ;
    ; $0000-$00FF -> Zero Page
    ; $0100-$01FF -> página da pilha
    ; $0300-$07FF -> RAM comum
    ;
    ; A página $0200 é reservada para a Shadow OAM.
    ;
    ; --------------------------------------------------------

    LDA #$00

    STA $0000, x
    STA $0100, x

    STA $0300, x
    STA $0400, x
    STA $0500, x
    STA $0600, x
    STA $0700, x


    ; --------------------------------------------------------
    ; ESCONDE TODOS OS SPRITES
    ; --------------------------------------------------------
    ;
    ; O valor $FE coloca a coordenada Y dos sprites fora da área
    ; visível.
    ;
    ; Aqui todos os 256 bytes da Shadow OAM recebem $FE.
    ; Posteriormente, as rotinas do jogo substituirão os bytes
    ; pertencentes aos sprites utilizados.
    ;
    ; --------------------------------------------------------

    LDA #$FE
    STA $0200, x


    ; Depois de 256 incrementos, X volta para zero.
    ;
    ; Quando isso acontece, todas as páginas foram percorridas.

    INX
    BNE clearmem


; ============================================================
; SEGUNDA ESPERA PELO VBLANK
; ============================================================
;
; A segunda espera garante que a PPU já esteja estabilizada antes
; de receber paletas, tiles e atributos.
;
; Durante toda essa preparação, a renderização continua desligada.
;
; ============================================================

vblankwait2:

    BIT $2002
    BPL vblankwait2


; ============================================================
; INICIALIZA A MÚSICA
; ============================================================
;
; famistudio_init recebe:
;
;   A -> configuração de região utilizada pela engine;
;   X -> byte baixo do endereço dos dados musicais;
;   Y -> byte alto do endereço dos dados musicais.
;
; Os operadores:
;
;   <label -> byte baixo do endereço
;   >label -> byte alto do endereço
;
; permitem entregar à engine um ponteiro de 16 bits.
;
; music_data_gyruss é o rótulo exportado pelo FamiStudio que
; contém os dados das músicas.
;
; ============================================================

    LDA #$01

    LDX #<music_data_gyruss
    LDY #>music_data_gyruss

    JSR famistudio_init


; ============================================================
; INICIALIZA OS EFEITOS SONOROS
; ============================================================
;
; famistudio_sfx_init recebe em X e Y o endereço da tabela que
; contém os efeitos sonoros exportados pelo FamiStudio.
;
; ============================================================

    LDX #<sounds
    LDY #>sounds

    JSR famistudio_sfx_init


; ============================================================
; INICIA A MÚSICA DA FASE
; ============================================================
;
; O acumulador contém o índice da música que será reproduzida.
;
; song_stage_2 é uma constante gerada pelo FamiStudio.
;
; Depois de iniciada, a música é atualizada uma vez por frame pela
; chamada famistudio_update realizada dentro da NMI.
;
; ============================================================

    LDA #song_stage_2
    JSR famistudio_music_play


; ============================================================
; PREPARA OS GRÁFICOS
; ============================================================
;
; A renderização ainda está desligada, portanto é seguro escrever
; grandes quantidades de dados na VRAM neste momento.
;
; ============================================================

    ; Carrega as cores de background e sprites.

    JSR load_palettes


    ; Preenche a Nametable 0 com o tile vazio.

    JSR clear_nametable


    ; Desenha o gramado, o chão e a cerca.

    JSR draw_background


    ; Configura quais paletas são utilizadas nas regiões do
    ; background.

    JSR load_bg_attributes


    ; Copia a definição inicial do jogador para a Shadow OAM.

    JSR load_biker_sprite


; ============================================================
; INICIALIZA O ESTADO DO JOGO
; ============================================================
;
; Define posições, estados, contadores e demais variáveis usadas
; pela partida.
;
; initialize_game também atualiza os sprites necessários para que
; a primeira imagem já esteja pronta antes do início do loop.
;
; ============================================================

    JSR initialize_game


; ============================================================
; ATIVA A PPU
; ============================================================

enable_ppu:

    ; --------------------------------------------------------
    ; CONFIGURA O SCROLL
    ; --------------------------------------------------------
    ;
    ; A leitura de $2002 reinicia o latch compartilhado pelos
    ; registradores $2005 e $2006.
    ;
    ; As duas escritas em $2005 definem:
    ;
    ;   scroll horizontal = 0
    ;   scroll vertical   = 0
    ;
    ; --------------------------------------------------------

    LDA $2002

    LDA #$00
    STA $2005
    STA $2005


; ============================================================
; LIGA A NMI E A RENDERIZAÇÃO
; ============================================================

audio_already_initialized:

    ; --------------------------------------------------------
    ; PPUCTRL - $2000
    ; --------------------------------------------------------
    ;
    ; %10000000:
    ;
    ;   bit 7 = 1 -> habilita NMI no início de cada VBlank
    ;   bit 2 = 0 -> incremento de VRAM de 1 byte
    ;   bit 1-0 = 0 -> seleciona a Nametable 0
    ;
    ; Os demais bits permanecem zerados.
    ;
    ; --------------------------------------------------------

    LDA #%10000000
    STA $2000


    ; --------------------------------------------------------
    ; PPUMASK - $2001
    ; --------------------------------------------------------
    ;
    ; %00011110:
    ;
    ;   bit 4 = 1 -> mostra sprites
    ;   bit 3 = 1 -> mostra background
    ;   bit 2 = 1 -> mostra sprites nos 8 pixels da esquerda
    ;   bit 1 = 1 -> mostra background nos 8 pixels da esquerda
    ;
    ; A renderização passa a funcionar a partir deste ponto.
    ;
    ; --------------------------------------------------------

    LDA #%00011110
    STA $2001


    ; A inicialização terminou.
    ;
    ; O controle da execução passa para o loop principal do jogo.

    JMP forever