@echo off
setlocal
setlocal EnableDelayedExpansion

SET PATH=%PATH%;%~dp0\Tools;%~dp0\Tools\ACC;%~dp0\Tools\GDCC
set GIT=None
set WorkingCopyPath=%~dp0
set REVISIONNUMBER=Unknown

for /f "tokens=1-2*" %%A in ('reg query HKEY_LOCAL_MACHINE\Software\GitForWindows /v InstallPath ^| find "REG_SZ"') do (
	set GIT=%%C
	set "PATH=!GIT!\bin;%PATH%"
)

if exist "!GIT!\bin\git.exe" (
	echo Found Git at !GIT!
	goto GITFOUND
) else (
	echo GIT NOT FOUND^^!
	goto MENU
)

:GITFOUND
echo ---------------------------
echo Retrieving GIT Commit Count
echo ---------------------------
for /f "delims=" %%i in ('git rev-list HEAD --count') do ( 
	set "REVISIONNUMBER=%%i"
)

:MENU
SET BUILD_TYPE=0
cd /d %~dp0
cls

chgcolor 0a
echo 浜様様様様様様様様様様様様様様様様様融
echoj $ba
chgcolor 0f
echoj " Simply Hard                        "
chgcolor 0a
echoj $ba $0a
echoj $ba
chgcolor 0f
echoj " Development and GIT Build Compiler "
chgcolor 0a
echoj $ba $0a
echo 藩様様様様様様様様様様様様様様様様様夕

chgcolor 07
echo.
echoj "Current Path Is: "
chgcolor 0b
echo %~dp0
chgcolor 07
echoj "Current GIT Revision: "
chgcolor 0c
echo %REVISIONNUMBER%
echo.
chgcolor 0f
echoj "1. "
chgcolor 0e
echo Development Build
chgcolor 0f
echoj "2. "
chgcolor 06
echo Release Build
chgcolor 0f
echoj "3. "
chgcolor 02
echo Refresh GIT Revision
chgcolor 0f
echoj "4. "
chgcolor 04
echo Compile ACS Scripts
chgcolor 0f
echoj "5. "
chgcolor 03
echo Quit
chgcolor 07

echo.
CHOICE /C 12345 /N /M "Choose Option (Number Keys):"
IF ERRORLEVEL 5 GOTO LEAVE
IF ERRORLEVEL 4 GOTO COMPILEACS
IF ERRORLEVEL 3 GOTO GITFOUND
IF ERRORLEVEL 2 GOTO RELEASEBUILD
IF ERRORLEVEL 1 GOTO DEVBUILD

:DEVBUILD
SET BUILD_TYPE=1
GOTO COMPILEACS

:DEVBUILD_CONTINUED
echo Compiling Simply Hard Dev Build...
cd /d %~dp0
del .\builds\Simply-Hard_DEV.pk3 /q
del .\pk3\*.tmp /q
move /Y .\pk3\*.bak .\backups >nul 2>&1

cd pk3
7za a -y -tzip -mx=0 -mmt -xr^^!.GIT -xr^^!*.dbs -xr^^!*.tmp -xr^^!*.backup* ..\builds\Simply-Hard_DEV.pk3 .\

pause
goto MENU

:RELEASEBUILD
SET BUILD_TYPE=2
GOTO COMPILEACS

:RELEASEBUILD_CONTINUED
echo Compiling Simply Hard Release Rev#: %REVISIONNUMBER% (Full Compression)...
cd /d %~dp0
del .\builds\Simply-Hard_r%REVISIONNUMBER%.pk3 /q
move /Y .\pk3\*.bak .\backups >nul 2>&1

cd pk3
7za a -y -tzip -mx=9 -mmt -xr^^!.GIT -xr^^!*.dbs -xr^^!*.backup* -xr^^!*.tmp ..\builds\Simply-Hard_r%REVISIONNUMBER%.pk3 .\

pause
goto MENU

:COMPILEACS
cd pk3
cd ACS
del *.err
del *.o
echo Compiling ACS Scripts...
for %%f in (*.acs) do (
	echo %%~nf
	acc.exe "%%~nf.acs" "%%~nf.o" 1>nul 2>%%~nf.err
	if ERRORLEVEL 1 (
		type %%~nf.err
	) else (
		del %%~nf.err
	)
)

echo Compiling ACSX Scripts...
for %%f in (*.acsx) do (
	echo %%~nf
	gdcc-acc.exe "%%~nf.acsx" "%%~nf.o" 1>nul 2>%%~nf.err
	if ERRORLEVEL 1 (
		type %%~nf.err
	) else (
		del %%~nf.err
	)
)

if %BUILD_TYPE% == 2 (
	GOTO RELEASEBUILD_CONTINUED
) else if %BUILD_TYPE% == 1 (
	GOTO DEVBUILD_CONTINUED
)

pause
goto MENU

:LEAVE
cls
echo.
chgcolor 0a
echo Thanks for trying Simply Hard! - Fiendzy
echo Build Batch written by Striker The Hedgefox.
chgcolor 0b
echo Found any bugs? E-Mail Striker at mossj32@gmail.com
chgcolor 0e
timeout 5