#!/usr/bin/env bash

CA65="/opt/cc65/bin/ca65"
LD65="/opt/cc65/bin/ld65"
MESEN="$HOME/nes/Mesen"

set -e

"$CA65" src/main.asm -o main.o --debug-info
"$LD65" main.o -o collision.nes -t nes --dbgfile collision.dbg

echo
echo "Compilação concluída com sucesso!"

read -p "Executar no Mesen? (s/N): " resp

if [[ "$resp" =~ ^[sS]$|^[sS][iI][mM]$ ]]; then
    "$MESEN" collision.nes &
fi