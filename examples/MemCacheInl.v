Require Import Ex.MemCache Kami.Notations Kami.Syntax Kami.Semantics Kami.SemFacts Kami.RefinementFacts.
Require Import Kami.ParametricEquiv Kami.ParametricInline String Kami.ParametricInlineLtac.
Require Import Kami.ParametricSyntax Lib.CommonTactics Lib.Reflection Kami.Tactics List Ex.Names Lib.Indexer Ex.RegFile.
Require Import Ex.L1Cache Ex.MemDir Ex.ChildParent.

Set Implicit Arguments.

Open Scope string.

Ltac simplMod :=
  match goal with
    | m :=
  ?modM: MetaModule |- _ =>
  let mEq := fresh "mEq" in
  let HeqmEq := fresh "HeqmEq" in
  remember m as mEq;
    unfold m in HeqmEq;
    clear m;
    cbv [inlineGenGenDm
           inlineGenSinDm inlineSinSinDm
           getGenGenBody
           getGenSinBody getSinSinBody
           appendGenGenAction appendSinSinAction appendSinGenAction
           convNameRec nameVal nameRec isRep projT1
           
           ChildParent.AddrBits ChildParent.Addr ChildParent.Idx ChildParent.Data
           ChildParent.Offset ChildParent.Line
           ChildParent.RqToP ChildParent.RqFromC ChildParent.RsToP ChildParent.RsFromC
           ChildParent.FromP ChildParent.ToC
           ChildParent.rqToPPop ChildParent.rqFromCEnq ChildParent.rsToPPop
           ChildParent.rsFromCEnq ChildParent.toCPop ChildParent.fromPEnq
           
           L1Cache.AddrBits L1Cache.Addr L1Cache.Tag L1Cache.Idx L1Cache.TagIdx
           L1Cache.Data L1Cache.Offset L1Cache.Line L1Cache.RqFromProc
           L1Cache.RsToProc L1Cache.FromP L1Cache.RqFromP L1Cache.RsFromP
           L1Cache.RqToP L1Cache.RsToP L1Cache.rqFromProcPop L1Cache.fromPPop
           L1Cache.rsToProcEnq L1Cache.rqToPEnq L1Cache.rsToPEnq L1Cache.lineRead
           L1Cache.lineWrite L1Cache.tagRead L1Cache.tagWrite
           L1Cache.csRead L1Cache.csWrite

           MemCache.MIdxBits

           MemDir.AddrBits MemDir.Addr MemDir.Idx MemDir.Data MemDir.Offset
           MemDir.Line
           MemDir.RqToP MemDir.RqFromC MemDir.RsToP
           MemDir.RsFromC MemDir.FromP MemDir.ToC
           MemDir.rqFromCPop MemDir.rsFromCPop MemDir.toCEnq MemDir.Dir MemDir.Dirw
           MemDir.lineRead MemDir.lineWrite MemDir.dirRead
           MemDir.dirWrite MemDir.Child

           MemTypes.MemOp MemTypes.Child MemTypes.Data MemTypes.Line MemTypes.RqToP
           MemTypes.RsToP MemTypes.RqFromC MemTypes.RsFromC MemTypes.ToC MemTypes.FromP

           Msi.Msi RegFile.Addr StringEq.string_eq StringEq.ascii_eq Bool.eqb andb

           eq_rect ret arg

        ] in HeqmEq;
    rewrite signature_eq in HeqmEq; unfold eq_rect in HeqmEq;
    simpl in HeqmEq;
    match type of HeqmEq with
      | ?sth = ?m => pose m; clear sth HeqmEq
    end
  end.

Ltac simplifyMod :=
  match goal with
    | mRef:
        modFromMeta _
                    <<== modFromMeta ?m,
        mEquiv: forall ty, MetaModEquiv ty typeUT ?m |- _ =>
      unfold m in mRef, mEquiv;
  clear m;
  cbv [inlineGenGenDm
         inlineGenSinDm inlineSinSinDm
         getGenGenBody
         getGenSinBody getSinSinBody
         appendGenGenAction appendSinSinAction appendSinGenAction
         convNameRec nameVal nameRec isRep projT1
         
         ChildParent.AddrBits ChildParent.Addr ChildParent.Idx ChildParent.Data
         ChildParent.Offset ChildParent.Line
         ChildParent.RqToP ChildParent.RqFromC ChildParent.RsToP ChildParent.RsFromC
         ChildParent.FromP ChildParent.ToC
         ChildParent.rqToPPop ChildParent.rqFromCEnq ChildParent.rsToPPop
         ChildParent.rsFromCEnq ChildParent.toCPop ChildParent.fromPEnq
         
         L1Cache.AddrBits L1Cache.Addr L1Cache.Tag L1Cache.Idx L1Cache.TagIdx
         L1Cache.Data L1Cache.Offset L1Cache.Line L1Cache.RqFromProc
         L1Cache.RsToProc L1Cache.FromP L1Cache.RqFromP L1Cache.RsFromP
         L1Cache.RqToP L1Cache.RsToP L1Cache.rqFromProcPop L1Cache.fromPPop
         L1Cache.rsToProcEnq L1Cache.rqToPEnq L1Cache.rsToPEnq L1Cache.lineRead
         L1Cache.lineWrite L1Cache.tagRead L1Cache.tagWrite
         L1Cache.csRead L1Cache.csWrite

         MemCache.MIdxBits

         MemDir.AddrBits MemDir.Addr MemDir.Idx MemDir.Data MemDir.Offset
         MemDir.Line
         MemDir.RqToP MemDir.RqFromC MemDir.RsToP
         MemDir.RsFromC MemDir.FromP MemDir.ToC
         MemDir.rqFromCPop MemDir.rsFromCPop MemDir.toCEnq MemDir.Dir MemDir.Dirw
         MemDir.lineRead MemDir.lineWrite MemDir.dirRead
         MemDir.dirWrite MemDir.Child

         MemTypes.MemOp MemTypes.Child MemTypes.Data MemTypes.Line MemTypes.RqToP
         MemTypes.RsToP MemTypes.RqFromC MemTypes.RsFromC MemTypes.ToC MemTypes.FromP

         Msi.Msi RegFile.Addr StringEq.string_eq StringEq.ascii_eq Bool.eqb andb

         eq_rect ret arg

      ] in mRef, mEquiv;
  rewrite signature_eq in mRef, mEquiv; unfold eq_rect in mRef, mEquiv;
  simpl in mRef, mEquiv
end;
  match goal with
    | mRef:
        modFromMeta _
                    <<== modFromMeta ?m,
        mEquiv: forall ty, MetaModEquiv ty typeUT ?m |- _ =>
      let newm := fresh in
      pose m as newm;
        fold newm in mRef;
        fold newm in mEquiv
  end.


Ltac noFilt ltac dm r :=
  match goal with
    | mRef:
        modFromMeta _
                    <<== modFromMeta ?m,
        mEquiv: forall ty, MetaModEquiv ty typeUT ?m |- _ =>
      ltac dm r;
        match goal with
          | m'Ref:
              modFromMeta ?m <<== modFromMeta ?m',
              m'Equiv: forall ty, MetaModEquiv ty typeUT ?m' |- _ =>
            apply (traceRefines_trans_elem mRef) in m'Ref; clear mRef;
            let newm := fresh in
            pose m' as newm;
              fold newm in m'Ref;
              fold newm in m'Equiv;
              simpl in newm; clear m mEquiv
        end
  end; simplifyMod.

Ltac ggNoFilt dm r := noFilt inlineGenDmGenRule_NoFilt dm r.
Ltac gsNoFilt dm r := noFilt inlineSinDmGenRule_NoFilt dm r.
Ltac ssNoFilt dm r := noFilt inlineSinDmSinRule_NoFilt dm r.

Ltac ggFilt dm r := noFilt inlineGenDmGenRule_Filt dm r.
Ltac gsFilt dm r := noFilt inlineSinDmGenRule_Filt dm r.
Ltac ssFilt dm r := noFilt inlineSinDmSinRule_Filt dm r.


Ltac ggNoF dm r :=
  match goal with
    | m := {| metaRegs :=?rgs; metaRules := ?rls; metaMeths := ?mts |} |- _ =>
           let dmTriple := find dm (@nil MetaMeth) mts in
           let rTriple := find r (@nil MetaRule) rls in
           match dmTriple with
             | (?preDm, @RepMeth ?A ?strA ?goodFn ?GenK ?getConstK
                                 ?goodFn2 ?bdm ?dmn ?ls ?noDup, ?sufDm) =>
               match rTriple with
                 | (?preR, @RepRule ?A ?strA ?goodFn ?GenK ?getConstK
                                    ?goodFn2 ?bdr ?rn ?ls ?noDup, ?sufR) =>
                   pose
                     {| metaRegs := rgs;
                        metaRules := preR ++
                                          RepRule strA goodFn getConstK goodFn2
                                          (fun ty =>
                                             inlineGenGenDm
                                               (bdr ty)
                                               (nameVal dmn) bdm) rn noDup :: sufR;
                        metaMeths := mts |}; clear m
               end
           end
  end; simplMod.

Ltac ggF dm r :=
  match goal with
    | m := {| metaRegs :=?rgs; metaRules := ?rls; metaMeths := ?mts |} |- _ =>
           let dmTriple := find dm (@nil MetaMeth) mts in
           let rTriple := find r (@nil MetaRule) rls in
           match dmTriple with
             | (?preDm, @RepMeth ?A ?strA ?goodFn ?GenK ?getConstK
                                 ?goodFn2 ?bdm ?dmn ?ls ?noDup, ?sufDm) =>
               match rTriple with
                 | (?preR, @RepRule ?A ?strA ?goodFn ?GenK ?getConstK
                                    ?goodFn2 ?bdr ?rn ?ls ?noDup, ?sufR) =>
                   pose
                     {| metaRegs := rgs;
                        metaRules := preR ++
                                          RepRule strA goodFn getConstK goodFn2
                                          (fun ty =>
                                             inlineGenGenDm
                                               (bdr ty)
                                               (nameVal dmn) bdm) rn noDup :: sufR;
                        metaMeths := preDm ++ sufDm |}; clear m
               end
           end
  end; simplMod.

Ltac gsNoF dm r :=
  match goal with
    | m := {| metaRegs :=?rgs; metaRules := ?rls; metaMeths := ?mts |} |- _ =>
           let dmTriple := find dm (@nil MetaMeth) mts in
           let rTriple := find r (@nil MetaRule) rls in
           match dmTriple with
             | (?preDm, @OneMeth ?bdm ?dmn, ?sufDm) =>
               match rTriple with
                 | (?preR, @RepRule ?A ?strA ?goodFn ?GenK ?getConstK
                                    ?goodFn2 ?bdr ?rn ?ls ?noDup, ?sufR) =>
                   pose
                     {| metaRegs := rgs;
                        metaRules := preR ++
                                          RepRule strA goodFn getConstK goodFn2
                                          (fun ty =>
                                             inlineGenSinDm
                                               (bdr ty)
                                               (nameVal dmn) bdm) rn noDup :: sufR;
                        metaMeths := mts |}; clear m
               end
           end
  end.

Ltac gsF dm r :=
  match goal with
    | m := {| metaRegs :=?rgs; metaRules := ?rls; metaMeths := ?mts |} |- _ =>
           let dmTriple := find dm (@nil MetaMeth) mts in
           let rTriple := find r (@nil MetaRule) rls in
           match dmTriple with
             | (?preDm, @OneMeth ?bdm ?dmn, ?sufDm) =>
               match rTriple with
                 | (?preR, @RepRule ?A ?strA ?goodFn ?GenK ?getConstK
                                    ?goodFn2 ?bdr ?rn ?ls ?noDup, ?sufR) =>
                   pose
                     {| metaRegs := rgs;
                        metaRules := preR ++
                                          RepRule strA goodFn getConstK goodFn2
                                          (fun ty =>
                                             inlineGenSinDm
                                               (bdr ty)
                                               (nameVal dmn) bdm) rn noDup :: sufR;
                        metaMeths := preDm ++ sufDm |}; clear m
               end
           end
  end; simplMod.

Ltac ssNoF dm r :=
  match goal with
    | m := {| metaRegs :=?rgs; metaRules := ?rls; metaMeths := ?mts |} |- _ =>
           let dmTriple := find dm (@nil MetaMeth) mts in
           let rTriple := find r (@nil MetaRule) rls in
           match dmTriple with
             | (?preDm, @OneMeth ?bdm ?dmn, ?sufDm) =>
               match rTriple with
                 | (?preR, @OneRule ?bdr ?rn, ?sufR) =>
                   pose
                     {| metaRegs := rgs;
                        metaRules := preR ++
                                          OneRule
                                          (fun ty =>
                                             inlineSinSinDm
                                               (bdr ty)
                                               (nameVal dmn) bdm) rn :: sufR;
                        metaMeths := mts |}; clear m
               end
           end
  end; simplMod.

Ltac ssF dm r :=
  match goal with
    | m := {| metaRegs :=?rgs; metaRules := ?rls; metaMeths := ?mts |} |- _ =>
           let dmTriple := find dm (@nil MetaMeth) mts in
           let rTriple := find r (@nil MetaRule) rls in
           match dmTriple with
             | (?preDm, @OneMeth ?bdm ?dmn, ?sufDm) =>
               match rTriple with
                 | (?preR, @OneRule ?bdr ?rn, ?sufR) =>
                   pose
                     {| metaRegs := rgs;
                        metaRules := preR ++
                                          OneRule
                                          (fun ty =>
                                             inlineSinSinDm
                                               (bdr ty)
                                               (nameVal dmn) bdm) rn :: sufR;
                        metaMeths := preDm ++ sufDm |}; clear m
               end
           end
  end; simplMod.

Ltac start_def m := let mod := fresh in pose m as mod; cbv [m] in mod.

Ltac finish_def :=
  match goal with
    | m := ?mod: MetaModule |- _ =>
           cbv [NativeFifo.listEltK NativeFifo.listEnq NativeFifo.listEltT] in m;
             simpl in m; clear -m;
             exact mod
  end.


Ltac start_pf2 m mpf :=
  let mod := fresh in
  let pf1 := fresh in
  let pf2 := fresh in
  pose m as mod;
    pose proof mpf as [pf1 pf2];
    fold mod in pf1, pf2;
    cbv [m] in mod.

Ltac finish_pf :=
  match goal with
    | mRef:
        modFromMeta _
                    <<== modFromMeta ?m,
        mEquiv: forall ty, MetaModEquiv ty typeUT ?m |- _ =>
      (abstract exact (conj mRef mEquiv))
  end.





Section MemCacheInl.
  Variables IdxBits TagBits LgNumDatas DataBytes: nat.
  Variable Id: Kind.

  Variable LgNumChildren: nat.

  Definition nmemCacheInl_flat: MetaModule.
  Proof.
    pose (nmemCache IdxBits TagBits LgNumDatas DataBytes Id LgNumChildren) as m;

    cbv [
        ChildParent.childParent

          Fifo.fifo Fifo.simpleFifo
          Fifo.fifoS Fifo.simpleFifoS

          FifoCorrect.fifo FifoCorrect.nfifo

          L1Cache.l1Cache l1 l1cs l1tag l1line l1Cache childParent

          MemCache.memDir MemCache.mline MemCache.mdir MemCache.memDirC MemCache.memCache
          MemCache.nl1C MemCache.nfifoRqFromC MemCache.nfifoRsFromC MemCache.nfifoToC
          MemCache.nchildParentC MemCache.nmemCache

          MemDir.memDir

          NativeFifo.nativeFifo NativeFifo.nativeSimpleFifo NativeFifo.nativeFifoS
          NativeFifo.nativeSimpleFifoS NativeFifo.nativeFifoM
          NativeFifo.nativeSimpleFifoM
        
          makeMetaModule
          getMetaFromSinNat makeSinModule getMetaFromSin
          sinRegs sinRules sinMeths rulesToRep regsToRep methsToRep
          convSinToGen concatMetaMod app metaRegs
          metaRules metaMeths

          ChildParent.AddrBits ChildParent.Addr ChildParent.Idx ChildParent.Data
          ChildParent.Offset ChildParent.Line
          ChildParent.RqToP ChildParent.RqFromC ChildParent.RsToP ChildParent.RsFromC
          ChildParent.FromP ChildParent.ToC
          ChildParent.rqToPPop ChildParent.rqFromCEnq ChildParent.rsToPPop
          ChildParent.rsFromCEnq ChildParent.toCPop ChildParent.fromPEnq
          
          L1Cache.AddrBits L1Cache.Addr L1Cache.Tag L1Cache.Idx L1Cache.TagIdx
          L1Cache.Data L1Cache.Offset L1Cache.Line L1Cache.RqFromProc
          L1Cache.RsToProc L1Cache.FromP L1Cache.RqFromP L1Cache.RsFromP
          L1Cache.RqToP L1Cache.RsToP L1Cache.rqFromProcPop L1Cache.fromPPop
          L1Cache.rsToProcEnq L1Cache.rqToPEnq L1Cache.rsToPEnq L1Cache.lineRead
          L1Cache.lineWrite L1Cache.tagRead L1Cache.tagWrite L1Cache.csRead L1Cache.csWrite

          L1Cache.RqFromProc L1Cache.rqFromProcFirst

          MemCache.MIdxBits

          MemDir.AddrBits MemDir.Addr MemDir.Idx MemDir.Data MemDir.Offset MemDir.Line
          MemDir.RqToP MemDir.RqFromC MemDir.RsToP MemDir.RsFromC MemDir.FromP MemDir.ToC
          MemDir.rqFromCPop MemDir.rsFromCPop MemDir.toCEnq MemDir.Dir MemDir.Dirw
          MemDir.lineRead MemDir.lineWrite MemDir.dirRead MemDir.dirWrite MemDir.Child

          MemTypes.MemOp MemTypes.Child MemTypes.Data MemTypes.Line
          MemTypes.RsToP MemTypes.RqFromC MemTypes.RsFromC MemTypes.ToC

          RegFile.regFileM RegFile.regFileS RegFile.regFile

          nfifoRqToP nfifoRsToP nfifoFromP

          String.append

          fullType

          ret arg

          projT1 projT2

          Lib.VectorFacts.Vector_find
      ] in m.
    simpl in m;
    unfold Lib.VectorFacts.Vector_find in m;
    simpl in m.

    finish_def.
  Defined.

  Theorem nmemCacheInl_flat_pf:
    (modFromMeta (nmemCache IdxBits TagBits LgNumDatas
                            DataBytes Id LgNumChildren) <<== modFromMeta nmemCacheInl_flat) /\
    forall ty, MetaModEquiv ty typeUT nmemCacheInl_flat.
  Proof.
    (* SKIP_PROOF_ON
    assert (mRef: modFromMeta
                    (nmemCache IdxBits TagBits LgNumDatas DataBytes Id LgNumChildren)
                    <<== modFromMeta nmemCacheInl_flat) by
        (abstract (cbv [nmemCacheInl_flat]; unfold MethsT;
                   rewrite @idElementwiseId; apply traceRefines_refl)).
    assert (mEquiv: forall ty, MetaModEquiv ty typeUT nmemCacheInl_flat)
      by (abstract (cbv [nmemCacheInl_flat];
                    kequiv)).

    finish_pf.
        END_SKIP_PROOF_ON *) apply cheat.

  Qed.

  Definition nmemCacheInl_1_1: MetaModule.
  Proof.
    start_def nmemCacheInl_flat.

    ssF (mline -- read) deferred.
  
    ssNoF (mcs -- read) missByState.
    ssNoF (mcs -- read) dwnRq.
    ssNoF (mcs -- read) dwnRs_wait.
    ssNoF (mcs -- read) dwnRs_noWait.
    ssF (mcs -- read) deferred.
    finish_def.
  Defined.

  Definition nmemCacheInl_1_2: MetaModule.
  Proof.
    start_def nmemCacheInl_1_1.

    ssNoF (mline -- write) dwnRs_wait.
    ssF (mline -- write) dwnRs_noWait.

    ssNoF (mcs -- write) dwnRs_wait.
    ssNoF (mcs -- write) dwnRs_noWait.
    ssF (mcs -- write) deferred.

    finish_def.
  Defined.

  Theorem nmemCacheInl_1_1_pf:
    (modFromMeta (nmemCache IdxBits TagBits LgNumDatas
                            DataBytes Id LgNumChildren) <<== modFromMeta nmemCacheInl_1_1) /\
    forall ty, MetaModEquiv ty typeUT nmemCacheInl_1_1.
  Proof.
    (* SKIP_PROOF_ON
    start_pf2 nmemCacheInl_flat nmemCacheInl_flat_pf.
    
    ssFilt (mline -- read) deferred.
  
    ssNoFilt (mcs -- read) missByState.
    ssNoFilt (mcs -- read) dwnRq.
    ssNoFilt (mcs -- read) dwnRs_wait.
    ssNoFilt (mcs -- read) dwnRs_noWait.
    ssFilt (mcs -- read) deferred.
    finish_pf.
       END_SKIP_PROOF_ON *) apply cheat.
  Qed.


  Theorem nmemCacheInl_1_2_pf:
    (modFromMeta (nmemCache IdxBits TagBits LgNumDatas
                            DataBytes Id LgNumChildren) <<== modFromMeta nmemCacheInl_1_2) /\
    forall ty, MetaModEquiv ty typeUT nmemCacheInl_1_2.
  Proof.
    (* SKIP_PROOF_ON
    start_pf2 nmemCacheInl_1_1 nmemCacheInl_1_1_pf.
    
    ssNoFilt (mline -- write) dwnRs_wait.
    ssFilt (mline -- write) dwnRs_noWait.

    ssNoFilt (mcs -- write) dwnRs_wait.
    ssNoFilt (mcs -- write) dwnRs_noWait.
    ssFilt (mcs -- write) deferred.

    finish_pf.
       END_SKIP_PROOF_ON *) apply cheat.
  Qed.

  Definition nmemCacheInl_2: MetaModule.
  Proof.

    start_def nmemCacheInl_1_2.
    ssNoF (toChild -- enqName) dwnRq.
    ssF (toChild -- enqName) deferred.

    ssNoF (rqFromChild -- firstEltName) missByState.
    ssF (rqFromChild -- firstEltName) dwnRq.
    
    ssF (rqFromChild -- deqName) deferred.

    ssNoF (rsFromChild -- deqName) dwnRs_wait.
    ssF (rsFromChild -- deqName) dwnRs_noWait.

    finish_def.
  Defined.

  Theorem nmemCacheInl_2_pf:
    (modFromMeta (nmemCache IdxBits TagBits LgNumDatas
                            DataBytes Id LgNumChildren) <<== modFromMeta nmemCacheInl_2) /\
    forall ty, MetaModEquiv ty typeUT nmemCacheInl_2.
  Proof.
    (* SKIP_PROOF_ON

    start_pf2 nmemCacheInl_1_2 nmemCacheInl_1_2_pf.

    ssNoFilt (toChild -- enqName) dwnRq.
    ssFilt (toChild -- enqName) deferred.

    ssNoFilt (rqFromChild -- firstEltName) missByState.
    ssFilt (rqFromChild -- firstEltName) dwnRq.
    
    ssFilt (rqFromChild -- deqName) deferred.

    ssNoFilt (rsFromChild -- deqName) dwnRs_wait.
    ssFilt (rsFromChild -- deqName) dwnRs_noWait.
    finish_pf.
        END_SKIP_PROOF_ON *) apply cheat.
  Qed.

  Definition nmemCacheInl_3: MetaModule.
  Proof.

    start_def nmemCacheInl_2.
    
    gsF (rsFromChild -- enqName) rsFromCToPRule.

    gsF (rqFromChild -- enqName) rqFromCToPRule.
    
    gsF (toChild -- deqName) fromPToCRule.

    finish_def.
  Defined.

  Theorem nmemCacheInl_3_pf:
    (modFromMeta (nmemCache IdxBits TagBits LgNumDatas
                            DataBytes Id LgNumChildren) <<== modFromMeta nmemCacheInl_3) /\
    forall ty, MetaModEquiv ty typeUT nmemCacheInl_3.
  Proof.
    (* SKIP_PROOF_ON

    start_pf2 nmemCacheInl_2 nmemCacheInl_2_pf.

    gsFilt (rsFromChild -- enqName) rsFromCToPRule.

    gsFilt (rqFromChild -- enqName) rqFromCToPRule.
    
    gsFilt (toChild -- deqName) fromPToCRule.

    finish_pf.
        END_SKIP_PROOF_ON *) apply cheat.
  Qed.
  

  
  Definition nmemCacheInl_4: MetaModule.
  Proof.
    start_def nmemCacheInl_3.

    ggNoF (cs -- read) l1MissByState.
    ggNoF (cs -- read) l1MissByLine.
    ggNoF (cs -- read) l1Hit.
    ggNoF (cs -- read) writeback.
    ggNoF (cs -- read) upgRq.
    ggNoF (cs -- read) upgRs.

    finish_def.
  Defined.

  Definition nmemCacheInl_4_5: MetaModule.
  Proof.
    start_def nmemCacheInl_4.
    
    ggNoF (cs -- read) ld.
    ggNoF (cs -- read) st.
    ggNoF (cs -- read) drop.
    ggF (cs -- read) pProcess.

    finish_def.
  Defined.

  Theorem nmemCacheInl_4_pf:
    (modFromMeta (nmemCache IdxBits TagBits LgNumDatas
                            DataBytes Id LgNumChildren) <<== modFromMeta nmemCacheInl_4) /\
    forall ty, MetaModEquiv ty typeUT nmemCacheInl_4.
  Proof.
    (* SKIP_PROOF_ON

    start_pf2 nmemCacheInl_3 nmemCacheInl_3_pf.

    ggNoFilt (cs -- read) l1MissByState.
    ggNoFilt (cs -- read) l1MissByLine.
    ggNoFilt (cs -- read) l1Hit.
    ggNoFilt (cs -- read) writeback.
    ggNoFilt (cs -- read) upgRq.
    ggNoFilt (cs -- read) upgRs.

    finish_pf.
        END_SKIP_PROOF_ON *) apply cheat.
  Qed.
    
  Theorem nmemCacheInl_4_5_pf:
    (modFromMeta (nmemCache IdxBits TagBits LgNumDatas
                            DataBytes Id LgNumChildren) <<== modFromMeta nmemCacheInl_4_5) /\
    forall ty, MetaModEquiv ty typeUT nmemCacheInl_4_5.
  Proof.
    (* SKIP_PROOF_ON
    start_pf2 nmemCacheInl_4 nmemCacheInl_4_pf.

    ggNoFilt (cs -- read) ld.
    ggNoFilt (cs -- read) st.
    ggNoFilt (cs -- read) drop.
    ggFilt (cs -- read) pProcess.

    finish_pf.
       END_SKIP_PROOF_ON *) apply cheat.
  Qed.
End MemCacheInl.

Section MemCacheInl2.

  Variables IdxBits TagBits LgNumDatas DataBytes: nat.
  Variable Id: Kind.

  Variable LgNumChildren: nat.

  Definition nmemCacheInl_4_5': MetaModule.
  Proof.
    pose (nmemCacheInl_4_5 IdxBits TagBits LgNumDatas DataBytes Id LgNumChildren) as sth.
    unfold nmemCacheInl_4_5 in sth.
    match goal with
      | m := ?mod |- _ => exact mod
    end.
  Defined.

  Theorem nmemCacheInl_4_5'_pf:
    (modFromMeta (nmemCache IdxBits TagBits LgNumDatas
                            DataBytes Id LgNumChildren) <<== modFromMeta nmemCacheInl_4_5') /\
    forall ty, MetaModEquiv ty typeUT nmemCacheInl_4_5'.
  Proof.
    (* SKIP_PROOF_ON
    eapply nmemCacheInl_4_5_pf; eauto.
        END_SKIP_PROOF_ON *) apply cheat.
  Qed.
  

  
  Definition nmemCacheInl_5: MetaModule.
  Proof.
    start_def nmemCacheInl_4_5'.

    ggNoF (tag -- read) l1MissByState.
    ggNoF (tag -- read) l1MissByLine.
    ggNoF (tag -- read) l1Hit.
    ggNoF (tag -- read) writeback.
    ggNoF (tag -- read) upgRq.
    ggNoF (tag -- read) ld.
    ggNoF (tag -- read) st.
    ggNoF (tag -- read) drop.
    ggF (tag -- read) pProcess.

    finish_def.
  Defined.

  Theorem nmemCacheInl_5_pf:
    (modFromMeta (nmemCache IdxBits TagBits LgNumDatas
                            DataBytes Id LgNumChildren) <<== modFromMeta nmemCacheInl_5) /\
    forall ty, MetaModEquiv ty typeUT nmemCacheInl_5.
  Proof.
    (* SKIP_PROOF_ON
    start_pf2 nmemCacheInl_4_5' nmemCacheInl_4_5'_pf.

    ggNoFilt (tag -- read) l1MissByState.
    ggNoFilt (tag -- read) l1MissByLine.
    ggNoFilt (tag -- read) l1Hit.
    ggNoFilt (tag -- read) writeback.
    ggNoFilt (tag -- read) upgRq.
    ggNoFilt (tag -- read) ld.
    ggNoFilt (tag -- read) st.
    ggNoFilt (tag -- read) drop.
    ggFilt (tag -- read) pProcess.

    finish_pf.
        END_SKIP_PROOF_ON *) apply cheat.
  Qed.
End MemCacheInl2.
  
Section MemCacheInl3.

  Variables IdxBits TagBits LgNumDatas DataBytes: nat.
  Variable Id: Kind.

  Variable LgNumChildren: nat.

  Definition nmemCacheInl_5': MetaModule.
  Proof.
    pose (nmemCacheInl_5 IdxBits TagBits LgNumDatas DataBytes Id LgNumChildren) as sth.
    unfold nmemCacheInl_5 in sth.
    match goal with
      | m := ?mod |- _ => exact mod
    end.
  Defined.

  Theorem nmemCacheInl_5'_pf:
    (modFromMeta (nmemCache IdxBits TagBits LgNumDatas
                            DataBytes Id LgNumChildren) <<== modFromMeta nmemCacheInl_5') /\
    forall ty, MetaModEquiv ty typeUT nmemCacheInl_5'.
  Proof.
    (* SKIP_PROOF_ON
    eapply nmemCacheInl_5_pf; eauto.
        END_SKIP_PROOF_ON *) apply cheat.
  Qed.
  

  Definition nmemCacheInl_6: MetaModule.
  Proof.
    start_def nmemCacheInl_5'.
    ggNoF (line -- read) writeback.
    ggNoF (line -- read) ld.
    ggNoF (line -- read) st.
    ggF (line -- read) pProcess.
    finish_def.
  Defined.

  Definition nmemCacheInl_6_3: MetaModule.
  Proof.
    start_def nmemCacheInl_6.
    ggNoF (cs -- write) writeback.
    ggNoF (cs -- write) upgRs.
    finish_def.
  Defined.

  Definition nmemCacheInl_6_6: MetaModule.
  Proof.
    start_def nmemCacheInl_6_3.
    ggF (cs -- write) pProcess.

    finish_def.
  Defined.

  Theorem nmemCacheInl_6_pf:
    (modFromMeta (nmemCache IdxBits TagBits LgNumDatas
                            DataBytes Id LgNumChildren) <<== modFromMeta nmemCacheInl_6) /\
    forall ty, MetaModEquiv ty typeUT nmemCacheInl_6.
  Proof.
    (* SKIP_PROOF_ON
    start_pf2 nmemCacheInl_5' nmemCacheInl_5'_pf.
    
    ggNoFilt (line -- read) writeback.
    ggNoFilt (line -- read) ld.
    ggNoFilt (line -- read) st.
    ggFilt (line -- read) pProcess.
    finish_pf.
        END_SKIP_PROOF_ON *) apply cheat.
  Qed.

  Theorem nmemCacheInl_6_3_pf:
    (modFromMeta (nmemCache IdxBits TagBits LgNumDatas
                            DataBytes Id LgNumChildren) <<== modFromMeta nmemCacheInl_6_3) /\
    forall ty, MetaModEquiv ty typeUT nmemCacheInl_6_3.
  Proof.
    (* SKIP_PROOF_ON
    start_pf2 nmemCacheInl_6 nmemCacheInl_6_pf.
    
    ggNoFilt (cs -- write) writeback.
    ggNoFilt (cs -- write) upgRs.

    finish_pf.
        END_SKIP_PROOF_ON *) apply cheat.
  Qed.

  Theorem nmemCacheInl_6_6_pf:
    (modFromMeta (nmemCache IdxBits TagBits LgNumDatas
                            DataBytes Id LgNumChildren) <<== modFromMeta nmemCacheInl_6_6) /\
    forall ty, MetaModEquiv ty typeUT nmemCacheInl_6_6.
  Proof.
    (* SKIP_PROOF_ON
    start_pf2 nmemCacheInl_6_3 nmemCacheInl_6_3_pf.
    
    ggFilt (cs -- write) pProcess.
    finish_pf.
        END_SKIP_PROOF_ON *) apply cheat.
  Qed.
End MemCacheInl3.
  
Section MemCacheInl4.

  Variables IdxBits TagBits LgNumDatas DataBytes: nat.
  Variable Id: Kind.

  Variable LgNumChildren: nat.

  Definition nmemCacheInl_6_6': MetaModule.
  Proof.
    pose (nmemCacheInl_6_6 IdxBits TagBits LgNumDatas DataBytes Id LgNumChildren) as sth.
    unfold nmemCacheInl_6_6 in sth.
    match goal with
      | m := ?mod |- _ => exact mod
    end.
  Defined.

  Theorem nmemCacheInl_6_6'_pf:
    (modFromMeta (nmemCache IdxBits TagBits LgNumDatas
                            DataBytes Id LgNumChildren) <<== modFromMeta nmemCacheInl_6_6') /\
    forall ty, MetaModEquiv ty typeUT nmemCacheInl_6_6'.
  Proof.
    (* SKIP_PROOF_ON
    eapply nmemCacheInl_6_6_pf; eauto.
        END_SKIP_PROOF_ON *) apply cheat.
  Qed.
  

  Definition nmemCacheInl_7: MetaModule.
  Proof.
    start_def nmemCacheInl_6_6'.
    ggF (tag -- write) upgRs.
    finish_def.
  Defined.

  Definition nmemCacheInl_7_3: MetaModule.
  Proof.
    start_def nmemCacheInl_7.
    ggNoF (line -- write) upgRs.
    ggF (line -- write) st.
    finish_def.
  Defined.
  
  Definition nmemCacheInl_7_7: MetaModule.
  Proof.
    start_def nmemCacheInl_7_3.

    ggNoF (fromParent -- deqName) upgRs.
    ggNoF (fromParent -- deqName) drop.
    ggF (fromParent -- deqName) pProcess.
    finish_def.
  Defined.

  Theorem nmemCacheInl_7_pf:
    (modFromMeta (nmemCache IdxBits TagBits LgNumDatas
                            DataBytes Id LgNumChildren) <<== modFromMeta nmemCacheInl_7) /\
    forall ty, MetaModEquiv ty typeUT nmemCacheInl_7.
  Proof.
    (* SKIP_PROOF_ON
    start_pf2 nmemCacheInl_6_6' nmemCacheInl_6_6'_pf.
    ggFilt (tag -- write) upgRs.
    finish_pf.
        END_SKIP_PROOF_ON *) apply cheat.
  Qed.

  Theorem nmemCacheInl_7_3_pf:
    (modFromMeta (nmemCache IdxBits TagBits LgNumDatas
                            DataBytes Id LgNumChildren) <<== modFromMeta nmemCacheInl_7_3) /\
    forall ty, MetaModEquiv ty typeUT nmemCacheInl_7_3.
  Proof.
    (* SKIP_PROOF_ON
    start_pf2 nmemCacheInl_7 nmemCacheInl_7_pf.
    ggNoFilt (line -- write) upgRs.
    ggFilt (line -- write) st.
    finish_pf.
        END_SKIP_PROOF_ON *) apply cheat.
  Qed.

  Theorem nmemCacheInl_7_7_pf:
    (modFromMeta (nmemCache IdxBits TagBits LgNumDatas
                            DataBytes Id LgNumChildren) <<== modFromMeta nmemCacheInl_7_7) /\
    forall ty, MetaModEquiv ty typeUT nmemCacheInl_7_7.
  Proof.
    (* SKIP_PROOF_ON
    start_pf2 nmemCacheInl_7_3 nmemCacheInl_7_3_pf.
    ggNoFilt (fromParent -- deqName) upgRs.
    ggNoFilt (fromParent -- deqName) drop.
    ggFilt (fromParent -- deqName) pProcess.
    finish_pf.
        END_SKIP_PROOF_ON *) apply cheat.
  Qed.
End MemCacheInl4.

Section MemCacheInl5.
  Variables IdxBits TagBits LgNumDatas DataBytes: nat.
  Variable Id: Kind.

  Variable LgNumChildren: nat.

  Definition nmemCacheInl_7_7': MetaModule.
  Proof.
    pose (nmemCacheInl_7_7 IdxBits TagBits LgNumDatas DataBytes Id LgNumChildren) as sth.
    unfold nmemCacheInl_7_7 in sth.
    match goal with
      | m := ?mod |- _ => exact mod
    end.
  Defined.

  Theorem nmemCacheInl_7_7'_pf:
    (modFromMeta (nmemCache IdxBits TagBits LgNumDatas
                            DataBytes Id LgNumChildren) <<== modFromMeta nmemCacheInl_7_7') /\
    forall ty, MetaModEquiv ty typeUT nmemCacheInl_7_7'.
  Proof.
    (* SKIP_PROOF_ON
    eapply nmemCacheInl_7_7_pf; eauto.
        END_SKIP_PROOF_ON *) apply cheat.
  Qed.
  

  Definition nmemCacheInl_8: MetaModule.
  Proof.
    start_def nmemCacheInl_7_7'.
    ggF (rqToParent -- enqName) upgRq.
    finish_def.
  Defined.

  Definition nmemCacheInl_9: MetaModule.
  Proof.
    start_def nmemCacheInl_8.
    ggNoF (rsToParent -- enqName) writeback.
    ggF (rsToParent -- enqName) pProcess.
    finish_def.
  Defined.

  Definition nmemCacheInl_10: MetaModule.
  Proof.
    start_def nmemCacheInl_9.
    ggF (rqToParent -- deqName) rqFromCToPRule.
    finish_def.
  Defined.
    
  Definition nmemCacheInl_11: MetaModule.
  Proof.
    start_def nmemCacheInl_10.
    ggF (rsToParent -- deqName) rsFromCToPRule.
    finish_def.
  Defined.

  
  Definition nmemCacheInl: MetaModule.
  Proof.
    start_def nmemCacheInl_11.
    ggF (fromParent -- enqName) fromPToCRule.
    finish_def.
  Defined.

  Theorem nmemCacheInl_8_pf:
    (modFromMeta (nmemCache IdxBits TagBits LgNumDatas
                            DataBytes Id LgNumChildren) <<== modFromMeta nmemCacheInl_8) /\
    forall ty, MetaModEquiv ty typeUT nmemCacheInl_8.
  Proof.
    (* SKIP_PROOF_ON
    start_pf2 nmemCacheInl_7_7' nmemCacheInl_7_7'_pf.
    ggFilt (rqToParent -- enqName) upgRq.
    finish_pf.
        END_SKIP_PROOF_ON *) apply cheat.
  Qed.

  Theorem nmemCacheInl_9_pf:
    (modFromMeta (nmemCache IdxBits TagBits LgNumDatas
                            DataBytes Id LgNumChildren) <<== modFromMeta nmemCacheInl_9) /\
    forall ty, MetaModEquiv ty typeUT nmemCacheInl_9.
  Proof.
    (* SKIP_PROOF_ON
    start_pf2 nmemCacheInl_8 nmemCacheInl_8_pf.
    ggNoFilt (rsToParent -- enqName) writeback.
    ggFilt (rsToParent -- enqName) pProcess.
    finish_pf.
        END_SKIP_PROOF_ON *) apply cheat.
  Qed.

  Theorem nmemCacheInl_10_pf:
    (modFromMeta (nmemCache IdxBits TagBits LgNumDatas
                            DataBytes Id LgNumChildren) <<== modFromMeta nmemCacheInl_10) /\
    forall ty, MetaModEquiv ty typeUT nmemCacheInl_10.
  Proof.
    (* SKIP_PROOF_ON
    start_pf2 nmemCacheInl_9 nmemCacheInl_9_pf.
    ggFilt (rqToParent -- deqName) rqFromCToPRule.
    finish_pf.
        END_SKIP_PROOF_ON *) apply cheat.
  Qed.
  
  Theorem nmemCacheInl_11_pf:
    (modFromMeta (nmemCache IdxBits TagBits LgNumDatas
                            DataBytes Id LgNumChildren) <<== modFromMeta nmemCacheInl_11) /\
    forall ty, MetaModEquiv ty typeUT nmemCacheInl_11.
  Proof.
    (* SKIP_PROOF_ON
    start_pf2 nmemCacheInl_10 nmemCacheInl_10_pf.
    ggFilt (rsToParent -- deqName) rsFromCToPRule.
    finish_pf.
        END_SKIP_PROOF_ON *) apply cheat.
  Qed.

  Theorem nmemCacheInl_pf:
    (modFromMeta (nmemCache IdxBits TagBits LgNumDatas
                            DataBytes Id LgNumChildren) <<== modFromMeta nmemCacheInl) /\
    forall ty, MetaModEquiv ty typeUT nmemCacheInl.
  Proof.
    (* SKIP_PROOF_ON
    start_pf2 nmemCacheInl_11 nmemCacheInl_11_pf.
    ggFilt (fromParent -- enqName) fromPToCRule.
    finish_pf.
        END_SKIP_PROOF_ON *) apply cheat.
  Qed.
End MemCacheInl5.

Close Scope string.
