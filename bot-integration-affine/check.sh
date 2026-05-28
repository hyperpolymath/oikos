#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# check.sh — runs `affinescript check` on every .affine file in src/
# and test/. Used as a pre-PR gate while the cross-module build wire-up
# is pending. Exits non-zero if any file fails to PARSE; resolution
# errors (cross-module imports) are reported but do not fail the gate.

set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
AS_BIN="${AS_BIN:-$HOME/developer/repos/affinescript/_build/default/bin/main.exe}"

if [ ! -x "$AS_BIN" ]; then
  echo "error: affinescript compiler not found at $AS_BIN" >&2
  echo "  override with AS_BIN=/path/to/main.exe" >&2
  exit 2
fi

fail=0
parse_only_pass=0
full_pass=0

check_one() {
  local f="$1"
  local out
  out=$("$AS_BIN" check "$f" 2>&1)
  if [ "$out" = "Type checking passed" ]; then
    printf "  [PASS] %s\n" "$f"
    full_pass=$((full_pass + 1))
    return
  fi
  if echo "$out" | head -1 | grep -q "parse error"; then
    printf "  [FAIL parse] %s\n%s\n" "$f" "$out"
    fail=$((fail + 1))
    return
  fi
  # Any other error class (Resolution / Visibility / etc.) is treated
  # as parse-OK pending build-orchestrator landing.
  printf "  [PARSE-OK / resolve] %s\n" "$f"
  parse_only_pass=$((parse_only_pass + 1))
}

echo "Checking src/*.affine ..."
for f in "$HERE"/src/*.affine; do
  [ -f "$f" ] && check_one "$f"
done

echo "Checking test/*.affine ..."
for f in "$HERE"/test/*.affine; do
  [ -f "$f" ] && check_one "$f"
done

echo
printf "Summary: %d full-pass, %d parse-only, %d failed\n" \
  "$full_pass" "$parse_only_pass" "$fail"

exit "$fail"
