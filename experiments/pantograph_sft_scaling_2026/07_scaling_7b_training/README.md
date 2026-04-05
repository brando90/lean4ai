# 07 — Scaling 7B Training (Phase 2)

## Objective

Run the full study on Qwen2.5-7B-Instruct with QLoRA.

## Model

Qwen2.5-7B-Instruct with **QLoRA** (4-bit quantization)

## Runs

| Condition | Seeds |
|-----------|-------|
| A (full trace)        | 3 |
| B (theorem only)      | 2 |
| C (generic math)      | 2 |

**Total: 7 runs**

## Hyperparameters

- Same base config as other scales
- QLoRA: 4-bit quantization, rank 64, alpha 128, dropout 0.05
- Learning rate: 1e-4, with fallback to 5e-5 if instability observed during pilot

## Deliverables

- [ ] 7 run directories with checkpoints, configs, and training logs
- [ ] Run manifest JSONL
- [ ] Loss curves
- [ ] Note on any lr fallback decisions
