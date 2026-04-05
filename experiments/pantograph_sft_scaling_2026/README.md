# Pantograph-based SFT Scaling Study (2026)

**Target venue:** TMLR or NeurIPS 2026

**Central question:** Does supervised fine-tuning on Pantograph-derived Lean 4 proof interaction data improve mathematical reasoning, proof explanation, and theorem-prover interaction competence, and how does that effect scale from ~1.5B to ~7B parameters?

## Model family

| Size   | Model                      | HuggingFace ID                  | Training method |
|--------|----------------------------|---------------------------------|-----------------|
| 1.5B   | Qwen2.5-1.5B-Instruct     | `Qwen/Qwen2.5-1.5B-Instruct`   | LoRA            |
| 3B     | Qwen2.5-3B-Instruct       | `Qwen/Qwen2.5-3B-Instruct`     | LoRA            |
| 7B     | Qwen2.5-7B-Instruct       | `Qwen/Qwen2.5-7B-Instruct`     | QLoRA (4-bit)   |

## Training conditions

| Condition | Input                          | Target                        |
|-----------|--------------------------------|-------------------------------|
| A         | Pantograph full trace          | Faithful informal proof (JSON)|
| B         | Theorem statement only         | Informal proof sketch (JSON)  |
| C         | Generic math problem/theorem   | Math explanation (JSON)       |

## Seed schedule

| Scale | Cond A | Cond B | Cond C | Total |
|-------|--------|--------|--------|-------|
| 1.5B  | 3      | 3      | 3      | 9     |
| 3B    | 3      | 3      | 3      | 9     |
| 7B    | 3      | 2      | 2      | 7     |
| **Total** | | | | **25** |

Seeds: 42, 43, 44 (42 and 43 only for 7B Cond B/C).

## Evaluation buckets

1. Hendrycks MATH (exact answer accuracy)
2. MMLU-Pro (multiple-choice accuracy)
3. Proof explanation quality (human eval, 200 examples, 3 raters)
4. Pantograph interaction competence (tactic prediction, proof-state explanation, short-horizon completion)

## SNAP cluster compute budget

| Phase | GPU-hours (A100 80GB) | Notes |
|-------|-----------------------|-------|
| 00–04 Data pipeline | ~24h + API costs | Extraction, generation, filtering |
| 05 Pilot 1.5B | ~54h | 9 runs × 6h |
| 06 Scaling 3B | ~72h | 9 runs × 8h |
| 07 Scaling 7B | ~84h | 7 runs × 12h |
| 08–11 Evaluation | ~84h | 28 models × 3h avg |
| **Total** | **~318h** | + API costs for data gen/judge |

## SNAP cluster conventions

- **Partition:** `gpu` (or `jsteinhardt` if available)
- **GPU type:** A100 80GB (`--gres=gpu:a100:1`)
- **Conda env:** `lean4ai`
- **Model cache:** `/lfs/ampere8/0/$USER/hf_cache/`
- **Data storage:** `/lfs/ampere8/0/$USER/lean4ai_data/`
- **Run storage:** `/lfs/ampere8/0/$USER/lean4ai_runs/`
- **Results storage:** `/lfs/ampere8/0/$USER/lean4ai_results/`
- **wandb project:** `lean4ai-pantograph-sft`
- **Environment vars:** `ANTHROPIC_API_KEY`, `HF_HOME`, `WANDB_PROJECT`

## Experiment subfolders

Each subfolder has a README with full spec + a **Claude Code execution prompt** ready for dispatch.

| Folder | Phase | Description | Compute |
|--------|-------|-------------|---------|
| `00_pantograph_extraction`         | Data   | Extract theorem/proof instances from Lean 4 via Pantograph | CPU, 6h |
| `01_data_generation`               | Data   | Generate Condition A & B targets using Prompt 1 & 2 | API or 1×A100 |
| `02_faithfulness_filtering`        | Data   | Judge filter + manual spot-check | API |
| `03_dataset_build_and_split`       | Data   | Theorem-level 80/10/10 splits, JSONL materialization | CPU, <30min |
| `04_generic_math_control_data`     | Data   | Build Condition C dataset from external math corpus | CPU or API |
| `05_pilot_1.5b_training`           | Train  | Phase 1 pilot: Qwen2.5-1.5B, 9 runs | 9×6h A100 |
| `06_scaling_3b_training`           | Train  | Phase 2: Qwen2.5-3B, 9 runs | 9×8h A100 |
| `07_scaling_7b_training`           | Train  | Phase 2: Qwen2.5-7B QLoRA, 7 runs | 7×12h A100 |
| `08_eval_math`                     | Eval   | Hendrycks MATH benchmark, 28 models | 28×3h A100 |
| `09_eval_mmlu_pro`                 | Eval   | MMLU-Pro benchmark, 28 models | 28×4h A100 |
| `10_eval_proof_explanation_human`  | Eval   | Human-rated proof explanation eval | 28×2h A100 + raters |
| `11_eval_pantograph_interaction`   | Eval   | Pantograph interaction benchmark | 28×3h A100 + API |
| `12_aggregation_and_plots`         | Paper  | Stats, CIs, scaling plots, comparison plots | CPU, <10min |
| `13_paper_assets`                  | Paper  | Figures, tables, qualitative examples, appendix | CPU |

## Stop/go gates

- **Phase 0 → Phase 1:** ≥80% of 100 spot-checked examples are genuinely faithful
- **Phase 1 → Phase 2:** Condition A beats both controls on ≥2 of 4 eval buckets at 1.5B

## Success criteria

The paper claims success only if ALL three hold:
1. Condition A beats B and C on MATH at both 3B and 7B
2. Condition A beats both controls on ≥1 of {proof explanation, interaction} at all 3 scales
3. 7B Condition A beats its own base model on ≥3 of 4 buckets
