# lean4ai results, consolidated (Nov 1 2026)

One place for the lean4ai results that can be public. Every number carries a label:
**Lean-checked** (Lean 4 decided it), **benchmark score** (answer accuracy against a key), **reading** (a person or model judged text).
None of these results use differential testing (no DT).

The 2024 internship results (Qwen2-1.5B, Llama3.1-8B, InternLM, DeepSeek-Coder, an Amazon 8B model) are held back until the collaborators approve public release; the full consolidated tables are in a private Doc.

## Current results (2026)

### Qwen3-Base pass@k on ProofNet-v3 test (Lean-checked compile, not translation correctness)
183 tasks, N=100 samples per task, Lean 4.15 + Mathlib. Details and runner: `qwen3_repro_2026_11_01/`.

| Model | pass@1 | pass@5 | pass@10 | pass@50 | pass@100 | tasks with >=1 pass | gold compiles |
|---|---|---|---|---|---|---|---|
| Qwen3-1.7B-Base | 0.156 | 0.428 | 0.582 | 0.891 | 0.967 | 177/183 | 183/183 |
| Qwen3-4B-Base | 0.234 | 0.589 | 0.756 | 0.977 | 0.989 | 181/183 | 183/183 |
| Qwen3-8B-Base | 0.186 | 0.493 | 0.657 | 0.941 | 0.995 | 182/183 | 183/183 |

### Lean to text to Lean round trip, 200 modern Mathlib statements (Lean-checked)
167 of 200 survive (83.5%, Wilson 77.7 to 88.0), a lower bound: 116 tier 1, 51 tier 2, 29 fail, 3 timeout, 1 not compiled. Figure: `lean2agi_tmlr_2026/paper/fig_roundtrip.pdf`; code on branch `exp/lean-to-nl-modern-pilot`. Not done: human check, scaling, whether training on such pairs helps natural-language reasoning.

### Compile versus faithful
In `brando90/agi4lean`, `experiments/03_passk_small_models` (Lean-checked): the pipeline accepts 94.5% of ProofNet gold statements taken from a different task (99.1% on MiniF2F); exact match with gold is at most 0.3% at pass@1.

### Pantograph SFT scaling (`pantograph_sft_scaling_2026/`)
Plan only, no results yet.

## Appendix: superseded results (kept)
- Qwen3 pass@k, first batch (retracted): Qwen3-1.7B-Base pass@1 0.140, pass@10 0.567, pass@100 0.962 (176/183); 4B 0.156, 0.589, 0.951 (174/183); 8B 0.540, 0.821, 0.989 (181/183). Wrong: the batched Lean check charged errors to the wrong lines, so failing statements counted as passing. Replaced by the table above.
- Earlier model-reading audit of the 200 round-trip pairs (reading): replaced by the Lean-checked round trip.
