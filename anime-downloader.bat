@echo off
setlocal EnableDelayedExpansion
title Anime Downloader

:: ============================================================
::  anime-downloader.bat  —  pkg-anime-1  launcher
::  Always calls OUR package directly via Python so no other
::  "anime" command on the system can interfere.
:: ============================================================

:MAIN_MENU
cls
echo.
echo  =========================================
echo   ANIME DOWNLOADER
echo  =========================================
echo.
echo   [1]  Download Anime
echo   [2]  Settings
echo   [3]  First-time Setup  (install / update)
echo   [4]  Exit
echo.
set /p CHOICE="  Choose (1-4): "

if "%CHOICE%"=="1" goto CHECK_READY
if "%CHOICE%"=="2" goto SETTINGS_MENU
if "%CHOICE%"=="3" goto SETUP
if "%CHOICE%"=="4" exit
goto MAIN_MENU


:: ============================================================
::  FIRST-TIME SETUP
:: ============================================================
:SETUP
cls
echo.
echo  =========================================
echo   SETUP
echo  =========================================
echo.

:: --- Check Python ---
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo  [!] Python is not installed or not in PATH.
    echo.
    echo  Opening the Python download page in your browser...
    echo  Install Python 3.11 or newer and tick "Add Python to PATH".
    echo  Then close this window and run the .bat again.
    echo.
    start https://www.python.org/downloads/
    pause
    exit
)
for /f "tokens=*" %%v in ('python --version 2^>^&1') do echo  [ok] %%v found.

:: --- Upgrade pip (show output so user knows it's working) ---
echo.
echo  [..] Upgrading pip...
python -m pip install --upgrade pip

:: --- Install pkg-anime-1 from TestPyPI, deps from real PyPI ---
echo.
echo  [..] Installing pkg-anime-1 and all dependencies...
echo      You will see each package being downloaded below:
echo.
python -m pip install ^
    --index-url https://test.pypi.org/simple/ ^
    --extra-index-url https://pypi.org/simple/ ^
    "pkg-anime-1==1.3.5" ^
    --upgrade

if %errorlevel% neq 0 (
    echo.
    echo  [ERROR] Installation failed. Check your internet and try again.
    pause
    goto MAIN_MENU
)
echo.
echo  [ok] pkg-anime-1 installed successfully.
echo.

:: --- Detect RAM via PowerShell (handles 16GB+ correctly) ---
call :DETECT_RAM
call :SUGGEST_THREADS

echo  Your PC has ~%RAM_GB% GB of RAM.
echo.
echo  Recommended thread counts:
echo    2 GB  RAM  ->  2  threads  (safe, slow)
echo    4 GB  RAM  ->  4  threads  (balanced)
echo    8 GB  RAM  ->  8  threads  (fast)
echo   16 GB  RAM  -> 16  threads  (very fast)
echo   32 GB+ RAM  -> 24  threads  (max speed)
echo.
echo  Suggested for your PC: %SUGGESTED_THREADS% threads
echo.
set /p THREADS_CHOICE="  Enter thread count (or press Enter for %SUGGESTED_THREADS%): "
if "%THREADS_CHOICE%"=="" set THREADS_CHOICE=%SUGGESTED_THREADS%
echo %THREADS_CHOICE%| findstr /r "^[0-9][0-9]*$" >nul
if %errorlevel% neq 0 (
    echo  [!] Not a number, using %SUGGESTED_THREADS%.
    set THREADS_CHOICE=%SUGGESTED_THREADS%
)
python -c "import sys; sys.argv=['anime','--set-threads','%THREADS_CHOICE%']; from anime_pahe.cli import main; main()" >nul 2>&1
echo  [ok] Threads set to %THREADS_CHOICE%.

:: --- Pick download folder via Windows dialog ---
echo.
echo  [..] Opening folder picker — choose where anime files are saved...
call :PICK_FOLDER
if not "!PICKED_FOLDER!"=="" (
    :: Write path to a temp file so Python reads it as raw text —
    :: avoids \t \n etc. being interpreted as escape sequences in -c strings
    echo !PICKED_FOLDER!>"%TEMP%\anime_dl_path.tmp"
    python -c "import sys,os; p=open(os.path.join(os.environ['TEMP'],'anime_dl_path.tmp')).read().strip(); sys.argv=['anime','--set-download-dir',p]; from anime_pahe.cli import main; main()" >nul 2>&1
    echo  [ok] Download folder: !PICKED_FOLDER!
) else (
    echo  [!] No folder selected. You can set one later in Settings.
)

echo.
echo  =========================================
echo   Setup complete! Starting download now...
echo  =========================================
echo.
timeout /t 2 /nobreak >nul
goto RUN_DOWNLOAD


:: ============================================================
::  DOWNLOAD
:: ============================================================
:CHECK_READY
python -m pip show pkg-anime-1 >nul 2>&1
if %errorlevel% neq 0 (
    cls
    echo.
    echo  [!] Not installed yet. Run option [3] First-time Setup first.
    echo.
    pause
    goto MAIN_MENU
)

:RUN_DOWNLOAD
cls
echo.
echo  Starting downloader...
echo  (A browser window may open briefly for Cloudflare — that is normal)
echo.
python -c "from anime_pahe.cli import main; main()"
echo.
pause
goto MAIN_MENU


:: ============================================================
::  SETTINGS MENU
:: ============================================================
:SETTINGS_MENU
cls
echo.
echo  =========================================
echo   SETTINGS
echo  =========================================
echo.
python -m pip show pkg-anime-1 >nul 2>&1
if %errorlevel% neq 0 (
    echo  [!] Not installed yet. Run option [3] First-time Setup first.
    pause
    goto MAIN_MENU
)
python -c "from anime_pahe.config import show_config; show_config()"
echo.
echo   [1]  Change download folder
echo   [2]  Change thread count
echo   [3]  Change video quality
echo   [4]  Change audio language
echo   [5]  Back
echo.
set /p SCHOICE="  Choose (1-5): "

if "%SCHOICE%"=="1" goto SET_FOLDER
if "%SCHOICE%"=="2" goto SET_THREADS
if "%SCHOICE%"=="3" goto SET_QUALITY
if "%SCHOICE%"=="4" goto SET_AUDIO
if "%SCHOICE%"=="5" goto MAIN_MENU
goto SETTINGS_MENU


:SET_FOLDER
echo.
echo  Opening folder picker...
call :PICK_FOLDER
if not "!PICKED_FOLDER!"=="" (
    echo !PICKED_FOLDER!>"%TEMP%\anime_dl_path.tmp"
    python -c "import sys,os; p=open(os.path.join(os.environ['TEMP'],'anime_dl_path.tmp')).read().strip(); sys.argv=['anime','--set-download-dir',p]; from anime_pahe.cli import main; main()" >nul 2>&1
    echo  [ok] Download folder updated to: !PICKED_FOLDER!
) else (
    echo  [!] No folder selected, no change made.
)
pause
goto SETTINGS_MENU


:SET_THREADS
echo.
call :DETECT_RAM
call :SUGGEST_THREADS
echo  Your PC has ~%RAM_GB% GB of RAM.
echo.
echo  Recommended thread counts:
echo    2 GB  RAM  ->  2  threads  (safe, slow)
echo    4 GB  RAM  ->  4  threads  (balanced)
echo    8 GB  RAM  ->  8  threads  (fast)
echo   16 GB  RAM  -> 16  threads  (very fast)
echo   32 GB+ RAM  -> 24  threads  (max speed)
echo.
echo  Suggested for your PC: %SUGGESTED_THREADS% threads
echo.
set /p NEW_THREADS="  Enter new thread count (or press Enter for %SUGGESTED_THREADS%): "
if "%NEW_THREADS%"=="" set NEW_THREADS=%SUGGESTED_THREADS%
echo %NEW_THREADS%| findstr /r "^[0-9][0-9]*$" >nul
if %errorlevel% neq 0 (
    echo  [!] Not a number, no change made.
    pause
    goto SETTINGS_MENU
)
python -c "import sys; sys.argv=['anime','--set-threads','%NEW_THREADS%']; from anime_pahe.cli import main; main()" >nul 2>&1
echo  [ok] Threads updated to %NEW_THREADS%.
pause
goto SETTINGS_MENU


:SET_QUALITY
echo.
echo   [1]  best  (highest available, auto per episode)
echo   [2]  1080p
echo   [3]  720p
echo   [4]  480p
echo   [5]  360p
echo.
set /p QCHOICE="  Choose (1-5): "
if "%QCHOICE%"=="1" python -c "import sys; sys.argv=['anime','--set-quality','best']; from anime_pahe.cli import main; main()" >nul 2>&1 & echo  [ok] Quality: best
if "%QCHOICE%"=="2" python -c "import sys; sys.argv=['anime','--set-quality','1080']; from anime_pahe.cli import main; main()" >nul 2>&1 & echo  [ok] Quality: 1080p
if "%QCHOICE%"=="3" python -c "import sys; sys.argv=['anime','--set-quality','720'];  from anime_pahe.cli import main; main()" >nul 2>&1 & echo  [ok] Quality: 720p
if "%QCHOICE%"=="4" python -c "import sys; sys.argv=['anime','--set-quality','480'];  from anime_pahe.cli import main; main()" >nul 2>&1 & echo  [ok] Quality: 480p
if "%QCHOICE%"=="5" python -c "import sys; sys.argv=['anime','--set-quality','360'];  from anime_pahe.cli import main; main()" >nul 2>&1 & echo  [ok] Quality: 360p
pause
goto SETTINGS_MENU


:SET_AUDIO
echo.
echo   [1]  jpn  (Japanese with subtitles)
echo   [2]  eng  (English dub)
echo.
set /p ACHOICE="  Choose (1-2): "
if "%ACHOICE%"=="1" python -c "import sys; sys.argv=['anime','--set-audio','jpn']; from anime_pahe.cli import main; main()" >nul 2>&1 & echo  [ok] Audio: Japanese (jpn)
if "%ACHOICE%"=="2" python -c "import sys; sys.argv=['anime','--set-audio','eng']; from anime_pahe.cli import main; main()" >nul 2>&1 & echo  [ok] Audio: English dub (eng)
pause
goto SETTINGS_MENU


:: ============================================================
::  HELPER — get total RAM in GB via PowerShell
::  (wmic set /a overflows for 16GB+ since bat math is 32-bit)
:: ============================================================
:DETECT_RAM
set RAM_GB=4
for /f %%r in ('powershell -NoProfile -Command "[math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)"') do (
    set RAM_GB=%%r
)
exit /b


:: ============================================================
::  HELPER — suggest threads from RAM
:: ============================================================
:SUGGEST_THREADS
set SUGGESTED_THREADS=4
if %RAM_GB% leq 2  set SUGGESTED_THREADS=2
if %RAM_GB% geq 4  set SUGGESTED_THREADS=4
if %RAM_GB% geq 8  set SUGGESTED_THREADS=8
if %RAM_GB% geq 16 set SUGGESTED_THREADS=16
if %RAM_GB% geq 32 set SUGGESTED_THREADS=24
exit /b


:: ============================================================
::  HELPER — Windows folder picker via PowerShell
::           result stored in PICKED_FOLDER
:: ============================================================
:PICK_FOLDER
set PICKED_FOLDER=
for /f "usebackq delims=" %%p in (`powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; $d = New-Object System.Windows.Forms.FolderBrowserDialog; $d.Description = 'Select your anime download folder'; $d.RootFolder = 'MyComputer'; if ($d.ShowDialog() -eq 'OK') { Write-Output $d.SelectedPath }"`) do (
    set "PICKED_FOLDER=%%p"
)
exit /b
