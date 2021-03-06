@echo off

set APP=FDIMPLES

if not "%1" == "" goto %1
if not "%1" == "" goto Error
goto Start

:Fresh
:Clean
CALL CLEAN.BAT
%0 %2 %3 %4 %5 %6 %7 %8 %9
goto Done

:Start

set TPV=TP70
set ASM=NASM
set TPC=TPC
if exist %DOSDIR%\LINKS\%ASM%.BAT set ASM=call %ASM%
if exist %DOSDIR%\LINKS\%TPC%.BAT set TPC=call %TPC%

goto HaveEnglish

REM Create Embedded English Language Translation
type NLS\%APP%.EN | grep -iv "^;" | vstr /I/B/N >ENGLISH.TMP
set OUT=ENGLISH.INC
if exist %OUT% goto HaveEnglish
if not exist NLS\%APP%.EN goto NoEnglish

echo { Embedded English language translation messages }>%OUT%
echo procedure BuiltInEnglish; assembler;>>%OUT%
echo asm>>%OUT%
type %OUT%

SET COUNT=
:GetCount
type ENGLISH.TMP | vstr /N/L TOTAL | set /p COUNT=
if "%COUNT%" == "" goto GetCount
set LINE=0
set NEXT=
:REPEAT
vmath %LINE% + 1 | set /P NEXT=
if "%NEXT%" == "" goto REPEAT
:FETCH
set MESSAGE=
type ENGLISH.TMP | vstr /N/L %LINE% | set /p MESSAGE=
if "%MESSAGE%" == "" goto FETCH
echo   db '%MESSAGE%',0>>%OUT%
echo   db '%MESSAGE%',0
set LINE=%NEXT%
if "%LINE%" == "%COUNT%" goto COMPLETE
goto REPEAT
:COMPLETE
echo   db 0>>%OUT%
echo   db 0
echo end;>>%OUT%
echo end;
set LINE=
set COUNT=
set MESSAGE=
deltree /y ENGLISH.TMP
goto HaveEnglish
:NoEnglish
echo Unable to locate English Translations.

:HaveEnglish

:TPRetry
rem Make using TurboPascal 7.0

cd QCrt\PASCAL
call mkUnits.bat
cd ..\..
if errorlevel 1 goto Done
:UnitsMade

if not exist %APP%.EXE goto NoPrev
vstr /R 79 /c 0x2d

echo Previous Executable(s):
echo.
dir *.exe | grep -i exe
vstr /R 79 /c 0x2d
:NoPrev
%TPC% -M /OQCRT\PASCAL /UQCRT\PASCAL;..\%APP% /IQCRT\PASCAL;..\%APP% %APP%.PAS
if errorlevel 1 goto Done
vstr /R 79 /c 0x2d
dir *.exe | grep -i exe
rem goto Done

:Appinfo
if not exist APPINFO\NUL mkdir APPINFO >NUL
:Sticky1
date /d | vstr /n /f ' ' 5 /n | set /p NOW=
if "%NOW%" == "" goto Sticky1
:Sticky2
echo %NOW% | vstr /f '-' -2 /n | set /P MMDD=
if "%MMDD%" == "" goto Sticky2
:Sticky3
echo %NOW% | vstr /f '-' 3 /n | set /P YEAR=
if "%YEAR%" == "" goto Sticky3
set NOW=
:Sticky4
echo %YEAR%-%MMDD% | vstr /s ' ' '' /n | set /p NOW=
if "%NOW%" == "" goto Sticky4
set YEAR=
set MMDD=
:Sticky5
type version.inc | vstr /f "'" 2 | vstr /i /n | set /P VERSION=
if "%VERSION%" == "" goto Sticky5

type APPINFO.LSM | vstr /s $DATE$ "%NOW%" | vstr /s $VERSION$ "%VERSION%" /n >APPINFO\%APP%.LSM
set NOW=
set VERSION=
goto Done

:Error
echo Error
verrlvl 1

:Done
