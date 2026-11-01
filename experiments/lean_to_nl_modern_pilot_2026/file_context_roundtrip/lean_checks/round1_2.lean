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


-- p123
theorem pilot_p123 {X : Type u} [TopologicalSpace X] {α : Type u_1} {F : Filter α} {u : α → X} {x : X}
  (h : MapClusterPt x F u) {p : X → Prop} (hp : ∀ᶠ (y : X) in nhds x, p y) : ∃ᶠ (a : α) in F, p (u a) := by sorry
theorem rt_p123 {X : Type u} {α : Type v} [TopologicalSpace X] (F : Filter α) (u : α → X) (x : X) (hx : MapClusterPt x F u) (p : X → Prop) (hp : ∀ᶠ y in nhds x, p y) : ∃ᶠ a in F, p (u a) := by sorry
#rt pilot_p123 rt_p123

-- p124
theorem pilot_p124 {α : Type u_1} {β : Type u_2} {e e' : PartialEquiv α β}
  (he : e ≈ e') (s : Set β) : e.source ∩ ↑e ⁻¹' s = e'.source ∩ ↑e' ⁻¹' s := by sorry
theorem rt_p124 {α : Type u_1} {β : Type u_2} {e e' : PartialEquiv α β} (h : e ≈ e') (s : Set β) : e.source ∩ e ⁻¹' s = e'.source ∩ e' ⁻¹' s := by sorry
#rt pilot_p124 rt_p124

-- p125
theorem pilot_p125 {𝕜 : Type u_1} {E : Type u_2} [RCLike 𝕜] [SeminormedAddCommGroup E]
  [InnerProductSpace 𝕜 E] {𝕝 : Type u_4} [CommSemiring 𝕝] [StarRing 𝕝] [Algebra 𝕝 𝕜] [_root_.Module 𝕝 E]
  [IsScalarTower 𝕝 𝕜 E] [StarModule 𝕝 𝕜] (x y : E) (r : 𝕝) :
  Inner.inner 𝕜 (r • x) y = (starRingEnd 𝕝) r • Inner.inner 𝕜 x y := by sorry
theorem rt_p125 {𝕜 : Type u_1} {E : Type u_2} {L : Type u_3} [RCLike 𝕜] [SeminormedAddCommGroup E] [InnerProductSpace 𝕜 E] [CommSemiring L] [StarRing L] [Algebra L 𝕜] [Module L E] [IsScalarTower L 𝕜 E] [StarModule L 𝕜] (x y : E) (r : L) : inner 𝕜 (r • x) y = star r • inner 𝕜 x y := by sorry
#rt pilot_p125 rt_p125

-- p127
theorem pilot_p127 {ι : Type u_1} {α : Type u_2} {s : ι → Set α}
  (hs : IndexedPartition s) {β : Type u_3} (f : ι → α → β) (t : Set β) : hs.piecewise f ⁻¹' t = ⋃ i, s i ∩ f i ⁻¹' t := by sorry
theorem rt_p127 {ι : Type u} {α : Type v} {β : Type w} {s : ι → Set α} (hs : Setoid.IndexedPartition s) (f : ι → α → β) (t : Set β) : hs.piecewise f ⁻¹' t = ⋃ i : ι, s i ∩ f i ⁻¹' t := by sorry
#rt pilot_p127 rt_p127

-- p129
theorem pilot_p129 {V : Type u_1} {G : SimpleGraph V} {u v : V} :
  G.IsEdgeReachable ⊤ u v ↔ ∀ ⦃s : Set (Sym2 V)⦄, s.Finite → (G.deleteEdges s).Reachable u v := by sorry
theorem rt_p129 {V : Type u} (G : SimpleGraph V) (u v : V) : G.IsEdgeReachable ⊤ u v ↔ ∀ s : Finset (Sym2 V), (G.deleteEdges (s : Set (Sym2 V))).Reachable u v := by sorry
#rt pilot_p129 rt_p129

-- p131
theorem pilot_p131 {ι : Type u_1} {σ : Type u_2} {R : Type u_4} [AddCommMonoid ι] [LinearOrder ι]
  [IsOrderedAddMonoid ι] [DecidableEq ι] [Semiring R] [SetLike σ R] [AddSubmonoidClass σ R] {A : ι → σ}
  [SetLike.GradedMonoid A] [CanonicallyOrderedAdd ι] {l : List ((DirectSum ι fun i => ↥(A i)) × ι)}
  (hl : ∀ xn ∈ l, ∀ k < xn.2, xn.1 k = 0) ⦃n : ι⦄ (hn : n < (List.map Prod.snd l).sum) :
  (List.map Prod.fst l).prod n = 0 := by sorry
theorem rt_p131 {ι : Type u} {σ : Type v} {R : Type w} [AddCommMonoid ι] [LinearOrder ι] [IsOrderedAddMonoid ι] [DecidableEq ι] [CanonicallyOrderedAdd ι] [Semiring R] [SetLike σ R] [AddSubmonoidClass σ R] (A : ι → σ) [SetLike.GradedMonoid A] (l : List ((DirectSum ι (fun i => ↥(A i))) × ι)) (hl : ∀ p ∈ l, ∀ k, k < p.2 → p.1 k = 0) (n : ι) (hn : n < (l.map Prod.snd).sum) : (l.map Prod.fst).prod n = 0 := by sorry
#rt pilot_p131 rt_p131

-- p132
theorem pilot_p132 {R : Type u_1} {n : Type u_2} [Fintype n] [DecidableEq n]
  [Semiring R] [PartialOrder R] [IsOrderedRing R] {M : Matrix n n R} {x : n → R} (hM : M ∈ Matrix.rowStochastic R n)
  (hx : ∀ (i : n), 0 ≤ x i) (j : n) : 0 ≤ Matrix.vecMul x M j := by sorry
theorem rt_p132 {R : Type u_1} {n : Type u_2} [Fintype n] [DecidableEq n] [Semiring R] [PartialOrder R] [IsOrderedRing R] {M : Matrix n n R} (hM : M ∈ Matrix.rowStochastic R n) {x : n → R} (hx : ∀ i, 0 ≤ x i) (j : n) : 0 ≤ Matrix.vecMul x M j := by sorry
#rt pilot_p132 rt_p132

-- p133
theorem pilot_p133 {T : Type u_1} {N : Type u_2} (r : ContextFreeRule T N)
  (p q : List (Symbol T N)) : r.Rewrites (p ++ [Symbol.nonterminal r.input] ++ q) (p ++ r.output ++ q) := by sorry
theorem rt_p133 {T : Type u} {N : Type v} (r : ContextFreeRule T N) (p q : List (Symbol T N)) : ContextFreeRule.Rewrites r (p ++ [Symbol.nonterminal r.input] ++ q) (p ++ r.output ++ q) := by sorry
#rt pilot_p133 rt_p133

-- p134
theorem pilot_p134 {α : Type u_2} {f : Equiv.Perm α} {x y : α} :
  f.SameCycle x ((Equiv.symm f) y) ↔ f.SameCycle x y := by sorry
theorem rt_p134 {α : Type u_1} (f : Equiv.Perm α) (x y : α) : Equiv.Perm.SameCycle f x (f⁻¹ y) ↔ Equiv.Perm.SameCycle f x y := by sorry
#rt pilot_p134 rt_p134

-- p135
theorem pilot_p135 {R : Type u} {S : Type v} [CommRing R] [CommRing S] [Algebra R S]
  {A B : Subalgebra R S} (H : A.LinearDisjoint B) (H' : A ⊔ B = ⊤) [Module.Free R ↥B] [Module.Finite R ↥B] (x : ↥B) :
  (Algebra.norm ↥A) ((Algebra.algebraMap (↥B) S) x) = (Algebra.algebraMap R ↥A) ((Algebra.norm R) x) := by sorry
theorem rt_p135 {R : Type u} {S : Type v} [CommRing R] [CommRing S] [Algebra R S] {A B : Subalgebra R S} (H : A.LinearDisjoint B) (H' : A ⊔ B = ⊤) [Module.Free R B] [Module.Finite R B] (x : B) : Algebra.norm A (x : S) = algebraMap R A (Algebra.norm R x) := by sorry
#rt pilot_p135 rt_p135

-- p136
theorem pilot_p136 {M : Type u_2} {α : Type u_4} [CommMonoid M] [MeasurableSpace M]
  [MeasurableMul₂ M] {m : MeasurableSpace α} {μ : MeasureTheory.Measure α} (s : Multiset (α → M))
  (hs : ∀ f ∈ s, AEMeasurable f μ) : AEMeasurable (fun x => (Multiset.map (fun f => f x) s).prod) μ := by sorry
theorem rt_p136 {M : Type u_1} {α : Type u_2} [CommMonoid M] [MeasurableSpace M] [MeasurableMul₂ M] [MeasurableSpace α] {μ : MeasureTheory.Measure α} (s : Multiset (α → M)) (hs : ∀ f ∈ s, AEMeasurable f μ) : AEMeasurable (fun x => (s.map (fun f => f x)).prod) μ := by sorry
#rt pilot_p136 rt_p136

-- p137
theorem pilot_p137 {α : Type u_1} [MeasurableSpace α] [Div α] [DiscreteMeasurableSpace α] :
  MeasurableDiv α := by sorry
theorem rt_p137 (α : Type u) [Div α] [MeasurableSpace α] [DiscreteMeasurableSpace α] : MeasurableDiv α := by sorry
#rt pilot_p137 rt_p137

-- p140
theorem pilot_p140 {C : Type u₁} [CategoryTheory.Category C]
  {J : Type u} [CategoryTheory.Category J] {F : CategoryTheory.Functor J C} {c : CategoryTheory.Limits.Cone F}
  (hc : CategoryTheory.Limits.IsLimit c) (X : J) (hX : CategoryTheory.Limits.IsInitial X) :
  CategoryTheory.IsIso (c.π.app X) := by sorry
open CategoryTheory in theorem rt_p140 {C : Type u₁} [Category.{v₁} C] {J : Type u₂} [Category.{v₂} J] {F : J ⥤ C} (c : CategoryTheory.Limits.Cone F) (hc : CategoryTheory.Limits.IsLimit c) (X : J) (hX : CategoryTheory.Limits.IsInitial X) : CategoryTheory.IsIso (c.π.app X) := by sorry
#rt pilot_p140 rt_p140

-- p142
theorem pilot_p142 {α β γ : Type u} {t : Type u → Type u} [Traversable t] [LawfulTraversable t]
  {m : Type u → Type u} [Monad m] [LawfulMonad m] (g : β → γ) (f : α → γ → m α) (a : α) (l : t β) :
  Traversable.foldlM f a (g <$> l) = Traversable.foldlM (fun x y => f x (g y)) a l := by sorry
theorem rt_p142 {t : Type u → Type u} [Traversable t] [LawfulTraversable t] {m : Type u → Type u} [Monad m] [LawfulMonad m] {α β γ : Type u} (g : β → γ) (f : α → γ → m α) (a : α) (l : t β) : Traversable.foldlM f a (g <$> l) = Traversable.foldlM (fun x y => f x (g y)) a l := by sorry
#rt pilot_p142 rt_p142

-- p143
theorem pilot_p143 {ι : Type u_1} {α : Type u_2} {β : Type u_3} [LinearOrder α] [Semifield β]
  [LinearOrder β] [IsStrictOrderedRing β] {s : Set ι} {f : ι → α} {g₁ g₂ : ι → β} (hg₁ : ∀ i ∈ s, 0 ≤ g₁ i)
  (hg₂ : ∀ i ∈ s, 0 < g₂ i) (h₁ : MonovaryOn f g₁ s) (h₂ : AntivaryOn f g₂ s) : MonovaryOn f (g₁ / g₂) s := by sorry
theorem rt_p143 {ι : Type u_1} {α : Type u_2} {β : Type u_3} [LinearOrder α] [Semifield β] [LinearOrder β] [IsStrictOrderedRing β] {s : Set ι} {f : ι → α} {g₁ g₂ : ι → β} (h₁ : ∀ i ∈ s, 0 ≤ g₁ i) (h₂ : ∀ i ∈ s, 0 < g₂ i) (hf₁ : MonovaryOn f g₁ s) (hf₂ : AntivaryOn f g₂ s) : MonovaryOn f (g₁ / g₂) s := by sorry
#rt pilot_p143 rt_p143

-- p144
theorem pilot_p144 {b : EReal} (h : b < 0) (h' : b ≠ ⊥) : StrictAnti fun a => a / b := by sorry
theorem rt_p144 (b : EReal) (hb : b < 0) (hb' : b ≠ ⊥) : StrictAnti (fun a : EReal => a / b) := by sorry
#rt pilot_p144 rt_p144

-- p145
theorem pilot_p145 {𝕜 : Type u_1} {ι : Type u_2} {E : Type u_3}
  {F : Type u_4} [NormedField 𝕜] [Finite ι] [SeminormedAddCommGroup E] [NormedSpace 𝕜 E] [TopologicalSpace F]
  [AddCommGroup F] [IsTopologicalAddGroup F] [_root_.Module 𝕜 F] : ContinuousEval (E [⋀^ι]→L[𝕜] F) (ι → E) F := by sorry
theorem rt_p145 {𝕜 : Type u_1} {ι : Type u_2} {E : Type u_3} {F : Type u_4} [NormedField 𝕜] [Fintype ι] [SeminormedAddCommGroup E] [NormedSpace 𝕜 E] [TopologicalSpace F] [AddCommGroup F] [IsTopologicalAddGroup F] [Module 𝕜 F] : Continuous (fun p : (E [⋀^ι]→L[𝕜] F) × (ι → E) => p.1 p.2) := by sorry
#rt pilot_p145 rt_p145

-- p146
theorem pilot_p146 {α : Type u_2} {β : Type u_3} [SeminormedAddCommGroup α]
  [SeminormedAddCommGroup β] (x : WithLp 1 (α × β)) : ‖x‖₊ = ‖x.fst‖₊ + ‖x.snd‖₊ := by sorry
theorem rt_p146 {α : Type u_1} {β : Type u_2} [SeminormedAddCommGroup α] [SeminormedAddCommGroup β] (x : WithLp 1 (α × β)) : ‖x‖₊ = ‖(WithLp.ofLp x).1‖₊ + ‖(WithLp.ofLp x).2‖₊ := by sorry
#rt pilot_p146 rt_p146

-- p147
theorem pilot_p147 {R S : CommRingCat} (f : R ⟶ S) :
  AlgebraicGeometry.IsPreimmersion (AlgebraicGeometry.Spec.map f) ↔
    Topology.IsEmbedding (PrimeSpectrum.comap (CommRingCat.Hom.hom f)) ∧ (CommRingCat.Hom.hom f).SurjectiveOnStalks := by sorry
theorem rt_p147 {R : Type u} {S : Type v} [CommRing R] [CommRing S] (f : R →+* S) : AlgebraicGeometry.IsPreimmersion (AlgebraicGeometry.Scheme.Spec.map (CommRingCat.ofHom f).op) ↔ Topology.IsEmbedding (PrimeSpectrum.comap f) ∧ RingHom.SurjectiveOnStalks f := by sorry
#rt pilot_p147 rt_p147

-- p149
theorem pilot_p149 {P : CategoryTheory.MorphismProperty AlgebraicGeometry.Scheme}
  {Q : AlgebraicGeometry.AffineTargetMorphismProperty} [AlgebraicGeometry.HasAffineProperty P Q]
  {X Y : AlgebraicGeometry.Scheme} {f : X ⟶ Y} {UX UY : AlgebraicGeometry.Scheme} [AlgebraicGeometry.IsAffine UY]
  {iY : UY ⟶ Y} [AlgebraicGeometry.IsOpenImmersion iY] {iX : UX ⟶ X} {f' : UX ⟶ UY}
  (h : CategoryTheory.IsPullback iX f' f iY) (hf : P f) : Q f' := by sorry
open CategoryTheory AlgebraicGeometry in theorem rt_p149 (P : MorphismProperty Scheme.{u}) (Q : AffineTargetMorphismProperty.{u}) [HasAffineProperty P Q] {X Y U_X U_Y : Scheme.{u}} (f : X ⟶ Y) [IsAffine U_Y] (i_Y : U_Y ⟶ Y) [IsOpenImmersion i_Y] (i_X : U_X ⟶ X) (f' : U_X ⟶ U_Y) (h : CategoryTheory.IsPullback i_X f' f i_Y) (hf : P f) : Q f' := by sorry
#rt pilot_p149 rt_p149

-- p150
theorem pilot_p150
  (S : LightProfinite) (p : ↑S.toTop → Prop) :
  CompHausLike.HasProp (fun X => TotallyDisconnectedSpace ↑X ∧ SecondCountableTopology ↑X) (Subtype p) := by sorry
theorem rt_p150 (S : LightProfinite.{u}) (p : S → Prop) : TotallyDisconnectedSpace (Subtype p) ∧ SecondCountableTopology (Subtype p) := by sorry
#rt pilot_p150 rt_p150

-- p151
theorem pilot_p151 {K : Type u} [Field K] (n : ℕ) (a : K) :
  AdjoinRoot.root (Polynomial.X ^ n - Polynomial.C a) ^ n = (AdjoinRoot.of (Polynomial.X ^ n - Polynomial.C a)) a := by sorry
theorem rt_p151 {K : Type u} [Field K] (n : ℕ) (a : K) : AdjoinRoot.root (Polynomial.X ^ n - Polynomial.C a) ^ n = AdjoinRoot.of (Polynomial.X ^ n - Polynomial.C a) a := by sorry
#rt pilot_p151 rt_p151

-- p152
theorem pilot_p152 (F : Type u) (E : Type v) [Field F] [Field E] [Algebra F E] (K : Type w) [Field K]
  [Algebra F K] [Algebra E K] [IsScalarTower F E K] [h1 : IsPurelyInseparable F E] [h2 : IsPurelyInseparable E K] :
  IsPurelyInseparable F K := by sorry
theorem rt_p152 (F : Type u_1) (E : Type u_2) (K : Type u_3) [Field F] [Field E] [Field K] [Algebra F E] [Algebra F K] [Algebra E K] [IsScalarTower F E K] [IsPurelyInseparable F E] [IsPurelyInseparable E K] : IsPurelyInseparable F K := by sorry
#rt pilot_p152 rt_p152

-- p154
theorem pilot_p154 {α : Type u_1} {f : α → ℚ → ℝ}
  [MeasurableSpace α] (hf : ProbabilityTheory.IsMeasurableRatCDF f) (a : α) :
  Filter.Tendsto (↑(hf.stieltjesFunction a)) Filter.atBot (nhds 0) := by sorry
theorem rt_p154 {α : Type u} [MeasurableSpace α] {f : α → ℚ → ℝ} (hf : ProbabilityTheory.IsMeasurableRatCDF f) (a : α) : Filter.Tendsto (hf.stieltjesFunction a : ℝ → ℝ) Filter.atBot (𝓝 (0 : ℝ)) := by sorry
#rt pilot_p154 rt_p154

-- p155
theorem pilot_p155 {ι : Type u_1} {α : Type u_2}
  [ConditionallyCompleteLinearOrder α] {s : Multiset ι} (f : ι → α) (h : ∃ x ∈ s, SupSet.sSup ∅ ≤ f x) :
  ⨆ x ∈ s, f x ∈ Multiset.map f s := by sorry
theorem rt_p155 {ι : Type u_1} {α : Type u_2} [ConditionallyCompleteLinearOrder α] (s : Multiset ι) (f : ι → α) (h : ∃ x ∈ s, sSup (∅ : Set α) ≤ f x) : (⨆ x ∈ s, f x) ∈ s.map f := by sorry
#rt pilot_p155 rt_p155

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
open CategoryTheory CategoryTheory.Limits in theorem rt_p157 {F : LightProfinite.{u}ᵒᵖ ⥤ Type u} (hF : ∀ S : LightProfinite.{u}, IsColimit (F.mapCocone (coconeRightOpOfCone S.asLimitCone))) (S : LightProfinite.{u}ᵒᵖ) : (LightCondensed.lanPresheafNatIso hF).hom.app S = colimit.desc _ (F.mapCocone (CostructuredArrow.cocone FintypeCat.toLightProfinite.op S)) := by sorry
#rt pilot_p157 rt_p157

-- p158
theorem pilot_p158 {C : Type u₁} [CategoryTheory.Category C]
  {D : Type u₂} [CategoryTheory.Category D] (F : CategoryTheory.Functor Cᵒᵖ Dᵒᵖ)
  [CategoryTheory.Limits.PreservesFiniteLimits F] : CategoryTheory.Limits.PreservesFiniteColimits F.unop := by sorry
theorem rt_p158 {C : Type u₁} {D : Type u₂} [CategoryTheory.Category.{v₁} C] [CategoryTheory.Category.{v₂} D] (F : CategoryTheory.Opposite C ⥤ CategoryTheory.Opposite D) [CategoryTheory.Limits.PreservesFiniteLimits F] : CategoryTheory.Limits.PreservesFiniteColimits F.unop := by sorry
#rt pilot_p158 rt_p158

-- p159
theorem pilot_p159 {k G : Type u} [CommRing k] [Group G] {A : Rep k G} (g : G)
  (a : ↑A) (ha : a ∈ A.ρ.invariants) : (fun₀ | g => a) ∈ groupHomology.cycles₁ A := by sorry
theorem rt_p159 {k G : Type u} [CommRing k] [Group G] (A : Rep.{u} k G) (g : G) (a : A) (ha : ∀ h : G, A.ρ h a = a) : Finsupp.single g a ∈ groupHomology.cycles₁ A := by sorry
#rt pilot_p159 rt_p159

-- p160
theorem pilot_p160 {X Y : AlgebraicGeometry.Scheme} (f : X ⟶ Y) [IsEmpty ↥X] :
  AlgebraicGeometry.IsOpenImmersion f := by sorry
open CategoryTheory in theorem rt_p160 {X Y : AlgebraicGeometry.Scheme.{u}} [IsEmpty X] (f : X ⟶ Y) : AlgebraicGeometry.IsOpenImmersion f := by sorry
#rt pilot_p160 rt_p160

-- p162
theorem pilot_p162 {R : Type u_1} {M : Type u_2} [DivisionRing R] [LinearOrder R]
  [IsOrderedRing R] [AddCommGroup M] [_root_.Module R M] {C F : PointedCone R M} (h₁ : F ≤ C)
  (h₂ : ∀ {x y : M}, x ∈ C → y ∈ C → x + y ∈ F → x ∈ F) : F.IsFaceOf C := by sorry
theorem rt_p162 {R : Type u} {M : Type v} [DivisionRing R] [LinearOrder R] [IsOrderedRing R] [AddCommGroup M] [Module R M] (C F : PointedCone R M) (hFC : F ≤ C) (hF : ∀ x ∈ C, ∀ y ∈ C, x + y ∈ F → x ∈ F) : PointedCone.IsFaceOf F C := by sorry
#rt pilot_p162 rt_p162

-- p163
theorem pilot_p163 {F : Type u_1} [Field F] [DecidableEq F] (v : Projectivization F (Fin 3 → F)) :
  v.cross v = v := by sorry
theorem rt_p163 {F : Type u_1} [Field F] [DecidableEq F] (v : Projectivization F (Fin 3 → F)) : Projectivization.cross v v = v := by sorry
#rt pilot_p163 rt_p163

-- p164
theorem pilot_p164 (G : Type u_2) [LinearOrderedCommGroupWithZero G]
  [Nontrivial Gˣ] [MulArchimedean G] : Nonempty (G ≃*o WithZero (Multiplicative ℤ)) ∨ DenselyOrdered G := by sorry
theorem rt_p164 (G : Type u) [CommGroupWithZero G] [LinearOrder G] [IsOrderedMonoid G] [ZeroLEOneClass G] [Nontrivial (Units G)] [MulArchimedean G] : Nonempty (G ≃*o WithZero (Multiplicative ℤ)) ∨ DenselyOrdered G := by sorry
#rt pilot_p164 rt_p164

-- p165
theorem pilot_p165 {R : Type u₁} {S : Type u₂} [CommRing R]
  [CommRing S] [Algebra R S] {T : Type u₃} [CommRing T] [Algebra R T] [Algebra S T] [IsScalarTower R S T] {ι : Type w₁}
  {σ : Type w₂} {τ : Type w₅} (Q : Algebra.Generators S T ι) (P : Algebra.Generators R S σ)
  (W : Algebra.Generators R T τ) (f : W.Hom Q) :
  Function.Exact ⇑(Algebra.Extension.H1Cotangent.map f.toExtensionHom) ⇑(Algebra.Generators.H1Cotangent.δ Q P) := by sorry
theorem rt_p165 {R : Type u₁} {S : Type u₂} {T : Type u₃} [CommRing R] [CommRing S] [CommRing T] [Algebra R S] [Algebra R T] [Algebra S T] [IsScalarTower R S T] {ι : Type u_1} {σ : Type u_2} {τ : Type u_3} (Q : Algebra.Generators S T ι) (P : Algebra.Generators R S σ) (W : Algebra.Generators R T τ) (f : W.Hom Q) : Function.Exact (Algebra.Extension.H1Cotangent.map f.toExtensionHom) (Algebra.Generators.H1Cotangent.δ (Q := Q) P) := by sorry
#rt pilot_p165 rt_p165

-- p166
theorem pilot_p166 {X : Type u_1} {Y : Type u_2} [TopologicalSpace X]
  [TopologicalSpace Y] {e e' : OpenPartialHomeomorph X Y} (h : Set.EqOn (↑e) (↑e') (e.source ∩ e'.source)) :
  e.restr e'.source ≈ e'.restr e.source := by sorry
theorem rt_p166 {X : Type u_1} {Y : Type u_2} [TopologicalSpace X] [TopologicalSpace Y] (e e' : OpenPartialHomeomorph X Y) (h : Set.EqOn e e' (e.source ∩ e'.source)) : e.restr e'.source ≈ e'.restr e.source := by sorry
#rt pilot_p166 rt_p166

-- p167
theorem pilot_p167 {X : Type u_1} {Y : Type u_2} [TopologicalSpace X] {f : X → Y} [Preorder X]
  [TopologicalSpace Y] [Zero Y] [Inv Y] [ContinuousInv₀ Y] (hf : IsRightContinuous f) (h : ∀ (x : X), f x ≠ 0) :
  IsRightContinuous f⁻¹ := by sorry
theorem rt_p167 {X : Type u_1} {Y : Type u_2} [Preorder X] [TopologicalSpace X] [TopologicalSpace Y] [Zero Y] [Inv Y] [ContinuousInv₀ Y] {f : X → Y} (hf : IsRightContinuous f) (hzero : ∀ x, f x ≠ 0) : IsRightContinuous (fun x => (f x)⁻¹) := by sorry
#rt pilot_p167 rt_p167

-- p168
theorem pilot_p168 {R : Type u_1} {M : Type u_3} {N : Type u_4} {M' : Type u_6}
  {N' : Type u_7} [CommSemiring R] [AddCommMonoid M] [_root_.Module R M] [AddCommMonoid N] [_root_.Module R N]
  [AddCommMonoid M'] [_root_.Module R M'] [AddCommMonoid N'] [_root_.Module R N'] (f : M →ₗ[R] M') (g : N →ₗ[R] N') :
  ↑(TensorProduct.comm R M' N') ∘ₗ TensorProduct.map f g = TensorProduct.map g f ∘ₗ ↑(TensorProduct.comm R M N) := by sorry
theorem rt_p168 {R : Type u} {M : Type v} {N : Type w} {M' : Type u₁} {N' : Type u₂} [CommSemiring R] [AddCommMonoid M] [Module R M] [AddCommMonoid N] [Module R N] [AddCommMonoid M'] [Module R M'] [AddCommMonoid N'] [Module R N'] (f : M →ₗ[R] M') (g : N →ₗ[R] N') : (TensorProduct.comm R M' N').toLinearMap.comp (TensorProduct.map f g) = (TensorProduct.map g f).comp (TensorProduct.comm R M N).toLinearMap := by sorry
#rt pilot_p168 rt_p168

-- p169
theorem pilot_p169 {M : Type u_1} {N : Type u_2} [MulOneClass M] [MulOneClass N] {F : Type u_4}
  [FunLike F M N] [mc : MonoidHomClass F M N] {f : F} {S : Submonoid N} (h : S ≤ MonoidHom.mrange f) :
  Submonoid.map f (Submonoid.comap f S) = S := by sorry
theorem rt_p169 {M : Type u} {N : Type v} [MulOneClass M] [MulOneClass N] {F : Type w} [FunLike F M N] [MonoidHomClass F M N] (f : F) (S : Submonoid N) (h : (S : Set N) ⊆ Set.range f) : (S.comap f).map f = S := by sorry
#rt pilot_p169 rt_p169

-- p170
theorem pilot_p170 {α : Type u_1} {β : Type u_2} {σ : Type u_4} {φ : Type u_5} {n : ℕ}
  {x : α} {y : β} {s : σ} (xs : List.Vector α n) (ys : List.Vector β n) {f : α → β → σ → σ × φ} :
  List.Vector.mapAccumr₂ f (x ::ᵥ xs) (y ::ᵥ ys) s =
    have r := List.Vector.mapAccumr₂ f xs ys s;
    have q := f x y r.1;
    (q.1, q.2 ::ᵥ r.2) := by sorry
theorem rt_p170 {α : Type u_1} {β : Type u_2} {σ : Type u_3} {φ : Type u_4} {n : ℕ} (f : α → β → σ → σ × φ) (x : α) (y : β) (s : σ) (xs : List.Vector α n) (ys : List.Vector β n) : List.Vector.mapAccumr₂ f (List.Vector.cons x xs) (List.Vector.cons y ys) s = (let r := List.Vector.mapAccumr₂ f xs ys s; let q := f x y r.1; (q.1, List.Vector.cons q.2 r.2)) := by sorry
#rt pilot_p170 rt_p170

-- p171
theorem pilot_p171 {C : Type u} [CategoryTheory.Category C] {D : Type u''}
  [CategoryTheory.Category D] [CategoryTheory.Limits.HasPullbacks C] [CategoryTheory.FinitaryExtensive C] :
  CategoryTheory.FinitaryExtensive (CategoryTheory.Functor D C) := by sorry
open CategoryTheory in theorem rt_p171 {C : Type u_1} [Category.{v_1} C] {D : Type u_2} [Category.{v_2} D] [CategoryTheory.Limits.HasPullbacks C] [FinitaryExtensive C] : FinitaryExtensive (D ⥤ C) := by sorry
#rt pilot_p171 rt_p171

-- p173
theorem pilot_p173 {V : Type u_1} [CategoryTheory.Category V]
  {W : Type u_2} [CategoryTheory.Category W] (F : CategoryTheory.Functor V W) (G : Type u_3) [Monoid G] [F.Faithful] :
  (F.mapAction G).Faithful := by sorry
open CategoryTheory in theorem rt_p173 {V : Type u_1} {W : Type u_2} [Category.{v₁} V] [Category.{v₂} W] (F : V ⥤ W) [F.Faithful] (G : Type u_3) [Monoid G] : (CategoryTheory.Functor.mapAction F G).Faithful := by sorry
#rt pilot_p173 rt_p173

-- p174
theorem pilot_p174 {𝕜 : Type u_1} [NontriviallyNormedField 𝕜] {E : Type u_2}
  [NormedAddCommGroup E] [NormedSpace 𝕜 E] [NormedSpace ℝ E] [h : IsRCLikeNormedField 𝕜] {s : Set E} (hs : Convex ℝ s) :
  Convex ℝ s := by sorry
theorem rt_p174 {𝕜 : Type u_1} {E : Type u_2} [NontriviallyNormedField 𝕜] [RCLike 𝕜] [NormedAddCommGroup E] [NormedSpace 𝕜 E] [NormedSpace ℝ E] (s : Set E) (hs : Convex ℝ s) : letI : NormedSpace ℝ E := NormedSpace.restrictScalars ℝ 𝕜 E; Convex ℝ s := by sorry
#rt pilot_p174 rt_p174

-- p175
theorem pilot_p175 (F : Type u) (E : Type v) [Field F] [Field E] [Algebra F E]
  {S : Set E} : Algebra.IsSeparable F ↥(IntermediateField.adjoin F S) ↔ ∀ x ∈ S, IsSeparable F x := by sorry
theorem rt_p175 {F : Type u} {E : Type v} [Field F] [Field E] [Algebra F E] (S : Set E) : Algebra.IsSeparable F (IntermediateField.adjoin F S) ↔ ∀ x ∈ S, IsSeparable F x := by sorry
#rt pilot_p175 rt_p175

-- p176
theorem pilot_p176 {X : Type u_1} [TopologicalSpace X] [ContractibleSpace X] :
  PathConnectedSpace X := by sorry
theorem rt_p176 (X : Type u_1) [TopologicalSpace X] [ContractibleSpace X] : PathConnectedSpace X := by sorry
#rt pilot_p176 rt_p176

-- p178
theorem pilot_p178 {C : Type u} [CategoryTheory.Category C] {f g : C} (η : f ⟶ g) :
  η =
    CategoryTheory.CategoryStruct.comp (CategoryTheory.Iso.refl f).hom
      (CategoryTheory.CategoryStruct.comp η (CategoryTheory.Iso.refl g).hom) := by sorry
open CategoryTheory in theorem rt_p178 {C : Type u} [Category.{v} C] {f g : C} (η : f ⟶ g) : η = (Iso.refl f).hom ≫ η ≫ (Iso.refl g).hom := by sorry
#rt pilot_p178 rt_p178

-- p180
theorem pilot_p180 {b : NNReal} (hb : 0 < b) : ∃ n, 0 < n ∧ (↑n)⁻¹ < b := by sorry
theorem rt_p180 (b : ℝ≥0) (hb : 0 < b) : ∃ n : ℕ, 0 < n ∧ (n : ℝ≥0)⁻¹ < b := by sorry
#rt pilot_p180 rt_p180

-- p182
theorem pilot_p182 : (compHausToTop.op.comp topCatOpToFrm).Faithful := by sorry
open CategoryTheory in theorem rt_p182 : ((forget₂ CompHaus.{u} TopCat.{u}).op ⋙ topCatOpToFrm).Faithful := by sorry
#rt pilot_p182 rt_p182

-- p183
theorem pilot_p183 {R : Type u_1} [NonAssocRing R] [LinearOrder R] [IsOrderedAddMonoid R] [Archimedean R]
  {p : R} (hp : 0 < p) (a b : R) (m : ℤ) : toIocMod hp a (↑m * p + b) = toIocMod hp a b := by sorry
theorem rt_p183 {R : Type u_1} [NonAssocRing R] [LinearOrder R] [IsOrderedAddMonoid R] [Archimedean R] {p : R} (hp : 0 < p) (a b : R) (m : ℤ) : toIocMod hp a ((m : R) * p + b) = toIocMod hp a b := by sorry
#rt pilot_p183 rt_p183

-- p184
theorem pilot_p184 {R : Type u} [CommRing R] {S : Type v}
  [CommRing S] [Algebra R S] [IsDedekindDomain S] [IsDomain R] [Module.IsTorsionFree R S] {S₀ : Type u_2} [CommRing S₀]
  [Algebra R S₀] [Algebra S₀ S] [IsScalarTower R S₀ S] (p : Ideal R) (P : Ideal S₀) (Q : Ideal S) [Q.LiesOver p]
  [hP : P.LiesOver p] [Q.IsPrime] (hp : p ≠ ⊥) : P.ramificationIdx' Q ≤ p.ramificationIdx' Q := by sorry
theorem rt_p184 {R : Type u} {S : Type v} {S₀ : Type w} [CommRing R] [IsDomain R] [CommRing S] [IsDomain S] [IsDedekindDomain S] [Algebra R S] [Module.IsTorsionFree R S] [CommRing S₀] [Algebra R S₀] [Algebra S₀ S] [IsScalarTower R S₀ S] (p : Ideal R) (P : Ideal S₀) (Q : Ideal S) (hp : p ≠ ⊥) [Q.IsPrime] (hQ : Ideal.comap (algebraMap R S) Q = p) (hP : Ideal.comap (algebraMap R S₀) P = p) : Ideal.ramificationIdx' P Q ≤ Ideal.ramificationIdx' p Q := by sorry
#rt pilot_p184 rt_p184

-- p185
theorem pilot_p185 {α : Type u_1} {M : Matroid α} {X : Set α} (h : M.IsRkFinite X) :
  ∃ I, M.IsBasis' I X ∧ I.Finite := by sorry
theorem rt_p185 {α : Type u_1} (M : Matroid α) (X : Set α) (hX : M.IsRkFinite X) : ∃ I : Set α, M.IsBasis I X ∧ I.Finite := by sorry
#rt pilot_p185 rt_p185

-- p186
theorem pilot_p186 (z : UpperHalfPlane) : UpperHalfPlane.denom 1 ↑z = 1 := by sorry
theorem rt_p186 (z : UpperHalfPlane) : UpperHalfPlane.denom 1 (z : ℂ) = 1 := by sorry
#rt pilot_p186 rt_p186
