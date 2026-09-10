@echo off
setlocal EnableDelayedExpansion
title Anime Downloader
:: ============================================================
::  anime-downloader.bat  --  launcher for pkg-anime-1 / anime_pahe
::
::  PUBLISHER / PROVENANCE
::    Publisher : YOUR-NAME-HERE
::    Source    : https://github.com/YOUR-USERNAME/YOUR-REPO
::    Launcher  : 1.1.0
::    License   : MIT
::
::  THIS FILE CONTAINS NO DOWNLOAD LOGIC.
::  It installs and runs the Python package anime_pahe, and it
::  prints the exact install command on screen before running
::  it. Read the whole file before you run it - it is about 500
::  lines, most of which is menu text.
::
::  Option [4] on the menu shows this same information at runtime.
:: ============================================================


:: ============================================================
::  EDIT THIS BLOCK - the only place you need to change.
::  Do not put < > or other redirection characters in these
::  values: they are echoed on screen.
:: ============================================================
set "PUBLISHER=YOUR-NAME-HERE"
set "REPO_URL=https://github.com/YOUR-USERNAME/YOUR-REPO"
set "LAUNCHER_VERSION=1.1.0"
set "LICENSE_NAME=MIT"

set "PKG_NAME=pkg-anime-1"
set "PKG_VERSION=1.3.5"

:: Where the downloader package comes from.
:: NOTE: TestPyPI is a TESTING index - its releases get purged.
:: To move to a real release, replace PKG_SOURCE_ARGS with
:: nothing and point PKG_SPEC at a wheel URL, e.g.
::   set "PKG_SPEC=https://github.com/YOUR-USERNAME/YOUR-REPO/releases/download/v1.4.0/pkg_anime_1-1.4.0-py3-none-any.whl"
:: or install straight from the repo:
::   set "PKG_SPEC=git+https://github.com/YOUR-USERNAME/YOUR-REPO.git@v1.4.0"
set "PKG_SPEC=%PKG_NAME%==%PKG_VERSION%"
set "PKG_SOURCE_ARGS=--index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple/"
:: ============================================================


:MAIN_MENU
cls
echo.
echo  =========================================
echo   ANIME DOWNLOADER
echo  =========================================
echo.
echo   Publisher : %PUBLISHER%
echo   Version   : %LAUNCHER_VERSION%
echo.
echo   [1]  Download Anime
echo   [2]  Settings
echo   [3]  First-time Setup  (install / update)
echo   [4]  About / Verify this tool
echo   [5]  Exit
echo.
set /p "CHOICE=  Choose (1-5): "

if "%CHOICE%"=="1" goto CHECK_READY
if "%CHOICE%"=="2" goto SETTINGS_MENU
if "%CHOICE%"=="3" goto SETUP
if "%CHOICE%"=="4" goto ABOUT
if "%CHOICE%"=="5" goto GOODBYE
goto MAIN_MENU


:: ============================================================
::  ABOUT / VERIFY
::  Shown so anyone can see who published this, where it came
::  from, and exactly what it will install - without reading
::  the whole file.
:: ============================================================
:ABOUT
cls
echo.
echo  =========================================
echo   ABOUT / VERIFY
echo  =========================================
echo.
echo   Launcher   : anime-downloader.bat v%LAUNCHER_VERSION%
echo   Publisher  : %PUBLISHER%
echo   Source     : %REPO_URL%
echo   License    : %LICENSE_NAME%
echo.
echo   ---------------------------------------------------------
echo   WHAT THIS LAUNCHER INSTALLS
echo   ---------------------------------------------------------
echo   Package    : %PKG_NAME%  version %PKG_VERSION%
echo   Index      : TestPyPI (a TESTING index) + PyPI for deps
echo   Where it goes : your Python installation
echo.
echo   The downloader logic is NOT stored in this .bat file.
echo   It lives in the Python package named above. The full
echo   install command is printed during First-time Setup and
echo   you must confirm it before anything is downloaded.
echo.
echo   ---------------------------------------------------------
echo   HOW TO CHECK OR REMOVE IT
echo   ---------------------------------------------------------
echo   Installed version : python -m pip show %PKG_NAME%
echo   Uninstall         : python -m pip uninstall %PKG_NAME%
echo   Settings file     : shown by Settings (menu option 2)
echo   Launcher source   : %REPO_URL%
echo.
echo   TestPyPI caveat: TestPyPI is run by the Python project
echo   for testing and its releases ARE periodically deleted.
echo   If installation fails for no clear reason, that is the
echo   most likely cause - report it at the source URL above.
echo.
pause
goto MAIN_MENU


:: ============================================================
::  FIRST-TIME SETUP / UPDATE
:: ============================================================
:SETUP
cls
echo.
echo  =========================================
echo   FIRST-TIME SETUP
echo  =========================================
echo.
echo   Publisher : %PUBLISHER%
echo   Source    : %REPO_URL%
echo.

:: --- Check Python is present at all ---
where python >nul 2>&1
if errorlevel 1 goto NO_PYTHON

:: --- Check Python is 3.11 or newer ---
:: This also catches the Microsoft Store "python" alias, which
:: exists on a clean Windows 11 machine but is not real Python.
python -c "import sys; sys.exit(0 if sys.version_info >= (3,11) else 1)" 2>nul
if errorlevel 1 goto BAD_PYTHON

for /f "tokens=*" %%v in ('python --version 2^>^&1') do echo  [ok] %%v found.
echo.

:: --- Show the exact command, then ask ---
echo  This setup will run exactly this command:
echo.
echo    python -m pip install --upgrade pip
echo    python -m pip install %PKG_SOURCE_ARGS% "%PKG_SPEC%"
echo.
echo  Read before you agree:
echo    - The downloader package comes from TestPyPI, a TESTING
echo      index, not the production one.
echo    - --extra-index-url also allows pypi.org, which is needed
echo      for dependencies but is also the "dependency confusion"
echo      pattern. Both indexes are shown above so you can see
echo      them rather than take them on trust.
echo    - Nothing is downloaded until you type Y below.
echo.
set "CONFIRM="
set /p "CONFIRM=  Type Y to install, or N to go back: "
if /i not "%CONFIRM%"=="Y" goto MAIN_MENU
echo.

:: --- Upgrade pip ---
echo  [..] Upgrading pip...
python -m pip install --upgrade pip
echo.

:: --- Install the downloader ---
echo  [..] Installing %PKG_NAME% %PKG_VERSION%...
echo      Each package will be listed as it downloads.
echo.
python -m pip install %PKG_SOURCE_ARGS% "%PKG_SPEC%" --upgrade
if errorlevel 1 goto INSTALL_FAILED
echo.
echo  [ok] %PKG_NAME% %PKG_VERSION% installed.
echo.

:: --- Detect RAM and suggest threads ---
call :DETECT_RAM
call :SUGGEST_THREADS

echo  Your PC has about %RAM_GB% GB of RAM.
echo.
echo  Recommended thread counts:
echo    2 GB  RAM  -^>  2  threads  (safe, slow)
echo    4 GB  RAM  -^>  4  threads  (balanced)
echo    8 GB  RAM  -^>  8  threads  (fast)
echo   16 GB  RAM  -^> 16  threads  (very fast)
echo   32 GB+ RAM  -^> 24  threads  (max speed)
echo.
echo  Suggested for your PC: %SUGGESTED_THREADS% threads
echo.
set "THREADS_CHOICE="
set /p "THREADS_CHOICE=  Enter thread count, or press Enter for %SUGGESTED_THREADS%: "
if "%THREADS_CHOICE%"=="" set "THREADS_CHOICE=%SUGGESTED_THREADS%"
echo %THREADS_CHOICE%| findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 set "THREADS_CHOICE=%SUGGESTED_THREADS%"

python -c "import sys; sys.argv=['anime','--set-threads','%THREADS_CHOICE%']; from anime_pahe.cli import main; main()"
if errorlevel 1 (echo  [ERROR] Could not save the thread count. You can set it later in Settings. & goto PICK_DOWNLOAD_FOLDER)
echo  [ok] Threads set to %THREADS_CHOICE%.

:: --- Choose the download folder ---
:PICK_DOWNLOAD_FOLDER
echo.
echo  [..] Opening the folder picker - choose where anime files are saved...
call :PICK_FOLDER
if "%PICKED_FOLDER%"=="" goto NO_FOLDER
python -c "import sys,os; p=open(os.path.join(os.environ['TEMP'],'anime_dl_path.tmp')).read().strip(); sys.argv=['anime','--set-download-dir',p]; from anime_pahe.cli import main; main()"
if errorlevel 1 (echo  [ERROR] Could not save the download folder. You can set it later in Settings. & goto SETUP_DONE)
echo  [ok] Download folder set to "%PICKED_FOLDER%"
goto SETUP_DONE

:NO_FOLDER
echo  No folder selected. You can set one later in Settings.

:SETUP_DONE
echo.
echo  =========================================
echo   Setup complete. Starting the downloader...
echo  =========================================
echo.
timeout /t 2 /nobreak >nul
goto RUN_DOWNLOAD


:: ============================================================
::  DOWNLOAD
:: ============================================================
:CHECK_READY
python -m pip show %PKG_NAME% >nul 2>&1
if errorlevel 1 goto NOT_INSTALLED
goto RUN_DOWNLOAD

:NOT_INSTALLED
cls
echo.
echo  =========================================
echo   NOT INSTALLED YET
echo  =========================================
echo.
echo   %PKG_NAME% is not installed in your Python.
echo.
echo   Run menu option [3] First-time Setup first.
echo   That screen shows you exactly what will be
echo   installed, from which index, before it runs.
echo.
pause
goto MAIN_MENU

:RUN_DOWNLOAD
cls
echo.
echo  Starting the downloader...
echo.
echo  A browser window may open briefly for Cloudflare.
echo  That is normal - the downloader is solving the
echo  challenge for you instead of asking you to copy
echo  a cookie by hand.
echo.
echo  Press Ctrl+C to stop at any time.
echo.
python -c "from anime_pahe.cli import main; main()"
if errorlevel 1 echo.
if errorlevel 1 echo  [ERROR] The downloader exited with an error. Scroll up for the reason.
echo.
pause
goto MAIN_MENU


:: ============================================================
::  SETTINGS
:: ============================================================
:SETTINGS_MENU
cls
echo.
echo  =========================================
echo   SETTINGS
echo  =========================================
echo.
python -m pip show %PKG_NAME% >nul 2>&1
if errorlevel 1 goto NOT_INSTALLED

echo  Current settings:
echo.
python -c "from anime_pahe.config import show_config; show_config()"
echo.
echo   [1]  Change download folder
echo   [2]  Change thread count
echo   [3]  Change video quality
echo   [4]  Change audio language
echo   [5]  Back
echo.
set /p "SCHOICE=  Choose (1-5): "

if "%SCHOICE%"=="1" goto SET_FOLDER
if "%SCHOICE%"=="2" goto SET_THREADS
if "%SCHOICE%"=="3" goto SET_QUALITY
if "%SCHOICE%"=="4" goto SET_AUDIO
if "%SCHOICE%"=="5" goto MAIN_MENU
goto SETTINGS_MENU


:SET_FOLDER
echo.
echo  Opening the folder picker...
call :PICK_FOLDER
if "%PICKED_FOLDER%"=="" (echo  No folder selected, no change made. & pause & goto SETTINGS_MENU)
python -c "import sys,os; p=open(os.path.join(os.environ['TEMP'],'anime_dl_path.tmp')).read().strip(); sys.argv=['anime','--set-download-dir',p]; from anime_pahe.cli import main; main()"
if errorlevel 1 (echo  [ERROR] Could not save the folder. & pause & goto SETTINGS_MENU)
echo  [ok] Download folder updated to "%PICKED_FOLDER%"
pause
goto SETTINGS_MENU


:SET_THREADS
echo.
call :DETECT_RAM
call :SUGGEST_THREADS
echo  Your PC has about %RAM_GB% GB of RAM.
echo  Suggested for your PC: %SUGGESTED_THREADS% threads
echo.
set "NEW_THREADS="
set /p "NEW_THREADS=  Enter new thread count, or press Enter for %SUGGESTED_THREADS%: "
if "%NEW_THREADS%"=="" set "NEW_THREADS=%SUGGESTED_THREADS%"
echo %NEW_THREADS%| findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 (echo  [ERROR] Not a number, no change made. & pause & goto SETTINGS_MENU)
python -c "import sys; sys.argv=['anime','--set-threads','%NEW_THREADS%']; from anime_pahe.cli import main; main()"
if errorlevel 1 (echo  [ERROR] Could not save the thread count. & pause & goto SETTINGS_MENU)
echo  [ok] Threads updated to %NEW_THREADS%.
pause
goto SETTINGS_MENU


:SET_QUALITY
echo.
echo   [1]  best  (highest available, chosen per episode)
echo   [2]  1080p
echo   [3]  720p
echo   [4]  480p
echo   [5]  360p
echo.
set "QCHOICE="
set /p "QCHOICE=  Choose (1-5): "
set "QVAL="
if "%QCHOICE%"=="1" set "QVAL=best"
if "%QCHOICE%"=="2" set "QVAL=1080"
if "%QCHOICE%"=="3" set "QVAL=720"
if "%QCHOICE%"=="4" set "QVAL=480"
if "%QCHOICE%"=="5" set "QVAL=360"
if "%QVAL%"=="" (echo  [ERROR] Invalid choice, no change made. & pause & goto SETTINGS_MENU)
python -c "import sys; sys.argv=['anime','--set-quality','%QVAL%']; from anime_pahe.cli import main; main()"
if errorlevel 1 (echo  [ERROR] Could not save the video quality. & pause & goto SETTINGS_MENU)
echo  [ok] Quality set to %QVAL%.
pause
goto SETTINGS_MENU


:SET_AUDIO
echo.
echo   [1]  jpn  (Japanese with subtitles)
echo   [2]  eng  (English dub)
echo.
set "ACHOICE="
set /p "ACHOICE=  Choose (1-2): "
set "AVAL="
if "%ACHOICE%"=="1" set "AVAL=jpn"
if "%ACHOICE%"=="2" set "AVAL=eng"
if "%AVAL%"=="" (echo  [ERROR] Invalid choice, no change made. & pause & goto SETTINGS_MENU)
python -c "import sys; sys.argv=['anime','--set-audio','%AVAL%']; from anime_pahe.cli import main; main()"
if errorlevel 1 (echo  [ERROR] Could not save the audio language. & pause & goto SETTINGS_MENU)
echo  [ok] Audio set to %AVAL%.
pause
goto SETTINGS_MENU


:GOODBYE
cls
echo.
echo  Thanks for using Anime Downloader.
echo  Publisher : %PUBLISHER%
echo  Source    : %REPO_URL%
echo.
if not "%PKG_NAME%"=="" echo  Uninstall : python -m pip uninstall %PKG_NAME%
echo.
timeout /t 3 /nobreak >nul
exit /b 0


:: ============================================================
::  ERROR HANDLERS
:: ============================================================
:NO_PYTHON
cls
echo.
echo  =========================================
echo   PYTHON NOT FOUND
echo  =========================================
echo.
echo   Python is not installed, or is not on your PATH.
echo.
echo   Opening the Python download page...
echo   1. Install Python 3.11 or newer.
echo   2. Tick "Add Python to PATH" on the first screen
echo      of the installer - this step is not optional.
echo   3. Close this window and run the .bat again.
echo.
start https://www.python.org/downloads/
pause
goto MAIN_MENU


:BAD_PYTHON
cls
echo.
echo  =========================================
echo   WRONG PYTHON VERSION
echo  =========================================
echo.
echo   Python was found, but it is older than 3.11
echo   or it is the Microsoft Store placeholder
echo   that ships with Windows.
echo.
echo   Install Python 3.11 or newer from python.org
echo   and tick "Add Python to PATH".
echo.
pause
goto MAIN_MENU


:INSTALL_FAILED
cls
echo.
echo  =========================================
echo   INSTALLATION FAILED
echo  =========================================
echo.
echo   The pip install command above did not complete.
echo.
echo   Two things to try, in this order:
echo.
echo   1. Check your internet connection, then run
echo      First-time Setup again.
echo   2. If it fails the same way every time, the
echo      package may have been removed from TestPyPI
echo      - releases there are deleted periodically.
echo      Report it at the source URL shown below.
echo.
echo   Source : %REPO_URL%
echo.
pause
goto MAIN_MENU


:: ============================================================
::  HELPER - total RAM in GB, read via PowerShell CIM.
::  wmic is deprecated and batch set /a does 32-bit signed
::  maths, so it overflows on large-RAM machines. This does
::  not.
:: ============================================================
:DETECT_RAM
set "RAM_GB=4"
for /f %%r in ('powershell -NoProfile -Command "[math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)"') do set "RAM_GB=%%r"
exit /b


:: ============================================================
::  HELPER - suggest a thread count from the RAM figure
:: ============================================================
:SUGGEST_THREADS
set "SUGGESTED_THREADS=4"
if %RAM_GB% leq 2  set "SUGGESTED_THREADS=2"
if %RAM_GB% geq 4  set "SUGGESTED_THREADS=4"
if %RAM_GB% geq 8  set "SUGGESTED_THREADS=8"
if %RAM_GB% geq 16 set "SUGGESTED_THREADS=16"
if %RAM_GB% geq 32 set "SUGGESTED_THREADS=24"
exit /b


:: ============================================================
::  HELPER - native Windows folder picker, result in
::  PICKED_FOLDER.
::
::  The picker itself writes the chosen path to
::  %TEMP%\anime_dl_path.tmp so nothing has to be echoed into
::  a file. Paths containing spaces, ampersands or parentheses
::  therefore cannot corrupt the value.
:: ============================================================
:PICK_FOLDER
set "PICKED_FOLDER="
for /f "usebackq delims=" %%p in (`powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; $d = New-Object System.Windows.Forms.FolderBrowserDialog; $d.Description = 'Select your anime download folder'; $d.RootFolder = 'MyComputer'; if ($d.ShowDialog() -eq 'OK') { $p = $d.SelectedPath; $f = Join-Path $env:TEMP 'anime_dl_path.tmp'; Set-Content -LiteralPath $f -Value $p -NoNewline; Write-Output $p }"`) do set "PICKED_FOLDER=%%p"
exit /b
