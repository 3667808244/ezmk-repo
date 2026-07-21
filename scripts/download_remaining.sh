#!/usr/bin/env bash
# download_remaining.sh — Download and organize glfw, yaml-cpp, sdl2 sources
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCES_DIR="$ROOT_DIR/sources"
TMP_DIR="${TMPDIR:-/tmp}/ezmk_pkg_dl"
mkdir -p "$TMP_DIR"

download() {
    local url="$1" dest="$2"
    echo "  downloading: $url"
    curl -fsSL --retry 3 -o "$dest" "$url" || { echo "  FAILED: $url"; return 1; }
}

# ═══════════════════════════════════════════════════════════════════
# glfw 3.4
# ═══════════════════════════════════════════════════════════════════
setup_glfw() {
    echo ""
    echo "=== glfw 3.4 ==="
    local pkg="$SOURCES_DIR/glfw"
    rm -rf "${TMP_DIR}/glfw"*
    download "https://github.com/glfw/glfw/archive/refs/tags/3.4.tar.gz" \
        "${TMP_DIR}/glfw-3.4.tar.gz"

    rm -rf "${TMP_DIR}/glfw-src"
    mkdir -p "${TMP_DIR}/glfw-src"
    tar xzf "${TMP_DIR}/glfw-3.4.tar.gz" -C "${TMP_DIR}/glfw-src" --strip-components=1

    local src="${TMP_DIR}/glfw-src"

    # Headers
    rm -rf "$pkg/include"
    mkdir -p "$pkg/include/GLFW"
    cp "$src/include/GLFW/"*.h "$pkg/include/GLFW/" 2>/dev/null || true
    echo "  headers: $(ls "$pkg/include/GLFW/"*.h 2>/dev/null | wc -l) files"

    # Source files — core GLFW (cross-platform)
    rm -rf "$pkg/src"
    mkdir -p "$pkg/src"
    local core_files=(
        "context.c" "egl_context.c" "glx_context.c" "init.c" "input.c"
        "monitor.c" "null_context.c" "null_init.c" "null_monitor.c" "null_window.c"
        "osmesa_context.c" "platform.c" "vulkan.c" "wgl_context.c" "win32_init.c"
        "win32_joystick.c" "win32_module.c" "win32_monitor.c" "win32_thread.c"
        "win32_time.c" "win32_window.c" "window.c"
        "x11_init.c" "x11_monitor.c" "x11_window.c" "xkb_unicode.c"
        "x11_platform.h" "x11_platform.h"
        "wl_init.c" "wl_monitor.c" "wl_window.c"
        "cocoa_init.m" "cocoa_joystick.m" "cocoa_monitor.m" "cocoa_window.m" "cocoa_time.c"
        "posix_module.c" "posix_thread.c" "posix_time.c"
        "linux_joystick.c"
        "internal.h" "mappings.h"
        "null_joystick.c"
    )
    for f in "${core_files[@]}"; do
        if [ -f "$src/src/$f" ]; then
            cp "$src/src/$f" "$pkg/src/"
        fi
    done
    echo "  sources: $(ls "$pkg/src/" 2>/dev/null | wc -l) files"
    echo "glfw done"
}

# ═══════════════════════════════════════════════════════════════════
# yaml-cpp 0.8.0
# ═══════════════════════════════════════════════════════════════════
setup_yaml_cpp() {
    echo ""
    echo "=== yaml-cpp 0.8.0 ==="
    local pkg="$SOURCES_DIR/yaml-cpp"
    rm -rf "${TMP_DIR}/yaml-cpp"*
    download "https://github.com/jbeder/yaml-cpp/archive/refs/tags/0.8.0.tar.gz" \
        "${TMP_DIR}/yaml-cpp-0.8.0.tar.gz"

    rm -rf "${TMP_DIR}/yaml-cpp-src"
    mkdir -p "${TMP_DIR}/yaml-cpp-src"
    tar xzf "${TMP_DIR}/yaml-cpp-0.8.0.tar.gz" -C "${TMP_DIR}/yaml-cpp-src" --strip-components=1

    local src="${TMP_DIR}/yaml-cpp-src"

    # Headers
    rm -rf "$pkg/include"
    mkdir -p "$pkg/include/yaml-cpp"
    cp -r "$src/include/yaml-cpp/"* "$pkg/include/yaml-cpp/" 2>/dev/null || true
    echo "  headers: $(find "$pkg/include" -type f 2>/dev/null | wc -l) files"

    # Source files
    rm -rf "$pkg/src"
    mkdir -p "$pkg/src"
    cp "$src/src/"*.cpp "$pkg/src/" 2>/dev/null || true
    # yaml-cpp 0.8.0 reorganised — src/ contains subdirs but no top-level .cpp
    # Actual impl is in src/*.cpp
    echo "  sources top: $(ls "$pkg/src/"*.cpp 2>/dev/null | wc -l) files"
    # Also check subdirectories
    for sub in "$src/src/"*/; do
        [ -d "$sub" ] || continue
        local subname=$(basename "$sub")
        # Skip contrib — not needed for basic usage
        [ "$subname" = "contrib" ] && continue
        cp "$sub"*.cpp "$pkg/src/" 2>/dev/null || true
    done
    echo "  sources total: $(ls "$pkg/src/"*.cpp 2>/dev/null | wc -l) files"

    # If still empty, copy everything from src/
    if [ "$(ls "$pkg/src/"*.cpp 2>/dev/null | wc -l)" -eq 0 ]; then
        echo "  trying flat copy..."
        find "$src/src" -name '*.cpp' -exec cp {} "$pkg/src/" \;
        echo "  sources flat: $(ls "$pkg/src/"*.cpp 2>/dev/null | wc -l) files"
    fi

    echo "yaml-cpp done"
}

# ═══════════════════════════════════════════════════════════════════
# sdl2 2.30.12
# ═══════════════════════════════════════════════════════════════════
setup_sdl2() {
    echo ""
    echo "=== sdl2 2.30.12 ==="
    local pkg="$SOURCES_DIR/sdl2"
    rm -rf "${TMP_DIR}/sdl2"*
    download "https://github.com/libsdl-org/SDL/archive/refs/tags/release-2.30.12.tar.gz" \
        "${TMP_DIR}/sdl2-2.30.12.tar.gz"

    rm -rf "${TMP_DIR}/sdl2-src"
    mkdir -p "${TMP_DIR}/sdl2-src"
    tar xzf "${TMP_DIR}/sdl2-2.30.12.tar.gz" -C "${TMP_DIR}/sdl2-src" --strip-components=1

    local src="${TMP_DIR}/sdl2-src"

    # Headers
    rm -rf "$pkg/include"
    mkdir -p "$pkg/include/SDL2"
    cp "$src/include/"*.h "$pkg/include/SDL2/" 2>/dev/null || true
    echo "  headers: $(ls "$pkg/include/SDL2/"*.h 2>/dev/null | wc -l) files"

    # Source files — flat collection
    rm -rf "$pkg/src"
    mkdir -p "$pkg/src"
    # Top-level src/*.c
    cp "$src/src/"*.c "$pkg/src/" 2>/dev/null || true
    # Subdirectories
    for sub in "$src/src/"*/; do
        [ -d "$sub" ] || continue
        local subname=$(basename "$sub")
        # dynapi is just a stub
        [ "$subname" = "dynapi" ] && continue
        cp "$sub"*.c "$pkg/src/" 2>/dev/null || true
        cp "$sub"*.h "$pkg/src/" 2>/dev/null || true
    done
    echo "  sources: $(ls "$pkg/src/"*.c 2>/dev/null | wc -l) files"
    echo "sdl2 done"
}

# ── main ──────────────────────────────────────────────────────────
echo "=== Downloading remaining package sources ==="
setup_glfw
setup_yaml_cpp
setup_sdl2
echo ""
echo "=== All done ==="
