# Colisão com Obstáculos no NES

Este exemplo demonstra como implementar uma das técnicas mais utilizadas em jogos para NES: **colisão entre o jogador e obstáculos do cenário**.

Até este ponto do projeto, o personagem podia se mover livremente pela tela, respeitando apenas os limites do vídeo. Agora adicionamos uma cerca ao background e impedimos que o jogador atravesse esse obstáculo.

---

# Objetivos

Ao final deste exemplo, você terá aprendido:

- Como desenhar obstáculos na Nametable.
- Como posicionar objetos em coordenadas específicas da tela.
- Como implementar colisão entre o jogador e um obstáculo.
- Como cancelar um movimento quando ocorre colisão.
- Como utilizar múltiplas paletas de background para destacar elementos do cenário.

---

# Como o obstáculo é desenhado

A cerca é composta por um bloco de **2 × 2 tiles**.

```
0C 0D
0E 0F
```

Cada bloco ocupa:

- 16 pixels de largura
- 16 pixels de altura

A rotina `draw_fence` posiciona esses tiles diretamente na Nametable utilizando os registradores da PPU.

Exemplo de sequência:

```asm
LDA $2002

LDA #$21
STA $2006

LDA #$CC
STA $2006
```

Após configurar o endereço, os tiles são escritos utilizando `$2007`.

---

# Nametable x OAM

É importante entender que existem dois sistemas independentes.

## Background

Os tiles do cenário são armazenados na Nametable.

```
CPU
 │
 ├── $2006
 └── $2007
      │
      ▼
Nametable
```

## Sprites

O personagem utiliza sprites armazenados na OAM.

```
CPU
 │
 ├── $0200
 └── DMA ($4014)
      │
      ▼
OAM
```

Por isso, desenhar a cerca não interfere no sprite do jogador.

---

# Posição da cerca

Neste exemplo, a cerca foi posicionada em:

```
Nametable:
$21CC
$21EC
```

Correspondendo aproximadamente a:

```
X = 96 pixels
Y = 112 pixels
```

Ela ocupa:

```
Largura: 64 pixels
Altura : 16 pixels
```

---

# Como a colisão funciona

A colisão utiliza uma técnica chamada **Bounding Box** (AABB - Axis Aligned Bounding Box).

Em vez de verificar pixel por pixel, o jogo considera apenas dois retângulos.

```
+--------------------+
|      Jogador       |
+--------------------+

        VS

+------------------------------+
|            Cerca             |
+------------------------------+
```

---

# Área do jogador

Neste exemplo inicial foi utilizada toda a área do sprite:

```
24 x 24 pixels
```

Ou seja:

```
left   = player_x
right  = player_x + 23

top    = player_y
bottom = player_y + 23
```

Posteriormente é possível utilizar uma hitbox menor para deixar a colisão mais natural.

---

# Área da cerca

A cerca possui um retângulo fixo:

```
left   = 96
right  = 159

top    = 112
bottom = 127
```

Esses valores são utilizados pela rotina de colisão.

---

# Detectando colisão

Ao invés de perguntar:

> "Os objetos estão colidindo?"

É mais simples perguntar:

- O jogador está totalmente à esquerda?
- Está totalmente à direita?
- Está totalmente acima?
- Está totalmente abaixo?

Se qualquer uma dessas condições for verdadeira:

```
Não existe colisão.
```

Caso contrário:

```
Existe colisão.
```

Essa abordagem reduz bastante a quantidade de comparações necessárias.

---

# Cancelando o movimento

A lógica utilizada pelo projeto é simples:

1. Move o jogador um pixel.
2. Testa a colisão.
3. Se houve colisão, desfaz o movimento.

Exemplo:

```asm
INC player_x

JSR check_fence_collision

LDA collision
BNE undo_move
```

Se houver colisão:

```asm
DEC player_x
```

O jogador retorna exatamente para a posição anterior.

O mesmo processo é utilizado para as quatro direções.

---

# Por que mover antes e desfazer depois?

Essa estratégia possui algumas vantagens:

- código simples;
- fácil de entender;
- evita cálculos adicionais;
- facilita a explicação em vídeos didáticos.

Embora jogos maiores normalmente calculem a posição futura antes de mover o personagem, esta abordagem é excelente para projetos iniciantes.

---

# Paletas de Background

O NES possui quatro paletas independentes para o background.

```
Paleta 0
Paleta 1
Paleta 2
Paleta 3
```

Cada paleta possui quatro cores.

Neste projeto:

- Paleta 0 → gramado
- Paleta 1 → chão
- Paleta 2 → cerca

---

# Tabela de atributos

Os tiles não armazenam qual paleta utilizam.

Essa informação fica na **Attribute Table**.

Cada byte controla uma área de:

```
4 × 4 tiles
```

Dividida em quatro quadrantes:

```
+-------+-------+
|   TL  |   TR  |
+-------+-------+
|   BL  |   BR  |
+-------+-------+
```

Cada quadrante utiliza apenas **2 bits**, permitindo selecionar uma das quatro paletas de background.

---

# Organização do projeto

Após esta etapa o projeto passa a possuir responsabilidades bem definidas:

```
main.asm
    Inicialização

ppu.asm
    Background
    Nametable
    Paletas
    Sprites

controller.asm
    Leitura do controle

player.asm
    Movimento
    Animação

collision.asm
    Colisão

biker.asm
    Dados do personagem
```

Essa separação facilita bastante a manutenção do código.

---

# Próximos passos

Com a colisão funcionando, torna-se possível implementar diversos elementos comuns em jogos:

- árvores;
- pedras;
- paredes;
- lagos;
- casas;
- NPCs;
- portas;
- obstáculos destrutíveis.

Também será possível evoluir para colisão baseada em mapas inteiros de tiles, utilizada pela maioria dos jogos comerciais do NES.

---

# Conclusão

A colisão por retângulos é uma técnica extremamente eficiente e muito utilizada em jogos 2D.

Apesar da simplicidade, ela permite criar cenários sólidos, controlar o movimento do jogador e servir de base para mecânicas mais avançadas.

Este exemplo demonstra como integrar desenho do cenário, movimentação e detecção de colisão utilizando apenas Assembly 6502 e os recursos disponíveis no hardware original do NES.
