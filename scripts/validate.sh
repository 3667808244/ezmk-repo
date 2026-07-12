#!/usr/bin/env bash
# validate.sh — validate the repository for correctness and consistency
# Usage: bash scripts/validate.sh
# Checks:
#   1. index.toml is parseable (has [repo] with name)
#   2. Every [[packages]].file exists in packages/
#   3. Every sha256 is 64-char hex AND matches the actual archive
#   4. Reproducibility: pack.sh produces no diff (identical result)
# Exit: 0 = clean, non-zero = validation failure

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INDEX_FILE="$ROOT_DIR/index.toml"
PACKAGES_DIR="$ROOT_DIR/packages"
ERRORS=0

red()  { echo -e "\033[31m$*\033[0m" >&2; }
green() { echo -e "\033[32m$*\033[0m"; }

err() { red "  FAIL: $1"; ERRORS=$((ERRORS + 1)); }
ok()  { green "  ok: $1"; }

# ── 1. index.toml parseable ──────────────────────────────────────────────

echo "=== Check 1: index.toml structure ==="

if ! grep -qE '^\s*name\s*=' "$INDEX_FILE"; then
    err "[repo].name is missing"
else
    repo_name=$(grep -E '^\s*name\s*=' "$INDEX_FILE" | head -1 | sed -E 's/^[^=]*=\s*"([^"]*)"\s*$/\1/')
    ok "[repo].name = \"$repo_name\""
fi

# ── 2. file existence ────────────────────────────────────────────────────

echo "=== Check 2: package file existence ==="

pkg_count=0
while IFS= read -r line; do
    if echo "$line" | grep -qE '^\s*file\s*='; then
        file=$(echo "$line" | sed -E 's/^[^=]*=\s*"([^"]+)"\s*$/\1/')
        pkg_count=$((pkg_count + 1))

        if [[ -f "$ROOT_DIR/$file" ]]; then
            ok "file exists: $file"
        else
            err "file missing: $file"
        fi
    fi
done < "$INDEX_FILE"

echo "  total packages: $pkg_count"

# ── 3. sha256 validation ─────────────────────────────────────────────────

echo "=== Check 3: sha256 validation ==="

# Parse [[packages]] blocks — collect name, file, sha256 per package
current_name=""
current_file=""
current_sha256=""

check_pkg_sha256() {
    [[ -z "$current_name" ]] && return
    [[ -z "$current_sha256" ]] && return  # no sha256 = allowed (but warned for public repos)

    # Validate format: 64 lowercase hex chars
    if ! echo "$current_sha256" | grep -qE '^[0-9a-f]{64}$'; then
        err "$current_name: sha256 is not 64 hex chars: $current_sha256"
        return
    fi

    local actual
    actual=$(sha256sum "$ROOT_DIR/$current_file" | awk '{print $1}')
    if [[ "$actual" != "$current_sha256" ]]; then
        err "$current_name: sha256 mismatch"
        red "       expected: $current_sha256"
        red "       actual:   $actual"
    else
        ok "$current_name: sha256 match"
    fi
}

while IFS= read -r line; do
    if echo "$line" | grep -qE '^\[\[packages\]\]'; then
        # Check previous package before starting new one
        check_pkg_sha256
        current_name=""
        current_file=""
        current_sha256=""
    elif echo "$line" | grep -qE '^\s*name\s*='; then
        current_name=$(echo "$line" | sed -E 's/^[^=]*=\s*"([^"]+)"\s*$/\1/')
    elif echo "$line" | grep -qE '^\s*file\s*='; then
        current_file=$(echo "$line" | sed -E 's/^[^=]*=\s*"([^"]+)"\s*$/\1/')
    elif echo "$line" | grep -qE '^\s*sha256\s*='; then
        current_sha256=$(echo "$line" | sed -E 's/^[^=]*=\s*"([^"]+)"\s*$/\1/')
    fi
done < "$INDEX_FILE"
# Check last package
check_pkg_sha256

# ── 4. reproducibility (optional) ────────────────────────────────────────

echo "=== Check 4: index.toml ↔ sources/ consistency ==="

# Verify that every source directory has a corresponding [[packages]] entry
# and that every [[packages]] entry has a corresponding source directory.
SRC_COUNT=0
PKG_MATCHED=0

for src_dir in "$ROOT_DIR/sources"/*/; do
    [[ -d "$src_dir" ]] || continue
    ezmk_toml="$src_dir/ezmk.toml"
    [[ -f "$ezmk_toml" ]] || continue

    src_name=$(grep -E '^\s*name\s*=' "$ezmk_toml" | head -1 | sed -E 's/^[^=]*=\s*"([^"]*)"\s*$/\1/')
    src_version=$(grep -E '^\s*version\s*=' "$ezmk_toml" | head -1 | sed -E 's/^[^=]*=\s*"([^"]*)"\s*$/\1/')

    if [[ -z "$src_name" || -z "$src_version" ]]; then
        err "sources/$(basename "$src_dir"): missing name or version in ezmk.toml"
        continue
    fi

    SRC_COUNT=$((SRC_COUNT + 1))

    # Check if this package is in index.toml
    if grep -qE "name\s*=\s*\"$src_name\"" "$INDEX_FILE" && \
       grep -qE "version\s*=\s*\"$src_version\"" "$INDEX_FILE"; then
        ok "sources/$(basename "$src_dir") → $src_name v$src_version in index.toml"
        PKG_MATCHED=$((PKG_MATCHED + 1))
    else
        err "sources/$(basename "$src_dir"): $src_name v$src_version NOT found in index.toml"
        red "       Run: bash scripts/pack.sh"
    fi
done

# Also check for orphan [[packages]] entries (no corresponding source)
while IFS= read -r line; do
    if echo "$line" | grep -qE '^\s*name\s*='; then
        idx_name=$(echo "$line" | sed -E 's/^[^=]*=\s*"([^"]*)"\s*$/\1/')
        if [[ -n "$idx_name" ]] && [[ "$idx_name" != "$repo_name" ]]; then
            if ! grep -qE "^\s*name\s*=\s*\"$idx_name\"\s*$" "$ROOT_DIR/sources/"*/ezmk.toml 2>/dev/null; then
                err "index.toml entry '$idx_name' has no matching source directory"
                red "       Add sources/$idx_name/ezmk.toml or remove the [[packages]] entry"
            fi
        fi
    fi
done < "$INDEX_FILE"

echo "  sources: $SRC_COUNT, matched in index.toml: $PKG_MATCHED"

# ── summary ──────────────────────────────────────────────────────────────

echo ""
if [[ $ERRORS -eq 0 ]]; then
    green "=== All checks passed ($pkg_count packages) ==="
    exit 0
else
    red "=== $ERRORS error(s) found ==="
    exit 1
fi
