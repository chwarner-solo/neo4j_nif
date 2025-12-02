# Rustler Precompilation Setup - Complete Guide

## What We Fixed

Your project had a critical configuration issue: the `mix.exs` file was trying to use `:rustler_precompiled` as a Mix compiler, but that's not how `rustler_precompiled` works.

### The Problem
```elixir
# ❌ WRONG - This doesn't work
compilers: Mix.compilers() ++ [:rustler_precompiled]
use Rustler, otp_app: :neo4j_nif, crate: "neo4j_nif"
```

### The Solution
```elixir
# ✅ CORRECT - Now it works
# No special compiler needed in mix.exs
use RustlerPrecompiled,
  otp_app: :neo4j_nif,
  crate: "neo4j_nif",
  base_url: "https://github.com/chwarner-solo/neo4j_nif/releases/download/v0.1.0",
  version: "0.1.0"
```

## How RustlerPrecompiled Works

**RustlerPrecompiled** is a system with two modes:

1. **Download Mode** (default for end users)
   - Tries to download precompiled binaries from the GitHub release URL
   - Fast, no Rust compiler needed
   - Fails gracefully if binaries don't exist

2. **Build Mode** (for development)
   - Activated by config setting: `config :rustler_precompiled, force_build: [neo4j_nif: true]`
   - Builds Rust code locally using the `:rustler` compiler
   - Used in development and when precompiled binaries aren't available

## Your Current Setup

### Development (Local Compilation)
```bash
# This will build from Rust source
mix compile

# The config/config.exs file forces build mode in dev
config :rustler_precompiled, force_build: [neo4j_nif: true]
```

### Production (Precompiled Binaries)
When you release to Hex, users will:
1. Try to download precompiled binaries (fast)
2. Fall back to building if binaries don't exist
3. Need Rust toolchain only if building

## GitHub Actions Workflow

The `.github/workflows/ci.yml` file we created has two jobs:

### Job 1: Test
- Runs on every push/PR to main or develop
- Tests on multiple OTP/Elixir versions
- Compiles Rust NIFs locally (using force_build mode)
- Runs your test suite

### Job 2: Precompile (only on tags)
- Runs when you tag a release (e.g., `v0.1.0`)
- Builds for multiple platforms:
  - Ubuntu x86_64 Linux
  - macOS x86_64
  - macOS ARM64 (M1/M2)
  - Windows x86_64
- Generates precompiled artifacts
- Uploads to GitHub Actions artifacts (you can then release these)

## Next Steps

### To Generate Precompiled Binaries

The `ci.yml` workflow attempts to generate precompiled NIFs. However, you need to:

1. **Install the precompilation tools locally first:**
   ```bash
   mix escript.install hex rustler_precompiled
   ```

2. **Generate checksums for your platform:**
   ```bash
   mix rustler_precompiled.download neo4j_nif --only-local
   ```
   This creates:
   - Compiled .so/.dll files
   - `checksum-*.exs` file with integrity checksums

3. **Add these to your repo and tag a release:**
   ```bash
   git add checksum-*.exs native/neo4j_nif/artifacts/
   git commit -m "Add precompiled NIFs for v0.1.0"
   git tag v0.1.0
   git push origin main --tags
   ```

4. **GitHub Actions will then generate cross-platform binaries** on tag push

### Alternative: Simple Build-from-Source Approach

If you prefer to skip precompilation (simpler setup), users just build from source:
- Keep the config that forces `:rustler` to build
- Remove the precompilation job from CI
- Requires Rust toolchain on user machines

### Publishing to Hex

When ready to publish:
```bash
# Create a Hex user/account first
mix hex.user register

# Then publish
mix hex.publish
```

Hex will package your source code + any precompiled artifacts.

## Files Modified/Created

1. **mix.exs** - Updated to:
   - Make `:rustler` optional dependency
   - Use `RustlerPrecompiled` macro instead of `Rustler`
   - Removed special compiler configuration

2. **lib/neo4j_nif.ex** - Changed from:
   - `use Rustler` → `use RustlerPrecompiled`
   - Added base_url and version to macro

3. **config/config.exs** (new) - Forces build mode in development:
   - Ensures local compilation during dev
   - Downloads mode only for production/releases

4. **.github/workflows/ci.yml** (new) - Complete CI pipeline:
   - Tests on multiple OTP versions
   - Generates precompiled binaries for releases
   - Ready for cross-platform builds

## Troubleshooting

### "compile.rustler could not be found"
This means `:rustler` isn't available. Either:
- Make sure `:rustler` is in deps
- Use `use RustlerPrecompiled` instead of `use Rustler`
- Check that config is loading (try `mix compile --force`)

### "couldn't fetch NIF from..."
Expected in development. This means:
- Precompiled binaries don't exist at that URL (normal)
- Check that `force_build` is enabled in config
- Verify Rust toolchain is installed: `rustc --version`

### Compilation fails in Rust
Common causes:
- Outdated `cargo.lock` - try `cargo update` in native/neo4j_nif/
- Dependency issues - check if neo4rs requires specific Rust version
- Missing system libraries - check Rust error messages

## Key Insight

**RustlerPrecompiled = smart fallback system**

```
User tries: mix deps.get + mix compile
    ↓
RustlerPrecompiled checks: do precompiled binaries exist?
    ↓
    YES → Download + extract (fast) ✓
    NO  → Check force_build config
        ↓
        force_build: true  → Compile from source (slow but works) ✓
        force_build: false → ERROR: "couldn't fetch NIF" ✗
```

In your case:
- **Dev** (`force_build: true`) - Always builds from source
- **Production/Release** - Tries precompiled first, falls back to build

This is the correct setup! 🚀
