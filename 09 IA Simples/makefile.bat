@echo off

ca65 src/main.asm -o main.o --debug-info || goto :erro
ld65 main.o -o simple_ai.nes -t nes --dbgfile simple_ai.dbg || goto :erro

echo.
choice /C SN /N /M "Abrir no Mesen? [S/N] "
if errorlevel 2 exit

start "" "F:\Emuladores\NES\Mesen.exe" "simple_ai.nes"

exit

:erro
echo.
echo Erro na compilacao.
pause