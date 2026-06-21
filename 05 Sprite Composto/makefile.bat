ca65 sprite_composto.asm -o sprite_composto.o --debug-info
ld65 sprite_composto.o -o sprite_composto.nes -t nes --dbgfile sprite_composto.dbg
pause
exit