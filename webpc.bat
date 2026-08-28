@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo.
    echo  [!] PENGGUNAAN: to-webp [-f] ^<file1^> [file2 file3 ...] [quality 0-100]
    echo      Contoh biasa  : to-webp *.png
    echo      Contoh paksa  : to-webp -f gambar.png 80
    echo.
    goto :eof
)

where cwebp >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [i] Google.Libwebp belum terinstall. Mengunduh via winget...
    winget install Google.Libwebp --accept-source-agreements --accept-package-agreements
    if !errorlevel! neq 0 (
        echo  [X] Gagal menginstall Google.Libwebp secara otomatis.
        goto :eof
    )
    echo  [V] Google.Libwebp berhasil terinstall!
)

set "FORCE_OVERWRITE=0"
if /i "%~1"=="-f" set "FORCE_OVERWRITE=1" & shift
if /i "%~1"=="--force" set "FORCE_OVERWRITE=1" & shift

set "QUALITY=80"
set "LAST_ARG="

for %%A in (%*) do set "LAST_ARG=%%A"

echo %LAST_ARG%| findstr /r "^[0-9][0-9]*$" >nul
if %errorlevel% equ 0 (
    if %LAST_ARG% leq 100 (
        if %LAST_ARG% gtr 0 (
            set "QUALITY=%LAST_ARG%"
        )
    )
)

set "SUCCESS_COUNT=0"
set "SKIP_COUNT=0"
set "FAIL_COUNT=0"

:loop
if "%~1"=="" goto end

if "%~1"=="%QUALITY%" (
    shift
    goto loop
)

set "INPUT=%~1"
set "OUTPUT=%~dpn1.webp"

echo.
echo  ======================================================
echo   MEMPROSES: %~nx1
echo  ======================================================

if exist "%OUTPUT%" (
    if "!FORCE_OVERWRITE!"=="0" (
        echo   [!] Status        : DILEWATI (File %~n1.webp sudah ada!)
        set /a "SKIP_COUNT+=1"
        shift
        goto loop
    )
)

for %%A in ("%INPUT%") do set "SIZE_BEFORE=%%~zA"
set /a "SIZE_BEFORE_KB=!SIZE_BEFORE! / 1024"

echo   [-] Target Format : WebP (Quality: %QUALITY%%%)
echo   [-] Ukuran Awal   : !SIZE_BEFORE_KB! KB
echo   [-] Progress      :

rem Menggunakan indikator bawaan cwebp / gif2webp / ffmpeg
if /i "%~x1"==".gif" (
    gif2webp -q %QUALITY% "%INPUT%" -o "%OUTPUT%"
) else if /i "%~x1"==".heic" (
    ffmpeg -hide_banner -stats -loglevel info -i "%INPUT%" -c:v libwebp -quality %QUALITY% "%OUTPUT%" -y
) else (
    cwebp -progress -q %QUALITY% "%INPUT%" -o "%OUTPUT%"
)

echo.
if !errorlevel! equ 0 (
    for %%B in ("%OUTPUT%") do set "SIZE_AFTER=%%~zB"
    set /a "SIZE_AFTER_KB=!SIZE_AFTER! / 1024"
    
    echo   [V] Status        : HASIL KONVERSI BERHASIL!
    echo   [-] Ukuran Akhir  : !SIZE_AFTER_KB! KB
    echo   [-] Saved As      : %~n1.webp
    set /a "SUCCESS_COUNT+=1"
) else (
    echo   [X] Status        : GAGAL DIKONVERSI!
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