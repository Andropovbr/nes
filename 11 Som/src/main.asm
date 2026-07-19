; ============================================================
; MAIN.ASM
; ============================================================
;
; Arquivo principal do projeto.
;
; Este arquivo reúne todos os módulos que formam a ROM.
;
; Como o projeto utiliza .include, o assembler trata o conteúdo
; dos arquivos incluídos como se tudo estivesse escrito neste
; mesmo arquivo.
;
; A ordem das inclusões é importante, principalmente quando um
; módulo depende de constantes, variáveis, dados ou rotinas
; declaradas anteriormente.
;
; ============================================================


; ============================================================
; MAPA DE MEMÓRIA
; ============================================================
;
; Declara variáveis, segmentos e endereços utilizados pelo jogo.
;
; Este arquivo precisa aparecer antes dos módulos que acessam
; essas variáveis.
;
; ============================================================

.include "memory_layout.asm"


; ============================================================
; INICIALIZAÇÃO
; ============================================================
;
; Contém a rotina RESET e a preparação inicial da CPU, da PPU,
; da memória e dos demais sistemas do NES.
;
; ============================================================

.include "startup.asm"


; ============================================================
; FLUXO PRINCIPAL DA PARTIDA
; ============================================================
;
; Inicializa o estado do jogo e executa o loop principal.
;
; Também coordena movimento, colisões, fim de partida e reinício.
;
; ============================================================

.include "game_flow.asm"


; ============================================================
; ÁUDIO
; ============================================================
;
; Configura a engine FamiStudio e inclui os dados de músicas,
; efeitos sonoros e samples DPCM.
;
; ============================================================

.include "audio.asm"


; ============================================================
; PPU E BACKGROUND
; ============================================================
;
; Contém as rotinas de configuração da PPU, carregamento da
; nametable, atributos e demais dados visuais de background.
;
; ============================================================

.include "ppu.asm"


; ============================================================
; CONTROLE
; ============================================================
;
; Lê o controle 1 e identifica quais botões estão pressionados
; ou foram acionados no frame atual.
;
; ============================================================

.include "controller.asm"


; ============================================================
; COLISÕES
; ============================================================
;
; Contém as verificações de colisão entre:
;
;   - jogador e cerca;
;   - jogador e inimigo;
;   - projétil e inimigo.
;
; ============================================================

.include "collision.asm"


; ============================================================
; JOGADOR
; ============================================================
;
; Controla movimento, direção, animação e atualização do sprite
; composto do jogador.
;
; ============================================================

.include "player.asm"


; ============================================================
; INIMIGO
; ============================================================
;
; Controla a perseguição, animação, direção e atualização do
; sprite composto do inimigo.
;
; ============================================================

.include "enemy.asm"


; ============================================================
; PROJÉTIL
; ============================================================
;
; Controla criação, movimento, direção, desativação e atualização
; visual do projétil.
;
; ============================================================

.include "projectile.asm"


; ============================================================
; PALETAS
; ============================================================
;
; Contém os dados de cores utilizados pelos backgrounds e pelos
; sprites.
;
; ============================================================

.include "palettes.asm"


; ============================================================
; DADOS DO SPRITE DO JOGADOR
; ============================================================
;
; Contém a tabela inicial do sprite composto do personagem.
;
; ============================================================

.include "biker.asm"


; ============================================================
; INTERRUPÇÕES, VETORES E CHR
; ============================================================
;
; Contém:
;
;   - rotina NMI;
;   - rotina IRQ;
;   - vetores de interrupção;
;   - inclusão dos dados gráficos da CHR ROM.
;
; Este módulo fica por último porque contém os segmentos finais
; da ROM, incluindo VECTORS e CHARS.
;
; ============================================================

.include "interrupts.asm"
