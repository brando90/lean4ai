import Mathlib
set_option autoImplicit false
set_option maxHeartbeats 400000
open scoped BigOperators Topology Pointwise ENNReal NNReal
universe r u u' u'' uM u_1 u_10 u_11 u_12 u_18 u_2 u_3 u_4 u_5 u_6 u_7 u_8 u_9 u₁ u₂ u₃ v v' v'' v_1 v_2 v_3 v₁ v₂ v₃ w w' wE wF wG wG' w₁ w₂ w₅

theorem pilot_p002 {L₁ : Type u_1} {L₂ : Type u_2} {M : Type u_3} [Bracket L₁ L₂] [Bracket L₁ M]
  [Bracket L₂ M] [Bracket L₂ L₁] [AddCommGroup M] [IsLieTower L₁ L₂ M] [IsLieTower L₂ L₁ M] (x : L₁) (y : L₂) (m : M) :
  ⁅⁅x, y⁆, m⁆ = -⁅⁅y, x⁆, m⁆ := by
  sorry

theorem pilot_p003 (N : ℕ) :
  (Subgroup.map (Matrix.SpecialLinearGroup.mapGL ℝ) (CongruenceSubgroup.Gamma1 N)).strictWidthInfty = 1 := by
  sorry

theorem pilot_p004 {α : Type u} {β : Type v} {γ : Type w} {δ : Type u_2} [PartialOrder α]
  [PartialOrder β] [Preorder γ] [Preorder δ] {f : α → γ} {g : β → δ} (hf : StrictAnti f) (hg : StrictAnti g) :
  StrictAnti (Prod.map f g) := by
  sorry

theorem pilot_p005 {α : Type u_1} {m : MeasurableSpace α}
  {ι : Type u_5} [Countable ι] (f : MeasureTheory.SimpleFunc α ENNReal) {s : ι → Set α}
  (hd : Directed (fun x1 x2 => x1 ⊆ x2) s) (μ : MeasureTheory.Measure α) :
  f.lintegral (μ.restrict (⋃ i, s i)) = ⨆ i, f.lintegral (μ.restrict (s i)) := by
  sorry

theorem pilot_p006 {V : Type u_1} {P : Type u_2} [NormedAddCommGroup V]
  [InnerProductSpace ℝ V] [MetricSpace P] [NormedAddTorsor V P] [hd2 : Fact (Module.finrank ℝ V = 2)]
  [Module.Oriented ℝ V (Fin 2)] (t : Affine.Triangle ℝ P) {i₁ i₂ i₃ : Fin 3} (h₁₂ : i₁ ≠ i₂) (h₁₃ : i₁ ≠ i₃)
  (h₂₃ : i₂ ≠ i₃) (signs : Finset (Fin 3)) :
  2 • EuclideanGeometry.oangle (t.points i₂) (t.points i₁) (Affine.Simplex.excenter t signs) =
    2 • EuclideanGeometry.oangle (Affine.Simplex.excenter t signs) (t.points i₁) (t.points i₃) := by
  sorry

theorem pilot_p007 {R : Type u_1} [Ring R] {M : Type u_2} [AddCommGroup M]
  [_root_.Module R M] {N : Type u_3} [AddCommGroup N] [_root_.Module R N] {f : M →ₗ[R] N} : f.range.FG ↔ f.ker.CoFG := by
  sorry

theorem pilot_p008 {R : Type u_1} {A : Type u_2} {p : A → Prop} [CommSemiring R] [StarRing R] [MetricSpace R]
  [IsTopologicalSemiring R] [ContinuousStar R] [TopologicalSpace A] [Ring A] [StarRing A] [Algebra R A]
  [instCFC : ContinuousFunctionalCalculus R A p] (f g : R → R) (a : A) : Commute (cfc f a) (cfc g a) := by
  sorry

theorem pilot_p009 {G : Type u_1} {α : Type u_2} [Group G] [MulAction G α]
  (h : MulAction.fixedPoints G α ≠ Set.univ) : Nontrivial α := by
  sorry

theorem pilot_p010 {𝕜 : Type u_2} [NontriviallyNormedField 𝕜] {E : Type u_3} {F : Type u_4}
  [NormedAddCommGroup E] [NormedSpace 𝕜 E] [NormedAddCommGroup F] [NormedSpace 𝕜 F] {f : E → F} {s : Set E}
  {R : Type u_9} [NormedRing R] [_root_.Module R F] [IsBoundedSMul R F] [SMulCommClass 𝕜 R F] {c : R}
  (hf : AnalyticOnNhd 𝕜 f s) : AnalyticOnNhd 𝕜 (c • f) s := by
  sorry

theorem pilot_p011 {α : Type u_1} {mα : MeasurableSpace α} {μ ν : MeasureTheory.Measure α}
  {f : α → ℝ} [MeasureTheory.IsProbabilityMeasure μ] [MeasureTheory.SigmaFinite ν] (hμν : μ.AbsolutelyContinuous ν)
  (hfμ : MeasureTheory.Integrable f μ) (hfν : MeasureTheory.Integrable (fun x => Real.exp (f x)) ν)
  (h_int : MeasureTheory.Integrable (MeasureTheory.llr μ ν) μ) :
  ∫ (x : α), MeasureTheory.llr μ (ν.tilted f) x ∂μ =
    ∫ (x : α), MeasureTheory.llr μ ν x ∂μ - ∫ (x : α), f x ∂μ + Real.log (∫ (x : α), Real.exp (f x) ∂ν) := by
  sorry

theorem pilot_p012 {α : Type u_2} [CommMonoidWithZero α]
  [StrongNormalizationMonoid α] [UniqueFactorizationMonoid α] {a : α} (ane0 : a ≠ 0) :
  (UniqueFactorizationMonoid.normalizedFactors a).prod = normalize a := by
  sorry

theorem pilot_p013 {α : Type u_1} [MeasurableSpace α] {f : α → α} {s : Set α}
  {μ : MeasureTheory.Measure α} (h : MeasureTheory.Conservative f μ) (hs : Set.MapsTo f s s) :
  MeasureTheory.Conservative f (μ.restrict s) := by
  sorry

theorem pilot_p014 (n : ℕ) :
  Real.goldenRatio * ↑(Nat.fib (n + 1)) + ↑(Nat.fib n) = Real.goldenRatio ^ (n + 1) := by
  sorry

theorem pilot_p015 {𝕜 : Type u_1} {α : Type u_2} {E : Type u_3}
  {m : MeasurableSpace α} {μ : MeasureTheory.Measure α} [NormedRing 𝕜] [NormedAddCommGroup E] [MulActionWithZero 𝕜 E]
  [IsBoundedSMul 𝕜 E] {f : α → E} {φ : α → 𝕜} {p q r : ENNReal} (hr : 0 < r) [hpqr : p.HolderTriple q r] :
  MeasureTheory.eLpNorm (φ • f) r μ ≤ MeasureTheory.eLpNorm φ p μ * MeasureTheory.eLpNorm f q μ := by
  sorry

theorem pilot_p016 : AkraBazziRecurrence.GrowsPolynomially fun x => x := by
  sorry

theorem pilot_p017 (t : Tactic.ComputeAsymptotics.Monomial) :
  List.length t.inv.unit = List.length t.unit := by
  sorry

theorem pilot_p019 {n : ℕ} (m : ℕ) [NeZero m] (i : Fin n) :
  Finset.map (Fin.castAddEmb m) (Finset.Ioi i) = Finset.Ioo (Fin.castAdd m i) (Fin.natAdd n 0) := by
  sorry

theorem pilot_p020 {ι : Type u_1} {ι' : Type u_2} {c : ComplexShape ι}
  {c' : ComplexShape ι'} {C : Type u_3} [CategoryTheory.Category C] [CategoryTheory.Limits.HasZeroMorphisms C]
  (K : HomologicalComplex C c') (e : c.Embedding c') [e.IsTruncGE] [∀ (i' : ι'), K.HasHomology i'] (i : ι)
  (hi : ¬e.BoundaryGE i) : CategoryTheory.IsIso ((K.restrictionToTruncGE' e).f i) := by
  sorry

theorem pilot_p023 : AddSubmonoid.closure (Set.range fun x => x * x) = AddSubmonoid.nonneg ℤ := by
  sorry

theorem pilot_p024 {R : Type u_1} {V : Type u_2} {P : Type u_4} [Ring R] [PartialOrder R] [AddCommGroup V]
  [_root_.Module R V] [AddTorsor V P] [IsOrderedRing R] {p : P} {l : List P} :
  List.Sbtw R (p :: l) ↔ List.Pairwise (Sbtw R p) l ∧ List.Sbtw R l ∧ l ≠ [p] := by
  sorry

theorem pilot_p026 {n : Type u_1} {R : Type u_2} {M : Type u_3} {N : Type u_4}
  [Fintype n] [DecidableEq n] [CommRing R] [AddCommGroup M] [_root_.Module R M] [AddCommGroup N] [_root_.Module R N]
  (rl : CartanMatrix.Realisation n R M N) [CharZero R] [IsDomain R] : LinearIndependent R rl.sRoot := by
  sorry

theorem pilot_p027 {Ω : Type u_1} {ι : Type u_2}
  {m : MeasurableSpace Ω} [Preorder ι] {f : MeasureTheory.Filtration ι m} {β : Type u_3} [TopologicalSpace β]
  [MeasurableSpace ι] {γ : Type u_4} [CommMonoid β] [ContinuousMul β] {U : γ → ι → Ω → β} {s : Finset γ}
  (h : ∀ c ∈ s, MeasureTheory.IsStronglyProgressive f (U c)) : MeasureTheory.IsStronglyProgressive f (∏ c ∈ s, U c) := by
  sorry

theorem pilot_p028 {α : Type u_1} {ι : Type u_3} {M : Type u_5} [AddCommMonoid M] {f : α → M}
  {I : Set ι} {t : ι → Set α} (h : I.PairwiseDisjoint t) (hI : I.Finite) (ht : ∀ i ∈ I, (t i).Finite) :
  ∑ᶠ (a : α) (_ : a ∈ ⋃ x ∈ I, t x), f a = ∑ᶠ (i : ι) (_ : i ∈ I) (j : α) (_ : j ∈ t i), f j := by
  sorry

theorem pilot_p029 {α : Type u_1} {γ : Type u_2}
  {mα : MeasurableSpace α} {mγ : MeasurableSpace γ} [hαγ : MeasurableSpace.CountableOrCountablyGenerated α γ]
  (κ η : ProbabilityTheory.Kernel α γ) [ProbabilityTheory.IsFiniteKernel κ] [ProbabilityTheory.IsFiniteKernel η]
  (a : α) : ((η.withDensity (κ.rnDeriv η)) a) (κ.mutuallySingularSetSlice η a) = 0 := by
  sorry

theorem pilot_p030 (r : ℝ) : ∃ x, r = ↑x ∨ r = -↑x := by
  sorry

theorem pilot_p031 {C : Type u₁} [CategoryTheory.Category C]
  {G : Type u₂} [CategoryTheory.Groupoid G] {G' : Type u₃} [CategoryTheory.Groupoid G'] (H : CategoryTheory.Functor G C)
  (F : CategoryTheory.Functor G' G) :
  CategoryTheory.Core.functorToCore (F.comp H) = F.comp (CategoryTheory.Core.functorToCore H) := by
  sorry

theorem pilot_p032 {C : Type u} [CategoryTheory.Category C]
  [HomotopicalAlgebra.CategoryWithWeakEquivalences C] [(HomotopicalAlgebra.weakEquivalences C).HasTwoOutOfThreeProperty]
  {X Y Z : C} (f : X ⟶ Y) (g : Y ⟶ Z) [HomotopicalAlgebra.WeakEquivalence f] :
  HomotopicalAlgebra.WeakEquivalence (CategoryTheory.CategoryStruct.comp f g) ↔ HomotopicalAlgebra.WeakEquivalence g := by
  sorry

theorem pilot_p033 {ι : Type u_1} {E : Type u_2} {μ : MeasureTheory.Measure ℝ}
  {l : Filter ι} [l.IsCountablyGenerated] [NormedAddCommGroup E] [NormedSpace ℝ E] {b : ι → ℝ} {f : ℝ → E}
  (hb : Filter.Tendsto b l Filter.atTop) : Filter.Tendsto (fun i => ∫ (x : ℝ) in Set.Ioi (b i), f x ∂μ) l (nhds 0) := by
  sorry

theorem pilot_p034 (X : _root_.SSet) {i : ℕ} (x : X.obj (Opposite.op { len := i })) {n : ℕ} (hi : i < n := by lia) :
  x ∈ (X.skeleton n).obj (Opposite.op { len := i }) := by
  sorry

theorem pilot_p036 {α : Type u_1} {Ω : Type u_2}
  {ι : Type u_3} {_mα : MeasurableSpace α} {_mΩ : MeasurableSpace Ω} {κ : ProbabilityTheory.Kernel α Ω}
  {μ : MeasureTheory.Measure α} {π : ι → Set (Set Ω)} {ι' : Type u_5} {g : ι' → ι} (hg : Function.Bijective g) :
  ProbabilityTheory.Kernel.iIndepSets (π ∘ g) κ μ ↔ ProbabilityTheory.Kernel.iIndepSets π κ μ := by
  sorry

theorem pilot_p037 {f g : ArithmeticFunction ℂ} {s : ℂ} (hf : LSeriesSummable (fun n => f n) s)
  (hg : LSeriesSummable (fun n => g n) s) : LSeriesSummable (fun n => (f * g) n) s := by
  sorry

theorem pilot_p038 {R : Type u} [CommRing R] {K' : Type u}
  [Field K'] [Algebra R K'] [IsAlgClosed K'] {ι' : Type u} (v' : ι' → K') [Nontrivial R]
  (hv : IsTranscendenceBasis R v') (hR : Cardinal.mk R ≤ Cardinal.aleph0) (hK : Cardinal.aleph0 < Cardinal.mk K') :
  Cardinal.mk K' = Cardinal.mk ι' := by
  sorry

theorem pilot_p039 {M : Type u_2} {α : Type u_4} [CommMonoid M] [MeasurableSpace M]
  [MeasurableMul₂ M] {m : MeasurableSpace α} (s : Multiset (α → M)) (hs : ∀ f ∈ s, Measurable f) :
  Measurable fun x => (Multiset.map (fun f => f x) s).prod := by
  sorry

theorem pilot_p040 : CategoryTheory.Limits.HasTerminal CategoryTheory.Cat := by
  sorry

theorem pilot_p041 {R : Type u} [CommSemiring R] {r : R} (hr : IsUnit r) (s : Set R) :
  PrimeSpectrum.zeroLocus (r • s) = PrimeSpectrum.zeroLocus s := by
  sorry

theorem pilot_p042 {V : Type u} {G : SimpleGraph V} {u v : V} (p : G.Walk u v) (n : ℕ) :
  (p.drop n).length = p.length - n := by
  sorry

theorem pilot_p043 {β : Type u_2} [SemilatticeSup β] {D : Set (Set (β × β))} :
  ScottContinuousOn D fun x =>
    match x with
    | (a, b) => a ⊔ b := by
  sorry

theorem pilot_p044 {I : Type u} [CategoryTheory.SmallCategory I] [CategoryTheory.IsCofiltered I]
  {F : CategoryTheory.Functor I FintypeCat} (c : CategoryTheory.Limits.Cone (F.comp FintypeCat.toProfinite))
  (hc : CategoryTheory.Limits.IsLimit c) [∀ (i : I), CategoryTheory.Epi (c.π.app i)] :
  (Profinite.Extend.functor c).Initial := by
  sorry

theorem pilot_p045 (a : Ordinal) {b : Ordinal} (hb₁ : b ≠ 1)
  (hb : Ordinal.IsPrincipal (fun x1 x2 => x1 + x2) b) : Ordinal.IsPrincipal (fun x1 x2 => x1 + x2) (a * b) := by
  sorry

theorem pilot_p046 {α : Type u_1} {β : Type u_2} [Preorder β] {r : α → α → Prop}
  {s : β → β → Prop} [DecidableRel r] [Trans (fun x1 x2 => x1 ≤ x2) s s] [Trans s (fun x1 x2 => x1 ≤ x2) s] (f : r ↪r s)
  {x y : β} {I J : Inclusion.Interval α} (hx : x ∈ I.map ⇑f) (hy : y ∈ J.map ⇑f) :
  s x y ∈ Inclusion.Interval.orderRelFalse r I J := by
  sorry

theorem pilot_p047 (R : Type u_1) [CommRing R] {n : ℤ} (hn : Even n) :
  Polynomial.eval 0 (Polynomial.Chebyshev.U R n) = ↑↑(n / 2).negOnePow := by
  sorry

theorem pilot_p048 {α : Type u} {β : Type v} {β' : Type v'} (s₁ : Stream'.Seq α) (s₂ : Stream'.Seq β)
  (f : β → β') : s₁.zip (Stream'.Seq.map f s₂) = Stream'.Seq.map (Prod.map id f) (s₁.zip s₂) := by
  sorry

theorem pilot_p051 {R : Type u_1} {A : Type u_2} [CommRing R] [CommRing A]
  [Algebra R A] {a : A} {lit : ℕ} (h : Mathlib.Meta.NormNum.IsInt a (Int.negOfNat lit)) :
  a = (Algebra.algebraMap R A) ((Int.negOfNat lit).rawCast + 0) + 0 := by
  sorry

theorem pilot_p052 {ι : Type u} {γ : Type w} {β : ι → Type v} [DecidableEq ι] [(i : ι) → Zero (β i)]
  [AddCommMonoid γ] (φ : (i : ι) → ZeroHom (β i) γ) (i : ι) (x : β i) :
  ((DFinsupp.sumZeroHom φ) fun₀ | i => x) = (φ i) x := by
  sorry

theorem pilot_p053 {M : Type u_3} [Monoid M] [Preorder M] [MulRightMono M] [MulLeftMono M]
  {l₁ l₂ : List M} (h : List.SublistForall₂ (fun x1 x2 => x1 ≤ x2) l₁ l₂) (h₁ : ∀ a ∈ l₂, 1 ≤ a) : l₁.prod ≤ l₂.prod := by
  sorry

theorem pilot_p055 {R : Type u_1} [CommRing R] {f : R → ℝ} {c : ℝ} (f_nonneg : 0 ≤ f)
  (f_mul : ∀ (x y : R), f (x * y) ≤ c * f x * f y) (x y : R) :
  seminormFromBounded' f (x * y) ≤ seminormFromBounded' f x * seminormFromBounded' f y := by
  sorry

theorem pilot_p056 {n : ℕ} [NeZero n] {χ : DirichletCharacter ℂ n}
  (hχ : χ ≠ 1) :
  ContinuousOn (fun s => -deriv (DirichletCharacter.LFunction χ) s / DirichletCharacter.LFunction χ s)
    {s | DirichletCharacter.LFunction χ s ≠ 0} := by
  sorry

theorem pilot_p057 {a b q m a' : ℤ} {b' r : ℕ} (ha : Mathlib.Meta.NormNum.IsInt a a')
  (hb : Mathlib.Meta.NormNum.IsNat b b') (hm : q * ↑b' = m) (h : ↑r + m = a') (h₂ : r.blt b' = Bool.true) :
  Mathlib.Meta.NormNum.IsInt (a / b) q := by
  sorry

theorem pilot_p058 {G : Type u_1} [Group G] [Group.IsVirtuallyCyclic G]
  (K : Subgroup G) : Group.IsVirtuallyCyclic ↥K := by
  sorry

theorem pilot_p059 {R : Type u_1} {S : Type u_2} [Semiring R] [Semiring S] (e : R ≃+* S)
  (I : Ideal R) : e.idealComapOrderIso.symm I = Ideal.map e I := by
  sorry

theorem pilot_p060 {C : Type u₁} [CategoryTheory.Category C] {J : Type u}
  [CategoryTheory.Category J] [CategoryTheory.Limits.HasTerminal J] (F : CategoryTheory.Functor J C)
  [∀ (i j : J) (f : i ⟶ j), CategoryTheory.IsIso (F.map f)] :
  CategoryTheory.IsIso (CategoryTheory.Limits.limit.π F (⊤_ J)) := by
  sorry

theorem pilot_p061 {R : Type u_1} {S : Type u_2} [CommRing R]
  [CommRing S] [IsDomain R] [Algebra R S] [IsIntegrallyClosed R] [IsDomain S] [Module.IsTorsionFree R S] {s : S}
  {p : Polynomial R} (hp : (Polynomial.aeval s) p = 0) (h₀ : p ≠ 0)
  (pmin : ∀ (q : Polynomial R), q.Monic → (Polynomial.aeval s) q = 0 → p.degree ≤ q.degree) :
  IsIntegral R s ↔ Polynomial.C p.leadingCoeff ∣ p := by
  sorry

theorem pilot_p063 {n : Type u} (S : AlgebraicGeometry.Scheme)
  [AlgebraicGeometry.IsAffine S] :
  CategoryTheory.CategoryStruct.comp (AlgebraicGeometry.AffineSpace.isoOfIsAffine n S).inv
      (AlgebraicGeometry.AffineSpace n S ↘ S) =
    CategoryTheory.CategoryStruct.comp (AlgebraicGeometry.Spec.map (CommRingCat.ofHom MvPolynomial.C)) S.isoSpec.inv := by
  sorry

theorem pilot_p064 {C : Type u_1} [CategoryTheory.Category C]
  {S₁ S₂ S₃ : CategoryTheory.SimplicialObject.Split C} (Φ₁₂ : S₁ ⟶ S₂) (Φ₂₃ : S₂ ⟶ S₃) :
  (CategoryTheory.CategoryStruct.comp Φ₁₂ Φ₂₃).F = CategoryTheory.CategoryStruct.comp Φ₁₂.F Φ₂₃.F := by
  sorry

theorem pilot_p065 {α β : Sort u} {a : α} {b : β} : a ≍ b ↔ ∃ (h : α = β), cast h a = b := by
  sorry

theorem pilot_p066 {C : Type u₁}
  [CategoryTheory.Category C] {D : Type u₂} [CategoryTheory.Category D] [CategoryTheory.Limits.HasZeroObject D]
  [CategoryTheory.Limits.HasZeroMorphisms D] (G : CategoryTheory.Functor C D) (hG : CategoryTheory.Limits.IsZero G)
  (J : Type u_1) [CategoryTheory.Category J] : CategoryTheory.Limits.PreservesColimitsOfShape J G := by
  sorry

theorem pilot_p067 {S : Type u_1} {R : Type u} {M : Type v} [CommSemiring S]
  [Semiring R] [AddCommMonoid M] [Algebra S R] [_root_.Module S M] [_root_.Module R M] [_root_.Module Rᵐᵒᵖ M]
  [SMulCommClass R Rᵐᵒᵖ M] [IsScalarTower S R M] [IsScalarTower S Rᵐᵒᵖ M] :
  (TrivSqZeroExt.inlAlgHom S R M).range ⊔ Algebra.adjoin S (Set.range TrivSqZeroExt.inr) = ⊤ := by
  sorry

theorem pilot_p069 {r : ℝ} (hr : r < 0) :
  Filter.Tendsto (fun x => Real.log x / x ^ r) (nhdsWithin 0 (Set.Ioi 0)) (nhds 0) := by
  sorry

theorem pilot_p070 {α : Type u_1} {β : Type u_2} [TopologicalSpace α] [TopologicalSpace β]
  [SemilatticeSup β] [ContinuousSup β] {ι : Type u_3} {s : Finset ι} (H : s.Nonempty) (f : ι → C(α, β)) :
  ⇑(s.sup' H f) = s.sup' H fun i => ⇑(f i) := by
  sorry

theorem pilot_p071 {𝕜 : Type u_2} {E : Type u_6} {ι : Type u_9}
  [NontriviallyNormedField 𝕜] [AddCommGroup E] [_root_.Module 𝕜 E] {p : SeminormFamily 𝕜 E ι} [t : TopologicalSpace E]
  (hp : WithSeminorms p) (q : Seminorm 𝕜 E) (hq : Continuous ⇑q) : ∃ s C, C ≠ 0 ∧ q ≤ C • ∑ i ∈ s, p i := by
  sorry

theorem pilot_p072 {α : Type u_1} {β : Type u_2} {γ : Type u_3}
  {mα : MeasurableSpace α} {mβ : MeasurableSpace β} {mγ : MeasurableSpace γ} (μ : MeasureTheory.Measure γ)
  (κ : ProbabilityTheory.Kernel α β) : ⇑((ProbabilityTheory.Kernel.const β μ).comp κ) = fun a => (κ a) Set.univ • μ := by
  sorry

theorem pilot_p073 {R : Type u_1} {M : Type u_2} [Semiring R] [AddCommMonoid M] [_root_.Module R M]
  (p p' : Submodule R M) : p ⊔ p' = ⊤ ↔ ∀ (m : M), ∃ u ∈ p, ∃ v ∈ p', m = u + v := by
  sorry

theorem pilot_p074 {σ : Type u_1} {R : Type u_2} [Semiring R]
  {f : MvPowerSeries σ R} : f ≠ 0 ↔ ∃ n d, (MvPowerSeries.coeff d) f ≠ 0 ∧ Finsupp.degree d = n := by
  sorry

theorem pilot_p075 {n m : SemiSimplexCategory} (f : n ⟶ m) :
  CategoryTheory.Mono (SemiSimplexCategory.toSimplexCategory.map f) := by
  sorry

theorem pilot_p076 : CategoryTheory.IsIso AlgebraicGeometry.ΓSpec.adjunction.counit := by
  sorry

theorem pilot_p077 {α : Type u_1} {β : Type u_2} [PartialOrder α] [PartialOrder β] {a : α}
  {b₁ b₂ : β} : (a, b₁) ⩿ (a, b₂) ↔ b₁ ⩿ b₂ := by
  sorry

theorem pilot_p078 (R : Type u_1) (S : Type u_2) {A : Type u_3} [CommRing R]
  [CommRing S] [Ring A] [Algebra R S] [Algebra R A] [Algebra S A] [IsScalarTower R S A] [NoZeroDivisors S]
  [Algebra.IsAlgebraic R S] [FaithfulSMul R S] {a : A} : IsAlgebraic R a ↔ IsAlgebraic S a := by
  sorry

theorem pilot_p079 {A : Type u_1} {p : A → Prop} [NormedRing A] [StarRing A] [NormedAlgebra ℂ A]
  [ContinuousFunctionalCalculus ℂ A p] {a : A} (ha : p a := by cfc_tac) : cfc Complex.exp a = NormedSpace.exp a := by
  sorry

theorem pilot_p081 {R : Type u_1} {M : Type uM} [CommRing R] [AddCommGroup M]
  [_root_.Module R M]
  (H : ∀ (I : Ideal R) (x : I.IsMaximal), Module.Projective (Localization.AtPrime I) (LocalizedModule I.primeCompl M))
  [Module.FinitePresentation R M] : Module.Projective R M := by
  sorry

theorem pilot_p082 {R : Type u_1} [CommMonoidWithZero R] [WfDvdMonoid R] {x : R} (hx₀ : x ≠ 0) :
  Squarefree x ↔ ∀ (p : R), Irreducible p → ¬p * p ∣ x := by
  sorry

theorem pilot_p083 {V : Type u} {G : SimpleGraph V} (C : G.ConnectedComponent)
  {u v : V} (hu : u ∈ C) (hv : v ∈ C) : C.toSimpleGraph.Adj ⟨u, hu⟩ ⟨v, hv⟩ ↔ G.Adj u v := by
  sorry

theorem pilot_p085 {α : Type u_2} {β : Type u_4} [TopologicalSpace α] [One β]
  [TopologicalSpace β] {f : α → β} {s : Set α} (hs : ContinuousOn f s) (h's : IsOpen s) (h''s : mulTSupport f ⊆ s) :
  Continuous f := by
  sorry

theorem pilot_p086 {R : Type u_1} [Ring R] {M : Type u_2} [TopologicalSpace M] [AddCommGroup M]
  [_root_.Module R M] {p q : Submodule R M} (h : Submodule.IsTopCompl p q) (x : M) : (p.projectionL q h) x ∈ p := by
  sorry

theorem pilot_p087 {F : Type u} [Field F] {W : WeierstrassCurve.Projective F}
  {P : Fin 3 → F} (hPz : P 2 ≠ 0) : W.Equation P ↔ W.toAffine.Equation (P 0 / P 2) (P 1 / P 2) := by
  sorry

theorem pilot_p088 {R : Type u_1} [CommSemiring R] (q : ℕ) (f : PowerSeries R) :
  ((ArithmeticFunction.ofPowerSeries q) f) 1 = PowerSeries.constantCoeff f := by
  sorry

theorem pilot_p089 {X : Type u_1} {F : Set X} (T : X → X) (h : F.Nonempty) (U : SetRel X X) :
  Dynamics.netMaxcard T F U 0 = 1 := by
  sorry

theorem pilot_p090 {k G : Type u} [CommRing k] [Group G] {A : Rep k G} (n : ℕ) :
  groupHomology.cyclesMap (MonoidHom.id G) (CategoryTheory.CategoryStruct.id A) n =
    CategoryTheory.CategoryStruct.id (groupHomology.cycles A n) := by
  sorry

theorem pilot_p091 (X : TopCat) :
  CategoryTheory.CategoryStruct.comp SSet.ι₀
      (CategoryTheory.CategoryStruct.comp
        (CategoryTheory.MonoidalCategoryStruct.whiskerLeft (TopCat.toSSet.obj X) SSet.stdSimplex.toSSetObjI)
        (CategoryTheory.Functor.LaxMonoidal.μ TopCat.toSSet X TopCat.I)) =
    TopCat.toSSet.map TopCat.ι₀ := by
  sorry

theorem pilot_p092 {X : Type u_1} {Y : Type u_2} [TopologicalSpace X]
  [TopologicalSpace Y] (e : OpenPartialHomeomorph X Y) (s : Set X) : e.source ∩ ↑e ⁻¹' ↑e.symm ⁻¹' s = e.source ∩ s := by
  sorry

theorem pilot_p094 (x : ↑unitInterval) : Subtype.val ⁻¹' Set.Ici ↑x = Set.Icc x 1 := by
  sorry

theorem pilot_p096 {G : Type u_1} [Group G] {X : Type u_2} [MulAction G X]
  {B : Set X} : MulAction.IsBlock G B ↔ ∀ ⦃g : G⦄, g • B ≠ B → Disjoint (g • B) B := by
  sorry

theorem pilot_p097 {C : Type u₁}
  [CategoryTheory.Category C] {D : Type u₂} [CategoryTheory.Category D] (J : Type w) [CategoryTheory.Category J]
  (F : CategoryTheory.Functor Cᵒᵖ D) [CategoryTheory.Limits.PreservesLimitsOfShape Jᵒᵖ F.rightOp] :
  CategoryTheory.Limits.PreservesColimitsOfShape J F := by
  sorry

theorem pilot_p098 {n d : ℕ}
  (s : (SSet.stdSimplex.obj { len := n }).obj (Opposite.op { len := d })) (i : Fin (d + 1)) :
  ((CategoryTheory.ConcreteCategory.hom ((SSet.stdSimplex.isoNerve n).hom.app (Opposite.op { len := d }))) s).obj i =
    { down := s i } := by
  sorry

theorem pilot_p099 {α : Type u_1} [FinEnum α] [Nonempty α] : 0 < FinEnum.card α := by
  sorry

theorem pilot_p100 {k G : Type u} [CommRing k] [Group G] (A : Rep k G) :
  CategoryTheory.CategoryStruct.comp (groupHomology.toCycles A 2 1) (groupHomology.isoCycles₁ A).hom =
    CategoryTheory.CategoryStruct.comp (groupHomology.chainsIso₂ A).hom
      (groupHomology.shortComplexH1 A).moduleCatLeftHomologyData.f' := by
  sorry

theorem pilot_p101 {α : Type u_1} [DecidableEq α] [Fintype α] {𝒜 : Finset (Finset α)} :
  𝒜.compls.shadow = 𝒜.upShadow.compls := by
  sorry

theorem pilot_p103 {C : Type u_1}
  [CategoryTheory.Category C] {X : CategoryTheory.SimplicialObject C} (s : X.Splitting) [CategoryTheory.Preadditive C] :
  CategoryTheory.CategoryStruct.comp s.toKaroubiNondegComplexIsoN₁.hom.f AlgebraicTopology.DoldKan.PInfty =
    s.toKaroubiNondegComplexIsoN₁.hom.f := by
  sorry

theorem pilot_p104 (t : ℝ) :
  (starRingEnd ℂ) (completedRiemannZeta (1 / 2 + ↑t * Complex.I)) = completedRiemannZeta (1 / 2 + ↑t * Complex.I) := by
  sorry

theorem pilot_p105 {A : Type u_1}
  [CategoryTheory.Category A] [CategoryTheory.Abelian A] {X : A} {n : ℕ} [CategoryTheory.EnoughProjectives A] :
  (CategoryTheory.isProjective A).hasFiniteResolutionOfLength n X ↔ CategoryTheory.HasProjectiveDimensionLE X n := by
  sorry

theorem pilot_p106 {𝕜 : Type u} {E : Type wE} {F : Type wF}
  {ι : Type v} [NontriviallyNormedField 𝕜] [SeminormedAddCommGroup E] [NormedSpace 𝕜 E] [SeminormedAddCommGroup F]
  [NormedSpace 𝕜 F] [Fintype ι] {f : E [⋀^ι]→L[𝕜] F} {m : ι → E} {C : ℝ} {b : ι → ℝ} (hC : ‖f‖ ≤ C)
  (hm : ∀ (i : ι), ‖m i‖ ≤ b i) : ‖f m‖ ≤ C * ∏ i, b i := by
  sorry

theorem pilot_p108 {α : Type u} [LE α] [Mul α] [c : MulRightMono α] : MulRightMono αᵒᵈ := by
  sorry

theorem pilot_p109 {α : Type u_1} {β : Type u_2} [Field α] [LinearOrder α] [IsStrictOrderedRing α] [Ring β]
  {abv : β → α} [IsAbsoluteValue abv] {f : ℕ → β} (hf : IsCauSeq abv f) (x : α) : ∃ r > x, ∀ (i : ℕ), abv (f i) < r := by
  sorry

theorem pilot_p111 {α : Type u_2} [Preorder α] {s : Set α}
  (hs : ∀ (x : α), ∃ y ∈ s, x ≤ y) : Filter.atTop = Filter.generate (Set.Ici '' s) := by
  sorry

theorem pilot_p112 {X : _root_.SSet} {A : X.Subcomplex} {P : A.Pairing}
  {α : Type v} [PartialOrder α] [WellFoundedLT α] (f : P.RankFunction α) : WellFounded P.AncestralRel := by
  sorry

theorem pilot_p113 {Ω : Type u_1} {mΩ : MeasurableSpace Ω} {B : NNReal → Ω → ℝ}
  {P : MeasureTheory.Measure Ω} (hB : ProbabilityTheory.IsPreBrownianReal B P) (t₀ : NNReal) :
  ProbabilityTheory.IndepFun (fun ω t => B (t₀ + t) ω - B t₀ ω) (fun ω t => B (↑t) ω) P := by
  sorry

theorem pilot_p117 {S : Type u_1} {T : Type u_2} {Ω : Type u_3}
  {E : Type u_4} {mΩ : MeasurableSpace Ω} {P : MeasureTheory.Measure Ω} {X : T → Ω → E} [NormedAddCommGroup E]
  [MeasurableSpace E] [BorelSpace E] [NormedSpace ℝ E] [SecondCountableTopology E]
  (h : ProbabilityTheory.IsGaussianProcess X P) (f : S → T) : ProbabilityTheory.IsGaussianProcess (X ∘ f) P := by
  sorry

theorem pilot_p118
  {X Y : AlgebraicGeometry.Scheme} (f : X ⟶ Y) (𝒰 : Y.OpenCover)
  (𝒱 : (i : 𝒰.I₀) → (CategoryTheory.Limits.pullback f (𝒰.f i)).OpenCover)
  [∀ (i : 𝒰.I₀), AlgebraicGeometry.IsAffine (𝒰.X i)]
  [∀ (i : 𝒰.I₀) (j : (𝒱 i).I₀), AlgebraicGeometry.IsAffine ((𝒱 i).X j)] :
  AlgebraicGeometry.IsClosedImmersion
    (CategoryTheory.Limits.pullback.diagonal f ∣_ AlgebraicGeometry.Scheme.Pullback.diagonalCoverDiagonalRange f 𝒰 𝒱) := by
  sorry

theorem pilot_p119 {ι : Type u_1} {α : ι → Type u_2} [(i : ι) → Zero (α i)] [LT ι] [(i : ι) → LT (α i)]
  {a b : Lex (Π₀ (i : ι), α i)} : a < b ↔ ∃ i, (∀ j < i, (ofLex a) j = (ofLex b) j) ∧ (ofLex a) i < (ofLex b) i := by
  sorry

theorem pilot_p120 {basis basis' : Tactic.ComputeAsymptotics.Basis}
  (h : List.Sublist basis basis') (h_basis : Tactic.ComputeAsymptotics.WellFormedBasis basis') :
  Tactic.ComputeAsymptotics.WellFormedBasis basis := by
  sorry

theorem pilot_p121 {J : Type u} [CategoryTheory.Category J] {X : J}
  (hX : CategoryTheory.Limits.IsTerminal X) (κ : Cardinal) [Fact κ.IsRegular] : CategoryTheory.IsCardinalFiltered J κ := by
  sorry

theorem pilot_p123 {X : Type u} [TopologicalSpace X] {α : Type u_1} {F : Filter α} {u : α → X} {x : X}
  (h : MapClusterPt x F u) {p : X → Prop} (hp : ∀ᶠ (y : X) in nhds x, p y) : ∃ᶠ (a : α) in F, p (u a) := by
  sorry

theorem pilot_p124 {α : Type u_1} {β : Type u_2} {e e' : PartialEquiv α β}
  (he : e ≈ e') (s : Set β) : e.source ∩ ↑e ⁻¹' s = e'.source ∩ ↑e' ⁻¹' s := by
  sorry

theorem pilot_p125 {𝕜 : Type u_1} {E : Type u_2} [RCLike 𝕜] [SeminormedAddCommGroup E]
  [InnerProductSpace 𝕜 E] {𝕝 : Type u_4} [CommSemiring 𝕝] [StarRing 𝕝] [Algebra 𝕝 𝕜] [_root_.Module 𝕝 E]
  [IsScalarTower 𝕝 𝕜 E] [StarModule 𝕝 𝕜] (x y : E) (r : 𝕝) :
  Inner.inner 𝕜 (r • x) y = (starRingEnd 𝕝) r • Inner.inner 𝕜 x y := by
  sorry

theorem pilot_p127 {ι : Type u_1} {α : Type u_2} {s : ι → Set α}
  (hs : IndexedPartition s) {β : Type u_3} (f : ι → α → β) (t : Set β) : hs.piecewise f ⁻¹' t = ⋃ i, s i ∩ f i ⁻¹' t := by
  sorry

theorem pilot_p129 {V : Type u_1} {G : SimpleGraph V} {u v : V} :
  G.IsEdgeReachable ⊤ u v ↔ ∀ ⦃s : Set (Sym2 V)⦄, s.Finite → (G.deleteEdges s).Reachable u v := by
  sorry

theorem pilot_p131 {ι : Type u_1} {σ : Type u_2} {R : Type u_4} [AddCommMonoid ι] [LinearOrder ι]
  [IsOrderedAddMonoid ι] [DecidableEq ι] [Semiring R] [SetLike σ R] [AddSubmonoidClass σ R] {A : ι → σ}
  [SetLike.GradedMonoid A] [CanonicallyOrderedAdd ι] {l : List ((DirectSum ι fun i => ↥(A i)) × ι)}
  (hl : ∀ xn ∈ l, ∀ k < xn.2, xn.1 k = 0) ⦃n : ι⦄ (hn : n < (List.map Prod.snd l).sum) :
  (List.map Prod.fst l).prod n = 0 := by
  sorry

theorem pilot_p132 {R : Type u_1} {n : Type u_2} [Fintype n] [DecidableEq n]
  [Semiring R] [PartialOrder R] [IsOrderedRing R] {M : Matrix n n R} {x : n → R} (hM : M ∈ Matrix.rowStochastic R n)
  (hx : ∀ (i : n), 0 ≤ x i) (j : n) : 0 ≤ Matrix.vecMul x M j := by
  sorry

theorem pilot_p133 {T : Type u_1} {N : Type u_2} (r : ContextFreeRule T N)
  (p q : List (Symbol T N)) : r.Rewrites (p ++ [Symbol.nonterminal r.input] ++ q) (p ++ r.output ++ q) := by
  sorry

theorem pilot_p134 {α : Type u_2} {f : Equiv.Perm α} {x y : α} :
  f.SameCycle x ((Equiv.symm f) y) ↔ f.SameCycle x y := by
  sorry

theorem pilot_p135 {R : Type u} {S : Type v} [CommRing R] [CommRing S] [Algebra R S]
  {A B : Subalgebra R S} (H : A.LinearDisjoint B) (H' : A ⊔ B = ⊤) [Module.Free R ↥B] [Module.Finite R ↥B] (x : ↥B) :
  (Algebra.norm ↥A) ((Algebra.algebraMap (↥B) S) x) = (Algebra.algebraMap R ↥A) ((Algebra.norm R) x) := by
  sorry

theorem pilot_p136 {M : Type u_2} {α : Type u_4} [CommMonoid M] [MeasurableSpace M]
  [MeasurableMul₂ M] {m : MeasurableSpace α} {μ : MeasureTheory.Measure α} (s : Multiset (α → M))
  (hs : ∀ f ∈ s, AEMeasurable f μ) : AEMeasurable (fun x => (Multiset.map (fun f => f x) s).prod) μ := by
  sorry

theorem pilot_p137 {α : Type u_1} [MeasurableSpace α] [Div α] [DiscreteMeasurableSpace α] :
  MeasurableDiv α := by
  sorry

theorem pilot_p140 {C : Type u₁} [CategoryTheory.Category C]
  {J : Type u} [CategoryTheory.Category J] {F : CategoryTheory.Functor J C} {c : CategoryTheory.Limits.Cone F}
  (hc : CategoryTheory.Limits.IsLimit c) (X : J) (hX : CategoryTheory.Limits.IsInitial X) :
  CategoryTheory.IsIso (c.π.app X) := by
  sorry

theorem pilot_p142 {α β γ : Type u} {t : Type u → Type u} [Traversable t] [LawfulTraversable t]
  {m : Type u → Type u} [Monad m] [LawfulMonad m] (g : β → γ) (f : α → γ → m α) (a : α) (l : t β) :
  Traversable.foldlM f a (g <$> l) = Traversable.foldlM (fun x y => f x (g y)) a l := by
  sorry

theorem pilot_p143 {ι : Type u_1} {α : Type u_2} {β : Type u_3} [LinearOrder α] [Semifield β]
  [LinearOrder β] [IsStrictOrderedRing β] {s : Set ι} {f : ι → α} {g₁ g₂ : ι → β} (hg₁ : ∀ i ∈ s, 0 ≤ g₁ i)
  (hg₂ : ∀ i ∈ s, 0 < g₂ i) (h₁ : MonovaryOn f g₁ s) (h₂ : AntivaryOn f g₂ s) : MonovaryOn f (g₁ / g₂) s := by
  sorry

theorem pilot_p144 {b : EReal} (h : b < 0) (h' : b ≠ ⊥) : StrictAnti fun a => a / b := by
  sorry

theorem pilot_p145 {𝕜 : Type u_1} {ι : Type u_2} {E : Type u_3}
  {F : Type u_4} [NormedField 𝕜] [Finite ι] [SeminormedAddCommGroup E] [NormedSpace 𝕜 E] [TopologicalSpace F]
  [AddCommGroup F] [IsTopologicalAddGroup F] [_root_.Module 𝕜 F] : ContinuousEval (E [⋀^ι]→L[𝕜] F) (ι → E) F := by
  sorry

theorem pilot_p146 {α : Type u_2} {β : Type u_3} [SeminormedAddCommGroup α]
  [SeminormedAddCommGroup β] (x : WithLp 1 (α × β)) : ‖x‖₊ = ‖x.fst‖₊ + ‖x.snd‖₊ := by
  sorry

theorem pilot_p147 {R S : CommRingCat} (f : R ⟶ S) :
  AlgebraicGeometry.IsPreimmersion (AlgebraicGeometry.Spec.map f) ↔
    Topology.IsEmbedding (PrimeSpectrum.comap (CommRingCat.Hom.hom f)) ∧ (CommRingCat.Hom.hom f).SurjectiveOnStalks := by
  sorry

theorem pilot_p149 {P : CategoryTheory.MorphismProperty AlgebraicGeometry.Scheme}
  {Q : AlgebraicGeometry.AffineTargetMorphismProperty} [AlgebraicGeometry.HasAffineProperty P Q]
  {X Y : AlgebraicGeometry.Scheme} {f : X ⟶ Y} {UX UY : AlgebraicGeometry.Scheme} [AlgebraicGeometry.IsAffine UY]
  {iY : UY ⟶ Y} [AlgebraicGeometry.IsOpenImmersion iY] {iX : UX ⟶ X} {f' : UX ⟶ UY}
  (h : CategoryTheory.IsPullback iX f' f iY) (hf : P f) : Q f' := by
  sorry

theorem pilot_p150
  (S : LightProfinite) (p : ↑S.toTop → Prop) :
  CompHausLike.HasProp (fun X => TotallyDisconnectedSpace ↑X ∧ SecondCountableTopology ↑X) (Subtype p) := by
  sorry

theorem pilot_p151 {K : Type u} [Field K] (n : ℕ) (a : K) :
  AdjoinRoot.root (Polynomial.X ^ n - Polynomial.C a) ^ n = (AdjoinRoot.of (Polynomial.X ^ n - Polynomial.C a)) a := by
  sorry

theorem pilot_p152 (F : Type u) (E : Type v) [Field F] [Field E] [Algebra F E] (K : Type w) [Field K]
  [Algebra F K] [Algebra E K] [IsScalarTower F E K] [h1 : IsPurelyInseparable F E] [h2 : IsPurelyInseparable E K] :
  IsPurelyInseparable F K := by
  sorry

theorem pilot_p154 {α : Type u_1} {f : α → ℚ → ℝ}
  [MeasurableSpace α] (hf : ProbabilityTheory.IsMeasurableRatCDF f) (a : α) :
  Filter.Tendsto (↑(hf.stieltjesFunction a)) Filter.atBot (nhds 0) := by
  sorry

theorem pilot_p155 {ι : Type u_1} {α : Type u_2}
  [ConditionallyCompleteLinearOrder α] {s : Multiset ι} (f : ι → α) (h : ∃ x ∈ s, SupSet.sSup ∅ ≤ f x) :
  ⨆ x ∈ s, f x ∈ Multiset.map f s := by
  sorry

theorem pilot_p157 {F : CategoryTheory.Functor LightProfiniteᵒᵖ (Type u)}
  (hF :
    (S : LightProfinite) →
      CategoryTheory.Limits.IsColimit (F.mapCocone (CategoryTheory.Limits.coconeRightOpOfCone S.asLimitCone)))
  (S : LightProfiniteᵒᵖ) :
  (LightCondensed.lanPresheafNatIso hF).hom.app S =
    CategoryTheory.Limits.colimit.desc
      ((CategoryTheory.CostructuredArrow.proj FintypeCat.toLightProfinite.op (Opposite.op (Opposite.unop S))).comp
        (FintypeCat.toLightProfinite.op.comp F))
      (LightProfinite.Extend.cocone F (Opposite.unop S)) := by
  sorry

theorem pilot_p158 {C : Type u₁} [CategoryTheory.Category C]
  {D : Type u₂} [CategoryTheory.Category D] (F : CategoryTheory.Functor Cᵒᵖ Dᵒᵖ)
  [CategoryTheory.Limits.PreservesFiniteLimits F] : CategoryTheory.Limits.PreservesFiniteColimits F.unop := by
  sorry

theorem pilot_p159 {k G : Type u} [CommRing k] [Group G] {A : Rep k G} (g : G)
  (a : ↑A) (ha : a ∈ A.ρ.invariants) : (fun₀ | g => a) ∈ groupHomology.cycles₁ A := by
  sorry

theorem pilot_p160 {X Y : AlgebraicGeometry.Scheme} (f : X ⟶ Y) [IsEmpty ↥X] :
  AlgebraicGeometry.IsOpenImmersion f := by
  sorry

theorem pilot_p162 {R : Type u_1} {M : Type u_2} [DivisionRing R] [LinearOrder R]
  [IsOrderedRing R] [AddCommGroup M] [_root_.Module R M] {C F : PointedCone R M} (h₁ : F ≤ C)
  (h₂ : ∀ {x y : M}, x ∈ C → y ∈ C → x + y ∈ F → x ∈ F) : F.IsFaceOf C := by
  sorry

theorem pilot_p163 {F : Type u_1} [Field F] [DecidableEq F] (v : Projectivization F (Fin 3 → F)) :
  v.cross v = v := by
  sorry

theorem pilot_p164 (G : Type u_2) [LinearOrderedCommGroupWithZero G]
  [Nontrivial Gˣ] [MulArchimedean G] : Nonempty (G ≃*o WithZero (Multiplicative ℤ)) ∨ DenselyOrdered G := by
  sorry

theorem pilot_p165 {R : Type u₁} {S : Type u₂} [CommRing R]
  [CommRing S] [Algebra R S] {T : Type u₃} [CommRing T] [Algebra R T] [Algebra S T] [IsScalarTower R S T] {ι : Type w₁}
  {σ : Type w₂} {τ : Type w₅} (Q : Algebra.Generators S T ι) (P : Algebra.Generators R S σ)
  (W : Algebra.Generators R T τ) (f : W.Hom Q) :
  Function.Exact ⇑(Algebra.Extension.H1Cotangent.map f.toExtensionHom) ⇑(Algebra.Generators.H1Cotangent.δ Q P) := by
  sorry

theorem pilot_p166 {X : Type u_1} {Y : Type u_2} [TopologicalSpace X]
  [TopologicalSpace Y] {e e' : OpenPartialHomeomorph X Y} (h : Set.EqOn (↑e) (↑e') (e.source ∩ e'.source)) :
  e.restr e'.source ≈ e'.restr e.source := by
  sorry

theorem pilot_p167 {X : Type u_1} {Y : Type u_2} [TopologicalSpace X] {f : X → Y} [Preorder X]
  [TopologicalSpace Y] [Zero Y] [Inv Y] [ContinuousInv₀ Y] (hf : IsRightContinuous f) (h : ∀ (x : X), f x ≠ 0) :
  IsRightContinuous f⁻¹ := by
  sorry

theorem pilot_p168 {R : Type u_1} {M : Type u_3} {N : Type u_4} {M' : Type u_6}
  {N' : Type u_7} [CommSemiring R] [AddCommMonoid M] [_root_.Module R M] [AddCommMonoid N] [_root_.Module R N]
  [AddCommMonoid M'] [_root_.Module R M'] [AddCommMonoid N'] [_root_.Module R N'] (f : M →ₗ[R] M') (g : N →ₗ[R] N') :
  ↑(TensorProduct.comm R M' N') ∘ₗ TensorProduct.map f g = TensorProduct.map g f ∘ₗ ↑(TensorProduct.comm R M N) := by
  sorry

theorem pilot_p169 {M : Type u_1} {N : Type u_2} [MulOneClass M] [MulOneClass N] {F : Type u_4}
  [FunLike F M N] [mc : MonoidHomClass F M N] {f : F} {S : Submonoid N} (h : S ≤ MonoidHom.mrange f) :
  Submonoid.map f (Submonoid.comap f S) = S := by
  sorry

theorem pilot_p170 {α : Type u_1} {β : Type u_2} {σ : Type u_4} {φ : Type u_5} {n : ℕ}
  {x : α} {y : β} {s : σ} (xs : List.Vector α n) (ys : List.Vector β n) {f : α → β → σ → σ × φ} :
  List.Vector.mapAccumr₂ f (x ::ᵥ xs) (y ::ᵥ ys) s =
    have r := List.Vector.mapAccumr₂ f xs ys s;
    have q := f x y r.1;
    (q.1, q.2 ::ᵥ r.2) := by
  sorry

theorem pilot_p171 {C : Type u} [CategoryTheory.Category C] {D : Type u''}
  [CategoryTheory.Category D] [CategoryTheory.Limits.HasPullbacks C] [CategoryTheory.FinitaryExtensive C] :
  CategoryTheory.FinitaryExtensive (CategoryTheory.Functor D C) := by
  sorry

theorem pilot_p173 {V : Type u_1} [CategoryTheory.Category V]
  {W : Type u_2} [CategoryTheory.Category W] (F : CategoryTheory.Functor V W) (G : Type u_3) [Monoid G] [F.Faithful] :
  (F.mapAction G).Faithful := by
  sorry

theorem pilot_p174 {𝕜 : Type u_1} [NontriviallyNormedField 𝕜] {E : Type u_2}
  [NormedAddCommGroup E] [NormedSpace 𝕜 E] [NormedSpace ℝ E] [h : IsRCLikeNormedField 𝕜] {s : Set E} (hs : Convex ℝ s) :
  Convex ℝ s := by
  sorry

theorem pilot_p175 (F : Type u) (E : Type v) [Field F] [Field E] [Algebra F E]
  {S : Set E} : Algebra.IsSeparable F ↥(IntermediateField.adjoin F S) ↔ ∀ x ∈ S, IsSeparable F x := by
  sorry

theorem pilot_p176 {X : Type u_1} [TopologicalSpace X] [ContractibleSpace X] :
  PathConnectedSpace X := by
  sorry

theorem pilot_p178 {C : Type u} [CategoryTheory.Category C] {f g : C} (η : f ⟶ g) :
  η =
    CategoryTheory.CategoryStruct.comp (CategoryTheory.Iso.refl f).hom
      (CategoryTheory.CategoryStruct.comp η (CategoryTheory.Iso.refl g).hom) := by
  sorry

theorem pilot_p180 {b : NNReal} (hb : 0 < b) : ∃ n, 0 < n ∧ (↑n)⁻¹ < b := by
  sorry

theorem pilot_p182 : (compHausToTop.op.comp topCatOpToFrm).Faithful := by
  sorry

theorem pilot_p183 {R : Type u_1} [NonAssocRing R] [LinearOrder R] [IsOrderedAddMonoid R] [Archimedean R]
  {p : R} (hp : 0 < p) (a b : R) (m : ℤ) : toIocMod hp a (↑m * p + b) = toIocMod hp a b := by
  sorry

theorem pilot_p184 {R : Type u} [CommRing R] {S : Type v}
  [CommRing S] [Algebra R S] [IsDedekindDomain S] [IsDomain R] [Module.IsTorsionFree R S] {S₀ : Type u_2} [CommRing S₀]
  [Algebra R S₀] [Algebra S₀ S] [IsScalarTower R S₀ S] (p : Ideal R) (P : Ideal S₀) (Q : Ideal S) [Q.LiesOver p]
  [hP : P.LiesOver p] [Q.IsPrime] (hp : p ≠ ⊥) : P.ramificationIdx' Q ≤ p.ramificationIdx' Q := by
  sorry

theorem pilot_p185 {α : Type u_1} {M : Matroid α} {X : Set α} (h : M.IsRkFinite X) :
  ∃ I, M.IsBasis' I X ∧ I.Finite := by
  sorry

theorem pilot_p186 (z : UpperHalfPlane) : UpperHalfPlane.denom 1 ↑z = 1 := by
  sorry

theorem pilot_p188 {G : Type u_1} {α : Type u_2} [Group G] [MulAction G α] {g : G}
  {x : MulAction.orbitRel.Quotient G α} {a : ↑x.orbit} : ↑(g • a) = g • ↑a := by
  sorry

theorem pilot_p189 {R : Type u} [LinearOrder R] [AddMonoid R] [AddLeftMono R] [AddRightMono R]
  (x y : MinTropical R) (n : ℕ) : (x + y) ^ n = x ^ n + y ^ n := by
  sorry

theorem pilot_p190 (x : ZFSet) : x.rank ≤ Order.succ x.sUnion.rank := by
  sorry

theorem pilot_p191
  {L : FirstOrder.Language} {α : Type u'} {n : ℕ} {M : Type u_1} [L.Structure M] {N : Type u_2} [L.Structure N]
  {F : Type u_3} [FunLike F M N] {φ : L.BoundedFormula α n} (hA : φ.IsAtomic) [L.HomClass F M N] {f : F}
  (hInj : Function.Injective ⇑f) {v : α → M} {xs : Fin n → M} : φ.Realize v xs → φ.Realize (⇑f ∘ v) (⇑f ∘ xs) := by
  sorry

theorem pilot_p192 {α : Type u_1} [LE α] :
  CanLift (α × α) (NonemptyInterval α) NonemptyInterval.toProd fun x => x.1 ≤ x.2 := by
  sorry

theorem pilot_p193 {C : Type u₁} [CategoryTheory.Category C]
  {α : Type u_1} {Z : α → C} {f f' : CategoryTheory.Limits.Fan Z}
  {c : CategoryTheory.Limits.Cofan fun x => Opposite.op (Z x)} (hf : CategoryTheory.Limits.IsLimit f)
  (hf' : CategoryTheory.Limits.IsLimit f') (hc : CategoryTheory.Limits.IsColimit c) :
  CategoryTheory.CategoryStruct.comp (CategoryTheory.Limits.opProductIsoCoproduct' hf hc).hom
      (CategoryTheory.Limits.opProductIsoCoproduct' hf' hc).inv =
    (hf.conePointUniqueUpToIso hf').op.inv := by
  sorry

theorem pilot_p194 {M : Type u_1} {α : Type u_3} [Monoid M] [MulAction M α] (a : α) :
  (MulAction.orbit M a).Nonempty := by
  sorry

theorem pilot_p195 {R : Type u_2} {M : Type u_4} [Semiring R] [AddCommMonoid M]
  [_root_.Module R M] {G : Type u_6} [Group G] [DistribMulAction G M] [SMulCommClass G R M] (a : G) (s : Set M) :
  LinearIndepOn R id (a • s) ↔ LinearIndepOn R id s := by
  sorry

theorem pilot_p196 {f : Ordinal → Ordinal} (hf : Order.IsNormal f) : Ordinal.veblenWith f 1 = Ordinal.deriv f := by
  sorry

theorem pilot_p198 {α : Type u_1} {n : ℕ} (v : List.Vector α n) : v.toList.length = n := by
  sorry

theorem pilot_p199 {α : Type u_1} [DecidableEq α] {a : α} {s : Finset α} (h : a ∉ s) : s ∩ {a} = ∅ := by
  sorry

theorem pilot_p200 {R : Type u} {S : Type v} [CommRing R] [CommRing S]
  [Algebra R S] (P : Algebra.Extension R S) {R₀ : Type u_1} [CommRing R₀] [Algebra R₀ R] [Algebra R₀ S]
  [IsScalarTower R₀ R S] : IsScalarTower R₀ P.Ring S := by
  sorry

theorem pilot_p201 {S : Type u_1} [SeminormedGroup S] [IsUltrametricDist S]
  {x y : S} (h : ‖x‖₊ ≠ ‖y‖₊) : ‖x * y‖₊ = Max.max ‖x‖₊ ‖y‖₊ := by
  sorry

theorem pilot_p203 {α : Type u_1} [DecidableEq α] [Fintype α] (s : Finset α) :
  s.card + sᶜ.card = Fintype.card α := by
  sorry

theorem pilot_p204 {𝕜 : Type u_1} {E : Type u_2} [RCLike 𝕜] [NormedAddCommGroup E]
  [NormedSpace 𝕜 E] [CompleteSpace E] {f : 𝕜 → E} {s : Set 𝕜} (hs : Convex ℝ s) (hf : DifferentiableOn 𝕜 f s) :
  ∃ g, ∀ a ∈ s, HasDerivWithinAt g (f a) s a := by
  sorry

theorem pilot_p206 {K : Type u_1} [Field K] [NumberField K]
  (x : NumberField.mixedEmbedding.mixedSpace K) :
  NumberField.mixedEmbedding.convexBodySumFun (-x) = NumberField.mixedEmbedding.convexBodySumFun x := by
  sorry

theorem pilot_p001 (A : Type u_3) [CategoryTheory.Category A]
  [CategoryTheory.Abelian A] : (HomotopyCategory.Plus.quasiIso A).IsCompatibleWithShift ℤ := by
  sorry

theorem pilot_p095 {C : Type u₁} [CategoryTheory.Category C]
  {D : Type u₂} [CategoryTheory.Category D] {J : Type w} [CategoryTheory.Category J] (K : CategoryTheory.Functor J Cᵒᵖ)
  (F : CategoryTheory.Functor C D) [CategoryTheory.Limits.PreservesLimit K.leftOp F] :
  CategoryTheory.Limits.PreservesColimit K F.op := by
  sorry

theorem pilot_p110 {X Y Z : Type u} [DistribLattice X] [BoundedOrder X] [Fintype X] [DistribLattice Y]
  [BoundedOrder Y] [Fintype Y] [DistribLattice Z] [BoundedOrder Z] [Fintype Z] (f : BoundedLatticeHom X Y)
  (g : BoundedLatticeHom Y Z) :
  FinBddDistLat.ofHom (g.comp f) = CategoryTheory.CategoryStruct.comp (FinBddDistLat.ofHom f) (FinBddDistLat.ofHom g) := by
  sorry

theorem pilot_p115 {s t : Finset ℕ} {n : ℕ} (hn : 2 ≤ n) :
  ∑ k ∈ s, n ^ k ≤ ∑ k ∈ t, n ^ k ↔ toColex s ≤ toColex t := by
  sorry

theorem pilot_p116 {α : Type u_1} {β : Type u_2} {r : α → α → Prop} {r' : β → β → Prop}
  (s : Set α) (e : r ↪r r') : (⇑e '' s).chainHeight r' = s.chainHeight r := by
  sorry

theorem pilot_p130 {V : Type u} {G : SimpleGraph V} {u : V} {n : ℕ} {p : G.Walk u u}
  (h : p.IsCycle) (hn : 0 < n) : (p.drop n).IsPath := by
  sorry

theorem pilot_p207 {A : Type u_1} [TopologicalSpace A] [Ring A] [StarRing A]
  [Algebra ℂ A] [ContinuousFunctionalCalculus ℂ A IsStarNormal] {u : A} :
  u ∈ unitary A ↔ IsStarNormal u ∧ spectrum ℂ u ⊆ ↑(unitary ℂ) := by
  sorry

theorem pilot_p208 {R : Type u_1} {M : Type u_2} {N : Type u_3} [Ring R]
  [AddCommGroup M] [_root_.Module R M] [TopologicalSpace M] [AddCommGroup N] [_root_.Module R N] [TopologicalSpace N]
  {n : ℕ} (f : M [⋀^Fin (n + 1)]→L[R] N) (x y : M) (v : Fin n → M) :
  f (Matrix.vecCons (x - y) v) = f (Matrix.vecCons x v) - f (Matrix.vecCons y v) := by
  sorry

theorem pilot_p210 {R : Type u_1} {S : Type u_2} [CommRing R] [CommRing S] [Algebra R S]
  [IsLocalRing R] [Module.Finite R S] [Module.Free R S] {ι : Type u_4} [Fintype ι] (b : Module.Basis ι R S) (x : S)
  (i : ι) :
  ((IsLocalRing.basisQuotient b).repr
        ((Ideal.Quotient.mk (Ideal.map (Algebra.algebraMap R S) (IsLocalRing.maximalIdeal R))) x))
      i =
    (Ideal.Quotient.mk (IsLocalRing.maximalIdeal R)) ((b.repr x) i) := by
  sorry

theorem pilot_p211 {α : Sort u_1} {r : α → α → Prop} [DecidableRel r] [Std.Refl r] :
  Std.Refl fun a b => Decidable.decide (r a b) = Bool.true := by
  sorry

theorem pilot_p212 {A : Type u_1} {B : Type u_2} [CommRing A] [CommRing B]
  [Algebra A B] [Module.Flat A B] (h : Function.Surjective (PrimeSpectrum.comap (Algebra.algebraMap A B))) :
  Module.FaithfullyFlat A B := by
  sorry

theorem pilot_p214 {C : Type u} [CategoryTheory.Category C]
  (P : CategoryTheory.MorphismProperty C) [P.HasPushouts] (P' : CategoryTheory.MorphismProperty C) :
  P.HasPushoutsAgainst P' := by
  sorry

theorem pilot_p215 {α : Type u_1} {mα : MeasurableSpace α}
  {μ ν : MeasureTheory.Measure α} (h1 : μ.AbsolutelyContinuous ν) (ν' : MeasureTheory.Measure α) :
  μ.AbsolutelyContinuous (ν + ν') := by
  sorry

theorem pilot_p217 {R : Type u_2} [Field R] [LinearOrder R] [IsStrictOrderedRing R] [Archimedean R]
  {p : R → Prop} (h : ∀ᶠ (x : R) in Filter.atTop, p x) : ∀ᶠ (n : ℚ) in Filter.atTop, p ↑n := by
  sorry

theorem pilot_p219 {α : Type u_1} {β : Type u_2} (e : PartialEquiv α β) :
  e.symm.trans e ≈ PartialEquiv.ofSet e.target := by
  sorry

theorem pilot_p221 :
  CategoryTheory.Limits.PreservesColimits AlgebraicGeometry.LocallyRingedSpace.forgetToSheafedSpace := by
  sorry

theorem pilot_p222 {α : Type u} {β : Type v} [Uncountable α] [Nonempty β] : Uncountable (α × β) := by
  sorry

theorem pilot_p223 (C D : Type u) [CategoryTheory.Category C]
  [CategoryTheory.Category D] :
  CategoryTheory.IsIso
    (CategoryTheory.Limits.prodComparison
      (CategoryTheory.nerveFunctor.comp (SSet.hoFunctor.comp CategoryTheory.nerveFunctor)) ↧C ↧D) := by
  sorry

theorem pilot_p225 {R : Type r} [CommRing R] {W' : WeierstrassCurve.Jacobian R}
  [NoZeroDivisors R] {P Q : Fin 3 → R} (hQz : Q 2 ≠ 0) (hx : P 0 * Q 2 ^ 2 = Q 0 * P 2 ^ 2)
  (hy : P 1 * Q 2 ^ 3 = Q 1 * P 2 ^ 3) (hy' : P 1 * Q 2 ^ 3 = W'.negY Q * P 2 ^ 3) : W'.negDblY P = (-W'.dblU P) ^ 3 := by
  sorry

theorem pilot_p226 {L : FirstOrder.Language} {α : Type u'} {n : ℕ}
  {φ : L.BoundedFormula α (n + 1)} : FirstOrder.Language.BoundedFormula.sigmaAll ⟨n + 1, φ⟩ = ⟨n, φ.all⟩ := by
  sorry

theorem pilot_p227 {c : Cardinal} {n : ℕ} [n.AtLeastTwo] :
  c.lift ≤ Cardinal.beth (OfNat.ofNat n) ↔ c ≤ Cardinal.beth (OfNat.ofNat n) := by
  sorry

theorem pilot_p228 {k : Type u_1} {V : Type u_2} {P : Type u_3} [Ring k]
  [AddCommGroup V] [_root_.Module k V] [AddTorsor V P] {s₁ s₂ : AffineSubspace k P} {p : P} (hp₁ : p ∈ s₁)
  (hp₂ : p ∈ s₂) : (s₁ ⊔ s₂).direction = s₁.direction ⊔ s₂.direction := by
  sorry

theorem pilot_p229 {p : Polynomial ℤ} (hp : p ≠ 0) :
  1 ≤ (Polynomial.map (Int.castRingHom ℂ) p).mahlerMeasure := by
  sorry

theorem pilot_p230 {ι : Type u_1} {R : Type u_4} [CommSemiring R] {s : ι → Type u_7}
  [(i : ι) → AddCommMonoid (s i)] [(i : ι) → _root_.Module R (s i)] {x y : PiTensorProduct R fun i => s i}
  {p q : FreeAddMonoid (R × ((i : ι) → s i))} (hp : p ∈ x.lifts) (hq : q ∈ y.lifts) : p + q ∈ (x + y).lifts := by
  sorry

theorem pilot_p232 {α : Type u_1} [Add α] [LE α] [OrderBot α] [Sub α] [OrderedSub α] : OrderedSub (WithTop α) := by
  sorry

theorem pilot_p233 (X : AlgebraicGeometry.Scheme) {U : X.Opens}
  (f g : ↑(X.presheaf.obj (Opposite.op U))) : X.basicOpen (f + g) ≤ X.basicOpen f ⊔ X.basicOpen g := by
  sorry

theorem pilot_p234 {a b c : Ordinal} (hc : Order.IsSuccLimit c) : a < b + c ↔ ∃ d < c, a < b + d := by
  sorry

theorem pilot_p235 {F : Type u} [Field F] {W : WeierstrassCurve.Jacobian F}
  {P : Fin 3 → F} (hPz : P 2 ≠ 0) :
  (MvPolynomial.eval P) W.polynomialX / P 2 ^ 4 =
    Polynomial.evalEval (P 0 / P 2 ^ 2) (P 1 / P 2 ^ 3) W.toAffine.polynomialX := by
  sorry

theorem pilot_p236 {b : ℕ} (l : List ℕ) : Nat.ofDigits b (l ++ [0]) = Nat.ofDigits b l := by
  sorry

theorem pilot_p237
  (P : CategoryTheory.MorphismProperty AlgebraicGeometry.Scheme) [AlgebraicGeometry.IsZariskiLocalAtTarget P] :
  AlgebraicGeometry.HasAffineProperty P (AlgebraicGeometry.AffineTargetMorphismProperty.of P) := by
  sorry

theorem pilot_p238 {α : Type u_1} {m0 : MeasurableSpace α} {μ : MeasureTheory.Measure α}
  {N : Set α} {f : α → ℝ} [MeasureTheory.IsProbabilityMeasure μ] (hf : MeasureTheory.Integrable f μ) (hN : μ N = 0) :
  ∃ x ∉ N, ∫ (a : α), f a ∂μ ≤ f x := by
  sorry

theorem pilot_p239 {α : Type u_1} {Ω : Type u_2} {ι : Type u_3}
  {β : Type u_4} {mα : MeasurableSpace α} {mΩ : MeasurableSpace Ω} {κ : ProbabilityTheory.Kernel α Ω}
  {μ : MeasureTheory.Measure α} [Zero β] [One β] {m : MeasurableSpace β} {s : ι → Set Ω}
  (hs : ProbabilityTheory.Kernel.iIndepSet s κ μ) :
  ProbabilityTheory.Kernel.iIndepFun (fun n => (s n).indicator fun _ω => 1) κ μ := by
  sorry

theorem pilot_p241 {c : Cardinal} : Cardinal.aleph 1 < c.lift ↔ Cardinal.aleph 1 < c := by
  sorry

theorem pilot_p242 {n : ℕ} {c : ℂ} :
  Polynomial.toAddCircle ((Polynomial.monomial n) c) = c • fourier ↑n := by
  sorry

