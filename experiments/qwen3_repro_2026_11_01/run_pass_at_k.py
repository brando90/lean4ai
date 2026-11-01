"""Reproduce lean4ai's pass@k (NL -> Lean statement that compiles) on ProofNet-v3 with a Qwen3 model.

Same protocol as ZIP-FIT main_eval_pass_at_k_af.py: 3-shot prompt, `##...##` parse, sampling
T=0.7 top_p=0.95 top_k=50 max_tokens=512, gold header_no_import prepended, a sample passes
when Lean reports no error, unbiased pass@k (Chen et al. 2021). Needs vllm + datasets.
Example:
  python run_pass_at_k.py --model Qwen/Qwen3-1.7B-Base --n 100 --ks 1 5 10 50 --out out/q3_1p7b_base
Steps: generate -> completions.jsonl; check -> checks.json; score -> results.json. Each skips if its file exists.
"""
import argparse, json, os, re, time
import numpy as np
from lean_check import check_all

FEWSHOT = (
    "Your task is translate the natural language version of the mathematical statement "
    "to a formal Lean statement version, using the following format:\n"
    "natural language statement:\nLet $z=\\frac{1+i}{\\sqrt{2}}.$What is $\\left(z^{1^2}+z^{2^2}+z^{3^2}+\\dots+z^{{12}^2}\\right) \\cdot "
    "\\left(\\frac{1}{z^{1^2}}+\\frac{1}{z^{2^2}}+\\frac{1}{z^{3^2}}+\\dots+\\frac{1}{z^{{12}^2}}\\right)?$ "
    "$\\textbf{(A)}\\ 18 \\qquad \\textbf{(B)}\\ 72-36\\sqrt2 \\qquad \\textbf{(C)}\\ 36 \\qquad \\textbf{(D)}\\ 72 \\qquad \\textbf{(E)}\\ 72+36\\sqrt2$ "
    "Show that it is \\textbf{(C)}\\ 36.\n"
    "formal Lean language statement:##\ntheorem amc12a_2019_p21 (z : ℂ) (h₀ : z = (1 + Complex.I) / Real.sqrt 2) : "
    "(∑ k in Finset.Icc 1 12, (z^(k^2))) * (∑ k in Finset.Icc 1 12, (1 / z^(k^2))) = 36 := sorry\n##"
    "natural language statement:\nIntegers $x$ and $y$ with $x>y>0$ satisfy $x+y+xy=80$. What is $x$? "
    "$\\textbf{(A)}\\ 8 \\qquad\\textbf{(B)}\\ 10 \\qquad\\textbf{(C)}\\ 15 \\qquad\\textbf{(D)}\\ 18 \\qquad\\textbf{(E)}\\ 26$ Show that it is \\textbf{(E)}\\ 26.\n"
    "formal Lean language statement:##\ntheorem amc12a_2015_p10 (x y : ℤ) (h₀ : 0 < y) (h₁ : y < x) "
    "(h₂ : x + y + (x * y) = 80) : x = 26 := sorry\n##"
    "natural language statement:\nWhat is the [[volume]] of a [[cube]] whose [[surface area]] is twice that of a cube with volume 1? "
    "$\\mathrm{(A)}\\ \\sqrt{2}\\qquad\\mathrm{(B)}\\ 2\\qquad\\mathrm{(C)}\\ 2\\sqrt{2}\\qquad\\mathrm{(D)}\\ 4\\qquad\\mathrm{(E)}\\ 8$ Show that it is \\mathrm{(C)}.\n"
    "formal Lean language statement:##\ntheorem amc12a_2008_p8 (x y : ℝ) (h₀ : 0 < x ∧ 0 < y) "
    "(h₁ : y^3 = 1) (h₂ : 6 * x^2 = 2 * (6 * y^2)) : x^3 = 2 * Real.sqrt 2 := sorry\n##"
)


def prompt(nl: str) -> str:
    return FEWSHOT + f"natural language statement:\n{nl}\nformal Lean language statement:"


def parse(text: str) -> str:
    m = re.search(r"##(.*?)##", text, re.DOTALL)
    return m.group(1).strip() if m else "aslfasfj 134ljdf by := :="


def pass_at_k(n: int, c: int, k: int) -> float:
    if n - c < k:
        return 1.0
    return float(1.0 - np.prod(1.0 - k / np.arange(n - c + 1, n + 1)))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--model", required=True)
    ap.add_argument("--n", type=int, default=100)
    ap.add_argument("--ks", type=int, nargs="+", default=[1, 5, 10, 50])
    ap.add_argument("--split", default="test")
    ap.add_argument("--max-tasks", type=int, default=None)
    ap.add_argument("--gpu-mem", type=float, default=0.35)
    ap.add_argument("--seed", type=int, default=42)
    ap.add_argument("--out", required=True)
    ap.add_argument("--lean-bin", required=True)
    ap.add_argument("--mathlib", required=True)
    ap.add_argument("--workers", type=int, default=16)
    ap.add_argument("--gold-check", action="store_true", help="also compile the gold statements (sanity control)")
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    from datasets import load_dataset
    ds = load_dataset("UDACA/proofnet-v3-lean4", split=a.split)
    if a.max_tasks:
        ds = ds.select(range(a.max_tasks))
    rows = list(ds)
    comp_f, chk_f, res_f = (f"{a.out}/{x}" for x in ("completions.jsonl", "checks.json", "results.json"))

    t0 = time.time()
    if not os.path.exists(comp_f):
        from vllm import LLM, SamplingParams
        llm = LLM(model=a.model, dtype="bfloat16", trust_remote_code=True, seed=a.seed, gpu_memory_utilization=a.gpu_mem)
        sp = SamplingParams(temperature=0.7, top_p=0.95, top_k=50, max_tokens=512, n=a.n, seed=a.seed)
        outs = llm.generate([prompt(r["nl_statement"]) for r in rows], sp)
        with open(comp_f, "w") as f:
            for r, o in zip(rows, outs):
                f.write(json.dumps({"name": r["name"], "completions": [c.text for c in o.outputs]}) + "\n")
        del llm
    t_gen = time.time() - t0

    comps = [json.loads(l) for l in open(comp_f)]
    t1 = time.time()
    if not os.path.exists(chk_f):
        items, uniq_maps = [], []
        for r, c in zip(rows, comps):
            parsed = [parse(t) for t in c["completions"]]
            uniq = sorted(set(parsed))
            items.append((r["header_no_import"], uniq))
            uniq_maps.append((parsed, uniq))
        res = check_all(items, a.lean_bin, a.mathlib, a.workers)
        checks = []
        for (parsed, uniq), ok in zip(uniq_maps, res):
            d = dict(zip(uniq, ok))
            checks.append([bool(d[p]) for p in parsed])
        json.dump(checks, open(chk_f, "w"))
    checks = json.load(open(chk_f))
    t_chk = time.time() - t1

    gold = None
    if a.gold_check:
        res = check_all([(r["header_no_import"], [r["formal_statement"]]) for r in rows], a.lean_bin, a.mathlib, a.workers)
        gold = sum(x[0] for x in res)

    n = a.n
    cs = [sum(x) for x in checks]
    res = {"model": a.model, "split": a.split, "tasks": len(rows), "n_samples": n, "seed": a.seed,
           "criterion": "Lean 4 (Mathlib) reports no error on the sampled statement, header prepended; sorry allowed",
           "mean_compile_rate": float(np.mean([c / n for c in cs])),
           "tasks_with_any_pass": int(sum(c > 0 for c in cs)),
           "pass_at_k": {str(k): float(np.mean([pass_at_k(n, c, k) for c in cs])) for k in a.ks if k <= n},
           "gold_statements_compiling": gold,
           "seconds_generate": round(t_gen), "seconds_lean_check": round(t_chk), "per_task_c": dict(zip([r["name"] for r in rows], cs))}
    json.dump(res, open(res_f, "w"), indent=1)
    print(json.dumps({k: v for k, v in res.items() if k != "per_task_c"}, indent=1))


if __name__ == "__main__":
    main()
