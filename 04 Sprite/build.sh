#!/usr/bin/env bash

CA65="/opt/cc65/bin/ca65"
LD65="/opt/cc65/bin/ld65"
MESEN="$HOME/nes/Mesen"

set -e

"$CA65" sprite.asm -o sprite.o --debug-info
"$LD65" sprite.o -o sprite.nes -t nes --dbgfile sprite.dbg

echo
echo "Compilação concluída com sucesso!"

read -p "Executar no Mesen? (s/N): " resp

if [[ "$resp" =~ ^[sS]$|^[sS][iI][mM]$ ]]; then
    "$MESEN" sprite.nes &
fi