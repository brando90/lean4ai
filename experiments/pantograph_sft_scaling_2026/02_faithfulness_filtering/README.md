# 02 — Faithfulness Filtering

## Objective

Filter generated targets using an LLM judge prompt, then manually spot-check accepted examples.

## Judge criteria

Score 1–5 on: `theorem_fidelity`, `step_fidelity`, `non_hallucination`, `mathematical_coherence`

## Rejection rules

Reject if any of:
- `accept == false`
- `theorem_fidelity < 4`
- `non_hallucination < 4`
- `mathematical_coherence < 4`

## Manual spot-check

Sample 100 accepted examples and manually verify faithfulness before proceeding to training.

## Deliverables

- [ ] Judge pipeline script (`judge.py`)
- [ ] Filtered Condition A JSONL
- [ ] Filtered Condition B JSONL
- [ ] Judge scores JSONL (all examples, accepted and rejected)
- [ ] Manual spot-check spreadsheet/log (100 examples)
- [ ] Acceptance rate report

## Stop/go gate (Phase 0 → Phase 1)

Proceed only if ≥80% of 100 inspected accepted examples are genuinely faithful.
