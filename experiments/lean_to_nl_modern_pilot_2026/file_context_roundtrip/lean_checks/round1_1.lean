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


-- p060
theorem pilot_p060 {C : Type u₁} [CategoryTheory.Category C] {J : Type u}
  [CategoryTheory.Category J] [CategoryTheory.Limits.HasTerminal J] (F : CategoryTheory.Functor J C)
  [∀ (i j : J) (f : i ⟶ j), CategoryTheory.IsIso (F.map f)] :
  CategoryTheory.IsIso (CategoryTheory.Limits.limit.π F (⊤_ J)) := by sorry
open CategoryTheory in theorem rt_p060 {C : Type u_1} [Category.{v_1} C] {J : Type u_2} [Category.{v_2} J] [CategoryTheory.Limits.HasTerminal J] (F : J ⥤ C) [∀ (i j : J) (φ : i ⟶ j), IsIso (F.map φ)] : IsIso (CategoryTheory.Limits.limit.π F (CategoryTheory.Limits.terminal J)) := by sorry
#rt pilot_p060 rt_p060

-- p061
theorem pilot_p061 {R : Type u_1} {S : Type u_2} [CommRing R]
  [CommRing S] [IsDomain R] [Algebra R S] [IsIntegrallyClosed R] [IsDomain S] [Module.IsTorsionFree R S] {s : S}
  {p : Polynomial R} (hp : (Polynomial.aeval s) p = 0) (h₀ : p ≠ 0)
  (pmin : ∀ (q : Polynomial R), q.Monic → (Polynomial.aeval s) q = 0 → p.degree ≤ q.degree) :
  IsIntegral R s ↔ Polynomial.C p.leadingCoeff ∣ p := by sorry
theorem rt_p061 {R : Type u} {S : Type v} [CommRing R] [CommRing S] [IsDomain R] [IsDomain S] [Algebra R S] [IsIntegrallyClosed R] [Module.IsTorsionFree R S] (s : S) (p : Polynomial R) (hp : p ≠ 0) (hps : Polynomial.aeval s p = 0) (hmin : ∀ q : Polynomial R, q.Monic → Polynomial.aeval s q = 0 → p.degree ≤ q.degree) : IsIntegral R s ↔ Polynomial.C p.leadingCoeff ∣ p := by sorry
#rt pilot_p061 rt_p061

-- p063
theorem pilot_p063 {n : Type u} (S : AlgebraicGeometry.Scheme)
  [AlgebraicGeometry.IsAffine S] :
  CategoryTheory.CategoryStruct.comp (AlgebraicGeometry.AffineSpace.isoOfIsAffine n S).inv
      (AlgebraicGeometry.AffineSpace n S ↘ S) =
    CategoryTheory.CategoryStruct.comp (AlgebraicGeometry.Spec.map (CommRingCat.ofHom MvPolynomial.C)) S.isoSpec.inv := by sorry
open AlgebraicGeometry CategoryTheory in theorem rt_p063 (n : Type u) (S : Scheme.{u}) [IsAffine S] : (AffineSpace.isoOfIsAffine n S).inv ≫ CategoryTheory.Limits.pullback.fst _ _ = Spec.map (CommRingCat.ofHom (MvPolynomial.C : Γ(S, ⊤) →+* MvPolynomial n Γ(S, ⊤))) ≫ S.isoSpec.inv := by sorry
#rt pilot_p063 rt_p063

-- p064
theorem pilot_p064 {C : Type u_1} [CategoryTheory.Category C]
  {S₁ S₂ S₃ : CategoryTheory.SimplicialObject.Split C} (Φ₁₂ : S₁ ⟶ S₂) (Φ₂₃ : S₂ ⟶ S₃) :
  (CategoryTheory.CategoryStruct.comp Φ₁₂ Φ₂₃).F = CategoryTheory.CategoryStruct.comp Φ₁₂.F Φ₂₃.F := by sorry
open CategoryTheory in theorem rt_p064 {C : Type u_1} [Category.{v_1} C] {S₁ S₂ S₃ : CategoryTheory.SimplicialObject.Split C} (Φ₁₂ : S₁ ⟶ S₂) (Φ₂₃ : S₂ ⟶ S₃) : (Φ₁₂ ≫ Φ₂₃).F = Φ₁₂.F ≫ Φ₂₃.F := by sorry
#rt pilot_p064 rt_p064

-- p065
theorem pilot_p065 {α β : Sort u} {a : α} {b : β} : a ≍ b ↔ ∃ (h : α = β), cast h a = b := by sorry
theorem rt_p065 {α β : Sort u} (a : α) (b : β) : HEq a b ↔ ∃ h : α = β, cast h a = b := by sorry
#rt pilot_p065 rt_p065

-- p066
theorem pilot_p066 {C : Type u₁}
  [CategoryTheory.Category C] {D : Type u₂} [CategoryTheory.Category D] [CategoryTheory.Limits.HasZeroObject D]
  [CategoryTheory.Limits.HasZeroMorphisms D] (G : CategoryTheory.Functor C D) (hG : CategoryTheory.Limits.IsZero G)
  (J : Type u_1) [CategoryTheory.Category J] : CategoryTheory.Limits.PreservesColimitsOfShape J G := by sorry
open CategoryTheory CategoryTheory.Limits in theorem rt_p066 {C : Type u₁} {D : Type u₂} [Category.{v₁} C] [Category.{v₂} D] [HasZeroMorphisms D] [HasZeroObject D] (G : C ⥤ D) (hG : IsZero G) (J : Type u₃) [Category.{v₃} J] : PreservesColimitsOfShape J G := by sorry
#rt pilot_p066 rt_p066

-- p067
theorem pilot_p067 {S : Type u_1} {R : Type u} {M : Type v} [CommSemiring S]
  [Semiring R] [AddCommMonoid M] [Algebra S R] [_root_.Module S M] [_root_.Module R M] [_root_.Module Rᵐᵒᵖ M]
  [SMulCommClass R Rᵐᵒᵖ M] [IsScalarTower S R M] [IsScalarTower S Rᵐᵒᵖ M] :
  (TrivSqZeroExt.inlAlgHom S R M).range ⊔ Algebra.adjoin S (Set.range TrivSqZeroExt.inr) = ⊤ := by sorry
theorem rt_p067 (S : Type u) (R : Type v) (M : Type w) [CommSemiring S] [Semiring R] [AddCommMonoid M] [Algebra S R] [Module S M] [Module R M] [Module Rᵐᵒᵖ M] [SMulCommClass R Rᵐᵒᵖ M] [IsScalarTower S R M] [IsScalarTower S Rᵐᵒᵖ M] : (TrivSqZeroExt.inlAlgHom S R M).range ⊔ Algebra.adjoin S (Set.range (TrivSqZeroExt.inr : M → TrivSqZeroExt R M)) = ⊤ := by sorry
#rt pilot_p067 rt_p067

-- p069
theorem pilot_p069 {r : ℝ} (hr : r < 0) :
  Filter.Tendsto (fun x => Real.log x / x ^ r) (nhdsWithin 0 (Set.Ioi 0)) (nhds 0) := by sorry
theorem rt_p069 (r : ℝ) (hr : r < 0) : Filter.Tendsto (fun x : ℝ => Real.log x / Real.rpow x r) (nhdsWithin (0 : ℝ) (Set.Ioi 0)) (nhds 0) := by sorry
#rt pilot_p069 rt_p069

-- p070
theorem pilot_p070 {α : Type u_1} {β : Type u_2} [TopologicalSpace α] [TopologicalSpace β]
  [SemilatticeSup β] [ContinuousSup β] {ι : Type u_3} {s : Finset ι} (H : s.Nonempty) (f : ι → C(α, β)) :
  ⇑(s.sup' H f) = s.sup' H fun i => ⇑(f i) := by sorry
theorem rt_p070 {α : Type u_1} {β : Type u_2} {ι : Type u_3} [TopologicalSpace α] [TopologicalSpace β] [SemilatticeSup β] [ContinuousSup β] (s : Finset ι) (hs : s.Nonempty) (f : ι → ContinuousMap α β) : (⇑(s.sup' hs f) : α → β) = s.sup' hs (fun i => (⇑(f i) : α → β)) := by sorry
#rt pilot_p070 rt_p070

-- p071
theorem pilot_p071 {𝕜 : Type u_2} {E : Type u_6} {ι : Type u_9}
  [NontriviallyNormedField 𝕜] [AddCommGroup E] [_root_.Module 𝕜 E] {p : SeminormFamily 𝕜 E ι} [t : TopologicalSpace E]
  (hp : WithSeminorms p) (q : Seminorm 𝕜 E) (hq : Continuous ⇑q) : ∃ s C, C ≠ 0 ∧ q ≤ C • ∑ i ∈ s, p i := by sorry
theorem rt_p071 {𝕜 : Type u} {E : Type v} {ι : Type w} [NontriviallyNormedField 𝕜] [AddCommGroup E] [Module 𝕜 E] [TopologicalSpace E] (p : SeminormFamily 𝕜 E ι) (hp : WithSeminorms p) (q : Seminorm 𝕜 E) (hq : Continuous (q : E → ℝ)) : ∃ (s : Finset ι) (C : ℝ≥0), C ≠ 0 ∧ q ≤ C • s.sum p := by sorry
#rt pilot_p071 rt_p071

-- p072
theorem pilot_p072 {α : Type u_1} {β : Type u_2} {γ : Type u_3}
  {mα : MeasurableSpace α} {mβ : MeasurableSpace β} {mγ : MeasurableSpace γ} (μ : MeasureTheory.Measure γ)
  (κ : ProbabilityTheory.Kernel α β) : ⇑((ProbabilityTheory.Kernel.const β μ).comp κ) = fun a => (κ a) Set.univ • μ := by sorry
theorem rt_p072 {α : Type u_1} {β : Type u_2} {γ : Type u_3} [MeasurableSpace α] [MeasurableSpace β] [MeasurableSpace γ] (μ : MeasureTheory.Measure γ) (κ : ProbabilityTheory.Kernel α β) (a : α) : (ProbabilityTheory.Kernel.comp (ProbabilityTheory.Kernel.const β μ) κ) a = κ a Set.univ • μ := by sorry
#rt pilot_p072 rt_p072

-- p073
theorem pilot_p073 {R : Type u_1} {M : Type u_2} [Semiring R] [AddCommMonoid M] [_root_.Module R M]
  (p p' : Submodule R M) : p ⊔ p' = ⊤ ↔ ∀ (m : M), ∃ u ∈ p, ∃ v ∈ p', m = u + v := by sorry
theorem rt_p073 {R : Type u_1} {M : Type u_2} [Semiring R] [AddCommMonoid M] [Module R M] (p p' : Submodule R M) : p ⊔ p' = ⊤ ↔ ∀ m : M, ∃ u ∈ p, ∃ v ∈ p', u + v = m := by sorry
#rt pilot_p073 rt_p073

-- p074
theorem pilot_p074 {σ : Type u_1} {R : Type u_2} [Semiring R]
  {f : MvPowerSeries σ R} : f ≠ 0 ↔ ∃ n d, (MvPowerSeries.coeff d) f ≠ 0 ∧ Finsupp.degree d = n := by sorry
theorem rt_p074 {σ : Type u_1} {R : Type u_2} [Semiring R] (f : MvPowerSeries σ R) : f ≠ 0 ↔ ∃ (n : ℕ) (d : σ →₀ ℕ), MvPowerSeries.coeff d f ≠ 0 ∧ d.sum (fun _ k => k) = n := by sorry
#rt pilot_p074 rt_p074

-- p075
theorem pilot_p075 {n m : SemiSimplexCategory} (f : n ⟶ m) :
  CategoryTheory.Mono (SemiSimplexCategory.toSimplexCategory.map f) := by sorry
open CategoryTheory in theorem rt_p075 (n m : SemiSimplexCategory) (f : n ⟶ m) : Mono (SemiSimplexCategory.toSimplexCategory.map f) := by sorry
#rt pilot_p075 rt_p075

-- p076
theorem pilot_p076 : CategoryTheory.IsIso AlgebraicGeometry.ΓSpec.adjunction.counit := by sorry
theorem rt_p076 : CategoryTheory.IsIso (AlgebraicGeometry.ΓSpec.adjunction.{u}).counit := by sorry
#rt pilot_p076 rt_p076

-- p077
theorem pilot_p077 {α : Type u_1} {β : Type u_2} [PartialOrder α] [PartialOrder β] {a : α}
  {b₁ b₂ : β} : (a, b₁) ⩿ (a, b₂) ↔ b₁ ⩿ b₂ := by sorry
theorem rt_p077 {α : Type u} {β : Type v} [PartialOrder α] [PartialOrder β] (a : α) (b₁ b₂ : β) : WCovBy (a, b₁) (a, b₂) ↔ WCovBy b₁ b₂ := by sorry
#rt pilot_p077 rt_p077

-- p078
theorem pilot_p078 (R : Type u_1) (S : Type u_2) {A : Type u_3} [CommRing R]
  [CommRing S] [Ring A] [Algebra R S] [Algebra R A] [Algebra S A] [IsScalarTower R S A] [NoZeroDivisors S]
  [Algebra.IsAlgebraic R S] [FaithfulSMul R S] {a : A} : IsAlgebraic R a ↔ IsAlgebraic S a := by sorry
theorem rt_p078 {R : Type u_1} {S : Type u_2} {A : Type u_3} [CommRing R] [CommRing S] [Ring A] [Algebra R S] [Algebra R A] [Algebra S A] [IsScalarTower R S A] [NoZeroDivisors S] [Algebra.IsAlgebraic R S] [FaithfulSMul R S] (a : A) : IsAlgebraic R a ↔ IsAlgebraic S a := by sorry
#rt pilot_p078 rt_p078

-- p079
theorem pilot_p079 {A : Type u_1} {p : A → Prop} [NormedRing A] [StarRing A] [NormedAlgebra ℂ A]
  [ContinuousFunctionalCalculus ℂ A p] {a : A} (ha : p a := by cfc_tac) : cfc Complex.exp a = NormedSpace.exp a := by sorry
theorem rt_p079 {A : Type u} [NormedRing A] [StarRing A] [NormedAlgebra ℂ A] (p : A → Prop) [ContinuousFunctionalCalculus ℂ A p] (a : A) (ha : p a) : cfc Complex.exp a = ∑' n : ℕ, ((n.factorial : ℂ)⁻¹) • a ^ n := by sorry
#rt pilot_p079 rt_p079

-- p081
theorem pilot_p081 {R : Type u_1} {M : Type uM} [CommRing R] [AddCommGroup M]
  [_root_.Module R M]
  (H : ∀ (I : Ideal R) (x : I.IsMaximal), Module.Projective (Localization.AtPrime I) (LocalizedModule I.primeCompl M))
  [Module.FinitePresentation R M] : Module.Projective R M := by sorry
theorem rt_p081 {R : Type u_1} {M : Type u_2} [CommRing R] [AddCommGroup M] [Module R M] [Module.FinitePresentation R M] (h : ∀ (m : Ideal R) [m.IsMaximal], Module.Projective (Localization.AtPrime m) (LocalizedModule m.primeCompl M)) : Module.Projective R M := by sorry
#rt pilot_p081 rt_p081

-- p082
theorem pilot_p082 {R : Type u_1} [CommMonoidWithZero R] [WfDvdMonoid R] {x : R} (hx₀ : x ≠ 0) :
  Squarefree x ↔ ∀ (p : R), Irreducible p → ¬p * p ∣ x := by sorry
theorem rt_p082 {R : Type u_1} [CommMonoidWithZero R] [WfDvdMonoid R] {x : R} (hx : x ≠ 0) : Squarefree x ↔ ∀ p : R, Irreducible p → ¬ p * p ∣ x := by sorry
#rt pilot_p082 rt_p082

-- p083
theorem pilot_p083 {V : Type u} {G : SimpleGraph V} (C : G.ConnectedComponent)
  {u v : V} (hu : u ∈ C) (hv : v ∈ C) : C.toSimpleGraph.Adj ⟨u, hu⟩ ⟨v, hv⟩ ↔ G.Adj u v := by sorry
theorem rt_p083 {V : Type u} (G : SimpleGraph V) (C : G.ConnectedComponent) (u v : V) (hu : u ∈ C) (hv : v ∈ C) : C.toSimpleGraph.Adj ⟨u, hu⟩ ⟨v, hv⟩ ↔ G.Adj u v := by sorry
#rt pilot_p083 rt_p083

-- p085
theorem pilot_p085 {α : Type u_2} {β : Type u_4} [TopologicalSpace α] [One β]
  [TopologicalSpace β] {f : α → β} {s : Set α} (hs : ContinuousOn f s) (h's : IsOpen s) (h''s : mulTSupport f ⊆ s) :
  Continuous f := by sorry
theorem rt_p085 {α : Type u} {β : Type v} [TopologicalSpace α] [TopologicalSpace β] [One β] (f : α → β) (s : Set α) (hf : ContinuousOn f s) (hs : IsOpen s) (h : mulTSupport f ⊆ s) : Continuous f := by sorry
#rt pilot_p085 rt_p085

-- p086
theorem pilot_p086 {R : Type u_1} [Ring R] {M : Type u_2} [TopologicalSpace M] [AddCommGroup M]
  [_root_.Module R M] {p q : Submodule R M} (h : Submodule.IsTopCompl p q) (x : M) : (p.projectionL q h) x ∈ p := by sorry
theorem rt_p086 {R : Type u} [Ring R] {M : Type v} [TopologicalSpace M] [AddCommGroup M] [Module R M] {p q : Submodule R M} (h : Submodule.IsTopCompl p q) (x : M) : h.projectionL x ∈ p := by sorry
#rt pilot_p086 rt_p086

-- p087
theorem pilot_p087 {F : Type u} [Field F] {W : WeierstrassCurve.Projective F}
  {P : Fin 3 → F} (hPz : P 2 ≠ 0) : W.Equation P ↔ W.toAffine.Equation (P 0 / P 2) (P 1 / P 2) := by sorry
theorem rt_p087 {F : Type u} [Field F] (W : WeierstrassCurve.Projective F) (P : Fin 3 → F) (hP : P 2 ≠ 0) : W.Equation P ↔ W.toAffine.Equation (P 0 / P 2) (P 1 / P 2) := by sorry
#rt pilot_p087 rt_p087

-- p088
theorem pilot_p088 {R : Type u_1} [CommSemiring R] (q : ℕ) (f : PowerSeries R) :
  ((ArithmeticFunction.ofPowerSeries q) f) 1 = PowerSeries.constantCoeff f := by sorry
theorem rt_p088 {R : Type u_1} [CommSemiring R] (q : ℕ) (f : PowerSeries R) : ArithmeticFunction.ofPowerSeries q f 1 = PowerSeries.constantCoeff f := by sorry
#rt pilot_p088 rt_p088

-- p089
theorem pilot_p089 {X : Type u_1} {F : Set X} (T : X → X) (h : F.Nonempty) (U : SetRel X X) :
  Dynamics.netMaxcard T F U 0 = 1 := by sorry
theorem rt_p089 {X : Type u} (T : X → X) (F : Set X) (U : Set (X × X)) (hF : F.Nonempty) : Dynamics.netMaxcard T F U 0 = 1 := by sorry
#rt pilot_p089 rt_p089

-- p090
theorem pilot_p090 {k G : Type u} [CommRing k] [Group G] {A : Rep k G} (n : ℕ) :
  groupHomology.cyclesMap (MonoidHom.id G) (CategoryTheory.CategoryStruct.id A) n =
    CategoryTheory.CategoryStruct.id (groupHomology.cycles A n) := by sorry
open CategoryTheory in theorem rt_p090 {k G : Type u} [CommRing k] [Group G] (A : Rep k G) (n : ℕ) : groupHomology.cyclesMap (MonoidHom.id G) (𝟙 A) n = 𝟙 (groupHomology.cycles A n) := by sorry
#rt pilot_p090 rt_p090

-- p091
theorem pilot_p091 (X : TopCat) :
  CategoryTheory.CategoryStruct.comp SSet.ι₀
      (CategoryTheory.CategoryStruct.comp
        (CategoryTheory.MonoidalCategoryStruct.whiskerLeft (TopCat.toSSet.obj X) SSet.stdSimplex.toSSetObjI)
        (CategoryTheory.Functor.LaxMonoidal.μ TopCat.toSSet X TopCat.I)) =
    TopCat.toSSet.map TopCat.ι₀ := by sorry
open CategoryTheory CategoryTheory.MonoidalCategory in theorem rt_p091 (X : TopCat.{u}) : SSet.ι₀ (TopCat.toSSet.obj X) ≫ ((𝟙 (TopCat.toSSet.obj X)) ⊗ₘ SSet.stdSimplex.toSSetObjI) ≫ CategoryTheory.Functor.LaxMonoidal.μ TopCat.toSSet X TopCat.I = TopCat.toSSet.map (TopCat.ι₀ X) := by sorry
#rt pilot_p091 rt_p091

-- p092
theorem pilot_p092 {X : Type u_1} {Y : Type u_2} [TopologicalSpace X]
  [TopologicalSpace Y] (e : OpenPartialHomeomorph X Y) (s : Set X) : e.source ∩ ↑e ⁻¹' ↑e.symm ⁻¹' s = e.source ∩ s := by sorry
theorem rt_p092 {X : Type u_1} {Y : Type u_2} [TopologicalSpace X] [TopologicalSpace Y] (e : OpenPartialHomeomorph X Y) (s : Set X) : e.source ∩ e ⁻¹' (e.symm ⁻¹' s) = e.source ∩ s := by sorry
#rt pilot_p092 rt_p092

-- p094
theorem pilot_p094 (x : ↑unitInterval) : Subtype.val ⁻¹' Set.Ici ↑x = Set.Icc x 1 := by sorry
theorem rt_p094 (x : ↥unitInterval) : (Subtype.val : ↥unitInterval → ℝ) ⁻¹' Set.Ici (x : ℝ) = Set.Icc x 1 := by sorry
#rt pilot_p094 rt_p094

-- p096
theorem pilot_p096 {G : Type u_1} [Group G] {X : Type u_2} [MulAction G X]
  {B : Set X} : MulAction.IsBlock G B ↔ ∀ ⦃g : G⦄, g • B ≠ B → Disjoint (g • B) B := by sorry
theorem rt_p096 {G : Type u} [Group G] {X : Type v} [MulAction G X] (B : Set X) : MulAction.IsBlock G B ↔ ∀ g : G, g • B ≠ B → Disjoint (g • B) B := by sorry
#rt pilot_p096 rt_p096

-- p097
theorem pilot_p097 {C : Type u₁}
  [CategoryTheory.Category C] {D : Type u₂} [CategoryTheory.Category D] (J : Type w) [CategoryTheory.Category J]
  (F : CategoryTheory.Functor Cᵒᵖ D) [CategoryTheory.Limits.PreservesLimitsOfShape Jᵒᵖ F.rightOp] :
  CategoryTheory.Limits.PreservesColimitsOfShape J F := by sorry
open CategoryTheory in theorem rt_p097 {C : Type u₁} [Category.{v₁} C] {D : Type u₂} [Category.{v₂} D] {J : Type w₁} [Category.{w₂} J] (F : Cᵒᵖ ⥤ D) [CategoryTheory.Limits.PreservesLimitsOfShape Jᵒᵖ F.rightOp] : CategoryTheory.Limits.PreservesColimitsOfShape J F := by sorry
#rt pilot_p097 rt_p097

-- p098
theorem pilot_p098 {n d : ℕ}
  (s : (SSet.stdSimplex.obj { len := n }).obj (Opposite.op { len := d })) (i : Fin (d + 1)) :
  ((CategoryTheory.ConcreteCategory.hom ((SSet.stdSimplex.isoNerve n).hom.app (Opposite.op { len := d }))) s).obj i =
    { down := s i } := by sorry
open CategoryTheory Opposite in theorem rt_p098 (n d : ℕ) (s : (SSet.stdSimplex.{u}.obj (SimplexCategory.mk n)).obj (op (SimplexCategory.mk d))) (i : Fin (d + 1)) : (((SSet.stdSimplex.isoNerve.{u} n).hom.app (op (SimplexCategory.mk d))) s).obj i = ULift.up (s i) := by sorry
#rt pilot_p098 rt_p098

-- p099
theorem pilot_p099 {α : Type u_1} [FinEnum α] [Nonempty α] : 0 < FinEnum.card α := by sorry
theorem rt_p099 (α : Type u) [FinEnum α] [Nonempty α] : 0 < FinEnum.card α := by sorry
#rt pilot_p099 rt_p099

-- p100
theorem pilot_p100 {k G : Type u} [CommRing k] [Group G] (A : Rep k G) :
  CategoryTheory.CategoryStruct.comp (groupHomology.toCycles A 2 1) (groupHomology.isoCycles₁ A).hom =
    CategoryTheory.CategoryStruct.comp (groupHomology.chainsIso₂ A).hom
      (groupHomology.shortComplexH1 A).moduleCatLeftHomologyData.f' := by sorry
open CategoryTheory in theorem rt_p100 {k G : Type u} [CommRing k] [Group G] (A : Rep.{u} k G) : (groupHomology.inhomogeneousChains A).toCycles 2 1 ≫ (groupHomology.isoCycles₁ A).hom = (groupHomology.chainsIso₂ A).hom ≫ CategoryTheory.Limits.kernel.lift (groupHomology.d₁₀ A) (groupHomology.d₂₁ A) (groupHomology.shortComplexH1 A).zero := by sorry
#rt pilot_p100 rt_p100

-- p101
theorem pilot_p101 {α : Type u_1} [DecidableEq α] [Fintype α] {𝒜 : Finset (Finset α)} :
  𝒜.compls.shadow = 𝒜.upShadow.compls := by sorry
theorem rt_p101 {α : Type u_1} [DecidableEq α] [Fintype α] (𝒜 : Finset (Finset α)) : Finset.shadow (𝒜.image (fun s => sᶜ)) = (Finset.upShadow 𝒜).image (fun s => sᶜ) := by sorry
#rt pilot_p101 rt_p101

-- p103
theorem pilot_p103 {C : Type u_1}
  [CategoryTheory.Category C] {X : CategoryTheory.SimplicialObject C} (s : X.Splitting) [CategoryTheory.Preadditive C] :
  CategoryTheory.CategoryStruct.comp s.toKaroubiNondegComplexIsoN₁.hom.f AlgebraicTopology.DoldKan.PInfty =
    s.toKaroubiNondegComplexIsoN₁.hom.f := by sorry
open CategoryTheory AlgebraicTopology DoldKan in theorem rt_p103 {C : Type u_1} [Category.{v_1} C] [Preadditive C] {X : CategoryTheory.SimplicialObject C} (s : CategoryTheory.SimplicialObject.Splitting X) : s.toKaroubiNondegComplexIsoN₁.hom.f ≫ (N₁.obj X).p = s.toKaroubiNondegComplexIsoN₁.hom.f := by sorry
#rt pilot_p103 rt_p103

-- p104
theorem pilot_p104 (t : ℝ) :
  (starRingEnd ℂ) (completedRiemannZeta (1 / 2 + ↑t * Complex.I)) = completedRiemannZeta (1 / 2 + ↑t * Complex.I) := by sorry
theorem rt_p104 (t : ℝ) : star (completedRiemannZeta ((1 / 2 : ℂ) + (t : ℂ) * Complex.I)) = completedRiemannZeta ((1 / 2 : ℂ) + (t : ℂ) * Complex.I) := by sorry
#rt pilot_p104 rt_p104

-- p105
theorem pilot_p105 {A : Type u_1}
  [CategoryTheory.Category A] [CategoryTheory.Abelian A] {X : A} {n : ℕ} [CategoryTheory.EnoughProjectives A] :
  (CategoryTheory.isProjective A).hasFiniteResolutionOfLength n X ↔ CategoryTheory.HasProjectiveDimensionLE X n := by sorry
theorem rt_p105 {A : Type u} [CategoryTheory.Category.{v} A] [CategoryTheory.Abelian A] [CategoryTheory.EnoughProjectives A] (X : A) (n : ℕ) : CategoryTheory.ObjectProperty.hasFiniteResolutionOfLength (fun Y : A => CategoryTheory.Projective Y) n X ↔ CategoryTheory.HasProjectiveDimensionLE X n := by sorry
#rt pilot_p105 rt_p105

-- p106
theorem pilot_p106 {𝕜 : Type u} {E : Type wE} {F : Type wF}
  {ι : Type v} [NontriviallyNormedField 𝕜] [SeminormedAddCommGroup E] [NormedSpace 𝕜 E] [SeminormedAddCommGroup F]
  [NormedSpace 𝕜 F] [Fintype ι] {f : E [⋀^ι]→L[𝕜] F} {m : ι → E} {C : ℝ} {b : ι → ℝ} (hC : ‖f‖ ≤ C)
  (hm : ∀ (i : ι), ‖m i‖ ≤ b i) : ‖f m‖ ≤ C * ∏ i, b i := by sorry
theorem rt_p106 {𝕜 : Type u} {E : Type u_1} {F : Type u_2} {ι : Type v} [NontriviallyNormedField 𝕜] [SeminormedAddCommGroup E] [NormedSpace 𝕜 E] [SeminormedAddCommGroup F] [NormedSpace 𝕜 F] [Fintype ι] (f : E [⋀^ι]→L[𝕜] F) (m : ι → E) (C : ℝ) (hC : ‖f‖ ≤ C) (b : ι → ℝ) (hb : ∀ i, ‖m i‖ ≤ b i) : ‖f m‖ ≤ C * ∏ i, b i := by sorry
#rt pilot_p106 rt_p106

-- p108
theorem pilot_p108 {α : Type u} [LE α] [Mul α] [c : MulRightMono α] : MulRightMono αᵒᵈ := by sorry
theorem rt_p108 {α : Type u_1} [LE α] [Mul α] [MulRightMono α] : MulRightMono (OrderDual α) := by sorry
#rt pilot_p108 rt_p108

-- p109
theorem pilot_p109 {α : Type u_1} {β : Type u_2} [Field α] [LinearOrder α] [IsStrictOrderedRing α] [Ring β]
  {abv : β → α} [IsAbsoluteValue abv] {f : ℕ → β} (hf : IsCauSeq abv f) (x : α) : ∃ r > x, ∀ (i : ℕ), abv (f i) < r := by sorry
theorem rt_p109 {α : Type u} {β : Type v} [Field α] [LinearOrder α] [IsStrictOrderedRing α] [Ring β] (abv : β → α) [IsAbsoluteValue abv] (f : ℕ → β) (hf : IsCauSeq abv f) (x : α) : ∃ r : α, x < r ∧ ∀ n : ℕ, abv (f n) < r := by sorry
#rt pilot_p109 rt_p109

-- p111
theorem pilot_p111 {α : Type u_2} [Preorder α] {s : Set α}
  (hs : ∀ (x : α), ∃ y ∈ s, x ≤ y) : Filter.atTop = Filter.generate (Set.Ici '' s) := by sorry
theorem rt_p111 {α : Type u_1} [Preorder α] (s : Set α) (hs : ∀ x : α, ∃ y ∈ s, x ≤ y) : (Filter.atTop : Filter α) = ⨅ y ∈ s, Filter.principal (Set.Ici y) := by sorry
#rt pilot_p111 rt_p111

-- p112
theorem pilot_p112 {X : _root_.SSet} {A : X.Subcomplex} {P : A.Pairing}
  {α : Type v} [PartialOrder α] [WellFoundedLT α] (f : P.RankFunction α) : WellFounded P.AncestralRel := by sorry
theorem rt_p112 {X : SSet.{u}} {A : X.Subcomplex} {P : A.Pairing} {α : Type v} [PartialOrder α] [WellFoundedLT α] (f : P.RankFunction α) : WellFounded P.AncestralRel := by sorry
#rt pilot_p112 rt_p112

-- p113
theorem pilot_p113 {Ω : Type u_1} {mΩ : MeasurableSpace Ω} {B : NNReal → Ω → ℝ}
  {P : MeasureTheory.Measure Ω} (hB : ProbabilityTheory.IsPreBrownianReal B P) (t₀ : NNReal) :
  ProbabilityTheory.IndepFun (fun ω t => B (t₀ + t) ω - B t₀ ω) (fun ω t => B (↑t) ω) P := by sorry
theorem rt_p113 {Ω : Type u_1} [MeasurableSpace Ω] {B : ℝ≥0 → Ω → ℝ} {P : MeasureTheory.Measure Ω} (hB : ProbabilityTheory.IsPreBrownianReal B P) (t₀ : ℝ≥0) : ProbabilityTheory.IndepFun (fun ω t => B (t₀ + t) ω - B t₀ ω) (fun ω (t : Set.Iic t₀) => B t ω) P := by sorry
#rt pilot_p113 rt_p113

-- p117
theorem pilot_p117 {S : Type u_1} {T : Type u_2} {Ω : Type u_3}
  {E : Type u_4} {mΩ : MeasurableSpace Ω} {P : MeasureTheory.Measure Ω} {X : T → Ω → E} [NormedAddCommGroup E]
  [MeasurableSpace E] [BorelSpace E] [NormedSpace ℝ E] [SecondCountableTopology E]
  (h : ProbabilityTheory.IsGaussianProcess X P) (f : S → T) : ProbabilityTheory.IsGaussianProcess (X ∘ f) P := by sorry
theorem rt_p117 {S : Type u₁} {T : Type u₂} {Ω : Type u₃} {E : Type u₄} [MeasurableSpace Ω] (P : MeasureTheory.Measure Ω) [NormedAddCommGroup E] [NormedSpace ℝ E] [MeasurableSpace E] [BorelSpace E] [SecondCountableTopology E] (X : T → Ω → E) (hX : ProbabilityTheory.IsGaussianProcess X P) (f : S → T) : ProbabilityTheory.IsGaussianProcess (X ∘ f) P := by sorry
#rt pilot_p117 rt_p117

-- p118
theorem pilot_p118
  {X Y : AlgebraicGeometry.Scheme} (f : X ⟶ Y) (𝒰 : Y.OpenCover)
  (𝒱 : (i : 𝒰.I₀) → (CategoryTheory.Limits.pullback f (𝒰.f i)).OpenCover)
  [∀ (i : 𝒰.I₀), AlgebraicGeometry.IsAffine (𝒰.X i)]
  [∀ (i : 𝒰.I₀) (j : (𝒱 i).I₀), AlgebraicGeometry.IsAffine ((𝒱 i).X j)] :
  AlgebraicGeometry.IsClosedImmersion
    (CategoryTheory.Limits.pullback.diagonal f ∣_ AlgebraicGeometry.Scheme.Pullback.diagonalCoverDiagonalRange f 𝒰 𝒱) := by sorry
open CategoryTheory CategoryTheory.Limits AlgebraicGeometry in theorem rt_p118 {X Y : Scheme.{u}} (f : X ⟶ Y) (𝒰 : Y.OpenCover) (𝒱 : ∀ i, (pullback f (𝒰.f i)).OpenCover) [∀ i, IsAffine (𝒰.X i)] [∀ i j, IsAffine ((𝒱 i).X j)] (W : (pullback f f).Opens) (hW : (W : Set (pullback f f)) = {z | ∃ (i : 𝒰.J) (j : (𝒱 i).J), (∃ t : (𝒱 i).X j, ((𝒱 i).f j ≫ pullback.fst f (𝒰.f i)) t = (pullback.fst f f) z) ∧ (∃ t : (𝒱 i).X j, ((𝒱 i).f j ≫ pullback.fst f (𝒰.f i)) t = (pullback.snd f f) z)}) : IsClosedImmersion ((pullback.diagonal f) ∣_ W) := by sorry
#rt pilot_p118 rt_p118

-- p119
theorem pilot_p119 {ι : Type u_1} {α : ι → Type u_2} [(i : ι) → Zero (α i)] [LT ι] [(i : ι) → LT (α i)]
  {a b : Lex (Π₀ (i : ι), α i)} : a < b ↔ ∃ i, (∀ j < i, (ofLex a) j = (ofLex b) j) ∧ (ofLex a) i < (ofLex b) i := by sorry
theorem rt_p119 {ι : Type u} {α : ι → Type v} [LT ι] [∀ i, Zero (α i)] [∀ i, LT (α i)] (a b : Lex (Π₀ i, α i)) : a < b ↔ ∃ i, (∀ j, j < i → ofLex a j = ofLex b j) ∧ ofLex a i < ofLex b i := by sorry
#rt pilot_p119 rt_p119

-- p120
theorem pilot_p120 {basis basis' : Tactic.ComputeAsymptotics.Basis}
  (h : List.Sublist basis basis') (h_basis : Tactic.ComputeAsymptotics.WellFormedBasis basis') :
  Tactic.ComputeAsymptotics.WellFormedBasis basis := by sorry
theorem rt_p120 {B B' : Tactic.ComputeAsymptotics.Basis} (h : B.Sublist B') (hB' : Tactic.ComputeAsymptotics.WellFormedBasis B') : Tactic.ComputeAsymptotics.WellFormedBasis B := by sorry
#rt pilot_p120 rt_p120

-- p121
theorem pilot_p121 {J : Type u} [CategoryTheory.Category J] {X : J}
  (hX : CategoryTheory.Limits.IsTerminal X) (κ : Cardinal) [Fact κ.IsRegular] : CategoryTheory.IsCardinalFiltered J κ := by sorry
theorem rt_p121 {J : Type u} [CategoryTheory.Category.{v} J] (X : J) (hX : CategoryTheory.Limits.IsTerminal X) (κ : Cardinal.{w}) [Fact κ.IsRegular] : CategoryTheory.IsCardinalFiltered J κ := by sorry
#rt pilot_p121 rt_p121
