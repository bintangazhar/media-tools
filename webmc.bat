@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo.
    echo  [*] PENGGUNAAN: to-webm [-f] ^<video_atau_gif1^> [video2 ...]
    echo      Contoh 1 : to-webm video.mp4
    echo      Contoh 2 : to-webm video.mp4 -f
    echo.
    goto :eof
)

where ffmpeg >nul 2>&1
if !errorlevel! neq 0 (
    echo.
    echo  [i] FFmpeg belum terinstall. Mengunduh via winget...
    winget install Gyan.FFmpeg --accept-source-agreements --accept-package-agreements
    if !errorlevel! neq 0 (
        echo  [X] Gagal menginstall FFmpeg.
        goto :eof
    )
    echo  [V] FFmpeg berhasil terinstall.
)

set "FORCE_OVERWRITE=0"
for %%A in (%*) do (
    if /i "%%~A"=="-f" set "FORCE_OVERWRITE=1"
    if /i "%%~A"=="--force" set "FORCE_OVERWRITE=1"
)

set "SUCCESS_COUNT=0"
set "SKIP_COUNT=0"
set "FAIL_COUNT=0"

:loop
if "%~1"=="" goto end

if /i "%~1"=="-f" (
    shift
    goto loop
)
if /i "%~1"=="--force" (
    shift
    goto loop
)

set "INPUT=%~1"
set "OUTPUT=%~dpn1.webm"

echo.
echo  ======================================================
echo   MEMPROSES: %~nx1
echo  ======================================================

if exist "%OUTPUT%" (
    if "!FORCE_OVERWRITE!"=="0" (
        echo   [*] Status        : DILEWATI ^(File %~n1.webm sudah ada^)
        echo   [-] Petunjuk      : Gunakan '-f' untuk menimpa file.
        set /a "SKIP_COUNT+=1"
        shift
        goto loop
    ) else (
        echo   [*] Status        : MENIMPA FILE LAMA ^(-f aktif^)
    )
)

set "SIZE_BEFORE_BYTES=0"
for /f "tokens=*" %%A in ("%INPUT%") do set "SIZE_BEFORE_BYTES=%%~zA"
for /f "usebackq tokens=*" %%S in (`powershell -NoProfile -Command "$b = !SIZE_BEFORE_BYTES!; if($b -ge 1GB){'{0:N2} GB' -f ($b/1GB)}elseif($b -ge 1MB){'{0:N2} MB' -f ($b/1MB)}else{'{0:N0} KB' -f ($b/1KB)}"`) do set "SIZE_BEFORE_FMT=%%S"

echo   [-] Target Format : WebM ^(Codec: VP9^)
echo   [-] Ukuran Awal   : !SIZE_BEFORE_FMT!
echo   [-] Progress      :

ffmpeg -hide_banner -stats -loglevel error -i "%INPUT%" -c:v libvpx-vp9 -crf 30 -b:v 0 -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2,format=yuva420p" -an "%OUTPUT%" -y

set "CMD_ERR=!errorlevel!"
echo.

if !CMD_ERR! equ 0 (
    set "SIZE_AFTER_BYTES=0"
    for /f "tokens=*" %%B in ("%OUTPUT%") do set "SIZE_AFTER_BYTES=%%~zB"
    for /f "usebackq tokens=*" %%S in (`powershell -NoProfile -Command "$b = !SIZE_AFTER_BYTES!; if($b -ge 1GB){'{0:N2} GB' -f ($b/1GB)}elseif($b -ge 1MB){'{0:N2} MB' -f ($b/1MB)}else{'{0:N0} KB' -f ($b/1KB)}"`) do set "SIZE_AFTER_FMT=%%S"

    echo   [V] Status        : HASIL KONVERSI BERHASIL
    echo   [-] Ukuran Akhir  : !SIZE_AFTER_FMT!
    echo   [-] File Hasil    : %~nx1.webm
    set /a "SUCCESS_COUNT+=1"
) else (
    echo   [X] Status        : GAGAL DIKONVERSI
    set /a "FAIL_COUNT+=1"
)

shift
goto loop

:end
echo.
echo  ======================================================
echo   RINGKASAN PROSES
echo  ======================================================
echo   Berhasil : !SUCCESS_COUNT! file
echo   Dilewati : !SKIP_COUNT! file
echo   Gagal    : !FAIL_COUNT! file
echo  ======================================================
echo.