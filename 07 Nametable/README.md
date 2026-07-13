# Backgrounds, Paletas e Attribute Table no NES

Este exemplo apresenta os primeiros conceitos de construção de cenários no NES utilizando **background tiles**, **Nametable** e **Attribute Table**.

Até este ponto da série, o personagem era composto por sprites. Agora começamos a utilizar o sistema de background da PPU para desenhar elementos fixos do cenário, como gramado e chão.

---

# Objetivos

Neste exemplo aprendemos a:

- Utilizar tiles da CHR-ROM como background.
- Carregar múltiplas paletas de background.
- Desenhar um cenário utilizando a Nametable.
- Selecionar paletas diferentes através da Attribute Table.
- Entender a diferença entre sprites e background.

---

# Organização da CHR

A CHR-ROM contém tanto os gráficos do personagem quanto do cenário.

Exemplo de organização:

| Tiles | Conteúdo |
|--------|----------|
| 00-0B | Personagem |
| 10-13 | Gramado |
| 14-17 | Chão |
| 18 | Tile vazio |

A CHR não faz distinção entre sprites e background. Ela apenas armazena desenhos de 8x8 pixels.

Quem define como esses desenhos serão utilizados é a PPU.

---

# Sprites x Background

Os sprites são desenhados através da OAM.

Cada sprite possui:

- posição X
- posição Y
- índice do tile
- atributos

Já o cenário é desenhado pela Nametable.

A Nametable contém apenas os índices dos tiles que devem aparecer em cada posição da tela.

```
CHR-ROM
    ↓
Nametable
    ↓
PPU desenha o cenário
```

---

# Paletas de Background

O NES possui quatro paletas de background.

```
$3F00-$3F03  Paleta 0
$3F04-$3F07  Paleta 1
$3F08-$3F0B  Paleta 2
$3F0C-$3F0F  Paleta 3
```

Neste exemplo utilizamos duas delas.

## Paleta 0

Utilizada pelo gramado.

```asm
.byte $29, $19, $2B, $39
```

## Paleta 1

Utilizada pelo chão.

```asm
.byte $29, $17, $27, $37
```

---

# Cor Universal do Background

Um detalhe importante da arquitetura do NES é que a primeira cor das paletas de background é compartilhada.

Na prática:

```
$3F00
```

é a cor universal do background.

Mesmo carregando:

```
$3F04
$3F08
$3F0C
```

o índice de cor 0 continuará utilizando a cor definida em `$3F00`.

Por isso, normalmente desenhamos o "fundo" dos tiles utilizando o índice **1**, deixando o índice **0** apenas para a cor universal.

---

# Espelhamento da Paleta de Sprites

Durante os testes foi observado outro detalhe importante.

O endereço:

```
$3F10
```

é espelhado para:

```
$3F00
```

Ou seja, ao carregar a primeira cor da paleta de sprites, ela também altera a cor universal do background.

Por isso, o primeiro byte da paleta de sprites deve possuir o mesmo valor da paleta de background.

Exemplo:

```asm
Background

.byte $29, $19, $2B, $39

Sprites

.byte $29, $0C, $21, $32
```

---

# Desenhando o Cenário

O cenário foi desenhado diretamente na Nametable.

Cada bloco de cenário possui 2x2 tiles.

## Gramado

```
10 11
12 13
```

## Chão

```
14 15
16 17
```

Esses blocos são repetidos até preencher a tela.

---

# Attribute Table

Após desenhar a Nametable, precisamos informar qual paleta cada região utilizará.

Isso é feito através da Attribute Table.

Ela ocupa:

```
$23C0-$23FF
```

Cada byte controla uma região de:

```
32 x 32 pixels
```

Internamente esse byte é dividido em quatro quadrantes.

Cada quadrante utiliza dois bits para selecionar uma das quatro paletas.

```
00 -> Paleta 0
01 -> Paleta 1
10 -> Paleta 2
11 -> Paleta 3
```

---

# Configurando as Paletas

Neste exemplo configuramos:

- metade superior usando a paleta 0;
- metade inferior usando a paleta 1.

Os primeiros 32 bytes da Attribute Table recebem:

```asm
$00
```

Todos os quadrantes utilizam a paleta 0.

Os últimos 32 bytes recebem:

```asm
$55
```

Em binário:

```
01010101
```

Cada grupo de dois bits vale:

```
01
```

ou seja, todos os quadrantes utilizam a paleta 1.

---

# Ordem da Inicialização

Durante o RESET, a sequência correta é:

```asm
JSR load_palettes
JSR clear_nametable
JSR draw_background
JSR load_bg_attributes
```

Cada rotina escreve em uma região diferente da memória da PPU.

```
$2000-$23BF -> Nametable

$23C0-$23FF -> Attribute Table

$3F00-$3F1F -> Paletas
```

---

# Quantidade de Linhas

Cada bloco desenhado possui duas linhas de tiles.

Assim:

```
LDY #$08
```

desenha:

```
8 blocos
=
16 linhas
=
128 pixels
```

Como a tela possui:

```
30 linhas de tiles
```

a soma das duas regiões deve sempre resultar em 30 linhas.

Exemplo:

```
Gramado
8 blocos
=
16 linhas

Chão
7 blocos
=
14 linhas

Total
30 linhas
```

---

# O que aprendemos

Este exemplo introduz três conceitos fundamentais da PPU do NES:

- A CHR-ROM armazena apenas os desenhos.
- A Nametable define quais tiles aparecem na tela.
- A Attribute Table define qual paleta cada região utiliza.

Com esses conceitos dominados, já é possível construir cenários completos utilizando diferentes tipos de terreno, reutilizando os mesmos tiles com paletas diferentes e preparando a base para implementar colisão com o mapa.
