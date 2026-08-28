@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo.
    echo  [*] PENGGUNAAN: webpc [-f] ^<file1^> [file2 ...] [quality 0-100]
    echo      Contoh 1 : webpc *.png
    echo      Contoh 2 : webpc -f gambar.png 80
    echo.
    goto :eof
)

where cwebp >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [i] Google.Libwebp belum terinstall. Mengunduh via winget...
    winget install Google.Libwebp --accept-source-agreements --accept-package-agreements
    if !errorlevel! neq 0 (
        echo  [X] Gagal menginstall Google.Libwebp.
        goto :eof
    )
    echo  [V] Google.Libwebp berhasil terinstall.
)

set "FORCE_OVERWRITE=0"
set "QUALITY=80"
set "LAST_ARG="

for %%A in (%*) do (
    if /i "%%~A"=="-f" set "FORCE_OVERWRITE=1"
    if /i "%%~A"=="--force" set "FORCE_OVERWRITE=1"
    set "LAST_ARG=%%A"
)

echo %LAST_ARG%| findstr /r "^[0-9][0-9]*$" >nul
if %errorlevel% equ 0 (
    if %LAST_ARG% leq 100 (
        if %LAST_ARG% gtr 0 set "QUALITY=%LAST_ARG%"
    )
)

set "SUCCESS_COUNT=0"
set "SKIP_COUNT=0"
set "FAIL_COUNT=0"

:loop
if "%~1"=="" goto end

if /i "%~1"=="-f" ( shift & goto loop )
if /i "%~1"=="--force" ( shift & goto loop )
if "%~1"=="%QUALITY%" ( shift & goto loop )

set "INPUT=%~1"
set "OUTPUT=%~dpn1.webp"

echo.
echo  ======================================================
echo   MEMPROSES: %~nx1
echo  ======================================================

if exist "%OUTPUT%" (
    if "!FORCE_OVERWRITE!"=="0" (
        echo   [*] Status        : DILEWATI ^(File %~n1.webp sudah ada^)
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

echo   [-] Target Format : WebP ^(Quality: %QUALITY%%%)
echo   [-] Ukuran Awal   : !SIZE_BEFORE_FMT!
echo   [-] Progress      :

rem Merekam waktu mulai
for /f "usebackq tokens=*" %%T in (`powershell -NoProfile -Command "(Get-Date).Ticks"`) do set "T_START=%%T"

if /i "%~x1"==".gif" (
    gif2webp -q %QUALITY% "%INPUT%" -o "%OUTPUT%"
) else if /i "%~x1"==".heic" (
    ffmpeg -hide_banner -stats -loglevel info -i "%INPUT%" -c:v libwebp -quality %QUALITY% "%OUTPUT%" -y
) else (
    cwebp -progress -q %QUALITY% "%INPUT%" -o "%OUTPUT%"
)

set "CMD_ERR=!errorlevel!"

rem Merekam waktu selesai dan menghitung durasi
for /f "usebackq tokens=*" %%T in (`powershell -NoProfile -Command "$ts=[timespan]::FromTicks((Get-Date).Ticks - !T_START!); if($ts.TotalMinutes -ge 1){'{0}m {1}s' -f $ts.Minutes, $ts.Seconds}else{'{0:N1} detik' -f $ts.TotalSeconds}"`) do set "DURATION=%%T"
echo.

if !CMD_ERR! equ 0 (
    set "SIZE_AFTER_BYTES=0"
    for /f "tokens=*" %%B in ("%OUTPUT%") do set "SIZE_AFTER_BYTES=%%~zB"
    for /f "usebackq tokens=*" %%S in (`powershell -NoProfile -Command "$b = !SIZE_AFTER_BYTES!; if($b -ge 1GB){'{0:N2} GB' -f ($b/1GB)}elseif($b -ge 1MB){'{0:N2} MB' -f ($b/1MB)}else{'{0:N0} KB' -f ($b/1KB)}"`) do set "SIZE_AFTER_FMT=%%S"

    echo   [V] Status        : HASIL KONVERSI BERHASIL
    echo   [-] Waktu Proses  : !DURATION!
    echo   [-] Ukuran Akhir  : !SIZE_AFTER_FMT!
    echo   [-] File Hasil    : %~n1.webp
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
