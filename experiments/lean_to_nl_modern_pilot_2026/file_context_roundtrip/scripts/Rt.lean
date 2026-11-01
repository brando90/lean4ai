import Mathlib
open Lean Meta Elab Command Term

/-- Round-trip check: does the re-formalised statement `x` match the original statement `o`?
 tier1: types definitionally equal. tier2: `type o ↔ type x` proved by automation.
 Prints `RT <o> tier1|tier2|fail`. -/
elab "#rt " o:ident x:ident : command => do
  liftTermElabM do
    let oi ← getConstInfo o.getId
    let xi ← getConstInfo x.getId
    let ot ← instantiateTypeLevelParams oi.toConstantVal (← oi.levelParams.mapM fun _ => mkFreshLevelMVar)
    let xt ← instantiateTypeLevelParams xi.toConstantVal (← xi.levelParams.mapM fun _ => mkFreshLevelMVar)
    let tag := o.getId.toString
    let t1 ← try
        withTransparency .default <| withCurrHeartbeats <| isDefEq ot xt
      catch _ => pure false
    if t1 then
      logInfo m!"RT {tag} tier1"; return
    let goal := mkApp2 (mkConst ``Iff) ot xt
    let ok ← try
      let g ← mkFreshExprMVar goal
      let stx ← `(tactic| (refine ⟨fun h => ?_, fun h => ?_⟩ <;> (intros; first | (exact h) | (apply h <;> assumption) | (simpa using h) | (aesop (add safe h)) | (simp_all))))
      Term.runTactic g.mvarId! stx .term
      let e ← instantiateMVars g
      pure (!e.hasSyntheticSorry && !e.hasSorry)
    catch _ => pure false
    if ok then logInfo m!"RT {tag} tier2" else logInfo m!"RT {tag} fail"
