@echo off
set PATH=C:\Program Files\Microsoft MPI\Bin;%PATH%
"D:\Orca\orca.exe" ts_inp_optTS_tight.inp > ts_inp_optTS_tight.out
exit /b %errorlevel%
