# 03 — Dataset Build and Split

## Objective

Materialize the final training/dev/test datasets with theorem-level splits.

## Split policy

- 80% train / 10% dev / 10% test-holdout
- **No theorem appears in more than one split**
- No near-duplicate theorem signatures across splits
- Maintain rough domain balance across splits

## Views materialized

| View   | Condition | Contents |
|--------|-----------|----------|
| View A | A         | Full trace: statement + proof states + tactics + metadata → faithful informal proof |
| View B | B         | Theorem only: statement + minimal metadata → proof sketch |

(View C is built separately in `04_generic_math_control_data`)

## SNAP cluster setup

- **Partition:** CPU-only (data processing, no GPU needed)
- **Memory:** 16GB RAM
- **Estimated time:** <30 minutes
- **Storage:** `/lfs/ampere8/0/$USER/lean4ai_data/03_splits/`

## Deliverables

- [ ] Split script (`build_splits.py`)
- [ ] `train.jsonl`, `dev.jsonl`, `test.jsonl` for View A
- [ ] `train.jsonl`, `dev.jsonl`, `test.jsonl` for View B
- [ ] Split manifest with per-split counts and domain distributions
- [ ] Deduplication / leakage check report

---

## Claude Code execution prompt

```
Implement a dataset splitting pipeline that produces theorem-level train/dev/test splits.

Location: /home/user/lean4ai/experiments/pantograph_sft_scaling_2026/03_dataset_build_and_split/

Context:
- Input: filtered_condition_a.jsonl and filtered_condition_b.jsonl from 02_faithfulness_filtering
- Each line has theorem_id, condition, input_theorem, generated_target, etc.
- We need theorem-level splits (no theorem in >1 split) with domain balance
- These splits will be used for fine-tuning Qwen2.5 models at 1.5B/3B/7B scale

What to build:
1. `build_splits.py` — typed Python CLI that:
   - Reads filtered JSONL files for Conditions A and B
   - Collects unique theorem_ids
   - Performs near-duplicate detection on theorem_statement text:
     * Normalize whitespace, strip comments
     * Use character-level 3-gram Jaccard similarity
     * Flag pairs with similarity > 0.85 as near-duplicates
     * Keep only one from each near-duplicate cluster
   - Groups theorems by domain_tag
   - Within each domain group, randomly assigns theorems to train/dev/test (80/10/10)
     using a fixed random seed (seed=42)
   - Materializes View A and View B JSONL files:
     * View A train/dev/test: full trace input + faithful informal proof target
     * View B train/dev/test: theorem-only input + proof sketch target
   - Each output line is a training-ready example:
     {
       "theorem_id": str,
       "condition": "A" or "B",
       "input": str,   # formatted input text
       "target": str,   # the JSON target as a string
       "domain_tag": str,
       "split": "train" or "dev" or "test"
     }

   For View A input formatting:
     "Theorem: {theorem_statement}\nProof states:\n{formatted proof_states}\nTactics:\n{formatted tactics}"

   For View B input formatting:
     "Theorem: {theorem_statement}"

   CLI interface:
     python build_splits.py \
       --condition-a-file /lfs/ampere8/0/$USER/lean4ai_data/02_filtering/filtered_condition_a.jsonl \
       --condition-b-file /lfs/ampere8/0/$USER/lean4ai_data/02_filtering/filtered_condition_b.jsonl \
       --output-dir /lfs/ampere8/0/$USER/lean4ai_data/03_splits/ \
       --train-ratio 0.8 \
       --dev-ratio 0.1 \
       --test-ratio 0.1 \
       --dedup-threshold 0.85 \
       --seed 42

2. `validate_splits.py` — reads the output splits and checks:
   - No theorem_id appears in more than one split
   - No near-duplicate theorem_statements across splits
   - Domain distribution is roughly balanced across splits
   - Prints a summary report and writes split_manifest.json with:
     * Per-split counts
     * Per-domain per-split counts
     * Near-duplicate pairs removed
     * Total examples per view

Engineering constraints:
- Typed Python, CLI via argparse, pathlib throughout
- No hardcoded paths
- Deterministic: fixed seed, sorted processing order
- Fast: should complete in <30 minutes even for 10k+ theorems

SNAP cluster notes:
- CPU-only, 16GB RAM, <30 min
- Output: /lfs/ampere8/0/$USER/lean4ai_data/03_splits/

Do NOT add docstrings to every function.
```
