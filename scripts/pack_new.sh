#!/usr/bin/env bash
# pack_new.sh — Pack new 0.9.7 packages and append to index.toml
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCES_DIR="$ROOT_DIR/sources"
PACKAGES_DIR="$ROOT_DIR/packages"
INDEX_FILE="$ROOT_DIR/index.toml"

NEW_PKGS=(
    "cli11" "zlib" "glfw" "yaml-cpp" "sdl2" "imgui"
    "imgui-glfw" "imgui-sdl2" "imgui-sdl3" "imgui-win32"
    "imgui-glut" "imgui-osx" "imgui-android"
    "imgui-opengl2" "imgui-opengl3" "imgui-vulkan"
    "imgui-dx9" "imgui-dx10" "imgui-dx11" "imgui-dx12"
    "imgui-metal" "imgui-wgpu"
)

toml_get() {
    local key="$1" file="$2"
    grep -E "^\s*${key}\s*=" "$file" | head -1 | sed -E 's/^[^=]*=\s*"([^"]*)"\s*$/\1/'
}

sha256_file() {
    sha256sum "$1" | awk '{print $1}'
}

mkdir -p "$PACKAGES_DIR"

echo "[pack_new] Packing ${#NEW_PKGS[@]} new packages..."

# Read existing package names
declare -A EXISTING
while IFS= read -r line; do
    if [[ "$line" =~ name[[:space:]]*=[[:space:]]*\"(.+)\" ]]; then
        EXISTING["${BASH_REMATCH[1]}"]=1
    fi
done < "$INDEX_FILE" || true

packed=0
skipped=0
declare -a NEW_ENTRIES=()

for pkg in "${NEW_PKGS[@]}"; do
    ezmk_toml="$SOURCES_DIR/$pkg/ezmk.toml"

    if [ ! -f "$ezmk_toml" ]; then
        echo "[pack_new] WARNING: $pkg — no ezmk.toml, skipping"
        continue
    fi

    name=$(toml_get "name" "$ezmk_toml")
    version=$(toml_get "version" "$ezmk_toml")

    if [ -z "$name" ] || [ -z "$version" ]; then
        echo "[pack_new] WARNING: $pkg — missing name or version, skipping"
        continue
    fi

    # Check if already in index.toml
    if [ -n "${EXISTING[$name]:-}" ]; then
        echo "[pack_new] SKIP: $name v$version — already in index.toml"
        skipped=$((skipped + 1))
        continue
    fi

    archive_name="${name}-${version}.tar.gz"
    archive_path="$PACKAGES_DIR/$archive_name"

    echo "[pack_new] Packaging: $name v$version -> $archive_name"

    # Create archive from source directory
    (cd "$SOURCES_DIR" && tar czf "$archive_path" \
        --exclude='.ezmk' --exclude='build' --exclude='.git' \
        "$pkg")

    sha256=$(sha256_file "$archive_path")
    echo "[pack_new]   sha256: $sha256"

    NEW_ENTRIES+=("[[packages]]
name = \"$name\"
version = \"$version\"
file = \"packages/$archive_name\"
sha256 = \"$sha256\"
")
    packed=$((packed + 1))
done

# Append to index.toml
if [ ${#NEW_ENTRIES[@]} -gt 0 ]; then
    {
        echo ""
        for entry in "${NEW_ENTRIES[@]}"; do
            echo "$entry"
        done
    } >> "$INDEX_FILE"
    echo "[pack_new] Appended ${#NEW_ENTRIES[@]} entries to index.toml"
fi

echo "[pack_new] Done: $packed packed, $skipped skipped"
