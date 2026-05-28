## Machine-Readable Artefacts

The following files in `.machine_readable/6a2/` contain structured project metadata (a2ml format; the prior `.scm` Guile-Scheme files were retired estate-wide):

- `STATE.a2ml` - Current project state and progress
- `META.a2ml` - Architecture decisions and development practices
- `ECOSYSTEM.a2ml` - Position in the ecosystem and related projects
- `AGENTIC.a2ml` - AI agent interaction patterns
- `NEUROSYM.a2ml` - Neurosymbolic integration config
- `PLAYBOOK.a2ml` - Operational runbook

---

# CLAUDE.md - AI Assistant Instructions

## Language Policy (Hyperpolymath Standard)

> **Policy refresh 2026-05-28**: This repo has two products. (1) The **Oikos DSL** at the repo root is **Rust** (compiler crates `oikos-syntax`, `oikos-parser`, `oikos-desugar`, `oikos-check`); (2) **OikosBot** at `bot-integration-affine/` is **AffineScript** as of the 2026-05-28 legacy-shutoff (oikos#41) — the previous ReScript implementation at `bot-integration/` was removed in the same PR. Write no new ReScript or TypeScript here. MPL-1.0 / MPL-1.0-or-later are banned; rewrite to MPL-2.0 wherever encountered (DR-010 supersedes DR-002).

### ALLOWED Languages & Tools

| Language/Tool | Use Case | Notes |
|---------------|----------|-------|
| **Rust** | Oikos DSL compiler crates | Repo root; performance-critical |
| **AffineScript** (`.affine`) | OikosBot (`bot-integration-affine/`) | Affine types, dependent types, row polymorphism, extensible effects |
| **Haskell** | OikosBot analyser backend (`analyzers/`) | Existing surface; pure analysis |
| **Deno** | Runtime & package management | Replaces Node/npm/bun |
| **Tauri 2.0+** | Mobile apps (iOS/Android) | Rust backend + web UI |
| **Dioxus** | Mobile apps (native UI) | Pure Rust, React-like |
| **Gleam** | Backend services | Runs on BEAM or compiles to JS |
| **Bash/POSIX Shell** | Scripts, automation | Keep minimal |
| **Nickel** | Configuration language | For complex configs |
| **A2ML** | State/meta files | `.machine_readable/6a2/*.a2ml` |
| **Julia** | Batch scripts, data processing | Per RSR |
| **OCaml** | AffineScript compiler upstream | Not in this repo (lives in `hyperpolymath/affinescript`) |
| **Ada** | Safety-critical systems | Where required |

### BANNED - Do Not Use

| Banned | Replacement |
|--------|-------------|
| TypeScript | AffineScript (for OikosBot) / Rust (for DSL) |
| **ReScript** (new files) | **AffineScript** — the legacy `bot-integration/` ReScript was removed 2026-05-28 (oikos#41) |
| JavaScript (new files) | AffineScript |
| Node.js | Deno |
| npm | Deno |
| Bun | Deno |
| pnpm/yarn | Deno |
| Go | Rust |
| Python | Julia/Rust/ReScript |
| Java/Kotlin | Rust/Tauri/Dioxus |
| Swift | Tauri/Dioxus |
| React Native | Tauri/Dioxus |
| Flutter/Dart | Tauri/Dioxus |

### Mobile Development

**No exceptions for Kotlin/Swift** - use Rust-first approach:

1. **Tauri 2.0+** - Web UI (AffineScript) + Rust backend, MIT/Apache-2.0
2. **Dioxus** - Pure Rust native UI, MIT/Apache-2.0

Both are FOSS with independent governance (no Big Tech).

### Enforcement Rules

1. **No new TypeScript files** - Write new code in AffineScript
2. **No new ReScript files** - Legacy `bot-integration/` ReScript was retired 2026-05-28 (oikos#41); the AS port lives at `bot-integration-affine/`
3. **No package.json for runtime deps** - Use deno.json imports
4. **No node_modules in production** - Deno caches deps automatically
5. **No Go code** - Use Rust instead
6. **No Python anywhere** - Use Julia for data/batch, Rust for systems
7. **No Kotlin/Swift for mobile** - Use Tauri 2.0+ or Dioxus
8. **MPL-1.0 / MPL-1.0-or-later are non-conforming** - Rewrite to MPL-2.0 (DR-010)

### Package Management

- **Primary**: Guix (guix.scm)
- **Fallback**: Nix (flake.nix)
- **JS deps**: Deno (deno.json imports)

### Security Requirements

- No MD5/SHA1 for security (use SHA256+)
- HTTPS only (no HTTP URLs)
- No hardcoded secrets
- SHA-pinned dependencies
- SPDX license headers on all files

