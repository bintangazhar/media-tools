# media-tools

A small collection of Windows batch scripts for everyday media conversion and
optimization: video to WebM/MP4/GIF, images to WebP/AVIF, image resizing, and
SVG minification. Each script is a thin, readable wrapper around `ffmpeg`,
`cwebp`, or `svgo`, and will offer to install its dependency the first time you
run it.

> Console messages are in Indonesian; flags, filenames, and this documentation
> are in English.

---

## Contents

| Script                | Command       | What it does                                              | Needs            |
| --------------------- | ------------- | -------------------------------------------------------- | ---------------- |
| `webmc.bat`           | `webmc`       | Video / GIF to **WebM** (VP9, no audio, alpha-capable)    | FFmpeg           |
| `webpc.bat`           | `webpc`       | Images (PNG/JPG/GIF/HEIC/...) to **WebP**                 | libwebp, FFmpeg\* |
| `avifc.bat`           | `avifc`       | Image to **AVIF** (SVT-AV1)                               | FFmpeg           |
| `mp4c.bat`            | `mp4c`        | Video to **MP4** (H.264 + AAC, web-safe)                  | FFmpeg           |
| `vid-to.gif.bat`      | `vid-to.gif`  | Video to **GIF** (palette-optimized)                      | FFmpeg           |
| `resize-img.bat`      | `resize-img`  | Resize an image to a target width                         | FFmpeg           |
| `opt-svg.bat`         | `opt-svg`     | Minify an **SVG** to `*.min.svg`                          | Node.js + SVGO   |

<sub>\* FFmpeg is only used by `webpc` for `.heic` input.</sub>

All scripts write the output **next to the input file** and never delete the
original.

---

## Requirements

- **Windows 10 (1809+) or Windows 11** with [`winget`](https://learn.microsoft.com/windows/package-manager/winget/) available.
- A dependency per script (see table). If it is missing, the script installs it
  automatically:
  - **FFmpeg**: `winget install Gyan.FFmpeg`
  - **libwebp** (`cwebp`, `gif2webp`): `winget install Google.Libwebp`
  - **SVGO**: `npm install -g svgo` (requires [Node.js](https://nodejs.org/))
- After an auto-install you may need to **open a new terminal** so the new
  command is on `PATH`.

---

## Setup

Clone the repo somewhere permanent:

```powershell
git clone https://github.com/<your-username>/media-tools.git
cd media-tools
```

Then pick one of the following. They are not mutually exclusive.

### Option A: PowerShell commands (recommended)

Dot-source `profile-snippet.ps1` from your PowerShell profile. It registers a
function for every `.bat` in the folder so you can call them by name from any
directory.

```powershell
# open your profile
notepad $PROFILE

# add this line (adjust the path), save, restart PowerShell
. "C:\path\to\media-tools\profile-snippet.ps1"
```

Verify:

```powershell
list-tools      # prints every registered command
```

### Option B: add the folder to PATH

Add the repo folder to your user `PATH` environment variable. You can then run
`webmc video.mp4` etc. from `cmd` or PowerShell. (`list-tools` is only available
with Option A.)

### Option C: Windows right-click menu

The `context-menu/` folder has `.reg` files that add **Convert to WebM** and
**Convert to WebP** entries to Explorer's context menu.

1. Open the `.reg` file in a text editor and replace every
   `D:\\04_personal\\tools\\...` path with the path where you cloned this repo
   (keep the double backslashes).
   - If your path contains spaces, change the command to:
     `cmd /c \"\"C:\\My Path\\webmc.bat\" \"%1\" & pause\"`
2. Double-click the file and confirm the import.
3. To remove the entries later, run the matching `Uninstall ...reg`.

---

## Usage

Examples assume Option A (commands on `PATH`). Otherwise call the `.bat`
directly.

### `webmc`: WebM

```
webmc [-f] <file> [more files ...]
```

- Codec VP9, `CRF 30`, variable bitrate. **Audio is dropped** (`-an`).
- Dimensions are padded to even numbers; pixel format keeps an alpha channel.
- Accepts video files and GIFs; processes any number of inputs.
- Skips a file if its `.webm` already exists. Pass `-f` / `--force` to overwrite.
- Prints the size before/after (KB/MB/GB), the elapsed conversion time, and a
  success/skipped/failed summary.

```powershell
webmc clip.mp4
webmc -f intro.mov outro.mov
webmc animation.gif
```

### `webpc`: WebP

```
webpc [-f] <file> [more files ...] [quality]
```

- Default quality **80**. A trailing number `1-100` is read as the quality.
- Routing by extension: `.gif` uses `gif2webp`, `.heic` uses `ffmpeg`, everything
  else uses `cwebp`.
- Skips a file if its `.webp` already exists. Pass `-f` / `--force` to overwrite.
- Prints sizes (KB/MB/GB), the elapsed conversion time, and a summary.

```powershell
webpc photo.jpg
webpc *.png                 # PowerShell expands the glob
webpc -f banner.png 90
webpc sticker.gif 75
```

### `avifc`: AVIF

```
avifc <image> [quality 0-63]
```

- Encoder SVT-AV1, `-preset 6`. Quality is the AV1 **CRF**: default **30**,
  lower means better quality and a larger file.
- One file per run. Overwrites the `.avif` if present.

```powershell
avifc render.png
avifc render.png 22
```

### `mp4c`: MP4

```
mp4c <video> [more videos ...]
```

- H.264 `CRF 23`, `-preset slow`, AAC 128 kbps.
- Padded to even dimensions, `yuv420p` for maximum player compatibility.
- Processes any number of inputs. Overwrites existing `.mp4`.

```powershell
mp4c recording.mkv
mp4c a.webm b.webm c.webm
```

### `vid-to.gif`: GIF

```
vid-to.gif <video> [fps] [width]
```

- Defaults: **15 fps**, **480 px** wide (height scales automatically).
- Two-pass palette generation for clean colors.
- One file per run. Overwrites existing `.gif`.

```powershell
vid-to.gif demo.mp4
vid-to.gif demo.mp4 24 640
```

### `resize-img`: resize

```
resize-img <image> [width_px]
```

- Default width **1080**; height is scaled to keep aspect ratio (rounded to an
  even number).
- Output is named `<name>_<width>px<ext>`, so the original is untouched.

```powershell
resize-img hero.jpg
resize-img hero.jpg 800
```

### `opt-svg`: minify SVG

```
opt-svg <file.svg> [more files ...]
```

- Runs SVGO with default settings. Output is `<name>.min.svg`.
- Processes any number of inputs.

```powershell
opt-svg icon.svg
opt-svg icons\*.svg
```

---

## Notes & gotchas

- **Originals are always kept.** Nothing is deleted or renamed in place.
- **Overwrite behavior:** `webmc` and `webpc` skip existing outputs unless you
  pass `-f`. The other scripts overwrite silently (`ffmpeg -y`).
- **`webmc` removes audio** by design. Use `mp4c` if you need sound.
- **Paths with spaces:** the scripts quote their arguments, but the `.reg`
  commands need the extra wrapping shown in Option C.
- **First run is slow** if a dependency has to be downloaded and installed.
- Tested on Windows 11. The scripts are plain `cmd` batch files, so no admin
  rights are needed except when importing `.reg` files.

---

## Repository layout

```
media-tools/
├── webmc.bat / webpc.bat / avifc.bat / mp4c.bat
├── vid-to.gif.bat / resize-img.bat / opt-svg.bat
├── profile-snippet.ps1        # registers the commands in PowerShell
├── context-menu/              # optional Explorer right-click entries
│   ├── Install to-webm.reg   / Uninstall to-webm.reg
│   └── Install to-webp.reg   / Uninstall to-webp.reg
├── README.md
├── CHANGELOG.md
└── LICENSE                     # The Unlicense (public domain)
```

## License

Released into the public domain under [The Unlicense](LICENSE). Use it however
you like.
