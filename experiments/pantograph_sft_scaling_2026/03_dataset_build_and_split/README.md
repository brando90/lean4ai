# 03 — Dataset Build and Split

## Objective

Materialize the final training/dev/test datasets with theorem-level splits.

## Split policy

- 80% train / 10% dev / 10% test-holdout
- **No theorem appears in more than one split**
- No near-duplicate theorem signatures across splits
- Maintain rough domain balance across splits

## Views materialized

| View   | Condition | Contents |
|--------|-----------|----------|
| View A | A         | Full trace: statement + proof states + tactics + metadata → faithful informal proof |
| View B | B         | Theorem only: statement + minimal metadata → proof sketch |

(View C is built separately in `04_generic_math_control_data`)

## Deliverables

- [ ] Split script (`build_splits.py`)
- [ ] `train.jsonl`, `dev.jsonl`, `test.jsonl` for View A
- [ ] `train.jsonl`, `dev.jsonl`, `test.jsonl` for View B
- [ ] Split manifest with per-split counts and domain distributions
- [ ] Deduplication / leakage check report
