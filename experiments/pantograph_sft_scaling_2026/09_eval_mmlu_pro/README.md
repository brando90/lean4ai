# 09 — Evaluation: MMLU-Pro

## Objective

Evaluate all trained models on MMLU-Pro benchmark.

## Benchmark

MMLU-Pro — harder, more reasoning-focused variant of MMLU.

## Metric

Exact multiple-choice accuracy.

## Runs to evaluate

All 25 trained checkpoints plus 3 base models.

## Reporting

- Overall accuracy
- Per-domain accuracy (STEM, humanities, social sciences, other)
- Mean and std over seeds per condition per scale
- 95% confidence intervals

## Deliverables

- [ ] MMLU-Pro eval script (`eval_mmlu_pro.py`)
- [ ] Per-run results JSONL
- [ ] Aggregated results table (condition × scale × domain)
