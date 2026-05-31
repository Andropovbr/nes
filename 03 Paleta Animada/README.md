# 03 - Paleta Animada

Este exemplo demonstra como animar a cor de fundo do NES utilizando a interrupção **NMI (Non-Maskable Interrupt)** e a memória de paletas da PPU.

O programa alterna a cor de fundo entre azul, vermelho, verde e amarelo em intervalos regulares, criando uma animação simples sem utilizar sprites ou tiles.

## Conceitos abordados

* Interrupções NMI
* VBlank
* Variáveis na Zero Page
* Contador de frames
* Tabelas de dados
* Atualização da PPU durante o VBlank
* Alteração dinâmica de cores da paleta

## Como funciona

Durante a inicialização, o programa:

1. Inicializa a CPU e a PPU.
2. Limpa a RAM.
3. Carrega uma paleta de cores inicial.
4. Habilita a interrupção NMI.
5. Liga a renderização do background.

A partir desse momento, a PPU gera uma interrupção NMI no início de cada VBlank.

## Contador de frames

A cada execução da rotina NMI, uma variável chamada `frame_counter` é incrementada.

Como o NES NTSC executa aproximadamente 60 frames por segundo:

* 30 frames ≈ 0,5 segundo
* 60 frames ≈ 1 segundo

Quando o contador atinge 30:

* O contador é zerado.
* O índice da cor atual é incrementado.
* A próxima cor da tabela é carregada.

## Tabela de cores

```asm
background_colors:
    .byte $21, $16, $2A, $28
```

As cores são percorridas ciclicamente:

```text
$21 → Azul
$16 → Vermelho
$2A → Verde
$28 → Amarelo
```

Quando a última cor é alcançada, o índice retorna para zero e o ciclo recomeça.

## Atualizando a paleta

A rotina NMI altera apenas o endereço `$3F00`, que corresponde à cor universal de fundo da PPU.

```text
$3F00 = Cor de fundo
$3F01 = Cor 1 da paleta
$3F02 = Cor 2 da paleta
$3F03 = Cor 3 da paleta
```

Dessa forma, apenas a cor de fundo muda, enquanto as demais cores da paleta permanecem inalteradas.

## Estrutura geral

```text
RESET
 ├─ Inicializa CPU
 ├─ Limpa RAM
 ├─ Carrega paleta
 ├─ Habilita NMI
 ├─ Liga renderização
 └─ Loop infinito

NMI
 ├─ Incrementa frame_counter
 ├─ Verifica se passaram 30 frames
 ├─ Atualiza color_index
 ├─ Escreve nova cor em $3F00
 └─ RTI
```

## O que aprendemos

Este exemplo introduz um dos conceitos mais importantes do desenvolvimento para NES: utilizar o VBlank para atualizar elementos gráficos.

Embora este demo altere apenas uma cor da paleta, a mesma técnica será utilizada futuramente para:

* Animar sprites
* Mover personagens
* Atualizar HUDs
* Fazer scroll de cenários
* Atualizar tiles na tela

Em outras palavras, este é o primeiro exemplo que utiliza uma estrutura semelhante à de um jogo real para NES.
