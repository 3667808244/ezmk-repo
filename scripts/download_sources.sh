#!/usr/bin/env bash
# download_sources.sh — Download and organize library source code for all packages
# Usage: bash scripts/download_sources.sh [pkg1 pkg2 ...]
# If no args, downloads all packages.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCES_DIR="$ROOT_DIR/sources"
TMP_DIR="${TMPDIR:-/tmp}/ezmk_pkg_sources"
mkdir -p "$TMP_DIR" "$SOURCES_DIR"

# ── helpers ────────────────────────────────────────────

download() {
    local url="$1" dest="$2"
    echo "  downloading: $url"
    curl -fsSL --retry 3 -o "$dest" "$url" || { echo "  FAILED: $url"; return 1; }
}

extract_tar() {
    local archive="$1" dest="$2"
    echo "  extracting to: $dest"
    mkdir -p "$dest"
    tar xzf "$archive" -C "$dest" --strip-components=1 2>/dev/null || tar xzf "$archive" -C "$dest"
}

extract_zip() {
    local archive="$1" dest="$2"
    echo "  extracting to: $dest"
    mkdir -p "$dest"
    unzip -qo "$archive" -d "$dest" 2>/dev/null
    # If there's a single subdirectory, flatten it
    local subdirs=("$dest"/*/)
    if [ ${#subdirs[@]} -eq 1 ] && [ -d "${subdirs[0]}" ]; then
        mv "${subdirs[0]}"/* "$dest/" 2>/dev/null || true
        rmdir "${subdirs[0]}" 2>/dev/null || true
    fi
}

clean_tmp() { rm -rf "$TMP_DIR"; mkdir -p "$TMP_DIR"; }

# ── cli11 v2.5.0 (header-only) ────────────────────────

pkg_cli11() {
    echo "[cli11] v2.5.0 (header-only)"
    local pkg="$SOURCES_DIR/cli11"
    mkdir -p "$pkg/include/CLI"
    download "https://github.com/CLIUtils/CLI11/releases/download/v2.5.0/CLI11.hpp" \
        "$pkg/include/CLI/CLI11.hpp"
    echo "[cli11] done"
}

# ── zlib v1.3.1 ──────────────────────────────────────

pkg_zlib() {
    echo "[zlib] v1.3.1"
    local pkg="$SOURCES_DIR/zlib"
    clean_tmp
    download "https://github.com/madler/zlib/archive/refs/tags/v1.3.1.tar.gz" "$TMP_DIR/zlib-1.3.1.tar.gz"
    extract_tar "$TMP_DIR/zlib-1.3.1.tar.gz" "$TMP_DIR/zlib-src"

    # Headers
    mkdir -p "$pkg/include"
    cp "$TMP_DIR/zlib-src/"*.h "$pkg/include/" 2>/dev/null || true

    # Source files
    mkdir -p "$pkg/src"
    local src_files=("adler32.c" "compress.c" "crc32.c" "deflate.c" "gzclose.c"
        "gzlib.c" "gzread.c" "gzwrite.c" "infback.c" "inffast.c" "inflate.c"
        "inftrees.c" "trees.c" "uncompr.c" "zutil.c")
    for f in "${src_files[@]}"; do
        [ -f "$TMP_DIR/zlib-src/$f" ] && cp "$TMP_DIR/zlib-src/$f" "$pkg/src/"
    done
    echo "[zlib] done"
}

# ── glfw v3.4 ────────────────────────────────────────

pkg_glfw() {
    echo "[glfw] v3.4"
    local pkg="$SOURCES_DIR/glfw"
    clean_tmp
    download "https://github.com/glfw/glfw/archive/refs/tags/3.4.tar.gz" \
        "$TMP_DIR/glfw-3.4.tar.gz"
    extract_tar "$TMP_DIR/glfw-3.4.tar.gz" "$TMP_DIR/glfw-src"

    # Headers
    mkdir -p "$pkg/include/GLFW"
    cp "$TMP_DIR/glfw-src/include/GLFW/"*.h "$pkg/include/GLFW/" 2>/dev/null || true

    # Source files (core GLFW sources)
    mkdir -p "$pkg/src"
    local src_files=("context.c" "egl_context.c" "glx_context.c" "init.c" "input.c"
        "monitor.c" "null_context.c" "null_init.c" "null_monitor.c" "null_window.c"
        "osmesa_context.c" "platform.c" "vulkan.c" "wgl_context.c" "win32_init.c"
        "win32_joystick.c" "win32_module.c" "win32_monitor.c" "win32_thread.c"
        "win32_time.c" "win32_window.c" "window.c")
    for f in "${src_files[@]}"; do
        [ -f "$TMP_DIR/glfw-src/src/$f" ] && cp "$TMP_DIR/glfw-src/src/$f" "$pkg/src/"
    done

    # Internal header
    mkdir -p "$pkg/src"
    cp "$TMP_DIR/glfw-src/src/internal.h" "$pkg/src/" 2>/dev/null || true

    echo "[glfw] done"
}

# ── yaml-cpp v0.8.0 ─────────────────────────────────

pkg_yaml_cpp() {
    echo "[yaml-cpp] v0.8.0"
    local pkg="$SOURCES_DIR/yaml-cpp"
    clean_tmp
    download "https://github.com/jbeder/yaml-cpp/archive/refs/tags/0.8.0.tar.gz" \
        "$TMP_DIR/yaml-cpp-0.8.0.tar.gz"
    extract_tar "$TMP_DIR/yaml-cpp-0.8.0.tar.gz" "$TMP_DIR/yaml-cpp-src"

    # Headers
    mkdir -p "$pkg/include/yaml-cpp"
    cp -r "$TMP_DIR/yaml-cpp-src/include/yaml-cpp/"* "$pkg/include/yaml-cpp/" 2>/dev/null || true

    # Source files
    mkdir -p "$pkg/src"
    cp "$TMP_DIR/yaml-cpp-src/src/"*.cpp "$pkg/src/" 2>/dev/null || true
    # Contrib sources (optional, some builds need them)
    if [ -d "$TMP_DIR/yaml-cpp-src/src/contrib" ]; then
        cp "$TMP_DIR/yaml-cpp-src/src/contrib/"*.cpp "$pkg/src/" 2>/dev/null || true
    fi

    echo "[yaml-cpp] done"
}

# ── sdl2 v2.30.12 ───────────────────────────────────

pkg_sdl2() {
    echo "[sdl2] v2.30.12"
    local pkg="$SOURCES_DIR/sdl2"
    clean_tmp
    download "https://github.com/libsdl-org/SDL/archive/refs/tags/release-2.30.12.tar.gz" \
        "$TMP_DIR/sdl2-2.30.12.tar.gz"
    extract_tar "$TMP_DIR/sdl2-2.30.12.tar.gz" "$TMP_DIR/sdl2-src"

    # Headers
    mkdir -p "$pkg/include/SDL2"
    cp "$TMP_DIR/sdl2-src/include/"*.h "$pkg/include/SDL2/" 2>/dev/null || true

    # Source files
    mkdir -p "$pkg/src"
    cp "$TMP_DIR/sdl2-src/src/"*.c "$pkg/src/" 2>/dev/null || true

    # Platform-specific sources
    for dir in "$TMP_DIR/sdl2-src/src/"*/; do
        local dirname=$(basename "$dir")
        mkdir -p "$pkg/src/$dirname"
        cp "$dir"*.c "$pkg/src/$dirname/" 2>/dev/null || true
    done

    # Dynamically loaded subsystems
    if [ -d "$TMP_DIR/sdl2-src/src/dynapi" ]; then
        mkdir -p "$pkg/src/dynapi"
        cp "$TMP_DIR/sdl2-src/src/dynapi/"*.c "$pkg/src/dynapi/" 2>/dev/null || true
    fi

    echo "[sdl2] done"
}

# ── imgui v1.91.9 (core) ───────────────────────────

pkg_imgui() {
    echo "[imgui] v1.91.9 (core)"
    local pkg="$SOURCES_DIR/imgui"
    clean_tmp
    download "https://github.com/ocornut/imgui/archive/refs/tags/v1.91.9.tar.gz" \
        "$TMP_DIR/imgui-1.91.9.tar.gz"
    extract_tar "$TMP_DIR/imgui-1.91.9.tar.gz" "$TMP_DIR/imgui-src"

    # Headers (core only, no backends/)
    mkdir -p "$pkg/include/imgui"
    cp "$TMP_DIR/imgui-src/"*.h "$pkg/include/imgui/" 2>/dev/null || true
    cp "$TMP_DIR/imgui-src/"*.cpp "$pkg/include/imgui/" 2>/dev/null || true

    # Source files (core .cpp files)
    mkdir -p "$pkg/src"
    for f in "$TMP_DIR/imgui-src/"*.cpp; do
        cp "$f" "$pkg/src/"
    done

    echo "[imgui] done"
}

# ── imgui backends ──────────────────────────────────

# Generic function for imgui backends
pkg_imgui_backend() {
    local name="$1"       # e.g. imgui-glfw
    local backend_h="$2"  # e.g. imgui_impl_glfw.h
    local backend_cpp="$3" # e.g. imgui_impl_glfw.cpp
    local version="1.91.9"

    echo "[$name] v$version"
    local pkg="$SOURCES_DIR/$name"
    clean_tmp

    # Download imgui if not already done
    if [ ! -d "$TMP_DIR/imgui-src" ]; then
        download "https://github.com/ocornut/imgui/archive/refs/tags/v1.91.9.tar.gz" \
            "$TMP_DIR/imgui-1.91.9.tar.gz"
        extract_tar "$TMP_DIR/imgui-1.91.9.tar.gz" "$TMP_DIR/imgui-src"
    fi

    # Headers
    mkdir -p "$pkg/include/imgui/backends"
    cp "$TMP_DIR/imgui-src/backends/$backend_h" "$pkg/include/imgui/backends/" 2>/dev/null || true

    # Source
    mkdir -p "$pkg/src"
    cp "$TMP_DIR/imgui-src/backends/$backend_cpp" "$pkg/src/" 2>/dev/null || true

    echo "[$name] done"
}

# ── main ────────────────────────────────────────────

main() {
    local pkgs=("$@")
    if [ ${#pkgs[@]} -eq 0 ]; then
        pkgs=("cli11" "zlib" "glfw" "yaml-cpp" "sdl2" "imgui"
              "imgui-glfw" "imgui-sdl2" "imgui-sdl3" "imgui-win32"
              "imgui-glut" "imgui-osx" "imgui-android"
              "imgui-opengl2" "imgui-opengl3" "imgui-vulkan"
              "imgui-dx9" "imgui-dx10" "imgui-dx11" "imgui-dx12"
              "imgui-metal" "imgui-wgpu")
    fi

    echo "=== EazyMake Package Source Downloader ==="
    echo "Target: $SOURCES_DIR"
    echo "Packages: ${#pkgs[@]}"
    echo ""

    for pkg in "${pkgs[@]}"; do
        case "$pkg" in
            cli11)          pkg_cli11 ;;
            zlib)           pkg_zlib ;;
            glfw)           pkg_glfw ;;
            "yaml-cpp")     pkg_yaml_cpp ;;
            sdl2)           pkg_sdl2 ;;
            imgui)          pkg_imgui ;;
            imgui-glfw)     pkg_imgui_backend "imgui-glfw" "imgui_impl_glfw.h" "imgui_impl_glfw.cpp" ;;
            imgui-sdl2)     pkg_imgui_backend "imgui-sdl2" "imgui_impl_sdl2.h" "imgui_impl_sdl2.cpp" ;;
            imgui-sdl3)     pkg_imgui_backend "imgui-sdl3" "imgui_impl_sdl3.h" "imgui_impl_sdl3.cpp" ;;
            imgui-win32)    pkg_imgui_backend "imgui-win32" "imgui_impl_win32.h" "imgui_impl_win32.cpp" ;;
            imgui-glut)     pkg_imgui_backend "imgui-glut" "imgui_impl_glut.h" "imgui_impl_glut.cpp" ;;
            imgui-osx)      pkg_imgui_backend "imgui-osx" "imgui_impl_osx.h" "imgui_impl_osx.mm" ;;
            imgui-android)  pkg_imgui_backend "imgui-android" "imgui_impl_android.h" "imgui_impl_android.cpp" ;;
            imgui-opengl2)  pkg_imgui_backend "imgui-opengl2" "imgui_impl_opengl2.h" "imgui_impl_opengl2.cpp" ;;
            imgui-opengl3)  pkg_imgui_backend "imgui-opengl3" "imgui_impl_opengl3.h" "imgui_impl_opengl3.cpp" ;;
            imgui-vulkan)   pkg_imgui_backend "imgui-vulkan" "imgui_impl_vulkan.h" "imgui_impl_vulkan.cpp" ;;
            imgui-dx9)      pkg_imgui_backend "imgui-dx9" "imgui_impl_dx9.h" "imgui_impl_dx9.cpp" ;;
            imgui-dx10)     pkg_imgui_backend "imgui-dx10" "imgui_impl_dx10.h" "imgui_impl_dx10.cpp" ;;
            imgui-dx11)     pkg_imgui_backend "imgui-dx11" "imgui_impl_dx11.h" "imgui_impl_dx11.cpp" ;;
            imgui-dx12)     pkg_imgui_backend "imgui-dx12" "imgui_impl_dx12.h" "imgui_impl_dx12.cpp" ;;
            imgui-metal)    pkg_imgui_backend "imgui-metal" "imgui_impl_metal.h" "imgui_impl_metal.mm" ;;
            imgui-wgpu)     pkg_imgui_backend "imgui-wgpu" "imgui_impl_wgpu.h" "imgui_impl_wgpu.cpp" ;;
            *)
                echo "Unknown package: $pkg"
                ;;
        esac
    done

    echo ""
    echo "=== Done ==="
}

main "$@"
