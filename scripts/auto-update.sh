#!/usr/bin/env bash
# hubble-claw auto-update script
# Triggered by Claude Code hook before Skill calls
# Strategy: check at most once per CHECK_INTERVAL seconds, fetch + compare, pull only if updates exist

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CACHE_FILE="/tmp/hubble-claw-last-check"
CHECK_INTERVAL=1  # TODO: change back to 1800 (30 minutes) after testing

# --- time gate: skip if checked recently ---
now=$(date +%s)
last=0
if [ -f "$CACHE_FILE" ]; then
  last=$(cat "$CACHE_FILE" 2>/dev/null || echo 0)
fi

if (( now - last < CHECK_INTERVAL )); then
  exit 0  # silent skip, no output
fi

# --- fetch and check for updates ---
cd "$REPO_DIR"

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "[hubble-claw] Not a git repo, skipping auto-update"
  exit 0
fi

git fetch --quiet origin 2>/dev/null || {
  echo "[hubble-claw] git fetch failed (network error?), skipping"
  echo "$now" > "$CACHE_FILE"
  exit 0
}

local_head=$(git rev-parse HEAD)
remote_head=$(git rev-parse origin/main 2>/dev/null || git rev-parse origin/master 2>/dev/null)

if [ "$local_head" = "$remote_head" ]; then
  # up to date — just refresh cache
  echo "$now" > "$CACHE_FILE"
  exit 0
fi

# --- updates available, pull ---
echo "[hubble-claw] New version detected, pulling..."

git pull --rebase --quiet 2>/dev/null || {
  echo "[hubble-claw] git pull failed (local changes conflict?), skipping"
  echo "$now" > "$CACHE_FILE"
  exit 0
}

# --- show version info ---
new_head=$(git rev-parse HEAD)
if [ -f "$REPO_DIR/VERSION" ]; then
  echo "[hubble-claw] Updated to version $(cat "$REPO_DIR/VERSION") (${new_head:0:7})"
else
  version=$(git describe --tags --abbrev=0 2>/dev/null || echo "no-tag")
  echo "[hubble-claw] Updated to ${version} (${new_head:0:7})"
fi

echo "$now" > "$CACHE_FILE"
exit 0
