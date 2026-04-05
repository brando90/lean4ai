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

## Prompt 2 — Theorem only to proof sketch

Input: theorem statement only
Output JSON keys: `theorem_in_words`, `likely_strategy`, `informal_proof_sketch`, `uncertain_steps`

## Deliverables

- [ ] Data generation script (`generate.py`) with CLI for prompt selection
- [ ] Condition A raw targets JSONL
- [ ] Condition B raw targets JSONL
- [ ] Generation manifest (counts, token stats, error rates)
