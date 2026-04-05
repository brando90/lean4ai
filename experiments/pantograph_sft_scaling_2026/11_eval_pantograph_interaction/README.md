# 11 — Evaluation: Pantograph Interaction Benchmark

## Objective

Evaluate models on theorem-prover interaction tasks using held-out Pantograph data.

## Tasks

1. **Next-step tactic prediction** — given theorem + proof state, predict the next tactic
2. **Proof-state explanation** — given theorem + proof state, produce a clear explanation
3. **Short-horizon proof completion** — given theorem + first k tactics, complete next 1–3 steps

## Metrics

- **Task 1:** Exact match accuracy (tactic string matches ground truth after normalization)
- **Task 2:** Judge-scored quality (1–5 scale using LLM judge, same as 02_faithfulness_filtering judge)
- **Task 3:** Fraction of completions where all predicted tactics are valid Lean 4 tactics (verified via Pantograph if available, else string match)

## Benchmark size

- 500 examples total: ~170 per task, sampled from test split
- Stratified by domain and proof length

## SNAP cluster setup

- **Partition:** `gpu`
- **GPUs:** 1x A100 80GB
- **Time limit:** 3 hours per model eval
- **Storage:** `/lfs/ampere8/0/$USER/lean4ai_results/11_interaction/`

## Deliverables

- [ ] Benchmark construction script (`build_interaction_benchmark.py`)
- [ ] Interaction eval script (`eval_interaction.py`)
- [ ] SLURM submission script (`submit_eval_interaction.sh`)
- [ ] Per-run results JSONL
- [ ] Aggregated results table (condition × scale × task)

---

## Claude Code execution prompt

```
Build a Pantograph interaction benchmark and evaluation pipeline.

Location: /home/user/lean4ai/experiments/pantograph_sft_scaling_2026/11_eval_pantograph_interaction/

Context:
- This evaluates whether models can interact with Lean 4 via Pantograph-style tasks.
- Three tasks: tactic prediction, proof-state explanation, short-horizon completion.
- 500 held-out examples from the Pantograph test split.
- Same 28 models to evaluate.

What to build:
1. `build_interaction_benchmark.py` — typed Python CLI that:
   - Reads test split from 03_dataset_build_and_split (condition A test — has full traces)
   - Constructs 3 task types from each proof instance:

   Task 1 — Next-step tactic prediction:
     - For each proof with ≥2 steps, pick a random intermediate step i
     - Input: theorem_statement + proof_states[0..i]
     - Target: tactics[i] (the next tactic)
     - Prompt: "Given the following Lean 4 theorem and proof state, predict the next tactic.\n\nTheorem: {theorem_statement}\n\nCurrent proof state:\n{proof_states[i]}\n\nNext tactic:"

   Task 2 — Proof-state explanation:
     - For each proof, pick a random proof state
     - Input: theorem_statement + proof_states[j]
     - Target: (no ground truth — will be judge-scored)
     - Prompt: "Explain in plain mathematical language what the following Lean 4 proof state means and what remains to be proved.\n\nTheorem: {theorem_statement}\n\nProof state:\n{proof_states[j]}\n\nExplanation:"

   Task 3 — Short-horizon completion:
     - For each proof with ≥3 steps, give first k steps and ask for next 1–3
     - Input: theorem_statement + tactics[0..k]
     - Target: tactics[k..k+3] (or remaining if fewer)
     - Prompt: "Given the following Lean 4 theorem and partial proof, provide the next 1-3 tactic steps.\n\nTheorem: {theorem_statement}\n\nTactics so far:\n{formatted tactics[0..k]}\n\nNext tactics:"

   - Sample ~170 examples per task (500 total), stratified by domain and proof length
   - Seed=42 for reproducibility
   - Write benchmark.jsonl:
     {
       "example_id": int,
       "task": "tactic_prediction" | "state_explanation" | "proof_completion",
       "theorem_id": str,
       "input_prompt": str,
       "ground_truth": str or null,
       "domain_tag": str,
       "proof_length": int
     }

   CLI:
     python build_interaction_benchmark.py \
       --test-file /lfs/ampere8/0/$USER/lean4ai_data/03_splits/condition_a_test.jsonl \
       --output-dir /lfs/ampere8/0/$USER/lean4ai_results/11_interaction/ \
       --n-total 500 \
       --seed 42

2. `eval_interaction.py` — typed Python CLI that:
   - Loads model (base or fine-tuned)
   - Reads benchmark.jsonl
   - Generates responses for all 500 examples (greedy, max_new_tokens=512)
   - Scores each task:
     * Task 1: exact match after normalization (strip whitespace, normalize spacing)
     * Task 2: call LLM judge (same judge prompt style as 02) to score 1-5 on clarity and correctness
     * Task 3: count how many predicted tactics exactly match ground truth (partial credit: k/n correct)
   - Writes per-example results.jsonl:
     {
       "example_id": int,
       "task": str,
       "predicted": str,
       "ground_truth": str or null,
       "score": float,  # 0/1 for task 1, 1-5 for task 2, fraction for task 3
       "exact_match": bool  # for tasks 1 and 3
     }
   - Writes eval_summary.json:
     {
       "model_path": str,
       "condition": str, "seed": int, "scale": str,
       "task1_accuracy": float,
       "task2_mean_score": float,
       "task3_success_rate": float,
       "overall_interaction_score": float  # mean of normalized task scores
     }

   CLI:
     python eval_interaction.py \
       --model-path <checkpoint_dir> \
       --base-model Qwen/Qwen2.5-1.5B-Instruct \
       --benchmark-file /lfs/ampere8/0/$USER/lean4ai_results/11_interaction/benchmark.jsonl \
       --output-dir /lfs/ampere8/0/$USER/lean4ai_results/11_interaction/1.5b_cond_a_seed42/ \
       --condition A --seed 42 --scale 1.5b \
       --judge-model claude-sonnet-4-20250514 \
       --judge-provider anthropic \
       --cache-dir /lfs/ampere8/0/$USER/hf_cache/

3. `submit_eval_interaction.sh` — SLURM for all 28 models:
   - Partition: gpu, 1x A100 80GB, 3 hours
   - Job names: eval_interact_{scale}_{cond}_{seed}

4. `aggregate_interaction.py` — aggregation:
   - Per (condition × scale) mean ± std per task
   - 95% CI
   - Writes aggregated_interaction_results.json

Engineering constraints:
- Typed Python, argparse, pathlib
- Tactic normalization: strip whitespace, collapse multiple spaces, lowercase for comparison
- Judge calls are async with rate limiting (for Task 2)
- Deterministic benchmark construction (seed=42)

SNAP cluster notes:
- GPU for model inference, CPU for judge API calls
- 3 hours per model eval
- Set ANTHROPIC_API_KEY for judge
- Results: /lfs/ampere8/0/$USER/lean4ai_results/11_interaction/

Do NOT add docstrings to every function.
```
