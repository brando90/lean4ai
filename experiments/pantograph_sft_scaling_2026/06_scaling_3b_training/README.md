# 06 — Scaling 3B Training (Phase 2)

## Objective

Run the full study on Qwen2.5-3B-Instruct.

## Model

- **HuggingFace ID:** `Qwen/Qwen2.5-3B-Instruct`
- **Training method:** LoRA (same config as 1.5B pilot)
- **Framework:** HuggingFace transformers + PEFT + TRL (SFTTrainer)

## Runs

| Condition | Seeds     | Total runs |
|-----------|-----------|------------|
| A (full trace)   | 42, 43, 44 | 3 |
| B (theorem only) | 42, 43, 44 | 3 |
| C (generic math) | 42, 43, 44 | 3 |

**Total: 9 runs**

## Hyperparameters

Same as `05_pilot_1.5b_training`:
- LoRA rank=64, alpha=128, dropout=0.05, lr=1e-4
- 3 epochs, max_seq_length=4096, batch_size=4, grad_accum=8, bf16

Only difference from 1.5B: may need to reduce per-device batch size to 2 and increase grad_accum to 16 if OOM. Try batch_size=4 first.

## SNAP cluster setup

- **Partition:** `gpu`
- **GPUs:** 1x A100 80GB (sufficient for 3B LoRA)
- **Memory:** 64GB RAM
- **Time limit:** 8 hours per run (72 hours total)
- **Storage:** `/lfs/ampere8/0/$USER/lean4ai_runs/06_scaling_3b/`
- **Logging:** wandb project `lean4ai-pantograph-sft`, group `scaling-3b`

## Deliverables

- [ ] SLURM batch script (`submit_3b.sh`) for all 9 runs
- [ ] 9 run directories with checkpoints, configs, and training logs
- [ ] Run manifest JSONL
- [ ] Loss curves

---

## Claude Code execution prompt

```
Create SLURM submission scripts for 3B model training runs, reusing the train.py from 05_pilot_1.5b_training.

Location: /home/user/lean4ai/experiments/pantograph_sft_scaling_2026/06_scaling_3b_training/

Context:
- Reuse train.py from 05_pilot_1.5b_training/ — it already supports --model-name and all needed params.
- We just need SLURM scripts and a manifest script for the 3B scale.
- Same 3 conditions × 3 seeds = 9 runs.
- Model: Qwen/Qwen2.5-3B-Instruct with LoRA (same hyperparams as 1.5B).

What to build:
1. `submit_3b.sh` — SLURM batch script that submits all 9 runs:
   - Partition: gpu
   - GPUs: 1x A100 80GB (--gres=gpu:a100:1)
   - Memory: 64GB RAM
   - CPUs: 4
   - Time: 8 hours per run
   - Conda env: lean4ai
   - HF_HOME=/lfs/ampere8/0/$USER/hf_cache/

   Submits 9 jobs with:
     python /home/user/lean4ai/experiments/pantograph_sft_scaling_2026/05_pilot_1.5b_training/train.py \
       --model-name Qwen/Qwen2.5-3B-Instruct \
       --train-file /lfs/ampere8/0/$USER/lean4ai_data/03_splits/condition_{cond}_train.jsonl \
       --eval-file /lfs/ampere8/0/$USER/lean4ai_data/03_splits/condition_{cond}_dev.jsonl \
       --output-dir /lfs/ampere8/0/$USER/lean4ai_runs/06_scaling_3b/cond_{cond}_seed{seed}/ \
       --condition {cond} \
       --seed {seed} \
       --training-method lora \
       --lora-rank 64 --lora-alpha 128 --lora-dropout 0.05 \
       --epochs 3 --batch-size 4 --grad-accum 8 --lr 1e-4 \
       --max-seq-length 4096 --bf16 \
       --wandb-project lean4ai-pantograph-sft --wandb-group scaling-3b \
       --cache-dir /lfs/ampere8/0/$USER/hf_cache/

   Conditions: A, B, C (use appropriate data files for each; C uses 04_control_data paths)
   Seeds: 42, 43, 44
   Job names: scaling_3b_{cond}_{seed}
   Logs: /lfs/ampere8/0/$USER/lean4ai_runs/06_scaling_3b/logs/

   SLURM header:
     #SBATCH --job-name=scaling_3b_{cond}_{seed}
     #SBATCH --partition=gpu
     #SBATCH --gres=gpu:a100:1
     #SBATCH --mem=64G
     #SBATCH --cpus-per-task=4
     #SBATCH --time=08:00:00
     #SBATCH --output=/lfs/ampere8/0/$USER/lean4ai_runs/06_scaling_3b/logs/%x_%j.out

   If 3B OOMs with batch_size=4, include a comment showing the fallback:
     --batch-size 2 --grad-accum 16  # fallback if OOM

2. `manifest.py` — scans run directories, produces run_manifest.jsonl (same as 05)

Keep it minimal — the training logic is all in 05's train.py.
```
