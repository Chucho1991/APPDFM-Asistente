CREATE OR REPLACE PACKAGE TRX3.Scfr_Trx_Dyn_Utl_Pk AS

  -- Author      : USER_PIVOT2
  -- Modified by : JESUS GUERRA CEDEÑO 
  -- Modified    : 12/05/2026
  -- Purpose     : inclusión campo RUC_INSTITUCION en trama DR  

  --Vversion VARCHAR2(25) := 'GEO.14.11.2022';
  -- VARCHAR2(25) := 'GEO.11.09.2023';
  --JRC 28/12/2022 Trama 'AR' en la Subtrama "Lista Productos" agrega campo GLOSA_DESCUENTO
  Vversion VARCHAR2(25) := 'GEO.23.04.2024';

  FUNCTION Version_Pkg RETURN VARCHAR2;

  FUNCTION Carga_Trama_Gg(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Gg;

  FUNCTION Carga_Trama_Rz(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rz;

  FUNCTION Carga_Trama_Ae(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ae;

  FUNCTION Carga_Trama_Ap(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ap;

  FUNCTION Carga_Trama_Qf(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Qf;

  FUNCTION Carga_Trama_Ad(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ad;

  FUNCTION Carga_Trama_De(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_De;

  FUNCTION Carga_Trama_Dj(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dj;

  FUNCTION Carga_Trama_Dj1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dj1;

  FUNCTION Carga_Trama_Dl(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dl;

  FUNCTION Carga_Trama_Dl1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dl1;

  FUNCTION Carga_Trama_Do(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Do;

  FUNCTION Carga_Trama_Dp(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp;

  /*FUNCTION Carga_Trama_Dp9(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp;*/

  FUNCTION Carga_Trama_Dp1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dp1;

  FUNCTION Carga_Trama_Dp2(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dp2;

  FUNCTION Carga_Trama_Dp3(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dp3;

  FUNCTION Carga_Trama_Fm(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Fm;

  FUNCTION Carga_Trama_Lc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Lc;

  FUNCTION Carga_Trama_Lo(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Lo;

  FUNCTION Carga_Trama_Rx(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rx;

  FUNCTION Carga_Trama_Te(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Te;

  FUNCTION Carga_Trama_Tx(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tx;

  FUNCTION Carga_Trama_Vc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vc;

  FUNCTION Carga_Trama_Vd(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vd;

  FUNCTION Carga_Trama_Vd1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Vd1;

  FUNCTION Carga_Trama_Vm(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vm;

  FUNCTION Carga_Trama_Vn(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vn;

  FUNCTION Carga_Trama_Vn1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Vn1;

  FUNCTION Carga_Trama_Vs(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vs;

  FUNCTION Carga_Trama_Vs1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Vs1;

  FUNCTION Carga_Trama_Vt(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vt;

  FUNCTION Carga_Trama_Cs(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cs;

  FUNCTION Carga_Trama_Cg(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cg;

  FUNCTION Carga_Trama_Rs(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rs;

  FUNCTION Carga_Trama_Na(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Na;

  FUNCTION Carga_Trama_Na1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Na1;

  FUNCTION Carga_Trama_Sf(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Sf;

  FUNCTION Carga_Trama_Sf1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Sf1;

  FUNCTION Carga_Trama_Sk(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Sk;

  FUNCTION Carga_Trama_Sk1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Sk1;

  FUNCTION Carga_Trama_Nc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Nc;

  FUNCTION Carga_Trama_Nd(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Nd;

  FUNCTION Carga_Trama_Nd1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Nd1;

  FUNCTION Carga_Trama_Nr(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Nr;

  FUNCTION Carga_Trama_Ns(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ns;

  FUNCTION Carga_Trama_Cd(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cd;

  FUNCTION Carga_Trama_Sc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Sc;

  FUNCTION Carga_Trama_Sc1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Sc1;

  FUNCTION Carga_Trama_Sc2(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Sc2;

  FUNCTION Carga_Trama_Sl(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Sl;

  FUNCTION Carga_Trama_Sp(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Sp;

  FUNCTION Carga_Trama_Zp(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Zp;

  FUNCTION Carga_Trama_Gs(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Gs;

  FUNCTION Carga_Trama_Pg1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pg1;

  FUNCTION Carga_Trama_Sc3(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Sc3;

  FUNCTION Carga_Trama_Gs1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gs1;

  FUNCTION Carga_Trama_Md(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Md;

  -- JRC 19/12/2019 Md4 <> de Md solo por campo Motivo
  --FUNCTION Carga_Trama_Md4(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Md;
  --

  --FUNCTION Carga_Trama_Md8(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Md8;

  FUNCTION Carga_Trama_Md1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Md1;

  FUNCTION Carga_Trama_Md2(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Md2;

  FUNCTION Carga_Trama_St(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_St;

  FUNCTION Carga_Trama_Fs(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Fs;

  FUNCTION Carga_Trama_Pp(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pp;

  FUNCTION Carga_Trama_Pq(p_Trama_Pos IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Hpo
                         ,p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pq;

  FUNCTION Carga_Trama_Lr(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Lr;

  FUNCTION Carga_Trama_Rr(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rr;

  FUNCTION Carga_Trama_Lf(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Lf;

  FUNCTION Carga_Trama_Ea(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ea;

  FUNCTION Carga_Trama_Eb(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Eb;

  FUNCTION Carga_Trama_Ps(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ps;

  FUNCTION Carga_Trama_Zr(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Zr;

  FUNCTION Carga_Trama_Za(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Za;

  FUNCTION Carga_Trama_Zj(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Zj;

  FUNCTION Carga_Trama_Zc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Zc;

  FUNCTION Carga_Trama_Ta(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ta;

  FUNCTION Carga_Trama_Dpu(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dpu;

  FUNCTION Carga_Trama_Dr(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dr;

  FUNCTION Carga_Trama_Dr1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dr1;

  FUNCTION Carga_Trama_Ds(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ds;

  FUNCTION Carga_Trama_Ds1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ds1;

  FUNCTION Carga_Trama_Dv(p_Trama_Pos IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Hpo
                         ,p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv;

  FUNCTION Carga_Trama_Dvr(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dvr;

  FUNCTION Carga_Trama_Dv1(p_Trama_Pos IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Hpo
                          ,p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dv1;

  FUNCTION Carga_Trama_Dv2(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dv2;

  FUNCTION Carga_Trama_Fp(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Fp;

  FUNCTION Carga_Trama_Fp1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Fp1;

  FUNCTION Carga_Trama_Gf(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Gf;

  FUNCTION Carga_Trama_Gf1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gf1;

  FUNCTION Carga_Trama_Hbo(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Hbo;

  FUNCTION Carga_Trama_Hc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Hc;

  FUNCTION Carga_Trama_Hpo(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Hpo;

  FUNCTION Carga_Trama_Htx(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Htx;

  FUNCTION Carga_Trama_Pi1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pi1;

  FUNCTION Carga_Trama_Pm(p_Trama_Pos IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Hpo
                         ,p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm;

  FUNCTION Carga_Trama_Pm1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm1;

  FUNCTION Carga_Trama_Pm2(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm2;

 -- IDHC
   FUNCTION Carga_Trama_Pm10(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm2;                          

  FUNCTION Carga_Trama_Pm3(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm3;

  FUNCTION Carga_Trama_Pm4(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm4;

  FUNCTION Carga_Trama_Pm5(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm5;

  FUNCTION Carga_Trama_Pm6(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm6;

  FUNCTION Carga_Trama_Pm7(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm7;

  FUNCTION Carga_Trama_Pm8(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm8;
                          
  --INI JAGC 20240909 NECESIDADES 'NEC'  
  -------------------------------------------------------------------------
  --SubTrama PM9 2024 JAGC Descuentos Aplicados Perdidoso Necesidades
  -------------------------------------------------------------------------  
  FUNCTION Carga_Trama_Pm9(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm9;  
  --FIN JAGC 20240909 NECESIDADES 'NEC'                        

  FUNCTION Carga_Trama_Pr(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pr;

  FUNCTION Carga_Trama_Pt(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pt;

  FUNCTION Carga_Trama_Pu(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pu;

  FUNCTION Carga_Trama_Pz(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pz;

  FUNCTION Carga_Trama_Ra(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ra;

  FUNCTION Carga_Trama_Rb(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rb;

  FUNCTION Carga_Trama_Rb1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rb1;

  FUNCTION Carga_Trama_Rc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rc;

  FUNCTION Carga_Trama_Rcv(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rcv;

  FUNCTION Carga_Trama_Re(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Re;

  FUNCTION Carga_Trama_Rf(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rf;

  FUNCTION Carga_Trama_Rfv(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rfv;

  FUNCTION Carga_Trama_Rg(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rg;

  FUNCTION Carga_Trama_Rg1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rg1;

  FUNCTION Carga_Trama_Ri(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ri;

  FUNCTION Carga_Trama_Ri1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ri1;

  FUNCTION Carga_Trama_Rj(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rj;

  FUNCTION Carga_Trama_Rj1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rj1;

  FUNCTION Carga_Trama_Rk(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rk;

  FUNCTION Carga_Trama_Rk1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rk1;

  FUNCTION Carga_Trama_Rl(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rl;

  FUNCTION Carga_Trama_Rl1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rl1;

  FUNCTION Carga_Trama_Rm(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rm;

  FUNCTION Carga_Trama_Rm1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rm1;

  FUNCTION Carga_Trama_Ro(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ro;

  FUNCTION Carga_Trama_Ro1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ro1;

  FUNCTION Carga_Trama_Rp(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp;

  FUNCTION Carga_Trama_Rp1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp1;

  FUNCTION Carga_Trama_Rp2(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp1;

  FUNCTION Carga_Trama_Rp3(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp2;

  FUNCTION Carga_Trama_Rp8(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp;

  FUNCTION Carga_Trama_Rp9(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp;

  FUNCTION Carga_Trama_Rpu(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rpu;

  FUNCTION Carga_Trama_Ep(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ep;

  FUNCTION Carga_Trama_Mf(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Mf;

  FUNCTION Carga_Trama_Mg(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Mg;

  FUNCTION Carga_Trama_Mg1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Mg1;

  FUNCTION Carga_Trama_Er(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Er;

  FUNCTION Carga_Trama_Ms(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ms;

  FUNCTION Carga_Trama_Mp(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Mp;

  FUNCTION Carga_Trama_Nv(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Nv;

  FUNCTION Carga_Trama_Nv1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Nv1;

  FUNCTION Carga_Trama_Oc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Oc;

  FUNCTION Carga_Trama_Or(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Or;

  FUNCTION Carga_Trama_Ot(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ot;

  FUNCTION Carga_Trama_Ot1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ot1;

  FUNCTION Carga_Trama_Vo(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vo;

  FUNCTION Carga_Trama_Pa(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pa;

  FUNCTION Carga_Trama_Pb(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pb;

  FUNCTION Carga_Trama_Pc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pc;

  FUNCTION Carga_Trama_Pd(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pd;

  FUNCTION Carga_Trama_Pe(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pe;

  FUNCTION Carga_Trama_Pf(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pf;

  FUNCTION Carga_Trama_Pi(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pi;

  --FUNCTION Carga_Trama_Pi8(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pi8;

  FUNCTION Carga_Trama_Fe(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Fe;

  FUNCTION Carga_Trama_Ab1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ab1;

  FUNCTION Carga_Trama_Ac(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ac;

  FUNCTION Carga_Trama_Ac1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ac1;

  FUNCTION Carga_Trama_Ar(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ar;

  FUNCTION Carga_Trama_Ar1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ar1;

  FUNCTION Carga_Trama_Ar2(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ar2;

  FUNCTION Carga_Trama_As(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_As;

  FUNCTION Carga_Trama_Ca(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ca;

  FUNCTION Carga_Trama_Cx(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cx;

  FUNCTION Carga_Trama_Cc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cc;

  FUNCTION Carga_Trama_Ce(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ce;

  FUNCTION Carga_Trama_Cf(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cf;

  FUNCTION Carga_Trama_Ci(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ci;

  FUNCTION Carga_Trama_Ck(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ck;

  FUNCTION Carga_Trama_Ck1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ck1;

  FUNCTION Carga_Trama_Ck2(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ck2;

  FUNCTION Carga_Trama_Cm(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cm;

  FUNCTION Carga_Trama_Cn(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cn;

  FUNCTION Carga_Trama_Co(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Co;

  FUNCTION Carga_Trama_Co1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Co1;

  FUNCTION Carga_Trama_Co2(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Co2;
  FUNCTION Carga_Trama_Cp(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cp;

  FUNCTION Carga_Trama_Cr(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cr;

  FUNCTION Carga_Trama_Ct(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ct;

  FUNCTION Carga_Trama_Va(p_Trama_Pos IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Hpo
                         ,p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Va;
  FUNCTION Carga_Trama_Va1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Va1;
  FUNCTION Carga_Trama_Vr(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vr;

  FUNCTION Carga_Trama_Vr1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Vr1;
  FUNCTION Carga_Trama_Ct1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ct1;

  FUNCTION Carga_Trama_Ct2(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ct2;

  FUNCTION Carga_Trama_Ct3(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ct3;

  FUNCTION Carga_Trama_Cu(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cu;

  FUNCTION Carga_Trama_Cv(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv;
  FUNCTION Carga_Trama_Cv1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv1;
  FUNCTION Carga_Trama_Cz(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cz;

  FUNCTION Carga_Trama_Db(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Db;

  FUNCTION Carga_Trama_Pg(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pg;

  FUNCTION Carga_Trama_Tm(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tm;

  FUNCTION Carga_Trama_Tm1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tm1;

  FUNCTION Carga_Trama_Tp(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Tp;

  FUNCTION Carga_Trama_Av(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Av;

  FUNCTION Carga_Trama_Ab(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ab;

  FUNCTION Carga_Trama_Pl(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pl;

  FUNCTION Carga_Trama_Po(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Po;

  FUNCTION Carga_Trama_Po9(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Po9;

  FUNCTION Carga_Trama_Po8(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Po8;

  FUNCTION Carga_Trama_Po6(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Po6;


  FUNCTION Carga_Trama_Po1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Po1;

  FUNCTION Carga_Trama_Pl9(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pl9;

  FUNCTION Carga_Trama_Pv(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pv;

  FUNCTION Carga_Trama_Aa(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Aa;

  FUNCTION Carga_Trama_Al(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Al;

  FUNCTION Carga_Trama_Cl(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cl;

  FUNCTION Carga_Trama_Ec(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ec;

  FUNCTION Carga_Trama_Ed(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ed;

  FUNCTION Carga_Trama_Ec1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ec1;

  FUNCTION Carga_Trama_Ed1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ed1;

  FUNCTION Carga_Trama_Dc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dc;

  FUNCTION Carga_Trama_Dh(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dh;

  FUNCTION Carga_Datos_Com(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Data_Com;

  FUNCTION Carga_Trama_Bt(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Bt;

  FUNCTION Carga_Trama_Gc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Gc;

  FUNCTION Carga_Trama_Gd(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gd;

  FUNCTION Carga_Trama_Gd1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gd1;

  FUNCTION Carga_Trama_Gr(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gr;

  FUNCTION Carga_Trama_Ic(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ic;

  FUNCTION Carga_Trama_Mb(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Mb;

  FUNCTION Carga_Trama_Mc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Mc;

  FUNCTION Carga_Trama_Mc1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Mc1;

  FUNCTION Carga_Trama_Id(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Id;

  FUNCTION Carga_Trama_In_Res(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_In_Res;
  
  --INI JAGC 20240909 NECESIDADES 'NEC'                               
  -------------------------------------------------------------------------
  --Trama IN 2024 JAGC Producto Inscrito a Necesidad
  -------------------------------------------------------------------------
  FUNCTION Carga_Trama_In(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_In;
  -------------------------------------------------------------------------
  --Trama IB 2024 JAGC Inscripci?n Producto a Beneficio Necesidad
  -------------------------------------------------------------------------  
  FUNCTION Carga_Trama_Ib(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ib;  
  --FIN JAGC 20240909 NECESIDADES 'NEC'

  FUNCTION Carga_Trama_Iv(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Iv;

  FUNCTION Carga_Trama_Ir(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ir;

  FUNCTION Carga_Trama_Is(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Is;

  FUNCTION Carga_Trama_Gu(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Gu;

  FUNCTION Carga_Trama_Tg(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tg;

  FUNCTION Carga_Trama_Tl(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tl; --FCG 191022 Totales

  FUNCTION Carga_Trama_Tf(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tf; --FCG 191022 Totales

  FUNCTION Carga_Trama_Px(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Px;

  FUNCTION Carga_Trama_Px1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Px1;

  FUNCTION Carga_Trama_Br(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Br;

  FUNCTION Carga_Trama_Rv(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rv;

  FUNCTION Carga_Trama_Rv1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rv1;
  -- Transacciones GNCU15 y GNCC15.
  FUNCTION Carga_Trama_Vv(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Vv;

  FUNCTION Carga_Trama_Vx1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Vx1;

  FUNCTION Carga_Trama_Vx(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vx;

END Scfr_Trx_Dyn_Utl_Pk;
/
