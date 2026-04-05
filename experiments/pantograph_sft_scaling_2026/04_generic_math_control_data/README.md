# 04 — Generic Math Control Data (Condition C)

## Objective

Build the Condition C dataset from an external generic math explanation corpus — **not** from Pantograph.

## Why separate

Condition C is the control that tests whether gains come from any math explanation fine-tuning vs. specifically from theorem-prover interaction data. The data source must be independent of Pantograph.

## Target schema

```json
{
  "problem_or_statement_in_words": "str",
  "solution_strategy": "str",
  "explanation": "str",
  "key_steps": ["str"]
}
```

## Candidate sources (in priority order)

1. **Hendrycks MATH training split** — competition problems with step-by-step solutions
   - HuggingFace: `hendrycks/competition_math`
2. **GSM8K** — grade school math with chain-of-thought solutions
   - HuggingFace: `openai/gsm8k`
3. **AMPS (Khan Academy + Mathematica)** — if more data needed

## Size matching

Match approximate token count and example count to Conditions A/B training sets so training compute is comparable across conditions.

## SNAP cluster setup

- **Partition:** CPU-only or `gpu` (if using local LLM for reformatting)
- **Estimated time:** 1–3 hours
- **Storage:** `/lfs/ampere8/0/$USER/lean4ai_data/04_control_data/`

## Deliverables

- [ ] Source selection and rationale document
- [ ] Generation/curation script (`build_control_data.py`)
- [ ] `train.jsonl`, `dev.jsonl`, `test.jsonl` for View C
- [ ] Token count and example count comparison table vs. Views A and B

---

## Claude Code execution prompt

```
Build a Condition C (generic math explanation) control dataset from public math corpora.

Location: /home/user/lean4ai/experiments/pantograph_sft_scaling_2026/04_generic_math_control_data/

Context:
- This is the control condition for a fine-tuning study comparing:
  A) Pantograph full trace → informal proof
  B) Theorem only → proof sketch
  C) Generic math problem → explanation (THIS dataset)
- The data must NOT come from Pantograph or Lean. It must be an independent math explanation corpus.
- The dataset size (token count, example count) must roughly match Conditions A and B.

What to build:
1. `build_control_data.py` — typed Python CLI that:
   - Downloads Hendrycks MATH training split from HuggingFace (hendrycks/competition_math)
   - Downloads GSM8K from HuggingFace (openai/gsm8k)
   - For each problem/solution pair, reformats into the target JSON schema:
     {
       "problem_or_statement_in_words": str,  # the problem text
       "solution_strategy": str,              # high-level approach in 1-2 sentences
       "explanation": str,                    # the full step-by-step solution
       "key_steps": [str]                     # 3-5 key reasoning steps extracted
     }
   - For Hendrycks MATH: use the problem as input, the solution as explanation base
   - For GSM8K: use the question as input, the chain-of-thought answer as explanation base
   - To extract solution_strategy and key_steps from raw solutions, use an LLM
     (Claude Sonnet 4 via Anthropic API or local model) with this prompt:

     "Given a math problem and its solution, extract:
     1. A 1-2 sentence strategy summary
     2. The 3-5 most important reasoning steps
     Return JSON: {\"solution_strategy\": str, \"key_steps\": [str]}"

   - Alternatively, if no LLM budget: use heuristic extraction:
     * solution_strategy = first sentence of solution
     * key_steps = sentences containing "=", "therefore", "thus", "so", "hence"
   - Support both modes via --extraction-method (llm | heuristic)
   - Match target size: read Condition A/B split manifests to determine target counts
   - Sample and split into train/dev/test using the same 80/10/10 ratio, seed=42
   - Write training-ready JSONL with schema:
     {
       "source": "hendrycks_math" or "gsm8k",
       "condition": "C",
       "input": str,   # the problem text
       "target": str,   # the target JSON as string
       "domain_tag": str,  # math category (algebra, geometry, etc.)
       "split": "train" or "dev" or "test"
     }

   CLI interface:
     python build_control_data.py \
       --output-dir /lfs/ampere8/0/$USER/lean4ai_data/04_control_data/ \
       --condition-a-manifest /lfs/ampere8/0/$USER/lean4ai_data/03_splits/split_manifest.json \
       --extraction-method heuristic \
       --seed 42 \
       --cache-dir /lfs/ampere8/0/$USER/hf_cache/

   For LLM extraction:
     --extraction-method llm \
     --model claude-sonnet-4-20250514 \
     --provider anthropic \
     --max-concurrent 10

2. `compare_sizes.py` — reads all three condition splits and prints:
   - Example counts per condition per split
   - Total token counts per condition (using tiktoken cl100k_base as proxy)
   - Ratio comparison table
   - Writes size_comparison.json

Engineering constraints:
- Typed Python, argparse CLI, pathlib throughout
- Use HuggingFace datasets library for downloads
- Cache downloads to --cache-dir to avoid re-downloading on SNAP
- Deterministic: seed=42, sorted processing
- No hardcoded paths

SNAP cluster notes:
- CPU-only if using heuristic extraction
- 1x A100 if using local vLLM for LLM extraction
- Set HF_HOME or HF_DATASETS_CACHE to /lfs/ampere8/0/$USER/hf_cache/
- Output: /lfs/ampere8/0/$USER/lean4ai_data/04_control_data/
- Time: 1–3 hours

Do NOT add docstrings to every function.
```
