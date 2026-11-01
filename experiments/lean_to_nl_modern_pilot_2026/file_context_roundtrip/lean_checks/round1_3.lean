import Mathlib
set_option autoImplicit false
set_option maxHeartbeats 400000
open scoped BigOperators Topology Pointwise ENNReal NNReal
universe r u u' u'' uM u_1 u_10 u_11 u_12 u_18 u_2 u_3 u_4 u_5 u_6 u_7 u_8 u_9 u₁ u₂ u₃ v v' v'' v_1 v_2 v_3 v₁ v₂ v₃ w w' wE wF wG wG' w₁ w₂ w₅
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


-- p188
theorem pilot_p188 {G : Type u_1} {α : Type u_2} [Group G] [MulAction G α] {g : G}
  {x : MulAction.orbitRel.Quotient G α} {a : ↑x.orbit} : ↑(g • a) = g • ↑a := by sorry
theorem rt_p188 {G : Type u} {α : Type v} [Group G] [MulAction G α] (x : MulAction.orbitRel.Quotient G α) (g : G) (a : x.orbit) : ((g • a : x.orbit) : α) = g • (a : α) := by sorry
#rt pilot_p188 rt_p188

-- p189
theorem pilot_p189 {R : Type u} [LinearOrder R] [AddMonoid R] [AddLeftMono R] [AddRightMono R]
  (x y : MinTropical R) (n : ℕ) : (x + y) ^ n = x ^ n + y ^ n := by sorry
theorem rt_p189 {R : Type u} [LinearOrder R] [AddMonoid R] [AddLeftMono R] [AddRightMono R] (x y : MinTropical R) (n : ℕ) : (x + y) ^ n = x ^ n + y ^ n := by sorry
#rt pilot_p189 rt_p189

-- p190
theorem pilot_p190 (x : ZFSet) : x.rank ≤ Order.succ x.sUnion.rank := by sorry
theorem rt_p190 (x : ZFSet.{u}) : ZFSet.rank x ≤ Order.succ (ZFSet.rank (ZFSet.sUnion x)) := by sorry
#rt pilot_p190 rt_p190

-- p191
theorem pilot_p191
  {L : FirstOrder.Language} {α : Type u'} {n : ℕ} {M : Type u_1} [L.Structure M] {N : Type u_2} [L.Structure N]
  {F : Type u_3} [FunLike F M N] {φ : L.BoundedFormula α n} (hA : φ.IsAtomic) [L.HomClass F M N] {f : F}
  (hInj : Function.Injective ⇑f) {v : α → M} {xs : Fin n → M} : φ.Realize v xs → φ.Realize (⇑f ∘ v) (⇑f ∘ xs) := by sorry
theorem rt_p191 {L : FirstOrder.Language.{u, v}} {α : Type u_1} {M : Type u_2} {N : Type u_3} [L.Structure M] [L.Structure N] {F : Type u_4} [FunLike F M N] [FirstOrder.Language.HomClass L F M N] (f : F) (hf : Function.Injective f) {n : ℕ} (φ : L.BoundedFormula α n) (hφ : φ.IsAtomic) (v : α → M) (xs : Fin n → M) (h : φ.Realize v xs) : φ.Realize (f ∘ v) (f ∘ xs) := by sorry
#rt pilot_p191 rt_p191

-- p192
theorem pilot_p192 {α : Type u_1} [LE α] :
  CanLift (α × α) (NonemptyInterval α) NonemptyInterval.toProd fun x => x.1 ≤ x.2 := by sorry
theorem rt_p192 {α : Type u_1} [LE α] : CanLift (α × α) (NonemptyInterval α) NonemptyInterval.toProd (fun x => x.1 ≤ x.2) := by sorry
#rt pilot_p192 rt_p192

-- p193
theorem pilot_p193 {C : Type u₁} [CategoryTheory.Category C]
  {α : Type u_1} {Z : α → C} {f f' : CategoryTheory.Limits.Fan Z}
  {c : CategoryTheory.Limits.Cofan fun x => Opposite.op (Z x)} (hf : CategoryTheory.Limits.IsLimit f)
  (hf' : CategoryTheory.Limits.IsLimit f') (hc : CategoryTheory.Limits.IsColimit c) :
  CategoryTheory.CategoryStruct.comp (CategoryTheory.Limits.opProductIsoCoproduct' hf hc).hom
      (CategoryTheory.Limits.opProductIsoCoproduct' hf' hc).inv =
    (hf.conePointUniqueUpToIso hf').op.inv := by sorry
open CategoryTheory CategoryTheory.Limits Opposite in theorem rt_p193 {C : Type u₁} [Category.{v₁} C] {α : Type u₂} {Z : α → C} {f f' : Fan Z} (hf : IsLimit f) (hf' : IsLimit f') {c : Cofan (fun a => op (Z a))} (hc : IsColimit c) : (opProductIsoCoproduct' hf hc).hom ≫ (opProductIsoCoproduct' hf' hc).inv = ((hf.conePointUniqueUpToIso hf').op).inv := by sorry
#rt pilot_p193 rt_p193

-- p194
theorem pilot_p194 {M : Type u_1} {α : Type u_3} [Monoid M] [MulAction M α] (a : α) :
  (MulAction.orbit M a).Nonempty := by sorry
theorem rt_p194 (M : Type u) {α : Type v} [Monoid M] [MulAction M α] (a : α) : (MulAction.orbit M a).Nonempty := by sorry
#rt pilot_p194 rt_p194

-- p195
theorem pilot_p195 {R : Type u_2} {M : Type u_4} [Semiring R] [AddCommMonoid M]
  [_root_.Module R M] {G : Type u_6} [Group G] [DistribMulAction G M] [SMulCommClass G R M] (a : G) (s : Set M) :
  LinearIndepOn R id (a • s) ↔ LinearIndepOn R id s := by sorry
theorem rt_p195 {R : Type u_1} {M : Type u_2} {G : Type u_3} [Semiring R] [AddCommMonoid M] [Module R M] [Group G] [DistribMulAction G M] [SMulCommClass G R M] (a : G) (s : Set M) : LinearIndependent R (fun x : a • s => (x : M)) ↔ LinearIndependent R (fun x : s => (x : M)) := by sorry
#rt pilot_p195 rt_p195

-- p196
theorem pilot_p196 {f : Ordinal → Ordinal} (hf : Order.IsNormal f) : Ordinal.veblenWith f 1 = Ordinal.deriv f := by sorry
theorem rt_p196 {f : Ordinal.{u} → Ordinal.{u}} (hf : Ordinal.IsNormal f) : Ordinal.veblenWith f 1 = Ordinal.deriv f := by sorry
#rt pilot_p196 rt_p196

-- p198
theorem pilot_p198 {α : Type u_1} {n : ℕ} (v : List.Vector α n) : v.toList.length = n := by sorry
theorem rt_p198 {α : Type u} {n : ℕ} (v : List.Vector α n) : v.toList.length = n := by sorry
#rt pilot_p198 rt_p198

-- p199
theorem pilot_p199 {α : Type u_1} [DecidableEq α] {a : α} {s : Finset α} (h : a ∉ s) : s ∩ {a} = ∅ := by sorry
theorem rt_p199 {α : Type u} [DecidableEq α] (s : Finset α) (a : α) (ha : a ∉ s) : s ∩ {a} = ∅ := by sorry
#rt pilot_p199 rt_p199

-- p200
theorem pilot_p200 {R : Type u} {S : Type v} [CommRing R] [CommRing S]
  [Algebra R S] (P : Algebra.Extension R S) {R₀ : Type u_1} [CommRing R₀] [Algebra R₀ R] [Algebra R₀ S]
  [IsScalarTower R₀ R S] : IsScalarTower R₀ P.Ring S := by sorry
theorem rt_p200 {R : Type u} {S : Type v} [CommRing R] [CommRing S] [Algebra R S] (P : Algebra.Extension.{w} R S) {R₀ : Type u_1} [CommRing R₀] [Algebra R₀ R] [Algebra R₀ S] [IsScalarTower R₀ R S] : IsScalarTower R₀ P.Ring S := by sorry
#rt pilot_p200 rt_p200

-- p201
theorem pilot_p201 {S : Type u_1} [SeminormedGroup S] [IsUltrametricDist S]
  {x y : S} (h : ‖x‖₊ ≠ ‖y‖₊) : ‖x * y‖₊ = Max.max ‖x‖₊ ‖y‖₊ := by sorry
theorem rt_p201 {S : Type u_1} [SeminormedGroup S] [IsUltrametricDist S] (x y : S) (h : ‖x‖₊ ≠ ‖y‖₊) : ‖x * y‖₊ = max ‖x‖₊ ‖y‖₊ := by sorry
#rt pilot_p201 rt_p201

-- p203
theorem pilot_p203 {α : Type u_1} [DecidableEq α] [Fintype α] (s : Finset α) :
  s.card + sᶜ.card = Fintype.card α := by sorry
theorem rt_p203 {α : Type u} [Fintype α] [DecidableEq α] (s : Finset α) : s.card + sᶜ.card = Fintype.card α := by sorry
#rt pilot_p203 rt_p203

-- p204
theorem pilot_p204 {𝕜 : Type u_1} {E : Type u_2} [RCLike 𝕜] [NormedAddCommGroup E]
  [NormedSpace 𝕜 E] [CompleteSpace E] {f : 𝕜 → E} {s : Set 𝕜} (hs : Convex ℝ s) (hf : DifferentiableOn 𝕜 f s) :
  ∃ g, ∀ a ∈ s, HasDerivWithinAt g (f a) s a := by sorry
theorem rt_p204 {𝕜 : Type u_1} {E : Type u_2} [RCLike 𝕜] [NormedAddCommGroup E] [NormedSpace 𝕜 E] [CompleteSpace E] (f : 𝕜 → E) (s : Set 𝕜) (hs : Convex ℝ s) (hf : DifferentiableOn 𝕜 f s) : ∃ g : 𝕜 → E, ∀ a ∈ s, HasDerivWithinAt g (f a) s a := by sorry
#rt pilot_p204 rt_p204

-- p206
theorem pilot_p206 {K : Type u_1} [Field K] [NumberField K]
  (x : NumberField.mixedEmbedding.mixedSpace K) :
  NumberField.mixedEmbedding.convexBodySumFun (-x) = NumberField.mixedEmbedding.convexBodySumFun x := by sorry
theorem rt_p206 {K : Type u_1} [Field K] [NumberField K] (x : NumberField.mixedEmbedding.mixedSpace K) : NumberField.mixedEmbedding.convexBodySumFun (-x) = NumberField.mixedEmbedding.convexBodySumFun x := by sorry
#rt pilot_p206 rt_p206

-- p001
theorem pilot_p001 (A : Type u_3) [CategoryTheory.Category A]
  [CategoryTheory.Abelian A] : (HomotopyCategory.Plus.quasiIso A).IsCompatibleWithShift ℤ := by sorry
theorem rt_p001 (A : Type u_1) [CategoryTheory.Category.{v₁} A] [CategoryTheory.Abelian A] : (CochainComplex.HomotopyCategory.Plus.quasiIso A).IsCompatibleWithShift ℤ := by sorry
#rt pilot_p001 rt_p001

-- p095
theorem pilot_p095 {C : Type u₁} [CategoryTheory.Category C]
  {D : Type u₂} [CategoryTheory.Category D] {J : Type w} [CategoryTheory.Category J] (K : CategoryTheory.Functor J Cᵒᵖ)
  (F : CategoryTheory.Functor C D) [CategoryTheory.Limits.PreservesLimit K.leftOp F] :
  CategoryTheory.Limits.PreservesColimit K F.op := by sorry
open CategoryTheory CategoryTheory.Limits in theorem rt_p095 {C : Type u₁} {D : Type u₂} {J : Type u₃} [Category.{v₁} C] [Category.{v₂} D] [Category.{v₃} J] (K : J ⥤ Cᵒᵖ) (F : C ⥤ D) [PreservesLimit K.leftOp F] : PreservesColimit K F.op := by sorry
#rt pilot_p095 rt_p095

-- p110
theorem pilot_p110 {X Y Z : Type u} [DistribLattice X] [BoundedOrder X] [Fintype X] [DistribLattice Y]
  [BoundedOrder Y] [Fintype Y] [DistribLattice Z] [BoundedOrder Z] [Fintype Z] (f : BoundedLatticeHom X Y)
  (g : BoundedLatticeHom Y Z) :
  FinBddDistLat.ofHom (g.comp f) = CategoryTheory.CategoryStruct.comp (FinBddDistLat.ofHom f) (FinBddDistLat.ofHom g) := by sorry
open CategoryTheory in theorem rt_p110 {X Y Z : Type u} [DistribLattice X] [BoundedOrder X] [Fintype X] [DistribLattice Y] [BoundedOrder Y] [Fintype Y] [DistribLattice Z] [BoundedOrder Z] [Fintype Z] (f : BoundedLatticeHom X Y) (g : BoundedLatticeHom Y Z) : FinBddDistLat.ofHom (g.comp f) = FinBddDistLat.ofHom f ≫ FinBddDistLat.ofHom g := by sorry
#rt pilot_p110 rt_p110

-- p115
theorem pilot_p115 {s t : Finset ℕ} {n : ℕ} (hn : 2 ≤ n) :
  ∑ k ∈ s, n ^ k ≤ ∑ k ∈ t, n ^ k ↔ toColex s ≤ toColex t := by sorry
theorem rt_p115 (s t : Finset ℕ) (n : ℕ) (hn : 2 ≤ n) : (∑ k ∈ s, n ^ k) ≤ (∑ k ∈ t, n ^ k) ↔ toColex s ≤ toColex t := by sorry
#rt pilot_p115 rt_p115

-- p116
theorem pilot_p116 {α : Type u_1} {β : Type u_2} {r : α → α → Prop} {r' : β → β → Prop}
  (s : Set α) (e : r ↪r r') : (⇑e '' s).chainHeight r' = s.chainHeight r := by sorry
theorem rt_p116 {α : Type u_1} {β : Type u_2} {r : α → α → Prop} {r' : β → β → Prop} (s : Set α) (e : RelEmbedding r r') : Set.chainHeight (e '' s) r' = Set.chainHeight s r := by sorry
#rt pilot_p116 rt_p116

-- p130
theorem pilot_p130 {V : Type u} {G : SimpleGraph V} {u : V} {n : ℕ} {p : G.Walk u u}
  (h : p.IsCycle) (hn : 0 < n) : (p.drop n).IsPath := by sorry
theorem rt_p130 {V : Type u} {G : SimpleGraph V} {u : V} {p : G.Walk u u} (hp : p.IsCycle) (n : ℕ) (hn : 0 < n) : (p.drop n).IsPath := by sorry
#rt pilot_p130 rt_p130

-- p207
theorem pilot_p207 {A : Type u_1} [TopologicalSpace A] [Ring A] [StarRing A]
  [Algebra ℂ A] [ContinuousFunctionalCalculus ℂ A IsStarNormal] {u : A} :
  u ∈ unitary A ↔ IsStarNormal u ∧ spectrum ℂ u ⊆ ↑(unitary ℂ) := by sorry
theorem rt_p207 {A : Type u_1} [TopologicalSpace A] [Ring A] [StarRing A] [Algebra ℂ A] [ContinuousFunctionalCalculus ℂ A IsStarNormal] (u : A) : u ∈ unitary A ↔ IsStarNormal u ∧ spectrum ℂ u ⊆ (unitary ℂ : Set ℂ) := by sorry
#rt pilot_p207 rt_p207

-- p208
theorem pilot_p208 {R : Type u_1} {M : Type u_2} {N : Type u_3} [Ring R]
  [AddCommGroup M] [_root_.Module R M] [TopologicalSpace M] [AddCommGroup N] [_root_.Module R N] [TopologicalSpace N]
  {n : ℕ} (f : M [⋀^Fin (n + 1)]→L[R] N) (x y : M) (v : Fin n → M) :
  f (Matrix.vecCons (x - y) v) = f (Matrix.vecCons x v) - f (Matrix.vecCons y v) := by sorry
theorem rt_p208 {R : Type u_1} {M : Type u_2} {N : Type u_3} [Ring R] [AddCommGroup M] [Module R M] [TopologicalSpace M] [AddCommGroup N] [Module R N] [TopologicalSpace N] {n : ℕ} (f : ContinuousAlternatingMap R M N (Fin (n + 1))) (x y : M) (v : Fin n → M) : f (Fin.cons (x - y) v) = f (Fin.cons x v) - f (Fin.cons y v) := by sorry
#rt pilot_p208 rt_p208

-- p210
theorem pilot_p210 {R : Type u_1} {S : Type u_2} [CommRing R] [CommRing S] [Algebra R S]
  [IsLocalRing R] [Module.Finite R S] [Module.Free R S] {ι : Type u_4} [Fintype ι] (b : Module.Basis ι R S) (x : S)
  (i : ι) :
  ((IsLocalRing.basisQuotient b).repr
        ((Ideal.Quotient.mk (Ideal.map (Algebra.algebraMap R S) (IsLocalRing.maximalIdeal R))) x))
      i =
    (Ideal.Quotient.mk (IsLocalRing.maximalIdeal R)) ((b.repr x) i) := by sorry
theorem rt_p210 {R : Type u_1} {S : Type u_2} [CommRing R] [CommRing S] [Algebra R S] [IsLocalRing R] [Module.Finite R S] [Module.Free R S] {ι : Type u_3} [Fintype ι] (b : Module.Basis ι R S) (x : S) (i : ι) : (IsLocalRing.basisQuotient b).repr (Ideal.Quotient.mk (Ideal.map (algebraMap R S) (IsLocalRing.maximalIdeal R)) x) i = Ideal.Quotient.mk (IsLocalRing.maximalIdeal R) (b.repr x i) := by sorry
#rt pilot_p210 rt_p210

-- p211
theorem pilot_p211 {α : Sort u_1} {r : α → α → Prop} [DecidableRel r] [Std.Refl r] :
  Std.Refl fun a b => Decidable.decide (r a b) = Bool.true := by sorry
theorem rt_p211 {α : Type u} (r : α → α → Prop) [DecidableRel r] [Std.Refl r] : Std.Refl (fun a b : α => decide (r a b) = true) := by sorry
#rt pilot_p211 rt_p211

-- p212
theorem pilot_p212 {A : Type u_1} {B : Type u_2} [CommRing A] [CommRing B]
  [Algebra A B] [Module.Flat A B] (h : Function.Surjective (PrimeSpectrum.comap (Algebra.algebraMap A B))) :
  Module.FaithfullyFlat A B := by sorry
theorem rt_p212 {A : Type u} {B : Type v} [CommRing A] [CommRing B] [Algebra A B] [Module.Flat A B] (h : Function.Surjective (PrimeSpectrum.comap (algebraMap A B))) : Module.FaithfullyFlat A B := by sorry
#rt pilot_p212 rt_p212

-- p214
theorem pilot_p214 {C : Type u} [CategoryTheory.Category C]
  (P : CategoryTheory.MorphismProperty C) [P.HasPushouts] (P' : CategoryTheory.MorphismProperty C) :
  P.HasPushoutsAgainst P' := by sorry
theorem rt_p214 {C : Type u} [CategoryTheory.Category.{v} C] (P P' : CategoryTheory.MorphismProperty C) [P.HasPushouts] : P.HasPushoutsAgainst P' := by sorry
#rt pilot_p214 rt_p214

-- p215
theorem pilot_p215 {α : Type u_1} {mα : MeasurableSpace α}
  {μ ν : MeasureTheory.Measure α} (h1 : μ.AbsolutelyContinuous ν) (ν' : MeasureTheory.Measure α) :
  μ.AbsolutelyContinuous (ν + ν') := by sorry
theorem rt_p215 {α : Type u_1} [MeasurableSpace α] {μ ν : MeasureTheory.Measure α} (h : MeasureTheory.Measure.AbsolutelyContinuous μ ν) (ν' : MeasureTheory.Measure α) : MeasureTheory.Measure.AbsolutelyContinuous μ (ν + ν') := by sorry
#rt pilot_p215 rt_p215

-- p217
theorem pilot_p217 {R : Type u_2} [Field R] [LinearOrder R] [IsStrictOrderedRing R] [Archimedean R]
  {p : R → Prop} (h : ∀ᶠ (x : R) in Filter.atTop, p x) : ∀ᶠ (n : ℚ) in Filter.atTop, p ↑n := by sorry
theorem rt_p217 {R : Type u} [Field R] [LinearOrder R] [IsStrictOrderedRing R] [Archimedean R] (p : R → Prop) (hp : Filter.Eventually p Filter.atTop) : Filter.Eventually (fun n : ℚ => p (n : R)) Filter.atTop := by sorry
#rt pilot_p217 rt_p217

-- p219
theorem pilot_p219 {α : Type u_1} {β : Type u_2} (e : PartialEquiv α β) :
  e.symm.trans e ≈ PartialEquiv.ofSet e.target := by sorry
theorem rt_p219 {α : Type u_1} {β : Type u_2} (e : PartialEquiv α β) : e.symm.trans e ≈ PartialEquiv.ofSet e.target := by sorry
#rt pilot_p219 rt_p219

-- p221
theorem pilot_p221 :
  CategoryTheory.Limits.PreservesColimits AlgebraicGeometry.LocallyRingedSpace.forgetToSheafedSpace := by sorry
theorem rt_p221 : CategoryTheory.Limits.PreservesColimitsOfSize.{u, u} AlgebraicGeometry.LocallyRingedSpace.forgetToSheafedSpace.{u} := by sorry
#rt pilot_p221 rt_p221

-- p222
theorem pilot_p222 {α : Type u} {β : Type v} [Uncountable α] [Nonempty β] : Uncountable (α × β) := by sorry
theorem rt_p222 {α : Type u} {β : Type v} [Uncountable α] [Nonempty β] : Uncountable (α × β) := by sorry
#rt pilot_p222 rt_p222

-- p223
theorem pilot_p223 (C D : Type u) [CategoryTheory.Category C]
  [CategoryTheory.Category D] :
  CategoryTheory.IsIso
    (CategoryTheory.Limits.prodComparison
      (CategoryTheory.nerveFunctor.comp (SSet.hoFunctor.comp CategoryTheory.nerveFunctor)) ↧C ↧D) := by sorry
open CategoryTheory CategoryTheory.Limits in theorem rt_p223 (C D : Cat.{u, u}) : IsIso (prodComparison (nerveFunctor.{u, u} ⋙ SSet.hoFunctor ⋙ nerveFunctor.{u, u}) C D) := by sorry
#rt pilot_p223 rt_p223

-- p225
theorem pilot_p225 {R : Type r} [CommRing R] {W' : WeierstrassCurve.Jacobian R}
  [NoZeroDivisors R] {P Q : Fin 3 → R} (hQz : Q 2 ≠ 0) (hx : P 0 * Q 2 ^ 2 = Q 0 * P 2 ^ 2)
  (hy : P 1 * Q 2 ^ 3 = Q 1 * P 2 ^ 3) (hy' : P 1 * Q 2 ^ 3 = W'.negY Q * P 2 ^ 3) : W'.negDblY P = (-W'.dblU P) ^ 3 := by sorry
theorem rt_p225 {R : Type u} [CommRing R] [NoZeroDivisors R] (W' : WeierstrassCurve.Jacobian R) (P Q : Fin 3 → R) (hQ : Q 2 ≠ 0) (h₀ : P 0 * Q 2 ^ 2 = Q 0 * P 2 ^ 2) (h₁ : P 1 * Q 2 ^ 3 = Q 1 * P 2 ^ 3) (h₂ : P 1 * Q 2 ^ 3 = W'.negY Q * P 2 ^ 3) : W'.negDblY P = (-W'.dblU P) ^ 3 := by sorry
#rt pilot_p225 rt_p225

-- p226
theorem pilot_p226 {L : FirstOrder.Language} {α : Type u'} {n : ℕ}
  {φ : L.BoundedFormula α (n + 1)} : FirstOrder.Language.BoundedFormula.sigmaAll ⟨n + 1, φ⟩ = ⟨n, φ.all⟩ := by sorry
theorem rt_p226 {L : FirstOrder.Language.{u, v}} {α : Type u_1} {n : ℕ} (φ : L.BoundedFormula α (n + 1)) : FirstOrder.Language.BoundedFormula.sigmaAll (⟨n + 1, φ⟩ : Σ k, L.BoundedFormula α k) = (⟨n, φ.all⟩ : Σ k, L.BoundedFormula α k) := by sorry
#rt pilot_p226 rt_p226

-- p227
theorem pilot_p227 {c : Cardinal} {n : ℕ} [n.AtLeastTwo] :
  c.lift ≤ Cardinal.beth (OfNat.ofNat n) ↔ c ≤ Cardinal.beth (OfNat.ofNat n) := by sorry
theorem rt_p227 (c : Cardinal.{u}) (n : ℕ) (hn : 2 ≤ n) : Cardinal.lift.{v} c ≤ Cardinal.beth.{max u v} (n : Ordinal.{max u v}) ↔ c ≤ Cardinal.beth.{u} (n : Ordinal.{u}) := by sorry
#rt pilot_p227 rt_p227

-- p228
theorem pilot_p228 {k : Type u_1} {V : Type u_2} {P : Type u_3} [Ring k]
  [AddCommGroup V] [_root_.Module k V] [AddTorsor V P] {s₁ s₂ : AffineSubspace k P} {p : P} (hp₁ : p ∈ s₁)
  (hp₂ : p ∈ s₂) : (s₁ ⊔ s₂).direction = s₁.direction ⊔ s₂.direction := by sorry
theorem rt_p228 {k : Type u} {V : Type v} {P : Type w} [Ring k] [AddCommGroup V] [Module k V] [AffineSpace V P] (s₁ s₂ : AffineSubspace k P) (p : P) (h₁ : p ∈ s₁) (h₂ : p ∈ s₂) : (s₁ ⊔ s₂).direction = s₁.direction ⊔ s₂.direction := by sorry
#rt pilot_p228 rt_p228

-- p229
theorem pilot_p229 {p : Polynomial ℤ} (hp : p ≠ 0) :
  1 ≤ (Polynomial.map (Int.castRingHom ℂ) p).mahlerMeasure := by sorry
theorem rt_p229 (p : Polynomial ℤ) (hp : p ≠ 0) : 1 ≤ (p.map (Int.castRingHom ℂ)).mahlerMeasure := by sorry
#rt pilot_p229 rt_p229

-- p230
theorem pilot_p230 {ι : Type u_1} {R : Type u_4} [CommSemiring R] {s : ι → Type u_7}
  [(i : ι) → AddCommMonoid (s i)] [(i : ι) → _root_.Module R (s i)] {x y : PiTensorProduct R fun i => s i}
  {p q : FreeAddMonoid (R × ((i : ι) → s i))} (hp : p ∈ x.lifts) (hq : q ∈ y.lifts) : p + q ∈ (x + y).lifts := by sorry
theorem rt_p230 {ι : Type u_1} {R : Type u_2} [CommSemiring R] {s : ι → Type u_3} [∀ i, AddCommMonoid (s i)] [∀ i, Module R (s i)] {x y : PiTensorProduct R s} {p q : FreeAddMonoid (R × ((i : ι) → s i))} (hp : p ∈ PiTensorProduct.lifts x) (hq : q ∈ PiTensorProduct.lifts y) : p + q ∈ PiTensorProduct.lifts (x + y) := by sorry
#rt pilot_p230 rt_p230

-- p232
theorem pilot_p232 {α : Type u_1} [Add α] [LE α] [OrderBot α] [Sub α] [OrderedSub α] : OrderedSub (WithTop α) := by sorry
theorem rt_p232 {α : Type u_1} [Add α] [LE α] [OrderBot α] [Sub α] [OrderedSub α] : OrderedSub (WithTop α) := by sorry
#rt pilot_p232 rt_p232

-- p233
theorem pilot_p233 (X : AlgebraicGeometry.Scheme) {U : X.Opens}
  (f g : ↑(X.presheaf.obj (Opposite.op U))) : X.basicOpen (f + g) ≤ X.basicOpen f ⊔ X.basicOpen g := by sorry
theorem rt_p233 (X : AlgebraicGeometry.Scheme.{u}) (U : X.Opens) (f g : X.presheaf.obj (Opposite.op U)) : X.basicOpen (f + g) ≤ X.basicOpen f ⊔ X.basicOpen g := by sorry
#rt pilot_p233 rt_p233

-- p234
theorem pilot_p234 {a b c : Ordinal} (hc : Order.IsSuccLimit c) : a < b + c ↔ ∃ d < c, a < b + d := by sorry
theorem rt_p234 (a b c : Ordinal.{u}) (hc : Order.IsSuccLimit c) : a < b + c ↔ ∃ d < c, a < b + d := by sorry
#rt pilot_p234 rt_p234

-- p235
theorem pilot_p235 {F : Type u} [Field F] {W : WeierstrassCurve.Jacobian F}
  {P : Fin 3 → F} (hPz : P 2 ≠ 0) :
  (MvPolynomial.eval P) W.polynomialX / P 2 ^ 4 =
    Polynomial.evalEval (P 0 / P 2 ^ 2) (P 1 / P 2 ^ 3) W.toAffine.polynomialX := by sorry
theorem rt_p235 {F : Type u} [Field F] (W : WeierstrassCurve.Jacobian F) (P : Fin 3 → F) (hP : P 2 ≠ 0) : MvPolynomial.eval P W.polynomialX / P 2 ^ 4 = W.a₁ * (P 1 / P 2 ^ 3) - (3 * (P 0 / P 2 ^ 2) ^ 2 + 2 * W.a₂ * (P 0 / P 2 ^ 2) + W.a₄) := by sorry
#rt pilot_p235 rt_p235

-- p236
theorem pilot_p236 {b : ℕ} (l : List ℕ) : Nat.ofDigits b (l ++ [0]) = Nat.ofDigits b l := by sorry
theorem rt_p236 (b : ℕ) (L : List ℕ) : Nat.ofDigits b (L ++ [0]) = Nat.ofDigits b L := by sorry
#rt pilot_p236 rt_p236

-- p237
theorem pilot_p237
  (P : CategoryTheory.MorphismProperty AlgebraicGeometry.Scheme) [AlgebraicGeometry.IsZariskiLocalAtTarget P] :
  AlgebraicGeometry.HasAffineProperty P (AlgebraicGeometry.AffineTargetMorphismProperty.of P) := by sorry
theorem rt_p237 (P : CategoryTheory.MorphismProperty AlgebraicGeometry.Scheme.{u}) [AlgebraicGeometry.IsZariskiLocalAtTarget P] : AlgebraicGeometry.HasAffineProperty P (AlgebraicGeometry.AffineTargetMorphismProperty.of P) := by sorry
#rt pilot_p237 rt_p237

-- p238
theorem pilot_p238 {α : Type u_1} {m0 : MeasurableSpace α} {μ : MeasureTheory.Measure α}
  {N : Set α} {f : α → ℝ} [MeasureTheory.IsProbabilityMeasure μ] (hf : MeasureTheory.Integrable f μ) (hN : μ N = 0) :
  ∃ x ∉ N, ∫ (a : α), f a ∂μ ≤ f x := by sorry
theorem rt_p238 {α : Type u_1} [MeasurableSpace α] (μ : MeasureTheory.Measure α) [MeasureTheory.IsProbabilityMeasure μ] (f : α → ℝ) (hf : MeasureTheory.Integrable f μ) (N : Set α) (hN : μ N = 0) : ∃ x : α, x ∉ N ∧ (∫ a, f a ∂μ) ≤ f x := by sorry
#rt pilot_p238 rt_p238

-- p239
theorem pilot_p239 {α : Type u_1} {Ω : Type u_2} {ι : Type u_3}
  {β : Type u_4} {mα : MeasurableSpace α} {mΩ : MeasurableSpace Ω} {κ : ProbabilityTheory.Kernel α Ω}
  {μ : MeasureTheory.Measure α} [Zero β] [One β] {m : MeasurableSpace β} {s : ι → Set Ω}
  (hs : ProbabilityTheory.Kernel.iIndepSet s κ μ) :
  ProbabilityTheory.Kernel.iIndepFun (fun n => (s n).indicator fun _ω => 1) κ μ := by sorry
theorem rt_p239 {α : Type u_1} {Ω : Type u_2} {ι : Type u_3} {β : Type u_4} [MeasurableSpace α] [MeasurableSpace Ω] [MeasurableSpace β] [Zero β] [One β] {κ : ProbabilityTheory.Kernel α Ω} {μ : MeasureTheory.Measure α} {s : ι → Set Ω} (hs : ProbabilityTheory.Kernel.iIndepSet s κ μ) : ProbabilityTheory.Kernel.iIndepFun (fun i => (s i).indicator (fun _ : Ω => (1 : β))) κ μ := by sorry
#rt pilot_p239 rt_p239

-- p241
theorem pilot_p241 {c : Cardinal} : Cardinal.aleph 1 < c.lift ↔ Cardinal.aleph 1 < c := by sorry
theorem rt_p241 (c : Cardinal.{u}) : Cardinal.aleph 1 < Cardinal.lift.{v, u} c ↔ Cardinal.aleph 1 < c := by sorry
#rt pilot_p241 rt_p241

-- p242
theorem pilot_p242 {n : ℕ} {c : ℂ} :
  Polynomial.toAddCircle ((Polynomial.monomial n) c) = c • fourier ↑n := by sorry
open AddCircle in theorem rt_p242 (n : ℕ) (c : ℂ) : Polynomial.toAddCircle (Polynomial.monomial n c) = c • fourier (T := 2 * Real.pi) (n : ℤ) := by sorry
#rt pilot_p242 rt_p242
