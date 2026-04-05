# 12 — Aggregation and Plots

## Objective

Aggregate all evaluation results and produce paper-ready figures and tables.

## Aggregation

- Mean, std, 95% CI over seeds for every (condition × scale × benchmark) cell
- Significance testing: paired bootstrap (10,000 resamples) for Condition A vs B and A vs C
- Effect sizes: Cohen's d for key comparisons

## Required plots

1. **Scaling plot** — x-axis: model size (1.5B, 3B, 7B), y-axis: accuracy, one line per condition. One subplot per benchmark.
2. **Control comparison bar chart** — grouped bars (A vs B vs C) at each scale, per benchmark.
3. **Per-category MATH heatmap** — rows: MATH categories, columns: (condition × scale), cells: accuracy.

## Required tables

1. Main results table (all benchmarks × conditions × scales) with mean ± std
2. Human eval summary table with IRR
3. Per-category MATH breakdown
4. Interaction benchmark breakdown by task

## SNAP cluster setup

- **Partition:** CPU-only
- **Memory:** 8GB RAM
- **Time:** <10 minutes
- **Storage:** `/lfs/ampere8/0/$USER/lean4ai_results/12_plots/`

## Deliverables

- [ ] Aggregation script (`aggregate.py`)
- [ ] Plotting script (`plot.py`)
- [ ] All figure PDFs
- [ ] All table CSVs / LaTeX snippets

---

## Claude Code execution prompt

```
Implement aggregation and plotting scripts for the Pantograph SFT scaling study.

Location: /home/user/lean4ai/experiments/pantograph_sft_scaling_2026/12_aggregation_and_plots/

Context:
- Results from 4 evaluation buckets are stored as JSON summaries:
  /lfs/ampere8/0/$USER/lean4ai_results/08_eval_math/*/eval_summary.json
  /lfs/ampere8/0/$USER/lean4ai_results/09_eval_mmlu_pro/*/eval_summary.json
  /lfs/ampere8/0/$USER/lean4ai_results/10_human_eval/analysis/human_eval_results.json
  /lfs/ampere8/0/$USER/lean4ai_results/11_interaction/*/eval_summary.json
- We need to aggregate across seeds, compute statistics, and produce paper-ready figures.

What to build:
1. `aggregate.py` — typed Python CLI that:
   - Scans result directories for all eval_summary.json files
   - Groups results by (benchmark, condition, scale)
   - For each group, computes:
     * mean accuracy over seeds
     * standard deviation
     * 95% CI: mean ± 1.96 * std / sqrt(n)
     * min and max seed values
   - Runs paired bootstrap significance tests (10,000 resamples):
     * Condition A vs Condition B (same scale, same benchmark)
     * Condition A vs Condition C (same scale, same benchmark)
     * Reports p-values and whether significant at alpha=0.05
   - Computes Cohen's d effect size for each comparison
   - Also aggregates per-category MATH results and per-domain MMLU-Pro results
   - Writes:
     * aggregated_all.json — full nested results
     * main_results_table.csv — flat table for easy viewing
     * significance_tests.json — all pairwise comparisons

   CLI:
     python aggregate.py \
       --math-dir /lfs/ampere8/0/$USER/lean4ai_results/08_eval_math/ \
       --mmlu-dir /lfs/ampere8/0/$USER/lean4ai_results/09_eval_mmlu_pro/ \
       --human-eval-file /lfs/ampere8/0/$USER/lean4ai_results/10_human_eval/analysis/human_eval_results.json \
       --interaction-dir /lfs/ampere8/0/$USER/lean4ai_results/11_interaction/ \
       --output-dir /lfs/ampere8/0/$USER/lean4ai_results/12_plots/

2. `plot.py` — typed Python CLI that reads aggregated_all.json and produces:

   Figure 1 — Scaling plot (PDF):
     - 2×2 grid of subplots (one per benchmark: MATH, MMLU-Pro, Human Eval mean, Interaction score)
     - x-axis: model size (1.5B, 3B, 7B)
     - y-axis: accuracy/score
     - 3 lines: Condition A (solid blue), Condition B (dashed orange), Condition C (dotted green)
     - Error bars: 95% CI
     - Legend, axis labels, grid lines
     - Style: matplotlib with seaborn "whitegrid" theme, font size 12
     - Save as scaling_plot.pdf

   Figure 2 — Control comparison bar chart (PDF):
     - 4 subplots (one per benchmark)
     - Grouped bars: 3 groups (1.5B, 3B, 7B), 3 bars each (A, B, C)
     - Error bars: std
     - Colors: A=steelblue, B=darkorange, C=forestgreen
     - Save as control_comparison.pdf

   Figure 3 — MATH category heatmap (PDF):
     - Rows: MATH categories (7 categories)
     - Columns: condition × scale (9 columns)
     - Cell values: accuracy
     - Color map: YlOrRd
     - Annotated with accuracy values
     - Save as math_heatmap.pdf

   CLI:
     python plot.py \
       --input-file /lfs/ampere8/0/$USER/lean4ai_results/12_plots/aggregated_all.json \
       --output-dir /lfs/ampere8/0/$USER/lean4ai_results/12_plots/figures/

3. `export_latex_tables.py` — generates LaTeX table snippets:
   - main_results.tex — the main paper results table
   - math_breakdown.tex — per-category MATH breakdown
   - human_eval.tex — human eval with IRR
   - interaction.tex — interaction benchmark by task
   - Format: booktabs style (\toprule, \midrule, \bottomrule)
   - Bold the best result in each row
   - Include ± std

   CLI:
     python export_latex_tables.py \
       --input-file /lfs/ampere8/0/$USER/lean4ai_results/12_plots/aggregated_all.json \
       --output-dir /lfs/ampere8/0/$USER/lean4ai_results/12_plots/tables/

Engineering constraints:
- Typed Python, argparse, pathlib
- Use matplotlib + seaborn for plotting
- Figures: PDF format, 300 DPI, tight_layout
- Tables: booktabs-style LaTeX
- No hardcoded paths
- Bootstrap uses numpy with seed=42 for reproducibility

Dependencies: matplotlib, seaborn, numpy, pandas

SNAP cluster notes:
- CPU-only, 8GB RAM, <10 minutes
- Results: /lfs/ampere8/0/$USER/lean4ai_results/12_plots/

Do NOT add docstrings to every function.
```
