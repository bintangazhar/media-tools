@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Penggunaan: optimize-svg file.svg
    goto :eof
)

where svgo >nul 2>&1
if !errorlevel! neq 0 (
    echo [INFO] SVGO belum terinstall. Mengunduh via npm...
    call npm install -g svgo
)

:loop
if "%~1"=="" goto end

echo Optimizing "%~1"...
svgo "%~1" -o "%~dpn1.min.svg"

shift
goto loop

:end
echo.
echo Selesai!