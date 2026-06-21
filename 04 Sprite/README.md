# 04 - Primeiro Sprite

Este exemplo demonstra como exibir o primeiro sprite na tela do NES.

Até este ponto da série, trabalhamos apenas com cores de fundo e paletas. Agora vamos utilizar a memória de sprites (OAM), uma paleta dedicada para sprites e um tile armazenado na CHR-ROM para desenhar um objeto visível na tela.

O resultado é uma pequena figura 8x8 pixels exibida no centro da tela.

## Conceitos abordados

* Estrutura de um sprite no NES
* Memória OAM (Object Attribute Memory)
* DMA de sprites através do registrador `$4014`
* Paletas de sprites
* CHR-ROM
* Tiles de 8x8 pixels
* Interrupção NMI

## Estrutura de um sprite

Cada sprite ocupa 4 bytes na OAM:

```text
.byte Y, TILE, ATRIBUTOS, X
```

| Byte      | Descrição                 |
| --------- | ------------------------- |
| Y         | Posição vertical          |
| TILE      | Índice do tile na CHR-ROM |
| ATRIBUTOS | Paleta e efeitos visuais  |
| X         | Posição horizontal        |

Exemplo:

```asm
.byte $70, $00, $00, $80
```

Neste caso:

* Y = `$70`
* Tile = `0`
* Paleta = `0`
* X = `$80`

## Paletas

O NES possui paletas separadas para background e sprites.

Neste exemplo são utilizadas:

```asm
bg_palette:
    .byte $0F, $01, $11, $31

sprite_palette:
    .byte $0F, $27, $15, $3D
```

A paleta do sprite é carregada na região `$3F10-$3F13` da memória da PPU.

## OAM DMA

Os dados dos sprites são inicialmente armazenados na RAM em `$0200`.

Durante a interrupção NMI, eles são copiados para a OAM da PPU através de DMA:

```asm
LDA #$00
STA $2003

LDA #$02
STA $4014
```

Isso transfere toda a página `$0200-$02FF` para a memória de sprites da PPU.

## CHR-ROM

O gráfico do sprite é armazenado na CHR-ROM.

Cada tile ocupa 16 bytes:

* 8 bytes para o bitplane 0
* 8 bytes para o bitplane 1

Neste exemplo foi criado um tile simples em formato de círculo/losango.

## Resultado

Após a inicialização da PPU:

* A paleta é carregada.
* O sprite é configurado na OAM.
* A CHR-ROM fornece os dados gráficos.
* O NMI realiza o DMA.
* O sprite é exibido na tela.

## Próximos passos

A partir deste exemplo já é possível evoluir para:

* Sprites compostos (personagens formados por vários tiles)
* Uso do YY-CHR
* Animação de sprites
* Movimento
* Leitura do controle
* Colisão

Este é o primeiro passo para criar personagens e objetos visíveis em jogos para NES.
