<!--
SPDX-License-Identifier: MPL-2.0
SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell (hyperpolymath)
-->

# Changelog

All notable changes to `oikos` will be documented in this file.

This file is generated from conventional commits by the
[`changelog-reusable.yml`](https://github.com/hyperpolymath/standards/blob/main/.github/workflows/changelog-reusable.yml)
workflow (`hyperpolymath/standards#206`). Adopt the workflow in this repo's CI to keep this file in sync automatically — see
[`templates/cliff.toml`](https://github.com/hyperpolymath/standards/blob/main/templates/cliff.toml)
for the canonical config.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
this project aims to follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- feat(bot): `bot-integration-affine/` Phase 5 AffineScript scaffold (#35) — initial AS port of OikosBot; cross-module type-check, JSON payload extraction, and HTTP-server accept loop are gated on upstream `affinescript` stdlib work (Json v0.3 RSR rewire `affinescript#421` + Http server FFI `affinescript#425`).
- feat: Oikos Bot v0.1.0-beta - TEA architecture with typed HTTP routing
- feat: add GitHub App manifest for developer programme registration

### Fixed

- fix(lexer): opt in to logos 0.16 `allow_greedy` for line-comment skip (#37) — `#[logos(skip("--[^\n]*", allow_greedy = true))]` replaces the unbounded greedy attribute that logos 0.16's new lint rejects.
- fix(codeql): switch language matrix to 'actions' (no JS/TS in repo) (#23)
- fix(codeql): switch language matrix to 'actions' (no JS/TS in repo) (#22)
- fix(ci): sync hypatia-scan.yml to canonical (413: env.HOME+Phase-2+SARIF) (#20)
- fix(codeql): switch language matrix to 'actions' (no JS/TS in repo) (#19)
- fix(ci): rsr-antipattern.yml duplicate heredoc (#15)
- fix(ci): move secret-scanner Cargo.toml gate from job-level if: to step-level (#17)
- fix(codeql): switch language matrix to 'actions' (no JS/TS in repo) (#16)
- fix(security): ERR-WF-008 and ERR-WF-009 fixes
- fix(ci): update quality.yml workflow
- fix(security): CodeQL language matrix correction

### Changed

- chore(bot-integration): clean shutoff of the legacy ReScript `bot-integration/` (#41) — 208 files / -33,061 lines: removes `bot-integration/`, `containers/`, `.github/workflows/oikos.yml`, the `rescript:` job from `ci.yml`, the npm/bot-integration dependabot entry, and `.gitmodules`. README / ARCHITECTURE / ROADMAP / DEPLOY / disambiguation docs repointed at `bot-integration-affine/`. No production blast radius (`.github/app.yml` URLs were `*.example.com` placeholders).
- chore(license): align stale SPDX headers + `Cargo.toml` manifest with `MPL-2.0` (#36) — completes the 2026-05-22 EUPL → MPL migration that had left 45 file headers + the manifest at `EUPL-1.2`.
- chore(license): remove historical `LICENSES/EUPL-1.2.txt` (#40) — final cleanup of the EUPL transition artefact, deferred from #38 as a transition-period record.
- refactor: convert TypeScript to JavaScript (language policy compliance)
- refactor: complete eco-bot → oikos rename across all files
- refactor: rename eco-bot to oikos, replace nerdctl with Svalinn/Vörðr

### Documentation

- docs(license): DR-010 supersedes DR-002 — `MPL-2.0` adoption + README badge / paragraph flip (#38) — closes the 2026-05-22 LICENSE migration that lacked a Decision Record. Documents PMPL ↔ EUPL distribution-compatibility incoherence as the migration rationale.
- docs(readme): add SPDX header and/or standard badges
- docs: add manifest flow instructions to DEPLOY.md
- docs(security): add SECURITY.md

### CI

- ci(secret-scanner): drop duplicate --fail from trufflehog extra_args (#14)
- ci(dependabot): restore cargo PR limit so security + version PRs flow (#12)
- ci: fix workflow-linter YAML parse error + self-flag bug
- ci(antipattern): fix top-level dir matching + benchmarks/lsp/bench filename allowlists (#10)
- ci(antipattern): TS check reads .claude/CLAUDE.md exemption table (#9)

## Pre-history

Prior commits to this file's introduction are recorded in git history but not formally classified into Keep-a-Changelog sections. To backfill, run `git cliff -o CHANGELOG.md` locally using the canonical [`cliff.toml`](https://github.com/hyperpolymath/standards/blob/main/templates/cliff.toml) — this is one-shot mechanical work.

---

<!-- This file was seeded by the 2026-05-26 estate tech-debt audit follow-up (Row-2 Phase 3); see [`hyperpolymath/standards/docs/audits/2026-05-26-estate-documentation-debt.md`](https://github.com/hyperpolymath/standards/blob/main/docs/audits/2026-05-26-estate-documentation-debt.md). -->
