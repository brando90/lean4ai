# 08 — Evaluation: Hendrycks MATH

## Objective

Evaluate all trained models on Hendrycks MATH benchmark.

## Benchmark

- **Dataset:** Hendrycks MATH (hendrycks/competition_math on HuggingFace)
- **Categories:** Algebra, Counting & Probability, Geometry, Intermediate Algebra, Number Theory, Pre-algebra, Precalculus
- **Metric:** Exact final answer accuracy with boxed answer extraction

## Runs to evaluate

| Scale | Condition A | Condition B | Condition C | Base (no FT) | Total |
|-------|-------------|-------------|-------------|--------------|-------|
| 1.5B  | 3           | 3           | 3           | 1            | 10    |
| 3B    | 3           | 3           | 3           | 1            | 10    |
| 7B    | 3           | 2           | 2           | 1            | 8     |

**Total: 28 evaluation runs**

## Generation settings

- Temperature: 0.0 (greedy decoding)
- Max new tokens: 2048
- Stop tokens: model-specific EOS

## SNAP cluster setup

- **Partition:** `gpu`
- **GPUs:** 1x A100 80GB per eval run
- **Memory:** 64GB RAM (80GB for 7B)
- **Time limit:** 3 hours per eval run
- **Storage:** `/lfs/ampere8/0/$USER/lean4ai_results/08_eval_math/`

## Reporting

- Per-category accuracy
- Mean and std over seeds per condition per scale
- 95% confidence intervals

## Deliverables

- [ ] MATH eval script (`eval_math.py`)
- [ ] SLURM submission script (`submit_eval_math.sh`)
- [ ] Per-run results JSONL
- [ ] Aggregated results table (condition × scale × category)

---

## Claude Code execution prompt

```
Implement a Hendrycks MATH evaluation pipeline for all trained models.

Location: /home/user/lean4ai/experiments/pantograph_sft_scaling_2026/08_eval_math/

Context:
- We have 25 fine-tuned models (9 × 1.5B + 9 × 3B + 7 × 7B) plus 3 base models = 28 to evaluate.
- Checkpoints live under:
  /lfs/ampere8/0/$USER/lean4ai_runs/05_pilot_1.5b/cond_{A,B,C}_seed{42,43,44}/
  /lfs/ampere8/0/$USER/lean4ai_runs/06_scaling_3b/cond_{A,B,C}_seed{42,43,44}/
  /lfs/ampere8/0/$USER/lean4ai_runs/07_scaling_7b/cond_{A,B,C}_seed{42,43,44}/
- Base models: Qwen/Qwen2.5-{1.5B,3B,7B}-Instruct (no fine-tuning)
- Metric: exact boxed answer accuracy on Hendrycks MATH test set.
- The repo already has lm_eval and vllm in pyproject.toml dependencies.

What to build:
1. `eval_math.py` — typed Python CLI that:
   - Loads a model (either base HF model or fine-tuned adapter merged with base)
   - For QLoRA models (7B): loads base in 4-bit, merges adapter, then evaluates
   - Downloads Hendrycks MATH test set from HuggingFace (hendrycks/competition_math)
   - For each problem:
     * Constructs a prompt: "Solve the following math problem. Put your final answer in \\boxed{}.\n\nProblem: {problem}"
     * Generates a response with greedy decoding (temperature=0, max_new_tokens=2048)
     * Extracts the boxed answer using regex: \\boxed{...}
     * Compares to ground truth boxed answer (normalize whitespace, strip $)
   - Supports batch generation via vLLM for speed (optional --use-vllm flag)
   - Writes per-problem results to results.jsonl:
     {
       "problem_id": int,
       "category": str,
       "level": str,
       "correct": bool,
       "predicted_answer": str,
       "ground_truth": str,
       "generated_text": str
     }
   - Writes summary to eval_summary.json:
     {
       "model_path": str,
       "condition": str,
       "seed": int,
       "scale": str,
       "overall_accuracy": float,
       "per_category_accuracy": {"Algebra": float, ...},
       "total_problems": int,
       "total_correct": int
     }

   CLI interface:
     python eval_math.py \
       --model-path /lfs/ampere8/0/$USER/lean4ai_runs/05_pilot_1.5b/cond_a_seed42/ \
       --base-model Qwen/Qwen2.5-1.5B-Instruct \
       --output-dir /lfs/ampere8/0/$USER/lean4ai_results/08_eval_math/1.5b_cond_a_seed42/ \
       --condition A \
       --seed 42 \
       --scale 1.5b \
       --temperature 0.0 \
       --max-new-tokens 2048 \
       --batch-size 16 \
       --use-vllm \
       --cache-dir /lfs/ampere8/0/$USER/hf_cache/

     For base model eval (no adapter):
     python eval_math.py \
       --model-path Qwen/Qwen2.5-1.5B-Instruct \
       --output-dir /lfs/ampere8/0/$USER/lean4ai_results/08_eval_math/1.5b_base/ \
       --condition base \
       --scale 1.5b \
       --is-base-model

2. `submit_eval_math.sh` — SLURM script that submits all 28 eval jobs:
   - 1 job per model checkpoint
   - Partition: gpu, 1x A100 80GB, 64GB RAM (80GB for 7B), 3 hours
   - Job names: eval_math_{scale}_{cond}_{seed}
   - Logs: /lfs/ampere8/0/$USER/lean4ai_results/08_eval_math/logs/

3. `aggregate_math.py` — after all evals complete:
   - Reads all eval_summary.json files
   - Computes per (condition × scale) mean accuracy ± std over seeds
   - Computes 95% CI: mean ± 1.96 * std / sqrt(n_seeds)
   - Writes aggregated_math_results.json and prints a formatted table
   - Per-category breakdown in aggregated_math_by_category.json

Engineering constraints:
- Typed Python, argparse CLI, pathlib
- Support both adapter-merged inference and base model inference
- Robust boxed answer extraction: handle nested braces, LaTeX formatting
- Deterministic: greedy decoding, fixed seed for any sampling

SNAP cluster notes:
- Partition: gpu, 1x A100 80GB
- Use vLLM for fast batch inference where possible
- Cache: /lfs/ampere8/0/$USER/hf_cache/
- Results: /lfs/ampere8/0/$USER/lean4ai_results/08_eval_math/
- ~3 hours per run, 28 runs total

Do NOT add docstrings to every function.
```
