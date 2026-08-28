# ---------------------------------------------------------------------------
#  media-tools - PowerShell profile snippet
#
#  Dot-source this file from your PowerShell profile so every .bat / .cmd /
#  .exe in this folder becomes a command you can call by name from any
#  directory:
#
#      . "C:\path\to\media-tools\profile-snippet.ps1"
#
#  Then run  list-tools  to see everything that was registered.
# ---------------------------------------------------------------------------

# Folder that holds the tools. Resolves to this script's own location when
# dot-sourced by path; falls back to a hard-coded path otherwise.
$toolsDir = if ($PSScriptRoot) { $PSScriptRoot } else { "D:\04_personal\tools" }

if (Test-Path $toolsDir) {
    Get-ChildItem -Path $toolsDir -File | Where-Object { $_.Extension -in '.bat', '.cmd', '.exe' } | ForEach-Object {
        $name     = $_.BaseName
        $fullPath = $_.FullName

        # Define a global function per tool so arguments ($1, $2, ...) pass through.
        Set-Item -Path "Function:\global:$name" -Value ([ScriptBlock]::Create("& '$fullPath' `$args"))
    }
}

function list-tools {
    $toolsDir = if ($PSScriptRoot) { $PSScriptRoot } else { "D:\04_personal\tools" }

    if (-not (Test-Path $toolsDir)) {
        Write-Host "Folder $toolsDir not found!" -ForegroundColor Red
        return
    }

    $files = Get-ChildItem -Path $toolsDir -File | Where-Object { $_.Extension -in '.bat', '.cmd', '.exe' }

    Write-Host "`n===================================================" -ForegroundColor Cyan
    Write-Host "       REGISTERED TOOLS ($($files.Count) files)" -ForegroundColor Cyan
    Write-Host "===================================================" -ForegroundColor Cyan

    foreach ($file in $files) {
        $aliasName = $file.BaseName
        $ext       = $file.Extension.ToUpper()

        Write-Host " > " -NoNewline -ForegroundColor Yellow
        Write-Host ("{0,-20}" -f $aliasName) -NoNewline -ForegroundColor Green
        Write-Host ("[{0}]" -f $ext) -NoNewline -ForegroundColor DarkGray
        Write-Host " -> $($file.FullName)" -ForegroundColor Gray
    }
    Write-Host "`nType any name above directly in the terminal to run it.`n" -ForegroundColor DarkCyan
}
