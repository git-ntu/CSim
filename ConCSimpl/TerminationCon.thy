(*
    Author:      David Sanan
    Maintainer:  David Sanan, sanan at ntu edu sg
    License:     LGPL
*)

(*  Title:      TerminationCon.thy
    Author:     Norbert Schirmer, TU Muenchen
    Author:     David Sanan, NTU

Copyright (C) 2015-2016 David Sanan 
Some rights reserved, NTU
This library is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as
published by the Free Software Foundation; either version 2.1 of the
License, or (at your option) any later version.

This library is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
USA
*)

section {* Terminating Programs *}

theory TerminationCon imports SemanticCon "EmbSimpl.Termination" begin

subsection {* Inductive Characterisation: @{text "\<Gamma>\<turnstile>c\<down>s"}*}

inductive "terminates"::"('s,'p,'f,'e) body \<Rightarrow> ('s,'p,'f,'e) com \<Rightarrow> ('s,'f) xstate \<Rightarrow> bool"
  ("_\<turnstile>\<^sub>p_ \<down> _" [60,20,60] 89)
  for  \<Gamma>::"('s,'p,'f,'e) body"
where
  Skip: "\<Gamma>\<turnstile>\<^sub>pSkip \<down>(Normal s)"

| Basic: "\<Gamma>\<turnstile>\<^sub>pBasic f e \<down>(Normal s)"

| Spec: "\<Gamma>\<turnstile>\<^sub>pSpec r e \<down>(Normal s)"

| Guard: "\<lbrakk>s\<in>g; \<Gamma>\<turnstile>\<^sub>pc\<down>(Normal s)\<rbrakk> 
          \<Longrightarrow> 
          \<Gamma>\<turnstile>\<^sub>pGuard f g c\<down>(Normal s)"

| GuardFault: "s\<notin>g  
               \<Longrightarrow> 
               \<Gamma>\<turnstile>\<^sub>pGuard f g c\<down>(Normal s)"


| Fault [intro,simp]: "\<Gamma>\<turnstile>\<^sub>pc\<down>Fault f" 


| Seq: "\<lbrakk>\<Gamma>\<turnstile>\<^sub>pc\<^sub>1\<down>Normal s; \<forall>s'. \<Gamma>\<turnstile>\<^sub>p\<langle>c\<^sub>1,Normal s\<rangle> \<Rightarrow> s' \<longrightarrow> \<Gamma>\<turnstile>\<^sub>pc\<^sub>2\<down>s'\<rbrakk>
        \<Longrightarrow>
        \<Gamma>\<turnstile>\<^sub>pSeq c\<^sub>1 c\<^sub>2\<down>(Normal s)"

| CondTrue: "\<lbrakk>s \<in> b; \<Gamma>\<turnstile>\<^sub>pc\<^sub>1\<down>(Normal s)\<rbrakk> 
             \<Longrightarrow>  
             \<Gamma>\<turnstile>\<^sub>pCond b c\<^sub>1 c\<^sub>2\<down>(Normal s)"


| CondFalse: "\<lbrakk>s \<notin> b; \<Gamma>\<turnstile>\<^sub>pc\<^sub>2\<down>(Normal s)\<rbrakk> 
             \<Longrightarrow>  
             \<Gamma>\<turnstile>\<^sub>pCond b c\<^sub>1 c\<^sub>2\<down>(Normal s)"


| WhileTrue: "\<lbrakk>s \<in> b; \<Gamma>\<turnstile>\<^sub>pc\<down>(Normal s); 
               \<forall>s'. \<Gamma>\<turnstile>\<^sub>p\<langle>c,Normal s \<rangle> \<Rightarrow> s' \<longrightarrow> \<Gamma>\<turnstile>\<^sub>pWhile b c\<down>s'\<rbrakk> 
              \<Longrightarrow>  
              \<Gamma>\<turnstile>\<^sub>pWhile b c\<down>(Normal s)"
| AwaitTrue: "\<lbrakk>s \<in> b; 
               \<Gamma>\<^sub>p=\<Gamma>\<^sub>\<not>\<^sub>a ; \<Gamma>\<^sub>p\<turnstile> c\<down>(Normal s)\<rbrakk>               
              \<Longrightarrow>  
              \<Gamma>\<turnstile>\<^sub>pAwait b c e\<down>(Normal s)"

| AwaitFalse: "\<lbrakk>s \<notin> b\<rbrakk>                             
              \<Longrightarrow>  
              \<Gamma>\<turnstile>\<^sub>pAwait b c e\<down>(Normal s)"

| WhileFalse: "\<lbrakk>s \<notin> b\<rbrakk> 
               \<Longrightarrow>  
               \<Gamma>\<turnstile>\<^sub>pWhile b c\<down>(Normal s)"

| Call:  "\<lbrakk>\<Gamma> p=Some bdy;\<Gamma>\<turnstile>\<^sub>pbdy\<down>(Normal s)\<rbrakk> 
          \<Longrightarrow> 
          \<Gamma>\<turnstile>\<^sub>pCall p\<down>(Normal s)"

| CallUndefined:  "\<lbrakk>\<Gamma> p = None\<rbrakk> 
                   \<Longrightarrow> 
                   \<Gamma>\<turnstile>\<^sub>pCall p\<down>(Normal s)"

| Stuck [intro,simp]: "\<Gamma>\<turnstile>\<^sub>pc\<down>Stuck"
 
| DynCom:  "\<lbrakk>\<Gamma>\<turnstile>\<^sub>p(c s)\<down>(Normal s)\<rbrakk> 
             \<Longrightarrow> 
             \<Gamma>\<turnstile>\<^sub>pDynCom c\<down>(Normal s)"

| Throw: "\<Gamma>\<turnstile>\<^sub>pThrow\<down>(Normal s)"

| Abrupt [intro,simp]: "\<Gamma>\<turnstile>\<^sub>pc\<down>Abrupt s"

| Catch: "\<lbrakk>\<Gamma>\<turnstile>\<^sub>pc\<^sub>1\<down>Normal s; 
           \<forall>s'. \<Gamma>\<turnstile>\<^sub>p\<langle>c\<^sub>1,Normal s \<rangle> \<Rightarrow> Abrupt s' \<longrightarrow> \<Gamma>\<turnstile>\<^sub>pc\<^sub>2\<down>Normal s'\<rbrakk>
          \<Longrightarrow>
          \<Gamma>\<turnstile>\<^sub>pCatch c\<^sub>1 c\<^sub>2\<down>Normal s"  


inductive_cases terminates_elim_cases [cases set]:
  "\<Gamma>\<turnstile>\<^sub>pSkip \<down> s"
  "\<Gamma>\<turnstile>\<^sub>pGuard f g c \<down> s"
  "\<Gamma>\<turnstile>\<^sub>pBasic f e \<down> s"
  "\<Gamma>\<turnstile>\<^sub>pSpec r e \<down> s"
  "\<Gamma>\<turnstile>\<^sub>pSeq c1 c2 \<down> s"
  "\<Gamma>\<turnstile>\<^sub>pCond b c1 c2 \<down> s"
  "\<Gamma>\<turnstile>\<^sub>pWhile b c \<down> s"
  "\<Gamma>\<turnstile>\<^sub>pCall p \<down> s"
  "\<Gamma>\<turnstile>\<^sub>pDynCom c \<down> s"
  "\<Gamma>\<turnstile>\<^sub>pThrow \<down> s"
  "\<Gamma>\<turnstile>\<^sub>pCatch c1 c2 \<down> s"
  "\<Gamma>\<turnstile>\<^sub>pAwait b c e \<down> s"


inductive_cases terminates_Normal_elim_cases [cases set]:
  "\<Gamma>\<turnstile>\<^sub>pSkip \<down> Normal s"
  "\<Gamma>\<turnstile>\<^sub>pGuard f g c \<down> Normal s"
  "\<Gamma>\<turnstile>\<^sub>pBasic f e \<down> Normal s"
  "\<Gamma>\<turnstile>\<^sub>pSpec r e \<down> Normal s"
  "\<Gamma>\<turnstile>\<^sub>pSeq c1 c2 \<down> Normal s"
  "\<Gamma>\<turnstile>\<^sub>pCond b c1 c2 \<down> Normal s"
  "\<Gamma>\<turnstile>\<^sub>pWhile b c \<down> Normal s"
  "\<Gamma>\<turnstile>\<^sub>pCall p \<down> Normal s"
  "\<Gamma>\<turnstile>\<^sub>pDynCom c \<down> Normal s"
  "\<Gamma>\<turnstile>\<^sub>pThrow \<down> Normal s"
  "\<Gamma>\<turnstile>\<^sub>pCatch c1 c2 \<down> Normal s"
  "\<Gamma>\<turnstile>\<^sub>pAwait b c e \<down> Normal s"

lemma terminates_Skip': "\<Gamma>\<turnstile>\<^sub>pSkip \<down> s"
  by (cases s) (auto intro: terminates.intros)

lemma terminates_Call_body: 
 "\<Gamma> p=Some bdy\<Longrightarrow>\<Gamma>\<turnstile>\<^sub>pCall  p \<down>s = \<Gamma>\<turnstile>\<^sub>p(the (\<Gamma> p))\<down>s"
  by (cases s)
     (auto elim: terminates_Normal_elim_cases intro: terminates.intros)

lemma terminates_Normal_Call_body: 
 "p \<in> dom \<Gamma> \<Longrightarrow>
  \<Gamma>\<turnstile>\<^sub>pCall p \<down>Normal s = \<Gamma>\<turnstile>\<^sub>p(the (\<Gamma> p))\<down>Normal s"
  by (auto elim: terminates_Normal_elim_cases intro: terminates.intros)

lemma terminates_implies_exec:
  assumes terminates: "\<Gamma>\<turnstile>\<^sub>pc\<down>s"
  shows "\<exists>t. \<Gamma>\<turnstile>\<^sub>p\<langle>c,s\<rangle> \<Rightarrow> t"
using terminates
proof (induct)
  case Skip thus ?case by (iprover intro: exec.intros)
next
  case Basic thus ?case by (iprover intro: exec.intros)
next
  case (Spec r e s) thus ?case
    by (cases "\<exists>t. (s,t)\<in> r") (auto intro: exec.intros)
next
  case Guard thus ?case by (iprover intro: exec.intros)
next
  case GuardFault thus ?case by (iprover intro: exec.intros)
next
  case Fault thus ?case by (iprover intro: exec.intros)
next
  case Seq thus ?case by (iprover intro: exec_Seq')
next
  case CondTrue thus ?case by (iprover intro: exec.intros)
next
  case CondFalse thus ?case by (iprover intro: exec.intros)
next
  case WhileTrue thus ?case by (iprover intro: exec.intros)
next
  case WhileFalse thus ?case by (iprover intro: exec.intros)
next
  case (Call p bdy s) 
  then obtain s' where 
    "\<Gamma>\<turnstile>\<^sub>p\<langle>bdy,Normal s \<rangle> \<Rightarrow> s'"
    by iprover
  moreover have "\<Gamma> p = Some bdy" by fact
  ultimately show ?case 
    by (cases s') (iprover intro: exec.intros)+
next
  case CallUndefined thus ?case by (iprover intro: exec.intros)
next
  case Stuck thus ?case by (iprover intro: exec.intros)
next
  case DynCom thus ?case by (iprover intro: exec.intros)
next
  case Throw thus ?case by (iprover intro: exec.intros)
next
  case Abrupt thus ?case by (iprover intro: exec.intros) 
next
  case (Catch c1 s c2) 
  then obtain s' where exec_c1: "\<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow> s'"
    by iprover
  thus ?case
  proof (cases s')
    case (Normal s'')
    with exec_c1 show ?thesis by (auto intro!: exec.intros)
  next
    case (Abrupt s'')
    with exec_c1 Catch.hyps
    obtain t where "\<Gamma>\<turnstile>\<^sub>p\<langle>c2,Normal s'' \<rangle> \<Rightarrow> t"
      by auto
    with exec_c1 Abrupt show ?thesis by (auto intro: exec.intros)
  next
    case Fault
    with exec_c1 show ?thesis by (auto intro!: exec.CatchMiss)
  next
    case Stuck
    with exec_c1 show ?thesis by (auto intro!: exec.CatchMiss)
  qed
  next 
    case (AwaitTrue s b \<Gamma>\<^sub>p c) 
    then obtain t where "\<Gamma>\<^sub>p\<turnstile>\<langle>c,Normal s\<rangle> \<Rightarrow> t" 
     using terminates_implies_exec by fastforce  
    then  have "\<Gamma>\<^sub>\<not>\<^sub>a\<turnstile> \<langle>c,Normal s\<rangle> \<Rightarrow> t"
      using AwaitTrue.hyps(2) `\<Gamma>\<^sub>p\<turnstile> \<langle>c,Normal s\<rangle> \<Rightarrow> t` by blast
    thus ?case
      by (meson AwaitTrue.hyps(1) exec.AwaitTrue)
  next 
    case (AwaitFalse s b) thus ?case by (fastforce intro: exec.intros(13))
qed

lemma terminates_block: 
"\<lbrakk>\<Gamma>\<turnstile>\<^sub>pbdy \<down> Normal (init s);
  \<forall>t. \<Gamma>\<turnstile>\<^sub>p\<langle>bdy,Normal (init s)\<rangle> \<Rightarrow> Normal t \<longrightarrow> \<Gamma>\<turnstile>\<^sub>pc s t \<down> Normal (return s t)\<rbrakk>
 \<Longrightarrow> \<Gamma>\<turnstile>\<^sub>pblock init ei bdy return er c \<down> Normal s"
apply (unfold block_def)
apply (fastforce intro: terminates.intros elim!: exec_Normal_elim_cases 
        dest!: not_isAbrD)
done

lemma terminates_block_elim [cases set, consumes 1]:
assumes termi: "\<Gamma>\<turnstile>\<^sub>pblock init ei bdy return er c \<down> Normal s"
assumes e: "\<lbrakk>\<Gamma>\<turnstile>\<^sub>pbdy \<down> Normal (init s);
          \<forall>t. \<Gamma>\<turnstile>\<^sub>p\<langle>bdy,Normal (init s)\<rangle> \<Rightarrow> Normal t \<longrightarrow> \<Gamma>\<turnstile>\<^sub>pc s t \<down> Normal (return s t)
         \<rbrakk> \<Longrightarrow> P"
shows P
proof -
  have "\<Gamma>\<turnstile>\<^sub>p\<langle>Basic init ei,Normal s\<rangle> \<Rightarrow> Normal (init s)"
    by (auto intro: exec.intros)
  with termi
  have "\<Gamma>\<turnstile>\<^sub>pbdy \<down> Normal (init s)"
    apply (unfold block_def)
    apply (elim terminates_Normal_elim_cases)
    by simp
  moreover
  {
    fix t
    assume exec_bdy: "\<Gamma>\<turnstile>\<^sub>p\<langle>bdy,Normal (init s)\<rangle> \<Rightarrow> Normal t" 
    have "\<Gamma>\<turnstile>\<^sub>pc s t \<down> Normal (return s t)"
    proof -
      from exec_bdy 
      have "\<Gamma>\<turnstile>\<^sub>p\<langle>Catch (Seq (Basic init ei) bdy) 
                               (Seq (Basic (return s) er) Throw),Normal s\<rangle> \<Rightarrow> Normal t"
        by (fastforce intro: exec.intros)
      with termi have "\<Gamma>\<turnstile>\<^sub>pDynCom (\<lambda>t. Seq (Basic (return s) er) (c s t)) \<down> Normal t"
        apply (unfold block_def)
        apply (elim terminates_Normal_elim_cases)
        by simp
      thus ?thesis
        apply (elim terminates_Normal_elim_cases)
        apply (auto intro: exec.intros)
        done
    qed
  }
  ultimately show P by (iprover intro: e)
qed


lemma terminates_call: 
"\<lbrakk>\<Gamma> p = Some bdy; \<Gamma>\<turnstile>\<^sub>pbdy \<down> Normal (init s);
  \<forall>t. \<Gamma>\<turnstile>\<^sub>p\<langle>bdy,Normal (init s)\<rangle> \<Rightarrow> Normal t \<longrightarrow> \<Gamma>\<turnstile>\<^sub>pc s t \<down> Normal (return s t)\<rbrakk>
 \<Longrightarrow> \<Gamma>\<turnstile>\<^sub>pcall init ei p return er c \<down> Normal s"
  apply (unfold call_def)
  apply (rule terminates_block)
  apply  (iprover intro: terminates.intros)
  apply (auto elim: exec_Normal_elim_cases)
  done

lemma terminates_callUndefined: 
"\<lbrakk>\<Gamma> p = None\<rbrakk>
 \<Longrightarrow> \<Gamma>\<turnstile>\<^sub>pcall init ei p return er result \<down> Normal s"
  apply (unfold call_def)
  apply (rule terminates_block)
  apply  (iprover intro: terminates.intros)
  apply (auto elim: exec_Normal_elim_cases)
  done

lemma terminates_call_elim [cases set, consumes 1]:
assumes termi: "\<Gamma>\<turnstile>\<^sub>pcall init ei p return er c \<down> Normal s"
assumes bdy: "\<And>bdy. \<lbrakk>\<Gamma> p = Some bdy; \<Gamma>\<turnstile>\<^sub>pbdy \<down> Normal (init s); 
     \<forall>t. \<Gamma>\<turnstile>\<^sub>p\<langle>bdy,Normal (init s)\<rangle> \<Rightarrow> Normal t \<longrightarrow> \<Gamma>\<turnstile>\<^sub>pc s t \<down> Normal (return s t)\<rbrakk> \<Longrightarrow> P"
assumes undef: "\<lbrakk>\<Gamma> p = None\<rbrakk> \<Longrightarrow> P" 
shows P
apply (cases "\<Gamma> p")
apply  (erule undef)
using termi
apply (unfold call_def)
apply (erule terminates_block_elim)
apply (erule terminates_Normal_elim_cases)
apply  simp
apply  (frule (1) bdy)
apply   (fastforce intro: exec.intros)
apply  assumption
apply simp
done

lemma terminates_dynCall: 
"\<lbrakk>\<Gamma>\<turnstile>\<^sub>pcall init ei (p s) return er c \<down> Normal s\<rbrakk>
 \<Longrightarrow> \<Gamma>\<turnstile>\<^sub>pdynCall init ei p return er c \<down> Normal s"
  apply (unfold dynCall_def)
  apply (auto intro: terminates.intros terminates_call)
  done

lemma terminates_dynCall_elim [cases set, consumes 1]:
assumes termi: "\<Gamma>\<turnstile>\<^sub>pdynCall init ei p return er c \<down> Normal s"
assumes "\<lbrakk>\<Gamma>\<turnstile>\<^sub>pcall init ei (p s) return er c \<down> Normal s\<rbrakk> \<Longrightarrow> P"
shows P
using termi
apply (unfold dynCall_def)
apply (elim terminates_Normal_elim_cases)
apply fact
done


(* ************************************************************************* *)
subsection {* Lemmas about @{const "sequence"}, @{const "flatten"} and 
 @{const "normalize"} *}
(* ************************************************************************ *)

lemma terminates_sequence_app: 
  "\<And>s. \<lbrakk>\<Gamma>\<turnstile>\<^sub>psequence Seq xs \<down> Normal s;
        \<forall>s'. \<Gamma>\<turnstile>\<^sub>p\<langle>sequence Seq xs,Normal s \<rangle> \<Rightarrow> s' \<longrightarrow>  \<Gamma>\<turnstile>\<^sub>psequence Seq ys \<down> s'\<rbrakk>
\<Longrightarrow> \<Gamma>\<turnstile>\<^sub>psequence Seq (xs @ ys) \<down> Normal s"
proof (induct xs)
  case Nil
  thus ?case by (auto intro: exec.intros)
next
  case (Cons x xs)
  have termi_x_xs: "\<Gamma>\<turnstile>\<^sub>psequence Seq (x # xs) \<down> Normal s" by fact
  have termi_ys: "\<forall>s'. \<Gamma>\<turnstile>\<^sub>p\<langle>sequence Seq (x # xs),Normal s \<rangle> \<Rightarrow> s' \<longrightarrow> \<Gamma>\<turnstile>\<^sub>psequence Seq ys \<down> s'" by fact
  show ?case
  proof (cases xs)
    case Nil
    with termi_x_xs termi_ys show ?thesis
      by (cases ys) (auto intro: terminates.intros)
  next
    case Cons
    from termi_x_xs Cons 
    have "\<Gamma>\<turnstile>\<^sub>px \<down> Normal s"
      by (auto elim: terminates_Normal_elim_cases)
    moreover 
    {
      fix s'
      assume exec_x: "\<Gamma>\<turnstile>\<^sub>p\<langle>x,Normal s \<rangle> \<Rightarrow> s'" 
      have "\<Gamma>\<turnstile>\<^sub>psequence Seq (xs @ ys) \<down> s'"
      proof -
        from exec_x termi_x_xs Cons
        have termi_xs: "\<Gamma>\<turnstile>\<^sub>psequence Seq xs \<down> s'"
          by (auto elim: terminates_Normal_elim_cases)
        show ?thesis
        proof (cases s')
          case (Normal s'')
          with exec_x termi_ys Cons 
          have "\<forall>s'. \<Gamma>\<turnstile>\<^sub>p\<langle>sequence Seq xs,Normal s'' \<rangle> \<Rightarrow> s' \<longrightarrow> \<Gamma>\<turnstile>\<^sub>psequence Seq ys \<down> s'"
            by (auto intro: exec.intros)
          from Cons.hyps [OF termi_xs [simplified Normal] this]
          have "\<Gamma>\<turnstile>\<^sub>psequence Seq (xs @ ys) \<down> Normal s''".
          with Normal show ?thesis by simp
        next
          case Abrupt thus ?thesis by (auto intro: terminates.intros)
        next
          case Fault thus ?thesis by (auto intro: terminates.intros)
        next
          case Stuck thus ?thesis by (auto intro: terminates.intros)
        qed
      qed
    }
    ultimately show ?thesis
      using Cons
      by (auto intro: terminates.intros)
  qed
qed

lemma terminates_sequence_appD: 
  "\<And>s. \<Gamma>\<turnstile>\<^sub>psequence Seq (xs @ ys) \<down> Normal s
   \<Longrightarrow> \<Gamma>\<turnstile>\<^sub>psequence Seq xs \<down> Normal s \<and>
       (\<forall>s'. \<Gamma>\<turnstile>\<^sub>p\<langle>sequence Seq xs,Normal s \<rangle> \<Rightarrow> s' \<longrightarrow>  \<Gamma>\<turnstile>\<^sub>psequence Seq ys \<down> s')"
proof (induct xs)
  case Nil
  thus ?case 
    by (auto elim: terminates_Normal_elim_cases exec_Normal_elim_cases 
         intro: terminates.intros)
next
  case (Cons x xs)
  have termi_x_xs_ys: "\<Gamma>\<turnstile>\<^sub>psequence Seq ((x # xs) @ ys) \<down> Normal s" by fact
  show ?case
  proof (cases xs)
    case Nil
    with termi_x_xs_ys show ?thesis
      by (cases ys)
         (auto elim: terminates_Normal_elim_cases exec_Normal_elim_cases 
           intro:  terminates_Skip')
  next
    case Cons
    with termi_x_xs_ys 
    obtain termi_x: "\<Gamma>\<turnstile>\<^sub>px \<down> Normal s" and
           termi_xs_ys: "\<forall>s'. \<Gamma>\<turnstile>\<^sub>p\<langle>x,Normal s \<rangle> \<Rightarrow> s' \<longrightarrow>  \<Gamma>\<turnstile>\<^sub>psequence Seq (xs@ys) \<down> s'"
      by (auto elim: terminates_Normal_elim_cases)
    
    have "\<Gamma>\<turnstile>\<^sub>pSeq x (sequence Seq xs) \<down> Normal s"
    proof (rule terminates.Seq [rule_format])
      show "\<Gamma>\<turnstile>\<^sub>px \<down> Normal s" by (rule termi_x)
    next
      fix s'
      assume exec_x: "\<Gamma>\<turnstile>\<^sub>p\<langle>x,Normal s \<rangle> \<Rightarrow> s'"
      show "\<Gamma>\<turnstile>\<^sub>psequence Seq xs \<down> s'"
      proof -
        from termi_xs_ys [rule_format, OF exec_x]
        have termi_xs_ys': "\<Gamma>\<turnstile>\<^sub>psequence Seq (xs@ys) \<down> s'" .
        show ?thesis
        proof (cases s')
          case (Normal s'')
          from Cons.hyps [OF termi_xs_ys' [simplified Normal]]
          show ?thesis
            using Normal by auto
        next
          case Abrupt thus ?thesis by (auto intro: terminates.intros)
        next
          case Fault thus ?thesis by (auto intro: terminates.intros)
        next
          case Stuck thus ?thesis by (auto intro: terminates.intros)
        qed
      qed
    qed
    moreover
    {
      fix s'
      assume exec_x_xs: "\<Gamma>\<turnstile>\<^sub>p\<langle>Seq x (sequence Seq xs),Normal s \<rangle> \<Rightarrow> s'"
      have "\<Gamma>\<turnstile>\<^sub>psequence Seq ys \<down> s'"
      proof -
        from exec_x_xs obtain t where 
          exec_x: "\<Gamma>\<turnstile>\<^sub>p\<langle>x,Normal s \<rangle> \<Rightarrow> t" and
          exec_xs: "\<Gamma>\<turnstile>\<^sub>p\<langle>sequence Seq xs,t \<rangle> \<Rightarrow> s'"
          by cases
        show ?thesis
        proof (cases t)
          case (Normal t')
          with exec_x termi_xs_ys have "\<Gamma>\<turnstile>\<^sub>psequence Seq (xs@ys) \<down> Normal t'"
            by auto
          from Cons.hyps [OF this] exec_xs Normal
          show ?thesis
            by auto
        next
          case (Abrupt t')
          with exec_xs have "s'=Abrupt t'"
            by (auto dest: Abrupt_end)
          thus ?thesis by (auto intro: terminates.intros)
        next
          case (Fault f)
          with exec_xs have "s'=Fault f"
            by (auto dest: Fault_end)
          thus ?thesis by (auto intro: terminates.intros)
        next
          case Stuck
          with exec_xs have "s'=Stuck"
            by (auto dest: Stuck_end)
          thus ?thesis by (auto intro: terminates.intros)
        qed
      qed
    }
    ultimately show ?thesis
      using Cons
      by auto
  qed
qed

lemma terminates_sequence_appE [consumes 1]:
  "\<lbrakk>\<Gamma>\<turnstile>\<^sub>psequence Seq (xs @ ys) \<down> Normal s;
    \<lbrakk>\<Gamma>\<turnstile>\<^sub>psequence Seq xs \<down> Normal s;
     \<forall>s'. \<Gamma>\<turnstile>\<^sub>p\<langle>sequence Seq xs,Normal s \<rangle> \<Rightarrow> s' \<longrightarrow>  \<Gamma>\<turnstile>\<^sub>psequence Seq ys \<down> s'\<rbrakk> \<Longrightarrow> P\<rbrakk>
   \<Longrightarrow> P"
  by (auto dest: terminates_sequence_appD)

lemma terminates_to_terminates_sequence_flatten: 
  assumes termi: "\<Gamma>\<turnstile>\<^sub>pc\<down>s" 
  shows "\<Gamma>\<turnstile>\<^sub>psequence Seq (flatten c)\<down>s" 
using termi 
by (induct)
   (auto intro: terminates.intros terminates_sequence_app 
     exec_sequence_flatten_to_exec)

lemma terminates_to_terminates_normalize: 
  assumes termi: "\<Gamma>\<turnstile>\<^sub>pc\<down>s" 
  shows "\<Gamma>\<turnstile>\<^sub>pnormalize c\<down>s" 
using termi 
proof induct
  case Seq
  thus ?case
    by (fastforce intro: terminates.intros terminates_sequence_app
                 terminates_to_terminates_sequence_flatten
        dest: exec_sequence_flatten_to_exec exec_normalize_to_exec)
next
  case WhileTrue
  thus ?case
    by (fastforce intro: terminates.intros terminates_sequence_app
                 terminates_to_terminates_sequence_flatten
        dest: exec_sequence_flatten_to_exec exec_normalize_to_exec)
next 
  case Catch
  thus ?case
    by (fastforce intro: terminates.intros terminates_sequence_app
                 terminates_to_terminates_sequence_flatten
        dest: exec_sequence_flatten_to_exec exec_normalize_to_exec)
next
 case AwaitTrue
 thus ?case
  using terminates_to_terminates_normalize
  by (simp add: terminates_to_terminates_normalize terminates.AwaitTrue)
qed (auto intro: terminates.intros)

lemma terminates_sequence_flatten_to_terminates: 
  shows "\<And>s. \<Gamma>\<turnstile>\<^sub>psequence Seq (flatten c)\<down>s \<Longrightarrow> \<Gamma>\<turnstile>\<^sub>pc\<down>s" 
proof (induct c)
  case (Seq c1 c2)
  have "\<Gamma>\<turnstile>\<^sub>psequence Seq (flatten (Seq c1 c2)) \<down> s" by fact
  hence termi_app: "\<Gamma>\<turnstile>\<^sub>psequence Seq (flatten c1 @ flatten c2) \<down> s" by simp
  show ?case
  proof (cases s)
    case (Normal s')
    have "\<Gamma>\<turnstile>\<^sub>pSeq c1 c2 \<down> Normal s'"
    proof (rule terminates.Seq [rule_format])
      from termi_app [simplified Normal]
      have "\<Gamma>\<turnstile>\<^sub>psequence Seq (flatten c1) \<down> Normal s'"
        by (cases rule: terminates_sequence_appE)
      with Seq.hyps
      show "\<Gamma>\<turnstile>\<^sub>pc1 \<down> Normal s'"
        by simp
    next
      fix s''
      assume "\<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s' \<rangle> \<Rightarrow> s''"
      from termi_app [simplified Normal] exec_to_exec_sequence_flatten [OF this]
      have "\<Gamma>\<turnstile>\<^sub>psequence Seq (flatten c2) \<down> s''"
        by (cases rule: terminates_sequence_appE) auto
      with Seq.hyps
      show "\<Gamma>\<turnstile>\<^sub>pc2 \<down> s''"
        by simp
    qed
    with Normal show ?thesis
      by simp
  qed (auto intro: terminates.intros)
qed (auto intro: terminates.intros)

lemma terminates_normalize_to_terminates: 
  shows "\<And>s. \<Gamma>\<turnstile>\<^sub>pnormalize c\<down>s \<Longrightarrow> \<Gamma>\<turnstile>\<^sub>pc\<down>s" 
proof (induct c)
  case Skip thus ?case by (auto intro:  terminates_Skip')
next
  case Basic thus ?case by (cases s) (auto intro: terminates.intros)
next
  case Spec thus ?case by (cases s) (auto intro: terminates.intros)
next
  case (Seq c1 c2)
  have "\<Gamma>\<turnstile>\<^sub>pnormalize (Seq c1 c2) \<down> s" by fact
  hence termi_app: "\<Gamma>\<turnstile>\<^sub>psequence Seq (flatten (normalize c1) @ flatten (normalize c2)) \<down> s"
    by simp
  show ?case
  proof (cases s)
    case (Normal s')
    have "\<Gamma>\<turnstile>\<^sub>pSeq c1 c2 \<down> Normal s'"
    proof (rule terminates.Seq [rule_format])
      from termi_app [simplified Normal]
      have "\<Gamma>\<turnstile>\<^sub>psequence Seq (flatten (normalize c1))  \<down> Normal s'"
        by (cases rule: terminates_sequence_appE)
      from terminates_sequence_flatten_to_terminates [OF this] Seq.hyps
      show "\<Gamma>\<turnstile>\<^sub>pc1 \<down> Normal s'" 
        by simp
    next
      fix s''
      assume "\<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s' \<rangle> \<Rightarrow> s''"
      from exec_to_exec_normalize [OF this]
      have "\<Gamma>\<turnstile>\<^sub>p\<langle>normalize c1,Normal s' \<rangle> \<Rightarrow> s''" .
      from termi_app [simplified Normal] exec_to_exec_sequence_flatten [OF this] 
      have "\<Gamma>\<turnstile>\<^sub>psequence Seq (flatten (normalize c2))  \<down> s''"
        by (cases rule: terminates_sequence_appE) auto
      from terminates_sequence_flatten_to_terminates [OF this] Seq.hyps
      show "\<Gamma>\<turnstile>\<^sub>pc2 \<down> s''" 
        by simp
    qed
    with Normal show ?thesis by simp
  qed (auto intro: terminates.intros)
next
  case (Cond b c1 c2) 
  thus ?case
    by (cases s)
       (auto intro: terminates.intros elim!: terminates_Normal_elim_cases)
next
  case (While b c)
  have "\<Gamma>\<turnstile>\<^sub>pnormalize (While b c) \<down> s" by fact
  hence termi_norm_w: "\<Gamma>\<turnstile>\<^sub>pWhile b (normalize c) \<down> s" by simp
  {
    fix t w
    assume termi_w: "\<Gamma>\<turnstile>\<^sub>p w \<down> t"
    have "w=While b (normalize c) \<Longrightarrow> \<Gamma>\<turnstile>\<^sub>pWhile b c \<down> t"
      using termi_w 
    proof (induct)
      case (WhileTrue t' b' c')
      from WhileTrue obtain
        t'_b: "t' \<in> b" and
        termi_norm_c: "\<Gamma>\<turnstile>\<^sub>pnormalize c \<down> Normal t'" and
        termi_norm_w': "\<forall>s'. \<Gamma>\<turnstile>\<^sub>p\<langle>normalize c,Normal t' \<rangle> \<Rightarrow> s' \<longrightarrow> \<Gamma>\<turnstile>\<^sub>pWhile b c \<down> s'"
        by auto
      from While.hyps [OF termi_norm_c]
      have "\<Gamma>\<turnstile>\<^sub>pc \<down> Normal t'".
      moreover
      from termi_norm_w' 
      have "\<forall>s'. \<Gamma>\<turnstile>\<^sub>p\<langle>c,Normal t' \<rangle> \<Rightarrow> s' \<longrightarrow> \<Gamma>\<turnstile>\<^sub>pWhile b c \<down> s'"
        by (auto intro: exec_to_exec_normalize)
      ultimately show ?case
        using t'_b
        by (auto intro: terminates.intros)
    qed (auto intro: terminates.intros)
  }
  from this [OF termi_norm_w]
  show ?case 
    by auto
next
  case Call thus ?case by simp
next
  case DynCom thus ?case 
    by (cases s) (auto intro: terminates.intros rangeI elim: terminates_Normal_elim_cases)
next
  case Guard thus ?case 
    by (cases s) (auto intro: terminates.intros elim: terminates_Normal_elim_cases)
next
  case Throw thus ?case by (cases s) (auto intro: terminates.intros)
next
  case Catch
  thus ?case
    by (cases s) 
       (auto dest: exec_to_exec_normalize elim!: terminates_Normal_elim_cases 
         intro!: terminates.Catch)
next 
  case (Await b c) thus ?case 
    by (cases s) (auto intro: terminates_normalize_to_terminates terminates.AwaitTrue terminates.AwaitFalse rangeI elim: terminates_Normal_elim_cases)
qed

lemma terminates_iff_terminates_normalize:
"\<Gamma>\<turnstile>\<^sub>pnormalize c\<down>s = \<Gamma>\<turnstile>\<^sub>pc\<down>s"
  by (auto intro: terminates_to_terminates_normalize 
    terminates_normalize_to_terminates)

(* ************************************************************************* *)
subsection {* Lemmas about @{const "strip_guards"} *}
(* ************************************************************************* *)

lemma terminates_strip_guards_to_terminates: "\<And>s. \<Gamma>\<turnstile>\<^sub>pstrip_guards F c\<down>s  \<Longrightarrow> \<Gamma>\<turnstile>\<^sub>pc\<down>s"
proof (induct c)
  case Skip thus ?case by simp
next
  case Basic thus ?case by simp
next
  case Spec thus ?case by simp
next
  case (Seq c1 c2)
  hence "\<Gamma>\<turnstile>\<^sub>pSeq (strip_guards F c1) (strip_guards F c2) \<down> s" by simp
  thus "\<Gamma>\<turnstile>\<^sub>pSeq c1 c2 \<down> s"
  proof (cases)
    fix f assume "s=Fault f" thus ?thesis by simp
  next
    assume "s=Stuck" thus ?thesis by simp
  next
    fix s' assume "s=Abrupt s'" thus ?thesis by simp
  next
    fix s'
    assume s: "s=Normal s'"
    assume "\<Gamma>\<turnstile>\<^sub>pstrip_guards F c1 \<down> Normal s'"
    hence "\<Gamma>\<turnstile>\<^sub>pc1 \<down> Normal s'" 
      by (rule Seq.hyps)
    moreover
    assume c2: 
      "\<forall>s''. \<Gamma>\<turnstile>\<^sub>p\<langle>strip_guards F c1,Normal s'\<rangle> \<Rightarrow> s'' \<longrightarrow> \<Gamma>\<turnstile>\<^sub>pstrip_guards F c2\<down>s''"
    {
      fix s'' assume exec_c1: "\<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s' \<rangle> \<Rightarrow> s''"
      have " \<Gamma>\<turnstile>\<^sub>pc2 \<down> s''"
      proof (cases s'')
        case (Normal s''')
        with exec_c1
        have "\<Gamma>\<turnstile>\<^sub>p\<langle>strip_guards F c1,Normal s' \<rangle> \<Rightarrow> s''"
          by (auto intro: exec_to_exec_strip_guards)
        with c2
        show ?thesis
          by (iprover intro: Seq.hyps)
      next
        case (Abrupt s''')
        with exec_c1
        have "\<Gamma>\<turnstile>\<^sub>p\<langle>strip_guards F c1,Normal s' \<rangle> \<Rightarrow> s''"
          by (auto intro: exec_to_exec_strip_guards )
        with c2
        show ?thesis
          by (iprover intro: Seq.hyps)
      next
        case Fault thus ?thesis by simp
      next
        case Stuck thus ?thesis by simp
      qed
    }
    ultimately show ?thesis
      using s
      by (iprover intro: terminates.intros)
  qed
next
  case (Cond b c1 c2)
  hence "\<Gamma>\<turnstile>\<^sub>pCond b (strip_guards F c1) (strip_guards F c2) \<down> s" by simp
  thus "\<Gamma>\<turnstile>\<^sub>pCond b c1 c2 \<down> s"
  proof (cases)
    fix f assume "s=Fault f" thus ?thesis by simp
  next
    assume "s=Stuck" thus ?thesis by simp
  next
    fix s' assume "s=Abrupt s'" thus ?thesis by simp
  next
    fix s'
    assume "s'\<in>b" "\<Gamma>\<turnstile>\<^sub>pstrip_guards F c1 \<down> Normal s'" "s = Normal s'"
    thus ?thesis
      by (iprover intro: terminates.intros Cond.hyps)
  next
    fix s'
    assume "s'\<notin>b" "\<Gamma>\<turnstile>\<^sub>pstrip_guards F c2 \<down> Normal s'" "s = Normal s'"
    thus ?thesis
      by (iprover intro: terminates.intros Cond.hyps)
  qed
next
  case (While b c)
  have hyp_c: "\<And>s. \<Gamma>\<turnstile>\<^sub>pstrip_guards F c \<down> s \<Longrightarrow> \<Gamma>\<turnstile>\<^sub>pc \<down> s" by fact
  have "\<Gamma>\<turnstile>\<^sub>pWhile b (strip_guards F c) \<down> s" using While.prems by simp
  moreover
  {
    fix sw  
    assume "\<Gamma>\<turnstile>\<^sub>psw\<down>s"  
    then have "sw=While b (strip_guards F c) \<Longrightarrow> 
      \<Gamma>\<turnstile>\<^sub>pWhile b c \<down> s"
    proof (induct)
      case (WhileTrue s b' c')
      have eqs: "While b' c' = While b (strip_guards F c)" by fact
      with `s\<in>b'` have b: "s\<in>b" by simp
      from eqs `\<Gamma>\<turnstile>\<^sub>pc' \<down> Normal s` have "\<Gamma>\<turnstile>\<^sub>pstrip_guards F c \<down> Normal s"
        by simp
      hence term_c: "\<Gamma>\<turnstile>\<^sub>pc \<down> Normal s"
        by (rule hyp_c)
      moreover
      {
        fix t
        assume exec_c: "\<Gamma>\<turnstile>\<^sub>p\<langle>c,Normal s \<rangle> \<Rightarrow> t"
        have "\<Gamma>\<turnstile>\<^sub>pWhile b c \<down> t"
        proof (cases t)
          case Fault
          thus ?thesis by simp
        next
          case Stuck
          thus ?thesis by simp
        next
          case (Abrupt t')
          thus ?thesis by simp
        next
          case (Normal t')
          with exec_c
          have "\<Gamma>\<turnstile>\<^sub>p\<langle>strip_guards F c,Normal s \<rangle> \<Rightarrow> Normal t'"
            by (auto intro: exec_to_exec_strip_guards)
          with WhileTrue.hyps eqs Normal
          show ?thesis
            by fastforce
        qed
      }
      ultimately
      show ?case
        using b
        by (auto intro: terminates.intros)
    next
      case WhileFalse thus ?case by (auto intro: terminates.intros)
    qed simp_all
  } 
  ultimately show "\<Gamma>\<turnstile>\<^sub>pWhile b c \<down> s"
    by auto
next
  case Call thus ?case by simp
next
  case DynCom thus ?case 
     by (cases s) (auto elim: terminates_Normal_elim_cases intro: terminates.intros rangeI)
next
  case Guard 
  thus ?case
    by (cases s) (auto elim: terminates_Normal_elim_cases intro: terminates.intros
                  split: if_split_asm)
next
  case Throw thus ?case by simp
next
  case (Catch c1 c2)
  hence "\<Gamma>\<turnstile>\<^sub>pCatch (strip_guards F c1) (strip_guards F c2) \<down> s" by simp
  thus "\<Gamma>\<turnstile>\<^sub>pCatch c1 c2 \<down> s"
  proof (cases)
    fix f assume "s=Fault f" thus ?thesis by simp
  next
    assume "s=Stuck" thus ?thesis by simp
  next
    fix s' assume "s=Abrupt s'" thus ?thesis by simp
  next
    fix s'
    assume s: "s=Normal s'"
    assume "\<Gamma>\<turnstile>\<^sub>pstrip_guards F c1 \<down> Normal s'"
    hence "\<Gamma>\<turnstile>\<^sub>pc1 \<down> Normal s'" 
      by (rule Catch.hyps)
    moreover
    assume c2: 
      "\<forall>s''. \<Gamma>\<turnstile>\<^sub>p\<langle>strip_guards F c1,Normal s'\<rangle> \<Rightarrow> Abrupt s''   
             \<longrightarrow> \<Gamma>\<turnstile>\<^sub>pstrip_guards F c2\<down>Normal s''"
    {
      fix s'' assume exec_c1: "\<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s' \<rangle> \<Rightarrow> Abrupt s''"
      have " \<Gamma>\<turnstile>\<^sub>pc2 \<down> Normal s''"
      proof -
        from exec_c1
        have "\<Gamma>\<turnstile>\<^sub>p\<langle>strip_guards F c1,Normal s' \<rangle> \<Rightarrow> Abrupt s''"
          by (auto intro: exec_to_exec_strip_guards)
        with c2 
        show ?thesis
          by (auto intro: Catch.hyps)
      qed
    }
    ultimately show ?thesis
      using s
      by (iprover intro: terminates.intros)
  qed
next case (Await b c) thus ?case         
     by (cases s) (auto elim: terminates_Normal_elim_cases intro: terminates_strip_guards_to_terminates terminates.intros
                  split: if_split_asm)
qed

lemma terminates_strip_to_terminates:
  assumes termi_strip: "strip F \<Gamma>\<turnstile>\<^sub>pc\<down>s"
  shows "\<Gamma>\<turnstile>\<^sub>pc\<down>s"
using termi_strip
proof induct
  case (Seq c1 s c2)
  have "\<Gamma>\<turnstile>\<^sub>pc1 \<down> Normal s" by fact
  moreover
  {
    fix s'
    assume exec: "\<Gamma>\<turnstile>\<^sub>p \<langle>c1,Normal s\<rangle> \<Rightarrow> s'"
    have "\<Gamma>\<turnstile>\<^sub>pc2 \<down> s'"
    proof (cases "isFault s'")
      case True
      thus ?thesis
        by (auto elim: isFaultE)
    next
      case False
      from exec_to_exec_strip [OF exec this] Seq.hyps
      show ?thesis
        by auto
    qed
  }
  ultimately show ?case
    by (auto intro: terminates.intros)
next
  case (WhileTrue s b c)
  have "\<Gamma>\<turnstile>\<^sub>pc \<down> Normal s" by fact
  moreover
  {
    fix s'
    assume exec: "\<Gamma>\<turnstile>\<^sub>p \<langle>c,Normal s\<rangle> \<Rightarrow> s'"
    have "\<Gamma>\<turnstile>\<^sub>pWhile b c \<down> s'"
    proof (cases "isFault s'")
      case True
      thus ?thesis
        by (auto elim: isFaultE)
    next
      case False
      from exec_to_exec_strip [OF exec this] WhileTrue.hyps
      show ?thesis
        by auto
    qed
  }
  ultimately show ?case
    by (auto intro: terminates.intros)
next
  case (Catch c1 s c2)
  have "\<Gamma>\<turnstile>\<^sub>pc1 \<down> Normal s" by fact
  moreover
  {
    fix s'
    assume exec: "\<Gamma>\<turnstile>\<^sub>p \<langle>c1,Normal s\<rangle> \<Rightarrow> Abrupt s'"
    from exec_to_exec_strip [OF exec] Catch.hyps
    have "\<Gamma>\<turnstile>\<^sub>pc2 \<down> Normal s'"
      by auto
  }
  ultimately show ?case
    by (auto intro: terminates.intros)
next
  case Call thus ?case 
    by (auto intro: terminates.intros terminates_strip_guards_to_terminates)
next
  case (AwaitTrue s b \<Gamma>\<^sub>p c)    
  then have eq_fun:"Language.strip F (\<Gamma>\<^sub>\<not>\<^sub>a) = \<Gamma>\<^sub>p"
    by (simp add: AwaitTrue.hyps(2) strip_eq)
  then have "Language.strip F (\<Gamma>\<^sub>\<not>\<^sub>a)\<turnstile>c \<down> Normal s" using AwaitTrue.hyps(3)
    by auto
  thus ?case by 
    (fastforce intro: AwaitTrue.hyps(1) terminates.AwaitTrue terminates_strip_to_terminates)   
qed (auto intro: terminates.intros)

(* ************************************************************************* *)
subsection {* Lemmas about @{term "c\<^sub>1 \<inter>\<^sub>g c\<^sub>2"} *}
(* ************************************************************************* *)

lemma inter_guards_terminates: 
  "\<And>c c2 s. \<lbrakk>(c1 \<inter>\<^sub>g\<^sub>s c2) = Some c; \<Gamma>\<turnstile>\<^sub>pc1\<down>s \<rbrakk>
        \<Longrightarrow> \<Gamma>\<turnstile>\<^sub>pc\<down>s"
proof (induct c1)
  case Skip thus ?case by (fastforce simp add: inter_guards_Skip)
next
  case (Basic f) thus ?case by (fastforce simp add: inter_guards_Basic)
next
  case (Spec r) thus ?case by (fastforce simp add: inter_guards_Spec)
next
  case (Seq a1 a2)
  have "(Seq a1 a2 \<inter>\<^sub>g\<^sub>s c2) = Some c" by fact
  then obtain b1 b2 d1 d2 where
    c2: "c2=Seq b1 b2" and 
    d1: "(a1 \<inter>\<^sub>g\<^sub>s b1) = Some d1" and d2: "(a2 \<inter>\<^sub>g\<^sub>s b2) = Some d2" and
    c: "c=Seq d1 d2"
    by (auto simp add: inter_guards_Seq)
  have termi_c1: "\<Gamma>\<turnstile>\<^sub>pSeq a1 a2 \<down> s" by fact
  have "\<Gamma>\<turnstile>\<^sub>pSeq d1 d2 \<down> s"
  proof (cases s)
    case Fault thus ?thesis by simp
  next
    case Stuck thus ?thesis by simp
  next
    case Abrupt thus ?thesis by simp
  next
    case (Normal s')
    note Normal_s = this
    with d1 termi_c1
    have "\<Gamma>\<turnstile>\<^sub>pd1 \<down> Normal s'"
      by (auto elim: terminates_Normal_elim_cases intro: Seq.hyps)
    moreover
    {
      fix t
      assume exec_d1: "\<Gamma>\<turnstile>\<^sub>p\<langle>d1,Normal s' \<rangle> \<Rightarrow> t"
      have "\<Gamma>\<turnstile>\<^sub>pd2 \<down> t"
      proof (cases t)
        case Fault thus ?thesis by simp
      next
        case Stuck thus ?thesis by simp
      next
        case Abrupt thus ?thesis by simp
      next
        case (Normal t')
        with inter_guards_exec_noFault [OF d1 exec_d1]
        have "\<Gamma>\<turnstile>\<^sub>p\<langle>a1,Normal s' \<rangle> \<Rightarrow> Normal t'"
          by simp
        with termi_c1 Normal_s have "\<Gamma>\<turnstile>\<^sub>pa2 \<down> Normal t'"
          by (auto elim: terminates_Normal_elim_cases) 
        with d2 have "\<Gamma>\<turnstile>\<^sub>pd2 \<down> Normal t'"
          by (auto intro: Seq.hyps)
        with Normal show ?thesis by simp  
      qed
    }
    ultimately have "\<Gamma>\<turnstile>\<^sub>pSeq d1 d2 \<down> Normal s'"
      by (fastforce intro: terminates.intros)
    with Normal show ?thesis by simp
  qed
  with c show ?case by simp
next
  case Cond thus ?case
    by - (cases s,
          auto intro: terminates.intros elim!: terminates_Normal_elim_cases
               simp add: inter_guards_Cond)
next
  case (While b bdy1)
  have "(While b bdy1 \<inter>\<^sub>g\<^sub>s c2) = Some c" by fact
  then obtain bdy2 bdy where
    c2: "c2=While b bdy2" and
    bdy: "(bdy1 \<inter>\<^sub>g\<^sub>s bdy2) = Some bdy" and
    c: "c=While b bdy"
    by (auto simp add: inter_guards_While)
  have "\<Gamma>\<turnstile>\<^sub>pWhile b bdy1 \<down> s" by fact
  moreover
  {
    fix s w w1 w2
    assume termi_w:  "\<Gamma>\<turnstile>\<^sub>pw \<down> s"
    assume w: "w=While b bdy1"
    from termi_w w 
    have "\<Gamma>\<turnstile>\<^sub>pWhile b bdy \<down> s"    
    proof (induct)
      case (WhileTrue s b' bdy1')
      have eqs: "While b' bdy1' = While b bdy1" by fact
      from WhileTrue have s_in_b: "s \<in> b" by simp
      from WhileTrue have termi_bdy1: "\<Gamma>\<turnstile>\<^sub>pbdy1 \<down> Normal s" by simp
      show ?case
      proof -
        from bdy termi_bdy1 
        have "\<Gamma>\<turnstile>\<^sub>pbdy\<down>(Normal s)"
          by (rule While.hyps)
        moreover
        {
          fix t
          assume exec_bdy: "\<Gamma>\<turnstile>\<^sub>p\<langle>bdy,Normal s \<rangle> \<Rightarrow> t" 
          have "\<Gamma>\<turnstile>\<^sub>pWhile b bdy\<down>t"
          proof (cases t)
            case Fault thus ?thesis by simp
          next
            case Stuck thus ?thesis by simp
          next
            case Abrupt thus ?thesis by simp
          next
            case (Normal t')
            with inter_guards_exec_noFault [OF bdy exec_bdy]
            have "\<Gamma>\<turnstile>\<^sub>p\<langle>bdy1,Normal s \<rangle> \<Rightarrow> Normal t'"
              by simp
            with WhileTrue have "\<Gamma>\<turnstile>\<^sub>pWhile b bdy \<down> Normal t'"
              by simp
            with Normal show ?thesis by simp
          qed
        }
        ultimately show ?thesis
          using s_in_b 
          by (blast intro: terminates.WhileTrue)
      qed
    next
      case WhileFalse thus ?case 
        by (blast intro: terminates.WhileFalse)
    qed (simp_all)
  }
  ultimately
  show ?case using c by simp
next
  case Call thus ?case by (simp add: inter_guards_Call)
next
  case (DynCom f1) 
  have "(DynCom f1 \<inter>\<^sub>g\<^sub>s c2) = Some c" by fact
  then obtain f2 f where
    c2: "c2=DynCom f2" and
    f_defined: "\<forall>s. ((f1 s) \<inter>\<^sub>g\<^sub>s (f2 s)) \<noteq> None" and
    c: "c=DynCom (\<lambda>s. the ((f1 s) \<inter>\<^sub>g\<^sub>s (f2 s)))"
    by (auto simp add: inter_guards_DynCom)
  have termi: "\<Gamma>\<turnstile>\<^sub>pDynCom f1 \<down> s" by fact
  show ?case
  proof (cases s)
    case Fault thus ?thesis by simp
  next
    case Stuck thus ?thesis by simp
  next
    case Abrupt thus ?thesis by simp
  next
    case (Normal s')
    from f_defined obtain f where f: "((f1 s') \<inter>\<^sub>g\<^sub>s (f2 s')) = Some f"
      by auto
    from Normal termi
    have "\<Gamma>\<turnstile>\<^sub>pf1 s'\<down> (Normal s')"
      by (auto elim: terminates_Normal_elim_cases)
    from DynCom.hyps f this 
    have "\<Gamma>\<turnstile>\<^sub>pf\<down> (Normal s')"
      by blast
    with c f Normal
    show ?thesis
      by (auto intro: terminates.intros)
  qed
next
  case (Guard f g1 bdy1)
  have "(Guard f g1 bdy1 \<inter>\<^sub>g\<^sub>s c2) = Some c" by fact
  then obtain g2 bdy2 bdy where
    c2: "c2=Guard f g2 bdy2" and
    bdy: "(bdy1 \<inter>\<^sub>g\<^sub>s bdy2) = Some bdy" and
    c: "c=Guard f (g1 \<inter> g2) bdy"
    by (auto simp add: inter_guards_Guard)
  have termi_c1: "\<Gamma>\<turnstile>\<^sub>pGuard f g1 bdy1 \<down> s" by fact
  show ?case
  proof (cases s)
    case Fault thus ?thesis by simp
  next
    case Stuck thus ?thesis by simp
  next
    case Abrupt thus ?thesis by simp
  next
    case (Normal s')
    show ?thesis
    proof (cases "s' \<in> g1")
      case False
      with Normal c show ?thesis by (auto intro: terminates.GuardFault)
    next
      case True
      note s_in_g1 = this
      show ?thesis
      proof (cases "s' \<in> g2")
        case False
        with Normal c show ?thesis by (auto intro: terminates.GuardFault)
      next
        case True
        with termi_c1 s_in_g1 Normal have "\<Gamma>\<turnstile>\<^sub>pbdy1 \<down> Normal s'"
          by (auto elim: terminates_Normal_elim_cases)
        with c bdy Guard.hyps Normal True s_in_g1 
        show ?thesis by (auto intro: terminates.Guard)
      qed
    qed
  qed
next
  case Throw thus ?case
    by (auto simp add: inter_guards_Throw)
next
  case (Catch a1 a2)
  have "(Catch a1 a2 \<inter>\<^sub>g\<^sub>s c2) = Some c" by fact
  then obtain b1 b2 d1 d2 where
    c2: "c2=Catch b1 b2" and 
    d1: "(a1 \<inter>\<^sub>g\<^sub>s b1) = Some d1" and d2: "(a2 \<inter>\<^sub>g\<^sub>s b2) = Some d2" and
    c: "c=Catch d1 d2"
    by (auto simp add: inter_guards_Catch)
  have termi_c1: "\<Gamma>\<turnstile>\<^sub>pCatch a1 a2 \<down> s" by fact
  have "\<Gamma>\<turnstile>\<^sub>pCatch d1 d2 \<down> s"
  proof (cases s)
    case Fault thus ?thesis by simp
  next
    case Stuck thus ?thesis by simp
  next
    case Abrupt thus ?thesis by simp
  next
    case (Normal s')
    note Normal_s = this
    with d1 termi_c1
    have "\<Gamma>\<turnstile>\<^sub>pd1 \<down> Normal s'"
      by (auto elim: terminates_Normal_elim_cases intro: Catch.hyps)
    moreover
    {
      fix t
      assume exec_d1: "\<Gamma>\<turnstile>\<^sub>p\<langle>d1,Normal s' \<rangle> \<Rightarrow> Abrupt t"
      have "\<Gamma>\<turnstile>\<^sub>pd2 \<down> Normal t"
      proof -
        from inter_guards_exec_noFault [OF d1 exec_d1]
        have "\<Gamma>\<turnstile>\<^sub>p\<langle>a1,Normal s' \<rangle> \<Rightarrow> Abrupt t"
          by simp
        with termi_c1 Normal_s have "\<Gamma>\<turnstile>\<^sub>pa2 \<down> Normal t"
          by (auto elim: terminates_Normal_elim_cases) 
        with d2 have "\<Gamma>\<turnstile>\<^sub>pd2 \<down> Normal t"
          by (auto intro: Catch.hyps)
        with Normal show ?thesis by simp  
      qed
    }
    ultimately have "\<Gamma>\<turnstile>\<^sub>pCatch d1 d2 \<down> Normal s'"
      by (fastforce intro: terminates.intros)
    with Normal show ?thesis by simp
  qed
  with c show ?case by simp
next 
   case (Await b bdy1 e)
   have "(Await b bdy1 e \<inter>\<^sub>g\<^sub>s c2) = Some c" by fact
  then obtain bdy2 bdy where
    c2: "c2=Await b bdy2 e" and
    bdy: "(bdy1 \<inter>\<^sub>g bdy2) = Some bdy" and
    c: "c=Await b bdy e"
    by (auto simp add: inter_guards_Await)
  have termi_c1:"\<Gamma>\<turnstile>\<^sub>pAwait b bdy1 e \<down> s" by fact 
  show ?case
  proof (cases s)
    case Fault thus ?thesis by simp
  next
    case Stuck thus ?thesis by simp
  next
    case Abrupt thus ?thesis by simp
  next
    case (Normal s') thus ?thesis  
     by (metis (no_types) Await.prems(2) TerminationCon.terminates_Normal_elim_cases(12) bdy c 
          inter_guards_terminates terminates.AwaitFalse terminates.AwaitTrue)     
  qed
qed

lemma inter_guards_terminates': 
  assumes c: "(c1 \<inter>\<^sub>g\<^sub>s c2) = Some c" 
  assumes termi_c2: "\<Gamma>\<turnstile>\<^sub>pc2\<down>s"
  shows "\<Gamma>\<turnstile>\<^sub>pc\<down>s"
proof -
  from c have "(c2 \<inter>\<^sub>g\<^sub>s c1) = Some c" 
    by (rule inter_guards_sym)
  from this termi_c2 show ?thesis
    by (rule inter_guards_terminates)
qed

(* ************************************************************************* *)
subsection {* Lemmas about @{const "mark_guards"} *}
(* ************************************************************************ *)

lemma terminates_to_terminates_mark_guards:
  assumes termi: "\<Gamma>\<turnstile>\<^sub>pc\<down>s" 
  shows "\<Gamma>\<turnstile>\<^sub>pmark_guards f c\<down>s"
using termi
proof (induct)
  case Skip thus ?case by (fastforce intro: terminates.intros)
next
  case Basic thus ?case by (fastforce intro: terminates.intros)
next
  case Spec thus ?case by (fastforce intro: terminates.intros)
next
  case Guard thus ?case by (fastforce intro: terminates.intros)
next
  case GuardFault thus ?case by (fastforce intro: terminates.intros)
next
  case Fault thus ?case by (fastforce intro: terminates.intros)
next
  case (Seq c1 s c2)
  have "\<Gamma>\<turnstile>\<^sub>pmark_guards f c1 \<down> Normal s" by fact
  moreover 
  {
    fix t
    assume exec_mark: "\<Gamma>\<turnstile>\<^sub>p\<langle>mark_guards f c1,Normal s \<rangle> \<Rightarrow> t"
    have "\<Gamma>\<turnstile>\<^sub>pmark_guards f c2 \<down> t"
    proof -
      from exec_mark_guards_to_exec [OF exec_mark] obtain t' where
        exec_c1: "\<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow> t'" and
        t_Fault: "isFault t \<longrightarrow> isFault t'" and
        t'_Fault_f: "t' = Fault f \<longrightarrow> t' = t" and
        t'_Fault: "isFault t' \<longrightarrow> isFault t" and
        t'_noFault: "\<not> isFault t' \<longrightarrow> t' = t"
        by blast
      show ?thesis
      proof (cases "isFault t'")
        case True
        with t'_Fault have "isFault t" by simp
        thus ?thesis
          by (auto elim: isFaultE)
      next
        case False
        with t'_noFault have "t'=t" by simp
        with exec_c1 Seq.hyps
        show ?thesis
          by auto
      qed
    qed  
  }
  ultimately show ?case
    by (auto intro: terminates.intros)
next
  case CondTrue thus ?case by (fastforce intro: terminates.intros)
next
  case CondFalse thus ?case by (fastforce intro: terminates.intros)
next
  case (WhileTrue s b c)
  have s_in_b: "s \<in> b" by fact
  have "\<Gamma>\<turnstile>\<^sub>pmark_guards f c \<down> Normal s" by fact
  moreover 
  {
    fix t
    assume exec_mark: "\<Gamma>\<turnstile>\<^sub>p\<langle>mark_guards f c,Normal s \<rangle> \<Rightarrow> t"
    have "\<Gamma>\<turnstile>\<^sub>pmark_guards f (While b c) \<down> t"
    proof -
      from exec_mark_guards_to_exec [OF exec_mark] obtain t' where
        exec_c1: "\<Gamma>\<turnstile>\<^sub>p\<langle>c,Normal s \<rangle> \<Rightarrow> t'" and
        t_Fault: "isFault t \<longrightarrow> isFault t'" and
        t'_Fault_f: "t' = Fault f \<longrightarrow> t' = t" and
        t'_Fault: "isFault t' \<longrightarrow> isFault t" and
        t'_noFault: "\<not> isFault t' \<longrightarrow> t' = t"
        by blast
      show ?thesis
      proof (cases "isFault t'")
        case True
        with t'_Fault have "isFault t" by simp
        thus ?thesis
          by (auto elim: isFaultE)
      next
        case False
        with t'_noFault have "t'=t" by simp
        with exec_c1 WhileTrue.hyps
        show ?thesis
          by auto
      qed
    qed  
  }
  ultimately show ?case
    by (auto intro: terminates.intros)
next
  case WhileFalse thus ?case by (fastforce intro: terminates.intros)
next
  case Call thus ?case by (fastforce intro: terminates.intros)
next
  case CallUndefined thus ?case by (fastforce intro: terminates.intros)
next
  case Stuck thus ?case by (fastforce intro: terminates.intros)
next
  case DynCom thus ?case by (fastforce intro: terminates.intros)
next
  case Throw thus ?case by (fastforce intro: terminates.intros)
next
  case Abrupt thus ?case by (fastforce intro: terminates.intros)
next 
  case (Catch c1 s c2) 
  have "\<Gamma>\<turnstile>\<^sub>pmark_guards f c1 \<down> Normal s" by fact
  moreover 
  {
    fix t
    assume exec_mark: "\<Gamma>\<turnstile>\<^sub>p\<langle>mark_guards f c1,Normal s \<rangle> \<Rightarrow> Abrupt t"
    have "\<Gamma>\<turnstile>\<^sub>pmark_guards f c2 \<down> Normal t"
    proof -
      from exec_mark_guards_to_exec [OF exec_mark] obtain t' where
        exec_c1: "\<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow> t'" and
        t'_Fault_f: "t' = Fault f \<longrightarrow> t' = Abrupt t" and
        t'_Fault: "isFault t' \<longrightarrow> isFault (Abrupt t)" and
        t'_noFault: "\<not> isFault t' \<longrightarrow> t' = Abrupt t"
        by fastforce
      show ?thesis
      proof (cases "isFault t'")
        case True
        with t'_Fault have "isFault (Abrupt t)" by simp
        thus ?thesis by simp
      next
        case False
        with t'_noFault have "t'=Abrupt t" by simp
        with exec_c1 Catch.hyps
        show ?thesis
          by auto
      qed
    qed  
  }
  ultimately show ?case
    by (auto intro: terminates.intros)
next
   case (AwaitTrue s b \<Gamma>\<^sub>p c)    
   then have "\<Gamma>\<^sub>\<not>\<^sub>a\<turnstile>c \<down> Normal s"
   using AwaitTrue.hyps(2) AwaitTrue.hyps(3) terminates_to_terminates_mark_guards by blast
   thus ?case
    by (simp add: AwaitTrue.hyps(1) terminates.AwaitTrue terminates_to_terminates_mark_guards) 
next 
  case (AwaitFalse s b) thus ?case by (fastforce intro: terminates.AwaitFalse)
qed


lemma terminates_mark_guards_to_terminates_Normal:
  "\<And>s. \<Gamma>\<turnstile>\<^sub>pmark_guards f c\<down>Normal s \<Longrightarrow> \<Gamma>\<turnstile>\<^sub>pc\<down>Normal s"
proof (induct c)
  case Skip thus ?case by (fastforce intro: terminates.intros)
next
  case Basic thus ?case by (fastforce intro: terminates.intros)
next
  case Spec thus ?case by (fastforce intro: terminates.intros)
next
  case (Seq c1 c2) 
  have "\<Gamma>\<turnstile>\<^sub>pmark_guards f (Seq c1 c2) \<down> Normal s" by fact
  then obtain
    termi_merge_c1: "\<Gamma>\<turnstile>\<^sub>pmark_guards f c1 \<down> Normal s" and
    termi_merge_c2: "\<forall>s'. \<Gamma>\<turnstile>\<^sub>p\<langle>mark_guards f c1,Normal s \<rangle> \<Rightarrow> s' \<longrightarrow> 
                           \<Gamma>\<turnstile>\<^sub>pmark_guards f c2 \<down> s'"
    by (auto elim: terminates_Normal_elim_cases)
  from termi_merge_c1 Seq.hyps
  have "\<Gamma>\<turnstile>\<^sub>pc1 \<down> Normal s" by iprover
  moreover
  {
    fix s'
    assume exec_c1: "\<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow> s'"
    have "\<Gamma>\<turnstile>\<^sub>p c2 \<down> s'"
    proof (cases "isFault s'")
      case True
      thus ?thesis by (auto elim: isFaultE)
    next
      case False
      from exec_to_exec_mark_guards [OF exec_c1 False] 
      have "\<Gamma>\<turnstile>\<^sub>p\<langle>mark_guards f c1,Normal s \<rangle> \<Rightarrow> s'" .
      from termi_merge_c2 [rule_format, OF this] Seq.hyps
      show ?thesis
        by (cases s') (auto)
    qed
  }
  ultimately show ?case by (auto intro: terminates.intros)
next
  case Cond thus ?case 
    by (fastforce intro: terminates.intros elim: terminates_Normal_elim_cases)
next
  case (While b c)
  {
    fix u c'
    assume termi_c': "\<Gamma>\<turnstile>\<^sub>pc' \<down> Normal u"
    assume c': "c' = mark_guards f (While b c)"
    have "\<Gamma>\<turnstile>\<^sub>pWhile b c \<down> Normal u"
      using termi_c' c'
    proof (induct)
      case (WhileTrue s b' c')
      have s_in_b: "s \<in> b" using WhileTrue by simp
      have "\<Gamma>\<turnstile>\<^sub>pmark_guards f c \<down> Normal s"
        using WhileTrue by (auto elim: terminates_Normal_elim_cases)
      with While.hyps have "\<Gamma>\<turnstile>\<^sub>pc \<down> Normal s"
        by auto
      moreover
      have hyp_w: "\<forall>w. \<Gamma>\<turnstile>\<^sub>p\<langle>mark_guards f c,Normal s \<rangle> \<Rightarrow> w \<longrightarrow> \<Gamma>\<turnstile>\<^sub>pWhile b c \<down> w"
        using WhileTrue by simp
      hence "\<forall>w. \<Gamma>\<turnstile>\<^sub>p\<langle>c,Normal s \<rangle> \<Rightarrow> w \<longrightarrow> \<Gamma>\<turnstile>\<^sub>pWhile b c \<down> w"
        apply -
        apply (rule allI)
        apply (case_tac "w")
        apply (auto dest: exec_to_exec_mark_guards)
        done
      ultimately show ?case
        using s_in_b
        by (auto intro: terminates.intros)
    next
      case WhileFalse thus ?case by (auto intro: terminates.intros) 
    qed auto
  }
  with While show ?case by simp
next
  case Call thus ?case 
    by (fastforce intro: terminates.intros )
next
  case DynCom thus ?case 
    by (fastforce intro: terminates.intros elim: terminates_Normal_elim_cases)
next
  case (Guard f g c)
  thus ?case by (fastforce intro: terminates.intros elim: terminates_Normal_elim_cases)
next
  case Throw thus ?case 
    by (fastforce intro: terminates.intros )
next
  case (Catch c1 c2) 
  have "\<Gamma>\<turnstile>\<^sub>pmark_guards f (Catch c1 c2) \<down> Normal s" by fact
  then obtain
    termi_merge_c1: "\<Gamma>\<turnstile>\<^sub>pmark_guards f c1 \<down> Normal s" and
    termi_merge_c2: "\<forall>s'. \<Gamma>\<turnstile>\<^sub>p\<langle>mark_guards f c1,Normal s \<rangle> \<Rightarrow> Abrupt s' \<longrightarrow> 
                           \<Gamma>\<turnstile>\<^sub>pmark_guards f c2 \<down> Normal s'"
    by (auto elim: terminates_Normal_elim_cases)
  from termi_merge_c1 Catch.hyps
  have "\<Gamma>\<turnstile>\<^sub>pc1 \<down> Normal s" by iprover
  moreover
  {
    fix s'
    assume exec_c1: "\<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow> Abrupt s'"
    have "\<Gamma>\<turnstile>\<^sub>p c2 \<down> Normal s'"
    proof -
      from exec_to_exec_mark_guards [OF exec_c1] 
      have "\<Gamma>\<turnstile>\<^sub>p\<langle>mark_guards f c1,Normal s \<rangle> \<Rightarrow> Abrupt s'" by simp
      from termi_merge_c2 [rule_format, OF this] Catch.hyps
      show ?thesis
        by iprover
    qed
  }
  ultimately show ?case by (auto intro: terminates.intros)
next
  case (Await b c) thus ?case 
  using terminates_mark_guards_to_terminates_Normal
  by (fastforce intro: terminates.intros(11) terminates.intros(12) elim: terminates_Normal_elim_cases)
qed

lemma terminates_mark_guards_to_terminates:
  "\<Gamma>\<turnstile>\<^sub>pmark_guards f c\<down>s \<Longrightarrow> \<Gamma>\<turnstile>\<^sub>pc\<down> s"
  by (cases s) (auto intro: terminates_mark_guards_to_terminates_Normal)


(* ************************************************************************* *)
subsection {* Lemmas about @{const "merge_guards"} *}
(* ************************************************************************ *)

lemma terminates_to_terminates_merge_guards:
  assumes termi: "\<Gamma>\<turnstile>\<^sub>pc\<down>s" 
  shows "\<Gamma>\<turnstile>\<^sub>pmerge_guards c\<down>s"
using termi
proof (induct)
  case (Guard s g c f)
  have s_in_g: "s \<in> g" by fact
  have termi_merge_c: "\<Gamma>\<turnstile>\<^sub>pmerge_guards c \<down> Normal s" by fact
  show ?case
  proof (cases "\<exists>f' g' c'. merge_guards c = Guard f' g' c'")
    case False
    hence "merge_guards (Guard f g c) = Guard f g (merge_guards c)"
      by (cases "merge_guards c") (auto simp add: Let_def)
    with s_in_g termi_merge_c show ?thesis
      by (auto intro: terminates.intros)
  next
    case True
    then obtain f' g' c' where 
      mc: "merge_guards c = Guard f' g' c'"
      by blast
    show ?thesis
    proof (cases "f=f'")
      case False
      with mc have "merge_guards (Guard f g c) = Guard f g (merge_guards c)"
        by (simp add: Let_def)
      with s_in_g termi_merge_c show ?thesis
        by (auto intro: terminates.intros)
    next
      case True
      with mc have "merge_guards (Guard f g c) = Guard f (g \<inter> g') c'"
        by simp
      with s_in_g mc True termi_merge_c
      show ?thesis
        by (cases "s \<in> g'")
           (auto intro: terminates.intros elim: terminates_Normal_elim_cases)
    qed
  qed
next
  case (GuardFault s g f c)
  have "s \<notin> g" by fact
  thus ?case
    by (cases "merge_guards c")
       (auto intro: terminates.intros split: if_split_asm simp add: Let_def)
next
  case (AwaitTrue s b  \<Gamma>1 c)
  thus ?case 
    by (simp add: terminates_to_terminates_merge_guards terminates.AwaitTrue)  
qed (fastforce intro: terminates.intros dest: exec_merge_guards_to_exec)+

lemma terminates_merge_guards_to_terminates_Normal:
  shows "\<And>s. \<Gamma>\<turnstile>\<^sub>pmerge_guards c\<down>Normal s \<Longrightarrow> \<Gamma>\<turnstile>\<^sub>pc\<down>Normal s"
proof (induct c)
  case Skip thus ?case by (fastforce intro: terminates.intros)
next
  case Basic thus ?case by (fastforce intro: terminates.intros)
next
  case Spec thus ?case by (fastforce intro: terminates.intros)
next
  case (Seq c1 c2) 
  have "\<Gamma>\<turnstile>\<^sub>pmerge_guards (Seq c1 c2) \<down> Normal s" by fact
  then obtain
    termi_merge_c1: "\<Gamma>\<turnstile>\<^sub>pmerge_guards c1 \<down> Normal s" and
    termi_merge_c2: "\<forall>s'. \<Gamma>\<turnstile>\<^sub>p\<langle>merge_guards c1,Normal s \<rangle> \<Rightarrow> s' \<longrightarrow> 
                           \<Gamma>\<turnstile>\<^sub>pmerge_guards c2 \<down> s'"
    by (auto elim: terminates_Normal_elim_cases)
  from termi_merge_c1 Seq.hyps
  have "\<Gamma>\<turnstile>\<^sub>pc1 \<down> Normal s" by iprover
  moreover
  {
    fix s'
    assume exec_c1: "\<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow> s'"
    have "\<Gamma>\<turnstile>\<^sub>p c2 \<down> s'"
    proof -
      from exec_to_exec_merge_guards [OF exec_c1] 
      have "\<Gamma>\<turnstile>\<^sub>p\<langle>merge_guards c1,Normal s \<rangle> \<Rightarrow> s'" .
      from termi_merge_c2 [rule_format, OF this] Seq.hyps
      show ?thesis
        by (cases s') (auto)
    qed
  }
  ultimately show ?case by (auto intro: terminates.intros)
next
  case Cond thus ?case 
    by (fastforce intro: terminates.intros elim: terminates_Normal_elim_cases)
next
  case (While b c)
  {
    fix u c'
    assume termi_c': "\<Gamma>\<turnstile>\<^sub>pc' \<down> Normal u"
    assume c': "c' = merge_guards (While b c)"
    have "\<Gamma>\<turnstile>\<^sub>pWhile b c \<down> Normal u"
      using termi_c' c'
    proof (induct)
      case (WhileTrue s b' c')
      have s_in_b: "s \<in> b" using WhileTrue by simp
      have "\<Gamma>\<turnstile>\<^sub>pmerge_guards c \<down> Normal s"
        using WhileTrue by (auto elim: terminates_Normal_elim_cases)
      with While.hyps have "\<Gamma>\<turnstile>\<^sub>pc \<down> Normal s"
        by auto
      moreover
      have hyp_w: "\<forall>w. \<Gamma>\<turnstile>\<^sub>p\<langle>merge_guards c,Normal s \<rangle> \<Rightarrow> w \<longrightarrow> \<Gamma>\<turnstile>\<^sub>pWhile b c \<down> w"
        using WhileTrue by simp
      hence "\<forall>w. \<Gamma>\<turnstile>\<^sub>p\<langle>c,Normal s \<rangle> \<Rightarrow> w \<longrightarrow> \<Gamma>\<turnstile>\<^sub>pWhile b c \<down> w"
        by (simp add: exec_iff_exec_merge_guards [symmetric])
      ultimately show ?case
        using s_in_b
        by (auto intro: terminates.intros)
    next
      case WhileFalse thus ?case by (auto intro: terminates.intros) 
    qed auto
  }
  with While show ?case by simp
next
  case Call thus ?case 
    by (fastforce intro: terminates.intros )
next
  case DynCom thus ?case 
    by (fastforce intro: terminates.intros elim: terminates_Normal_elim_cases)
next
  case (Guard f g c)
  have termi_merge: "\<Gamma>\<turnstile>\<^sub>pmerge_guards (Guard f g c) \<down> Normal s" by fact
  show ?case
  proof (cases "\<exists>f' g' c'. merge_guards c = Guard f' g' c'")
    case False
    hence m: "merge_guards (Guard f g c) = Guard f g (merge_guards c)"
      by (cases "merge_guards c") (auto simp add: Let_def)
    from termi_merge Guard.hyps show ?thesis
      by (simp only: m)
         (fastforce intro: terminates.intros elim: terminates_Normal_elim_cases)
  next
    case True
    then obtain f' g' c' where 
      mc: "merge_guards c = Guard f' g' c'"
      by blast
    show ?thesis
    proof (cases "f=f'")
      case False
      with mc have m: "merge_guards (Guard f g c) = Guard f g (merge_guards c)"
        by (simp add: Let_def)
      from termi_merge Guard.hyps show ?thesis
      by (simp only: m)
         (fastforce intro: terminates.intros elim: terminates_Normal_elim_cases)
    next
      case True
      with mc have m: "merge_guards (Guard f g c) = Guard f (g \<inter> g') c'"
        by simp
      from termi_merge Guard.hyps
      show ?thesis
        by (simp only: m mc)
           (auto intro: terminates.intros elim: terminates_Normal_elim_cases)
    qed
  qed
next
  case Throw thus ?case 
    by (fastforce intro: terminates.intros )
next
  case (Catch c1 c2) 
  have "\<Gamma>\<turnstile>\<^sub>pmerge_guards (Catch c1 c2) \<down> Normal s" by fact
  then obtain
    termi_merge_c1: "\<Gamma>\<turnstile>\<^sub>pmerge_guards c1 \<down> Normal s" and
    termi_merge_c2: "\<forall>s'. \<Gamma>\<turnstile>\<^sub>p\<langle>merge_guards c1,Normal s \<rangle> \<Rightarrow> Abrupt s' \<longrightarrow> 
                           \<Gamma>\<turnstile>\<^sub>pmerge_guards c2 \<down> Normal s'"
    by (auto elim: terminates_Normal_elim_cases)
  from termi_merge_c1 Catch.hyps
  have "\<Gamma>\<turnstile>\<^sub>pc1 \<down> Normal s" by iprover
  moreover
  {
    fix s'
    assume exec_c1: "\<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow> Abrupt s'"
    have "\<Gamma>\<turnstile>\<^sub>p c2 \<down> Normal s'"
    proof -
      from exec_to_exec_merge_guards [OF exec_c1] 
      have "\<Gamma>\<turnstile>\<^sub>p\<langle>merge_guards c1,Normal s \<rangle> \<Rightarrow> Abrupt s'" .
      from termi_merge_c2 [rule_format, OF this] Catch.hyps
      show ?thesis
        by iprover
    qed
  }
  ultimately show ?case by (auto intro: terminates.intros)
next
  case (Await b c) thus ?case 
    using terminates_merge_guards_to_terminates_Normal
    by (fastforce intro: terminates.intros(11) terminates.intros(12) elim: terminates_Normal_elim_cases)
qed

lemma terminates_merge_guards_to_terminates:
   "\<Gamma>\<turnstile>\<^sub>pmerge_guards c\<down> s \<Longrightarrow> \<Gamma>\<turnstile>\<^sub>pc\<down> s"
by (cases s) (auto intro: terminates_merge_guards_to_terminates_Normal)

theorem terminates_iff_terminates_merge_guards:
  "\<Gamma>\<turnstile>\<^sub>pc\<down> s = \<Gamma>\<turnstile>\<^sub>pmerge_guards c\<down> s"
  by (iprover intro: terminates_to_terminates_merge_guards 
    terminates_merge_guards_to_terminates)

(* ************************************************************************* *)
subsection {* Lemmas about @{term "c\<^sub>1 \<subseteq>\<^sub>g c\<^sub>2"} *}
(* ************************************************************************ *)

lemma terminates_fewer_guards_Normal:
  shows "\<And>c s. \<lbrakk>\<Gamma>\<turnstile>\<^sub>pc'\<down>Normal s; c \<subseteq>\<^sub>g\<^sub>s c'; \<Gamma>\<turnstile>\<^sub>p\<langle>c',Normal s \<rangle> \<Rightarrow>\<notin>Fault ` UNIV\<rbrakk>
              \<Longrightarrow> \<Gamma>\<turnstile>\<^sub>pc\<down>Normal s"
proof (induct c')
  case Skip thus ?case by (auto intro: terminates.intros dest: subseteq_guardsD)
next
  case Basic thus ?case by (auto intro: terminates.intros dest: subseteq_guardsD)
next
  case Spec thus ?case by (auto intro: terminates.intros dest: subseteq_guardsD)
next
  case (Seq c1' c2')
  have termi: "\<Gamma>\<turnstile>\<^sub>pSeq c1' c2' \<down> Normal s" by fact
  then obtain 
    termi_c1': "\<Gamma>\<turnstile>\<^sub>pc1'\<down> Normal s" and
    termi_c2': "\<forall>s'. \<Gamma>\<turnstile>\<^sub>p\<langle>c1',Normal s \<rangle> \<Rightarrow> s' \<longrightarrow> \<Gamma>\<turnstile>\<^sub>pc2'\<down> s'"
    by (auto elim: terminates_Normal_elim_cases)
  have noFault: "\<Gamma>\<turnstile>\<^sub>p\<langle>Seq c1' c2',Normal s \<rangle> \<Rightarrow>\<notin>Fault ` UNIV" by fact
  hence noFault_c1': "\<Gamma>\<turnstile>\<^sub>p\<langle>c1',Normal s \<rangle> \<Rightarrow>\<notin>Fault ` UNIV"
    by (auto intro: exec.intros simp add: final_notin_def)
  have "c \<subseteq>\<^sub>g\<^sub>s Seq c1' c2'" by fact
  from subseteq_guards_Seq [OF this] obtain c1 c2 where 
    c: "c = Seq c1 c2" and
    c1_c1': "c1 \<subseteq>\<^sub>g\<^sub>s c1'" and
    c2_c2': "c2 \<subseteq>\<^sub>g\<^sub>s c2'" 
    by blast
  from termi_c1' c1_c1' noFault_c1'
  have "\<Gamma>\<turnstile>\<^sub>pc1\<down> Normal s"
    by (rule Seq.hyps)
  moreover
  {
    fix t
    assume exec_c1: "\<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow> t"
    have "\<Gamma>\<turnstile>\<^sub>pc2\<down> t"
    proof -
      from exec_to_exec_subseteq_guards [OF c1_c1' exec_c1] obtain t' where
        exec_c1': "\<Gamma>\<turnstile>\<^sub>p\<langle>c1',Normal s \<rangle> \<Rightarrow> t'" and
        t_Fault: "isFault t \<longrightarrow> isFault t'" and
        t'_noFault: "\<not> isFault t' \<longrightarrow> t' = t"
        by blast
      show ?thesis
      proof (cases "isFault t'")
        case True
        with exec_c1' noFault_c1'
        have False
          by (fastforce elim: isFaultE dest: Fault_end simp add: final_notin_def)
        thus ?thesis ..
      next
        case False
        with t'_noFault have t': "t'=t" by simp
        with termi_c2' exec_c1' 
        have termi_c2': "\<Gamma>\<turnstile>\<^sub>pc2'\<down> t"
          by auto
        show ?thesis
        proof (cases t)
          case Fault thus ?thesis by auto
        next
          case Abrupt thus ?thesis by auto
        next
          case Stuck thus ?thesis by auto
        next
          case (Normal u)
          with noFault exec_c1' t' 
          have "\<Gamma>\<turnstile>\<^sub>p\<langle>c2',Normal u \<rangle> \<Rightarrow>\<notin>Fault ` UNIV"
            by (auto intro: exec.intros simp add: final_notin_def)
          from termi_c2' [simplified Normal] c2_c2' this
          have "\<Gamma>\<turnstile>\<^sub>pc2 \<down> Normal u"
            by (rule Seq.hyps)
          with Normal exec_c1
          show ?thesis by simp
        qed
      qed
    qed
  }
  ultimately show ?case using c by (auto intro: terminates.intros)
next
  case (Cond b c1' c2')
  have noFault: "\<Gamma>\<turnstile>\<^sub>p\<langle>Cond b c1' c2',Normal s \<rangle> \<Rightarrow>\<notin>Fault ` UNIV" by fact
  have termi: "\<Gamma>\<turnstile>\<^sub>pCond b c1' c2' \<down> Normal s" by fact
  have "c \<subseteq>\<^sub>g\<^sub>s Cond b c1' c2'" by fact
  from subseteq_guards_Cond [OF this] obtain c1 c2 where
    c: "c = Cond b c1 c2" and
    c1_c1': "c1 \<subseteq>\<^sub>g\<^sub>s c1'" and
    c2_c2': "c2 \<subseteq>\<^sub>g\<^sub>s c2'" 
    by blast
  thus ?case 
  proof (cases "s \<in> b")
    case True
    with termi have termi_c1': "\<Gamma>\<turnstile>\<^sub>pc1' \<down> Normal s"
      by (auto elim: terminates_Normal_elim_cases)
    from True noFault have "\<Gamma>\<turnstile>\<^sub>p\<langle>c1',Normal s \<rangle> \<Rightarrow>\<notin>Fault ` UNIV"
      by (auto intro: exec.intros simp add: final_notin_def)
    from termi_c1' c1_c1' this
    have "\<Gamma>\<turnstile>\<^sub>pc1 \<down> Normal s"
      by (rule Cond.hyps)
    with True c show ?thesis
      by (auto intro: terminates.intros)
  next
    case False
    with termi have termi_c2': "\<Gamma>\<turnstile>\<^sub>pc2' \<down> Normal s"
      by (auto elim: terminates_Normal_elim_cases)
    from False noFault have "\<Gamma>\<turnstile>\<^sub>p\<langle>c2',Normal s \<rangle> \<Rightarrow>\<notin>Fault ` UNIV"
      by (auto intro: exec.intros simp add: final_notin_def)
    from termi_c2' c2_c2' this
    have "\<Gamma>\<turnstile>\<^sub>pc2 \<down> Normal s"
      by (rule Cond.hyps)
    with False c show ?thesis
      by (auto intro: terminates.intros)
  qed
next
  case (While b c')
  have noFault: "\<Gamma>\<turnstile>\<^sub>p\<langle>While b c',Normal s \<rangle> \<Rightarrow>\<notin>Fault ` UNIV" by fact
  have termi: "\<Gamma>\<turnstile>\<^sub>pWhile b c' \<down> Normal s" by fact
  have "c \<subseteq>\<^sub>g\<^sub>s While b c'" by fact
  from subseteq_guards_While [OF this]
  obtain c'' where 
    c: "c = While b c''" and
    c''_c': "c'' \<subseteq>\<^sub>g\<^sub>s c'"
    by blast
  {
    fix d u
    assume termi: "\<Gamma>\<turnstile>\<^sub>pd \<down> u"
    assume d: "d = While b c'"
    assume noFault: "\<Gamma>\<turnstile>\<^sub>p\<langle>While b c',u \<rangle> \<Rightarrow>\<notin>Fault ` UNIV"
    have "\<Gamma>\<turnstile>\<^sub>pWhile b c'' \<down> u"
    using termi d noFault
    proof (induct)
      case (WhileTrue u b' c''')
      have u_in_b: "u \<in> b" using WhileTrue by simp
      have termi_c': "\<Gamma>\<turnstile>\<^sub>pc' \<down> Normal u" using WhileTrue by simp
      have noFault: "\<Gamma>\<turnstile>\<^sub>p\<langle>While b c',Normal u \<rangle> \<Rightarrow>\<notin>Fault ` UNIV" using WhileTrue by simp
      hence noFault_c': "\<Gamma>\<turnstile>\<^sub>p\<langle>c',Normal u \<rangle> \<Rightarrow>\<notin>Fault ` UNIV" using u_in_b
        by (auto intro: exec.intros simp add: final_notin_def)
      from While.hyps [OF termi_c' c''_c' this] 
      have "\<Gamma>\<turnstile>\<^sub>pc'' \<down> Normal u".
      moreover
      from WhileTrue 
      have hyp_w: "\<forall>s'. \<Gamma>\<turnstile>\<^sub>p\<langle>c',Normal u \<rangle> \<Rightarrow> s'  \<longrightarrow> \<Gamma>\<turnstile>\<^sub>p\<langle>While b c',s' \<rangle> \<Rightarrow>\<notin>Fault ` UNIV 
                        \<longrightarrow> \<Gamma>\<turnstile>\<^sub>pWhile b c'' \<down> s'"
        by simp
      {
        fix v
        assume exec_c'': "\<Gamma>\<turnstile>\<^sub>p\<langle>c'',Normal u \<rangle> \<Rightarrow> v"
        have "\<Gamma>\<turnstile>\<^sub>pWhile b c'' \<down> v"
        proof - 
          from exec_to_exec_subseteq_guards [OF c''_c' exec_c''] obtain v' where
            exec_c': "\<Gamma>\<turnstile>\<^sub>p\<langle>c',Normal u \<rangle> \<Rightarrow> v'" and
            v_Fault: "isFault v \<longrightarrow> isFault v'" and 
            v'_noFault: "\<not> isFault v' \<longrightarrow> v' = v"
            by auto
          show ?thesis
          proof (cases "isFault v'")
            case True
            with exec_c' noFault u_in_b
            have False
              by (fastforce 
                   simp add: final_notin_def intro: exec.intros elim: isFaultE)
            thus ?thesis ..
          next
            case False
            with v'_noFault have v': "v'=v"
              by simp
            with noFault exec_c' u_in_b
            have "\<Gamma>\<turnstile>\<^sub>p\<langle>While b c',v \<rangle> \<Rightarrow>\<notin>Fault ` UNIV"
              by (fastforce simp add: final_notin_def intro: exec.intros)
            from hyp_w [rule_format, OF exec_c' [simplified v'] this]
            show "\<Gamma>\<turnstile>\<^sub>pWhile b c'' \<down> v" .
          qed
        qed
      }
      ultimately
      show ?case using u_in_b 
        by (auto intro: terminates.intros)
    next
      case WhileFalse thus ?case by (auto intro: terminates.intros)
    qed auto
  }
  with c noFault termi show ?case
    by auto
next
  case Call thus ?case by (auto intro: terminates.intros dest: subseteq_guardsD)
next
  case (DynCom C') 
  have termi: "\<Gamma>\<turnstile>\<^sub>pDynCom C' \<down> Normal s" by fact
  hence termi_C': "\<Gamma>\<turnstile>\<^sub>pC' s \<down> Normal s"
    by cases
  have noFault: "\<Gamma>\<turnstile>\<^sub>p\<langle>DynCom C',Normal s \<rangle> \<Rightarrow>\<notin>Fault ` UNIV" by fact
  hence noFault_C': "\<Gamma>\<turnstile>\<^sub>p\<langle>C' s,Normal s \<rangle> \<Rightarrow>\<notin>Fault ` UNIV"
    by (auto intro: exec.intros simp add: final_notin_def)
  have "c \<subseteq>\<^sub>g\<^sub>s DynCom C'" by fact
  from subseteq_guards_DynCom [OF this] obtain C where
    c: "c = DynCom C" and
    C_C': "\<forall>s. C s \<subseteq>\<^sub>g\<^sub>s C' s"
    by blast
  from DynCom.hyps termi_C' C_C' [rule_format] noFault_C'
  have "\<Gamma>\<turnstile>\<^sub>pC s \<down> Normal s"
    by fast
  with c show ?case
    by (auto intro: terminates.intros)
next 
  case (Guard f' g' c')
  have noFault: "\<Gamma>\<turnstile>\<^sub>p\<langle>Guard f' g' c',Normal s \<rangle> \<Rightarrow>\<notin>Fault ` UNIV" by fact
  have termi: "\<Gamma>\<turnstile>\<^sub>pGuard f' g' c' \<down> Normal s" by fact
  have "c \<subseteq>\<^sub>g\<^sub>s Guard f' g' c'" by fact
  hence c_cases: "(c \<subseteq>\<^sub>g\<^sub>s c') \<or> (\<exists>c''. c = Guard f' g' c'' \<and> (c'' \<subseteq>\<^sub>g\<^sub>s c'))"
    by (rule subseteq_guards_Guard)
  thus ?case
  proof (cases "s \<in> g'")
    case True
    note s_in_g' = this
    with noFault have noFault_c': "\<Gamma>\<turnstile>\<^sub>p\<langle>c',Normal s \<rangle> \<Rightarrow>\<notin>Fault ` UNIV"
      by (auto simp add: final_notin_def intro: exec.intros)
    from termi s_in_g' have termi_c': "\<Gamma>\<turnstile>\<^sub>pc' \<down> Normal s"
      by cases auto
    from c_cases show ?thesis
    proof
      assume "c \<subseteq>\<^sub>g\<^sub>s c'"
      from termi_c' this noFault_c'
      show "\<Gamma>\<turnstile>\<^sub>pc \<down> Normal s" 
        by (rule Guard.hyps)
    next
      assume "\<exists>c''. c = Guard f' g' c'' \<and> (c'' \<subseteq>\<^sub>g\<^sub>s c')"
      then obtain c'' where
        c: "c = Guard f' g' c''" and c''_c': "c'' \<subseteq>\<^sub>g\<^sub>s c'" 
        by blast
      from termi_c' c''_c' noFault_c'
      have "\<Gamma>\<turnstile>\<^sub>pc'' \<down> Normal s" 
        by (rule Guard.hyps)
      with s_in_g' c
      show ?thesis
        by (auto intro: terminates.intros)
    qed
  next
    case False
    with noFault have False
      by (auto intro: exec.intros simp add: final_notin_def)
    thus ?thesis ..
  qed
next
  case Throw thus ?case by (auto intro: terminates.intros dest: subseteq_guardsD)
next
  case (Catch c1' c2')
  have termi: "\<Gamma>\<turnstile>\<^sub>pCatch c1' c2' \<down> Normal s" by fact
  then obtain 
    termi_c1': "\<Gamma>\<turnstile>\<^sub>pc1'\<down> Normal s" and
    termi_c2': "\<forall>s'. \<Gamma>\<turnstile>\<^sub>p\<langle>c1',Normal s \<rangle> \<Rightarrow> Abrupt s' \<longrightarrow> \<Gamma>\<turnstile>\<^sub>pc2'\<down> Normal s'"
    by (auto elim: terminates_Normal_elim_cases)
  have noFault: "\<Gamma>\<turnstile>\<^sub>p\<langle>Catch c1' c2',Normal s \<rangle> \<Rightarrow>\<notin>Fault ` UNIV" by fact
  hence noFault_c1': "\<Gamma>\<turnstile>\<^sub>p\<langle>c1',Normal s \<rangle> \<Rightarrow>\<notin>Fault ` UNIV"
    by (fastforce intro: exec.intros simp add: final_notin_def)
  have "c \<subseteq>\<^sub>g\<^sub>s Catch c1' c2'"  by fact
  from subseteq_guards_Catch [OF this] obtain c1 c2 where 
    c: "c = Catch c1 c2" and
    c1_c1': "c1 \<subseteq>\<^sub>g\<^sub>s c1'" and
    c2_c2': "c2 \<subseteq>\<^sub>g\<^sub>s c2'" 
    by blast
  from termi_c1' c1_c1' noFault_c1'
  have "\<Gamma>\<turnstile>\<^sub>pc1\<down> Normal s"
    by (rule Catch.hyps)
  moreover
  {
    fix t
    assume exec_c1: "\<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow> Abrupt t"
    have "\<Gamma>\<turnstile>\<^sub>pc2\<down> Normal t"
    proof -
      from exec_to_exec_subseteq_guards [OF c1_c1' exec_c1] obtain t' where
        exec_c1': "\<Gamma>\<turnstile>\<^sub>p\<langle>c1',Normal s \<rangle> \<Rightarrow> t'" and
        t'_noFault: "\<not> isFault t' \<longrightarrow> t' = Abrupt t"
        by blast
      show ?thesis
      proof (cases "isFault t'")
        case True
        with exec_c1' noFault_c1'
        have False
          by (fastforce elim: isFaultE dest: Fault_end simp add: final_notin_def)
        thus ?thesis ..
      next
        case False
        with t'_noFault have t': "t'=Abrupt t" by simp
        with termi_c2' exec_c1' 
        have termi_c2': "\<Gamma>\<turnstile>\<^sub>pc2'\<down> Normal t"
          by auto
        with noFault exec_c1' t' 
        have "\<Gamma>\<turnstile>\<^sub>p\<langle>c2',Normal t \<rangle> \<Rightarrow>\<notin>Fault ` UNIV"
          by (auto intro: exec.intros simp add: final_notin_def)
        from termi_c2' c2_c2' this
        show "\<Gamma>\<turnstile>\<^sub>pc2 \<down> Normal t"
          by (rule Catch.hyps)
      qed
    qed
  }
  ultimately show ?case using c by (auto intro: terminates.intros)
next
  case (Await b c' e)   
  have noFault: "\<Gamma>\<turnstile>\<^sub>p\<langle>Await b c' e,Normal s \<rangle> \<Rightarrow>\<notin>Fault ` UNIV" by fact
  have termi: "\<Gamma>\<turnstile>\<^sub>pAwait b c' e \<down> Normal s" by fact
  have "c \<subseteq>\<^sub>g\<^sub>s Await b c' e" by fact
  from subseteq_guards_Await [OF this]
  obtain c'' where 
    c: "c = Await b c'' e" and
    c''_c': "c'' \<subseteq>\<^sub>g c'"
  by blast
  with c c''_c' noFault termi 
  show ?case using terminates_fewer_guards_Normal
   by (metis Semantic.final_notinI SemanticCon.final_notin_def TerminationCon.terminates_Normal_elim_cases(12) exec.AwaitTrue terminates.AwaitFalse terminates.AwaitTrue)
           
qed

theorem terminates_fewer_guards:
  shows "\<lbrakk>\<Gamma>\<turnstile>\<^sub>pc'\<down>s; c \<subseteq>\<^sub>g\<^sub>s c'; \<Gamma>\<turnstile>\<^sub>p\<langle>c',s \<rangle> \<Rightarrow>\<notin>Fault ` UNIV\<rbrakk>
         \<Longrightarrow> \<Gamma>\<turnstile>\<^sub>pc\<down>s"
  by (cases s) (auto intro: terminates_fewer_guards_Normal)

lemma terminates_noFault_strip_guards:
  assumes termi: "\<Gamma>\<turnstile>\<^sub>pc\<down>Normal s"
  shows "\<lbrakk>\<Gamma>\<turnstile>\<^sub>p\<langle>c,Normal s \<rangle> \<Rightarrow>\<notin>Fault ` F\<rbrakk> \<Longrightarrow> \<Gamma>\<turnstile>\<^sub>pstrip_guards F c\<down>Normal s"
using termi
proof (induct)
  case Skip thus ?case by (auto intro: terminates.intros)
next
  case Basic thus ?case by (auto intro: terminates.intros)
next
  case Spec thus ?case by (auto intro: terminates.intros)
next
  case (Guard s g c f)
  have s_in_g: "s \<in> g" by fact
  have "\<Gamma>\<turnstile>\<^sub>pc \<down> Normal s" by fact
  have "\<Gamma>\<turnstile>\<^sub>p\<langle>Guard f g c,Normal s \<rangle> \<Rightarrow>\<notin>Fault ` F" by fact
  with s_in_g have "\<Gamma>\<turnstile>\<^sub>p\<langle>c,Normal s \<rangle> \<Rightarrow>\<notin>Fault ` F"
    by (fastforce simp add: final_notin_def intro: exec.intros)
  with Guard.hyps have "\<Gamma>\<turnstile>\<^sub>pstrip_guards F c \<down> Normal s" by simp
  with s_in_g show ?case
    by (auto intro: terminates.intros)
next
  case GuardFault thus ?case 
    by (auto intro: terminates.intros exec.intros simp add: final_notin_def )
next
  case Fault thus ?case by (auto intro: terminates.intros)
next
  case (Seq c1 s c2) 
  have noFault_Seq: "\<Gamma>\<turnstile>\<^sub>p\<langle>Seq c1 c2,Normal s \<rangle> \<Rightarrow>\<notin>Fault ` F" by fact
  hence noFault_c1: "\<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow>\<notin>Fault ` F"
    by (auto simp add: final_notin_def intro: exec.intros)
  with Seq.hyps have "\<Gamma>\<turnstile>\<^sub>pstrip_guards F c1 \<down> Normal s" by simp
  moreover
  {
    fix s'
    assume exec_strip_guards_c1: "\<Gamma>\<turnstile>\<^sub>p\<langle>strip_guards F c1,Normal s \<rangle> \<Rightarrow> s'"
    have "\<Gamma>\<turnstile>\<^sub>pstrip_guards F c2 \<down> s'"
    proof (cases "isFault s'")
      case True
      thus ?thesis by (auto elim: isFaultE intro: terminates.intros)
    next
      case False
      with exec_strip_guards_to_exec [OF exec_strip_guards_c1] noFault_c1
      have "\<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow> s'"
        by (auto simp add: final_notin_def elim!: isFaultE)
      moreover
      from this noFault_Seq have "\<Gamma>\<turnstile>\<^sub>p\<langle>c2,s' \<rangle> \<Rightarrow>\<notin>Fault ` F"
        by (auto simp add: final_notin_def intro: exec.intros)
      ultimately show ?thesis
        using Seq.hyps by simp
    qed
  }
  ultimately show ?case
    by (auto intro: terminates.intros)
next
  case CondTrue thus ?case
    by (fastforce intro: terminates.intros exec.intros simp add: final_notin_def ) 
next
  case CondFalse thus ?case
    by (fastforce intro: terminates.intros exec.intros simp add: final_notin_def ) 
next
  case (WhileTrue s b c)
  have s_in_b: "s \<in> b" by fact
  have noFault_while: "\<Gamma>\<turnstile>\<^sub>p\<langle>While b c,Normal s \<rangle> \<Rightarrow>\<notin>Fault ` F" by fact
  with s_in_b have noFault_c: "\<Gamma>\<turnstile>\<^sub>p\<langle>c,Normal s \<rangle> \<Rightarrow>\<notin>Fault ` F"
    by (auto simp add: final_notin_def intro: exec.intros)
  with WhileTrue.hyps have "\<Gamma>\<turnstile>\<^sub>pstrip_guards F c \<down> Normal s" by simp
  moreover
  {
    fix s'
    assume exec_strip_guards_c: "\<Gamma>\<turnstile>\<^sub>p\<langle>strip_guards F c,Normal s \<rangle> \<Rightarrow> s'"
    have "\<Gamma>\<turnstile>\<^sub>pstrip_guards F (While b c) \<down> s'"
    proof (cases "isFault s'")
      case True
      thus ?thesis by (auto elim: isFaultE intro: terminates.intros)
    next
      case False
      with exec_strip_guards_to_exec [OF exec_strip_guards_c] noFault_c
      have "\<Gamma>\<turnstile>\<^sub>p\<langle>c,Normal s \<rangle> \<Rightarrow> s'"
        by (auto simp add: final_notin_def elim!: isFaultE)
      moreover
      from this s_in_b noFault_while have "\<Gamma>\<turnstile>\<^sub>p\<langle>While b c,s' \<rangle> \<Rightarrow>\<notin>Fault ` F"
        by (auto simp add: final_notin_def intro: exec.intros)
      ultimately show ?thesis
        using WhileTrue.hyps by simp
    qed
  }
  ultimately show ?case
    using WhileTrue.hyps by (auto intro: terminates.intros)
next
  case WhileFalse thus ?case by (auto intro: terminates.intros)
next
  case Call thus ?case by (auto intro: terminates.intros)
next
  case CallUndefined thus ?case by (auto intro: terminates.intros)
next
  case Stuck thus ?case by (auto intro: terminates.intros)
next
  case DynCom thus ?case 
    by (auto intro: terminates.intros exec.intros simp add: final_notin_def )
next
  case Throw thus ?case by (auto intro: terminates.intros)
next
  case Abrupt thus ?case by (auto intro: terminates.intros)
next
  case (Catch c1 s c2)
  have noFault_Catch: "\<Gamma>\<turnstile>\<^sub>p\<langle>Catch c1 c2,Normal s \<rangle> \<Rightarrow>\<notin>Fault ` F" by fact
  hence noFault_c1: "\<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow>\<notin>Fault ` F"
    by (fastforce simp add: final_notin_def intro: exec.intros)
  with Catch.hyps have "\<Gamma>\<turnstile>\<^sub>pstrip_guards F c1 \<down> Normal s" by simp
  moreover
  {
    fix s'
    assume exec_strip_guards_c1: "\<Gamma>\<turnstile>\<^sub>p\<langle>strip_guards F c1,Normal s \<rangle> \<Rightarrow> Abrupt s'"
    have "\<Gamma>\<turnstile>\<^sub>pstrip_guards F c2 \<down> Normal s'"
    proof -
      from exec_strip_guards_to_exec [OF exec_strip_guards_c1] noFault_c1
      have "\<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow> Abrupt s'"
        by (auto simp add: final_notin_def elim!: isFaultE)
      moreover
      from this noFault_Catch have "\<Gamma>\<turnstile>\<^sub>p\<langle>c2,Normal s' \<rangle> \<Rightarrow>\<notin>Fault ` F"
        by (auto simp add: final_notin_def intro: exec.intros)
      ultimately show ?thesis
        using Catch.hyps by simp
    qed
  }
  ultimately show ?case
    using Catch.hyps by (auto intro: terminates.intros)
next
  case (AwaitTrue s b \<Gamma>\<^sub>p c) 
  with terminates_noFault_strip_guards 
  have "\<Gamma>\<^sub>p\<turnstile>Language.strip_guards F c \<down> Normal s"
   by (simp add: terminates_noFault_strip_guards Semantic.final_notinI SemanticCon.final_notin_def exec.AwaitTrue)  
  thus ?case
    by (simp add: AwaitTrue.hyps(1) AwaitTrue.hyps(2) terminates.AwaitTrue)     
next 
  case (AwaitFalse s b) thus ?case by (simp add: terminates.AwaitFalse)
qed

(* ************************************************************************* *)
subsection {* Lemmas about @{const "strip_guards"} *}
(* ************************************************************************* *)

lemma terminates_noFault_strip:
  assumes termi: "\<Gamma>\<turnstile>\<^sub>pc\<down>Normal s"
  shows "\<lbrakk>\<Gamma>\<turnstile>\<^sub>p\<langle>c,Normal s \<rangle> \<Rightarrow>\<notin>Fault ` F\<rbrakk> \<Longrightarrow> strip F \<Gamma>\<turnstile>\<^sub>pc\<down>Normal s"
using termi
proof (induct)
  case Skip thus ?case by (auto intro: terminates.intros)
next
  case Basic thus ?case by (auto intro: terminates.intros)
next
  case Spec thus ?case by (auto intro: terminates.intros)
next
  case (Guard s g c f)
  have s_in_g: "s \<in> g" by fact
  have "\<Gamma>\<turnstile>\<^sub>p\<langle>Guard f g c,Normal s \<rangle> \<Rightarrow>\<notin>Fault ` F" by fact
  with s_in_g have "\<Gamma>\<turnstile>\<^sub>p\<langle>c,Normal s \<rangle> \<Rightarrow>\<notin>Fault ` F"
    by (fastforce simp add: final_notin_def intro: exec.intros)
  then have "strip F \<Gamma>\<turnstile>\<^sub>pc \<down> Normal s" by (simp add: Guard.hyps) 
  with s_in_g show ?case
    by (auto intro: terminates.intros simp del: strip_simp)
next
  case GuardFault thus ?case 
    by (auto intro: terminates.intros exec.intros simp add: final_notin_def )
next
  case Fault thus ?case by (auto intro: terminates.intros)
next
  case (Seq c1 s c2) 
  have noFault_Seq: "\<Gamma>\<turnstile>\<^sub>p\<langle>Seq c1 c2,Normal s \<rangle> \<Rightarrow>\<notin>Fault ` F" by fact
  hence noFault_c1: "\<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow>\<notin>Fault ` F"
    by (auto simp add: final_notin_def intro: exec.intros)
  then have "strip F \<Gamma>\<turnstile>\<^sub>pc1 \<down> Normal s" by (simp add: Seq.hyps)
  moreover
  {
    fix s'
    assume exec_strip_c1: "strip F \<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow> s'"
    have "strip F \<Gamma>\<turnstile>\<^sub>pc2 \<down> s'"
    proof (cases "isFault s'")
      case True
      thus ?thesis by (auto elim: isFaultE intro: terminates.intros)
    next
      case False
      with exec_strip_to_exec [OF exec_strip_c1] noFault_c1
      have "\<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow> s'"
        by (auto simp add: final_notin_def elim!: isFaultE)
      moreover
      from this noFault_Seq have "\<Gamma>\<turnstile>\<^sub>p\<langle>c2,s' \<rangle> \<Rightarrow>\<notin>Fault ` F"
        by (auto simp add: final_notin_def intro: exec.intros)
      ultimately show ?thesis
        using Seq.hyps by (simp del: strip_simp)
    qed
  }
  ultimately show ?case
    by (fastforce intro: terminates.intros)
next
  case CondTrue thus ?case
    by (fastforce intro: terminates.intros exec.intros simp add: final_notin_def ) 
next
  case CondFalse thus ?case
    by (fastforce intro: terminates.intros exec.intros simp add: final_notin_def ) 
next
  case (WhileTrue s b c)
  have s_in_b: "s \<in> b" by fact
  have noFault_while: "\<Gamma>\<turnstile>\<^sub>p\<langle>While b c,Normal s \<rangle> \<Rightarrow>\<notin>Fault ` F" by fact
  with s_in_b have noFault_c: "\<Gamma>\<turnstile>\<^sub>p\<langle>c,Normal s \<rangle> \<Rightarrow>\<notin>Fault ` F"
    by (auto simp add: final_notin_def intro: exec.intros)
  then have "strip F \<Gamma>\<turnstile>\<^sub>pc \<down> Normal s" by (simp add: WhileTrue.hyps)
  moreover
  {
    fix s'
    assume exec_strip_c: "strip F \<Gamma>\<turnstile>\<^sub>p\<langle>c,Normal s \<rangle> \<Rightarrow> s'"
    have "strip F \<Gamma>\<turnstile>\<^sub>pWhile b c \<down> s'"
    proof (cases "isFault s'")
      case True
      thus ?thesis by (auto elim: isFaultE intro: terminates.intros)
    next
      case False
      with exec_strip_to_exec [OF exec_strip_c] noFault_c
      have "\<Gamma>\<turnstile>\<^sub>p\<langle>c,Normal s \<rangle> \<Rightarrow> s'"
        by (auto simp add: final_notin_def elim!: isFaultE)
      moreover
      from this s_in_b noFault_while have "\<Gamma>\<turnstile>\<^sub>p\<langle>While b c,s' \<rangle> \<Rightarrow>\<notin>Fault ` F"
        by (auto simp add: final_notin_def intro: exec.intros)
      ultimately show ?thesis
        using WhileTrue.hyps by (simp del: strip_simp)
    qed
  }
  ultimately show ?case
    using WhileTrue.hyps by (auto intro: terminates.intros simp del: strip_simp)
next
  case WhileFalse thus ?case by (auto intro: terminates.intros)
next
  case (Call p bdy s) 
  have bdy: "\<Gamma> p = Some bdy" by fact
  have "\<Gamma>\<turnstile>\<^sub>p\<langle>Call p,Normal s \<rangle> \<Rightarrow>\<notin>Fault ` F" by fact
  with bdy have bdy_noFault: "\<Gamma>\<turnstile>\<^sub>p\<langle>bdy,Normal s \<rangle> \<Rightarrow>\<notin>Fault ` F"
    by (auto intro: exec.intros simp add: final_notin_def)
  then have strip_bdy_noFault: "strip F \<Gamma>\<turnstile>\<^sub>p\<langle>bdy,Normal s \<rangle> \<Rightarrow>\<notin>Fault ` F"
    by (auto simp add: final_notin_def dest!: exec_strip_to_exec elim!: isFaultE)

  from bdy_noFault have "strip F \<Gamma>\<turnstile>\<^sub>pbdy \<down> Normal s" by (simp add: Call.hyps)
  from terminates_noFault_strip_guards [OF this strip_bdy_noFault]
  have "strip F \<Gamma>\<turnstile>\<^sub>pstrip_guards F bdy \<down> Normal s".
  with bdy show ?case
    by (fastforce intro: terminates.Call)
next
  case CallUndefined thus ?case by (auto intro: terminates.intros)
next
  case Stuck thus ?case by (auto intro: terminates.intros)
next
  case DynCom thus ?case 
    by (auto intro: terminates.intros exec.intros simp add: final_notin_def )
next
  case Throw thus ?case by (auto intro: terminates.intros)
next
  case Abrupt thus ?case by (auto intro: terminates.intros)
next
  case (Catch c1 s c2)
  have noFault_Catch: "\<Gamma>\<turnstile>\<^sub>p\<langle>Catch c1 c2,Normal s \<rangle> \<Rightarrow>\<notin>Fault ` F" by fact
  hence noFault_c1: "\<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow>\<notin>Fault ` F"
    by (fastforce simp add: final_notin_def intro: exec.intros)
  then have "strip F \<Gamma>\<turnstile>\<^sub>pc1 \<down> Normal s" by (simp add: Catch.hyps)
  moreover
  {
    fix s'
    assume exec_strip_c1: "strip F \<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow> Abrupt s'"
    have "strip F \<Gamma>\<turnstile>\<^sub>pc2 \<down> Normal s'"
    proof -
      from exec_strip_to_exec [OF exec_strip_c1] noFault_c1
      have "\<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow> Abrupt s'"
        by (auto simp add: final_notin_def elim!: isFaultE)
      moreover
      from this noFault_Catch have "\<Gamma>\<turnstile>\<^sub>p\<langle>c2,Normal s' \<rangle> \<Rightarrow>\<notin>Fault ` F"
        by (auto simp add: final_notin_def intro: exec.intros)
      ultimately show ?thesis
        using Catch.hyps by (simp del: strip_simp)
    qed
  }
  ultimately show ?case
    using Catch.hyps by (auto intro: terminates.intros simp del: strip_simp)
next
  case (AwaitTrue s b \<Gamma>\<^sub>p c) 
  with terminates_noFault_strip have "Language.strip F \<Gamma>\<^sub>p\<turnstile> c \<down> Normal s"
   by (simp add: terminates_noFault_strip Semantic.final_notinI SemanticCon.final_notin_def exec.AwaitTrue)
  then have "Language.strip F \<Gamma>\<^sub>p = (LanguageCon.strip F \<Gamma>)\<^sub>\<not>\<^sub>a"
    by (simp add: AwaitTrue.hyps(2) strip_eq)
  then have "(LanguageCon.strip F \<Gamma>)\<^sub>\<not>\<^sub>a\<turnstile>c \<down> Normal s"
    using `Language.strip F \<Gamma>\<^sub>p = (LanguageCon.strip F \<Gamma>)\<^sub>\<not>\<^sub>a` `Language.strip F \<Gamma>\<^sub>p\<turnstile>c \<down> Normal s` 
  by presburger
  thus ?case
    by (meson AwaitTrue.hyps(1) terminates.AwaitTrue)
next
  case(AwaitFalse s b) thus ?case by (simp add:terminates.AwaitFalse)
qed  

(* ************************************************************************* *)
subsection {* Miscellaneous *}
(* ************************************************************************* *)

lemma terminates_while_lemma:
  assumes termi: "\<Gamma>\<turnstile>\<^sub>pw\<down>fk" 
  shows "\<And>k b c. \<lbrakk>fk = Normal (f k); w=While b c; 
                       \<forall>i. \<Gamma>\<turnstile>\<^sub>p\<langle>c,Normal (f i) \<rangle> \<Rightarrow> Normal (f (Suc i))\<rbrakk>
         \<Longrightarrow> \<exists>i. f i \<notin> b"
using termi
proof (induct)
  case WhileTrue thus ?case by blast
next
  case WhileFalse thus ?case by blast
qed simp_all

lemma terminates_while:
  "\<lbrakk>\<Gamma>\<turnstile>\<^sub>p(While b c)\<down>Normal (f k);  
    \<forall>i. \<Gamma>\<turnstile>\<^sub>p\<langle>c,Normal (f i) \<rangle> \<Rightarrow> Normal (f (Suc i))\<rbrakk>
         \<Longrightarrow> \<exists>i. f i \<notin> b"
  by (blast intro: terminates_while_lemma)

lemma wf_terminates_while: 
 "wf {(t,s). \<Gamma>\<turnstile>\<^sub>p(While b c)\<down>Normal s \<and> s\<in>b \<and> 
             \<Gamma>\<turnstile>\<^sub>p\<langle>c,Normal s \<rangle> \<Rightarrow> Normal t}"
apply(subst wf_iff_no_infinite_down_chain)
apply(rule notI)
apply clarsimp
apply(insert terminates_while)
apply blast
done

lemma terminates_restrict_to_terminates:
  assumes terminates_res: "\<Gamma>|\<^bsub>M\<^esub>\<turnstile>\<^sub>p c \<down> s"
  assumes not_Stuck: "\<Gamma>|\<^bsub>M\<^esub>\<turnstile>\<^sub>p\<langle>c,s \<rangle> \<Rightarrow>\<notin>{Stuck}"
  shows "\<Gamma>\<turnstile>\<^sub>p c \<down> s"
using terminates_res not_Stuck
proof (induct)
  case Skip show ?case by (rule terminates.Skip)
next
  case Basic show ?case by (rule terminates.Basic)
next
  case Spec show ?case by (rule terminates.Spec)
next
  case Guard thus ?case 
    by (auto intro: terminates.Guard dest: notStuck_GuardD)
next
  case GuardFault thus ?case by (auto intro: terminates.GuardFault)
next
  case Fault show ?case by (rule terminates.Fault)
next
  case (Seq c1 s c2) 
  have not_Stuck: "\<Gamma>|\<^bsub>M\<^esub>\<turnstile>\<^sub>p\<langle>Seq c1 c2,Normal s \<rangle> \<Rightarrow>\<notin>{Stuck}" by fact
  hence c1_notStuck: "\<Gamma>|\<^bsub>M\<^esub>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow>\<notin>{Stuck}"
    by (rule notStuck_SeqD1)
  show "\<Gamma>\<turnstile>\<^sub>pSeq c1 c2 \<down> Normal s"
  proof (rule terminates.Seq,safe)
    from c1_notStuck
    show "\<Gamma>\<turnstile>\<^sub>pc1 \<down> Normal s"
      by (rule Seq.hyps)
  next
    fix s'
    assume exec: "\<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow> s'"
    show "\<Gamma>\<turnstile>\<^sub>pc2 \<down> s'"
    proof -
      from exec_to_exec_restrict [OF exec] obtain t' where
        exec_res: "\<Gamma>|\<^bsub>M\<^esub>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow> t'" and 
        t'_notStuck: "t' \<noteq> Stuck \<longrightarrow> t' = s'"
        by blast
      show ?thesis
      proof (cases "t'=Stuck")
        case True
        with c1_notStuck exec_res have "False"
          by (auto simp add: final_notin_def)
        thus ?thesis ..
      next
        case False
        with t'_notStuck have t': "t'=s'" by simp
        with not_Stuck exec_res
        have "\<Gamma>|\<^bsub>M\<^esub>\<turnstile>\<^sub>p\<langle>c2,s' \<rangle> \<Rightarrow>\<notin>{Stuck}"
          by (auto dest: notStuck_SeqD2) 
        with exec_res t' Seq.hyps
        show ?thesis
          by auto
      qed
    qed
  qed
next
  case CondTrue thus ?case 
    by (auto intro: terminates.CondTrue dest: notStuck_CondTrueD)
next
  case CondFalse thus ?case 
    by (auto intro: terminates.CondFalse dest: notStuck_CondFalseD)
next
  case (WhileTrue s b c)
  have s: "s \<in> b" by fact
  have not_Stuck: "\<Gamma>|\<^bsub>M\<^esub>\<turnstile>\<^sub>p\<langle>While b c,Normal s \<rangle> \<Rightarrow>\<notin>{Stuck}" by fact
  with WhileTrue have c_notStuck: "\<Gamma>|\<^bsub>M\<^esub>\<turnstile>\<^sub>p\<langle>c,Normal s \<rangle> \<Rightarrow>\<notin>{Stuck}"
    by (iprover intro:  notStuck_WhileTrueD1)
  show ?case
  proof (rule terminates.WhileTrue [OF s],safe)
    from c_notStuck
    show "\<Gamma>\<turnstile>\<^sub>pc \<down> Normal s"
      by (rule WhileTrue.hyps)
  next
    fix s'
    assume exec: "\<Gamma>\<turnstile>\<^sub>p\<langle>c,Normal s \<rangle> \<Rightarrow> s'"
    show "\<Gamma>\<turnstile>\<^sub>pWhile b c \<down> s'"
    proof -
      from exec_to_exec_restrict [OF exec] obtain t' where
        exec_res: "\<Gamma>|\<^bsub>M\<^esub>\<turnstile>\<^sub>p\<langle>c,Normal s \<rangle> \<Rightarrow> t'" and 
        t'_notStuck: "t' \<noteq> Stuck \<longrightarrow> t' = s'"
        by blast
      show ?thesis
      proof (cases "t'=Stuck")
        case True
        with c_notStuck exec_res have "False"
          by (auto simp add: final_notin_def)
        thus ?thesis ..
      next
        case False
        with t'_notStuck have t': "t'=s'" by simp
        with not_Stuck exec_res s
        have "\<Gamma>|\<^bsub>M\<^esub>\<turnstile>\<^sub>p\<langle>While b c,s' \<rangle> \<Rightarrow>\<notin>{Stuck}"
          by (auto dest: notStuck_WhileTrueD2) 
        with exec_res t' WhileTrue.hyps
        show ?thesis
          by auto
      qed
    qed
  qed
next
  case WhileFalse then show ?case by (iprover intro: terminates.WhileFalse)
next
  case Call thus ?case 
    by (auto intro: terminates.Call dest: notStuck_CallD restrict_SomeD)
next
  case CallUndefined
  thus ?case
    by (auto dest: notStuck_CallDefinedD)
next
  case Stuck show ?case by (rule terminates.Stuck)
next
  case DynCom
  thus ?case
    by (auto intro: terminates.DynCom dest: notStuck_DynComD)
next
  case Throw show ?case by (rule terminates.Throw)
next
  case Abrupt show ?case by (rule terminates.Abrupt)
next
  case (Catch c1 s c2) 
  have not_Stuck: "\<Gamma>|\<^bsub>M\<^esub>\<turnstile>\<^sub>p\<langle>Catch c1 c2,Normal s \<rangle> \<Rightarrow>\<notin>{Stuck}" by fact
  hence c1_notStuck: "\<Gamma>|\<^bsub>M\<^esub>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow>\<notin>{Stuck}"
    by (rule notStuck_CatchD1)
  show "\<Gamma>\<turnstile>\<^sub>pCatch c1 c2 \<down> Normal s"
  proof (rule terminates.Catch,safe)
    from c1_notStuck
    show "\<Gamma>\<turnstile>\<^sub>pc1 \<down> Normal s"
      by (rule Catch.hyps)
  next
    fix s'
    assume exec: "\<Gamma>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow> Abrupt s'"
    show "\<Gamma>\<turnstile>\<^sub>pc2 \<down> Normal s'"
    proof -
      from exec_to_exec_restrict [OF exec] obtain t' where
        exec_res: "\<Gamma>|\<^bsub>M\<^esub>\<turnstile>\<^sub>p\<langle>c1,Normal s \<rangle> \<Rightarrow> t'" and 
        t'_notStuck: "t' \<noteq> Stuck \<longrightarrow> t' = Abrupt s'"
        by blast
      show ?thesis
      proof (cases "t'=Stuck")
        case True
        with c1_notStuck exec_res have "False"
          by (auto simp add: final_notin_def)
        thus ?thesis ..
      next
        case False
        with t'_notStuck have t': "t'=Abrupt s'" by simp
        with not_Stuck exec_res
        have "\<Gamma>|\<^bsub>M\<^esub>\<turnstile>\<^sub>p\<langle>c2,Normal s' \<rangle> \<Rightarrow>\<notin>{Stuck}"
          by (auto dest: notStuck_CatchD2) 
        with exec_res t' Catch.hyps
        show ?thesis
          by auto
      qed
    qed
  qed
next
  case (AwaitTrue s b \<Gamma>\<^sub>p c e) 
  then have "(\<Gamma>|\<^bsub>M\<^esub>)\<^sub>\<not>\<^sub>a = (\<Gamma>\<^sub>\<not>\<^sub>a)|\<^bsub>M\<^esub>" using restrict_eq by auto
  with AwaitTrue terminates_restrict_to_terminates have "(\<Gamma>\<^sub>\<not>\<^sub>a)|\<^bsub>M\<^esub>\<turnstile>c \<down> Normal s"
   by force   
  then have "\<not> \<Gamma>|\<^bsub>M\<^esub>\<turnstile>\<^sub>p \<langle>Await b c e,Normal s\<rangle> \<Rightarrow> Stuck"
    by (fastforce intro: AwaitTrue.prems SemanticCon.noStuckE)
  hence "\<not> \<Gamma>\<^sub>\<not>\<^sub>a|\<^bsub>M\<^esub>\<turnstile> \<langle>c,Normal s\<rangle> \<Rightarrow> Stuck"
    by (metis (no_types) AwaitTrue.hyps(1) `(\<Gamma>|\<^bsub>M\<^esub>)\<^sub>\<not>\<^sub>a = \<Gamma>\<^sub>\<not>\<^sub>a|\<^bsub>M\<^esub>` exec.AwaitTrue)
  then have "\<Gamma>\<^sub>\<not>\<^sub>a\<turnstile>c \<down> Normal s"
    using Semantic.noStuckI' `\<Gamma>\<^sub>\<not>\<^sub>a|\<^bsub>M\<^esub>\<turnstile>c \<down> Normal s` terminates_restrict_to_terminates by blast
  thus ?case using AwaitTrue by (simp add: terminates.AwaitTrue) 
next
  case (AwaitFalse s b) thus ?case by (simp add: terminates.AwaitFalse)
qed

end