# 01 — Data Generation

## Objective

Generate training targets for Conditions A and B using LLM-based prompting over extracted Pantograph instances.

## Scope

- **Condition A (full trace → faithful informal proof):** Use Prompt 1 on full Pantograph instances
- **Condition B (theorem only → proof sketch):** Use Prompt 2 on theorem statements only
- All outputs in structured JSON format

## Prompt 1 — Full trace to faithful informal proof

Input: theorem statement + proof states + tactics + metadata

Output JSON keys: `theorem_in_words`, `proof_strategy`, `faithful_informal_proof`, `used_key_ideas`, `possible_uncertainties`

Full prompt text:
```
You are given a Lean 4 theorem statement and a proof interaction trace extracted through Pantograph.
Write a mathematically faithful informal proof.

Requirements:
- Preserve the logical structure of the trace.
- Do not invent assumptions, lemmas, or proof steps.
- Translate Lean tactics into ordinary mathematical language.
- Compress repetitive low-level tactical steps.
- If part of the proof is unclear from the trace, state that explicitly.
- Be concise but complete enough for a mathematically mature reader.

Return valid JSON with exactly these keys:
{
  "theorem_in_words": str,
  "proof_strategy": str,
  "faithful_informal_proof": str,
  "used_key_ideas": [str],
  "possible_uncertainties": [str]
}
```

## Prompt 2 — Theorem only to proof sketch

Input: theorem statement only

Output JSON keys: `theorem_in_words`, `likely_strategy`, `informal_proof_sketch`, `uncertain_steps`

Full prompt text:
```
You are given only a Lean 4 theorem statement.
Write a conservative informal proof sketch.

Requirements:
- Distinguish clearly between what is supported by the theorem statement and what is only a likely strategy.
- Do not claim detailed proof steps unless they are directly implied.
- Prefer underclaiming to hallucinating.

Return valid JSON with exactly these keys:
{
  "theorem_in_words": str,
  "likely_strategy": str,
  "informal_proof_sketch": str,
  "uncertain_steps": [str]
}
```

## SNAP cluster setup

- **Partition:** `gpu` (if using local vLLM for generation) or CPU-only (if using API)
- **Generation model:** Claude Sonnet 4 via Anthropic API, or Qwen2.5-72B-Instruct via vLLM on SNAP
- **API key:** set `ANTHROPIC_API_KEY` env var, or run vLLM server on SNAP A100 node
- **Estimated time:** 4–12 hours for ~5k instances depending on model and parallelism
- **Storage:** write to `/lfs/ampere8/0/$USER/lean4ai_data/01_generation/`

## Deliverables

- [ ] Data generation script (`generate.py`) with CLI for prompt selection
- [ ] Condition A raw targets JSONL
- [ ] Condition B raw targets JSONL
- [ ] Generation manifest (counts, token stats, error rates)

---

## Claude Code execution prompt

```
Implement an LLM-based data generation pipeline for creating formal-to-informal proof training pairs.

Location: /home/user/lean4ai/experiments/pantograph_sft_scaling_2026/01_data_generation/

Context:
- Input: raw_instances.jsonl from 00_pantograph_extraction (each line has theorem_id, theorem_statement, proof_states, tactics, etc.)
- We need to generate two types of training targets using an LLM:
  * Condition A: full Pantograph trace → faithful informal proof (JSON)
  * Condition B: theorem statement only → informal proof sketch (JSON)
- This is for a supervised fine-tuning study on Qwen2.5 models.

What to build:
1. `generate.py` — typed Python CLI script that:
   - Reads raw_instances.jsonl
   - For each instance, constructs the appropriate prompt (Prompt 1 for Condition A, Prompt 2 for Condition B)
   - Calls an LLM API to generate the target JSON
   - Validates that the response is valid JSON with the required keys
   - Retries up to 3 times on invalid JSON or API errors
   - Writes successful outputs to JSONL (one per line)
   - Logs failures separately
   - Supports parallel generation with configurable concurrency

   CLI interface:
     python generate.py \
       --input-file /lfs/ampere8/0/$USER/lean4ai_data/00_extraction/raw_instances.jsonl \
       --output-dir /lfs/ampere8/0/$USER/lean4ai_data/01_generation/ \
       --condition A \
       --model claude-sonnet-4-20250514 \
       --provider anthropic \
       --max-concurrent 10 \
       --temperature 0.3 \
       --max-tokens 2048 \
       --max-instances 0  # 0 = all

   Supported providers: "anthropic" (using anthropic SDK), "openai_compat" (for vLLM/OpenAI-compatible endpoints)

   For --provider openai_compat:
     --api-base http://localhost:8000/v1
     --model Qwen/Qwen2.5-72B-Instruct

   Prompt 1 (Condition A) — the full prompt text is in the README above.
   Prompt 2 (Condition B) — the full prompt text is in the README above.

   For Condition A, the user message should include:
     Theorem: {theorem_statement}
     Proof states: {proof_states as formatted list}
     Tactics: {tactics as formatted list}

   For Condition B, the user message should include:
     Theorem: {theorem_statement}

   Output JSONL schema per line:
   {
     "theorem_id": str,
     "condition": "A" or "B",
     "input_theorem": str,
     "generated_target": { ... the LLM's JSON output ... },
     "model": str,
     "temperature": float,
     "generation_timestamp": str (ISO 8601)
   }

2. `manifest.py` — reads output JSONL and produces:
   - Total generated count (success / fail)
   - Per-condition counts
   - Mean/median token lengths of generated targets
   - Error rate and error type distribution
   - Writes generation_manifest.json

Engineering constraints:
- Typed Python with type hints everywhere
- Use asyncio + aiohttp or anthropic async client for concurrency
- No hardcoded paths, all via CLI args
- Use pathlib for file ops
- Rate-limit aware: respect API rate limits with exponential backoff
- Deterministic: process instances in sorted theorem_id order
- Resume support: skip theorem_ids already present in output file

SNAP cluster notes:
- If using Anthropic API: CPU-only node, set ANTHROPIC_API_KEY
- If using vLLM locally: request 1x A100 80GB, run vLLM serve Qwen/Qwen2.5-72B-Instruct
- Output: /lfs/ampere8/0/$USER/lean4ai_data/01_generation/
- Time estimate: 4–12 hours for ~5k instances

Do NOT add docstrings to every function. Keep it functional and production-grade.
```
