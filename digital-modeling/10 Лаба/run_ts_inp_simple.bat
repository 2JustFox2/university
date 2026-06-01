@echo off
set PATH=C:\Program Files\Microsoft MPI\Bin;%PATH%
"D:\Orca\orca.exe" ts_inp_simple.inp > ts_inp_simple.out
exit /b %errorlevel%
