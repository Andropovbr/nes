# 02 - Paleta de Background

Este exemplo demonstra como escrever dados na RAM de paletas da PPU do NES para alterar a cor de fundo da tela.

## Objetivo

Aprender os conceitos básicos de manipulação de paletas no NES:

* Localização da RAM de paletas (`$3F00-$3F1F`)
* Uso dos registradores da PPU (`$2006` e `$2007`)
* Escrita de dados na VRAM
* Estrutura básica de uma paleta de background

## Conceitos apresentados

### RAM de Paletas

O NES possui uma área específica da PPU reservada para armazenar cores.

O endereço inicial dessa área é:

```text
$3F00
```

Os quatro primeiros bytes representam a primeira paleta de background:

```text
$3F00 = Cor universal de fundo
$3F01 = Cor 1
$3F02 = Cor 2
$3F03 = Cor 3
```

Neste exemplo carregamos a seguinte paleta:

```asm
palette_data:
    .byte $21, $01, $11, $31
```

### Acesso à PPU

Para escrever na RAM de paletas é necessário:

1. Definir o endereço desejado através de `$2006`
2. Escrever os dados através de `$2007`

O endereço `$3F00` é enviado em duas etapas:

```asm
LDA #$3F
STA $2006

LDA #$00
STA $2006
```

Depois disso, cada escrita em `$2007` grava um byte e avança automaticamente para o próximo endereço.

## Resultado

Ao executar a ROM, a cor universal de fundo é alterada para a cor definida em `$3F00`.

Como ainda não existem tiles desenhados na tela, apenas a primeira cor da paleta fica visível.

As demais cores serão utilizadas em exemplos futuros quando começarmos a desenhar backgrounds e sprites.

## O que este exemplo ensina

* Como localizar a RAM de paletas da PPU
* Como usar os registradores `$2006` e `$2007`
* Como copiar uma tabela de dados para a PPU
* Como alterar a cor de fundo do NES

## Próximos passos

Os próximos exemplos podem explorar:

* Animação de paletas usando NMI
* Desenho de tiles na nametable
* Uso completo das cores da paleta
* Criação de sprites