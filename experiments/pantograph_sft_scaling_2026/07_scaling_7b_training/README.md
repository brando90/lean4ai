# 07 — Scaling 7B Training (Phase 2)

## Objective

Run the full study on Qwen2.5-7B-Instruct with QLoRA.

## Model

- **HuggingFace ID:** `Qwen/Qwen2.5-7B-Instruct`
- **Training method:** QLoRA (4-bit NF4 quantization + LoRA adapters)
- **Framework:** HuggingFace transformers + PEFT + TRL + bitsandbytes

## Runs

| Condition | Seeds     | Total runs |
|-----------|-----------|------------|
| A (full trace)   | 42, 43, 44 | 3 |
| B (theorem only) | 42, 43    | 2 |
| C (generic math) | 42, 43    | 2 |

**Total: 7 runs**

## Hyperparameters

| Parameter | Value |
|-----------|-------|
| Max sequence length | 4096 |
| Epochs | 3 |
| Optimizer | AdamW |
| Scheduler | cosine |
| Warmup ratio | 0.03 |
| Weight decay | 0.01 |
| Gradient clipping | 1.0 |
| LoRA rank | 64 |
| LoRA alpha | 128 |
| LoRA dropout | 0.05 |
| Learning rate | 1e-4 (fallback: 5e-5 if loss spikes) |
| Per-device batch size | 2 |
| Gradient accumulation steps | 16 |
| Effective batch size | 32 |
| bf16 (compute dtype) | true |
| Quantization | 4-bit NF4 (bitsandbytes) |
| Double quantization | true |
| LoRA target modules | q_proj, k_proj, v_proj, o_proj, gate_proj, up_proj, down_proj |

## SNAP cluster setup

- **Partition:** `gpu`
- **GPUs:** 1x A100 80GB (QLoRA fits 7B in ~20GB VRAM)
- **Memory:** 80GB RAM
- **Time limit:** 12 hours per run (84 hours total)
- **Storage:** `/lfs/ampere8/0/$USER/lean4ai_runs/07_scaling_7b/`
- **Logging:** wandb project `lean4ai-pantograph-sft`, group `scaling-7b`

## LR fallback protocol

If loss spikes or diverges (loss > 2x initial loss after warmup) during the first seed of any condition:
1. Kill the run
2. Re-run with `--lr 5e-5`
3. Document the fallback in run_config.json

## Deliverables

- [ ] SLURM batch script (`submit_7b.sh`) for all 7 runs
- [ ] 7 run directories with checkpoints, configs, and training logs
- [ ] Run manifest JSONL
- [ ] Loss curves
- [ ] Note on any lr fallback decisions

---

## Claude Code execution prompt

```
Create SLURM submission scripts for 7B QLoRA training runs, extending train.py from 05 to support QLoRA.

Location: /home/user/lean4ai/experiments/pantograph_sft_scaling_2026/07_scaling_7b_training/

Context:
- Reuse and extend train.py from 05_pilot_1.5b_training/ to support QLoRA via bitsandbytes.
- Model: Qwen/Qwen2.5-7B-Instruct with 4-bit NF4 quantization.
- 3 Condition A seeds + 2 Condition B seeds + 2 Condition C seeds = 7 runs total.

What to build:
1. Update train.py in 05_pilot_1.5b_training/ to support QLoRA:
   - Add --quantization-bits flag (default: none, options: 4, 8)
   - When --quantization-bits 4:
     * Load model with BitsAndBytesConfig(
         load_in_4bit=True,
         bnb_4bit_quant_type="nf4",
         bnb_4bit_compute_dtype=torch.bfloat16,
         bnb_4bit_use_double_quant=True,
       )
     * Prepare model with prepare_model_for_kbit_training() from PEFT
   - Everything else stays the same (LoRA config, trainer, etc.)

2. `submit_7b.sh` — SLURM batch script that submits all 7 runs:
   - Partition: gpu
   - GPUs: 1x A100 80GB (--gres=gpu:a100:1)
   - Memory: 80GB RAM
   - CPUs: 4
   - Time: 12 hours per run
   - Conda env: lean4ai

   Submits 7 jobs:
     Condition A, seeds: 42, 43, 44
     Condition B, seeds: 42, 43
     Condition C, seeds: 42, 43

   Each job runs:
     python /home/user/lean4ai/experiments/pantograph_sft_scaling_2026/05_pilot_1.5b_training/train.py \
       --model-name Qwen/Qwen2.5-7B-Instruct \
       --train-file <appropriate data file> \
       --eval-file <appropriate dev file> \
       --output-dir /lfs/ampere8/0/$USER/lean4ai_runs/07_scaling_7b/cond_{cond}_seed{seed}/ \
       --condition {cond} \
       --seed {seed} \
       --training-method lora \
       --quantization-bits 4 \
       --lora-rank 64 --lora-alpha 128 --lora-dropout 0.05 \
       --epochs 3 --batch-size 2 --grad-accum 16 --lr 1e-4 \
       --max-seq-length 4096 --bf16 \
       --wandb-project lean4ai-pantograph-sft --wandb-group scaling-7b \
       --cache-dir /lfs/ampere8/0/$USER/hf_cache/

   Job names: scaling_7b_{cond}_{seed}
   Logs: /lfs/ampere8/0/$USER/lean4ai_runs/07_scaling_7b/logs/

   SLURM header:
     #SBATCH --job-name=scaling_7b_{cond}_{seed}
     #SBATCH --partition=gpu
     #SBATCH --gres=gpu:a100:1
     #SBATCH --mem=80G
     #SBATCH --cpus-per-task=4
     #SBATCH --time=12:00:00
     #SBATCH --output=/lfs/ampere8/0/$USER/lean4ai_runs/07_scaling_7b/logs/%x_%j.out

3. `submit_7b_lr_fallback.sh` — identical to submit_7b.sh but with --lr 5e-5
   (ready to use if 1e-4 causes instability)

4. `manifest.py` — scans run directories, produces run_manifest.jsonl

Dependencies to add to the conda env: bitsandbytes>=0.43.0
```
