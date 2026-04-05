# 06 — Scaling 3B Training (Phase 2)

## Objective

Run the full study on Qwen2.5-3B-Instruct.

## Model

Qwen2.5-3B-Instruct with **LoRA**

## Runs

| Condition | Seeds |
|-----------|-------|
| A (full trace)        | 3 |
| B (theorem only)      | 3 |
| C (generic math)      | 3 |

**Total: 9 runs**

## Hyperparameters

Same as `05_pilot_1.5b_training` (LoRA rank 64, alpha 128, dropout 0.05, lr 1e-4).

## Deliverables

- [ ] 9 run directories with checkpoints, configs, and training logs
- [ ] Run manifest JSONL
- [ ] Loss curves
