# 1.1.0-dev.7: Create ezmk.toml + README.md for all 22 new packages
# Source downloads will happen when network is available.
$ErrorActionPreference = "Continue"
$sourcesDir = "E:\claude_workspace\ezmk-repo\sources"
New-Item -ItemType Directory -Force -Path $sourcesDir | Out-Null

function New-Pkg($name, $version, $lang, $type, $deps, $desc, $sourceUrl, $wantDeps, $extraFields) {
    $pkgDir = "$sourcesDir/$name"
    New-Item -ItemType Directory -Force -Path $pkgDir | Out-Null
    if ($type -eq "header_only") {
        New-Item -ItemType Directory -Force -Path "$pkgDir/include" | Out-Null
    } else {
        New-Item -ItemType Directory -Force -Path "$pkgDir/include" | Out-Null
        New-Item -ItemType Directory -Force -Path "$pkgDir/src" | Out-Null
    }

    $toml = @()
    $toml += '[project]'
    $toml += "name = `"$name`""
    $toml += 'type = "static"'
    $toml += "version = `"$version`""
    $toml += "language = `"$lang`""
    if ($type -eq "header_only") { $toml += 'header_only = true' }
    if ($type -eq "precompiled") { $toml += 'precompiled = true' }
    if ($extraFields) { $toml += $extraFields }
    $toml += ''
    $toml += '[compile]'
    $toml += 'include_dirs = ["include"]'
    if ($type -ne "header_only" -and $type -ne "precompiled") { $toml += 'src_dirs = ["src"]' }
    $toml += 'flags = []'
    if ($deps -or $wantDeps) {
        $toml += ''
        if ($deps) { $toml += '[depends]'; $deps_str = ($deps | ForEach-Object { "`"$_`"" }) -join ", "; $toml += "lib = [$deps_str]" }
        if ($wantDeps) { $want_str = ($wantDeps | ForEach-Object { "`"$_`"" }) -join ", "; $toml += "want = [$want_str]" }
    }
    $toml -join "`n" | Set-Content -Path "$pkgDir/ezmk.toml" -Encoding UTF8

    $readme = @("# $name"; ''; $desc; ''; "- **Version**: $version"; "- **Type**: $type"; "- **Source**: $sourceUrl")
    if ($deps) { $readme += "- **Dependencies**: $($deps -join ', ')" }
    if ($wantDeps) { $readme += "- **Optional dependencies**: $($wantDeps -join ', ')" }
    $readme += ''; $readme += '## Usage'; $readme += ''; $readme += 'Add to your `ezmk.toml`:'; $readme += '```toml'; $readme += '[depends]'; $readme += "lib = [`"$name`"]"; $readme += '```'
    $readme -join "`n" | Set-Content -Path "$pkgDir/README.md" -Encoding UTF8

    Write-Host "  Created: $name v$version"
}

Write-Host "=== Header-only packages ==="
New-Pkg "tomlplusplus" "3.4.0" "C++17" "header_only" @() "Header-only C++17 TOML parser (single-file)" "https://github.com/marzer/tomlplusplus"
New-Pkg "eigen" "3.4.0" "C++17" "header_only" @() "C++ template library for linear algebra: matrices, vectors, numerical solvers" "https://gitlab.com/libeigen/eigen"
New-Pkg "cpp-httplib" "0.18.3" "C++11" "header_only" @() "C++11 single-header HTTP/HTTPS client and server library" "https://github.com/yhirose/cpp-httplib" @("openssl")
New-Pkg "msgpack-c" "6.1.0" "C11" "header_only" @() "MessagePack binary serialization (header-only mode)" "https://github.com/msgpack/msgpack-c"

Write-Host "=== Source-compiled packages ==="
New-Pkg "hiredis" "1.2.0" "C11" "source" @() "Minimalistic C client for Redis" "https://github.com/redis/hiredis"
New-Pkg "sqlitecpp" "3.3.0" "C++17" "source" @("sqlite3") "C++ SQLite3 wrapper (RAII, exception-safe)" "https://github.com/SRombauts/SQLiteCpp"

Write-Host "=== Precompiled packages (complex builds) ==="
New-Pkg "openssl" "3.4.0" "C11" "precompiled" @() "TLS/SSL cryptographic library" "https://github.com/openssl/openssl" @() @'
[link]
system_target = ["ws2_32", "crypt32"]
'@
New-Pkg "libcurl" "8.11.0" "C11" "precompiled" @("openssl", "zlib") "Multi-protocol file transfer library (HTTP/HTTPS/FTP/...)" "https://github.com/curl/curl" @() @'
[link]
system_target = ["ws2_32", "wldap32", "crypt32"]
'@
New-Pkg "protobuf" "28.3" "C++17" "precompiled" @() "Protocol Buffers — structured data serialization (library + protoc)" "https://github.com/protocolbuffers/protobuf"
New-Pkg "gRPC" "1.68.0" "C++17" "precompiled" @("protobuf", "openssl") "High-performance RPC framework (minimal build, no abseil)" "https://github.com/grpc/grpc"
New-Pkg "libpqxx" "7.9.2" "C++17" "source" @() "Official C++ client API for PostgreSQL" "https://github.com/jtv/libpqxx" @() @"
# NOTE: Requires libpq (PostgreSQL C client). On MSYS2: pacman -S mingw-w64-ucrt-x86_64-postgresql
# First release targets Linux/macOS; Windows support pending libpq availability.
"@

Write-Host "=== Test framework (source-compiled) ==="
New-Pkg "googletest" "1.15.2" "C++17" "source" @() "GoogleTest + GoogleMock C++ testing framework" "https://github.com/google/googletest"

Write-Host "`nAll 12 new non-Boost package structures created."
Write-Host "NOTE: Sources need to be downloaded and placed in the src/ directories."
