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


-- p002
theorem pilot_p002 {L₁ : Type u_1} {L₂ : Type u_2} {M : Type u_3} [Bracket L₁ L₂] [Bracket L₁ M]
  [Bracket L₂ M] [Bracket L₂ L₁] [AddCommGroup M] [IsLieTower L₁ L₂ M] [IsLieTower L₂ L₁ M] (x : L₁) (y : L₂) (m : M) :
  ⁅⁅x, y⁆, m⁆ = -⁅⁅y, x⁆, m⁆ := by sorry
theorem rt_p002 {L₁ : Type u} {L₂ : Type v} {M : Type w} [Bracket L₁ L₂] [Bracket L₁ M] [Bracket L₂ M] [Bracket L₂ L₁] [AddCommGroup M] [IsLieTower L₁ L₂ M] [IsLieTower L₂ L₁ M] (x : L₁) (y : L₂) (m : M) : ⁅⁅x, y⁆, m⁆ = -⁅⁅y, x⁆, m⁆ := by sorry
#rt pilot_p002 rt_p002

-- p003
theorem pilot_p003 (N : ℕ) :
  (Subgroup.map (Matrix.SpecialLinearGroup.mapGL ℝ) (CongruenceSubgroup.Gamma1 N)).strictWidthInfty = 1 := by sorry
theorem rt_p003 (N : ℕ) : Subgroup.strictWidthInfty ((CongruenceSubgroup.Gamma1 N).map (Matrix.SpecialLinearGroup.mapGL ℝ)) = 1 := by sorry
#rt pilot_p003 rt_p003

-- p004
theorem pilot_p004 {α : Type u} {β : Type v} {γ : Type w} {δ : Type u_2} [PartialOrder α]
  [PartialOrder β] [Preorder γ] [Preorder δ] {f : α → γ} {g : β → δ} (hf : StrictAnti f) (hg : StrictAnti g) :
  StrictAnti (Prod.map f g) := by sorry
theorem rt_p004 {A : Type u_1} {B : Type u_2} {C : Type u_3} {D : Type u_4} [PartialOrder A] [PartialOrder B] [Preorder C] [Preorder D] (f : A → C) (g : B → D) (hf : StrictAnti f) (hg : StrictAnti g) : StrictAnti (fun x : A × B => (f x.1, g x.2)) := by sorry
#rt pilot_p004 rt_p004

-- p005
theorem pilot_p005 {α : Type u_1} {m : MeasurableSpace α}
  {ι : Type u_5} [Countable ι] (f : MeasureTheory.SimpleFunc α ENNReal) {s : ι → Set α}
  (hd : Directed (fun x1 x2 => x1 ⊆ x2) s) (μ : MeasureTheory.Measure α) :
  f.lintegral (μ.restrict (⋃ i, s i)) = ⨆ i, f.lintegral (μ.restrict (s i)) := by sorry
theorem rt_p005 {α : Type u} {ι : Type v} [MeasurableSpace α] [Countable ι] (μ : MeasureTheory.Measure α) (f : MeasureTheory.SimpleFunc α ℝ≥0∞) (s : ι → Set α) (hs : Directed (· ⊆ ·) s) : MeasureTheory.SimpleFunc.lintegral f (μ.restrict (⋃ i, s i)) = ⨆ i, MeasureTheory.SimpleFunc.lintegral f (μ.restrict (s i)) := by sorry
#rt pilot_p005 rt_p005

-- p006
theorem pilot_p006 {V : Type u_1} {P : Type u_2} [NormedAddCommGroup V]
  [InnerProductSpace ℝ V] [MetricSpace P] [NormedAddTorsor V P] [hd2 : Fact (Module.finrank ℝ V = 2)]
  [Module.Oriented ℝ V (Fin 2)] (t : Affine.Triangle ℝ P) {i₁ i₂ i₃ : Fin 3} (h₁₂ : i₁ ≠ i₂) (h₁₃ : i₁ ≠ i₃)
  (h₂₃ : i₂ ≠ i₃) (signs : Finset (Fin 3)) :
  2 • EuclideanGeometry.oangle (t.points i₂) (t.points i₁) (Affine.Simplex.excenter t signs) =
    2 • EuclideanGeometry.oangle (Affine.Simplex.excenter t signs) (t.points i₁) (t.points i₃) := by sorry
theorem rt_p006 {V : Type u_1} {P : Type u_2} [NormedAddCommGroup V] [InnerProductSpace ℝ V] [MetricSpace P] [NormedAddTorsor V P] [Fact (Module.finrank ℝ V = 2)] [Module.Oriented ℝ V (Fin 2)] (t : Affine.Simplex ℝ P 2) (i₁ i₂ i₃ : Fin 3) (h₁₂ : i₁ ≠ i₂) (h₁₃ : i₁ ≠ i₃) (h₂₃ : i₂ ≠ i₃) (signs : Finset (Fin 3)) : (2 : ℕ) • EuclideanGeometry.oangle (t.points i₂) (t.points i₁) (t.excenter signs) = (2 : ℕ) • EuclideanGeometry.oangle (t.excenter signs) (t.points i₁) (t.points i₃) := by sorry
#rt pilot_p006 rt_p006

-- p007
theorem pilot_p007 {R : Type u_1} [Ring R] {M : Type u_2} [AddCommGroup M]
  [_root_.Module R M] {N : Type u_3} [AddCommGroup N] [_root_.Module R N] {f : M →ₗ[R] N} : f.range.FG ↔ f.ker.CoFG := by sorry
theorem rt_p007 {R : Type u_1} [Ring R] {M : Type u_2} [AddCommGroup M] [Module R M] {N : Type u_3} [AddCommGroup N] [Module R N] (f : M →ₗ[R] N) : (LinearMap.range f).FG ↔ (LinearMap.ker f).CoFG := by sorry
#rt pilot_p007 rt_p007

-- p008
theorem pilot_p008 {R : Type u_1} {A : Type u_2} {p : A → Prop} [CommSemiring R] [StarRing R] [MetricSpace R]
  [IsTopologicalSemiring R] [ContinuousStar R] [TopologicalSpace A] [Ring A] [StarRing A] [Algebra R A]
  [instCFC : ContinuousFunctionalCalculus R A p] (f g : R → R) (a : A) : Commute (cfc f a) (cfc g a) := by sorry
theorem rt_p008 {R : Type u_1} {A : Type u_2} {p : A → Prop} [CommSemiring R] [StarRing R] [MetricSpace R] [IsTopologicalSemiring R] [ContinuousStar R] [Ring A] [StarRing A] [TopologicalSpace A] [Algebra R A] [ContinuousFunctionalCalculus R A p] (f g : R → R) (a : A) : cfc f a * cfc g a = cfc g a * cfc f a := by sorry
#rt pilot_p008 rt_p008

-- p009
theorem pilot_p009 {G : Type u_1} {α : Type u_2} [Group G] [MulAction G α]
  (h : MulAction.fixedPoints G α ≠ Set.univ) : Nontrivial α := by sorry
theorem rt_p009 (G : Type u) (α : Type v) [Group G] [MulAction G α] (h : MulAction.fixedPoints G α ≠ Set.univ) : Nontrivial α := by sorry
#rt pilot_p009 rt_p009

-- p010
theorem pilot_p010 {𝕜 : Type u_2} [NontriviallyNormedField 𝕜] {E : Type u_3} {F : Type u_4}
  [NormedAddCommGroup E] [NormedSpace 𝕜 E] [NormedAddCommGroup F] [NormedSpace 𝕜 F] {f : E → F} {s : Set E}
  {R : Type u_9} [NormedRing R] [_root_.Module R F] [IsBoundedSMul R F] [SMulCommClass 𝕜 R F] {c : R}
  (hf : AnalyticOnNhd 𝕜 f s) : AnalyticOnNhd 𝕜 (c • f) s := by sorry
theorem rt_p010 {𝕜 : Type u} [NontriviallyNormedField 𝕜] {E : Type v} {F : Type w} [NormedAddCommGroup E] [NormedSpace 𝕜 E] [NormedAddCommGroup F] [NormedSpace 𝕜 F] {R : Type u_1} [NormedRing R] [Module R F] [IsBoundedSMul R F] [SMulCommClass 𝕜 R F] {f : E → F} {s : Set E} (h : AnalyticOnNhd 𝕜 f s) (c : R) : AnalyticOnNhd 𝕜 (fun x => c • f x) s := by sorry
#rt pilot_p010 rt_p010

-- p011
theorem pilot_p011 {α : Type u_1} {mα : MeasurableSpace α} {μ ν : MeasureTheory.Measure α}
  {f : α → ℝ} [MeasureTheory.IsProbabilityMeasure μ] [MeasureTheory.SigmaFinite ν] (hμν : μ.AbsolutelyContinuous ν)
  (hfμ : MeasureTheory.Integrable f μ) (hfν : MeasureTheory.Integrable (fun x => Real.exp (f x)) ν)
  (h_int : MeasureTheory.Integrable (MeasureTheory.llr μ ν) μ) :
  ∫ (x : α), MeasureTheory.llr μ (ν.tilted f) x ∂μ =
    ∫ (x : α), MeasureTheory.llr μ ν x ∂μ - ∫ (x : α), f x ∂μ + Real.log (∫ (x : α), Real.exp (f x) ∂ν) := by sorry
theorem rt_p011 {α : Type u} [MeasurableSpace α] (μ ν : MeasureTheory.Measure α) [MeasureTheory.IsProbabilityMeasure μ] [MeasureTheory.SigmaFinite ν] (hμν : μ.AbsolutelyContinuous ν) (f : α → ℝ) (hf : MeasureTheory.Integrable f μ) (hexp : MeasureTheory.Integrable (fun x => Real.exp (f x)) ν) (hllr : MeasureTheory.Integrable (MeasureTheory.llr μ ν) μ) : (∫ x, MeasureTheory.llr μ (ν.withDensity (fun y => ENNReal.ofReal (Real.exp (f y) / (∫ z, Real.exp (f z) ∂ν)))) x ∂μ) = (∫ x, MeasureTheory.llr μ ν x ∂μ) - (∫ x, f x ∂μ) + Real.log (∫ x, Real.exp (f x) ∂ν) := by sorry
#rt pilot_p011 rt_p011

-- p012
theorem pilot_p012 {α : Type u_2} [CommMonoidWithZero α]
  [StrongNormalizationMonoid α] [UniqueFactorizationMonoid α] {a : α} (ane0 : a ≠ 0) :
  (UniqueFactorizationMonoid.normalizedFactors a).prod = normalize a := by sorry
theorem rt_p012 {α : Type u_1} [CommMonoidWithZero α] [NormalizationMonoid α] [UniqueFactorizationMonoid α] (a : α) (ha : a ≠ 0) : (UniqueFactorizationMonoid.normalizedFactors a).prod = normalize a := by sorry
#rt pilot_p012 rt_p012

-- p013
theorem pilot_p013 {α : Type u_1} [MeasurableSpace α] {f : α → α} {s : Set α}
  {μ : MeasureTheory.Measure α} (h : MeasureTheory.Conservative f μ) (hs : Set.MapsTo f s s) :
  MeasureTheory.Conservative f (μ.restrict s) := by sorry
theorem rt_p013 {α : Type u} [MeasurableSpace α] {μ : MeasureTheory.Measure α} {f : α → α} {s : Set α} (hf : MeasureTheory.Conservative f μ) (hs : Set.MapsTo f s s) : MeasureTheory.Conservative f (μ.restrict s) := by sorry
#rt pilot_p013 rt_p013

-- p014
theorem pilot_p014 (n : ℕ) :
  Real.goldenRatio * ↑(Nat.fib (n + 1)) + ↑(Nat.fib n) = Real.goldenRatio ^ (n + 1) := by sorry
theorem rt_p014 (n : ℕ) : Real.goldenRatio * (Nat.fib (n + 1) : ℝ) + (Nat.fib n : ℝ) = Real.goldenRatio ^ (n + 1) := by sorry
#rt pilot_p014 rt_p014

-- p015
theorem pilot_p015 {𝕜 : Type u_1} {α : Type u_2} {E : Type u_3}
  {m : MeasurableSpace α} {μ : MeasureTheory.Measure α} [NormedRing 𝕜] [NormedAddCommGroup E] [MulActionWithZero 𝕜 E]
  [IsBoundedSMul 𝕜 E] {f : α → E} {φ : α → 𝕜} {p q r : ENNReal} (hr : 0 < r) [hpqr : p.HolderTriple q r] :
  MeasureTheory.eLpNorm (φ • f) r μ ≤ MeasureTheory.eLpNorm φ p μ * MeasureTheory.eLpNorm f q μ := by sorry
theorem rt_p015 {α : Type u_1} [MeasurableSpace α] {μ : MeasureTheory.Measure α} {𝕜 : Type u_2} [NormedRing 𝕜] {E : Type u_3} [NormedAddCommGroup E] [MulActionWithZero 𝕜 E] [IsBoundedSMul 𝕜 E] (f : α → E) (φ : α → 𝕜) {p q r : ℝ≥0∞} (hr : 0 < r) (hpqr : 1 / p + 1 / q = 1 / r) : MeasureTheory.eLpNorm (φ • f) r μ ≤ MeasureTheory.eLpNorm φ p μ * MeasureTheory.eLpNorm f q μ := by sorry
#rt pilot_p015 rt_p015

-- p016
theorem pilot_p016 : AkraBazziRecurrence.GrowsPolynomially fun x => x := by sorry
theorem rt_p016 : AkraBazziRecurrence.GrowsPolynomially (fun x : ℝ => x) := by sorry
#rt pilot_p016 rt_p016

-- p017
theorem pilot_p017 (t : Tactic.ComputeAsymptotics.Monomial) :
  List.length t.inv.unit = List.length t.unit := by sorry
theorem rt_p017 (t : Tactic.ComputeAsymptotics.Monomial) : (Tactic.ComputeAsymptotics.Monomial.inv t).exps.length = t.exps.length := by sorry
#rt pilot_p017 rt_p017

-- p019
theorem pilot_p019 {n : ℕ} (m : ℕ) [NeZero m] (i : Fin n) :
  Finset.map (Fin.castAddEmb m) (Finset.Ioi i) = Finset.Ioo (Fin.castAdd m i) (Fin.natAdd n 0) := by sorry
theorem rt_p019 {n m : ℕ} (hm : m ≠ 0) (i : Fin n) : Finset.image (Fin.castAdd m) (Finset.Ioi i) = Finset.Ioo (Fin.castAdd m i) (Fin.natAdd n (⟨0, Nat.pos_of_ne_zero hm⟩ : Fin m)) := by sorry
#rt pilot_p019 rt_p019

-- p020
theorem pilot_p020 {ι : Type u_1} {ι' : Type u_2} {c : ComplexShape ι}
  {c' : ComplexShape ι'} {C : Type u_3} [CategoryTheory.Category C] [CategoryTheory.Limits.HasZeroMorphisms C]
  (K : HomologicalComplex C c') (e : c.Embedding c') [e.IsTruncGE] [∀ (i' : ι'), K.HasHomology i'] (i : ι)
  (hi : ¬e.BoundaryGE i) : CategoryTheory.IsIso ((K.restrictionToTruncGE' e).f i) := by sorry
open CategoryTheory in theorem rt_p020 {ι : Type u_1} {ι' : Type u_2} {c : ComplexShape ι} {c' : ComplexShape ι'} {C : Type u_3} [Category.{v} C] [HasZeroMorphisms C] (K : HomologicalComplex C c') (e : c.Embedding c') [e.IsTruncGE] [∀ i', K.HasHomology i'] (i : ι) (hi : ¬ e.BoundaryGE i) : IsIso ((K.restrictionToTruncGE' e).f i) := by sorry
#rt pilot_p020 rt_p020

-- p023
theorem pilot_p023 : AddSubmonoid.closure (Set.range fun x => x * x) = AddSubmonoid.nonneg ℤ := by sorry
theorem rt_p023 : (↑(AddSubmonoid.closure (Set.range (fun x : ℤ => x * x))) : Set ℤ) = {n : ℤ | 0 ≤ n} := by sorry
#rt pilot_p023 rt_p023

-- p024
theorem pilot_p024 {R : Type u_1} {V : Type u_2} {P : Type u_4} [Ring R] [PartialOrder R] [AddCommGroup V]
  [_root_.Module R V] [AddTorsor V P] [IsOrderedRing R] {p : P} {l : List P} :
  List.Sbtw R (p :: l) ↔ List.Pairwise (Sbtw R p) l ∧ List.Sbtw R l ∧ l ≠ [p] := by sorry
theorem rt_p024 {R : Type u} {V : Type v} {P : Type w} [Ring R] [PartialOrder R] [IsOrderedRing R] [AddCommGroup V] [Module R V] [AddTorsor V P] (p : P) (l : List P) : (let ordered : List P → Prop := fun xs => (∀ (i j k : Fin xs.length), i < j → j < k → Wbtw R (xs.get i) (xs.get j) (xs.get k)) ∧ xs.Nodup; ordered (p :: l) ↔ l.Pairwise (fun b c => Sbtw R p b c) ∧ ordered l ∧ l ≠ [p]) := by sorry
#rt pilot_p024 rt_p024

-- p026
theorem pilot_p026 {n : Type u_1} {R : Type u_2} {M : Type u_3} {N : Type u_4}
  [Fintype n] [DecidableEq n] [CommRing R] [AddCommGroup M] [_root_.Module R M] [AddCommGroup N] [_root_.Module R N]
  (rl : CartanMatrix.Realisation n R M N) [CharZero R] [IsDomain R] : LinearIndependent R rl.sRoot := by sorry
theorem rt_p026 {n : Type u_1} {R : Type u_2} {M : Type u_3} {N : Type u_4} [Fintype n] [DecidableEq n] [CommRing R] [AddCommGroup M] [Module R M] [AddCommGroup N] [Module R N] [CharZero R] [IsDomain R] (rl : CartanMatrix.Realisation n R M N) : LinearIndependent R rl.v := by sorry
#rt pilot_p026 rt_p026

-- p027
theorem pilot_p027 {Ω : Type u_1} {ι : Type u_2}
  {m : MeasurableSpace Ω} [Preorder ι] {f : MeasureTheory.Filtration ι m} {β : Type u_3} [TopologicalSpace β]
  [MeasurableSpace ι] {γ : Type u_4} [CommMonoid β] [ContinuousMul β] {U : γ → ι → Ω → β} {s : Finset γ}
  (h : ∀ c ∈ s, MeasureTheory.IsStronglyProgressive f (U c)) : MeasureTheory.IsStronglyProgressive f (∏ c ∈ s, U c) := by sorry
theorem rt_p027 {Ω : Type u_1} {ι : Type u_2} {m : MeasurableSpace Ω} [Preorder ι] [MeasurableSpace ι] (f : MeasureTheory.Filtration ι m) {β : Type u_3} [TopologicalSpace β] [CommMonoid β] [ContinuousMul β] {γ : Type u_4} (U : γ → ι → Ω → β) (s : Finset γ) (hU : ∀ c ∈ s, MeasureTheory.IsStronglyProgressive f (U c)) : MeasureTheory.IsStronglyProgressive f (fun i ω => ∏ c ∈ s, U c i ω) := by sorry
#rt pilot_p027 rt_p027

-- p028
theorem pilot_p028 {α : Type u_1} {ι : Type u_3} {M : Type u_5} [AddCommMonoid M] {f : α → M}
  {I : Set ι} {t : ι → Set α} (h : I.PairwiseDisjoint t) (hI : I.Finite) (ht : ∀ i ∈ I, (t i).Finite) :
  ∑ᶠ (a : α) (_ : a ∈ ⋃ x ∈ I, t x), f a = ∑ᶠ (i : ι) (_ : i ∈ I) (j : α) (_ : j ∈ t i), f j := by sorry
theorem rt_p028 {α : Type u_1} {ι : Type u_2} {M : Type u_3} [AddCommMonoid M] (f : α → M) (I : Set ι) (t : ι → Set α) (hdisj : Set.PairwiseDisjoint I t) (hI : I.Finite) (ht : ∀ i ∈ I, (t i).Finite) : (∑ᶠ a ∈ ⋃ i ∈ I, t i, f a) = ∑ᶠ i ∈ I, ∑ᶠ j ∈ t i, f j := by sorry
#rt pilot_p028 rt_p028

-- p029
theorem pilot_p029 {α : Type u_1} {γ : Type u_2}
  {mα : MeasurableSpace α} {mγ : MeasurableSpace γ} [hαγ : MeasurableSpace.CountableOrCountablyGenerated α γ]
  (κ η : ProbabilityTheory.Kernel α γ) [ProbabilityTheory.IsFiniteKernel κ] [ProbabilityTheory.IsFiniteKernel η]
  (a : α) : ((η.withDensity (κ.rnDeriv η)) a) (κ.mutuallySingularSetSlice η a) = 0 := by sorry
theorem rt_p029 {α : Type u} {γ : Type v} [MeasurableSpace α] [MeasurableSpace γ] [MeasurableSpace.CountableOrCountablyGenerated α γ] (κ η : ProbabilityTheory.Kernel α γ) [ProbabilityTheory.IsFiniteKernel κ] [ProbabilityTheory.IsFiniteKernel η] (a : α) : ProbabilityTheory.Kernel.withDensity η (ProbabilityTheory.Kernel.rnDeriv κ η) a (ProbabilityTheory.Kernel.mutuallySingularSetSlice κ η a) = 0 := by sorry
#rt pilot_p029 rt_p029

-- p030
theorem pilot_p030 (r : ℝ) : ∃ x, r = ↑x ∨ r = -↑x := by sorry
theorem rt_p030 (r : ℝ) : ∃ x : ℝ≥0, r = (x : ℝ) ∨ r = -(x : ℝ) := by sorry
#rt pilot_p030 rt_p030

-- p031
theorem pilot_p031 {C : Type u₁} [CategoryTheory.Category C]
  {G : Type u₂} [CategoryTheory.Groupoid G] {G' : Type u₃} [CategoryTheory.Groupoid G'] (H : CategoryTheory.Functor G C)
  (F : CategoryTheory.Functor G' G) :
  CategoryTheory.Core.functorToCore (F.comp H) = F.comp (CategoryTheory.Core.functorToCore H) := by sorry
open CategoryTheory in theorem rt_p031 {C : Type u₁} [Category.{v₁} C] {G : Type u₂} [Groupoid.{v₂} G] {G' : Type u₃} [Groupoid.{v₃} G'] (H : G ⥤ C) (F : G' ⥤ G) : CategoryTheory.Core.functorToCore (F ⋙ H) = F ⋙ CategoryTheory.Core.functorToCore H := by sorry
#rt pilot_p031 rt_p031

-- p032
theorem pilot_p032 {C : Type u} [CategoryTheory.Category C]
  [HomotopicalAlgebra.CategoryWithWeakEquivalences C] [(HomotopicalAlgebra.weakEquivalences C).HasTwoOutOfThreeProperty]
  {X Y Z : C} (f : X ⟶ Y) (g : Y ⟶ Z) [HomotopicalAlgebra.WeakEquivalence f] :
  HomotopicalAlgebra.WeakEquivalence (CategoryTheory.CategoryStruct.comp f g) ↔ HomotopicalAlgebra.WeakEquivalence g := by sorry
open CategoryTheory HomotopicalAlgebra in theorem rt_p032 {C : Type u_1} [Category.{v_1} C] [CategoryWithWeakEquivalences C] [(weakEquivalences C).HasTwoOutOfThreeProperty] {X Y Z : C} (f : X ⟶ Y) (g : Y ⟶ Z) [WeakEquivalence f] : WeakEquivalence (f ≫ g) ↔ WeakEquivalence g := by sorry
#rt pilot_p032 rt_p032

-- p033
theorem pilot_p033 {ι : Type u_1} {E : Type u_2} {μ : MeasureTheory.Measure ℝ}
  {l : Filter ι} [l.IsCountablyGenerated] [NormedAddCommGroup E] [NormedSpace ℝ E] {b : ι → ℝ} {f : ℝ → E}
  (hb : Filter.Tendsto b l Filter.atTop) : Filter.Tendsto (fun i => ∫ (x : ℝ) in Set.Ioi (b i), f x ∂μ) l (nhds 0) := by sorry
theorem rt_p033 {ι : Type u} {E : Type v} [NormedAddCommGroup E] [NormedSpace ℝ E] (μ : MeasureTheory.Measure ℝ) (f : ℝ → E) (l : Filter ι) [Filter.IsCountablyGenerated l] (b : ι → ℝ) (hb : Filter.Tendsto b l Filter.atTop) : Filter.Tendsto (fun i => MeasureTheory.integral (μ := μ.restrict (Set.Ioi (b i))) f) l (𝓝 (0 : E)) := by sorry
#rt pilot_p033 rt_p033

-- p034
theorem pilot_p034 (X : _root_.SSet) {i : ℕ} (x : X.obj (Opposite.op { len := i })) {n : ℕ} (hi : i < n := by lia) :
  x ∈ (X.skeleton n).obj (Opposite.op { len := i }) := by sorry
theorem rt_p034 (X : SSet.{u}) (i n : ℕ) (h : i < n) (x : X.obj (Opposite.op (SimplexCategory.mk i))) : x ∈ (X.skeleton n).obj (Opposite.op (SimplexCategory.mk i)) := by sorry
#rt pilot_p034 rt_p034

-- p036
theorem pilot_p036 {α : Type u_1} {Ω : Type u_2}
  {ι : Type u_3} {_mα : MeasurableSpace α} {_mΩ : MeasurableSpace Ω} {κ : ProbabilityTheory.Kernel α Ω}
  {μ : MeasureTheory.Measure α} {π : ι → Set (Set Ω)} {ι' : Type u_5} {g : ι' → ι} (hg : Function.Bijective g) :
  ProbabilityTheory.Kernel.iIndepSets (π ∘ g) κ μ ↔ ProbabilityTheory.Kernel.iIndepSets π κ μ := by sorry
theorem rt_p036 {α : Type u_1} {Ω : Type u_2} {ι : Type u_3} {ι' : Type u_4} [MeasurableSpace α] [MeasurableSpace Ω] (κ : ProbabilityTheory.Kernel α Ω) (μ : MeasureTheory.Measure α) (π : ι → Set (Set Ω)) (g : ι' → ι) (hg : Function.Bijective g) : ProbabilityTheory.Kernel.iIndepSets (π ∘ g) κ μ ↔ ProbabilityTheory.Kernel.iIndepSets π κ μ := by sorry
#rt pilot_p036 rt_p036

-- p037
theorem pilot_p037 {f g : ArithmeticFunction ℂ} {s : ℂ} (hf : LSeriesSummable (fun n => f n) s)
  (hg : LSeriesSummable (fun n => g n) s) : LSeriesSummable (fun n => (f * g) n) s := by sorry
theorem rt_p037 (f g : ArithmeticFunction ℂ) (s : ℂ) (hf : LSeriesSummable f s) (hg : LSeriesSummable g s) : LSeriesSummable (f * g) s := by sorry
#rt pilot_p037 rt_p037

-- p038
theorem pilot_p038 {R : Type u} [CommRing R] {K' : Type u}
  [Field K'] [Algebra R K'] [IsAlgClosed K'] {ι' : Type u} (v' : ι' → K') [Nontrivial R]
  (hv : IsTranscendenceBasis R v') (hR : Cardinal.mk R ≤ Cardinal.aleph0) (hK : Cardinal.aleph0 < Cardinal.mk K') :
  Cardinal.mk K' = Cardinal.mk ι' := by sorry
theorem rt_p038 {R K' ι' : Type u} [CommRing R] [Nontrivial R] [Field K'] [Algebra R K'] [IsAlgClosed K'] (v : ι' → K') (hv : IsTranscendenceBasis R v) (hR : Cardinal.mk R ≤ Cardinal.aleph0) (hK : Cardinal.aleph0 < Cardinal.mk K') : Cardinal.mk K' = Cardinal.mk ι' := by sorry
#rt pilot_p038 rt_p038

-- p039
theorem pilot_p039 {M : Type u_2} {α : Type u_4} [CommMonoid M] [MeasurableSpace M]
  [MeasurableMul₂ M] {m : MeasurableSpace α} (s : Multiset (α → M)) (hs : ∀ f ∈ s, Measurable f) :
  Measurable fun x => (Multiset.map (fun f => f x) s).prod := by sorry
theorem rt_p039 {M : Type u} {α : Type v} [CommMonoid M] [MeasurableSpace M] [MeasurableMul₂ M] [MeasurableSpace α] (s : Multiset (α → M)) (hs : ∀ f ∈ s, Measurable f) : Measurable (fun x => (s.map (fun f => f x)).prod) := by sorry
#rt pilot_p039 rt_p039

-- p040
theorem pilot_p040 : CategoryTheory.Limits.HasTerminal CategoryTheory.Cat := by sorry
theorem rt_p040 : CategoryTheory.Limits.HasTerminal CategoryTheory.Cat.{v, u} := by sorry
#rt pilot_p040 rt_p040

-- p041
theorem pilot_p041 {R : Type u} [CommSemiring R] {r : R} (hr : IsUnit r) (s : Set R) :
  PrimeSpectrum.zeroLocus (r • s) = PrimeSpectrum.zeroLocus s := by sorry
theorem rt_p041 {R : Type u_1} [CommSemiring R] (r : R) (hr : IsUnit r) (s : Set R) : PrimeSpectrum.zeroLocus (r • s) = PrimeSpectrum.zeroLocus s := by sorry
#rt pilot_p041 rt_p041

-- p042
theorem pilot_p042 {V : Type u} {G : SimpleGraph V} {u v : V} (p : G.Walk u v) (n : ℕ) :
  (p.drop n).length = p.length - n := by sorry
theorem rt_p042 {V : Type u} {G : SimpleGraph V} {u v : V} (p : G.Walk u v) (n : ℕ) : (p.drop n).length = p.length - n := by sorry
#rt pilot_p042 rt_p042

-- p043
theorem pilot_p043 {β : Type u_2} [SemilatticeSup β] {D : Set (Set (β × β))} :
  ScottContinuousOn D fun x =>
    match x with
    | (a, b) => a ⊔ b := by sorry
theorem rt_p043 {β : Type u_1} [SemilatticeSup β] (D : Set (Set (β × β))) : ScottContinuousOn D (fun p : β × β => p.1 ⊔ p.2) := by sorry
#rt pilot_p043 rt_p043

-- p044
theorem pilot_p044 {I : Type u} [CategoryTheory.SmallCategory I] [CategoryTheory.IsCofiltered I]
  {F : CategoryTheory.Functor I FintypeCat} (c : CategoryTheory.Limits.Cone (F.comp FintypeCat.toProfinite))
  (hc : CategoryTheory.Limits.IsLimit c) [∀ (i : I), CategoryTheory.Epi (c.π.app i)] :
  (Profinite.Extend.functor c).Initial := by sorry
open CategoryTheory CategoryTheory.Limits in theorem rt_p044 {I : Type u} [SmallCategory I] [IsCofiltered I] {F : I ⥤ FintypeCat.{max u w}} (c : Cone (F ⋙ FintypeCat.toProfinite)) (hc : IsLimit c) [∀ i, Epi (c.π.app i)] : Functor.Initial (Profinite.Extend.functor c) := by sorry
#rt pilot_p044 rt_p044

-- p045
theorem pilot_p045 (a : Ordinal) {b : Ordinal} (hb₁ : b ≠ 1)
  (hb : Ordinal.IsPrincipal (fun x1 x2 => x1 + x2) b) : Ordinal.IsPrincipal (fun x1 x2 => x1 + x2) (a * b) := by sorry
theorem rt_p045 (a b : Ordinal.{u}) (hb : b ≠ 1) (hp : Ordinal.IsPrincipal (fun x y => x + y) b) : Ordinal.IsPrincipal (fun x y => x + y) (a * b) := by sorry
#rt pilot_p045 rt_p045

-- p046
theorem pilot_p046 {α : Type u_1} {β : Type u_2} [Preorder β] {r : α → α → Prop}
  {s : β → β → Prop} [DecidableRel r] [Trans (fun x1 x2 => x1 ≤ x2) s s] [Trans s (fun x1 x2 => x1 ≤ x2) s] (f : r ↪r s)
  {x y : β} {I J : Inclusion.Interval α} (hx : x ∈ I.map ⇑f) (hy : y ∈ J.map ⇑f) :
  s x y ∈ Inclusion.Interval.orderRelFalse r I J := by sorry
theorem rt_p046 {α : Type u} {β : Type v} [Preorder β] (r : α → α → Prop) [DecidableRel r] (s : β → β → Prop) (hs₁ : ∀ a b c : β, a ≤ b → s b c → s a c) (hs₂ : ∀ a b c : β, s a b → b ≤ c → s a c) (f : r ↪r s) (x y : β) (I J : Inclusion.Interval α) (hx : x ∈ I.map f) (hy : y ∈ J.map f) : s x y ∈ Inclusion.Interval.orderRelFalse r I J := by sorry
#rt pilot_p046 rt_p046

-- p047
theorem pilot_p047 (R : Type u_1) [CommRing R] {n : ℤ} (hn : Even n) :
  Polynomial.eval 0 (Polynomial.Chebyshev.U R n) = ↑↑(n / 2).negOnePow := by sorry
theorem rt_p047 (R : Type u) [CommRing R] (n : ℤ) (hn : Even n) : Polynomial.eval (0 : R) (Polynomial.Chebyshev.U R n) = (((-1 : Rˣ) ^ (n / 2) : Rˣ) : R) := by sorry
#rt pilot_p047 rt_p047

-- p048
theorem pilot_p048 {α : Type u} {β : Type v} {β' : Type v'} (s₁ : Stream'.Seq α) (s₂ : Stream'.Seq β)
  (f : β → β') : s₁.zip (Stream'.Seq.map f s₂) = Stream'.Seq.map (Prod.map id f) (s₁.zip s₂) := by sorry
theorem rt_p048 {α : Type u} {β : Type v} {β' : Type w} (s₁ : Stream'.Seq α) (s₂ : Stream'.Seq β) (f : β → β') : Stream'.Seq.zip s₁ (Stream'.Seq.map f s₂) = Stream'.Seq.map (fun p : α × β => (p.1, f p.2)) (Stream'.Seq.zip s₁ s₂) := by sorry
#rt pilot_p048 rt_p048

-- p051
theorem pilot_p051 {R : Type u_1} {A : Type u_2} [CommRing R] [CommRing A]
  [Algebra R A] {a : A} {lit : ℕ} (h : Mathlib.Meta.NormNum.IsInt a (Int.negOfNat lit)) :
  a = (Algebra.algebraMap R A) ((Int.negOfNat lit).rawCast + 0) + 0 := by sorry
theorem rt_p051 {R : Type u_1} {A : Type u_2} [CommRing R] [CommRing A] [Algebra R A] (a : A) (ℓ : ℕ) (ha : a = ((Int.negOfNat ℓ : ℤ) : A)) : a = algebraMap R A (((Int.negOfNat ℓ : ℤ) : R) + 0) + 0 := by sorry
#rt pilot_p051 rt_p051

-- p052
theorem pilot_p052 {ι : Type u} {γ : Type w} {β : ι → Type v} [DecidableEq ι] [(i : ι) → Zero (β i)]
  [AddCommMonoid γ] (φ : (i : ι) → ZeroHom (β i) γ) (i : ι) (x : β i) :
  ((DFinsupp.sumZeroHom φ) fun₀ | i => x) = (φ i) x := by sorry
theorem rt_p052 {ι : Type u} {β : ι → Type v} {γ : Type w} [DecidableEq ι] [∀ i, Zero (β i)] [AddCommMonoid γ] (φ : ∀ i, ZeroHom (β i) γ) (i : ι) (x : β i) : DFinsupp.sumZeroHom φ (DFinsupp.single i x) = φ i x := by sorry
#rt pilot_p052 rt_p052

-- p053
theorem pilot_p053 {M : Type u_3} [Monoid M] [Preorder M] [MulRightMono M] [MulLeftMono M]
  {l₁ l₂ : List M} (h : List.SublistForall₂ (fun x1 x2 => x1 ≤ x2) l₁ l₂) (h₁ : ∀ a ∈ l₂, 1 ≤ a) : l₁.prod ≤ l₂.prod := by sorry
theorem rt_p053 {M : Type u_1} [Monoid M] [Preorder M] [MulLeftMono M] [MulRightMono M] (l₁ l₂ : List M) (h : ∃ l : List M, l.Sublist l₂ ∧ List.Forall₂ (fun a b : M => a ≤ b) l₁ l) (h₁ : ∀ a ∈ l₂, (1 : M) ≤ a) : l₁.prod ≤ l₂.prod := by sorry
#rt pilot_p053 rt_p053

-- p055
theorem pilot_p055 {R : Type u_1} [CommRing R] {f : R → ℝ} {c : ℝ} (f_nonneg : 0 ≤ f)
  (f_mul : ∀ (x y : R), f (x * y) ≤ c * f x * f y) (x y : R) :
  seminormFromBounded' f (x * y) ≤ seminormFromBounded' f x * seminormFromBounded' f y := by sorry
theorem rt_p055 {R : Type u_1} [CommRing R] (f : R → ℝ) {c : ℝ} (hf : ∀ x, 0 ≤ f x) (hc : ∀ x y, f (x * y) ≤ c * f x * f y) (x y : R) : seminormFromBounded' f (x * y) ≤ seminormFromBounded' f x * seminormFromBounded' f y := by sorry
#rt pilot_p055 rt_p055

-- p056
theorem pilot_p056 {n : ℕ} [NeZero n] {χ : DirichletCharacter ℂ n}
  (hχ : χ ≠ 1) :
  ContinuousOn (fun s => -deriv (DirichletCharacter.LFunction χ) s / DirichletCharacter.LFunction χ s)
    {s | DirichletCharacter.LFunction χ s ≠ 0} := by sorry
theorem rt_p056 {n : ℕ} [NeZero n] (χ : DirichletCharacter ℂ n) (hχ : χ ≠ 1) : ContinuousOn (fun s : ℂ => -(deriv (DirichletCharacter.LFunction χ) s) / DirichletCharacter.LFunction χ s) {s : ℂ | DirichletCharacter.LFunction χ s ≠ 0} := by sorry
#rt pilot_p056 rt_p056

-- p057
theorem pilot_p057 {a b q m a' : ℤ} {b' r : ℕ} (ha : Mathlib.Meta.NormNum.IsInt a a')
  (hb : Mathlib.Meta.NormNum.IsNat b b') (hm : q * ↑b' = m) (h : ↑r + m = a') (h₂ : r.blt b' = Bool.true) :
  Mathlib.Meta.NormNum.IsInt (a / b) q := by sorry
theorem rt_p057 (a b q m a' : ℤ) (b' r : ℕ) (ha : a = a') (hb : b = (b' : ℤ)) (hm : q * (b' : ℤ) = m) (hr : (r : ℤ) + m = a') (hlt : decide (r < b') = true) : a / b = q := by sorry
#rt pilot_p057 rt_p057

-- p058
theorem pilot_p058 {G : Type u_1} [Group G] [Group.IsVirtuallyCyclic G]
  (K : Subgroup G) : Group.IsVirtuallyCyclic ↥K := by sorry
theorem rt_p058 {G : Type u} [Group G] [Group.IsVirtuallyCyclic G] (K : Subgroup G) : Group.IsVirtuallyCyclic K := by sorry
#rt pilot_p058 rt_p058

-- p059
theorem pilot_p059 {R : Type u_1} {S : Type u_2} [Semiring R] [Semiring S] (e : R ≃+* S)
  (I : Ideal R) : e.idealComapOrderIso.symm I = Ideal.map e I := by sorry
theorem rt_p059 {R : Type u} {S : Type v} [Semiring R] [Semiring S] (e : R ≃+* S) (I : Ideal R) : e.idealComapOrderIso.symm I = Ideal.map e I := by sorry
#rt pilot_p059 rt_p059
