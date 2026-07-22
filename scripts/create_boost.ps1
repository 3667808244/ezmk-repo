# Create Boost header-only packages from individual GitHub repos
# Each Boost sub-library lives at https://github.com/boostorg/<name>
$ErrorActionPreference = "Continue"
$sourcesDir = "E:\claude_workspace\ezmk-repo\sources"
$boostTemp = "E:\claude_workspace\ezmk-repo\boost_temp"
$boostVersion = "1.87.0"

# Boost packages: name -> [boostorg repo name(s), dependencies]
# Each package maps to one boostorg repo. Dependencies list other ezmk boost-* packages.
$packages = @(
    @{name="boost-config";           repo="config";            desc="Compiler/platform feature detection macros";              deps=@()}
    @{name="boost-assert";          repo="assert";            desc="Lightweight assertion macros (BOOST_ASSERT/BOOST_VERIFY)"; deps=@("boost-config")}
    @{name="boost-core";            repo="core";              desc="Core utilities (addressof, ref, noncopyable, checked_delete, etc.)"; deps=@("boost-config", "boost-assert")}
    @{name="boost-static-assert";   repo="static_assert";     desc="Compile-time assertions (BOOST_STATIC_ASSERT)";           deps=@("boost-config")}
    @{name="boost-throw-exception"; repo="throw_exception";   desc="Exception throwing utilities";                             deps=@("boost-config", "boost-assert")}
    @{name="boost-lexical-cast";    repo="lexical_cast";      desc="String-to-number and number-to-string conversions";       deps=@("boost-config", "boost-assert", "boost-core", "boost-static-assert", "boost-throw-exception")}
    @{name="boost-algorithm";       repo="algorithm";         desc="String algorithms (trim, split, join, starts_with, etc.)"; deps=@("boost-config", "boost-assert", "boost-core")}
    @{name="boost-optional";        repo="optional";          desc="Optional<T> — type-safe nullable value";                  deps=@("boost-config", "boost-assert", "boost-core", "boost-static-assert", "boost-throw-exception")}
    @{name="boost-variant2";        repo="variant2";          desc="Type-safe union (variant<Ts...>)";                         deps=@("boost-config", "boost-assert", "boost-mp11")}
    @{name="boost-mp11";           repo="mp11";              desc="C++11 metaprogramming library";                            deps=@("boost-config")}
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
        $result = bash -c "cd /e/claude_workspace/ezmk-repo/boost_temp && git clone --depth 1 $url $repo 2>&1"
        Write-Host "  Clone: $result"
        if (-not (Test-Path $cloneDir)) {
            Write-Host "  FAILED to clone $repo — skipping"
            continue
        }
    } else {
        Write-Host "  Already cloned: $cloneDir"
    }

    # Remove existing package dir
    if (Test-Path $pkgDir) { Remove-Item -Recurse -Force $pkgDir }

    # Create include/boost/ directory
    New-Item -ItemType Directory -Force -Path $boostIncludeDir | Out-Null

    # Copy headers from the repo's include/boost/ directory
    $srcInclude = Join-Path $cloneDir "include" "boost"
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

Write-Host "`nAll Boost packages created."
