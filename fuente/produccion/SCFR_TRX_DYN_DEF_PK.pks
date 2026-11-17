CREATE OR REPLACE PACKAGE TRX3.Scfr_Trx_Dyn_Def_Pk IS

  -- Author      : USER_PIVOT2
  -- Modified by : JESUS GUERRA CEDE?O 
  -- Modified    : 12/05/2026
  -- Purpose     : inclusi?n campo RUC_INSTITUCION en trama DR  

  --Vversion VARCHAR2(25) := 'GEO.11.09.2023';
  Vversion VARCHAR2(25) := 'GEO.23.04.2024';

  FUNCTION Version_Pkg RETURN VARCHAR2;

  TYPE Rec_Def_Mod_Dyn IS RECORD(
     Codigo_Trama Scfr_Catalogo_Diccionario.Tipo_Info%TYPE
    ,Nombre_Trama Scfr_Catalogo.Descripcion%TYPE
    ,Largo_Campo  Scfr_Catalogo_Diccionario.Largo%TYPE
    ,Itera_Trama  Scfr_Catalogo.Iterativo%TYPE
    ,Codigo_Campo Scfr_Diccionario.Codigo_Diccionario%TYPE
    ,Desc_Campo   Scfr_Diccionario.Descripcion%TYPE
    ,Tipo_Campo   Scfr_Diccionario.Tipo%TYPE
    ,Nombre_Campo Scfr_Diccionario.Nombre_Campo%TYPE);

  TYPE Tab_Def_Mod_Dyn IS TABLE OF Rec_Def_Mod_Dyn INDEX BY BINARY_INTEGER;

  FUNCTION Get_Def_Trama_Gg RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama(p_Trama IN VARCHAR2) RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Aa RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ab RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ab9 RETURN Tab_Def_Mod_Dyn;  
  
  FUNCTION Get_Def_Trama_Ab10 RETURN Tab_Def_Mod_Dyn;  -- JAGC 20250715 CORRECCI?N EXCU11  

  FUNCTION Get_Def_Trama_Ab1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ab2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ac RETURN Tab_Def_Mod_Dyn;
  -- JRG CIA 04/06/219
  FUNCTION Get_Def_Trama_Ac2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ac3 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ac4 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ac5 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ac7 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ac8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ac9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ad RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ae RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ae9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Al RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ap RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ar RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ar7 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ar9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ar1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ar2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ar8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_As RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Av RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Br RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Bt RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ca RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ca7 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ca8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ca9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Cc RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Cd RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ce RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Cf RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Cg RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ci RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ck RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ck1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ck2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Cl RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Cm RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Cn RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Co RETURN Tab_Def_Mod_Dyn;

  --//--------------------------------------------------------------------------\\
  --// CBR 17/08/2020 00:20                                                     \\
  --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
  --// Se reutiliza por ser la sub_trama mas antigua                            \\
  --//-----------------------------------------------------------------Inicio---\\
  FUNCTION Get_Def_Trama_Co1 RETURN Tab_Def_Mod_Dyn;
  --//-----------------------------------------------------------------Termino--\\

  FUNCTION Get_Def_Trama_Co2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Co3 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Co4 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Co5 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Co6 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Co7 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Co8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Co9 RETURN Tab_Def_Mod_Dyn;

  -- JRG CIA 04/06/219
  FUNCTION Get_Def_Trama_Co0 RETURN Tab_Def_Mod_Dyn;

  --//--------------------------------------------------------------------------\\
  --// LMP 4/2023                                                              \\
  --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'SAL'    \\
  --//-----------------------------------------------------------------Inicio---\\
  FUNCTION Get_Def_Trama_Coa RETURN Tab_Def_Mod_Dyn;
  --//-----------------------------------------------------------------Termino--\\

  FUNCTION Get_Def_Trama_Cp RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Cr RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Cs RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ct RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ct1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ct2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ct3 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Cu RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Cv RETURN Tab_Def_Mod_Dyn;
  FUNCTION Get_Def_Trama_Cv1 RETURN Tab_Def_Mod_Dyn;
  FUNCTION Get_Def_Trama_Cv2 RETURN Tab_Def_Mod_Dyn;
  FUNCTION Get_Def_Trama_Cv3 RETURN Tab_Def_Mod_Dyn;
  FUNCTION Get_Def_Trama_Cv9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Cx RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Cz RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Db RETURN Tab_Def_Mod_Dyn;
  FUNCTION Get_Def_Trama_Db1 RETURN Tab_Def_Mod_Dyn;
  FUNCTION Get_Def_Trama_Db9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dc RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_De RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dh RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dh9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dj RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dj8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dj9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dj2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dj1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dl RETURN Tab_Def_Mod_Dyn;
  
  FUNCTION Get_Def_Trama_Dla RETURN Tab_Def_Mod_Dyn;--JAGC 20250414 ORIGEN FGI

  FUNCTION Get_Def_Trama_Dl8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dl9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dl1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dl2 RETURN Tab_Def_Mod_Dyn;
  
  FUNCTION Get_Def_Trama_Dl3 RETURN Tab_Def_Mod_Dyn; -- IDHC origen NGL

  FUNCTION Get_Def_Trama_Do RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Do1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Do2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dp RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dp8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dp9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dp7 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dp6 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dp1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dp4 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dp5 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dp10 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dpu RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dr RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dr5 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dr6 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dr7 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dr8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dr9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dr1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dr2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dr3 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dr4 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ds RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ds1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dv RETURN Tab_Def_Mod_Dyn;
  -- JRG CIA 04/06/219
  FUNCTION Get_Def_Trama_Dv0 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dv5 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dv6 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dv7 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dv9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_D10 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_D11 RETURN Tab_Def_Mod_Dyn; -- FCG DONACION MX 04082022

  FUNCTION Get_Def_Trama_D12 RETURN Tab_Def_Mod_Dyn; --FCG 21082023  origen OMS

  FUNCTION Get_Def_Trama_D13 RETURN Tab_Def_Mod_Dyn; --JAGC 20240529 origen CON
    
  FUNCTION Get_Def_Trama_D14 RETURN Tab_Def_Mod_Dyn; --JAGC 20240529 origen NEC
    
  FUNCTION Get_Def_Trama_Dvr RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dv1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dv2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dv3 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dv4 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Dv8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ea RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Eb RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ec RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ec9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ec1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ed RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ed9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ed1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ep RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Er RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Fe RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Fm RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Fp RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Fp1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Fp2 RETURN Tab_Def_Mod_Dyn; --FCG Nuevo campo Autorizacion online

  FUNCTION Get_Def_Trama_Fp3 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Fp4 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Fp5 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Fp6 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Fp7 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Fp8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Fp9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Fs RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Gc RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Gd RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Gd9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Gd1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Gd2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Gf RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Gf1 RETURN Tab_Def_Mod_Dyn;
  
  FUNCTION Get_Def_Trama_Gf2 RETURN Tab_Def_Mod_Dyn; -- IDHC origen NLG

  FUNCTION Get_Def_Trama_Gf8 RETURN Tab_Def_Mod_Dyn; --JRC 30/08/2023 Unificando EXCU17 desde Yza a Ecuador

  FUNCTION Get_Def_Trama_Gf9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Gp RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Gp3 RETURN Tab_Def_Mod_Dyn; --JRC 28/04/2023 Gp3 nace de Gp, se agrega campo Cantidad_Productos_Traspaso

  FUNCTION Get_Def_Trama_Gp1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Gr RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Gs RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Gs1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Gu RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Hbo RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Hc RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Hc9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Hc8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Hpo RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Htx RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ic RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Id RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Id9 RETURN Tab_Def_Mod_Dyn;

  --INI JAGC 20240909 NECESIDADES 'NEC'  
  FUNCTION Get_Def_Trama_In_Res RETURN Tab_Def_Mod_Dyn;
  
  FUNCTION Get_Def_Trama_In RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ib RETURN Tab_Def_Mod_Dyn;
  
  FUNCTION Get_Def_Trama_Pm11 RETURN Tab_Def_Mod_Dyn;
  
  FUNCTION Get_Def_Trama_Pm12 RETURN Tab_Def_Mod_Dyn;
  --FIN JAGC 20240909 NECESIDADES 'NEC'  

  FUNCTION Get_Def_Trama_Ir RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Is RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Lc RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Lf RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Lf9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Lo RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Lr RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Mb RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Mc RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Mc7 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Mc8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Mc9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Mc1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Mc2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Mc3 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Md RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Md7 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Md9 RETURN Tab_Def_Mod_Dyn; --JRC 20/07/2027 Md9 nace desde Md7 Se agranda el campo motivo de 25 a 250 con origen IVA

  FUNCTION Get_Def_Trama_Mda RETURN Tab_Def_Mod_Dyn; --JRC 20/07/2027 Mda nace desde Md9 Se agrega campo Numero_Factura origen FTR

  FUNCTION Get_Def_Trama_Mdb RETURN Tab_Def_Mod_Dyn; --JAGC 20250429 FGI

  FUNCTION Get_Def_Trama_Md5 RETURN Tab_Def_Mod_Dyn;
  --
  FUNCTION Get_Def_Trama_Md4 RETURN Tab_Def_Mod_Dyn; --JRC 19/12/2019
  --
  FUNCTION Get_Def_Trama_Md6 RETURN Tab_Def_Mod_Dyn; -- RMC 12-07-2023

  FUNCTION Get_Def_Trama_Md8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Md1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Md2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Md3 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Mf RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Mg RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Mg1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Mg2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ms RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Mp RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Mp9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Na RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Na1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Na2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Sf RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Sf1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Sk RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Sk1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Nc RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Nd RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Nd1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ns RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ns9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Nr RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Nv RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Nv1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Oc RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Oc1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Oc8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Oc9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Or RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Or1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Or2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Or3 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ot RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ot1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ot2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pa RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pb RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pc RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pd RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pe RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pe8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pe9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pf RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pg RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pg1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pi RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pi1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pi7 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pi8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pi9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pi10 RETURN Tab_Def_Mod_Dyn;
  
  FUNCTION Get_Def_Trama_Pi11 RETURN Tab_Def_Mod_Dyn; -- IDHC ORIGEN SLV

  FUNCTION Get_Def_Trama_Pi3 RETURN Tab_Def_Mod_Dyn; --JRC 19/12/2019

  FUNCTION Get_Def_Trama_Pi4 RETURN Tab_Def_Mod_Dyn; --FCG 19112020 sub trama guias multiples

  FUNCTION Get_Def_Trama_Pi5 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pi2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pi6 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pl RETURN Tab_Def_Mod_Dyn;
  FUNCTION Get_Def_Trama_Pl1 RETURN Tab_Def_Mod_Dyn;
  FUNCTION Get_Def_Trama_Pl9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pm RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pm0 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pm1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pm2 RETURN Tab_Def_Mod_Dyn;
  
  -- IDHC promotion Web
  FUNCTION Get_Def_Trama_Pm10 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pm3 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pm4 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pm5 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pm6 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pm7 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pm8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pm9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_P10 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_P11 RETURN Tab_Def_Mod_Dyn;
  
  FUNCTION Get_Def_Trama_Pm13 RETURN Tab_Def_Mod_Dyn; --NEC

  FUNCTION Get_Def_Trama_P12 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_P13 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_P14 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_P15 RETURN Tab_Def_Mod_Dyn; --NEC

  FUNCTION Get_Def_Trama_Po RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Po1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Po9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Po8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Po7 RETURN Tab_Def_Mod_Dyn;
   
  FUNCTION Get_Def_Trama_Po6 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pp RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pq RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pq7 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pq8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pq9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pr RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ps RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pt RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pu RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pu9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pu8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pv RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Pz RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Qf RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ra RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rb RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rb1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rb2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rc RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rcv RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Re RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rf RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rfv RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rg RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rg1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ri RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ri8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ri9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ri1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rj RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rj1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rk RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rk1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rl RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rl1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rm RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rm1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rp RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rp1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rp2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rp3 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rp7 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rp8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rp9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rpu RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ro RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ro1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ro2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rr RETURN Tab_Def_Mod_Dyn;

  --JRC 11/03/2020 Origen_Trx 'EMP' Excendemte al medio de pago
  --Se agregan a la trama RR campos Tipo de Documento y Folio
  FUNCTION Get_Def_Trama_Rr1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rs RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rv RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rv1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rv2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rx RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Rz RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Sc RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Sc1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Sc2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Sc3 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Sl RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Sp RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_St RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ta RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Te RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Tp RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Tm RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Tm1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Tx RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Va RETURN Tab_Def_Mod_Dyn;

  -- JRG CIA 04/06/219
  FUNCTION Get_Def_Trama_Va2 RETURN Tab_Def_Mod_Dyn;
  FUNCTION Get_Def_Trama_Va3 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Va4 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Va5 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Va6 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Va9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Va8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Vc RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Vd RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Vd8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Vd9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Vd1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ve RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Vm RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Vn RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Vn1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Vo RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Vr RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Vr1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Vr2 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Vr9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Vr8 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Vs RETURN Tab_Def_Mod_Dyn;
  
  FUNCTION Get_Def_Trama_Vs_Resp RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Vs1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Vt RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Za RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Zc RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Zj RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Zp RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Zr RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Lp RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Iv RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Tg RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Tf RETURN Tab_Def_Mod_Dyn; --FCG 191022 Totales
  FUNCTION Get_Def_Trama_Tl RETURN Tab_Def_Mod_Dyn; --FCG 191022 Totales
  FUNCTION Get_Def_Trama_Tt RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Px9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Px RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Px1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ex RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ex9 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Ex1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Dat_Trama(p_Trama IN VARCHAR2) RETURN Scfr_Trx_Dyn_Pk.Tab_Trama;

  FUNCTION Get_Def_Trama_Vx1 RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Vx RETURN Tab_Def_Mod_Dyn;

  FUNCTION Get_Def_Trama_Vv RETURN Tab_Def_Mod_Dyn;
END Scfr_Trx_Dyn_Def_Pk;
/
