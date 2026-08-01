# Create 10 new Boost header-only packages (1.1.0-dev.7)
# Extends the existing 10 Boost packages from 0.9.8
$ErrorActionPreference = "Continue"
$sourcesDir = "E:\claude_workspace\ezmk-repo\sources"
$boostTemp = "E:\claude_workspace\ezmk-repo\boost_temp"
$boostVersion = "1.88.0"

# New Boost packages for 1.1.0-dev.7
$packages = @(
    @{name="boost-asio";          repo="asio";          desc="Asynchronous I/O networking (header-only mode)";     deps=@("boost-config", "boost-assert", "boost-core", "boost-system")}
    @{name="boost-beast";        repo="beast";         desc="HTTP/WebSocket library built on Asio";                deps=@("boost-config", "boost-assert", "boost-core", "boost-asio", "boost-system", "boost-smart-ptr")}
    @{name="boost-filesystem";   repo="filesystem";    desc="Cross-platform filesystem operations (header-only)";  deps=@("boost-config", "boost-assert", "boost-core", "boost-system")}
    @{name="boost-system";       repo="system";        desc="Error code infrastructure (Asio/Beast/Filesystem dep)"; deps=@("boost-config", "boost-assert", "boost-core")}
    @{name="boost-smart-ptr";    repo="smart_ptr";     desc="Smart pointers (shared_ptr/intrusive_ptr/local_shared_ptr)"; deps=@("boost-config", "boost-assert", "boost-core", "boost-throw-exception")}
    @{name="boost-tokenizer";    repo="tokenizer";     desc="String tokenizer / splitter";                         deps=@("boost-config", "boost-assert")}
    @{name="boost-uuid";         repo="uuid";          desc="Universally unique identifiers";                       deps=@("boost-config", "boost-assert", "boost-core", "boost-static-assert", "boost-throw-exception", "boost-optional", "boost-algorithm")}
    @{name="boost-random";       repo="random";        desc="Random number generation (header-only subset)";        deps=@("boost-config", "boost-assert", "boost-core", "boost-static-assert", "boost-throw-exception")}
    @{name="boost-math";         repo="math";          desc="Mathematical special functions (header-only)";          deps=@("boost-config", "boost-assert", "boost-core", "boost-static-assert", "boost-throw-exception")}
    @{name="boost-functional";   repo="functional";    desc="Function object adapters (hash/bind/function)";         deps=@("boost-config", "boost-assert", "boost-core", "boost-static-assert", "boost-throw-exception")}
)

New-Item -ItemType Directory -Force -Path $boostTemp | Out-Null

foreach ($pkg in $packages) {
    $name = $pkg.name
    $repo = $pkg.repo
    $pkgDir = Join-Path $sourcesDir $name
    $includeDir = Join-Path $pkgDir "include"
    $boostIncludeDir = Join-Path $includeDir "boost"

    Write-Host "--- $name (boostorg/$repo) ---"

    # Clone the boostorg repo if not already done
    $cloneDir = Join-Path $boostTemp $repo
    if (-not (Test-Path $cloneDir)) {
        $url = "https://github.com/boostorg/$repo.git"
        Write-Host "  Cloning $url ..."
        Push-Location $boostTemp
        $result = git -c http.sslBackend=openssl clone --depth 1 --single-branch $url $repo 2>&1
        Pop-Location
        if (-not (Test-Path $cloneDir)) {
            Write-Host "  FAILED to clone $repo — skipping"
            continue
        }
        Start-Sleep -Milliseconds 500  # throttle to avoid rate limiting
    } else {
        Write-Host "  Already cloned: $cloneDir"
    }

    # Remove existing package dir
    if (Test-Path $pkgDir) { Remove-Item -Recurse -Force $pkgDir }

    # Create include/boost/ directory
    New-Item -ItemType Directory -Force -Path $boostIncludeDir | Out-Null

    # Copy headers from the repo's include/boost/ directory
    $srcInclude = "$cloneDir/include/boost"
    if (Test-Path $srcInclude) {
        Copy-Item -Recurse "$srcInclude\*" $boostIncludeDir
        Write-Host "  Copied headers to include/boost/"
    } else {
        Write-Host "  WARNING: no include/boost/ in $cloneDir"
    }

    # Create ezmk.toml
    $toml = @()
    $toml += '[project]'
    $toml += "name = `"$name`""
    $toml += 'type = "static"'
    $toml += "version = `"$boostVersion`""
    $toml += 'language = "C++17"'
    $toml += 'header_only = true'
    $toml += ''
    $toml += '[compile]'
    $toml += 'include_dirs = ["include"]'
    $toml += 'flags = []'
    if ($pkg.deps.Count -gt 0) {
        $toml += ''
        $toml += '[depends]'
        $deps_str = ($pkg.deps | ForEach-Object { "`"$_`"" }) -join ", "
        $toml += "lib = [$deps_str]"
    }
    $toml -join "`n" | Set-Content -Path (Join-Path $pkgDir "ezmk.toml") -Encoding UTF8

    # Create README.md
    $readme = @()
    $readme += "# $name"
    $readme += ''
    $readme += "Boost.$($pkg.repo) — $($pkg.desc)"
    $readme += ''
    $readme += "- **Version**: $boostVersion (Boost release)"
    $readme += "- **License**: Boost Software License 1.0"
    $readme += "- **Type**: Header-only"
    $readme += "- **Source**: [boostorg/$repo](https://github.com/boostorg/$repo)"
    if ($pkg.deps.Count -gt 0) {
        $readme += "- **Dependencies**: $($pkg.deps -join ', ')"
    }
    $readme += ''
    $readme += '## Usage'
    $readme += ''
    $readme += 'Add to your `ezmk.toml`:'
    $readme += '```toml'
    $readme += '[depends]'
    $readme += "lib = [`"$name`"]"
    $readme += '```'
    $readme -join "`n" | Set-Content -Path (Join-Path $pkgDir "README.md") -Encoding UTF8

    Write-Host "  Done: $name v$boostVersion"
}

Write-Host "`nAll 10 new Boost packages created."
