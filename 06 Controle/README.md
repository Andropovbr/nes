# NES Assembly - Movimento e Animação de Sprites Compostos

Este exemplo demonstra como criar um personagem composto por múltiplos sprites, controlado pelo jogador através do controle do NES, com animação de caminhada e mudança de direção.

É um passo importante para transformar exemplos isolados em um projeto que começa a se parecer com um jogo.

## O que este exemplo demonstra

- Leitura do controle do jogador.
- Movimentação utilizando o D-Pad.
- Atualização da lógica uma vez por quadro (NMI).
- Personagem composto por múltiplos sprites 8x8.
- Animação de caminhada por troca de tiles.
- Inversão horizontal (flip) para olhar para a esquerda e direita.
- Organização do projeto em múltiplos arquivos.

---

## Estrutura do projeto

```
src/
├── main.asm
├── zeropage.inc
├── controller.asm
├── player.asm
├── ppu.asm
├── palettes.asm
├── biker.asm
└── sprites.chr
```

Cada arquivo possui uma responsabilidade específica, facilitando a manutenção do projeto conforme novos recursos são adicionados.

---

## Sprite composto

O personagem é formado por uma matriz de **3 × 3 sprites**, totalizando:

- 9 sprites de 8×8 pixels
- Área total de 24×24 pixels

```
+----+----+----+
| 00 | 01 | 02 |
+----+----+----+
| 10 | 11 | 12 |
+----+----+----+
| 20 | 21 | 22 |
+----+----+----+
```

As duas primeiras linhas permanecem fixas durante toda a animação.

A última linha representa os pés e é responsável pela animação da caminhada.

---

## Animação

Foram utilizados dois frames de caminhada.

Frame 0

```
20 21 22
```

Frame 1

```
23 24 25
```

A animação alterna continuamente entre esses dois conjuntos de tiles enquanto o personagem está em movimento.

Quando o jogador para de andar, a animação retorna automaticamente ao primeiro frame.

---

## Atualização por quadro

A lógica do jogo não é executada continuamente.

A NMI sinaliza quando um novo quadro está disponível, permitindo que a lógica seja atualizada exatamente uma vez por frame.

Fluxo principal:

```
NMI
    ↓
frame_ready = 1
    ↓
Loop principal
    ↓
Lê controle
    ↓
Atualiza posição
    ↓
Atualiza animação
    ↓
Atualiza sprites
    ↓
Espera próxima NMI
```

Esse modelo evita velocidades inconsistentes e garante uma movimentação suave.

---

## Mudança de direção

O personagem possui uma variável de direção:

```
player_direction
```

Valores:

```
0 = direita
1 = esquerda
```

Ao mudar de direção:

- o bit de flip horizontal é ativado nos atributos dos sprites;
- a ordem das colunas é invertida.

Assim, um personagem montado originalmente como:

```
00 01 02
10 11 12
20 21 22
```

passa a ser exibido como:

```
02 01 00
12 11 10
22 21 20
```

sem necessidade de armazenar novos gráficos para a direção oposta.

---

## Organização da animação

O projeto utiliza algumas variáveis auxiliares:

| Variável | Função |
|----------|--------|
| `player_x` | Posição horizontal |
| `player_y` | Posição vertical |
| `player_direction` | Direção do personagem |
| `player_moving` | Indica se o personagem está andando |
| `anim_counter` | Controla a velocidade da animação |
| `anim_frame` | Frame atual da caminhada |
| `frame_ready` | Sincronização com a NMI |

---

## Próximos passos

Esta base permite implementar facilmente novos recursos, como:

- colisão com obstáculos;
- limites da tela;
- animação de idle;
- diferentes velocidades de movimento;
- inimigos;
- projéteis;
- scrolling;
- mapas.

---

## Requisitos

- cc65 (ca65 + ld65)
- Mesen (ou outro emulador compatível)
- Aseprite (edição dos sprites)
- NEXXT (opcional, para edição/importação de CHR)

---

## Licença

Este projeto é disponibilizado para fins de estudo e aprendizado da programação para o Nintendo Entertainment System (NES).
