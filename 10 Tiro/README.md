# Disparo de Projéteis e Colisão entre Entidades no NES

## Objetivo

Até este ponto da série, já possuímos:

- Movimentação do jogador;
- Animação de sprites;
- Colisão com obstáculos do cenário;
- Um inimigo que persegue o jogador.

Neste capítulo, evoluímos a demo adicionando:

- Disparo de projéteis;
- Colisão entre projétil e inimigo;
- Colisão entre jogador e inimigo;
- Estados de vitória e derrota;
- Reinício da partida com o botão **Start**.

---

# Organização do projeto

Para manter o código organizado, cada responsabilidade ficou em um arquivo diferente.

| Arquivo | Responsabilidade |
|----------|------------------|
| `projectile.asm` | Criação, movimentação e desenho do projétil |
| `collision.asm` | Colisões entre jogador, inimigo e projétil |
| `controller.asm` | Detecção de botões recém-pressionados |
| `main.asm` | Fluxo principal do jogo e estados da partida |

Essa separação facilita futuras expansões e evita concentrar toda a lógica em um único arquivo.

---

# Um único projétil

Nesta primeira implementação existe apenas um projétil ativo por vez.

Isso simplifica bastante a lógica.

As variáveis utilizadas são:

```asm
projectile_active
projectile_x
projectile_y
projectile_direction
```

Quando `projectile_active` vale zero, não existe nenhum projétil na tela.

Ao pressionar o botão **A**, um novo projétil é criado.

---

# Disparo

O projétil nasce na frente do jogador.

Sua posição depende da direção para a qual o personagem está olhando.

```text
Jogador olhando para a direita

[PLAYER]---->

             *
          projétil
```

```text
Jogador olhando para a esquerda

<----[PLAYER]

   *
projétil
```

A direção do projétil é copiada da direção atual do jogador.

Depois disso, ele continua seguindo seu caminho mesmo que o jogador mude de direção.

---

# Movimento

A cada frame o projétil é deslocado alguns pixels.

```text
Frame 1

*

Frame 2

   *

Frame 3

      *
```

Quando ele alcança uma das bordas da tela, é desativado.

Isso evita que continue existindo fora da área visível.

---

# Sprite do projétil

O jogador ocupa os sprites:

```
$0200-$0223
```

O inimigo ocupa:

```
$0224-$0247
```

O próximo sprite livre fica em:

```
$0248
```

Portanto, o projétil utiliza:

| Endereço | Conteúdo |
|----------|-----------|
| `$0248` | Y |
| `$0249` | Tile |
| `$024A` | Atributos |
| `$024B` | X |

Quando o projétil está inativo, sua coordenada Y recebe `$FE`, escondendo-o da tela.

---

# Botões recém-pressionados

Até agora o programa verificava apenas se um botão estava pressionado.

Para o disparo isso não é suficiente.

Se o botão **A** permanecer pressionado durante vários frames, um novo projétil seria criado continuamente.

Para resolver isso foram adicionadas três variáveis:

```asm
controller1
previous_controller1
controller_pressed
```

O cálculo realizado é:

```text
controller_pressed =
    controller_atual
    AND
    (NOT controller_anterior)
```

Assim somente os botões que acabaram de ser pressionados permanecem ativos durante um único frame.

Essa mesma lógica também foi utilizada para detectar o botão **Start**.

---

# Colisão entre entidades

Até então existia apenas a colisão entre jogador e cenário.

Agora o mesmo conceito foi aplicado entre entidades móveis.

Foram implementadas duas novas rotinas:

- Jogador × Inimigo
- Projétil × Inimigo

---

# Bounding Box (AABB)

Cada objeto é tratado como um retângulo.

```text
+-------------------+
|                   |
|      Jogador      |
|                   |
+-------------------+
```

A colisão ocorre quando esses retângulos se sobrepõem.

Não é necessário verificar pixel por pixel.

A rotina procura quatro situações em que os retângulos estão completamente separados.

Se nenhuma delas ocorrer, existe colisão.

---

# Colisão entre jogador e inimigo

Jogador e inimigo possuem aproximadamente:

```
24 x 24 pixels
```

São verificadas quatro condições:

- jogador totalmente à esquerda;
- jogador totalmente à direita;
- jogador totalmente acima;
- jogador totalmente abaixo.

Se nenhuma delas for verdadeira:

```asm
collision = 1
```

O programa então:

- marca o jogador como morto;
- encerra a partida.

---

# Colisão entre projétil e inimigo

O projétil utiliza uma caixa de colisão de:

```
8 x 8 pixels
```

Embora o desenho possua apenas alguns pixels visíveis, utilizar uma caixa maior torna o jogo mais agradável.

Quando ocorre colisão:

- o projétil desaparece;
- o inimigo desaparece;
- a partida termina.

---

# Escondendo sprites

No NES não é necessário remover sprites da OAM.

Basta posicioná-los fora da tela.

Para isso, utiliza-se:

```asm
Y = $FE
```

Essa técnica foi utilizada para esconder:

- jogador;
- inimigo;
- projétil.

É uma solução extremamente comum em jogos comerciais para o NES.

---

# Estado da partida

Foi adicionada a variável:

```asm
game_over
```

Ela indica apenas se a partida terminou.

```
0 = partida em andamento

1 = partida encerrada
```

Não importa quem venceu.

O resultado pode ser identificado observando:

```asm
player_alive

enemy_alive
```

---

# Reinício da partida

Quando `game_over` vale um, o jogo deixa de atualizar:

- jogador;
- inimigo;
- projétil.

O único botão aceito passa a ser:

```
Start
```

Ao pressioná-lo, a rotina `initialize_game` restaura:

- posição do jogador;
- posição do inimigo;
- estados das animações;
- projétil;
- estado da partida.

Não é necessário executar novamente o processo completo de RESET do console.

---

# Organização das responsabilidades

Uma preocupação importante desta etapa foi separar as responsabilidades do código.

- `projectile.asm` cuida apenas do projétil;
- `collision.asm` apenas detecta colisões;
- `main.asm` decide o que acontece após uma colisão;
- `controller.asm` interpreta a entrada do jogador.

Essa organização torna o projeto mais fácil de manter e preparar para futuras expansões.

---

# Próximos passos

Com essa etapa concluída, nossa demo já possui praticamente todos os elementos fundamentais de um jogo para NES:

- ✅ Controle
- ✅ Movimento
- ✅ Animação
- ✅ Colisão com cenário
- ✅ IA simples
- ✅ Disparo
- ✅ Colisão entre entidades
- ✅ Estados de vitória e derrota

Nos próximos capítulos adicionaremos:

- efeitos sonoros;
- música de fundo;
- integração do sistema de áudio ao projeto.

Após isso, a base estará pronta para iniciar o desenvolvimento de um jogo completo utilizando toda a infraestrutura construída ao longo da série.