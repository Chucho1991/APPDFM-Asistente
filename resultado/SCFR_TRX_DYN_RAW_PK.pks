CREATE OR REPLACE PACKAGE TRX3.Scfr_Trx_Dyn_Raw_Pk AS

  -- Author      : USER_PIVOT2
  -- Modified by : JESUS GUERRA CEDENO
  -- Modified    : 22/10/2026
  -- Purpose     : Cambio Boletos / Recaudos - origen transaccion OBE 

  --Vversion VARCHAR2(25) := 'GEO.25.07.2023';
  Vversion VARCHAR2(25) := 'GEO.24.11.2023';
  
  FUNCTION Version_Pkg RETURN VARCHAR2;

  -- gncc01
  FUNCTION Arma_Trama_Dp(p_Trama_Dp IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Dp1(p_Trama_Dp1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dp1) RETURN BLOB;

  FUNCTION Arma_Trama_Dp2(p_Trama_Dp2 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dp2) RETURN BLOB;

  FUNCTION Arma_Trama_Dp3(p_Trama_Dp3 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dp3) RETURN BLOB;

  FUNCTION Arma_Trama_Dc(p_Trama_Dc IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dc) RETURN BLOB;

  FUNCTION Arma_Trama_Ms(p_Trama_Ms IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ms) RETURN BLOB;

  FUNCTION Arma_Trama_Pu(p_Trama_Pu IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pu
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Ca(p_Trama_Ca IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ca
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Cx(p_Trama_Cx IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cx) RETURN BLOB;

  FUNCTION Arma_Trama_Pf(p_Trama_Pf IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pf) RETURN BLOB;

  FUNCTION Arma_Trama_Pz(p_Trama_Pz IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pz) RETURN BLOB;

  FUNCTION Arma_Trama_Cf(p_Trama_Cf IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cf) RETURN BLOB;

  FUNCTION Arma_Trama_Pc(p_Trama_Pc IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pc) RETURN BLOB;

  FUNCTION Arma_Trama_Rf(p_Trama_Rf IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rf) RETURN BLOB;

  FUNCTION Arma_Trama_Rc(p_Trama_Rc IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rc) RETURN BLOB;

  FUNCTION Arma_Trama_Cu(p_Trama_Cu IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cu) RETURN BLOB;

  FUNCTION Arma_Trama_Cm(p_Trama_Cm IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cm) RETURN BLOB;

  FUNCTION Arma_Trama_Cc(p_Trama_Cc IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cc) RETURN BLOB;

  FUNCTION Arma_Trama_Ce(p_Trama_Ce IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ce) RETURN BLOB;

  FUNCTION Arma_Trama_Hc(p_Trama_Hc IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Hc
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Co(p_Trama_Co IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Co
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  -- gncc02
  FUNCTION Arma_Trama_Db(p_Trama_Db IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Db
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Cv(p_Trama_Cv IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;
  FUNCTION Arma_Trama_Cv1(p_Trama_Cv1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv1) RETURN BLOB;

  FUNCTION Arma_Trama_Dv(p_Trama_Dv IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Pm(p_Trama_Pm IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Pm1(p_Trama_Pm1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm1
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Pm2(p_Trama_Pm2 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm2
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

-- IDHC
  FUNCTION Arma_Trama_Pm10(p_Trama_Pm2 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm2
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;                         

  FUNCTION Arma_Trama_Pm3(p_Trama_Pm3 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm3
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Pm4(p_Trama_Pm4 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm4
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Pm5(p_Trama_Pm5 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm5
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Fp(p_Trama_Fp IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Fp
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Fp1(p_Trama_Fp1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Fp1) RETURN BLOB;

  FUNCTION Arma_Trama_Tx(p_Trama_Tx IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tx) RETURN BLOB;

  FUNCTION Arma_Trama_Rx(p_Trama_Rx IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rx) RETURN BLOB;

  FUNCTION Arma_Trama_Rp(p_Trama_Rp IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Rp1(p_Trama_Rp1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp1
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Rp2(p_Trama_Rp2 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp2
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Ri(p_Trama_Ri IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ri
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Ri1(p_Trama_Ri1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ri1
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Rv(p_Trama_Rv IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rv
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Rv1(p_Trama_Rv1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rv1
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Br(p_Trama_Br IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Br
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  /*********************************************************************************************/
  FUNCTION Arma_Trama_Dj(p_Trama_Dj IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dj) RETURN BLOB;

  FUNCTION Arma_Trama_Dj1(p_Trama_Dj1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dj1) RETURN BLOB;

  FUNCTION Arma_Trama_Dl(p_Trama_Dl IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dl) RETURN BLOB;

  FUNCTION Arma_Trama_Dl1(p_Trama_Dl1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dl1) RETURN BLOB;

  FUNCTION Arma_Trama_Lo(p_Trama_Lo IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Lo) RETURN BLOB;

  FUNCTION Arma_Trama_Te(p_Trama_Te IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Te) RETURN BLOB;

  FUNCTION Arma_Trama_Vc(p_Trama_Vc IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vc) RETURN BLOB;

  FUNCTION Arma_Trama_Vd(p_Trama_Vd IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vd
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Vd1(p_Trama_Vd1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Vd1) RETURN BLOB;

  FUNCTION Arma_Trama_Ve(p_Trama_Ve IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ve
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Vn(p_Trama_Vn IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vn) RETURN BLOB;

  FUNCTION Arma_Trama_Vn1(p_Trama_Vn1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Vn1) RETURN BLOB;

  FUNCTION Arma_Trama_Vs(p_Trama_Vs IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vs) RETURN BLOB;

  FUNCTION Arma_Trama_Vs1(p_Trama_Vs1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Vs1) RETURN BLOB;

  FUNCTION Arma_Trama_Vt(p_Trama_Vt IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vt) RETURN BLOB;

  FUNCTION Arma_Trama_Cs(p_Trama_Cs IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cs) RETURN BLOB;

  FUNCTION Arma_Trama_Cg(p_Trama_Cg IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cg) RETURN BLOB;

  FUNCTION Arma_Trama_Rs(p_Trama_Rs IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rs) RETURN BLOB;

  FUNCTION Arma_Trama_Rr(p_Trama_Rr IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rr) RETURN BLOB;

  FUNCTION Arma_Trama_Nr(p_Trama_Nr IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Nr) RETURN BLOB;

  FUNCTION Arma_Trama_Cd(p_Trama_Cd IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cd) RETURN BLOB;

  FUNCTION Arma_Trama_Sc(p_Trama_Sc IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Sc) RETURN BLOB;

  FUNCTION Arma_Trama_Sc1(p_Trama_Sc1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Sc1) RETURN BLOB;

  FUNCTION Arma_Trama_Sc2(p_Trama_Sc2 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Sc2) RETURN BLOB;

  FUNCTION Arma_Trama_Sp(p_Trama_Sp IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Sp) RETURN BLOB;

  FUNCTION Arma_Trama_Zp(p_Trama_Zp IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Zp) RETURN BLOB;

  FUNCTION Arma_Trama_Gs(p_Trama_Gs IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Gs) RETURN BLOB;

  FUNCTION Arma_Trama_Pg1(p_Trama_Pg1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pg1) RETURN BLOB;

  FUNCTION Arma_Trama_Sc3(p_Trama_Sc3 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Sc3) RETURN BLOB;

  FUNCTION Arma_Trama_Sl(p_Trama_Sl IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Sl) RETURN BLOB;

  FUNCTION Arma_Trama_Gs1(p_Trama_Gs1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gs1) RETURN BLOB;

  FUNCTION Arma_Trama_Md(p_Trama_Md IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Md) RETURN BLOB;
  --
  FUNCTION Arma_Trama_Md4(p_Trama_Md IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Md) RETURN BLOB;
  --

  FUNCTION Arma_Trama_Md8(p_Trama_Md IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Md8) RETURN BLOB;

  FUNCTION Arma_Trama_Md1(p_Trama_Md1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Md1
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB; --JRC 25/07/2023 Agrego Origen

  FUNCTION Arma_Trama_Md2(p_Trama_Md2 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Md2) RETURN BLOB;

  FUNCTION Arma_Trama_St(p_Trama_St IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_St) RETURN BLOB;

  FUNCTION Arma_Trama_Fs(p_Trama_Fs IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Fs) RETURN BLOB;

  FUNCTION Arma_Trama_Pq(p_Trama_Pq IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pq
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Pp(p_Trama_Pp IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pp) RETURN BLOB;

  FUNCTION Arma_Trama_Lf(p_Trama_Lf IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Lf
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Ea(p_Trama_Ea IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ea) RETURN BLOB;

  FUNCTION Arma_Trama_Eb(p_Trama_Eb IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Eb) RETURN BLOB;

  FUNCTION Arma_Trama_Ps(p_Trama_Ps IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ps) RETURN BLOB;

  FUNCTION Arma_Trama_Zj(p_Trama_Zj IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Zj) RETURN BLOB;

  FUNCTION Arma_Trama_Zc(p_Trama_Zc IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Zc) RETURN BLOB;

  FUNCTION Arma_Trama_Ta(p_Trama_Ta IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ta) RETURN BLOB;

  FUNCTION Arma_Trama_Dpu(p_Trama_Dpu IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dpu) RETURN BLOB;

  FUNCTION Arma_Trama_Dr(p_Trama_Dr IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dr
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Dr1(p_Trama_Dr1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dr1
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Ds(p_Trama_Ds IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ds) RETURN BLOB;

  FUNCTION Arma_Trama_Ds1(p_Trama_Ds1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ds1) RETURN BLOB;

  FUNCTION Arma_Trama_Dvr(p_Trama_Dvr IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dvr) RETURN BLOB;

  FUNCTION Arma_Trama_Dv2(p_Trama_Dv2 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dv2) RETURN BLOB;

  FUNCTION Arma_Trama_Dv1(p_Trama_Dv1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dv1
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;
  /*
    FUNCTION Arma_Trama_Dv8(p_Trama_Dv1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dv1
                           ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;
  */
  FUNCTION Arma_Trama_Fm(p_Trama_Fm IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Fm) RETURN BLOB;

  FUNCTION Arma_Trama_Gd(p_Trama_Gd IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gd
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Gd1(p_Trama_Gd1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gd1
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Gf(p_Trama_Gf IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Gf
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Gf1(p_Trama_Gf1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gf1
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Hbo(p_Trama_Hbo IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Hbo) RETURN BLOB;

  FUNCTION Arma_Trama_Hpo(p_Trama_Hpo IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Hpo) RETURN BLOB;

  FUNCTION Arma_Trama_Htx(p_Trama_Htx IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Htx) RETURN BLOB;

  FUNCTION Arma_Trama_Pi1(p_Trama_Pi1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pi1
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  --FUNCTION Arma_Trama_Pi2(p_Trama_Pi1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pi1
  --                       ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Pt(p_Trama_Pt IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pt) RETURN BLOB;

  FUNCTION Arma_Trama_Ra(p_Trama_Ra IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ra) RETURN BLOB;

  FUNCTION Arma_Trama_Rb(p_Trama_Rb IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rb
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Rb1(p_Trama_Rb1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rb1
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Rcv(p_Trama_Rcv IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rcv) RETURN BLOB;

  FUNCTION Arma_Trama_Re(p_Trama_Re IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Re) RETURN BLOB;

  FUNCTION Arma_Trama_Rfv(p_Trama_Rfv IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rfv) RETURN BLOB;

  FUNCTION Arma_Trama_Rg(p_Trama_Rg IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rg) RETURN BLOB;

  FUNCTION Arma_Trama_Rg1(p_Trama_Rg1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rg1) RETURN BLOB;

  FUNCTION Arma_Trama_Rj(p_Trama_Rj IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rj) RETURN BLOB;

  FUNCTION Arma_Trama_Rj1(p_Trama_Rj1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rj1) RETURN BLOB;

  FUNCTION Arma_Trama_Rk(p_Trama_Rk IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rk) RETURN BLOB;

  FUNCTION Arma_Trama_Rk1(p_Trama_Rk1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rk1) RETURN BLOB;

  FUNCTION Arma_Trama_Rl(p_Trama_Rl IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rl) RETURN BLOB;

  FUNCTION Arma_Trama_Rl1(p_Trama_Rl1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rl1) RETURN BLOB;

  FUNCTION Arma_Trama_Rm(p_Trama_Rm IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rm) RETURN BLOB;

  FUNCTION Arma_Trama_Rm1(p_Trama_Rm1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rm1) RETURN BLOB;

  FUNCTION Arma_Trama_Rpu(p_Trama_Rpu IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rpu) RETURN BLOB;

  FUNCTION Arma_Trama_Ep(p_Trama_Ep IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ep) RETURN BLOB;

  FUNCTION Arma_Trama_Mf(p_Trama_Mf IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Mf) RETURN BLOB;

  FUNCTION Arma_Trama_Er(p_Trama_Er IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Er) RETURN BLOB;

  FUNCTION Arma_Trama_Nv(p_Trama_Nv IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Nv) RETURN BLOB;

  FUNCTION Arma_Trama_Nv1(p_Trama_Nv1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Nv1) RETURN BLOB;

  FUNCTION Arma_Trama_Pb(p_Trama_Pb IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pb) RETURN BLOB;

  FUNCTION Arma_Trama_Pd(p_Trama_Pd IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pd) RETURN BLOB;

  FUNCTION Arma_Trama_Pe(p_Trama_Pe IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pe
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Gp1(p_Trama_Gp1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gp1
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Gp(p_Trama_Gp IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gp
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Pi(p_Trama_Pi IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pi
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Pi(p_Trama_Pi IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pi
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  --FUNCTION Arma_Trama_Pi8(p_Trama_Pi IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pi
  --                       ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Fe(p_Trama_Fe IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Fe) RETURN BLOB;

  FUNCTION Arma_Trama_Ab1(p_Trama_Ab1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ab1) RETURN BLOB;

  FUNCTION Arma_Trama_Ar(p_Trama_Ar IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ar
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Ar1(p_Trama_Ar1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ar1
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Ar2(p_Trama_Ar2 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ar2) RETURN BLOB;

  FUNCTION Arma_Trama_As(p_Trama_As IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_As) RETURN BLOB;

  FUNCTION Arma_Trama_Ck(p_Trama_Ck IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ck) RETURN BLOB;

  FUNCTION Arma_Trama_Ck1(p_Trama_Ck1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ck1) RETURN BLOB;

  FUNCTION Arma_Trama_Ck2(p_Trama_Ck2 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ck2) RETURN BLOB;

  FUNCTION Arma_Trama_Co1(p_Trama_Co1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Co1
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;
  FUNCTION Arma_Trama_Co2(p_Trama_Co2 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Co2
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;
  FUNCTION Arma_Trama_Cr(p_Trama_Cr IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cr) RETURN BLOB;

  FUNCTION Arma_Trama_Ct(p_Trama_Ct IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ct) RETURN BLOB;

  FUNCTION Arma_Trama_Va(p_Trama_Va IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Va
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;
  FUNCTION Arma_Trama_Va1(p_Trama_Va1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Va1) RETURN BLOB;
  FUNCTION Arma_Trama_Vr(p_Trama_Vr IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vr
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;
  FUNCTION Arma_Trama_Vr1(p_Trama_Vr1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Vr1) RETURN BLOB;
  FUNCTION Arma_Trama_Ct1(p_Trama_Ct1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ct1) RETURN BLOB;

  FUNCTION Arma_Trama_Ct2(p_Trama_Ct2 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ct2) RETURN BLOB;

  FUNCTION Arma_Trama_Ct3(p_Trama_Ct3 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ct3) RETURN BLOB;

  FUNCTION Arma_Trama_Cz(p_Trama_Cz IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cz) RETURN BLOB;

  FUNCTION Arma_Trama_Pg(p_Trama_Pg IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pg) RETURN BLOB;

  FUNCTION Arma_Trama_Tm(p_Trama_Tm IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tm
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Tm1(p_Trama_Tm1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tm1
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Tp(p_Trama_Tp IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Tp) RETURN BLOB;

  FUNCTION Arma_Trama_Av(p_Trama_Av IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Av) RETURN BLOB;

  FUNCTION Arma_Trama_Ab(p_Trama_Ab IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ab) RETURN BLOB;

  FUNCTION Arma_Trama_Po(p_Trama_Po IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Po8
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;
  FUNCTION Arma_Trama_Po7(p_Trama_Po IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Po7
                         ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;
  
  FUNCTION Arma_Trama_Po6(p_Trama_Po IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Po6
                         ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;
                                                
  FUNCTION Arma_Trama_Po1(p_Trama_Po1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Po1) RETURN BLOB;

  /*FUNCTION arma_trama_pv(p_trama_pv IN scfr_trx_dyn_types_pk.tab_trama_pv) RETURN BLOB;*/
  /*FUNCTION Arma_Trama_Pm9(p_Trama_Pm9 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm9) RETURN BLOB;*/

  FUNCTION Arma_Trama_Ec(p_Trama_Ec IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ec) RETURN BLOB;

  FUNCTION Arma_Trama_Ed(p_Trama_Ed IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ed) RETURN BLOB;

  FUNCTION Arma_Trama_Ec1(p_Trama_Ec1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ec1) RETURN BLOB;

  FUNCTION Arma_Trama_Ed1(p_Trama_Ed1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ed1) RETURN BLOB;

  FUNCTION Arma_Trama_Dh(p_Trama_Dh IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dh
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Bt(p_Trama_Bt IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Bt) RETURN BLOB;

  FUNCTION Arma_Trama_Gc(p_Trama_Gc IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gc) RETURN BLOB;

  FUNCTION Arma_Trama_Gr(p_Trama_Gr IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gr) RETURN BLOB;

  FUNCTION Arma_Trama_Ic(p_Trama_Ic IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ic) RETURN BLOB;

  FUNCTION Arma_Trama_Mb(p_Trama_Mb IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Mb) RETURN BLOB;

  FUNCTION Arma_Trama_Mc(p_Trama_Mc IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Mc
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Mc1(p_Trama_Mc1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Mc1
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Do(p_Trama_Do IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Do
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Tt(p_Trama_Tt IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tt) RETURN BLOB;

  FUNCTION Arma_Trama_Tg(p_Trama_Tg IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tg) RETURN BLOB;

  FUNCTION Arma_Trama_Oc(p_Trama_Oc IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Oc
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Mg(p_Trama_Mg IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Mg
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Mg1(p_Trama_Mg1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Mg1
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Mp(p_Trama_Mp IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Mp
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Or(p_Trama_Or IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Or
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Ro(p_Trama_Ro IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ro
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Ro1(p_Trama_Ro1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ro1
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Ot(p_Trama_Ot IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ot
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Ot1(p_Trama_Ot1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ot1
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Gu(p_Trama_Gu IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Gu
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Aa(p_Trama_Aa IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Aa) RETURN BLOB;

  FUNCTION Arma_Trama_Al(p_Trama_Al IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Al) RETURN BLOB;

  FUNCTION Arma_Trama_Pv(p_Trama_Pv IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pv) RETURN BLOB;

  FUNCTION Arma_Trama_Iv(p_Trama_Iv IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Iv) RETURN BLOB;

  FUNCTION Arma_Trama_Px(p_Trama_Px IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Px
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Px1(p_Trama_Px1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Px1) RETURN BLOB;

  FUNCTION Arma_Trama_Ex(p_Trama_Ex IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ex
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Ex1(p_Trama_Ex1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ex1) RETURN BLOB;

  /*
  function arma_trama_lc( p_trama_lc in scfr_trx_dyn_types_pk.rec_trama_lc )
  return blob;
  */
  /*
  function arma_trama_nc( p_trama_nc in scfr_trx_dyn_types_pk.rec_trama_nc )
  return blob;
  */
  /*
  function arma_trama_lr( p_trama_lr in scfr_trx_dyn_types_pk.rec_trama_lr )
  return blob;
  */
  /*
  function arma_trama_rr( p_trama_rr in scfr_trx_dyn_types_pk.rec_trama_rr )
  return blob;
  */
  /*
  function arma_trama_zr( p_trama_zr in scfr_trx_dyn_types_pk.rec_trama_zr )
  return blob;
  */
  /*
  function arma_trama_za( p_trama_za in scfr_trx_dyn_types_pk.rec_trama_za )
  return blob;
  */
  /*
  function arma_trama_vt( p_trama_vt in scfr_trx_dyn_types_pk.rec_trama_vt )
  return blob;
  */
  /*
  function arma_trama_pq( p_trama_pq in scfr_trx_dyn_types_pk.tab_trama_pq , p_version in varchar2 default null)
  return blob;
  */
  /*
  function arma_trama_pr( p_trama_pr in scfr_trx_dyn_types_pk.tab_trama_pr )
  return blob;
  */
  /*
  function arma_trama_pa( p_trama_pa in scfr_trx_dyn_types_pk.tab_trama_pa )
  return blob;
  */
  FUNCTION Arma_Trama_Ac(p_Trama_Ac IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ac) RETURN BLOB;

  FUNCTION Arma_Trama_Ac(p_Trama_Ac IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ac
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  FUNCTION Arma_Trama_Ac1(p_Trama_Ac1 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ac1) RETURN BLOB;

  /*  function arma_trama_ac9( p_trama_ac9 in scfr_trx_dyn_types_pk.rec_trama_ac9, p_version in varchar2 default null )
  return blob;*/
  /*
  function arma_trama_ci( p_trama_ci in scfr_trx_dyn_types_pk.tab_trama_ci )
  return blob;
  */
  /*
  function arma_trama_cn( p_trama_cn in scfr_trx_dyn_types_pk.tab_trama_cn )
  return blob;
  */
  /*
  function arma_trama_cp( p_trama_cp in scfr_trx_dyn_types_pk.tab_trama_cp )
  return blob;
  */
  /*
  function arma_trama_va( p_trama_va in scfr_trx_dyn_types_pk.rec_trama_va )
  return blob;
  */
  FUNCTION Arma_Trama_Pl(p_Trama_Pl IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pl
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;

  /*
  function arma_trama_po( p_trama_po in scfr_trx_dyn_types_pk.tab_trama_po )
  return blob;
  
  function arma_trama_po9( p_trama_po9 in scfr_trx_dyn_types_pk.tab_trama_po9, p_version in varchar2 default null )
  return blob;
  */
  /*
  function arma_trama_pl9( p_trama_pl9 in scfr_trx_dyn_types_pk.tab_trama_pl9, p_version in varchar2 default null )
  return blob;
  */
  FUNCTION Arma_Trama_Cl(p_Trama_Cl IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cl) RETURN BLOB;

  FUNCTION Arma_Trama_Ns(p_Trama_Ns IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ns
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;
  FUNCTION Arma_Trama_Vz(p_Trama_Vz IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Vz) RETURN BLOB;
  
   --INI JAGC 20240909 NECESIDADES 'NEC'                               
  -------------------------------------------------------------------------
  --Trama IL 2024 JAGC Producto Inscrito a Necesidad
  -------------------------------------------------------------------------  
  FUNCTION Arma_Trama_In(p_Trama_In IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_In
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;
  
  -------------------------------------------------------------------------
  --Trama IB 2024 JAGC Inscripci?n Producto a Beneficio Necesidad
  -------------------------------------------------------------------------  
  FUNCTION Arma_Trama_Ib(p_Trama_Ib IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ib
                        ,p_Version  IN VARCHAR2 DEFAULT NULL) RETURN BLOB;
                        
  FUNCTION Arma_Trama_Pm9(p_Trama_Pm9 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm9
                         ,p_Version   IN VARCHAR2 DEFAULT NULL) RETURN BLOB;                      
  --FIN JAGC 20240909 NECESIDADES 'NEC'

END Scfr_Trx_Dyn_Raw_Pk;

/
