<!-- SPDX-License-Identifier: MPL-2.0-or-later -->
<!-- SPDX-FileCopyrightText: 2026 hyperpolymath -->

# OikosBot — Hetzner production deployment

A long-lived production setup designed to survive deploy-target migrations:
plain Podman + systemd + Caddy on a Hetzner Cloud box. No PaaS lock-in, no
proprietary control plane, ~€4/month, recoverable from a clean snapshot in
under ten minutes.

> This is the **production** path. For the dev-stack compose file (ArangoDB,
> Virtuoso, Prometheus, Grafana, etc.), see `../compose.yaml`.

## What you get

```
                    Internet
                       │
                       ▼  443/tcp + 443/udp (HTTP/3) + 80/tcp
                  ┌─────────┐
                  │  Caddy  │  ← Let's Encrypt, TLS termination,
                  │  :443   │     rate limiting, security headers
                  └────┬────┘
                       │  oikos network (10.89.0.0/24, no public route)
                       ▼
                  ┌──────────┐
                  │ OikosBot │  ← ReScript + Deno, no host port
                  │  :3000   │
                  └─────┬────┘
                        │  HTTP
                        ▼
                  ┌──────────────────┐
                  │ Haskell analyser │  ← optional, deploy later
                  │  (not present)   │     (bot posts degraded reports
                  └──────────────────┘      until this exists)
```

## Why Quadlet (not `podman-compose`)

Quadlet generates real systemd unit files from `.container` / `.network` /
`.volume` declarations at unit-load time. Each container becomes a first-class
systemd service: `systemctl status oikosbot`, `journalctl -u caddy`,
`systemd-cgls` to see the resource tree. No Python on the box, no
`podman-compose` shim, no daemon. Restart policy, healthchecks, sandboxing,
and ordering are all expressed in standard systemd vocabulary.

Requires Podman ≥ 4.4 — on Debian 12 that means `apt install -t
bookworm-backports podman`. The installer checks this.

## First-time install

### On your dev box

```bash
# 1. Compile ReScript so the image build has something to copy in.
cd bot-integration
deno install --node-modules-dir=auto
./node_modules/.bin/rescript build

# 2. Commit the .res.js outputs (the image expects them present at build time).
git add bot-integration/src/*.res.js
git commit -m "build: compiled ReScript outputs"
git push
```

### On the Hetzner box

```bash
# 1. Provision a CX22 (or larger) box with Debian 12, your SSH key pre-installed.
#    Hetzner Cloud Console → New Server → Falkenstein/Helsinki/Nuremberg → CX22.

# 2. Lock it down (this is your job, not the installer's):
ssh root@<box-ip> <<'BOX'
    apt-get update && apt-get -y full-upgrade
    apt-get install -y ufw fail2ban unattended-upgrades
    ufw default deny incoming
    ufw allow ssh
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow 443/udp
    ufw enable
    dpkg-reconfigure -plow unattended-upgrades
BOX

# 3. Point DNS at the box. ANY name you control:
#      bot.example.com.   A     <box-ipv4>
#      bot.example.com.   AAAA  <box-ipv6>
#    Wait until `dig +short bot.example.com` resolves before continuing,
#    otherwise Let's Encrypt will fail and rate-limit you.

# 4. Install.
ssh root@<box-ip> <<'BOX'
    git clone https://github.com/hyperpolymath/oikos /opt/oikos
    cd /opt/oikos/containers/production
    ./install.sh
BOX

# 5. Populate secrets.
ssh root@<box-ip> "editor /etc/oikosbot/.env"
#    Set BOT_DOMAIN, BOT_ADMIN_EMAIL, GITHUB_APP_ID,
#    GITHUB_WEBHOOK_SECRET, GITHUB_PRIVATE_KEY (PKCS#8 PEM).

# 6. Restart so the new env is picked up.
ssh root@<box-ip> "systemctl restart oikosbot caddy"

# 7. Verify.
curl -fsS https://bot.example.com/health
# {"status":"healthy","mode":"advisor"}
```

### Final wiring on GitHub

1. Open https://github.com/settings/apps/oikosbot.
2. Set **Homepage URL** and **External URL** to `https://bot.example.com`.
3. Set **Webhook URL** to `https://bot.example.com/webhooks/github`.
4. Confirm **Webhook secret** matches `GITHUB_WEBHOOK_SECRET` in `/etc/oikosbot/.env`.
5. Click **Save changes**. GitHub will send a `ping` webhook — `journalctl -u oikosbot -f` should show it arriving.
6. Install the App on a test repo and open a PR.

## Day-2 operations

### Logs

```bash
# Bot
journalctl -u oikosbot -f

# Caddy access (JSON)
tail -f /var/log/caddy/access.log

# Caddy unit logs (TLS issuance, restarts)
journalctl -u caddy -f
```

### Restart after editing config

```bash
# After editing /etc/oikosbot/.env or /etc/oikosbot/Caddyfile
systemctl restart oikosbot caddy

# After editing a Quadlet unit (.container / .network / .volume)
systemctl daemon-reload
systemctl restart oikosbot caddy
```

### Updating the bot

```bash
# Pull, recompile ReScript on your dev box, push.
# On the server:
cd /opt/oikos && git pull
cd containers/production && ./install.sh   # idempotent; rebuilds the image
systemctl restart oikosbot
```

### Backups

The only state worth backing up:

- `/etc/oikosbot/.env` — secrets. Keep an encrypted copy off-box.
- `caddy-data` volume — Let's Encrypt account + issued certs. Losing it means
  one slow Caddy startup while ACME re-issues. Skippable.

```bash
# Quick env backup
ssh root@<box-ip> 'cat /etc/oikosbot/.env' | gpg -er <your-key> > oikosbot-env.gpg
```

### Migrating to another box / provider

The whole point of this setup is that this is trivial:

```bash
# On the new box:
git clone https://github.com/hyperpolymath/oikos /opt/oikos
cd /opt/oikos/containers/production
./install.sh

# Restore /etc/oikosbot/.env from your backup.
# Update DNS to the new box.
# systemctl restart oikosbot caddy

# Done. The bot is stateless (token cache rebuilds from GitHub on first miss).
```

## Troubleshooting

| Symptom | First thing to check |
|---|---|
| `curl https://bot.example.com/health` → connection refused | `ufw status` — port 443 open? `systemctl status caddy` |
| Caddy: "challenge timeout" | DNS not pointing here yet, or port 80 not open |
| Bot won't start, "Refusing to start: no webhook secret" | `/etc/oikosbot/.env` is missing `GITHUB_WEBHOOK_SECRET` |
| Bot returns 401 to every GitHub webhook | Webhook secret mismatch — regenerate on GitHub, update `.env`, restart |
| PR comments say "analyser unavailable" | Expected until the Haskell analyser ships. Bot is working correctly. |
| GitHub App audit log: "Webhook failed (status 502)" | Bot is down. `systemctl status oikosbot; journalctl -u oikosbot -n 100` |

## Threat model

- **Public surface:** ports 80, 443 (Caddy only). Bot is unreachable from the
  internet.
- **TLS:** Caddy auto-renews 60 days before expiry. No manual rotation.
- **Webhook spoofing:** rejected at the bot layer via HMAC-SHA256 verification
  (`Webhook.verifyGitHubSignature`). Caddy adds nothing here — defence in depth
  is at the app layer.
- **Secrets at rest:** `/etc/oikosbot/.env` is mode 0600 root-only. The bot
  container reads it as an `EnvironmentFile` so secrets never appear in the
  Quadlet unit or `ps` output.
- **Lateral movement:** containers run with `NoNewPrivileges`, `DropCapability=ALL`,
  read-only root filesystem, and an unprivileged uid. A bot compromise can read
  envs (the threat budget assumes that anyway) but can't escalate inside the
  container.
- **SSH:** out of scope for this doc. Use key-only auth, disable root login
  after first deploy, run `fail2ban`.

## When to leave this setup

This is "small infrastructure that lives for years." It is the wrong shape if:

- You need horizontal scaling beyond what one CX22 can deliver. (Webhook
  load: a single box handles tens of thousands of installs comfortably.)
- You need multi-region failover. (DNS round-robin between two of these would
  work, but consider Fly.io at that point.)
- You need a richer observability stack than `journalctl` + `/metrics`.

When you outgrow it, the migration path is straightforward: the bot is
stateless and the only persistent dependency (Caddy's ACME state) is
disposable.
