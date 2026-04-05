# 12 — Aggregation and Plots

## Objective

Aggregate all evaluation results and produce paper-ready figures.

## Aggregation

- Mean, std, 95% CI over seeds for every (condition × scale × benchmark) cell
- Significance testing where appropriate (paired t-test or bootstrap)

## Required plots

1. **Scaling plot** — performance vs. model size for each condition, per benchmark
2. **Control comparison plot** — Condition A vs. B vs. C at each scale, per benchmark
3. **Radar/spider plot** (optional) — multi-benchmark profile per condition at 7B

## Required tables

1. Main results table (all benchmarks × conditions × scales)
2. Human eval summary table
3. Per-category MATH breakdown

## Deliverables

- [ ] Aggregation script (`aggregate.py`)
- [ ] Plotting script (`plot.py`)
- [ ] All figure PDFs
- [ ] All table CSVs / LaTeX snippets
