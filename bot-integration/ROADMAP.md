<!-- SPDX-License-Identifier: MPL-2.0 -->
<!-- SPDX-FileCopyrightText: 2026 hyperpolymath -->

# OikosBot — roadmap

This is the roadmap for **OikosBot**, the code-analysis GitHub/GitLab App.
For the **Oikos DSL** roadmap, see [`../docs/ROADMAP.adoc`](../docs/ROADMAP.adoc).
For why those are different things, see
[`../docs/disambiguation/oikos-dsl-vs-oikosbot.adoc`](../docs/disambiguation/oikos-dsl-vs-oikosbot.adoc).

Status legend: `done` · `in-progress` · `blocked` · `planned`

---

## v0.1 — Hardened scaffold *(current)*

The bot service exists, signs JWTs, posts PR comments, and refuses
unverified webhooks. Not deployed.

### Done

- App registered at GitHub (`apps/oikosbot`, id 2538504, 2025-12-25).
- ReScript + Deno service (~2 000 LoC): webhook routing, HMAC-SHA256
  verification, RS256 JWT, installation token cache, PR comment + check run.
- Haskell analyser scaffold in [`../analyzers/code-haskell/`](../analyzers/code-haskell/).
- Three operational modes: `advisor` (default) / `consultant` / `regulator`.
- Fail-closed webhook signature contract (PR #32, 2026-05-27).
- Schema-validated analyser JSON responses with regression tests (PR #32).
- No mock data on real PRs — analyser failures become honest degraded
  reports + neutral / action_required check runs (PR #32).
- App manifest at `.github/app.yml` synced with what `Main.res` actually
  handles (PR #32).

### Remaining for v0.1 exit

- [ ] Lock in the analyser-response schema as a versioned artefact and
      surface a `/schema` endpoint serving it.
- [ ] Wire the analyser-failure path through `Analysis_test.js` end-to-end
      with a fake analyser.
- [ ] Stand up CI that runs `rescript build` + `deno test` on every PR
      against `bot-integration/`.

---

## v0.2 — First production install *(blocked on owner-only actions)*

The bot becomes a thing that actually receives webhooks.

### Owner actions (cannot be automated)

- [ ] Decide on a homepage domain. Either:
      - **register `oikosbot.org`** (currently NXDOMAIN), or
      - **change the App's `external_url`** to a domain you already own.
- [ ] Pick a deployment target (recommendation: Deno Deploy; alternatives
      Fly.io, Render, self-hosted Podman per [`../DEPLOY.md`](../DEPLOY.md)).
- [ ] Provision secrets: `GITHUB_APP_ID`, `GITHUB_PRIVATE_KEY` (PKCS#8),
      `GITHUB_WEBHOOK_SECRET`, `ANALYSIS_ENDPOINT`.
- [ ] Point the App's webhook URL at the deployed service.
- [ ] Install on `hyperpolymath/oikos` and one throwaway test repo.

### Code actions

- [ ] Replace placeholder URLs in `.github/app.yml` (`oikos-bot.example.com`)
      with whatever owner decides above.
- [ ] Implement `/setup` and `/callback` routes so the manifest install
      flow actually works end-to-end.
- [ ] Health-check the Haskell analyser before posting "unavailable" so we
      distinguish *analyser down* from *bot deploy broken*.
- [ ] Structured logs include the GitHub delivery ID for cross-referencing
      with App audit logs.

### Exit criterion

Opening a PR on the test repo posts a real eco/econ/quality comment AND
a `check_run` within 30 seconds, end-to-end.

---

## v0.3 — Rich PR feedback

Once v0.2 proves the loop, make the feedback useful instead of just present.

- [ ] Inline review comments via `POST /pulls/:n/reviews` with line-specific
      annotations (line-locations are already part of the `policyViolation`
      schema in `Types.res`).
- [ ] Check Run `output.annotations[]` — surface findings in the Files-changed
      tab, not just as a PR comment.
- [ ] Per-repo `.oikos.yml` config (mode, thresholds, exclusions).
      Wire via the manifest's `single_file_name` declaration (currently
      commented out in `.github/app.yml`).
- [ ] Comment de-duplication: update the previous Oikos comment instead of
      posting a new one on every push (`GitHubAPI.updateComment` already
      exists).
- [ ] Render a single-image SVG badge for repos to embed
      ("Oikos Health: B / 78").

---

## v0.4 — Regulator mode that actually blocks

Today regulator mode escalates degraded reports to `action_required`. To
make that a meaningful block, the policy backend has to do real work.

- [ ] Branch-protection integration — document the precise check name to
      mark as required.
- [ ] Policy DSL: site-specific rules in `.oikos.yml`
      (e.g. "block if `eco.carbonScore < 60`").
- [ ] Policy ↔ analyser feedback loop: analyser returns the violations,
      bot enforces them by mode.
- [ ] SARIF upload to GitHub code scanning
      (`Report.generateSARIF` already exists; just needs the upload call).
- [ ] Append-only audit log of regulator decisions, keyed by commit SHA.

---

## v0.5 — Observability and ops

- [ ] `/metrics` returns real Prometheus / OpenTelemetry counters
      (currently returns zeros — `Main.res:376-385`).
- [ ] Dashboard: installs, PRs analysed, analyser latency p50/p95/p99,
      degraded rate.
- [ ] Rate limiting per installation to stop runaway repos.
- [ ] Webhook-replay endpoint for ops triage.

---

## v1.0 — Marketplace listing

The bot is something other people can find and install.

- [ ] Public docs site at `oikosbot.org` (or wherever v0.2 lands).
- [ ] Marketplace screenshots: PR comment, check run, regulator-mode block.
- [ ] Install button on the docs site.
- [ ] 5+ live installs outside `hyperpolymath/*`.
- [ ] OpenSSF Scorecard ≥ 7 on the deployed service.

---

## Out of scope (and why)

| Idea | Why not now |
|---|---|
| Web UI / dashboard per installation | Real product surface, separate roadmap; not needed for v1.0. |
| Self-hosted Slack/Discord notifications | Belongs in a notification fan-out layer, not the App itself. |
| Direct integration with the Oikos *DSL* | Cute, but the DSL targets macroeconomic models, not source code. Cross-product wiring only makes sense once both products are independently shippable. |
| Train a model on PR feedback | The data does not exist yet; revisit after v1.0. |
