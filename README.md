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

### Libraries

| Package | Version | Type | Language | Description |
|---------|---------|------|----------|-------------|
| `catch2` | 3.6.0 | static | C++17 | Catch2 testing framework (header-only + stub) |
| `fmt` | 10.2.1 | static | C++17 | {fmt} formatting library |
| `hello-lib` | 0.1.0 | static | C++17 | Minimal example static library |
| `lua` | 5.4.7 | static | C | Lua 5.4 interpreter C library |
| `nlohmann_json` | 3.11.3 | static | C++17 | JSON for Modern C++ (header-only + stub) |
| `spdlog` | 1.14.1 | static | C++17 | Fast C++ logging library (depends on `fmt`) |
| `sqlite3` | 3.46.0 | static | C | SQLite embedded database (single-file amalgamation) |
| `tinyxml2` | 11.0.0 | static | C++17 | Lightweight XML parsing library |

### Utilities

| Package | Version | Type | Description |
|---------|---------|------|-------------|
| `example-utils` | 0.1.0 | utils | Example Lua utils tool with permissions |

### Dependency Graph

```
spdlog ──→ fmt
```

All other packages are self-contained with no external dependencies.

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
