# 05 — Pilot 1.5B Training (Phase 1)

## Objective

Run the pilot study on Qwen2.5-1.5B-Instruct across all three conditions to validate the pipeline before scaling up.

## Model

- **HuggingFace ID:** `Qwen/Qwen2.5-1.5B-Instruct`
- **Training method:** LoRA (full precision base, LoRA adapters)
- **Framework:** HuggingFace transformers + PEFT + TRL (SFTTrainer)

## Runs

| Condition | Seeds     | Total runs |
|-----------|-----------|------------|
| A (full trace)   | 42, 43, 44 | 3 |
| B (theorem only) | 42, 43, 44 | 3 |
| C (generic math) | 42, 43, 44 | 3 |

**Total: 9 runs**

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
| Learning rate | 1e-4 |
| Per-device batch size | 4 |
| Gradient accumulation steps | 8 |
| Effective batch size | 32 |
| bf16 | true |
| LoRA target modules | q_proj, k_proj, v_proj, o_proj, gate_proj, up_proj, down_proj |
| Save strategy | epoch |
| Eval strategy | epoch |
| Logging steps | 10 |
| Dataloader num workers | 4 |

## SNAP cluster setup

- **Partition:** `gpu`
- **GPUs:** 1x A100 80GB (sufficient for 1.5B LoRA)
- **Memory:** 64GB RAM
- **Time limit:** 6 hours per run (54 hours total for 9 runs)
- **Storage:** `/lfs/ampere8/0/$USER/lean4ai_runs/05_pilot_1.5b/`
- **Model cache:** `/lfs/ampere8/0/$USER/hf_cache/`
- **Logging:** wandb project `lean4ai-pantograph-sft`, group `pilot-1.5b`

## Deliverables

- [ ] Training script (`train.py`) with CLI for condition/seed/model selection
- [ ] SLURM batch script (`submit_pilot.sh`) for all 9 runs
- [ ] 9 run directories with checkpoints, configs, and training logs
- [ ] Run manifest JSONL linking each run to its condition, seed, and config
- [ ] Loss curves for all 9 runs

## Stop/go gate (Phase 1 → Phase 2)

Proceed to 3B/7B only if Condition A beats both controls on ≥2 of 4 eval buckets.

---

## Claude Code execution prompt

```
Implement a LoRA fine-tuning pipeline for the Pantograph SFT scaling study and a SLURM submission script for the 1.5B pilot.

Location: /home/user/lean4ai/experiments/pantograph_sft_scaling_2026/05_pilot_1.5b_training/

Context:
- We are fine-tuning Qwen/Qwen2.5-1.5B-Instruct with LoRA on 3 conditions (A, B, C) × 3 seeds each = 9 runs.
- Input data: train.jsonl / dev.jsonl from 03_dataset_build_and_split (conditions A, B) and 04_generic_math_control_data (condition C).
  Each line has: {"input": str, "target": str, "condition": str, ...}
- The training format is: system prompt + user input → assistant target (JSON string)
- This is Phase 1 (pilot). We only proceed to 3B/7B if results look good.

What to build:
1. `train.py` — typed Python CLI that:
   - Loads base model Qwen/Qwen2.5-1.5B-Instruct from HuggingFace
   - Applies LoRA via PEFT with config:
     * r=64, lora_alpha=128, lora_dropout=0.05
     * target_modules=["q_proj", "k_proj", "v_proj", "o_proj", "gate_proj", "up_proj", "down_proj"]
     * task_type=CAUSAL_LM
   - Loads training data from JSONL, formats as chat messages:
     * system: "You are a mathematical proof assistant. Given a mathematical input, produce a structured JSON response."
     * user: the "input" field from JSONL
     * assistant: the "target" field from JSONL
   - Uses TRL SFTTrainer or HuggingFace Trainer with:
     * max_seq_length=4096
     * num_train_epochs=3
     * per_device_train_batch_size=4
     * gradient_accumulation_steps=8
     * learning_rate=1e-4
     * lr_scheduler_type=cosine
     * warmup_ratio=0.03
     * weight_decay=0.01
     * max_grad_norm=1.0
     * bf16=True
     * save_strategy="epoch"
     * evaluation_strategy="epoch"
     * logging_steps=10
     * dataloader_num_workers=4
     * seed=<from CLI>
     * report_to="wandb"
   - Saves final adapter + merged model to output directory
   - Writes run_config.json with all hyperparameters and paths used

   CLI interface:
     python train.py \
       --model-name Qwen/Qwen2.5-1.5B-Instruct \
       --train-file /lfs/ampere8/0/$USER/lean4ai_data/03_splits/condition_a_train.jsonl \
       --eval-file /lfs/ampere8/0/$USER/lean4ai_data/03_splits/condition_a_dev.jsonl \
       --output-dir /lfs/ampere8/0/$USER/lean4ai_runs/05_pilot_1.5b/cond_a_seed42/ \
       --condition A \
       --seed 42 \
       --training-method lora \
       --lora-rank 64 \
       --lora-alpha 128 \
       --lora-dropout 0.05 \
       --epochs 3 \
       --batch-size 4 \
       --grad-accum 8 \
       --lr 1e-4 \
       --max-seq-length 4096 \
       --bf16 \
       --wandb-project lean4ai-pantograph-sft \
       --wandb-group pilot-1.5b \
       --cache-dir /lfs/ampere8/0/$USER/hf_cache/

2. `submit_pilot.sh` — SLURM batch script that submits all 9 runs:
   - Uses SNAP cluster partition "gpu"
   - Requests 1x A100 80GB, 64GB RAM, 4 CPUs, 6 hour time limit per job
   - Sets up conda environment: conda activate lean4ai
   - Sets HF_HOME=/lfs/ampere8/0/$USER/hf_cache/
   - Sets WANDB_PROJECT=lean4ai-pantograph-sft
   - Submits 9 SLURM jobs (one per condition × seed combination):
     * Conditions: A, B, C
     * Seeds: 42, 43, 44
   - Each job name: pilot_1.5b_{condition}_{seed}
   - Each output dir: /lfs/ampere8/0/$USER/lean4ai_runs/05_pilot_1.5b/cond_{condition}_seed{seed}/
   - Log files: /lfs/ampere8/0/$USER/lean4ai_runs/05_pilot_1.5b/logs/

   SLURM header template:
     #!/bin/bash
     #SBATCH --job-name=pilot_1.5b_{cond}_{seed}
     #SBATCH --partition=gpu
     #SBATCH --gres=gpu:a100:1
     #SBATCH --mem=64G
     #SBATCH --cpus-per-task=4
     #SBATCH --time=06:00:00
     #SBATCH --output=/lfs/ampere8/0/$USER/lean4ai_runs/05_pilot_1.5b/logs/%x_%j.out

3. `manifest.py` — after all runs complete, scans run directories and produces:
   - run_manifest.jsonl: one line per run with condition, seed, final loss, checkpoint path, config
   - Prints summary table

Engineering constraints:
- Typed Python, argparse CLI, pathlib throughout
- No hardcoded paths — everything via CLI or environment variables
- Deterministic: set all seeds (torch, numpy, random, transformers)
- Save run_config.json in each output directory for reproducibility
- Use PEFT library for LoRA, TRL for SFTTrainer

SNAP cluster specifics:
- Partition: gpu
- Available GPUs: A100 80GB (gres=gpu:a100:1)
- Conda env: lean4ai (has torch, transformers, peft, trl, wandb, datasets)
- Model cache: /lfs/ampere8/0/$USER/hf_cache/
- Run storage: /lfs/ampere8/0/$USER/lean4ai_runs/05_pilot_1.5b/
- wandb logging: project=lean4ai-pantograph-sft, group=pilot-1.5b

Do NOT add docstrings to every function. Keep it production-grade.
```
