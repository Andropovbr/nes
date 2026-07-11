@echo off

ca65 src/main.asm -o main.o --debug-info || goto :erro
ld65 main.o -o nametable.nes -t nes --dbgfile nametable.dbg || goto :erro

echo.
choice /C SN /N /M "Abrir no Mesen? [S/N] "
if errorlevel 2 exit

start "" "F:\Emuladores\NES\Mesen.exe" "nametable.nes"

exit

:erro
echo.
echo Erro na compilacao.
pause