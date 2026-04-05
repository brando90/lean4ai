# Pantograph-based SFT Scaling Study (2026)

**Target venue:** TMLR or NeurIPS 2026

**Central question:** Does supervised fine-tuning on Pantograph-derived Lean 4 proof interaction data improve mathematical reasoning, proof explanation, and theorem-prover interaction competence, and how does that effect scale from ~1.5B to ~7B parameters?

## Model family

| Size   | Model                      | Training method |
|--------|----------------------------|-----------------|
| 1.5B   | Qwen2.5-1.5B-Instruct     | LoRA            |
| 3B     | Qwen2.5-3B-Instruct       | LoRA            |
| 7B     | Qwen2.5-7B-Instruct       | QLoRA           |

## Training conditions

| Condition | Input                          | Target                        |
|-----------|--------------------------------|-------------------------------|
| A         | Pantograph full trace          | Faithful informal proof (JSON)|
| B         | Theorem statement only         | Informal proof sketch (JSON)  |
| C         | Generic math problem/theorem   | Math explanation (JSON)       |

## Seed schedule

| Scale | Cond A | Cond B | Cond C |
|-------|--------|--------|--------|
| 1.5B  | 3      | 3      | 3      |
| 3B    | 3      | 3      | 3      |
| 7B    | 3      | 2      | 2      |

## Evaluation buckets

1. Hendrycks MATH (exact answer accuracy)
2. MMLU-Pro (multiple-choice accuracy)
3. Proof explanation quality (human eval, 200 examples, 3 raters)
4. Pantograph interaction competence (tactic prediction, proof-state explanation, short-horizon completion)

## Experiment subfolders

| Folder | Phase | Description |
|--------|-------|-------------|
| `00_pantograph_extraction`         | Data   | Extract theorem/proof instances from Lean 4 via Pantograph |
| `01_data_generation`               | Data   | Generate Condition A & B targets using Prompt 1 & 2 |
| `02_faithfulness_filtering`        | Data   | Judge filter + manual spot-check |
| `03_dataset_build_and_split`       | Data   | Theorem-level 80/10/10 splits, JSONL materialization |
| `04_generic_math_control_data`     | Data   | Build Condition C dataset from external math explanation corpus |
| `05_pilot_1.5b_training`           | Train  | Phase 1 pilot on Qwen2.5-1.5B-Instruct (all 3 conditions, 3 seeds) |
| `06_scaling_3b_training`           | Train  | Phase 2 on Qwen2.5-3B-Instruct |
| `07_scaling_7b_training`           | Train  | Phase 2 on Qwen2.5-7B-Instruct (QLoRA) |
| `08_eval_math`                     | Eval   | Hendrycks MATH benchmark runs |
| `09_eval_mmlu_pro`                 | Eval   | MMLU-Pro benchmark runs |
| `10_eval_proof_explanation_human`  | Eval   | Human-rated proof explanation eval |
| `11_eval_pantograph_interaction`   | Eval   | Pantograph interaction benchmark |
| `12_aggregation_and_plots`         | Paper  | Means, CIs, scaling plots, comparison plots |
| `13_paper_assets`                  | Paper  | Figures, tables, qualitative examples, appendix |

## Stop/go gates

- **Phase 0 → Phase 1:** ≥80% of 100 spot-checked examples are genuinely faithful
- **Phase 1 → Phase 2:** Condition A beats both controls on ≥2 of 4 eval buckets at 1.5B
