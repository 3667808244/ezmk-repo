#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

PKGS=(imgui imgui-glfw imgui-sdl2 imgui-sdl3 imgui-win32 imgui-glut imgui-osx imgui-android
      imgui-opengl2 imgui-opengl3 imgui-vulkan imgui-dx9 imgui-dx10 imgui-dx11 imgui-dx12
      imgui-metal imgui-wgpu)

for pkg in "${PKGS[@]}"; do
    toml="sources/${pkg}/ezmk.toml"
    if [ ! -f "$toml" ]; then echo "SKIP $pkg: no ezmk.toml"; continue; fi
    version=$(grep -E '^\s*version\s*=' "$toml" | head -1 | sed -E 's/.*"([^"]*)".*/\1/')
    archive="packages/${pkg}-${version}.tar.gz"
    rm -f "$archive"
    (cd sources && tar czf "../${archive}" --exclude='.ezmk' --exclude='build' --exclude='.git' "$pkg")
    sha=$(sha256sum "$archive" | awk '{print $1}')
    echo "REPACKED: ${pkg}-${version}.tar.gz sha256=${sha}"
done
echo "Done"
