#!/usr/bin/env bash
# pack.sh — pack all sources into archives, compute sha256, regenerate index.toml
# Usage: bash scripts/pack.sh
# Prerequisites: bash, tar, sha256sum, git (for clean check)

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCES_DIR="$ROOT_DIR/sources"
PACKAGES_DIR="$ROOT_DIR/packages"
INDEX_FILE="$ROOT_DIR/index.toml"

# ── helpers ──────────────────────────────────────────────────────────────

# Read a value from a simple TOML key=value line (no sections).
# Usage: toml_get <key> <file>
toml_get() {
    local key="$1" file="$2"
    grep -E "^\s*${key}\s*=" "$file" | head -1 | sed -E 's/^[^=]*=\s*"([^"]*)"\s*$/\1/'
}

# Compute SHA-256 of a file, output 64 hex chars lowercased.
sha256_file() {
    local file="$1"
    sha256sum "$file" | awk '{print $1}'
}

# ── pre-flight ───────────────────────────────────────────────────────────

echo "[pack] Root: $ROOT_DIR"

# Ensure packages/ exists
mkdir -p "$PACKAGES_DIR"

# Clean existing packages to ensure fresh build
echo "[pack] Cleaning packages/ ..."
rm -f "$PACKAGES_DIR"/*.tar.gz "$PACKAGES_DIR"/*.zip

# ── pack each source ─────────────────────────────────────────────────────

# Collect package entries for index.toml generation
declare -a PKG_ENTRIES=()

for src_dir in "$SOURCES_DIR"/*/; do
    [[ -d "$src_dir" ]] || continue

    ezmk_toml="$src_dir/ezmk.toml"
    if [[ ! -f "$ezmk_toml" ]]; then
        echo "[pack] WARNING: $src_dir has no ezmk.toml — skipping"
        continue
    fi

    name=$(toml_get "name" "$ezmk_toml")
    version=$(toml_get "version" "$ezmk_toml")

    if [[ -z "$name" || -z "$version" ]]; then
        echo "[pack] WARNING: $src_dir missing name or version — skipping"
        continue
    fi

    archive_name="${name}-${version}.tar.gz"
    archive_path="$PACKAGES_DIR/$archive_name"

    echo "[pack] Packaging: $name v$version → $archive_name"

    # Create archive from source directory (relative to sources/)
    # Exclude .ezmk/, build/, and any git artifacts
    # Note: archive reproducibility depends on the tar implementation;
    # CI validates consistency via git diff rather than byte-identical archives.
    (cd "$SOURCES_DIR" && tar czf "$archive_path" \
        --exclude='.ezmk' \
        --exclude='build' \
        --exclude='.git' \
        "$(basename "$src_dir")")

    # Compute sha256
    sha256=$(sha256_file "$archive_path")
    echo "[pack]   sha256: $sha256"

    # Collect entry
    PKG_ENTRIES+=("[[packages]]
name = \"$name\"
version = \"$version\"
file = \"packages/$archive_name\"
sha256 = \"$sha256\"
")
done

# ── regenerate index.toml ────────────────────────────────────────────────

echo "[pack] Regenerating index.toml ..."

# Preserve [repo] section, rewrite [[packages]]
# Extract [repo] header (everything before first [[packages]] or EOF)
repo_header=$(awk 'BEGIN{p=1} /^\[\[packages\]\]/{p=0} p' "$INDEX_FILE" 2>/dev/null || true)
if [[ -z "$repo_header" ]]; then
    repo_header="[repo]
name = \"official\"
description = \"EazyMake official package repository\""
fi

{
    echo "$repo_header"
    echo ""
    for entry in "${PKG_ENTRIES[@]}"; do
        echo "$entry"
    done
} > "$INDEX_FILE"

echo "[pack] Done. Packages: ${#PKG_ENTRIES[@]}"
