# Contributing to the Official EazyMake Repository

Thank you for contributing! This guide walks through adding a package to the official EazyMake repository.

## Workflow

### 1. Fork & Clone

```bash
git clone https://github.com/<your-username>/ezmk-repo.git
cd ezmk-repo
```

### 2. Add Your Package Source

Create your package under `sources/<package-name>/`:

```
sources/<package-name>/
├── ezmk.toml       # Required: [project] with name, type, version
├── include/        # Public headers (for static/shared libs)
│   └── *.h / *.hpp
├── src/            # Source files
│   └── *.c / *.cpp / *.cxx
└── utils/           # Lua scripts (for type = "utils" only)
    └── <tool>.lua
```

**`ezmk.toml` requirements:**

```toml
[project]
name = "my-lib"         # lowercase-hyphens, unique
type = "static"         # "static" | "shared" | "utils"
version = "0.1.0"       # Semantic Versioning
language = "C++17"      # optional, defaults to "C++17"

[compile]
include_dirs = ["include"]
src_dirs = ["src"]

# For utils packages:
# [utils]
# tools = ["my-tool"]
#
# [utils.permissions]     # REQUIRED for utils — keep minimal!
# read = []
# write = []
# run = []
```

### 3. Run pack.sh

This generates the archive in `packages/` and updates `index.toml` automatically:

```bash
bash scripts/pack.sh
```

**Never edit `index.toml` or add files to `packages/` by hand** — `pack.sh` is the authoritative source.

### 4. Run validate.sh

Run the same checks that CI will run:

```bash
bash scripts/validate.sh
```

All 4 checks must pass:
1. `index.toml` structure is valid
2. All package files exist
3. SHA-256 checksums match
4. `pack.sh` is reproducible (no uncommitted diff)

### 5. Commit & Pull Request

```bash
git add sources/<package-name>/ packages/ index.toml
git commit -m "Add <package-name> v<version>"
git push origin main
```

Open a Pull Request against the upstream `main` branch. CI will:
- Run `scripts/validate.sh`
- Verify reproducibility (`pack.sh` produces no diff)

### 6. Review

A maintainer will review:
- Package naming and versioning
- Source code quality and structure
- **Utils packages**: `[utils.permissions]` are minimal and justified
- No malicious or unexpected behavior

Once approved and merged, your package is available to all EazyMake users!

## Version Upgrades

To release a new version of an existing package:

1. Update `version` in `sources/<pkg>/ezmk.toml`
2. Run `bash scripts/pack.sh` — this adds a new `[[packages]]` entry while preserving the old one
3. `ezmk pkg install` will default to the highest version; old versions remain available

## Naming Conventions

| Rule | Example |
|------|---------|
| Package name: lowercase, hyphens | `my-lib`, `json-parser` |
| Archive name: `<name>-<version>.tar.gz` | `my-lib-1.0.0.tar.gz` |
| Version: SemVer | `1.0.0`, `0.2.1`, `2.0.0-beta.1` |

## Permissions for Utils Packages

For `type = "utils"` packages, declare exactly what your Lua scripts need:

```toml
[utils.permissions]
read = ["src/", "include/"]     # directories the tool can read
write = ["build/", "output/"]   # directories the tool can write to
run = ["git", "clang-format"]   # external commands the tool may execute
```

**Principle of least privilege**: start with empty lists and add only what your tool actually uses. Permissions exceeding actual usage will be flagged in review.

## Questions?

Open an [issue](https://github.com/3667808244/ezmk-repo/issues) or refer to:
- [EazyMake documentation](https://github.com/3667808244/EazyMake/tree/main/docs)
- [Package management guide](https://github.com/3667808244/EazyMake/blob/main/docs/pkg.md)
- [Utils & Lua API reference](https://github.com/3667808244/EazyMake/blob/main/docs/utils.md)
