ca65 src/main.asm -o main.o --debug-info
ld65 main.o -o move_player.nes -t nes --dbgfile move_player.dbg
pause
exit