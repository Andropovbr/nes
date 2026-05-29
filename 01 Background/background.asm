; ------------------------------------------------------------
; SEGMENTO HEADER
; ------------------------------------------------------------
; Aqui definimos o cabeçalho iNES da ROM.
; Esse cabeçalho é usado principalmente por emuladores
; para entender como o cartucho deve ser carregado.
;
; Em hardware original isso não existia fisicamente
; dessa forma — é uma convenção criada para arquivos .NES.
; ------------------------------------------------------------

.segment "HEADER"

    ; Escreve os caracteres "NES"
    ; Isso identifica o arquivo como uma ROM de NES
    .byte "NES"

    ; Byte de assinatura obrigatório do formato iNES
    ; Valor hexadecimal $1A
    ; O emulador procura essa sequência para validar a ROM
    .byte $1A

    ; Quantidade de bancos PRG ROM
    ;
    ; Cada unidade = 16 KB
    ;
    ; $02 = 2 bancos
    ; 2 x 16 KB = 32 KB de código/programa
    .byte $02

    ; Quantidade de bancos CHR ROM
    ;
    ; Cada unidade = 8 KB
    ;
    ; $01 = 1 banco
    ; 1 x 8 KB = 8 KB de gráficos
    .byte $01

    ; Flags de mapper e mirroring
    ;
    ; %00000000 em binário:
    ;
    ; - Mapper 0 (NROM)
    ;   Cartucho simples, sem bank switching
    ;
    ; - Mirroring horizontal
    ;
    ; - Sem recursos especiais
    .byte %00000000

    ; Bytes reservados / não utilizados
    ; Normalmente preenchidos com zero
    .byte $00
    .byte $00
    .byte $00
    .byte $00

    ; Espaço reservado restante do cabeçalho
    ; Mantido zerado
    .byte $00, $00, $00, $00, $00

; ------------------------------------------------------------
; SEGMENTOS DE MEMÓRIA
; ------------------------------------------------------------

; Área reservada para variáveis de acesso rápido
; (endereços $0000-$00FF da RAM)
.segment "ZEROPAGE"

; Código executado durante a inicialização
; do console/programa
.segment "STARTUP"

; ------------------------------------------------------------
; ROTINA DE RESET / INICIALIZAÇÃO DO NES
; ------------------------------------------------------------

RESET:

    ; Desabilita interrupções IRQ da CPU.
    ; Evita que interrupções aconteçam durante
    ; a inicialização do sistema.
    SEI

    ; Desabilita modo decimal do 6502.
    ;
    ; O NES não usa aritmética decimal,
    ; então garantimos que isso fique desligado.
    CLD

    ; Carrega valor hexadecimal $40 no registrador X
    LDX #$40

    ; Escreve $40 no registrador $4017.
    ;
    ; Isso desabilita IRQ do frame counter da APU.
    ; Não significa "desligar o som inteiro",
    ; apenas impede essa fonte de interrupção.
    STX $4017

    ; Carrega $FF no registrador X
    LDX #$FF

    ; Inicializa a stack da CPU em $FF.
    ;
    ; A stack do 6502 cresce "para baixo",
    ; decrementando o ponteiro conforme dados
    ; são empilhados.
    TXS

    ; X estava em $FF.
    ; Incrementar faz overflow:
    ;
    ; $FF + 1 = $00
    ;
    ; Então agora X = $00.
    INX

    ; Escreve $00 em PPUCTRL ($2000).
    ;
    ; Desabilita NMI da PPU durante
    ; a inicialização.
    STX $2000

    ; Escreve $00 em PPUMASK ($2001).
    ;
    ; Desabilita renderização.
    ; Background e sprites ficam desligados.
    STX $2001

    ; Escreve $00 em $4010.
    ;
    ; Desabilita IRQs do canal DMC da APU.
    ; Evita interrupções de áudio inesperadas.
    STX $4010

; ------------------------------------------------------------
; ESPERA PELO PRIMEIRO VBLANK
; ------------------------------------------------------------

vblankwait1:

    ; Lê PPUSTATUS ($2002).
    ;
    ; O bit 7 indica estado do VBLANK:
    ;
    ; 0 = não está em VBLANK
    ; 1 = está em VBLANK
    ;
    ; A instrução BIT copia o bit 7
    ; para a flag N da CPU.
    BIT $2002

    ; Enquanto a flag N for 0
    ; (sem VBLANK),
    ; continua esperando.
    BPL vblankwait1

; ------------------------------------------------------------
; LIMPEZA DA RAM
; ------------------------------------------------------------

clearmem:

    ; Carrega valor $00 no acumulador A.
    ;
    ; Também poderíamos usar TXA,
    ; pois X já está em $00 nesse momento.
    LDA #$00

    ; Escreve $00 nas páginas principais
    ; da RAM interna do NES.
    ;
    ; X funciona como índice.
    STA $0000, x
    STA $0100, x
    STA $0300, x
    STA $0400, x
    STA $0500, x
    STA $0600, x
    STA $0700, x

    ; Carrega valor $FE no acumulador.
    LDA #$FE

    ; Escreve $FE em $0200-$02FF.
    ;
    ; Essa área normalmente é usada como
    ; shadow OAM, ou seja, buffer de sprites.
    ;
    ; Usar $FE no byte Y dos sprites
    ; posiciona os sprites fora da tela.
    STA $0200, x

    ; Incrementa X.
    INX

    ; Enquanto X não voltar para $00,
    ; continua o loop.
    ;
    ; Como X é de 8 bits, o loop executa
    ; 256 vezes.
    BNE clearmem

; ------------------------------------------------------------
; ESPERA PELO SEGUNDO VBLANK
; ------------------------------------------------------------

vblankwait2:

    ; Lê PPUSTATUS ($2002).
    ;
    ; O bit 7 indica estado do VBLANK.
    ; A instrução BIT copia esse bit
    ; para a flag N da CPU.
    BIT $2002

    ; Enquanto ainda não estiver em VBLANK,
    ; continua esperando.
    BPL vblankwait2

; ------------------------------------------------------------
; LIMPEZA DAS PALETAS DA PPU
; ------------------------------------------------------------

clearpalette:

    ; Lê PPUSTATUS ($2002).
    ;
    ; Isso reseta o latch/endereço interno da PPU.
    ; Antes de escrever em $2006,
    ; normalmente fazemos essa leitura.
    LDA $2002

    ; Define endereço da PPU para $3F00,
    ; início da RAM de paletas.
    ;
    ; Primeiro byte alto:
    LDA #$3F
    STA $2006

    ; Depois byte baixo:
    LDA #$00
    STA $2006

    ; X = $20, ou 32 em decimal.
    ;
    ; Vamos limpar $3F00-$3F1F,
    ; que corresponde às paletas de
    ; background e sprites.
    LDX #$20

    ; Valor usado para limpar cada entrada.
    ; $00 normalmente representa preto.
    LDA #$00

:
    ; Escreve $00 no endereço atual da VRAM.
    ;
    ; Após cada escrita em $2007,
    ; a PPU incrementa o endereço automaticamente.
    STA $2007

    ; Decrementa X.
    DEX

    ; Continua até escrever 32 bytes.
    ;
    ; ":-" referencia o label anônimo acima.
    BNE :-

    ; %10000000 ativa ênfase azul no PPUMASK.
    ;
    ; Isso NÃO liga a renderização.
    ; Apenas aplica uma tonalidade azulada
    ; à imagem final.
    LDA #%10000000

    ; Escreve configuração em PPUMASK ($2001).
    STA $2001

; Segmento principal do código do jogo
; A maior parte do assembly ficará aqui
.segment "CODE"

; ------------------------------------------------------------
; LOOP INFINITO PRINCIPAL
; ------------------------------------------------------------

forever:

    ; Como ainda não existe lógica de jogo,
    ; o programa simplesmente fica preso aqui.
    JMP forever

; ------------------------------------------------------------
; ROTINA NMI
; ------------------------------------------------------------
; Quando habilitado, o NMI acontece no início
; do VBLANK.
;
; Neste exemplo, o NMI está desabilitado em $2000,
; então esta rotina existe apenas porque o vetor
; precisa apontar para algum lugar válido.
; ------------------------------------------------------------

NMI:

    ; Retorna da interrupção.
    RTI

; ------------------------------------------------------------
; ROTINA IRQ/BRK
; ------------------------------------------------------------
; Não estamos usando IRQs neste exemplo.
; Mesmo assim, criamos uma rotina segura
; para o vetor IRQ/BRK apontar para ela.
; ------------------------------------------------------------

IRQ:

    ; Retorna da interrupção.
    RTI

; ------------------------------------------------------------
; TABELA DE VETORES DA CPU
; ------------------------------------------------------------

.segment "VECTORS"

    ; Vetor de NMI.
    .word NMI

    ; Vetor de RESET.
    .word RESET

    ; Vetor de IRQ/BRK.
    .word IRQ

; ------------------------------------------------------------
; SEGMENTO DE DADOS GRÁFICOS CHR
; ------------------------------------------------------------
; Aqui normalmente ficam:
; - tiles
; - sprites
; - fontes
; - padrões gráficos
;
; Neste exemplo ainda não há gráficos definidos.
; ------------------------------------------------------------

.segment "CHARS"