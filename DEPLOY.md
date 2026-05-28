<!--
SPDX-License-Identifier: MPL-2.0-or-later
SPDX-FileCopyrightText: 2024-2025 hyperpolymath
-->

# Oikos Bot Deployment Guide

> **Status: in flight.**
>
> The previous OikosBot deployment runbook (Podman Quadlet + Caddy +
> ReScript/Deno containers under `containers/production/`) was retired on
> 2026-05-28 alongside the ReScript codebase. See `git log -- containers/`
> and `git log -- bot-integration/` for the prior material — it remains a
> valid reference for the runtime topology (Caddy reverse-proxy + bot
> network + healthchecks) and can be re-used once the AffineScript port
> reaches operational parity.
>
> The replacement codebase is the AffineScript port at
> [`bot-integration-affine/`](bot-integration-affine/). It is currently a
> scaffold: cross-module type-checking, JSON payload extraction, and the
> HTTP server accept loop are gated on upstream AffineScript stdlib work
> (`Json` v0.3 RSR rewire + `http-capability-gateway` extern surfacing).
> Production deployment will resume once those gates lift and the AS
> port has a stable build target.
>
> For now, OikosBot is **not** running in production. The previous
> `.github/app.yml` manifest still describes the intended permissions
> and webhook events and remains valid for re-registering the GitHub
> App when the AS port is ready.
