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

## Deliverables

- [ ] Pantograph extraction script (`extract.py`)
- [ ] Raw extracted JSONL (`raw_instances.jsonl`)
- [ ] Extraction manifest with counts and domain distribution
- [ ] Spot-check log for 50 random instances

## Stop/go

Proceed to `01_data_generation` once extraction is stable and spot-check passes.
