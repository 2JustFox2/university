@echo off
setlocal
set "OLDPATH=%PATH%"
set "PATH=C:\Program Files\Microsoft MPI\Bin;%PATH%"

REM Adjust ORCA_EXE if your ORCA binary is in a different location
set "ORCA_EXE=D:\Orca\orca.exe"

for %%f in (neb_img*.inp) do (
  echo Running %%f
  "%ORCA_EXE%" "%%~ff"
  if ERRORLEVEL 1 (
    echo ORCA returned non-zero for %%f
    set "PATH=%OLDPATH%"
    exit /b 1
  )
)

endlocal
echo All done.
