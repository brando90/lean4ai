# 00 — Pantograph Extraction

## Objective

Extract structured theorem/proof instances from Lean 4 libraries via Pantograph.

## Scope

- Connect to Lean 4 projects through Pantograph's machine-to-machine interface
- Extract per-theorem: statement, ordered proof states, ordered tactics, file/module path, namespace context, environment references
- Tag each instance with domain metadata and proof length
- Output: one JSONL file with all raw extracted instances

## Per-instance schema

```json
{
  "theorem_id": "str",
  "file_path": "str",
  "module": "str",
  "theorem_statement": "str",
  "local_imports": ["str"],
  "proof_states": ["str"],
  "tactics": ["str"],
  "environment_refs": ["str"],
  "domain_tag": "str",
  "proof_length": "int"
}
```

## SNAP cluster setup

- **Partition:** `jsteinhardt` or `gpu` (CPU-only task, no GPU needed for extraction)
- **Estimated time:** 2–6 hours depending on Mathlib size
- **Memory:** 32GB RAM recommended (Lean server + Pantograph)
- **Storage:** write output to `/lfs/ampere8/0/$USER/lean4ai_data/00_extraction/`

## Deliverables

- [ ] Pantograph extraction script (`extract.py`)
- [ ] Raw extracted JSONL (`raw_instances.jsonl`)
- [ ] Extraction manifest with counts and domain distribution
- [ ] Spot-check log for 50 random instances

## Stop/go

Proceed to `01_data_generation` once extraction is stable and spot-check passes.

---

## Claude Code execution prompt

```
Implement a Pantograph-based Lean 4 theorem/proof extraction pipeline.

Location: /home/user/lean4ai/experiments/pantograph_sft_scaling_2026/00_pantograph_extraction/

Context:
- Pantograph is a Lean 4 machine-to-machine interaction engine (https://github.com/lenianiva/Pantograph).
- PyPantograph is the Python binding (pip install pantograph).
- We need to extract theorem/proof instances from Lean 4 Mathlib or LeanDojo-sourced projects.
- This is the data foundation for a supervised fine-tuning scaling study.

What to build:
1. `extract.py` — typed Python CLI script using argparse that:
   - Connects to a Lean 4 project via PyPantograph
   - Iterates over all theorems in the target Lean project/library
   - For each theorem, extracts:
     * theorem_id (fully qualified name)
     * file_path (source file within the project)
     * module (Lean module name)
     * theorem_statement (the full type signature / statement)
     * local_imports (list of imported modules/namespaces)
     * proof_states (ordered list of proof state strings at each step)
     * tactics (ordered list of tactic strings applied)
     * environment_refs (referenced definitions/lemmas if accessible)
     * domain_tag (inferred from module path, e.g., "Algebra", "Topology", "NumberTheory")
     * proof_length (number of tactic steps)
   - Writes output to JSONL (one JSON object per line per theorem)
   - Handles errors gracefully: logs failures, continues to next theorem
   - Prints progress every 100 theorems

   CLI interface:
     python extract.py \
       --project-path /path/to/lean4/project \
       --output-dir /lfs/ampere8/0/$USER/lean4ai_data/00_extraction/ \
       --output-file raw_instances.jsonl \
       --log-file extraction_log.jsonl \
       --max-theorems 0  # 0 = all

2. `manifest.py` — reads raw_instances.jsonl and produces:
   - Total theorem count
   - Per-domain-tag distribution
   - Proof length histogram stats (min, max, mean, median, p95)
   - Count of extraction failures from the log
   - Writes manifest.json

3. `spot_check.py` — samples 50 random instances from raw_instances.jsonl
   and writes them to spot_check_samples.jsonl for manual review.

4. `requirements.txt` — pantograph, tqdm, orjson or json

Engineering constraints:
- Typed Python (use type hints everywhere)
- No hardcoded paths — all paths via CLI args
- Use pathlib for all file operations
- Deterministic ordering: process theorems in sorted order by theorem_id
- Use orjson for fast JSONL writing if available, fall back to json

SNAP cluster notes:
- This is a CPU-only task (no GPU needed)
- Target Lean 4 projects live under /lfs/ or user home
- Output goes to /lfs/ampere8/0/$USER/lean4ai_data/00_extraction/
- Request 32GB RAM, 4 CPU cores, 6 hour time limit

Do NOT create tests. Do NOT add docstrings to every function. Keep it lean and functional.
```
