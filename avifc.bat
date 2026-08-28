@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Penggunaan: to-avif gambar.ext [quality 0-63]
    goto :eof
)

where ffmpeg >nul 2>&1
if !errorlevel! neq 0 (
    echo [INFO] FFmpeg belum terinstall. Mengunduh via winget...
    winget install Gyan.FFmpeg --accept-source-agreements --accept-package-agreements
)

set "INPUT=%~1"
set "OUTPUT=%~dpn1.avif"
set "CRF=%~2"

if "%CRF%"=="" set "CRF=30"

echo Converting "%INPUT%" to AVIF...
ffmpeg -i "%INPUT%" -c:v libsvtav1 -crf %CRF% -preset 6 "%OUTPUT%" -y

if %errorlevel% equ 0 (
    echo [SUCCESS] File dikonversi ke %OUTPUT%
) else (
    echo [ERROR] Gagal mengonversi gambar.
)