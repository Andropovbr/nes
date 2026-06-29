ca65 sprite.asm -o sprite.o --debug-info
ld65 sprite.o -o sprite.nes -t nes --dbgfile sprite.dbg
pause
exit