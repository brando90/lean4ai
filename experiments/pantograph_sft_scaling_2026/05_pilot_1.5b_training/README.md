# 05 — Pilot 1.5B Training (Phase 1)

## Objective

Run the pilot study on Qwen2.5-1.5B-Instruct across all three conditions to validate the pipeline before scaling up.

## Model

Qwen2.5-1.5B-Instruct with **LoRA**

## Runs

| Condition | Seeds |
|-----------|-------|
| A (full trace)        | 3 |
| B (theorem only)      | 3 |
| C (generic math)      | 3 |

**Total: 9 runs**

## Hyperparameters

- Max sequence length: 4096
- Epochs: 3
- Optimizer: AdamW
- Scheduler: cosine
- Warmup ratio: 0.03
- Weight decay: 0.01
- Gradient clipping: 1.0
- LoRA rank: 64, alpha: 128, dropout: 0.05
- Learning rate: 1e-4

## Deliverables

- [ ] Training script (`train.py`) with CLI for condition/seed/model selection
- [ ] 9 run directories with checkpoints, configs, and training logs
- [ ] Run manifest JSONL linking each run to its condition, seed, and config
- [ ] Loss curves for all 9 runs

## Stop/go gate (Phase 1 → Phase 2)

Proceed to 3B/7B only if Condition A beats both controls on ≥2 of 4 eval buckets.
