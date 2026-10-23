#!/usr/bin/env bash
# Run on the OLD server. Produces an encrypted archive of the full OpenClaw setup.
# Usage: ./backup.sh [output_dir]   (default: ~/openclaw-migrate/out)
set -euo pipefail

OUT_DIR="${1:-$HOME/openclaw-migrate/out}"
STAMP="$(date +%Y%m%d-%H%M)"
STAGE="$(mktemp -d)"
NODE_BIN="$(cat "$HOME/.openclaw-node24-bin" 2>/dev/null || true)"
SVC=(openclaw-gateway.service actual-server.service)
mkdir -p "$OUT_DIR"

cleanup() { systemctl --user start "${SVC[@]}" 2>/dev/null || true; rm -rf "$STAGE"; }
trap cleanup EXIT

echo "stopping services for a consistent snapshot..."
systemctl --user stop "${SVC[@]}" || true

cat > "$STAGE/MANIFEST.txt" <<M
created=$STAMP
old_home=$HOME
old_user=$USER
arch=$(uname -m)
openclaw_version=$("$NODE_BIN/openclaw" --version 2>/dev/null | head -1 || echo unknown)
node_version=$("$NODE_BIN/node" --version 2>/dev/null || echo unknown)
M

cd "$HOME"
tar -czf "$STAGE/payload.tgz" \
  --exclude='.openclaw/cache' --exclude='.openclaw/tmp' --exclude='.openclaw/npm' \
  --exclude='.openclaw/browser' --exclude='.openclaw/update-captures' \
  --exclude='.openclaw/completions' \
  --exclude='.venv' --exclude='.venv-*' --exclude='__pycache__' \
  --exclude='node_modules' --exclude='ActualBudget/automation/snapshots' \
  --exclude='ActualBudget/automation/cache' \
  .openclaw \
  ActualBudget \
  .config/systemd/user/openclaw-gateway.service \
  .config/systemd/user/actual-server.service \
  .config/systemd/user/budget-*.service \
  .config/systemd/user/budget-*.timer \
  .openclaw-node24-bin 2>/dev/null

tar -C "$STAGE" -cf "$STAGE/bundle.tar" MANIFEST.txt payload.tgz
OUT="$OUT_DIR/openclaw-$STAMP.tar.gpg"
echo "encrypting (passphrase from $OPENCLAW_PASSFILE, default ~/.openclaw-backup-pass, else prompt)..."
PASSFILE="${OPENCLAW_PASSFILE:-$HOME/.openclaw-backup-pass}"
if [ -r "$PASSFILE" ]; then
  gpg --batch --pinentry-mode loopback --passphrase-file "$PASSFILE" \
    --symmetric --cipher-algo AES256 -o "$OUT" "$STAGE/bundle.tar"
else
  gpg --symmetric --cipher-algo AES256 -o "$OUT" "$STAGE/bundle.tar"
fi
echo "done: $OUT ($(du -h "$OUT" | cut -f1))"
echo "copy it over:  rsync -avP '$OUT' newhost:~/"
