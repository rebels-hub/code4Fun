@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: setup_magickey.cmd
:: Checks for Python, installs it if missing, ensures 'requests'
:: is installed, then downloads a target .py file.
:: Does NOT auto-run the downloaded script.
:: ============================================================

:: ---- EDIT THIS LINE with the real raw file URL ----
set "FILE_URL=https://raw.githubusercontent.com/rebels-hub/code4fun/main/magickey.py"
set "OUT_FILE=%~dp0magickey.py"

echo.
echo === Step 1: Checking for Python ===
where python >nul 2>&1
if %errorlevel%==0 (
    echo Python found:
    python --version
) else (
    echo Python not found. Attempting install via winget...
    where winget >nul 2>&1
    if %errorlevel%==0 (
        winget install -e --id Python.Python.3.12 --accept-source-agreements --accept-package-agreements
    ) else (
        echo winget not available on this system.
        echo Please install Python manually from https://www.python.org/downloads/
        echo Make sure to check "Add python.exe to PATH" during install.
        pause
        exit /b 1
    )
)

echo.
echo === Step 2: Refreshing PATH check ===
where python >nul 2>&1
if not %errorlevel%==0 (
    echo Python still not found on PATH. Restart this script after installing,
    echo or restart your terminal/PC so PATH updates take effect.
    pause
    exit /b 1
)

echo.
echo === Step 3: Checking pip ===
python -m ensurepip --upgrade >nul 2>&1
python -m pip --version >nul 2>&1
if not %errorlevel%==0 (
    echo pip not available. Something is wrong with the Python install.
    pause
    exit /b 1
)

echo.
echo === Step 4: Checking/installing 'requests' library ===
python -c "import requests" >nul 2>&1
if %errorlevel%==0 (
    echo requests already installed.
) else (
    echo Installing requests...
    python -m pip install --upgrade pip >nul 2>&1
    python -m pip install requests
)

echo.
echo === Step 5: Downloading target file ===
echo URL: %FILE_URL%
echo Destination: %OUT_FILE%

powershell -Command "try { Invoke-WebRequest -Uri '%FILE_URL%' -OutFile '%OUT_FILE%' -UseBasicParsing; Write-Host 'Download OK' } catch { Write-Host 'Download FAILED:' $_.Exception.Message; exit 1 }"

if not exist "%OUT_FILE%" (
    echo Download failed. Check the FILE_URL variable at the top of this script.
    pause
    exit /b 1
)

echo.
echo === Done ===
echo File saved to: %OUT_FILE%
echo This script did NOT run the file. Review it, then run manually with:
echo     python "%OUT_FILE%"
echo.
pause
