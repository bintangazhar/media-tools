# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project aims
to follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] — 2026-08-28

First public release.

### Added

- **`webmc.bat`** — convert video/GIF to WebM (VP9, CRF 30, audio stripped,
  alpha-capable, even-dimension padding). Batch input, `-f`/`--force` to
  overwrite, before/after size report (KB/MB/GB), per-file elapsed time
  (`detik`, switching to `m s` past one minute), and a summary.
- **`webpc.bat`** — convert images to WebP. Default quality 80, trailing number
  read as quality; `.gif` via `gif2webp`, `.heic` via `ffmpeg`, others via
  `cwebp`. Batch input, `-f`/`--force`, before/after size report (KB/MB/GB),
  per-file elapsed time, and a summary.
- **`avifc.bat`** — convert an image to AVIF (SVT-AV1, `-preset 6`, CRF
  default 30).
- **`mp4c.bat`** — convert video to web-safe MP4 (H.264 CRF 23 `-preset slow`,
  AAC 128k, `yuv420p`). Batch input.
- **`vid-to.gif.bat`** — convert video to a palette-optimized GIF
  (default 15 fps, 480 px wide).
- **`resize-img.bat`** — resize an image to a target width (default 1080 px),
  output named `<name>_<width>px<ext>`.
- **`opt-svg.bat`** — minify SVG files with SVGO to `<name>.min.svg`. Batch
  input.
- **`profile-snippet.ps1`** — dot-source from a PowerShell profile to register
  every `.bat` in the folder as a callable command; adds `list-tools`.
- **`context-menu/`** — `.reg` files that add "Convert to WebM" / "Convert to
  WebP" entries to the Explorer right-click menu, plus matching uninstallers.
- Each script auto-installs its dependency (FFmpeg via `winget`, libwebp via
  `winget`, SVGO via `npm`) on first run if it is missing.
- `README.md`, `CHANGELOG.md`, `LICENSE` (The Unlicense), `.gitignore`.

### Changed

- Renamed the PowerShell profile file from `notepad %PROFILE.txt` to
  `profile-snippet.ps1`.
- `profile-snippet.ps1` now resolves the tools folder from its own location
  (`$PSScriptRoot`) instead of a hard-coded path, and its messages are in
  English.
- Context-menu `.reg` commands now run through `cmd /c … & pause` so the
  console window stays open to show the result, and register a few more file
  extensions (`.mkv`, `.mov`, `.avi`, `.gif`; `.gif`, `.heic`, `.bmp`,
  `.tiff`).
- Moved the `.reg` files into `context-menu/`.
- `webpc.bat` now reports file sizes in KB/MB/GB (was integer KB only) and scans
  all arguments for `-f`/`--force` instead of only the first, matching
  `webmc.bat`.

### Fixed

- `context-menu` `.reg` files pointed at non-existent `to-webm.bat` /
  `to-webp.bat`; they now call `webmc.bat` / `webpc.bat`.
- `avifc.bat` compared the quality argument against a literal space, so the
  default CRF was never applied and `ffmpeg` got an empty `-crf` value when no
  quality was passed. It now falls back to `30` correctly.
