# 08 — Evaluation: Hendrycks MATH

## Objective

Evaluate all trained models on Hendrycks MATH benchmark.

## Benchmark

Hendrycks MATH — competition-style math problems.

## Metric

Exact final answer accuracy with standardized parsing (boxed answer extraction).

## Runs to evaluate

All 25 trained checkpoints (9 × 1.5B + 9 × 3B + 7 × 7B) plus 3 base models (no fine-tuning).

## Reporting

- Per-category accuracy (algebra, geometry, number theory, counting & probability, intermediate algebra, pre-algebra, precalculus)
- Mean and std over seeds per condition per scale
- 95% confidence intervals

## Deliverables

- [ ] MATH eval script (`eval_math.py`)
- [ ] Per-run results JSONL
- [ ] Aggregated results table (condition × scale × category)
