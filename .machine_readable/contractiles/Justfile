# SPDX-License-Identifier: MPL-2.0
# SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Oikos — SFC economic modelling DSL
# justfile: project automation recipes

# ── Configuration ──────────────────────────────────────────────────────────────

# Minimum supported Rust version
msrv := "1.83"

# Cargo invocation — override to add e.g. `--target wasm32-unknown-unknown`
cargo := "cargo"

# ── Primary targets ────────────────────────────────────────────────────────────

# Run all checks: format, lint, build, test (the full local CI gate)
all: fmt check build test

# Check: clippy + deny + doc generation
check:
    {{ cargo }} clippy --workspace --all-targets --all-features -- -D warnings
    {{ cargo }} doc --workspace --no-deps --document-private-items

# Build all workspace crates in release mode
build:
    {{ cargo }} build --workspace --release

# Run the full test suite
test:
    {{ cargo }} test --workspace

# Format all Rust source files (check only — use `fmt-fix` to apply)
fmt:
    {{ cargo }} fmt --all --check

# Apply formatting in-place
fmt-fix:
    {{ cargo }} fmt --all

# ── Development helpers ────────────────────────────────────────────────────────

# Fast development build (debug, no doc, no clippy)
dev:
    {{ cargo }} build --workspace

# Watch for changes and re-run tests
watch:
    cargo watch -x "test --workspace"

# Generate documentation and open in browser
docs:
    {{ cargo }} doc --workspace --no-deps --document-private-items --open

# ── Quality gates ─────────────────────────────────────────────────────────────

# Check for security advisories in dependencies
audit:
    cargo audit

# Check for outdated dependencies
outdated:
    cargo outdated --root-deps-only

# Run minimum supported Rust version check
msrv-check:
    cargo +{{ msrv }} check --workspace

# ── Housekeeping ──────────────────────────────────────────────────────────────

# Remove build artefacts
clean:
    {{ cargo }} clean

# Print workspace dependency tree
tree:
    {{ cargo }} tree --workspace

# Verify SPDX licence headers (requires `reuse` tool)
reuse-check:
    reuse lint

secret-scan-trufflehog:
    @command -v trufflehog >/dev/null && trufflehog filesystem . --only-verified || true
