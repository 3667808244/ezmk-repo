# Create stb packages from local git clone
$ErrorActionPreference = "Stop"
$sourcesDir = "E:\claude_workspace\ezmk-repo\sources"
$stbClone = "E:\claude_workspace\ezmk-repo\stb_temp"

# Name -> file mapping + version + description
$packages = @(
    @{name="stb-image";        file="stb_image.h";         version="2.30.0";  desc="Image loading/decoding (PNG, JPEG, BMP, TGA, HDR, PSD, GIF, etc.)";          header_only=$true}
    @{name="stb-image-write";  file="stb_image_write.h";   version="1.16.0";  desc="Image writing (PNG, JPEG, BMP, TGA)";                                       header_only=$true}
    @{name="stb-image-resize"; file="stb_image_resize2.h"; version="0.97.0";  desc="Image resizing/filtering (v2)";                                                header_only=$true}
    @{name="stb-truetype";     file="stb_truetype.h";      version="1.27.0";  desc="TrueType font rasterization";                                                  header_only=$true}
    @{name="stb-rect-pack";    file="stb_rect_pack.h";     version="1.01.0";  desc="Rectangle packing for texture atlases";                                         header_only=$true}
    @{name="stb-perlin";       file="stb_perlin.h";        version="0.05.0";  desc="Perlin noise generation";                                                       header_only=$true}
    @{name="stb-sprintf";      file="stb_sprintf.h";       version="1.10.0";  desc="Fast sprintf/sscanf replacement";                                               header_only=$true}
    @{name="stb-ds";           file="stb_ds.h";            version="0.67.0";  desc="Type-safe dynamic arrays and hash maps (C macros)";                              header_only=$true}
    @{name="stb-textedit";     file="stb_textedit.h";      version="1.14.0";  desc="Simple text editor widget";                                                      header_only=$true}
    @{name="stb-vorbis";       file="stb_vorbis.c";       version="1.22.0";  desc="Ogg Vorbis audio decoder (single-file C implementation)";                         header_only=$false}
)

foreach ($pkg in $packages) {
    $name = $pkg.name
    $pkgDir = Join-Path $sourcesDir $name
    $includeDir = Join-Path $pkgDir "include"
    $srcFile = Join-Path $stbClone $pkg.file

    if (-not (Test-Path $srcFile)) {
        Write-Host "SKIP $name : source file not found at $srcFile"
        continue
    }

    # Clean existing if any
    if (Test-Path $pkgDir) { Remove-Item -Recurse -Force $pkgDir }

    if ($pkg.header_only) {
        # header-only: put header in include/
        New-Item -ItemType Directory -Force -Path $includeDir | Out-Null
        Copy-Item $srcFile $includeDir
        Write-Host "OK $name (header-only) : $($pkg.file)"
    } else {
        # stb-vorbis: has .c source file
        $srcDir = Join-Path $pkgDir "src"
        New-Item -ItemType Directory -Force -Path $includeDir | Out-Null
        New-Item -ItemType Directory -Force -Path $srcDir | Out-Null
        # Copy .c as both source and "header" (it's single-file, you include it)
        Copy-Item $srcFile $srcDir
        # Create a thin wrapper header that points to the source
        $wrapper = "#pragma once`n/* stb_vorbis — include stb_vorbis.c in one translation unit with:`n   #define STB_VORBIS_IMPLEMENTATION`n   #include `"stb_vorbis.c`"`n*/`n"
        $wrapper | Set-Content -Path (Join-Path $includeDir "stb_vorbis.h") -Encoding UTF8
        Write-Host "OK $name (compiled) : $($pkg.file)"
    }

    # Create ezmk.toml
    $toml = @()
    $toml += '[project]'
    $toml += "name = `"$name`""
    $toml += 'type = "static"'
    $toml += "version = `"$($pkg.version)`""
    $toml += 'language = "C99"'
    if ($pkg.header_only) {
        $toml += 'header_only = true'
    }
    $toml += ''
    $toml += '[compile]'
    $toml += 'include_dirs = ["include"]'
    $toml += 'flags = []'
    $toml -join "`n" | Set-Content -Path (Join-Path $pkgDir "ezmk.toml") -Encoding UTF8

    # Create README.md
    $readme = @()
    $readme += "# $name"
    $readme += ''
    $readme += $pkg.desc
    $readme += ''
    $readme += "- **Version**: $($pkg.version)"
    $readme += "- **License**: MIT / Public Domain"
    if ($pkg.header_only) {
        $readme += "- **Type**: Header-only (single-file C library)"
    } else {
        $readme += "- **Type**: Single-file C library (requires compilation)"
    }
    $readme += "- **Source**: [nothings/stb](https://github.com/nothings/stb)"
    $readme += ''
    $readme += '## Usage'
    $readme += ''
    $readme += 'Add to your `ezmk.toml`:'
    $readme += '```toml'
    $readme += '[depends]'
    $readme += "lib = [`"$name`"]"
    $readme += '```'
    $readme -join "`n" | Set-Content -Path (Join-Path $pkgDir "README.md") -Encoding UTF8
}

Write-Host "`nDone. Created all stb packages."
