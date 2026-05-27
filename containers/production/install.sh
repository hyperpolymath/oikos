#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0-or-later
# OikosBot production installer for Hetzner / Debian 12 (bookworm) or newer.
# Idempotent — safe to re-run after edits.
#
# Usage (as root on a fresh box):
#   git clone https://github.com/hyperpolymath/oikos /opt/oikos
#   cd /opt/oikos/containers/production
#   ./install.sh
#
# What this does:
#   1. Installs Podman 4.4+ (Quadlet support) and Caddy's runtime dependencies.
#   2. Creates the oikosbot system user (uid 1000 inside the container).
#   3. Copies Quadlet unit files to /etc/containers/systemd/.
#   4. Copies the Caddyfile to /etc/oikosbot/Caddyfile.
#   5. Seeds /etc/oikosbot/.env from .env.example if it does not exist.
#   6. Builds the local OikosBot container image.
#   7. Reloads systemd and enables the units.
#
# What this does NOT do:
#   - Configure DNS. You must point A/AAAA records at this box before starting
#     Caddy, or the Let's Encrypt HTTP-01 challenge will fail.
#   - Open the firewall. Run `ufw allow 80,443/tcp` (or equivalent) yourself.
#   - Populate secrets. Edit /etc/oikosbot/.env after install.

set -euo pipefail

# -----------------------------------------------------------------------------
# Preflight
# -----------------------------------------------------------------------------

if [[ "${EUID}" -ne 0 ]]; then
    echo "Run as root: sudo ${0}" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

echo "==> Installing OikosBot from ${REPO_ROOT}"

# -----------------------------------------------------------------------------
# 1. Packages
# -----------------------------------------------------------------------------

echo "==> Ensuring podman, deno (for ReScript build), and curl are present"
apt-get update -qq
apt-get install -y --no-install-recommends \
    podman \
    podman-compose \
    uidmap \
    slirp4netns \
    curl \
    ca-certificates \
    git

# Podman 4.4+ is required for Quadlet. Bookworm ships 4.3 — backports has 4.x+.
PODMAN_MAJOR=$(podman --version | awk '{print $3}' | cut -d. -f1)
PODMAN_MINOR=$(podman --version | awk '{print $3}' | cut -d. -f2)
if [[ ${PODMAN_MAJOR} -lt 4 || (${PODMAN_MAJOR} -eq 4 && ${PODMAN_MINOR} -lt 4) ]]; then
    echo "ERROR: podman >= 4.4 required for Quadlet. Found $(podman --version)." >&2
    echo "On Debian 12, enable bookworm-backports and: apt install -t bookworm-backports podman" >&2
    exit 1
fi

# -----------------------------------------------------------------------------
# 2. System user
# -----------------------------------------------------------------------------

if ! id -u oikosbot &>/dev/null; then
    echo "==> Creating oikosbot system user (uid 1000 inside container)"
    useradd --system --home /var/lib/oikosbot --shell /usr/sbin/nologin oikosbot
fi

# -----------------------------------------------------------------------------
# 3. Quadlet units
# -----------------------------------------------------------------------------

echo "==> Installing Quadlet units"
install -d -m 0755 /etc/containers/systemd
install -m 0644 "${SCRIPT_DIR}/quadlet/oikos.network"      /etc/containers/systemd/
install -m 0644 "${SCRIPT_DIR}/quadlet/caddy-data.volume"  /etc/containers/systemd/
install -m 0644 "${SCRIPT_DIR}/quadlet/caddy.container"    /etc/containers/systemd/
install -m 0644 "${SCRIPT_DIR}/quadlet/oikosbot.container" /etc/containers/systemd/

# -----------------------------------------------------------------------------
# 4. Caddyfile
# -----------------------------------------------------------------------------

echo "==> Installing Caddyfile"
install -d -m 0755 /etc/oikosbot
install -m 0644 "${SCRIPT_DIR}/Caddyfile" /etc/oikosbot/Caddyfile

install -d -m 0755 -o oikosbot -g oikosbot /var/log/caddy

# -----------------------------------------------------------------------------
# 5. .env
# -----------------------------------------------------------------------------

if [[ ! -e /etc/oikosbot/.env ]]; then
    echo "==> Seeding /etc/oikosbot/.env from .env.example (mode 0600)"
    install -m 0600 "${SCRIPT_DIR}/.env.example" /etc/oikosbot/.env
    echo "    EDIT /etc/oikosbot/.env BEFORE STARTING THE BOT."
else
    echo "==> /etc/oikosbot/.env exists — not overwriting"
fi

# -----------------------------------------------------------------------------
# 6. Build the bot image
# -----------------------------------------------------------------------------

# ReScript output must be present before building the image. We expect this to
# happen on the developer's box, not on the production server — bookworm has
# no Deno package and we don't want a JS toolchain on the server.
if ! find "${REPO_ROOT}/bot-integration/src" -name "*.res.js" -print -quit | grep -q .; then
    cat >&2 <<EOF
ERROR: No compiled ReScript output found in bot-integration/src/.
The bot image expects pre-compiled .res.js. On your dev box:
    cd bot-integration
    deno install --node-modules-dir=auto
    ./node_modules/.bin/rescript build
Then re-run ${0} after pushing.
EOF
    exit 1
fi

echo "==> Building localhost/oikosbot:latest"
podman build \
    -t localhost/oikosbot:latest \
    -f "${REPO_ROOT}/containers/Containerfile" \
    "${REPO_ROOT}"

# -----------------------------------------------------------------------------
# 7. systemd
# -----------------------------------------------------------------------------

echo "==> Reloading systemd and starting units"
systemctl daemon-reload

# Bring the network up first so the bot/caddy units can attach
systemctl start oikos-network.service
systemctl enable --now oikosbot.service
systemctl enable --now caddy.service

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------

cat <<EOF

==> Done.

Verify:
    systemctl status oikosbot caddy
    journalctl -u oikosbot -f
    curl -fsS https://\$(grep ^BOT_DOMAIN /etc/oikosbot/.env | cut -d= -f2)/health

Common next steps:
    - Edit /etc/oikosbot/.env (you almost certainly haven't filled the secrets yet)
    - Point the GitHub App's webhook URL at https://<BOT_DOMAIN>/webhooks/github
    - Point the App's external_url at https://<BOT_DOMAIN>
    - Install the App on a test repo and open a PR

Logs:
    journalctl -u oikosbot -u caddy
    tail -f /var/log/caddy/access.log
EOF
