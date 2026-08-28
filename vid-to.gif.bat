@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Penggunaan: vid-to-gif video.ext [fps] [width]
    goto :eof
)

where ffmpeg >nul 2>&1
if !errorlevel! neq 0 (
    echo [INFO] FFmpeg belum terinstall. Mengunduh via winget...
    winget install Gyan.FFmpeg --accept-source-agreements --accept-package-agreements
)

set "INPUT=%~1"
set "FPS=%~2"
set "WIDTH=%~3"

if "%FPS%"=="" set "FPS=15"
if "%WIDTH%"=="" set "WIDTH=480"

set "OUTPUT=%~dpn1.gif"

echo Generating high-quality GIF...
ffmpeg -i "%INPUT%" -vf "fps=%FPS%,scale=%WIDTH%:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" "%OUTPUT%" -y

if %errorlevel% equ 0 (
    echo [SUCCESS] GIF berhasil dibuat: %OUTPUT%
) else (
    echo [ERROR] Gagal membuat GIF.
)