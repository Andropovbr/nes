@echo off

ca65 src/main.asm -o main.o --debug-info || goto :erro
ld65 main.o -o sound.nes -t nes --dbgfile sound.dbg || goto :erro

echo.
choice /C SN /N /M "Abrir no Mesen? [S/N] "
if errorlevel 2 exit

start "" "F:\Emuladores\NES\Mesen.exe" "sound.nes"

exit

:erro
echo.
echo Erro na compilacao.
pause