# 11 — Evaluation: Pantograph Interaction Benchmark

## Objective

Evaluate models on theorem-prover interaction tasks using held-out Pantograph data.

## Tasks

1. **Next-step tactic prediction** — given proof state, predict the next tactic
2. **Proof-state explanation** — given a proof state, produce a clear explanation
3. **Short-horizon proof completion** — given partial proof, complete the next 1–3 steps

## Metrics

- Exact next-step accuracy (task 1)
- Task success rate (tasks 2 and 3)
- Explanation quality scored by judge prompt (task 2)

## Runs to evaluate

All 25 trained checkpoints plus 3 base models.

## Deliverables

- [ ] Pantograph interaction benchmark construction script (`build_interaction_benchmark.py`)
- [ ] Interaction eval script (`eval_interaction.py`)
- [ ] Per-run results JSONL
- [ ] Aggregated results table (condition × scale × task)
