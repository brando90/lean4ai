# 02 — Faithfulness Filtering

## Objective

Filter generated targets using an LLM judge prompt, then manually spot-check accepted examples.

## Judge prompt

```
You are auditing whether an informal proof output is faithful to a Lean 4 theorem and, when provided, its Pantograph proof trace.

Score from 1 to 5 on:
- theorem fidelity
- step fidelity
- non-hallucination
- mathematical coherence

Reject the example if any of the following occur:
- unsupported assumptions are introduced
- the theorem is misstated
- the output claims stronger proof details than justified
- the proof omits the central strategy while presenting itself as complete

Return valid JSON with exactly these keys:
{
  "theorem_fidelity": int,
  "step_fidelity": int,
  "non_hallucination": int,
  "mathematical_coherence": int,
  "accept": bool,
  "reasons": [str]
}
```

## Rejection rules

Reject if any of:
- `accept == false`
- `theorem_fidelity < 4`
- `non_hallucination < 4`
- `mathematical_coherence < 4`

## SNAP cluster setup

- **Partition:** CPU-only (API-based judging) or `gpu` (local vLLM judge)
- **Judge model:** Claude Sonnet 4 via Anthropic API (preferred for judge quality)
- **Estimated time:** 2–6 hours for ~5k examples at 10 concurrent requests
- **Storage:** `/lfs/ampere8/0/$USER/lean4ai_data/02_filtering/`

## Deliverables

- [ ] Judge pipeline script (`judge.py`)
- [ ] Filtered Condition A JSONL
- [ ] Filtered Condition B JSONL
- [ ] Judge scores JSONL (all examples, accepted and rejected)
- [ ] Manual spot-check spreadsheet/log (100 examples)
- [ ] Acceptance rate report

## Stop/go gate (Phase 0 → Phase 1)

Proceed only if ≥80% of 100 inspected accepted examples are genuinely faithful.

---

## Claude Code execution prompt

```
Implement a faithfulness judge pipeline that filters LLM-generated proof targets.

Location: /home/user/lean4ai/experiments/pantograph_sft_scaling_2026/02_faithfulness_filtering/

Context:
- Input: Condition A and Condition B JSONL files from 01_data_generation
  (each line has theorem_id, condition, input_theorem, generated_target, etc.)
- We use an LLM judge to score each generated target on 4 dimensions (1-5 scale)
- We reject examples that fail quality thresholds
- This gate must pass before any training begins

What to build:
1. `judge.py` — typed Python CLI script that:
   - Reads generated targets JSONL (from 01_data_generation)
   - For each example, constructs a judge prompt containing:
     * The original theorem statement
     * The Pantograph proof trace (for Condition A) or "not available" (for Condition B)
     * The generated informal proof / sketch
   - Calls an LLM judge (Anthropic API or OpenAI-compatible endpoint)
   - Parses the judge's JSON response
   - Validates scores are integers 1-5 and accept is boolean
   - Retries up to 3 times on parse failure
   - Writes ALL judge results (accepted + rejected) to judge_scores.jsonl
   - Writes accepted-only examples to filtered_condition_a.jsonl / filtered_condition_b.jsonl
   - Applies rejection rules:
     * accept == false → reject
     * theorem_fidelity < 4 → reject
     * non_hallucination < 4 → reject
     * mathematical_coherence < 4 → reject

   CLI interface:
     python judge.py \
       --input-file /lfs/ampere8/0/$USER/lean4ai_data/01_generation/condition_a_targets.jsonl \
       --raw-instances /lfs/ampere8/0/$USER/lean4ai_data/00_extraction/raw_instances.jsonl \
       --output-dir /lfs/ampere8/0/$USER/lean4ai_data/02_filtering/ \
       --condition A \
       --model claude-sonnet-4-20250514 \
       --provider anthropic \
       --max-concurrent 10 \
       --temperature 0.0 \
       --max-tokens 512

   The judge prompt (system message) is specified in the README above.
   The user message should contain:
     Theorem statement: {theorem_statement}
     Proof trace: {proof_states and tactics, or "Not provided (theorem-only condition)"}
     Generated output: {the generated_target JSON}

   Output judge_scores.jsonl schema per line:
   {
     "theorem_id": str,
     "condition": "A" or "B",
     "theorem_fidelity": int,
     "step_fidelity": int,
     "non_hallucination": int,
     "mathematical_coherence": int,
     "accept": bool,
     "reasons": [str],
     "final_verdict": "accepted" or "rejected",
     "rejection_reason": str or null
   }

2. `report.py` — reads judge_scores.jsonl and produces:
   - Total judged count
   - Acceptance rate overall and per-condition
   - Mean scores per dimension
   - Distribution of rejection reasons
   - Writes filtering_report.json

3. `spot_check.py` — samples 100 accepted examples (50 per condition)
   and writes spot_check_100.jsonl with full context for manual review.

Engineering constraints:
- Typed Python, all paths via CLI, pathlib throughout
- Async concurrency with rate limiting
- Resume support: skip already-judged theorem_ids
- Deterministic: process in sorted theorem_id order
- Judge temperature = 0.0 for maximum consistency

SNAP cluster notes:
- CPU-only if using Anthropic API
- Set ANTHROPIC_API_KEY env var
- Output: /lfs/ampere8/0/$USER/lean4ai_data/02_filtering/
- Time: 2–6 hours for ~5k examples

Do NOT add docstrings to every function.
```
