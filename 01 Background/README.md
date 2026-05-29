# NES Demo 01 - ROM Mínima com Inicialização do Hardware

Este projeto é um estudo introdutório de desenvolvimento para Nintendo Entertainment System (NES) utilizando Assembly 6502 e a ferramenta ca65.

O objetivo desta ROM é demonstrar a estrutura mínima necessária para inicializar corretamente o hardware do NES, configurar a CPU e a PPU e gerar uma ROM funcional que pode ser executada em emuladores ou hardware real.

## O que esta ROM faz

Ao iniciar, o programa:

* Define um cabeçalho iNES válido
* Inicializa a CPU
* Configura a stack
* Desabilita interrupções durante o boot
* Aguarda a estabilização da PPU
* Limpa a RAM interna do NES
* Limpa a memória de paletas da PPU
* Configura uma tonalidade azul através do PPUMASK
* Entra em um loop infinito

Como ainda não existem tiles, sprites ou lógica de jogo, o resultado visual é apenas uma tela vazia.

## Conceitos abordados

Este exemplo apresenta diversos conceitos fundamentais da arquitetura do NES:

* Estrutura de uma ROM iNES
* Segmentos do ca65
* Vetores de interrupção
* Processo de RESET
* Registradores da PPU
* VBLANK
* Limpeza da RAM
* Paletas de cores
* Loop principal
* Rotinas NMI e IRQ

## Estrutura do código

### HEADER

Contém o cabeçalho iNES utilizado pelos emuladores para identificar e carregar a ROM.

### ZEROPAGE

Área reservada para variáveis de acesso rápido.

### STARTUP

Contém toda a rotina de inicialização do console.

### CODE

Contém o loop principal e as rotinas de interrupção.

### VECTORS

Tabela utilizada pelo processador para localizar as rotinas de RESET, NMI e IRQ.

### CHARS

Área reservada para os dados gráficos (CHR ROM).

## Compilação

Este projeto utiliza a suíte cc65.

Exemplo:

```bash
ca65 background.asm -o background.o
ld65 background.o -C nes.cfg -o background.nes
```

## Execução

A ROM pode ser executada em qualquer emulador compatível com NES, como:

* Mesen
* FCEUX
* Nestopia

## Próximos passos

Os próximos exemplos desta série irão abordar:

1. Alteração de cores da paleta
2. Escrita na VRAM da PPU
3. Exibição de tiles
4. Exibição de sprites
5. Leitura do controle
6. Movimentação de objetos na tela
7. Estrutura básica de um game loop

## Referências

* Nerdy Nights
* NESDev Wiki
* cc65 Documentation

---

Projeto criado como parte de uma jornada de aprendizado e documentação sobre desenvolvimento para o Nintendo Entertainment System (NES).
