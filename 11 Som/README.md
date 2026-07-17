# Áudio no projeto NES

Este projeto utiliza a **FamiStudio Sound Engine** para reproduzir simultaneamente:

- a música `song_stage_2`, iniciada junto com o jogo;
- o efeito sonoro `sfx_megamanhit`, executado quando um projétil é disparado;
- a parte DPCM da música, armazenada no arquivo `audio/song.dmc`.

O código é escrito em assembly 6502 e montado com `ca65` e `ld65`.

## Organização dos arquivos de áudio

| Arquivo | Responsabilidade |
| --- | --- |
| `src/audio.asm` | Configura a engine e inclui todos os dados de áudio na ROM. |
| `audio/famistudio_ca65.s` | Implementação da FamiStudio Sound Engine. |
| `audio/song.s` | Dados, instrumentos e sequências da música exportada pelo FamiStudio. |
| `audio/song.inc` | Define o índice `song_stage_2 = 0`. |
| `audio/song.dmc` | Sample utilizado pelo canal DPCM da música. |
| `audio/sfx.s` | Dados do efeito sonoro exportado pelo FamiStudio. |
| `audio/sfx.inc` | Define o índice `sfx_megamanhit = 0`. |
| `src/startup.asm` | Inicializa a engine, os efeitos e inicia a música. |
| `src/interrupts.asm` | Atualiza o áudio uma vez a cada quadro. |
| `src/projectile.asm` | Solicita a reprodução do efeito ao disparar o projétil. |
| `nes-dpcm.cfg` | Posiciona o sample DPCM no endereço correto da ROM. |

Os arquivos dentro de `audio/` são gerados pelo FamiStudio. Quando a música ou o efeito forem alterados, eles devem ser exportados novamente pelo programa.

## Visão geral do funcionamento

O fluxo do áudio pode ser resumido assim:

1. O console entra na rotina `RESET`.
2. `famistudio_init` recebe os dados da música.
3. `famistudio_sfx_init` recebe os dados dos efeitos sonoros.
4. `famistudio_music_play` inicia `song_stage_2`.
5. A NMI chama `famistudio_update` uma vez por quadro.
6. Quando o jogador dispara, `famistudio_sfx_play` inicia `sfx_megamanhit`.
7. A engine combina música e efeito sonoro antes de atualizar os registradores de áudio do NES.

Depois de iniciada, a música não precisa ser solicitada novamente. A chamada feita a cada quadro mantém o andamento das notas, instrumentos, envelopes, efeitos e samples.

## Configuração da engine

A configuração está concentrada em `src/audio.asm` e é feita antes da inclusão da engine:

```asm
FAMISTUDIO_CFG_NTSC_SUPPORT = 1
FAMISTUDIO_CFG_PAL_SUPPORT  = 0
FAMISTUDIO_CFG_SFX_SUPPORT  = 1
FAMISTUDIO_CFG_SFX_STREAMS  = 1
FAMISTUDIO_CFG_THREAD       = 1
FAMISTUDIO_CFG_DPCM_SUPPORT = 1
```

As opções têm as seguintes funções:

- `FAMISTUDIO_CFG_NTSC_SUPPORT`: utiliza a temporização NTSC do jogo.
- `FAMISTUDIO_CFG_SFX_SUPPORT`: habilita a reprodução de efeitos sonoros.
- `FAMISTUDIO_CFG_SFX_STREAMS`: reserva um fluxo para um efeito simultâneo.
- `FAMISTUDIO_CFG_THREAD`: protege a comunicação entre o código principal, que solicita o efeito, e a NMI, que atualiza a engine.
- `FAMISTUDIO_CFG_DPCM_SUPPORT`: habilita o canal DPCM e permite executar `song.dmc`.

A música também utiliza recursos específicos habilitados pelas seguintes opções:

```asm
FAMISTUDIO_EXP_FDS           = 1
FAMISTUDIO_USE_RELEASE_NOTES = 1
FAMISTUDIO_USE_VOLUME_TRACK  = 1
FAMISTUDIO_USE_PITCH_TRACK   = 1
```

Essas opções precisam coincidir com os recursos usados durante a exportação da música. Desabilitar uma delas pode eliminar canais ou fazer a engine interpretar os dados incorretamente.

## Como a música é iniciada

Depois da limpeza da memória e da espera pelo VBlank, `RESET`, em `src/startup.asm`, executa:

```asm
LDA #$01
LDX #<music_data_gyruss
LDY #>music_data_gyruss
JSR famistudio_init

LDA #song_stage_2
JSR famistudio_music_play
```

Na inicialização:

- `A = 1` informa à engine que o jogo utiliza NTSC;
- `X` recebe o byte baixo do endereço dos dados musicais;
- `Y` recebe o byte alto;
- `famistudio_init` prepara os canais e o estado interno da música;
- `song_stage_2` vale `0`, pois é a primeira música da tabela exportada;
- `famistudio_music_play` começa a reprodução dessa música.

A inicialização acontece antes de a PPU e a NMI serem ativadas. Quando a NMI começa a executar, a música já está preparada para receber sua primeira atualização.

## Atualização por quadro

Uma música não continua tocando apenas com a chamada de inicialização. A engine precisa avançar seu estado exatamente uma vez por quadro.

Em `src/interrupts.asm`, a NMI executa:

```asm
JSR famistudio_update
```

Essa rotina:

- avança a posição atual da música;
- processa notas, volumes, timbres e efeitos;
- verifica se há um efeito sonoro ativo;
- inicia ou continua samples DPCM;
- escreve o resultado nos registradores da APU e da expansão de áudio.

A NMI preserva `A`, `X` e `Y` na pilha antes da atualização e restaura os três registradores antes de retornar. Assim, o áudio não altera acidentalmente o código que estava sendo executado no loop principal.

## Como o efeito de disparo funciona

Os dados do efeito são inicializados separadamente dos dados musicais:

```asm
LDX #<sounds
LDY #>sounds
JSR famistudio_sfx_init
```

Quando o projétil é ativado, `src/projectile.asm` executa:

```asm
LDA #sfx_megamanhit
LDX #FAMISTUDIO_SFX_CH0
JSR famistudio_sfx_play
```

Nesse momento:

- `A` contém o índice do efeito que deve ser reproduzido;
- `X` seleciona o fluxo de efeitos `FAMISTUDIO_SFX_CH0`;
- `famistudio_sfx_play` registra a solicitação na engine;
- na próxima chamada de `famistudio_update`, o efeito é misturado com a música.

O índice `sfx_megamanhit` vale `0`, pois esse é o primeiro efeito presente em `audio/sfx.s`.

O efeito não interrompe permanentemente a música. Durante sua reprodução, a engine dá prioridade ao efeito nos canais necessários e continua mantendo o estado musical. Quando o efeito termina, os canais voltam a reproduzir somente a música.

## Funcionamento do DPCM

DPCM é o canal da APU capaz de reproduzir amostras digitalizadas. Diferentemente dos canais de pulso, triângulo e ruído, ele lê os bytes do sample diretamente da ROM.

O arquivo é incluído em um segmento separado:

```asm
.segment "DPCM"
    .incbin "../audio/song.dmc"
```

A configuração define o endereço esperado pela engine:

```asm
FAMISTUDIO_DPCM_OFF = $C000
```

O linker usa `nes-dpcm.cfg` para colocar o segmento `DPCM` exatamente entre `$C000` e `$C0BF`. Esse posicionamento é importante porque a APU acessa samples DPCM em uma região específica da memória e o endereço inicial precisa estar alinhado em blocos de 64 bytes.

Quando a sequência musical alcança uma nota DPCM, a engine consulta a tabela de samples presente em `audio/song.s`, configura os registradores do canal e inicia a leitura de `song.dmc`. Não é necessário chamar uma rotina DPCM manualmente: ele faz parte de `song_stage_2` e é disparado pela própria música.

## Música e efeito tocando juntos

Música e efeitos possuem dados e inicializações separados, mas compartilham a mesma engine e a mesma atualização por quadro:

- `famistudio_init` controla os dados musicais;
- `famistudio_sfx_init` controla a tabela de efeitos;
- `famistudio_music_play` seleciona a música;
- `famistudio_sfx_play` solicita um efeito;
- `famistudio_update` processa tudo e envia o resultado ao hardware.

Por isso, a ordem de inicialização deve ser preservada e a engine não deve ser reinicializada depois de `famistudio_music_play`. Uma nova inicialização apagaria o estado da música que acabou de começar.

## Compilação

No Windows, execute:

```bat
makefile.bat
```

Em Linux, execute:

```bash
./build.sh
```

Os dois scripts montam `src/main.asm` e usam `nes-dpcm.cfg` na etapa de link. O resultado é a ROM `sound.nes`.

Ao modificar a configuração do linker, confirme sempre que:

- o segmento `DPCM` continua começando em `$C000`;
- os vetores permanecem em `$FFFA–$FFFF`;
- o tamanho declarado no cabeçalho iNES continua correspondendo à ROM gerada.
