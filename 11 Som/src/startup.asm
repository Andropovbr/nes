.segment "STARTUP"                               ; Seleciona o segmento "STARTUP"
RESET:                                           ; Define o ponto de entrada RESET
    SEI                                          ; Desativa interrupcoes mascaraveis
    CLD                                          ; Desativa o modo decimal do processador
    LDX #$40                                     ; Carrega o valor no registrador X
    STX $4017                                    ; Armazena o registrador X no destino
    LDX #$FF                                     ; Carrega o valor no registrador X
    TXS                                          ; Define o ponteiro da pilha com o registrador X
    INX                                          ; Incrementa o registrador X
    STX $2000                                    ; Armazena o registrador X no destino
    STX $2001                                    ; Armazena o registrador X no destino
    STX $4010                                    ; Armazena o registrador X no destino
vblankwait1:                                     ; Define o ponto de entrada vblankwait1
    BIT $2002                                    ; Testa os bits do registrador indicado
    BPL vblankwait1                              ; Desvia quando o resultado anterior e positivo
clearmem:                                        ; Define o ponto de entrada clearmem
    LDA #$00                                     ; Carrega o valor no acumulador
    STA $0000, x                                 ; Armazena o acumulador no destino
    STA $0100, x                                 ; Armazena o acumulador no destino
    STA $0300, x                                 ; Armazena o acumulador no destino
    STA $0400, x                                 ; Armazena o acumulador no destino
    STA $0500, x                                 ; Armazena o acumulador no destino
    STA $0600, x                                 ; Armazena o acumulador no destino
    STA $0700, x                                 ; Armazena o acumulador no destino
    LDA #$FE                                     ; Carrega o valor no acumulador
    STA $0200, x                                 ; Armazena o acumulador no destino
    INX                                          ; Incrementa o registrador X
    BNE clearmem                                 ; Desvia quando o resultado anterior nao e zero
vblankwait2:                                     ; Define o ponto de entrada vblankwait2
    BIT $2002                                    ; Testa os bits do registrador indicado
    BPL vblankwait2                              ; Desvia quando o resultado anterior e positivo
    LDA #$01                                     ; Carrega o valor no acumulador
    LDX #<music_data_gyruss                      ; Carrega o valor no registrador X
    LDY #>music_data_gyruss                      ; Carrega o valor no registrador Y
    JSR famistudio_init                          ; Executa a rotina indicada
    LDX #<sounds                                 ; Carrega o valor no registrador X
    LDY #>sounds                                 ; Carrega o valor no registrador Y
    JSR famistudio_sfx_init                      ; Executa a rotina indicada
    LDA #song_stage_2                            ; Carrega o valor no acumulador
    JSR famistudio_music_play                    ; Executa a rotina indicada
    JSR load_palettes                            ; Executa a rotina indicada
    JSR clear_nametable                          ; Executa a rotina indicada
    JSR draw_background                          ; Executa a rotina indicada
    JSR load_bg_attributes                       ; Executa a rotina indicada
    JSR load_biker_sprite                        ; Executa a rotina indicada
    JSR initialize_game                          ; Executa a rotina indicada
enable_ppu:                                      ; Define o ponto de entrada enable_ppu
    LDA $2002                                    ; Carrega o valor no acumulador
    LDA #$00                                     ; Carrega o valor no acumulador
    STA $2005                                    ; Armazena o acumulador no destino
    STA $2005                                    ; Armazena o acumulador no destino
    JMP audio_already_initialized                ; Continua a execucao no rotulo indicado
    LDA #$01                                     ; Carrega o valor no acumulador
    LDX #<sounds                                 ; Carrega o valor no registrador X
    LDY #>sounds                                 ; Carrega o valor no registrador Y
    JSR famistudio_init                          ; Executa a rotina indicada
    LDX #<sounds                                 ; Carrega o valor no registrador X
    LDY #>sounds                                 ; Carrega o valor no registrador Y
    JSR famistudio_sfx_init                      ; Executa a rotina indicada
    LDA #$01                                     ; Carrega o valor no acumulador
    LDX #<music_data_gyruss                      ; Carrega o valor no registrador X
    LDY #>music_data_gyruss                      ; Carrega o valor no registrador Y
    JSR famistudio_init                          ; Executa a rotina indicada
    LDX #<sounds                                 ; Carrega o valor no registrador X
    LDY #>sounds                                 ; Carrega o valor no registrador Y
    JSR famistudio_sfx_init                      ; Executa a rotina indicada
audio_already_initialized:                       ; Define o ponto de entrada audio_already_initialized
    LDA #%10000000                               ; Carrega o valor no acumulador
    STA $2000                                    ; Armazena o acumulador no destino
    LDA #%00011110                               ; Carrega o valor no acumulador
    STA $2001                                    ; Armazena o acumulador no destino
    JMP forever                                  ; Continua a execucao no rotulo indicado
