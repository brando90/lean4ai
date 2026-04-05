# 09 — Evaluation: MMLU-Pro

## Objective

Evaluate all trained models on MMLU-Pro benchmark.

## Benchmark

- **Dataset:** MMLU-Pro (TIGER-Lab/MMLU-Pro on HuggingFace)
- **Format:** 10-choice multiple choice (A–J)
- **Domains:** STEM, Humanities, Social Sciences, Other
- **Metric:** Exact multiple-choice accuracy

## Runs to evaluate

28 total (same as 08_eval_math): 25 fine-tuned + 3 base models.

## Generation settings

- Temperature: 0.0 (greedy)
- Max new tokens: 1024
- Extract answer: last occurrence of a single capital letter A–J

## SNAP cluster setup

- **Partition:** `gpu`
- **GPUs:** 1x A100 80GB
- **Memory:** 64GB RAM (80GB for 7B)
- **Time limit:** 4 hours per eval run
- **Storage:** `/lfs/ampere8/0/$USER/lean4ai_results/09_eval_mmlu_pro/`

## Reporting

- Overall accuracy
- Per-domain accuracy (STEM, humanities, social sciences, other)
- Mean and std over seeds per condition per scale
- 95% confidence intervals

## Deliverables

- [ ] MMLU-Pro eval script (`eval_mmlu_pro.py`)
- [ ] SLURM submission script (`submit_eval_mmlu_pro.sh`)
- [ ] Per-run results JSONL
- [ ] Aggregated results table (condition × scale × domain)

---

## Claude Code execution prompt

```
Implement an MMLU-Pro evaluation pipeline for all trained models.

Location: /home/user/lean4ai/experiments/pantograph_sft_scaling_2026/09_eval_mmlu_pro/

Context:
- MMLU-Pro is a harder, 10-choice variant of MMLU from TIGER-Lab/MMLU-Pro on HuggingFace.
- Same 28 models to evaluate as 08_eval_math.
- Metric: exact multiple-choice accuracy.

What to build:
1. `eval_mmlu_pro.py` — typed Python CLI that:
   - Loads the model (base or fine-tuned adapter merged with base)
   - Downloads MMLU-Pro test set from HuggingFace (TIGER-Lab/MMLU-Pro)
   - For each question:
     * Formats prompt with the question and all 10 answer choices (A–J)
     * Prompt template:
       "Answer the following multiple choice question. Think step by step, then give your final answer as a single letter (A-J).\n\nQuestion: {question}\n\nChoices:\nA) {A}\nB) {B}\n...\nJ) {J}\n\nAnswer:"
     * Generates response (greedy, max_new_tokens=1024)
     * Extracts predicted answer: regex for last single capital letter A–J in response
     * Compares to ground truth
   - Supports vLLM batch inference (--use-vllm)
   - Writes per-question results.jsonl:
     {
       "question_id": int,
       "subject": str,
       "domain": str,   # STEM, humanities, social_sciences, other
       "correct": bool,
       "predicted": str,
       "ground_truth": str
     }
   - Writes eval_summary.json:
     {
       "model_path": str,
       "condition": str,
       "seed": int,
       "scale": str,
       "overall_accuracy": float,
       "per_domain_accuracy": {"STEM": float, ...},
       "per_subject_accuracy": {"physics": float, ...}
     }

   CLI interface:
     python eval_mmlu_pro.py \
       --model-path /lfs/ampere8/0/$USER/lean4ai_runs/05_pilot_1.5b/cond_a_seed42/ \
       --base-model Qwen/Qwen2.5-1.5B-Instruct \
       --output-dir /lfs/ampere8/0/$USER/lean4ai_results/09_eval_mmlu_pro/1.5b_cond_a_seed42/ \
       --condition A --seed 42 --scale 1.5b \
       --temperature 0.0 --max-new-tokens 1024 \
       --batch-size 16 --use-vllm \
       --cache-dir /lfs/ampere8/0/$USER/hf_cache/

2. `submit_eval_mmlu_pro.sh` — SLURM script for all 28 eval jobs:
   - Partition: gpu, 1x A100 80GB, 64GB RAM (80GB for 7B), 4 hours
   - Job names: eval_mmlu_{scale}_{cond}_{seed}

3. `aggregate_mmlu_pro.py` — aggregation script:
   - Computes per (condition × scale) mean ± std over seeds
   - 95% CI
   - Per-domain breakdown
   - Writes aggregated_mmlu_pro_results.json

   Subject-to-domain mapping: group MMLU-Pro subjects into STEM / humanities / social_sciences / other
   using the standard MMLU category mapping.

Engineering constraints:
- Same patterns as 08_eval_math
- Typed Python, argparse, pathlib
- Robust answer extraction (handle "The answer is B" and bare "B" formats)

SNAP cluster notes:
- Partition: gpu, 1x A100 80GB
- 4 hours per run (MMLU-Pro is larger than MATH)
- Results: /lfs/ampere8/0/$USER/lean4ai_results/09_eval_mmlu_pro/

Do NOT add docstrings to every function.
```
