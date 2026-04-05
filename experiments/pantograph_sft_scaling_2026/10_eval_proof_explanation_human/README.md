# 10 — Evaluation: Proof Explanation (Human Eval)

## Objective

Human-rated evaluation of proof explanation quality on 200 held-out Pantograph test examples.

## Protocol

- Sample 200 examples from the held-out Pantograph test split (from 03_dataset_build_and_split)
- Generate proof explanations from all conditions at all scales
- 3 mathematically trained raters per example
- 1–5 scale on each dimension

## Rating dimensions

1. **Faithfulness** — does the explanation accurately reflect the formal proof?
2. **Clarity** — is the explanation clear and well-structured?
3. **Usefulness** — would this help someone understand the theorem?

## Generation settings

- Temperature: 0.0 (greedy)
- Max new tokens: 2048
- Prompt: same as training (system + user input), but generating on test examples

## SNAP cluster setup

- **Partition:** `gpu` (for model inference to generate explanations)
- **GPUs:** 1x A100 80GB
- **Time limit:** 2 hours for generating all explanations
- **Storage:** `/lfs/ampere8/0/$USER/lean4ai_results/10_human_eval/`

## Reporting

- Per-dimension means per condition per scale
- Inter-Rater Reliability (IRR) via Krippendorff's alpha
- Qualitative examples of strong and weak outputs

## Deliverables

- [ ] Human eval export script (`export_human_eval.py`)
- [ ] Generation script for all models (`generate_explanations.py`)
- [ ] SLURM submission script (`submit_generate.sh`)
- [ ] Rating collection spreadsheet/interface
- [ ] Raw ratings JSONL
- [ ] Aggregated human eval table
- [ ] IRR report
- [ ] Selected qualitative examples (strong + weak)

---

## Claude Code execution prompt

```
Implement the proof explanation human evaluation pipeline: sampling, generation, and rating infrastructure.

Location: /home/user/lean4ai/experiments/pantograph_sft_scaling_2026/10_eval_proof_explanation_human/

Context:
- We need to evaluate proof explanation quality via human ratings.
- 200 examples from the held-out Pantograph test split.
- Generate explanations from all 28 models (25 fine-tuned + 3 base).
- 3 raters score each (model × example) pair on faithfulness, clarity, usefulness (1-5 scale).
- This is a critical evaluation bucket for the paper.

What to build:
1. `sample_test_examples.py` — typed Python CLI that:
   - Reads the test split from 03_dataset_build_and_split (condition A test, since it has full traces)
   - Randomly samples 200 examples (seed=42)
   - Stratifies by domain_tag to maintain domain balance
   - Writes sampled_200.jsonl
   - Writes sample_manifest.json (counts per domain)

   CLI:
     python sample_test_examples.py \
       --test-file /lfs/ampere8/0/$USER/lean4ai_data/03_splits/condition_a_test.jsonl \
       --output-dir /lfs/ampere8/0/$USER/lean4ai_results/10_human_eval/ \
       --n-samples 200 \
       --seed 42

2. `generate_explanations.py` — typed Python CLI that:
   - Loads a model (base or fine-tuned)
   - Reads sampled_200.jsonl
   - For each example, generates a proof explanation using the model
   - Prompt: same system message as training + user input from the test example
   - Greedy decoding, max_new_tokens=2048
   - Writes explanations.jsonl:
     {
       "example_id": int,
       "theorem_id": str,
       "model_path": str,
       "condition": str,
       "scale": str,
       "seed": int,
       "generated_explanation": str
     }

   CLI:
     python generate_explanations.py \
       --model-path /lfs/ampere8/0/$USER/lean4ai_runs/05_pilot_1.5b/cond_a_seed42/ \
       --base-model Qwen/Qwen2.5-1.5B-Instruct \
       --input-file /lfs/ampere8/0/$USER/lean4ai_results/10_human_eval/sampled_200.jsonl \
       --output-dir /lfs/ampere8/0/$USER/lean4ai_results/10_human_eval/generations/1.5b_cond_a_seed42/ \
       --condition A --seed 42 --scale 1.5b \
       --temperature 0.0 --max-new-tokens 2048 \
       --cache-dir /lfs/ampere8/0/$USER/hf_cache/

3. `submit_generate.sh` — SLURM script to generate explanations from all 28 models:
   - Partition: gpu, 1x A100 80GB, 2 hours each
   - One job per model

4. `export_rating_sheet.py` — after all generations complete:
   - Reads all explanations from all models for all 200 examples
   - For the paper, we only need to rate a subset of models (e.g., best seed per condition per scale)
   - Or rate all — configurable via --rating-strategy (all | best_seed)
   - Exports a CSV/TSV for raters with columns:
     example_id, theorem_statement, formal_proof_trace, model_id (anonymized), generated_explanation, faithfulness, clarity, usefulness
   - Anonymizes model_id so raters are blind to condition
   - Randomizes row order per rater (different seed per rater)
   - Exports 3 copies (one per rater) with different random orderings

   CLI:
     python export_rating_sheet.py \
       --generations-dir /lfs/ampere8/0/$USER/lean4ai_results/10_human_eval/generations/ \
       --test-data /lfs/ampere8/0/$USER/lean4ai_results/10_human_eval/sampled_200.jsonl \
       --output-dir /lfs/ampere8/0/$USER/lean4ai_results/10_human_eval/rating_sheets/ \
       --rating-strategy best_seed \
       --n-raters 3

5. `analyze_ratings.py` — after raters submit scores:
   - Reads completed rating CSVs
   - De-anonymizes model_ids
   - Computes per-dimension means per condition per scale
   - Computes Krippendorff's alpha for IRR (using krippendorff package)
   - Writes human_eval_results.json
   - Selects qualitative examples:
     * 5 highest-rated examples (best explanations)
     * 5 lowest-rated examples (worst explanations)
     * 5 examples with highest rater disagreement
   - Writes qualitative_examples.json

   CLI:
     python analyze_ratings.py \
       --ratings-dir /lfs/ampere8/0/$USER/lean4ai_results/10_human_eval/rating_sheets/ \
       --output-dir /lfs/ampere8/0/$USER/lean4ai_results/10_human_eval/analysis/

Engineering constraints:
- Typed Python, argparse, pathlib
- Rating sheets must be rater-blind (anonymized model IDs)
- Deterministic sampling and ordering with fixed seeds
- Install krippendorff package for IRR computation

SNAP cluster notes:
- GPU needed only for generate_explanations.py
- Everything else is CPU-only
- Results: /lfs/ampere8/0/$USER/lean4ai_results/10_human_eval/

Do NOT add docstrings to every function.
```
