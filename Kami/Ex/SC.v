Require Import Ascii Bool String List.
Require Import Lib.CommonTactics Lib.Indexer Lib.ilist Lib.Word Lib.Struct.
Require Import Kami.Syntax Kami.Notations.
Require Import Kami.Semantics Kami.Specialize Kami.Duplicate.
Require Import Kami.Wf Kami.Tactics.
Require Import Ex.MemTypes.

Set Implicit Arguments.

(* The SC module is defined as follows: SC = n * Pinst + Minst,
 * where Pinst denotes an instantaneous processor core
 * and Minst denotes an instantaneous memory.
 *)

(* Abstract ISA *)
Section DecExec.
  Variables opIdx addrSize iaddrSize instBytes dataBytes rfIdx: nat.

  Definition Pc := Bit (2 + iaddrSize).
  
  (* opcode-related *)
  Definition OpcodeK := SyntaxKind (Bit opIdx).
  Definition OpcodeE (ty: Kind -> Type) := Expr ty OpcodeK.
  Definition OpcodeT := forall ty, fullType ty (SyntaxKind (Data instBytes)) -> OpcodeE ty.

  Definition opLd := WO~0~0.
  Definition opSt := WO~0~1.
  Definition opNm := WO~1~1.
  
  Definition OptypeK := SyntaxKind (Bit 2).
  Definition OptypeE (ty: Kind -> Type) := Expr ty OptypeK.
  Definition OptypeT := forall ty, fullType ty (SyntaxKind (Data instBytes)) -> OptypeE ty.
  
  (* load-related *)
  Definition LdDstK := SyntaxKind (Bit rfIdx).
  Definition LdDstE (ty: Kind -> Type) := Expr ty LdDstK.
  Definition LdDstT := forall ty, fullType ty (SyntaxKind (Data instBytes)) -> LdDstE ty.

  Definition LdAddrK := SyntaxKind (Bit addrSize).
  Definition LdAddrE (ty: Kind -> Type) := Expr ty LdAddrK.
  Definition LdAddrT := forall ty, fullType ty (SyntaxKind (Data instBytes)) -> LdAddrE ty.

  Definition LdSrcK := SyntaxKind (Bit rfIdx).
  Definition LdSrcE (ty: Kind -> Type) := Expr ty LdSrcK.
  Definition LdSrcT := forall ty, fullType ty (SyntaxKind (Data instBytes)) -> LdSrcE ty.

  Definition f3Lb := WO~0~0~0.
  Definition f3Lh := WO~0~0~1.
  Definition f3Lw := WO~0~1~0.
  Definition f3Lbu := WO~1~0~0.
  Definition f3Lhu := WO~1~0~1.

  Definition LdTypeK := SyntaxKind (Bit 3).
  Definition LdTypeE (ty: Kind -> Type) := Expr ty LdTypeK.
  Definition LdTypeT := forall ty, fullType ty (SyntaxKind (Data instBytes)) -> LdTypeE ty.

  Definition LdAddrCalcT :=
    forall ty,
      fullType ty (SyntaxKind (Bit addrSize)) -> (* base address *)
      fullType ty (SyntaxKind (Data dataBytes)) -> (* offset value *)
      Expr ty (SyntaxKind (Bit addrSize)).

  Definition LdValCalcT :=
    forall ty,
      fullType ty (SyntaxKind (Bit addrSize)) -> (* requested address *)
      fullType ty (SyntaxKind (Data dataBytes)) (* loaded value *) ->
      fullType ty LdTypeK -> (* load type: lb, lh, lw, lbu, or lhu *)
      Expr ty (SyntaxKind (Data dataBytes)). (* calculated value *)

  (* store-related *)
  Definition StAddrK := SyntaxKind (Bit addrSize).
  Definition StAddrE (ty: Kind -> Type) := Expr ty StAddrK.
  Definition StAddrT := forall ty, fullType ty (SyntaxKind (Data instBytes)) -> StAddrE ty.
  
  Definition StSrcK := SyntaxKind (Bit rfIdx).
  Definition StSrcE (ty: Kind -> Type) := Expr ty StSrcK.
  Definition StSrcT := forall ty, fullType ty (SyntaxKind (Data instBytes)) -> StSrcE ty.

  Definition StAddrCalcT :=
    forall ty,
      fullType ty (SyntaxKind (Bit addrSize)) -> (* base address *)
      fullType ty (SyntaxKind (Data dataBytes)) -> (* offset value *)
      Expr ty (SyntaxKind (Bit addrSize)).

  Definition StVSrcK := SyntaxKind (Bit rfIdx).
  Definition StVSrcE (ty: Kind -> Type) := Expr ty StVSrcK.
  Definition StVSrcT := forall ty, fullType ty (SyntaxKind (Data instBytes)) -> StVSrcE ty.

  (* general sources *)
  Definition Src1K := SyntaxKind (Bit rfIdx).
  Definition Src1E (ty: Kind -> Type) := Expr ty Src1K.
  Definition Src1T := forall ty, fullType ty (SyntaxKind (Data instBytes)) -> Src1E ty.

  Definition Src2K := SyntaxKind (Bit rfIdx).
  Definition Src2E (ty: Kind -> Type) := Expr ty Src2K.
  Definition Src2T := forall ty, fullType ty (SyntaxKind (Data instBytes)) -> Src2E ty.

  (* general destination *)
  Definition DstK := SyntaxKind (Bit rfIdx).
  Definition DstE (ty: Kind -> Type) := Expr ty DstK.
  Definition DstT := forall ty, fullType ty (SyntaxKind (Data instBytes)) -> DstE ty.
  
  (* execution *)
  Definition StateK := SyntaxKind (Vector (Data dataBytes) rfIdx).
  Definition StateT (ty : Kind -> Type) := fullType ty StateK.
  Definition StateE (ty : Kind -> Type) := Expr ty StateK.

  Definition ExecT := forall ty, fullType ty (SyntaxKind (Data dataBytes)) -> (* val1 *)
                                 fullType ty (SyntaxKind (Data dataBytes)) -> (* val2 *)
                                 fullType ty (SyntaxKind Pc) -> (* pc *)
                                 fullType ty (SyntaxKind (Data instBytes)) -> (* rawInst *)
                                 Expr ty (SyntaxKind (Data dataBytes)). (* executed value *)
  Definition NextPcT := forall ty, StateT ty -> (* rf *)
                                   fullType ty (SyntaxKind Pc) -> (* pc *)
                                   fullType ty (SyntaxKind (Data instBytes)) -> (* rawInst *)
                                   Expr ty (SyntaxKind Pc). (* next pc *)
  Definition AlignAddrT := forall ty, fullType ty (SyntaxKind (Bit iaddrSize)) ->
                                      Expr ty (SyntaxKind (Bit addrSize)).
  Definition AlignInstT := forall ty, fullType ty (SyntaxKind (Data dataBytes)) -> (* loaded word *)
                                      Expr ty (SyntaxKind (Data instBytes)). (* aligned inst. *)

  Class AbsFetch :=
    { alignAddr: AlignAddrT;
      alignInst: AlignInstT
    }.
  
  Class AbsDec :=
    { getOptype: OptypeT;
      getLdDst: LdDstT;
      getLdAddr: LdAddrT;
      getLdSrc: LdSrcT;
      calcLdAddr: LdAddrCalcT;
      getLdType: LdTypeT;
      getStAddr: StAddrT;
      getStSrc: StSrcT;
      calcStAddr: StAddrCalcT;
      getStVSrc: StVSrcT;
      getSrc1: Src1T;
      getSrc2: Src2T;
      getDst: DstT
    }.

  Class AbsExec :=
    { calcLdVal: LdValCalcT;
      doExec: ExecT;
      getNextPc: NextPcT
    }.

  Class AbsIsa :=
    { fetch: AbsFetch;
      dec: AbsDec;
      exec: AbsExec
    }.
  
End DecExec.

Hint Unfold Pc OpcodeK OpcodeE OpcodeT OptypeK OptypeE OptypeT opLd opSt opNm
     LdDstK LdDstE LdDstT LdAddrK LdAddrE LdAddrT LdSrcK LdSrcE LdSrcT LdAddrCalcT
     LdTypeK LdTypeE LdTypeT f3Lb f3Lh f3Lw f3Lbu f3Lhu LdValCalcT
     StAddrK StAddrE StAddrT StSrcK StSrcE StSrcT StAddrCalcT StVSrcK StVSrcE StVSrcT
     Src1K Src1E Src1T Src2K Src2E Src2T
     StateK StateE StateT ExecT NextPcT AlignAddrT AlignInstT : MethDefs.

(* The module definition for Minst with n ports *)
Section MemInst.
  Variable addrSize : nat.
  Variable dataBytes : nat.

  Definition RqFromProc := RqFromProc dataBytes (Bit addrSize).
  Definition RsToProc := RsToProc dataBytes.

  Definition MemInit := ConstT (Vector (Bit BitsPerByte) addrSize).
  
  Variable (memInit: MemInit).

  Definition memOp := MethodSig "memOp"(Struct RqFromProc) : Struct RsToProc.

  (* NOTE: it's little endian *)
  Fixpoint memLoadBytes {ty} (n: nat) (addr: Expr ty (SyntaxKind (Bit addrSize)))
           (mem: Expr ty (SyntaxKind (Vector (Bit BitsPerByte) addrSize))):
    Expr ty (SyntaxKind (Bit (n * BitsPerByte))) :=
    (match n with
     | 0 => $$WO
     | S n' => {memLoadBytes n' (addr + $1) mem, mem@[addr]}
     end)%kami_expr.

  (* NOTE: it's little endian as well *)
  Fixpoint memStoreBytes {ty} (n: nat) (addr: Expr ty (SyntaxKind (Bit addrSize)))
           (val: Expr ty (SyntaxKind (Bit (n * BitsPerByte))))
           (mem: Expr ty (SyntaxKind (Vector (Bit BitsPerByte) addrSize))):
    Expr ty (SyntaxKind (Vector (Bit BitsPerByte) addrSize)) :=
    (match n as n0 return
           ((Bit (n0 * BitsPerByte))@ty ->
            (Vector (Bit BitsPerByte) addrSize)@ty)
     with
     | 0 => fun _ => mem
     | S n' =>
       fun val0 =>
         memStoreBytes
           n' (addr + $1)
           (UniBit (TruncLsb BitsPerByte (n' * BitsPerByte)) val0)
           (mem@[addr <- UniBit (Trunc BitsPerByte (n' * BitsPerByte)) val0])
     end val)%kami_expr.

  (* For semantic uses *)
  Fixpoint combineBytes (n: nat) (addr: word addrSize)
           (mem: word addrSize -> word BitsPerByte): word (n * BitsPerByte) :=
    match n with
    | 0 => WO
    | S n' => combine (mem addr) (combineBytes n' (addr ^+ $1) mem)
    end.

  Fixpoint updateBytes (n: nat) (addr: word addrSize) (val: word (n * BitsPerByte))
           (mem: word addrSize -> word BitsPerByte): word addrSize -> word BitsPerByte :=
    (match n as n0 return
           (word (n0 * BitsPerByte) -> (word addrSize -> word BitsPerByte))
     with
     | 0 => fun _ => mem
     | S n' => fun val0 =>
                 updateBytes
                   n' (addr ^+ $1)
                   (split2 BitsPerByte (n' * BitsPerByte) val0)
                   (fun w =>
                      if weq w addr
                      then (split1 BitsPerByte (n' * BitsPerByte) val0)
                      else mem w)
     end) val.

  Definition memInst :=
    MODULE {
      Register "mem" : Vector (Bit BitsPerByte) addrSize <- memInit

      with Method "memOp" (a : Struct RqFromProc) : Struct RsToProc :=
        If !(#a!RqFromProc@."op") then (* load *)
          Read memv <- "mem";
          LET addr <- #a!RqFromProc@."addr";
          LET ldval <- memLoadBytes dataBytes #addr #memv;
          Ret (STRUCT { "data" ::= #ldval } :: Struct RsToProc)
        else (* store *)
          Read memv <- "mem";
          LET addr <- #a!RqFromProc@."addr";
          LET val <- #a!RqFromProc@."data";
          Write "mem" <- memStoreBytes dataBytes #addr #val #memv;
          Ret (STRUCT { "data" ::= $$Default } :: Struct RsToProc)
        as na;
        Ret #na
    }.
    
  Definition IsMMIOE (ty: Kind -> Type) := Expr ty (SyntaxKind Bool).
  Definition IsMMIOT :=
    forall ty, fullType ty (SyntaxKind (Bit addrSize)) -> IsMMIOE ty.

  Class AbsMMIO :=
    { isMMIO: IsMMIOT }.

  Variable (ammio: AbsMMIO).

  Definition mmioExec :=
    MethodSig "mmioExec"(Struct RqFromProc): Struct RsToProc.
  
  Definition mm :=
    MODULE {
      Register "mem" : Vector (Bit BitsPerByte) addrSize <- memInit

      with Method "memOp" (a : Struct RqFromProc): Struct RsToProc :=
        LET addr <- #a!RqFromProc@."addr";

        If (isMMIO _ addr) then (** mmio *)
          Call rs <- mmioExec(#a);
          Ret #rs
        else
          If !(#a!RqFromProc@."op") then (* load *)
            Read memv <- "mem";
            LET addr <- #a!RqFromProc@."addr";
            LET ldval <- memLoadBytes dataBytes #addr #memv;
            Ret (STRUCT { "data" ::= #ldval } :: Struct RsToProc)
          else (* store *)
            Read memv <- "mem";
            LET addr <- #a!RqFromProc@."addr";
            LET val <- #a!RqFromProc@."data";
            Write "mem" <- memStoreBytes dataBytes #addr #val #memv;
            Ret (STRUCT { "data" ::= $$Default } :: Struct RsToProc)
          as na;
          Ret #na
        as na;
        Ret #na
    }.
  
End MemInst.

Hint Unfold RqFromProc RsToProc memOp IsMMIOE IsMMIOT mmioExec: MethDefs.
Hint Unfold memInst mm: ModuleDefs.

(* The module definition for Pinst *)
Section ProcInst.
  Variables addrSize iaddrSize instBytes dataBytes rfIdx : nat.

  Variables (fetch: AbsFetch addrSize iaddrSize instBytes dataBytes)
            (dec: AbsDec addrSize instBytes dataBytes rfIdx)
            (exec: AbsExec addrSize iaddrSize instBytes dataBytes rfIdx).

  Definition nextPc {ty} ppc st rawInst :=
    (Write "pc" <- getNextPc ty st ppc rawInst;
     Retv)%kami_action.

  Record ProcInit := { pcInit : ConstT (Pc iaddrSize);
                       rfInit : ConstT (Vector (Data dataBytes) rfIdx)
                     }.
  Definition procInitDefault :=
    {| pcInit := Default; rfInit := Default |}.

  Local Notation memOp := (memOp addrSize dataBytes).

  Variables (procInit: ProcInit).

  Definition procInst := MODULE {
    Register "pc" : Pc iaddrSize <- (pcInit procInit)
    with Register "rf" : Vector (Data dataBytes) rfIdx <- (rfInit procInit)

    with Register "pinit" : Bool <- Default
    with Register "pinitOfs" : Bit iaddrSize <- Default
    with Register "pgm" : Vector (Data instBytes) iaddrSize <- Default

    (** Phase 1: initialize the program [pinit == false] *)

    with Rule "pgmInit" :=
      Read pinit : Bool <- "pinit";
      Read pinitOfs : Bit iaddrSize <- "pinitOfs";
      Read pgm : Vector (Data instBytes) iaddrSize <- "pgm";
      Assert !#pinit;
      Assert ((UniBit (Inv _) #pinitOfs) != $0);

      Call ldData <- memOp(STRUCT { "addr" ::= alignAddr _ pinitOfs;
                                    "op" ::= $$false;
                                    "data" ::= $$Default });
      LET ldVal <- #ldData!(RsToProc dataBytes)@."data";
      LET inst <- alignInst _ ldVal;
      Write "pgm" <- #pgm@[#pinitOfs <- #inst];
      Write "pinitOfs" <- #pinitOfs + $1;
      Retv

    with Rule "pgmInitEnd" :=
      Read pinit : Bool <- "pinit";
      Read pinitOfs : Bit iaddrSize <- "pinitOfs";
      Read pgm : Vector (Data instBytes) iaddrSize <- "pgm";
      Assert !#pinit;
      Assert ((UniBit (Inv _) #pinitOfs) == $0);
      Call ldData <- memOp(STRUCT { "addr" ::= alignAddr _ pinitOfs;
                                    "op" ::= $$false;
                                    "data" ::= $$Default });
      LET ldVal <- #ldData!(RsToProc dataBytes)@."data";
      LET inst <- alignInst _ ldVal;
      Write "pgm" <- #pgm@[#pinitOfs <- #inst];
      Write "pinit" <- !#pinit;
      Write "pinitOfs" : Bit iaddrSize <- $0;
      Retv

    (** Phase 2: execute the program [pinit == true] *)
        
    with Rule "execLd" :=
      Read ppc : Pc iaddrSize <- "pc";
      Read rf : Vector (Data dataBytes) rfIdx <- "rf";
      Read pinit : Bool <- "pinit";
      Read pgm : Vector (Data instBytes) iaddrSize <- "pgm";
      Assert #pinit;
      LET rawInst <- #pgm@[_truncLsb_ #ppc];
      Assert (getOptype _ rawInst == $$opLd);
      LET dstIdx <- getLdDst _ rawInst;
      Assert (#dstIdx != $0);
      LET addr <- getLdAddr _ rawInst;
      LET srcIdx <- getLdSrc _ rawInst;
      LET srcVal <- #rf@[#srcIdx];
      LET laddr <- calcLdAddr _ addr srcVal;
      Call ldRep <- memOp(STRUCT { "addr" ::= #laddr;
                                   "op" ::= $$false;
                                   "data" ::= $$Default });
      LET ldValWord <- #ldRep!(RsToProc dataBytes)@."data";
      LET ldType <- getLdType _ rawInst;
      LET ldVal <- calcLdVal _ laddr ldValWord ldType;
      Write "rf" <- #rf@[#dstIdx <- #ldVal];
      nextPc ppc rf rawInst
             
    with Rule "execLdZ" :=
      Read ppc : Pc iaddrSize <- "pc";
      Read rf : Vector (Data dataBytes) rfIdx <- "rf";
      Read pinit : Bool <- "pinit";
      Read pgm : Vector (Data instBytes) iaddrSize <- "pgm";
      Assert #pinit;
      LET rawInst <- #pgm@[_truncLsb_ #ppc];
      Assert (getOptype _ rawInst == $$opLd);
      LET regIdx <- getLdDst _ rawInst;
      (* NOTE: no register update when the dst register is r0, 
       * but the memory call should be made. *)
      Assert (#regIdx == $0);
      LET addr <- getLdAddr _ rawInst;
      LET srcIdx <- getLdSrc _ rawInst;
      LET srcVal <- #rf@[#srcIdx];
      LET laddr <- calcLdAddr _ addr srcVal;
      Call memOp(STRUCT { "addr" ::= #laddr;
                          "op" ::= $$false;
                          "data" ::= $$Default });
      nextPc ppc rf rawInst

    with Rule "execSt" :=
      Read ppc : Pc iaddrSize <- "pc";
      Read rf : Vector (Data dataBytes) rfIdx <- "rf";
      Read pinit : Bool <- "pinit";
      Read pgm : Vector (Data instBytes) iaddrSize <- "pgm";
      Assert #pinit;
      LET rawInst <- #pgm@[_truncLsb_ #ppc];
      Assert (getOptype _ rawInst == $$opSt);
      LET addr <- getStAddr _ rawInst;
      LET srcIdx <- getStSrc _ rawInst;
      LET srcVal <- #rf@[#srcIdx];
      LET vsrcIdx <- getStVSrc _ rawInst;
      LET stVal <- #rf@[#vsrcIdx];
      LET saddr <- calcStAddr _ addr srcVal;
      Call memOp(STRUCT { "addr" ::= #saddr;
                          "op" ::= $$true;
                          "data" ::= #stVal });
      nextPc ppc rf rawInst

    with Rule "execNm" :=
      Read ppc : Pc iaddrSize <- "pc";
      Read rf : Vector (Data dataBytes) rfIdx <- "rf";
      Read pinit : Bool <- "pinit";
      Read pgm : Vector (Data instBytes) iaddrSize <- "pgm";
      Assert #pinit;
      LET rawInst <- #pgm@[_truncLsb_ #ppc];
      Assert (getOptype _ rawInst == $$opNm);
      LET src1 <- getSrc1 _ rawInst;
      LET val1 <- #rf@[#src1];
      LET src2 <- getSrc2 _ rawInst;
      LET val2 <- #rf@[#src2];
      LET dst <- getDst _ rawInst;
      Assert (#dst != $0);
      LET execVal <- doExec _ val1 val2 ppc rawInst;
      Write "rf" <- #rf@[#dst <- #execVal];
      nextPc ppc rf rawInst

    with Rule "execNmZ" :=
      Read ppc : Pc iaddrSize <- "pc";
      Read rf : Vector (Data dataBytes) rfIdx <- "rf";
      Read pinit : Bool <- "pinit";
      Read pgm : Vector (Data instBytes) iaddrSize <- "pgm";
      Assert #pinit;
      LET rawInst <- #pgm@[_truncLsb_ #ppc];
      Assert (getOptype _ rawInst == $$opNm);
      LET dst <- getDst _ rawInst;
      Assert (#dst == $0);
      nextPc ppc rf rawInst
  }.

End ProcInst.

Hint Unfold nextPc procInitDefault : MethDefs.
Hint Unfold procInst : ModuleDefs.

Section SC.
  Variables addrSize iaddrSize instBytes dataBytes rfIdx : nat.

  Variables (fetch: AbsFetch addrSize iaddrSize instBytes dataBytes)
            (dec: AbsDec addrSize instBytes dataBytes rfIdx)
            (exec: AbsExec addrSize iaddrSize instBytes dataBytes rfIdx)
            (ammio: AbsMMIO addrSize).

  Variable n: nat.

  Variables (procInit: ProcInit iaddrSize dataBytes rfIdx)
            (memInit: MemInit addrSize).

  Definition pinst := procInst fetch dec exec procInit.

  Definition scmm := ConcatMod pinst (mm dataBytes memInit ammio).

End SC.

Hint Unfold pinst scmm : ModuleDefs.

Section Facts.
  Variables addrSize iaddrSize instBytes dataBytes rfIdx : nat.

  Variables (fetch: AbsFetch addrSize iaddrSize instBytes dataBytes)
            (dec: AbsDec addrSize instBytes dataBytes rfIdx)
            (exec: AbsExec addrSize iaddrSize instBytes dataBytes rfIdx)
            (ammio: AbsMMIO addrSize).

  Lemma memLoadBytes_combineBytes:
    forall n (addr: (Bit addrSize)@type)
           (mem: (Vector (Bit BitsPerByte) addrSize)@type),
      evalExpr (memLoadBytes n addr mem) =
      combineBytes n (evalExpr addr) (evalExpr mem).
  Proof.
    induction n.
    - intros; reflexivity.
    - intros; simpl.
      rewrite IHn; reflexivity.
  Qed.

  Lemma memStoreBytes_updateBytes:
    forall n (addr: (Bit addrSize)@type)
           (val: (Bit (n * BitsPerByte))@type)
           (mem: (Vector (Bit BitsPerByte) addrSize)@type),
      evalExpr (memStoreBytes n addr val mem) =
      updateBytes n (evalExpr addr) (evalExpr val) (evalExpr mem).
  Proof.
    induction n.
    - intros; reflexivity.
    - intros; simpl.
      rewrite IHn; reflexivity.
  Qed.

  Lemma pinst_ModEquiv:
    forall init,
      ModPhoasWf (pinst fetch dec exec init).
  Proof.
    kequiv.
  Qed.
  Hint Resolve pinst_ModEquiv.

  Lemma memInst_ModEquiv:
    forall (init: MemInit addrSize),
      ModPhoasWf (memInst dataBytes init).
  Proof.
    kequiv.
  Qed.
  Hint Resolve memInst_ModEquiv.

  Lemma mm_ModEquiv:
    forall (init: MemInit addrSize),
      ModPhoasWf (mm dataBytes init ammio).
  Proof.
    kequiv.
  Qed.
  Hint Resolve mm_ModEquiv.

  Lemma scmm_ModEquiv:
    forall procInit memInit,
      ModPhoasWf (scmm fetch dec exec ammio procInit memInit).
  Proof.
    kequiv.
  Qed.
  
End Facts.

Hint Resolve pinst_ModEquiv memInst_ModEquiv mm_ModEquiv scmm_ModEquiv.

