# Lean to natural-language math: modern pilot (Mathlib v4.35.0, Lean v4.35.0)

Pilot of 200 Lean-to-natural-language pairs on current Mathlib. Scale is NOT run; see the recommendation below.

## Staleness of the existing data (evidence)
- lean4ai README links the LeanDojo Benchmark 4 (Zenodo 10114185, `leandojo_benchmark_4_v5`). Its `metadata.json`: Mathlib4 commit `3ce43c18f614b76e161f911b75a3e1ef641620ff`, created 2023-11-06, LeanDojo 1.4.0. That commit is dated 2023-10-21 and its `lean-toolchain` is `leanprover/lean4:v4.2.0-rc4`.
- HF `akjadhav/leandojo-lean4-formal-informal-strings-split` (created 2024-02-08): 47,382 train + 1,344 validation + 1,295 test = 50,021 entries. All 50,021 `formal` names are exact `full_name`s of that benchmark, so it is the same Oct 2023 Mathlib (Lean v4.2.0-rc4). All 50,021 `informal` fields are empty: the set holds Lean only, no natural-language text.
- lean4ai's own natural-language pairs: `src/lean4agi/` has 94 / 220 / 144 pairs (claudedataset, 250ktokendataset, 102k_token_clean_claude_dataset), the first entries of the same HF train set, informalised by an LLM in early 2024. `src/lean4math/dataset_gen/lean_train.jsonl` has 84,679 natural-language-to-Lean pairs (the reverse direction).
- Current: Mathlib v4.35.0 (2026-10-13) on Lean v4.35.0; Mathlib master is already on v4.36.0-rc2. Lean released v4.3.0 ... v4.35.0 since, 33 minor releases.
- Measured on Mathlib v4.35.0 (Lean environment, `scripts/dump_old_names_and_candidates.lean`, table `old_names_status_in_mathlib_v4.35.0.tsv.gz`): of the 50,020 distinct old theorem names, 40,149 (80.3%) still exist, 742 (1.5%) exist but are deprecated, 9,130 (18.3%) no longer exist (renamed or removed). Name existence only: a surviving name can still have a changed statement.
- Current Mathlib has 264,717 public non-deprecated theorems; 80,469 (30.4%) have a name in the old benchmark, 184,248 (69.6%) do not.

## What ran
1. `scripts/dump_old_names_and_candidates.lean` in a Mathlib v4.35.0 checkout (cache fetched, nothing rebuilt): old-name survival, theorem totals, and 6,307 candidates (theorems whose name hash mod 40 is 7), each with its pretty-printed signature (full names) and source line range.
2. `scripts/select_candidates.py`: new-name theorems only, 3-30 source lines, stratified over 27 Mathlib areas, seed 2349, 299 drawn.
3. `scripts/compile_check_statements.py`: each statement as `theorem pilot_pNNN ... := by sorry` in one file with `import Mathlib`, run with Lean v4.35.0. 245 of 299 compiled (81.9%); 54 failed (elaboration errors in the pretty-printed signature, e.g. stuck instances, lost coercions) and were dropped (`dropped_statements_failed_compile.json`). The first 200 compiling were kept, 200 of 200 re-checked in `compile_check_200.lean` / `compile_check_200.txt`: 0 errors, 200 `sorry` warnings (the proof placeholder, expected).
4. Natural-language writing: 12 ub9sc subagents (Claude), 17-20 items each, prompt = Prompt 1 of `experiments/pantograph_sft_scaling_2026/01_data_generation` (same 5 JSON keys) with the Mathlib source proof in place of a Pantograph trace. No Lean in the loop for the text.
5. Independent audit: 12 other ub9sc subagents, same model, no access to the writers' context, each judged statement_ok and proof_ok from the Lean statement + Mathlib source + the text. This is an LLM reading, not a proof, and not a stronger or different model.

## Results
- Lean statements that compile on v4.35.0: 200/200 (Lean-checked). The Mathlib proofs are the repo's own proofs (built by Mathlib's CI), not re-run here.
- Audit statement_ok (LLM reading): 196 yes, 3 unsure, 1 no (p008 adds "topological ring").
- Audit proof_ok (LLM reading): 189 yes, 11 partly, 0 no.
- 157 of 200 carry `possible_uncertainties`, mostly "definition or helper lemma not visible in the snippet". Real weakness: the writer sees the declaration, not the surrounding Mathlib file.
- p028's source snippet has only the attribute and docstring; its proof text is recalled, flagged partly.
- No human check yet. No training or evaluation was run: whether this data helps natural-language reasoning is untested.

## Files
- `pairs_all.jsonl`: 200 pairs (statement, source, theorem_in_words, proof, audit fields).
- `pairs_audit_statement_ok.jsonl`: the 196 with audit statement_ok = yes.
- `audit_summary.json`, `mathlib_v4.35.0_totals.txt`, `compile_check_200.lean`, `compile_check_200.txt`.

## Recommendation on scaling
- Scale, but add a fidelity filter first: give the writer the surrounding file context (opens, variables, defs), then a Lean-side check that each natural-language statement round-trips (a different model re-formalises it and Lean proves it equivalent to the original), instead of an LLM reading.
- Cost: this pilot used about 1.1M subagent tokens in total (writers about 0.67M, auditors about 0.44M; includes 34 items redone after a compile-filter bug), about 5k tokens per kept pair. 20k pairs is about 100M tokens by the same recipe; get a price before running. Pre-filter compile failures (18% here) with the compile check before writing.
- Source of Lean: take it from current Mathlib directly (264k theorems, names not in the 2023 benchmark first), not from the 2023 dump.
- Decision needed before scaling: the experiment that matters is the downstream one (fine-tune on pairs, test natural-language math reasoning); the pilot only shows the data can be made.
