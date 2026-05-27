<!-- SPDX-License-Identifier: MPL-2.0 -->
<!-- SPDX-FileCopyrightText: 2026 hyperpolymath -->

# OikosBot — bot-integration

The ReScript + Deno service that backs the
[`oikosbot` GitHub App](https://github.com/apps/oikosbot).
Receives webhooks from GitHub / GitLab, calls a Haskell analyser, posts
eco/econ/quality reports back as PR comments and check runs.

> **Note — which product is this?**
> This is **OikosBot**, a code-analysis bot.
> If you're looking for the *Oikos DSL* (a Rust compiler for stock-flow
> consistent macroeconomic models), go up one directory and read the top-level
> [`README.adoc`](../README.adoc). The two products share the οἶκος root but
> nothing else. See
> [`../docs/disambiguation/oikos-dsl-vs-oikosbot.adoc`](../docs/disambiguation/oikos-dsl-vs-oikosbot.adoc).

## Status (2026-05)

- App registered at GitHub (id `2538504`, slug `oikosbot`).
- Bot code present; recent hardening landed in
  [PR #32](https://github.com/hyperpolymath/oikos/pull/32) (fail-closed webhooks,
  schema-validated analyser responses, honest degraded reports).
- **Not deployed anywhere.** The App's `external_url` is `oikosbot.org` and
  DNS does not resolve. The webhook target in `.github/app.yml` is still a
  placeholder.
- Not installed on any repository.

See [`ROADMAP.md`](ROADMAP.md) for the path to a first production install.

## Architecture (one paragraph)

Webhook → signature verification (`Webhook.res`) → event routing (`Main.res`) →
GitHub App JWT + installation token (`GitHubApp.res`) → analyser HTTP call
(`Analysis.res`, decodes JSON into the `analysisResult` schema in `Types.res`)
→ Markdown comment + `check_run` (`Report.res` + `GitHubAPI.res`). Three modes:
**advisor** (suggestions only), **consultant** (more detail), **regulator**
(degraded analyser becomes `action_required` so branch protection can gate).

Full architecture diagram and rationale: [`../ARCHITECTURE.md`](../ARCHITECTURE.md).

## Build and run

```bash
# Install deps (rescript compiler via npm-in-node_modules, std libs via JSR)
deno install --node-modules-dir=auto

# Compile ReScript → JS
./node_modules/.bin/rescript build

# Run tests
deno test --allow-net --allow-env --allow-read src/

# Run locally (set webhook secret, or opt into unverified for dev)
GITHUB_WEBHOOK_SECRET=dev-secret deno task start
# OR (local dev with smee/ngrok)
OIKOS_ALLOW_UNVERIFIED_WEBHOOKS=true deno task start
```

The bot refuses to start without `GITHUB_WEBHOOK_SECRET` /
`GITLAB_WEBHOOK_SECRET` unless `OIKOS_ALLOW_UNVERIFIED_WEBHOOKS=true` is set.
That escape hatch is for local dev only — never set it in production.

## Configuration

| Env var | Purpose | Required? |
|---|---|---|
| `GITHUB_WEBHOOK_SECRET` | HMAC-SHA256 secret for `x-hub-signature-256` | yes (or GitLab equivalent) |
| `GITLAB_WEBHOOK_SECRET` | Token compared against `x-gitlab-token` | yes (or GitHub equivalent) |
| `GITHUB_APP_ID` | Numeric App ID for JWT generation | for posting comments |
| `GITHUB_PRIVATE_KEY` | PKCS#8 PEM (see `docs/GITHUB_APP_SETUP.md`) | for posting comments |
| `ANALYSIS_ENDPOINT` | Haskell analyser base URL | yes for real analyses |
| `BOT_MODE` | `advisor` / `consultant` / `regulator` | no; defaults to `advisor` |
| `PORT` | HTTP listen port | no; defaults to `3000` |
| `OIKOS_ALLOW_UNVERIFIED_WEBHOOKS` | `true` allows unsigned webhooks (DEV ONLY) | no |

Full deployment guide: [`../DEPLOY.md`](../DEPLOY.md).
GitHub App registration walkthrough: [`../docs/GITHUB_APP_SETUP.md`](../docs/GITHUB_APP_SETUP.md).

## Files

```
bot-integration/
├── src/
│   ├── Main.res         # HTTP routing, webhook dispatch, fail-closed contract
│   ├── Webhook.res      # HMAC-SHA256 verify, event parse
│   ├── GitHubApp.res    # App JWT (RS256) + installation token cache
│   ├── GitHubAPI.res    # Authenticated REST calls (PR comments, check runs)
│   ├── Analysis.res     # Analyser HTTP client + JSON schema decoders
│   ├── Report.res       # PR comment Markdown + SARIF + degraded report
│   ├── Config.res       # Env loading + fail-closed validation
│   ├── Types.res        # Shared record types
│   ├── Router.res       # HTTP router (used by Oikos.res entry, not Main.res)
│   ├── Oikos.res        # TEA-style entry (skeleton; Main.res is what runs)
│   └── Analysis_test.js # Decoder regression tests
└── bindings/            # Deno + Fetch ReScript bindings
```

## Licence

MPL-2.0. See `../LICENSE`.
