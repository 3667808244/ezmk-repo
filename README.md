# EazyMake Official Package Repository

The default package repository for [EazyMake](https://github.com/3667808244/EazyMake) — a simple C/C++ build tool.

## Quick Start

```bash
# Register this repo (user scope, persists across projects)
ezmk repo add -u https://github.com/3667808244/ezmk-repo.git --name official
ezmk repo update -u official

# Or use the Gitee mirror (for users in China)
ezmk repo add -u https://gitee.com/egglzh/ezmk-repo.git --name official
ezmk repo update -u official

# Install a package by name
ezmk pkg install hello-lib
```

Then in your project's `ezmk.toml`:

```toml
[depends]
lib = ["hello-lib"]
```

## Available Packages

> 下表由 [`index.toml`](index.toml) 生成。所有归档均带 SHA-256，安装时强制校验。

### 通用库

| Package | Version | Type | Language | Description |
| --- | --- | --- | --- | --- |
| `catch2` | 3.16.0 | static | C++17 | C++ 测试框架 v3（多文件实现 + 头文件） |
| `cereal` | 1.3.2 | static | C++17 | C++11 序列化库（header-only） |
| `cli11` | 2.5.0 | static (header-only) | C++17 | C++11 命令行解析库（单头文件） |
| `cpp-httplib` | 0.59.0 | static (header-only) | C++11 | C++11 单头文件 HTTP/HTTPS 客户端与服务器 |
| `doctest` | 2.5.3 | static | C++17 | 轻量快速的 C++ 测试框架 |
| `eigen` | 5.0.1 | static (header-only) | C++17 | C++ 线性代数模板库（矩阵/向量/数值求解） |
| `fmt` | 12.2.0 | static | C++17 | {fmt} 格式化库 |
| `glfw` | 3.5.1 | static | C11 | 跨平台窗口/输入/OpenGL 上下文库 |
| `glm` | 1.0.3 | static | C++17 | OpenGL Mathematics（GLSL 风格数学库） |
| `googletest` | 1.18.0 | static | C++17 | GoogleTest + GoogleMock C++ 测试框架 |
| `gRPC` | 1.68.0 | static (precompiled) | C++17 | 高性能 RPC 框架（预编译） |
| `hello-lib` | 0.1.0 | static | C++17 | 最小示例静态库 |
| `hiredis` | 1.4.1 | static | C11 | Redis 的极简 C 客户端 |
| `libcurl` | 8.11.0 | static (precompiled) | C11 | 多协议文件传输库（预编译） |
| `libpqxx` | 8.0.2 | static | C++17 | PostgreSQL 官方 C++ 客户端 API |
| `lua` | 5.5.1 | static | C99 | Lua 5.5 解释器 C 库 |
| `magic_enum` | 0.9.8 | static | C++17 | 编译期枚举反射（header-only） |
| `msgpack-c` | 7.0.2 | static (header-only) | C11 | MessagePack 二进制序列化（C） |
| `nlohmann_json` | 3.12.0 | static | C++17 | JSON for Modern C++（单头文件 + stub） |
| `openssl` | 3.4.0 | static (precompiled) | C11 | TLS/SSL 密码学库（预编译） |
| `protobuf` | 28.3 | static (precompiled) | C++17 | Protocol Buffers 结构化数据序列化（预编译） |
| `rapidjson` | 1.1.0 | static | C++17 | 快速 JSON 解析/生成库 |
| `sdl2` | 2.32.10 | static (precompiled) | C11 | Simple DirectMedia Layer 2（预编译） |
| `spdlog` | 1.17.0 | static | C++17 | 高性能 C++ 日志库（依赖 fmt） |
| `sqlite3` | 3.53.4 | static | C99 | SQLite 嵌入式数据库（amalgamation） |
| `sqlitecpp` | 3.4.0 | static | C++17 | C++ SQLite3 RAII 封装 |
| `term_pic` | 0.1.2 | static | C++23 | 终端图片/绘图工具库 |
| `tinyxml2` | 11.0.0 | static | C++17 | 轻量 XML 解析库 |
| `tomlplusplus` | 3.4.0 | static (header-only) | C++17 | header-only C++17 TOML 解析器（单头文件） |
| `vt100_utils` | 0.2.0 | static | C++11 | VT100 终端格式与探测工具库 |
| `yaml-cpp` | 0.8.0 | static | C++17 | YAML 解析与生成库 |
| `zlib` | 1.3.2 | static | C11 | zlib 压缩库 |

### Dear ImGui（含 16 个后端）

| Package | Version | Type | Language | Description |
| --- | --- | --- | --- | --- |
| `imgui` | 1.92.9 | static | C++17 | Dear ImGui 核心（docking 分支） |
| `imgui-android` | 1.92.9 | static | C++17 | Dear ImGui 后端：android |
| `imgui-dx10` | 1.92.9 | static | C++17 | Dear ImGui 后端：dx10 |
| `imgui-dx11` | 1.92.9 | static | C++17 | Dear ImGui 后端：dx11 |
| `imgui-dx12` | 1.92.9 | static | C++17 | Dear ImGui 后端：dx12 |
| `imgui-dx9` | 1.92.9 | static | C++17 | Dear ImGui 后端：dx9 |
| `imgui-glfw` | 1.92.9 | static | C++17 | Dear ImGui 后端：glfw |
| `imgui-glut` | 1.92.9 | static | C++17 | Dear ImGui 后端：glut |
| `imgui-metal` | 1.92.9 | static | C++17 | Dear ImGui 后端：metal |
| `imgui-opengl2` | 1.92.9 | static | C++17 | Dear ImGui 后端：opengl2 |
| `imgui-opengl3` | 1.92.9 | static | C++17 | Dear ImGui 后端：opengl3 |
| `imgui-osx` | 1.92.9 | static | C++17 | Dear ImGui 后端：osx |
| `imgui-sdl2` | 1.92.9 | static | C++17 | Dear ImGui 后端：sdl2 |
| `imgui-sdl3` | 1.92.9 | static | C++17 | Dear ImGui 后端：sdl3 |
| `imgui-vulkan` | 1.92.9 | static | C++17 | Dear ImGui 后端：vulkan |
| `imgui-wgpu` | 1.92.9 | static | C++17 | Dear ImGui 后端：wgpu |
| `imgui-win32` | 1.92.9 | static | C++17 | Dear ImGui 后端：win32 |

### Boost header-only 子集（v1.92.0）

| Package | Version | Type | Language | Description |
| --- | --- | --- | --- | --- |
| `boost-algorithm` | 1.92.0 | static (header-only) | C++17 | 字符串算法（trim/split/join/starts_with） |
| `boost-asio` | 1.92.0 | static (header-only) | C++17 | 异步 I/O 网络库（header-only） |
| `boost-assert` | 1.92.0 | static (header-only) | C++17 | 轻量断言宏（BOOST_ASSERT/BOOST_VERIFY） |
| `boost-beast` | 1.92.0 | static (header-only) | C++17 | 基于 Asio 的 HTTP/WebSocket 库 |
| `boost-config` | 1.92.0 | static (header-only) | C++17 | 编译器/平台特性检测宏（基础依赖） |
| `boost-core` | 1.92.0 | static (header-only) | C++17 | 核心工具（addressof/ref/noncopyable/checked_delete） |
| `boost-filesystem` | 1.92.0 | static (header-only) | C++17 | 跨平台文件系统操作（header-only） |
| `boost-functional` | 1.92.0 | static (header-only) | C++17 | 函数对象适配器（hash/bind/function） |
| `boost-lexical-cast` | 1.92.0 | static (header-only) | C++17 | 字符串与数值互转 |
| `boost-math` | 1.92.0 | static (header-only) | C++17 | 数学特殊函数（header-only） |
| `boost-mp11` | 1.92.0 | static (header-only) | C++17 | C++11 元编程库 |
| `boost-optional` | 1.92.0 | static (header-only) | C++17 | Optional<T> 类型安全可空值 |
| `boost-random` | 1.92.0 | static (header-only) | C++17 | 随机数生成（header-only 子集） |
| `boost-smart-ptr` | 1.92.0 | static (header-only) | C++17 | 智能指针（shared_ptr/intrusive_ptr 等） |
| `boost-static-assert` | 1.92.0 | static (header-only) | C++17 | 编译期断言（BOOST_STATIC_ASSERT） |
| `boost-system` | 1.92.0 | static (header-only) | C++17 | 错误码基础设施 |
| `boost-throw-exception` | 1.92.0 | static (header-only) | C++17 | 异常抛出工具 |
| `boost-tokenizer` | 1.92.0 | static (header-only) | C++17 | 字符串分词器 |
| `boost-uuid` | 1.92.0 | static (header-only) | C++17 | 通用唯一标识符 |
| `boost-variant2` | 1.92.0 | static (header-only) | C++17 | 类型安全的 union（variant<Ts...>） |

### stb 单文件 C 库

| Package | Version | Type | Language | Description |
| --- | --- | --- | --- | --- |
| `stb-ds` | 0.67.0 | static (header-only) | C99 | 类型安全动态数组与哈希表 |
| `stb-image` | 2.30.0 | static (header-only) | C99 | 图像加载（PNG/JPEG/BMP/TGA/HDR 等） |
| `stb-image-resize` | 0.97.0 | static (header-only) | C99 | 图像缩放/滤波（v2） |
| `stb-image-write` | 1.16.0 | static (header-only) | C99 | 图像写出（PNG/JPEG/BMP/TGA） |
| `stb-perlin` | 0.05.0 | static (header-only) | C99 | Perlin 噪声生成 |
| `stb-rect-pack` | 1.01.0 | static (header-only) | C99 | 纹理图集矩形打包 |
| `stb-sprintf` | 1.10.0 | static (header-only) | C99 | 快速 sprintf/sscanf 替代 |
| `stb-textedit` | 1.14.0 | static (header-only) | C99 | 简单文本编辑控件 |
| `stb-truetype` | 1.27.0 | static (header-only) | C99 | TrueType 字体光栅化 |
| `stb-vorbis` | 1.22.0 | static | C99 | Ogg Vorbis 音频解码器 |

### Utilities

| Package | Version | Type | Language | Description |
| --- | --- | --- | --- | --- |
| `example-utils` | 0.1.0 | utils | - | 带权限声明的示例 Lua utils 工具 |

### 保留的旧版本

破坏性大版本升级会保留旧条目，项目可用 `lib = ["eigen@3.4.0"]` 之类的方式固定旧版本。

| Package | Version | Type | Language | Description |
| --- | --- | --- | --- | --- |
| `cpp-httplib` | 0.18.3 | static (header-only) | C++11 | 保留的旧版本（0.x minor 破坏性升级前） |
| `eigen` | 3.4.0 | static (header-only) | C++17 | 保留的旧版本（Eigen 3 → 5 破坏性升级前） |
| `fmt` | 10.2.1 | static | C++17 | 保留的旧版本（fmt 10 → 12 破坏性升级前） |
| `libpqxx` | 7.9.2 | static | C++17 | 保留的旧版本（libpqxx 7 → 8 破坏性升级前） |
| `lua` | 5.4.7 | static | C99 | 保留的旧版本（Lua 5.4 → 5.5 前） |
| `msgpack-c` | 6.1.0 | static (header-only) | C11 | 保留的旧版本（msgpack-c 6 → 7 破坏性升级前） |
| `vt100_utils` | 0.1.0 | static | C++11 | 保留的旧版本 |

### 依赖关系

```
spdlog     ──→ fmt
sqlitecpp  ──→ sqlite3
libcurl    ──→ openssl, zlib
gRPC       ──→ protobuf, openssl
cpp-httplib ──→ (可选) openssl

# Boost header-only 内部依赖（仅编译期）
boost-assert ──→ boost-config
boost-core ──→ boost-config, boost-assert
boost-asio ──→ boost-config, boost-assert, boost-core, boost-system
boost-beast ──→ boost-asio, boost-system, boost-smart-ptr
```
## Repository Structure

```
ezmk-repo/
├── index.toml       # Repository metadata + package index (auto-generated)
├── packages/        # Package archives (.tar.gz)
├── sources/         # Source projects (auditable, each with ezmk.toml)
├── scripts/
│   ├── pack.sh      # Pack sources → archives + regenerate index.toml
│   └── validate.sh  # CI validation script
└── .github/
    └── workflows/
        └── ci.yml   # PR validation
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full contribution workflow.

Quick summary:
1. **Fork** this repository
2. Add your package source under `sources/<your-pkg>/` with a valid `ezmk.toml`
3. Run `bash scripts/pack.sh` to generate the archive and update `index.toml`
4. Submit a **Pull Request** — CI will validate automatically
5. For `utils` packages, declare `[utils.permissions]` in your `ezmk.toml`

### Package Requirements

- **`ezmk.toml`** at the package root with `[project]` (`name`, `type`, `version` required)
- `type` must be one of: `static`, `shared`, `utils`
- **Versioning**: [SemVer](https://semver.org/) (e.g. `1.0.0`)
- **Naming**: lowercase with hyphens (e.g. `my-lib`)
- **SHA-256**: provided automatically by `pack.sh` — do not edit `index.toml` by hand
- **Utils packages** must declare `[utils.permissions]` with explicit `read`, `write`, `run` lists

## Security

- All archives in `index.toml` carry a **SHA-256** checksum — ezmk enforces it at install time.
- Every package source lives under `sources/` so it can be **audited** independently of the archive.
- CI ensures **source → archive → hash** consistency on every PR.
- Human review is required before merging any contribution.

See the [EazyMake safety docs](https://github.com/3667808244/EazyMake/blob/main/docs/@safety.md) for the full security model.
