# 10 — Evaluation: Proof Explanation (Human Eval)

## Objective

Human-rated evaluation of proof explanation quality on 200 held-out Pantograph test examples.

## Protocol

- Sample 200 examples from the held-out Pantograph test split
- Generate proof explanations from all conditions at all scales
- 3 mathematically trained raters per example
- 1–5 scale on each dimension

## Rating dimensions

1. **Faithfulness** — does the explanation accurately reflect the formal proof?
2. **Clarity** — is the explanation clear and well-structured?
3. **Usefulness** — would this help someone understand the theorem?

## Reporting

- Per-dimension means per condition per scale
- Inter-Rater Reliability (IRR)
- Qualitative examples of strong and weak outputs

## Deliverables

- [ ] Human eval export script (`export_human_eval.py`)
- [ ] Rating collection spreadsheet/interface
- [ ] Raw ratings JSONL
- [ ] Aggregated human eval table
- [ ] IRR report
- [ ] Selected qualitative examples (strong + weak)
