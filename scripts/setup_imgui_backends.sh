#!/usr/bin/env bash
# setup_imgui_backends.sh — Copy imgui backend files from extracted source
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCES_DIR="$ROOT_DIR/sources"
IMGUI_SRC="/tmp/imgui-1.91.9"

if [ ! -d "$IMGUI_SRC" ]; then
    echo "Error: imgui source not found at $IMGUI_SRC"
    echo "Run: curl -fsSL -o /tmp/imgui.tar.gz https://github.com/ocornut/imgui/archive/refs/tags/v1.91.9.tar.gz"
    echo "     tar xzf /tmp/imgui.tar.gz -C /tmp/"
    exit 1
fi

BACKENDS=(
    "glfw:imgui_impl_glfw.h:imgui_impl_glfw.cpp"
    "sdl2:imgui_impl_sdl2.h:imgui_impl_sdl2.cpp"
    "sdl3:imgui_impl_sdl3.h:imgui_impl_sdl3.cpp"
    "win32:imgui_impl_win32.h:imgui_impl_win32.cpp"
    "glut:imgui_impl_glut.h:imgui_impl_glut.cpp"
    "osx:imgui_impl_osx.h:imgui_impl_osx.mm"
    "android:imgui_impl_android.h:imgui_impl_android.cpp"
    "opengl2:imgui_impl_opengl2.h:imgui_impl_opengl2.cpp"
    "opengl3:imgui_impl_opengl3.h:imgui_impl_opengl3.cpp"
    "vulkan:imgui_impl_vulkan.h:imgui_impl_vulkan.cpp"
    "dx9:imgui_impl_dx9.h:imgui_impl_dx9.cpp"
    "dx10:imgui_impl_dx10.h:imgui_impl_dx10.cpp"
    "dx11:imgui_impl_dx11.h:imgui_impl_dx11.cpp"
    "dx12:imgui_impl_dx12.h:imgui_impl_dx12.cpp"
    "metal:imgui_impl_metal.h:imgui_impl_metal.mm"
    "wgpu:imgui_impl_wgpu.h:imgui_impl_wgpu.cpp"
)

for entry in "${BACKENDS[@]}"; do
    IFS=':' read -r name header source <<< "$entry"
    pkg="imgui-${name}"
    echo "[${pkg}]"

    mkdir -p "${SOURCES_DIR}/${pkg}/include/imgui/backends"
    mkdir -p "${SOURCES_DIR}/${pkg}/src"

    cp "${IMGUI_SRC}/backends/${header}" "${SOURCES_DIR}/${pkg}/include/imgui/backends/" 2>/dev/null || \
        echo "  WARNING: ${header} not found"

    if [ -f "${IMGUI_SRC}/backends/${source}" ]; then
        cp "${IMGUI_SRC}/backends/${source}" "${SOURCES_DIR}/${pkg}/src/"
    else
        echo "  WARNING: ${source} not found"
    fi

    echo "  done"
done

echo "=== All imgui backends set up ==="
