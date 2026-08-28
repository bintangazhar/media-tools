@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Penggunaan: resize-img gambar.ext [width_px]
    goto :eof
)

where ffmpeg >nul 2>&1
if !errorlevel! neq 0 (
    echo [INFO] FFmpeg belum terinstall. Mengunduh via winget...
    winget install Gyan.FFmpeg --accept-source-agreements --accept-package-agreements
)

set "INPUT=%~1"
set "WIDTH=%~2"

if "%WIDTH%"=="" set "WIDTH=1080"

set "OUTPUT=%~dpn1_%WIDTH%px%~x1"

echo Resizing "%INPUT%" to width %WIDTH%px...
ffmpeg -i "%INPUT%" -vf "scale=%WIDTH%:-2" "%OUTPUT%" -y

if %errorlevel% equ 0 (
    echo [SUCCESS] File berhasil di-resize: %OUTPUT%
) else (
    echo [ERROR] Gagal meng-resize file.
)