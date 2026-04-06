#!/usr/bin/env bash
# hubble-claw auto-update hook
# Triggered by PreToolUse before any Skill call
# Strategy: check at most once per CHECK_INTERVAL, fetch+compare, pull only if updates exist

set -euo pipefail

REPO_DIR="$CLAUDE_PROJECT_DIR"
CACHE_FILE="/tmp/hubble-claw-last-check"
CHECK_INTERVAL=1  # TODO: change back to 1800 (30 minutes) after testing

# --- time gate: skip if checked recently ---
now=$(date +%s)
last=0
if [ -f "$CACHE_FILE" ]; then
  last=$(cat "$CACHE_FILE" 2>/dev/null || echo 0)
fi

if (( now - last < CHECK_INTERVAL )); then
  exit 0
fi

# --- validate we're in the right repo ---
if [ -z "$REPO_DIR" ] || [ ! -d "$REPO_DIR/.git" ]; then
  exit 0
fi

cd "$REPO_DIR"

# --- fetch and compare ---
git fetch --quiet origin 2>/dev/null || {
  echo "[hubble-claw] git fetch failed (network error?), will retry later"
  echo "$now" > "$CACHE_FILE"
  exit 0
}

local_head=$(git rev-parse HEAD)
remote_head=$(git rev-parse origin/main 2>/dev/null || git rev-parse origin/master 2>/dev/null)

if [ "$local_head" = "$remote_head" ]; then
  echo "$now" > "$CACHE_FILE"
  exit 0
fi

# --- updates available, pull ---
echo "[hubble-claw] New version available, pulling updates..."

git pull --rebase --quiet 2>/dev/null || {
  echo "[hubble-claw] git pull failed (local changes conflict?), will retry later"
  echo "$now" > "$CACHE_FILE"
  exit 0
}

# --- show version ---
new_head=$(git rev-parse HEAD)
if [ -f "$REPO_DIR/VERSION" ]; then
  echo "[hubble-claw] Updated to v$(cat "$REPO_DIR/VERSION" | tr -d '[:space:]') (${new_head:0:7})"
else
  version=$(git describe --tags --abbrev=0 2>/dev/null || echo "no-tag")
  echo "[hubble-claw] Updated to ${version} (${new_head:0:7})"
fi

echo "$now" > "$CACHE_FILE"
exit 0
