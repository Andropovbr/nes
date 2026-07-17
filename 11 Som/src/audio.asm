; Configura e integra todo o audio do jogo com a engine FamiStudio.
; A engine e preparada para NTSC, efeitos sonoros, musica FDS e samples DPCM.
; Os indices, dados musicais e efeitos exportados sao incluidos antes da engine.
; O sample DPCM fica em um segmento proprio iniciado em $C000, conforme a APU exige.

FAMISTUDIO_CFG_EXTERNAL = 1                      ; Configura a constante FAMISTUDIO_CFG_EXTERNAL
.define FAMISTUDIO_CA65_ZP_SEGMENT   ZEROPAGE    ; Define um parametro usado durante a montagem
.define FAMISTUDIO_CA65_RAM_SEGMENT  BSS         ; Define um parametro usado durante a montagem
.define FAMISTUDIO_CA65_CODE_SEGMENT CODE        ; Define um parametro usado durante a montagem
FAMISTUDIO_CFG_NTSC_SUPPORT = 1                  ; Configura a constante FAMISTUDIO_CFG_NTSC_SUPPORT
FAMISTUDIO_CFG_PAL_SUPPORT  = 0                  ; Configura a constante FAMISTUDIO_CFG_PAL_SUPPORT
FAMISTUDIO_CFG_SFX_SUPPORT  = 1                  ; Configura a constante FAMISTUDIO_CFG_SFX_SUPPORT
FAMISTUDIO_CFG_SFX_STREAMS  = 1                  ; Configura a constante FAMISTUDIO_CFG_SFX_STREAMS
FAMISTUDIO_CFG_THREAD       = 1                  ; Configura a constante FAMISTUDIO_CFG_THREAD
FAMISTUDIO_CFG_DPCM_SUPPORT = 1                  ; Configura a constante FAMISTUDIO_CFG_DPCM_SUPPORT
FAMISTUDIO_DPCM_OFF         = $C000              ; Configura a constante FAMISTUDIO_DPCM_OFF
FAMISTUDIO_EXP_FDS           = 1                 ; Configura a constante FAMISTUDIO_EXP_FDS
FAMISTUDIO_USE_RELEASE_NOTES = 1                 ; Configura a constante FAMISTUDIO_USE_RELEASE_NOTES
FAMISTUDIO_USE_VOLUME_TRACK  = 1                 ; Configura a constante FAMISTUDIO_USE_VOLUME_TRACK
FAMISTUDIO_USE_PITCH_TRACK   = 1                 ; Configura a constante FAMISTUDIO_USE_PITCH_TRACK
SFX_STRINGS  = 0                                 ; Configura a constante SFX_STRINGS
SONG_STRINGS = 0                                 ; Configura a constante SONG_STRINGS
.include "../audio/sfx.inc"                      ; Inclui o modulo "../audio/sfx.inc"
.include "../audio/song.inc"                     ; Inclui o modulo "../audio/song.inc"
.include "../audio/sfx.s"                        ; Inclui o modulo "../audio/sfx.s"
.include "../audio/song.s"                       ; Inclui o modulo "../audio/song.s"
.include "../audio/famistudio_ca65.s"            ; Inclui o modulo "../audio/famistudio_ca65.s"
.segment "DPCM"                                  ; Seleciona o segmento "DPCM"
    .incbin "../audio/song.dmc"                  ; Inclui os dados binarios de "../audio/song.dmc"
.segment "CODE"                                  ; Seleciona o segmento "CODE"
