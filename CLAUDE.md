# CLAUDE.md — lean4ai

## Project

Research repo for "Can Lean4 (and thus Formal Methods) Improve Language Models?" — Pantograph-based SFT scaling study targeting TMLR/NeurIPS 2026.

## Stack

- Python 3.10+, PyTorch, HuggingFace (transformers, peft, trl, datasets)
- Lean 4 + Pantograph (PyPantograph)
- vLLM for inference, lm_eval for benchmarks
- SNAP cluster (Stanford): A100 80GB, SLURM

## Structure

- `src/lean4agi/` — original CS197 paper code (formal→informal, fine-tuning)
- `src/lean4math/` — training, eval, backtranslation pipelines
- `experiments/pantograph_sft_scaling_2026/` — current experiment plan (00–13 subfolders with Claude Code dispatch prompts)
- `latex_paper/lean4agi_cs197/` — original paper LaTeX (section-split)

## Commands

```bash
pip install -e ~/lean4ai          # install in editable mode
conda activate lean4ai            # activate env
```

## Rules

- **TLDR required:** End every response with a `## TLDR` section (1–3 sentences summarizing what happened).
- **Work on `main` branch** unless told otherwise. Push directly to main.
- **PRs:** When creating PRs, keep the body to 5–10 bullet point summary. Put details in an appendix section below.
- **Commits:** Descriptive but concise. No empty commits.
- **No unnecessary files:** Don't create READMEs, docs, or markdown unless explicitly asked.
- **SNAP cluster paths:** Use `/lfs/ampere8/0/$USER/` for data, runs, results. Model cache at `$HF_HOME`.
- **Typed Python:** Use type hints. No docstrings on every function. Keep code lean.
- **No hardcoded paths** in scripts — always CLI args or env vars.

## Conventions

- Experiment subfolders: `00_name`, `01_name`, etc.
- Seeds: 42, 43, 44
- JSON targets for all training data
- SLURM job naming: `{phase}_{scale}_{condition}_{seed}`
