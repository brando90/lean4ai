# 04 — Generic Math Control Data (Condition C)

## Objective

Build the Condition C dataset from an external generic math explanation corpus — **not** from Pantograph.

## Why separate

Condition C is the control that tests whether gains come from any math explanation fine-tuning vs. specifically from theorem-prover interaction data. The data source must be independent of Pantograph.

## Target schema

```json
{
  "problem_or_statement_in_words": "str",
  "solution_strategy": "str",
  "explanation": "str",
  "key_steps": ["str"]
}
```

## Candidate sources

- Hendrycks MATH training split explanations
- GSM8K explanations
- Other publicly available math explanation corpora

## Size matching

Match token count and example count to Conditions A/B as closely as possible so training compute is comparable.

## Deliverables

- [ ] Source selection and rationale document
- [ ] Generation/curation script (`build_control_data.py`)
- [ ] `train.jsonl`, `dev.jsonl`, `test.jsonl` for View C
- [ ] Token count and example count comparison table vs. Views A and B
