# IA Simples no NES em Assembly

Neste capítulo da série adicionamos o primeiro inimigo ao projeto. O objetivo foi implementar uma inteligência artificial simples capaz de perseguir o jogador, reutilizando os mesmos gráficos do personagem e alterando apenas a paleta de cores.

Embora o comportamento seja bastante básico, ele introduz conceitos fundamentais que serão reutilizados na construção de jogos mais complexos.

---

## Objetivos

Ao final desta etapa o projeto possui:

- Um inimigo desenhado na tela utilizando um sprite composto.
- Reutilização dos mesmos tiles do jogador.
- Paleta de cores independente para diferenciar o inimigo.
- IA simples baseada na posição do jogador.
- Controle da velocidade do inimigo.
- Animação independente dos pés.

---

# Reaproveitando os Sprites

Como o jogador e o inimigo possuem exatamente o mesmo formato (3 × 3 sprites), não foi necessário criar novos gráficos.

Os mesmos tiles da CHR foram reutilizados:

```
00 01 02
03 04 05
06 07 08
```

A única diferença visual está na paleta utilizada.

Enquanto o jogador utiliza a paleta 0, o inimigo utiliza a paleta 1.

```text
Jogador
Paleta 0

Inimigo
Paleta 1
```

Essa técnica era bastante comum nos jogos do NES para economizar memória de vídeo.

---

# Adicionando uma Segunda Paleta de Sprites

Anteriormente o projeto carregava apenas uma paleta de sprites.

Foi criada uma segunda paleta para o inimigo:

```asm
sprite_palettes:

    ; Jogador
    .byte $29, $0C, $21, $32

    ; Inimigo
    .byte $29, $15, $06, $26
```

A rotina de carregamento passou a copiar oito bytes em vez de apenas quatro.

---

# Estrutura do Inimigo

Foram adicionadas novas variáveis na página zero para controlar o estado do inimigo.

```asm
enemy_x
enemy_y

enemy_direction
enemy_moving

enemy_move_counter

enemy_anim_counter
enemy_anim_frame
```

Cada variável possui uma responsabilidade específica.

| Variável | Função |
|----------|--------|
| enemy_x | Coordenada horizontal |
| enemy_y | Coordenada vertical |
| enemy_direction | Direção para a qual o inimigo está olhando |
| enemy_moving | Indica se está perseguindo o jogador |
| enemy_move_counter | Controla a velocidade da movimentação |
| enemy_anim_counter | Controla a velocidade da animação |
| enemy_anim_frame | Frame atual da caminhada |

---

# IA de Perseguição

A inteligência artificial implementada é extremamente simples.

Primeiro o inimigo compara sua posição horizontal com a posição do jogador.

```text
enemy_x < player_x
```

↓

Move para a direita.

Caso contrário:

```text
enemy_x > player_x
```

↓

Move para a esquerda.

O mesmo processo é repetido para o eixo Y.

```text
enemy_y < player_y
```

↓

Move para baixo.

```text
enemy_y > player_y
```

↓

Move para cima.

O resultado é um inimigo que sempre tenta reduzir a distância até o jogador.

---

# Comparando Coordenadas

A decisão é feita utilizando a instrução `CMP`.

```asm
LDA enemy_x
CMP player_x
```

Após a comparação são utilizadas duas instruções de desvio:

- `BEQ` → posições iguais
- `BCC` → inimigo menor que jogador

Quando nenhuma delas ocorre, significa que:

```text
enemy_x > player_x
```

e o inimigo deve mover-se para a esquerda.

---

# Controlando a Velocidade

Se o inimigo se movesse em todos os frames, sua velocidade seria muito alta.

Para resolver isso foi criado um contador.

```asm
INC enemy_move_counter
```

Enquanto o contador ainda não atingir o valor definido por:

```asm
ENEMY_MOVE_DELAY
```

a rotina termina imediatamente.

```asm
CMP #ENEMY_MOVE_DELAY
BCC update_enemy_done
```

Quando o contador chega ao limite:

- o contador é reiniciado;
- o inimigo pode dar mais um passo.

Essa técnica é bastante utilizada em jogos para controlar velocidades sem depender de temporizadores.

---

# Animação Independente

Assim como o jogador, o inimigo possui sua própria animação.

São utilizadas duas variáveis:

```asm
enemy_anim_counter
enemy_anim_frame
```

Enquanto o inimigo estiver perseguindo o jogador, o contador avança.

A cada oito frames o valor de `enemy_anim_frame` é alternado entre:

```
0
1
```

fazendo os pés mudarem entre os dois conjuntos de tiles.

---

# Atualizando a OAM

O jogador ocupa os primeiros 36 bytes da OAM Shadow.

```
$0200
...
$0223
```

O inimigo foi colocado logo em seguida.

```
$0224
...
$0247
```

Como cada sprite ocupa quatro bytes:

```
Y
Tile
Atributos
X
```

o índice `X` do loop é incrementado quatro vezes ao final de cada iteração.

```asm
INX
INX
INX
INX
```

Já o índice `Y` percorre as tabelas de deslocamentos e tiles.

```asm
INY
```

Ao final do processo os nove sprites do inimigo já estão posicionados corretamente na OAM Shadow.

---

# Organização do Loop Principal

O loop principal passou a atualizar tanto o jogador quanto o inimigo.

```text
Ler controle

↓

Atualizar jogador

↓

Atualizar animação do jogador

↓

Atualizar IA do inimigo

↓

Atualizar animação do inimigo

↓

Atualizar OAM
```

Essa organização separa claramente:

- entrada;
- lógica do jogo;
- renderização.

---

# Próximos Passos

Com o inimigo funcionando, o projeto já possui a base necessária para implementar mecânicas mais interessantes.

Nos próximos capítulos poderemos adicionar:

- colisão entre jogador e inimigo;
- vidas;
- efeito de dano;
- múltiplos inimigos;
- disparos;
- IA mais sofisticada.

A partir desse ponto o projeto começa a se aproximar cada vez mais de um jogo completo.