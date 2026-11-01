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


-- p017
theorem pilot_p017 (t : Tactic.ComputeAsymptotics.Monomial) :
  List.length t.inv.unit = List.length t.unit := by sorry
theorem rt_p017 (t : Tactic.ComputeAsymptotics.Monomial) : (Tactic.ComputeAsymptotics.Monomial.inv t).unit.length = t.unit.length := by sorry
#rt pilot_p017 rt_p017

-- p020
theorem pilot_p020 {ι : Type u_1} {ι' : Type u_2} {c : ComplexShape ι}
  {c' : ComplexShape ι'} {C : Type u_3} [CategoryTheory.Category C] [CategoryTheory.Limits.HasZeroMorphisms C]
  (K : HomologicalComplex C c') (e : c.Embedding c') [e.IsTruncGE] [∀ (i' : ι'), K.HasHomology i'] (i : ι)
  (hi : ¬e.BoundaryGE i) : CategoryTheory.IsIso ((K.restrictionToTruncGE' e).f i) := by sorry
open CategoryTheory in theorem rt_p020 {ι : Type u_1} {ι' : Type u_2} {c : ComplexShape ι} {c' : ComplexShape ι'} {C : Type u_3} [Category.{v} C] [CategoryTheory.Limits.HasZeroMorphisms C] (K : HomologicalComplex C c') (e : c.Embedding c') [e.IsTruncGE] [∀ i', K.HasHomology i'] (i : ι) (hi : ¬ e.BoundaryGE i) : IsIso ((K.restrictionToTruncGE' e).f i) := by sorry
#rt pilot_p020 rt_p020

-- p026
theorem pilot_p026 {n : Type u_1} {R : Type u_2} {M : Type u_3} {N : Type u_4}
  [Fintype n] [DecidableEq n] [CommRing R] [AddCommGroup M] [_root_.Module R M] [AddCommGroup N] [_root_.Module R N]
  (rl : CartanMatrix.Realisation n R M N) [CharZero R] [IsDomain R] : LinearIndependent R rl.sRoot := by sorry
theorem rt_p026 {n : Type u_1} {R : Type u_2} {M : Type u_3} {N : Type u_4} [Fintype n] [DecidableEq n] [CommRing R] [AddCommGroup M] [Module R M] [AddCommGroup N] [Module R N] [CharZero R] [IsDomain R] (rl : CartanMatrix.Realisation n R M N) : LinearIndependent R rl.root := by sorry
#rt pilot_p026 rt_p026

-- p086
theorem pilot_p086 {R : Type u_1} [Ring R] {M : Type u_2} [TopologicalSpace M] [AddCommGroup M]
  [_root_.Module R M] {p q : Submodule R M} (h : Submodule.IsTopCompl p q) (x : M) : (p.projectionL q h) x ∈ p := by sorry
theorem rt_p086 {R : Type u} [Ring R] {M : Type v} [TopologicalSpace M] [AddCommGroup M] [Module R M] {p q : Submodule R M} (h : Submodule.IsTopCompl p q) (x : M) : Submodule.projectionL p q h x ∈ p := by sorry
#rt pilot_p086 rt_p086

-- p091
theorem pilot_p091 (X : TopCat) :
  CategoryTheory.CategoryStruct.comp SSet.ι₀
      (CategoryTheory.CategoryStruct.comp
        (CategoryTheory.MonoidalCategoryStruct.whiskerLeft (TopCat.toSSet.obj X) SSet.stdSimplex.toSSetObjI)
        (CategoryTheory.Functor.LaxMonoidal.μ TopCat.toSSet X TopCat.I)) =
    TopCat.toSSet.map TopCat.ι₀ := by sorry
open CategoryTheory CategoryTheory.MonoidalCategory in theorem rt_p091 (X : TopCat.{u}) : (SSet.ι₀ : TopCat.toSSet.obj X ⟶ _) ≫ ((𝟙 (TopCat.toSSet.obj X)) ⊗ₘ SSet.stdSimplex.toSSetObjI) ≫ CategoryTheory.Functor.LaxMonoidal.μ TopCat.toSSet X TopCat.I = TopCat.toSSet.map (TopCat.ι₀ : X ⟶ X ⊗ TopCat.I) := by sorry
#rt pilot_p091 rt_p091

-- p100
theorem pilot_p100 {k G : Type u} [CommRing k] [Group G] (A : Rep k G) :
  CategoryTheory.CategoryStruct.comp (groupHomology.toCycles A 2 1) (groupHomology.isoCycles₁ A).hom =
    CategoryTheory.CategoryStruct.comp (groupHomology.chainsIso₂ A).hom
      (groupHomology.shortComplexH1 A).moduleCatLeftHomologyData.f' := by sorry
open CategoryTheory in theorem rt_p100 {k G : Type u} [CommRing k] [Group G] (A : Rep.{u} k G) : (groupHomology.inhomogeneousChains A).toCycles 2 1 ≫ (groupHomology.isoCycles₁ A).hom = (groupHomology.chainsIso₂ A).hom ≫ (groupHomology.shortComplexH1 A).moduleCatLeftHomologyData.f' := by sorry
#rt pilot_p100 rt_p100

-- p117
theorem pilot_p117 {S : Type u_1} {T : Type u_2} {Ω : Type u_3}
  {E : Type u_4} {mΩ : MeasurableSpace Ω} {P : MeasureTheory.Measure Ω} {X : T → Ω → E} [NormedAddCommGroup E]
  [MeasurableSpace E] [BorelSpace E] [NormedSpace ℝ E] [SecondCountableTopology E]
  (h : ProbabilityTheory.IsGaussianProcess X P) (f : S → T) : ProbabilityTheory.IsGaussianProcess (X ∘ f) P := by sorry
theorem rt_p117 {S : Type u_1} {T : Type u_2} {Ω : Type u_3} {E : Type u_4} [MeasurableSpace Ω] (P : MeasureTheory.Measure Ω) [NormedAddCommGroup E] [NormedSpace ℝ E] [MeasurableSpace E] [BorelSpace E] [SecondCountableTopology E] (X : T → Ω → E) (hX : ProbabilityTheory.IsGaussianProcess X P) (f : S → T) : ProbabilityTheory.IsGaussianProcess (X ∘ f) P := by sorry
#rt pilot_p117 rt_p117

-- p118
theorem pilot_p118
  {X Y : AlgebraicGeometry.Scheme} (f : X ⟶ Y) (𝒰 : Y.OpenCover)
  (𝒱 : (i : 𝒰.I₀) → (CategoryTheory.Limits.pullback f (𝒰.f i)).OpenCover)
  [∀ (i : 𝒰.I₀), AlgebraicGeometry.IsAffine (𝒰.X i)]
  [∀ (i : 𝒰.I₀) (j : (𝒱 i).I₀), AlgebraicGeometry.IsAffine ((𝒱 i).X j)] :
  AlgebraicGeometry.IsClosedImmersion
    (CategoryTheory.Limits.pullback.diagonal f ∣_ AlgebraicGeometry.Scheme.Pullback.diagonalCoverDiagonalRange f 𝒰 𝒱) := by sorry
open CategoryTheory CategoryTheory.Limits AlgebraicGeometry in theorem rt_p118 {X Y : Scheme.{u}} (f : X ⟶ Y) (𝒰 : Y.OpenCover) (𝒱 : ∀ i, (pullback f (𝒰.f i)).OpenCover) [∀ i, IsAffine (𝒰.X i)] [∀ i j, IsAffine ((𝒱 i).X j)] (W : (pullback f f : Scheme.{u}).Opens) (hW : (W : Set ↥(pullback f f : Scheme.{u})) = ⋃ (i : 𝒰.I₀) (j : (𝒱 i).I₀), (let a : (𝒱 i).X j ⟶ X := (𝒱 i).f j ≫ pullback.fst f (𝒰.f i); let b : (𝒱 i).X j ⟶ 𝒰.X i := (𝒱 i).f j ≫ pullback.snd f (𝒰.f i); Set.range (fun t : (pullback b b : Scheme.{u}) => (pullback.lift (pullback.fst b b ≫ a) (pullback.snd b b ≫ a) (by sorry) : (pullback b b : Scheme.{u}) ⟶ (pullback f f : Scheme.{u})) t))) : IsClosedImmersion ((pullback.diagonal f) ∣_ W) := by sorry
#rt pilot_p118 rt_p118

-- p127
theorem pilot_p127 {ι : Type u_1} {α : Type u_2} {s : ι → Set α}
  (hs : IndexedPartition s) {β : Type u_3} (f : ι → α → β) (t : Set β) : hs.piecewise f ⁻¹' t = ⋃ i, s i ∩ f i ⁻¹' t := by sorry
theorem rt_p127 {ι : Type u} {α : Type v} {β : Type w} {s : ι → Set α} (hs : IndexedPartition s) (f : ι → α → β) (t : Set β) : hs.piecewise f ⁻¹' t = ⋃ i : ι, s i ∩ f i ⁻¹' t := by sorry
#rt pilot_p127 rt_p127

-- p147
theorem pilot_p147 {R S : CommRingCat} (f : R ⟶ S) :
  AlgebraicGeometry.IsPreimmersion (AlgebraicGeometry.Spec.map f) ↔
    Topology.IsEmbedding (PrimeSpectrum.comap (CommRingCat.Hom.hom f)) ∧ (CommRingCat.Hom.hom f).SurjectiveOnStalks := by sorry
theorem rt_p147 {R S : Type u} [CommRing R] [CommRing S] (f : R →+* S) : AlgebraicGeometry.IsPreimmersion (AlgebraicGeometry.Scheme.Spec.map (CommRingCat.ofHom f).op) ↔ Topology.IsEmbedding (PrimeSpectrum.comap f) ∧ RingHom.SurjectiveOnStalks f := by sorry
#rt pilot_p147 rt_p147

-- p157
theorem pilot_p157 {F : CategoryTheory.Functor LightProfiniteᵒᵖ (Type u)}
  (hF :
    (S : LightProfinite) →
      CategoryTheory.Limits.IsColimit (F.mapCocone (CategoryTheory.Limits.coconeRightOpOfCone S.asLimitCone)))
  (S : LightProfiniteᵒᵖ) :
  (LightCondensed.lanPresheafNatIso hF).hom.app S =
    CategoryTheory.Limits.colimit.desc
      ((CategoryTheory.CostructuredArrow.proj FintypeCat.toLightProfinite.op (Opposite.op (Opposite.unop S))).comp
        (FintypeCat.toLightProfinite.op.comp F))
      (LightProfinite.Extend.cocone F (Opposite.unop S)) := by sorry
open CategoryTheory CategoryTheory.Limits in theorem rt_p157 {F : LightProfinite.{u}ᵒᵖ ⥤ Type u} (hF : ∀ S : LightProfinite.{u}, IsColimit (F.mapCocone (coconeRightOpOfCone S.asLimitCone))) (S : LightProfinite.{u}ᵒᵖ) : (LightCondensed.lanPresheafNatIso hF).hom.app S = colimit.desc _ (F.mapCocone ({ pt := S, ι := { app := fun j => j.hom, naturality := by sorry } } : Cocone (CostructuredArrow.proj FintypeCat.toLightProfinite.op S ⋙ FintypeCat.toLightProfinite.op))) := by sorry
#rt pilot_p157 rt_p157

-- p158
theorem pilot_p158 {C : Type u₁} [CategoryTheory.Category C]
  {D : Type u₂} [CategoryTheory.Category D] (F : CategoryTheory.Functor Cᵒᵖ Dᵒᵖ)
  [CategoryTheory.Limits.PreservesFiniteLimits F] : CategoryTheory.Limits.PreservesFiniteColimits F.unop := by sorry
open CategoryTheory in theorem rt_p158 {C : Type u₁} {D : Type u₂} [Category.{v₁} C] [Category.{v₂} D] (F : Opposite C ⥤ Opposite D) [CategoryTheory.Limits.PreservesFiniteLimits F] : CategoryTheory.Limits.PreservesFiniteColimits F.unop := by sorry
#rt pilot_p158 rt_p158

-- p195
theorem pilot_p195 {R : Type u_2} {M : Type u_4} [Semiring R] [AddCommMonoid M]
  [_root_.Module R M] {G : Type u_6} [Group G] [DistribMulAction G M] [SMulCommClass G R M] (a : G) (s : Set M) :
  LinearIndepOn R id (a • s) ↔ LinearIndepOn R id s := by sorry
theorem rt_p195 {R : Type u_1} {M : Type u_2} {G : Type u_3} [Semiring R] [AddCommMonoid M] [Module R M] [Group G] [DistribMulAction G M] [SMulCommClass G R M] (a : G) (s : Set M) : LinearIndependent R (fun x : ↥(a • s : Set M) => (x : M)) ↔ LinearIndependent R (fun x : s => (x : M)) := by sorry
#rt pilot_p195 rt_p195

-- p196
theorem pilot_p196 {f : Ordinal → Ordinal} (hf : Order.IsNormal f) : Ordinal.veblenWith f 1 = Ordinal.deriv f := by sorry
theorem rt_p196 {f : Ordinal.{u} → Ordinal.{u}} (hf : Order.IsNormal f) : Ordinal.veblenWith f 1 = Ordinal.deriv f := by sorry
#rt pilot_p196 rt_p196

-- p001
theorem pilot_p001 (A : Type u_3) [CategoryTheory.Category A]
  [CategoryTheory.Abelian A] : (HomotopyCategory.Plus.quasiIso A).IsCompatibleWithShift ℤ := by sorry
theorem rt_p001 (A : Type u_1) [CategoryTheory.Category.{v₁} A] [CategoryTheory.Abelian A] : (HomotopyCategory.Plus.quasiIso A).IsCompatibleWithShift ℤ := by sorry
#rt pilot_p001 rt_p001

-- p228
theorem pilot_p228 {k : Type u_1} {V : Type u_2} {P : Type u_3} [Ring k]
  [AddCommGroup V] [_root_.Module k V] [AddTorsor V P] {s₁ s₂ : AffineSubspace k P} {p : P} (hp₁ : p ∈ s₁)
  (hp₂ : p ∈ s₂) : (s₁ ⊔ s₂).direction = s₁.direction ⊔ s₂.direction := by sorry
theorem rt_p228 {k : Type u} {V : Type v} {P : Type w} [Ring k] [AddCommGroup V] [Module k V] [AddTorsor V P] (s₁ s₂ : AffineSubspace k P) (p : P) (h₁ : p ∈ s₁) (h₂ : p ∈ s₂) : (s₁ ⊔ s₂).direction = s₁.direction ⊔ s₂.direction := by sorry
#rt pilot_p228 rt_p228
