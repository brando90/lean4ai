# CLAUDE.md — lean4ai

Read `~/agents-config/INDEX_RULES.md` for all global rules, machine docs, and workflow routing.

**Remote fallback:** If `~/agents-config/` is not available locally, fetch files from `https://raw.githubusercontent.com/brando90/agents-config/main/`.

---

## Automatic Claude and Codex jobs (Brando, 11-03-2026)

Applies to every job that calls Claude or Codex without a person typing each turn: cron, launchd, queues, loops, supervisors, watchers, tmux, headless. Full rule: [automation rules](https://github.com/brando90/agents-config/blob/main/rules/automation.md); job list: [manifest](https://github.com/brando90/agents-config/blob/main/automation/manifest.md).

- **Transcript log:** a full transcript goes to a log path chosen before the job starts. No `--no-session-persistence`, `--ephemeral` or equivalent. A job with no log path does not start.
- **End condition:** a time limit, item count or stop file; nothing loops forever.
- **Manifest:** the job is listed (what it does, account, schedule, log path, stop command, stop-email) before its first start.
- **Ceiling:** queue gates stop at 80% of the weekly limit, all-model and Fable meters.
- **Stop email:** when a job that was looping stops, it emails brando.science@gmail.com and brandojazz@gmail.com: what it was doing, why it stopped, suggested next steps (even "done, ignore").
- **No restart** of a stopped job without Brando's yes. Background jobs default to Sonnet 5.5 at medium effort; Opus or Fable at max only with his yes per job.

## Project

Research repo for "Can Lean4 (and thus Formal Methods) Improve Language Models?" — Pantograph-based SFT scaling study targeting TMLR/NeurIPS 2026.

## Stack

- Python 3.10+, PyTorch, HuggingFace (transformers, peft, trl, datasets)
- Lean 4 + Pantograph (PyPantograph)
- vLLM for inference, lm_eval for benchmarks
- SNAP cluster (Stanford): A100 80GB — see `~/agents-config/machine/snap.md`

## Structure

- `src/lean4agi/` — original CS197 paper code (formal→informal, fine-tuning)
- `experiments/pantograph_sft_scaling_2026/` — current experiment plan (00–13 subfolders with Claude Code dispatch prompts)
- `latex_paper/lean4agi_cs197/` — original paper LaTeX (section-split)
- The Lean-ing on Quality paper (arXiv 2502.15795: backtranslation, training, dataset generation, `src/lean4math`) moved to https://github.com/brando90/agi4lean on 2026-11-01. The old tree is kept at tag/branch `archive/pre-agi4lean-split-2026-11-01`.

## Commands

```bash
pip install -e ~/lean4ai          # install in editable mode
conda activate lean4ai            # activate env
```

## Project-specific rules

These supplement the global rules in `~/agents-config/INDEX_RULES.md`:

- **SNAP cluster paths:** Use `/lfs/<hostname>/0/$USER/` for data, runs, results. Model cache at `$HF_HOME`. See `~/agents-config/machine/snap.md` for full filesystem layout.
- **Typed Python:** Use type hints. No docstrings on every function. Keep code lean.
- **No hardcoded paths** in scripts — always CLI args or env vars.
- **Experiment structure:** Follow `~/agents-config/workflows/expts-and-results.md`. Each experiment subfolder gets a `claude_code.md` prompt.

## Conventions

- Experiment subfolders: `00_name`, `01_name`, etc.
- Seeds: 42, 43, 44
- JSON targets for all training data
- SLURM job naming: `{phase}_{scale}_{condition}_{seed}`
- W&B entity: `brando-su`, project: `lean4ai-pantograph-sft`

## Old keys

- Old keys that are revoked or outdated, found in the history or in files, are fine to ignore. Do not raise them as a problem or complaint.
- Never print a key.
