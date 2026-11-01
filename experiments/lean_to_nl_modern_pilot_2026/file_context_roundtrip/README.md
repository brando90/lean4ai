# Lean to natural language, pilot step 2: file context + Lean-checked round trip (same 200 pairs)

Nothing scaled beyond the 200 pairs of the first pilot (`../pairs_all.jsonl`). Lean v4.35.0, Mathlib v4.35.0.

## Result (Lean-checked)
- 167 of 200 pairs (83.5%) survive the round trip: a second model, shown only the new text, re-formalises it, and Lean proves its statement equivalent to the original statement.
  - 116: the two statements are definitionally equal (Lean `isDefEq`, binder names and order as written).
  - 51: not definitionally equal, but Lean proves `original <-> re-formalised` with automation (`aesop`/`simp_all`).
- 33 do not survive: 29 compile but equivalence was not proved, 3 hit the heartbeat limit in the automation, 1 re-formalisation still does not compile after a repair round. "Not proved" is not "wrong": the automation only proves easy equivalences, so 167 is a lower bound on faithful texts (example: `HolderTriple p q r` vs `1/p + 1/q = 1/r`).
- No DT, no human check. Whether training on these pairs helps natural-language reasoning is still untested.

## What ran
1. `scripts/ctx.py`: for each pair, a compact extract of the Mathlib file above the declaration (namespace, open, variable, notation, def/structure/class/instance lines with docstrings, up to 7,000 characters, plus the 25 raw lines above). Saved as `file_context_extracts.json`.
2. 12 ub9sc subagents (Claude) rewrote each text from the Lean statement, the Mathlib source and that file context (old text and its uncertainty notes as a draft). Same 5 JSON keys as before. Tokens about 0.9M.
3. Re-formalisation by a different model: Codex CLI (an OpenAI GPT model, no tools, no Lean), shown only the new text and the file context, never the original Lean statement (`scripts/prompt2.txt`). 200 statements; 16 did not compile, so one repair round with the compiler error shown (`scripts/prompt_rep.txt`), still blind to the original.
4. Lean check (`scripts/Rt.lean`, `lean_checks/`): each re-formalised statement is compiled next to the original (`:= by sorry`), then `#rt` tries tier 1 (types definitionally equal) and tier 2 (`type_orig <-> type_rt` by `refine ⟨fun h => ?_, fun h => ?_⟩ <;> (intros; first | exact h | apply h <;> assumption | simpa using h | aesop (add safe h) | simp_all)`). Proofs of the Mathlib theorems themselves are not re-run. Vacuity cannot occur here: an equivalence with the original statement carries over its non-vacuity.
5. Status per pair in `roundtrip_status.json` and in `pairs_v2.jsonl` (`roundtrip_lean_status`: tier1, tier2, fail, timeout, x_not_compiled). `pairs_v2_survivors.jsonl` holds the 167.

## Compared with the first pilot (LLM reading, not a proof)
- Writer uncertainty notes: 123 of 200 pairs (was 157). Missing definitions are still the main cause: the extract is compact, so definitions defined far above or in other files are not shown.
- p008 was the one pilot audit "no" (the text added "topological ring"); the new text drops it and survives (tier 2).

## Example
p003, `CongruenceSubgroup.strictWidthInfty_Gamma1` (survives, tier 1).
- Lean: `theorem (N : ℕ) : (Subgroup.map (Matrix.SpecialLinearGroup.mapGL ℝ) (CongruenceSubgroup.Gamma1 N)).strictWidthInfty = 1`
- Old text: "...The strict width of the cusp ∞ for this subgroup equals 1."
- New text defines Γ1(N) by its matrix conditions (N = 0 allowed), the map to GL2(R), strict periods and strict width, then states the width is 1.
- Re-formalised from the new text alone: `theorem rt_p003 (N : ℕ) : Subgroup.strictWidthInfty ((CongruenceSubgroup.Gamma1 N).map (Matrix.SpecialLinearGroup.mapGL ℝ)) = 1`, definitionally equal to the original.

## Limits
- One re-formaliser model, one sample per text; the repair round used the compiler error.
- The re-formaliser sees the same compact file context as the writer, so a missing definition hurts both.
- Statement faithfulness only; the informal proofs are unchecked (LLM-written from the Mathlib proof).
- Scaling cost, rough: this step about 0.9M ub9sc tokens plus 9 Codex calls for 200 pairs, so 20k pairs would be about 90M tokens plus 900 Codex calls; get a price first.
