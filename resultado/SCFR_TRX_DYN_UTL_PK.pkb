CREATE OR REPLACE PACKAGE BODY TRX3.Scfr_Trx_Dyn_Utl_Pk AS

  FUNCTION Version_Pkg RETURN VARCHAR2 AS
  BEGIN
    RETURN Vversion;
  END;

  FUNCTION Carga_Trama_Gg(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Gg IS
    l_Trama_Gg Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Gg;
  BEGIN
    l_Trama_Gg.Separador_Registro    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'GG'
                                                                          ,'SEPARADOR_REGISTRO');
    l_Trama_Gg.Separador_Campo       := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'GG'
                                                                          ,'SEPARADOR_CAMPO');
    l_Trama_Gg.Cantidad_De_Registros := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'GG'
                                                                          ,'CANTIDAD_DE_REGISTROS');
    l_Trama_Gg.Campos_Por_Registro   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'GG'
                                                                          ,'CAMPOS_POR_REGISTRO');
    l_Trama_Gg.Data                  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'GG'
                                                                          ,'DATA');
    RETURN l_Trama_Gg;
  END;

  FUNCTION Carga_Trama_Rz(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rz IS
    l_Trama_Rz Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rz;
  BEGIN
    l_Trama_Rz.Secuencia_Receta := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'RZ'
                                                                     ,'SECUENCIA_RECETA');
    RETURN l_Trama_Rz;
  END;

  FUNCTION Carga_Trama_Ae(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ae IS
    l_Trama_Ae Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ae;
  BEGIN
    l_Trama_Ae.Hora_Presentacion_Pop_Up := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'AE'
                                                                             ,'HORA_PRESENTACION_POP_UP');
    l_Trama_Ae.Hora_Seleccion_Opcion    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'AE'
                                                                             ,'HORA_SELECCION_OPCION');
    l_Trama_Ae.Campana                  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'AE'
                                                                             ,'CAMPANA');
    l_Trama_Ae.Opcion_Seleccionada      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'AE'
                                                                             ,'OPCION_SELECCIONADA');
    l_Trama_Ae.Numero_Preventa          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'AE'
                                                                             ,'NUMERO_PREVENTA');
    l_Trama_Ae.Reintento_Vendedor       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'AE'
                                                                             ,'REINTENTO_VENDEDOR');
    l_Trama_Ae.Motivo_Rechazo           := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'AE'
                                                                             ,'MOTIVO_RECHAZO');
    RETURN l_Trama_Ae;
  END;

  FUNCTION Carga_Trama_Ap(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ap IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Ap Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ap;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'AP'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Ap(l_Item).Correlativo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'AP'
                                                                          ,'CORRELATIVO'
                                                                          ,l_Item);
      l_Trama_Ap(l_Item).Codigo_Parte := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AP'
                                                                           ,'CODIGO_PARTE'
                                                                           ,l_Item);
      l_Trama_Ap(l_Item).Fecha := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'AP'
                                                                    ,'FECHA'
                                                                    ,l_Item);
      l_Trama_Ap(l_Item).Estado := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'AP'
                                                                     ,'ESTADO'
                                                                     ,l_Item);
      l_Trama_Ap(l_Item).Glosa := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'AP'
                                                                    ,'GLOSA'
                                                                    ,l_Item);
    END LOOP;
    RETURN l_Trama_Ap;
  END;

  FUNCTION Carga_Trama_Qf(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Qf IS
    l_Trama_Qf Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Qf;
  BEGIN
    l_Trama_Qf.Autorizacion_Qf := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'QF'
                                                                    ,'AUTORIZACION_QF');
    l_Trama_Qf.Rut_Qf          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'QF'
                                                                    ,'RUT_QF');
    l_Trama_Qf.Numero_Preventa := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'QF'
                                                                    ,'NUMERO_PREVENTA');
    RETURN l_Trama_Qf;
  END;

  FUNCTION Carga_Trama_Ad(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ad IS
    l_Trama_Ad Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ad;
  BEGIN
    l_Trama_Ad.Comuna           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'AD'
                                                                     ,'COMUNA');
    l_Trama_Ad.Ciudad           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'AD'
                                                                     ,'CIUDAD');
    l_Trama_Ad.Numero_Direccion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'AD'
                                                                     ,'NUMERO_DIRECCION');
    l_Trama_Ad.Calle_Direccion  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'AD'
                                                                     ,'CALLE_DIRECCION');
    l_Trama_Ad.Numero_Depto     := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'AD'
                                                                     ,'NUMERO_DEPTO');
    l_Trama_Ad.Block            := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'AD'
                                                                     ,'BLOCK');
    l_Trama_Ad.Poblacion        := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'AD'
                                                                     ,'POBLACION');
    RETURN l_Trama_Ad;
  END;

  FUNCTION Carga_Trama_De(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_De IS
    l_Trama_De Scfr_Trx_Dyn_Types_Pk.Rec_Trama_De;
  BEGIN
    l_Trama_De.Campana      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                 ,'DE'
                                                                 ,'CAMPANA');
    l_Trama_De.Dato_Campana := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                 ,'DE'
                                                                 ,'DATO_CAMPANA');
    l_Trama_De.Valor        := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                 ,'DE'
                                                                 ,'VALOR');
    RETURN l_Trama_De;
  END;

  FUNCTION Carga_Trama_Ab(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ab IS
    l_Trama_Ab Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ab;
  BEGIN
    l_Trama_Ab.Tipo_Movimiento_Padre := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'AB'
                                                                          ,'TIPO_MOVIMIENTO_PADRE');
    l_Trama_Ab.Tipo_Movimiento_Hijo  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'AB'
                                                                          ,'TIPO_MOVIMIENTO_HIJO');
    l_Trama_Ab.Folio                 := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'AB'
                                                                               ,'FOLIO'));
    IF Nvl(l_Trama_Ab.Folio
          ,0) = 0 THEN
      l_Trama_Ab.Folio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                            ,'AB'
                                                            ,'FOLIO');
    END IF;

    l_Trama_Ab.Monto              := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'AB'
                                                                       ,'MONTO');
    l_Trama_Ab.Decimal_Monto      := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'AB'
                                                                               ,'DECIMAL_MONTO')
                                            ,'-'
                                            ,'0');
    l_Trama_Ab.Monto              := To_Number(l_Trama_Ab.Monto || '.' || l_Trama_Ab.Decimal_Monto
                                              ,'999999999999.9999');
    l_Trama_Ab.Precio_Final       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'AB'
                                                                       ,'PRECIO_FINAL');
    l_Trama_Ab.Decimal_Pfinal     := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'AB'
                                                                               ,'DECIMAL_PFINAL')
                                            ,'-'
                                            ,'0');
    l_Trama_Ab.Precio_Final       := To_Number(l_Trama_Ab.Precio_Final || '.' || l_Trama_Ab.Decimal_Pfinal
                                              ,'999999999999.9999');
    
    --INI JAGC 20250414 ORIGEN FGI                                          
    l_Trama_Ab.Folio_Ajuste := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'AB'
                                                                       ,'FOLIO_AJUSTE');
    --FIN JAGC 20250414 ORIGEN FGI
                                              
    l_Trama_Ab.Cantidad_Productos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'AB'
                                                                       ,'CANTIDAD_PRODUCTOS');
    l_Trama_Ab.Subtrama_Ab1       := Carga_Trama_Ab1(p_Cuerpo_Tx
                                                    ,l_Trama_Ab.Cantidad_Productos);
    RETURN l_Trama_Ab;
  END;

  FUNCTION Carga_Trama_Ab1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ab1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Ab1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ab1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Ab1(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'AB1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item);
      l_Trama_Ab1(l_Item).Tipo_Movimiento := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'AB1'
                                                                               ,'TIPO_MOVIMIENTO'
                                                                               ,l_Item);
      l_Trama_Ab1(l_Item).Accion_Sobre_Existencia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                       ,'AB1'
                                                                                       ,'ACCION_SOBRE_EXISTENCIA'
                                                                                       ,l_Item);
      l_Trama_Ab1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'AB1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
      l_Trama_Ab1(l_Item).Motivo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'AB1'
                                                                      ,'MOTIVO'
                                                                      ,l_Item);
      l_Trama_Ab1(l_Item).Costo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'AB1'
                                                                     ,'COSTO'
                                                                     ,l_Item);

      l_Trama_Ab1(l_Item).Decimal_Costo := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'AB1'
                                                                                     ,'DECIMAL_COSTO'
                                                                                     ,l_Item)
                                                  ,'-'
                                                  ,'0');
      l_Trama_Ab1(l_Item).Costo := To_Number(l_Trama_Ab1(l_Item).Costo || '.' || l_Trama_Ab1(l_Item).Decimal_Costo
                                            ,'999999999999.9999');

      l_Trama_Ab1(l_Item).Precio_Lista := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'AB1'
                                                                            ,'PRECIO_LISTA'
                                                                            ,l_Item);
      l_Trama_Ab1(l_Item).Decimal_Plista := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'AB1'
                                                                                      ,'DECIMAL_PLISTA'
                                                                                      ,l_Item)
                                                   ,'-'
                                                   ,'0');
      l_Trama_Ab1(l_Item).Precio_Lista := To_Number(l_Trama_Ab1(l_Item).Precio_Lista || '.' || l_Trama_Ab1(l_Item).Decimal_Plista
                                                   ,'999999999999.9999');

      l_Trama_Ab1(l_Item).Codigo_Reclamo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'AB1'
                                                                              ,'CODIGO_RECLAMO'
                                                                              ,l_Item);
    END LOOP;
    RETURN l_Trama_Ab1;
  END;

  FUNCTION Carga_Trama_Ac(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ac IS
    l_Trama_Ac Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ac;

  BEGIN
    l_Trama_Ac.Convenio               := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AC'
                                                                           ,'CONVENIO');
    l_Trama_Ac.Plan                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AC'
                                                                           ,'PLAN');
    l_Trama_Ac.Rut                    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AC'
                                                                           ,'RUT');
    l_Trama_Ac.Digito_Verificador_Rut := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AC'
                                                                           ,'DIGITO_VERIFICADOR_RUT');
    l_Trama_Ac.Secuencia_b            := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AC'
                                                                           ,'SECUENCIA_B');
    l_Trama_Ac.Rut_Medico             := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AC'
                                                                           ,'RUT_MEDICO');
    l_Trama_Ac.Dv_Rut_Medico          := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AC'
                                                                           ,'DV_RUT_MEDICO');
    l_Trama_Ac.Codigo_Receta          := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AC'
                                                                           ,'CODIGO_RECETA');
    l_Trama_Ac.Rut_Institucion        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AC'
                                                                           ,'RUT_INSTITUCION');
    l_Trama_Ac.Dv_Rut_Institucion     := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AC'
                                                                           ,'DV_RUT_INSTITUCION');
    l_Trama_Ac.Fecha_Receta           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AC'
                                                                           ,'FECHA_RECETA');
    l_Trama_Ac.Rut_Comprador          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AC'
                                                                           ,'RUT_COMPRADOR');
    l_Trama_Ac.Dv_Rut_Comprador       := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AC'
                                                                           ,'DV_RUT_COMPRADOR');
    l_Trama_Ac.Cantidad_Periodos      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AC'
                                                                           ,'CANTIDAD_PERIODOS');
    l_Trama_Ac.Rut_Perfil             := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AC'
                                                                           ,'RUT_PERFIL');
    l_Trama_Ac.Secuencia_Receta       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AC'
                                                                           ,'SECUENCIA_RECETA');
    l_Trama_Ac.Receta_Nueva           := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AC'
                                                                           ,'RECETA_NUEVA');
    l_Trama_Ac.Ges_Uso_Receta         := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AC'
                                                                           ,'GES_USO_RECETA');
    l_Trama_Ac.Uso_Excedente          := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AC'
                                                                           ,'USO_EXCEDENTE');
    l_Trama_Ac.Plan_Con_Guia          := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AC'
                                                                           ,'PLAN_CON_GUIA');

    l_Trama_Ac.Codigo_Medico := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                  ,'AC'
                                                                  ,'CODIGO_MEDICO');

    l_Trama_Ac.Identificador_Titular    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'AC'
                                                                             ,'IDENTIFICADOR_TITULAR');
    l_Trama_Ac.Identificacion_Comprador := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'AC'
                                                                             ,'IDENTIFICACION_COMPRADOR');
    l_Trama_Ac.Identificacion_Perfil    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'AC'
                                                                             ,'IDENTIFICACION_PERFIL');
    l_Trama_Ac.Party_Id_Cliente_c       := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'AC'
                                                                             ,'PARTY_ID_CLIENTE_C');
    l_Trama_Ac.Lista_Diagnosticos       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'AC'
                                                                             ,'LISTA_DIAGNOSTICOS');
    l_Trama_Ac.Subtrama_Ac1             := Carga_Trama_Ac1(p_Cuerpo_Tx
                                                          ,l_Trama_Ac.Lista_Diagnosticos);

    RETURN l_Trama_Ac;
  END;

  FUNCTION Carga_Trama_Ac1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ac1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Ac1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ac1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Ac1(l_Item).Diagnostico := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AC5'
                                                                           ,'DIAGNOSTICO'
                                                                           ,l_Item);
    END LOOP;
    RETURN l_Trama_Ac1;
  END;

  FUNCTION Carga_Trama_Ar(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ar IS
    l_Trama_Ar Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ar;
  BEGIN
    l_Trama_Ar.Codigo_Autorizacion           := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'AR'
                                                                                  ,'CODIGO_AUTORIZACION');
    l_Trama_Ar.Permite_Autorizacion_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'AR'
                                                                                  ,'PERMITE_AUTORIZACION_PRODUCTO');
    l_Trama_Ar.Convenio_Cuota                := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'AR'
                                                                                  ,'CONVENIO_CUOTA');
    l_Trama_Ar.Afecto_Segundo_Credito        := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'AR'
                                                                                  ,'AFECTO_SEGUNDO_CREDITO');
    l_Trama_Ar.Saldo                         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'AR'
                                                                                  ,'SALDO');
    l_Trama_Ar.Saldo_Segundo_Credito         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'AR'
                                                                                  ,'SALDO_SEGUNDO_CREDITO');
    l_Trama_Ar.Tipo_Deducible                := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'AR'
                                                                                  ,'TIPO_DEDUCIBLE');
    l_Trama_Ar.Monto_Deducible               := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'AR'
                                                                                  ,'MONTO_DEDUCIBLE');
    l_Trama_Ar.Valor_Moneda                  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'AR'
                                                                                  ,'VALOR_MONEDA');
    l_Trama_Ar.Tipo_Moneda                   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'AR'
                                                                                  ,'TIPO_MONEDA');
    l_Trama_Ar.Saldo_Descuento               := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'AR'
                                                                                  ,'SALDO_DESCUENTO');
    l_Trama_Ar.Cuadra_Transaccion            := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'AR'
                                                                                  ,'CUADRA_TRANSACCION');
    l_Trama_Ar.Documento_Liquidacion_Pago    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'AR'
                                                                                  ,'DOCUMENTO_LIQUIDACION_PAGO');
    l_Trama_Ar.Documento_Liquidacion_Empresa := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'AR'
                                                                                  ,'DOCUMENTO_LIQUIDACION_EMPRESA');
    l_Trama_Ar.Folio_Bono                    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'AR'
                                                                                  ,'FOLIO_BONO');
    l_Trama_Ar.Folio_Copago                  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'AR'
                                                                                  ,'FOLIO_COPAGO');
    l_Trama_Ar.Id_Solicitud                  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'AR'
                                                                                  ,'ID_SOLICITUD');
    l_Trama_Ar.Numero_Tarjeta                := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'AR'
                                                                                  ,'NUMERO_TARJETA');
    l_Trama_Ar.Codigo_Autorizacion_Ext       := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'AR'
                                                                                  ,'CODIGO_AUTORIZACION_EXT');

    l_Trama_Ar.Saldo_Decimal := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                  ,'AR'
                                                                  ,'SALDO_DECIMAL');

    l_Trama_Ar.Lista_Productos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'AR'
                                                                    ,'LISTA_PRODUCTOS');
    l_Trama_Ar.Lista_Cuotas    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'AR'
                                                                    ,'LISTA_CUOTAS');
    l_Trama_Ar.Subtrama_Ar1    := Carga_Trama_Ar1(p_Cuerpo_Tx
                                                 ,l_Trama_Ar.Lista_Productos);
    l_Trama_Ar.Subtrama_Ar2    := Carga_Trama_Ar2(p_Cuerpo_Tx
                                                 ,l_Trama_Ar.Lista_Cuotas);
    RETURN l_Trama_Ar;
  END;

  FUNCTION Carga_Trama_Ar1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ar1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Ar1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ar1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Ar1(l_Item).Codigo_Lista_Productos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'AR1'
                                                                                      ,'CODIGO_LISTA_PRODUCTOS'
                                                                                      ,l_Item);
      l_Trama_Ar1(l_Item).Bonificacion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'AR1'
                                                                            ,'BONIFICACION'
                                                                            ,l_Item);
      l_Trama_Ar1(l_Item).Descuento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'AR1'
                                                                         ,'DESCUENTO'
                                                                         ,l_Item);
      l_Trama_Ar1(l_Item).Tipo_Lista := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'AR1'
                                                                          ,'TIPO_LISTA'
                                                                          ,l_Item);
      l_Trama_Ar1(l_Item).Asociacion_Lista := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'AR1'
                                                                                ,'ASOCIACION_LISTA'
                                                                                ,l_Item);
      l_Trama_Ar1(l_Item).Prioridad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'AR1'
                                                                         ,'PRIORIDAD'
                                                                         ,l_Item);
      l_Trama_Ar1(l_Item).Permite_Levantar_Restriccion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                            ,'AR1'
                                                                                            ,'PERMITE_LEVANTAR_RESTRICCION'
                                                                                            ,l_Item);
      l_Trama_Ar1(l_Item).Maxima_Compra_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'AR1'
                                                                                      ,'MAXIMA_COMPRA_PRODUCTO'
                                                                                      ,l_Item);
      l_Trama_Ar1(l_Item).Derecho_Segundo_Credito := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                       ,'AR1'
                                                                                       ,'DERECHO_SEGUNDO_CREDITO'
                                                                                       ,l_Item);
      l_Trama_Ar1(l_Item).Saldo_Contador := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'AR1'
                                                                              ,'SALDO_CONTADOR'
                                                                              ,l_Item);
      l_Trama_Ar1(l_Item).Descuento_Adicional := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'AR1'
                                                                                   ,'DESCUENTO_ADICIONAL'
                                                                                   ,l_Item);
      l_Trama_Ar1(l_Item).Aplicar_Siempre := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'AR1'
                                                                               ,'APLICAR_SIEMPRE'
                                                                               ,l_Item);
      l_Trama_Ar1(l_Item).Base_Descuento := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'AR1'
                                                                              ,'BASE_DESCUENTO'
                                                                              ,l_Item);
    END LOOP;
    RETURN l_Trama_Ar1;
  END;

  FUNCTION Carga_Trama_Ar2(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ar2 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Ar2 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ar2;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Ar2(l_Item).Numero_Cuotas := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'AR2'
                                                                             ,'NUMERO_CUOTAS'
                                                                             ,l_Item);
      l_Trama_Ar2(l_Item).Saldo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'AR2'
                                                                     ,'SALDO'
                                                                     ,l_Item);
    END LOOP;
    RETURN l_Trama_Ar2;
  END;

  FUNCTION Carga_Trama_As(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_As IS
    l_Trama_As Scfr_Trx_Dyn_Types_Pk.Rec_Trama_As;
  BEGIN
    l_Trama_As.Numero_Pedido          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AS'
                                                                           ,'NUMERO_PEDIDO');
    l_Trama_As.Estado_Service_Request := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AS'
                                                                           ,'ESTADO_SERVICE_REQUEST');
    l_Trama_As.Estado                 := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AS'
                                                                           ,'ESTADO');
    l_Trama_As.Fecha                  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AS'
                                                                           ,'FECHA');
    l_Trama_As.Motivo                 := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'AS'
                                                                           ,'MOTIVO');
    RETURN l_Trama_As;
  END;

  FUNCTION Carga_Trama_Av(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Av IS
    l_Trama_Av Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Av;
  BEGIN
    l_Trama_Av.Codigo_Autorizacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'AV'
                                                                        ,'CODIGO_AUTORIZACION');
    RETURN l_Trama_Av;
  END;

  FUNCTION Carga_Trama_Ca(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ca IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Ca Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ca;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'CA'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Ca(l_Item).Campana := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'CA'
                                                                      ,'CAMPANA'
                                                                      ,l_Item);
      l_Trama_Ca(l_Item).Control_Eventos := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'CA'
                                                                              ,'CONTROL_EVENTOS'
                                                                              ,l_Item);
      l_Trama_Ca(l_Item).Saldo_Descuento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'CA'
                                                                              ,'SALDO_DESCUENTO'
                                                                              ,l_Item);
      l_Trama_Ca(l_Item).Controla_Tope_Descuento := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'CA'
                                                                                      ,'CONTROLA_TOPE_DESCUENTO'
                                                                                      ,l_Item);
      l_Trama_Ca(l_Item).Saldo_Primera_Compra := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'CA'
                                                                                   ,'SALDO_PRIMERA_COMPRA'
                                                                                   ,l_Item);
      l_Trama_Ca(l_Item).Numero_Cuenta := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'CA'
                                                                            ,'NUMERO_CUENTA'
                                                                            ,l_Item);
      l_Trama_Ca(l_Item).Numero_Rechazos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'CA'
                                                                              ,'NUMERO_RECHAZOS'
                                                                              ,l_Item);
      l_Trama_Ca(l_Item).Puntos_Disponibles := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'CA'
                                                                                 ,'PUNTOS_DISPONIBLES'
                                                                                 ,l_Item);
      l_Trama_Ca(l_Item).Vigencia := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'CA'
                                                                       ,'VIGENCIA'
                                                                       ,l_Item);
      l_Trama_Ca(l_Item).Numero_Rechazos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'CA'
                                                                              ,'MENSAJES_NO_OFRECIDOS'
                                                                              ,l_Item);
      l_Trama_Ca(l_Item).Signo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'CA'
                                                                    ,'SIGNO'
                                                                    ,l_Item);
      l_Trama_Ca(l_Item).Cupo_Preaprobado := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'CA'
                                                                               ,'CUPO_PREAPROBADO'
                                                                               ,l_Item);
    END LOOP;
    RETURN l_Trama_Ca;
  END;

  FUNCTION Carga_Trama_Cx(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cx IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Cx Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cx;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'CX'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Cx(l_Item).Campana := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'CX'
                                                                      ,'CAMPANA'
                                                                      ,l_Item);
      l_Trama_Cx(l_Item).Control_Eventos := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'CX'
                                                                              ,'CONTROL_EVENTOS'
                                                                              ,l_Item);
      l_Trama_Cx(l_Item).Saldo_Descuento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'CX'
                                                                              ,'SALDO_DESCUENTO'
                                                                              ,l_Item);
      l_Trama_Cx(l_Item).Controla_Tope_Descuento := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'CX'
                                                                                      ,'CONTROLA_TOPE_DESCUENTO'
                                                                                      ,l_Item);
    END LOOP;
    RETURN l_Trama_Cx;
  END;

  FUNCTION Carga_Trama_Cc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cc IS
    l_Trama_Cc Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cc;
  BEGIN
    l_Trama_Cc.Codigo_Consejo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'CC'
                                                                   ,'CODIGO_CONSEJO');
    RETURN l_Trama_Cc;
  END;

  FUNCTION Carga_Trama_Cd(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cd IS
    l_Trama_Cd Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cd;
  BEGIN
    l_Trama_Cd.Uso_Frecuente := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                  ,'CD'
                                                                  ,'USO_FRECUENTE');
    RETURN l_Trama_Cd;
  END;

  FUNCTION Carga_Trama_Ce(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ce IS
    l_Trama_Ce Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ce;
  BEGIN
    l_Trama_Ce.Codigo_Enfermedad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'CE'
                                                                      ,'CODIGO_ENFERMEDAD');
    RETURN l_Trama_Ce;
  END;

  FUNCTION Carga_Trama_Cf(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cf IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Cf Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cf;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'CF'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Cf(l_Item).Uso_Frecuente := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'CF'
                                                                            ,'USO_FRECUENTE'
                                                                            ,l_Item);
      l_Trama_Cf(l_Item).Evento_Actual := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'CF'
                                                                            ,'EVENTO_ACTUAL'
                                                                            ,l_Item);
      l_Trama_Cf(l_Item).Saldo_Evento_Actual := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'CF'
                                                                                  ,'SALDO_EVENTO_ACTUAL'
                                                                                  ,l_Item);
      l_Trama_Cf(l_Item).Signo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'CF'
                                                                    ,'SIGNO'
                                                                    ,l_Item);
      l_Trama_Cf(l_Item).Eventos_Cumplidos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'CF'
                                                                                ,'EVENTOS_CUMPLIDOS'
                                                                                ,l_Item);
      l_Trama_Cf(l_Item).Campana := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'CF'
                                                                      ,'CAMPANA'
                                                                      ,l_Item);
      l_Trama_Cf(l_Item).Fecha_Vencimiento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'CF'
                                                                                ,'FECHA_VENCIMIENTO'
                                                                                ,l_Item);
    END LOOP;
    RETURN l_Trama_Cf;
  END;

  FUNCTION Carga_Trama_Cg(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cg IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Cg Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cg;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'CG'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Cg(l_Item).Codigo_Cupon := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'CG'
                                                                           ,'CODIGO_CUPON'
                                                                           ,l_Item);
      l_Trama_Cg(l_Item).Estado := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'CG'
                                                                     ,'ESTADO'
                                                                     ,l_Item);
      l_Trama_Cg(l_Item).Campana := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'CG'
                                                                      ,'CAMPANA'
                                                                      ,l_Item);
      l_Trama_Cg(l_Item).Fecha := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'CG'
                                                                    ,'FECHA'
                                                                    ,l_Item);
      l_Trama_Cg(l_Item).Rut := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                  ,'CG'
                                                                  ,'RUT'
                                                                  ,l_Item);
      l_Trama_Cg(l_Item).Digito_Verificador_Rut := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'CG'
                                                                                     ,'DIGITO_VERIFICADOR_RUT'
                                                                                     ,l_Item);
      l_Trama_Cg(l_Item).Apellido_Paterno := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'CG'
                                                                               ,'APELLIDO_PATERNO'
                                                                               ,l_Item);
      l_Trama_Cg(l_Item).Apellido_Materno := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'CG'
                                                                               ,'APELLIDO_MATERNO'
                                                                               ,l_Item);
      l_Trama_Cg(l_Item).Nombre := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'CG'
                                                                     ,'NOMBRE'
                                                                     ,l_Item);
      l_Trama_Cg(l_Item).Local := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'CG'
                                                                    ,'LOCAL'
                                                                    ,l_Item);
      l_Trama_Cg(l_Item).Folio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'CG'
                                                                    ,'FOLIO'
                                                                    ,l_Item);
    END LOOP;
    RETURN l_Trama_Cg;
  END;

  FUNCTION Carga_Trama_Ci(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ci IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Ci Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ci;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'CI'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Ci(l_Item).Codigo_Cupon := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'CI'
                                                                           ,'CODIGO_CUPON'
                                                                           ,l_Item);
    END LOOP;
    RETURN l_Trama_Ci;
  END;

  FUNCTION Carga_Trama_Ck(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ck IS
    l_Trama_Ck Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ck;
  BEGIN
    l_Trama_Ck.Cantidad_Locales   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'CK'
                                                                       ,'CANTIDAD_LOCALES');
    l_Trama_Ck.Cantidad_Productos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'CK'
                                                                       ,'CANTIDAD_PRODUCTOS');
    l_Trama_Ck.Subtrama_Ck1       := Carga_Trama_Ck1(p_Cuerpo_Tx
                                                    ,l_Trama_Ck.Cantidad_Locales);
    l_Trama_Ck.Subtrama_Ck2       := Carga_Trama_Ck2(p_Cuerpo_Tx
                                                    ,l_Trama_Ck.Cantidad_Productos);
    RETURN l_Trama_Ck;
  END;

  FUNCTION Carga_Trama_Ck1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ck1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Ck1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ck1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Ck1(l_Item).Local := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'CK1'
                                                                     ,'LOCAL'
                                                                     ,l_Item);
    END LOOP;
    RETURN l_Trama_Ck1;
  END;

  FUNCTION Carga_Trama_Ck2(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ck2 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Ck2 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ck2;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Ck2(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'CK2'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item);
    END LOOP;
    RETURN l_Trama_Ck2;
  END;

  FUNCTION Carga_Trama_Cl(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cl IS
    l_Trama_Cl Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cl;
  BEGIN
    l_Trama_Cl.Autorizacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                 ,'CL'
                                                                 ,'AUTORIZACION');
    l_Trama_Cl.Valida_Lista := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                 ,'CL'
                                                                 ,'VALIDA_LISTA');
    RETURN l_Trama_Cl;
  END;

  FUNCTION Carga_Trama_Cm(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cm IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Cm Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cm;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'CM'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Cm(l_Item).Codigo_Interno_Cupon := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'CM'
                                                                                   ,'CODIGO_INTERNO_CUPON'
                                                                                   ,l_Item);
      l_Trama_Cm(l_Item).Mes := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                  ,'CM'
                                                                  ,'MES'
                                                                  ,l_Item);
      l_Trama_Cm(l_Item).Limite := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'CM'
                                                                     ,'LIMITE'
                                                                     ,l_Item);
      l_Trama_Cm(l_Item).Tipo_Cupon := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'CM'
                                                                         ,'TIPO_CUPON'
                                                                         ,l_Item);
      l_Trama_Cm(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'CM'
                                                                       ,'PRODUCTO'
                                                                       ,l_Item);
      l_Trama_Cm(l_Item).Familia_Comercial := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'CM'
                                                                                ,'FAMILIA_COMERCIAL'
                                                                                ,l_Item);
      l_Trama_Cm(l_Item).Descuento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'CM'
                                                                        ,'DESCUENTO'
                                                                        ,l_Item);
      l_Trama_Cm(l_Item).Campana := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'CM'
                                                                      ,'CAMPANA'
                                                                      ,l_Item);
      l_Trama_Cm(l_Item).Tipo_Beneficio := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'CM'
                                                                             ,'TIPO_BENEFICIO'
                                                                             ,l_Item);
    END LOOP;
    RETURN l_Trama_Cm;
  END;

  FUNCTION Carga_Trama_Cn(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cn IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Cn Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cn;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'CN'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Cn(l_Item).Numero_Opcion_Concurso := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'CN'
                                                                                     ,'NUMERO_OPCION_CONCURSO'
                                                                                     ,l_Item);
      l_Trama_Cn(l_Item).Campana := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'CN'
                                                                      ,'CAMPANA'
                                                                      ,l_Item);
    END LOOP;
    RETURN l_Trama_Cn;
  END;

  FUNCTION Carga_Trama_Co(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Co IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Co Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Co;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'CO'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Co(l_Item).Convenio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'CO'
                                                                       ,'CONVENIO'
                                                                       ,l_Item);
      l_Trama_Co(l_Item).Plan := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'CO'
                                                                   ,'PLAN'
                                                                   ,l_Item);
      l_Trama_Co(l_Item).Estado_Convenio := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'CO'
                                                                              ,'ESTADO_CONVENIO'
                                                                              ,l_Item);
      l_Trama_Co(l_Item).Retencion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'CO'
                                                                        ,'RETENCION'
                                                                        ,l_Item);
      l_Trama_Co(l_Item).Aplica_Dcto_Posologia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'CO'
                                                                                    ,'APLICA_DCTO_DESCUENTO'
                                                                                    ,l_Item);
      l_Trama_Co(l_Item).Agrupacion_Perfil := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'CO'
                                                                                ,'AGRUPACION_PERFIL'
                                                                                ,l_Item);
      l_Trama_Co(l_Item).Prioridad_Ges := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'CO'
                                                                            ,'PRIORIDAD_GES'
                                                                            ,l_Item);
      l_Trama_Co(l_Item).Dias_Tto_Defecto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'CO'
                                                                               ,'DIAS_TTO_DEFECTO'
                                                                               ,l_Item);
      l_Trama_Co(l_Item).Receta_Retenida := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'CO'
                                                                              ,'RECETA_RETENIDA'
                                                                              ,l_Item);
      l_Trama_Co(l_Item).Requiere_Indicaciones := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'CO'
                                                                                    ,'REQUIERE_INDICACIONES'
                                                                                    ,l_Item);
      l_Trama_Co(l_Item).Imprime_Indicaciones := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'CO'
                                                                                   ,'IMPRIME_INDICACIONES'
                                                                                   ,l_Item);
      l_Trama_Co(l_Item).Solicitar_Clave_Qf := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'CO'
                                                                                 ,'SOLICITAR_CLAVE_QF'
                                                                                 ,l_Item);
      l_Trama_Co(l_Item).Despliegue_Rechazo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'CO'
                                                                                 ,'DESPLIEGUE_RECHAZO'
                                                                                 ,l_Item);
      l_Trama_Co(l_Item).Glosa_Descuento := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'CO'
                                                                              ,'GLOSA_DESCUENTO'
                                                                              ,l_Item);
      l_Trama_Co(l_Item).Convenio_Club := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'CO'
                                                                            ,'CONVENIO_CLUB'
                                                                            ,l_Item);
      l_Trama_Co(l_Item).Digitalizacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'CO'
                                                                             ,'DIGITALIZACION'
                                                                             ,l_Item);

      l_Trama_Co(l_Item).Plan_Con_Guia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'CO'
                                                                            ,'PLAN_CON_GUIA'
                                                                            ,l_Item);

      l_Trama_Co(l_Item).Plan_Alternativo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'CO'
                                                                               ,'PLAN_ALTERNATIVO'
                                                                               ,l_Item);

      l_Trama_Co(l_Item).Tipo_Plan := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'CO'
                                                                        ,'TIPO_PLAN'
                                                                        ,l_Item);
      l_Trama_Co(l_Item).Item_Fee := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'CO'
                                                                       ,'ITEM_FEE'
                                                                       ,l_Item);

      l_Trama_Co(l_Item).Marca_Fee := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'CO'
                                                                        ,'MARCA_FEE'
                                                                        ,l_Item);

      l_Trama_Co(l_Item).Lista_Beneficiarios := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'CO'
                                                                                  ,'LISTA_BENEFICIARIOS'
                                                                                  ,l_Item);

      l_Trama_Co(l_Item).Lista_Preexistencia := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'CO'
                                                                                  ,'LISTA_PREEXISTENCIA'
                                                                                  ,l_Item);

      l_Trama_Co(l_Item).Subtrama_Co1 := Carga_Trama_Co1(p_Cuerpo_Tx
                                                        ,l_Trama_Co(l_Item).Lista_Beneficiarios
                                                        ,l_Item);

      l_Trama_Co(l_Item).Subtrama_Co2 := Carga_Trama_Co2(p_Cuerpo_Tx
                                                        ,l_Trama_Co(l_Item).Lista_Preexistencia
                                                        ,l_Item);
    END LOOP;
    RETURN l_Trama_Co;
  END;

  FUNCTION Carga_Trama_Co2(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Co2 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Co2 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Co2;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Co2(l_Item).Identi_Titular_Benefic := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'CO9'
                                                                                      ,'IDENTI_TITULAR_BENEFIC'
                                                                                      ,l_Item
                                                                                      ,p_Ind);
      --//-----------------------------------------------------------------Termino--\\
      l_Trama_Co2(l_Item).Codigo_Preexistencia := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'CO9'
                                                                                    ,'CODIGO_PREEXISTENCIA'
                                                                                    ,l_Item
                                                                                    ,p_Ind);
      l_Trama_Co2(l_Item).Mensaje_Preexistencia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'CO9'
                                                                                     ,'MENSAJE_PREEXISTENCIA'
                                                                                     ,l_Item
                                                                                     ,p_Ind);
    END LOOP;
    RETURN l_Trama_Co2;
  END;

  FUNCTION Carga_Trama_Co1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Co1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Co1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Co1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      --//--------------------------------------------------------------------------\\
      --// CBR 17/08/2020 05:16                                                     \\
      --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
      --//-----------------------------------------------------------------Inicio---\\
      l_Trama_Co1(l_Item).Identi_Titular_Benefic := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'CO1'
                                                                                      ,'IDENTI_TITULAR_BENEFIC'
                                                                                      ,l_Item
                                                                                      ,p_Ind);
      --//-----------------------------------------------------------------Termino--\\
      l_Trama_Co1(l_Item).Rut_Titular_Beneficiario := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                        ,'CO1'
                                                                                        ,'RUT_TITULAR_BENEFICIARIO'
                                                                                        ,l_Item
                                                                                        ,p_Ind);
      l_Trama_Co1(l_Item).Digito_Verificador_Rut := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'CO1'
                                                                                      ,'DIGITO_VERIFICADOR_RUT'
                                                                                      ,l_Item
                                                                                      ,p_Ind);
      l_Trama_Co1(l_Item).Party_Id_Cliente := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'CO1'
                                                                                ,'PARTY_ID_CLIENTE'
                                                                                ,l_Item
                                                                                ,p_Ind);
      l_Trama_Co1(l_Item).Party_Id_Cliente_c := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'CO1'
                                                                                  ,'PARTY_ID_CLIENTE_C'
                                                                                  ,l_Item
                                                                                  ,p_Ind);
      l_Trama_Co1(l_Item).Secuencia_Titular_Beneficiario := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                              ,'CO1'
                                                                                              ,'SECUENCIA_TITULAR_BENEFICIARIO'
                                                                                              ,l_Item
                                                                                              ,p_Ind);
      l_Trama_Co1(l_Item).Apellido_Paterno := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'CO1'
                                                                                ,'APELLIDO_PATERNO'
                                                                                ,l_Item
                                                                                ,p_Ind);
      l_Trama_Co1(l_Item).Apellido_Materno := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'CO1'
                                                                                ,'APELLIDO_MATERNO'
                                                                                ,l_Item
                                                                                ,p_Ind);
      l_Trama_Co1(l_Item).Nombres := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'CO1'
                                                                       ,'NOMBRES'
                                                                       ,l_Item
                                                                       ,p_Ind);
      l_Trama_Co1(l_Item).Estado_Beneficiario := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'CO1'
                                                                                   ,'ESTADO_BENEFICIARIO'
                                                                                   ,l_Item
                                                                                   ,p_Ind);
      l_Trama_Co1(l_Item).Saldo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'CO1'
                                                                     ,'SALDO'
                                                                     ,l_Item
                                                                     ,p_Ind);
      l_Trama_Co1(l_Item).Saldo_Segundo_Credito := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'CO1'
                                                                                     ,'SALDO_SEGUNDO_CREDITO'
                                                                                     ,l_Item
                                                                                     ,p_Ind);
      --//--------------------------------------------------------------------------\\
      --// CBR 11/10/2017 17:19                                                     \\
      --// BIOMETRIA                                                                         \\
      --//-----------------------------------------------------------------Inicio---\\
      l_Trama_Co1(l_Item).Biometria := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'CO1'
                                                                         ,'BIOMETRIA'
                                                                         ,l_Item
                                                                         ,p_Ind);
      l_Trama_Co1(l_Item).Clave_Qf_Biometria := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'CO1'
                                                                                  ,'CLAVE_QF_BIOMETRIA'
                                                                                  ,l_Item
                                                                                  ,p_Ind);
      --//-----------------------------------------------------------------Termino--\\
      /* CGC 25-10-2018*/

      l_Trama_Co1(l_Item).Huella_Qf_Biometria := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'CO1'
                                                                                   ,'HUELLA_QF_BIOMETRIA'
                                                                                   ,l_Item
                                                                                   ,p_Ind);
      l_Trama_Co1(l_Item).Firma_Electronica := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'CO1'
                                                                                 ,'FIRMA_ELECTRONICA'
                                                                                 ,l_Item
                                                                                 ,p_Ind);
      l_Trama_Co1(l_Item).Mensaje_Beneficiario := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'CO1'
                                                                                    ,'MENSAJE_BENEFICIARIO'
                                                                                    ,l_Item
                                                                                    ,p_Ind);

      l_Trama_Co1(l_Item).Saldo_Decimal := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'CO1'
                                                                             ,'SALDO_DECIMAL'
                                                                             ,l_Item
                                                                             ,p_Ind);

    END LOOP;
    RETURN l_Trama_Co1;
  END;

  FUNCTION Carga_Trama_Cp(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cp IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Cp Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cp;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'CP'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Cp(l_Item).Codigo_Interno_Cupon := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'CP'
                                                                                   ,'CODIGO_INTERNO_CUPON'
                                                                                   ,l_Item);
      l_Trama_Cp(l_Item).Codigo_Cupon := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'CP'
                                                                           ,'CODIGO_CUPON'
                                                                           ,l_Item);
      l_Trama_Cp(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'CP'
                                                                       ,'PRODUCTO'
                                                                       ,l_Item);
      l_Trama_Cp(l_Item).Familia_Comercial := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'CP'
                                                                                ,'FAMILIA_COMERCIAL'
                                                                                ,l_Item);
      l_Trama_Cp(l_Item).Descuento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'CP'
                                                                        ,'DESCUENTO'
                                                                        ,l_Item);
      l_Trama_Cp(l_Item).Tipo_Descuento := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'CP'
                                                                             ,'TIPO_DESCUENTO'
                                                                             ,l_Item);
      l_Trama_Cp(l_Item).Vencimiento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'CP'
                                                                          ,'VENCIMIENTO'
                                                                          ,l_Item);
      l_Trama_Cp(l_Item).Campana := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'CP'
                                                                      ,'CAMPANA'
                                                                      ,l_Item);
      l_Trama_Cp(l_Item).Tipo_Cupon := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'CP'
                                                                         ,'TIPO_CUPON'
                                                                         ,l_Item);
    END LOOP;
    RETURN l_Trama_Cp;
  END;

  FUNCTION Carga_Trama_Cr(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cr IS
    l_Trama_Cr Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cr;
  BEGIN
    l_Trama_Cr.Rut_Quien_Retira    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'CR'
                                                                        ,'RUT_QUIEN_RETIRA');
    l_Trama_Cr.Dv_Rut_Quien_Retira := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'CR'
                                                                        ,'DV_RUT_QUIEN_RETIRA');
    l_Trama_Cr.Nombre_Quien_Retiro := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'CR'
                                                                        ,'NOMBRE_QUIEN_RETIRO');
    RETURN l_Trama_Cr;
  END;

  FUNCTION Carga_Trama_Cs(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cs IS
    l_Trama_Cs Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cs;
  BEGIN
    l_Trama_Cs.Codigo_Cupon := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                 ,'CS'
                                                                 ,'CODIGO_CUPON');
    RETURN l_Trama_Cs;
  END;

  FUNCTION Carga_Trama_Ct(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ct IS
    l_Trama_Ct Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ct;
  BEGIN
    l_Trama_Ct.Signo               := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'CT'
                                                                        ,'SIGNO');
    l_Trama_Ct.Puntos              := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'CT'
                                                                        ,'PUNTOS');
    l_Trama_Ct.Rut_Beneficiario    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'CT'
                                                                        ,'RUT_BENEFICIARIO');
    l_Trama_Ct.Dv_Rut_Beneficiario := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'CT'
                                                                        ,'DV_RUT_BENEFICIARIO');
    l_Trama_Ct.Nombre              := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'CT'
                                                                        ,'NOMBRE');
    l_Trama_Ct.Cantidad_Tx_Puntos  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'CT'
                                                                        ,'CANTIDAD_TX_PUNTOS');
    l_Trama_Ct.Subtrama_Ct1        := Carga_Trama_Ct1(p_Cuerpo_Tx
                                                     ,l_Trama_Ct.Cantidad_Tx_Puntos);
    RETURN l_Trama_Ct;
  END;

  FUNCTION Carga_Trama_Ct1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ct1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Ct1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ct1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Ct1(l_Item).Tipo_Transaccion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'CT1'
                                                                                ,'TIPO_TRANSACCION'
                                                                                ,l_Item);
      l_Trama_Ct1(l_Item).Local := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'CT1'
                                                                     ,'LOCAL'
                                                                     ,l_Item);
      l_Trama_Ct1(l_Item).Folio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'CT1'
                                                                     ,'FOLIO'
                                                                     ,l_Item);
      l_Trama_Ct1(l_Item).Fecha := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'CT1'
                                                                     ,'FECHA'
                                                                     ,l_Item);
      l_Trama_Ct1(l_Item).Signo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'CT1'
                                                                     ,'SIGNO'
                                                                     ,l_Item);
      l_Trama_Ct1(l_Item).Puntos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'CT1'
                                                                      ,'PUNTOS'
                                                                      ,l_Item);
    END LOOP;
    RETURN l_Trama_Ct1;
  END;

  FUNCTION Carga_Trama_Ct2(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ct2 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Ct2 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ct2;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Ct2(l_Item).Local := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'CT2'
                                                                     ,'LOCAL'
                                                                     ,l_Item);
      l_Trama_Ct2(l_Item).Folio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'CT2'
                                                                     ,'FOLIO'
                                                                     ,l_Item);
      l_Trama_Ct2(l_Item).Fecha := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'CT2'
                                                                     ,'FECHA'
                                                                     ,l_Item);
      l_Trama_Ct2(l_Item).Signo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'CT2'
                                                                     ,'SIGNO'
                                                                     ,l_Item);
      l_Trama_Ct2(l_Item).Puntos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'CT2'
                                                                      ,'PUNTOS'
                                                                      ,l_Item);
    END LOOP;
    RETURN l_Trama_Ct2;
  END;

  FUNCTION Carga_Trama_Ct3(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ct3 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Ct3 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ct3;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Ct3(l_Item).Local := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'CT3'
                                                                     ,'LOCAL'
                                                                     ,l_Item);
      l_Trama_Ct3(l_Item).Folio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'CT3'
                                                                     ,'FOLIO'
                                                                     ,l_Item);
      l_Trama_Ct3(l_Item).Fecha := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'CT3'
                                                                     ,'FECHA'
                                                                     ,l_Item);
      l_Trama_Ct3(l_Item).Signo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'CT3'
                                                                     ,'SIGNO'
                                                                     ,l_Item);
      l_Trama_Ct3(l_Item).Puntos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'CT3'
                                                                      ,'PUNTOS'
                                                                      ,l_Item);
    END LOOP;
    RETURN l_Trama_Ct3;
  END;

  FUNCTION Carga_Trama_Cu(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cu IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Cu Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cu;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'CU'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Cu(l_Item).Codigo_Cupon := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'CU'
                                                                           ,'CODIGO_CUPON'
                                                                           ,l_Item);
      l_Trama_Cu(l_Item).Estado := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'CU'
                                                                     ,'ESTADO'
                                                                     ,l_Item);
      l_Trama_Cu(l_Item).Campana := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'CU'
                                                                      ,'CAMPANA'
                                                                      ,l_Item);
      l_Trama_Cu(l_Item).Fecha := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'CU'
                                                                    ,'FECHA'
                                                                    ,l_Item);
      l_Trama_Cu(l_Item).Local := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'CU'
                                                                    ,'LOCAL'
                                                                    ,l_Item);
      l_Trama_Cu(l_Item).Folio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'CU'
                                                                    ,'FOLIO'
                                                                    ,l_Item);
    END LOOP;
    RETURN l_Trama_Cu;
  END;

  FUNCTION Carga_Trama_Cv(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Cv Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'CV'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Cv(l_Item).Convenio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'CV'
                                                                       ,'CONVENIO'
                                                                       ,l_Item);
      l_Trama_Cv(l_Item).Plan := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'CV'
                                                                   ,'PLAN'
                                                                   ,l_Item);
      l_Trama_Cv(l_Item).Codigo_Autorizacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'CV'
                                                                                  ,'CODIGO_AUTORIZACION'
                                                                                  ,l_Item);
      --//--------------------------------------------------------------------------\\
      --// CBR 17/08/2020 05:23                                                     \\
      --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
      --//-----------------------------------------------------------------Inicio---\\
      l_Trama_Cv(l_Item).Identi_Titular := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'CV'
                                                                             ,'IDENTI_TITULAR'
                                                                             ,l_Item);
      l_Trama_Cv(l_Item).Identificacion_Comprador := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                       ,'CV'
                                                                                       ,'IDENTIFICACION_COMPRADOR'
                                                                                       ,l_Item);
      l_Trama_Cv(l_Item).Codigo_Autorizacion_Externo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'CV'
                                                                                          ,'CODIGO_AUTORIZACION_EXTERNO'
                                                                                          ,l_Item);
      --//-----------------------------------------------------------------Termino--\\
      l_Trama_Cv(l_Item).Rut_Titular := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'CV'
                                                                          ,'RUT_TITULAR'
                                                                          ,l_Item);
      l_Trama_Cv(l_Item).Dv_Titular := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'CV'
                                                                         ,'DV_TITULAR'
                                                                         ,l_Item);
      l_Trama_Cv(l_Item).Party_Id := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'CV'
                                                                       ,'PARTY_ID'
                                                                       ,l_Item);
      l_Trama_Cv(l_Item).Party_Id_c := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'CV'
                                                                         ,'PARTY_ID_C'
                                                                         ,l_Item);

      l_Trama_Cv(l_Item).Lista_Diagnosticos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'CV'
                                                                                 ,'LISTA_DIAGNOSTICOS');

      l_Trama_Cv(l_Item).Subtrama_Cv1 := Carga_Trama_Cv1(p_Cuerpo_Tx
                                                        ,l_Trama_Cv(l_Item).Lista_Diagnosticos);
    END LOOP;
    RETURN l_Trama_Cv;
  END;

  FUNCTION Carga_Trama_Cv1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Cv1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Cv1(l_Item).Diagnostico := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'CV2'
                                                                           ,'DIAGNOSTICO'
                                                                           ,l_Item);
    END LOOP;
    RETURN l_Trama_Cv1;
  END;

  FUNCTION Carga_Trama_Cz(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cz IS
    l_Trama_Cz Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cz;
  BEGIN
    l_Trama_Cz.Uso_Frecuente      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'CZ'
                                                                       ,'USO_FRECUENTE');
    l_Trama_Cz.Rut_Medico         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'CZ'
                                                                       ,'RUT_MEDICO');
    l_Trama_Cz.Dv_Rut_Medico      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'CZ'
                                                                       ,'DV_RUT_MEDICO');
    l_Trama_Cz.Folio              := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'CZ'
                                                                       ,'FOLIO');
    l_Trama_Cz.Rut_Vendedor       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'CZ'
                                                                       ,'RUT_VENDEDOR');
    l_Trama_Cz.Dv_Rut_Vendedor    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'CZ'
                                                                       ,'DV_RUT_VENDEDOR');
    l_Trama_Cz.Numero_Inscripcion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'CZ'
                                                                       ,'NUMERO_INSCRIPCION');
    l_Trama_Cz.Fecha_Expiracion   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'CZ'
                                                                       ,'FECHA_EXPIRACION');
    RETURN l_Trama_Cz;
  END;

  FUNCTION Carga_Trama_Db(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Db IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Db Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Db;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'DB'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      --//--------------------------------------------------------------------------\\
      --// CBR 17/08/2020 04:23                                                     \\
      --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
      --//-----------------------------------------------------------------Inicio---\\
      l_Trama_Db(l_Item).Identi_Beneficiario := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DB'
                                                                                  ,'IDENTI_BENEFICIARIO'
                                                                                  ,l_Item);
      --//-----------------------------------------------------------------Termino--\\
            
      l_Trama_Db(l_Item).Rut_Beneficiario := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'DB'
                                                                               ,'RUT_BENEFICIARIO'
                                                                               ,l_Item);
      
      l_Trama_Db(l_Item).Dv_Rut_Beneficiario := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DB'
                                                                                  ,'DV_RUT_BENEFICIARIO'
                                                                                  ,l_Item);
      
      l_Trama_Db(l_Item).Party_Id := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'DB'
                                                                       ,'PARTY_ID'
                                                                       ,l_Item);
                                                                       
      l_Trama_Db(l_Item).Party_Id_c := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'DB'
                                                                         ,'PARTY_ID_C'
                                                                         ,l_Item);      
                                                                         
      l_Trama_Db(l_Item).Secuencia_b := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'DB'
                                                                          ,'SECUENCIA_B'
                                                                          ,l_Item);
                                                                                                                                                    
      l_Trama_Db(l_Item).Apellido_Paterno := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'DB'
                                                                               ,'APELLIDO_PATERNO'
                                                                               ,l_Item);
                                                                                           
      l_Trama_Db(l_Item).Apellido_Materno := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'DB'
                                                                               ,'APELLIDO_MATERNO'
                                                                               ,l_Item);
                                                                                                                                                              
      l_Trama_Db(l_Item).Nombre := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'DB'
                                                                     ,'NOMBRE'
                                                                     ,l_Item);
                                                                                                                                          
    END LOOP;
    RETURN l_Trama_Db;
  END;

  FUNCTION Carga_Trama_Dc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dc IS
    l_Trama_Dc Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dc;
  BEGIN
    l_Trama_Dc.Rut_Facturacion              := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DC'
                                                                                 ,'RUT_FACTURACION');
    l_Trama_Dc.Dv_Rut_Facturacion           := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DC'
                                                                                 ,'DV_RUT_FACTURACION');
    l_Trama_Dc.Party_Id                     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DC'
                                                                                 ,'PARTY_ID');
    l_Trama_Dc.Razon_Social                 := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DC'
                                                                                 ,'RAZON_SOCIAL');
    l_Trama_Dc.Nombre_Fantasia              := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DC'
                                                                                 ,'NOMBRE_FANTASIA');
    l_Trama_Dc.Giro                         := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DC'
                                                                                 ,'GIRO');
    l_Trama_Dc.Direccion_Facturacion        := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DC'
                                                                                 ,'DIRECCION_FACTURACION');
    l_Trama_Dc.Comuna_Facturacion           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DC'
                                                                                 ,'COMUNA_FACTURACION');
    l_Trama_Dc.Ciudad_Facturacion           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DC'
                                                                                 ,'CIUDAD_FACTURACION');
    l_Trama_Dc.Direccion_Envio_Correo       := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DC'
                                                                                 ,'DIRECCION_ENVIO_CORREO');
    l_Trama_Dc.Comuna_Envio_Correspondencia := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DC'
                                                                                 ,'COMUNA_ENVIO_CORRESPONDENCIA');
    l_Trama_Dc.Ciudad_Envio_Correspondencia := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DC'
                                                                                 ,'CIUDAD_ENVIO_CORRESPONDENCIA');
    l_Trama_Dc.Telefono                     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DC'
                                                                                 ,'TELEFONO');
    l_Trama_Dc.Fax                          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DC'
                                                                                 ,'FAX');
    l_Trama_Dc.Email                        := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DC'
                                                                                 ,'EMAIL');
    RETURN l_Trama_Dc;
  END;

  FUNCTION Carga_Trama_Dh(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dh IS
    l_Trama_Dh Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dh;
  BEGIN
    l_Trama_Dh.Correlativo_Tx := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'DH'
                                                                   ,'CORRELATIVO_TX');
    l_Trama_Dh.Ot             := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                   ,'DH'
                                                                   ,'OT');
    l_Trama_Dh.Local          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'DH'
                                                                   ,'LOCAL');
    RETURN l_Trama_Dh;
  END;

  FUNCTION Carga_Trama_Dj(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dj IS
    l_Trama_Dj Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dj;
  BEGIN
    l_Trama_Dj.Tipo_Movimiento_Padre   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DJ'
                                                                            ,'TIPO_MOVIMIENTO_PADRE');
    l_Trama_Dj.Tipo_Movimiento_Hijo    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DJ'
                                                                            ,'TIPO_MOVIMIENTO_HIJO');
    l_Trama_Dj.Folio                   := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DJ'
                                                                                 ,'FOLIO'));
    l_Trama_Dj.Guia_Despacho           := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DJ'
                                                                                 ,'GUIA_DESPACHO'));
    l_Trama_Dj.Tipo_Guia_Despacho      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DJ'
                                                                            ,'TIPO_GUIA_DESPACHO');
    l_Trama_Dj.Accion_Sobre_Existencia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DJ'
                                                                            ,'ACCION_SOBRE_EXISTENCIA');
    l_Trama_Dj.Numero_Folio_Original   := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DJ'
                                                                                 ,'NUMERO_FOLIO_ORIGINAL'));
    l_Trama_Dj.Fecha_Folio_Original    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DJ'
                                                                            ,'FECHA_FOLIO_ORIGINAL');
    l_Trama_Dj.Codigo_Local_Socofar    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DJ'
                                                                            ,'CODIGO_LOCAL_SOCOFAR');
    l_Trama_Dj.Numero_Reclamo          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DJ'
                                                                            ,'NUMERO_RECLAMO');
    l_Trama_Dj.Fecha_Reclamo           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DJ'
                                                                            ,'FECHA_RECLAMO');
    l_Trama_Dj.Dfi_Numero_Asignacion   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DJ'
                                                                            ,'DFI_NUMERO_ASIGNACION');
    l_Trama_Dj.Matricula_Bulto         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DJ'
                                                                            ,'MATRICULA_BULTO');
    l_Trama_Dj.Monto                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DJ'
                                                                            ,'MONTO');
    l_Trama_Dj.Decimal_Monto           := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'DJ'
                                                                                    ,'DECIMAL_MONTO')
                                                 ,'-'
                                                 ,'0');
    l_Trama_Dj.Monto                   := To_Number(l_Trama_Dj.Monto || '.' || l_Trama_Dj.Decimal_Monto
                                                   ,'999999999999.9999');
    l_Trama_Dj.Identi_Proveedor        := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DJ'
                                                                            ,'IDENTI_PROVEEDOR');

    l_Trama_Dj.Rut_Proveedor      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'DJ'
                                                                       ,'RUT_PROVEEDOR');
    l_Trama_Dj.Sucursal_Proveedor := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'DJ'
                                                                       ,'SUCURSAL_PROVEEDOR');
    l_Trama_Dj.Sello_Seguro_Uno   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'DJ'
                                                                       ,'SELLO_SEGURO_UNO');
    l_Trama_Dj.Sello_Seguro_Dos   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'DJ'
                                                                       ,'SELLO_SEGURO_DOS');
    l_Trama_Dj.Cantidad_Productos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'DJ'
                                                                       ,'CANTIDAD_PRODUCTOS');
    l_Trama_Dj.Subtrama_Dj1       := Carga_Trama_Dj1(p_Cuerpo_Tx
                                                    ,l_Trama_Dj.Cantidad_Productos);
    RETURN l_Trama_Dj;
  END;

  FUNCTION Carga_Trama_Dj1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dj1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Dj1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dj1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Dj1(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'DJ1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item);
      l_Trama_Dj1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'DJ1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
      l_Trama_Dj1(l_Item).Motivo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'DJ1'
                                                                      ,'MOTIVO'
                                                                      ,l_Item);
      l_Trama_Dj1(l_Item).Precio_Final := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DJ1'
                                                                            ,'PRECIO_FINAL'
                                                                            ,l_Item);

      l_Trama_Dj1(l_Item).Decimal_Pfinal := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'DJ1'
                                                                                      ,'DECIMAL_PFINAL'
                                                                                      ,l_Item)
                                                   ,'-'
                                                   ,'0');
      l_Trama_Dj1(l_Item).Precio_Final := To_Number(l_Trama_Dj1(l_Item).Precio_Final || '.' || l_Trama_Dj1(l_Item).Decimal_Pfinal
                                                   ,'999999999999.9999');

      l_Trama_Dj1(l_Item).Costo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'DJ1'
                                                                     ,'COSTO'
                                                                     ,l_Item);

      l_Trama_Dj1(l_Item).Decimal_Costo := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'DJ1'
                                                                                     ,'DECIMAL_COSTO'
                                                                                     ,l_Item)
                                                  ,'-'
                                                  ,'0');
      l_Trama_Dj1(l_Item).Costo := To_Number(l_Trama_Dj1(l_Item).Costo || '.' || l_Trama_Dj1(l_Item).Decimal_Costo
                                            ,'999999999999.9999');

      l_Trama_Dj1(l_Item).Codigo_Personal := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'DJ1'
                                                                               ,'CODIGO_PERSONAL'
                                                                               ,l_Item);
      l_Trama_Dj1(l_Item).Rut_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DJ1'
                                                                            ,'RUT_VENDEDOR'
                                                                            ,l_Item);
      l_Trama_Dj1(l_Item).Dv_Rut_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'DJ1'
                                                                               ,'DV_RUT_VENDEDOR'
                                                                               ,l_Item);

      l_Trama_Dj1(l_Item).Identi_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'DJ1'
                                                                               ,'IDENTI_VENDEDOR'
                                                                               ,l_Item);
      l_Trama_Dj1(l_Item).Precio_Lista := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DJ1'
                                                                            ,'PRECIO_LISTA'
                                                                            ,l_Item);
      l_Trama_Dj1(l_Item).Decimal_Plista := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'DJ1'
                                                                                      ,'DECIMAL_PLISTA'
                                                                                      ,l_Item)
                                                   ,'-'
                                                   ,'0');
      l_Trama_Dj1(l_Item).Precio_Lista := To_Number(l_Trama_Dj1(l_Item).Precio_Lista || '.' || l_Trama_Dj1(l_Item).Decimal_Plista
                                                   ,'999999999999.9999');

    END LOOP;
    RETURN l_Trama_Dj1;
  END;

  FUNCTION Carga_Trama_Dl(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dl IS
    l_Trama_Dl Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dl;
  BEGIN
    l_Trama_Dl.Tipo_Movimiento_Padre   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DL'
                                                                            ,'TIPO_MOVIMIENTO_PADRE');
    l_Trama_Dl.Tipo_Movimiento_Hijo    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DL'
                                                                            ,'TIPO_MOVIMIENTO_HIJO');
    l_Trama_Dl.Folio                   := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DL'
                                                                                 ,'FOLIO'));
    l_Trama_Dl.Numero_Pedido           := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DL'
                                                                                 ,'NUMERO_PEDIDO'));
    l_Trama_Dl.Guia_Electronica        := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DL'
                                                                                 ,'GUIA_ELECTRONICA'));
    l_Trama_Dl.Guia_Despacho           := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DL'
                                                                                 ,'GUIA_DESPACHO'));
    l_Trama_Dl.Tipo_Guia_Despacho      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DL'
                                                                            ,'TIPO_GUIA_DESPACHO');
    l_Trama_Dl.Accion_Sobre_Existencia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DL'
                                                                            ,'ACCION_SOBRE_EXISTENCIA');
    l_Trama_Dl.Numero_Folio_Original   := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DL'
                                                                                 ,'NUMERO_FOLIO_ORIGINAL'));
    l_Trama_Dl.Fecha_Folio_Original    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DL'
                                                                            ,'FECHA_FOLIO_ORIGINAL');
    l_Trama_Dl.Codigo_Local_Socofar    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DL'
                                                                            ,'CODIGO_LOCAL_SOCOFAR');
    l_Trama_Dl.Numero_Reclamo          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DL'
                                                                            ,'NUMERO_RECLAMO');
    l_Trama_Dl.Fecha_Reclamo           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DL'
                                                                            ,'FECHA_RECLAMO');
    l_Trama_Dl.Dfi_Numero_Asignacion   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DL'
                                                                            ,'DFI_NUMERO_ASIGNACION');
    l_Trama_Dl.Matricula_Bulto         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DL'
                                                                            ,'MATRICULA_BULTO');
    l_Trama_Dl.Monto                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DL'
                                                                            ,'MONTO');
    l_Trama_Dl.Decimal_Monto           := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'DL'
                                                                                    ,'DECIMAL_MONTO')
                                                 ,'-'
                                                 ,'0');
    l_Trama_Dl.Monto                   := To_Number(l_Trama_Dl.Monto || '.' || l_Trama_Dl.Decimal_Monto
                                                   ,'999999999999.9999');

    l_Trama_Dl.Identi_Proveedor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'DL'
                                                                     ,'IDENTI_PROVEEDOR');
    -----
    l_Trama_Dl.Rut_Proveedor := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                  ,'DL'
                                                                  ,'RUT_PROVEEDOR');
    -----
    l_Trama_Dl.Sucursal_Proveedor   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'DL'
                                                                         ,'SUCURSAL_PROVEEDOR');
    l_Trama_Dl.Sello_Seguro_Uno     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'DL'
                                                                         ,'SELLO_SEGURO_UNO');
    l_Trama_Dl.Sello_Seguro_Dos     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'DL'
                                                                         ,'SELLO_SEGURO_DOS');
    l_Trama_Dl.Registro_Electronico := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'DL'
                                                                         ,'REGISTRO_ELECTRONICO');

    --INI JAGC 20250414 ORIGEN FGI
    l_Trama_Dl.FOLIO_INGRESO        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DL'
                                                                            ,'FOLIO_INGRESO');
    --FIN JAGC 20250414 ORIGEN FGI
       
    l_Trama_Dl.Cantidad_Productos   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'DL'
                                                                         ,'CANTIDAD_PRODUCTOS');
    l_Trama_Dl.Subtrama_Dl1         := Carga_Trama_Dl1(p_Cuerpo_Tx
                                                      ,l_Trama_Dl.Cantidad_Productos);
    RETURN l_Trama_Dl;
  END;

  FUNCTION Carga_Trama_Dl1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dl1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Dl1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dl1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Dl1(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'DL1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item);
      l_Trama_Dl1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'DL1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
      l_Trama_Dl1(l_Item).Motivo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'DL1'
                                                                      ,'MOTIVO'
                                                                      ,l_Item);
      l_Trama_Dl1(l_Item).Precio_Final := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DL1'
                                                                            ,'PRECIO_FINAL'
                                                                            ,l_Item);

      l_Trama_Dl1(l_Item).Decimal_Pfinal := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'DL1'
                                                                                      ,'DECIMAL_PFINAL'
                                                                                      ,l_Item)
                                                   ,'-'
                                                   ,'0');
      l_Trama_Dl1(l_Item).Precio_Final := To_Number(l_Trama_Dl1(l_Item).Precio_Final || '.' || l_Trama_Dl1(l_Item).Decimal_Pfinal
                                                   ,'999999999999.9999');

      l_Trama_Dl1(l_Item).Costo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'DL1'
                                                                     ,'COSTO'
                                                                     ,l_Item);
      l_Trama_Dl1(l_Item).Decimal_Costo := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'DL1'
                                                                                     ,'DECIMAL_COSTO'
                                                                                     ,l_Item)
                                                  ,'-'
                                                  ,'0');
      l_Trama_Dl1(l_Item).Costo := To_Number(l_Trama_Dl1(l_Item).Costo || '.' || l_Trama_Dl1(l_Item).Decimal_Costo
                                            ,'999999999999.9999');

      l_Trama_Dl1(l_Item).Codigo_Personal := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'DL1'
                                                                               ,'CODIGO_PERSONAL'
                                                                               ,l_Item);
      l_Trama_Dl1(l_Item).Identi_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'DL1'
                                                                               ,'IDENTI_VENDEDOR'
                                                                               ,l_Item);
      ------
      l_Trama_Dl1(l_Item).Rut_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DL1'
                                                                            ,'RUT_VENDEDOR'
                                                                            ,l_Item);
      l_Trama_Dl1(l_Item).Dv_Rut_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'DL1'
                                                                               ,'DV_RUT_VENDEDOR'
                                                                               ,l_Item);
      ------
      l_Trama_Dl1(l_Item).Precio_Lista := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DL1'
                                                                            ,'PRECIO_LISTA'
                                                                            ,l_Item);

      l_Trama_Dl1(l_Item).Decimal_Plista := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'DL1'
                                                                                      ,'DECIMAL_PLISTA'
                                                                                      ,l_Item)
                                                   ,'-'
                                                   ,'0');
      l_Trama_Dl1(l_Item).Precio_Lista := To_Number(l_Trama_Dl1(l_Item).Precio_Lista || '.' || l_Trama_Dl1(l_Item).Decimal_Plista
                                                   ,'999999999999.9999');
                                                   
      -- IDHC origen NLG
      l_Trama_Dl1(l_Item).Numero_Item := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'DL1'
                                                                           ,'NUMERO_ITEM'
                                                                           ,l_Item);
      -- fin IDHC

    END LOOP;
    RETURN l_Trama_Dl1;
  END;

  FUNCTION Carga_Trama_Do(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Do IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Do Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Do;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'DO'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Do(l_Item).Numero_Orden_Trabajo := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                        ,'DO'
                                                                                        ,'NUMERO_ORDEN_TRABAJO'
                                                                                        ,l_Item));
      l_Trama_Do(l_Item).Codigo_Respuesta := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'DO'
                                                                               ,'CODIGO_RESPUESTA'
                                                                               ,l_Item);
      l_Trama_Do(l_Item).Glosa_Respuesta := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'DO'
                                                                              ,'GLOSA_RESPUESTA'
                                                                              ,l_Item);
      l_Trama_Do(l_Item).Secuencia_Receta := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'DO'
                                                                               ,'SECUENCIA_RECETA'
                                                                               ,l_Item);
      l_Trama_Do(l_Item).Fecha_Hora_Estado := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DO'
                                                                                ,'FECHA_HORA_ESTADO'
                                                                                ,l_Item);
      l_Trama_Do(l_Item).Estado := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'DO'
                                                                     ,'ESTADO'
                                                                     ,l_Item);
      l_Trama_Do(l_Item).Numero_Rp := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'DO'
                                                                        ,'NUMERO_RP'
                                                                        ,l_Item);
      l_Trama_Do(l_Item).Fecha_Vencimiento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DO'
                                                                                ,'FECHA_VENCIMIENTO'
                                                                                ,l_Item);
      l_Trama_Do(l_Item).Monto_Abono := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'DO'
                                                                          ,'MONTO_ABONO'
                                                                          ,l_Item);
      l_Trama_Do(l_Item).Valor_Total := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'DO'
                                                                          ,'VALOR_TOTAL'
                                                                          ,l_Item);
      l_Trama_Do(l_Item).Costo_Total := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'DO'
                                                                          ,'COSTO_TOTAL'
                                                                          ,l_Item);
      l_Trama_Do(l_Item).Retiro := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'DO'
                                                                     ,'RETIRO'
                                                                     ,l_Item);
      l_Trama_Do(l_Item).Local := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'DO'
                                                                    ,'LOCAL'
                                                                    ,l_Item);
      l_Trama_Do(l_Item).Tipo_Recepcion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DO'
                                                                             ,'TIPO_RECEPCION'
                                                                             ,l_Item);
      l_Trama_Do(l_Item).Total_Envases := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DO'
                                                                            ,'TOTAL_ENVASES'
                                                                            ,l_Item);
    END LOOP;
    RETURN l_Trama_Do;
  END;

  FUNCTION Carga_Trama_Dp(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp IS
    l_Trama_Dp Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp;
  BEGIN
    l_Trama_Dp.Apellido_Paterno    := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DP'
                                                                             ,'APELLIDO_PATERNO'));
    l_Trama_Dp.Apellido_Materno    := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DP'
                                                                             ,'APELLIDO_MATERNO'));
    l_Trama_Dp.Nombres             := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DP'
                                                                             ,'NOMBRES'));
    l_Trama_Dp.Segundo_Nombre      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'DP'
                                                                        ,'SEGUNDO_NOMBRE');
    l_Trama_Dp.Sexo                := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'DP'
                                                                        ,'SEXO');
    l_Trama_Dp.Fecha_Nacimiento    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'DP'
                                                                        ,'FECHA_NACIMIENTO');
    l_Trama_Dp.Direccion           := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'DP'
                                                                        ,'DIRECCION');
    l_Trama_Dp.Comuna              := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'DP'
                                                                        ,'COMUNA');
    l_Trama_Dp.Ciudad              := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'DP'
                                                                        ,'CIUDAD');
    l_Trama_Dp.Telefono_Particular := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'DP'
                                                                        ,'TELEFONO_PARTICULAR');
    l_Trama_Dp.Telefono_Celular    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'DP'
                                                                        ,'TELEFONO_CELULAR');

    l_Trama_Dp.Telefono_Particularc := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'DP'
                                                                         ,'TELEFONO_PARTICULARC');
    l_Trama_Dp.Telefono_Celularc    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'DP'
                                                                         ,'TELEFONO_CELULARC');

    l_Trama_Dp.Inscrito_Mas_Cruz_Verde  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DP'
                                                                             ,'INSCRITO_MAS_CRUZ_VERDE');
    l_Trama_Dp.Folio_Tarjeta_Mcv        := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DP'
                                                                             ,'FOLIO_TARJETA_MCV');
    l_Trama_Dp.Email                    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DP'
                                                                             ,'EMAIL');
    l_Trama_Dp.Fecha_Hora_Actualizacion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DP'
                                                                             ,'FECHA_HORA_ACTUALIZACION');
    l_Trama_Dp.Tipo_Creacion            := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DP'
                                                                             ,'TIPO_CREACION');
    l_Trama_Dp.Fecha_Hora_Ultima_Venta  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DP'
                                                                             ,'FECHA_HORA_ULTIMA_VENTA');
    l_Trama_Dp.Local_Ultima_Venta       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DP'
                                                                             ,'LOCAL_ULTIMA_VENTA');
    l_Trama_Dp.Codigo_Pais              := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DP'
                                                                             ,'CODIGO_PAIS');
    l_Trama_Dp.Codigo_Region            := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DP'
                                                                             ,'CODIGO_REGION');
    l_Trama_Dp.Institucion_Salud        := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DP'
                                                                             ,'INSTITUCION_SALUD');
    l_Trama_Dp.Monto_Acumulado_Club     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DP'
                                                                             ,'MONTO_ACUMULADO_CLUB');
    --//--------------------------------------------------------------------------\\
    --// CBR 12/08/2020 02:01                                                     \\
    --// Desarrollo para resolutor Ecuador                                        \\
    --// con nuevo origen transaccion 'DEC'                                       \\
    --//-----------------------------------------------------------------Inicio---\\
    l_Trama_Dp.Decimal_Acum_Club := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'DP'
                                                                              ,'DECIMAL_ACUM_CLUB')
                                           ,'-'
                                           ,'0');
    IF l_Trama_Dp.Monto_Acumulado_Club <> -1 AND
       l_Trama_Dp.Decimal_Acum_Club <> '-' THEN
      l_Trama_Dp.Monto_Acumulado_Club := To_Number(l_Trama_Dp.Monto_Acumulado_Club || '.' || l_Trama_Dp.Decimal_Acum_Club
                                                  ,'999999999999.9999');
    END IF;

    --//-----------------------------------------------------------------Termino--\\
    
    --INI JAGC 20240909 NECESIDADES 'NEC'
    l_Trama_Dp.Estado_Civil       := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DP'
                                                                             ,'ESTADO_CIVIL');     
    l_Trama_Dp.Nro_Depto_Casa       := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DP'
                                                                             ,'NRO_DEPTO_CASA');    
    l_Trama_Dp.Medios_Notificacion       := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DP'
                                                                             ,'MEDIOS_NOTIFICACION');
    l_Trama_Dp.Estado       := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DP'
                                                                             ,'ESTADO');
    l_Trama_Dp.Fecha_Inscripcion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DP'
                                                                             ,'FECHA_INSCRIPCION');
    l_Trama_Dp.Canal       := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DP'
                                                                             ,'CANAL');
    l_Trama_Dp.Nombre_Vendedor       := SUBSTR(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DP'
                                                                             ,'NOMBRE_VENDEDOR'), 1, 30);
    --FIN JAGC 20240909 NECESIDADES 'NEC'
    
    l_Trama_Dp.Lista_Atributos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'DP'
                                                                    ,'LISTA_ATRIBUTOS');
    l_Trama_Dp.Lista_Grupos    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'DP'
                                                                    ,'LISTA_GRUPOS');
    /*
    l_Trama_Dp.Lista_Programas          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DP'
                                                                             ,'LISTA_PROGRAMAS');
    */
    l_Trama_Dp.Subtrama_Dp1 := Carga_Trama_Dp1(p_Cuerpo_Tx
                                              ,l_Trama_Dp.Lista_Atributos);
    l_Trama_Dp.Subtrama_Dp2 := Carga_Trama_Dp2(p_Cuerpo_Tx
                                              ,l_Trama_Dp.Lista_Grupos);
    /*
    l_Trama_Dp.Subtrama_Dp3             := Carga_Trama_Dp3(p_Cuerpo_Tx
                                                          ,l_Trama_Dp.Lista_Programas);
    */
    RETURN l_Trama_Dp;
  END;

  FUNCTION Carga_Trama_Dp1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dp1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Dp1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dp1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Dp1(l_Item).Atributo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'DP1'
                                                                        ,'ATRIBUTO'
                                                                        ,l_Item);
    END LOOP;
    RETURN l_Trama_Dp1;
  END;

  FUNCTION Carga_Trama_Dp2(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dp2 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Dp2 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dp2;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Dp2(l_Item).Id := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                  ,'DP4'
                                                                  ,'ID'
                                                                  ,l_Item);
      l_Trama_Dp2(l_Item).Id_Grupo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'DP4'
                                                                        ,'ID_GRUPO'
                                                                        ,l_Item);
      l_Trama_Dp2(l_Item).Nombre_Grupo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DP4'
                                                                            ,'NOMBRE_GRUPO'
                                                                            ,l_Item);
      l_Trama_Dp2(l_Item).Valor_Grupo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'DP4'
                                                                           ,'VALOR_GRUPO'
                                                                           ,l_Item);
      l_Trama_Dp2(l_Item).Fecha_Creacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'DP4'
                                                                              ,'FECHA_CREACION'
                                                                              ,l_Item);
      l_Trama_Dp2(l_Item).Fecha_Actualizacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'DP4'
                                                                                   ,'FECHA_ACTUALIZACION'
                                                                                   ,l_Item);
      l_Trama_Dp2(l_Item).Habilitado := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'DP4'
                                                                          ,'HABILITADO'
                                                                          ,l_Item);
      l_Trama_Dp2(l_Item).Eliminado := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'DP4'
                                                                         ,'ELIMINADO'
                                                                         ,l_Item);
    END LOOP;
    RETURN l_Trama_Dp2;
  END;

  FUNCTION Carga_Trama_Dp3(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dp3 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Item2     NUMBER;
    l_Tot_Reg2  NUMBER;
    l_Trama_Dp3 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dp3;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Dp3(l_Item).Id_Pro := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'DP3'
                                                                      ,'ID_PRO'
                                                                      ,l_Item);
      l_Trama_Dp3(l_Item).Nombre_Pro := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'DP3'
                                                                          ,'NOMBRE_PRO'
                                                                          ,l_Item);
      l_Trama_Dp3(l_Item).Descripcion_Pro := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'DP3'
                                                                               ,'DESCRIPCION_PRO'
                                                                               ,l_Item);
      l_Trama_Dp3(l_Item).Fecha_Creacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'DP3'
                                                                              ,'FECHA_CREACION'
                                                                              ,l_Item);
      l_Trama_Dp3(l_Item).Fecha_Actualizacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'DP3'
                                                                                   ,'FECHA_ACTUALIZACION'
                                                                                   ,l_Item);
      l_Trama_Dp3(l_Item).Habilitado := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'DP3'
                                                                          ,'HABILITADO'
                                                                          ,l_Item);
      l_Trama_Dp3(l_Item).Eliminado := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'DP3'
                                                                         ,'ELIMINADO'
                                                                         ,l_Item);
      l_Trama_Dp3(l_Item).Sistema := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'DP3'
                                                                       ,'SISTEMA'
                                                                       ,l_Item);
      -------------------
      l_Trama_Dp3(l_Item).Id_Currency := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'DP5'
                                                                           ,'ID_CURRENCY'
                                                                           ,l_Item);

      l_Trama_Dp3(l_Item).Nombre_Currency := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'DP5'
                                                                               ,'NOMBRE_CURRENCY'
                                                                               ,l_Item);
      l_Trama_Dp3(l_Item).Nombre_Corto_Currency := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'DP5'
                                                                                     ,'NOMBRE_CORTO_CURRENCY'
                                                                                     ,l_Item);
      l_Trama_Dp3(l_Item).Descripcion_Currency := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'DP5'
                                                                                    ,'DESCRIPCION_CURRENCY'
                                                                                    ,l_Item);
      l_Trama_Dp3(l_Item).Fecha_Creacion_Currency := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                       ,'DP5'
                                                                                       ,'FECHA_CREACION_CURRENCY'
                                                                                       ,l_Item);
      l_Trama_Dp3(l_Item).Eliminado_Currency := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DP5'
                                                                                  ,'ELIMINADO_CURRENCY'
                                                                                  ,l_Item);
      l_Trama_Dp3(l_Item).Estado_Currency := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'DP5'
                                                                               ,'ESTADO_CURRENCY'
                                                                               ,l_Item);
    END LOOP;
    RETURN l_Trama_Dp3;
  END;

  /*
    FUNCTION Carga_Trama_Dp9(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp IS
      l_Trama_Dp9 Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp;
    BEGIN
      l_Trama_Dp9.Apellido_Paterno         := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DP9'
                                                                                ,'APELLIDO_PATERNO'));
      l_Trama_Dp9.Apellido_Materno         := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DP9'
                                                                                ,'APELLIDO_MATERNO'));
      l_Trama_Dp9.Nombres                  := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DP9'
                                                                                ,'NOMBRES'));
      l_Trama_Dp9.Sexo                     := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DP9'
                                                                                ,'SEXO');
      l_Trama_Dp9.Fecha_Nacimiento         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DP9'
                                                                                ,'FECHA_NACIMIENTO');
      l_Trama_Dp9.Direccion                := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DP9'
                                                                                ,'DIRECCION');
      l_Trama_Dp9.Comuna                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DP9'
                                                                                ,'COMUNA');
      l_Trama_Dp9.Ciudad                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DP9'
                                                                                ,'CIUDAD');
      l_Trama_Dp9.Telefono_Particular      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DP9'
                                                                                ,'TELEFONO_PARTICULAR');
      l_Trama_Dp9.Telefono_Celular         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DP9'
                                                                                ,'TELEFONO_CELULAR');
      l_Trama_Dp9.Inscrito_Mas_Cruz_Verde  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DP9'
                                                                                ,'INSCRITO_MAS_CRUZ_VERDE');
      l_Trama_Dp9.Folio_Tarjeta_Mcv        := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DP9'
                                                                                ,'FOLIO_TARJETA_MCV');
      l_Trama_Dp9.Email                    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DP9'
                                                                                ,'EMAIL');
      l_Trama_Dp9.Fecha_Hora_Actualizacion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DP9'
                                                                                ,'FECHA_HORA_ACTUALIZACION');
      l_Trama_Dp9.Tipo_Creacion            := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DP9'
                                                                                ,'TIPO_CREACION');
      l_Trama_Dp9.Fecha_Hora_Ultima_Venta  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DP9'
                                                                                ,'FECHA_HORA_ULTIMA_VENTA');
      l_Trama_Dp9.Local_Ultima_Venta       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DP9'
                                                                                ,'LOCAL_ULTIMA_VENTA');
      RETURN l_Trama_Dp9;
    END;
  */

  FUNCTION Carga_Trama_Dpu(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dpu IS
    l_Trama_Dpu Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dpu;
  BEGIN
    l_Trama_Dpu.Rut_Beneficiario    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'DPU'
                                                                         ,'RUT_BENEFICIARIO');
    l_Trama_Dpu.Dv_Rut_Beneficiario := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'DPU'
                                                                         ,'DV_RUT_BENEFICIARIO');
    l_Trama_Dpu.Fecha_Inicio        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'DPU'
                                                                         ,'FECHA_INICIO');
    l_Trama_Dpu.Fecha_Termino       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'DPU'
                                                                         ,'FECHA_TERMINO');
    RETURN l_Trama_Dpu;
  END;

  FUNCTION Carga_Trama_Dr(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dr IS
    l_Trama_Dr Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dr;
  BEGIN
    l_Trama_Dr.Correlativo_Tx                := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'CORRELATIVO_TX');
    l_Trama_Dr.Tipo_Movimiento_Padre         := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'TIPO_MOVIMIENTO_PADRE');
    l_Trama_Dr.Fecha                         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'FECHA');
    l_Trama_Dr.Hora_Recaudacion              := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'HORA_RECAUDACION');
    l_Trama_Dr.Secuencia_b                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'SECUENCIA_B');
    l_Trama_Dr.Numero_Cuenta                 := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                       ,'DR'
                                                                                       ,'NUMERO_CUENTA'));
    l_Trama_Dr.Codigo_Autorizacion           := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'CODIGO_AUTORIZACION');
    l_Trama_Dr.Ot                            := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'OT');
    l_Trama_Dr.Venta_Relacionada             := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'VENTA_RELACIONADA');
    l_Trama_Dr.Local_Relacionado             := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'LOCAL_RELACIONADO');
    l_Trama_Dr.Codigo_Servicio               := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'CODIGO_SERVICIO');
    l_Trama_Dr.Local                         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'LOCAL');
    l_Trama_Dr.Numero_Pos                    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'NUMERO_POS');
    l_Trama_Dr.Destino                       := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'DESTINO');
    l_Trama_Dr.Sistema                       := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'SISTEMA');
    l_Trama_Dr.Funcion                       := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'FUNCION');
    l_Trama_Dr.Secuencia_c                   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'SECUENCIA_C');
    l_Trama_Dr.Fecha_Transaccion             := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'FECHA_TRANSACCION');
    l_Trama_Dr.Correlativo                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'CORRELATIVO');
    l_Trama_Dr.Numero_Trama                  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'NUMERO_TRAMA');
    l_Trama_Dr.Codigo_Transaccion            := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'CODIGO_TRANSACCION');
    l_Trama_Dr.Cuadra_Transaccion            := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'CUADRA_TRANSACCION');
    l_Trama_Dr.Documento_Liquidacion_Pago    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'DOCUMENTO_LIQUIDACION_PAGO');
    l_Trama_Dr.Documento_Liquidacion_Empresa := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'DOCUMENTO_LIQUIDACION_EMPRESA');
    l_Trama_Dr.Codigo_Autorizacion_Externo   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'CODIGO_AUTORIZACION_EXTERNO');
    l_Trama_Dr.Transaccion_Manual            := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'TRANSACCION_MANUAL');
    l_Trama_Dr.Id_Empresa                    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'ID_EMPRESA');
    l_Trama_Dr.Fecha_Inicio_Tx               := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'FECHA_INICIO_TX');
    l_Trama_Dr.Fecha_Cierre_Tx               := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'FECHA_CIERRE_TX');
    l_Trama_Dr.Numero_Tx_Comercio            := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'NUMERO_TX_COMERCIO');
    l_Trama_Dr.Registro_Recepcion_1          := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'REGISTRO_RECEPCION_1');
    l_Trama_Dr.Documentos_Emitidos           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR'
                                                                                  ,'DOCUMENTOS_EMITIDOS');
    l_Trama_Dr.Subtrama_Dr1                  := Carga_Trama_Dr1(p_Cuerpo_Tx
                                                               ,l_Trama_Dr.Documentos_Emitidos);
    RETURN l_Trama_Dr;
  END;

  FUNCTION Carga_Trama_Dr1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dr1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Dr1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dr1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Dr1(l_Item).Secuencia_b := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'DR1'
                                                                           ,'SECUENCIA_B'
                                                                           ,l_Item);
      l_Trama_Dr1(l_Item).Tipo_Movimiento_Hijo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'DR1'
                                                                                    ,'TIPO_MOVIMIENTO_HIJO'
                                                                                    ,l_Item);
      l_Trama_Dr1(l_Item).Institucion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'DR1'
                                                                           ,'INSTITUCION'
                                                                           ,l_Item);

      l_Trama_Dr1(l_Item).Ruc_Institucion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'DR1'
                                                                           ,'RUC_INSTITUCION'
                                                                           ,l_Item);    
                                                                           
      l_Trama_Dr1(l_Item).Numero_Asignacion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DR1'
                                                                                 ,'NUMERO_ASIGNACION'
                                                                                 ,l_Item);
      l_Trama_Dr1(l_Item).Anulado := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'DR1'
                                                                       ,'ANULADO'
                                                                       ,l_Item);
      l_Trama_Dr1(l_Item).Folio := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'DR1'
                                                                          ,'FOLIO'
                                                                          ,l_Item));
      l_Trama_Dr1(l_Item).Tipo_Dicc := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'DR1'
                                                                         ,'TIPO_DICC'
                                                                         ,l_Item);
      l_Trama_Dr1(l_Item).Folio_Dicc := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'DR1'
                                                                          ,'FOLIO_DICC'
                                                                          ,l_Item);
      l_Trama_Dr1(l_Item).Total_Iva_Incluido := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DR1'
                                                                                  ,'TOTAL_IVA_INCLUIDO'
                                                                                  ,l_Item);
      l_Trama_Dr1(l_Item).Decimal_Total := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'DR1'
                                                                                     ,'DECIMAL_TOTAL'
                                                                                     ,l_Item)
                                                  ,'-'
                                                  ,'0');
      l_Trama_Dr1(l_Item).Total_Iva_Incluido := To_Number(l_Trama_Dr1(l_Item).Total_Iva_Incluido || '.' || l_Trama_Dr1(l_Item).Decimal_Total
                                                         ,'999999999999.9999');

      l_Trama_Dr1(l_Item).Iva := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'DR1'
                                                                   ,'IVA'
                                                                   ,l_Item);
      l_Trama_Dr1(l_Item).Decimal_Iva := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'DR1'
                                                                                   ,'DECIMAL_IVA'
                                                                                   ,l_Item)
                                                ,'-'
                                                ,'0');
      l_Trama_Dr1(l_Item).Iva := To_Number(l_Trama_Dr1(l_Item).Iva || '.' || l_Trama_Dr1(l_Item).Decimal_Iva
                                          ,'999999999999.9999');

      l_Trama_Dr1(l_Item).Signo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'DR1'
                                                                     ,'SIGNO'
                                                                     ,l_Item);
      l_Trama_Dr1(l_Item).Puntos_Asignados := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DR1'
                                                                                ,'PUNTOS_ASIGNADOS'
                                                                                ,l_Item);
      l_Trama_Dr1(l_Item).Tipo_Distribucion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DR1'
                                                                                 ,'TIPO_DISTRIBUCION'
                                                                                 ,l_Item);
      l_Trama_Dr1(l_Item).Campana := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'DR1'
                                                                       ,'CAMPANA'
                                                                       ,l_Item);
      l_Trama_Dr1(l_Item).Secuencia_Financiamiento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                        ,'DR1'
                                                                                        ,'SECUENCIA_FINANCIAMIENTO'
                                                                                        ,l_Item);
      l_Trama_Dr1(l_Item).Documento_Fiscal := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DR1'
                                                                                ,'DOCUMENTO_FISCAL'
                                                                                ,l_Item);
    END LOOP;
    RETURN l_Trama_Dr1;
  END;

  FUNCTION Carga_Trama_Ds(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ds IS
    l_Trama_Ds Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ds;
  BEGIN
    l_Trama_Ds.Tipo_Movimiento_Padre   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DS'
                                                                            ,'TIPO_MOVIMIENTO_PADRE');
    l_Trama_Ds.Tipo_Movimiento_Hijo    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DS'
                                                                            ,'TIPO_MOVIMIENTO_HIJO');
    l_Trama_Ds.Folio                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DS'
                                                                            ,'FOLIO');
    l_Trama_Ds.Numero_Pedido           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DS'
                                                                            ,'NUMERO_PEDIDO');
    l_Trama_Ds.Guia_Despacho           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DS'
                                                                            ,'GUIA_DESPACHO');
    l_Trama_Ds.Tipo_Guia_Despacho      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DS'
                                                                            ,'TIPO_GUIA_DESPACHO');
    l_Trama_Ds.Accion_Sobre_Existencia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DS'
                                                                            ,'ACCION_SOBRE_EXISTENCIA');
    l_Trama_Ds.Cantidad_Productos      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'DS'
                                                                            ,'CANTIDAD_PRODUCTOS');
    l_Trama_Ds.Subtrama_Ds1            := Carga_Trama_Ds1(p_Cuerpo_Tx
                                                         ,l_Trama_Ds.Cantidad_Productos);
    RETURN l_Trama_Ds;
  END;

  FUNCTION Carga_Trama_Ds1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ds1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Ds1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ds1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Ds1(l_Item).Guia_Electronica := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DS1'
                                                                                ,'GUIA_ELECTRONICA'
                                                                                ,l_Item);
      l_Trama_Ds1(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'DS1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item);
      l_Trama_Ds1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'DS1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
    END LOOP;
    RETURN l_Trama_Ds1;
  END;

  FUNCTION Carga_Trama_Dv(p_Trama_Pos IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Hpo
                         ,p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv IS
    l_Trama_Dv Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv;
  BEGIN
    l_Trama_Dv.Correlativo_Tx               := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DV'
                                                                                 ,'CORRELATIVO_TX');
    l_Trama_Dv.Tipo_Tx                      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DV'
                                                                                 ,'TIPO_TX');
    l_Trama_Dv.Tipo_Movimiento_Padre        := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DV'
                                                                                 ,'TIPO_MOVIMIENTO_PADRE');
    l_Trama_Dv.Fecha                        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DV'
                                                                                 ,'FECHA');
    l_Trama_Dv.Hora_Venta                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DV'
                                                                                 ,'HORA_VENTA');
    l_Trama_Dv.Numero_Cotizacion            := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DV'
                                                                                 ,'NUMERO_COTIZACION');
    l_Trama_Dv.Pin_Transaccion              := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DV'
                                                                                 ,'PIN_TRANSACCION');
    l_Trama_Dv.Numero_Preventa              := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DV'
                                                                                 ,'NUMERO_PREVENTA');
    l_Trama_Dv.Correlativo_Tx_Asociado      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DV'
                                                                                 ,'CORRELATIVO_TX_ASOCIADO');
    l_Trama_Dv.Local                        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DV'
                                                                                 ,'LOCAL');
    l_Trama_Dv.Codigo_Agente_Desp_Domicilio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DV'
                                                                                 ,'CODIGO_AGENTE_DESP_DOMICILIO');
    --//--------------------------------------------------------------------------\\
    l_Trama_Dv.Identi_Agente_Despacho := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'DV'
                                                                           ,'IDENTI_AGENTE_DESPACHO');
    --//--------------------------------------------------------------------------\\
    l_Trama_Dv.Rut_Agente_Despacho_Domicilio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DV'
                                                                                  ,'RUT_AGENTE_DESPACHO_DOMICILIO');
    l_Trama_Dv.Dv_Rut_Agente_Desp_Domicilio  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DV'
                                                                                  ,'DV_RUT_AGENTE_DESP_DOMICILIO');
    l_Trama_Dv.Numero_Service_Request_Ddo    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DV'
                                                                                  ,'NUMERO_SERVICE_REQUEST_DDO');
    l_Trama_Dv.Ot                            := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DV'
                                                                                  ,'OT');
    l_Trama_Dv.Recaudacion_Relacionada       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DV'
                                                                                  ,'RECAUDACION_RELACIONADA');
    l_Trama_Dv.Cuadra_Transaccion            := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DV'
                                                                                  ,'CUADRA_TRANSACCION');
    l_Trama_Dv.Documento_Liquidacion_Pago    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DV'
                                                                                  ,'DOCUMENTO_LIQUIDACION_PAGO');
    l_Trama_Dv.Documento_Liquidacion_Empresa := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DV'
                                                                                  ,'DOCUMENTO_LIQUIDACION_EMPRESA');
    l_Trama_Dv.Codigo_Autorizacion_Externo   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DV'
                                                                                  ,'CODIGO_AUTORIZACION_EXTERNO');
    --//--------------------------------------------------------------------------\\
    l_Trama_Dv.Identi_Empresa := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'DV'
                                                                   ,'IDENTI_EMPRESA');
    --//--------------------------------------------------------------------------\\
    l_Trama_Dv.Rut_Empresa        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'DV'
                                                                       ,'RUT_EMPRESA');
    l_Trama_Dv.Transaccion_Manual := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'DV'
                                                                       ,'TRANSACCION_MANUAL');
    l_Trama_Dv.Movimiento_Enlinea := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'DV'
                                                                       ,'MOVIMIENTO_ENLINEA');
    l_Trama_Dv.Supervisor         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'DV'
                                                                       ,'SUPERVISOR');
    --//--------------------------------------------------------------------------\\
    l_Trama_Dv.Identi_Supervisor := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'DV'
                                                                      ,'IDENTI_SUPERVISOR');
    --//--------------------------------------------------------------------------\\
    l_Trama_Dv.Rut_Supervisor  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'DV'
                                                                    ,'RUT_SUPERVISOR');
    l_Trama_Dv.Tipo_Deducible  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'DV'
                                                                    ,'TIPO_DEDUCIBLE');
    l_Trama_Dv.Monto_Deducible := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'DV'
                                                                    ,'MONTO_DEDUCIBLE');
    --//--------------------------------------------------------------------------\\
    l_Trama_Dv.Decimal_Monto_Deducible := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'DV'
                                                                                    ,'DECIMAL_MONTO_DEDUCIBLE')
                                                 ,'-'
                                                 ,'0');
    --//--------------------------------------------------------------------------\\
    l_Trama_Dv.Monto_Deducible := To_Number(l_Trama_Dv.Monto_Deducible || '.' || l_Trama_Dv.Decimal_Monto_Deducible
                                           ,'999999999999.9999');

    l_Trama_Dv.Valor_Moneda          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'DV'
                                                                          ,'VALOR_MONEDA');
    l_Trama_Dv.Tipo_Moneda           := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'DV'
                                                                          ,'TIPO_MONEDA');
    l_Trama_Dv.Numero_Liquidacion    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'DV'
                                                                          ,'NUMERO_LIQUIDACION');
    l_Trama_Dv.Indicadores_Tx        := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'DV'
                                                                          ,'INDICADORES_TX');
    l_Trama_Dv.Documento_Electronico := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'DV'
                                                                          ,'DOCUMENTO_ELECTRONICO');
    l_Trama_Dv.Fecha_Inicio_Tx       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'DV'
                                                                          ,'FECHA_INICIO_TX');
    l_Trama_Dv.Fecha_Cierre_Tx       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'DV'
                                                                          ,'FECHA_CIERRE_TX');
    --//--------------------------------------------------------------------------\\
    --// CBR 07/01/2019 17:55                                                     \\
    --// desarrollo Factura Turista                                               \\
    --//-----------------------------------------------------------------Inicio---\\
    l_Trama_Dv.Factura_Turista     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'DV'
                                                                        ,'FACTURA_TURISTA');
    l_Trama_Dv.Tipo_Documento_Id   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'DV'
                                                                        ,'TIPO_DOCUMENTO_ID');
    l_Trama_Dv.Numero_Documento_Id := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'DV'
                                                                             ,'NUMERO_DOCUMENTO_ID'));
    --//-----------------------------------------------------------------Termino--\\
    --//--------------------------------------------------------------------------\\
    --// CBR 28/08/2020 11:04                                                     \\
    --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
    --//-----------------------------------------------------------------Inicio---\\

    l_Trama_Dv.Clave_Acceso       := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'DV'
                                                                       ,'CLAVE_ACCESO');
    l_Trama_Dv.Numero_Comprobante := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'DV'
                                                                       ,'NUMERO_COMPROBANTE');
    /*
    l_Trama_Dv.Numero_Comprobante := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'DV'
                                                                       ,'TIPO_FACTURACION');
    */
    l_Trama_Dv.Cliente_Factura           := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'DV'
                                                                                   ,'CLIENTE_FACTURA'));
    l_Trama_Dv.Nombre_Cliente_Factura    := SUBSTR(TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'DV'
                                                                                   ,'NOMBRE_CLIENTE_FACTURA')),1,100);
    l_Trama_Dv.Direccion_Cliente_Factura := SUBSTR(TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'DV'
                                                                                   ,'DIRECCION_CLIENTE_FACTURA')),1,100);
    l_Trama_Dv.Correo_Electronico        := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'DV'
                                                                                   ,'CORREO_ELECTRONICO'));

    l_Trama_Dv.Serie_Sri         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'DV'
                                                                      ,'SERIE_SRI');
    l_Trama_Dv.Numero_Resolucion := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'DV'
                                                                           ,'NUMERO_RESOLUCION'));
    l_Trama_Dv.Agente_Retencion  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'DV'
                                                                      ,'AGENTE_RETENCION');
    l_Trama_Dv.Microempresa      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'DV'
                                                                      ,'MICROEMPRESA');
    l_Trama_Dv.Motivo            := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'DV'
                                                                      ,'MOTIVO');

    l_Trama_Dv.Id_Supervisor_Externo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'DV'
                                                                          ,'ID_SUPERVISOR_EXTERNO');

    l_Trama_Dv.Canal_Transaccion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'DV'
                                                                      ,'CANAL_TRANSACCION');
                                                                      
    --INI JAGC 20240909 NECESIDADES 'NEC'  
    l_Trama_Dv.Tiene_Donacion      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'DV'
                                                                           ,'TIENE_DONACION');                             
    
    --FIN JAGC 20240909 NECESIDADES 'NEC'                                                                  
                                                                      
    --//-----------------------------------------------------------------Termino--\\
    --   FCG 04082022 DONACION MX
    --    l_Trama_Dv.Tiene_Donacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
    --                                                                   ,'DV'
    --                                                                   ,'TIENE_DONACION');

    --   FCG 13082023 Origen OMS
    l_Trama_Dv.Url_Factura := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                ,'DV'
                                                                ,'URL_FACTURA');
    l_Trama_Dv.Url_Xml     := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                ,'DV'
                                                                ,'URL_XML');
    
    --==================================================
    --Origen CON JAGC 20240529
    --==================================================
    ----------------------------------------------------                                                     
    l_Trama_Dv.Tax_Payer     := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                ,'DV'
                                                                ,'TAX_PAYER');
    ----------------------------------------------------                    
    
    --INI JAGC 20240909 NECESIDADES 'NEC'  

    --l_Trama_Dv.Folio_venta_Anulada := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
    --                                                                      ,'DV'
    --                                                                      ,'FOLIO_VENTA_ANULADA');
    l_Trama_Dv.Folio_venta_Anulada     := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                ,'DV'
                                                                ,'FOLIO_VENTA_ANULADA');
                                                                          
    l_Trama_Dv.Canal      := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'DV'
                                                                                   ,'CANAL'));                             
   
  --FIN JAGC 20240909 NECESIDADES 'NEC'                                  

    l_Trama_Dv.Documentos_Emitidos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'DV'
                                                                        ,'DOCUMENTOS_EMITIDOS');
    l_Trama_Dv.Tx_Relacionadas     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'DV'
                                                                        ,'TX_RELACIONADAS');
                                                                       
    l_Trama_Dv.Subtrama_Dv1        := Carga_Trama_Dv1(p_Trama_Pos
                                                     ,p_Cuerpo_Tx
                                                     ,l_Trama_Dv.Documentos_Emitidos);
    l_Trama_Dv.Subtrama_Dv2        := Carga_Trama_Dv2(p_Cuerpo_Tx
                                                     ,l_Trama_Dv.Tx_Relacionadas);
    RETURN l_Trama_Dv;
  END;

  FUNCTION Carga_Trama_Dvr(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dvr IS
    l_Trama_Dvr Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dvr;
  BEGIN
    l_Trama_Dvr.Tipo_Movimiento_Hijo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'DVR'
                                                                          ,'TIPO_MOVIMIENTO_HIJO');
    l_Trama_Dvr.Folio                := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'DVR'
                                                                          ,'FOLIO');
    RETURN l_Trama_Dvr;
  END;

  FUNCTION Carga_Trama_Dv1(p_Trama_Pos IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Hpo
                          ,p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dv1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    p_Iva       NUMBER;
    p_Aplicar   NUMBER := 0;
    l_Trama_Dv1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dv1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Dv1(l_Item).Secuencia_b := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'DV1'
                                                                           ,'SECUENCIA_B'
                                                                           ,l_Item);
      l_Trama_Dv1(l_Item).Tipo_Movimiento_Hijo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'DV1'
                                                                                    ,'TIPO_MOVIMIENTO_HIJO'
                                                                                    ,l_Item);
      l_Trama_Dv1(l_Item).Numero_Asignacion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DV1'
                                                                                 ,'NUMERO_ASIGNACION'
                                                                                 ,l_Item);
      l_Trama_Dv1(l_Item).Anulado := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'DV1'
                                                                       ,'ANULADO'
                                                                       ,l_Item);
      l_Trama_Dv1(l_Item).Folio := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'DV1'
                                                                          ,'FOLIO'
                                                                          ,l_Item));
      l_Trama_Dv1(l_Item).Tipo_Dicc := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'DV1'
                                                                         ,'TIPO_DICC'
                                                                         ,l_Item);
      l_Trama_Dv1(l_Item).Folio_Dicc := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'DV1'
                                                                          ,'FOLIO_DICC'
                                                                          ,l_Item);
      l_Trama_Dv1(l_Item).Total_Iva_Incluido := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'DV1'
                                                                                  ,'TOTAL_IVA_INCLUIDO'
                                                                                  ,l_Item);
      --//--------------------------------------------------------------------------\\
      l_Trama_Dv1(l_Item).Decimal_Total := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'DV1'
                                                                                     ,'DECIMAL_TOTAL'
                                                                                     ,l_Item)
                                                  ,'-'
                                                  ,'0');
      --//--------------------------------------------------------------------------\\
      l_Trama_Dv1(l_Item).Total_Iva_Incluido := To_Number(l_Trama_Dv1(l_Item).Total_Iva_Incluido || '.' || l_Trama_Dv1(l_Item).Decimal_Total
                                                         ,'999999999999.9999');

      l_Trama_Dv1(l_Item).Iva := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'DV1'
                                                                   ,'IVA'
                                                                   ,l_Item);
      --//--------------------------------------------------------------------------\\
      l_Trama_Dv1(l_Item).Decimal_Iva := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'DV1'
                                                                                   ,'DECIMAL_IVA'
                                                                                   ,l_Item)
                                                ,'-'
                                                ,'0');
      l_Trama_Dv1(l_Item).Iva := To_Number(l_Trama_Dv1(l_Item).Iva || '.' || l_Trama_Dv1(l_Item).Decimal_Iva
                                          ,'999999999999.9999');
      --//--------------------------------------------------------------------------\\
      l_Trama_Dv1(l_Item).Puntos_Asignados := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DV1'
                                                                                ,'PUNTOS_ASIGNADOS'
                                                                                ,l_Item);
      l_Trama_Dv1(l_Item).Tipo_Distribucion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DV1'
                                                                                 ,'TIPO_DISTRIBUCION'
                                                                                 ,l_Item);
      l_Trama_Dv1(l_Item).Campana := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'DV1'
                                                                       ,'CAMPANA'
                                                                       ,l_Item);
      l_Trama_Dv1(l_Item).Secuencia_Financiamiento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                        ,'DV1'
                                                                                        ,'SECUENCIA_FINANCIAMIENTO'
                                                                                        ,l_Item);
      l_Trama_Dv1(l_Item).Documento_Fiscal := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'DV1'
                                                                                ,'DOCUMENTO_FISCAL'
                                                                                ,l_Item);
      l_Trama_Dv1(l_Item).Afecto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'DV1'
                                                                      ,'AFECTO'
                                                                      ,l_Item);
      --//--------------------------------------------------------------------------\\
      l_Trama_Dv1(l_Item).Decimal_Afecto := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'DV1'
                                                                                      ,'DECIMAL_AFECTO'
                                                                                      ,l_Item)
                                                   ,'-'
                                                   ,'0');
      l_Trama_Dv1(l_Item).Afecto := To_Number(l_Trama_Dv1(l_Item).Afecto || '.' || l_Trama_Dv1(l_Item).Decimal_Afecto
                                             ,'999999999999.9999');
      --//--------------------------------------------------------------------------\\
      l_Trama_Dv1(l_Item).Exento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'DV1'
                                                                      ,'EXENTO'
                                                                      ,l_Item);
      --//--------------------------------------------------------------------------\\
      l_Trama_Dv1(l_Item).Decimal_Exento := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'DV1'
                                                                                      ,'DECIMAL_EXENTO'
                                                                                      ,l_Item)
                                                   ,'-'
                                                   ,'0');
      l_Trama_Dv1(l_Item).Exento := To_Number(l_Trama_Dv1(l_Item).Exento || '.' || l_Trama_Dv1(l_Item).Decimal_Exento
                                             ,'999999999999.9999');
      --//--------------------------------------------------------------------------\\
      l_Trama_Dv1(l_Item).Periodo_Facturacion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'DV1'
                                                                                   ,'PERIODO_FACTURACION'
                                                                                   ,l_Item);

      --  JRG CIA 04/06/219
      l_Trama_Dv1(l_Item).Tipo_Guia_Emitida := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'DV1'
                                                                                 ,'TIPO_GUIA_EMITIDA'
                                                                                 ,l_Item);

      --//--------------------------------------------------------------------------\\
      --// CBR 21/03/2017 10:55                                                     \\
      --// Para las versiones de POS que no incluyen el iva en la GUIA              \\
      --//-----------------------------------------------------------------Inicio---\\
      IF l_Trama_Dv1(l_Item).Tipo_Movimiento_Hijo IN ('VENGUI'
                                  ,'ANUGUI') THEN
        p_Aplicar := 1;
      END IF;
      --//-----------------------------------------------------------------Termino--\\
    END LOOP;

    -- Si encontro un docto GUI y luego es local de rollout
    IF p_Aplicar = 1 THEN
      IF Scfr_Trx_Dyn_Pk.Agrega_Iva(p_Trama_Pos.Cadena
                                   ,p_Trama_Pos.Empresa
                                   ,p_Trama_Pos.Local
                                   ,p_Iva) = 'SI' THEN
        FOR l_Item IN 1 .. l_Tot_Reg
        LOOP
          -- l_Trama_Dv1(l_Item).Total_Iva_Incluido := Round(l_Trama_Dv1(l_Item).Afecto * (1 + p_Iva / 100),0);
          l_Trama_Dv1(l_Item).Total_Iva_Incluido := Ceil(l_Trama_Dv1(l_Item).Afecto * (1 + p_Iva / 100));
          l_Trama_Dv1(l_Item).Iva := l_Trama_Dv1(l_Item).Total_Iva_Incluido - l_Trama_Dv1(l_Item).Afecto;
        END LOOP;
      END IF;
    END IF;

    RETURN l_Trama_Dv1;
  END;

  FUNCTION Carga_Trama_Dv2(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dv2 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Dv2 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Dv2;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Dv2(l_Item).Correlativo_Tx := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'DV2'
                                                                              ,'CORRELATIVO_TX'
                                                                              ,l_Item);
      l_Trama_Dv2(l_Item).Motivo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'DV2'
                                                                      ,'MOTIVO'
                                                                      ,l_Item);
    END LOOP;
    RETURN l_Trama_Dv2;
  END;

  FUNCTION Carga_Trama_Ea(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ea IS
    l_Trama_Ea Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ea;
  BEGIN
    l_Trama_Ea.Numero_Reclamo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'EA'
                                                                   ,'NUMERO_RECLAMO');
    l_Trama_Ea.Fecha_Reclamo  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'EA'
                                                                   ,'FECHA_RECLAMO');
    RETURN l_Trama_Ea;
  END;

  FUNCTION Carga_Trama_Eb(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Eb IS
    l_Trama_Eb Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Eb;
  BEGIN
    l_Trama_Eb.Codigo_Respuesta := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'EB'
                                                                     ,'CODIGO_RESPUESTA');
    l_Trama_Eb.Glosa_Respuesta  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'EB'
                                                                     ,'GLOSA_RESPUESTA');
    RETURN l_Trama_Eb;
  END;

  FUNCTION Carga_Trama_Ec(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ec IS
    l_Trama_Ec Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ec;
  BEGIN
    l_Trama_Ec.Tipo_Movimiento_Padre   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'EC'
                                                                            ,'TIPO_MOVIMIENTO_PADRE');
    l_Trama_Ec.Tipo_Movimiento_Hijo    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'EC'
                                                                            ,'TIPO_MOVIMIENTO_HIJO');
    l_Trama_Ec.Folio                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'EC'
                                                                            ,'FOLIO');
    l_Trama_Ec.Numero_Pedido           := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'EC'
                                                                                 ,'NUMERO_PEDIDO'));
    l_Trama_Ec.Codigo_Local_Socofar    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'EC'
                                                                            ,'CODIGO_LOCAL_SOCOFAR');
    l_Trama_Ec.Numero_Reclamo          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'EC'
                                                                            ,'NUMERO_RECLAMO');
    l_Trama_Ec.Fecha_Reclamo           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'EC'
                                                                            ,'FECHA_RECLAMO');
    l_Trama_Ec.Accion_Sobre_Existencia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'EC'
                                                                            ,'ACCION_SOBRE_EXISTENCIA');
    l_Trama_Ec.Numero_Folio_Original   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'EC'
                                                                            ,'NUMERO_FOLIO_ORIGINAL');
    l_Trama_Ec.Fecha_Folio_Original    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'EC'
                                                                            ,'FECHA_FOLIO_ORIGINAL');
    l_Trama_Ec.Monto                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'EC'
                                                                            ,'MONTO');
    l_Trama_Ec.Decimal_Monto           := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'EC'
                                                                                    ,'DECIMAL_MONTO')
                                                 ,'-'
                                                 ,'0');
    l_Trama_Ec.Monto                   := To_Number(l_Trama_Ec.Monto || '.' || l_Trama_Ec.Decimal_Monto
                                                   ,'999999999999.9999');

    l_Trama_Ec.Ident_Proveedor    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'EC'
                                                                       ,'IDENT_PROVEEDOR');
    l_Trama_Ec.Sucursal_Proveedor := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'EC'
                                                                       ,'SUCURSAL_PROVEEDOR');
    l_Trama_Ec.Cantidad_Productos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'EC'
                                                                       ,'CANTIDAD_PRODUCTOS');
    l_Trama_Ec.Subtrama_Ec1       := Carga_Trama_Ec1(p_Cuerpo_Tx
                                                    ,l_Trama_Ec.Cantidad_Productos);
    RETURN l_Trama_Ec;
  END;

  FUNCTION Carga_Trama_Ec1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ec1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Ec1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ec1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Ec1(l_Item).Guia_Electronica := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'EC1'
                                                                                     ,'GUIA_ELECTRONICA'
                                                                                     ,l_Item));
      l_Trama_Ec1(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'EC1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item);
      l_Trama_Ec1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'EC1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
      l_Trama_Ec1(l_Item).Decimal_Cantidad := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                        ,'EC1'
                                                                                        ,'DECIMAL_CANTIDAD'
                                                                                        ,l_Item)
                                                     ,'-'
                                                     ,'0');
      l_Trama_Ec1(l_Item).Cantidad := To_Number(l_Trama_Ec1(l_Item).Cantidad || '.' || l_Trama_Ec1(l_Item).Decimal_Cantidad
                                               ,'999999999999.9999');

      l_Trama_Ec1(l_Item).Motivo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'EC1'
                                                                      ,'MOTIVO'
                                                                      ,l_Item);
      l_Trama_Ec1(l_Item).Costo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'EC1'
                                                                     ,'COSTO'
                                                                     ,l_Item);
      l_Trama_Ec1(l_Item).Decimal_Costo := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'EC1'
                                                                                     ,'DECIMAL_COSTO'
                                                                                     ,l_Item)
                                                  ,'-'
                                                  ,'0');
      l_Trama_Ec1(l_Item).Costo := To_Number(l_Trama_Ec1(l_Item).Costo || '.' || l_Trama_Ec1(l_Item).Decimal_Costo
                                            ,'999999999999.9999');

      l_Trama_Ec1(l_Item).Codigo_Personal := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'EC1'
                                                                               ,'CODIGO_PERSONAL'
                                                                               ,l_Item);
      l_Trama_Ec1(l_Item).Ident_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'EC1'
                                                                              ,'IDENT_VENDEDOR'
                                                                              ,l_Item);
      l_Trama_Ec1(l_Item).Precio_Lista := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'EC1'
                                                                            ,'PRECIO_LISTA'
                                                                            ,l_Item);
      l_Trama_Ec1(l_Item).Decimal_Precio_Lista := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                            ,'EC1'
                                                                                            ,'DECIMAL_PRECIO_LISTA'
                                                                                            ,l_Item)
                                                         ,'-'
                                                         ,'0');
      l_Trama_Ec1(l_Item).Precio_Lista := To_Number(l_Trama_Ec1(l_Item).Precio_Lista || '.' || l_Trama_Ec1(l_Item).Decimal_Precio_Lista
                                                   ,'999999999999.9999');

    END LOOP;
    RETURN l_Trama_Ec1;
  END;

  FUNCTION Carga_Trama_Ed(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ed IS
    l_Trama_Ed Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ed;
  BEGIN
    l_Trama_Ed.Tipo_Movimiento_Padre   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'ED'
                                                                            ,'TIPO_MOVIMIENTO_PADRE');
    l_Trama_Ed.Tipo_Movimiento_Hijo    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'ED'
                                                                            ,'TIPO_MOVIMIENTO_HIJO');
    l_Trama_Ed.Folio                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'ED'
                                                                            ,'FOLIO');
    l_Trama_Ed.Numero_Pedido           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'ED'
                                                                            ,'NUMERO_PEDIDO');
    l_Trama_Ed.Codigo_Local_Socofar    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'ED'
                                                                            ,'CODIGO_LOCAL_SOCOFAR');
    l_Trama_Ed.Numero_Reclamo          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'ED'
                                                                            ,'NUMERO_RECLAMO');
    l_Trama_Ed.Fecha_Reclamo           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'ED'
                                                                            ,'FECHA_RECLAMO');
    l_Trama_Ed.Accion_Sobre_Existencia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'ED'
                                                                            ,'ACCION_SOBRE_EXISTENCIA');
    l_Trama_Ed.Numero_Folio_Original   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'ED'
                                                                            ,'NUMERO_FOLIO_ORIGINAL');
    l_Trama_Ed.Fecha_Folio_Original    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'ED'
                                                                            ,'FECHA_FOLIO_ORIGINAL');
    l_Trama_Ed.Cantidad_Productos      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'ED'
                                                                            ,'CANTIDAD_PRODUCTOS');
    l_Trama_Ed.Subtrama_Ed1            := Carga_Trama_Ed1(p_Cuerpo_Tx
                                                         ,l_Trama_Ed.Cantidad_Productos);
    RETURN l_Trama_Ed;
  END;

  FUNCTION Carga_Trama_Ed1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ed1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Ed1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ed1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Ed1(l_Item).Guia_Electronica := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'ED1'
                                                                                ,'GUIA_ELECTRONICA'
                                                                                ,l_Item);
      l_Trama_Ed1(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'ED1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item);
      l_Trama_Ed1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'ED1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
      -- l_Trama_Ed1(l_Item).Motivo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
    --                                                                 ,'ED1'
    --                                                                 ,'MOTIVO'
    --                                                                 ,l_Item);
    END LOOP;
    RETURN l_Trama_Ed1;
  END;

  FUNCTION Carga_Trama_Ep(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ep IS
    l_Trama_Ep Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ep;
  BEGIN
    l_Trama_Ep.Orden_Pedido           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'EP'
                                                                           ,'ORDEN_PEDIDO');
    l_Trama_Ep.Estado_Service_Request := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'EP'
                                                                           ,'ESTADO_SERVICE_REQUEST');
    l_Trama_Ep.Estado_Pos             := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'EP'
                                                                           ,'ESTADO_POS');
    l_Trama_Ep.Fecha_Inicio           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'EP'
                                                                           ,'FECHA_INICIO');
    l_Trama_Ep.Fecha_Termino          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'EP'
                                                                           ,'FECHA_TERMINO');
    RETURN l_Trama_Ep;
  END;

  FUNCTION Carga_Trama_Er(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Er IS
    l_Trama_Er Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Er;
  BEGIN
    l_Trama_Er.Local                    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'ER'
                                                                             ,'LOCAL');
    l_Trama_Er.Orden_Pedido             := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'ER'
                                                                             ,'ORDEN_PEDIDO');
    l_Trama_Er.Fecha_Hora_Envio         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'ER'
                                                                             ,'FECHA_HORA_ENVIO');
    l_Trama_Er.Fecha_Hora_Actualizacion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'ER'
                                                                             ,'FECHA_HORA_ACTUALIZACION');
    l_Trama_Er.Estado_Service_Request   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'ER'
                                                                             ,'ESTADO_SERVICE_REQUEST');
    l_Trama_Er.Estado_Pos               := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'ER'
                                                                             ,'ESTADO_POS');
    RETURN l_Trama_Er;
  END;

  FUNCTION Carga_Trama_Fe(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Fe IS
    l_Trama_Fe Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Fe;
  BEGIN
    l_Trama_Fe.Uso_Frecuente := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                  ,'FE'
                                                                  ,'USO_FRECUENTE');
    RETURN l_Trama_Fe;
  END;

  FUNCTION Carga_Trama_Fm(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Fm IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Fm Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Fm;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'FM'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Fm(l_Item).Codigo_Movimiento := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'FM'
                                                                                ,'CODIGO_MOVIMIENTO'
                                                                                ,l_Item);
      l_Trama_Fm(l_Item).Fecha_Transaccion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'FM'
                                                                                ,'FECHA_TRANSACCION'
                                                                                ,l_Item);
      l_Trama_Fm(l_Item).Movimiento_Padre := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'FM'
                                                                               ,'MOVIMIENTO_PADRE'
                                                                               ,l_Item);
      l_Trama_Fm(l_Item).Codigo_Item := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'FM'
                                                                          ,'CODIGO_ITEM'
                                                                          ,l_Item);
    END LOOP;
    RETURN l_Trama_Fm;
  END;

  FUNCTION Carga_Trama_Fp(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Fp IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Fp Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Fp;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'FP'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Fp(l_Item).Codigo_Personal := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'FP'
                                                                              ,'CODIGO_PERSONAL'
                                                                              ,l_Item);
      l_Trama_Fp(l_Item).Identi_Cajero := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'FP'
                                                                            ,'IDENTI_CAJERO'
                                                                            ,l_Item);
      l_Trama_Fp(l_Item).Rut := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                  ,'FP'
                                                                  ,'RUT'
                                                                  ,l_Item);
      l_Trama_Fp(l_Item).Dv := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                 ,'FP'
                                                                 ,'DV'
                                                                 ,l_Item);
      l_Trama_Fp(l_Item).Id_Maquina := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'FP'
                                                                         ,'ID_MAQUINA'
                                                                         ,l_Item);
      l_Trama_Fp(l_Item).Identi_Titular := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'FP'
                                                                             ,'IDENTI_TITULAR'
                                                                             ,l_Item);
      l_Trama_Fp(l_Item).Rut_Titular := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'FP'
                                                                          ,'RUT_TITULAR'
                                                                          ,l_Item);
      l_Trama_Fp(l_Item).Dv_Titular := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'FP'
                                                                         ,'DV_TITULAR'
                                                                         ,l_Item);
      l_Trama_Fp(l_Item).Forma_Pago := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'FP'
                                                                         ,'FORMA_PAGO'
                                                                         ,l_Item);
      l_Trama_Fp(l_Item).Medio_Pago := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'FP'
                                                                         ,'MEDIO_PAGO'
                                                                         ,l_Item);
      l_Trama_Fp(l_Item).Codigo_Autorizacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'FP'
                                                                                  ,'CODIGO_AUTORIZACION'
                                                                                  ,l_Item);
      l_Trama_Fp(l_Item).Numero_Documento := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'FP'
                                                                                    ,'NUMERO_DOCUMENTO'
                                                                                    ,l_Item));
      l_Trama_Fp(l_Item).Numero_Cuenta := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'FP'
                                                                                 ,'NUMERO_CUENTA'
                                                                                 ,l_Item));
      l_Trama_Fp(l_Item).Banco := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'FP'
                                                                    ,'BANCO'
                                                                    ,l_Item);
      l_Trama_Fp(l_Item).Fecha_Vencimiento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'FP'
                                                                                ,'FECHA_VENCIMIENTO'
                                                                                ,l_Item);
      l_Trama_Fp(l_Item).Monto_Documento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'FP'
                                                                              ,'MONTO_DOCUMENTO'
                                                                              ,l_Item);
      l_Trama_Fp(l_Item).Decimal_Mdocumento := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                         ,'FP'
                                                                                         ,'DECIMAL_MDOCUMENTO'
                                                                                         ,l_Item)
                                                      ,'-'
                                                      ,'0');
      l_Trama_Fp(l_Item).Monto_Documento := To_Number(l_Trama_Fp(l_Item).Monto_Documento || '.' || l_Trama_Fp(l_Item).Decimal_Mdocumento
                                                     ,'999999999999.9999');

      l_Trama_Fp(l_Item).Monto_Forma_Pago := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'FP'
                                                                               ,'MONTO_FORMA_PAGO'
                                                                               ,l_Item);
      l_Trama_Fp(l_Item).Decimal_Fpago := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'FP'
                                                                                    ,'DECIMAL_FPAGO'
                                                                                    ,l_Item)
                                                 ,'-'
                                                 ,'0');
      l_Trama_Fp(l_Item).Monto_Forma_Pago := To_Number(l_Trama_Fp(l_Item).Monto_Forma_Pago || '.' || l_Trama_Fp(l_Item).Decimal_Fpago
                                                      ,'999999999999.9999');

      l_Trama_Fp(l_Item).Movimiento_Caja := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'FP'
                                                                              ,'MOVIMIENTO_CAJA'
                                                                              ,l_Item);
      l_Trama_Fp(l_Item).Tipo_Autorizacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'FP'
                                                                                ,'TIPO_AUTORIZACION'
                                                                                ,l_Item);
      l_Trama_Fp(l_Item).Cantidad_Cuotas := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'FP'
                                                                              ,'CANTIDAD_CUOTAS'
                                                                              ,l_Item);
      /*
            l_Trama_Fp(l_Item).Decimal_CCuotas := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'FP'
                                                                                  ,'DECIMAL_CCUOTAS'
                                                                                  ,l_Item);
      */
      l_Trama_Fp(l_Item).Interes := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'FP'
                                                                      ,'INTERES'
                                                                      ,l_Item);
      l_Trama_Fp(l_Item).Decimal_Interes := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'FP'
                                                                                      ,'DECIMAL_INTERES'
                                                                                      ,l_Item)
                                                   ,'-'
                                                   ,'0');
      l_Trama_Fp(l_Item).Interes := To_Number(l_Trama_Fp(l_Item).Interes || '.' || l_Trama_Fp(l_Item).Decimal_Interes
                                             ,'999999999999.9999');

      l_Trama_Fp(l_Item).Banda_Magnetica := Scfr_Trx_Dyn_Pk.Obtiene_Bvalor_Trx(p_Cuerpo_Tx
                                                                              ,'FP'
                                                                              ,'BANDA_MAGNETICA'
                                                                              ,l_Item);
      l_Trama_Fp(l_Item).Codigo_Servicio := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'FP'
                                                                              ,'CODIGO_SERVICIO'
                                                                              ,l_Item);
      l_Trama_Fp(l_Item).Local := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'FP'
                                                                    ,'LOCAL'
                                                                    ,l_Item);
      l_Trama_Fp(l_Item).Numero_Pos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'FP'
                                                                         ,'NUMERO_POS'
                                                                         ,l_Item);
      l_Trama_Fp(l_Item).Destino := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'FP'
                                                                      ,'DESTINO'
                                                                      ,l_Item);
      l_Trama_Fp(l_Item).Sistema := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'FP'
                                                                      ,'SISTEMA'
                                                                      ,l_Item);
      l_Trama_Fp(l_Item).Funcion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'FP'
                                                                      ,'FUNCION'
                                                                      ,l_Item);
      l_Trama_Fp(l_Item).Secuencia_c := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'FP'
                                                                          ,'SECUENCIA_C'
                                                                          ,l_Item);
      l_Trama_Fp(l_Item).Fecha_Transaccion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'FP'
                                                                                ,'FECHA_TRANSACCION'
                                                                                ,l_Item);
      l_Trama_Fp(l_Item).Correlativo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'FP'
                                                                          ,'CORRELATIVO'
                                                                          ,l_Item);
      l_Trama_Fp(l_Item).Numero_Trama := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'FP'
                                                                           ,'NUMERO_TRAMA'
                                                                           ,l_Item);
      l_Trama_Fp(l_Item).Codigo_Transaccion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'FP'
                                                                                 ,'CODIGO_TRANSACCION'
                                                                                 ,l_Item);
      l_Trama_Fp(l_Item).Secuencia_Pago := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'FP'
                                                                             ,'SECUENCIA_PAGO'
                                                                             ,l_Item);
      l_Trama_Fp(l_Item).Meses_Diferido := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'FP'
                                                                             ,'MESES_DIFERIDO'
                                                                             ,l_Item);
      l_Trama_Fp(l_Item).Tipo_Cuotas := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'FP'
                                                                          ,'TIPO_CUOTAS'
                                                                          ,l_Item);
      l_Trama_Fp(l_Item).Numero_Tx_Comercio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'FP'
                                                                                 ,'NUMERO_TX_COMERCIO'
                                                                                 ,l_Item);
      l_Trama_Fp(l_Item).Id_Transaccion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'FP'
                                                                             ,'ID_TRANSACCION'
                                                                             ,l_Item);
      l_Trama_Fp(l_Item).Valor_Cuota := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'FP'
                                                                          ,'VALOR_CUOTA'
                                                                          ,l_Item);
      l_Trama_Fp(l_Item).Decimal_Vcuota := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'FP'
                                                                                     ,'DECIMAL_VCUOTA'
                                                                                     ,l_Item)
                                                  ,'-'
                                                  ,'0');
      l_Trama_Fp(l_Item).Valor_Cuota := To_Number(l_Trama_Fp(l_Item).Valor_Cuota || '.' || l_Trama_Fp(l_Item).Decimal_Vcuota
                                                 ,'999999999999.9999');
      l_Trama_Fp(l_Item).Modo_Ingreso_Tarjeta := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'FP'
                                                                                   ,'MODO_INGRESO_TARJETA'
                                                                                   ,l_Item);
      l_Trama_Fp(l_Item).Flujo_Caja := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'FP'
                                                                         ,'FLUJO_CAJA'
                                                                         ,l_Item);
      l_Trama_Fp(l_Item).Cliente_Tarjeta := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'FP'
                                                                                   ,'CLIENTE_TARJETA'
                                                                                   ,l_Item));
      l_Trama_Fp(l_Item).Telefono_Cliente := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'FP'
                                                                               ,'TELEFONO_CLIENTE'
                                                                               ,l_Item);
      l_Trama_Fp(l_Item).Celular_Cliente := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'FP'
                                                                              ,'CELULAR_CLIENTE'
                                                                              ,l_Item);
      l_Trama_Fp(l_Item).Direccion_Cliente := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'FP'
                                                                                     ,'DIRECCION_CLIENTE'
                                                                                     ,l_Item));
      l_Trama_Fp(l_Item).Genero := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'FP'
                                                                     ,'GENERO'
                                                                     ,l_Item);
      l_Trama_Fp(l_Item).Nacimiento := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'FP'
                                                                         ,'NACIMIENTO'
                                                                         ,l_Item);
      ------------
      l_Trama_Fp(l_Item).Importe_Pago := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'FP'
                                                                           ,'IMPORTE_PAGO'
                                                                           ,l_Item);
      l_Trama_Fp(l_Item).Decimal_Importe_Pago := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                           ,'FP'
                                                                                           ,'DECIMAL_IMPORTE_PAGO'
                                                                                           ,l_Item)
                                                        ,'-'
                                                        ,'0');
      l_Trama_Fp(l_Item).Importe_Pago := To_Number(l_Trama_Fp(l_Item).Importe_Pago || '.' || l_Trama_Fp(l_Item).Decimal_Importe_Pago
                                                  ,'999999999999.9999');
      l_Trama_Fp(l_Item).Importe_Cambio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'FP'
                                                                             ,'IMPORTE_CAMBIO'
                                                                             ,l_Item);
      l_Trama_Fp(l_Item).Decimal_Importe_Cambio := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                             ,'FP'
                                                                                             ,'DECIMAL_IMPORTE_CAMBIO'
                                                                                             ,l_Item)
                                                          ,'-'
                                                          ,'0');
      l_Trama_Fp(l_Item).Importe_Cambio := To_Number(l_Trama_Fp(l_Item).Importe_Cambio || '.' || l_Trama_Fp(l_Item).Decimal_Importe_Cambio
                                                    ,'999999999999.9999');
      l_Trama_Fp(l_Item).Tipo_Cambio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'FP'
                                                                          ,'TIPO_CAMBIO'
                                                                          ,l_Item);
      l_Trama_Fp(l_Item).Decimal_Tipo_Cambio := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'FP'
                                                                                          ,'DECIMAL_TIPO_CAMBIO'
                                                                                          ,l_Item)
                                                       ,'-'
                                                       ,'0');
      l_Trama_Fp(l_Item).Tipo_Cambio := To_Number(l_Trama_Fp(l_Item).Tipo_Cambio || '.' || l_Trama_Fp(l_Item).Decimal_Tipo_Cambio
                                                 ,'999999999999.9999');
      l_Trama_Fp(l_Item).Importe_Pago_Usd := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'FP'
                                                                               ,'IMPORTE_PAGO_USD'
                                                                               ,l_Item);
      l_Trama_Fp(l_Item).Decimal_Importe_Pago_Usd := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                               ,'FP'
                                                                                               ,'DECIMAL_IMPORTE_PAGO_USD'
                                                                                               ,l_Item)
                                                            ,'-'
                                                            ,'0');
      l_Trama_Fp(l_Item).Importe_Pago_Usd := To_Number(l_Trama_Fp(l_Item).Importe_Pago_Usd || '.' || l_Trama_Fp(l_Item).Decimal_Importe_Pago_Usd
                                                      ,'999999999999.9999');
      ------------
      -- --FCG Nuevo campo Autorizacion online
      l_Trama_Fp(l_Item).Autorizacion_Online := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                       ,'FP'
                                                                                       ,'AUTORIZACION_ONLINE'
                                                                                       ,l_Item));

      --------------
      l_Trama_Fp(l_Item).Documentos_a_Cancelar := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'FP'
                                                                                    ,'DOCUMENTOS_A_CANCELAR'
                                                                                    ,l_Item);
      l_Trama_Fp(l_Item).Subtrama_Fp1 := Carga_Trama_Fp1(p_Cuerpo_Tx
                                                        ,l_Trama_Fp(l_Item).Documentos_a_Cancelar
                                                        ,l_Item);

    END LOOP;
    RETURN l_Trama_Fp;
  END;

  FUNCTION Carga_Trama_Fp1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Fp1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Fp1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Fp1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Fp1(l_Item).Correlativo_Tx := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'FP1'
                                                                              ,'CORRELATIVO_TX'
                                                                              ,l_Item
                                                                              ,p_Ind);
      l_Trama_Fp1(l_Item).Tipo_Tx := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'FP1'
                                                                       ,'TIPO_TX'
                                                                       ,l_Item
                                                                       ,p_Ind);
    END LOOP;
    RETURN l_Trama_Fp1;
  END;

  --//--------------------------------------------------------------------------\\
  --// CBR 05/14/2019 10:32AM                                                    \\
  --//                                                                          \\
  --//-----------------------------------------------------------------Inicio---\\
  FUNCTION Carga_Trama_Na(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Na IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Na Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Na;
  BEGIN
    l_Trama_Na.Tipo_Llamado        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'NA'
                                                                        ,'TIPO_LLAMADO');
    l_Trama_Na.Llamado             := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'NA'
                                                                        ,'LLAMADO');
    l_Trama_Na.Numero_De_Turno     := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'NA'
                                                                        ,'NUMERO_DE_TURNO');
    l_Trama_Na.Rut_Atencion        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'NA'
                                                                        ,'RUT_ATENCION');
    l_Trama_Na.Tiempo_Espera       := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'NA'
                                                                        ,'TIEMPO_ESPERA');
    l_Trama_Na.Inicio_Servicio     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'NA'
                                                                        ,'INICIO_SERVICIO');
    l_Trama_Na.Local               := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'NA'
                                                                        ,'LOCAL');
    l_Trama_Na.Caja                := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'NA'
                                                                        ,'CAJA');
    l_Trama_Na.Codigo_Vendedor     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'NA'
                                                                        ,'CODIGO_VENDEDOR');
    l_Trama_Na.Autorizacion        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'NA'
                                                                        ,'AUTORIZACION');
    l_Trama_Na.Fin_Servicio        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'NA'
                                                                        ,'FIN_SERVICIO');
    l_Trama_Na.Cantidad_Atenciones := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'NA'
                                                                        ,'CANTIDAD_ATENCIONES');
    l_Trama_Na.Subtrama_Na1        := Carga_Trama_Na1(p_Cuerpo_Tx
                                                     ,l_Trama_Na.Cantidad_Atenciones);
    RETURN l_Trama_Na;
  END;

  FUNCTION Carga_Trama_Na1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Na1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Na1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Na1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Na1(l_Item).Inicio_Atencion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'NA1'
                                                                               ,'INICIO_ATENCION'
                                                                               ,l_Item);
      l_Trama_Na1(l_Item).Secuencia_Atencion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'NA1'
                                                                                  ,'SECUENCIA_ATENCION'
                                                                                  ,l_Item);
      l_Trama_Na1(l_Item).Rut_Cliente := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'NA1'
                                                                           ,'RUT_CLIENTE'
                                                                           ,l_Item);
      l_Trama_Na1(l_Item).Opcion_Atencion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'NA1'
                                                                               ,'OPCION_ATENCION'
                                                                               ,l_Item);
      l_Trama_Na1(l_Item).Id_Transaccion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'NA1'
                                                                              ,'ID_TRANSACCION'
                                                                              ,l_Item);
      l_Trama_Na1(l_Item).Fin_Atencion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'NA1'
                                                                            ,'FIN_ATENCION'
                                                                            ,l_Item);
      l_Trama_Na1(l_Item).Inicio_Consulta_Perfil := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'NA1'
                                                                                      ,'INICIO_CONSULTA_PERFIL'
                                                                                      ,l_Item);
    END LOOP;
    RETURN l_Trama_Na1;
  END;
  --//-----------------------------------------------------------------Termino--\\
  -----------------------------------
  FUNCTION Carga_Trama_Sf(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Sf IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Sf Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Sf;
  BEGIN
    l_Trama_Sf.Fecha_Actualizacion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'SF'
                                                                        ,'FECHA_HORA_TRANSACCION');
    l_Trama_Sf.Folio_Actualizacion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'SF'
                                                                        ,'FOLIO_TRANSACCION');
    l_Trama_Sf.Cantidad_Productos  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'SF'
                                                                        ,'CANTIDAD_PRODUCTOS');
    l_Trama_Sf.Subtrama_Sf1        := Carga_Trama_Sf1(p_Cuerpo_Tx
                                                     ,l_Trama_Sf.Cantidad_Productos);
    RETURN l_Trama_Sf;
  END;

  FUNCTION Carga_Trama_Sf1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Sf1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Sf1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Sf1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Sf1(l_Item).Pro_Codigo_Interno := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'SF1'
                                                                                  ,'CODIGO_INTERNO'
                                                                                  ,l_Item);
      l_Trama_Sf1(l_Item).Signo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'SF1'
                                                                     ,'SIGNO'
                                                                     ,l_Item);
      l_Trama_Sf1(l_Item).Unidades := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'SF1'
                                                                        ,'CANTIDAD_UNIDADES'
                                                                        ,l_Item);
      l_Trama_Sf1(l_Item).Precio_Costo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'SF1'
                                                                            ,'PRECIO_COSTO'
                                                                            ,l_Item);
      l_Trama_Sf1(l_Item).Decimal_Precio_Costo := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                            ,'SF1'
                                                                                            ,'DECIMAL_PRECIO_COSTO'
                                                                                            ,l_Item)
                                                         ,'-'
                                                         ,'0');
      l_Trama_Sf1(l_Item).Precio_Costo := To_Number(l_Trama_Sf1(l_Item).Precio_Costo || '.' || l_Trama_Sf1(l_Item).Decimal_Precio_Costo
                                                   ,'999999999999.9999');
      ------------
      l_Trama_Sf1(l_Item).Unidad_Empaque := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'SF1'
                                                                              ,'UNIDAD_EMPAQUE'
                                                                              ,l_Item);
    END LOOP;
    RETURN l_Trama_Sf1;
  END;
  -----------------------------------
  --//--------------------------------------------------------------------------\\
  --// CBR 01/10/2019 19:01                                                     \\
  --// Trama para Transaccion GNCU13 desde eCommerce                            \\
  --//-----------------------------------------------------------------Inicio---\\
  FUNCTION Carga_Trama_Sk(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Sk IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Sk Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Sk;
  BEGIN
    l_Trama_Sk.Correlativo_Tx     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'SK'
                                                                       ,'CORRELATIVO_TX');
    l_Trama_Sk.Cantidad_Productos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'SK'
                                                                       ,'CANTIDAD_PRODUCTOS');
    l_Trama_Sk.Subtrama_Sk1       := Carga_Trama_Sk1(p_Cuerpo_Tx
                                                    ,l_Trama_Sk.Cantidad_Productos);
    RETURN l_Trama_Sk;
  END;

  FUNCTION Carga_Trama_Sk1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Sk1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Sk1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Sk1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Sk1(l_Item).Pro_Codigo_Interno := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'SK1'
                                                                                  ,'PRO_CODIGO_INTERNO'
                                                                                  ,l_Item);
      l_Trama_Sk1(l_Item).Pro_Vendidos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'SK1'
                                                                            ,'PRO_VENDIDOS'
                                                                            ,l_Item);
      l_Trama_Sk1(l_Item).Pro_Picking := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'SK1'
                                                                           ,'PRO_PICKING'
                                                                           ,l_Item);
      l_Trama_Sk1(l_Item).Pro_Packing := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'SK1'
                                                                           ,'PRO_PACKING'
                                                                           ,l_Item);
      l_Trama_Sk1(l_Item).Rut_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'SK1'
                                                                            ,'RUT_VENDEDOR'
                                                                            ,l_Item);
    END LOOP;
    RETURN l_Trama_Sk1;
  END;
  --//-----------------------------------------------------------------Termino--\\

  FUNCTION Carga_Trama_Fs(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Fs IS
    l_Trama_Fs Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Fs;
  BEGIN
    l_Trama_Fs.Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                             ,'FS'
                                                             ,'PRODUCTO');
    RETURN l_Trama_Fs;
  END;

  FUNCTION Carga_Trama_Gf(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Gf IS
    l_Trama_Gf Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Gf;
  BEGIN
    l_Trama_Gf.Tipo_Movimiento_Padre   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'GF'
                                                                            ,'TIPO_MOVIMIENTO_PADRE');
    l_Trama_Gf.Tipo_Movimiento_Hijo    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'GF'
                                                                            ,'TIPO_MOVIMIENTO_HIJO');
    l_Trama_Gf.Folio                   := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'GF'
                                                                                 ,'FOLIO'));
    l_Trama_Gf.Numero_Pedido           := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'GF'
                                                                                 ,'NUMERO_PEDIDO'));
    l_Trama_Gf.Fecha                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'GF'
                                                                            ,'FECHA');
    l_Trama_Gf.Codigo_Local_Socofar    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'GF'
                                                                            ,'CODIGO_LOCAL_SOCOFAR');
    l_Trama_Gf.Numero_Reclamo          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'GF'
                                                                            ,'NUMERO_RECLAMO');
    l_Trama_Gf.Fecha_Reclamo           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'GF'
                                                                            ,'FECHA_RECLAMO');
    l_Trama_Gf.Accion_Sobre_Existencia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'GF'
                                                                            ,'ACCION_SOBRE_EXISTENCIA');
    l_Trama_Gf.Numero_Folio_Original   := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'GF'
                                                                                 ,'NUMERO_FOLIO_ORIGINAL'));
    l_Trama_Gf.Fecha_Folio_Original    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'GF'
                                                                            ,'FECHA_FOLIO_ORIGINAL');
    l_Trama_Gf.Monto                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'GF'
                                                                            ,'MONTO');
    l_Trama_Gf.Decimal_Monto           := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'GF'
                                                                                    ,'DECIMAL_MONTO')
                                                 ,'-'
                                                 ,'0');
    l_Trama_Gf.Monto                   := To_Number(l_Trama_Gf.Monto || '.' || l_Trama_Gf.Decimal_Monto
                                                   ,'999999999999.9999');

    l_Trama_Gf.Ident_Proveedor    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'GF'
                                                                       ,'IDENT_PROVEEDOR');
    l_Trama_Gf.Sucursal_Proveedor := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'GF'
                                                                       ,'SUCURSAL_PROVEEDOR');
    --JRC 30/08/2023 Unificando EXCU17 desde Yza a Ecuador
    l_Trama_Gf.Numero_Factura := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'GF'
                                                                        ,'NUMERO_FFACTURA'));
    --
    
    --INI JAGC 20250414 ORIGEN FGI
    l_Trama_Gf.FOLIO_INGRESO  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'GF'
                                                                            ,'FOLIO_INGRESO');
    --FIN JAGC 20250414 ORIGEN FGI
    
    l_Trama_Gf.Cantidad_Productos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'GF'
                                                                       ,'CANTIDAD_PRODUCTOS');
    l_Trama_Gf.Subtrama_Gf1       := Carga_Trama_Gf1(p_Cuerpo_Tx
                                                    ,l_Trama_Gf.Cantidad_Productos);
    RETURN l_Trama_Gf;
  END;

  FUNCTION Carga_Trama_Gf1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gf1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Gf1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gf1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Gf1(l_Item).Guia_Electronica := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'GF1'
                                                                                     ,'GUIA_ELECTRONICA'
                                                                                     ,l_Item));
      l_Trama_Gf1(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'GF1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item);
      l_Trama_Gf1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'GF1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
      l_Trama_Gf1(l_Item).Decimal_Cantidad := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                        ,'GF1'
                                                                                        ,'DECIMAL_CANTIDAD'
                                                                                        ,l_Item)
                                                     ,'-'
                                                     ,'0');
      l_Trama_Gf1(l_Item).Cantidad := To_Number(l_Trama_Gf1(l_Item).Cantidad || '.' || l_Trama_Gf1(l_Item).Decimal_Cantidad
                                               ,'999999999999.9999');

      l_Trama_Gf1(l_Item).Tipo_Falta_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'GF1'
                                                                                   ,'TIPO_FALTA_PRODUCTO'
                                                                                   ,l_Item);
      l_Trama_Gf1(l_Item).Motivo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'GF1'
                                                                      ,'MOTIVO'
                                                                      ,l_Item);
      l_Trama_Gf1(l_Item).Guia_Facturable := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'GF1'
                                                                                    ,'GUIA_FACTURABLE'
                                                                                    ,l_Item));
      l_Trama_Gf1(l_Item).Costo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'GF1'
                                                                     ,'COSTO'
                                                                     ,l_Item);
      l_Trama_Gf1(l_Item).Decimal_Costo := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'GF1'
                                                                                     ,'DECIMAL_COSTO'
                                                                                     ,l_Item)
                                                  ,'-'
                                                  ,'0');
      l_Trama_Gf1(l_Item).Costo := To_Number(l_Trama_Gf1(l_Item).Costo || '.' || l_Trama_Gf1(l_Item).Decimal_Costo
                                            ,'999999999999.9999');

      l_Trama_Gf1(l_Item).Codigo_Personal := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'GF1'
                                                                               ,'CODIGO_PERSONAL'
                                                                               ,l_Item);
      l_Trama_Gf1(l_Item).Ident_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'GF1'
                                                                              ,'IDENT_VENDEDOR'
                                                                              ,l_Item);
      l_Trama_Gf1(l_Item).Precio_Lista := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'GF1'
                                                                            ,'PRECIO_LISTA'
                                                                            ,l_Item);
      l_Trama_Gf1(l_Item).Decimal_Precio_Lista := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                            ,'GF1'
                                                                                            ,'DECIMAL_PRECIO_LISTA'
                                                                                            ,l_Item)
                                                         ,'-'
                                                         ,'0');
      l_Trama_Gf1(l_Item).Precio_Lista := To_Number(l_Trama_Gf1(l_Item).Precio_Lista || '.' || l_Trama_Gf1(l_Item).Decimal_Precio_Lista
                                                   ,'999999999999.9999');
      -- IDHC origen NLG
      l_Trama_Gf1(l_Item).Numero_Item := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'GF1'
                                                                           ,'NUMERO_ITEM'
                                                                           ,l_Item);
      -- fin IDHC
    END LOOP;
    RETURN l_Trama_Gf1;
  END;

  FUNCTION Carga_Trama_Gs(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Gs IS
    l_Trama_Gs Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Gs;
  BEGIN
    l_Trama_Gs.Correlativo_Tx     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'GS'
                                                                       ,'CORRELATIVO_TX');
    l_Trama_Gs.Cantidad_Productos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'GS'
                                                                       ,'CANTIDAD_PRODUCTOS');
    l_Trama_Gs.Subtrama_Gs1       := Carga_Trama_Gs1(p_Cuerpo_Tx
                                                    ,l_Trama_Gs.Cantidad_Productos);
    RETURN l_Trama_Gs;
  END;

  FUNCTION Carga_Trama_Gs1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gs1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Gs1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gs1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Gs1(l_Item).Folio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'GS1'
                                                                     ,'FOLIO'
                                                                     ,l_Item);
      l_Trama_Gs1(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'GS1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item);
      l_Trama_Gs1(l_Item).Uso_Frecuente := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'GS1'
                                                                             ,'USO_FRECUENTE'
                                                                             ,l_Item);
      l_Trama_Gs1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'GS1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
    END LOOP;
    RETURN l_Trama_Gs1;
  END;

  FUNCTION Carga_Trama_Gu(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Gu IS
    l_Trama_Gu Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Gu;
  BEGIN
    l_Trama_Gu.Numero_Guia := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'GU'
                                                                     ,'NUMERO_GUIA'));
    RETURN l_Trama_Gu;
  END;

  FUNCTION Carga_Trama_Hbo(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Hbo IS
    l_Trama_Hbo Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Hbo;
  BEGIN
    l_Trama_Hbo.Forma_Identificacion  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'HBO'
                                                                           ,'FORMA_IDENTIFICACION');
    l_Trama_Hbo.String_Identificacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'HBO'
                                                                           ,'STRING_IDENTIFICACION');
    l_Trama_Hbo.Party_Id              := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'HBO'
                                                                           ,'PARTY_ID');
    l_Trama_Hbo.Codigo_Respuesta      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'HBO'
                                                                           ,'CODIGO_RESPUESTA');
    l_Trama_Hbo.Largo_Total_Buffer    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'HBO'
                                                                           ,'LARGO_TOTAL_BUFFER');
    RETURN l_Trama_Hbo;
  END;

  FUNCTION Carga_Trama_Hc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Hc IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Hc Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Hc;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'HC'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Hc(l_Item).Codigo_Producto_Interno := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'HC'
                                                                                      ,'CODIGO_PRODUCTO_INTERNO'
                                                                                      ,l_Item);
      l_Trama_Hc(l_Item).Fecha := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'HC'
                                                                    ,'FECHA'
                                                                    ,l_Item);
      l_Trama_Hc(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'HC'
                                                                       ,'CANTIDAD'
                                                                       ,l_Item);
      --//--------------------------------------------------------------------------\\
      --// CBR 17/08/2020 05:15                                                     \\
      --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
      --//-----------------------------------------------------------------Inicio---\\
      l_Trama_Hc(l_Item).Decimal_Cantidad := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                       ,'HC'
                                                                                       ,'DECIMAL_CANTIDAD'
                                                                                       ,l_Item)
                                                    ,'-'
                                                    ,'0');
      l_Trama_Hc(l_Item).Cantidad := To_Number(l_Trama_Hc(l_Item).Cantidad || '.' || l_Trama_Hc(l_Item).Decimal_Cantidad
                                              ,'999999999999.9999');
      --//-----------------------------------------------------------------Termino--\\
      l_Trama_Hc(l_Item).Numero_Consejo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'HC'
                                                                             ,'NUMERO_CONSEJO'
                                                                             ,l_Item);
      l_Trama_Hc(l_Item).Id_Grupo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'HC'
                                                                       ,'ID_GRUPO'
                                                                       ,l_Item);
      l_Trama_Hc(l_Item).Saldo_Grupo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HC'
                                                                          ,'SALDO_GRUPO'
                                                                          ,l_Item);
      l_Trama_Hc(l_Item).Nombre_Grupo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'HC'
                                                                           ,'NOMBRE_GRUPO'
                                                                           ,l_Item);
    END LOOP;
    RETURN l_Trama_Hc;
  END;

  FUNCTION Carga_Trama_Hpo(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Hpo IS
    l_Trama_Hpo Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Hpo;
  BEGIN
    l_Trama_Hpo.Version_Primaria     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'VERSION_PRIMARIA');
    l_Trama_Hpo.Version_Secundaria   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'VERSION_SECUNDARIA');
    l_Trama_Hpo.Encriptado           := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'ENCRIPTADO');
    l_Trama_Hpo.Largo_Tx_Encriptada  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'LARGO_TX_ENCRIPTADA');
    l_Trama_Hpo.Certificado          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'CERTIFICADO');
    l_Trama_Hpo.Empresa              := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'EMPRESA');
    l_Trama_Hpo.Cadena               := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'CADENA');
    l_Trama_Hpo.Local                := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'LOCAL');
    l_Trama_Hpo.Numero_Pos           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'NUMERO_POS');
    l_Trama_Hpo.Id_Maquina           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'ID_MAQUINA');
    l_Trama_Hpo.Usuario_Responsable  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'USUARIO_RESPONSABLE');
    l_Trama_Hpo.Destino              := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'DESTINO');
    l_Trama_Hpo.Tipo_Transmision     := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'TIPO_TRANSMISION');
    l_Trama_Hpo.Sistema              := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'SISTEMA');
    l_Trama_Hpo.Funcion              := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'FUNCION');
    l_Trama_Hpo.Secuencia_c          := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'SECUENCIA_C');
    l_Trama_Hpo.Fecha_Hora_Contable  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'FECHA_HORA_CONTABLE');
    l_Trama_Hpo.Fecha_Hora_Proceso   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'FECHA_HORA_PROCESO');
    l_Trama_Hpo.Fecha_Hora_Tx        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'FECHA_HORA_TX');
    l_Trama_Hpo.Fecha_Hora_Rx        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'FECHA_HORA_RX');
    l_Trama_Hpo.Correlativo          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'CORRELATIVO');
    l_Trama_Hpo.Codigo_Respuesta     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'CODIGO_RESPUESTA');
    l_Trama_Hpo.Tipo_Requerimiento   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'TIPO_REQUERIMIENTO');
    l_Trama_Hpo.Identificador_Global := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'IDENTIFICADOR_GLOBAL');
    l_Trama_Hpo.Empresa_Destino      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'EMPRESA_DESTINO');
    l_Trama_Hpo.Cadena_Destino       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'CADENA_DESTINO');
    l_Trama_Hpo.Local_Destino        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'LOCAL_DESTINO');
    l_Trama_Hpo.Prioridad            := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'PRIORIDAD');
    l_Trama_Hpo.Ttl                  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'TTL');
    l_Trama_Hpo.Resolver_Localmente  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'RESOLVER_LOCALMENTE');
    l_Trama_Hpo.Cliente_Destino      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'CLIENTE_DESTINO');
    l_Trama_Hpo.Plataforma           := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'PLATAFORMA');
    l_Trama_Hpo.Procesar_Central     := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'PROCESAR_CENTRAL');
    l_Trama_Hpo.Reservados           := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'RESERVADOS');
    l_Trama_Hpo.Origen_Transaccion   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'ORIGEN_TRANSACCION');
    l_Trama_Hpo.Tramas_Fragmentadas  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'TRAMAS_FRAGMENTADAS');
    l_Trama_Hpo.Headers_Presente     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'HEADERS_PRESENTE');
    l_Trama_Hpo.Numero_Trama         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'NUMERO_TRAMA');
    l_Trama_Hpo.Cantidad_Tramas      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'CANTIDAD_TRAMAS');
    l_Trama_Hpo.Largo_Total_Buffer   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'HPO'
                                                                          ,'LARGO_TOTAL_BUFFER');
    RETURN l_Trama_Hpo;
  END;

  FUNCTION Carga_Trama_Htx(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Htx IS
    l_Trama_Htx Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Htx;
  BEGIN
    l_Trama_Htx.Tipo_Informacion   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'HTX'
                                                                        ,'TIPO_INFORMACION');
    l_Trama_Htx.Modo_Largo_Campos  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'HTX'
                                                                        ,'MODO_LARGO_CAMPOS');
    l_Trama_Htx.Largo_Buffer_Datos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'HTX'
                                                                        ,'LARGO_BUFFER_DATOS');
    l_Trama_Htx.Cantidad_Registros := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'HTX'
                                                                        ,'CANTIDAD_REGISTROS');
    RETURN l_Trama_Htx;
  END;

  FUNCTION Carga_Trama_Lc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Lc IS
    l_Trama_Lc Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Lc;
  BEGIN
    l_Trama_Lc.Convenio            := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'LC'
                                                                        ,'CONVENIO');
    l_Trama_Lc.Plan                := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'LC'
                                                                        ,'PLAN');
    l_Trama_Lc.Secuencia_b         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'LC'
                                                                        ,'SECUENCIA_B');
    l_Trama_Lc.Codigo_Autorizacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'LC'
                                                                        ,'CODIGO_AUTORIZACION');
    RETURN l_Trama_Lc;
  END;

  FUNCTION Carga_Trama_Lf(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Lf IS
    l_Trama_Lf Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Lf;
  BEGIN
    l_Trama_Lf.Codigo_Autorizacion         := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'LF'
                                                                                ,'CODIGO_AUTORIZACION');
    l_Trama_Lf.Codigo_Autorizacion_Externo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'LF'
                                                                                ,'CODIGO_AUTORIZACION_EXTERNO');
    l_Trama_Lf.Tipo_Reversa                := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'LF'
                                                                                ,'TIPO_REVERSA');
    l_Trama_Lf.Monto_Reversa               := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'LF'
                                                                                ,'MONTO_REVERSA');
    RETURN l_Trama_Lf;
  END;

  FUNCTION Carga_Trama_Lo(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Lo IS
    l_Trama_Lo Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Lo;
  BEGIN
    l_Trama_Lo.Fecha_Inicio            := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'LO'
                                                                            ,'FECHA_INICIO');
    l_Trama_Lo.Hora_Inicio             := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'LO'
                                                                            ,'HORA_INICIO');
    l_Trama_Lo.Version_Primaria_Adlc   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'LO'
                                                                            ,'VERSION_PRIMARIA_ADLC');
    l_Trama_Lo.Version_Secundaria_Adlc := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'LO'
                                                                            ,'VERSION_SECUNDARIA_ADLC');
    RETURN l_Trama_Lo;
  END;

  FUNCTION Carga_Trama_Lr(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Lr IS
    l_Trama_Lr Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Lr;
  BEGIN
    l_Trama_Lr.Codigo_Autorizacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'LR'
                                                                        ,'CODIGO_AUTORIZACION');
    RETURN l_Trama_Lr;
  END;

  FUNCTION Carga_Trama_Md(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Md IS
    l_Trama_Md Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Md;
  BEGIN
    l_Trama_Md.Tipo_Movimiento_Padre   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'TIPO_MOVIMIENTO_PADRE');
    l_Trama_Md.Tipo_Movimiento_Hijo    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'TIPO_MOVIMIENTO_HIJO');
    l_Trama_Md.Folio                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'FOLIO');
    
    --INI JAGC 20250414 ORIGEN FGI
    l_Trama_Md.FOLIO_INGRESO                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'FOLIO_INGRESO');
    l_Trama_Md.DISPATCH_QR           := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'MD'
                                                                                 ,'DISPATCH_QR'));
    --FIN JAGC 20250414 ORIGEN FGI
        
    l_Trama_Md.Numero_Pedido           := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'MD'
                                                                                 ,'NUMERO_PEDIDO'));
    l_Trama_Md.Tipo_Guia_Despacho      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'TIPO_GUIA_DESPACHO');
    l_Trama_Md.Accion_Sobre_Existencia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'ACCION_SOBRE_EXISTENCIA');
    l_Trama_Md.Numero_Folio_Original   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'NUMERO_FOLIO_ORIGINAL');
    l_Trama_Md.Fecha_Folio_Original    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'FECHA_FOLIO_ORIGINAL');
    l_Trama_Md.Tipo_Recepcion          := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'TIPO_RECEPCION');
    l_Trama_Md.Numero_Reclamo          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'NUMERO_RECLAMO');
    l_Trama_Md.Fecha_Reclamo           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'FECHA_RECLAMO');
    l_Trama_Md.Dfi_Numero_Asignacion   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'DFI_NUMERO_ASIGNACION');
    l_Trama_Md.Matricula_Bulto         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'MATRICULA_BULTO');
    l_Trama_Md.Monto                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'MONTO');
    l_Trama_Md.Decimal_Monto           := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'MD'
                                                                                    ,'DECIMAL_MONTO')
                                                 ,'-'
                                                 ,'0');
    l_Trama_Md.Monto                   := To_Number(l_Trama_Md.Monto || '.' || l_Trama_Md.Decimal_Monto
                                                   ,'999999999999.9999');
    l_Trama_Md.Identi_Proveedor        := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'IDENTI_PROVEEDOR');
    /*
        l_Trama_Md.Rut_Proveedor           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'MD'
                                                                                ,'RUT_PROVEEDOR');
    */
    l_Trama_Md.Sucursal_Proveedor := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'MD'
                                                                       ,'SUCURSAL_PROVEEDOR');
    l_Trama_Md.Sello_Seguro_Uno   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'MD'
                                                                       ,'SELLO_SEGURO_UNO');
    l_Trama_Md.Sello_Seguro_Dos   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'MD'
                                                                       ,'SELLO_SEGURO_DOS');

    -- JRC 20/07/2023
    l_Trama_Md.Motivo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                           ,'MD'
                                                           ,'MOTIVO');

    --JRC 27/09/2023 Origen FTR(Factura Transacciones Relacionadas)
    l_Trama_Md.Numero_Factura := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                   ,'MD'
                                                                   ,'NUMERO_FACTURA');
    --

    l_Trama_Md.Cantidad_Productos    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'MD'
                                                                          ,'CANTIDAD_PRODUCTOS');
    l_Trama_Md.Cantidad_Contenedores := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'MD'
                                                                          ,'CANTIDAD_CONTENEDORES');
    l_Trama_Md.Subtrama_Md1          := Carga_Trama_Md1(p_Cuerpo_Tx
                                                       ,l_Trama_Md.Cantidad_Productos);
    l_Trama_Md.Subtrama_Md2          := Carga_Trama_Md2(p_Cuerpo_Tx
                                                       ,l_Trama_Md.Cantidad_Contenedores);
    RETURN l_Trama_Md;
  END;

  /* JRC 20/07/2023 Comento ya que todo debe quedar en Carga_Trama_Md
  -- JRC 19/12/2019 Md4 <> solo por el campo Motivo
  FUNCTION Carga_Trama_Md4(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Md IS
    l_Trama_Md Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Md;
  BEGIN
    l_Trama_Md.Tipo_Movimiento_Padre   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'TIPO_MOVIMIENTO_PADRE');
    l_Trama_Md.Tipo_Movimiento_Hijo    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'TIPO_MOVIMIENTO_HIJO');
    l_Trama_Md.Folio                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'FOLIO');
    l_Trama_Md.Numero_Pedido           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'NUMERO_PEDIDO');
    l_Trama_Md.Tipo_Guia_Despacho      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'TIPO_GUIA_DESPACHO');
    l_Trama_Md.Accion_Sobre_Existencia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'ACCION_SOBRE_EXISTENCIA');
    l_Trama_Md.Numero_Folio_Original   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'NUMERO_FOLIO_ORIGINAL');
    l_Trama_Md.Fecha_Folio_Original    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'FECHA_FOLIO_ORIGINAL');
    l_Trama_Md.Tipo_Recepcion          := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'TIPO_RECEPCION');
    l_Trama_Md.Numero_Reclamo          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'NUMERO_RECLAMO');
    l_Trama_Md.Fecha_Reclamo           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'FECHA_RECLAMO');
    l_Trama_Md.Dfi_Numero_Asignacion   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'DFI_NUMERO_ASIGNACION');
    l_Trama_Md.Matricula_Bulto         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'MATRICULA_BULTO');
    l_Trama_Md.Monto                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'MONTO');
    l_Trama_Md.Rut_Proveedor           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'RUT_PROVEEDOR');
    l_Trama_Md.Sucursal_Proveedor      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'SUCURSAL_PROVEEDOR');
    l_Trama_Md.Sello_Seguro_Uno        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'SELLO_SEGURO_UNO');
    l_Trama_Md.Sello_Seguro_Dos        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'SELLO_SEGURO_DOS');
    -- JRC 19/12/2019
    l_Trama_Md.Motivo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                           ,'MD'
                                                           ,'MOTIVO');
    --
    l_Trama_Md.Cantidad_Productos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'MD'
                                                                       ,'CANTIDAD_PRODUCTOS');
    l_Trama_Md.Subtrama_Md1       := Carga_Trama_Md1(p_Cuerpo_Tx
                                                    ,l_Trama_Md.Cantidad_Productos);
    RETURN l_Trama_Md;
  END;


  FUNCTION Carga_Trama_Md8(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Md8 IS
    l_Trama_Md Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Md8;
  BEGIN
    l_Trama_Md.Tipo_Movimiento_Padre   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'TIPO_MOVIMIENTO_PADRE');
    l_Trama_Md.Tipo_Movimiento_Hijo    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'TIPO_MOVIMIENTO_HIJO');
    l_Trama_Md.Folio                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'FOLIO');
    l_Trama_Md.Numero_Pedido           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'NUMERO_PEDIDO');
    l_Trama_Md.Tipo_Guia_Despacho      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'TIPO_GUIA_DESPACHO');
    l_Trama_Md.Accion_Sobre_Existencia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'ACCION_SOBRE_EXISTENCIA');
    l_Trama_Md.Numero_Folio_Original   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'NUMERO_FOLIO_ORIGINAL');
    l_Trama_Md.Fecha_Folio_Original    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'FECHA_FOLIO_ORIGINAL');
    l_Trama_Md.Tipo_Recepcion          := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'TIPO_RECEPCION');
    l_Trama_Md.Numero_Reclamo          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'NUMERO_RECLAMO');
    l_Trama_Md.Fecha_Reclamo           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'FECHA_RECLAMO');
    l_Trama_Md.Cantidad_Productos      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD'
                                                                            ,'CANTIDAD_PRODUCTOS');
    l_Trama_Md.Subtrama_Md2            := Carga_Trama_Md2(p_Cuerpo_Tx
                                                         ,l_Trama_Md.Cantidad_Productos);
    RETURN l_Trama_Md;
  END;
  */

  FUNCTION Carga_Trama_Md1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Md1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Md1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Md1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Md1(l_Item).Guia_Electronica := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'MD1'
                                                                                     ,'GUIA_ELECTRONICA'
                                                                                     ,l_Item));
      l_Trama_Md1(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'MD1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item);
      l_Trama_Md1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'MD1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
      
      l_Trama_Md1(l_Item).Decimal_Cantidad := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                        ,'MD1'
                                                                                        ,'DECIMAL_CANTIDAD'
                                                                                        ,l_Item)
                                                     ,'-'
                                                     ,'0');
         
                                                
      l_Trama_Md1(l_Item).Cantidad := To_Number(l_Trama_Md1(l_Item).Cantidad || '.' || l_Trama_Md1(l_Item).Decimal_Cantidad
                                               ,'999999999999.9999');
      l_Trama_Md1(l_Item).Costo_Unitario := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'MD1'
                                                                              ,'COSTO_UNITARIO'
                                                                              ,l_Item);
     
      l_Trama_Md1(l_Item).Decimal_Cunitario := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                         ,'MD1'
                                                                                         ,'DECIMAL_CUNITARIO'
                                                                                         ,l_Item)
                                                      ,'-'
                                                      ,'0');
                                                    
      l_Trama_Md1(l_Item).Costo_Unitario := To_Number(l_Trama_Md1(l_Item).Costo_Unitario || '.' || l_Trama_Md1(l_Item).Decimal_Cunitario
                                                     ,'999999999999.9999');
      l_Trama_Md1(l_Item).Numero_Item := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'MD1'
                                                                           ,'NUMERO_ITEM'
                                                                           ,l_Item);
      l_Trama_Md1(l_Item).Lote := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'MD1'
                                                                    ,'LOTE'
                                                                    ,l_Item);
      l_Trama_Md1(l_Item).Guia_Facturable := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'MD1'
                                                                                    ,'GUIA_FACTURABLE'
                                                                                    ,l_Item));
      l_Trama_Md1(l_Item).Precio_Final := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD1'
                                                                            ,'PRECIO_FINAL'
                                                                            ,l_Item);

     
      l_Trama_Md1(l_Item).Decimal_Pfinal := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'MD1'
                                                                                      ,'DECIMAL_PFINAL'
                                                                                      ,l_Item)
                                                   ,'-'
                                                   ,'0');
                                                   
      l_Trama_Md1(l_Item).Precio_Final := To_Number(l_Trama_Md1(l_Item).Precio_Final || '.' || l_Trama_Md1(l_Item).Decimal_Pfinal
                                                   ,'999999999999.9999');

      l_Trama_Md1(l_Item).Codigo_Personal := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'MD1'
                                                                               ,'CODIGO_PERSONAL'
                                                                               ,l_Item);
      /*
            l_Trama_Md1(l_Item).Rut_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'MD1'
                                                                                  ,'RUT_VENDEDOR'
                                                                                  ,l_Item);
            l_Trama_Md1(l_Item).Dv_Rut_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'MD1'
                                                                                     ,'DV_RUT_VENDEDOR'
                                                                                     ,l_Item);
      */
      l_Trama_Md1(l_Item).Identi_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'MD1'
                                                                               ,'IDENTI_VENDEDOR'
                                                                               ,l_Item);
      l_Trama_Md1(l_Item).Precio_Lista := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MD1'
                                                                            ,'PRECIO_LISTA'
                                                                            ,l_Item);
      
      l_Trama_Md1(l_Item).Decimal_Plista := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'MD1'
                                                                                      ,'DECIMAL_PLISTA'
                                                                                      ,l_Item)
                                                   ,'-'
                                                   ,'0');
                                
                                                   
      l_Trama_Md1(l_Item).Precio_Lista := To_Number(l_Trama_Md1(l_Item).Precio_Lista || '.' || l_Trama_Md1(l_Item).Decimal_Plista
                                                   ,'999999999999.9999');
      l_Trama_Md1(l_Item).Codigo_Reclamo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'MD1'
                                                                              ,'CODIGO_RECLAMO'
                                                                              ,l_Item);

      l_Trama_Md1(l_Item).Iva := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'MD1'
                                                                   ,'IVA'
                                                                   ,l_Item);

      l_Trama_Md1(l_Item).Ieps := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'MD1'
                                                                    ,'IEPS'
                                                                    ,l_Item);

    END LOOP;
    RETURN l_Trama_Md1;
  END;

  FUNCTION Carga_Trama_Md2(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Md2 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Md2 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Md2;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Md2(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'MD2'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item);
      l_Trama_Md2(l_Item).Numero_Contenedor := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'MD2'
                                                                                      ,'NUMERO_CONTENEDOR'
                                                                                      ,l_Item));
      l_Trama_Md2(l_Item).Cantidad_Productos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'MD2'
                                                                                  ,'CANTIDAD_PRODUCTOS'
                                                                                  ,l_Item);
    END LOOP;
    RETURN l_Trama_Md2;
  END;

  FUNCTION Carga_Trama_Mf(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Mf IS
    l_Trama_Mf Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Mf;
  BEGIN
    l_Trama_Mf.Mensaje  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                             ,'MF'
                                                             ,'MENSAJE');
    l_Trama_Mf.Dirigido := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                             ,'MF'
                                                             ,'DIRIGIDO');
    RETURN l_Trama_Mf;
  END;

  FUNCTION Carga_Trama_Mg(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Mg IS
    l_Trama_Mg Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Mg;
  BEGIN
    l_Trama_Mg.Secuencia_Receta      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'MG'
                                                                          ,'SECUENCIA_RECETA');
    l_Trama_Mg.Tipo_Preparado        := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'MG'
                                                                          ,'TIPO_PREPARADO');
    l_Trama_Mg.Unidad_Medida         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'MG'
                                                                          ,'UNIDAD_MEDIDA');
    l_Trama_Mg.Cantidad              := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'MG'
                                                                          ,'CANTIDAD');
    l_Trama_Mg.Volumen_Parte_Entera  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'MG'
                                                                          ,'VOLUMEN_PARTE_ENTERA');
    l_Trama_Mg.Volumen_Parte_Decimal := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'MG'
                                                                          ,'VOLUMEN_PARTE_DECIMAL');
    l_Trama_Mg.Cantidad_Insumos      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'MG'
                                                                          ,'CANTIDAD_INSUMOS');
    l_Trama_Mg.Subtrama_Mg1          := Carga_Trama_Mg1(p_Cuerpo_Tx
                                                       ,l_Trama_Mg.Cantidad_Insumos);
    RETURN l_Trama_Mg;
  END;

  FUNCTION Carga_Trama_Mg1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Mg1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Mg1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Mg1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Mg1(l_Item).Codigo_Insumo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'MG1'
                                                                             ,'CODIGO_INSUMO'
                                                                             ,l_Item);
      l_Trama_Mg1(l_Item).Cantidad_Parte_Entera := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'MG1'
                                                                                     ,'CANTIDAD_PARTE_ENTERA'
                                                                                     ,l_Item);
      l_Trama_Mg1(l_Item).Cantidad_Parte_Decimal := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'MG1'
                                                                                      ,'CANTIDAD_PARTE_DECIMAL'
                                                                                      ,l_Item);
      l_Trama_Mg1(l_Item).Unidad_Medida := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'MG1'
                                                                             ,'UNIDAD_MEDIDA'
                                                                             ,l_Item);
      l_Trama_Mg1(l_Item).Excipiente := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'MG1'
                                                                          ,'EXCIPIENTE'
                                                                          ,l_Item);
    END LOOP;
    RETURN l_Trama_Mg1;
  END;

  FUNCTION Carga_Trama_Ms(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ms IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Ms Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ms;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'MS'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Ms(l_Item).Mensaje := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'MS'
                                                                      ,'MENSAJE'
                                                                      ,l_Item);
      l_Trama_Ms(l_Item).Dirigido := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'MS'
                                                                       ,'DIRIGIDO'
                                                                       ,l_Item);
      l_Trama_Ms(l_Item).Medio_Comunicacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'MS'
                                                                                 ,'MEDIO_COMUNICACION'
                                                                                 ,l_Item);
    END LOOP;
    RETURN l_Trama_Ms;
  END;

  FUNCTION Carga_Trama_Mp(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Mp IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Mp Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Mp;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'MP'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Mp(l_Item).Correlativo_Tx := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'MP'
                                                                             ,'CORRELATIVO_TX'
                                                                             ,l_Item);
      l_Trama_Mp(l_Item).Codigo_Interno := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'MP'
                                                                             ,'CODIGO_INTERNO'
                                                                             ,l_Item);
      l_Trama_Mp(l_Item).Codigo_Autorizacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'MP'
                                                                                  ,'CODIGO_AUTORIZACION'
                                                                                  ,l_Item);
      l_Trama_Mp(l_Item).Numero_Id := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'MP'
                                                                             ,'NUMERO_ID'
                                                                             ,l_Item));
      l_Trama_Mp(l_Item).Monto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'MP'
                                                                    ,'MONTO'
                                                                    ,l_Item);
      l_Trama_Mp(l_Item).Decimal_Monto := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'MP'
                                                                                    ,'DECIMAL_MONTO'
                                                                                    ,l_Item)
                                                 ,'-'
                                                 ,'0');
      l_Trama_Mp(l_Item).Monto := To_Number(l_Trama_Mp(l_Item).Monto || '.' || l_Trama_Mp(l_Item).Decimal_Monto
                                           ,'999999999999.9999');

      l_Trama_Mp(l_Item).Codigo_Autorizacion_Empresa := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'MP'
                                                                                          ,'CODIGO_AUTORIZACION_EMPRESA'
                                                                                          ,l_Item);
      l_Trama_Mp(l_Item).Numero_Folio := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'MP'
                                                                                ,'NUMERO_FOLIO'
                                                                                ,l_Item));
      l_Trama_Mp(l_Item).Fecha_Vencimiento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'MP'
                                                                                ,'FECHA_VENCIMIENTO'
                                                                                ,l_Item);
      l_Trama_Mp(l_Item).Empresa := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'MP'
                                                                      ,'EMPRESA'
                                                                      ,l_Item);
      l_Trama_Mp(l_Item).Cadena := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'MP'
                                                                     ,'CADENA'
                                                                     ,l_Item);
      l_Trama_Mp(l_Item).Numero_Local := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'MP'
                                                                           ,'NUMERO_LOCAL'
                                                                           ,l_Item);
      l_Trama_Mp(l_Item).Numero_Pos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'MP'
                                                                         ,'NUMERO_POS'
                                                                         ,l_Item);
      l_Trama_Mp(l_Item).Destino := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'MP'
                                                                      ,'DESTINO'
                                                                      ,l_Item);
      l_Trama_Mp(l_Item).Sistema := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'MP'
                                                                      ,'SISTEMA'
                                                                      ,l_Item);
      l_Trama_Mp(l_Item).Funcion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'MP'
                                                                      ,'FUNCION'
                                                                      ,l_Item);
      l_Trama_Mp(l_Item).Secuencia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'MP'
                                                                        ,'SECUENCIA'
                                                                        ,l_Item);
      l_Trama_Mp(l_Item).Fecha_Transaccion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'MP'
                                                                                ,'FECHA_TRANSACCION'
                                                                                ,l_Item);
      l_Trama_Mp(l_Item).Correlativo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'MP'
                                                                          ,'CORRELATIVO'
                                                                          ,l_Item);
      l_Trama_Mp(l_Item).Numero_Trama := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'MP'
                                                                           ,'NUMERO_TRAMA'
                                                                           ,l_Item);
      l_Trama_Mp(l_Item).Telefono := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'MP'
                                                                       ,'TELEFONO'
                                                                       ,l_Item);
      l_Trama_Mp(l_Item).Bono_Adicional := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'MP'
                                                                             ,'BONO_ADICIONAL'
                                                                             ,l_Item);
      l_Trama_Mp(l_Item).Decimal_Badicional := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                         ,'MP'
                                                                                         ,'DECIMAL_BADICIONAL'
                                                                                         ,l_Item)
                                                      ,'-'
                                                      ,'0');
      l_Trama_Mp(l_Item).Bono_Adicional := To_Number(l_Trama_Mp(l_Item).Bono_Adicional || '.' || l_Trama_Mp(l_Item).Decimal_Badicional
                                                    ,'999999999999.9999');

      l_Trama_Mp(l_Item).Nuevo_Saldo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'MP'
                                                                          ,'NUEVO_SALDO'
                                                                          ,l_Item);
      l_Trama_Mp(l_Item).Decimal_Nsaldo := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'MP'
                                                                                     ,'DECIMAL_NSALDO'
                                                                                     ,l_Item)
                                                  ,'-'
                                                  ,'0');
      l_Trama_Mp(l_Item).Nuevo_Saldo := To_Number(l_Trama_Mp(l_Item).Nuevo_Saldo || '.' || l_Trama_Mp(l_Item).Decimal_Nsaldo
                                                 ,'999999999999.9999');

      l_Trama_Mp(l_Item).Dias_Vigencia := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MP'
                                                                            ,'DIAS_VIGENCIA'
                                                                            ,l_Item);
      l_Trama_Mp(l_Item).Id_Unico := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'MP'
                                                                       ,'ID_UNICO'
                                                                       ,l_Item);
      l_Trama_Mp(l_Item).Incluido_En_Journal := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'MP'
                                                                                  ,'INCLUIDO_EN_JOURNAL'
                                                                                  ,l_Item);
      l_Trama_Mp(l_Item).Forma_Pago := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'MP'
                                                                         ,'FORMA_PAGO'
                                                                         ,l_Item);
      l_Trama_Mp(l_Item).Descuento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'MP'
                                                                        ,'DESCUENTO'
                                                                        ,l_Item);
    END LOOP;
    RETURN l_Trama_Mp;
  END;

  FUNCTION Carga_Trama_Nc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Nc IS
    l_Trama_Nc Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Nc;
  BEGIN
    l_Trama_Nc.Convenio               := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'NC'
                                                                           ,'CONVENIO');
    l_Trama_Nc.Plan                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'NC'
                                                                           ,'PLAN');
    l_Trama_Nc.Rut                    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'NC'
                                                                           ,'RUT');
    l_Trama_Nc.Digito_Verificador_Rut := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'NC'
                                                                           ,'DIGITO_VERIFICADOR_RUT');
    l_Trama_Nc.Secuencia_b            := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'NC'
                                                                           ,'SECUENCIA_B');
    l_Trama_Nc.Rut_Medico             := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'NC'
                                                                           ,'RUT_MEDICO');
    l_Trama_Nc.Dv_Rut_Medico          := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'NC'
                                                                           ,'DV_RUT_MEDICO');
    l_Trama_Nc.Monto                  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'NC'
                                                                           ,'MONTO');
    l_Trama_Nc.Cantidad_Cuotas        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'NC'
                                                                           ,'CANTIDAD_CUOTAS');
    RETURN l_Trama_Nc;
  END;

  FUNCTION Carga_Trama_Nd(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Nd IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Nd Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Nd;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'ND'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Nd(l_Item).Folio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'ND'
                                                                    ,'FOLIO'
                                                                    ,l_Item);
      l_Trama_Nd(l_Item).Tipo_Nomina := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'ND'
                                                                          ,'TIPO_NOMINA'
                                                                          ,l_Item);
      l_Trama_Nd(l_Item).Fecha_Nomina := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'ND'
                                                                           ,'FECHA_NOMINA'
                                                                           ,l_Item);
      l_Trama_Nd(l_Item).Rut_Supervisor := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'ND'
                                                                             ,'RUT_SUPERVISOR'
                                                                             ,l_Item);
      l_Trama_Nd(l_Item).Dv_Supervisor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'ND'
                                                                            ,'DV_SUPERVISOR'
                                                                            ,l_Item);
      l_Trama_Nd(l_Item).Estado_Nomina := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'ND'
                                                                            ,'ESTADO_NOMINA'
                                                                            ,l_Item);
      l_Trama_Nd(l_Item).Fecha_Estado := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'ND'
                                                                           ,'FECHA_ESTADO'
                                                                           ,l_Item);
      l_Trama_Nd(l_Item).Monto_Nomina := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'ND'
                                                                           ,'MONTO_NOMINA'
                                                                           ,l_Item);
      l_Trama_Nd(l_Item).Cantidad_Items := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'ND'
                                                                             ,'CANTIDAD_ITEMS'
                                                                             ,l_Item);
      l_Trama_Nd(l_Item).Subtrama_Nd1 := Carga_Trama_Nd1(p_Cuerpo_Tx
                                                        ,l_Trama_Nd(l_Item).Cantidad_Items
                                                        ,l_Item);
    END LOOP;
    RETURN l_Trama_Nd;
  END;

  FUNCTION Carga_Trama_Nd1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Nd1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Nd1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Nd1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Nd1(l_Item).Num_Item := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'ND1'
                                                                        ,'NUM_ITEM'
                                                                        ,l_Item
                                                                        ,p_Ind);
      l_Trama_Nd1(l_Item).Folio_Dicc := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'ND1'
                                                                          ,'FOLIO_DICC'
                                                                          ,l_Item
                                                                          ,p_Ind);
      l_Trama_Nd1(l_Item).Monto_Dicc := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'ND1'
                                                                          ,'MONTO_DICC'
                                                                          ,l_Item
                                                                          ,p_Ind);
    END LOOP;
    RETURN l_Trama_Nd1;
  END;

  FUNCTION Carga_Trama_Nr(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Nr IS
    l_Trama_Nr Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Nr;
  BEGIN
    l_Trama_Nr.Codigo_Autorizacion         := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'NR'
                                                                                ,'CODIGO_AUTORIZACION');
    l_Trama_Nr.Codigo_Autorizacion_Externo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'NR'
                                                                                ,'CODIGO_AUTORIZACION_EXTERNO');
    l_Trama_Nr.Interes                     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'NR'
                                                                                ,'INTERES');
    RETURN l_Trama_Nr;
  END;

  FUNCTION Carga_Trama_Nv(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Nv IS
    l_Trama_Nv Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Nv;
  BEGIN
    l_Trama_Nv.Tipo_Movimiento_Padre   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'NV'
                                                                            ,'TIPO_MOVIMIENTO_PADRE');
    l_Trama_Nv.Tipo_Movimiento_Hijo    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'NV'
                                                                            ,'TIPO_MOVIMIENTO_HIJO');
    l_Trama_Nv.Folio                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'NV'
                                                                            ,'FOLIO');
    l_Trama_Nv.Numero_Folio_Original   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'NV'
                                                                            ,'NUMERO_FOLIO_ORIGINAL');
    l_Trama_Nv.Fecha_Folio_Original    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'NV'
                                                                            ,'FECHA_FOLIO_ORIGINAL');
    l_Trama_Nv.Motivo                  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'NV'
                                                                            ,'MOTIVO');
    l_Trama_Nv.Accion_Sobre_Existencia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'NV'
                                                                            ,'ACCION_SOBRE_EXISTENCIA');
    l_Trama_Nv.Monto                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'NV'
                                                                            ,'MONTO');
    l_Trama_Nv.Cantidad_Productos      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'NV'
                                                                            ,'CANTIDAD_PRODUCTOS');
    l_Trama_Nv.Subtrama_Nv1            := Carga_Trama_Nv1(p_Cuerpo_Tx
                                                         ,l_Trama_Nv.Cantidad_Productos);
    RETURN l_Trama_Nv;
  END;

  FUNCTION Carga_Trama_Nv1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Nv1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Nv1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Nv1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Nv1(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'NV1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item);
      l_Trama_Nv1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'NV1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
      l_Trama_Nv1(l_Item).Precio_Final := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'NV1'
                                                                            ,'PRECIO_FINAL'
                                                                            ,l_Item);
      l_Trama_Nv1(l_Item).Costo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'NV1'
                                                                     ,'COSTO'
                                                                     ,l_Item);
      l_Trama_Nv1(l_Item).Codigo_Personal := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'NV1'
                                                                               ,'CODIGO_PERSONAL'
                                                                               ,l_Item);
      l_Trama_Nv1(l_Item).Rut_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'NV1'
                                                                            ,'RUT_VENDEDOR'
                                                                            ,l_Item);
      l_Trama_Nv1(l_Item).Dv_Rut_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'NV1'
                                                                               ,'DV_RUT_VENDEDOR'
                                                                               ,l_Item);
      l_Trama_Nv1(l_Item).Precio_Lista := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'NV1'
                                                                            ,'PRECIO_LISTA'
                                                                            ,l_Item);
      /*      l_Trama_Nv1(l_Item).Codigo_Reclamo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
      ,'NV1'
      ,'CODIGO_RECLAMO'
      ,l_Item);*/
      -- ctm 06-06-2016
      l_Trama_Nv1(l_Item).Motivo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'NV1'
                                                                      ,'CODIGO_RECLAMO'
                                                                      ,l_Item);

    END LOOP;
    RETURN l_Trama_Nv1;
  END;

  FUNCTION Carga_Trama_Oc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Oc IS
    l_Trama_Oc Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Oc;
  BEGIN
    l_Trama_Oc.Numero_Orden_Trabajo := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'OC'
                                                                              ,'NUMERO_ORDEN_TRABAJO'));
    l_Trama_Oc.Fecha_Hasta          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'OC'
                                                                         ,'FECHA_HASTA');
    l_Trama_Oc.Valor_Total          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'OC'
                                                                         ,'VALOR_TOTAL');
    l_Trama_Oc.Local_Recetario      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'OC'
                                                                         ,'LOCAL_RECETARIO');
    l_Trama_Oc.Fecha_Compromiso     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'OC'
                                                                         ,'FECHA_COMPROMISO');
    RETURN l_Trama_Oc;
  END;

  FUNCTION Carga_Trama_Or(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Or IS
    l_Trama_Or Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Or;
  BEGIN
    l_Trama_Or.Numero_Orden_Trabajo          := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                       ,'OR'
                                                                                       ,'NUMERO_ORDEN_TRABAJO'));
    l_Trama_Or.Secuencia_Receta              := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'SECCUENCIA_RECETA');
    l_Trama_Or.Fecha_Receta                  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'FECHA_RECETA');
    l_Trama_Or.Serie_Cheque                  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'SERIE_CHEQUE');
    l_Trama_Or.Numero_Cheque                 := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'NUMERO_CHEQUE');
    l_Trama_Or.Rut_Medico                    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'RUT_MEDICO');
    l_Trama_Or.Digito_Verificador_Medico     := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'DV_MEDICO');
    l_Trama_Or.Nombre_Medico                 := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'NOMBRE_MEDICO');
    l_Trama_Or.Rut_Paciente                  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'RUT_PACIENTE');
    l_Trama_Or.Digito_Verificador_Paciente   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'DV_PACIENTE');
    l_Trama_Or.Nombre_Paciente               := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'NOMBRE_PACIENTE');
    l_Trama_Or.Direccion_Paciente            := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'DIRECCION_PACIENTE');
    l_Trama_Or.Telefono                      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'TELEFONO');
    l_Trama_Or.Rut_Adquirente                := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'RUT_ADQUIRENTE');
    l_Trama_Or.Digito_Verificador_Adquirente := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'DV_ADQUIRENTE');
    l_Trama_Or.Nombre_Adquirente             := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'NOMBRE_ADQUIRENTE');
    l_Trama_Or.Monto_Abono                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'MONTO_ABONO');
    l_Trama_Or.Fecha_Abono                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'FECHA_ABONO');
    l_Trama_Or.Descuento                     := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'DESCUENTO');
    l_Trama_Or.Retiro                        := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'RETIRO');
    l_Trama_Or.Local                         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'LOCAL');
    l_Trama_Or.Observacion                   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'OBSERVACION');
    l_Trama_Or.Codigo_Vendedor               := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'CODIGO_VENDEDOR');
    l_Trama_Or.Nombre_Vendedor               := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'NOMBRE_VENDEDOR');
    l_Trama_Or.Codigo_Qf                     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'CODIGO_QF');
    l_Trama_Or.Nombre_Qf                     := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'OR'
                                                                                  ,'NOMBRE_QF');
    RETURN l_Trama_Or;
  END;

  FUNCTION Carga_Trama_Ot(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ot IS
    l_Trama_Ot Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ot;
  BEGIN
    l_Trama_Ot.Cantidad_Ordenes_Trabajo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'OT'
                                                                             ,'CANTIDAD_ORDENES_TRABAJO');
    l_Trama_Ot.Subtrama_Ot1             := Carga_Trama_Ot1(p_Cuerpo_Tx
                                                          ,l_Trama_Ot.Cantidad_Ordenes_Trabajo);
    RETURN l_Trama_Ot;
  END;

  FUNCTION Carga_Trama_Ot1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ot1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Ot1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ot1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Ot1(l_Item).Numero_Orden_Trabajo := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                         ,'OT1'
                                                                                         ,'NUMERO_ORDEN_TRABAJO'
                                                                                         ,l_Item));
    END LOOP;
    RETURN l_Trama_Ot1;
  END;

  FUNCTION Carga_Trama_Vo(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vo IS
    l_Trama_Vo Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vo;
  BEGIN
    l_Trama_Vo.Hora_Presentacion_Pop_Up := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'VO'
                                                                             ,'HORA_PRESENTACION_POP_UP');
    l_Trama_Vo.Hora_Seleccion_Opcion    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'VO'
                                                                             ,'HORA_SELECCION_OPCION');
    l_Trama_Vo.Convenio                 := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'VO'
                                                                             ,'CONVENIO');
    l_Trama_Vo.Opcion_Seleccionada      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'VO'
                                                                             ,'OPCION_SELECCIONADA');
    l_Trama_Vo.Rut_Cliente              := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'VO'
                                                                             ,'RUT_CLIENTE');
    l_Trama_Vo.Rut_Vendedor             := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'VO'
                                                                             ,'RUT_VENDEDOR');
    RETURN l_Trama_Vo;
  END;

  FUNCTION Carga_Trama_Pa(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pa IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Pa Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pa;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'PA'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Pa(l_Item).Uso_Frecuente := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PA'
                                                                            ,'USO_FRECUENTE'
                                                                            ,l_Item);
      l_Trama_Pa(l_Item).Ofrecido := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PA'
                                                                       ,'OFRECIDO'
                                                                       ,l_Item);
      l_Trama_Pa(l_Item).Estado_Crm := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'PA'
                                                                         ,'ESTADO_CRM'
                                                                         ,l_Item);
    END LOOP;
    RETURN l_Trama_Pa;
  END;

  FUNCTION Carga_Trama_Pb(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pb IS
    l_Trama_Pb Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pb;
  BEGIN
    l_Trama_Pb.Uso_Frecuente      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PB'
                                                                       ,'USO_FRECUENTE');
    l_Trama_Pb.Rut_Medico         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PB'
                                                                       ,'RUT_MEDICO');
    l_Trama_Pb.Dv_Rut_Medico      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PB'
                                                                       ,'DV_RUT_MEDICO');
    l_Trama_Pb.Folio              := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PB'
                                                                       ,'FOLIO');
    l_Trama_Pb.Rut_Vendedor       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PB'
                                                                       ,'RUT_VENDEDOR');
    l_Trama_Pb.Dv_Rut_Vendedor    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PB'
                                                                       ,'DV_RUT_VENDEDOR');
    l_Trama_Pb.Numero_Inscripcion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PB'
                                                                       ,'NUMERO_INSCRIPCION');
    l_Trama_Pb.Fecha_Expiracion   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PB'
                                                                       ,'FECHA_EXPIRACION');
    RETURN l_Trama_Pb;
  END;

  FUNCTION Carga_Trama_Pc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pc IS
    l_Trama_Pc Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pc;
  BEGIN
    l_Trama_Pc.Producto           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PC'
                                                                       ,'PRODUCTO');
    l_Trama_Pc.Producto_Premio    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PC'
                                                                       ,'PRODUCTO_PREMIO');
    l_Trama_Pc.Meta_Compra        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PC'
                                                                       ,'META_COMPRA');
    l_Trama_Pc.Cantidad_a_Regalar := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PC'
                                                                       ,'CANTIDAD_A_REGALAR');
    l_Trama_Pc.Campana            := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PC'
                                                                       ,'CAMPANA');
    l_Trama_Pc.Uso_Frecuente      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PC'
                                                                       ,'USO_FRECUENTE');
    l_Trama_Pc.Tipo_Descuento     := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PC'
                                                                       ,'TIPO_DESCUENTO');
    l_Trama_Pc.Descuento          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PC'
                                                                       ,'DESCUENTO');
    RETURN l_Trama_Pc;
  END;

  FUNCTION Carga_Trama_Pd(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pd IS
    l_Trama_Pd Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pd;
  BEGIN
    l_Trama_Pd.Rut_Beneficiario       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PD'
                                                                           ,'RUT_BENEFICIARIO');
    l_Trama_Pd.Digito_Verificador_Rut := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PD'
                                                                           ,'DIGITO_VERIFICADOR_RUT');
    l_Trama_Pd.Fecha_Inicio           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PD'
                                                                           ,'FECHA_INICIO');
    l_Trama_Pd.Fecha_Termino          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PD'
                                                                           ,'FECHA_TERMINO');
    RETURN l_Trama_Pd;
  END;

  FUNCTION Carga_Trama_Pe(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pe IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Pe Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pe;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'PE'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Pe(l_Item).Id_Periodo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'PE'
                                                                         ,'ID_PERIODO'
                                                                         ,l_Item);
      l_Trama_Pe(l_Item).Fecha_Inicio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PE'
                                                                           ,'FECHA_INICIO'
                                                                           ,l_Item);
      l_Trama_Pe(l_Item).Fecha_Termino := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PE'
                                                                            ,'FECHA_TERMINO'
                                                                            ,l_Item);
      l_Trama_Pe(l_Item).Monto_Copago := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PE'
                                                                           ,'MONTO_COPAGO'
                                                                           ,l_Item);
      l_Trama_Pe(l_Item).Decimal_Copago := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'PE'
                                                                                     ,'DECIMAL_COPAGO'
                                                                                     ,l_Item)
                                                  ,'-'
                                                  ,'0');
      l_Trama_Pe(l_Item).Monto_Copago := To_Number(l_Trama_Pe(l_Item).Monto_Copago || '.' || l_Trama_Pe(l_Item).Decimal_Copago
                                                  ,'999999999999.9999');

      l_Trama_Pe(l_Item).Folio_Bono := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'PE'
                                                                         ,'FOLIO_BONO'
                                                                         ,l_Item);
      l_Trama_Pe(l_Item).Folio_Copago := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PE'
                                                                           ,'FOLIO_COPAGO'
                                                                           ,l_Item);
      l_Trama_Pe(l_Item).Periodo_Desmarcable := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'PE'
                                                                                  ,'PERIODO_DESMARCABLE'
                                                                                  ,l_Item);
    END LOOP;
    RETURN l_Trama_Pe;
  END;

  FUNCTION Carga_Trama_Pf(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pf IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Pf Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pf;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'PF'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Pf(l_Item).Uso_Frecuente := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PF'
                                                                            ,'USO_FRECUENTE'
                                                                            ,l_Item);
      l_Trama_Pf(l_Item).Evento_Actual := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PF'
                                                                            ,'EVENTO_ACTUAL'
                                                                            ,l_Item);
      l_Trama_Pf(l_Item).Campana := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'PF'
                                                                      ,'CAMPANA'
                                                                      ,l_Item);
      l_Trama_Pf(l_Item).Eventos_Cumplidos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'PF'
                                                                                ,'EVENTOS_CUMPLIDOS'
                                                                                ,l_Item);
      l_Trama_Pf(l_Item).Fecha_Vencimiento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'PF'
                                                                                ,'FECHA_VENCIMIENTO'
                                                                                ,l_Item);
    END LOOP;
    RETURN l_Trama_Pf;
  END;

  FUNCTION Carga_Trama_Pg(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pg IS
    l_Trama_Pg Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pg;
  BEGIN
    l_Trama_Pg.Correlativo_Tx     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PG'
                                                                       ,'CORRELATIVO_TX');
    l_Trama_Pg.Cantidad_Productos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PG'
                                                                       ,'CANTIDAD_PRODUCTOS');
    l_Trama_Pg.Subtrama_Pg1       := Carga_Trama_Pg1(p_Cuerpo_Tx
                                                    ,l_Trama_Pg.Cantidad_Productos);
    RETURN l_Trama_Pg;
  END;

  FUNCTION Carga_Trama_Pg1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pg1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Pg1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pg1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Pg1(l_Item).Folio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'PG1'
                                                                     ,'FOLIO'
                                                                     ,l_Item);
      l_Trama_Pg1(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'PG1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item);
      l_Trama_Pg1(l_Item).Uso_Frecuente := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'PG1'
                                                                             ,'USO_FRECUENTE'
                                                                             ,l_Item);
      l_Trama_Pg1(l_Item).Cantidad_Acumulada_Psalud := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                         ,'PG1'
                                                                                         ,'CANTIDAD_ACUMULADA_PSALUD'
                                                                                         ,l_Item);
      l_Trama_Pg1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'PG1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
      l_Trama_Pg1(l_Item).Porcentaje_Descuento := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'PG1'
                                                                                    ,'PORCENTAJE_DESCUENTO'
                                                                                    ,l_Item);
      l_Trama_Pg1(l_Item).Detalle_Descuento_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'PG1'
                                                                                          ,'DETALLE_DESCUENTO_PRODUCTO'
                                                                                          ,l_Item);
    END LOOP;
    RETURN l_Trama_Pg1;
  END;

  FUNCTION Carga_Trama_Pi(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pi IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Pi Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pi;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'PI'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Pi(l_Item).Tipo_Movimiento_Padre := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'PI'
                                                                                    ,'TIPO_MOVIMIENTO_PADRE'
                                                                                    ,l_Item);
      l_Trama_Pi(l_Item).Tipo_Movimiento_Hijo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'PI'
                                                                                   ,'TIPO_MOVIMIENTO_HIJO'
                                                                                   ,l_Item);
      l_Trama_Pi(l_Item).Folio := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'PI'
                                                                         ,'FOLIO'
                                                                         ,l_Item));
      l_Trama_Pi(l_Item).Guia_Despacho := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'PI'
                                                                                 ,'GUIA_DESPACHO'
                                                                                 ,l_Item));
      l_Trama_Pi(l_Item).Tipo_Guia_Despacho := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'PI'
                                                                                 ,'TIPO_GUIA_DESPACHO'
                                                                                 ,l_Item);
      l_Trama_Pi(l_Item).Accion_Sobre_Existencia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'PI'
                                                                                      ,'ACCION_SOBRE_EXISTENCIA'
                                                                                      ,l_Item);
      l_Trama_Pi(l_Item).Numero_Folio_Original := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                         ,'PI'
                                                                                         ,'NUMERO_FOLIO_ORIGINAL'
                                                                                         ,l_Item));
      l_Trama_Pi(l_Item).Fecha_Folio_Original := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'PI'
                                                                                   ,'FECHA_FOLIO_ORIGINAL'
                                                                                   ,l_Item);
      l_Trama_Pi(l_Item).Ot := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                 ,'PI'
                                                                 ,'OT'
                                                                 ,l_Item);
      l_Trama_Pi(l_Item).Valor_Recetario := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PI'
                                                                              ,'VALOR_RECETARIO'
                                                                              ,l_Item);
      l_Trama_Pi(l_Item).Decimal_Valor_Recetario := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                              ,'PI'
                                                                                              ,'DECIMAL_VALOR_RECETARIO'
                                                                                              ,l_Item)
                                                           ,'-'
                                                           ,'0');
      l_Trama_Pi(l_Item).Valor_Recetario := To_Number(l_Trama_Pi(l_Item).Valor_Recetario || '.' || l_Trama_Pi(l_Item).Decimal_Valor_Recetario
                                                     ,'999999999999.9999');

      -- JRC 19/12/2019
      l_Trama_Pi(l_Item).Motivo := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'PI'
                                                                          ,'MOTIVO'
                                                                          ,l_Item));

      l_Trama_Pi(l_Item).Tipo_Negocio := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PI'
                                                                           ,'TIPO_NEGOCIO'
                                                                           ,l_Item);

      l_Trama_Pi(l_Item).Tipo_Transferencia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'PI'
                                                                                 ,'TIPO_TRANSFERENCIA'
                                                                                 ,l_Item);

      l_Trama_Pi(l_Item).Idtransportista := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PI'
                                                                              ,'IDTRANSPORTISTA'
                                                                              ,l_Item);
      l_Trama_Pi(l_Item).Nombre_Transportista := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'PI'
                                                                                   ,'NOMBRE_TRANSPORTISTA'
                                                                                   ,l_Item);
      l_Trama_Pi(l_Item).Placa_Transportista := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'PI'
                                                                                  ,'PLACA_TRANSPORTISTA'
                                                                                  ,l_Item);
      l_Trama_Pi(l_Item).Clave_Acceso := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PI'
                                                                           ,'CLAVE_ACCESO'
                                                                           ,l_Item);

      l_Trama_Pi(l_Item).Serie := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'PI'
                                                                    ,'SERIE'
                                                                    ,l_Item);

      l_Trama_Pi(l_Item).Comprobante := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'PI'
                                                                          ,'COMPROBANTE'
                                                                          ,l_Item);

      l_Trama_Pi(l_Item).Codigo_Numerico := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PI'
                                                                              ,'CODIGO_NUMERICO'
                                                                              ,l_Item);
      l_Trama_Pi(l_Item).Numero_Resolucion := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'PI'
                                                                                     ,'NUMERO_RESOLUCION'
                                                                                     ,l_Item));

      l_Trama_Pi(l_Item).Agente_Retencion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'PI'
                                                                               ,'AGENTE_RETENCION'
                                                                               ,l_Item);

      l_Trama_Pi(l_Item).Microempresa := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PI'
                                                                           ,'MICROEMPRESA'
                                                                           ,l_Item);
      l_Trama_Pi(l_Item).Local_Origen := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PI'
                                                                           ,'LOCAL_ORIGEN'
                                                                           ,l_Item);
      l_Trama_Pi(l_Item).Local_Destino := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PI'
                                                                            ,'LOCAL_DESTINO'
                                                                            ,l_Item);
      --JRC 27/04/2023 Solo informa la cantidad de productos, no la SubTrama
      l_Trama_Pi(l_Item).Cantidad_Productos_Traspaso := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'PI'
                                                                                          ,'CANTIDAD_PRODUCTOS_TRASPASO'
                                                                                          ,l_Item);
      --
      
      --INI JAGC 20250414 ORIGEN FGI  
      l_Trama_Pi(l_Item).DISPATCH_QR := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'PI'
                                                                                 ,'DISPATCH_QR'
                                                                                 ,l_Item);

      l_Trama_Pi(l_Item).CODIGO_DESPLAZAMIENTO := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'PI'
                                                                                 ,'CODIGO_DESPLAZAMIENTO'
                                                                                 ,l_Item);
      
      l_Trama_Pi(l_Item).USUARIO_EMISOR := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'PI'
                                                                                 ,'USUARIO_EMISOR'
                                                                                 ,l_Item);                                                                                                                                                                  
      --FIN JAGC 20250414 ORIGEN FGI 

      --INI IDHC 20260623 ORIGEN SLV  
   
       l_Trama_Pi(l_Item).OBSERVACION := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'PI'
                                                                                ,'OBSERVACION'
                                                                                ,l_Item));                                                
      --FIN IDHC 20260623 ORIGEN SLV  

      l_Trama_Pi(l_Item).Cantidad_Productos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'PI'
                                                                                 ,'CANTIDAD_PRODUCTOS'
                                                                                 ,l_Item);
      
      l_Trama_Pi(l_Item).Subtrama_Pi1 := Carga_Trama_Pi1(p_Cuerpo_Tx
                                                        ,l_Trama_Pi(l_Item).Cantidad_Productos);
    END LOOP;
    RETURN l_Trama_Pi;
  END;

  --//--------------------------------------------------------------------------\\
  --// CBR 12/27/2019 6:59PM                                                    \\
  --//                                                                          \\
  --//-----------------------------------------------------------------Inicio---\\
  /*
  FUNCTION Carga_Trama_Pi8(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pi8 IS
    l_Trama_Pi Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pi8;
  BEGIN
    l_Trama_Pi.Tipo_Movimiento_Padre   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PI'
                                                                            ,'TIPO_MOVIMIENTO_PADRE');
    l_Trama_Pi.Tipo_Movimiento_Hijo    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PI'
                                                                            ,'TIPO_MOVIMIENTO_HIJO');
    l_Trama_Pi.Folio                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PI'
                                                                            ,'FOLIO');
    l_Trama_Pi.Guia_Despacho           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PI'
                                                                            ,'GUIA_DESPACHO');
    l_Trama_Pi.Tipo_Guia_Despacho      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PI'
                                                                            ,'TIPO_GUIA_DESPACHO');
    l_Trama_Pi.Accion_Sobre_Existencia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PI'
                                                                            ,'ACCION_SOBRE_EXISTENCIA');
    l_Trama_Pi.Numero_Folio_Original   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PI'
                                                                            ,'NUMERO_FOLIO_ORIGINAL');
    l_Trama_Pi.Fecha_Folio_Original    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PI'
                                                                            ,'FECHA_FOLIO_ORIGINAL');
    l_Trama_Pi.Ot                      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PI'
                                                                            ,'OT');
    l_Trama_Pi.Valor_Recetario         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PI'
                                                                            ,'VALOR_RECETARIO');
    l_Trama_Pi.Cantidad_Productos      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PI'
                                                                            ,'CANTIDAD_PRODUCTOS');
    l_Trama_Pi.Subtrama_Pi2            := Carga_Trama_Pi2(p_Cuerpo_Tx
                                                         ,l_Trama_Pi.Cantidad_Productos);
    RETURN l_Trama_Pi;
  END;

    -- JRC 19/12/2019 Pi3 <> a Pi8 solo por el campo Motivo
    FUNCTION Carga_Trama_Pi3(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pi3 IS
      l_Trama_Pi Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pi3;
    BEGIN
      l_Trama_Pi.Tipo_Movimiento_Padre   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PI'
                                                                              ,'TIPO_MOVIMIENTO_PADRE');
      l_Trama_Pi.Tipo_Movimiento_Hijo    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PI'
                                                                              ,'TIPO_MOVIMIENTO_HIJO');
      l_Trama_Pi.Folio                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PI'
                                                                              ,'FOLIO');
      l_Trama_Pi.Guia_Despacho           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PI'
                                                                              ,'GUIA_DESPACHO');
      l_Trama_Pi.Tipo_Guia_Despacho      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PI'
                                                                              ,'TIPO_GUIA_DESPACHO');
      l_Trama_Pi.Accion_Sobre_Existencia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PI'
                                                                              ,'ACCION_SOBRE_EXISTENCIA');
      l_Trama_Pi.Numero_Folio_Original   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PI'
                                                                              ,'NUMERO_FOLIO_ORIGINAL');
      l_Trama_Pi.Fecha_Folio_Original    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PI'
                                                                              ,'FECHA_FOLIO_ORIGINAL');
      l_Trama_Pi.Ot                      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PI'
                                                                              ,'OT');
      l_Trama_Pi.Valor_Recetario         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PI'
                                                                              ,'VALOR_RECETARIO');
      -- JRC 19/12/2019
      l_Trama_Pi.Motivo := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                             ,'PI'
                                                             ,'MOTIVO'));
      --
      l_Trama_Pi.Cantidad_Productos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'PI'
                                                                         ,'CANTIDAD_PRODUCTOS');
      l_Trama_Pi.Subtrama_Pi2       := Carga_Trama_Pi2(p_Cuerpo_Tx
                                                      ,l_Trama_Pi.Cantidad_Productos);
      RETURN l_Trama_Pi;
    END;
    --
  */
  --//-----------------------------------------------------------------Termino--\\
  FUNCTION Carga_Trama_Pi1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pi1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Pi1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pi1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Pi1(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'PI1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item);
      l_Trama_Pi1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'PI1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
      l_Trama_Pi1(l_Item).Costo_Unitario := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PI1'
                                                                              ,'COSTO_UNITARIO'
                                                                              ,l_Item);
      -- FCG 20112020 GUIAS MULTIPLES
      l_Trama_Pi1(l_Item).Decimal_Cunitario := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                         ,'PI1'
                                                                                         ,'DECIMAL_CUNITARIO'
                                                                                         ,l_Item)
                                                      ,'-'
                                                      ,'0');
      l_Trama_Pi1(l_Item).Costo_Unitario := To_Number(l_Trama_Pi1(l_Item).Costo_Unitario || '.' || l_Trama_Pi1(l_Item).Decimal_Cunitario
                                                     ,'999999999999.9999');
      ---
      l_Trama_Pi1(l_Item).Lote := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'PI1'
                                                                    ,'LOTE'
                                                                    ,l_Item);

      l_Trama_Pi1(l_Item).Fecha_Vencimiento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'PI1'
                                                                                 ,'FECHA_VENCIMIENTO'
                                                                                 ,l_Item);
    END LOOP;
    RETURN l_Trama_Pi1;
  END;

  --//--------------------------------------------------------------------------\\
  --// CBR 12/27/2019 7:01PM                                                    \\
  --//                                                                          \\
  --//-----------------------------------------------------------------Inicio---\\
  /*
  FUNCTION Carga_Trama_Pi2(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pi2 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Pi2 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pi2;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Pi2(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'PI2'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item);
      l_Trama_Pi2(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'PI2'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
      l_Trama_Pi2(l_Item).Costo_Unitario := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PI2'
                                                                              ,'COSTO_UNITARIO'
                                                                              ,l_Item);
      l_Trama_Pi2(l_Item).Lote := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'PI2'
                                                                    ,'LOTE'
                                                                    ,l_Item);
    END LOOP;
    RETURN l_Trama_Pi2;
  END;
  */
  --//-----------------------------------------------------------------Termino--\\

  FUNCTION Carga_Trama_Pl(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pl IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Pl Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pl;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'PL'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Pl(l_Item).Codigo_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PL'
                                                                              ,'CODIGO_PRODUCTO'
                                                                              ,l_Item);
      l_Trama_Pl(l_Item).Dosis := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'PL'
                                                                    ,'DOSIS'
                                                                    ,l_Item);
      l_Trama_Pl(l_Item).Veces := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'PL'
                                                                    ,'VECES'
                                                                    ,l_Item);
      l_Trama_Pl(l_Item).Dias := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'PL'
                                                                   ,'DIAS'
                                                                   ,l_Item);
      l_Trama_Pl(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PL'
                                                                       ,'CANTIDAD'
                                                                       ,l_Item);
      l_Trama_Pl(l_Item).Enviar_Sustituto := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'PL'
                                                                               ,'ENVIAR_SUSTITUTO'
                                                                               ,l_Item);
      l_Trama_Pl(l_Item).Precio_Lista := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PL'
                                                                           ,'PRECIO_LISTA'
                                                                           ,l_Item);
      l_Trama_Pl(l_Item).Precio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'PL'
                                                                     ,'PRECIO'
                                                                     ,l_Item);
      l_Trama_Pl(l_Item).Codigo_Barra := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PL'
                                                                           ,'CODIGO_BARRA'
                                                                           ,l_Item);
      l_Trama_Pl(l_Item).Descuento_Financiado := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'PL'
                                                                                   ,'DESCUENTO_FINANCIADO'
                                                                                   ,l_Item);
      l_Trama_Pl(l_Item).Numero_Retiro := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PL'
                                                                            ,'NUMERO_RETIRO'
                                                                            ,l_Item);

      l_Trama_Pl(l_Item).Decimal_Precio_Lista := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'PL'
                                                                                   ,'DECIMAL_PRECIO_LISTA'
                                                                                   ,l_Item);
      ---------------------------------------------------------------------------------------------------
      --l_Trama_Pl(l_Item).Precio_Lista := To_Number(l_Trama_Pl(l_Item).Precio_Lista || '.' ||
      --                                  l_Trama_Pl(l_Item).Decimal_Precio_Lista,'999999999999.9999');
      ---------------------------------------------------------------------------------------------------
      l_Trama_Pl(l_Item).Decimal_Precio_Final := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'PL'
                                                                                   ,'DECIMAL_PRECIO_FINAL'
                                                                                   ,l_Item);
      l_Trama_Pl(l_Item).Monto_Iva := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'PL'
                                                                        ,'MONTO_IVA'
                                                                        ,l_Item);
      l_Trama_Pl(l_Item).Decimal_Iva := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'PL'
                                                                          ,'DECIMAL_IVA'
                                                                          ,l_Item);
    END LOOP;
    RETURN l_Trama_Pl;
  END;

  FUNCTION Carga_Trama_Pl9(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pl9 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Pl9 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pl9;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'PL'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Pl9(l_Item).Codigo_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'PL'
                                                                               ,'CODIGO_PRODUCTO'
                                                                               ,l_Item);
      l_Trama_Pl9(l_Item).Dosis := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'PL'
                                                                     ,'DOSIS'
                                                                     ,l_Item);
      l_Trama_Pl9(l_Item).Veces := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'PL'
                                                                     ,'VECES'
                                                                     ,l_Item);
      l_Trama_Pl9(l_Item).Dias := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'PL'
                                                                    ,'DIAS'
                                                                    ,l_Item);
      l_Trama_Pl9(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'PL'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
      l_Trama_Pl9(l_Item).Enviar_Sustituto := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'PL'
                                                                                ,'ENVIAR_SUSTITUTO'
                                                                                ,l_Item);
    END LOOP;
    RETURN l_Trama_Pl9;
  END;

  FUNCTION Carga_Trama_Pm(p_Trama_Pos IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Hpo
                         ,p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm IS
    l_Item     NUMBER;
    l_Item1    NUMBER;
    l_Item2    NUMBER;
    l_Item3    NUMBER;
    l_Item4    NUMBER;
    l_Item5    NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Pm Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm;
    l_Trama_Dv Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv;
    p_Iva      NUMBER := 0;
    p_Aplicar  NUMBER := 0;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'PM'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Pm(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PM'
                                                                       ,'PRODUCTO'
                                                                       ,l_Item);
      l_Trama_Pm(l_Item).Codigo_Barra := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PM'
                                                                           ,'CODIGO_BARRA'
                                                                           ,l_Item);
      l_Trama_Pm(l_Item).Uso_Frecuente := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PM'
                                                                            ,'USO_FRECUENTE'
                                                                            ,l_Item);
      l_Trama_Pm(l_Item).Precio_Lista := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PM'
                                                                           ,'PRECIO_LISTA'
                                                                           ,l_Item);
      l_Trama_Pm(l_Item).Decimal_Plista := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'PM'
                                                                                     ,'DECIMAL_PLISTA'
                                                                                     ,l_Item)
                                                  ,'-'
                                                  ,'0');
      l_Trama_Pm(l_Item).Precio_Lista := To_Number(l_Trama_Pm(l_Item).Precio_Lista || '.' || l_Trama_Pm(l_Item).Decimal_Plista
                                                  ,'999999999999.9999');

      l_Trama_Pm(l_Item).Precio_Final := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PM'
                                                                           ,'PRECIO_FINAL'
                                                                           ,l_Item);
      l_Trama_Pm(l_Item).Decimal_Pfinal := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'PM'
                                                                                     ,'DECIMAL_PFINAL'
                                                                                     ,l_Item)
                                                  ,'-'
                                                  ,'0');
      l_Trama_Pm(l_Item).Precio_Final := To_Number(l_Trama_Pm(l_Item).Precio_Final || '.' || l_Trama_Pm(l_Item).Decimal_Pfinal
                                                  ,'999999999999.9999');

      l_Trama_Pm(l_Item).Costo_Unitario := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'PM'
                                                                             ,'COSTO_UNITARIO'
                                                                             ,l_Item);
      l_Trama_Pm(l_Item).Decimal_Cunitario := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                        ,'PM'
                                                                                        ,'DECIMAL_CUNITARIO'
                                                                                        ,l_Item)
                                                     ,'-'
                                                     ,'0');
      l_Trama_Pm(l_Item).Costo_Unitario := To_Number(l_Trama_Pm(l_Item).Costo_Unitario || '.' || l_Trama_Pm(l_Item).Decimal_Cunitario
                                                    ,'999999999999.9999');

      l_Trama_Pm(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PM'
                                                                       ,'CANTIDAD'
                                                                       ,l_Item);
      l_Trama_Pm(l_Item).Decimal_Cantidad := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                       ,'PM'
                                                                                       ,'DECIMAL_CANTIDAD'
                                                                                       ,l_Item)
                                                    ,'-'
                                                    ,'0');
      l_Trama_Pm(l_Item).Cantidad := To_Number(l_Trama_Pm(l_Item).Cantidad || '.' || l_Trama_Pm(l_Item).Decimal_Cantidad
                                              ,'999999999999.9999');

      l_Trama_Pm(l_Item).Cantidad_Acumulada_Psalud := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                        ,'PM'
                                                                                        ,'CANTIDAD_ACUMULADA_PSALUD'
                                                                                        ,l_Item);
      l_Trama_Pm(l_Item).Identi_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PM'
                                                                              ,'IDENTI_VENDEDOR'
                                                                              ,l_Item);
      l_Trama_Pm(l_Item).Rut_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PM'
                                                                           ,'RUT_VENDEDOR'
                                                                           ,l_Item);
      l_Trama_Pm(l_Item).Dv_Rut_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PM'
                                                                              ,'DV_RUT_VENDEDOR'
                                                                              ,l_Item);
      l_Trama_Pm(l_Item).Codigo_Autorizacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'PM'
                                                                                  ,'CODIGO_AUTORIZACION'
                                                                                  ,l_Item);
      l_Trama_Pm(l_Item).Aplicacion_Item := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PM'
                                                                              ,'APLICACION_ITEM'
                                                                              ,l_Item);
      l_Trama_Pm(l_Item).Accion_Sobre_Existencia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'PM'
                                                                                      ,'ACCION_SOBRE_EXISTENCIA'
                                                                                      ,l_Item);
      l_Trama_Pm(l_Item).Saldo_Compra_Frecuente := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'PM'
                                                                                     ,'SALDO_COMPRA_FRECUENTE'
                                                                                     ,l_Item);
      l_Trama_Pm(l_Item).Acumulador_Entrega := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'PM'
                                                                                 ,'ACUMULADOR_ENTREGA'
                                                                                 ,l_Item);
      l_Trama_Pm(l_Item).Numero_Consejo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'PM'
                                                                             ,'NUMERO_CONSEJO'
                                                                             ,l_Item);
      l_Trama_Pm(l_Item).Porcentaje_Bonificacion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'PM'
                                                                                      ,'PORCENTAJE_BONIFICACION'
                                                                                      ,l_Item);
      l_Trama_Pm(l_Item).Cantidad_Canjeada := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'PM'
                                                                                ,'CANTIDAD_CANJEADA'
                                                                                ,l_Item);
      l_Trama_Pm(l_Item).Canje_Transaccion_Origen := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                       ,'PM'
                                                                                       ,'CANJE_TRANSACCION_ORIGEN'
                                                                                       ,l_Item);
      l_Trama_Pm(l_Item).Canje_Local_Origen := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'PM'
                                                                                 ,'CANJE_LOCAL_ORIGEN'
                                                                                 ,l_Item);
      l_Trama_Pm(l_Item).Inscrito_Programa_Salud := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'PM'
                                                                                      ,'INSCRITO_PROGRAMA_SALUD'
                                                                                      ,l_Item);
      l_Trama_Pm(l_Item).Permitido_Por_Convenio := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'PM'
                                                                                     ,'PERMITIDO_POR_CONVENIO'
                                                                                     ,l_Item);
      l_Trama_Pm(l_Item).Campana_Promocion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'PM'
                                                                                ,'CAMPANA_PROMOCION'
                                                                                ,l_Item);
      l_Trama_Pm(l_Item).Campana_Aditiva := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PM'
                                                                              ,'CAMPANA_ADITIVA'
                                                                              ,l_Item);
      l_Trama_Pm(l_Item).Beneficio_Pendiente_Ps := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'PM'
                                                                                     ,'BENEFICIO_PENDIENTE_PS'
                                                                                     ,l_Item);
      l_Trama_Pm(l_Item).Exento_Iva := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'PM'
                                                                         ,'EXENTO_IVA'
                                                                         ,l_Item);
      l_Trama_Pm(l_Item).Controla_Stock := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'PM'
                                                                             ,'CONTROLA_STOCK'
                                                                             ,l_Item);
      l_Trama_Pm(l_Item).Permite_Devolucion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'PM'
                                                                                 ,'PERMITE_DEVOLUCION'
                                                                                 ,l_Item);
      l_Trama_Pm(l_Item).Producto_Original_Demandado := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'PM'
                                                                                          ,'PRODUCTO_ORIGINAL_DEMANDADO'
                                                                                          ,l_Item);
      l_Trama_Pm(l_Item).Secuencia_Receta_Relacionada := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                           ,'PM'
                                                                                           ,'SECUENCIA_RECETA_RELACIONADA'
                                                                                           ,l_Item);
      l_Trama_Pm(l_Item).Porcentaje_Bonif_Informado := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                         ,'PM'
                                                                                         ,'PORCENTAJE_BONIF_INFORMADO'
                                                                                         ,l_Item);
      l_Trama_Pm(l_Item).Monto_Bonif_Informado := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'PM'
                                                                                    ,'MONTO_BONIF_INFORMADO'
                                                                                    ,l_Item);
      l_Trama_Pm(l_Item).Deducible_Aplicado_En_Pesos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'PM'
                                                                                          ,'DEDUCIBLE_APLICADO_EN_PESOS'
                                                                                          ,l_Item);
      l_Trama_Pm(l_Item).Tope_Aplicado_En_Pesos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'PM'
                                                                                     ,'TOPE_APLICADO_EN_PESOS'
                                                                                     ,l_Item);
      l_Trama_Pm(l_Item).Identi_Supervisor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'PM'
                                                                                ,'IDENTI_SUPERVISOR'
                                                                                ,l_Item);
                                                                                
         
      --INI JAGC 20240909 NECESIDADES 'NEC'  
      l_Trama_Pm(l_Item).Nombre_Vendedor      := SUBSTR(TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'PM'
                                                                                     ,'NOMBRE_VENDEDOR'
                                                                                     ,l_Item)), 1, 25);                             
 
      
      --FIN JAGC 20240909 NECESIDADES 'NEC'                                                                           
                                                                                
      l_Trama_Pm(l_Item).Rut_Supervisor := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'PM'
                                                                             ,'RUT_SUPERVISOR'
                                                                             ,l_Item);
      l_Trama_Pm(l_Item).Dv_Rut_Supervisor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'PM'
                                                                                ,'DV_RUT_SUPERVISOR'
                                                                                ,l_Item);
      l_Trama_Pm(l_Item).Deduccion_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'PM'
                                                                                 ,'DEDUCCION_PRODUCTO'
                                                                                 ,l_Item);
      l_Trama_Pm(l_Item).Documentos_Referencia := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'PM'
                                                                                    ,'DOCUMENTOS_REFERENCIA'
                                                                                    ,l_Item);
      l_Trama_Pm(l_Item).Descuentos_Aplicados := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'PM'
                                                                                   ,'DESCUENTOS_APLICADOS'
                                                                                   ,l_Item);
      l_Trama_Pm(l_Item).Puntos_Generados := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'PM'
                                                                               ,'PUNTOS_GENERADOS'
                                                                               ,l_Item);
      l_Trama_Pm(l_Item).Distribucion_Convenio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'PM'
                                                                                    ,'DISTRIBUCION_CONVENIO'
                                                                                    ,l_Item);
      l_Trama_Pm(l_Item).Impuestos_Aplicados := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'PM'
                                                                                  ,'IMPUESTOS_APLICADOS'
                                                                                  ,l_Item);

      l_Trama_Pm(l_Item).Recargas_y_Telepeaje := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'PM'
                                                                                   ,'RECARGAS_TELEPEAJE'
                                                                                   ,l_Item);
      l_Trama_Pm(l_Item).Mejor_Opcion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PM'
                                                                           ,'MEJOR_OPCION'
                                                                           ,l_Item);
      l_Trama_Pm(l_Item).Productos_Controlados := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'PM'
                                                                                    ,'PRODUCTOS_CONTROLADOS'
                                                                                    ,l_Item);
                                                                                    
      --INI JAGC 20240909 NECESIDADES 'NEC'  
                                                                              
      l_Trama_Pm(l_Item).Descuentos_Aplicados_Perdidos      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'PM'
                                                                                    ,'DESCUENTOS_APLICADOS_PERDIDOS'
                                                                                    ,l_Item);                             
      --FIN JAGC 20240909 NECESIDADES 'NEC' 
      
      l_Trama_Pm(l_Item).Subtrama_Pm1 := Carga_Trama_Pm1(p_Cuerpo_Tx
                                                        ,l_Trama_Pm(l_Item).Documentos_Referencia
                                                        ,l_Item);
      l_Trama_Pm(l_Item).Subtrama_Pm2 := Carga_Trama_Pm2(p_Cuerpo_Tx
                                                        ,l_Trama_Pm(l_Item).Descuentos_Aplicados
                                                        ,l_Item);
      l_Trama_Pm(l_Item).Subtrama_Pm3 := Carga_Trama_Pm3(p_Cuerpo_Tx
                                                        ,l_Trama_Pm(l_Item).Puntos_Generados
                                                        ,l_Item);
      l_Trama_Pm(l_Item).Subtrama_Pm4 := Carga_Trama_Pm4(p_Cuerpo_Tx
                                                        ,l_Trama_Pm(l_Item).Distribucion_Convenio
                                                        ,l_Item);
      l_Trama_Pm(l_Item).Subtrama_Pm5 := Carga_Trama_Pm5(p_Cuerpo_Tx
                                                        ,l_Trama_Pm(l_Item).Impuestos_Aplicados
                                                        ,l_Item);
      l_Trama_Pm(l_Item).Subtrama_Pm6 := Carga_Trama_Pm6(p_Cuerpo_Tx
                                                        ,l_Trama_Pm(l_Item).Recargas_y_Telepeaje
                                                        ,l_Item);
      l_Trama_Pm(l_Item).Subtrama_Pm7 := Carga_Trama_Pm7(p_Cuerpo_Tx
                                                        ,l_Trama_Pm(l_Item).Mejor_Opcion
                                                        ,l_Item);
      l_Trama_Pm(l_Item).Subtrama_Pm8 := Carga_Trama_Pm8(p_Cuerpo_Tx
                                                        ,l_Trama_Pm(l_Item).Productos_Controlados
                                                        ,l_Item);
      
      --INI JAGC 20240909 NECESIDADES 'NEC'        
      l_Trama_Pm(l_Item).Subtrama_Pm9 := Carga_Trama_Pm9(p_Cuerpo_Tx
                                                        ,l_Trama_Pm(l_Item).Descuentos_Aplicados_Perdidos
                                                        ,l_Item);
      --FIN JAGC 20240909 NECESIDADES 'NEC'

      
    END LOOP;

    --//--------------------------------------------------------------------------\\
    --// CBR 21/03/2017 10:55                                                     \\
    --// Para las versiones de POS que no incluyen el iva en la GUIA              \\
    --//-----------------------------------------------------------------Inicio---\\
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Cuerpo_Tx
                                     ,'DV') THEN
      l_Trama_Dv := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Dv(p_Trama_Pos
                                                      ,p_Cuerpo_Tx);
      l_Tot_Reg  := l_Trama_Dv.Documentos_Emitidos;
      FOR l_Item IN 1 .. l_Tot_Reg
      LOOP
        IF l_Trama_Dv.Subtrama_Dv1(l_Item).Tipo_Movimiento_Hijo IN ('VENGUI'
                                    ,'ANUGUI') THEN
          p_Aplicar := 1;
        END IF;
      END LOOP;
      IF p_Aplicar = 1 THEN
        IF Scfr_Trx_Dyn_Pk.Agrega_Iva(p_Trama_Pos.Cadena
                                     ,p_Trama_Pos.Empresa
                                     ,p_Trama_Pos.Local
                                     ,p_Iva) = 'SI' THEN
          l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                         ,'PM'
                                                         ,'CANTIDAD_REGISTROS');
          FOR l_Item IN 1 .. l_Tot_Reg
          LOOP
            -- l_Trama_Pm(l_Item).Precio_Lista := Round(l_Trama_Pm(l_Item).Precio_Lista * (1 + p_Iva / 100),0);
            -- l_Trama_Pm(l_Item).Precio_Final := Round(l_Trama_Pm(l_Item).Precio_Final * (1 + p_Iva / 100),0);

            l_Trama_Pm(l_Item).Precio_Lista := Ceil(l_Trama_Pm(l_Item).Precio_Lista * (1 + p_Iva / 100));
            l_Trama_Pm(l_Item).Precio_Final := Ceil(l_Trama_Pm(l_Item).Precio_Final * (1 + p_Iva / 100));
            FOR l_Item1 IN 1 .. l_Trama_Pm(l_Item).Documentos_Referencia
            LOOP
              -- l_Trama_Pm(l_Item).Subtrama_Pm1(l_Item1).Total_Item_Por_Documento := Round(l_Trama_Pm(l_Item).Subtrama_Pm1(l_Item1).Total_Item_Por_Documento * (1 + p_Iva / 100),0);
              l_Trama_Pm(l_Item).Subtrama_Pm1(l_Item1).Total_Item_Por_Documento := Ceil(l_Trama_Pm(l_Item).Subtrama_Pm1(l_Item1)
                                                                                        .Total_Item_Por_Documento * (1 + p_Iva / 100));
            END LOOP;

            FOR l_Item2 IN 1 .. l_Trama_Pm(l_Item).Descuentos_Aplicados
            LOOP
              -- l_Trama_Pm(l_Item).Subtrama_Pm2(l_Item2).Monto_Documento := Round(l_Trama_Pm(l_Item).Subtrama_Pm2(l_Item2).Monto_Documento * (1 + p_Iva / 100),0);
              l_Trama_Pm(l_Item).Subtrama_Pm2(l_Item2).Monto_Documento := Ceil(l_Trama_Pm(l_Item).Subtrama_Pm2(l_Item2)
                                                                               .Monto_Documento * (1 + p_Iva / 100));
            END LOOP;

            FOR l_Item4 IN 1 .. l_Trama_Pm(l_Item).Distribucion_Convenio
            LOOP
              -- l_Trama_Pm(l_Item).Subtrama_Pm4(l_Item4).Monto_Distribucion := Round(l_Trama_Pm(l_Item).Subtrama_Pm4(l_Item4).Monto_Distribucion * (1 + p_Iva / 100),0);
              l_Trama_Pm(l_Item).Subtrama_Pm4(l_Item4).Monto_Distribucion := Ceil(l_Trama_Pm(l_Item).Subtrama_Pm4(l_Item4)
                                                                                  .Monto_Distribucion * (1 + p_Iva / 100));
            END LOOP;
          END LOOP;

        END IF;
      END IF;
    END IF;

    RETURN l_Trama_Pm;
  END;

  FUNCTION Carga_Trama_Pm1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Pm1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Pm1(l_Item).Secuencia_b := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PM1'
                                                                           ,'SECUENCIA_B'
                                                                           ,l_Item
                                                                           ,p_Ind);
      l_Trama_Pm1(l_Item).Total_Item_Por_Documento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                        ,'PM1'
                                                                                        ,'TOTAL_ITEM_POR_DOCUMENTO'
                                                                                        ,l_Item
                                                                                        ,p_Ind);
      l_Trama_Pm1(l_Item).Decimal_Total_Item := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'PM1'
                                                                                          ,'DECIMAL_TOTAL_ITEM'
                                                                                          ,l_Item
                                                                                          ,p_Ind)
                                                       ,'-'
                                                       ,'0');
      l_Trama_Pm1(l_Item).Total_Item_Por_Documento := To_Number(l_Trama_Pm1(l_Item).Total_Item_Por_Documento || '.' || l_Trama_Pm1(l_Item).Decimal_Total_Item
                                                               ,'999999999999.9999');
    END LOOP;
    RETURN l_Trama_Pm1;
  END;

  FUNCTION Carga_Trama_Pm2(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm2 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Pm2 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm2;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Pm2(l_Item).Secuencia_b := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PM2'
                                                                           ,'SECUENCIA_B'
                                                                           ,l_Item
                                                                           ,p_Ind);
      l_Trama_Pm2(l_Item).Tipo_Descuento := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PM2'
                                                                              ,'TIPO_DESCUENTO'
                                                                              ,l_Item
                                                                              ,p_Ind);
      l_Trama_Pm2(l_Item).Campana_o_Convenio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'PM2'
                                                                                  ,'CAMPANA_O_CONVENIO'
                                                                                  ,l_Item
                                                                                  ,p_Ind);
      l_Trama_Pm2(l_Item).Codigo_Cupon := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PM2'
                                                                            ,'CODIGO_CUPON'
                                                                            ,l_Item
                                                                            ,p_Ind);
      l_Trama_Pm2(l_Item).Monto_Documento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'PM2'
                                                                               ,'MONTO_DOCUMENTO'
                                                                               ,l_Item
                                                                               ,p_Ind);
      l_Trama_Pm2(l_Item).Decimal_Monto_Docto := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                           ,'PM2'
                                                                                           ,'DECIMAL_MONTO_DOCTO'
                                                                                           ,l_Item
                                                                                           ,p_Ind)
                                                        ,'-'
                                                        ,'0');
      l_Trama_Pm2(l_Item).Monto_Documento := To_Number(l_Trama_Pm2(l_Item).Monto_Documento || '.' || l_Trama_Pm2(l_Item).Decimal_Monto_Docto
                                                      ,'999999999999.9999');

      l_Trama_Pm2(l_Item).Puntos_Canjeados := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'PM2'
                                                                                ,'PUNTOS_CANJEADOS'
                                                                                ,l_Item
                                                                                ,p_Ind);
      l_Trama_Pm2(l_Item).Convertibilidad_Pesos_Puntos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                            ,'PM2'
                                                                                            ,'CONVERTIBILIDAD_PESOS_PUNTOS'
                                                                                            ,l_Item
                                                                                            ,p_Ind);
      l_Trama_Pm2(l_Item).Tipo_Aplicacion_Descuento := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                         ,'PM2'
                                                                                         ,'TIPO_APLICACION_DESCUENTO'
                                                                                         ,l_Item
                                                                                         ,p_Ind);
      l_Trama_Pm2(l_Item).Id_Descuento_Complementario := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                           ,'PM2'
                                                                                           ,'ID_DESCUENTO_COMPLEMENTARIO'
                                                                                           ,l_Item
                                                                                           ,p_Ind);
                                                                                           
      --INI JAGC 20240909 NECESIDADES 'NEC'  
                                                                              
      --l_Trama_Pm2(l_Item).Det_Descto_Producto      := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
      --                                                                               ,'PM2'
      --                                                                               ,'DET_DESCTO_PRODUCTO'
      --                                                                               ,l_Item
      --                                                                               ,p_Ind));                             
      --FIN JAGC 20240909 NECESIDADES 'NEC'  
                                                                                           
      l_Trama_Pm2(l_Item).Detalle_Descuento_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'PM2'
                                                                                          ,'DETALLE_DESCUENTO_PRODUCTO'
                                                                                          ,l_Item
                                                                                          ,p_Ind);
      l_Trama_Pm2(l_Item).Descuento_Financiado := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'PM2'
                                                                                    ,'DESCUENTO_FINANCIADO'
                                                                                    ,l_Item
                                                                                    ,p_Ind);
      l_Trama_Pm2(l_Item).Secuencia_Financiamiento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                        ,'PM2'
                                                                                        ,'SECUENCIA_FINANCIAMIENTO'
                                                                                        ,l_Item
                                                                                        ,p_Ind);
      l_Trama_Pm2(l_Item).Unidades_Beneficio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'PM2'
                                                                                  ,'UNIDADES_BENEFICIO'
                                                                                  ,l_Item
                                                                                  ,p_Ind);
      l_Trama_Pm2(l_Item).Descuento_Referencial := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'PM2'
                                                                                     ,'DESCUENTO_REFERENCIAL'
                                                                                     ,l_Item
                                                                                     ,p_Ind);
      l_Trama_Pm2(l_Item).Signo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'PM2'
                                                                     ,'SIGNO'
                                                                     ,l_Item
                                                                     ,p_Ind);
      --//--------------------------------------------------------------------------\\
      --// CBR 27/12/2017 13:24 BOX AHORRO                                          \\
      --//-----------------------------------------------------------------Inicio---\\
      l_Trama_Pm2(l_Item).Pertenece_Club := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PM2'
                                                                              ,'PERTENECE_CLUB'
                                                                              ,l_Item
                                                                              ,p_Ind);
      --//-----------------------------------------------------------------Termino--\\
       -- IDHC
      l_Trama_Pm2(l_Item).Promotion_Web := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PM2'
                                                                              ,'PROMOTION_WEB'
                                                                              ,l_Item
                                                                              ,p_Ind);
   
    END LOOP;
    RETURN l_Trama_Pm2;
  END;
  
  -- IDHC
   FUNCTION Carga_Trama_Pm10(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm2 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Pm2 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm2;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Pm2(l_Item).Secuencia_b := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PM2'
                                                                           ,'SECUENCIA_B'
                                                                           ,l_Item
                                                                           ,p_Ind);
      l_Trama_Pm2(l_Item).Tipo_Descuento := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PM2'
                                                                              ,'TIPO_DESCUENTO'
                                                                              ,l_Item
                                                                              ,p_Ind);
      l_Trama_Pm2(l_Item).Campana_o_Convenio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'PM2'
                                                                                  ,'CAMPANA_O_CONVENIO'
                                                                                  ,l_Item
                                                                                  ,p_Ind);
      l_Trama_Pm2(l_Item).Codigo_Cupon := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PM2'
                                                                            ,'CODIGO_CUPON'
                                                                            ,l_Item
                                                                            ,p_Ind);
      l_Trama_Pm2(l_Item).Monto_Documento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'PM2'
                                                                               ,'MONTO_DOCUMENTO'
                                                                               ,l_Item
                                                                               ,p_Ind);
      l_Trama_Pm2(l_Item).Decimal_Monto_Docto := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                           ,'PM2'
                                                                                           ,'DECIMAL_MONTO_DOCTO'
                                                                                           ,l_Item
                                                                                           ,p_Ind)
                                                        ,'-'
                                                        ,'0');
      l_Trama_Pm2(l_Item).Monto_Documento := To_Number(l_Trama_Pm2(l_Item).Monto_Documento || '.' || l_Trama_Pm2(l_Item).Decimal_Monto_Docto
                                                      ,'999999999999.9999');

      l_Trama_Pm2(l_Item).Puntos_Canjeados := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'PM2'
                                                                                ,'PUNTOS_CANJEADOS'
                                                                                ,l_Item
                                                                                ,p_Ind);
      l_Trama_Pm2(l_Item).Convertibilidad_Pesos_Puntos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                            ,'PM2'
                                                                                            ,'CONVERTIBILIDAD_PESOS_PUNTOS'
                                                                                            ,l_Item
                                                                                            ,p_Ind);
      l_Trama_Pm2(l_Item).Tipo_Aplicacion_Descuento := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                         ,'PM2'
                                                                                         ,'TIPO_APLICACION_DESCUENTO'
                                                                                         ,l_Item
                                                                                         ,p_Ind);
      l_Trama_Pm2(l_Item).Id_Descuento_Complementario := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                           ,'PM2'
                                                                                           ,'ID_DESCUENTO_COMPLEMENTARIO'
                                                                                           ,l_Item
                                                                                           ,p_Ind);
      l_Trama_Pm2(l_Item).Detalle_Descuento_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'PM2'
                                                                                          ,'DETALLE_DESCUENTO_PRODUCTO'
                                                                                          ,l_Item
                                                                                          ,p_Ind);
      l_Trama_Pm2(l_Item).Descuento_Financiado := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'PM2'
                                                                                    ,'DESCUENTO_FINANCIADO'
                                                                                    ,l_Item
                                                                                    ,p_Ind);
      l_Trama_Pm2(l_Item).Secuencia_Financiamiento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                        ,'PM2'
                                                                                        ,'SECUENCIA_FINANCIAMIENTO'
                                                                                        ,l_Item
                                                                                        ,p_Ind);
      l_Trama_Pm2(l_Item).Unidades_Beneficio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'PM2'
                                                                                  ,'UNIDADES_BENEFICIO'
                                                                                  ,l_Item
                                                                                  ,p_Ind);
      l_Trama_Pm2(l_Item).Descuento_Referencial := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'PM2'
                                                                                     ,'DESCUENTO_REFERENCIAL'
                                                                                     ,l_Item
                                                                                     ,p_Ind);
      l_Trama_Pm2(l_Item).Signo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'PM2'
                                                                     ,'SIGNO'
                                                                     ,l_Item
                                                                     ,p_Ind);
      --//--------------------------------------------------------------------------\\
      --// CBR 27/12/2017 13:24 BOX AHORRO                                          \\
      --//-----------------------------------------------------------------Inicio---\\
      l_Trama_Pm2(l_Item).Pertenece_Club := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PM2'
                                                                              ,'PERTENECE_CLUB'
                                                                              ,l_Item
                                                                              ,p_Ind);
      --//-----------------------------------------------------------------Termino--\\
      -- IDHC
      l_Trama_Pm2(l_Item).Promotion_Web := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PM2'
                                                                              ,'PROMOTION_WEB'
                                                                              ,l_Item
                                                                              ,p_Ind);
      
    END LOOP;
    RETURN l_Trama_Pm2;
  END;

  FUNCTION Carga_Trama_Pm3(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm3 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Pm3 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm3;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Pm3(l_Item).Campana := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PM3'
                                                                       ,'CAMPANA'
                                                                       ,l_Item
                                                                       ,p_Ind);
      l_Trama_Pm3(l_Item).Puntos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'PM3'
                                                                      ,'PUNTOS'
                                                                      ,l_Item
                                                                      ,p_Ind);
      l_Trama_Pm3(l_Item).Signo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'PM3'
                                                                     ,'SIGNO'
                                                                     ,l_Item
                                                                     ,p_Ind);
      l_Trama_Pm3(l_Item).Vigencia := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'PM3'
                                                                        ,'VIGENCIA'
                                                                        ,l_Item
                                                                        ,p_Ind);
    END LOOP;
    RETURN l_Trama_Pm3;
  END;

  FUNCTION Carga_Trama_Pm4(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm4 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Pm4 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm4;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Pm4(l_Item).Tipo_Distribucion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'PM4'
                                                                                 ,'TIPO_DISTRIBUCION'
                                                                                 ,l_Item
                                                                                 ,p_Ind);
      l_Trama_Pm4(l_Item).Monto_Distribucion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'PM4'
                                                                                  ,'MONTO_DISTRIBUCION'
                                                                                  ,l_Item
                                                                                  ,p_Ind);
      l_Trama_Pm4(l_Item).Decimal_Monto_Distrib := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                             ,'PM4'
                                                                                             ,'DECIMAL_MONTO_DISTRIB'
                                                                                             ,l_Item
                                                                                             ,p_Ind)
                                                          ,'-'
                                                          ,'0');
      l_Trama_Pm4(l_Item).Monto_Distribucion := To_Number(l_Trama_Pm4(l_Item).Monto_Distribucion || '.' || l_Trama_Pm4(l_Item).Decimal_Monto_Distrib
                                                         ,'999999999999.9999');
    END LOOP;
    RETURN l_Trama_Pm4;
  END;

  --//--------------------------------------------------------------------------\\
  --// CBR 28/08/2020 12:37                                                     \\
  --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
  --//-----------------------------------------------------------------Inicio---\\
  FUNCTION Carga_Trama_Pm5(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm5 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Pm5 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm5;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Pm5(l_Item).Codigo_Impuesto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'PM5'
                                                                               ,'CODIGO_IMPUESTO'
                                                                               ,l_Item
                                                                               ,p_Ind);
      l_Trama_Pm5(l_Item).Porcentaje_Impuesto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'PM5'
                                                                                   ,'PORCENTAJE_IMPUESTO'
                                                                                   ,l_Item
                                                                                   ,p_Ind);
      l_Trama_Pm5(l_Item).Decimal_Porc_Impuesto := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                             ,'PM5'
                                                                                             ,'DECIMAL_PORC_IMPUESTO'
                                                                                             ,l_Item
                                                                                             ,p_Ind)
                                                          ,'-'
                                                          ,'0');
      l_Trama_Pm5(l_Item).Porcentaje_Impuesto := To_Number(l_Trama_Pm5(l_Item).Porcentaje_Impuesto || '.' || l_Trama_Pm5(l_Item).Decimal_Porc_Impuesto
                                                          ,'999999999999.9999');

      l_Trama_Pm5(l_Item).Monto_Impuesto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PM5'
                                                                              ,'MONTO_IMPUESTO'
                                                                              ,l_Item
                                                                              ,p_Ind);
      l_Trama_Pm5(l_Item).Decimal_Mto_Impuesto := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                            ,'PM5'
                                                                                            ,'DECIMAL_MTO_IMPUESTO'
                                                                                            ,l_Item
                                                                                            ,p_Ind)
                                                         ,'-'
                                                         ,'0');
      l_Trama_Pm5(l_Item).Monto_Impuesto := To_Number(l_Trama_Pm5(l_Item).Monto_Impuesto || '.' || l_Trama_Pm5(l_Item).Decimal_Mto_Impuesto
                                                     ,'999999999999.9999');
    END LOOP;
    RETURN l_Trama_Pm5;
  END;
  --//-----------------------------------------------------------------Termino--\\

  --//--------------------------------------------------------------------------\\
  --// CBR 26/11/2021 14:22                                                     \\
  --//Nuevas Subtramas de la trma PM                                            \\
  --//-----------------------------------------------------------------Inicio---\\
  FUNCTION Carga_Trama_Pm6(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm6 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Pm6 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm6;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Pm6(l_Item).Secuencia := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'PM6'
                                                                         ,'SECUENCIA'
                                                                         ,l_Item
                                                                         ,p_Ind);
      l_Trama_Pm6(l_Item).Identificacdor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PM6'
                                                                              ,'IDENTIFICADOR'
                                                                              ,l_Item
                                                                              ,p_Ind);
      l_Trama_Pm6(l_Item).Nombre := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'PM6'
                                                                      ,'NOMBRE'
                                                                      ,l_Item
                                                                      ,p_Ind);
      l_Trama_Pm6(l_Item).Monto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'PM6'
                                                                     ,'MONTO'
                                                                     ,l_Item
                                                                     ,p_Ind);
      l_Trama_Pm6(l_Item).Decimal_Monto := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'PM6'
                                                                                     ,'DECIMAL_MONTO'
                                                                                     ,l_Item
                                                                                     ,p_Ind)
                                                  ,'-'
                                                  ,'0');
      l_Trama_Pm6(l_Item).Monto := To_Number(l_Trama_Pm6(l_Item).Monto || '.' || l_Trama_Pm6(l_Item).Decimal_Monto
                                            ,'999999999999.9999');

      l_Trama_Pm6(l_Item).Autorizacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PM6'
                                                                            ,'AUTORIZACION'
                                                                            ,l_Item
                                                                            ,p_Ind);
      l_Trama_Pm6(l_Item).Auditoria := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'PM6'
                                                                         ,'AUDITORIA'
                                                                         ,l_Item
                                                                         ,p_Ind);
      l_Trama_Pm6(l_Item).Tipo_Servicio := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'PM6'
                                                                             ,'TIPO_SERVICIO'
                                                                             ,l_Item
                                                                             ,p_Ind);
    END LOOP;
    RETURN l_Trama_Pm6;
  END;

  FUNCTION Carga_Trama_Pm7(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm7 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Pm7 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm7;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Pm7(l_Item).Sku_Original := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PM7'
                                                                            ,'SKU_ORIGINAL'
                                                                            ,l_Item
                                                                            ,p_Ind);
      l_Trama_Pm7(l_Item).Regla_Calculo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'PM7'
                                                                             ,'REGLA_CALCULO'
                                                                             ,l_Item
                                                                             ,p_Ind);
      l_Trama_Pm7(l_Item).Sku_Sugerido := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PM7'
                                                                            ,'SKU_SUGERIDO'
                                                                            ,l_Item
                                                                            ,p_Ind);
      l_Trama_Pm7(l_Item).Id_Combinacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PM7'
                                                                              ,'ID_COMBINACION'
                                                                              ,l_Item
                                                                              ,p_Ind);
      l_Trama_Pm7(l_Item).Decision_Cliente := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'PM7'
                                                                                ,'DECISION_CLIENTE'
                                                                                ,l_Item
                                                                                ,p_Ind);
    END LOOP;
    RETURN l_Trama_Pm7;
  END;
  --//-----------------------------------------------------------------Termino--\\

  --//--------------------------------------------------------------------------\\
  --// CBR 05-05-2022 4:15                                                      \\
  --// Desarrollos para Mexico subtrama Productos Controlados Origen   'VCO'    \\
  --//                                                                          \\
  --//-----------------------------------------------------------------Inicio---\\
  FUNCTION Carga_Trama_Pm8(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm8 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Pm8 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm8;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Pm8(l_Item).Folio_Receta := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PM8'
                                                                            ,'FOLIO_RECETA'
                                                                            ,l_Item
                                                                            ,p_Ind);
      l_Trama_Pm8(l_Item).Ced_Prof := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'PM8'
                                                                        ,'CED_PROF'
                                                                        ,l_Item
                                                                        ,p_Ind);
      -------------------------------------------------------------------------
      -- LMP 2023 GPF Ecuador para poder manipular caracteres especiales
      -------------------------------------------------------------------------
      l_Trama_Pm8(l_Item).Nombre_Medico := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'PM8'
                                                                                  ,'NOMBRE_MEDICO'
                                                                                  ,l_Item
                                                                                  ,p_Ind));

      l_Trama_Pm8(l_Item).Calle := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'PM8'
                                                                     ,'CALLE'
                                                                     ,l_Item
                                                                     ,p_Ind);
      l_Trama_Pm8(l_Item).Colonia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PM8'
                                                                       ,'COLONIA'
                                                                       ,l_Item
                                                                       ,p_Ind);
      l_Trama_Pm8(l_Item).Cod_Postal := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'PM8'
                                                                          ,'COD_POSTAL'
                                                                          ,l_Item
                                                                          ,p_Ind);
      l_Trama_Pm8(l_Item).Ciudad := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'PM8'
                                                                      ,'CIUDAD'
                                                                      ,l_Item
                                                                      ,p_Ind);
      l_Trama_Pm8(l_Item).Municipio := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'PM8'
                                                                         ,'MUNICIPIO'
                                                                         ,l_Item
                                                                         ,p_Ind);
      l_Trama_Pm8(l_Item).Folio_Correlativo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'PM8'
                                                                                 ,'FOLIO_CORRELATIVO'
                                                                                 ,l_Item
                                                                                 ,p_Ind);
    END LOOP;
    RETURN l_Trama_Pm8;
  END;
  --//-----------------------------------------------------------------Termino--\\
  
  --INI JAGC 20240909 NECESIDADES 'NEC'  
  -------------------------------------------------------------------------
  --SubTrama PM9 2024 JAGC Descuentos Aplicados Perdidoso Necesidades
  -------------------------------------------------------------------------  
  FUNCTION Carga_Trama_Pm9(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm9 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Pm9 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm9;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
                                                                          
      l_Trama_Pm9(l_Item).Id_descuento_perdido := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PM9'
                                                                            ,'ID_DESCUENTO_PERDIDO'
                                                                            ,l_Item
                                                                            ,p_Ind));
                                                                            
      l_Trama_Pm9(l_Item).Evento_Perdido := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PM9'
                                                                            ,'EVENTO_PERDIDO'
                                                                            ,l_Item
                                                                            ,p_Ind));      
                                                                               
      l_Trama_Pm9(l_Item).Monto_descuento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'PM9'
                                                                          ,'MONTO_DESCUENTO'
                                                                          ,l_Item
                                                                          ,p_Ind);
                                                                          
      
      l_Trama_Pm9(l_Item).Decimal_Monto_Docto := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                           ,'PM9'
                                                                                           ,'DECIMAL_MONTO_DOCTO'
                                                                                           ,l_Item
                                                                                           ,p_Ind));                                                                    
                                                                          
      l_Trama_Pm9(l_Item).Descuento_relacionado := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PM9'
                                                                            ,'DESCUENTO_RELACIONADO'
                                                                            ,l_Item
                                                                            ,p_Ind));
                                                                            
      l_Trama_Pm9(l_Item).Tipo_descuento_aplicado_perdido := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PM9'
                                                                            ,'TIPO_DESCUENTO_APLICADO_PERDIDO'
                                                                            ,l_Item
                                                                            ,p_Ind));
      
      --INI JAGC 20250415 NECESIDADES 'NEU'                                                                      
      l_Trama_Pm9(l_Item).Unidad_Compra := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PM9'
                                                                            ,'UNIDAD_COMPRA'
                                                                            ,l_Item
                                                                            ,p_Ind));
                                                                            
      l_Trama_Pm9(l_Item).Unidad_Beneficio := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PM9'
                                                                            ,'UNIDAD_BENEFICIO'
                                                                            ,l_Item
                                                                            ,p_Ind));  
      --FIN JAGC 20250415 NECESIDADES 'NEU'                                              
    END LOOP;
    RETURN l_Trama_Pm9;
  END;  
  --FIN JAGC 20240909 NECESIDADES 'NEC'

  FUNCTION Carga_Trama_Po(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Po IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Po Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Po;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'PO'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Po(l_Item).Codigo_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PO'
                                                                              ,'CODIGO_PRODUCTO'
                                                                              ,l_Item);
      l_Trama_Po(l_Item).Dosis := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'PO'
                                                                    ,'DOSIS'
                                                                    ,l_Item);
      l_Trama_Po(l_Item).Veces := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'PO'
                                                                    ,'VECES'
                                                                    ,l_Item);
      l_Trama_Po(l_Item).Dias := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'PO'
                                                                   ,'DIAS'
                                                                   ,l_Item);
      l_Trama_Po(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PO'
                                                                       ,'CANTIDAD'
                                                                       ,l_Item);
      l_Trama_Po(l_Item).Codigo_De_Respuesta := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'PO'
                                                                                  ,'CODIGO_DE_RESPUESTA'
                                                                                  ,l_Item);
      l_Trama_Po(l_Item).Dias_Tratamiento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'PO'
                                                                               ,'DIAS_TRATAMIENTO'
                                                                               ,l_Item);
      l_Trama_Po(l_Item).Precio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'PO'
                                                                     ,'PRECIO'
                                                                     ,l_Item);

      -- ============================================================
      -- DESARROLLO DISPENSACI?N (JAGC 2024-03-20)
      -- ORIGEN DE TRANSACCI?N PARA DISPENSACI?N 'MSP'
      -- ============================================================

      l_Trama_Po(l_Item).Decimal_Precio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'PO'
                                                                             ,'DECIMAL_PRECIO'
                                                                             ,l_Item);

      -- ============================================================

      l_Trama_Po(l_Item).Bonificacion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PO'
                                                                           ,'BONIFICACION'
                                                                           ,l_Item);
      l_Trama_Po(l_Item).Descuento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'PO'
                                                                        ,'DESCUENTO'
                                                                        ,l_Item);
    END LOOP;
    RETURN l_Trama_Po;
  END;

  FUNCTION Carga_Trama_Po1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Po1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Po1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Po1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Po1(l_Item).Codigo_Sustituto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'PO1'
                                                                                ,'CODIGO_SUSTITUTO'
                                                                                ,l_Item
                                                                                ,p_Ind);
      l_Trama_Po1(l_Item).En_Lista := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'PO1'
                                                                        ,'EN_LISTA'
                                                                        ,l_Item
                                                                        ,p_Ind);
    END LOOP;
    RETURN l_Trama_Po1;
  END;

  FUNCTION Carga_Trama_Po9(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Po9 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Po9 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Po9;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'PO9'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Po9(l_Item).Codigo_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'PO9'
                                                                               ,'CODIGO_PRODUCTO'
                                                                               ,l_Item);
      l_Trama_Po9(l_Item).Dosis := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'PO9'
                                                                     ,'DOSIS'
                                                                     ,l_Item);
      l_Trama_Po9(l_Item).Veces := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'PO9'
                                                                     ,'VECES'
                                                                     ,l_Item);
      l_Trama_Po9(l_Item).Dias := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'PO9'
                                                                    ,'DIAS'
                                                                    ,l_Item);
      l_Trama_Po9(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'PO9'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
      l_Trama_Po9(l_Item).Codigo_De_Respuesta := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'PO9'
                                                                                   ,'CODIGO_DE_RESPUESTA'
                                                                                   ,l_Item);
      l_Trama_Po9(l_Item).Dias_Tratamiento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'PO9'
                                                                                ,'DIAS_TRATAMIENTO'
                                                                                ,l_Item);
      l_Trama_Po9(l_Item).Precio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'PO9'
                                                                      ,'PRECIO'
                                                                      ,l_Item);

      l_Trama_Po9(l_Item).Bonificacion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PO9'
                                                                            ,'BONIFICACION'
                                                                            ,l_Item);
      l_Trama_Po9(l_Item).Descuento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'PO9'
                                                                         ,'DESCUENTO'
                                                                         ,l_Item);
      l_Trama_Po9(l_Item).Porcentaje_Bonif_Informado := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'PO9'
                                                                                          ,'PORCENTAJE_BONIF_INFORMADO'
                                                                                          ,l_Item);
      l_Trama_Po9(l_Item).Monto_Bonif_Informado := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'PO9'
                                                                                     ,'MONTO_BONIF_INFORMADO'
                                                                                     ,l_Item);
      l_Trama_Po9(l_Item).Deducible_Aplicado_En_Pesos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                           ,'PO9'
                                                                                           ,'DEDUCIBLE_APLICADO_EN_PESOS'
                                                                                           ,l_Item);
      l_Trama_Po9(l_Item).Tope_Aplicado_En_Pesos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'PO9'
                                                                                      ,'TOPE_APLICADO_EN_PESOS'
                                                                                      ,l_Item);
      l_Trama_Po9(l_Item).Cantidad_Sustitutos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'PO9'
                                                                                   ,'CANTIDAD_SUSTITUTOS'
                                                                                   ,l_Item);
      l_Trama_Po9(l_Item).Subtrama_Po1 := Carga_Trama_Po1(p_Cuerpo_Tx
                                                         ,l_Trama_Po9(l_Item).Cantidad_Sustitutos
                                                         ,l_Item);
    END LOOP;
    RETURN l_Trama_Po9;
  END;

  FUNCTION Carga_Trama_Po8(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Po8 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Po8 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Po8;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'PO8'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Po8(l_Item).Codigo_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'PO8'
                                                                               ,'CODIGO_PRODUCTO'
                                                                               ,l_Item);
      l_Trama_Po8(l_Item).Dosis := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'PO8'
                                                                     ,'DOSIS'
                                                                     ,l_Item);
      l_Trama_Po8(l_Item).Veces := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'PO8'
                                                                     ,'VECES'
                                                                     ,l_Item);
      l_Trama_Po8(l_Item).Dias := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'PO8'
                                                                    ,'DIAS'
                                                                    ,l_Item);
      l_Trama_Po8(l_Item).Cantidad_Original := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'PO8'
                                                                                 ,'CANTIDAD_ORIGINAL'
                                                                                 ,l_Item);
      l_Trama_Po8(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'PO8'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
      l_Trama_Po8(l_Item).Codigo_De_Respuesta := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'PO8'
                                                                                   ,'CODIGO_DE_RESPUESTA'
                                                                                   ,l_Item);
      l_Trama_Po8(l_Item).Mensaje_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'PO8'
                                                                                ,'MENSAJE_PRODUCTO'
                                                                                ,l_Item);
      l_Trama_Po8(l_Item).Dias_Tratamiento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'PO8'
                                                                                ,'DIAS_TRATAMIENTO'
                                                                                ,l_Item);
      l_Trama_Po8(l_Item).Precio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'PO8'
                                                                      ,'PRECIO'
                                                                      ,l_Item);
 

      l_Trama_Po8(l_Item).Tipo_Bonificacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'PO8'
                                                                                 ,'TIPO_BONIFICACION'
                                                                                 ,l_Item);
      l_Trama_Po8(l_Item).Bonificacion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PO8'
                                                                            ,'BONIFICACION'
                                                                            ,l_Item);
      l_Trama_Po8(l_Item).Descuento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'PO8'
                                                                         ,'DESCUENTO'
                                                                         ,l_Item);
      l_Trama_Po8(l_Item).Afecto_Sgdo_Credito := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'PO8'
                                                                                   ,'AFECTO_SGDO_CREDITO'
                                                                                   ,l_Item);
      l_Trama_Po8(l_Item).Porcentaje_Bonif_Informado := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'PO8'
                                                                                          ,'PORCENTAJE_BONIF_INFORMADO'
                                                                                          ,l_Item);
      l_Trama_Po8(l_Item).Monto_Bonif_Informado := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'PO8'
                                                                                     ,'MONTO_BONIF_INFORMADO'
                                                                                     ,l_Item);
      l_Trama_Po8(l_Item).Deducible_Aplicado_En_Pesos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                           ,'PO8'
                                                                                           ,'DEDUCIBLE_APLICADO_EN_PESOS'
                                                                                           ,l_Item);
      l_Trama_Po8(l_Item).Tope_Aplicado_En_Pesos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'PO8'
                                                                                      ,'TOPE_APLICADO_EN_PESOS'
                                                                                      ,l_Item);
      l_Trama_Po8(l_Item).Numero_Plan := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PO8'
                                                                           ,'NUMERO_PLAN'
                                                                           ,l_Item);
      l_Trama_Po8(l_Item).Codigo_Ges := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'PO8'
                                                                          ,'CODIGO_GES'
                                                                          ,l_Item);
      l_Trama_Po8(l_Item).Folio_Bono := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'PO8'
                                                                          ,'FOLIO_BONO'
                                                                          ,l_Item);
      l_Trama_Po8(l_Item).Cantidad_Sustitutos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'PO8'
                                                                                   ,'CANTIDAD_SUSTITUTOS'
                                                                                   ,l_Item);
      l_Trama_Po8(l_Item).Subtrama_Po1 := Carga_Trama_Po1(p_Cuerpo_Tx
                                                         ,l_Trama_Po8(l_Item).Cantidad_Sustitutos
                                                         ,l_Item);
    END LOOP;
    RETURN l_Trama_Po8;
  END;
  
  -- ============================================================
-- DESARROLLO DISPENSACI?N (JAGC 2024-03-20)
-- ORIGEN DE TRANSACCI?N PARA DISPENSACI?N 'MSP'
-- ============================================================
  
   FUNCTION Carga_Trama_Po6(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Po6 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Po6 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Po6;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'PO6'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Po6(l_Item).Codigo_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'PO6'
                                                                               ,'CODIGO_PRODUCTO'
                                                                               ,l_Item);
      l_Trama_Po6(l_Item).Dosis := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'PO6'
                                                                     ,'DOSIS'
                                                                     ,l_Item);
      l_Trama_Po6(l_Item).Veces := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'PO6'
                                                                     ,'VECES'
                                                                     ,l_Item);
      l_Trama_Po6(l_Item).Dias := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'PO6'
                                                                    ,'DIAS'
                                                                    ,l_Item);
      l_Trama_Po6(l_Item).Cantidad_Original := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'PO6'
                                                                                 ,'CANTIDAD_ORIGINAL'
                                                                                 ,l_Item);
      l_Trama_Po6(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'PO6'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
      l_Trama_Po6(l_Item).Codigo_De_Respuesta := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'PO6'
                                                                                   ,'CODIGO_DE_RESPUESTA'
                                                                                   ,l_Item);
      l_Trama_Po6(l_Item).Mensaje_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'PO6'
                                                                                ,'MENSAJE_PRODUCTO'
                                                                                ,l_Item);
      l_Trama_Po6(l_Item).Dias_Tratamiento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'PO6'
                                                                                ,'DIAS_TRATAMIENTO'
                                                                                ,l_Item);
      l_Trama_Po6(l_Item).Precio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'PO6'
                                                                      ,'PRECIO'
                                                                      ,l_Item);
                                                                      
                                                                     
      -- ============================================================
      -- DESARROLLO DISPENSACI?N (JAGC 2024-03-20)
      -- ORIGEN DE TRANSACCI?N PARA DISPENSACI?N 'MSP'
      -- ============================================================

      l_Trama_Po6(l_Item).Decimal_Precio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'PO6'
                                                                             ,'DECIMAL_PRECIO'
                                                                             ,l_Item);

      -- ============================================================

 

      l_Trama_Po6(l_Item).Tipo_Bonificacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'PO6'
                                                                                 ,'TIPO_BONIFICACION'
                                                                                 ,l_Item);
      l_Trama_Po6(l_Item).Bonificacion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PO6'
                                                                            ,'BONIFICACION'
                                                                            ,l_Item);
      l_Trama_Po6(l_Item).Descuento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'PO6'
                                                                         ,'DESCUENTO'
                                                                         ,l_Item);
      l_Trama_Po6(l_Item).Afecto_Sgdo_Credito := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'PO6'
                                                                                   ,'AFECTO_SGDO_CREDITO'
                                                                                   ,l_Item);
      l_Trama_Po6(l_Item).Porcentaje_Bonif_Informado := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'PO6'
                                                                                          ,'PORCENTAJE_BONIF_INFORMADO'
                                                                                          ,l_Item);
      l_Trama_Po6(l_Item).Monto_Bonif_Informado := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'PO6'
                                                                                     ,'MONTO_BONIF_INFORMADO'
                                                                                     ,l_Item);
      l_Trama_Po6(l_Item).Deducible_Aplicado_En_Pesos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                           ,'PO6'
                                                                                           ,'DEDUCIBLE_APLICADO_EN_PESOS'
                                                                                           ,l_Item);
      l_Trama_Po6(l_Item).Tope_Aplicado_En_Pesos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'PO6'
                                                                                      ,'TOPE_APLICADO_EN_PESOS'
                                                                                      ,l_Item);
      l_Trama_Po6(l_Item).Numero_Plan := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PO6'
                                                                           ,'NUMERO_PLAN'
                                                                           ,l_Item);
      l_Trama_Po6(l_Item).Codigo_Ges := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'PO6'
                                                                          ,'CODIGO_GES'
                                                                          ,l_Item);
      l_Trama_Po6(l_Item).Folio_Bono := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'PO6'
                                                                          ,'FOLIO_BONO'
                                                                          ,l_Item);
      l_Trama_Po6(l_Item).Cantidad_Sustitutos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'PO6'
                                                                                   ,'CANTIDAD_SUSTITUTOS'
                                                                                   ,l_Item);
      l_Trama_Po6(l_Item).Subtrama_Po1 := Carga_Trama_Po1(p_Cuerpo_Tx
                                                         ,l_Trama_Po6(l_Item).Cantidad_Sustitutos
                                                         ,l_Item);
    END LOOP;
    RETURN l_Trama_Po6;
  END;

-- ============================================================


  FUNCTION Carga_Trama_Pp(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pp IS
    l_Trama_Pp Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pp;
  BEGIN
    l_Trama_Pp.Fecha  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                           ,'PP'
                                                           ,'FECHA');
    l_Trama_Pp.Puntos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                           ,'PP'
                                                           ,'PUNTOS');
    RETURN l_Trama_Pp;
  END;

  FUNCTION Carga_Trama_Pq(p_Trama_Pos IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Hpo
                         ,p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pq IS
    l_Item       NUMBER;
    l_Tot_Reg    NUMBER;
    l_Trama_Pq   Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pq;
    l_Trama_Va   Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Va;
    p_Iva        NUMBER := 0;
    p_Agrega_Iva VARCHAR2(2) := 'NO';
  BEGIN

    IF Scfr_Trx_Dyn_Pk.Agrega_Iva(p_Trama_Pos.Cadena
                                 ,p_Trama_Pos.Empresa
                                 ,p_Trama_Pos.Local
                                 ,p_Iva) = 'SI' THEN

      IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Cuerpo_Tx
                                       ,'VA') THEN
        -- l_Dbg_Mensaje := 'Obtener informacion de la trama VA';
        l_Trama_Va := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Va(p_Trama_Pos
                                                        ,p_Cuerpo_Tx);

        BEGIN
          SELECT 'SI'
            INTO p_Agrega_Iva
            FROM Scfr_Convenios t
           WHERE t.Numero_Convenio = l_Trama_Va.Convenio
             AND t.Tipo_Convenio = 'GUI';

        EXCEPTION
          WHEN OTHERS THEN
            p_Agrega_Iva := 'NO'; -- estaba en null se cambia a 1 para dejarlo igual a batc
        END;
      END IF;
    END IF;

    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'PQ'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Pq(l_Item).Codigo_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PQ'
                                                                              ,'CODIGO_PRODUCTO'
                                                                              ,l_Item);
      l_Trama_Pq(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PQ'
                                                                       ,'CANTIDAD'
                                                                       ,l_Item);
      l_Trama_Pq(l_Item).Precio_Con_Descuento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'PQ'
                                                                                   ,'PRECIO_CON_DESCUENTO'
                                                                                   ,l_Item);
      l_Trama_Pq(l_Item).Decimal_Precio_Descuento := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                               ,'PQ'
                                                                                               ,'DECIMAL_PRECIO_DESCUENTO'
                                                                                               ,l_Item)
                                                            ,'-'
                                                            ,'0');
      l_Trama_Pq(l_Item).Precio_Con_Descuento := To_Number(l_Trama_Pq(l_Item).Precio_Con_Descuento || '.' || l_Trama_Pq(l_Item).Decimal_Precio_Descuento
                                                          ,'999999999999.9999');
      l_Trama_Pq(l_Item).Bonificacion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PQ'
                                                                           ,'BONIFICACION'
                                                                           ,l_Item);
      l_Trama_Pq(l_Item).Decimal_Bonificacion := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                           ,'PQ'
                                                                                           ,'DECIMAL_BONIFICACION'
                                                                                           ,l_Item)
                                                        ,'-'
                                                        ,'0');
      l_Trama_Pq(l_Item).Bonificacion := To_Number(l_Trama_Pq(l_Item).Bonificacion || '.' || l_Trama_Pq(l_Item).Decimal_Bonificacion
                                                  ,'999999999999.9999');
      l_Trama_Pq(l_Item).Codigo_Barra := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PQ'
                                                                           ,'CODIGO_BARRA'
                                                                           ,l_Item);
      l_Trama_Pq(l_Item).Porcentaje_Bonif_Informado := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                         ,'PQ'
                                                                                         ,'PORCENTAJE_BONIF_INFORMADO'
                                                                                         ,l_Item);
      l_Trama_Pq(l_Item).Monto_Bonif_Informado := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'PQ'
                                                                                    ,'MONTO_BONIF_INFORMADO'
                                                                                    ,l_Item);
      l_Trama_Pq(l_Item).Decimal_Bonif_Informado := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                              ,'PQ'
                                                                                              ,'DECIMAL_BONIF_INFORMADO'
                                                                                              ,l_Item)
                                                           ,'-'
                                                           ,'0');
      l_Trama_Pq(l_Item).Monto_Bonif_Informado := To_Number(l_Trama_Pq(l_Item).Monto_Bonif_Informado || '.' || l_Trama_Pq(l_Item).Decimal_Bonif_Informado
                                                           ,'999999999999.9999');
      l_Trama_Pq(l_Item).Deducible_Aplicado_En_Pesos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'PQ'
                                                                                          ,'DEDUCIBLE_APLICADO_EN_PESOS'
                                                                                          ,l_Item);
      l_Trama_Pq(l_Item).Decimal_Deducible_Aplicado := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                                 ,'PQ'
                                                                                                 ,'DECIMAL_DEDUCIBLE_APLICADO'
                                                                                                 ,l_Item)
                                                              ,'-'
                                                              ,'0');
      l_Trama_Pq(l_Item).Deducible_Aplicado_En_Pesos := To_Number(l_Trama_Pq(l_Item).Deducible_Aplicado_En_Pesos || '.' || l_Trama_Pq(l_Item).Decimal_Deducible_Aplicado
                                                                 ,'999999999999.9999');
      l_Trama_Pq(l_Item).Tope_Aplicado_En_Pesos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'PQ'
                                                                                     ,'TOPE_APLICADO_EN_PESOS'
                                                                                     ,l_Item);
      l_Trama_Pq(l_Item).Decimal_Tope_Aplicado := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                            ,'PQ'
                                                                                            ,'DECIMAL_TOPE_APLICADO'
                                                                                            ,l_Item)
                                                         ,'-'
                                                         ,'0');
      l_Trama_Pq(l_Item).Tope_Aplicado_En_Pesos := To_Number(l_Trama_Pq(l_Item).Tope_Aplicado_En_Pesos || '.' || l_Trama_Pq(l_Item).Decimal_Tope_Aplicado
                                                            ,'999999999999.9999');
      --//--------------------------------------------------------------------------\\
      --// CBR 21/03/2017 10:55                                                     \\
      --// Para las versiones de POS que no incluyen el iva en la GUIA              \\
      --//-----------------------------------------------------------------Inicio---\\
      IF p_Agrega_Iva = 'SI' THEN
        -- l_Trama_Pq(l_Item).Precio_Con_Descuento := Round(l_Trama_Pq(l_Item).Precio_Con_Descuento * (1 + p_Iva / 100),0);
        l_Trama_Pq(l_Item).Precio_Con_Descuento := Ceil(l_Trama_Pq(l_Item).Precio_Con_Descuento * (1 + p_Iva / 100));
      END IF;
      --//-----------------------------------------------------------------Termino--\\
    END LOOP;
    RETURN l_Trama_Pq;
  END;

  FUNCTION Carga_Trama_Pr(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pr IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Pr Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pr;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'PR'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Pr(l_Item).Uso_Frecuente := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PR'
                                                                            ,'USO_FRECUENTE'
                                                                            ,l_Item);
      l_Trama_Pr(l_Item).Ofrecido := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PR'
                                                                       ,'OFRECIDO'
                                                                       ,l_Item);
      l_Trama_Pr(l_Item).Estado_Crm := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'PR'
                                                                         ,'ESTADO_CRM'
                                                                         ,l_Item);
    END LOOP;
    RETURN l_Trama_Pr;
  END;

  FUNCTION Carga_Trama_Ps(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ps IS
    l_Trama_Ps Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ps;
  BEGIN
    l_Trama_Ps.Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                             ,'PS'
                                                             ,'PRODUCTO');
    RETURN l_Trama_Ps;
  END;

  FUNCTION Carga_Trama_Pt(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pt IS
    l_Trama_Pt Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pt;
  BEGIN
    l_Trama_Pt.Local           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'PT'
                                                                    ,'LOCAL');
    l_Trama_Pt.Rut_Vendedor    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'PT'
                                                                    ,'RUT_VENDEDOR');
    l_Trama_Pt.Dv_Rut_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'PT'
                                                                    ,'DV_RUT_VENDEDOR');
    l_Trama_Pt.Correlativo_Tx  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'PT'
                                                                    ,'CORRELATIVO_TX');
    RETURN l_Trama_Pt;
  END;

  FUNCTION Carga_Trama_Pu(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pu IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Pu Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pu;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'PU'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Pu(l_Item).Signo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'PU'
                                                                    ,'SIGNO');
      l_Trama_Pu(l_Item).Puntos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'PU'
                                                                     ,'PUNTOS');
      l_Trama_Pu(l_Item).Donacion_Vigente := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'PU'
                                                                               ,'DONACION_VIGENTE');
      --//--------------------------------------------------------------------------\\
      --// CBR 17/08/2020 05:13                                                     \\
      --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
      --//-----------------------------------------------------------------Inicio---\\
      l_Trama_Pu(l_Item).Rut_Beneficiario := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'PU'
                                                                               ,'IDENTI_BENEFICIARIO');
      --//-----------------------------------------------------------------Termino--\\
      l_Trama_Pu(l_Item).Rut_Beneficiario := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'PU'
                                                                               ,'RUT_BENEFICIARIO');
      l_Trama_Pu(l_Item).Dv_Rut_Beneficiario := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'PU'
                                                                                  ,'DV_RUT_BENEFICIARIO');
      l_Trama_Pu(l_Item).Nombre := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'PU'
                                                                     ,'NOMBRE');
      l_Trama_Pu(l_Item).Fecha_Inicio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PU'
                                                                           ,'FECHA_INICIO');
      l_Trama_Pu(l_Item).Fecha_Termino := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'PU'
                                                                            ,'FECHA_TERMINO');
      l_Trama_Pu(l_Item).Vigencia := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PU'
                                                                       ,'VIGENCIA');
    END LOOP;
    RETURN l_Trama_Pu;
  END;

  /*FUNCTION carga_trama_pv(p_cuerpo_tx IN scfr_trx_dyn_pk.tab_cuerpo_tx) RETURN scfr_trx_dyn_types_pk.tab_trama_pv IS
    l_item NUMBER;
    l_tot_reg NUMBER;
    l_trama_pv scfr_trx_dyn_types_pk.tab_trama_pv;
  BEGIN
    l_tot_reg := scfr_trx_dyn_pk.obtiene_nvalor_trx(p_cuerpo_tx, 'PV', 'CANTIDAD_REGISTROS');
    FOR l_item IN 1 .. l_tot_reg LOOP
      l_trama_pv(l_item).id_periodo := scfr_trx_dyn_pk.obtiene_nvalor_trx(p_cuerpo_tx, 'PV', 'ID_PERIODO', l_item);
      l_trama_pv(l_item).fecha_inicio := scfr_trx_dyn_pk.obtiene_nvalor_trx(p_cuerpo_tx, 'PV', 'FECHA_INICIO', l_item);
      l_trama_pv(l_item).fecha_termino := scfr_trx_dyn_pk.obtiene_nvalor_trx(p_cuerpo_tx, 'PV', 'FECHA_TERMINO', l_item);
      l_trama_pv(l_item).monto_copago := scfr_trx_dyn_pk.obtiene_nvalor_trx(p_cuerpo_tx, 'PV', 'MONTO_COPAGO', l_item);
      l_trama_pv(l_item).folio_copago := scfr_trx_dyn_pk.obtiene_nvalor_trx(p_cuerpo_tx, 'PV', 'FOLIO_COPAGO', l_item);
      l_trama_pv(l_item).periodo_pagado := scfr_trx_dyn_pk.obtiene_cvalor_trx(p_cuerpo_tx, 'PV', 'PERIODO_PAGADO', l_item);
    END LOOP;
    RETURN l_trama_pv;
  END;*/
  FUNCTION Carga_Trama_Pv(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pv IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Pv Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pv;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'PV'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Pv(l_Item).Tipo_Auditoria := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'PV'
                                                                             ,'TIPO_AUDITORIA'
                                                                             ,l_Item);
      l_Trama_Pv(l_Item).Numero_Preventa := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'PV'
                                                                              ,'NUMERO_PREVENTA'
                                                                              ,l_Item);
      l_Trama_Pv(l_Item).Rut_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'PV'
                                                                           ,'RUT_VENDEDOR'
                                                                           ,l_Item);
      l_Trama_Pv(l_Item).Dv_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'PV'
                                                                          ,'DV_VENDEDOR'
                                                                          ,l_Item);
      l_Trama_Pv(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PV'
                                                                       ,'PRODUCTO'
                                                                       ,l_Item);
    END LOOP;
    RETURN l_Trama_Pv;
  END;

  FUNCTION Carga_Trama_Aa(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Aa IS
    l_Trama_Aa Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Aa;
  BEGIN
    l_Trama_Aa.Tipo_Auditoria := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                   ,'AA'
                                                                   ,'TIPO_AUDITORIA');
    l_Trama_Aa.Rut_Supervisor := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'AA'
                                                                   ,'RUT_SUPERVISOR');
    l_Trama_Aa.Dv_Supervisor  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                   ,'AA'
                                                                   ,'DV_SUPERVISOR');
    l_Trama_Aa.Rut_Vendedor   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'AA'
                                                                   ,'RUT_VENDEDOR');
    l_Trama_Aa.Dv_Vendedor    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                   ,'AA'
                                                                   ,'DV_VENDEDOR');
    l_Trama_Aa.Ip_Origen      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                   ,'AA'
                                                                   ,'IP_ORIGEN');
    RETURN l_Trama_Aa;
  END;

  FUNCTION Carga_Trama_Al(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Al IS
    l_Trama_Al Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Al;
  BEGIN
    l_Trama_Al.Tipo_Auditoria     := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'AL'
                                                                       ,'TIPO_AUDITORIA');
    l_Trama_Al.Rut_Supervisor     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'AL'
                                                                       ,'RUT_SUPERVISOR');
    l_Trama_Al.Dv_Supervisor      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'AL'
                                                                       ,'DV_SUPERVISOR');
    l_Trama_Al.Rut_Vendedor       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'AL'
                                                                       ,'RUT_VENDEDOR');
    l_Trama_Al.Dv_Vendedor        := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'AL'
                                                                       ,'DV_VENDEDOR');
    l_Trama_Al.Rut_Cliente        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'AL'
                                                                       ,'RUT_CLIENTE');
    l_Trama_Al.Dv_Cliente         := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'AL'
                                                                       ,'DV_CLIENTE');
    l_Trama_Al.Alerta             := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'AL'
                                                                       ,'ALERTA');
    l_Trama_Al.Motivo             := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'AL'
                                                                       ,'MOTIVO');
    l_Trama_Al.Nro_Veces          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'AL'
                                                                       ,'NRO_VECES');
    l_Trama_Al.Nro_Documento      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'AL'
                                                                       ,'NRO_DOCUMENTO');
    l_Trama_Al.Producto           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'AL'
                                                                       ,'PRODUCTO');
    l_Trama_Al.Fecha_Captura      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'AL'
                                                                       ,'FECHA_CAPTURA');
    l_Trama_Al.Fecha_Autorizacion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'AL'
                                                                       ,'FECHA_AUTORIZACION');
    l_Trama_Al.Resultado          := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'AL'
                                                                       ,'RESULTADO');
    RETURN l_Trama_Al;
  END;

  FUNCTION Carga_Trama_Pz(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pz IS
    l_Trama_Pz Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pz;
  BEGIN
    l_Trama_Pz.Producto          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'PZ'
                                                                      ,'PRODUCTO');
    l_Trama_Pz.Familia_Comercial := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'PZ'
                                                                      ,'FAMILIA_COMERCIAL');
    l_Trama_Pz.Tipo_Descuento    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'PZ'
                                                                      ,'TIPO_DESCUENTO');
    l_Trama_Pz.Descuento         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'PZ'
                                                                      ,'DESCUENTO');
    l_Trama_Pz.Campana           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'PZ'
                                                                      ,'CAMPANA');
    l_Trama_Pz.Uso_Frecuente     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'PZ'
                                                                      ,'USO_FRECUENTE');
    RETURN l_Trama_Pz;
  END;

  FUNCTION Carga_Trama_Ra(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ra IS
    l_Trama_Ra Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ra;
  BEGIN
    l_Trama_Ra.Tarjeta_Invitado := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'RA'
                                                                     ,'TARJETA_INVITADO');
    RETURN l_Trama_Ra;
  END;

  FUNCTION Carga_Trama_Rb(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rb IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Rb Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rb;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'RB'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Rb(l_Item).Numero_Manifiesto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'RB'
                                                                                ,'NUMERO_MANIFIESTO'
                                                                                ,l_Item);
      l_Trama_Rb(l_Item).Fecha_Manifiesto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'RB'
                                                                               ,'FECHA_MANIFIESTO'
                                                                               ,l_Item);
      l_Trama_Rb(l_Item).Numero_Despacho := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'RB'
                                                                              ,'NUMERO_DESPACHO'
                                                                              ,l_Item);
      l_Trama_Rb(l_Item).Fecha_Despacho := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'RB'
                                                                             ,'FECHA_DESPACHO'
                                                                             ,l_Item);
      l_Trama_Rb(l_Item).Patente_Transporte := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'RB'
                                                                                 ,'PATENTE_TRANSPORTE'
                                                                                 ,l_Item);
      l_Trama_Rb(l_Item).Fecha_Hora_Recepcion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'RB'
                                                                                   ,'FECHA_HORA_RECEPCION'
                                                                                   ,l_Item);
      l_Trama_Rb(l_Item).Fecha_Hora_Ingreso_Vendible := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'RB'
                                                                                          ,'FECHA_HORA_INGRESO_VENDIBLE'
                                                                                          ,l_Item);
      l_Trama_Rb(l_Item).Tipo_Recepcion_Manifiesto := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                        ,'RB'
                                                                                        ,'TIPO_RECEPCION_MANIFIESTO'
                                                                                        ,l_Item);
      l_Trama_Rb(l_Item).Cantidad_Bultos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'RB'
                                                                              ,'CANTIDAD_BULTOS'
                                                                              ,l_Item);
      l_Trama_Rb(l_Item).Subtrama_Rb1 := Carga_Trama_Rb1(p_Cuerpo_Tx
                                                        ,l_Trama_Rb(l_Item).Cantidad_Bultos
                                                        ,l_Item);
    END LOOP;
    RETURN l_Trama_Rb;
  END;

  FUNCTION Carga_Trama_Rb1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rb1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Rb1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rb1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Rb1(l_Item).Numero_Pedido := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'RB1'
                                                                             ,'NUMERO_PEDIDO'
                                                                             ,l_Item
                                                                             ,p_Ind);
      l_Trama_Rb1(l_Item).Codigo_Bulto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RB1'
                                                                            ,'CODIGO_BULTO'
                                                                            ,l_Item
                                                                            ,p_Ind);
      l_Trama_Rb1(l_Item).Matricula_Bulto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'RB1'
                                                                               ,'MATRICULA_BULTO'
                                                                               ,l_Item
                                                                               ,p_Ind);
      l_Trama_Rb1(l_Item).Tipo_Bulto := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'RB1'
                                                                          ,'TIPO_BULTO'
                                                                          ,l_Item
                                                                          ,p_Ind);
      l_Trama_Rb1(l_Item).Recepcionado := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RB1'
                                                                            ,'RECEPCIONADO'
                                                                            ,l_Item
                                                                            ,p_Ind);
      l_Trama_Rb1(l_Item).Fecha_Recepcion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'RB1'
                                                                               ,'FECHA_RECEPCION'
                                                                               ,l_Item
                                                                               ,p_Ind);
      l_Trama_Rb1(l_Item).Devuelto := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RB1'
                                                                        ,'DEVUELTO'
                                                                        ,l_Item
                                                                        ,p_Ind);
      l_Trama_Rb1(l_Item).Fecha_Devolucion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'RB1'
                                                                                ,'FECHA_DEVOLUCION'
                                                                                ,l_Item
                                                                                ,p_Ind);
      l_Trama_Rb1(l_Item).Guia_Devolucion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'RB1'
                                                                               ,'GUIA_DEVOLUCION'
                                                                               ,l_Item
                                                                               ,p_Ind);
      l_Trama_Rb1(l_Item).Fecha_Ingreso := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'RB1'
                                                                             ,'FECHA_INGRESO'
                                                                             ,l_Item
                                                                             ,p_Ind);
      l_Trama_Rb1(l_Item).Fecha_Revision_Ini := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'RB1'
                                                                                  ,'FECHA_REVISION_INI'
                                                                                  ,l_Item
                                                                                  ,p_Ind);
      l_Trama_Rb1(l_Item).Fecha_Revision_Fin := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'RB1'
                                                                                  ,'FECHA_REVISION_FIN'
                                                                                  ,l_Item
                                                                                  ,p_Ind);
      l_Trama_Rb1(l_Item).Tipo_Recepcion_Bulto := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'RB1'
                                                                                    ,'TIPO_RECEPCION_BULTO'
                                                                                    ,l_Item
                                                                                    ,p_Ind);
      l_Trama_Rb1(l_Item).Numero_Pedido_Proveedor := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                       ,'RB1'
                                                                                       ,'NUMERO_PEDIDO_PROVEEDOR'
                                                                                       ,l_Item
                                                                                       ,p_Ind);
      l_Trama_Rb1(l_Item).Folio_Guia_Reclamo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'RB1'
                                                                                  ,'FOLIO_GUIA_RECLAMO'
                                                                                  ,l_Item
                                                                                  ,p_Ind);
      l_Trama_Rb1(l_Item).Numero_Reclamo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'RB1'
                                                                              ,'NUMERO_RECLAMO'
                                                                              ,l_Item
                                                                              ,p_Ind);
    END LOOP;
    RETURN l_Trama_Rb1;
  END;

  FUNCTION Carga_Trama_Rc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rc IS
    l_Trama_Rc Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rc;
  BEGIN
    l_Trama_Rc.Producto         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'RC'
                                                                     ,'PRODUCTO');
    l_Trama_Rc.Tipo_Inscripcion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'RC'
                                                                     ,'TIPO_INSCRIPCION');
    RETURN l_Trama_Rc;
  END;

  FUNCTION Carga_Trama_Rcv(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rcv IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Rcv Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rcv;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'RCV'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Rcv(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RCV'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item);
      l_Trama_Rcv(l_Item).Tipo_Inscripcion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'RCV'
                                                                                ,'TIPO_INSCRIPCION'
                                                                                ,l_Item);
      l_Trama_Rcv(l_Item).Ofrecido := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RCV'
                                                                        ,'OFRECIDO'
                                                                        ,l_Item);
      l_Trama_Rcv(l_Item).Estado_Crm := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'RCV'
                                                                          ,'ESTADO_CRM'
                                                                          ,l_Item);
    END LOOP;
    RETURN l_Trama_Rcv;
  END;

  FUNCTION Carga_Trama_Re(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Re IS
    l_Trama_Re Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Re;
  BEGIN
    l_Trama_Re.Timespan        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'RE'
                                                                    ,'TIMESPAN');
    l_Trama_Re.Rx_Ack          := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'RE'
                                                                    ,'RX_ACK');
    l_Trama_Re.Rx_Nack         := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'RE'
                                                                    ,'RX_NACK');
    l_Trama_Re.Rx_Con_Servicio := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'RE'
                                                                    ,'RX_CON_SERVICIO');
    l_Trama_Re.Rx_Sin_Servicio := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'RE'
                                                                    ,'RX_SIN_SERVICIO');
    l_Trama_Re.Rx_Timeout      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'RE'
                                                                    ,'RX_TIMEOUT');
    l_Trama_Re.Rx_Erronea      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'RE'
                                                                    ,'RX_ERRONEA');
    RETURN l_Trama_Re;
  END;

  FUNCTION Carga_Trama_Rf(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rf IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Rf Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rf;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'RF'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Rf(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RF'
                                                                       ,'PRODUCTO'
                                                                       ,l_Item);
      l_Trama_Rf(l_Item).Fecha_Vencimiento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'RF'
                                                                                ,'FECHA_VENCIMIENTO'
                                                                                ,l_Item);
    END LOOP;
    RETURN l_Trama_Rf;
  END;

  FUNCTION Carga_Trama_Rfv(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rfv IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Rfv Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rfv;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'RFV'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Rfv(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RFV'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item);
      l_Trama_Rfv(l_Item).Consumo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RFV'
                                                                       ,'CONSUMO'
                                                                       ,l_Item);
      l_Trama_Rfv(l_Item).Estado_Consumo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'RFV'
                                                                              ,'ESTADO_CONSUMO'
                                                                              ,l_Item);
    END LOOP;
    RETURN l_Trama_Rfv;
  END;

  FUNCTION Carga_Trama_Rg(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rg IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Rg Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rg;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'RG'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Rg(l_Item).Tipo_Movimiento_Padre := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'RG'
                                                                                    ,'TIPO_MOVIMIENTO_PADRE'
                                                                                    ,l_Item);
      l_Trama_Rg(l_Item).Tipo_Movimiento_Hijo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'RG'
                                                                                   ,'TIPO_MOVIMIENTO_HIJO'
                                                                                   ,l_Item);
      l_Trama_Rg(l_Item).Folio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'RG'
                                                                    ,'FOLIO'
                                                                    ,l_Item);
      l_Trama_Rg(l_Item).Numero_Pedido := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RG'
                                                                            ,'NUMERO_PEDIDO'
                                                                            ,l_Item);
      l_Trama_Rg(l_Item).Fecha := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'RG'
                                                                    ,'FECHA'
                                                                    ,l_Item);
      l_Trama_Rg(l_Item).Cantidad_Productos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'RG'
                                                                                 ,'CANTIDAD_PRODUCTOS'
                                                                                 ,l_Item);
      l_Trama_Rg(l_Item).Subtrama_Rg1 := Carga_Trama_Rg1(p_Cuerpo_Tx
                                                        ,l_Trama_Rg(l_Item).Cantidad_Productos
                                                        ,l_Item);
    END LOOP;
    RETURN l_Trama_Rg;
  END;

  FUNCTION Carga_Trama_Rg1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rg1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Rg1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rg1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Rg1(l_Item).Guia_Electronica := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'RG1'
                                                                                ,'GUIA_ELECTRONICA'
                                                                                ,l_Item
                                                                                ,p_Ind);
      l_Trama_Rg1(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RG1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item
                                                                        ,p_Ind);
      l_Trama_Rg1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RG1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item
                                                                        ,p_Ind);
    END LOOP;
    RETURN l_Trama_Rg1;
  END;

  FUNCTION Carga_Trama_Rj(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rj IS
    l_Trama_Rj Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rj;
  BEGIN
    l_Trama_Rj.Tipo_Movimiento_Padre   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RJ'
                                                                            ,'TIPO_MOVIMIENTO_PADRE');
    l_Trama_Rj.Tipo_Movimiento_Hijo    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RJ'
                                                                            ,'TIPO_MOVIMIENTO_HIJO');
    l_Trama_Rj.Folio                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RJ'
                                                                            ,'FOLIO');
    l_Trama_Rj.Guia_Despacho           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RJ'
                                                                            ,'GUIA_DESPACHO');
    l_Trama_Rj.Tipo_Guia_Despacho      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RJ'
                                                                            ,'TIPO_GUIA_DESPACHO');
    l_Trama_Rj.Accion_Sobre_Existencia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RJ'
                                                                            ,'ACCION_SOBRE_EXISTENCIA');
    l_Trama_Rj.Cantidad_Productos      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RJ'
                                                                            ,'CANTIDAD_PRODUCTOS');
    l_Trama_Rj.Subtrama_Rj1            := Carga_Trama_Rj1(p_Cuerpo_Tx
                                                         ,l_Trama_Rj.Cantidad_Productos);
    RETURN l_Trama_Rj;
  END;

  FUNCTION Carga_Trama_Rj1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rj1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Rj1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rj1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Rj1(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RJ1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item);
      l_Trama_Rj1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RJ1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
    END LOOP;
    RETURN l_Trama_Rj1;
  END;

  FUNCTION Carga_Trama_Rk(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rk IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Rk Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rk;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'RK'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Rk(l_Item).Local := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'RK'
                                                                    ,'LOCAL'
                                                                    ,l_Item);
      l_Trama_Rk(l_Item).Cantidad_Productos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'RK'
                                                                                 ,'CANTIDAD_PRODUCTOS'
                                                                                 ,l_Item);
      l_Trama_Rk(l_Item).Subtrama_Rk1 := Carga_Trama_Rk1(p_Cuerpo_Tx
                                                        ,l_Trama_Rk(l_Item).Cantidad_Productos
                                                        ,l_Item);
    END LOOP;
    RETURN l_Trama_Rk;
  END;

  FUNCTION Carga_Trama_Rk1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rk1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Rk1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rk1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Rk1(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RK1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item
                                                                        ,p_Ind);
      l_Trama_Rk1(l_Item).Signo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'RK1'
                                                                     ,'SIGNO'
                                                                     ,l_Item
                                                                     ,p_Ind);
      l_Trama_Rk1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RK1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item
                                                                        ,p_Ind);
    END LOOP;
    RETURN l_Trama_Rk1;
  END;

  FUNCTION Carga_Trama_Rl(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rl IS
    l_Trama_Rl Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rl;
  BEGIN
    l_Trama_Rl.Tipo_Movimiento_Padre   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RL'
                                                                            ,'TIPO_MOVIMIENTO_PADRE');
    l_Trama_Rl.Tipo_Movimiento_Hijo    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RL'
                                                                            ,'TIPO_MOVIMIENTO_HIJO');
    l_Trama_Rl.Folio                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RL'
                                                                            ,'FOLIO');
    l_Trama_Rl.Numero_Pedido           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RL'
                                                                            ,'NUMERO_PEDIDO');
    l_Trama_Rl.Guia_Electronica        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RL'
                                                                            ,'GUIA_ELECTRONICA');
    l_Trama_Rl.Guia_Despacho           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RL'
                                                                            ,'GUIA_DESPACHO');
    l_Trama_Rl.Tipo_Guia_Despacho      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RL'
                                                                            ,'TIPO_GUIA_DESPACHO');
    l_Trama_Rl.Accion_Sobre_Existencia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RL'
                                                                            ,'ACCION_SOBRE_EXISTENCIA');
    l_Trama_Rl.Cantidad_Productos      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RL'
                                                                            ,'CANTIDAD_PRODUCTOS');
    l_Trama_Rl.Subtrama_Rl1            := Carga_Trama_Rl1(p_Cuerpo_Tx
                                                         ,l_Trama_Rl.Cantidad_Productos);
    RETURN l_Trama_Rl;
  END;

  FUNCTION Carga_Trama_Rl1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rl1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Rl1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rl1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Rl1(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RL1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item);
      l_Trama_Rl1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RL1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
    END LOOP;
    RETURN l_Trama_Rl1;
  END;

  FUNCTION Carga_Trama_Rm(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rm IS
    l_Trama_Rm Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rm;
  BEGIN
    l_Trama_Rm.Tipo_Movimiento_Padre := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'RM'
                                                                          ,'TIPO_MOVIMIENTO_PADRE');
    l_Trama_Rm.Tipo_Movimiento_Hijo  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'RM'
                                                                          ,'TIPO_MOVIMIENTO_HIJO');
    l_Trama_Rm.Folio                 := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'RM'
                                                                          ,'FOLIO');
    l_Trama_Rm.Fecha_Expiracion      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'RM'
                                                                          ,'FECHA_EXPIRACION');
    l_Trama_Rm.Certificados_Origen   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'RM'
                                                                          ,'CERTIFICADOS_ORIGEN');
    l_Trama_Rm.Cantidad_Productos    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'RM'
                                                                          ,'CANTIDAD_PRODUCTOS');
    l_Trama_Rm.Subtrama_Rm1          := Carga_Trama_Rm1(p_Cuerpo_Tx
                                                       ,l_Trama_Rm.Cantidad_Productos);
    RETURN l_Trama_Rm;
  END;

  FUNCTION Carga_Trama_Rm1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rm1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Rm1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rm1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Rm1(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RM1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item);
      l_Trama_Rm1(l_Item).Tipo_Movimiento := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'RM1'
                                                                               ,'TIPO_MOVIMIENTO'
                                                                               ,l_Item);
      l_Trama_Rm1(l_Item).Accion_Sobre_Existencia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                       ,'RM1'
                                                                                       ,'ACCION_SOBRE_EXISTENCIA'
                                                                                       ,l_Item);
      l_Trama_Rm1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RM1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
      l_Trama_Rm1(l_Item).Cantidad_Decimal := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'RM1'
                                                                                ,'CANTIDAD_DECIMAL'
                                                                                ,l_Item);
      l_Trama_Rm1(l_Item).Ot := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                  ,'RM1'
                                                                  ,'OT'
                                                                  ,l_Item);
      l_Trama_Rm1(l_Item).Lote := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'RM1'
                                                                    ,'LOTE'
                                                                    ,l_Item);
      l_Trama_Rm1(l_Item).Fecha_Expiracion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'RM1'
                                                                                ,'FECHA_EXPIRACION'
                                                                                ,l_Item);
      l_Trama_Rm1(l_Item).Valorizacion_Entero := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'RM1'
                                                                                   ,'VALORIZACION_ENTERO'
                                                                                   ,l_Item);
      l_Trama_Rm1(l_Item).Valorizacion_Decimal := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'RM1'
                                                                                    ,'VALORIZACION_DECIMAL'
                                                                                    ,l_Item);
      l_Trama_Rm1(l_Item).Unidad_Medida := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'RM1'
                                                                             ,'UNIDAD_MEDIDA'
                                                                             ,l_Item);
      l_Trama_Rm1(l_Item).Motivo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'RM1'
                                                                      ,'MOTIVO'
                                                                      ,l_Item);
      l_Trama_Rm1(l_Item).Id_Envio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RM1'
                                                                        ,'ID_ENVIO'
                                                                        ,l_Item);
      l_Trama_Rm1(l_Item).Numero_Ingreso := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'RM1'
                                                                              ,'NUMERO_INGRESO'
                                                                              ,l_Item);
      l_Trama_Rm1(l_Item).Linea_Compra := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RM1'
                                                                            ,'LINEA_COMPRA'
                                                                            ,l_Item);
    END LOOP;
    RETURN l_Trama_Rm1;
  END;

  FUNCTION Carga_Trama_Ro(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ro IS
    l_Trama_Ro Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ro;
  BEGIN
    l_Trama_Ro.Cantidad_Ordenes_Trabajo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'RO'
                                                                             ,'CANTIDAD_ORDENES_TRABAJO');
    l_Trama_Ro.Subtrama_Ro1             := Carga_Trama_Ro1(p_Cuerpo_Tx
                                                          ,l_Trama_Ro.Cantidad_Ordenes_Trabajo);
    RETURN l_Trama_Ro;
  END;

  FUNCTION Carga_Trama_Ro1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ro1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Ro1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ro1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Ro1(l_Item).Numero_Orden_Trabajo := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                         ,'RO1'
                                                                                         ,'NUMERO_ORDEN_TRABAJO'
                                                                                         ,l_Item));
      l_Trama_Ro1(l_Item).Total_Envases := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'RO1'
                                                                             ,'TOTAL_ENVASES'
                                                                             ,l_Item);
    END LOOP;
    RETURN l_Trama_Ro1;
  END;

  FUNCTION Carga_Trama_Rp(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Rp Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'RP'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Rp(l_Item).Serie := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'RP'
                                                                    ,'SERIE'
                                                                    ,l_Item);
      l_Trama_Rp(l_Item).Secuencia_b := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'RP'
                                                                          ,'SECUENCIA_B'
                                                                          ,l_Item);
      --//--------------------------------------------------------------------------\\
      --// CBR 17/08/2020 05:33                                                     \\
      --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
      --//-----------------------------------------------------------------Inicio---\\
      l_Trama_Rp(l_Item).Rut_Medico := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'RP'
                                                                         ,'RUT_MEDICO'
                                                                         ,l_Item);
      --//-----------------------------------------------------------------Termino--\\
      l_Trama_Rp(l_Item).Rut_Medico := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'RP'
                                                                         ,'RUT_MEDICO'
                                                                         ,l_Item);
      l_Trama_Rp(l_Item).Dv_Rut_Medico := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RP'
                                                                            ,'DV_RUT_MEDICO'
                                                                            ,l_Item);
      l_Trama_Rp(l_Item).Nombre_Medico := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RP'
                                                                            ,'NOMBRE_MEDICO'
                                                                            ,l_Item);
      l_Trama_Rp(l_Item).Emision := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'RP'
                                                                      ,'EMISION'
                                                                      ,l_Item);
      l_Trama_Rp(l_Item).Diagnostico := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'RP'
                                                                          ,'DIAGNOSTICO'
                                                                          ,l_Item);
      l_Trama_Rp(l_Item).Firma := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'RP'
                                                                    ,'FIRMA'
                                                                    ,l_Item);
      l_Trama_Rp(l_Item).Tipo_Receta := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'RP'
                                                                          ,'TIPO_RECETA'
                                                                          ,l_Item);
      l_Trama_Rp(l_Item).Con_Copia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RP'
                                                                        ,'CON_COPIA'
                                                                        ,l_Item);
      l_Trama_Rp(l_Item).Folio_Receta := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'RP'
                                                                           ,'FOLIO_RECETA'
                                                                           ,l_Item);
      l_Trama_Rp(l_Item).Lista_Productos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'RP'
                                                                              ,'LISTA_PRODUCTOS'
                                                                              ,l_Item);
      l_Trama_Rp(l_Item).Subtrama_Rp1 := Carga_Trama_Rp1(p_Cuerpo_Tx
                                                        ,l_Trama_Rp(l_Item).Lista_Productos
                                                        ,l_Item);
    END LOOP;
    RETURN l_Trama_Rp;
  END;

  -- ============================================================
  -- DESARROLLO CUENTA CORRIENTE RECETA (CGC 16-12-2015)
  -- ============================================================
  FUNCTION Carga_Trama_Br(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Br IS
    l_Trama_Br Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Br;
  BEGIN
    l_Trama_Br.Id_Receta    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                 ,'BR'
                                                                 ,'ID_RECETA');
    l_Trama_Br.Rut_Paciente := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                 ,'BR'
                                                                 ,'RUT_PACIENTE');
    l_Trama_Br.Dv_Paciente  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                 ,'BR'
                                                                 ,'DV_PACIENTE');
    l_Trama_Br.Convenio     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                 ,'BR'
                                                                 ,'CONVENIO');
    l_Trama_Br.Plan         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                 ,'BR'
                                                                 ,'PLAN');
    RETURN l_Trama_Br;
  END;

  FUNCTION Carga_Trama_Ri(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ri IS
    l_Trama_Ri Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ri;
  BEGIN
    l_Trama_Ri.Id_Receta          := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                       ,'ID_RECETA');
    l_Trama_Ri.Copia_Verde        := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                       ,'COPIA_VERDE');
    l_Trama_Ri.Secuencia_Receta   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                       ,'SECUENCIA_RECETA');
    l_Trama_Ri.Serie              := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                       ,'SERIE');
    l_Trama_Ri.Folio              := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                       ,'FOLIO');
    l_Trama_Ri.Fecha_Emision      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                       ,'FECHA_EMISION');
    l_Trama_Ri.Identi_Cliente     := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                       ,'IDENTI_CLIENTE');
    l_Trama_Ri.Rut_Cliente        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                       ,'RUT_CLIENTE');
    l_Trama_Ri.Dv_Cliente         := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                       ,'DV_CLIENTE');
    l_Trama_Ri.Nombre_Cliente     := Scfr_Trx_Dyn_Pk.Limpiar_String(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                       ,'NOMBRE_CLIENTE'));
    l_Trama_Ri.Identi_Paciente    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                       ,'IDENTI_PACIENTE');
    l_Trama_Ri.Rut_Paciente       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                       ,'RUT_PACIENTE');
    l_Trama_Ri.Dv_Paciente        := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                     ,'DV_PACIENTE');
    l_Trama_Ri.Nombre_Paciente    := Scfr_Trx_Dyn_Pk.Limpiar_String(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                       ,'NOMBRE_PACIENTE'));
    l_Trama_Ri.Telefono           := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                       ,'TELEFONO');
    l_Trama_Ri.Identi_Medico      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                       ,'IDENTI_MEDICO');
    l_Trama_Ri.Rut_Medico         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                       ,'RUT_MEDICO');
    l_Trama_Ri.Dv_Medico          := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                       ,'DV_MEDICO');
    l_Trama_Ri.Nombre_Medico      := Scfr_Trx_Dyn_Pk.Limpiar_String(SUBSTR(TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                       ,'NOMBRE_MEDICO')),1,60));
    l_Trama_Ri.Identi_Institucion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                       ,'IDENTI_INSTITUCION');
    l_Trama_Ri.Rut_Institucion    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                       ,'RUT_INSTITUCION');
    l_Trama_Ri.Dv_Institucion     := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                       ,'DV_INSTITUCION');
    l_Trama_Ri.Nombre_Institucion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                       ,'NOMBRE_INSTITUCION');
    l_Trama_Ri.Lista_Productos    := Scfr_Trx_Dyn_Pk.Limpiar_String(Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RI'
                                                                       ,'LISTA_PRODUCTOS'));
    l_Trama_Ri.Subtrama_Ri1       := Carga_Trama_Ri1(p_Cuerpo_Tx
                                                    ,l_Trama_Ri.Lista_Productos);
    RETURN l_Trama_Ri;
  END;

  FUNCTION Carga_Trama_Ri1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ri1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Ri1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ri1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Ri1(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RI1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item);
      l_Trama_Ri1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RI1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
      l_Trama_Ri1(l_Item).Dosis := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'RI1'
                                                                     ,'DOSIS'
                                                                     ,l_Item);
      l_Trama_Ri1(l_Item).Veces := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'RI1'
                                                                     ,'VECES'
                                                                     ,l_Item);
      l_Trama_Ri1(l_Item).Dias := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'RI1'
                                                                    ,'DIAS'
                                                                    ,l_Item);
      l_Trama_Ri1(l_Item).Permanente := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'RI1'
                                                                          ,'PERMANENTE'
                                                                          ,l_Item);
      l_Trama_Ri1(l_Item).Indicaciones := Scfr_Trx_Dyn_Pk.Limpiar_String(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RI1'
                                                                            ,'INDICACIONES'
                                                                            ,l_Item));
      l_Trama_Ri1(l_Item).Retiro := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'RI1'
                                                                      ,'RETIRO'
                                                                      ,l_Item);
    END LOOP;
    RETURN l_Trama_Ri1;
  END;

  FUNCTION Carga_Trama_Rp8(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Rp Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'RP'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Rp(l_Item).Id_Receta := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RP'
                                                                        ,'ID_RECETA'
                                                                        ,l_Item);
      l_Trama_Rp(l_Item).Local_Origen := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'RP'
                                                                           ,'LOCAL_ORIGEN'
                                                                           ,l_Item);
      l_Trama_Rp(l_Item).Fecha_Emision := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RP'
                                                                            ,'FECHA_EMISION'
                                                                            ,l_Item);
      l_Trama_Rp(l_Item).Convenio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RP'
                                                                       ,'CONVENIO'
                                                                       ,l_Item);
      l_Trama_Rp(l_Item).Plan := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'RP'
                                                                   ,'PLAN'
                                                                   ,l_Item);
      l_Trama_Rp(l_Item).Estado_Receta := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RP'
                                                                            ,'ESTADO_RECETA'
                                                                            ,l_Item);
      l_Trama_Rp(l_Item).Serie := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'RP'
                                                                    ,'SERIE'
                                                                    ,l_Item);
      l_Trama_Rp(l_Item).Folio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'RP'
                                                                    ,'FOLIO'
                                                                    ,l_Item);
      l_Trama_Rp(l_Item).Despacho_Anticipado := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'RP'
                                                                                  ,'DESPACHO_ANTICIPADO'
                                                                                  ,l_Item);
      l_Trama_Rp(l_Item).Fecha_Ingreso := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RP'
                                                                            ,'FECHA_INGRESO'
                                                                            ,l_Item);
      l_Trama_Rp(l_Item).Rut_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'RP'
                                                                           ,'RUT_VENDEDOR'
                                                                           ,l_Item);
      l_Trama_Rp(l_Item).Dv_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'RP'
                                                                          ,'DV_VENDEDOR'
                                                                          ,l_Item);
      l_Trama_Rp(l_Item).Rut_Cliente := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'RP'
                                                                          ,'RUT_CLIENTE'
                                                                          ,l_Item);
      l_Trama_Rp(l_Item).Dv_Cliente := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'RP'
                                                                         ,'DV_CLIENTE'
                                                                         ,l_Item);
      l_Trama_Rp(l_Item).Nombre_Cliente := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'RP'
                                                                             ,'NOMBRE_CLIENTE'
                                                                             ,l_Item);
      l_Trama_Rp(l_Item).Rut_Paciente := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'RP'
                                                                           ,'RUT_PACIENTE'
                                                                           ,l_Item);
      l_Trama_Rp(l_Item).Dv_Paciente := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'RP'
                                                                          ,'DV_PACIENTE'
                                                                          ,l_Item);
      l_Trama_Rp(l_Item).Nombre_Paciente := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'RP'
                                                                              ,'NOMBRE_PACIENTE'
                                                                              ,l_Item);
      l_Trama_Rp(l_Item).Telefono := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RP'
                                                                       ,'TELEFONO'
                                                                       ,l_Item);
      l_Trama_Rp(l_Item).Rut_Medico := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'RP'
                                                                         ,'RUT_MEDICO'
                                                                         ,l_Item);
      l_Trama_Rp(l_Item).Dv_Medico := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RP'
                                                                        ,'DV_MEDICO'
                                                                        ,l_Item);
      l_Trama_Rp(l_Item).Nombre_Medico := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RP'
                                                                            ,'NOMBRE_MEDICO'
                                                                            ,l_Item);
      l_Trama_Rp(l_Item).Lista_Productos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'RP'
                                                                              ,'LISTA_PRODUCTOS'
                                                                              ,l_Item);
      l_Trama_Rp(l_Item).Historial_Productos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'RP'
                                                                                  ,'HISTORIAL_PRODUCTOS'
                                                                                  ,l_Item);
      l_Trama_Rp(l_Item).Subtrama_Rp1 := Carga_Trama_Rp2(p_Cuerpo_Tx
                                                        ,l_Trama_Rp(l_Item).Lista_Productos
                                                        ,l_Item);
      l_Trama_Rp(l_Item).Subtrama_Rp2 := Carga_Trama_Rp3(p_Cuerpo_Tx
                                                        ,l_Trama_Rp(l_Item).Historial_Productos
                                                        ,l_Item);
    END LOOP;
    RETURN l_Trama_Rp;
  END;

  FUNCTION Carga_Trama_Rp2(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Rp1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Rp1(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RP1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item
                                                                        ,p_Ind);
      l_Trama_Rp1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RP1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item
                                                                        ,p_Ind);
      l_Trama_Rp1(l_Item).Dosis := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'RP1'
                                                                     ,'DOSIS'
                                                                     ,l_Item
                                                                     ,p_Ind);
      l_Trama_Rp1(l_Item).Veces := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'RP1'
                                                                     ,'VECES'
                                                                     ,l_Item
                                                                     ,p_Ind);
      l_Trama_Rp1(l_Item).Dias := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'RP1'
                                                                    ,'DIAS'
                                                                    ,l_Item
                                                                    ,p_Ind);
      l_Trama_Rp1(l_Item).Estado_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'RP1'
                                                                               ,'ESTADO_PRODUCTO'
                                                                               ,l_Item
                                                                               ,p_Ind);
      l_Trama_Rp1(l_Item).Permanente := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'RP1'
                                                                          ,'PERMANENTE'
                                                                          ,l_Item
                                                                          ,p_Ind);
      l_Trama_Rp1(l_Item).Indicaciones := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RP1'
                                                                            ,'INDICACIONES'
                                                                            ,l_Item
                                                                            ,p_Ind);
      l_Trama_Rp1(l_Item).Retiro_Anticipado := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'RP1'
                                                                                 ,'RETIRO_ANTICIPADO'
                                                                                 ,l_Item
                                                                                 ,p_Ind);
      l_Trama_Rp1(l_Item).Retiro_Actual := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'RP1'
                                                                             ,'RETIRO_ACTUAL'
                                                                             ,l_Item
                                                                             ,p_Ind);
      l_Trama_Rp1(l_Item).Total_Retiros := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'RP1'
                                                                             ,'TOTAL_RETIROS'
                                                                             ,l_Item
                                                                             ,p_Ind);
      l_Trama_Rp1(l_Item).Fecha_Proximo_Retiro := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'RP1'
                                                                                    ,'FECHA_PROXIMO_RETIRO'
                                                                                    ,l_Item
                                                                                    ,p_Ind);
      l_Trama_Rp1(l_Item).Fecha_Termino_Tratamiento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                         ,'RP1'
                                                                                         ,'FECHA_TERMINO_TRATAMIENTO'
                                                                                         ,l_Item
                                                                                         ,p_Ind);
      l_Trama_Rp1(l_Item).Cantidad_Despacho_Anterior := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'RP1'
                                                                                          ,'CANTIDAD_DESPACHO_ANTERIOR'
                                                                                          ,l_Item
                                                                                          ,p_Ind);
      l_Trama_Rp1(l_Item).Cantidad_Despacho_Total := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                       ,'RP1'
                                                                                       ,'CANTIDAD_DESPACHO_TOTAL'
                                                                                       ,l_Item
                                                                                       ,p_Ind);
      l_Trama_Rp1(l_Item).Cantidad_Pendiente := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'RP1'
                                                                                  ,'CANTIDAD_PENDIENTE'
                                                                                  ,l_Item
                                                                                  ,p_Ind);
    END LOOP;
    RETURN l_Trama_Rp1;
  END;

  FUNCTION Carga_Trama_Rp3(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp2 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Rp2 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp2;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Rp2(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RP1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item
                                                                        ,p_Ind);
      l_Trama_Rp2(l_Item).Numero_Retiro := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'RP1'
                                                                             ,'NUMERO_RETIRO'
                                                                             ,l_Item
                                                                             ,p_Ind);
      l_Trama_Rp2(l_Item).Total_Retiros := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'RP1'
                                                                             ,'TOTAL_RETIROS'
                                                                             ,l_Item
                                                                             ,p_Ind);
      l_Trama_Rp2(l_Item).Folio_Documento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'RP1'
                                                                               ,'FOLIO_DOCUMENTO'
                                                                               ,l_Item
                                                                               ,p_Ind);
      l_Trama_Rp2(l_Item).Fecha_Documento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'RP1'
                                                                               ,'FECHA_DOCUMENTO'
                                                                               ,l_Item
                                                                               ,p_Ind);
      l_Trama_Rp2(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RP1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item
                                                                        ,p_Ind);
    END LOOP;
    RETURN l_Trama_Rp2;
  END;

  FUNCTION Carga_Trama_Rv(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rv IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Rv Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rv;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'RV'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Rv(l_Item).Id_Receta := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RV'
                                                                        ,'ID_RECETA'
                                                                        ,l_Item);
      l_Trama_Rv(l_Item).Convenio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RV'
                                                                       ,'CONVENIO'
                                                                       ,l_Item);
      l_Trama_Rv(l_Item).Plan := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'RV'
                                                                   ,'PLAN'
                                                                   ,l_Item);
      l_Trama_Rv(l_Item).Folio := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'RV'
                                                                    ,'FOLIO'
                                                                    ,l_Item);
      l_Trama_Rv(l_Item).Lista_Productos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'RV'
                                                                              ,'LISTA_PRODUCTOS'
                                                                              ,l_Item);
      l_Trama_Rv(l_Item).Subtrama_Rv1 := Carga_Trama_Rv1(p_Cuerpo_Tx
                                                        ,l_Trama_Rv(l_Item).Lista_Productos
                                                        ,l_Item);
    END LOOP;
    RETURN l_Trama_Rv;
  END;

  FUNCTION Carga_Trama_Rv1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rv1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Rv1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rv1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Rv1(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RV1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item
                                                                        ,p_Ind);
      l_Trama_Rv1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RV1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item
                                                                        ,p_Ind);
      l_Trama_Rv1(l_Item).Decimal_Cantidad := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                        ,'RV1'
                                                                                        ,'DECIMAL_CANTIDAD'
                                                                                        ,l_Item
                                                                                        ,p_Ind)
                                                     ,'-'
                                                     ,'0');
      l_Trama_Rv1(l_Item).Cantidad := To_Number(l_Trama_Rv1(l_Item).Cantidad || '.' || l_Trama_Rv1(l_Item).Decimal_Cantidad
                                               ,'999999999999.9999');
    END LOOP;
    RETURN l_Trama_Rv1;
  END;

  -- ============================================================
  -- DESARROLLO CUENTA CORRIENTE RECETA ( FIN )
  -- ============================================================
  FUNCTION Carga_Trama_Rp9(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Rp Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'RP'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Rp(l_Item).Serie := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'RP'
                                                                    ,'SERIE'
                                                                    ,l_Item);
      l_Trama_Rp(l_Item).Secuencia_b := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'RP'
                                                                          ,'SECUENCIA_B'
                                                                          ,l_Item);
      l_Trama_Rp(l_Item).Secuencia_Receta := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'RP'
                                                                               ,'SECUENCIA_RECETA'
                                                                               ,l_Item);
      l_Trama_Rp(l_Item).Rut_Medico := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'RP'
                                                                         ,'RUT_MEDICO'
                                                                         ,l_Item);
      l_Trama_Rp(l_Item).Dv_Rut_Medico := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RP'
                                                                            ,'DV_RUT_MEDICO'
                                                                            ,l_Item);
      l_Trama_Rp(l_Item).Nombre_Medico := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RP'
                                                                            ,'NOMBRE_MEDICO'
                                                                            ,l_Item);
      l_Trama_Rp(l_Item).Emision := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'RP'
                                                                      ,'EMISION'
                                                                      ,l_Item);
      l_Trama_Rp(l_Item).Diagnostico := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'RP'
                                                                          ,'DIAGNOSTICO'
                                                                          ,l_Item);
      l_Trama_Rp(l_Item).Firma := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'RP'
                                                                    ,'FIRMA'
                                                                    ,l_Item);
      l_Trama_Rp(l_Item).Tipo_Receta := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'RP'
                                                                          ,'TIPO_RECETA'
                                                                          ,l_Item);
      l_Trama_Rp(l_Item).Con_Copia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RP'
                                                                        ,'CON_COPIA'
                                                                        ,l_Item);
      l_Trama_Rp(l_Item).Folio_Receta := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'RP'
                                                                           ,'FOLIO_RECETA'
                                                                           ,l_Item);
      l_Trama_Rp(l_Item).Tipo_Medicamento := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'RP'
                                                                               ,'TIPO_MEDICAMENTO'
                                                                               ,l_Item);
      l_Trama_Rp(l_Item).Rut_Paciente := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'RP'
                                                                           ,'RUT_PACIENTE'
                                                                           ,l_Item);
      l_Trama_Rp(l_Item).Dv_Paciente := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'RP'
                                                                          ,'DV_PACIENTE'
                                                                          ,l_Item);
      l_Trama_Rp(l_Item).Nombre_Paciente := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'RP'
                                                                              ,'NOMBRE_PACIENTE'
                                                                              ,l_Item);
      l_Trama_Rp(l_Item).Fecha_Ingreso_Paciente := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'RP'
                                                                                     ,'FECHA_INGRESO_PACIENTE'
                                                                                     ,l_Item);
      l_Trama_Rp(l_Item).Fono_Paciente := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'RP'
                                                                            ,'FONO_PACIENTE'
                                                                            ,l_Item);
      l_Trama_Rp(l_Item).Convenio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RP'
                                                                       ,'CONVENIO'
                                                                       ,l_Item);
      l_Trama_Rp(l_Item).Plan := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'RP'
                                                                   ,'PLAN'
                                                                   ,l_Item);
      l_Trama_Rp(l_Item).Rut_Institucion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'RP'
                                                                              ,'RUT_INSTITUCION'
                                                                              ,l_Item);
      l_Trama_Rp(l_Item).Dv_Institucion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'RP'
                                                                             ,'DV_INSTITUCION'
                                                                             ,l_Item);
      l_Trama_Rp(l_Item).Lista_Productos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'RP'
                                                                              ,'LISTA_PRODUCTOS'
                                                                              ,l_Item);
      l_Trama_Rp(l_Item).Subtrama_Rp1 := Carga_Trama_Rp1(p_Cuerpo_Tx
                                                        ,l_Trama_Rp(l_Item).Lista_Productos
                                                        ,l_Item);
    END LOOP;
    RETURN l_Trama_Rp;
  END;

  FUNCTION Carga_Trama_Rpu(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rpu IS
    l_Trama_Rpu Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rpu;
  BEGIN
    l_Trama_Rpu.Local           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'RPU'
                                                                     ,'LOCAL');
    l_Trama_Rpu.Rut_Vendedor    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'RPU'
                                                                     ,'RUT_VENDEDOR');
    l_Trama_Rpu.Dv_Rut_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'RPU'
                                                                     ,'DV_RUT_VENDEDOR');
    l_Trama_Rpu.Correlativo_Tx  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'RPU'
                                                                     ,'CORRELATIVO_TX');
    RETURN l_Trama_Rpu;
  END;

  FUNCTION Carga_Trama_Rp1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Rp1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Rp1(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RP1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item
                                                                        ,p_Ind);
      l_Trama_Rp1(l_Item).Tipo_Medicamento := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'RP1'
                                                                                ,'TIPO_MEDICAMENTO'
                                                                                ,l_Item
                                                                                ,p_Ind);
      l_Trama_Rp1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RP1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item
                                                                        ,p_Ind);
      l_Trama_Rp1(l_Item).Cantidad_Pendiente := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'RP1'
                                                                                  ,'CANTIDAD_PENDIENTE'
                                                                                  ,l_Item
                                                                                  ,p_Ind);
      l_Trama_Rp1(l_Item).Dosis := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'RP1'
                                                                     ,'DOSIS'
                                                                     ,l_Item
                                                                     ,p_Ind);
      l_Trama_Rp1(l_Item).Veces := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'RP1'
                                                                     ,'VECES'
                                                                     ,l_Item
                                                                     ,p_Ind);
      l_Trama_Rp1(l_Item).Dias := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'RP1'
                                                                    ,'DIAS'
                                                                    ,l_Item
                                                                    ,p_Ind);
      l_Trama_Rp1(l_Item).Inscribir_En_Refill := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'RP1'
                                                                                   ,'INSCRIBIR_EN_REFILL'
                                                                                   ,l_Item
                                                                                   ,p_Ind);
      l_Trama_Rp1(l_Item).Tipo_Inscripcion_Refill := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                       ,'RP1'
                                                                                       ,'TIPO_INSCRIPCION_REFILL'
                                                                                       ,l_Item
                                                                                       ,p_Ind);
      l_Trama_Rp1(l_Item).Texto := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'RP1'
                                                                     ,'TEXTO'
                                                                     ,l_Item
                                                                     ,p_Ind);
      l_Trama_Rp1(l_Item).Forma_Farmaceutica := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'RP1'
                                                                                  ,'FORMA_FARMACEUTICA'
                                                                                  ,l_Item
                                                                                  ,p_Ind);
    END LOOP;
    RETURN l_Trama_Rp1;
  END;

  FUNCTION Carga_Trama_Rr(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rr IS
    l_Trama_Rr Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rr;
  BEGIN
    l_Trama_Rr.Codigo_Autorizacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RR'
                                                                        ,'CODIGO_AUTORIZACION');
    l_Trama_Rr.Tipo_Documento      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RR'
                                                                        ,'TIPO_DOCUMENTO'); --JRC
    l_Trama_Rr.Folio               := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RR'
                                                                        ,'FOLIO'); --JRC

    RETURN l_Trama_Rr;
  END;

  --JRC 11/03/2020 Origen_Trx 'EMP' Excendemte al medio de pago
  --Se agregan a la trama RR campos Tipo de Documento y Folio
  /*  FUNCTION Carga_Trama_Rr1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rr1 IS
    l_Trama_Rr Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rr1;
  BEGIN
    l_Trama_Rr.Codigo_Autorizacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RR1'
                                                                        ,'CODIGO_AUTORIZACION');
    l_Trama_Rr.Tipo_Documento      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RR1'
                                                                        ,'TIPO_DOCUMENTO');
    l_Trama_Rr.Folio               := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'RR1'
                                                                        ,'FOLIO');
    RETURN l_Trama_Rr;
  END;*/

  FUNCTION Carga_Trama_Rs(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rs IS
    l_Trama_Rs Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rs;
  BEGIN
    l_Trama_Rs.Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                             ,'RS'
                                                             ,'PRODUCTO');
    RETURN l_Trama_Rs;
  END;

  FUNCTION Carga_Trama_Rx(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rx IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Rx Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rx;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'RX'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Rx(l_Item).Codigo_Servicio := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'RX'
                                                                              ,'CODIGO_SERVICIO'
                                                                              ,l_Item);
      l_Trama_Rx(l_Item).Rx := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                 ,'RX'
                                                                 ,'RX'
                                                                 ,l_Item);
      l_Trama_Rx(l_Item).Timespan := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'RX'
                                                                       ,'TIMESPAN'
                                                                       ,l_Item);
      l_Trama_Rx(l_Item).Rx_Ack := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'RX'
                                                                     ,'RX_ACK'
                                                                     ,l_Item);
      l_Trama_Rx(l_Item).Rx_Nack := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'RX'
                                                                      ,'RX_NACK'
                                                                      ,l_Item);
      l_Trama_Rx(l_Item).Rx_Con_Servicio := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'RX'
                                                                              ,'RX_CON_SERVICIO'
                                                                              ,l_Item);
      l_Trama_Rx(l_Item).Rx_Sin_Servicio := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'RX'
                                                                              ,'RX_SIN_SERVICIO'
                                                                              ,l_Item);
      l_Trama_Rx(l_Item).Rx_Timeout := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'RX'
                                                                         ,'RX_TIMEOUT'
                                                                         ,l_Item);
      l_Trama_Rx(l_Item).Rx_Erronea := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'RX'
                                                                         ,'RX_ERRONEA'
                                                                         ,l_Item);
    END LOOP;
    RETURN l_Trama_Rx;
  END;

  FUNCTION Carga_Trama_Sc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Sc IS
    l_Trama_Sc Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Sc;
  BEGIN
    l_Trama_Sc.Puntos                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'SC'
                                                                             ,'PUNTOS');
    l_Trama_Sc.Minimo_Canje_Puntos      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'SC'
                                                                             ,'MINIMO_CANJE_PUNTOS');
    l_Trama_Sc.Operaciones_Fidelizacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'SC'
                                                                             ,'OPERACIONES_FIDELIZACION');
    l_Trama_Sc.Cantidad_Productos       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'SC'
                                                                             ,'CANTIDAD_PRODUCTOS');
    l_Trama_Sc.Lista_Beneficiarios      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'SC'
                                                                             ,'LISTA_BENEFICIARIOS');
    l_Trama_Sc.Cantidad_Cuotas          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'SC'
                                                                             ,'CANTIDAD_CUOTAS');
    l_Trama_Sc.Subtrama_Sc1             := Carga_Trama_Sc1(p_Cuerpo_Tx
                                                          ,l_Trama_Sc.Cantidad_Productos);
    l_Trama_Sc.Subtrama_Sc2             := Carga_Trama_Sc2(p_Cuerpo_Tx
                                                          ,l_Trama_Sc.Lista_Beneficiarios);
    l_Trama_Sc.Subtrama_Sc3             := Carga_Trama_Sc3(p_Cuerpo_Tx
                                                          ,l_Trama_Sc.Cantidad_Cuotas);
    RETURN l_Trama_Sc;
  END;

  FUNCTION Carga_Trama_Sc1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Sc1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Sc1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Sc1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Sc1(l_Item).Codigo_Producto_Interno := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                       ,'SC1'
                                                                                       ,'CODIGO_PRODUCTO_INTERNO'
                                                                                       ,l_Item);
      l_Trama_Sc1(l_Item).Familia_Comercial := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'SC1'
                                                                                 ,'FAMILIA_COMERCIAL'
                                                                                 ,l_Item);
      l_Trama_Sc1(l_Item).Tope := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'SC1'
                                                                    ,'TOPE'
                                                                    ,l_Item);
      l_Trama_Sc1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'SC1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
      l_Trama_Sc1(l_Item).Fecha_Transaccion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'SC1'
                                                                                 ,'FECHA_TRANSACCION'
                                                                                 ,l_Item);
      l_Trama_Sc1(l_Item).Convenio_Compra_Frecuente := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                         ,'SC1'
                                                                                         ,'CONVENIO_COMPRA_FRECUENTE'
                                                                                         ,l_Item);
      l_Trama_Sc1(l_Item).Fecha_Expiracion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'SC1'
                                                                                ,'FECHA_EXPIRACION'
                                                                                ,l_Item);
      l_Trama_Sc1(l_Item).Glosa_Reclamo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'SC1'
                                                                             ,'GLOSA_RECLAMO'
                                                                             ,l_Item);
      l_Trama_Sc1(l_Item).Porcentaje_Descuento := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'SC1'
                                                                                    ,'PORCENTAJE_DESCUENTO'
                                                                                    ,l_Item);
      l_Trama_Sc1(l_Item).Signo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'SC1'
                                                                     ,'SIGNO'
                                                                     ,l_Item);
      l_Trama_Sc1(l_Item).Cantidad_Eventos_Beneficio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'SC1'
                                                                                          ,'CANTIDAD_EVENTOS_BENEFICIO'
                                                                                          ,l_Item);
    END LOOP;
    RETURN l_Trama_Sc1;
  END;

  FUNCTION Carga_Trama_Sc2(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Sc2 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Sc2 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Sc2;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Sc2(l_Item).Rut_Beneficiario := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'SC2'
                                                                                ,'RUT_BENEFICIARIO'
                                                                                ,l_Item);
      l_Trama_Sc2(l_Item).Dv_Rut_Beneficiario := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'SC2'
                                                                                   ,'DV_RUT_BENEFICIARIO'
                                                                                   ,l_Item);
      l_Trama_Sc2(l_Item).Titular := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'SC2'
                                                                       ,'TITULAR'
                                                                       ,l_Item);
      l_Trama_Sc2(l_Item).Copago := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'SC2'
                                                                      ,'COPAGO'
                                                                      ,l_Item);
      l_Trama_Sc2(l_Item).Deducible_Evento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'SC2'
                                                                                ,'DEDUCIBLE_EVENTO'
                                                                                ,l_Item);
      l_Trama_Sc2(l_Item).Fecha_Nacimiento := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'SC2'
                                                                                ,'FECHA_NACIMIENTO'
                                                                                ,l_Item);
      l_Trama_Sc2(l_Item).Convenio_Relacionado := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'SC2'
                                                                                    ,'CONVENIO_RELACIONADO'
                                                                                    ,l_Item);
      l_Trama_Sc2(l_Item).Convenio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'SC2'
                                                                        ,'CONVENIO'
                                                                        ,l_Item);
      l_Trama_Sc2(l_Item).Sexo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'SC2'
                                                                    ,'SEXO'
                                                                    ,l_Item);
      l_Trama_Sc2(l_Item).Accede_Dicc := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'SC2'
                                                                           ,'ACCEDE_DICC'
                                                                           ,l_Item);
      l_Trama_Sc2(l_Item).Dv_Numero_Inscripcion := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'SC2'
                                                                                          ,'DV_NUMERO_INSCRIPCION'
                                                                                          ,l_Item));
      l_Trama_Sc2(l_Item).Cupo_Total := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'SC2'
                                                                          ,'CUPO_TOTAL'
                                                                          ,l_Item);
      l_Trama_Sc2(l_Item).Numero_Cuenta := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'SC2'
                                                                                  ,'NUMERO_CUENTA'
                                                                                  ,l_Item));
    END LOOP;
    RETURN l_Trama_Sc2;
  END;

  FUNCTION Carga_Trama_Sc3(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Sc3 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Sc3 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Sc3;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Sc3(l_Item).Numero_Cuenta := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'SC3'
                                                                                  ,'NUMERO_CUENTA'
                                                                                  ,l_Item));
    END LOOP;
    RETURN l_Trama_Sc3;
  END;

  FUNCTION Carga_Trama_Sp(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Sp IS
    l_Trama_Sp Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Sp;
  BEGIN
    l_Trama_Sp.Local           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'SP'
                                                                    ,'LOCAL');
    l_Trama_Sp.Tipo_Movimiento := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'SP'
                                                                    ,'TIPO_MOVIMIENTO');
    l_Trama_Sp.Folio           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'SP'
                                                                    ,'FOLIO');
    RETURN l_Trama_Sp;
  END;

  FUNCTION Carga_Trama_St(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_St IS
    l_Trama_St Scfr_Trx_Dyn_Types_Pk.Rec_Trama_St;
  BEGIN
    l_Trama_St.Tipo_Consulta := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                  ,'ST'
                                                                  ,'TIPO_CONSULTA');
    RETURN l_Trama_St;
  END;

  FUNCTION Carga_Trama_Ta(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ta IS
    l_Trama_Ta Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ta;
  BEGIN
    l_Trama_Ta.Correlativo_Tx          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'TA'
                                                                            ,'CORRELATIVO_TX');
    l_Trama_Ta.Puntos                  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'TA'
                                                                            ,'PUNTOS');
    l_Trama_Ta.Destino                 := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'TA'
                                                                            ,'DESTINO');
    l_Trama_Ta.Correlativo_Tx_Asociado := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'TA'
                                                                            ,'CORRELATIVO_TX_ASOCIADO');
    RETURN l_Trama_Ta;
  END;

  FUNCTION Carga_Trama_Te(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Te IS
    l_Trama_Te Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Te;
  BEGIN
    l_Trama_Te.Timespan       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'TE'
                                                                   ,'TIMESPAN');
    l_Trama_Te.Tx_Respuesta   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                   ,'TE'
                                                                   ,'TX_RESPUESTA');
    l_Trama_Te.Tx_No_Enrutada := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                   ,'TE'
                                                                   ,'TX_NO_ENRUTADA');
    l_Trama_Te.Tx_No_Existe   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                   ,'TE'
                                                                   ,'TX_NO_EXISTE');
    l_Trama_Te.Tx_Timeout     := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                   ,'TE'
                                                                   ,'TX_TIMEOUT');
    l_Trama_Te.Tx_Erronea     := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                   ,'TE'
                                                                   ,'TX_ERRONEA');
    l_Trama_Te.Tx_Expirada    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                   ,'TE'
                                                                   ,'TX_EXPIRADA');
    l_Trama_Te.Tx_Online      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                   ,'TE'
                                                                   ,'TX_ONLINE');
    l_Trama_Te.Tx_Confirmada  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                   ,'TE'
                                                                   ,'TX_CONFIRMADA');
    l_Trama_Te.Tx_Nack        := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                   ,'TE'
                                                                   ,'TX_NACK');
    RETURN l_Trama_Te;
  END;

  FUNCTION Carga_Trama_Tm(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tm IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Tm Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tm;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'TM'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Tm(l_Item).Convenio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'TM'
                                                                       ,'CONVENIO'
                                                                       ,l_Item);
      l_Trama_Tm(l_Item).Plan := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'TM'
                                                                   ,'PLAN'
                                                                   ,l_Item);
      l_Trama_Tm(l_Item).Lista_Productos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'TM'
                                                                              ,'LISTA_PRODUCTOS'
                                                                              ,l_Item);
      l_Trama_Tm(l_Item).Subtrama_Tm1 := Carga_Trama_Tm1(p_Cuerpo_Tx
                                                        ,l_Trama_Tm(l_Item).Lista_Productos
                                                        ,l_Item);
    END LOOP;
    RETURN l_Trama_Tm;
  END;

  FUNCTION Carga_Trama_Tm1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tm1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Tm1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tm1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Tm1(l_Item).Codigo_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'TM1'
                                                                               ,'PRODUCTO'
                                                                               ,l_Item
                                                                               ,p_Ind);
      l_Trama_Tm1(l_Item).Dias_Autorizados := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'TM1'
                                                                                ,'DIAS_AUTORIZADOS'
                                                                                ,l_Item
                                                                                ,p_Ind);
      l_Trama_Tm1(l_Item).Fecha_Inicio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'TM1'
                                                                            ,'FECHA_INICIO'
                                                                            ,l_Item
                                                                            ,p_Ind);
      l_Trama_Tm1(l_Item).Fecha_Termino := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'TM1'
                                                                             ,'FECHA_TERMINO'
                                                                             ,l_Item
                                                                             ,p_Ind);
      l_Trama_Tm1(l_Item).Local := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'TM1'
                                                                     ,'LOCAL'
                                                                     ,l_Item
                                                                     ,p_Ind);
      l_Trama_Tm1(l_Item).Fecha_Compra := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'TM1'
                                                                            ,'FECHA_COMPRA'
                                                                            ,l_Item
                                                                            ,p_Ind);
    END LOOP;
    RETURN l_Trama_Tm1;
  END;

  FUNCTION Carga_Trama_Tp(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Tp IS
    l_Trama_Tp Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Tp;
  BEGIN
    l_Trama_Tp.Correlativo_Tx := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'TP'
                                                                   ,'CORRELATIVO_TX');
    l_Trama_Tp.Puntos         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'TP'
                                                                   ,'PUNTOS');
    l_Trama_Tp.Destino        := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                   ,'TP'
                                                                   ,'DESTINO');
    RETURN l_Trama_Tp;
  END;

  FUNCTION Carga_Trama_Tx(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tx IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Tx Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tx;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'TX'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Tx(l_Item).Codigo_Servicio := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'TX'
                                                                              ,'CODIGO_SERVICIO'
                                                                              ,l_Item);
      l_Trama_Tx(l_Item).Tx := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                 ,'TX'
                                                                 ,'TX'
                                                                 ,l_Item);
      l_Trama_Tx(l_Item).Timespan := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'TX'
                                                                       ,'TIMESPAN'
                                                                       ,l_Item);
      l_Trama_Tx(l_Item).Tx_Respuesta := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'TX'
                                                                           ,'TX_RESPUESTA'
                                                                           ,l_Item);
      l_Trama_Tx(l_Item).Tx_No_Enrutada := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'TX'
                                                                             ,'TX_NO_ENRUTADA'
                                                                             ,l_Item);
      l_Trama_Tx(l_Item).Tx_No_Existe := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'TX'
                                                                           ,'TX_NO_EXISTE'
                                                                           ,l_Item);
      l_Trama_Tx(l_Item).Tx_Timeout := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'TX'
                                                                         ,'TX_TIMEOUT'
                                                                         ,l_Item);
      l_Trama_Tx(l_Item).Tx_Erronea := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'TX'
                                                                         ,'TX_ERRONEA'
                                                                         ,l_Item);
      l_Trama_Tx(l_Item).Tx_Expirada := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'TX'
                                                                          ,'TX_EXPIRADA'
                                                                          ,l_Item);
      l_Trama_Tx(l_Item).Tx_Online := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'TX'
                                                                        ,'TX_ONLINE'
                                                                        ,l_Item);
      l_Trama_Tx(l_Item).Tx_Confirmada := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'TX'
                                                                            ,'TX_CONFIRMADA'
                                                                            ,l_Item);
      l_Trama_Tx(l_Item).Tx_Nack := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'TX'
                                                                      ,'TX_NACK'
                                                                      ,l_Item);
    END LOOP;
    RETURN l_Trama_Tx;
  END;

  FUNCTION Carga_Trama_Tt(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tt IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Tt Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tt;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'TT'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Tt(l_Item).Numero_Tarjeta := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'TT'
                                                                                  ,'NUMERO_TARJETA'
                                                                                  ,l_Item));
      l_Trama_Tt(l_Item).Patente := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'TT'
                                                                      ,'PATENTE'
                                                                      ,l_Item);
      l_Trama_Tt(l_Item).Estado := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'TT'
                                                                     ,'ESTADO'
                                                                     ,l_Item);
    END LOOP;
    RETURN l_Trama_Tt;
  END;

  FUNCTION Carga_Trama_Va(p_Trama_Pos IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Hpo
                         ,p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Va IS
    l_Trama_Va   Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Va;
    p_Iva        NUMBER := 0;
    p_Agrega_Iva VARCHAR2(2) := 'NO';
  BEGIN
    l_Trama_Va.Convenio            := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'VA'
                                                                        ,'CONVENIO');
    l_Trama_Va.Plan                := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'VA'
                                                                        ,'PLAN');
    l_Trama_Va.Rut_Titular         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'VA'
                                                                        ,'RUT_TITULAR');
    l_Trama_Va.Dv_Titular          := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'VA'
                                                                        ,'DV_TITULAR');
    l_Trama_Va.Secuencia_b         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'VA'
                                                                        ,'SECUENCIA_B');
    l_Trama_Va.Codigo_Autorizacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'VA'
                                                                        ,'CODIGO_AUTORIZACION');
    l_Trama_Va.Precio_Lista        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'VA'
                                                                        ,'PRECIO_LISTA');
    l_Trama_Va.Decimal_Plista      := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'VA'
                                                                                ,'DECIMAL_PRECIO_LISTA')
                                             ,'-'
                                             ,'0');
    l_Trama_Va.Precio_Lista        := To_Number(l_Trama_Va.Precio_Lista || '.' || l_Trama_Va.Decimal_Plista
                                               ,'999999999999.9999');

    l_Trama_Va.Bonificacion             := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'VA'
                                                                             ,'BONIFICACION');
    l_Trama_Va.Decimal_Bonif_1          := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'VA'
                                                                                     ,'DECIMAL_BONIFICACION')
                                                  ,'-'
                                                  ,'0');
    l_Trama_Va.Bonificacion             := To_Number(l_Trama_Va.Bonificacion || '.' || l_Trama_Va.Decimal_Bonif_1
                                                    ,'999999999999.9999');
    l_Trama_Va.Bonificacion_2           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'VA'
                                                                             ,'BONIFICACION_2');
    l_Trama_Va.Decimal_Bonif_2          := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'VA'
                                                                                     ,'DECIMAL_BONIFICACION_2')
                                                  ,'-'
                                                  ,'0');
    l_Trama_Va.Bonificacion_2           := To_Number(l_Trama_Va.Bonificacion_2 || '.' || l_Trama_Va.Decimal_Bonif_2
                                                    ,'999999999999.9999');
    l_Trama_Va.Copago                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'VA'
                                                                             ,'COPAGO');
    l_Trama_Va.Decimal_Copago           := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'VA'
                                                                                     ,'DECIMAL_COPAGO')
                                                  ,'-'
                                                  ,'0');
    l_Trama_Va.Copago                   := To_Number(l_Trama_Va.Copago || '.' || l_Trama_Va.Decimal_Copago
                                                    ,'999999999999.9999');
    l_Trama_Va.Cantidad_Cuotas          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'VA'
                                                                             ,'CANTIDAD_CUOTAS');
    l_Trama_Va.Monto_Copago_Ges         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'VA'
                                                                             ,'MONTO_COPAGO_GES');
    l_Trama_Va.Decimal_Copago_Ges       := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'VA'
                                                                                     ,'DECIMAL_MONTO_COPAGO_GES')
                                                  ,'-'
                                                  ,'0');
    l_Trama_Va.Monto_Copago_Ges         := To_Number(l_Trama_Va.Monto_Copago_Ges || '.' || l_Trama_Va.Decimal_Copago_Ges
                                                    ,'999999999999.9999');
    l_Trama_Va.Numero_Boleta            := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'VA'
                                                                                  ,'NUMERO_BOLETA'));
    l_Trama_Va.Requiere_Id_Receta       := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'VA'
                                                                             ,'REQUIERE_ID_RECETA');
    l_Trama_Va.Plan_Con_Guia            := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'VA'
                                                                             ,'PLAN_CON_GUIA');
    l_Trama_Va.Identificador_Titular    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'VA'
                                                                             ,'IDENTIFICADOR_TITULAR');
    l_Trama_Va.Identificacion_Comprador := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'VA'
                                                                             ,'IDENTIFICACION_COMPRADOR');
    l_Trama_Va.Serie_Factura            := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'VA'
                                                                             ,'SERIE_FACTURA');
    l_Trama_Va.Clave_Acceso             := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'VA'
                                                                             ,'CLAVE_ACCESO');
    l_Trama_Va.Id_Prestador             := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'VA'
                                                                             ,'ID_PRESTADOR');
    l_Trama_Va.De_Mail                  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'VA'
                                                                             ,'DE_MAIL');
    l_Trama_Va.Lista_Diagnosticos       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'VA'
                                                                             ,'LISTA_DIAGNOSTICOS');

    --//--------------------------------------------------------------------------\\
    --// CBR 21/03/2017 10:55                                                     \\
    --// Para las versiones de POS que no incluyen el iva en la GUIA              \\
    --//-----------------------------------------------------------------Inicio---\\
    IF Scfr_Trx_Dyn_Pk.Agrega_Iva(p_Trama_Pos.Cadena
                                 ,p_Trama_Pos.Empresa
                                 ,p_Trama_Pos.Local
                                 ,p_Iva) = 'SI' THEN
      BEGIN
        SELECT 'SI'
          INTO p_Agrega_Iva
          FROM Scfr_Convenios t
         WHERE t.Numero_Convenio = l_Trama_Va.Convenio
           AND t.Tipo_Convenio = 'GUI';

      EXCEPTION
        WHEN OTHERS THEN
          p_Agrega_Iva := 'NO'; -- estaba en null se cambia a 1 para dejarlo igual a batc
      END;

      IF p_Agrega_Iva = 'SI' THEN
        l_Trama_Va.Bonificacion   := Ceil(l_Trama_Va.Bonificacion * (1 + p_Iva / 100));
        l_Trama_Va.Bonificacion_2 := Ceil(l_Trama_Va.Bonificacion_2 * (1 + p_Iva / 100));
        l_Trama_Va.Copago         := Ceil(l_Trama_Va.Copago * (1 + p_Iva / 100));
      END IF;
    END IF;
    --//-----------------------------------------------------------------Termino--\\

    l_Trama_Va.Subtrama_Va1 := Carga_Trama_Va1(p_Cuerpo_Tx
                                              ,l_Trama_Va.Lista_Diagnosticos);

    RETURN l_Trama_Va;
  END;

  FUNCTION Carga_Trama_Va1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Va1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Va1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Va1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      /*l_Trama_Va1(l_Item).Diagnostico := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
      ,'VA4'
      ,'DIAGNOSTICO'
      ,l_Item); */
      l_Trama_Va1(l_Item).Diagnostico := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'VA4'
                                                                                ,'DIAGNOSTICO'
                                                                                ,l_Item));
    END LOOP;
    RETURN l_Trama_Va1;
  END;

  FUNCTION Carga_Trama_Vc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vc IS
    l_Trama_Vc Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vc;
  BEGIN
    l_Trama_Vc.Correlativo_Tx := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'VC'
                                                                   ,'CORRELATIVO_TX');
    l_Trama_Vc.Local          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'VC'
                                                                   ,'LOCAL');
    RETURN l_Trama_Vc;
  END;

  FUNCTION Carga_Trama_Vd(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vd IS
    l_Trama_Vd Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vd;
  BEGIN
    l_Trama_Vd.Correlativo_Tx        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VD'
                                                                          ,'CORRELATIVO_TX');
    l_Trama_Vd.Tipo_Movimiento_Padre := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VD'
                                                                          ,'TIPO_MOVIMIENTO_PADRE');
    l_Trama_Vd.Fecha                 := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VD'
                                                                          ,'FECHA');
    l_Trama_Vd.Hora_Venta            := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VD'
                                                                          ,'HORA_VENTA');
    l_Trama_Vd.Secuencia_b           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VD'
                                                                          ,'SECUENCIA_B');
    l_Trama_Vd.Numero_Cuenta         := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'VD'
                                                                               ,'NUMERO_CUENTA'));
    l_Trama_Vd.Codigo_Autorizacion   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VD'
                                                                          ,'CODIGO_AUTORIZACION');
    l_Trama_Vd.Local_Relacionado     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VD'
                                                                          ,'LOCAL_RELACIONADO');
    l_Trama_Vd.Codigo_Servicio       := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VD'
                                                                          ,'CODIGO_SERVICIO');
    l_Trama_Vd.Local                 := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VD'
                                                                          ,'LOCAL');
    l_Trama_Vd.Numero_Pos            := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VD'
                                                                          ,'NUMERO_POS');
    l_Trama_Vd.Destino               := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VD'
                                                                          ,'DESTINO');
    l_Trama_Vd.Sistema               := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VD'
                                                                          ,'SISTEMA');
    l_Trama_Vd.Funcion               := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VD'
                                                                          ,'FUNCION');
    l_Trama_Vd.Secuencia_c           := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VD'
                                                                          ,'SECUENCIA_C');
    l_Trama_Vd.Fecha_Transaccion     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VD'
                                                                          ,'FECHA_TRANSACCION');
    l_Trama_Vd.Correlativo           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VD'
                                                                          ,'CORRELATIVO');
    l_Trama_Vd.Numero_Trama          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VD'
                                                                          ,'NUMERO_TRAMA');
    l_Trama_Vd.Codigo_Transaccion    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VD'
                                                                          ,'CODIGO_TRANSACCION');
    l_Trama_Vd.Numero_Cuotas         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VD'
                                                                          ,'NUMERO_CUOTAS');
    l_Trama_Vd.Fecha_Inicio_Tx       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VD'
                                                                          ,'FECHA_INICIO_TX');
    l_Trama_Vd.Fecha_Cierre_Tx       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VD'
                                                                          ,'FECHA_CIERRE_TX');
    l_Trama_Vd.Documentos_Emitidos   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VD'
                                                                          ,'DOCUMENTOS_EMITIDOS');
    l_Trama_Vd.Subtrama_Vd1          := Carga_Trama_Vd1(p_Cuerpo_Tx
                                                       ,l_Trama_Vd.Documentos_Emitidos);
    RETURN l_Trama_Vd;
  END;

  FUNCTION Carga_Trama_Vd1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Vd1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Vd1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Vd1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Vd1(l_Item).Secuencia_b := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'VD1'
                                                                           ,'SECUENCIA_B'
                                                                           ,l_Item);
      l_Trama_Vd1(l_Item).Tipo_Movimiento_Hijo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'VD1'
                                                                                    ,'TIPO_MOVIMIENTO_HIJO'
                                                                                    ,l_Item);
      l_Trama_Vd1(l_Item).Anulado := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'VD1'
                                                                       ,'ANULADO'
                                                                       ,l_Item);
      l_Trama_Vd1(l_Item).Total_Iva_Incluido := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'VD1'
                                                                                  ,'TOTAL_IVA_INCLUIDO'
                                                                                  ,l_Item);
    END LOOP;
    RETURN l_Trama_Vd1;
  END;

  --//--------------------------------------------------------------------------\\
  --// CBR 23/11/2020 13:13                                                     \\
  --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
  --// Carga Trama Consulta Vademecum                                           \\
  --//-----------------------------------------------------------------Inicio---\\
  FUNCTION Carga_Trama_Vm(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vm IS
    l_Trama_Vm Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vm;
  BEGIN
    l_Trama_Vm.Codigo_Producto      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'VM'
                                                                         ,'CODIGO_PRODUCTO');
    l_Trama_Vm.Descripcion_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'VM'
                                                                         ,'DESCRIPCION_PRODUCTO');
    l_Trama_Vm.Principio_Activo     := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'VM'
                                                                         ,'PRINCIPIO_ACTIVO');
    RETURN l_Trama_Vm;
  END;
  --//-----------------------------------------------------------------Termino--\\

  FUNCTION Carga_Trama_Vn(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vn IS
    l_Trama_Vn Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vn;
  BEGIN
    l_Trama_Vn.Tipo_Movimiento_Padre   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VN'
                                                                            ,'TIPO_MOVIMIENTO_PADRE');
    l_Trama_Vn.Tipo_Movimiento_Hijo    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VN'
                                                                            ,'TIPO_MOVIMIENTO_HIJO');
    l_Trama_Vn.Folio                   := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'VN'
                                                                                 ,'FOLIO'));
    l_Trama_Vn.Numero_Folio_Original   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VN'
                                                                            ,'NUMERO_FOLIO_ORIGINAL');
    l_Trama_Vn.Fecha_Folio_Original    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VN'
                                                                            ,'FECHA_FOLIO_ORIGINAL');
    l_Trama_Vn.Motivo                  := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VN'
                                                                            ,'MOTIVO');
    l_Trama_Vn.Accion_Sobre_Existencia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VN'
                                                                            ,'ACCION_SOBRE_EXISTENCIA');
    l_Trama_Vn.Fecha_Limite            := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VN'
                                                                            ,'FECHA_LIMITE');
    l_Trama_Vn.Hora_Limite             := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VN'
                                                                            ,'HORA_LIMITE');
    l_Trama_Vn.Monto                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VN'
                                                                            ,'MONTO');
    l_Trama_Vn.Cantidad_Productos      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VN'
                                                                            ,'CANTIDAD_PRODUCTOS');
    l_Trama_Vn.Subtrama_Vn1            := Carga_Trama_Vn1(p_Cuerpo_Tx
                                                         ,l_Trama_Vn.Cantidad_Productos);
    RETURN l_Trama_Vn;
  END;

  FUNCTION Carga_Trama_Vn1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Vn1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Vn1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Vn1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Vn1(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'VN1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item);
      l_Trama_Vn1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'VN1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
      l_Trama_Vn1(l_Item).Precio_Final := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VN1'
                                                                            ,'PRECIO_FINAL'
                                                                            ,l_Item);
      l_Trama_Vn1(l_Item).Costo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'VN1'
                                                                     ,'COSTO'
                                                                     ,l_Item);
      l_Trama_Vn1(l_Item).Codigo_Personal := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'VN1'
                                                                               ,'CODIGO_PERSONAL'
                                                                               ,l_Item);
      l_Trama_Vn1(l_Item).Rut_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VN1'
                                                                            ,'RUT_VENDEDOR'
                                                                            ,l_Item);
      l_Trama_Vn1(l_Item).Dv_Rut_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'VN1'
                                                                               ,'DV_RUT_VENDEDOR'
                                                                               ,l_Item);
      l_Trama_Vn1(l_Item).Precio_Lista := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VN1'
                                                                            ,'PRECIO_LISTA'
                                                                            ,l_Item);
      -- ctm 06-06-2016 se modifica el campo donde viene el motivo.
      l_Trama_Vn1(l_Item).Motivo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'VN1'
                                                                      ,'CODIGO_RECLAMO'
                                                                      ,l_Item);
    END LOOP;
    RETURN l_Trama_Vn1;
  END;

  FUNCTION Carga_Trama_Vr(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vr IS
    l_Trama_Vr Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vr;
  BEGIN
    l_Trama_Vr.Codigo_Autorizacion         := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'VR'
                                                                                ,'CODIGO_AUTORIZACION');
    l_Trama_Vr.Disponible                  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'VR'
                                                                                ,'DISPONIBLE');
    l_Trama_Vr.Disponible_Copago           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'VR'
                                                                                ,'DISPONIBLE_COPAGO');
    l_Trama_Vr.Codigo_Autorizacion_Externo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'VR'
                                                                                ,'CODIGO_AUTORIZACION_EXTERNO');
    l_Trama_Vr.Interes                     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'VR'
                                                                                ,'INTERES');
    l_Trama_Vr.Vencimiento_Primera_Cuota   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'VR'
                                                                                ,'VENCIMIENTO_PRIMERA_CUOTA');
    l_Trama_Vr.Valor_Primera_Cuota         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'VR'
                                                                                ,'VALOR_PRIMERA_CUOTA');
    l_Trama_Vr.Numero_Liquidacion          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'VR'
                                                                                ,'NUMERO_LIQUIDACION');
    l_Trama_Vr.Id_Receta                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'VR'
                                                                                ,'ID_RECETA');

    l_Trama_Vr.Cantidad_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'VR'
                                                                      ,'CANTIDAD_PRODUCTO');

    l_Trama_Vr.Subtrama_Vr1 := Carga_Trama_Vr1(p_Cuerpo_Tx
                                              ,l_Trama_Vr.Cantidad_Producto);

    RETURN l_Trama_Vr;
  END;

  FUNCTION Carga_Trama_Vr1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Vr1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Vr1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Vr1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Vr1(l_Item).Codigo_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'VR2'
                                                                               ,'CODIGO_PRODUCTO'
                                                                               ,l_Item);
      l_Trama_Vr1(l_Item).Aceptado := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'VR2'
                                                                        ,'ACEPTADO'
                                                                        ,l_Item);
    END LOOP;
    RETURN l_Trama_Vr1;
  END;

  FUNCTION Carga_Trama_Vs(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vs IS
    l_Trama_Vs Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vs;
  BEGIN
    l_Trama_Vs.Tipo_Movimiento_Padre   := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VS'
                                                                            ,'TIPO_MOVIMIENTO_PADRE');
    l_Trama_Vs.Tipo_Movimiento_Hijo    := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VS'
                                                                            ,'TIPO_MOVIMIENTO_HIJO');
    l_Trama_Vs.Folio                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VS'
                                                                            ,'FOLIO');
    l_Trama_Vs.Numero_Pedido           := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'VS'
                                                                                 ,'NUMERO_PEDIDO'));
    l_Trama_Vs.Guia_Despacho           := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'VS'
                                                                                 ,'GUIA_DESPACHO'));
    l_Trama_Vs.Tipo_Guia_Despacho      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VS'
                                                                            ,'TIPO_GUIA_DESPACHO');
    l_Trama_Vs.Accion_Sobre_Existencia := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VS'
                                                                            ,'ACCION_SOBRE_EXISTENCIA');
    l_Trama_Vs.Codigo_Local_Socofar    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VS'
                                                                            ,'CODIGO_LOCAL_SOCOFAR');
    l_Trama_Vs.Numero_Reclamo          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VS'
                                                                            ,'NUMERO_RECLAMO');
    l_Trama_Vs.Fecha_Reclamo           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VS'
                                                                            ,'FECHA_RECLAMO');
    l_Trama_Vs.Dfi_Numero_Asignacion   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VS'
                                                                            ,'DFI_NUMERO_ASIGNACION');
    l_Trama_Vs.Matricula_Bulto         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VS'
                                                                            ,'MATRICULA_BULTO');
    l_Trama_Vs.Monto                   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VS'
                                                                            ,'MONTO');
    l_Trama_Vs.Rut_Proveedor           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VS'
                                                                            ,'RUT_PROVEEDOR');
    l_Trama_Vs.Sello_Seguro_Uno        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VS'
                                                                            ,'SELLO_SEGURO_UNO');
    l_Trama_Vs.Sello_Seguro_Dos        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VS'
                                                                            ,'SELLO_SEGURO_DOS');
    
    --INI JAGC 20250414 ORIGEN FGI
    l_Trama_Vs.DECIMAL_MONTO      := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VS'
                                                                            ,'DECIMAL_MONTO');
    l_Trama_Vs.NUMERO_FACTURA := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VS'
                                                                            ,'NUMERO_FACTURA');
    l_Trama_Vs.FOLIO_INGRESO    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VS'
                                                                            ,'FOLIO_INGRESO');
    --FIN JAGC 20250414 ORIGEN FGI
    
    l_Trama_Vs.Cantidad_Productos      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VS'
                                                                            ,'CANTIDAD_PRODUCTOS');
    l_Trama_Vs.Subtrama_Vs1            := Carga_Trama_Vs1(p_Cuerpo_Tx
                                                         ,l_Trama_Vs.Cantidad_Productos);
    RETURN l_Trama_Vs;
  END;

  FUNCTION Carga_Trama_Vs1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Vs1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Vs1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Vs1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Vs1(l_Item).Guia_Electronica := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'VS1'
                                                                                     ,'GUIA_ELECTRONICA'
                                                                                     ,l_Item));
      l_Trama_Vs1(l_Item).Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'VS1'
                                                                        ,'PRODUCTO'
                                                                        ,l_Item);
      l_Trama_Vs1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'VS1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
      l_Trama_Vs1(l_Item).Motivo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'VS1'
                                                                      ,'MOTIVO'
                                                                      ,l_Item);
      l_Trama_Vs1(l_Item).Precio_Final := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VS1'
                                                                            ,'PRECIO_FINAL'
                                                                            ,l_Item);
      --INI JAGC 20250414 ORIGEN FGI
      l_Trama_Vs1(l_Item).DECIMAL_PRECIO_FINAL := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'VS1'
                                                                      ,'DECIMAL_PRECIO_FINAL'
                                                                      ,l_Item);
      l_Trama_Vs1(l_Item).Numero_Item := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VS1'
                                                                            ,'NUMERO_ITEM'
                                                                            ,l_Item);
      --FIN JAGC 20250414 ORIGEN FGI                                                                   
    END LOOP;
    RETURN l_Trama_Vs1;
  END;

  FUNCTION Carga_Trama_Vt(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vt IS
    l_Trama_Vt Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vt;
  BEGIN
    l_Trama_Vt.Tipo_Movimiento_Hijo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'VT'
                                                                         ,'TIPO_MOVIMIENTO_HIJO');
    l_Trama_Vt.Folio                := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'VT'
                                                                         ,'FOLIO');
    l_Trama_Vt.Local                := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'VT'
                                                                         ,'LOCAL');
    RETURN l_Trama_Vt;
  END;

  FUNCTION Carga_Trama_Za(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Za IS
    l_Trama_Za Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Za;
  BEGIN
    l_Trama_Za.Convenio                    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'ZA'
                                                                                ,'CONVENIO');
    l_Trama_Za.Plan                        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'ZA'
                                                                                ,'PLAN');
    l_Trama_Za.Secuencia_b                 := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'ZA'
                                                                                ,'SECUENCIA_B');
    l_Trama_Za.Codigo_Autorizacion         := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'ZA'
                                                                                ,'CODIGO_AUTORIZACION');
    l_Trama_Za.Monto                       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'ZA'
                                                                                ,'MONTO');
    l_Trama_Za.Cantidad_Cuotas             := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'ZA'
                                                                                ,'CANTIDAD_CUOTAS');
    l_Trama_Za.Interes                     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'ZA'
                                                                                ,'INTERES');
    l_Trama_Za.Codigo_Autorizacion_Externo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'ZA'
                                                                                ,'CODIGO_AUTORIZACION_EXTERNO');
    RETURN l_Trama_Za;
  END;

  FUNCTION Carga_Trama_Zc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Zc IS
    l_Trama_Zc Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Zc;
  BEGIN
    l_Trama_Zc.Correlativo_Tx          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'ZC'
                                                                            ,'CORRELATIVO_TX');
    l_Trama_Zc.Puntos                  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'ZC'
                                                                            ,'PUNTOS');
    l_Trama_Zc.Correlativo_Tx_Asociado := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'ZC'
                                                                            ,'CORRELATIVO_TX_ASOCIADO');
    RETURN l_Trama_Zc;
  END;

  FUNCTION Carga_Trama_Zj(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Zj IS
    l_Trama_Zj Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Zj;
  BEGIN
    l_Trama_Zj.Correlativo_Tx := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'ZJ'
                                                                   ,'CORRELATIVO_TX');
    l_Trama_Zj.Puntos         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'ZJ'
                                                                   ,'PUNTOS');
    RETURN l_Trama_Zj;
  END;

  FUNCTION Carga_Trama_Zp(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Zp IS
    l_Trama_Zp Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Zp;
  BEGIN
    l_Trama_Zp.Correlativo_Tx := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'ZP'
                                                                   ,'CORRELATIVO_TX');
    l_Trama_Zp.Puntos         := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                   ,'ZP'
                                                                   ,'PUNTOS');
    RETURN l_Trama_Zp;
  END;

  FUNCTION Carga_Trama_Zr(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Zr IS
    l_Trama_Zr Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Zr;
  BEGIN
    l_Trama_Zr.Convenio                       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'ZR'
                                                                                   ,'CONVENIO');
    l_Trama_Zr.Plan                           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'ZR'
                                                                                   ,'PLAN');
    l_Trama_Zr.Secuencia_Titular_Beneficiario := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'ZR'
                                                                                   ,'SECUENCIA_TITULAR_BENEFICIARIO');
    l_Trama_Zr.Codigo_Autorizacion            := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'ZR'
                                                                                   ,'CODIGO_AUTORIZACION');
    l_Trama_Zr.Monto                          := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'ZR'
                                                                                   ,'MONTO');
    l_Trama_Zr.Cantidad_Cuotas                := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'ZR'
                                                                                   ,'CANTIDAD_CUOTAS');
    l_Trama_Zr.Codigo_Autorizacion_Origen     := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'ZR'
                                                                                   ,'CODIGO_AUTORIZACION_ORIGEN');
    RETURN l_Trama_Zr;
  END;

  FUNCTION Carga_Datos_Com(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Data_Com IS
    l_Data_Com Scfr_Trx_Dyn_Types_Pk.Rec_Data_Com;
  BEGIN
    l_Data_Com.Version_Header_Primaria   := p_Transaccion.Trama_Pos.Version_Primaria;
    l_Data_Com.Version_Header_Secundaria := p_Transaccion.Trama_Pos.Version_Secundaria;
    --l_data_com.version_pos := p_transaccion.trama_pos.version_pos;
    --l_data_com.version_mensajeria_primaria := p_transaccion.trama_pos.version_mensajeria_primaria;
    --l_data_com.version_mensajeria_secundaria := p_transaccion.trama_pos.version_mensajeria_secundaria;
    l_Data_Com.Empresa            := p_Transaccion.Trama_Pos.Empresa;
    l_Data_Com.Cadena             := p_Transaccion.Trama_Pos.Cadena;
    l_Data_Com.Numero_Local       := p_Transaccion.Trama_Pos.Local;
    l_Data_Com.Numero_Pos         := p_Transaccion.Trama_Pos.Numero_Pos;
    l_Data_Com.Destino            := p_Transaccion.Trama_Pos.Destino;
    l_Data_Com.Tipo_Transmision   := p_Transaccion.Trama_Pos.Tipo_Transmision;
    l_Data_Com.Sistema            := p_Transaccion.Trama_Pos.Sistema;
    l_Data_Com.Funcion            := p_Transaccion.Trama_Pos.Funcion;
    l_Data_Com.Secuencia          := p_Transaccion.Trama_Pos.Secuencia_c;
    l_Data_Com.Fecha_Contable     := p_Transaccion.Trama_Pos.Fecha_Hora_Contable;
    l_Data_Com.Fecha_Hora_Proceso := p_Transaccion.Trama_Pos.Fecha_Hora_Proceso;
    l_Data_Com.Fecha_Hora_Tx      := p_Transaccion.Trama_Pos.Fecha_Hora_Tx;
    l_Data_Com.Fecha_Hora_Rx      := p_Transaccion.Trama_Pos.Fecha_Hora_Rx;
    l_Data_Com.Correlativo        := p_Transaccion.Trama_Pos.Correlativo;
    l_Data_Com.Tipo_Envio         := p_Transaccion.Trama_Pos.Tipo_Requerimiento;
    l_Data_Com.Empresa_Destino    := p_Transaccion.Trama_Pos.Empresa_Destino;
    l_Data_Com.Cadena_Destino     := p_Transaccion.Trama_Pos.Cadena_Destino;
    l_Data_Com.Local_Destino      := p_Transaccion.Trama_Pos.Local_Destino;
    l_Data_Com.Ttl                := p_Transaccion.Trama_Pos.Ttl;
    l_Data_Com.Origen_Transaccion := p_Transaccion.Trama_Pos.Origen_Transaccion;
    RETURN l_Data_Com;
  END;

  FUNCTION Carga_Trama_Bt(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Bt IS
    l_Trama_Bt Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Bt;
  BEGIN
    l_Trama_Bt.Numero_Matricula := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'BT'
                                                                     ,'NUMERO_MATRICULA');
    RETURN l_Trama_Bt;
  END;

  FUNCTION Carga_Trama_Gc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Gc IS
    l_Trama_Gc Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Gc;
  BEGIN
    l_Trama_Gc.Accion           := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'GC'
                                                                     ,'ACCION');
    l_Trama_Gc.Numero_Guia      := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'GC'
                                                                     ,'NUMERO_GUIA');
    l_Trama_Gc.Numero_Matricula := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'GC'
                                                                     ,'NUMERO_MATRICULA');
    RETURN l_Trama_Gc;
  END;

  FUNCTION Carga_Trama_Gd(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gd IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Gd Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gd;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'GD'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Gd(l_Item).Codigo_Deposito := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'GD'
                                                                              ,'CODIGO_DEPOSITO'
                                                                              ,l_Item);
      l_Trama_Gd(l_Item).Monto_Deposito := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'GD'
                                                                             ,'MONTO_DEPOSITO'
                                                                             ,l_Item);
      l_Trama_Gd(l_Item).Decimal_Mto_Deposito := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                           ,'GD'
                                                                                           ,'DECIMAL_MTO_DEPOSITO'
                                                                                           ,l_Item)
                                                        ,'-'
                                                        ,'0');
      l_Trama_Gd(l_Item).Monto_Deposito := To_Number(l_Trama_Gd(l_Item).Monto_Deposito || '.' || l_Trama_Gd(l_Item).Decimal_Mto_Deposito
                                                    ,'999999999999.9999');

      l_Trama_Gd(l_Item).Numero_Colilla := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'GD'
                                                                             ,'NUMERO_COLILLA'
                                                                             ,l_Item);
      l_Trama_Gd(l_Item).Registro_Recepcion_1 := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'GD'
                                                                                   ,'REGISTRO_RECEPCION_1'
                                                                                   ,l_Item);
      l_Trama_Gd(l_Item).Registro_Recepcion_2 := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'GD'
                                                                                   ,'REGISTRO_RECEPCION_2'
                                                                                   ,l_Item);
      l_Trama_Gd(l_Item).Registro_Devolucion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'GD'
                                                                                  ,'REGISTRO_DEVOLUCION'
                                                                                  ,l_Item);
      l_Trama_Gd(l_Item).Cantidad_Documentos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'GD'
                                                                                  ,'CANTIDAD_DOCUMENTOS'
                                                                                  ,l_Item);
      l_Trama_Gd(l_Item).Subtrama_Gd1 := Carga_Trama_Gd1(p_Cuerpo_Tx
                                                        ,l_Trama_Gd(l_Item).Cantidad_Documentos
                                                        ,l_Item);
    END LOOP;
    RETURN l_Trama_Gd;
  END;

  FUNCTION Carga_Trama_Gd1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER
                          ,p_Ind       IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gd1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Gd1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gd1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Gd1(l_Item).Correlativo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'GD1'
                                                                           ,'CORRELATIVO'
                                                                           ,l_Item
                                                                           ,p_Ind);
      l_Trama_Gd1(l_Item).Tipo_Remesa := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'GD1'
                                                                           ,'TIPO_REMESA'
                                                                           ,l_Item
                                                                           ,p_Ind);
      l_Trama_Gd1(l_Item).Cant_Doctos_Remesa := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                  ,'GD1'
                                                                                  ,'CANT_DOCTOS_REMESA'
                                                                                  ,l_Item
                                                                                  ,p_Ind);
      l_Trama_Gd1(l_Item).Monto_Remesa := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'GD1'
                                                                            ,'MONTO_REMESA'
                                                                            ,l_Item
                                                                            ,p_Ind);
      l_Trama_Gd1(l_Item).Decimal_Mto_Remesa := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'GD1'
                                                                                          ,'DECIMAL_MTO_REMESA'
                                                                                          ,l_Item
                                                                                          ,p_Ind)
                                                       ,'-'
                                                       ,'0');
      l_Trama_Gd1(l_Item).Monto_Remesa := To_Number(l_Trama_Gd1(l_Item).Monto_Remesa || '.' || l_Trama_Gd1(l_Item).Decimal_Mto_Remesa
                                                   ,'999999999999.9999');

      l_Trama_Gd1(l_Item).Validada := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                        ,'GD1'
                                                                        ,'VALIDADA'
                                                                        ,l_Item
                                                                        ,p_Ind);
      l_Trama_Gd1(l_Item).Tipo_Validacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'GD1'
                                                                               ,'TIPO_VALIDACION'
                                                                               ,l_Item
                                                                               ,p_Ind);
      l_Trama_Gd1(l_Item).Codigo_Barra_Remesa := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'GD1'
                                                                                   ,'CODIGO_BARRA_REMESA'
                                                                                   ,l_Item
                                                                                   ,p_Ind);
    END LOOP;
    RETURN l_Trama_Gd1;
  END;

  FUNCTION Carga_Trama_Gr(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gr IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Gr Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gr;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'GR'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Gr(l_Item).Tipo_Cubeta := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'GR'
                                                                          ,'TIPO_CUBETA'
                                                                          ,l_Item);
      l_Trama_Gr(l_Item).Fecha_Recepcion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'GR'
                                                                              ,'FECHA_RECEPCION'
                                                                              ,l_Item);
      l_Trama_Gr(l_Item).Fecha_Disponible := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'GR'
                                                                               ,'FECHA_DISPONIBLE'
                                                                               ,l_Item);
      l_Trama_Gr(l_Item).Numero_Matricula := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'GR'
                                                                               ,'NUMERO_MATRICULA'
                                                                               ,l_Item);
      l_Trama_Gr(l_Item).Numero_Guia := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'GR'
                                                                          ,'NUMERO_GUIA'
                                                                          ,l_Item);
    END LOOP;
    RETURN l_Trama_Gr;
  END;

  FUNCTION Carga_Trama_Ic(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ic IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Ic Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ic;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'IC'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Ic(l_Item).Numero_Guia := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'IC'
                                                                          ,'NUMERO_GUIA'
                                                                          ,l_Item);
      l_Trama_Ic(l_Item).Numero_Matricula := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'IC'
                                                                               ,'NUMERO_MATRICULA'
                                                                               ,l_Item);
      l_Trama_Ic(l_Item).Tipo_Cubeta := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'IC'
                                                                          ,'TIPO_CUBETA'
                                                                          ,l_Item);
      l_Trama_Ic(l_Item).Fecha_Generacion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'IC'
                                                                               ,'FECHA_GENERACION'
                                                                               ,l_Item);
    END LOOP;
    RETURN l_Trama_Ic;
  END;

  FUNCTION Carga_Trama_Mb(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Mb IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Mb Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Mb;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'MB'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Mb(l_Item).Numero_Matricula := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'MB'
                                                                               ,'NUMERO_MATRICULA'
                                                                               ,l_Item);
      l_Trama_Mb(l_Item).Tipo_Movimiento := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'MB'
                                                                              ,'TIPO_MOVIMIENTO'
                                                                              ,l_Item);
      l_Trama_Mb(l_Item).Local_Origen := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'MB'
                                                                           ,'LOCAL_ORIGEN'
                                                                           ,l_Item);
      l_Trama_Mb(l_Item).Local_Destino := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MB'
                                                                            ,'LOCAL_DESTINO'
                                                                            ,l_Item);
      l_Trama_Mb(l_Item).Rut := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                  ,'MB'
                                                                  ,'RUT'
                                                                  ,l_Item);
      l_Trama_Mb(l_Item).Nombre_Servidor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'MB'
                                                                              ,'NOMBRE_SERVIDOR'
                                                                              ,l_Item);
      l_Trama_Mb(l_Item).Fecha_Generacion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'MB'
                                                                               ,'FECHA_GENERACION'
                                                                               ,l_Item);
    END LOOP;
    RETURN l_Trama_Mb;
  END;

  FUNCTION Carga_Trama_Mc(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Mc IS
    l_Trama_Mc Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Mc;
  BEGIN
    l_Trama_Mc.Correlativo           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'MC'
                                                                          ,'CORRELATIVO');
    l_Trama_Mc.Tipo_Movimiento_Padre := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'MC'
                                                                          ,'TIPO_MOVIMIENTO_PADRE');
    l_Trama_Mc.Fecha                 := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'MC'
                                                                          ,'FECHA');
    l_Trama_Mc.Hora                  := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'MC'
                                                                          ,'HORA');
    l_Trama_Mc.Identi_Titular        := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'MC'
                                                                          ,'IDENTIF_TITULAR');
    --    l_Trama_Mc.Rut_Titular           := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
    --                                                                          ,'MC'
    --                                                                          ,'RUT_TITULAR');
    --    l_Trama_Mc.Dv_Titular            := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
    --                                                                          ,'MC'
    --                                                                          ,'DV_TITULAR');
    l_Trama_Mc.Fecha_Generacion     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'MC'
                                                                         ,'FECHA_GENERACION');
    l_Trama_Mc.Registro_Electronico := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'MC'
                                                                         ,'REGISTRO_ELECTRONICO');
    l_Trama_Mc.Correlativo_Tx       := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'MC'
                                                                         ,'CORRELATIVO_TX');
    l_Trama_Mc.Cant_Remesas_Depo    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'MC'
                                                                         ,'CANT_REMESAS_DEPO');
    l_Trama_Mc.Decimal_Cant_Remesas := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'MC'
                                                                                 ,'DECIMAL_CANT_REMESAS')
                                              ,'-'
                                              ,'0');
    l_Trama_Mc.Cant_Remesas_Depo    := To_Number(l_Trama_Mc.Cant_Remesas_Depo || '.' || l_Trama_Mc.Decimal_Cant_Remesas
                                                ,'999999999999.9999');

    l_Trama_Mc.Monto_No_Depositado := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'MC'
                                                                        ,'MONTO_NO_DEPOSITADO');
    l_Trama_Mc.Decimal_Mto_No_Depo := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                ,'MC'
                                                                                ,'DECIMAL_MTO_NO_DEPO')
                                             ,'-'
                                             ,'0');
    l_Trama_Mc.Monto_No_Depositado := To_Number(l_Trama_Mc.Monto_No_Depositado || '.' || l_Trama_Mc.Decimal_Mto_No_Depo
                                               ,'999999999999.9999');

    l_Trama_Mc.Cant_Remesas_No_Depo    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'MC'
                                                                            ,'CANT_REMESAS_NO_DEPO');
    l_Trama_Mc.Decimal_Remesas_No_Depo := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'MC'
                                                                                    ,'DECIMAL_REMESAS_NO_DEPO')
                                                 ,'-'
                                                 ,'0');
    l_Trama_Mc.Cant_Remesas_No_Depo    := To_Number(l_Trama_Mc.Cant_Remesas_No_Depo || '.' || l_Trama_Mc.Decimal_Remesas_No_Depo
                                                   ,'999999999999.9999');

    l_Trama_Mc.Cantidad_Documentos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'MC'
                                                                        ,'CANTIDAD_DOCUMENTOS');
    l_Trama_Mc.Subtrama_Mc1        := Carga_Trama_Mc1(p_Cuerpo_Tx
                                                     ,l_Trama_Mc.Cantidad_Documentos);
    RETURN l_Trama_Mc;
  END;

  FUNCTION Carga_Trama_Mc1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Mc1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Mc1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Mc1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Mc1(l_Item).Secuencia := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'MC1'
                                                                         ,'SECUENCIA'
                                                                         ,l_Item);
      l_Trama_Mc1(l_Item).Tipo_Movimiento := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'MC1'
                                                                               ,'TIPO_MOVIMIENTO'
                                                                               ,l_Item);
      l_Trama_Mc1(l_Item).Anulado := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'MC1'
                                                                       ,'ANULADO'
                                                                       ,l_Item);
      l_Trama_Mc1(l_Item).Monto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'MC1'
                                                                     ,'MONTO'
                                                                     ,l_Item);
      l_Trama_Mc1(l_Item).Decimal_Monto := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'MC1'
                                                                                     ,'DECIMAL_MONTO'
                                                                                     ,l_Item)
                                                  ,'-'
                                                  ,'0');
      BEGIN
        l_Trama_Mc1(l_Item).Monto := To_Number(l_Trama_Mc1(l_Item).Monto || '.' || l_Trama_Mc1(l_Item).Decimal_Monto
                                              ,'999999999999.9999');
      EXCEPTION
        WHEN OTHERS THEN
          l_Trama_Mc1(l_Item).Monto := 0;
      END;

      l_Trama_Mc1(l_Item).Folio := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'MC1'
                                                                     ,'FOLIO'
                                                                     ,l_Item);
      l_Trama_Mc1(l_Item).Estado := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'MC1'
                                                                      ,'ESTADO'
                                                                      ,l_Item);
      l_Trama_Mc1(l_Item).Fecha_Regularizacion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'MC1'
                                                                                    ,'FECHA_REGULARIZACION'
                                                                                    ,l_Item);
    END LOOP;
    RETURN l_Trama_Mc1;
  END;

  FUNCTION Carga_Trama_Id(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Id IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Id Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Id;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'ID'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Id(l_Item).Fecha := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'ID'
                                                                    ,'FECHA'
                                                                    ,l_Item);
      l_Trama_Id(l_Item).Codigo_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'ID'
                                                                              ,'CODIGO_PRODUCTO'
                                                                              ,l_Item);
      l_Trama_Id(l_Item).Descriptor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'ID'
                                                                         ,'DESCRIPTOR'
                                                                         ,l_Item);
      l_Trama_Id(l_Item).Kardex := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'ID'
                                                                     ,'KARDEX'
                                                                     ,l_Item);
      l_Trama_Id(l_Item).Signo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'ID'
                                                                    ,'SIGNO'
                                                                    ,l_Item);
      l_Trama_Id(l_Item).Cuenta := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'ID'
                                                                     ,'CUENTA'
                                                                     ,l_Item);
      l_Trama_Id(l_Item).Costo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'ID'
                                                                    ,'COSTO'
                                                                    ,l_Item);
    END LOOP;
    RETURN l_Trama_Id;
  END;

  -------------------------------------------------------------------------
  -- Trama IN 2023 LMP Ecuador para nuevos campos en reporte IRD
  -------------------------------------------------------------------------
  FUNCTION Carga_Trama_In_Res(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_In_Res IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_In_Res Scfr_Trx_Dyn_Types_Pk.Tab_Trama_In_Res;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'INR'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_In_Res(l_Item).Numero_Conteo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'INR'
                                                                            ,'NUMERO_CONTEO'
                                                                            ,l_Item);
      l_Trama_In_Res(l_Item).Tipo_Ird := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                       ,'INR'
                                                                       ,'TIPO_IRD'
                                                                       ,l_Item);
      l_Trama_In_Res(l_Item).Grupo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'INR'
                                                                    ,'GRUPO'
                                                                    ,l_Item);
      l_Trama_In_Res(l_Item).Fecha_Finalizacion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'INR'
                                                                                 ,'FECHA_FINALIZACION'
                                                                                 ,l_Item);
      l_Trama_In_Res(l_Item).Cant_Discrepancias := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'INR'
                                                                                 ,'CANT_DISCREPANCIAS'
                                                                                 ,l_Item);
      l_Trama_In_Res(l_Item).Stock_0 := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                      ,'INR'
                                                                      ,'STOCK_0'
                                                                      ,l_Item);
    END LOOP;
    RETURN l_Trama_In_Res;
  END;
  
  --INI JAGC 20240909 NECESIDADES 'NEC'                               
  -------------------------------------------------------------------------
  --Trama IN 2024 JAGC Producto Inscrito a Necesidad
  -------------------------------------------------------------------------
  FUNCTION Carga_Trama_In(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_In IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_In Scfr_Trx_Dyn_Types_Pk.Tab_Trama_In;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'NI'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_In(l_Item).Codigo_Producto    := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'NI'
                                                                               ,'CODIGO_PRODUCTO',l_Item));
                                                                               
      l_Trama_In(l_Item).unidadesAcumuladasCtaCte    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'NI'
                                                                          ,'UNIDADESACUMULADASCTACTE',l_Item);
                                                                          
      l_Trama_In(l_Item).montoProximoDescuento    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'NI'
                                                                          ,'MONTOPROXIMODESCUENTO',l_Item);
                                                                          
      l_Trama_In(l_Item).tipoProximoDescuento    := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'NI'
                                                                               ,'TIPOPROXIMODESCUENTO',l_Item));
                                                                               
      l_Trama_In(l_Item).unidadesAcumuladasMensuales     := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'NI'
                                                                          ,'UNIDADESACUMULADASMENSUALES',l_Item);
                                                                          
      l_Trama_In(l_Item).fechaInscripcion    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'NI'
                                                                          ,'FECHAINSCRIPCION',l_Item);
                                                                          
      l_Trama_In(l_Item).limiteUnidadesTx    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'NI'
                                                                          ,'LIMITEUNIDADESTX',l_Item);
                                                                          
      l_Trama_In(l_Item).limiteUnidadesMensuales    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'NI'
                                                                          ,'LIMITEUNIDADESMENSUALES',l_Item);
                                                                          
      l_Trama_In(l_Item).fechaExpiracionProducto    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'NI'
                                                                          ,'FECHAEXPIRACIONPRODUCTO',l_Item);
                                                                          
      l_Trama_In(l_Item).estado    := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'NI'
                                                                               ,'ESTADO',l_Item));
                                                                               
      l_Trama_In(l_Item).idNecesidad    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'NI'
                                                                          ,'IDNECESIDAD',l_Item);
                                                                          
      l_Trama_In(l_Item).descripcionNecesidad    := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'NI'
                                                                               ,'DESCRIPCIONNECESIDAD',l_Item));
                                                                               
      l_Trama_In(l_Item).nombreNecesidad    := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'NI'
                                                                               ,'NOMBRENECESIDAD',l_Item));
    
    END LOOP;                                                                         
    RETURN l_Trama_In;
  END;
  
  -------------------------------------------------------------------------
  --Trama IB 2024 JAGC Inscripci?n Producto a Beneficio Necesidad
  -------------------------------------------------------------------------  
  FUNCTION Carga_Trama_Ib(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ib IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Ib Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ib;
  BEGIN
    
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'IB'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
    
      l_Trama_Ib(l_Item).idNecesidad    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'IB'
                                                                          ,'IDNECESIDAD',l_Item);
                                                                          
      l_Trama_Ib(l_Item).Codigo_Producto    := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'IB'
                                                                               ,'CODIGO_PRODUCTO',l_Item)); 
                                                                               
      l_Trama_Ib(l_Item).FechaHoraInscripcion    := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'IB'
                                                                          ,'FECHAHORAINSCRIPCION',l_Item);  
                                                                                            
      l_Trama_Ib(l_Item).IdVendedor    := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'IB'
                                                                               ,'IDVENDEDOR',l_Item)); 
                                                                               
      l_Trama_Ib(l_Item).NombreVendedor    := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'IB'
                                                                               ,'NOMBREVENDEDOR',l_Item)); 
                                                                               
      l_Trama_Ib(l_Item).Canal    := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                               ,'IB'
                                                                               ,'CANAL',l_Item)); 
    
    END LOOP;                                                                           
    RETURN l_Trama_Ib;
  END;  
  --FIN JAGC 20240909 NECESIDADES 'NEC'

  --//--------------------------------------------------------------------------\\
  --// C_BRIONES 27/10/2012 17:24 REP.                                          \\
  --//-----------------------------------------------------------------Inicio---\\
  FUNCTION Carga_Trama_Iv(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Iv IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Iv Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Iv;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'IV'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Iv(l_Item).Tipo_Propiedad := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'IV'
                                                                             ,'TIPO_PROPIEDAD'
                                                                             ,l_Item);
      l_Trama_Iv(l_Item).Numero_Manifiesto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'IV'
                                                                                ,'NUMERO_MANIFIESTO'
                                                                                ,l_Item);
      l_Trama_Iv(l_Item).Numero_Pedido := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'IV'
                                                                            ,'NUMERO_PEDIDO'
                                                                            ,l_Item);
      l_Trama_Iv(l_Item).Rut_Personal := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'IV'
                                                                           ,'RUT_PERSONAL'
                                                                           ,l_Item);
      l_Trama_Iv(l_Item).Total_Pedido := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'IV'
                                                                           ,'TOTAL_PEDIDO'
                                                                           ,l_Item);
      l_Trama_Iv(l_Item).Total_Bultos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'IV'
                                                                           ,'TOTAL_BULTOS'
                                                                           ,l_Item);
      l_Trama_Iv(l_Item).Total_Bultos_Opticon := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'IV'
                                                                                   ,'TOTAL_BULTOS_OPTICON'
                                                                                   ,l_Item);
      l_Trama_Iv(l_Item).Total_Bultos_Aplicacion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'IV'
                                                                                      ,'TOTAL_BULTOS_APLICACION'
                                                                                      ,l_Item);
      l_Trama_Iv(l_Item).Total_Bultos_Digitados := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'IV'
                                                                                     ,'TOTAL_BULTOS_DIGITADOS'
                                                                                     ,l_Item);
      l_Trama_Iv(l_Item).Tiempo_1 := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'IV'
                                                                       ,'TIEMPO_1'
                                                                       ,l_Item);
      l_Trama_Iv(l_Item).Tiempo_2 := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'IV'
                                                                       ,'TIEMPO_2'
                                                                       ,l_Item);
      l_Trama_Iv(l_Item).Total_Unidades := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'IV'
                                                                             ,'TOTAL_UNIDADES'
                                                                             ,l_Item);
      l_Trama_Iv(l_Item).Total_Sku := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'IV'
                                                                        ,'TOTAL_SKU'
                                                                        ,l_Item);
      l_Trama_Iv(l_Item).Unidades_Scf := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'IV'
                                                                           ,'UNIDADES_SCF'
                                                                           ,l_Item);
      l_Trama_Iv(l_Item).Unidades_Fcv := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'IV'
                                                                           ,'UNIDADES_FCV'
                                                                           ,l_Item);
      l_Trama_Iv(l_Item).Unidades_Recepcionadas_Scf := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                         ,'IV'
                                                                                         ,'UNIDADES_RECEPCIONADAS_SCF'
                                                                                         ,l_Item);
      l_Trama_Iv(l_Item).Unidades_Recepcionadas_Fcv := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                         ,'IV'
                                                                                         ,'UNIDADES_RECEPCIONADAS_FCV'
                                                                                         ,l_Item);
      l_Trama_Iv(l_Item).Fecha_Inicio_Revision := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'IV'
                                                                                    ,'FECHA_INICIO_REVISION'
                                                                                    ,l_Item);
      l_Trama_Iv(l_Item).Fecha_Fin_Revision := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'IV'
                                                                                 ,'FECHA_FIN_REVISION'
                                                                                 ,l_Item);
      l_Trama_Iv(l_Item).Tipo_Cargo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'IV'
                                                                         ,'TIPO_CARGO'
                                                                         ,l_Item);
    END LOOP;
    RETURN l_Trama_Iv;
  END;

  --//-----------------------------------------------------------------Termino--\\
  FUNCTION Carga_Trama_Ir(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ir IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Ir Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ir;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'IR'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Ir(l_Item).Fecha := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'IR'
                                                                    ,'FECHA'
                                                                    ,l_Item);
      l_Trama_Ir(l_Item).Codigo_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'IR'
                                                                              ,'CODIGO_PRODUCTO'
                                                                              ,l_Item);
      l_Trama_Ir(l_Item).Descriptor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'IR'
                                                                         ,'DESCRIPTOR'
                                                                         ,l_Item);
    END LOOP;
    RETURN l_Trama_Ir;
  END;

  FUNCTION Carga_Trama_Is(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Is IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Is Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Is;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'IS'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Is(l_Item).Institucion_Isapre := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                 ,'IS'
                                                                                 ,'INSTITUCION_ISAPRE'
                                                                                 ,l_Item);
      l_Trama_Is(l_Item).Numero_Preventa := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'IS'
                                                                              ,'NUMERO_PREVENTA'
                                                                              ,l_Item);
      l_Trama_Is(l_Item).Numero_Campana := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'IS'
                                                                             ,'NUMERO_CAMPANA'
                                                                             ,l_Item);
    END LOOP;
    RETURN l_Trama_Is;
  END;

  FUNCTION Carga_Trama_Tg(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tg IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Tg Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tg;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'TG'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Tg(l_Item).Numero_Guia := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'TG'
                                                                          ,'NUMERO_GUIA'
                                                                          ,l_Item);
      l_Trama_Tg(l_Item).Numero_Pedido := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'TG'
                                                                            ,'NUMERO_PEDIDO'
                                                                            ,l_Item);
      l_Trama_Tg(l_Item).Total := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'TG'
                                                                    ,'TOTAL'
                                                                    ,l_Item);
      l_Trama_Tg(l_Item).Fecha := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'TG'
                                                                    ,'FECHA'
                                                                    ,l_Item);
    END LOOP;
    RETURN l_Trama_Tg;
  END;

  --FCG 191022 Totales Locales
  FUNCTION Carga_Trama_Tl(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tl IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Tl Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tl;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'TG'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Tl(l_Item).Clave_Poliza := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                           ,'TL'
                                                                           ,'CLAVE_POLIZA'
                                                                           ,l_Item);
      l_Trama_Tl(l_Item).Moneda := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                     ,'TL'
                                                                     ,'MONEDA'
                                                                     ,l_Item);
      l_Trama_Tl(l_Item).Forma_Pago := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'TL'
                                                                         ,'FORMA_PAGO'
                                                                         ,l_Item);
      l_Trama_Tl(l_Item).Monto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'TL'
                                                                    ,'MONTO'
                                                                    ,l_Item);
      --//--Union Monto con decimales-------------------------------------------------------\\
      l_Trama_Tl(l_Item).Monto_Decimal := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'TL'
                                                                                    ,'MONTO_DECIMAL'
                                                                                    ,l_Item)
                                                 ,'-'
                                                 ,'0');

      l_Trama_Tl(l_Item).Monto := To_Number(l_Trama_Tl(l_Item).Monto || '.' || l_Trama_Tl(l_Item).Monto_Decimal
                                           ,'999999999999.9999');
      --//--------------------------------------------------------------------------\\

      l_Trama_Tl(l_Item).Signo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'TL'
                                                                    ,'SIGNO'
                                                                    ,l_Item);

      l_Trama_Tl(l_Item).Monto_Conversion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'TL'
                                                                               ,'MONTO_CONVERSION'
                                                                               ,l_Item);
      --//--Union Monto con decimales-------------------------------------------------------\\
      l_Trama_Tl(l_Item).Monto_Dec_Conversion := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                           ,'TL'
                                                                                           ,'MONTO_DEC_CONVERSION'
                                                                                           ,l_Item)
                                                        ,'-'
                                                        ,'0');

      l_Trama_Tl(l_Item).Monto_Conversion := To_Number(l_Trama_Tl(l_Item).Monto_Conversion || '.' || l_Trama_Tl(l_Item).Monto_Dec_Conversion
                                                      ,'999999999999.9999');
      --//--------------------------------------------------------------------------\\

    END LOOP;
    RETURN l_Trama_Tl;
  END;

  --FCG 191022 Totales Generales
  FUNCTION Carga_Trama_Tf(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tf IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Tf Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tf;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'TG'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Tf(l_Item).Tipo_Total := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'TF'
                                                                         ,'TIPO_TOTAL'
                                                                         ,l_Item);
      l_Trama_Tf(l_Item).Monto_Total := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'TF'
                                                                          ,'MONTO_TOTAL'
                                                                          ,l_Item);
      --//--Union Monto con decimales-------------------------------------------------------\\
      l_Trama_Tf(l_Item).Monto_Total_Decimal := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'TF'
                                                                                          ,'MONTO_TOTAL_DECIMAL'
                                                                                          ,l_Item)
                                                       ,'-'
                                                       ,'0');

      l_Trama_Tf(l_Item).Monto_Total := To_Number(l_Trama_Tf(l_Item).Monto_Total || '.' || l_Trama_Tf(l_Item).Monto_Total_Decimal
                                                 ,'999999999999.9999');
      --//--------------------------------------------------------------------------\\

      l_Trama_Tf(l_Item).Identificacion_Vendedor := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'TF'
                                                                                      ,'IDENTIFICADOR_VENDEDOR'
                                                                                      ,l_Item);
      l_Trama_Tf(l_Item).Signo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                    ,'TF'
                                                                    ,'SIGNO'
                                                                    ,l_Item);

    END LOOP;
    RETURN l_Trama_Tf;
  END;

  FUNCTION Carga_Trama_Sl(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Sl IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Sl Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Sl;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'SL'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Sl(l_Item).Codigo_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                              ,'SL'
                                                                              ,'CODIGO_PRODUCTO'
                                                                              ,l_Item);
      l_Trama_Sl(l_Item).Precio_Lista := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'SL'
                                                                           ,'PRECIO_LISTA'
                                                                           ,l_Item);
      l_Trama_Sl(l_Item).Fecha_Act_Precio_Lista := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'SL'
                                                                                     ,'FECHA_ACT_PRECIO_LISTA'
                                                                                     ,l_Item);
      l_Trama_Sl(l_Item).Precio_Oferta := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'SL'
                                                                            ,'PRECIO_OFERTA'
                                                                            ,l_Item);
      l_Trama_Sl(l_Item).Fecha_Act_Precio_Oferta := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                      ,'SL'
                                                                                      ,'FECHA_ACT_PRECIO_OFERTA'
                                                                                      ,l_Item);
      l_Trama_Sl(l_Item).Cam_Precio_Oferta := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'SL'
                                                                                ,'CAM_PRECIO_OFERTA'
                                                                                ,l_Item);
      l_Trama_Sl(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'SL'
                                                                       ,'CANTIDAD'
                                                                       ,l_Item);
      l_Trama_Sl(l_Item).Precio_Costo := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                           ,'SL'
                                                                           ,'PRECIO_COSTO'
                                                                           ,l_Item);
    END LOOP;
    RETURN l_Trama_Sl;
  END;

  FUNCTION Carga_Trama_Px(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Px IS
    l_Trama_Px Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Px;
  BEGIN
    l_Trama_Px.Rut_Cliente_Perfil := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PX'
                                                                       ,'RUT_CLIENTE_PERFIL');
    l_Trama_Px.Cantidad_Productos := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                       ,'PX'
                                                                       ,'CANTIDAD_PRODUCTOS');
    l_Trama_Px.Subtrama_Px1       := Carga_Trama_Px1(p_Cuerpo_Tx
                                                    ,l_Trama_Px.Cantidad_Productos);
    RETURN l_Trama_Px;
  END;

  FUNCTION Carga_Trama_Px1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Px1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    l_Trama_Px1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Px1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Px1(l_Item).Codigo_Producto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                               ,'PX1'
                                                                               ,'CODIGO_PRODUCTO'
                                                                               ,l_Item);
      l_Trama_Px1(l_Item).Cantidad := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                        ,'PX1'
                                                                        ,'CANTIDAD'
                                                                        ,l_Item);
      l_Trama_Px1(l_Item).Excedente := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'PX1'
                                                                         ,'EXCEDENTE'
                                                                         ,l_Item);
      l_Trama_Px1(l_Item).Monto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'PX1'
                                                                     ,'MONTO_EXCEDENTE'
                                                                     ,l_Item);
    END LOOP;
    RETURN l_Trama_Px1;
  END;

  --//--------------------------------------------------------------------------\\
  --// CBR 04/13/2020 12:24PM                                                   \\
  --// Validacion numero de serie en Biometria                                  \\
  --//-----------------------------------------------------------------Inicio---\\
  FUNCTION Carga_Trama_Ns(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ns IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Ns Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ns;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'NS'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Ns(l_Item).Trace := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                    ,'NS'
                                                                    ,'TRACE'
                                                                    ,l_Item);
      l_Trama_Ns(l_Item).Correlativo_Tx := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'NS'
                                                                             ,'CORRELATIVO_TX'
                                                                             ,l_Item);
      l_Trama_Ns(l_Item).Tipo_Tx := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                      ,'NS'
                                                                      ,'TIPO_TX'
                                                                      ,l_Item);
      l_Trama_Ns(l_Item).Fecha_Hora_Validacion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'NS'
                                                                                    ,'FECHA_HORA_VALIDACION'
                                                                                    ,l_Item);
      l_Trama_Ns(l_Item).Rut_Cliente := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'NS'
                                                                          ,'RUT_CLIENTE'
                                                                          ,l_Item);
      l_Trama_Ns(l_Item).Dv_Rut_Cliente := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'NS'
                                                                             ,'DV_RUT_CLIENTE'
                                                                             ,l_Item);
      l_Trama_Ns(l_Item).Validacion_Biometria := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'NS'
                                                                                   ,'VALIDACION_BIOMETRIA'
                                                                                   ,l_Item);
      l_Trama_Ns(l_Item).Codigo_Validacion_Biometria := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'NS'
                                                                                          ,'CODIGO_VALIDACION_BIOMETRIA'
                                                                                          ,l_Item);
      l_Trama_Ns(l_Item).Descrip_Validacion_Biometria := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                           ,'NS'
                                                                                           ,'DESCRIP_VALIDACION_BIOMETRIA'
                                                                                           ,l_Item);

      l_Trama_Ns(l_Item).Validacion_Nro_Serie_Cedula := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'NS'
                                                                                          ,'VALIDACION_NRO_SERIE_CEDULA'
                                                                                          ,l_Item);
      l_Trama_Ns(l_Item).Serie_Dcto_Ingresado := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'NS'
                                                                                   ,'SERIE_DCTO_INGRESADO'
                                                                                   ,l_Item);
      l_Trama_Ns(l_Item).Codigo_Validacion_Serie_Cedula := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                             ,'NS'
                                                                                             ,'CODIGO_VALIDACION_SERIE_CEDULA'
                                                                                             ,l_Item);
      l_Trama_Ns(l_Item).Descrip_Validacion_Cedula := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                        ,'NS'
                                                                                        ,'DESCRIP_VALIDACION_CEDULA'
                                                                                        ,l_Item);
      l_Trama_Ns(l_Item).Resultado_Firma_Electronica := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'NS'
                                                                                          ,'RESULTADO_FIRMA_ELECTRONICA'
                                                                                          ,l_Item);
      l_Trama_Ns(l_Item).Mensaje_Firma_Electronica := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                        ,'NS'
                                                                                        ,'MENSAJE_FIRMA_ELECTRONICA'
                                                                                        ,l_Item);
      l_Trama_Ns(l_Item).Json_Utilizado := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'NS'
                                                                             ,'JSON_UTILIZADO'
                                                                             ,l_Item);
      l_Trama_Ns(l_Item).Codigo_Dec := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                         ,'NS'
                                                                         ,'CODIGO_DEC'
                                                                         ,l_Item);
      l_Trama_Ns(l_Item).Resultado_Digitalizacion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                       ,'NS'
                                                                                       ,'RESULTADO_DIGITALIZACION'
                                                                                       ,l_Item);
      l_Trama_Ns(l_Item).Documentos_Postergados := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'NS'
                                                                                     ,'DOCUMENTOS_POSTERGADOS'
                                                                                     ,l_Item);
      l_Trama_Ns(l_Item).Ticket_Postergacion_Digital := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                          ,'NS'
                                                                                          ,'TICKET_POSTERGACION_DIGITAL'
                                                                                          ,l_Item);
    END LOOP;
    RETURN l_Trama_Ns;
  END;

  -- Obtiene datos trama GNCC15
  FUNCTION Carga_Trama_Vv(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Vv IS
    l_Item     NUMBER;
    l_Tot_Reg  NUMBER;
    l_Trama_Vv Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Vv;
  BEGIN
    l_Tot_Reg := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                   ,'VV'
                                                   ,'CANTIDAD_REGISTROS');
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Vv(l_Item).Tipo_Retencion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                             ,'VV'
                                                                             ,'TIPO_RETENCION'
                                                                             ,l_Item);
      l_Trama_Vv(l_Item).Numero_Factura := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                             ,'VV'
                                                                             ,'NUMERO_FACTURA'
                                                                             ,l_Item);
      l_Trama_Vv(l_Item).Fecha_Factura := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                            ,'VV'
                                                                            ,'FECHA_FACTURA'
                                                                            ,l_Item);
    END LOOP;
    RETURN l_Trama_Vv;
  END;

  FUNCTION Carga_Trama_Vx1(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx
                          ,p_Tot_Reg   IN NUMBER) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Vx1 IS
    l_Item      NUMBER;
    l_Tot_Reg   NUMBER;
    p_Iva       NUMBER;
    p_Aplicar   NUMBER := 0;
    l_Trama_Vx1 Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Vx1;
  BEGIN
    l_Tot_Reg := p_Tot_Reg;
    FOR l_Item IN 1 .. l_Tot_Reg
    LOOP
      l_Trama_Vx1(l_Item).Secuencia := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                         ,'VX1'
                                                                         ,'SECUENCIA'
                                                                         ,l_Item);
      l_Trama_Vx1(l_Item).Tipo_Movimiento_Hijo := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                    ,'VX1'
                                                                                    ,'TIPO_MOVIMIENTO_HIJO'
                                                                                    ,l_Item);
      l_Trama_Vx1(l_Item).Tipo_Retencion := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                              ,'VX1'
                                                                              ,'TIPO_RETENCION'
                                                                              ,l_Item);
      l_Trama_Vx1(l_Item).Numero_Factura := TRIM(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                   ,'VX1'
                                                                                   ,'NUMERO_FACTURA'
                                                                                   ,l_Item));
      l_Trama_Vx1(l_Item).Numero_Retencion := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                                ,'VX1'
                                                                                ,'NUMERO_RETENCION'
                                                                                ,l_Item);
      l_Trama_Vx1(l_Item).Monto := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                     ,'VX1'
                                                                     ,'MONTO'
                                                                     ,l_Item);
      --//--------------------------------------------------------------------------\\
      l_Trama_Vx1(l_Item).Decimal_Monto := REPLACE(Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                                     ,'VX1'
                                                                                     ,'DECIMAL_MONTO'
                                                                                     ,l_Item)
                                                  ,'-'
                                                  ,'0');
      l_Trama_Vx1(l_Item).Monto := To_Number(l_Trama_Vx1(l_Item).Monto || '.' || l_Trama_Vx1(l_Item).Decimal_Monto
                                            ,'999999999999.9999');
    END LOOP;
    RETURN l_Trama_Vx1;
  END;

  FUNCTION Carga_Trama_Vx(p_Cuerpo_Tx IN Scfr_Trx_Dyn_Pk.Tab_Cuerpo_Tx) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vx IS
    l_Trama_Vx Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vx;
  BEGIN
    l_Trama_Vx.Correlativo_Tx        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VX'
                                                                          ,'CORRELATIVO_TX');
    l_Trama_Vx.Tipo_Movimiento_Padre := Scfr_Trx_Dyn_Pk.Obtiene_Cvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VX'
                                                                          ,'TIPO_MOVIMIENTO_PADRE');
    l_Trama_Vx.Fecha                 := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VX'
                                                                          ,'FECHA');
    l_Trama_Vx.Hora_Retencion        := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VX'
                                                                          ,'HORA_RETENCION');
    l_Trama_Vx.Local                 := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VX'
                                                                          ,'LOCAL');
    l_Trama_Vx.Numero_Pos            := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VX'
                                                                          ,'NUMERO_POS');
    l_Trama_Vx.Documentos_Emitidos   := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Cuerpo_Tx
                                                                          ,'VX'
                                                                          ,'DOCUMENTOS_EMITIDOS');
    l_Trama_Vx.Subtrama_Vx1          := Carga_Trama_Vx1(p_Cuerpo_Tx
                                                       ,l_Trama_Vx.Documentos_Emitidos);

    RETURN l_Trama_Vx;
  END;

--//-----------------------------------------------------------------Termino--\\

END Scfr_Trx_Dyn_Utl_Pk;
/
