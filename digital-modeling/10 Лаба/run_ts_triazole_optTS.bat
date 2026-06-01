@echo off
set PATH=C:\Program Files\Microsoft MPI\Bin;%PATH%
"D:\Orca\orca.exe" "C:\Users\alexv\OneDrive\projects\labs\digital-modeling\10 Лаба\ts_triazole_optTS.inp" > ts_triazole_optTS.out
exit /b %errorlevel%
