; ============================================================
; AUDIO.ASM
; ============================================================
;
; Configura e integra a engine de áudio do FamiStudio ao jogo.
;
; Este arquivo é responsável por:
;
; - definir os recursos que serão habilitados na engine;
; - informar em quais segmentos ficarão o código e as variáveis;
; - incluir os dados exportados de músicas e efeitos sonoros;
; - incluir o código da engine FamiStudio;
; - posicionar os samples DPCM no segmento reservado para eles.
;
; As configurações precisam ser declaradas antes da inclusão do
; arquivo famistudio_ca65.s, pois elas determinam quais partes da
; engine serão montadas.
;
; ============================================================


; ============================================================
; CONFIGURAÇÃO GERAL DA ENGINE
; ============================================================
;
; Indica que as opções da engine serão configuradas externamente
; por este arquivo, em vez de usar as configurações padrão.
;
; ============================================================

FAMISTUDIO_CFG_EXTERNAL = 1


; ============================================================
; SEGMENTOS UTILIZADOS PELA ENGINE
; ============================================================
;
; Informa ao FamiStudio em quais segmentos do projeto devem ser
; armazenadas suas variáveis e seu código.
;
; Os nomes precisam corresponder aos segmentos definidos no
; arquivo de configuração do linker, como o nes.cfg.
;
; ============================================================

.define FAMISTUDIO_CA65_ZP_SEGMENT   ZEROPAGE
.define FAMISTUDIO_CA65_RAM_SEGMENT  BSS
.define FAMISTUDIO_CA65_CODE_SEGMENT CODE


; ============================================================
; PADRÃO DE VÍDEO
; ============================================================
;
; O NES possui diferenças de temporização entre NTSC e PAL.
;
; Esta demo foi configurada somente para NTSC, padrão utilizado
; pelos consoles americanos e japoneses.
;
; ============================================================

FAMISTUDIO_CFG_NTSC_SUPPORT = 1
FAMISTUDIO_CFG_PAL_SUPPORT  = 0


; ============================================================
; EFEITOS SONOROS
; ============================================================
;
; Habilita o sistema de efeitos sonoros da engine.
;
; Um stream significa que apenas um efeito sonoro será controlado
; por vez. Caso outro efeito seja iniciado, ele poderá substituir
; o efeito que já estiver tocando.
;
; ============================================================

FAMISTUDIO_CFG_SFX_SUPPORT = 1
FAMISTUDIO_CFG_SFX_STREAMS = 1


; ============================================================
; EXECUÇÃO SEGURA DA ENGINE
; ============================================================
;
; Habilita o modo thread-safe do FamiStudio.
;
; Essa opção permite que comandos como iniciar músicas e efeitos
; sejam chamados pelo código principal enquanto a atualização do
; áudio acontece durante a NMI.
;
; ============================================================

FAMISTUDIO_CFG_THREAD = 1


; ============================================================
; SAMPLES DPCM
; ============================================================
;
; Habilita o canal DPCM da APU, usado para reproduzir samples
; digitais exportados pelo FamiStudio.
;
; O endereço $C000 informa onde os dados DPCM começam na ROM.
; Esse endereço precisa ser compatível com o posicionamento do
; segmento DPCM definido no arquivo de configuração do linker.
;
; ============================================================

FAMISTUDIO_CFG_DPCM_SUPPORT = 1
FAMISTUDIO_DPCM_OFF         = $C000


; ============================================================
; EXPANSÃO DE ÁUDIO FDS
; ============================================================
;
; Habilita o suporte ao canal de áudio adicional do Famicom Disk
; System.
;
; Esta opção só é necessária quando a música utiliza instrumentos
; ou canais da expansão FDS.
;
; Em um projeto comum de NES sem áudio de expansão, esta opção
; normalmente deve permanecer desabilitada.
;
; ============================================================

FAMISTUDIO_EXP_FDS = 1


; ============================================================
; RECURSOS UTILIZADOS PELAS MÚSICAS
; ============================================================
;
; Habilita recursos adicionais utilizados pelos dados exportados
; pelo FamiStudio.
;
; RELEASE_NOTES:
; Permite que instrumentos controlem a fase de soltura da nota.
;
; VOLUME_TRACK:
; Permite alterações de volume ao longo da música.
;
; PITCH_TRACK:
; Permite alterações de afinação, como slides e vibratos.
;
; Essas opções precisam corresponder aos recursos utilizados no
; projeto exportado pelo FamiStudio.
;
; ============================================================

FAMISTUDIO_USE_RELEASE_NOTES = 1
FAMISTUDIO_USE_VOLUME_TRACK  = 1
FAMISTUDIO_USE_PITCH_TRACK   = 1


; ============================================================
; NOMES DE MÚSICAS E EFEITOS
; ============================================================
;
; Os arquivos exportados podem incluir strings com os nomes das
; músicas e dos efeitos sonoros.
;
; Como o jogo utiliza apenas os índices numéricos, essas strings
; são desabilitadas para economizar espaço na ROM.
;
; ============================================================

SFX_STRINGS  = 0
SONG_STRINGS = 0


; ============================================================
; ÍNDICES DAS MÚSICAS E DOS EFEITOS
; ============================================================
;
; Estes arquivos contêm constantes geradas pelo FamiStudio.
;
; Exemplos:
;
;   sfx_megamanhit
;   song_stage_2
;
; As constantes permitem iniciar músicas e efeitos utilizando
; nomes legíveis em vez de números fixos espalhados pelo código.
;
; ============================================================

.include "../audio/sfx.inc"
.include "../audio/song.inc"


; ============================================================
; DADOS MUSICAIS E EFEITOS SONOROS
; ============================================================
;
; Inclui os dados exportados pelo FamiStudio.
;
; O arquivo sfx.s contém os efeitos sonoros.
; O arquivo song.s contém as músicas e os instrumentos.
;
; Esses arquivos armazenam dados, mas não executam o áudio
; sozinhos. A reprodução será feita pela engine incluída abaixo.
;
; ============================================================

.include "../audio/sfx.s"
.include "../audio/song.s"


; ============================================================
; ENGINE DE ÁUDIO
; ============================================================
;
; Inclui a implementação da engine FamiStudio para o assembler
; ca65.
;
; As configurações declaradas anteriormente determinam quais
; recursos serão incluídos durante a montagem.
;
; ============================================================

.include "../audio/famistudio_ca65.s"


; ============================================================
; DADOS DPCM
; ============================================================
;
; Seleciona o segmento reservado aos samples DPCM e inclui
; diretamente o arquivo binário exportado pelo FamiStudio.
;
; Diferentemente dos arquivos .s, o arquivo .dmc já contém dados
; binários prontos, por isso é incluído com .incbin.
;
; O linker deverá posicionar este segmento a partir do endereço
; definido por FAMISTUDIO_DPCM_OFF.
;
; ============================================================

.segment "DPCM"

    .incbin "../audio/song.dmc"


; ============================================================
; RETORNO AO SEGMENTO DE CÓDIGO
; ============================================================
;
; Depois de incluir os samples, retorna ao segmento CODE para que
; as próximas rotinas do projeto continuem sendo armazenadas na
; área normal de código da ROM.
;
; ============================================================

.segment "CODE"
