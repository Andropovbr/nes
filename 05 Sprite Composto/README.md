# 05 - Sprite Composto

Este exemplo demonstra como criar um personagem utilizando vários sprites de 8x8 pixels.

No exemplo anterior foi exibido apenas um único sprite. Agora vamos combinar vários tiles para formar um personagem maior, semelhante à forma como os jogos comerciais do NES construíam seus personagens.

O resultado é um personagem de 16x32 pixels formado por 8 sprites independentes.

## Conceitos abordados

* Sprites compostos
* Arquivos CHR externos
* Uso do YY-CHR
* Paletas de sprites
* Atributos de sprite
* Organização de tiles na CHR-ROM
* Composição de personagens na OAM

## CHR-ROM externa

Em vez de definir os gráficos diretamente no código Assembly, este exemplo utiliza um arquivo CHR externo:

```asm
.segment "CHARS"

.incbin "sprites_8kb.chr"
```

Isso permite desenhar os gráficos em ferramentas como o YY-CHR e incorporá-los diretamente na ROM.

## Organização dos tiles

Os tiles utilizados pelo personagem ocupam as primeiras posições da CHR-ROM:

```text
+----+----+
| 00 | 01 |
+----+----+
| 02 | 03 |
+----+----+
| 04 | 05 |
+----+----+
| 06 | 07 |
+----+----+
```

Cada tile possui 8x8 pixels.

Juntos, formam um personagem de:

```text
16 x 32 pixels
```

## Estrutura de um sprite

Cada sprite utiliza 4 bytes:

```text
.byte Y, TILE, ATRIBUTOS, X
```

| Campo     | Descrição                 |
| --------- | ------------------------- |
| Y         | Posição vertical          |
| TILE      | Índice do tile na CHR-ROM |
| ATRIBUTOS | Paleta e efeitos visuais  |
| X         | Posição horizontal        |

## Montando o personagem

O personagem é definido através da tabela:

```asm
biker_sprite:
    .byte $60, $00, $00, $80
    .byte $60, $01, $00, $88

    .byte $68, $02, $00, $80
    .byte $68, $03, $00, $88

    .byte $70, $04, $00, $80
    .byte $70, $05, $00, $88

    .byte $78, $06, $00, $80
    .byte $78, $07, $00, $88
```

Observe que:

* Os valores X avançam de 8 em 8 pixels.
* Os valores Y avançam de 8 em 8 pixels.
* Cada entrada utiliza um tile diferente da CHR-ROM.

Isso faz com que os 8 sprites sejam desenhados lado a lado, formando um único personagem.

## Paletas de sprite

O NES possui paletas separadas para background e sprites.

Neste exemplo:

```asm
bg_palette:
    .byte $0F, $01, $11, $31

sprite_palette:
    .byte $0D, $27, $15, $3D
```

A paleta de sprite é carregada na região:

```text
$3F10-$3F13
```

da memória da PPU.

## Atributos

O terceiro byte de cada sprite controla:

* Paleta utilizada
* Prioridade
* Flip horizontal
* Flip vertical

Formato:

```text
76543210
||||||||
||||++-- Paleta (0-3)
|||+---- Não usado
||+----- Não usado
|+------ Prioridade
+------- Flip horizontal
```

Exemplo:

```asm
%00000000
```

Utiliza a paleta de sprite 0 sem efeitos adicionais.

## DMA de sprites

Assim como no exemplo anterior, os dados são copiados da RAM para a OAM através de DMA durante o NMI:

```asm
LDA #$00
STA $2003

LDA #$02
STA $4014
```

## Resultado

Ao executar a ROM:

* A CHR-ROM fornece os gráficos.
* A paleta de sprite define as cores.
* Os 8 sprites são posicionados na tela.
* O personagem aparece como uma única entidade visual.

## Próximos passos

Este exemplo serve de base para:

* Animação de personagens
* Movimento horizontal e vertical
* Controle pelo joypad
* Flip horizontal para mudar direção
* Sprites compostos mais complexos
* Desenvolvimento de jogos completos

A maioria dos personagens de jogos para NES é construída exatamente dessa forma: vários sprites 8x8 posicionados lado a lado para formar uma figura maior.
