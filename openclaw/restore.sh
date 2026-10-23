#!/usr/bin/env bash
# Run on the NEW server (Ubuntu/Debian assumed).
# Usage: ./restore.sh openclaw-XXXX.tar.gpg
set -euo pipefail

ARCHIVE="${1:?usage: restore.sh <archive.tar.gpg>}"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT

sudo apt-get update -qq
sudo apt-get install -y -qq gnupg curl git python3-venv build-essential nodejs npm >/dev/null

echo "decrypting..."
gpg --decrypt -o "$WORK/bundle.tar" "$ARCHIVE"
tar -C "$WORK" -xf "$WORK/bundle.tar"
# shellcheck disable=SC1091
source <(grep -E '^[a-z_]+=' "$WORK/MANIFEST.txt")
echo "backup from $old_user@$old_home, openclaw $openclaw_version, node $node_version, $arch"
[ "$arch" = "$(uname -m)" ] || echo "WARNING: architecture differs; native modules will be reinstalled"

# node via nvm, pinned to the old version
export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi
# shellcheck disable=SC1091
. "$NVM_DIR/nvm.sh"
nvm install "${node_version#v}"
nvm alias default "${node_version#v}"
NODE_BIN="$(dirname "$(nvm which "${node_version#v}")")"
ver="$(echo "$openclaw_version" | grep -oE '[0-9]{4}\.[0-9]+\.[0-9]+' | head -1)"
npm install -g "openclaw@${ver:-latest}"

# files
tar -C "$HOME" -xzf "$WORK/payload.tgz"
echo "$NODE_BIN" > "$HOME/.openclaw-node24-bin"
chmod 700 "$HOME/.openclaw"

# rewrite paths if home/user/node path differ
OLD_NODE="$(grep -oE '/[^ ]*/versions/node/v[0-9.]+/bin' "$HOME/.config/systemd/user/openclaw-gateway.service" | head -1 || true)"
files=("$HOME/.openclaw/openclaw.json" "$HOME"/.config/systemd/user/*.service)
if [ "$old_home" != "$HOME" ]; then sed -i "s#$old_home#$HOME#g" "${files[@]}"; fi
if [ -n "$OLD_NODE" ] && [ "$OLD_NODE" != "$NODE_BIN" ]; then sed -i "s#$OLD_NODE#$NODE_BIN#g" "${files[@]}"; fi

# python venvs are not backed up
echo "NOTE: python venvs (.venv, .venv-teacher) are not restored; recreate per workspace, see Claude checklist."

# ActualBudget node deps (not backed up)
for d in runtime automation; do
  [ -f "$HOME/ActualBudget/$d/package.json" ] && (cd "$HOME/ActualBudget/$d" && npm ci --silent)
done

# services
sudo loginctl enable-linger "$USER"
systemctl --user daemon-reload
systemctl --user enable --now openclaw-gateway.service actual-server.service
systemctl --user enable --now budget-backup.timer budget-nightly.timer
sleep 5
systemctl --user --no-pager status openclaw-gateway.service | head -8
"$NODE_BIN/openclaw" doctor || true
echo "restored. Next: see CHECKLIST.md (WhatsApp/Telegram verification, venvs)."
