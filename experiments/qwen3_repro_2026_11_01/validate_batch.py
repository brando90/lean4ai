"""Spot-check the batched Lean check: re-check random candidates one at a time and compare.

Usage: python validate_batch.py --run out/q3_8b --n 60 --lean-bin ... --mathlib ...
Prints how many single-candidate verdicts differ from the batched verdict (should be 0).
"""
import argparse, json, random, re
from datasets import load_dataset
from lean_check import check_task
from run_pass_at_k import parse

ap = argparse.ArgumentParser()
ap.add_argument("--run", required=True); ap.add_argument("--n", type=int, default=60); ap.add_argument("--seed", type=int, default=0)
ap.add_argument("--lean-bin", required=True); ap.add_argument("--mathlib", required=True)
a = ap.parse_args()
rows = list(load_dataset("UDACA/proofnet-v3-lean4", split="test"))
comps = [json.loads(l) for l in open(f"{a.run}/completions.jsonl")]
chk = json.load(open(f"{a.run}/checks.json"))
random.seed(a.seed)
picks = [(i, j) for i in range(len(rows)) for j in range(len(chk[i]))]
picks = random.sample(picks, a.n)
diff = 0; npass = 0
for i, j in picks:
    single = check_task(rows[i]["header_no_import"], [parse(comps[i]["completions"][j])], a.lean_bin, a.mathlib)[0]
    npass += single; diff += (single != chk[i][j])
print(json.dumps({"run": a.run, "sampled": a.n, "single_pass": npass, "batch_pass": sum(chk[i][j] for i, j in picks), "differ": diff}))
