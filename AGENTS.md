# AGENTS.md

## Old keys

- Old keys that are revoked or outdated, found in the history or in files, are fine to ignore. Do not raise them as a problem or complaint.
- Never print a key.

## Automatic Claude and Codex jobs (Brando, 11-03-2026)

Applies to every job that calls Claude or Codex without a person typing each turn: cron, launchd, queues, loops, supervisors, watchers, tmux, headless. Full rule: [automation rules](https://github.com/brando90/agents-config/blob/main/rules/automation.md); job list: [manifest](https://github.com/brando90/agents-config/blob/main/automation/manifest.md).

- **Transcript log:** a full transcript goes to a log path chosen before the job starts. No `--no-session-persistence`, `--ephemeral` or equivalent. A job with no log path does not start.
- **End condition:** a time limit, item count or stop file; nothing loops forever.
- **Manifest:** the job is listed (what it does, account, schedule, log path, stop command, stop-email) before its first start.
- **Ceiling:** queue gates stop at 80% of the weekly limit, all-model and Fable meters.
- **Stop email:** when a job that was looping stops, it emails brando.science@gmail.com and brandojazz@gmail.com: what it was doing, why it stopped, suggested next steps (even "done, ignore").
- **No restart** of a stopped job without Brando's yes. Background jobs default to Sonnet 5.5 at medium effort; Opus or Fable at max only with his yes per job.
