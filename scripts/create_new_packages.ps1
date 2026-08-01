# 1.1.0-dev.7: Create new packages (header-only + source-compiled)
# Precompiled packages will need separate per-platform builds.
$ErrorActionPreference = "Continue"
$sourcesDir = "E:\claude_workspace\ezmk-repo\sources"
$downloadDir = "E:\claude_workspace\ezmk-repo\temp_sources"
New-Item -ItemType Directory -Force -Path $downloadDir | Out-Null

# ── Header-only packages ──────────────────────────────────────────────────

# 1. tomlplusplus — single header file
$name = "tomlplusplus"
$version = "3.4.0"
$pkgDir = "$sourcesDir/$name"
if (-not (Test-Path $pkgDir)) { New-Item -ItemType Directory -Force -Path "$pkgDir/include" | Out-Null }
$tomlHpp = "$downloadDir/toml.hpp"
if (-not (Test-Path $tomlHpp)) {
    Write-Host "Downloading tomlplusplus..."
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/marzer/tomlplusplus/master/toml.hpp" -OutFile $tomlHpp -TimeoutSec 60
}
Copy-Item $tomlHpp "$pkgDir/include/"
@"
[project]
name = "$name"
type = "static"
version = "$version"
language = "C++17"
header_only = true

[compile]
include_dirs = ["include"]
flags = []
"@ | Set-Content -Path "$pkgDir/ezmk.toml" -Encoding UTF8
@"
# $name

tomlplusplus — Header-only C++17 TOML parser

- **Version**: $version
- **License**: MIT
- **Type**: Header-only
- **Source**: [marzer/tomlplusplus](https://github.com/marzer/tomlplusplus)

## Usage

Add to your `ezmk.toml`:
```toml
[depends]
lib = ["$name"]
```
"@ | Set-Content -Path "$pkgDir/README.md" -Encoding UTF8
Write-Host "Done: $name v$version"

# 2. eigen — linear algebra (header-only)
$name = "eigen"
$version = "3.4.0"
$pkgDir = "$sourcesDir/$name"
$eigenZip = "$downloadDir/eigen-3.4.0.zip"
if (-not (Test-Path $eigenZip)) {
    Write-Host "Downloading Eigen..."
    try {
        Invoke-WebRequest -Uri "https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.zip" -OutFile $eigenZip -TimeoutSec 120
    } catch {
        Write-Host "  FAILED to download Eigen: $_"
    }
}
if (Test-Path $eigenZip) {
    if (Test-Path $pkgDir) { Remove-Item -Recurse -Force $pkgDir }
    $extractDir = "$downloadDir/eigen-extract"
    if (Test-Path $extractDir) { Remove-Item -Recurse -Force $extractDir }
    Expand-Archive -Path $eigenZip -DestinationPath $extractDir -Force
    $eigenSrc = Get-ChildItem $extractDir -Directory | Select-Object -First 1
    New-Item -ItemType Directory -Force -Path "$pkgDir/include" | Out-Null
    Copy-Item -Recurse "$($eigenSrc.FullName)/Eigen" "$pkgDir/include/Eigen"
    # Also copy unsupported if available
    if (Test-Path "$($eigenSrc.FullName)/unsupported") {
        Copy-Item -Recurse "$($eigenSrc.FullName)/unsupported" "$pkgDir/include/"
    }
    Remove-Item -Recurse -Force $extractDir
    @"
[project]
name = "$name"
type = "static"
version = "$version"
language = "C++17"
header_only = true

[compile]
include_dirs = ["include"]
flags = []
"@ | Set-Content -Path "$pkgDir/ezmk.toml" -Encoding UTF8
    @"
# $name

Eigen — C++ template library for linear algebra

- **Version**: $version
- **License**: MPL-2.0
- **Type**: Header-only
- **Source**: [libeigen/eigen](https://gitlab.com/libeigen/eigen)

## Usage

Add to your `ezmk.toml`:
```toml
[depends]
lib = ["$name"]
```
"@ | Set-Content -Path "$pkgDir/README.md" -Encoding UTF8
    Write-Host "Done: $name v$version"
} else {
    Write-Host "SKIP $name: download failed"
}

# 3. cpp-httplib — single header file
$name = "cpp-httplib"
$version = "0.18.3"
$pkgDir = "$sourcesDir/$name"
if (-not (Test-Path $pkgDir)) { New-Item -ItemType Directory -Force -Path "$pkgDir/include" | Out-Null }
$httplibHpp = "$downloadDir/httplib.h"
if (-not (Test-Path $httplibHpp)) {
    Write-Host "Downloading cpp-httplib..."
    try {
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/yhirose/cpp-httplib/master/httplib.h" -OutFile $httplibHpp -TimeoutSec 60
    } catch {
        Write-Host "  FAILED: $_"
    }
}
if (Test-Path $httplibHpp) {
    Copy-Item $httplibHpp "$pkgDir/include/"
    @"
[project]
name = "$name"
type = "static"
version = "$version"
language = "C++11"
header_only = true

[compile]
include_dirs = ["include"]
flags = []

[depends]
want = ["openssl"]
"@ | Set-Content -Path "$pkgDir/ezmk.toml" -Encoding UTF8
    @"
# $name

cpp-httplib — C++11 single-header HTTP/HTTPS library

- **Version**: $version
- **License**: MIT
- **Type**: Header-only (optional OpenSSL for HTTPS)
- **Source**: [yhirose/cpp-httplib](https://github.com/yhirose/cpp-httplib)
- **Optional dependency**: openssl (for HTTPS support)

## Usage

Add to your `ezmk.toml`:
```toml
[depends]
lib = ["$name"]
```
"@ | Set-Content -Path "$pkgDir/README.md" -Encoding UTF8
    Write-Host "Done: $name v$version"
} else {
    Write-Host "SKIP $name: download failed"
}

# 4. msgpack-c — header-only mode
$name = "msgpack-c"
$version = "6.1.0"
$pkgDir = "$sourcesDir/$name"
$msgpackZip = "$downloadDir/msgpack-c-6.1.0.zip"
if (-not (Test-Path $msgpackZip)) {
    Write-Host "Downloading msgpack-c..."
    try {
        Invoke-WebRequest -Uri "https://github.com/msgpack/msgpack-c/archive/refs/tags/c-6.1.0.zip" -OutFile $msgpackZip -TimeoutSec 120
    } catch {
        Write-Host "  FAILED: $_"
    }
}
if (Test-Path $msgpackZip) {
    if (Test-Path $pkgDir) { Remove-Item -Recurse -Force $pkgDir }
    $extractDir = "$downloadDir/msgpack-extract"
    if (Test-Path $extractDir) { Remove-Item -Recurse -Force $extractDir }
    Expand-Archive -Path $msgpackZip -DestinationPath $extractDir -Force
    $msgSrc = Get-ChildItem $extractDir -Directory | Select-Object -First 1
    New-Item -ItemType Directory -Force -Path "$pkgDir/include" | Out-Null
    Copy-Item -Recurse "$($msgSrc.FullName)/include/*" "$pkgDir/include/"
    if (Test-Path "$($msgSrc.FullName)/src") { Copy-Item -Recurse "$($msgSrc.FullName)/src" "$pkgDir/" }
    Remove-Item -Recurse -Force $extractDir
    @"
[project]
name = "$name"
type = "static"
version = "$version"
language = "C11"
header_only = true

[compile]
include_dirs = ["include"]
flags = []
"@ | Set-Content -Path "$pkgDir/ezmk.toml" -Encoding UTF8
    @"
# $name

MessagePack — binary serialization format (C library)

- **Version**: $version
- **License**: BSL-1.0
- **Type**: Header-only (header-only mode)
- **Source**: [msgpack/msgpack-c](https://github.com/msgpack/msgpack-c)

## Usage

Add to your `ezmk.toml`:
```toml
[depends]
lib = ["$name"]
```
"@ | Set-Content -Path "$pkgDir/README.md" -Encoding UTF8
    Write-Host "Done: $name v$version"
} else {
    Write-Host "SKIP $name: download failed"
}

Write-Host "`nHeader-only packages done."
