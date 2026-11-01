# lean2agi: does Lean-derived natural-language data help natural-language math? (TMLR draft)

Status: draft, not submitted anywhere.

Working title: "Does Training on Informalized Lean Proofs Improve Natural-Language Math in LLMs? Mostly Negative Results, and a Lean-Checked Fidelity Filter".

## What is here
- `paper/refs.bib`: the bibliography (checked against arXiv titles and authors).
- `paper/tmlr.sty`, `tmlr.bst`, `fancyhdr.sty`, `math_commands.tex`: the TMLR template files.
- `paper/fig_roundtrip.pdf`: Lean-checked round-trip outcomes for 200 pairs (167 survive; from `experiments/lean_to_nl_modern_pilot_2026/file_context_roundtrip`, branch `exp/lean-to-nl-modern-pilot`).

## What is not here yet
The full LaTeX source, tables and analysis scripts include results from an internal collaboration and are held back until the collaborators approve public release. The complete draft PDF is shared privately. Once approved, the source goes in `paper/` in this folder.

## Evidence labels used in the paper
Every number is tagged: Lean-checked (Lean decided it), reading (a person or model judged text), or benchmark score (answer accuracy against a key; neither of the other two).
