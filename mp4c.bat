@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Penggunaan: to-mp4 video.ext
    goto :eof
)

where ffmpeg >nul 2>&1
if !errorlevel! neq 0 (
    echo [INFO] FFmpeg belum terinstall. Mengunduh via winget...
    winget install Gyan.FFmpeg --accept-source-agreements --accept-package-agreements
)

:loop
if "%~1"=="" goto end

echo Converting "%~1" to MP4...
ffmpeg -i "%~1" -c:v libx264 -crf 23 -preset slow -c:a aac -b:a 128k -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2,format=yuv420p" "%~dpn1.mp4" -y

shift
goto loop

:end
echo.
echo Selesai!