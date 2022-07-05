@echo off
cd /d "%~dp1"
copy archdef.psm "..\%~nx1"
copy customasm_v0.11.14.exe "..\%~nx1"
cd "..\%~nx1"
customasm_v0.11.14 -o program.hex -f logisim16 archdef.psm main.psm
del archdef.psm
del customasm_v0.11.14.exe
move program.hex D:\Circuiting\Digital\Phinix\