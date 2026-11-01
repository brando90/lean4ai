# Qwen3 reproduction of the lean4ai pass@k run (Nov 1 2026)

What this measures: the repo's pass@k on ProofNet-v3 (`UDACA/proofnet-v3-lean4`, test, 183 tasks). The model reads a
natural-language statement and writes a Lean 4 statement; a sample passes when Lean 4.15 + Mathlib reports no error on
it (sorry allowed). **This is "the statement compiles", not "the statement is a correct translation".** Numbers are
Lean-checked, sampled at N=100 per task, unbiased pass@k (Chen et al. 2021).

Protocol copied from ZIP-FIT `main_eval_pass_at_k_af.py`: same 3-shot prompt, `##...##` parse, T=0.7, top_p=0.95,
top_k=50, max 512 new tokens, gold `header_no_import` prepended. Seed 42, bf16, vLLM 0.21.

| Model | pass@1 | pass@5 | pass@10 | pass@50 | pass@100 | tasks with >=1 pass | gold statements compile (checker control) |
|---|---|---|---|---|---|---|---|
| Qwen3-1.7B-Base | 0.156 | 0.428 | 0.582 | 0.891 | 0.967 | 177/183 | 183/183 |
| Qwen3-4B-Base | 0.234 | 0.589 | 0.756 | 0.977 | 0.989 | 181/183 | 183/183 |
| Qwen3-8B-Base | 0.186 | 0.493 | 0.657 | 0.941 | 0.995 | 182/183 | 183/183 |

Machine: skampere1, one A100-80GB (GPU 6, free), Lean 4.15.0 + Mathlib in `mathlib4_15_0`. Generation 18 / 33 / 37 min
for 1.7B / 4B / 8B, Lean checking 2 to 8 min each. Free hardware only, no paid API.

## Run
```bash
python run_pass_at_k.py --model Qwen/Qwen3-1.7B-Base --n 100 --ks 1 5 10 50 100 --gold-check \
  --out out/q3_1p7b --lean-bin <lean 4.15 binary> --mathlib <mathlib4 for 4.15 project> --workers 16
python validate_batch.py --run out/q3_1p7b --n 30 --lean-bin ... --mathlib ...   # one-by-one spot check
```

## Why a new runner (the repo's path does not run as written)
- README script calls `~/ZIP-FIT/zip_fit/main/main_eval_pass_at_k_af.py`; on branch `bm_dev` that file is not there (only an old copy under `build/lib`).
- It imports `prompt_templates` (module missing) and `lean4_utils.get_list_lean4_syntax_errors` (not defined; the backwards-compat wrapper shadows and recurses into itself).
- `metrics/lean4_comp_pass_at_k.py`: function names do not match the imports, `wandb` is not imported in the first function, `final_avg_pass` is undefined and the function returns nothing.
- Needs `~/mathlib4_15_0`, PyPantograph, `~/keys/master_hf_token.txt`; README pins vllm 0.6.4.post1, which cannot load Qwen3.
- Not reproduced: the AI4M Gemma-2-2B / GPT-2 fine-tuned models from the paper (not run; Qwen3 base models only, as asked).

## Checker notes (three bugs found and fixed before these numbers)
Many candidates share one Lean file (one `import Mathlib` per task) so 18k statements check in minutes.
1. Header was counted as one line, so errors were charged to the wrong candidate (all passed).
2. Duplicate theorem names collided (fixed with one `namespace` per candidate).
3. A candidate with an open `/-` swallowed the rest of the file (fixed with a `#print` sentinel per candidate; a candidate that loses its sentinel fails and the rest are re-run without it).
After the fixes, one-by-one re-checks of random samples agree with the batched verdicts: 1.7B 48/48, 4B 48/48, 8B 78/78.
Earlier wrong versions were never used; their files are not committed.
