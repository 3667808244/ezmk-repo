$ErrorActionPreference = "Stop"
$sourcesDir = "E:\claude_workspace\ezmk-repo\sources"
$stbBaseUrl = "https://raw.githubusercontent.com/nothings/stb/master"

$stb_packages = @(
    @{name="stb-image";       file="stb_image.h";        version="2.30.0"; desc="Image loading/decoding (PNG, JPEG, BMP, TGA, HDR, etc.)"; license="MIT / Public Domain"}
    @{name="stb-image-write"; file="stb_image_write.h";  version="1.16.0"; desc="Image writing (PNG, JPEG, BMP, TGA)"; license="MIT / Public Domain"}
    @{name="stb-image-resize";file="stb_image_resize.h"; version="0.97.0"; desc="Image resizing/filtering"; license="MIT / Public Domain"}
    @{name="stb-truetype";    file="stb_truetype.h";     version="1.27.0"; desc="TrueType font rasterization"; license="MIT / Public Domain"}
    @{name="stb-rect-pack";   file="stb_rect_pack.h";    version="1.01.0"; desc="Rectangle packing for texture atlases"; license="MIT / Public Domain"}
    @{name="stb-perlin";      file="stb_perlin.h";       version="0.05.0"; desc="Perlin noise generation"; license="MIT / Public Domain"}
    @{name="stb-sprintf";     file="stb_sprintf.h";      version="1.10.0"; desc="Fast sprintf/sscanf replacement"; license="MIT / Public Domain"}
    @{name="stb-ds";          file="stb_ds.h";           version="0.67.0"; desc="Type-safe dynamic arrays and hash maps (C macros)"; license="MIT / Public Domain"}
    @{name="stb-textedit";    file="stb_textedit.h";     version="1.14.0"; desc="Simple text editor widget"; license="MIT / Public Domain"}
)

foreach ($pkg in $stb_packages) {
    $name = $pkg.name
    $pkgDir = Join-Path $sourcesDir $name
    $includeDir = Join-Path $pkgDir "include"

    Write-Host "Creating $name ..."
    New-Item -ItemType Directory -Force -Path $includeDir | Out-Null

    # Download header
    $url = "$stbBaseUrl/$($pkg.file)"
    $dest = Join-Path $includeDir $pkg.file
    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -ErrorAction Stop
        $size = (Get-Item $dest).Length
        Write-Host "  Downloaded $($pkg.file) ($size bytes)"
    } catch {
        Write-Host "  ERROR downloading $url : $_"
        continue
    }

    # Create ezmk.toml
    $toml_lines = @()
    $toml_lines += '[project]'
    $toml_lines += "name = `"$name`""
    $toml_lines += 'type = "static"'
    $toml_lines += "version = `"$($pkg.version)`""
    $toml_lines += 'language = "C99"'
    $toml_lines += 'header_only = true'
    $toml_lines += ''
    $toml_lines += '[compile]'
    $toml_lines += 'include_dirs = ["include"]'
    $toml_lines += 'flags = []'
    $toml_lines -join "`n" | Set-Content -Path (Join-Path $pkgDir "ezmk.toml") -Encoding UTF8

    # Create README.md
    $usage_hint = "stb_image.h"
    $readme_lines = @()
    $readme_lines += "# $name"
    $readme_lines += ''
    $readme_lines += $pkg.desc
    $readme_lines += ''
    $readme_lines += "- **Version**: $($pkg.version)"
    $readme_lines += "- **License**: $($pkg.license)"
    $readme_lines += "- **Type**: Header-only (single-file C library)"
    $readme_lines += "- **Source**: [nothings/stb](https://github.com/nothings/stb)"
    $readme_lines += ''
    $readme_lines += '## Usage'
    $readme_lines += ''
    $readme_lines += '```c'
    $readme_lines += "#define STB_IMAGE_IMPLEMENTATION"
    $readme_lines += '#include "stb_image.h"'
    $readme_lines += '```'
    $readme_lines += ''
    $readme_lines += 'Add to your `ezmk.toml`:'
    $readme_lines += '```toml'
    $readme_lines += '[depends]'
    $readme_lines += "lib = [`"$name`"]"
    $readme_lines += '```'
    $readme_lines -join "`n" | Set-Content -Path (Join-Path $pkgDir "README.md") -Encoding UTF8

    Write-Host "  Package created: $name v$($pkg.version)"
}

Write-Host "`nDone. Created packages in $sourcesDir"
