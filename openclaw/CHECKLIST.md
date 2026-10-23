# Post-restore checklist (hand to Claude on the new box)

Ask Claude: "I restored OpenClaw with ~/openclaw-migrate/restore.sh; work through CHECKLIST.md."

1. `systemctl --user status openclaw-gateway actual-server`; `journalctl --user -u openclaw-gateway -n 100`.
2. `openclaw doctor`; fix anything it flags (paths, missing plugins, port 18789 reachable).
3. Recreate Python venvs: `~/.openclaw/workspace/.venv-teacher`, `~/.openclaw/workspace-kanji-teacher/.venv`
   (inspect scripts' imports / any requirements file; kanji-teacher: `git pull` from GitLab, needs the SSH key).
4. WhatsApp: send a test message. If the session was invalidated (new IP/device), re-pair via `openclaw` channel login.
5. Telegram: message each bot (main, finance, dmv). Only one host may poll a bot token: STOP the old gateway first.
6. Google API keys (search/TTS) work: trigger a web search and a TTS reply.
7. ActualBudget: open the web UI, confirm data; run `systemctl --user start budget-nightly` once and check logs.
8. SSH keys / gitlab access, `~/.local/bin/claude` login, anything else outside ~/.openclaw (not backed up).
9. Once verified, disable the old server's services.
