import Mathlib
open Lean Meta Elab Command

def esc (s : String) : String := (toJson s).compress

#eval show CommandElabM Unit from do
  let env ← getEnv
  -- (a) survival of the old names
  let lines ← IO.FS.lines "hf_names.txt"
  let mut rows : Array String := #[]
  for l in lines do
    let n := l.toName
    let ex := env.contains n
    let dep := Linter.isDeprecated env n
    rows := rows.push s!"{l}\t{ex}\t{dep}"
  IO.FS.writeFile "old_names_status.tsv" ("\n".intercalate rows.toList)
  -- (b) candidates in current Mathlib
  let bm := (← IO.FS.lines "bm_names.txt").foldl (fun (s : Std.HashSet String) x => s.insert x) {}
  let mut total := 0
  let mut inBm := 0
  let mut cands : Array String := #[]
  for (n, ci) in env.constants.map₁.toList do
    match ci with
    | .thmInfo _ =>
      let some idx := env.getModuleIdxFor? n | continue
      let mod := env.header.moduleNames[idx.toNat]!
      unless (`Mathlib).isPrefixOf mod do continue
      if n.isInternalDetail || isPrivateName n || n.isInternal then continue
      if Linter.isDeprecated env n then continue
      total := total + 1
      let inb := bm.contains n.toString
      if inb then inBm := inBm + 1
      if n.hash % 40 != 7 then continue
      let some r ← findDeclarationRanges? n | continue
      let doc ← findDocString? env n
      let sig ← (liftTermElabM (do
          let o := (← getOptions).setBool `pp.fullNames true |>.setBool `pp.universes false
          withOptions (fun _ => o) do
            let f ← PrettyPrinter.ppSignature n
            return toString f.fmt) : CommandElabM String)
      cands := cands.push s!"\{\"name\":{esc n.toString},\"module\":{esc mod.toString},\"in_old_benchmark\":{inb},\"start\":{r.range.pos.line},\"end\":{r.range.endPos.line},\"signature\":{esc sig},\"doc\":{esc (doc.getD "")}}"
    | _ => pure ()
  IO.FS.writeFile "candidates.jsonl" ("\n".intercalate cands.toList)
  IO.FS.writeFile "totals.txt" s!"total_theorems_current_mathlib={total}\nof_which_in_old_benchmark_names={inBm}\ncandidates={cands.size}\n"
