#!/usr/bin/env bash

CA65="/opt/cc65/bin/ca65"
LD65="/opt/cc65/bin/ld65"
MESEN="$HOME/nes/Mesen"

set -e

"$CA65" sprite_composto.asm -o sprite_composto.o --debug-info
"$LD65" sprite_composto.o -o sprite_composto.nes -t nes --dbgfile sprite_composto.dbg

echo
echo "Compilação concluída com sucesso!"

read -p "Executar no Mesen? (s/N): " resp

if [[ "$resp" =~ ^[sS]$|^[sS][iI][mM]$ ]]; then
    "$MESEN" sprite_composto.nes &
fi