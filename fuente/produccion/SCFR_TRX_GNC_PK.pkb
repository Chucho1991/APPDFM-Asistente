CREATE OR REPLACE PACKAGE BODY TRX3.Scfr_Trx_Gnc_Pk IS

  Serviciorest Varchar2(25) := 'PDV';

  FUNCTION Version_Pkg RETURN VARCHAR2 AS
  BEGIN
    RETURN Vversion;
  END;

  -- Fecha Compilacion : 28-06-2007
  -- Implementacion de procedimientos privados del package
  PROCEDURE Agrega_Respuesta(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                            ,p_Cod_Resp    IN NUMBER
                            ,x_Respuesta   OUT BLOB) IS
    l_Largo_Tot   NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_GNC_PK.agrega_respuesta()';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
  BEGIN
    IF p_Transaccion.Trama_Pos.Tipo_Transmision = 'O' THEN
      IF Scfr_Trx_Gnc_Utl2_Pk.Funcion_Valida(p_Transaccion.Trama_Pos.Funcion) = 'SI' THEN
        l_Dbg_Mensaje                              := 'Determinar Largo de la trama';
        l_Largo_Tot                                := Scfr_Trx_Dyn_Pk.Obtiene_Largo_Trama(Scfr_Trx_Dyn_Pk.k_Trama_Header_Boc);
        l_Dbg_Mensaje                              := 'Armar Respuesta (trama POS)';
        x_Respuesta                                := NULL;
        p_Transaccion.Trama_Pos.Largo_Total_Buffer := l_Largo_Tot;
        x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                    ,Scfr_Trx_Dyn_Pk.Arma_Trama_Pos(p_Transaccion));
        l_Dbg_Mensaje                              := 'Armar Respuesta (trama BOC)';
        p_Transaccion.Trama_Boc.Codigo_Respuesta   := p_Cod_Resp;
        p_Transaccion.Trama_Boc.Largo_Total_Buffer := 0;
        x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                    ,Scfr_Trx_Dyn_Pk.Arma_Trama_Boc(p_Transaccion));
      END IF;
    END IF;
  END Agrega_Respuesta;

  --------------------------------------------------------------------------------------------------
  --  PROCEDURE LOG_AUTEXT  --  Graba transaccionabilidad externa en tabla scfr_log_autorizacion_mdp
  --------------------------------------------------------------------------------------------------
  PROCEDURE Log_Autext(p_Proceso                 IN VARCHAR2
                      ,p_Tipo_Operacion          IN VARCHAR2
                      ,p_Fecha_Autorizacion      IN DATE
                      ,p_Fecha_Confirmacion      IN DATE
                      ,p_Codigo_Resultado        IN VARCHAR2
                      ,p_Codigo_Autorizacion_Fcv IN VARCHAR2 -- NUMBER
                      ,p_Codigo_Autorizacion_Ext IN VARCHAR2 -- NUMBER
                      ,p_Consulta                IN VARCHAR2
                      ,p_Respuesta               IN VARCHAR2
                      ,p_Glosa_Respuesta         IN VARCHAR2
                      ,p_Rut                     IN NUMBER
                      ,p_Local                   IN NUMBER
                      ,x_Cod_Error               OUT VARCHAR2
                      ,x_Msg_Error               OUT VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_Secuencia NUMBER;
  BEGIN
    SELECT Scfr_Log_Autorizacion_Mdp_s.Nextval INTO l_Secuencia FROM Dual;
    INSERT INTO Scfr_Log_Autorizacion_Mdp
      (Emp_Codigo
      ,Secuencia
      ,Comercio
      ,Tipo_Operacion
      ,Fecha_Autorizacion
      ,Fecha_Confirmacion
      ,Codigo_Resultado
      ,Codigo_Autorizacion_Fcv
      ,Codigo_Autorizacion_Ext
      ,Consulta
      ,Respuesta
      ,Glosa_Respuesta
      ,Local_Fcv
      ,Rut)
    --      ,Numero_Boleta)
    VALUES
      (1
      ,l_Secuencia
      ,p_Proceso
      ,p_Tipo_Operacion
      ,p_Fecha_Autorizacion
      ,p_Fecha_Confirmacion
      ,p_Codigo_Resultado
      ,p_Codigo_Autorizacion_Fcv
      ,p_Codigo_Autorizacion_Ext
      ,p_Consulta
      ,p_Respuesta
      ,p_Glosa_Respuesta
      ,p_Local
      ,p_Rut);
    --      ,0);
    COMMIT;
    x_Cod_Error := '0';
    x_Msg_Error := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      x_Cod_Error := '1098';
      x_Msg_Error := 'ERROR AL GRABAR SCFR_EXCEDENTE_CNV_PK.SCFR_LOG_AUTORIZACION_MDP: ' || SQLERRM;
  END Log_Autext;

  PROCEDURE Trama_Dv_Resuelve(p_Transaccion    IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Trama_Dv       OUT Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                             ,x_Trama_Cv       OUT Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv
                             ,x_Tiene_Trama_Cv OUT BOOLEAN
                             ,x_Doc_Emitidos   OUT Scfr_Trx_Gnc_Pk.Tab_Doc_Emitidos
                             ,x_Cod_Error      OUT NUMBER
                             ,x_Msg_Error      OUT VARCHAR2) IS
    l_Trama_Db           Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Db;
    l_Trama_Dv           Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv;
    l_Trama_Cv           Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv;
    l_Trama_Pm           Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm;
    l_Codigo_Tx          Scfr_Trx_Rec_Pos.Codigo_Transaccion%TYPE;
    l_Itm                NUMBER;
    l_Fecha              NUMBER;
    l_Hora               NUMBER;
    l_Doctos_Emitidos    NUMBER;
    l_Mov_Documentos     NUMBER;
    l_Resultado          NUMBER;
    l_Cod_Error          NUMBER;
    l_Monto_Bonificado   NUMBER;
    l_Cod_Autorizacion   NUMBER;
    l_Codigo_Tx_Recaud   NUMBER;
    l_Crea_Documento     NUMBER;
    l_Folio_Ant          Scfr_Mov_Documentos_Txs.Folio%TYPE;
    l_Guia_Existe        NUMBER;
    l_Banda              VARCHAR2(30);
    l_Msg_Error          VARCHAR2(2000);
    l_Rut_Titular        VARCHAR2(16);
    l_Dbg_Proceso        VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_dv_resuelve';
    l_Dbg_Mensaje        VARCHAR2(250) := 'Error General';
    l_Error_Controlado   EXCEPTION;
    l_Codigo_Tx_Relacion NUMBER;
    l_Local_Tx_Relacion  NUMBER;
    /*EMSG 07042020 Excedentes*/
    l_Comercio      VARCHAR2(30);
    l_Rut_Cliente   NUMBER;
    l_Codigo_Fcv    NUMBER;
    l_Tipo_Docto    VARCHAR2(30);
    l_Fecha_Inicio  DATE;
    l_Rut_Proveedor NUMBER;
    l_Origen        NUMBER;
    l_Canal         NUMBER;
    l_Folio_Boleta  NUMBER;
    l_Estado_Exc    NUMBER;
    l_Cod_Error_Exc VARCHAR2(3000);
    l_Des_Error_Exc VARCHAR2(3000);
    l_Consulta      VARCHAR2(3000);
    l_Respuesta     VARCHAR2(3000);
    /*EMSG 07042020 Excedentes*/
    v_Pin_Transaccion Scfr_Mov_Transacciones.Pin_Transaccion%TYPE; -- ctm 20-04-2020 reutilizar campo con el folio de receta.
    v_Upd             VARCHAR2(1) := 'N';
    l_Convenio        VARCHAR2(50);
  
  BEGIN
    x_Cod_Error := 0;
    /*
    -- obtiene el rut y dv del cliente
    l_Dbg_Mensaje := 'Obtener Rut del cliente';
    IF p_Transaccion.Trama_Boc.Party_Id > 0 THEN
      Scfr_Trx_Util_Pk.Obtiene_Rut(p_Transaccion.Trama_Boc.Party_Id -- in
                                  ,p_Transaccion.Rut_Titular -- out
                                  ,p_Transaccion.Dv_Rut_Titular); -- out
    ELSIF p_Transaccion.Trama_Boc.Forma_Identificacion = Scfr_Trx_Fid_Pk.k_Por_Rut THEN
      -- seteo el rut del cliente aunque no tenga party id
      l_Rut_Titular                := TRIM(p_Transaccion.Trama_Boc.String_Identificacion);
      p_Transaccion.Dv_Rut_Titular := Substr(l_Rut_Titular
                                            ,Length(l_Rut_Titular)
                                            ,1);
      p_Transaccion.Rut_Titular    := Substr(l_Rut_Titular
                                            ,1
                                            ,Length(l_Rut_Titular) - 1);
    END IF;
    */
    -- obtiene folio de la transaccion para el modelo ON-LINE
    l_Dbg_Mensaje := 'Obtener folio desde scfr_mov_transacciones_s';
    SELECT Scfr_Mov_Transacciones_s.Nextval INTO p_Transaccion.Codigo_Tx FROM Dual;
    -- Obtiene informacion de la trama DB
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'DB') THEN
      l_Dbg_Mensaje := 'Obtener informacion de la trama DB';
      l_Trama_Db    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Db(p_Transaccion.Cuerpo_Tx);
    ELSE
      l_Trama_Db(1).Secuencia_b := NULL;
      l_Trama_Db(1).Rut_Beneficiario := NULL;
      l_Trama_Db(1).Dv_Rut_Beneficiario := NULL;
      l_Trama_Db(1).Party_Id := NULL;
    END IF;
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'CV') THEN
      x_Tiene_Trama_Cv := TRUE;
      l_Trama_Cv       := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Cv(p_Transaccion.Cuerpo_Tx);
      /* Para controlar cuando mandan encabezado de trama CV con 0 registros */
      IF l_Trama_Cv.Count = 0 THEN
        l_Trama_Cv(1).Convenio := NULL;
        l_Trama_Cv(1).Plan := NULL;
        l_Trama_Cv(1).Codigo_Autorizacion := NULL;
      END IF;
      FOR l_Itm IN 1 .. l_Trama_Cv(1).Subtrama_Cv1.Count
      LOOP
        INSERT INTO Scfr_Mov_Diagnosticos_Abf
          (Diagnostico
          ,Documento_Venta
          ,Farmacia
          ,Numero_Maquina
          ,Txo_Codgo_Tx)
        VALUES
          (TRIM(l_Trama_Cv(1).Subtrama_Cv1(l_Itm).Diagnostico)
          ,l_Trama_Cv(1).Codigo_Autorizacion
          ,p_Transaccion.Trama_Pos.Local
          ,p_Transaccion.Trama_Pos.Numero_Pos
          ,p_Transaccion.Codigo_Tx);
      END LOOP;
    
    ELSE
      x_Tiene_Trama_Cv := FALSE;
      l_Trama_Cv(1).Convenio := NULL;
      l_Trama_Cv(1).Plan := NULL;
      l_Trama_Cv(1).Codigo_Autorizacion := NULL;
    END IF;
    /*
        -- Intenta obtener informacion de la trama CV
        if scfr_trx_dyn_pk.contiene_trama( p_transaccion.cuerpo_tx, 'CV' ) then
          l_DBG_MENSAJE := 'Obtener informacion de la trama CV';
          l_trama_cv    := scfr_trx_dyn_utl_pk.carga_trama_cv( p_transaccion.cuerpo_tx );
          begin
            if l_trama_cv.cod_autorizacion is not null and ltrim(rtrim(l_trama_cv.cod_autorizacion)) is not null then
              l_cod_autorizacion := to_number( l_trama_cv.cod_autorizacion );
            end if;
          exception
            when others then
              -- Obtiene informacion de la trama PM
              l_DBG_MENSAJE := 'Obtener informacion de la trama PM';
              l_trama_pm    := scfr_trx_dyn_utl_pk.carga_trama_pm(p_Transaccion.Trama_Pos,p_transaccion.cuerpo_tx );
    
              l_DBG_MENSAJE := 'Obtener Monto Bonificado';
              l_monto_bonificado := 0;
              for l_itm1 in 1..l_trama_pm.count loop
                for l_itm2 in 1..l_trama_pm(l_itm1).subtrama_pm4.count loop
                  if l_trama_pm(l_itm1).subtrama_pm4(l_itm2).tipo_distribucion = 'BON' then
                    l_monto_bonificado := l_monto_bonificado + l_trama_pm(l_itm1).subtrama_pm4(l_itm2).monto_distribucion;
                  end if;
                end loop;
              end loop;
    
              l_DBG_MENSAJE := 'Validar que el string de Identificacion sea por Banda';
              if p_transaccion.trama_boc.forma_identificacion = 'B' then
                l_banda := p_transaccion.trama_boc.string_identificacion;
              else
                l_banda := null;
              end if;
    
              l_DBG_MENSAJE := 'Ejecutar scfr_conv_pk.autorizacion_rapida_venta_cnv';
              scfr_conv_pk.autorizacion_rapida_venta_cnv( p_empresa                 => Scfr_Conv_Pk.entrega_codigo_empresa( p_transaccion.trama_pos.empresa )
                                                        , p_forzada                 => 'SI'
                                                        , p_convenio                => l_trama_cv.convenio
                                                        , p_plan                    => l_trama_cv.PLAN
                                                        , p_rut_titular             => p_transaccion.rut_titular
                                                        , p_dv_titular              => p_transaccion.dv_rut_titular
                                                        , p_secuencia               => 0
                                                        , p_codigo_autorizacion_ext => l_trama_cv.cod_autorizacion -- solo para fuera de linea
                                                        , p_rut_medico              => null
                                                        , p_dv_medico               => null
                                                        , p_cadena                  => p_transaccion.trama_pos.cadena
                                                        , p_local                   => p_transaccion.trama_pos.LOCAL
                                                        , p_pos                     => p_transaccion.trama_pos.id_maquina --numero_pos
                                                        , p_maquina                 => p_transaccion.trama_pos.numero_pos --id_maquina
                                                        , p_responsable             => p_transaccion.trama_pos.usuario_responsable
                                                        , p_banda                   => l_banda
                                                        , p_monto_bonificado        => l_monto_bonificado
                                                        , p_numero_cuotas           => null
                                                        , x_codigo_autorizacion     => l_cod_autorizacion
                                                        , x_error                   => l_cod_error
                                                        , x_msg_error               => l_msg_error );
              begin
                x_cod_error := to_number(l_cod_error);
              exception
                when others then
                  raise_application_error( -20000 , 'Problemas al intentar ' || l_dbg_mensaje );
              end;
              l_resultado := scfr_trx_dyn_pk.setea_nvalor_trx( p_transaccion.cuerpo_tx
                                                             , 'CV'
                                                             , 'CODIGO_AUTORIZACION'
                                                             , 1
                                                             , 1
                                                             , l_cod_autorizacion );
              if l_resultado != 0 then
                 scfr_trx_util_pk.debug_msg(p_proceso=>l_DBG_PROCESO, p_msg=>'No se pudo setear el valor de Cod. Autorizacion en la trama CV' );
              end if;
          end;
        else
          l_trama_cv.convenio         := null;
          l_trama_cv.plan             := null;
          l_trama_cv.cod_autorizacion := null;
        end if;
    */
    -- Obtiene informacion de la trama DV
    l_Dbg_Mensaje                := 'Obtener informacion de la trama DV';
    l_Trama_Dv                   := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Dv(p_Transaccion.Trama_Pos
                                                                      ,p_Transaccion.Cuerpo_Tx);
    p_Transaccion.Fecha_Tx       := To_Date(Ltrim(Rtrim(l_Trama_Dv.Fecha)) || Ltrim(Rtrim(To_Char(l_Trama_Dv.Hora_Venta
                                                                                                 ,'000009')))
                                           ,'yyyymmddhh24miss');
    p_Transaccion.Correlativo_Tx := l_Trama_Dv.Correlativo_Tx;
  
    -- CTM 20-04-2020 folio receta
    BEGIN
      SELECT 'S'
        INTO v_Upd
        FROM Trx.Scfr_Locales_Receta t
       WHERE t.Loc_Local = p_Transaccion.Trama_Pos.Local
         AND t.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa;
    EXCEPTION
      WHEN OTHERS THEN
        v_Upd := 'N';
    END;
    IF v_Upd = 'S' THEN
      BEGIN
        SELECT Substr(TRIM(t.Comentario)
                     ,1
                     ,15)
          INTO v_Pin_Transaccion
          FROM Scfr_Detalle_Consumos t
         WHERE t.Emp_Codigo = 1
           AND t.Codigo_Autorizacion = l_Trama_Cv(1).Codigo_Autorizacion
           AND t.Numero_Linea = 0;
      EXCEPTION
        WHEN OTHERS THEN
          v_Pin_Transaccion := l_Trama_Dv.Pin_Transaccion;
      END;
    ELSE
      v_Pin_Transaccion := l_Trama_Dv.Pin_Transaccion;
    END IF;
    -- inserta transaccion
  
    IF (l_Trama_Cv(1).Convenio >= 1000000000) THEN
      l_Convenio := To_Char(To_Number(Substr(To_Char(l_Trama_Cv(1).Convenio)
                                            ,3
                                            ,10)));
    ELSE
      l_Convenio := To_Char(To_Number(To_Char(l_Trama_Cv(1).Convenio)));
    END IF;
  
    IF (l_Trama_Dv.Correlativo_Tx_Asociado IS NOT NULL) THEN
      l_Dbg_Mensaje := 'Obtener folio de la transaccion original desde scfr_mov_transacciones';
      BEGIN
        SELECT Mtr.Codigo_Tx
              ,Mtr.Loc_Local
          INTO l_Codigo_Tx_Relacion
              ,l_Local_Tx_Relacion
          FROM Scfr_Mov_Transacciones  Mtr
              ,Scfr_Mov_Documentos_Txs Mdo
         WHERE Mtr.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
           AND Mtr.Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
           AND Mtr.Loc_Local = l_Trama_Dv.Local
           AND Mtr.Tmo_Movimiento_Padre LIKE 'VEN%'
           AND Mdo.Tmo_Movimiento LIKE 'VEN%'
           AND Mtr.Codigo_Tx = Mdo.Txo_Codigo_Tx
           AND Mtr.Correlativo_Tx = l_Trama_Dv.Correlativo_Tx_Asociado
           AND Mdo.Documento_Fiscal = 'SI'
           AND Rownum = 1;
      EXCEPTION
        WHEN No_Data_Found THEN
          l_Codigo_Tx_Relacion := NULL;
          l_Local_Tx_Relacion  := NULL;
      END;
    END IF;
  
    l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_TRANSACCIONES';
    INSERT INTO Scfr_Mov_Transacciones
      (Codigo_Tx
      ,Correlativo_Tx
      ,Tmo_Movimiento_Padre
      ,Fecha_Tx
      ,Pos_Tipo_Transaccion
      ,Pt_Party_Id_Titular
      ,Rut_Titular
      ,Dv_Titular
      ,Secuencia_Beneficiario
      ,Rut_Beneficiario
      ,Dv_Beneficiario
      ,Pt_Party_Id_Beneficiario
      ,Tipo_Identi_Beneficiario
      ,Identi_Beneficiario
      ,Con_Numero_Convenio
      ,Pla_Numero_Plan
      ,Autorizacion_Cnv_Tx
      ,Rut_Fidelizado
      ,Dv_Fidelizado
      ,Pt_Party_Id_Fidelizado
      ,Cot_Cotizacion
      ,Numero_Preventa
      ,Txo_Codigo_Tx_Relacionado
      ,Txo_Correlativo_Tx_Relacionado
      ,Loc_Local_Relacionado
      ,Num_Service_Request
      ,Agente_Ddo
      ,Rut_Agente_Ddo
      ,Dv_Agente_Ddo
      ,Sec_Recaudacion
      ,Pin_Transaccion
      ,Rut_Retira
      ,Dv_Retira
      ,Nombre_Retira
      ,Cad_Cadena_Traspaso
      ,Loc_Local_Traspaso
      ,Emp_Empresa
      ,Cad_Cadena
      ,Loc_Local
      ,Canal
      ,Estado_Registro
      ,Proceso_Dwh
      ,Numero_Maquina
      ,Cuadrar_Transacciones
      ,Docs_Emitir_Liq_Pag
      ,Docs_Emitir_Liq_Emp
      ,Autorizacion_Cnv_Ext
       --, transaccion_manual
      ,Linea
      ,Supervisor
      ,Rut_Supervisor
      ,Tipo_Identi_Supervisor
      ,Identi_Supervisor
      ,Tipo_Deducible
      ,Monto_Deducible
      ,Valor_Moneda
      ,Tipo_Moneda
      ,Periodicidad_Deducible
      ,Indicadores_Tx
      ,Reg_Electronico
      ,Numero_Tav
      ,Fecha_Inicio_Tx
      ,Fecha_Cierre_Tx
      ,Fecha_Generacion_Registro
      ,Canal_Transaccion
      --,Tiene_Donacion          -- LMP GPF 2023 No se envia por GEO
      ,Url_Factura
      , -- FCG 21082023 Origen OMS
       Url_Xml
      ,Folio_Venta_Anulada -- JAGC NEC 20240909
       )
    VALUES
      (p_Transaccion.Codigo_Tx -- codigo_tx                         not null
      ,l_Trama_Dv.Correlativo_Tx -- correlativo_tx                    not null
      ,l_Trama_Dv.Tipo_Movimiento_Padre -- tmo_movimiento_padre              not null
      ,p_Transaccion.Fecha_Tx -- fecha_tx                          not null
      ,l_Trama_Dv.Tipo_Tx -- pos_tipo_transaccion                  null
      ,p_Transaccion.Trama_Boc.Party_Id -- pt_party_id_titular                   null
      ,p_Transaccion.Rut_Titular -- rut_titular                           null
      ,p_Transaccion.Dv_Rut_Titular -- dv_titular                            null
      ,l_Trama_Db(1).Secuencia_b -- secuencia_beneficiario                null
      ,l_Trama_Db(1).Rut_Beneficiario -- rut_beneficiario                      null
      ,l_Trama_Db(1).Dv_Rut_Beneficiario -- dv_beneficiario                       null
      ,l_Trama_Db(1).Party_Id -- pt_party_id_beneficiario              null
      ,Substr(l_Trama_Db(1).Identi_Beneficiario
             ,1
             ,1)
      ,Substr(l_Trama_Db(1).Identi_Beneficiario
             ,2
             ,30)
      ,l_Convenio --l_Trama_Cv(1).Convenio -- con_numero_convenio                   null
      ,l_Trama_Cv(1).Plan -- pla_numero_plan                       null
      ,TRIM(l_Trama_Cv(1).Codigo_Autorizacion) -- autorizacion_cnv_tx                   null
      ,p_Transaccion.Rut_Titular -- rut_fidelizado                        null
      ,p_Transaccion.Dv_Rut_Titular -- dv_fidelizado                         null
      ,p_Transaccion.Trama_Boc.Party_Id -- pt_party_id_fidelizado                null
      ,NULL -- cot_cotizacion                        null
      ,l_Trama_Dv.Numero_Preventa -- numero_preventa                       null
      ,NULL --l_Codigo_Tx_Relacion
      ,NULL --l_trama_dv.Correlativo_Tx_Asociado             -- null
      ,l_Trama_Dv.Local -- loc_local_relacionado                 null
      ,l_Trama_Dv.Numero_Service_Request_Ddo -- num_service_request                   null
      ,NULL -- agente_ddo                            null
      ,NULL -- rut_agente_ddo                        null
      ,NULL -- dv_agente_ddo                         null
      ,l_Trama_Dv.Recaudacion_Relacionada -- sec_recaudacion                       null
      ,v_Pin_Transaccion -- pin_transaccion                       null
      ,NULL -- rut_retira                            null
      ,NULL -- dv_retira                             null
      ,NULL -- nombre_retira                         null
      ,NULL -- cad_cadena_traspaso                   null
      ,NULL -- loc_local_traspaso                    null
      ,p_Transaccion.Trama_Pos.Empresa -- emp_empresa                           null
      ,p_Transaccion.Trama_Pos.Cadena -- cad_cadena                            null
      ,p_Transaccion.Trama_Pos.Local -- loc_local                             null
      ,Rtrim(Ltrim(l_Trama_Dv.Canal)) -- JAGC NEC 20240909 --,'POS' -- canal                                 null
      ,'VIG' -- estado_registro                   not null
      ,0 -- proceso_dwh                       not null
      ,p_Transaccion.Trama_Pos.Numero_Pos -- numero_maquina                    not null
      ,l_Trama_Dv.Cuadra_Transaccion
      ,l_Trama_Dv.Documento_Liquidacion_Pago
      ,l_Trama_Dv.Documento_Liquidacion_Empresa
      ,Rtrim(Ltrim(l_Trama_Dv.Codigo_Autorizacion_Externo))
       --, l_trama_dv.transaccion_manual
      ,l_Trama_Dv.Movimiento_Enlinea
      ,l_Trama_Dv.Supervisor
      ,l_Trama_Dv.Rut_Supervisor
      ,Substr(l_Trama_Dv.Identi_Supervisor
             ,1
             ,1)
      ,Substr(l_Trama_Dv.Identi_Supervisor
             ,2
             ,30)
      ,l_Trama_Dv.Tipo_Deducible
      ,l_Trama_Dv.Monto_Deducible
      ,l_Trama_Dv.Valor_Moneda
      ,l_Trama_Dv.Tipo_Moneda
      ,NULL
      , --l_trama_dv.periodicidad_deducible
       l_Trama_Dv.Indicadores_Tx
      ,l_Trama_Dv.Documento_Electronico
      ,TRIM(p_Transaccion.Trama_Pos.Id_Maquina)
      ,To_Date(Decode(l_Trama_Dv.Fecha_Inicio_Tx
                     ,0
                     ,NULL
                     ,l_Trama_Dv.Fecha_Inicio_Tx)
              ,'yyyymmddhh24miss')
      ,To_Date(Decode(l_Trama_Dv.Fecha_Cierre_Tx
                     ,0
                     ,NULL
                     ,l_Trama_Dv.Fecha_Cierre_Tx)
              ,'yyyymmddhh24miss')
      ,Trunc(To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Proceso
                    ,'yyyymmddhh24miss'))
      --INI 20241125 POSLIGTH              
      --,l_Trama_Dv.Canal_Transaccion
      ,CASE WHEN TRIM(l_Trama_Dv.Canal_Transaccion) = 'F' THEN NULL ELSE l_Trama_Dv.Canal_Transaccion END 
      --FIN 20241125 POSLIGTH  
        
      --,l_Trama_Dv.Tiene_Donacion            -- LMP GPF 2023 No se envia por GEO
      ,l_Trama_Dv.Url_Factura
      , -- FCG 21082023 Origen OMS
       l_Trama_Dv.Url_Xml
      ,l_Trama_Dv.Folio_Venta_Anulada -- JAGC NEC 20240909
       );
  
    -- recorre documentos emitidos
    l_Dbg_Mensaje    := 'Recorrer documentos emitidos (DV1)';
    l_Crea_Documento := 1;
    l_Folio_Ant      := NULL;
    FOR l_Itm IN 1 .. l_Trama_Dv.Subtrama_Dv1.Count
    LOOP
      -- obtiene ID para tabla scfr_mov_documentos_txs
      l_Dbg_Mensaje := 'Obtener folio desde SCFR_MOV_DOCUMENTOS_TXS_S';
      SELECT Scfr_Mov_Documentos_Txs_s.Nextval INTO l_Mov_Documentos FROM Dual;
      x_Doc_Emitidos(l_Itm) := l_Mov_Documentos;
      IF l_Trama_Dv.Subtrama_Dv1(l_Itm).Afecto = -1 THEN
        l_Trama_Dv.Subtrama_Dv1(l_Itm).Afecto := NULL;
      END IF;
      IF l_Trama_Dv.Subtrama_Dv1(l_Itm).Exento = -1 THEN
        l_Trama_Dv.Subtrama_Dv1(l_Itm).Exento := NULL;
      END IF;
      -- Identificados de Guias para companias de Seguros
      -- GTR : Guia de traslado, solo emitida en locales franquicias
      -- GDE : Guia de despacho, emitida en locales propios o franquicias.
      IF (l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Guia_Emitida IN ('GTR'
                                                              ,'GDE')) AND
         (l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Movimiento_Hijo = 'VENGUI') THEN
        -- Revisa si registro de GTR o GDE existen
        IF (l_Folio_Ant IS NOT NULL) THEN
          BEGIN
            SELECT 1
              INTO l_Guia_Existe
              FROM Scfr_Mov_Documentos_Txs
             WHERE Txo_Codigo_Tx = p_Transaccion.Codigo_Tx
               AND Tmo_Movimiento = l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Movimiento_Hijo
               AND Folio = l_Folio_Ant;
          EXCEPTION
            WHEN No_Data_Found THEN
              l_Folio_Ant   := l_Trama_Dv.Subtrama_Dv1(l_Itm).Folio;
              l_Guia_Existe := 0;
          END;
          IF (l_Guia_Existe = 1) THEN
            IF (l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Guia_Emitida = 'GDE') THEN
              UPDATE Scfr_Mov_Documentos_Txs
                 SET Folio         = l_Trama_Dv.Subtrama_Dv1(l_Itm).Folio
                    ,Guia_Despacho = l_Folio_Ant
               WHERE Txo_Codigo_Tx = p_Transaccion.Codigo_Tx
                 AND Tmo_Movimiento = l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Movimiento_Hijo
                 AND Folio = l_Folio_Ant;
            ELSE
              UPDATE Scfr_Mov_Documentos_Txs
                 SET Folio         = l_Folio_Ant
                    ,Guia_Despacho = l_Trama_Dv.Subtrama_Dv1(l_Itm).Folio
               WHERE Txo_Codigo_Tx = p_Transaccion.Codigo_Tx
                 AND Tmo_Movimiento = l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Movimiento_Hijo
                 AND Folio = l_Folio_Ant;
            END IF;
            l_Crea_Documento := 0;
          END IF;
        ELSE
          l_Folio_Ant := l_Trama_Dv.Subtrama_Dv1(l_Itm).Folio;
        END IF;
      END IF; --
    
      IF (l_Crea_Documento = 1) THEN
        -- inserta documentos emitidos
        l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_DOCUMENTOS_TXS_S';
        INSERT INTO Scfr_Mov_Documentos_Txs
          (Mov_Documentos
          ,Txo_Codigo_Tx
          ,Txo_Correlativo_Tx
          ,Secuencia
          ,Tmo_Movimiento
          ,Dfi_Numero_Asignacion
          ,Monto
          ,Anulado
          ,Iva
          ,Folio
          ,Folio_Dicc
          ,Tipo_Dicc
          ,Pin_Ot_Recetario
          ,Estado_Movimiento_Caja
          ,Fecha_Regularizacion
          ,Numero_Pedido
          ,Pvr_Rut_Proveedor
          ,Pvr_Sucursal_Proveedor
          ,Folio_Reclamo_Canje
          ,Matricula_Bulto
          ,Sello_Seguro_Uno
          ,Sello_Seguro_Dos
          ,Facturado
          ,Periodo_Facturacion
          ,Puntos_Asignados
          ,Emp_Empresa
          ,Cad_Cadena
          ,Loc_Local
          ,Tipo_Distribucion
          ,Campana
          ,Documento_Fiscal
          ,Sec_Financiamiento
          ,Afecto
          ,Exento
          ,Factura_Turista
          ,Tipo_Docto_Id
          ,Numero_Docto_Id
          ,Nota_Credito_Original)
        VALUES
          (l_Mov_Documentos -- mov_documentos                    not null
          ,p_Transaccion.Codigo_Tx -- txo_codigo_tx                     not null
          ,l_Trama_Dv.Correlativo_Tx -- txo_correlativo_tx                not null
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Secuencia_b -- secuencia                         not null
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Movimiento_Hijo -- tmo_movimiento                    not null
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Numero_Asignacion -- dfi_numero_asignacion                 null
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Total_Iva_Incluido -- monto                             not null
          ,Substr(l_Trama_Dv.Subtrama_Dv1(l_Itm).Anulado
                 ,1
                 ,1) -- anulado                           not null
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Iva -- iva                                   null
          ,TRIM(l_Trama_Dv.Subtrama_Dv1(l_Itm).Folio) -- folio                                 null
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Folio_Dicc -- folio_dicc                            null
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Dicc -- tipo_dicc                             null
          ,l_Trama_Dv.Ot -- pin_ot_recetario
          ,NULL -- estado_movimiento_caja                null
          ,NULL -- fecha_regularizacion                  null
          ,NULL -- numero_pedido                         null
          ,NULL -- pvr_rut_proveedor                     null
          ,NULL -- pvr_sucursal_proveedor                null
          ,NULL -- folio_reclamo_canje                   null
          ,NULL -- matricula_bulto                       null
          ,NULL -- sello_seguro_uno                      null
          ,NULL -- sello_seguro_dos                      null
          ,NULL -- facturado                             null
          ,Substr(To_Char(Decode(l_Trama_Dv.Subtrama_Dv1(l_Itm).Periodo_Facturacion
                                ,0
                                ,NULL
                                ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Periodo_Facturacion))
                 ,1
                 ,6) -- periodo_facturacion                 null
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Puntos_Asignados -- puntos_asignados                      null
          ,p_Transaccion.Trama_Pos.Empresa -- emp_empresa                           null
          ,p_Transaccion.Trama_Pos.Cadena -- cad_cadena                            null
          ,p_Transaccion.Trama_Pos.Local -- loc_local                             null
          ,Decode(TRIM(l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Distribucion)
                 ,'EXC'
                 ,'COP'
                 ,TRIM(l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Distribucion)) --TRIM(l_trama_dv.subtrama_dv1(l_itm).tipo_distribucion) -- tipo_distribucion                     null
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Campana
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Documento_Fiscal
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Secuencia_Financiamiento
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Afecto
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Exento
          ,l_Trama_Dv.Factura_Turista
          ,l_Trama_Dv.Tipo_Documento_Id
          ,Rtrim(Ltrim(l_Trama_Dv.Numero_Documento_Id))
          ,l_Codigo_Tx_Relacion);
      END IF;
    END LOOP;
    -- recorre transacciones relacionadas
    l_Dbg_Mensaje := 'Recorrer documentos emitidos (DV2)';
    FOR l_Itm IN 1 .. l_Trama_Dv.Subtrama_Dv2.Count
    LOOP
      --  busca recaudacion asociada
      BEGIN
        SELECT Mtr.Codigo_Tx
          INTO l_Codigo_Tx_Recaud
          FROM Scfr_Mov_Transacciones Mtr
         WHERE Mtr.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
           AND Mtr.Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
           AND Mtr.Loc_Local = p_Transaccion.Trama_Pos.Local
           AND ((Mtr.Tmo_Movimiento_Padre = 'RECAUD' AND Mtr.Correlativo_Tx = l_Trama_Dv.Subtrama_Dv2(l_Itm).Correlativo_Tx) OR
               (Mtr.Tmo_Movimiento_Padre = 'AVANCE' AND Mtr.Correlativo_Tx = l_Trama_Dv.Subtrama_Dv2(l_Itm).Correlativo_Tx));
      EXCEPTION
        WHEN No_Data_Found THEN
          l_Codigo_Tx_Recaud := 0;
      END;
      -- inserta documentos emitidos
      l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_TX_RELACIONADAS';
      INSERT INTO Scfr_Mov_Tx_Relacionadas
        (Txo_Codigo_Tx
        ,Txo_Codigo_Tx_Relacionado
        ,Motivo
        ,Correlativo_Tx_Relacionado
        ,LOCAL
        ,Fecha_Tx
        ,Numero_Maquina
        ,Empresa
        ,Cadena
        ,Loc_Local)
      VALUES
        (p_Transaccion.Codigo_Tx
        ,l_Codigo_Tx_Recaud
        ,l_Trama_Dv.Subtrama_Dv2(l_Itm).Motivo
        ,l_Trama_Dv.Subtrama_Dv2(l_Itm).Correlativo_Tx
        ,p_Transaccion.Trama_Pos.Local
        ,p_Transaccion.Fecha_Tx
        ,p_Transaccion.Trama_Pos.Numero_Pos
        ,p_Transaccion.Trama_Pos.Empresa
        ,p_Transaccion.Trama_Pos.Cadena
        ,p_Transaccion.Trama_Pos.Local);
    END LOOP;
    -- CTM 27/03/2012 - Procedimiento que graba el campo CODIGO_TX_VTA  en la tabla SCFR_RM_COTIZACION.
    l_Dbg_Mensaje := 'Verificar si existe trama RP';
    --//--------------------------------------------------------------------------\\
    --// C_BRIONES 17/12/2012 17:49 REP. MANTIS 3169                              \\
    --// Se cambia Consulta pra ejecutar Update_Codigo_Cotizacion                 \\
    --//    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx,'RP') THEN  \\
    --//-----------------------------------------------------------------Inicio---\\
    /*IF To_Number(Nvl(TRIM(l_Trama_Dv.Ot)
                    ,'0')) > 0 THEN
                    */
     -----------------------------------------------
     -- LMP GPF 20230916 OT es varchar2
     -----------------------------------------------  
     IF l_Trama_Dv.Ot is not null THEN                           
      l_Codigo_Tx   := p_Transaccion.Trama_Pos.Sistema || p_Transaccion.Trama_Pos.Funcion || p_Transaccion.Trama_Pos.Secuencia_c;
      l_Dbg_Mensaje := 'LLamar a update_codigo_cotizacion';
      Update_Codigo_Cotizacion(l_Trama_Dv.Ot
                              ,p_Transaccion.Codigo_Tx
                              ,l_Codigo_Tx
                              ,x_Cod_Error
                              ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) <> 0 THEN
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
        x_Cod_Error := 0;
        x_Msg_Error := '';
      END IF;
    END IF;
    x_Trama_Dv := l_Trama_Dv;
    x_Trama_Cv := l_Trama_Cv;
    --//-----------------------------------------------------------------Termino--\\
    /*EMSG 07042020 Enviar numero de la boleta al autorizador externo de excedentes */
    /*
    BEGIN
      SELECT c.Comercio
            ,c.Rut
            ,c.Codigo_Autorizacion_Fcv
            ,TRIM(Substr(c.Consulta
                        ,Instr(c.Consulta
                              ,'|'
                              ,1
                              ,11) + 1
                        ,Instr(c.Consulta
                              ,'|'
                              ,1
                              ,12) - Instr(c.Consulta
                                          ,'|'
                                          ,1
                                          ,11) - 1)) Tipo_Docto
        INTO l_Comercio
            ,l_Rut_Cliente
            ,l_Codigo_Fcv
            ,l_Tipo_Docto
        FROM Scfr_Log_Autorizacion_Mdp   c
            ,Scfr_Mov_Transacciones_Pago b
            ,Scfr_Mov_Transacciones      a
       WHERE a.Codigo_Autorizacion_Tx = l_Trama_Dv.Ot
         AND a.Loc_Local = p_Transaccion.Trama_Pos.Local
         AND a.Tmo_Movimiento_Padre = 'RECAUD'
         AND a.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
         AND b.Txo_Codigo_Tx = a.Codigo_Tx
         AND c.Codigo_Autorizacion_Fcv = b.Codigo_Autorizacion
         AND c.Tipo_Operacion = 'INE';
    EXCEPTION
      WHEN OTHERS THEN
        l_Comercio := NULL;
    END;
    IF l_Comercio IS NOT NULL THEN
      BEGIN
        SELECT a.Attribute1
              ,a.Attribute2
              ,a.Attribute3
          INTO l_Rut_Proveedor
              ,l_Origen
              ,l_Canal
          FROM Scfr_Comn_Externa a
         WHERE a.Proceso = 'EXCEDENTE_MDP'
           AND a.Empresa_Que_Autoriza = l_Comercio;
      EXCEPTION
        WHEN OTHERS THEN
          l_Rut_Proveedor := NULL;
          l_Origen        := NULL;
          l_Canal         := NULL;
      END;
    END IF;
    l_Fecha_Inicio := SYSDATE;
    BEGIN
      l_Consulta := p_Transaccion.Trama_Pos.Empresa || '|' || p_Transaccion.Trama_Pos.Cadena || '|' || p_Transaccion.Trama_Pos.Local || '|' ||
                    l_Comercio || l_Rut_Proveedor || '|' || l_Rut_Cliente || '|' || l_Codigo_Fcv || '|' || l_Folio_Boleta || '|' || l_Tipo_Docto || '|' ||
                    l_Origen || '|' || l_Canal;
      Pkg_Excedentes_Mp.Proc_Registra_Doc(p_Empresa       => p_Transaccion.Trama_Pos.Empresa
                                         ,p_Cadena        => p_Transaccion.Trama_Pos.Cadena
                                         ,p_Local         => p_Transaccion.Trama_Pos.Local
                                         ,p_Comercio      => l_Comercio
                                         ,p_Fecha         => SYSDATE
                                         ,p_Rut_Proveedor => l_Rut_Proveedor
                                         ,p_Rut_Cliente   => l_Rut_Cliente
                                         ,p_Id_Tx         => l_Codigo_Fcv
                                         ,p_Num_Doc       => l_Folio_Boleta
                                         ,p_Tipo_Doc      => l_Tipo_Docto
                                         ,p_Origen        => l_Origen
                                         ,p_Canal         => l_Canal
                                         ,x_Estado        => l_Estado_Exc
                                         ,x_Cod_Error     => l_Cod_Error_Exc
                                         ,x_Des_Error     => l_Des_Error_Exc);
      l_Respuesta := l_Estado_Exc || '|' || l_Cod_Error_Exc || '|' || l_Des_Error_Exc;
    EXCEPTION
      WHEN OTHERS THEN
        Log_Autext(p_Proceso                 => l_Comercio
                  ,p_Tipo_Operacion          => 'DOC'
                  ,p_Fecha_Autorizacion      => l_Fecha_Inicio
                  ,p_Fecha_Confirmacion      => SYSDATE
                  ,p_Codigo_Resultado        => l_Cod_Error_Exc
                  ,p_Codigo_Autorizacion_Fcv => l_Codigo_Fcv
                  ,p_Codigo_Autorizacion_Ext => l_Estado_Exc
                  ,p_Consulta                => l_Consulta
                  ,p_Respuesta               => l_Respuesta
                  ,p_Glosa_Respuesta         => 'Resp Registra DOC Excedente ' || SQLERRM
                  ,p_Rut                     => p_Transaccion.Rut_Titular
                  ,p_Local                   => p_Transaccion.Trama_Pos.Local
                  ,x_Cod_Error               => l_Cod_Error
                  ,x_Msg_Error               => l_Msg_Error);
    
    END;
    */
    /*EMSG 07042020 Enviar numero de la boleta al autorizador externo de excedentes */
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Trama DV resuelta correctamente');
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  PROCEDURE Trama_Dv_Reversa(p_Transaccion    IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                            ,x_Trama_Dv       OUT Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                            ,x_Trama_Cv       OUT Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv
                            ,x_Tiene_Trama_Cv OUT BOOLEAN
                            ,x_Doc_Emitidos   OUT Scfr_Trx_Gnc_Pk.Tab_Doc_Emitidos
                            ,x_Cod_Error      OUT NUMBER
                            ,x_Msg_Error      OUT VARCHAR2) IS
    l_Trama_Dv  Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv;
    l_Trama_Cv  Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv;
    l_Codigo_Tx Scfr_Trx_Rec_Pos.Codigo_Transaccion%TYPE;
    l_Itm       NUMBER;
    l_Fecha     NUMBER;
    l_Hora      NUMBER;
    l_Folio_Anu VARCHAR2(15);
    --       l_Folio_Anu       NUMBER; --FCG 04062021
    l_Doctos_Emitidos NUMBER;
  
    l_Mov_Documentos     NUMBER;
    l_Codigo_Tx_Relacion NUMBER;
    l_Crea_Documento     NUMBER;
    l_Folio_Ant          Scfr_Mov_Documentos_Txs.Folio%TYPE;
    l_Folio_Docto_Venta  Scfr_Mov_Documentos_Txs.Folio%TYPE;
    l_Guia_Existe        NUMBER;
    l_Local_Tx_Relacion  NUMBER;
    l_Fecha_Tx_Relacion  DATE;
    l_Party_Id_Aux       NUMBER;
    l_Trx_Esta_En_Online BOOLEAN;
    l_Puntos_Canjeados   NUMBER;
    l_String             VARCHAR2(1000);
    l_Dbg_Proceso        VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_dv_reversa';
    l_Dbg_Mensaje        VARCHAR2(250) := 'Error General';
    l_Origen_Anulacion   VARCHAR2(3);
    Mes_Venta            NUMBER;
    Mes_Anulacion        NUMBER;
    Dia_Venta            NUMBER;
    Dia_Anulacion        NUMBER;
    l_Error_Controlado   EXCEPTION;
    l_Fecha_Tx_Origen    DATE; --incidencia 3241
    l_Rut_Proveedor      NUMBER;
    l_Origen             NUMBER;
    l_Canal              NUMBER;
    l_Id_Tx              NUMBER;
    l_Id_Dev_Tx          NUMBER;
    l_Cod_Rev            VARCHAR2(300);
    l_Cod_Error          VARCHAR2(10);
    l_Msg_Error          VARCHAR2(200);
    l_Comercio           VARCHAR2(3);
    l_Fecha_Inicio       DATE;
    l_Consulta           VARCHAR2(1000);
    l_Respuesta          VARCHAR2(1000);
    l_Tipo_Doc           NUMBER;
    l_Rut_Exc            NUMBER;
    l_Rev_Enviada        VARCHAR2(3);
    l_Tipo_Doc_Ine       VARCHAR2(30);
    l_Convenio           VARCHAR2(50);
  BEGIN
    x_Cod_Error          := 0;
    l_Trx_Esta_En_Online := TRUE;
    --l_puntos_canjeados   := Scfr_Trx_Gnc_Utl_Pk.retorna_puntos_canjeados(p_transaccion);
    -- obtiene folio de la transaccion para el modelo ON-LINE
    l_Dbg_Mensaje := 'Obtener folio desde scfr_mov_transacciones_s';
    SELECT Scfr_Mov_Transacciones_s.Nextval INTO p_Transaccion.Codigo_Tx FROM Dual;
    -- Obtiene informacion de la trama DV
    l_Dbg_Mensaje                := 'Obtener informacion de la trama DV';
    l_Trama_Dv                   := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Dv(p_Transaccion.Trama_Pos
                                                                      ,p_Transaccion.Cuerpo_Tx);
    p_Transaccion.Fecha_Tx       := To_Date(Ltrim(Rtrim(l_Trama_Dv.Fecha)) || Ltrim(Rtrim(To_Char(l_Trama_Dv.Hora_Venta
                                                                                                 ,'000009')))
                                           ,'yyyymmddhh24miss');
    p_Transaccion.Correlativo_Tx := l_Trama_Dv.Correlativo_Tx;
    -- Obtiene codigo tx de la transaccion original (GNCU01) desde la tabla SCFR_MOV_DOCUMENTOS
    -- Utiliza el primer documento emitido para la transaccion
    l_Dbg_Mensaje := 'Obtener folio de la transaccion original desde scfr_mov_transacciones';
    BEGIN
      SELECT Mtr.Codigo_Tx
            ,Mtr.Loc_Local
            ,Mtr.Fecha_Tx
            ,Mtr.Pt_Party_Id_Titular
        INTO l_Codigo_Tx_Relacion
            ,l_Local_Tx_Relacion
            ,l_Fecha_Tx_Relacion
            ,l_Party_Id_Aux
        FROM Scfr_Mov_Transacciones  Mtr
            ,Scfr_Mov_Documentos_Txs Mdo
       WHERE Mtr.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
         AND Mtr.Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
         AND Mtr.Loc_Local = l_Trama_Dv.Local
         AND Mtr.Tmo_Movimiento_Padre LIKE 'VEN%'
         AND Mdo.Tmo_Movimiento LIKE 'VEN%'
         AND Mtr.Codigo_Tx = Mdo.Txo_Codigo_Tx
         AND Mtr.Correlativo_Tx = l_Trama_Dv.Correlativo_Tx_Asociado
         AND Mdo.Documento_Fiscal = 'SI'
         AND Rownum = 1;
      -- obtiene el codigo tx de la venta original para su uso posterior
      p_Transaccion.Codigo_Tx_Origen := l_Codigo_Tx_Relacion;
      p_Transaccion.Fecha_Tx_Origen  := l_Fecha_Tx_Relacion;
      p_Transaccion.Local_Origen     := l_Local_Tx_Relacion;
    EXCEPTION
      WHEN No_Data_Found THEN
        -- se asume que transaccion es de hace varios dias por lo tanto se debe buscar en el
        -- modelo BATC.
        l_Dbg_Mensaje := 'Obtener folio de la transaccion original desde batc_mov_transacciones';
        BEGIN
          SELECT Substr(Mtr.Codigo_Tx
                       ,6) Codigo_Tx
                ,Mtr.Loc_Local
                ,Mtr.Fecha_Tx
                ,Mtr.Pt_Party_Id_Titular
            INTO l_Codigo_Tx_Relacion
                ,l_Local_Tx_Relacion
                ,l_Fecha_Tx_Relacion
                ,l_Party_Id_Aux
            FROM Batc_Mov_Transacciones  Mtr
                ,Batc_Mov_Documentos_Txs Mdo
           WHERE Mtr.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
             AND Mtr.Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
             AND Mtr.Loc_Local = l_Trama_Dv.Local
             AND Mtr.Tmo_Movimiento_Padre LIKE 'VEN%'
             AND Mdo.Tmo_Movimiento LIKE 'VEN%'
             AND Mtr.Codigo_Tx = Mdo.Txo_Codigo_Tx
             AND Mtr.Correlativo_Tx = l_Trama_Dv.Correlativo_Tx_Asociado
             AND Mdo.Documento_Fiscal = 'SI'
             AND Rownum = 1;
          -- obtiene el codigo tx de la venta original para su uso posterior
          p_Transaccion.Codigo_Tx_Origen := NULL; -- l_codigo_tx_relacion;
          p_Transaccion.Fecha_Tx_Origen  := l_Fecha_Tx_Relacion;
          p_Transaccion.Local_Origen     := l_Local_Tx_Relacion;
          l_Trx_Esta_En_Online           := FALSE;
        EXCEPTION
          WHEN OTHERS THEN
            p_Transaccion.Codigo_Tx_Origen := NULL;
            p_Transaccion.Fecha_Tx_Origen  := NULL;
            p_Transaccion.Local_Origen     := NULL;
        END;
      WHEN OTHERS THEN
        p_Transaccion.Codigo_Tx_Origen := NULL;
        p_Transaccion.Fecha_Tx_Origen  := NULL;
        p_Transaccion.Local_Origen     := NULL;
    END;
    -- en caso que transaccion no tenga identificacion, busca el party id en el documento original
    IF Nvl(p_Transaccion.Trama_Boc.Party_Id
          ,0) = 0 THEN
      p_Transaccion.Trama_Boc.Party_Id := l_Party_Id_Aux;
    END IF;
    IF Nvl(p_Transaccion.Trama_Boc.Party_Id
          ,0) = 0 THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'No se pudo encontrar el party id para la reversa');
    END IF;
    -- obtiene el rut y dv del cliente
    l_Dbg_Mensaje := 'Obtener Rut del cliente';
    Scfr_Trx_Fid_Pk.Obtiene_Rut(p_Transaccion.Trama_Boc.Party_Id -- in
                               ,p_Transaccion.Rut_Titular -- out
                               ,p_Transaccion.Dv_Rut_Titular); -- out
    -- Inenta obtener informacion de la trama CV
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'CV') THEN
      l_Dbg_Mensaje    := 'Obtener informacion de la trama CV';
      x_Tiene_Trama_Cv := TRUE;
      l_Trama_Cv       := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Cv(p_Transaccion.Cuerpo_Tx);
      /* Para controlar cuando mandan encabezado de trama CV con 0 registros */
      IF l_Trama_Cv.Count = 0 THEN
        x_Tiene_Trama_Cv := FALSE;
        l_Trama_Cv(1).Convenio := NULL;
        l_Trama_Cv(1).Plan := NULL;
        l_Trama_Cv(1).Codigo_Autorizacion := NULL;
      END IF;
    ELSE
      x_Tiene_Trama_Cv := FALSE;
      l_Trama_Cv(1).Convenio := NULL;
      l_Trama_Cv(1).Plan := NULL;
      l_Trama_Cv(1).Codigo_Autorizacion := NULL;
    END IF;
  
    IF (l_Trama_Cv(1).Convenio >= 1000000000) THEN
      l_Convenio := To_Char(To_Number(Substr(To_Char(l_Trama_Cv(1).Convenio)
                                            ,3
                                            ,10)));
    ELSE
      l_Convenio := To_Char(To_Number(To_Char(l_Trama_Cv(1).Convenio)));
    END IF;
    -- inserta transaccion
    l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_TRANSACCIONES';
    INSERT INTO Scfr_Mov_Transacciones
      (Codigo_Tx
      ,Correlativo_Tx
      ,Tmo_Movimiento_Padre
      ,Fecha_Tx
      ,Pos_Tipo_Transaccion
      ,Pt_Party_Id_Titular
      ,Rut_Titular
      ,Dv_Titular
      ,Secuencia_Beneficiario
      ,Rut_Beneficiario
      ,Dv_Beneficiario
      ,Pt_Party_Id_Beneficiario
      ,Con_Numero_Convenio
      ,Pla_Numero_Plan
      ,Autorizacion_Cnv_Tx
      ,Rut_Fidelizado
      ,Dv_Fidelizado
      ,Pt_Party_Id_Fidelizado
      ,Cot_Cotizacion
      ,Numero_Preventa
      ,Txo_Codigo_Tx_Relacionado
      ,Txo_Correlativo_Tx_Relacionado
      ,Loc_Local_Relacionado
      ,Num_Service_Request
      ,Agente_Ddo
      ,Rut_Agente_Ddo
      ,Dv_Agente_Ddo
      ,Sec_Recaudacion
      ,Pin_Transaccion
      ,Rut_Retira
      ,Dv_Retira
      ,Nombre_Retira
      ,Cad_Cadena_Traspaso
      ,Loc_Local_Traspaso
      ,Emp_Empresa
      ,Cad_Cadena
      ,Loc_Local
      ,Canal
      ,Estado_Registro
      ,Proceso_Dwh
      ,Numero_Maquina
      ,Cuadrar_Transacciones
      ,Docs_Emitir_Liq_Pag
      ,Docs_Emitir_Liq_Emp
      ,Autorizacion_Cnv_Ext
       --, transaccion_manual
      ,Linea
      ,Supervisor
      ,Rut_Supervisor
      ,Tipo_Identi_Supervisor
      ,Identi_Supervisor
      ,Tipo_Deducible
      ,Monto_Deducible
      ,Valor_Moneda
      ,Tipo_Moneda
      ,Periodicidad_Deducible
      ,Indicadores_Tx
      ,Reg_Electronico
      ,Numero_Tav
      ,Fecha_Inicio_Tx
      ,Fecha_Cierre_Tx
      ,Fecha_Generacion_Registro
      ,Canal_Transaccion---- IDHC 23/05/2024
      ,Folio_Venta_Anulada -- JAGC NEC 20240909
      )
    VALUES
      (p_Transaccion.Codigo_Tx -- codigo_tx                         not null
      ,l_Trama_Dv.Correlativo_Tx -- correlativo_tx                    not null
      ,l_Trama_Dv.Tipo_Movimiento_Padre -- tmo_movimiento_padre              not null
      ,p_Transaccion.Fecha_Tx -- fecha_tx                          not null
      ,l_Trama_Dv.Tipo_Tx -- pos_tipo_transaccion                  null
      ,p_Transaccion.Trama_Boc.Party_Id -- pt_party_id_titular                   null
      ,p_Transaccion.Rut_Titular -- rut_titular                           null
      ,p_Transaccion.Dv_Rut_Titular -- dv_titular                            null
      ,NULL -- secuencia_beneficiario                null
      ,NULL -- rut_beneficiario                      null
      ,NULL -- dv_beneficiario                       null
      ,NULL -- pt_party_id_beneficiario              null
      ,l_Convenio -- l_Trama_Cv(1).Convenio -- con_numero_convenio                   null
      ,l_Trama_Cv(1).Plan -- pla_numero_plan                       null
      ,TRIM(l_Trama_Cv(1).Codigo_Autorizacion) -- autorizacion_cnv_tx                   null
      ,p_Transaccion.Rut_Titular -- rut_fidelizado                        null
      ,p_Transaccion.Dv_Rut_Titular -- dv_fidelizado                         null
      ,p_Transaccion.Trama_Boc.Party_Id -- pt_party_id_fidelizado                null
      ,NULL -- cot_cotizacion                        null
      ,l_Trama_Dv.Numero_Preventa -- numero_preventa                       null
      ,p_Transaccion.Codigo_Tx_Origen -- l_codigo_tx_relacion -- txo_codigo_tx_relacionado             null
      ,l_Trama_Dv.Correlativo_Tx_Asociado -- txo_correlativo_tx_relacionado        null
      ,l_Local_Tx_Relacion -- loc_local_relacionado                 null
      ,NULL -- num_service_request                   null
      ,NULL -- agente_ddo                            null
      ,NULL -- rut_agente_ddo                        null
      ,NULL -- dv_agente_ddo                         null
      ,l_Trama_Dv.Recaudacion_Relacionada -- sec_recaudacion                       null
      ,l_Trama_Dv.Pin_Transaccion -- pin_transaccion                       null
      ,NULL -- rut_retira                            null
      ,NULL -- dv_retira                             null
      ,NULL -- nombre_retira                         null
      ,NULL -- cad_cadena_traspaso                   null
      ,NULL -- loc_local_traspaso                    null
      ,p_Transaccion.Trama_Pos.Empresa -- emp_empresa                           null
      ,p_Transaccion.Trama_Pos.Cadena -- cad_cadena                            null
      ,p_Transaccion.Trama_Pos.Local -- loc_local                             null
      ,Rtrim(Ltrim(l_Trama_Dv.Canal)) -- JAGC NEC 20240909 --,'POS' -- canal                                 null
      ,'VIG' -- estado_registro                   not null
      ,0 -- proceso_dwh                       not null
      ,p_Transaccion.Trama_Pos.Numero_Pos -- numero_maquina                    not null
      ,l_Trama_Dv.Cuadra_Transaccion
      ,l_Trama_Dv.Documento_Liquidacion_Pago
      ,l_Trama_Dv.Documento_Liquidacion_Empresa
      ,l_Trama_Dv.Codigo_Autorizacion_Externo
       --, l_trama_dv.transaccion_manual
      ,l_Trama_Dv.Movimiento_Enlinea
      ,l_Trama_Dv.Supervisor
      ,l_Trama_Dv.Rut_Supervisor
      ,Substr(l_Trama_Dv.Identi_Supervisor
             ,1
             ,1)
      ,Substr(l_Trama_Dv.Identi_Supervisor
             ,2
             ,30)
      ,l_Trama_Dv.Tipo_Deducible
      ,l_Trama_Dv.Monto_Deducible
      ,l_Trama_Dv.Valor_Moneda
      ,l_Trama_Dv.Tipo_Moneda
      ,NULL
      ,l_Trama_Dv.Indicadores_Tx
      ,l_Trama_Dv.Documento_Electronico
      ,TRIM(p_Transaccion.Trama_Pos.Id_Maquina)
      ,To_Date(Decode(l_Trama_Dv.Fecha_Inicio_Tx
                     ,0
                     ,NULL
                     ,l_Trama_Dv.Fecha_Inicio_Tx)
              ,'yyyymmddhh24miss')
      ,To_Date(Decode(l_Trama_Dv.Fecha_Cierre_Tx
                     ,0
                     ,NULL
                     ,l_Trama_Dv.Fecha_Cierre_Tx)
              ,'yyyymmddhh24miss')
      ,Trunc(To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Proceso
                    ,'yyyymmddhh24miss')),
       l_Trama_Dv.Canal_Transaccion -- IDHC 23/05/2024
      ,l_Trama_Dv.Folio_Venta_Anulada -- JAGC NEC 20240909
       );
    -- recorre documentos emitidos
    l_Dbg_Mensaje := 'Recorrer documentos emitidos (DV1)';
    -- Incidencia 3241
    IF l_Trx_Esta_En_Online = TRUE THEN
      BEGIN
        SELECT Fecha_Tx
          INTO l_Fecha_Tx_Origen
          FROM Scfr_Mov_Transacciones
         WHERE Correlativo_Tx = l_Trama_Dv.Correlativo_Tx_Asociado
           AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
           AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
           AND Loc_Local = l_Trama_Dv.Local
           AND Tmo_Movimiento_Padre = l_Trama_Dv.Tipo_Movimiento_Padre
           AND Fecha_Tx >= To_Date(l_Trama_Dv.Fecha
                                  ,'yyyymmdd') - 90;
      EXCEPTION
        WHEN No_Data_Found THEN
          SELECT Fecha_Tx
            INTO l_Fecha_Tx_Origen
            FROM Batc_Mov_Transacciones
           WHERE Correlativo_Tx = l_Trama_Dv.Correlativo_Tx_Asociado
             AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
             AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
             AND Loc_Local = l_Trama_Dv.Local
             AND Tmo_Movimiento_Padre = l_Trama_Dv.Tipo_Movimiento_Padre
             AND Fecha_Tx >= To_Date(l_Trama_Dv.Fecha
                                    ,'yyyymmdd') - 90;
      END;
    ELSE
      BEGIN
        SELECT Fecha_Tx
          INTO l_Fecha_Tx_Origen
          FROM Batc_Mov_Transacciones
         WHERE Correlativo_Tx = l_Trama_Dv.Correlativo_Tx_Asociado
           AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
           AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
           AND Loc_Local = l_Trama_Dv.Local
           AND Tmo_Movimiento_Padre = l_Trama_Dv.Tipo_Movimiento_Padre
           AND Fecha_Tx >= To_Date(l_Trama_Dv.Fecha
                                  ,'yyyymmdd') - 90;
      EXCEPTION
        WHEN OTHERS THEN
          l_Fecha_Tx_Origen := p_Transaccion.Fecha_Tx;
      END;
    END IF;
    l_Crea_Documento := 1;
    l_Folio_Ant      := NULL;
    FOR l_Itm IN 1 .. l_Trama_Dv.Subtrama_Dv1.Count
    LOOP
      IF l_Trx_Esta_En_Online = TRUE THEN
        l_Dbg_Mensaje := 'Buscar documento original en tabla SCFR_MOV_DOCUMENTOS';
        SELECT Folio
          INTO l_Folio_Anu
          FROM Scfr_Mov_Documentos_Txs
         WHERE Secuencia = l_Trama_Dv.Subtrama_Dv1(l_Itm).Secuencia_b
           AND Txo_Correlativo_Tx = l_Trama_Dv.Correlativo_Tx_Asociado
           AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
           AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
           AND Loc_Local = l_Trama_Dv.Local;
        l_Dbg_Mensaje := 'Actualizar documento original en tabla SCFR_MOV_DOCUMENTOS';
        --Incidente 3241
        --mes_venta := extract(MONTH FROM p_transaccion.fecha_tx_origen);
        --mes_anulacion := extract(MONTH FROM to_date(p_transaccion.trama_pos.fecha_hora_contable, 'yyyymmddhh24mi'));
        --dia_venta := extract(DAY FROM p_transaccion.fecha_tx_origen);
        --dia_anulacion := extract(DAY FROM to_date(p_transaccion.trama_pos.fecha_hora_contable, 'yyyymmddhh24mi'));
        Mes_Venta     := Extract(MONTH FROM To_Date(l_Fecha_Tx_Origen
                                        ,'dd/mm/yyyy hh24:mi:ss'));
        Mes_Anulacion := Extract(MONTH FROM To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                        ,'yyyymmddhh24miss'));
        Dia_Venta     := Extract(DAY FROM To_Date(l_Fecha_Tx_Origen
                                        ,'dd/mm/yyyy hh24:mi:ss'));
        Dia_Anulacion := Extract(DAY FROM To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                        ,'yyyymmddhh24miss'));
        IF (Mes_Venta = Mes_Anulacion) THEN
          IF (Dia_Venta = Dia_Anulacion) THEN
            l_Origen_Anulacion := 'DIA';
          ELSE
            l_Origen_Anulacion := 'ANT';
          END IF;
        ELSE
          l_Origen_Anulacion := 'MAN';
        END IF;
        UPDATE Scfr_Mov_Documentos_Txs
           SET Anulado          = 'S'
              ,Origen_Anulacion = l_Origen_Anulacion
              ,Procesado        = Nvl2(Procesado
                                      ,2
                                      ,Procesado)
         WHERE Secuencia = l_Trama_Dv.Subtrama_Dv1(l_Itm).Secuencia_b
           AND Txo_Correlativo_Tx = l_Trama_Dv.Correlativo_Tx_Asociado
           AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
           AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
           AND Loc_Local = l_Trama_Dv.Local;
      ELSE
        l_Dbg_Mensaje := 'Buscar documento original en tabla BATC_MOV_DOCUMENTOS';
        SELECT Folio
          INTO l_Folio_Anu
          FROM Batc_Mov_Documentos_Txs
         WHERE Secuencia = l_Trama_Dv.Subtrama_Dv1(l_Itm).Secuencia_b
           AND Txo_Correlativo_Tx = l_Trama_Dv.Correlativo_Tx_Asociado
           AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
           AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
           AND Loc_Local = l_Trama_Dv.Local;
        l_Dbg_Mensaje := 'Actualizar documento original en tabla BATC_MOV_DOCUMENTOS';
        Mes_Venta     := Extract(MONTH FROM To_Date(l_Fecha_Tx_Origen
                                        ,'dd/mm/yyyy hh24:mi:ss'));
        Mes_Anulacion := Extract(MONTH FROM To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                        ,'yyyymmddhh24miss'));
        Dia_Venta     := Extract(DAY FROM To_Date(l_Fecha_Tx_Origen
                                        ,'dd/mm/yyyy hh24:mi:ss'));
        Dia_Anulacion := Extract(DAY FROM To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                        ,'yyyymmddhh24miss'));
        IF (Mes_Venta = Mes_Anulacion) THEN
          IF (Dia_Venta = Dia_Anulacion) THEN
            l_Origen_Anulacion := 'DIA';
          ELSE
            l_Origen_Anulacion := 'ANT';
          END IF;
        ELSE
          l_Origen_Anulacion := 'MAN';
        END IF;
        UPDATE Batc_Mov_Documentos_Txs
           SET Anulado          = 'S'
              ,Origen_Anulacion = l_Origen_Anulacion
         WHERE Secuencia = l_Trama_Dv.Subtrama_Dv1(l_Itm).Secuencia_b
           AND Txo_Correlativo_Tx = l_Trama_Dv.Correlativo_Tx_Asociado
           AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
           AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
           AND Loc_Local = l_Trama_Dv.Local;
      END IF;
      -- obtiene ID para tabla scfr_mov_documentos_txs
      l_Dbg_Mensaje := 'Obtener folio desde SCFR_MOV_DOCUMENTOS_TXS_S';
      SELECT Scfr_Mov_Documentos_Txs_s.Nextval INTO l_Mov_Documentos FROM Dual;
      x_Doc_Emitidos(l_Itm) := l_Mov_Documentos;
      IF l_Trama_Dv.Subtrama_Dv1(l_Itm).Afecto = -1 THEN
        l_Trama_Dv.Subtrama_Dv1(l_Itm).Afecto := NULL;
      END IF;
      IF l_Trama_Dv.Subtrama_Dv1(l_Itm).Exento = -1 THEN
        l_Trama_Dv.Subtrama_Dv1(l_Itm).Exento := NULL;
      END IF;
      -- Identificados de Guias para companias de Seguros
      -- GTR : Guia de traslado, solo emitida en locales franquicias
      -- GDE : Guia de despacho, emitida en locales propios o franquicias.
      IF (l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Guia_Emitida IN ('GTR'
                                                              ,'GDE')) AND
         (l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Movimiento_Hijo = 'ANUGUI') THEN
        -- Revisa si registro de GTR o GDE existen
        IF (l_Folio_Ant IS NOT NULL) THEN
          BEGIN
            SELECT 1
              INTO l_Guia_Existe
              FROM Scfr_Mov_Documentos_Txs
             WHERE Txo_Codigo_Tx = p_Transaccion.Codigo_Tx
               AND Tmo_Movimiento = l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Movimiento_Hijo
               AND Folio = l_Folio_Ant;
          EXCEPTION
            WHEN No_Data_Found THEN
              l_Folio_Ant   := l_Trama_Dv.Subtrama_Dv1(l_Itm).Folio;
              l_Guia_Existe := 0;
          END;
          IF (l_Guia_Existe = 1) THEN
            IF (l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Guia_Emitida = 'GDE') THEN
              UPDATE Scfr_Mov_Documentos_Txs
                 SET Folio         = l_Trama_Dv.Subtrama_Dv1(l_Itm).Folio
                    ,Guia_Despacho = l_Folio_Ant
               WHERE Txo_Codigo_Tx = p_Transaccion.Codigo_Tx
                 AND Tmo_Movimiento = l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Movimiento_Hijo
                 AND Folio = l_Folio_Ant;
            ELSE
              UPDATE Scfr_Mov_Documentos_Txs
                 SET Folio         = l_Folio_Ant
                    ,Guia_Despacho = l_Trama_Dv.Subtrama_Dv1(l_Itm).Folio
               WHERE Txo_Codigo_Tx = p_Transaccion.Codigo_Tx
                 AND Tmo_Movimiento = l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Movimiento_Hijo
                 AND Folio = l_Folio_Ant;
            END IF;
            l_Crea_Documento := 0;
          END IF;
        ELSE
          l_Folio_Ant := l_Trama_Dv.Subtrama_Dv1(l_Itm).Folio;
        END IF;
      END IF; --
      IF (l_Crea_Documento = 1) THEN
        -- inserta documentos emitidos
        l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_DOCUMENTOS_TXS_S';
        INSERT INTO Scfr_Mov_Documentos_Txs
          (Mov_Documentos
          ,Txo_Codigo_Tx
          ,Txo_Correlativo_Tx
          ,Secuencia
          ,Tmo_Movimiento
          ,Dfi_Numero_Asignacion
          ,Monto
          ,Anulado
          ,Iva
          ,Folio
          ,Folio_Dicc
          ,Tipo_Dicc
          ,Pin_Ot_Recetario
          ,Estado_Movimiento_Caja
          ,Fecha_Regularizacion
          ,Numero_Pedido
          ,Pvr_Rut_Proveedor
          ,Pvr_Sucursal_Proveedor
          ,Folio_Reclamo_Canje
          ,Matricula_Bulto
          ,Sello_Seguro_Uno
          ,Sello_Seguro_Dos
          ,Facturado
          ,Periodo_Facturacion
          ,Puntos_Asignados
          ,Emp_Empresa
          ,Cad_Cadena
          ,Loc_Local
          ,Tipo_Distribucion
          ,Campana
          ,Documento_Fiscal
          ,Sec_Financiamiento
          ,Afecto
          ,Exento
          ,Origen_Anulacion
          ,Factura_Turista
          ,Tipo_Docto_Id
          ,Numero_Docto_Id)
        VALUES
          (l_Mov_Documentos -- mov_documentos                    not null
          ,p_Transaccion.Codigo_Tx -- txo_codigo_tx                     not null
          ,l_Trama_Dv.Correlativo_Tx -- txo_correlativo_tx                not null
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Secuencia_b -- secuencia                         not null
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Movimiento_Hijo -- tmo_movimiento                    not null
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Numero_Asignacion -- dfi_numero_asignacion                 null
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Total_Iva_Incluido * -1 -- monto                             not null
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Anulado -- anulado                           not null
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Iva * -1 -- iva                                   null
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Folio -- folio                                 null
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Folio_Dicc -- folio_dicc                            null
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Dicc -- tipo_dicc                             null
          ,l_Trama_Dv.Ot -- pin_ot_recetario
          ,NULL -- estado_movimiento_caja                null
          ,NULL -- fecha_regularizacion                  null
          ,NULL -- numero_pedido                         null
          ,NULL -- pvr_rut_proveedor                     null
          ,NULL -- pvr_sucursal_proveedor                null
          ,NULL -- folio_reclamo_canje                   null
          ,NULL -- matricula_bulto                       null
          ,NULL -- sello_seguro_uno                      null
          ,NULL -- sello_seguro_dos                      null
          ,NULL -- facturado                             null
          ,NULL -- periodo_facturacion                   null
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Puntos_Asignados -- puntos_asignados                      null
          ,p_Transaccion.Trama_Pos.Empresa -- emp_empresa                           null
          ,p_Transaccion.Trama_Pos.Cadena -- cad_cadena                            null
          ,p_Transaccion.Trama_Pos.Local -- loc_local                             null
          ,TRIM(l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Distribucion) -- tipo_distribucion                     null
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Campana -- campana
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Documento_Fiscal -- documento_fiscal                     null
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Secuencia_Financiamiento -- secuencia_financiamiento
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Afecto * -1
          ,l_Trama_Dv.Subtrama_Dv1(l_Itm).Exento * -1
          ,l_Origen_Anulacion
          ,l_Trama_Dv.Factura_Turista
          ,l_Trama_Dv.Tipo_Documento_Id
          ,Rtrim(Ltrim(l_Trama_Dv.Numero_Documento_Id)));
        l_Dbg_Mensaje := 'Puntos Canjeados:' || l_Puntos_Canjeados;
        Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => l_Dbg_Mensaje);
        --  IF l_trama_dv.subtrama_dv1(l_itm).puntos_asignados = 'S' and l_puntos_canjeados  > 0 THEN
        l_Dbg_Mensaje := 'LLamar a scfr_trx_puntos_pk.registra_rev';
        --        Scfr_Trx_Puntos_Pk.Registra_Rev(p_Party_Id           => NULL --p_transaccion.trama_boc.party_id
        --                                       ,p_Rut_Titular        => p_Transaccion.Rut_Titular
        --                                       ,p_Codigo_Tx          => p_Transaccion.Codigo_Tx
        --                                       ,p_Codigo_Tx_Original => l_Codigo_Tx_Relacion
        --                                       ,p_Numero_Docto       => l_Folio_Anu
        --                                       ,p_Empresa            => p_Transaccion.Trama_Pos.Empresa
        --                                       ,p_Cadena             => p_Transaccion.Trama_Pos.Cadena
        --                                       ,p_Fecha              => p_Transaccion.Fecha_Tx
        --                                       ,p_Vendedor           => p_Transaccion.Trama_Pos.Usuario_Responsable
        --                                       ,p_Local              => p_Transaccion.Trama_Pos.Local
        --                                       ,p_Fecha_Venta        => l_Fecha_Tx_Relacion
        --                                       ,p_Local_Venta        => l_Local_Tx_Relacion
        --                                       ,x_Cod_Error          => x_Cod_Error
        --                                       ,x_Msg_Error          => x_Msg_Error);
        --    END IF;
        IF Nvl(x_Cod_Error
              ,0) != 0 THEN
          RAISE l_Error_Controlado;
        END IF;
      END IF;
    END LOOP;
    --//--------------------------------------------------------------------------\\
    --// C_BRIONES 07/06/2013 17:49 REP. MANTIS 3365                              \\
    --// Se cambia Consulta pra ejecutar Update_Codigo_Cotizacion                 \\
    --//-----------------------------------------------------------------Inicio---\\
    
    --------------------------------------------------------
    -- VEAR Se modifica para poder enviar el numero de orden de oms 
    --------------------------------------------------------
    IF l_Trama_Dv.Ot is not null THEN
    --IF To_Number(Nvl(TRIM(l_Trama_Dv.Ot),'0')) > 0 THEN
      l_Codigo_Tx   := p_Transaccion.Trama_Pos.Sistema || p_Transaccion.Trama_Pos.Funcion || p_Transaccion.Trama_Pos.Secuencia_c;
      l_Dbg_Mensaje := 'LLamar a update_codigo_cotizacion';
      Update_Codigo_Cotizacion(l_Trama_Dv.Ot
                              ,p_Transaccion.Codigo_Tx
                              ,l_Codigo_Tx
                              ,x_Cod_Error
                              ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) <> 0 THEN
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
        x_Cod_Error := 0;
        x_Msg_Error := '';
      END IF;
    END IF;
    x_Trama_Dv := l_Trama_Dv;
    x_Trama_Cv := l_Trama_Cv;
    /*********************************************/ --excedente medio pago todas las isapres
    BEGIN
      SELECT a.Folio_Dicc
            ,b.Codigo_Autorizacion_Ext
            ,b.Comercio
            ,b.Rut
            ,TRIM(Substr(b.Consulta
                        ,Instr(b.Consulta
                              ,'|'
                              ,1
                              ,11) + 1
                        ,Instr(b.Consulta
                              ,'|'
                              ,1
                              ,12) - Instr(b.Consulta
                                          ,'|'
                                          ,1
                                          ,11) - 1)) Tipo_Docto
        INTO l_Id_Tx
            ,l_Id_Dev_Tx
            ,l_Comercio
            ,l_Rut_Exc
            ,l_Tipo_Doc_Ine
        FROM Scfr_Log_Autorizacion_Mdp b
            ,Scfr_Mov_Documentos_Txs   a
       WHERE a.Txo_Correlativo_Tx = l_Trama_Dv.Correlativo_Tx_Asociado
         AND a.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
         AND a.Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
         AND a.Loc_Local = l_Trama_Dv.Local
         AND a.Tmo_Movimiento IN ('VENEXC'
                                 ,'VENGUI')
         AND b.Codigo_Autorizacion_Fcv = a.Folio_Dicc
         AND b.Tipo_Operacion = 'INE';
    EXCEPTION
      WHEN OTHERS THEN
        l_Id_Tx     := 0;
        l_Id_Dev_Tx := 0;
    END;
    BEGIN
      SELECT a.Attribute1
            ,a.Attribute2
            ,a.Attribute3
        INTO l_Rut_Proveedor
            ,l_Origen
            ,l_Canal
        FROM Scfr_Comn_Externa a
       WHERE a.Proceso = 'EXCEDENTE_MDP'
         AND a.Empresa_Que_Autoriza = l_Comercio;
    EXCEPTION
      WHEN OTHERS THEN
        l_Rut_Proveedor := NULL;
        l_Origen        := NULL;
        l_Canal         := NULL;
    END;
    BEGIN
      SELECT 'SI'
        INTO l_Rev_Enviada
        FROM Scfr_Log_Autorizacion_Mdp b
       WHERE b.Codigo_Autorizacion_Fcv = l_Id_Tx
         AND b.Tipo_Operacion = 'REV'
         AND b.Codigo_Resultado = '0';
    EXCEPTION
      WHEN OTHERS THEN
        l_Rev_Enviada := 'NO';
    END;
    IF l_Id_Tx <> 0 AND
       l_Rev_Enviada = 'NO' THEN
      l_Dbg_Mensaje  := 'LLamar a Pkg_Excedentes_Mp.Proc_Anulacion_Excendentes';
      l_Fecha_Inicio := SYSDATE;
      BEGIN
        SELECT a.Doc_Interno1
          INTO l_Tipo_Doc
          FROM Scfr_Comercios_Doc a
         WHERE a.Comercio = l_Comercio
           AND a.Cadena = p_Transaccion.Trama_Pos.Empresa
           AND a.Doc_Externo = l_Tipo_Doc_Ine;
      EXCEPTION
        WHEN OTHERS THEN
          l_Tipo_Doc := 1;
      END;
      --//--------------------------------------------------------------------------\\
      --// CBR 03/27/2020 6:29PM                                                    \\
      --// Rescato el folio de venta (vengui/venbol)                                \\
      --//-----------------------------------------------------------------Inicio---\\
      BEGIN
        SELECT Folio
          INTO l_Folio_Docto_Venta
          FROM Scfr_Mov_Documentos_Txs
         WHERE Txo_Correlativo_Tx = l_Trama_Dv.Correlativo_Tx_Asociado
           AND Tmo_Movimiento IN ('VENBOL'
                                 ,'VENGUI')
           AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
           AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
           AND Loc_Local = l_Trama_Dv.Local;
      EXCEPTION
        WHEN OTHERS THEN
          l_Folio_Docto_Venta := 0;
      END;
      --//-----------------------------------------------------------------Termino--\\
      BEGIN
        -- Crea_Lst('LOG_EXC ' || l_Id_Tx || '.TXT','ANULA ENVIADO ====> ' || l_Consulta);
        l_Consulta := p_Transaccion.Trama_Pos.Empresa || '|' || p_Transaccion.Trama_Pos.Cadena || '|' || p_Transaccion.Trama_Pos.Local || '|' ||
                      l_Comercio || '|' || l_Rut_Proveedor || '|' || l_Rut_Exc || '|' || l_Id_Tx || '|' || l_Id_Dev_Tx || '|' || l_Tipo_Doc || '|' ||
                      l_Folio_Docto_Venta || '|' || l_Origen || '|' || l_Canal;
        Pkg_Excedentes_Mp.Proc_Anulacion_Excendentes(p_Empresa       => p_Transaccion.Trama_Pos.Empresa
                                                    ,p_Cadena        => p_Transaccion.Trama_Pos.Cadena
                                                    ,p_Local         => p_Transaccion.Trama_Pos.Local
                                                    ,p_Comercio      => l_Comercio
                                                    ,p_Fecha         => SYSDATE
                                                    ,p_Rut_Proveedor => l_Rut_Proveedor
                                                    ,p_Rut_Cliente   => l_Rut_Exc
                                                    ,p_Id_Tx         => l_Id_Tx
                                                    ,p_Id_Dev_Tx     => l_Id_Dev_Tx
                                                    ,p_Tipo_Doc      => l_Tipo_Doc
                                                    ,p_Folio         => l_Folio_Docto_Venta
                                                    ,p_Origen        => l_Origen
                                                    ,p_Canal         => l_Canal
                                                    ,x_Respuesta     => l_Cod_Rev
                                                    ,x_Cod_Error     => l_Cod_Error
                                                    ,x_Des_Error     => l_Msg_Error);
      
        l_Respuesta := l_Cod_Rev || '|' || l_Cod_Error || '|' || l_Msg_Error;
        -- Crea_Lst('LOG_EXC ' || l_Id_Tx || '.TXT','ANULA RESPUESTA ====> ' || l_Respuesta);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      l_Dbg_Mensaje := 'LLamar a Log_Autext() --> Pkg_Excedentes_Mp.Proc_Anulacion_Excendentes()';
      Log_Autext(p_Proceso                 => l_Comercio
                ,p_Tipo_Operacion          => 'REV'
                ,p_Fecha_Autorizacion      => l_Fecha_Inicio
                ,p_Fecha_Confirmacion      => SYSDATE
                ,p_Codigo_Resultado        => l_Cod_Error
                ,p_Codigo_Autorizacion_Fcv => l_Id_Tx
                ,p_Codigo_Autorizacion_Ext => l_Cod_Rev
                ,p_Consulta                => l_Consulta
                ,p_Respuesta               => l_Respuesta
                ,p_Glosa_Respuesta         => 'DV-Resp Anulaion Excedente ' || SQLERRM
                ,p_Rut                     => p_Transaccion.Rut_Titular
                ,p_Local                   => p_Transaccion.Trama_Pos.Local
                ,x_Cod_Error               => l_Cod_Error
                ,x_Msg_Error               => l_Msg_Error);
    END IF;
    /*********************************************/
    --//-----------------------------------------------------------------Termino--\\
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Trama DV resuelta correctamente');
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  FUNCTION Trama_Dv_Prepara(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,l_Trama_Vt    IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vt
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv IS
    CURSOR c_Doctos_Emitidos(p_Codigo_Tx IN NUMBER) IS
      SELECT Secuencia
            ,Tmo_Movimiento
            ,Dfi_Numero_Asignacion
            ,Substr(Anulado
                   ,1
                   ,1) Anulado
            ,Folio
            ,Tipo_Dicc
            ,Folio_Dicc
            ,Monto
            ,Iva
            ,Substr(Puntos_Asignados
                   ,1
                   ,1) Puntos_Asignados
            ,Tipo_Distribucion
            ,Pin_Ot_Recetario
            ,Campana
            ,Documento_Fiscal
            ,Sec_Financiamiento
            ,Afecto
            ,Exento
            ,To_Number(Decode(Periodo_Facturacion
                             ,NULL
                             ,'0'
                             ,Periodo_Facturacion)) Periodo_Facturacion
        FROM Scfr_Mov_Documentos_Txs
       WHERE Txo_Codigo_Tx = p_Codigo_Tx;
    CURSOR c_Tx_Relacionadas(p_Codigo_Tx IN NUMBER) IS
      SELECT Trx.Correlativo_Tx
            ,Mtr.Motivo
        FROM Scfr_Mov_Transacciones   Trx
            ,Scfr_Mov_Tx_Relacionadas Mtr
       WHERE Trx.Codigo_Tx = Mtr.Txo_Codigo_Tx_Relacionado
         AND Mtr.Txo_Codigo_Tx = p_Codigo_Tx;
    l_Trama_Dv         Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv;
    l_Codigo_Tx_Rel    NUMBER;
    l_Itm              NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_dv_prepara';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    -- obtiene datos del beneficiario desde la transaccion original
    BEGIN
      l_Dbg_Mensaje := 'Obtener ID de la transacccion';
      /*
      select txo_codigo_tx
        into p_transaccion.codigo_tx
        from scfr_mov_documentos_txs mdo
       where tmo_movimiento = l_trama_vt.tipo_movimiento_hijo
         and folio          = l_trama_vt.folio
         and loc_local      = l_trama_vt.local;
      */
      SELECT Mdo.Txo_Codigo_Tx
        INTO p_Transaccion.Codigo_Tx
        FROM Scfr_Mov_Documentos_Txs Mdo
            ,Scfr_Mov_Transacciones  Mt
       WHERE Mdo.Tmo_Movimiento = l_Trama_Vt.Tipo_Movimiento_Hijo
         AND Mdo.Folio = l_Trama_Vt.Folio
         AND Mdo.Loc_Local = l_Trama_Vt.Local
         AND Mdo.Txo_Codigo_Tx = Mt.Codigo_Tx
         AND Mt.Fecha_Tx >= Scfr_Trx_Util_Pk.Get_Sysdate() - 90;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN l_Trama_Dv;
    END;
    l_Dbg_Mensaje := 'Obtener datos desde la tabla SCFR_MOV_TRANSACCIONES para la trama DV';
    SELECT Correlativo_Tx
          ,Pos_Tipo_Transaccion
          ,Tmo_Movimiento_Padre
          ,To_Number(To_Char(Fecha_Tx
                            ,'yyyymmdd'))
          ,To_Number(To_Char(Fecha_Tx
                            ,'hh24miss'))
          ,Cot_Cotizacion
          ,Pin_Transaccion
          ,Numero_Preventa
          ,Loc_Local
          ,Agente_Ddo
          ,Rut_Agente_Ddo
          ,Dv_Agente_Ddo
          ,Num_Service_Request
          ,Txo_Codigo_Tx_Relacionado
          ,Sec_Recaudacion
          ,Pt_Party_Id_Titular
          ,Rut_Titular
          ,Dv_Titular
          ,Cuadrar_Transacciones
          ,Docs_Emitir_Liq_Pag
          ,Docs_Emitir_Liq_Emp
          ,Autorizacion_Cnv_Ext
           --, transaccion_manual
          ,Linea
          ,Supervisor
          ,Rut_Supervisor
          ,Tipo_Deducible
          ,Monto_Deducible
          ,Valor_Moneda
          ,Tipo_Moneda
          ,Indicadores_Tx
          ,Reg_Electronico
      INTO l_Trama_Dv.Correlativo_Tx
          ,l_Trama_Dv.Tipo_Tx
          ,l_Trama_Dv.Tipo_Movimiento_Padre
          ,l_Trama_Dv.Fecha
          ,l_Trama_Dv.Hora_Venta
          ,l_Trama_Dv.Numero_Cotizacion
          ,l_Trama_Dv.Pin_Transaccion
          ,l_Trama_Dv.Numero_Preventa
          ,l_Trama_Dv.Local
          ,l_Trama_Dv.Codigo_Agente_Desp_Domicilio
          ,l_Trama_Dv.Rut_Agente_Despacho_Domicilio
          ,l_Trama_Dv.Dv_Rut_Agente_Desp_Domicilio
          ,l_Trama_Dv.Numero_Service_Request_Ddo
          ,l_Codigo_Tx_Rel
          ,l_Trama_Dv.Recaudacion_Relacionada
          ,p_Transaccion.Trama_Boc.Party_Id
          ,p_Transaccion.Rut_Titular
          ,p_Transaccion.Dv_Rut_Titular
          ,l_Trama_Dv.Cuadra_Transaccion
          ,l_Trama_Dv.Documento_Liquidacion_Pago
          ,l_Trama_Dv.Documento_Liquidacion_Empresa
          ,l_Trama_Dv.Codigo_Autorizacion_Externo
           --, l_trama_dv.transaccion_manual
          ,l_Trama_Dv.Movimiento_Enlinea
          ,l_Trama_Dv.Supervisor
          ,l_Trama_Dv.Rut_Supervisor
          ,l_Trama_Dv.Tipo_Deducible
          ,l_Trama_Dv.Monto_Deducible
          ,l_Trama_Dv.Valor_Moneda
          ,l_Trama_Dv.Tipo_Moneda
          ,l_Trama_Dv.Indicadores_Tx
          ,l_Trama_Dv.Documento_Electronico
      FROM Scfr_Mov_Transacciones
     WHERE Codigo_Tx = p_Transaccion.Codigo_Tx;
    l_Trama_Dv.Correlativo_Tx_Asociado := 0;
    IF l_Codigo_Tx_Rel IS NOT NULL THEN
      BEGIN
        SELECT Correlativo_Tx INTO l_Trama_Dv.Correlativo_Tx_Asociado FROM Scfr_Mov_Transacciones WHERE Codigo_Tx = l_Codigo_Tx_Rel;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
    l_Dbg_Mensaje := 'Obtener rut del local del documento original';
    BEGIN
      l_Trama_Dv.Rut_Empresa := Scfr_Trx_Util_Pk.Devuelve_Rut_Local(p_Transaccion.Trama_Pos.Empresa
                                                                   ,p_Transaccion.Trama_Pos.Cadena
                                                                   ,l_Trama_Vt.Local);
    EXCEPTION
      WHEN OTHERS THEN
        l_Trama_Dv.Rut_Empresa := 0;
    END;
    l_Dbg_Mensaje := 'Obtener datos desde la tabla SCFR_MOV_DOCUMENTOS_TXS para la subtrama DV1 (documentos emitidos)';
    l_Itm         := 1;
    FOR r_Doctos_Emitidos IN c_Doctos_Emitidos(p_Transaccion.Codigo_Tx)
    LOOP
      l_Trama_Dv.Subtrama_Dv1(l_Itm).Secuencia_b := r_Doctos_Emitidos.Secuencia;
      l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Movimiento_Hijo := r_Doctos_Emitidos.Tmo_Movimiento;
      l_Trama_Dv.Subtrama_Dv1(l_Itm).Numero_Asignacion := r_Doctos_Emitidos.Dfi_Numero_Asignacion;
      l_Trama_Dv.Subtrama_Dv1(l_Itm).Anulado := r_Doctos_Emitidos.Anulado;
      l_Trama_Dv.Subtrama_Dv1(l_Itm).Folio := r_Doctos_Emitidos.Folio;
      l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Dicc := r_Doctos_Emitidos.Tipo_Dicc;
      l_Trama_Dv.Subtrama_Dv1(l_Itm).Folio_Dicc := r_Doctos_Emitidos.Folio_Dicc;
      l_Trama_Dv.Subtrama_Dv1(l_Itm).Total_Iva_Incluido := r_Doctos_Emitidos.Monto;
      l_Trama_Dv.Subtrama_Dv1(l_Itm).Iva := r_Doctos_Emitidos.Iva;
      l_Trama_Dv.Subtrama_Dv1(l_Itm).Puntos_Asignados := r_Doctos_Emitidos.Puntos_Asignados;
      l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Distribucion := r_Doctos_Emitidos.Tipo_Distribucion;
      l_Trama_Dv.Subtrama_Dv1(l_Itm).Campana := r_Doctos_Emitidos.Campana;
      l_Trama_Dv.Subtrama_Dv1(l_Itm).Documento_Fiscal := r_Doctos_Emitidos.Documento_Fiscal;
      l_Trama_Dv.Subtrama_Dv1(l_Itm).Secuencia_Financiamiento := r_Doctos_Emitidos.Sec_Financiamiento;
      l_Trama_Dv.Subtrama_Dv1(l_Itm).Afecto := r_Doctos_Emitidos.Afecto;
      l_Trama_Dv.Subtrama_Dv1(l_Itm).Exento := r_Doctos_Emitidos.Exento;
      l_Trama_Dv.Subtrama_Dv1(l_Itm).Periodo_Facturacion := r_Doctos_Emitidos.Periodo_Facturacion;
      IF l_Trama_Dv.Ot IS NULL THEN
        l_Trama_Dv.Ot := r_Doctos_Emitidos.Pin_Ot_Recetario;
      END IF;
      l_Itm := l_Itm + 1;
    END LOOP;
    l_Trama_Dv.Documentos_Emitidos := l_Trama_Dv.Subtrama_Dv1.Count;
    l_Dbg_Mensaje                  := 'Obtener datos desde la tabla SCFR_MOV_TX_RELACIONADAS para la subtrama DV2 (tx relacionadas)';
    l_Itm                          := 1;
    FOR r_Tx_Relacionadas IN c_Tx_Relacionadas(p_Transaccion.Codigo_Tx)
    LOOP
      l_Trama_Dv.Subtrama_Dv2(l_Itm).Correlativo_Tx := r_Tx_Relacionadas.Correlativo_Tx;
      l_Trama_Dv.Subtrama_Dv2(l_Itm).Motivo := r_Tx_Relacionadas.Motivo;
      l_Itm := l_Itm + 1;
    END LOOP;
    l_Trama_Dv.Tx_Relacionadas := l_Trama_Dv.Subtrama_Dv2.Count;
    RETURN l_Trama_Dv;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
    
  END;

  PROCEDURE Rebaja_Puntos_Mcv_Desc(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                  ,x_Cod_Error   OUT NUMBER
                                  ,x_Msg_Error   OUT NUMBER) IS
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.Rebaja_Puntos_MCV_Desc';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    --
    l_Monto_Descuento   NUMBER;
    l_Puntos_Disponible NUMBER;
    l_Party_Id          NUMBER;
    l_Folio_Docto       NUMBER;
    l_Campana_Puntos    NUMBER;
    l_Party_Id_Rel      NUMBER;
    l_Dias_Vcto_Ptos    NUMBER;
    l_Id_Relacion       NUMBER;
    l_Id_Pto            NUMBER;
    l_Desc_Aplicado     NUMBER;
  BEGIN
    x_Cod_Error := 0;
    BEGIN
      SELECT 1
        INTO l_Desc_Aplicado
        FROM Scfr_Txs_Puntos
       WHERE Txo_Codigo_Tx = p_Transaccion.Codigo_Tx
         AND Rownum = 1;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Desc_Aplicado := 0;
    END;
    IF l_Desc_Aplicado = 1 THEN
      RAISE l_Error_Controlado;
    END IF;
    -- Obtiene descuento entregado en la venta, asociados a campana de Puntos(DPM: descuento puntos MCV)
    l_Dbg_Mensaje := 'Obtener puntos monto descuento en venta';
    BEGIN
      SELECT Nvl(SUM(Des.Monto)
                ,0)
        INTO l_Monto_Descuento
        FROM Scfr_Mov_Descuentos_Productos Des
            ,Scfr_Campanas                 Cam
            ,Scfr_Condiciones              Con
       WHERE Des.Txo_Codigo_Tx = p_Transaccion.Codigo_Tx
         AND Scfr_Trx_Util_Pk.Get_Sysdate() BETWEEN Trunc(Cam.Fecha_Inicio) AND Cam.Fecha_Termino + 1
         AND Des.Campana_Convenio = Cam.Campana
         AND Cam.Campana = Con.Cam_Campana
         AND Con.Tipo_Condicion = 'DPM'
         AND Con.Dentro_Intervalo = 'SI';
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Monto_Descuento := 0;
    END;
    IF (l_Monto_Descuento > 0) THEN
      l_Dbg_Mensaje       := 'Obtener puntos DIVEPU conjelados';
      l_Dias_Vcto_Ptos    := Scfr_Trx_Util_Pk.Det_Valor_Parametro_Por_Cod('DIVEPU');
      l_Puntos_Disponible := Scfr_Trx_Fid_Pk.Puntos_Disponibles(p_Party_Id    => NULL
                                                               ,p_Rut_Titular => p_Transaccion.Rut_Titular
                                                               ,p_Tipo_Puntos => 'I');
      IF (l_Puntos_Disponible = 0) THEN
        -- En caso de no tener puntos congelados, se revisa cuenta corriente vigente
        l_Dbg_Mensaje       := 'Obtener puntos DIVEPU activos';
        l_Puntos_Disponible := Scfr_Trx_Fid_Pk.Puntos_Disponibles(p_Party_Id    => NULL
                                                                 ,p_Rut_Titular => p_Transaccion.Rut_Titular
                                                                 ,p_Tipo_Puntos => 'T');
      END IF; -- if (l_puntos_disponible = 0) then
      -- Si el total de puntos es mayor a Cero, se activan para realizar el canje.
      IF (l_Puntos_Disponible > 0) THEN
        l_Party_Id     := Scfr_Trx_Util_Pk.Obtiene_Party_Id(To_Number(p_Transaccion.Rut_Titular));
        l_Dbg_Mensaje  := 'Buscar relacion ES_FIDELIZADO ';
        l_Party_Id_Rel := Scfr_Trx_Util_Pk.Busca_Party_Id_Relacion(l_Party_Id
                                                                  ,Scfr_Trx_Util_Pk.Obtiene_Party_Id(Scfr_Trx_Util_Pk.Rut_Con_Org_Id(p_Transaccion.Trama_Pos.Empresa
                                                                                                                                    ,Scfr_Trx_Util_Pk.Instancia))
                                                                  ,'ES_FIDELIZADO'
                                                                  ,p_Transaccion.Trama_Pos.Empresa
                                                                  ,l_Id_Relacion);
        IF (Nvl(l_Party_Id_Rel
               ,0) <= 0) THEN
          BEGIN
            SELECT Party_Id
              INTO l_Party_Id_Rel
              FROM Scfr_Tmp_Clientes
             WHERE Rut = p_Transaccion.Rut_Titular
               AND Inscrito_Mas_Cruz_Verde = 'S';
          EXCEPTION
            WHEN No_Data_Found THEN
              l_Party_Id_Rel := -1;
          END;
        END IF; -- if (Nvl(l_Party_Id_Rel   ,0) > 0) then
        -- Actualiza Puntos Congelados para realizar la rebaja de los puntos
        -- activa puntos programa mcv antiguo.
        l_Dbg_Mensaje := 'Activa puntos programa MCV antiguo.';
        UPDATE Scfr_Txs_Puntos
           SET Estado_Registro = 'A'
         WHERE Rut_Titular = p_Transaccion.Rut_Titular
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Estado_Registro = 'P';
        l_Dbg_Mensaje := ' Ontiene numero de Folio';
        BEGIN
          SELECT Folio
            INTO l_Folio_Docto
            FROM Scfr_Mov_Documentos_Txs
           WHERE Tmo_Movimiento IN ('VENBOL'
                                   ,'VENFAC'
                                   ,'VENGUI')
             AND Txo_Codigo_Tx = p_Transaccion.Codigo_Tx
             AND Rownum = 1;
        EXCEPTION
          WHEN No_Data_Found THEN
            l_Folio_Docto := 0;
        END;
        l_Dbg_Mensaje    := 'Obtener campa?a generica de puntos';
        l_Campana_Puntos := Scfr_Trx_Gnc_Utl_Pk.Obtiene_Campana_Puntos(p_Transaccion.Trama_Pos.Empresa
                                                                      ,p_Transaccion.Trama_Pos.Cadena);
        l_Dbg_Mensaje    := 'LLamar a scfr_trx_puntos_pk.registra_can';
        Scfr_Trx_Puntos_Pk.Setea_Local_Trx(p_Transaccion.Trama_Pos.Local);
        l_Id_Pto      := Scfr_Trx_Puntos_Pk.Registra_Can(p_Party_Id     => NULL
                                                        , --p_transaccion.trama_boc.party_id
                                                         p_Rut_Titular  => p_Transaccion.Rut_Titular
                                                        ,p_Puntos       => l_Monto_Descuento
                                                        ,p_Codigo_Tx    => p_Transaccion.Codigo_Tx
                                                        ,p_Numero_Docto => l_Folio_Docto
                                                        ,p_Campana      => l_Campana_Puntos
                                                        ,p_Empresa      => p_Transaccion.Trama_Pos.Empresa
                                                        ,p_Cadena       => p_Transaccion.Trama_Pos.Cadena
                                                        ,p_Fecha        => p_Transaccion.Fecha_Tx
                                                        ,p_Vendedor     => p_Transaccion.Trama_Pos.Usuario_Responsable
                                                        ,p_Local        => p_Transaccion.Trama_Pos.Local
                                                        ,x_Cod_Error    => x_Cod_Error
                                                        ,x_Msg_Error    => x_Msg_Error);
        l_Dbg_Mensaje := 'Estado Original Cta Cte Pto(Segun MCV)';
        IF Nvl(l_Party_Id_Rel
              ,0) <= 0 THEN
          UPDATE Scfr_Txs_Puntos
             SET Estado_Registro = 'P'
           WHERE Rut_Titular = p_Transaccion.Rut_Titular
             AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
             AND Estado_Registro = 'A';
        END IF; --IF Nvl(l_Party_Id_Rel   ,0) <= 0 THEN
        --+
        IF Nvl(x_Cod_Error
              ,0) != 0 THEN
          RAISE l_Error_Controlado;
        END IF;
      END IF; -- if (l_puntos_disponible > 0) then
    END IF; -- if (l_monto_descuento > 0 ) then
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      l_Dbg_Mensaje := 'Estado Original Cta Cte Pto(Segun MCV)';
      IF Nvl(l_Party_Id_Rel
            ,0) <= 0 THEN
        UPDATE Scfr_Txs_Puntos
           SET Estado_Registro = 'P'
         WHERE Rut_Titular = p_Transaccion.Rut_Titular
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Estado_Registro = 'A';
      END IF; --IF Nvl(l_Party_Id_Rel   ,0) <= 0 THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  PROCEDURE Trama_Pm_Desctos_Aplicados(p_Transaccion      IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                      ,p_Trama_Pm         IN OUT Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pm
                                      ,p_Trama_Dv         IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                                      ,p_Codigo_Detalle   IN NUMBER
                                      ,p_Estado           IN VARCHAR2
                                      ,p_Tipo_Tx          IN VARCHAR2
                                      ,x_Puntos_Canjeados IN OUT Scfr_Trx_Gnc_Pk.Tab_Puntos_Canjeados
                                      ,x_Cod_Error        OUT NUMBER
                                      ,x_Msg_Error        OUT NUMBER) IS
    -- JRG 10072017 Inicio
    CURSOR c_Acumulacion_Automatica(p_Cam_Activacion NUMBER) IS
      SELECT Puf_Relacionado
        FROM Scfr_Campanas_Relacionadas
       WHERE Accion = 'ACU' -- rv_domain  fid.cg_ref_codes 'INSCRIPCION AUT. PSALUD'
         AND Cam_Campana_Activacion = p_Cam_Activacion
         AND Puf_Relacionado IS NOT NULL;
    -- JRG 10072017 Fin
  
    l_Itm NUMBER;
  
    l_Itm2 NUMBER;
  
    l_Itm3 NUMBER;
  
    l_Pos           NUMBER;
    l_Sec_Descuento NUMBER;
  
    l_Sec_Ciclo        VARCHAR2(3);
    l_Ciclo            NUMBER;
    l_Monto            NUMBER;
    l_Tot_Det          NUMBER;
    l_Folio_Docto      NUMBER;
    l_Posdesc          NUMBER;
    l_Totdesc          NUMBER;
    l_Id_Pto           NUMBER;
    l_Unid_Desc        NUMBER;
    l_String           VARCHAR2(1000);
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_pm_desctos_aplicados';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    --
    l_Resultado  NUMBER;
    l_Tipo_Mov   VARCHAR2(3);
    l_Cam_Inc    NUMBER;
    l_Ind_Salida BOOLEAN := FALSE;
    -- l_String     VARCHAR2(256);
    l_Salto_Item  NUMBER := 1;
    Cont          NUMBER := 0;
    l_Movdesc     NUMBER := 1;
    l_Lista_Lpc   NUMBER;
    l_Campana_Lpc NUMBER;
    -- JRG 10072017 Inicio
    l_Mov_Prod_Doc_Aux NUMBER;
    l_Tipo_Acum_Psalud VARCHAR2(3);
    l_Tipo_Tx          VARCHAR2(3);
    l_Folio_Docto_Ps   NUMBER;
    l_Signo_Acumula    NUMBER;
    l_Existe_Pin_Ot    NUMBER;
    l_Codigo_Tx        NUMBER;
    l_Lista_Alta_Cli   NUMBER;
    l_Convenio         VARCHAR2(50);
    
    -- INI JAGC NEC 20240909
    l_Valor_String VARCHAR2(100); 
    l_Valor_Evento   NUMBER; -- +Valor Evento Aplicado (Numerico 5)
    l_Tipo_Descuento VARCHAR2(2); -- +Tipo Descuento (Caracter 2)
    l_Id_Promocion   NUMBER; -- +Id Promocion (Numerico 10)
    l_Tipo_Promocion VARCHAR2(1); -- +Tipo Promocion (Caracter 1)
    l_Precio_Lista NUMBER;
    -- FIN JAGC NEC 20240909
    
  BEGIN
    x_Cod_Error := 0;
    IF p_Tipo_Tx = 'GNCU02' OR
       p_Tipo_Tx = 'GNCU06' THEN
      l_Movdesc := -1;
      l_Tipo_Tx := 'REV';
    ELSE
      l_Tipo_Tx := 'VEN';
    END IF;
    l_Dbg_Mensaje := 'Recorrer detalle de la subtrama PM2 (Descuentos Aplicados)';
    FOR l_Itm IN 1 .. p_Trama_Pm.Subtrama_Pm2.Count
    LOOP
      -- Obtiene id de del primer documentos en donde esta referenciado el producto
      l_Folio_Docto := Scfr_Trx_Gnc_Utl_Pk.Obtiene_Folio_Docto(p_Transaccion
                                                              ,p_Trama_Pm);
      -- Valida que el codigo de cupon sea un dato valido, sino asigna NULL.
      l_Dbg_Mensaje := 'Validar codigo de cupon';
      IF Nvl(Length(Ltrim(Rtrim(p_Trama_Pm.Subtrama_Pm2(l_Itm).Codigo_Cupon)))
            ,0) = 0 THEN
        p_Trama_Pm.Subtrama_Pm2(l_Itm).Codigo_Cupon := NULL;
      END IF;
      -- Suma puntos canjeados (Menos los descuentos autoliquidables)
      l_Dbg_Mensaje := 'Sumar los puntos canjeados (Menos los descuentos autoliquidables)';
      IF Ltrim(Rtrim(p_Trama_Pm.Subtrama_Pm2(l_Itm).Tipo_Aplicacion_Descuento)) = 'AC' AND
         p_Trama_Pm.Subtrama_Pm2(l_Itm).Puntos_Canjeados > 0 AND
         (p_Trama_Pm.Subtrama_Pm2(l_Itm).Descuento_Referencial = 'NO')
      -- estaba antes  p_trama_pm.producto != 801006 OR G_CODIGO_TRANSACCION != 'GNCU01'
       THEN
        -- Acumula puntos en arreglo por documento emitido (solo uno por producto)
        l_Totdesc := x_Puntos_Canjeados.Count;
        l_Posdesc := 0;
        FOR l_Itm3 IN 1 .. l_Totdesc
        LOOP
          IF x_Puntos_Canjeados(l_Itm3).Folio = l_Folio_Docto THEN
            l_Posdesc := l_Itm3;
            EXIT;
          END IF;
        END LOOP;
        IF l_Posdesc > 0 THEN
          x_Puntos_Canjeados(l_Posdesc).Total_Puntos := x_Puntos_Canjeados(l_Posdesc).Total_Puntos + p_Trama_Pm.Subtrama_Pm2(l_Itm).Puntos_Canjeados;
        ELSE
          x_Puntos_Canjeados(l_Totdesc + 1).Folio := l_Folio_Docto;
          x_Puntos_Canjeados(l_Totdesc + 1).Total_Puntos := p_Trama_Pm.Subtrama_Pm2(l_Itm).Puntos_Canjeados;
        END IF;
      END IF;
      -- En caso que campa?a no fue enviada desde el pos, se obtiene desde el cupon
      l_Dbg_Mensaje := 'Validar tipo de descuento';
      IF Upper(Ltrim(Rtrim(p_Trama_Pm.Subtrama_Pm2(l_Itm).Tipo_Descuento))) = 'CAM' THEN
        IF p_Trama_Pm.Subtrama_Pm2(l_Itm).Campana_o_Convenio IS NULL THEN
          -- Busca codigo de capa?a segun el codigo de cupon
          l_Dbg_Mensaje := 'Buscar codigo de campa?a';
          SELECT Cam_Campana
            INTO p_Trama_Pm.Subtrama_Pm2(l_Itm).Campana_o_Convenio
            FROM Scfr_Cupones
           WHERE Codigo_Cupon = p_Trama_Pm.Subtrama_Pm2(l_Itm).Codigo_Cupon;
          -- *
        ELSE
          -- JRG 09/03/2011 Baja automatica de clientes TCV en primera compra.
          ---Baja Cliente campana descuento primera compra --  Incentivo TCV.
          -- Obtiene si hay campanas activas
          BEGIN
            SELECT 1
              INTO l_Cam_Inc
              FROM Scfr_Listas_Clientes_Campanas Scfr_Listas_Clientes_Cam_Des
                  ,Scfr_Listas_Clientes_Campanas Scfr_Listas_Clientes_Cam_Inc
                  ,Scfr_Campanas
             WHERE (Scfr_Listas_Clientes_Cam_Des.Cam_Campana = p_Trama_Pm.Subtrama_Pm2(l_Itm).Campana_o_Convenio AND
                   Scfr_Campanas.Tipo_Campana = 'INC' AND
                   Trunc(Scfr_Listas_Clientes_Cam_Des.Fecha_Asociacion) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) AND
                   Trunc(Nvl(Scfr_Listas_Clientes_Cam_Des.Fecha_Termino
                             ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) AND
                   Trunc(Scfr_Listas_Clientes_Cam_Inc.Fecha_Asociacion) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) AND
                   Trunc(Nvl(Scfr_Listas_Clientes_Cam_Inc.Fecha_Termino
                             ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) AND
                   Trunc(Scfr_Campanas.Fecha_Inicio) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) AND
                   Trunc(Nvl(Scfr_Campanas.Fecha_Termino
                             ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()))
               AND ((Scfr_Listas_Clientes_Cam_Des.Sle_Listas_Clientes = Scfr_Listas_Clientes_Cam_Inc.Sle_Listas_Clientes) AND
                   (Scfr_Listas_Clientes_Cam_Inc.Cam_Campana = Scfr_Campanas.Campana))
               AND Rownum = 1;
          EXCEPTION
            WHEN No_Data_Found THEN
              l_Cam_Inc := 0;
          END;
          -- *
          IF (l_Cam_Inc = 1) THEN
            -- actualiza vigencia clientes.
            UPDATE Scfr_Deta_List_Clientes
               SET Fecha_Expiracion = Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) - 1
             WHERE Rut_Cliente = p_Transaccion.Rut_Titular
               AND EXISTS (SELECT 1
                      FROM Scfr_Campanas                 Sc
                          ,Scfr_Listas_Clientes_Campanas Slcc
                          ,Scfr_Listas_Clientes          Slc
                     WHERE Sc.Campana = p_Trama_Pm.Subtrama_Pm2(l_Itm).Campana_o_Convenio
                       AND Slc.Vigencia = 'SI'
                       AND Slc.Listas_Clientes = Scfr_Deta_List_Clientes.Sle_Listas_Clientes
                       AND (Trunc(Slc.Fecha_Creacion) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) AND
                           Trunc(Nvl(Slc.Fecha_Termino
                                     ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) AND
                           Trunc(Slcc.Fecha_Asociacion) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) AND
                           Trunc(Nvl(Slcc.Fecha_Termino
                                     ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()))
                       AND ((Sc.Campana = Slcc.Cam_Campana) AND (Slcc.Sle_Listas_Clientes = Slc.Listas_Clientes)));
          END IF; -- if (l_cam_inc = 1) then
        
          -- Carga cliente en lista de negaion para
          -- Test gratis de colesterol
          BEGIN
            SELECT To_Number(Rv_High_Value)
              INTO l_Lista_Alta_Cli
              FROM Cg_Ref_Codes
             WHERE Rv_Domain = 'TEST COLESTEROL'
               AND To_Number(TRIM(Rv_Low_Value)) = p_Trama_Pm.Subtrama_Pm2(l_Itm).Campana_o_Convenio
               AND Rownum = 1;
          EXCEPTION
            WHEN OTHERS THEN
              l_Lista_Alta_Cli := NULL;
          END;
          IF (l_Lista_Alta_Cli IS NOT NULL) THEN
            IF (l_Tipo_Tx = 'VEN') THEN
              BEGIN
                INSERT INTO Scfr_Deta_List_Clientes
                  (Sle_Listas_Clientes
                  ,Pt_Party_Id_Cliente
                  ,Fecha_Carga
                  ,Fecha_Expiracion
                  ,Rut_Cliente
                  ,Dv_Cliente)
                VALUES
                  (l_Lista_Alta_Cli
                  ,p_Transaccion.Trama_Boc.Party_Id
                  ,SYSDATE
                  ,NULL
                  ,p_Transaccion.Rut_Titular
                  ,p_Transaccion.Dv_Rut_Titular);
              
                INSERT INTO Scfr_Log_Debug
                VALUES
                  (Scfr_Log_Debug_s.Nextval
                  ,'TEST.COLESTEROL'
                  ,SYSDATE
                  ,'10000'
                  ,'Elimina scfr_deta_list_clientes RUT => ' || p_Transaccion.Rut_Titular
                  ,'Rut Cliente  =>' || p_Transaccion.Rut_Titular
                  ,p_Transaccion.Trama_Pos.Local
                  ,p_Transaccion.Codigo_Tx);
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            ELSE
              -- en el caso de reversa, clientes es eliminado de la lista de negacion de la campana
              DELETE FROM Scfr_Deta_List_Clientes
               WHERE Sle_Listas_Clientes = l_Lista_Alta_Cli
                 AND Rut_Cliente = p_Transaccion.Rut_Titular;
              INSERT INTO Scfr_Log_Debug
              VALUES
                (Scfr_Log_Debug_s.Nextval
                ,'TEST.COLESTEROL'
                ,SYSDATE
                ,'20000'
                ,'Elimina scfr_deta_list_clientes RUT => ' || p_Transaccion.Rut_Titular
                ,'Rut Cliente  =>' || p_Transaccion.Rut_Titular
                ,p_Transaccion.Trama_Pos.Local
                ,p_Transaccion.Codigo_Tx);
            END IF; -- if (l_Tipo_Tx = 'VEN') then
          
          END IF; -- if (  L_lista_alta_cli is not null) then
        
          -- FID JRG 09/03/2011 Baja automatica de clientes TCV en primera compra.
          -- Baja del clientes par descuento primera compra nuevo programa de puntos.
          -- JRG 11-12-2015
          BEGIN
            SELECT 1
              INTO l_Campana_Lpc
              FROM Scfr_Condiciones
             WHERE Cam_Campana = p_Trama_Pm.Subtrama_Pm2(l_Itm).Campana_o_Convenio
               AND Tipo_Condicion = 'EVE'
               AND Restriccion_Minima = 1
               AND Restriccion_Maxima = 1
               AND Rownum = 1;
          EXCEPTION
            WHEN No_Data_Found THEN
              l_Campana_Lpc := 0;
          END;
          IF (l_Campana_Lpc = 1) THEN
            -- actualiza vigencia clientes.
            UPDATE Scfr_Deta_List_Clientes
               SET Fecha_Expiracion = Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) - 1
             WHERE Rut_Cliente = p_Transaccion.Rut_Titular
               AND EXISTS (SELECT 1
                      FROM Scfr_Campanas                 Sc
                          ,Scfr_Listas_Clientes_Campanas Slcc
                          ,Scfr_Listas_Clientes          Slc
                     WHERE Sc.Campana = p_Trama_Pm.Subtrama_Pm2(l_Itm).Campana_o_Convenio
                       AND Slc.Vigencia = 'SI'
                       AND Slc.Listas_Clientes = Scfr_Deta_List_Clientes.Sle_Listas_Clientes
                       AND (Trunc(Slc.Fecha_Creacion) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) AND
                           Trunc(Nvl(Slc.Fecha_Termino
                                     ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) AND
                           Trunc(Slcc.Fecha_Asociacion) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) AND
                           Trunc(Nvl(Slcc.Fecha_Termino
                                     ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()))
                       AND ((Sc.Campana = Slcc.Cam_Campana) AND (Slcc.Sle_Listas_Clientes = Slc.Listas_Clientes)));
          END IF;
          -- Valida si hay campanas primera compra activa
          -- Fin Baja del clientes par descuento primera compra nuevo programa de puntos.
          -- --------------------------------------------------------------------------------------
          -- JRG 07/07/2017 Inscripcion automatica y programa 2 y acumulacion de unidades.
          -- --------------------------------------------------------------------------------------
          FOR r_Acumulacion_Automatica IN c_Acumulacion_Automatica(p_Trama_Pm.Subtrama_Pm2(l_Itm).Campana_o_Convenio)
          LOOP
          
            l_Dbg_Mensaje := 'Obtener Correlativo productos documentos';
            BEGIN
              SELECT Pd.Mov_Productos_Documentos
                INTO l_Mov_Prod_Doc_Aux
                FROM Scfr_Mov_Productos_Documentos Pd
                    ,Scfr_Mov_Transacciones        Mt
               WHERE Pd.Txo_Codigo_Tx = Mt.Codigo_Tx
                 AND Mt.Correlativo_Tx = p_Trama_Dv.Correlativo_Tx_Asociado
                 AND Mt.Loc_Local = p_Trama_Dv.Local
                 AND Mt.Tmo_Movimiento_Padre = p_Trama_Dv.Tipo_Movimiento_Padre
                 AND Pd.Pro_Codigo_Interno = p_Trama_Pm.Producto
                 AND Pd.Impreso_En_Boleta = 'SI';
            EXCEPTION
              WHEN No_Data_Found THEN
                l_Mov_Prod_Doc_Aux := 0;
              WHEN OTHERS THEN
                l_Mov_Prod_Doc_Aux := -1; -- le indica a programa de salud que id de mov_productos_documentos no fue encontrado.
            END;
            IF p_Trama_Dv.Movimiento_Enlinea = 'SI' THEN
              l_Tipo_Acum_Psalud := 'AOL';
            ELSE
              l_Tipo_Acum_Psalud := 'OLB';
            END IF;
          
            IF (l_Tipo_Tx = 'REV') THEN
              l_Signo_Acumula  := -1;
              l_Dbg_Mensaje    := 'Obtiene folio asociado al programa de salud';
              l_Folio_Docto_Ps := Scfr_Trx_Gnc_Utl2_Pk.Obtiene_Folio_Psalud(p_Trama_Dv
                                                                           ,p_Transaccion.Trama_Pos.Local
                                                                           ,r_Acumulacion_Automatica.Puf_Relacionado);
            ELSE
              l_Signo_Acumula  := 1;
              l_Folio_Docto_Ps := l_Folio_Docto;
            END IF;
          
            l_Dbg_Mensaje := 'Ejecutar scfr_pprog_salud_pk.puntos_ps_GeoCom';
            Scfr_Pprog_Salud_Pk.Puntos_Ps_Geocom(Pmov_Movimientos   => l_Mov_Prod_Doc_Aux
                                                ,Pparty_Id          => p_Transaccion.Trama_Boc.Party_Id
                                                ,Puso_Frecuente     => r_Acumulacion_Automatica.Puf_Relacionado
                                                ,Pcantidad          => p_Trama_Pm.Subtrama_Pm2(l_Itm).Unidades_Beneficio
                                                ,Pcant_Prog_Salud   => p_Trama_Pm.Subtrama_Pm2(l_Itm).Unidades_Beneficio * l_Signo_Acumula
                                                ,Prut_Cliente       => p_Transaccion.Rut_Titular
                                                ,Pdv_Rut_Cliente    => p_Transaccion.Dv_Rut_Titular
                                                ,Ptipo_Tx           => l_Tipo_Tx
                                                ,Pfecha_Tx          => To_Date(p_Trama_Dv.Fecha
                                                                              ,'yyyymmdd')
                                                ,Pcanal             => 'POS'
                                                ,Pdetalle_Descuento => '00' -- indica que no hubo descuentos
                                                ,Pfolio             => l_Folio_Docto_Ps
                                                ,Plocal             => p_Transaccion.Trama_Pos.Local
                                                ,Ppro_Codigo_Tx     => p_Trama_Pm.Producto
                                                ,Ptipo_Acum_Psalud  => l_Tipo_Acum_Psalud
                                                ,Pfecha_Venta       => p_Transaccion.Fecha_Tx_Origen
                                                ,Plocal_Venta       => p_Transaccion.Local_Origen
                                                ,Pcod_Error         => x_Cod_Error
                                                ,Pmsg_Error         => x_Msg_Error);
          
          END LOOP; -- for r_ins_automatica in c_ins_automatica(l_Trama_Pb.Uso_Frecuente) loop
        END IF;
        IF p_Trama_Pm.Subtrama_Pm2(l_Itm).Puntos_Canjeados > 0 AND
            Ltrim(Rtrim(p_Trama_Pm.Subtrama_Pm2(l_Itm).Tipo_Aplicacion_Descuento)) = 'AP' AND
            Nvl(p_Transaccion.Trama_Boc.Party_Id
               ,0) != 0 AND
            (p_Trama_Pm.Subtrama_Pm2(l_Itm).Descuento_Referencial = 'NO')
        --estaba antes  p_trama_pm.producto != 801006 OR G_CODIGO_TRANSACCION != 'GNCU01' )
         THEN
          l_Dbg_Mensaje := 'LLamar a scfr_trx_puntos_pk.registra_can';
          Scfr_Trx_Puntos_Pk.Setea_Local_Trx(p_Transaccion.Trama_Pos.Local);
          l_Id_Pto := Scfr_Trx_Puntos_Pk.Registra_Can(p_Party_Id     => NULL --p_transaccion.trama_boc.party_id
                                                     ,p_Rut_Titular  => p_Transaccion.Rut_Titular
                                                     ,p_Puntos       => p_Trama_Pm.Subtrama_Pm2(l_Itm).Puntos_Canjeados
                                                     ,p_Codigo_Tx    => p_Transaccion.Codigo_Tx
                                                     ,p_Numero_Docto => l_Folio_Docto
                                                     ,p_Campana      => p_Trama_Pm.Subtrama_Pm2(l_Itm).Campana_o_Convenio
                                                     ,p_Empresa      => p_Transaccion.Trama_Pos.Empresa
                                                     ,p_Cadena       => p_Transaccion.Trama_Pos.Cadena
                                                     ,p_Fecha        => p_Transaccion.Fecha_Tx
                                                     ,p_Vendedor     => p_Transaccion.Trama_Pos.Usuario_Responsable
                                                     ,p_Local        => p_Transaccion.Trama_Pos.Local
                                                     ,x_Cod_Error    => x_Cod_Error
                                                     ,x_Msg_Error    => x_Msg_Error);
          IF Nvl(x_Cod_Error
                ,0) != 0 THEN
            RAISE l_Error_Controlado;
          END IF;
        END IF;
      END IF;
      BEGIN
        /*        IF p_trama_pm.subtrama_pm2(l_itm).signo = 'N' AND (p_tipo_tx = 'GNCU02' OR p_tipo_tx = 'GNCU06') THEN
          l_movdesc := 1;
        ELSIF p_trama_pm.subtrama_pm2(l_itm).signo = 'N' AND (p_tipo_tx = 'GNCU01' OR p_tipo_tx = 'GNCU05') THEN
          l_movdesc := -1;
        END IF;*/
        IF p_Trama_Pm.Subtrama_Pm2(l_Itm).Signo = 'N' AND
            (p_Tipo_Tx = 'GNCU02' OR p_Tipo_Tx = 'GNCU06') THEN
          l_Movdesc := 1;
        ELSIF p_Trama_Pm.Subtrama_Pm2(l_Itm).Signo = 'P' AND
               (p_Tipo_Tx = 'GNCU02' OR p_Tipo_Tx = 'GNCU06') THEN
          l_Movdesc := -1;
        ELSIF p_Trama_Pm.Subtrama_Pm2(l_Itm).Signo = 'N' AND
               (p_Tipo_Tx = 'GNCU01' OR p_Tipo_Tx = 'GNCU05') THEN
          l_Movdesc := -1;
        ELSIF p_Trama_Pm.Subtrama_Pm2(l_Itm).Signo = 'P' AND
               (p_Tipo_Tx = 'GNCU01' OR p_Tipo_Tx = 'GNCU05') THEN
          l_Movdesc := 1;
        END IF;
        l_Dbg_Mensaje := 'Insertar en tabla scfr_mov_descuentos_productos - secuencia =>' || p_Trama_Pm.Subtrama_Pm2(l_Itm).Secuencia_b;
        IF (p_Trama_Pm.Subtrama_Pm2(l_Itm).Tipo_Descuento = 'CNV') THEN
        
          IF (p_Trama_Pm.Subtrama_Pm2(l_Itm).Campana_o_Convenio >= 1000000000) THEN
            l_Convenio := To_Char(To_Number(Substr(To_Char(p_Trama_Pm.Subtrama_Pm2(l_Itm).Campana_o_Convenio)
                                                  ,3
                                                  ,10)));
          ELSE
            l_Convenio := To_Char(To_Number(To_Char(p_Trama_Pm.Subtrama_Pm2(l_Itm).Campana_o_Convenio)));
          END IF;
        
        ELSE
          l_Convenio := p_Trama_Pm.Subtrama_Pm2(l_Itm).Campana_o_Convenio;
        
        END IF;
        INSERT INTO Scfr_Mov_Descuentos_Productos
          (Secuencia_Descuento
          ,Txo_Codigo_Tx
          ,Txo_Correlativo_Tx
          ,Pro_Codigo_Interno
          ,Tipo_Descuento
          ,Campana_Convenio
          ,Mcu_Codigo_Cupon
          ,Monto
          ,Puntos_Canjeados
          ,Prt_Codigo_Detalle
          ,Tipo_Aplicacion_Descuento
          ,Id_Dcto_Complem
          ,Financiado
          ,Sec_Financiamiento
          ,Descuento_Referencial
          ,Unidades_Descuento
          ,Empresa
          ,Cadena
          ,Loc_Local
          ,Rut_Supervisor
          ,Dv_Supervisor
          ,Tipo_Identi_Supervisor
          ,Identi_Supervisor
          ,Pertenece_Club
          ,Promotion_web)
        VALUES
          (p_Trama_Pm.Subtrama_Pm2(l_Itm).Secuencia_b -- secuencia_descuento
          ,p_Transaccion.Codigo_Tx -- txo_codigo_tx
          ,p_Trama_Dv.Correlativo_Tx -- txo_correlativo_tx
          ,p_Trama_Pm.Producto -- pro_codigo_interno
          ,p_Trama_Pm.Subtrama_Pm2(l_Itm).Tipo_Descuento -- tipo_descuento
          ,l_Convenio -- p_Trama_Pm.Subtrama_Pm2(l_Itm).Campana_o_Convenio -- campana_convenio
          ,p_Trama_Pm.Subtrama_Pm2(l_Itm).Codigo_Cupon -- mcu_codigo_cupon
          ,p_Trama_Pm.Subtrama_Pm2(l_Itm).Monto_Documento * l_Movdesc -- monto
          ,p_Trama_Pm.Subtrama_Pm2(l_Itm).Puntos_Canjeados * l_Movdesc -- puntos_canjeados
          ,p_Codigo_Detalle -- prt_codigo_detalle
          ,p_Trama_Pm.Subtrama_Pm2(l_Itm).Tipo_Aplicacion_Descuento
          ,p_Trama_Pm.Subtrama_Pm2(l_Itm).Id_Descuento_Complementario
          ,p_Trama_Pm.Subtrama_Pm2(l_Itm).Descuento_Financiado -- financiado
          ,p_Trama_Pm.Subtrama_Pm2(l_Itm).Secuencia_Financiamiento -- secuencia_financiamiento
          ,p_Trama_Pm.Subtrama_Pm2(l_Itm).Descuento_Referencial -- descuento_referencial
          ,p_Trama_Pm.Subtrama_Pm2(l_Itm).Unidades_Beneficio -- unidades_descuento
          ,p_Transaccion.Trama_Pos.Empresa
          ,p_Transaccion.Trama_Pos.Cadena
          ,p_Transaccion.Trama_Pos.Local
          ,p_Trama_Pm.Rut_Supervisor
          ,p_Trama_Pm.Dv_Rut_Supervisor
          ,Substr(p_Trama_Pm.Identi_Supervisor
                 ,1
                 ,1)
          ,Substr(p_Trama_Pm.Identi_Supervisor
                 ,2
                 ,30)
          ,Substr(Nvl(p_Trama_Pm.Subtrama_Pm2(l_Itm).Pertenece_Club
                     ,'N')
                 ,1
                 ,1)
          ,p_Trama_Pm.Subtrama_Pm2(l_Itm).Promotion_web); -- IDHC  04/06/2024
      
        --//--------------------------------------------------------------------------\\
        --// CBR 27/12/2017 17:33   BOX AHORRO                                        \\
        --//-----------------------------------------------------------------Inicio---\\
        IF p_Transaccion.Trama_Pos.Origen_Transaccion IN ('BOX'
                                                         ,'GLO'
                                                         ,'FEL'
                                                         ,'FAT'
                                                         ,'CIA'
                                                         ,'EMP'
                                                         ,'NEC' -- JAGC NEC 20240909 
                                                         ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                                                         ,'OBE' --JAGC 20261022
                                                         ,'DEC') THEN
          l_Dbg_Mensaje := 'Registrar Descuento Obtenido por Campana/Convenio Club Mas CruzVerde';
          IF Nvl(p_Trama_Pm.Subtrama_Pm2(l_Itm).Pertenece_Club
                ,'N') = 'S' OR
             Nvl(p_Trama_Pm.Subtrama_Pm2(l_Itm).Pertenece_Club
                ,'NO') = 'SI' THEN
          
            IF p_Tipo_Tx <> 'GNCU05' THEN
              BEGIN
                SELECT t.Txo_Codigo_Tx
                  INTO l_Codigo_Tx
                  FROM Scfr_Mov_Documentos_Txs t
                 WHERE t.Pin_Ot_Recetario = p_Trama_Dv.Ot
                   AND t.Tmo_Movimiento = 'RECRMA';
              EXCEPTION
                WHEN OTHERS THEN
                  l_Codigo_Tx := NULL;
              END;
              BEGIN
                SELECT 1 INTO l_Existe_Pin_Ot FROM Scfr_Mov_Descuentos_Club t WHERE t.Txo_Codigo_Tx = l_Codigo_Tx;
              EXCEPTION
                WHEN OTHERS THEN
                  l_Existe_Pin_Ot := NULL;
              END;
            END IF;
          
            IF Nvl(l_Existe_Pin_Ot
                  ,0) = 0 THEN
            
              INSERT INTO Scfr_Mov_Descuentos_Club
                (Txo_Codigo_Tx
                ,Txo_Correlativo_Tx
                ,Pro_Codigo_Interno
                ,Tipo_Descuento
                ,Campana_Convenio
                ,Monto
                ,Fecha_Tx
                ,Rut_Titular
                ,Dv_Titular
                ,Pt_Party_Id_Titular
                ,Cad_Cadena
                ,Emp_Empresa
                ,Loc_Local)
              VALUES
                (p_Transaccion.Codigo_Tx
                ,p_Trama_Dv.Correlativo_Tx
                ,p_Trama_Pm.Producto
                ,p_Trama_Pm.Subtrama_Pm2(l_Itm).Tipo_Descuento
                ,p_Trama_Pm.Subtrama_Pm2(l_Itm).Campana_o_Convenio
                ,p_Trama_Pm.Subtrama_Pm2(l_Itm).Monto_Documento * l_Movdesc
                ,p_Transaccion.Fecha_Tx
                ,p_Transaccion.Rut_Titular
                ,p_Transaccion.Dv_Rut_Titular
                ,p_Transaccion.Trama_Boc.Party_Id
                ,p_Transaccion.Trama_Pos.Cadena
                ,p_Transaccion.Trama_Pos.Empresa
                ,p_Transaccion.Trama_Pos.Local);
            END IF;
          END IF;
        END IF;
        --//-----------------------------------------------------------------Termino--\\
      
        l_Dbg_Mensaje := 'Registrar el Control de Frecuencia de Compras';
        IF p_Estado = 'UTI' THEN
          l_Tipo_Mov := 'COM';
        ELSE
          l_Tipo_Mov := 'REV';
        END IF;
        IF p_Transaccion.Trama_Boc.Party_Id > 0 THEN
          l_Resultado := Scfr_Trx_Gnc_Utl_Pk.Campanas_Frecuencias(p_Trama_Pm.Subtrama_Pm2(l_Itm).Campana_o_Convenio
                                                                 ,p_Transaccion.Trama_Boc.Party_Id
                                                                 ,p_Transaccion.Rut_Titular
                                                                 ,p_Transaccion.Codigo_Tx
                                                                 ,p_Transaccion.Fecha_Tx
                                                                 ,l_Tipo_Mov);
        END IF;
        IF l_Resultado != 0 THEN
          Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                    ,p_Msg     => l_Dbg_Mensaje);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                    ,p_Msg     => l_Dbg_Mensaje);
      END;
      -- Transaccion de origen local GeoPos
      -- INI JAGC NEC 20240909
      --IF p_Transaccion.Trama_Pos.Plataforma = 'U' THEN
      
      IF p_Transaccion.Trama_Pos.Plataforma IN ('U'
                                               ,'E') THEN
        l_Dbg_Mensaje := 'Recorrer detalle de descuento productos GeoCom';
        Dbms_Output.Put_Line('p_Trama_Pm.Subtrama_Pm2(l_Itm).Detalle_Descuento_Producto=>' || p_Trama_Pm.Subtrama_Pm2(l_Itm).Detalle_Descuento_Producto);
        l_Ind_Salida := FALSE;
        l_Salto_Item := 1;
        Cont         := 0;
               
        WHILE (NOT l_Ind_Salida)
        LOOP    
          
          IF (TRIM(p_Trama_Pm.Subtrama_Pm2(l_Itm).Tipo_Aplicacion_Descuento) = 'PA') THEN
              l_Ind_Salida := TRUE;
          END IF;
            
          IF (TRIM(p_Trama_Pm.Subtrama_Pm2(l_Itm).Tipo_Aplicacion_Descuento) = 'NS') THEN
            
            
              l_String     := Substr(Ltrim(Rtrim(p_Trama_Pm.Subtrama_Pm2(l_Itm).Detalle_Descuento_Producto))
                                    ,l_Salto_Item
                                    --,36);
                                    ,40);
              --l_Salto_Item := l_Salto_Item + 36;
              l_Salto_Item := l_Salto_Item + 40;
              IF (Nvl(Length(TRIM(l_String))
                     --,0) < 35) THEN
                     ,0) < 39) THEN
                l_Ind_Salida := TRUE;
              ELSE
                -- Registra descuento Necesidades de Salud
                Dbms_Output.Put_Line('l_String=>' || l_String);
                Cont        := Cont + 1;
                l_Sec_Ciclo := To_Number(Substr(l_String
                                               ,1
                                               ,2));
              
                Dbms_Output.Put_Line('l_Sec_Ciclo=>' || l_Sec_Ciclo);
                l_Valor_String := Substr(l_String
                                        ,3
                                        ,3);
              
                l_Ciclo := To_Number(Substr(l_Valor_String
                                           ,Instr(l_Valor_String
                                                 ,'-')
                                           ,Length(l_Valor_String)));
              
                Dbms_Output.Put_Line('l_Ciclo=>' || l_Ciclo);
                l_Valor_String := Substr(l_String
                                        ,6
                                        ,14);
                l_Monto        := To_Number(Substr(l_Valor_String
                                                  ,Instr(l_Valor_String
                                                        ,'-')
                                                  ,Length(l_Valor_String))) / 10000;
              
                Dbms_Output.Put_Line('l_Monto=>' || l_Monto);
                l_Valor_String := Substr(l_String
                                        ,20
                                        ,3);
                l_Unid_Desc    := To_Number(Substr(l_Valor_String
                                                  ,Instr(l_Valor_String
                                                        ,'-')
                                                  ,Length(l_Valor_String)));
              
                Dbms_Output.Put_Line('l_Unid_Desc=>' || l_Unid_Desc);
                l_Valor_Evento := To_Number(Substr(l_String
                                                  ,23
                                                  ,5)); -- +Valor Evento Aplicado (Numerico 5)
                Dbms_Output.Put_Line('l_valor_evento=>' || l_Valor_Evento);
                l_Tipo_Descuento := Substr(l_String
                                          ,28
                                          ,2); -- +Tipo Descuento (Caracter 2)
                Dbms_Output.Put_Line('l_tipo_descuento=>' || l_Tipo_Descuento);
                l_Id_Promocion := To_Number(Substr(l_String
                                                  ,30
                                                  ,10)); -- +Id Promocion (Numerico 10)
                Dbms_Output.Put_Line('l_id_promocion=>' || l_Id_Promocion);
                l_Tipo_Promocion := Substr(l_String
                                          ,40
                                          ,1); -- +Tipo Promocion (Caracter 1)}
                Dbms_Output.Put_Line('l_tipo_promocion=>' || l_Tipo_Promocion);
              
                IF l_Valor_Evento = 0 THEN
                
                  BEGIN
                    SELECT Abs(Pro_Precio_Lista)
                      INTO l_Precio_Lista
                      FROM Scfr_Mov_Productos_Txs
                     WHERE Txo_Codigo_Tx = p_Transaccion.Codigo_Tx
                       AND Codigo_Detalle = p_Codigo_Detalle;
                  EXCEPTION
                    WHEN No_Data_Found THEN
                      l_Precio_Lista := NULL;
                  END;
                
                  -- obtiene porcentaje de descuento
                  BEGIN
                  
                    l_Valor_Evento   := (Abs(l_Monto) * 100 / Abs(Nvl(l_Precio_Lista
                                                                     ,Abs(l_Monto))));
                    l_Tipo_Descuento := 'P';
                  EXCEPTION
                    WHEN OTHERS THEN
                      l_Valor_Evento   := 0;
                      l_Tipo_Descuento := 'N';
                  END;
                
                END IF;  
              
                l_Dbg_Mensaje := 'Insertar en tabla scfr_mov_det_desc_producto GeoCom';
                INSERT INTO Scfr_Mov_Det_Desc_Producto
                  (Secuencia_Descuento
                  ,Txo_Codigo_Tx
                  ,Ciclo
                  ,Monto_Descuento
                  ,Secuencia_Ciclo
                  ,Unidades_Descuento
                  ,Empresa
                  ,Cadena
                  ,Loc_Local
                  ,Valor_Evento_Aplicado
                  ,Tipo_Descuento
                  ,Id_Promocion
                  ,Tipo_Promocion)
                VALUES
                  (p_Trama_Pm.Subtrama_Pm2(l_Itm).Secuencia_b
                  ,p_Transaccion.Codigo_Tx
                  ,l_Ciclo
                  ,l_Monto
                  ,l_Sec_Ciclo
                  ,l_Unid_Desc
                  ,p_Transaccion.Trama_Pos.Empresa
                  ,p_Transaccion.Trama_Pos.Cadena
                  ,p_Transaccion.Trama_Pos.Local
                  ,l_Valor_Evento
                  ,TRIM(l_Tipo_Descuento)
                  ,l_Id_Promocion
                  ,l_Tipo_Promocion);
              END IF;
          ELSE  
            
           l_String     := Substr(Ltrim(Rtrim(p_Trama_Pm.Subtrama_Pm2(l_Itm).Detalle_Descuento_Producto))
                                  ,l_Salto_Item
                                  ,22);
            l_Salto_Item := l_Salto_Item + 22;
            IF (Nvl(Length(TRIM(l_String))
                   ,0) < 22) THEN
              l_Ind_Salida := TRUE;
            ELSE
              Cont          := Cont + 1;
              l_Sec_Ciclo   := To_Number(Substr(l_String
                                               ,1
                                               ,2));
              l_Ciclo       := To_Number(Substr(l_String
                                               ,3
                                                
                                               ,3));
              l_Monto       := To_Number(Substr(l_String
                                               ,6
                                               ,14));
              l_Unid_Desc   := To_Number(Substr(l_String
                                               ,20
                                                
                                               ,3));
              l_Dbg_Mensaje := 'Insertar en tabla scfr_mov_det_desc_producto GeoCom';
            
              INSERT INTO Scfr_Mov_Det_Desc_Producto
                (Secuencia_Descuento
                ,Txo_Codigo_Tx
                ,Ciclo
                ,Monto_Descuento
                ,Secuencia_Ciclo
                ,Unidades_Descuento
                ,Empresa
                ,Cadena
                ,Loc_Local)
              VALUES
                (p_Trama_Pm.Subtrama_Pm2(l_Itm).Secuencia_b
                ,p_Transaccion.Codigo_Tx
                ,((Cont * 100) + l_Ciclo)
                ,l_Monto
                ,l_Sec_Ciclo
                ,l_Unid_Desc
                ,p_Transaccion.Trama_Pos.Empresa
                ,p_Transaccion.Trama_Pos.Cadena
                ,p_Transaccion.Trama_Pos.Local);
            END IF; -- if (length(l_string < 18)) then
          END IF;         
        END LOOP; -- 
         
        /*WHILE (NOT l_Ind_Salida)
        LOOP
            l_String     := Substr(Ltrim(Rtrim(p_Trama_Pm.Subtrama_Pm2(l_Itm).Detalle_Descuento_Producto))
                                  ,l_Salto_Item
                                  ,18);
            l_Salto_Item := l_Salto_Item + 18;
            IF (Nvl(Length(TRIM(l_String))
                   ,0) < 18) THEN
              l_Ind_Salida := TRUE;
            ELSE
              Cont          := Cont + 1;
              l_Sec_Ciclo   := To_Number(Substr(l_String
                                               ,1
                                               ,2));
              l_Ciclo       := To_Number(Substr(l_String
                                               ,3
                                               ,3));
              l_Monto       := To_Number(Substr(l_String
                                               ,6
                                               ,10));
              l_Unid_Desc   := To_Number(Substr(l_String
                                               ,16
                                               ,3));
              l_Dbg_Mensaje := 'Insertar en tabla scfr_mov_det_desc_producto GeoCom';
              --            INSERT INTO Scfr_Mov_Det_Desc_Producto
              --              (Secuencia_Descuento
              --              ,Txo_Codigo_Tx
              --              ,Ciclo
              --              ,Monto_Descuento
              --              ,Secuencia_Ciclo
              --              ,Unidades_Descuento
              --              ,Empresa
              --              ,Cadena
              --              ,Loc_Local)
              --            VALUES
              --              (p_Trama_Pm.Subtrama_Pm2(l_Itm).Secuencia_b
              --              ,p_Transaccion.Codigo_Tx
              --              ,((Cont * 100) + l_Ciclo)
              --              ,l_Monto
              --              ,l_Sec_Ciclo
              --              ,l_Unid_Desc
              --              ,p_Transaccion.Trama_Pos.Empresa
              --              ,p_Transaccion.Trama_Pos.Cadena
              --              ,p_Transaccion.Trama_Pos.Local);
            END IF; -- if (length(l_string < 18)) then          
          END IF;  
        END LOOP; -- *
        */
      -- FIN JAGC NEC 20240909
      ELSE
        -- IF p_Transaccion.Trama_Pos.Plataforma = 'U' THEN
        l_Dbg_Mensaje := 'Recorrer detalle de descuento productos';
        IF Length(Ltrim(Rtrim(p_Trama_Pm.Subtrama_Pm2(l_Itm).Detalle_Descuento_Producto))) > 2 THEN
          l_Tot_Det := To_Number(Substr(p_Trama_Pm.Subtrama_Pm2(l_Itm).Detalle_Descuento_Producto
                                       ,1
                                       ,2));
          l_Pos     := 3;
          FOR l_Itm2 IN 1 .. l_Tot_Det
          LOOP
            l_Ciclo       := To_Number(Substr(p_Trama_Pm.Subtrama_Pm2(l_Itm).Detalle_Descuento_Producto
                                             ,l_Pos
                                             ,3));
            l_Monto       := To_Number(Substr(p_Trama_Pm.Subtrama_Pm2(l_Itm).Detalle_Descuento_Producto
                                             ,l_Pos + 3
                                             --,10));
                                             ,14));-- JAGC NEC 20240909
            l_Sec_Ciclo   := Substr(p_Trama_Pm.Subtrama_Pm2(l_Itm).Detalle_Descuento_Producto
                                   ,l_Pos + 13
                                   ,3);
            l_Unid_Desc   := To_Number(Substr(p_Trama_Pm.Subtrama_Pm2(l_Itm).Detalle_Descuento_Producto
                                             ,l_Pos + 16
                                             ,3));
            l_Dbg_Mensaje := 'Insertar en tabla scfr_mov_det_desc_producto';
            --          select scfr_mov_det_desc_producto_s.nextval
            --            into l_sec_descuento
            --            from dual;
            l_Dbg_Mensaje := 'Insertar en tabla scfr_mov_det_desc_producto';
            
            -- INI DESCOMENTADO JAGC NEC 20240909
            
                        INSERT INTO Scfr_Mov_Det_Desc_Producto
                          (Secuencia_Descuento
                          ,Txo_Codigo_Tx
                          ,Ciclo
                          ,Monto_Descuento
                          ,Secuencia_Ciclo
                          ,Unidades_Descuento
                          ,Empresa
                          ,Cadena
                          ,Loc_Local)
                        VALUES
                          (p_Trama_Pm.Subtrama_Pm2(l_Itm).Secuencia_b
                          ,p_Transaccion.Codigo_Tx
                          ,l_Ciclo
                          ,l_Monto
                          ,l_Sec_Ciclo
                          ,l_Unid_Desc
                          ,p_Transaccion.Trama_Pos.Empresa
                          ,p_Transaccion.Trama_Pos.Cadena
                          ,p_Transaccion.Trama_Pos.Local);
            
            -- FIN DESCOMENTADO JAGC NEC 20240909
            
            --l_Pos := l_Pos + 19;
            l_Pos := l_Pos + 23;-- JAGC NEC 20240909 --l_pos+13  SE AGREGO CAMPO DE LARGO 3
          END LOOP;
        END IF;
      END IF; -- IF p_Transaccion.Trama_Pos.Plataforma = 'U' THEN
      -- Actualiza el cupon utilizado
      l_Dbg_Mensaje := 'Actualizar cupon';
      UPDATE Scfr_Cupones
         SET Estado_Cupon        = p_Estado
            ,Txo_Codigo_Tx_Canje = p_Transaccion.Codigo_Tx
            ,Fecha_Canje         = p_Transaccion.Fecha_Tx
            ,Loc_Local           = p_Transaccion.Trama_Pos.Local
            ,Procesado           = Nvl2(Procesado
                                       ,2
                                       ,Procesado)
       WHERE Codigo_Cupon = p_Trama_Pm.Subtrama_Pm2(l_Itm).Codigo_Cupon;
      --//--------------------------------------------------------------------------\\
      --// CBR 05/02/2015 18:59               Mensajes / Eventos / Descuentos       \\
      --//                                                                          \\
      --//-----------------------------------------------------------------Inicio---\\
      IF p_Trama_Pm.Subtrama_Pm2(l_Itm).Tipo_Descuento = 'CAM' THEN
        l_Dbg_Mensaje := 'Validar si aplica Control de Evento en Campana de Descuentos';
        Scfr_Trx_Fid_Pk.Dto_x_Evento_Aplicar(p_Estado -- p_Accion
                                            ,p_Transaccion.Rut_Titular -- p_Rut_Cliente
                                            ,p_Trama_Pm.Subtrama_Pm2(l_Itm).Campana_o_Convenio -- p_Campana_Descuentos
                                            ,x_Cod_Error -- x_Cod_Error
                                            ,x_Msg_Error); -- x_Msg_Error
      END IF;
      --//-----------------------------------------------------------------Termino--\\
    END LOOP;
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Trama PM2 (descuentos aplicados) resuelta correctamente');
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  PROCEDURE Trama_Pm_Puntos_Generados(p_Transaccion    IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                     ,p_Trama_Pm       IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pm
                                     ,p_Codigo_Detalle IN NUMBER
                                     ,p_Tipo_Tx        IN VARCHAR2
                                     ,x_Cod_Error      OUT NUMBER
                                     ,x_Msg_Error      OUT NUMBER) IS
    l_Itm              NUMBER;
    l_Puntos_Generados NUMBER;
    l_Mov_Prod_Doctos  NUMBER;
    l_Signo_Puntos     NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_pm_puntos_generados';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    --
    l_Tipo_Mov  VARCHAR2(3);
    l_Resultado NUMBER;
  BEGIN
    x_Cod_Error        := 0;
    l_Puntos_Generados := 0;
    l_Dbg_Mensaje      := 'Recorrer detalle de la subtrama PM3 (Puntos Generados)';
    FOR l_Itm IN 1 .. p_Trama_Pm.Subtrama_Pm3.Count
    LOOP
      l_Mov_Prod_Doctos := Scfr_Trx_Gnc_Utl_Pk.Obtiene_Id_Productos_Doctos(p_Transaccion
                                                                          ,p_Trama_Pm);
      l_Dbg_Mensaje     := 'Insertar en tabla scfr_mov_puntos_productos';
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'l_mov_prod_doctos=>' || l_Mov_Prod_Doctos);
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'p_trama_pm.producto=>' || p_Trama_Pm.Producto);
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'p_trama_pm.subtrama_pm3(l_itm).campana=>' || p_Trama_Pm.Subtrama_Pm3(l_Itm).Campana);
      l_Signo_Puntos := 1;
      IF p_Trama_Pm.Subtrama_Pm3(l_Itm).Signo = 'N' OR
          p_Tipo_Tx = 'GNCU02' THEN
        l_Signo_Puntos := -1;
      END IF;
      IF l_Mov_Prod_Doctos > 0 THEN
        INSERT INTO Scfr_Mov_Puntos_Productos
          (Mov_Productos_Documentos
          ,Pro_Codigo_Interno
          ,Cam_Campana
          ,Puntos_Generados
          ,Empresa
          ,Cadena
          ,Loc_Local)
        VALUES
          (l_Mov_Prod_Doctos
          ,p_Trama_Pm.Producto
          ,p_Trama_Pm.Subtrama_Pm3(l_Itm).Campana
          ,p_Trama_Pm.Subtrama_Pm3(l_Itm).Puntos * l_Signo_Puntos
          ,p_Transaccion.Trama_Pos.Empresa
          ,p_Transaccion.Trama_Pos.Cadena
          ,p_Transaccion.Trama_Pos.Local);
      END IF;
      l_Dbg_Mensaje      := 'Suma puntos generados';
      l_Puntos_Generados := l_Puntos_Generados + (p_Trama_Pm.Subtrama_Pm3(l_Itm).Puntos * l_Signo_Puntos);
      l_Dbg_Mensaje      := 'Registrar el Control de Frecuencia de Compras';
      IF l_Signo_Puntos = 1 THEN
        l_Tipo_Mov := 'COM';
      ELSE
        l_Tipo_Mov := 'REV';
      END IF;
      IF p_Transaccion.Trama_Boc.Party_Id > 0 THEN
        l_Resultado := Scfr_Trx_Gnc_Utl_Pk.Campanas_Frecuencias(p_Trama_Pm.Subtrama_Pm3(l_Itm).Campana
                                                               ,p_Transaccion.Trama_Boc.Party_Id
                                                               ,p_Transaccion.Rut_Titular
                                                               ,p_Transaccion.Codigo_Tx
                                                               ,p_Transaccion.Fecha_Tx
                                                               ,l_Tipo_Mov);
      END IF;
      IF l_Resultado != 0 THEN
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => l_Dbg_Mensaje);
      END IF;
    END LOOP;
    l_Dbg_Mensaje := 'Actualizar tabla scfr_mov_productos_txs';
    UPDATE Scfr_Mov_Productos_Txs
       SET Puntos_Generados = l_Puntos_Generados
          ,Procesado        = Nvl2(Procesado
                                  ,2
                                  ,Procesado)
     WHERE Codigo_Detalle = p_Codigo_Detalle;
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Trama PM3 (puntos generados) resuelta correctamente');
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  -- INI JAGC NEC 20240909
  PROCEDURE Trama_Pm_Eventos_Perdidos(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                     ,p_Trama_Pm    IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pm
                                      
                                     ,p_Codigo_Detalle IN NUMBER
                                     ,p_Tipo_Tx        IN VARCHAR2
                                     ,x_Cod_Error      OUT NUMBER
                                     ,x_Msg_Error      OUT NUMBER) IS
    l_Itm              NUMBER;
    l_Puntos_Generados NUMBER;
    l_Mov_Prod_Doctos  NUMBER;
    l_Signo_Puntos     NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.Trama_Pm_Eventos_Perdidos';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    --
    l_Tipo_Mov     VARCHAR2(3);
    l_Resultado    NUMBER;
    l_Secuencia    NUMBER;
    l_Precio_Lista NUMBER;
    l_Porcentaje   NUMBER;
    l_Decimal      NUMBER;
    
    l_Unidad_Beneficio NUMBER;
    l_Unidad_Compra NUMBER;
    l_texto_Aux VARCHAR2(8);
    
  BEGIN    
    
      x_Cod_Error        := 0;
      l_Puntos_Generados := 0;
      l_Dbg_Mensaje      := 'Recorrer detalle de la subtrama PM5 (Trama_Pm_Eventos_Perdidos)';
      FOR l_Itm IN 1 .. p_Trama_Pm.Subtrama_Pm9.Count
      LOOP
        
        IF p_Transaccion.Trama_Pos.Origen_Transaccion NOT IN ('NEC','NEU','ONS'
                                                               ,'OBE' --JAGC 20261022
                                                               ) THEN  
          l_Unidad_Beneficio := 1;
          l_Unidad_Compra := 1;         
          
          BEGIN
            SELECT Abs(Pro_Precio_Lista * Cantidad)
              INTO l_Precio_Lista
              FROM Scfr_Mov_Productos_Txs
             WHERE Txo_Codigo_Tx = p_Transaccion.Codigo_Tx
               AND Codigo_Detalle = p_Codigo_Detalle;
          EXCEPTION
            WHEN No_Data_Found THEN
              l_Precio_Lista := NULL;
          END;
          
        ELSE 
          
          Dbms_Output.Put_Line('p_Transaccion.Trama_Pos.Origen_Transaccion=> ' || p_Transaccion.Trama_Pos.Origen_Transaccion);  

          l_texto_Aux := p_Trama_Pm.Subtrama_Pm9(l_Itm).Unidad_Beneficio; 
          Dbms_Output.Put_Line('l_texto_Aux=> ' || l_texto_Aux);       
        
          IF l_texto_Aux IS NOT NULL AND TRIM(l_texto_Aux) IS NOT NULL AND REGEXP_LIKE(l_texto_Aux, '^\d+(\.\d+)?$') THEN
            l_Unidad_Beneficio := TO_NUMBER(l_texto_Aux);
          ELSE    
            l_Unidad_Beneficio := 1;
          END IF; 
          
          Dbms_Output.Put_Line('l_Unidad_Beneficio=> ' || l_Unidad_Beneficio);  
          
          l_texto_Aux := p_Trama_Pm.Subtrama_Pm9(l_Itm).Unidad_Compra;  
          Dbms_Output.Put_Line('l_texto_Aux=> ' || l_texto_Aux);
                
          IF l_texto_Aux IS NOT NULL AND TRIM(l_texto_Aux) IS NOT NULL AND REGEXP_LIKE(l_texto_Aux, '^\d+(\.\d+)?$') THEN
            l_Unidad_Compra := TO_NUMBER(l_texto_Aux);
          ELSE    
            l_Unidad_Compra := 1;
          END IF;   
          
          Dbms_Output.Put_Line('l_Unidad_Compra=> ' || l_Unidad_Compra);        
                  
          BEGIN          
            SELECT Abs(Pro_Precio_Lista)
              INTO l_Precio_Lista
              FROM Scfr_Mov_Productos_Txs
             WHERE Txo_Codigo_Tx = p_Transaccion.Codigo_Tx
               AND Codigo_Detalle = p_Codigo_Detalle;
          EXCEPTION
            WHEN No_Data_Found THEN
              l_Precio_Lista := NULL;
          END;
          
          Dbms_Output.Put_Line('l_Precio_Lista=> ' || l_Precio_Lista);        
          
        END IF;  
        
        l_Precio_Lista := l_Precio_Lista * l_Unidad_Beneficio;
        
        -- obtiene decimal de descuento
        BEGIN
          l_Decimal := (Abs(TO_NUMBER(p_Trama_Pm.Subtrama_Pm9(l_Itm).Decimal_Monto_Docto)) * 0.1)/1000;
        
        EXCEPTION
          WHEN OTHERS THEN
            l_Decimal := 0;
        END;    
      
        -- obtiene porcentaje de descuento
        BEGIN
          l_Porcentaje := (Abs((p_Trama_Pm.Subtrama_Pm9(l_Itm).Monto_Descuento + l_Decimal)) * 100 /
                          Abs(Nvl(l_Precio_Lista
                                  ,Abs((p_Trama_Pm.Subtrama_Pm9(l_Itm).Monto_Descuento + l_Decimal)))));
        
        EXCEPTION
          WHEN OTHERS THEN
            l_Porcentaje := 0;
        END;
      
        BEGIN
          SELECT Secuencia_Descuento
            INTO l_Secuencia
            FROM Scfr_Mov_Descuentos_Productos
           WHERE Prt_Codigo_Detalle = p_Codigo_Detalle
             AND Tipo_Aplicacion_Descuento = 'NS'
             AND Rownum = 1;
        EXCEPTION
          WHEN No_Data_Found THEN
            l_Secuencia := 1;
        END;
      
        IF (l_Secuencia = 1) THEN
          BEGIN
            SELECT Secuencia_Descuento
              INTO l_Secuencia
              FROM Scfr_Mov_Descuentos_Productos
             WHERE Prt_Codigo_Detalle = p_Codigo_Detalle
               AND Campana_Convenio = p_Trama_Pm.Subtrama_Pm9(l_Itm).Descuento_Relacionado
               AND Rownum = 1;
          EXCEPTION
            WHEN No_Data_Found THEN
              l_Secuencia := 1;
          END;
        END IF;
        INSERT INTO Scfr_Mov_Det_Desc_Producto
          (Secuencia_Descuento
          ,Txo_Codigo_Tx
          ,Ciclo
          ,Monto_Descuento
          ,Secuencia_Ciclo
          ,Unidades_Descuento
          ,Empresa
          ,Cadena
          ,Loc_Local
          ,Valor_Evento_Aplicado
          ,Tipo_Descuento
          ,Id_Promocion
          ,Tipo_Promocion)
        VALUES
          (l_Secuencia
          ,p_Transaccion.Codigo_Tx
          ,p_Trama_Pm.Subtrama_Pm9(l_Itm).Evento_Perdido
          ,p_Trama_Pm.Subtrama_Pm9(l_Itm).Monto_Descuento + l_Decimal
          ,TRIM(p_Trama_Pm.Subtrama_Pm9(l_Itm).Evento_Perdido)
          ,l_Unidad_Beneficio
          ,p_Transaccion.Trama_Pos.Empresa
          ,p_Transaccion.Trama_Pos.Cadena
          ,p_Transaccion.Trama_Pos.Local
          ,l_Porcentaje
          ,'P'
          ,p_Trama_Pm.Subtrama_Pm9(l_Itm).Id_descuento_perdido
          ,'C');
        l_Dbg_Mensaje := 'Registrar el Control de Eventos Perdidos';
      END LOOP;
      
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'subtrama PM9 (Trama_Pm_Eventos_Perdidos) resuelta correctamente');
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;
  -- FIN JAGC NEC 20240909
  
  PROCEDURE Trama_Pm_Distrib_Convenios(p_Transaccion    IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                      ,p_Trama_Pm       IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pm
                                      ,p_Trama_Dv       IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                                      ,p_Codigo_Detalle IN NUMBER
                                      ,x_Cod_Error      OUT NUMBER
                                      ,x_Msg_Error      OUT NUMBER) IS
    l_Itm              NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_pm_distrib_convenios';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    x_Cod_Error   := 0;
    l_Dbg_Mensaje := 'Recorrer detalle de la subtrama PM4 (Distribucion Convenios)';
    FOR l_Itm IN 1 .. p_Trama_Pm.Subtrama_Pm4.Count
    LOOP
      l_Dbg_Mensaje := 'Insertar en tabla scfr_mov_productos_dis';
      INSERT INTO Scfr_Mov_Productos_Dis
        (Prt_Codigo_Detalle
        ,Txo_Codigo_Tx
        ,Txo_Correlativo_Tx
        ,Tipo_Distribucion
        ,Pro_Codigo_Interno
        ,Monto_Distribucion
        ,Empresa
        ,Cadena
        ,Loc_Local)
      VALUES
        (p_Codigo_Detalle
        ,p_Transaccion.Codigo_Tx
        ,p_Trama_Dv.Correlativo_Tx
        ,p_Trama_Pm.Subtrama_Pm4(l_Itm).Tipo_Distribucion
        ,p_Trama_Pm.Producto
        ,p_Trama_Pm.Subtrama_Pm4(l_Itm).Monto_Distribucion
        ,p_Transaccion.Trama_Pos.Empresa
        ,p_Transaccion.Trama_Pos.Cadena
        ,p_Transaccion.Trama_Pos.Local);
    END LOOP;
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Trama PM4 (distribucion convenios) resuelta correctamente');
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  PROCEDURE Trama_Pm_Impuestos_Aplicados(p_Transaccion    IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                        ,p_Trama_Pm       IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pm
                                        --,p_Trama_Dv       IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                                        ,P_Correlativo_Tx   IN NUMBER
                                        ,p_Codigo_Detalle IN NUMBER
                                        ,x_Cod_Error      OUT NUMBER
                                        ,x_Msg_Error      OUT NUMBER) IS
    l_Itm              NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_pm_Impuestos_Aplicados';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    
    DBMS_OUTPUT.PUT_LINE('Trama_Pm_Impuestos_Aplicados');  
    DBMS_OUTPUT.PUT_LINE('P_Correlativo_Tx: ' || P_Correlativo_Tx);  
  
    x_Cod_Error   := 0;
    l_Dbg_Mensaje := 'Recorrer detalle de la subtrama PM5 (Impuestos Aplicados)';
    
    DBMS_OUTPUT.PUT_LINE('l_Dbg_Mensaje: ' || l_Dbg_Mensaje);
    
    FOR l_Itm IN 1 .. p_Trama_Pm.Subtrama_Pm5.Count
    LOOP
      l_Dbg_Mensaje := 'Insertar en tabla scfr_mov_Impuestos_Aplicados';
      
      DBMS_OUTPUT.PUT_LINE('l_Dbg_Mensaje: ' || l_Dbg_Mensaje);
    
      INSERT INTO Scfr_Mov_Impuestos_Aplicados
        (Prt_Codigo_Detalle
        ,Txo_Codigo_Tx
        ,Txo_Correlativo_Tx
        ,Pro_Codigo_Interno
        ,Codigo_Impuesto
        ,Porcentaje_Impuesto
        ,Monto_Impuesto
        ,Empresa
        ,Cadena
        ,Loc_Local)
      VALUES
        (p_Codigo_Detalle
        ,p_Transaccion.Codigo_Tx
        ,P_Correlativo_Tx
        ,p_Trama_Pm.Producto
        ,p_Trama_Pm.Subtrama_Pm5(l_Itm).Codigo_Impuesto
        ,p_Trama_Pm.Subtrama_Pm5(l_Itm).Porcentaje_Impuesto -- Decimal_Porc_Impuesto
        ,p_Trama_Pm.Subtrama_Pm5(l_Itm).Monto_Impuesto -- Decimal_Mto_Impuesto
        ,p_Transaccion.Trama_Pos.Empresa
        ,p_Transaccion.Trama_Pos.Cadena
        ,p_Transaccion.Trama_Pos.Local);
    END LOOP;
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Trama PM5 (Impuestos Aplicados) resuelta correctamente');
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
    
    DBMS_OUTPUT.PUT_LINE('x_Msg_Error: ' || x_Cod_Error || ' ' || x_Msg_Error);
    
  END;
  
 PROCEDURE Trama_Pm_Impuestos_AplicadosOLD(p_Transaccion    IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                        ,p_Trama_Pm       IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pm
                                        ,p_Trama_Dv       IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                                        ,p_Codigo_Detalle IN NUMBER
                                        ,x_Cod_Error      OUT NUMBER
                                        ,x_Msg_Error      OUT NUMBER) IS
    l_Itm              NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_pm_Impuestos_Aplicados';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    x_Cod_Error   := 0;
    l_Dbg_Mensaje := 'Recorrer detalle de la subtrama PM5 (Impuestos Aplicados)';
    FOR l_Itm IN 1 .. p_Trama_Pm.Subtrama_Pm5.Count
    LOOP
      l_Dbg_Mensaje := 'Insertar en tabla scfr_mov_Impuestos_Aplicados';
      INSERT INTO Scfr_Mov_Impuestos_Aplicados
        (Prt_Codigo_Detalle
        ,Txo_Codigo_Tx
        ,Txo_Correlativo_Tx
        ,Pro_Codigo_Interno
        ,Codigo_Impuesto
        ,Porcentaje_Impuesto
        ,Monto_Impuesto
        ,Empresa
        ,Cadena
        ,Loc_Local)
      VALUES
        (p_Codigo_Detalle
        ,p_Transaccion.Codigo_Tx
        ,p_Trama_Dv.Correlativo_Tx
        ,p_Trama_Pm.Producto
        ,p_Trama_Pm.Subtrama_Pm5(l_Itm).Codigo_Impuesto
        ,p_Trama_Pm.Subtrama_Pm5(l_Itm).Porcentaje_Impuesto -- Decimal_Porc_Impuesto
        ,p_Trama_Pm.Subtrama_Pm5(l_Itm).Monto_Impuesto -- Decimal_Mto_Impuesto
        ,p_Transaccion.Trama_Pos.Empresa
        ,p_Transaccion.Trama_Pos.Cadena
        ,p_Transaccion.Trama_Pos.Local);
    END LOOP;
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Trama PM5 (Impuestos Aplicados) resuelta correctamente');
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

 PROCEDURE Trama_Pm_Recargas_Telepeajes(p_Transaccion    IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                        ,p_Trama_Pm       IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pm
                                        ,p_Trama_Dv       IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                                        ,p_Codigo_Detalle IN NUMBER
                                        ,p_Tipo_Tx        IN VARCHAR2
                                        ,x_Cod_Error      OUT NUMBER
                                        ,x_Msg_Error      OUT NUMBER) IS
    l_Itm              NUMBER;
    l_Mov_Ryt          NUMBER := 1;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_pm_Recargas_Telepeajes';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  l_cant_filas    NUMBER:= 0;
  BEGIN
    x_Cod_Error   := 0;
    l_Dbg_Mensaje := 'Recorrer detalle de la subtrama PM6 (Recargas_Telepeajes)';
    
    IF p_Tipo_Tx = 'GNCU02' OR
       p_Tipo_Tx = 'GNCU06' THEN
      l_Mov_Ryt := -1;
    END IF;
    --
    -- LMP GPF 20231208 Ecuador
    --
    -- Se agreg? esta solucion para insertar los productos de tipo servicio 
    -- que no se estaban persistiend en la base de datos
    -- especificamente el item FEE
    --
    If p_Trama_Pm.Subtrama_Pm6.Count = 0 then
      begin 
       SELECT count(*) INTO l_cant_filas FROM scfr_productos_v v WHERE v.codigo = p_Trama_Pm.Producto AND v.EMPRESA = p_Transaccion.Trama_Pos.Empresa AND v.div_name = 'SERVICIOS';
       if l_cant_filas > 0 then 
          l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_PRODUCTOS_RYT';
          INSERT INTO Scfr_Mov_Productos_Ryt
          (Prt_Codigo_Detalle
          ,Txo_Codigo_Tx
          ,Txo_Correlativo_Tx
          ,Pro_Codigo_Interno
          ,Secuencia_Ingreso
          ,Identificador_Recarga
          ,Nombre
          ,Monto_Recarga
          ,Codigo_Autorizacion
          ,Auditoria
          ,Tipo_Servicio
          ,Loc_Local
          ,Cad_Cadena
          ,Emp_Empresa)
          VALUES
          (p_Codigo_Detalle
          ,p_Transaccion.Codigo_Tx
          ,p_Trama_Dv.Correlativo_Tx
          ,p_Trama_Pm.Producto
          ,0 --,p_Trama_Pm.Subtrama_Pm6(l_Itm).Secuencia
          ,null --,TRIM(p_Trama_Pm.Subtrama_Pm6(l_Itm).Identificacdor)
          ,'02' --,TRIM(p_Trama_Pm.Subtrama_Pm6(l_Itm).Nombre)
          ,p_trama_pm.precio_final * l_Mov_Ryt --,p_Trama_Pm.Subtrama_Pm6(l_Itm).Monto * l_Mov_Ryt
          ,null --,TRIM(p_Trama_Pm.Subtrama_Pm6(l_Itm).Autorizacion)
          ,null --,TRIM(p_Trama_Pm.Subtrama_Pm6(l_Itm).Auditoria)
          ,'R' --,p_Trama_Pm.Subtrama_Pm6(l_Itm).Tipo_Servicio
          ,p_Transaccion.Trama_Pos.Local
          ,p_Transaccion.Trama_Pos.Cadena
          ,p_Transaccion.Trama_Pos.Empresa);
      end if;
      exception 
         WHEN OTHERS THEN 
           null;
      end;
    End if;
    --
    FOR l_Itm IN 1 .. p_Trama_Pm.Subtrama_Pm6.Count
    LOOP
      l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_PRODUCTOS_RYT';
      INSERT INTO Scfr_Mov_Productos_Ryt
        (Prt_Codigo_Detalle
        ,Txo_Codigo_Tx
        ,Txo_Correlativo_Tx
        ,Pro_Codigo_Interno
        ,Secuencia_Ingreso
        ,Identificador_Recarga
        ,Nombre
        ,Monto_Recarga
        ,Codigo_Autorizacion
        ,Auditoria
        ,Tipo_Servicio
        ,Loc_Local
        ,Cad_Cadena
        ,Emp_Empresa)
      VALUES
        (p_Codigo_Detalle
        ,p_Transaccion.Codigo_Tx
        ,p_Trama_Dv.Correlativo_Tx
        ,p_Trama_Pm.Producto
        ,p_Trama_Pm.Subtrama_Pm6(l_Itm).Secuencia
        ,TRIM(p_Trama_Pm.Subtrama_Pm6(l_Itm).Identificacdor)
        ,TRIM(p_Trama_Pm.Subtrama_Pm6(l_Itm).Nombre)
        ,p_Trama_Pm.Subtrama_Pm6(l_Itm).Monto * l_Mov_Ryt
        ,TRIM(p_Trama_Pm.Subtrama_Pm6(l_Itm).Autorizacion)
        ,TRIM(p_Trama_Pm.Subtrama_Pm6(l_Itm).Auditoria)
        ,p_Trama_Pm.Subtrama_Pm6(l_Itm).Tipo_Servicio
        ,p_Transaccion.Trama_Pos.Local
        ,p_Transaccion.Trama_Pos.Cadena
        ,p_Transaccion.Trama_Pos.Empresa);
    END LOOP;
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Trama PM6 (Recargas_Telepeajes) resuelta correctamente');
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  PROCEDURE Trama_Pm_Mejor_Opcion(p_Transaccion    IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                 ,p_Trama_Pm       IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pm
                                 ,p_Trama_Dv       IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                                 ,p_Codigo_Detalle IN NUMBER
                                 ,x_Cod_Error      OUT NUMBER
                                 ,x_Msg_Error      OUT NUMBER) IS
    l_Itm              NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.Trama_Pm_Mejor_Opcion';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    x_Cod_Error   := 0;
    l_Dbg_Mensaje := 'Recorrer detalle de la subtrama PM7 (Mejor Opcion)';
    FOR l_Itm IN 1 .. p_Trama_Pm.Subtrama_Pm7.Count
    LOOP
      l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_PRODUCTOS_MEJOR_OPCION';
      INSERT INTO Scfr_Mov_Productos_Mejor_Opcion
        (Prt_Codigo_Detalle
        ,Txo_Codigo_Tx
        ,Txo_Correlativo_Tx
        ,Pro_Codigo_Interno
        ,Sku_Original
        ,Regla_Calculo
        ,Sku_Sugerido
        ,Id_Combinacion
        ,Decision_Cliente
        ,Emp_Empresa
        ,Cad_Cadena
        ,Loc_Local)
      VALUES
        (p_Codigo_Detalle
        ,p_Transaccion.Codigo_Tx
        ,p_Trama_Dv.Correlativo_Tx
        ,p_Trama_Pm.Producto
        ,p_Trama_Pm.Subtrama_Pm7(l_Itm).Sku_Original
        ,TRIM(p_Trama_Pm.Subtrama_Pm7(l_Itm).Regla_Calculo)
        ,p_Trama_Pm.Subtrama_Pm7(l_Itm).Sku_Sugerido
        ,TRIM(p_Trama_Pm.Subtrama_Pm7(l_Itm).Id_Combinacion)
        ,TRIM(p_Trama_Pm.Subtrama_Pm7(l_Itm).Decision_Cliente)
        ,p_Transaccion.Trama_Pos.Empresa
        ,p_Transaccion.Trama_Pos.Cadena
        ,p_Transaccion.Trama_Pos.Local);
    END LOOP;
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Trama PM7 (Mejor Opcion) resuelta correctamente');
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  PROCEDURE Trama_Pm_Prds_Controlados(p_Transaccion    IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                     ,p_Trama_Pm       IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pm
                                     ,p_Trama_Dv       IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                                     ,p_Codigo_Detalle IN NUMBER
                                     ,x_Cod_Error      OUT NUMBER
                                     ,x_Msg_Error      OUT NUMBER) IS
    l_Itm              NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.Trama_Pm_Prds_Controlados';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    x_Cod_Error   := 0;
    l_Dbg_Mensaje := 'Recorrer detalle de la subtrama PM8 (Productos Controlados)';
    FOR l_Itm IN 1 .. p_Trama_Pm.Subtrama_Pm8.Count
    LOOP
      l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_PRODUCTOS_CONTROLADOS';
      INSERT INTO Scfr_Mov_Productos_Controlados
        (Prt_Codigo_Detalle
        ,Txo_Codigo_Tx
        ,Txo_Correlativo_Tx
        ,Pro_Codigo_Interno
        ,Folio_Receta
        ,Ced_Prof
        ,Nombre_Medico
        ,Calle
        ,Colonia
        ,Cod_Postal
        ,Ciudad
        ,Municipio
        ,Folio_Correlativo
        ,Emp_Empresa
        ,Cad_Cadena
        ,Loc_Local)
      VALUES
        (p_Codigo_Detalle
        ,p_Transaccion.Codigo_Tx
        ,p_Trama_Dv.Correlativo_Tx
        ,p_Trama_Pm.Producto
        ,TRIM(p_Trama_Pm.Subtrama_Pm8(l_Itm).Folio_Receta)
        ,TRIM(p_Trama_Pm.Subtrama_Pm8(l_Itm).Ced_Prof)
        ,TRIM(p_Trama_Pm.Subtrama_Pm8(l_Itm).Nombre_Medico)
        ,TRIM(p_Trama_Pm.Subtrama_Pm8(l_Itm).Calle)
        ,TRIM(p_Trama_Pm.Subtrama_Pm8(l_Itm).Colonia)
        ,TRIM(p_Trama_Pm.Subtrama_Pm8(l_Itm).Cod_Postal)
        ,TRIM(p_Trama_Pm.Subtrama_Pm8(l_Itm).Ciudad)
        ,TRIM(p_Trama_Pm.Subtrama_Pm8(l_Itm).Municipio)
        ,TRIM(p_Trama_Pm.Subtrama_Pm8(l_Itm).Folio_Correlativo)
        ,p_Transaccion.Trama_Pos.Empresa
        ,p_Transaccion.Trama_Pos.Cadena
        ,p_Transaccion.Trama_Pos.Local);
    END LOOP;
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Trama PM8 (Productos Controlados) resuelta correctamente');
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  PROCEDURE Trama_Pm_Agrega_Ptos_Gan(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                    ,x_Cod_Error   OUT NUMBER
                                    ,x_Msg_Error   OUT VARCHAR2) IS
    CURSOR c_Puntos IS
      SELECT Mdo.Folio Folio_Docto
            ,SUM(Mpp.Puntos_Generados) Total_x_Docto
        FROM Scfr_Mov_Documentos_Txs       Mdo
            ,Scfr_Mov_Productos_Documentos Mpd
            ,Scfr_Mov_Puntos_Productos     Mpp
       WHERE Mdo.Txo_Codigo_Tx = p_Transaccion.Codigo_Tx -- todos los documentos
         AND Mdo.Puntos_Asignados = 'S' -- que SI asignen puntos
         AND Mdo.Tmo_Movimiento != 'VENDIC' -- que no sean VENDIC
         AND Mdo.Mov_Documentos = Mpd.Dte_Mov_Documentos -- que tengan productos referenciados
         AND Mpd.Mov_Productos_Documentos = Mpp.Mov_Productos_Documentos -- que tengan puntos ganados x docto
         AND Mpd.Pro_Codigo_Interno = Mpp.Pro_Codigo_Interno -- solo del producto
       GROUP BY Mdo.Folio; -- agrupados por documento emitido
    l_Campana_Puntos   NUMBER;
    l_Id_Pto           NUMBER;
    l_Accion_Puntos    VARCHAR2(3);
    l_String           VARCHAR2(1000);
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_pm_agrega_ptos_gan';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    l_Puntos_Ganados   NUMBER := 0;
    l_Ind_Cta_Cte      NUMBER;
    l_Folio_Docto      NUMBER;
  BEGIN
    x_Cod_Error      := 0;
    l_Dbg_Mensaje    := 'Obtener campa?a generica de puntos';
    l_Campana_Puntos := Scfr_Trx_Gnc_Utl_Pk.Obtiene_Campana_Puntos(p_Transaccion.Trama_Pos.Empresa
                                                                  ,p_Transaccion.Trama_Pos.Cadena);
    l_Dbg_Mensaje    := 'Recorrer detalle de puntos por documento';
    FOR Reg_Ptos IN c_Puntos
    LOOP
      l_Dbg_Mensaje := 'LLamar a scfr_trx_puntos_pk.registra_apg';
      Scfr_Trx_Puntos_Pk.Setea_Local_Trx(p_Transaccion.Trama_Pos.Local);
      l_Id_Pto         := Scfr_Trx_Puntos_Pk.Registra_Apg(p_Party_Id     => NULL --p_transaccion.trama_boc.party_id
                                                         ,p_Rut_Titular  => p_Transaccion.Rut_Titular
                                                         ,p_Puntos       => Reg_Ptos.Total_x_Docto
                                                         ,p_Codigo_Tx    => p_Transaccion.Codigo_Tx
                                                         ,p_Numero_Docto => Reg_Ptos.Folio_Docto
                                                         ,p_Campana      => l_Campana_Puntos
                                                         ,p_Empresa      => p_Transaccion.Trama_Pos.Empresa
                                                         ,p_Cadena       => p_Transaccion.Trama_Pos.Cadena
                                                         ,p_Fecha        => p_Transaccion.Fecha_Tx
                                                         ,p_Vendedor     => p_Transaccion.Trama_Pos.Usuario_Responsable
                                                         ,p_Local        => p_Transaccion.Trama_Pos.Local
                                                         ,x_Cod_Error    => x_Cod_Error
                                                         ,x_Msg_Error    => x_Msg_Error);
      l_Puntos_Ganados := l_Puntos_Ganados + Reg_Ptos.Total_x_Docto;
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  PROCEDURE Trama_Pm_Agrega_Ptos_Can(p_Transaccion      IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                    ,p_Puntos_Canjeados IN Scfr_Trx_Gnc_Pk.Tab_Puntos_Canjeados
                                    ,x_Cod_Error        OUT NUMBER
                                    ,x_Msg_Error        OUT VARCHAR2) IS
    l_Campana_Puntos   NUMBER;
    l_Itm              NUMBER;
    l_Id_Pto           NUMBER;
    l_String           VARCHAR2(1000);
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_pm_agrega_ptos_can';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    x_Cod_Error      := 0;
    l_Dbg_Mensaje    := 'Obtener campa?a generica de puntos';
    l_Campana_Puntos := Scfr_Trx_Gnc_Utl_Pk.Obtiene_Campana_Puntos(p_Transaccion.Trama_Pos.Empresa
                                                                  ,p_Transaccion.Trama_Pos.Cadena);
    l_Dbg_Mensaje    := 'Recorre detalle de puntos canjeados por Documento';
    FOR l_Itm IN 1 .. p_Puntos_Canjeados.Count
    LOOP
      IF p_Transaccion.Trama_Boc.Party_Id > 0 THEN
        l_Dbg_Mensaje := 'Llamar a scfr_trx_puntos_pk.registra_can';
        Scfr_Trx_Puntos_Pk.Setea_Local_Trx(p_Transaccion.Trama_Pos.Local);
        l_Id_Pto := Scfr_Trx_Puntos_Pk.Registra_Can(p_Party_Id     => NULL --p_transaccion.trama_boc.party_id
                                                   ,p_Rut_Titular  => p_Transaccion.Rut_Titular
                                                   ,p_Puntos       => p_Puntos_Canjeados(l_Itm).Total_Puntos
                                                   ,p_Codigo_Tx    => p_Transaccion.Codigo_Tx
                                                   ,p_Numero_Docto => p_Puntos_Canjeados(l_Itm).Folio
                                                   ,p_Campana      => l_Campana_Puntos
                                                   ,p_Empresa      => p_Transaccion.Trama_Pos.Empresa
                                                   ,p_Cadena       => p_Transaccion.Trama_Pos.Cadena
                                                   ,p_Fecha        => p_Transaccion.Fecha_Tx
                                                   ,p_Vendedor     => p_Transaccion.Trama_Pos.Usuario_Responsable
                                                   ,p_Local        => p_Transaccion.Trama_Pos.Local
                                                   ,x_Cod_Error    => x_Cod_Error
                                                   ,x_Msg_Error    => x_Msg_Error);
      END IF;
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  /*
    procedure trama_pm_inventario( p_transaccion in  scfr_trx_dyn_pk.rec_transaccion
                                 , p_trama_pm    in  scfr_trx_dyn_types_pk.rec_trama_pm
                                 , p_trama_dv    in  scfr_trx_dyn_types_pk.rec_trama_dv
                                 , p_tipo_trx    in  varchar2  -- puede ser 'GNCU01' o 'GNCU02'
                                 , p_item        in  number
                                 , x_cod_error   out number
                                 , x_msg_error   out varchar2 )
    is
      l_datos_inventario scfr_trx_exc_pk.t_datos_inventario;
      l_auxiliar         blob;
      l_mov_hijo         varchar2(6);
      l_estado           varchar2(10);
      l_campana_puntos   number;
      l_signo_local      number;
      l_folio_docto      number;
      l_string           varchar2(1000);
      l_DBG_PROCESO      varchar2(100) := 'SCFR_TRX_GNC_PK.trama_pm_inventario';
      l_DBG_MENSAJE      varchar2(250) := 'Error General';
      l_ERROR_CONTROLADO exception;
    begin
      l_DBG_MENSAJE := 'Obtener folio del documento en donde se imprimio el producto';
      select mdo.folio
           , mdo.tmo_movimiento
        into l_folio_docto
           , l_mov_hijo
        from scfr_mov_productos_documentos mpd
           , scfr_mov_documentos_txs       mdo
       where mpd.txo_codigo_tx      = p_transaccion.codigo_tx
         and mpd.pro_codigo_interno = p_trama_pm.producto
         and mpd.impreso_en_boleta  = 'SI'
         and mpd.dte_mov_documentos = mdo.mov_documentos;
  
      l_DBG_MENSAJE := 'Poblar estructura de datos para registrar movimiento de existencia';
      scfr_trx_exc_pk.poblar_tipo( p_trx_pos           => p_tipo_trx                       --in  varchar2
                                 , p_tipo              => 'Ventas'                         --in  varchar2
                                 , p_empresa           => p_transaccion.trama_pos.empresa  --in  number
                                 , p_cadena            => p_transaccion.trama_pos.cadena   --in  number
                                 , p_padre             => p_trama_dv.tipo_movimiento_padre --in  varchar2
                                 , p_hijo              => l_mov_hijo                       --in  varchar2 default null
                                 , p_motivo            => 'N/A'                            --in  varchar2
                                 , p_correlativo       => p_transaccion.correlativo_tx     --in  number
                                 , p_nro_cliente       => null                             --in  varchar2
                                 , p_nro_factura       => p_transaccion.codigo_tx          --in  varchar2  ASV
                                 , p_codigo_local      => p_transaccion.trama_pos.local    --in  number
                                 , p_codigo_sucursal   => p_transaccion.trama_pos.local    --in  number
                                 , p_producto          => p_trama_pm.producto              --in  number
                                 , p_correlativo_prod  => p_item                           --in  number
                                 , p_cantidad          => -1 * p_trama_pm.cantidad         --in  number
                                 , p_item              => ltrim(rtrim(to_char(p_trama_pm.producto,'000009'))) --in  number
                                 , p_precio_venta      => p_trama_pm.precio_final          --in  number
                                 , p_convenio          => null                             --in  number
                                 , p_desctos_aplicados => 0                                --in  number
                                 , p_glosa_reclamo     => null                             --in  varchar2
                                 , p_numero_vendedor   => '0'                              --in  varchar2
                                 , p_fecha_transaccion => to_date( p_transaccion.trama_pos.fecha_hora_contable, 'yyyy/mm/dd' ) --in  date
                                 , p_last_update_date  => to_date( p_transaccion.trama_pos.fecha_hora_contable, 'yyyy/mm/dd' ) --in  date
                                 , p_last_updated_by   => 0                                --in  number
                                 , p_creation_date     => to_date( p_transaccion.trama_pos.fecha_hora_contable, 'yyyy/mm/dd' ) --in  date
                                 , p_created_by        => 0                                --in  number
                                 , x_signo_local       => l_signo_local                    --out number
                                 , x_datos_inventario  => l_datos_inventario               --out t_datos_inventario
                                 );
  
      l_DBG_MENSAJE := 'Registrar movimiento de existencia - scfr_trx_exc_pk.insert_row()';
      begin
        scfr_trx_exc_pk.insert_row( p_status           => l_estado           --in  out varchar2
                                  , p_datos_inventario => l_datos_inventario --in  scfr_exc_pk.t_datos_inventario
                                  , x_cod_error        => x_cod_error        --out number
                                  , x_msg_error        => x_msg_error        --out varchar2
                                  );
      exception
        when others then
          scfr_trx_util_pk.debug_msg(p_proceso=>l_DBG_PROCESO, p_msg=>'Error al intentar '||l_DBG_MENSAJE );
      end;
  
      l_DBG_MENSAJE := 'Actualizar Stock en Linea';
      scfr_trx_exc_pk.ActualizaStockEnLinea( 0
                                           , l_datos_inventario
                                           , p_trama_pm.producto
                                           , p_transaccion.trama_pos.empresa
                                           , p_transaccion.trama_pos.cadena
                                           , p_transaccion.trama_pos.local
                                           , ( p_trama_pm.cantidad * l_signo_local )
                                           , p_transaccion.codigo_tx
                                           , l_auxiliar
                                           );
      x_cod_error := 0;
    exception
      when others then
        scfr_trx_util_pk.debug_msg(p_proceso=>l_DBG_PROCESO, p_msg=>'Error al intentar '||l_DBG_MENSAJE );
        x_cod_error := 0;
    end;
  */
  PROCEDURE Trama_Pm_Resuelve(p_Transaccion  IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,p_Doc_Emitidos IN Scfr_Trx_Gnc_Pk.Tab_Doc_Emitidos
                             ,p_Trama_Dv     IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                             ,p_Tipo_Tx      IN VARCHAR2
                             ,x_Rut_Vendedor OUT NUMBER
                             ,x_Dv_Vendedor  OUT VARCHAR2
                             ,x_Cod_Error    OUT NUMBER
                             ,x_Msg_Error    OUT VARCHAR2) IS
    l_Productos_Ordenados Tab_Productos;
    l_Trama_Pm            Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm;
    --l_trama_dv            scfr_trx_dyn_types_pk.rec_trama_dv;
    l_Codigo_Personal  Scfr_Mov_Productos_Txs.Per_Codigo_Personal%TYPE;
    l_Codigo_Detalle   Scfr_Mov_Productos_Txs.Codigo_Detalle%TYPE;
    l_Codigo_Interno   Scfr_Mov_Productos_Txs.Pro_Codigo_Interno%TYPE;
    l_Categoria        Scfr_Mov_Productos_Txs.Cat_Categoria%TYPE;
    l_Id_Relacion      NUMBER;
    l_Itm              NUMBER;
    l_Pos              NUMBER;
    l_Puntos_Canjeados Scfr_Trx_Gnc_Pk.Tab_Puntos_Canjeados;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_pm_resuelve';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    l_Cantidad         Scfr_Mov_Productos_Txs.Cantidad%TYPE;
    l_Precio_Final     Scfr_Mov_Productos_Txs.Precio_Final%TYPE;
    l_Party_Id_Rel     NUMBER;
    l_Datos_Inventario Scfr_Trx_Exc_Pk.t_Datos_Inventario;
    l_Auxiliar         BLOB;
    l_Signo            NUMBER;
    l_Es_Loyalty       BOOLEAN;
    l_Respuesta        NUMBER;
    l_Mensaje          VARCHAR2(250);
    l_Ajuste_Cia       NUMBER(1) := 0;
    l_Pro_Ajuste_Cia   NUMBER;
  BEGIN
    --
    -- LMP 2023 Ecuador GPF
    --   
    --//--------------------------------------------------------------------------\\
    --// CBR 13/08/2018 10:20                                                     \\
    --// BIFURCAR EMPRESA MAICAO EN GNCC01                                        \\
    --//-----------------------------------------------------------------Inicio---\\
    l_Es_Loyalty := FALSE;
  
    IF Es_Consulta_Loyalty(p_Transaccion.Trama_Pos.Empresa
                          ,p_Transaccion.Trama_Pos.Cadena
                          ,p_Transaccion.Trama_Pos.Local) = 'SI' THEN
      l_Es_Loyalty := TRUE;
    END IF;
  
    BEGIN
      l_Pro_Ajuste_Cia := To_Number(Scfr_Trx_Util_Pk.Det_Valor_Parametro_Por_Cod('PROAJUCIA'));
      IF (l_Pro_Ajuste_Cia = 0) THEN
        l_Pro_Ajuste_Cia := 297475;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        l_Pro_Ajuste_Cia := 297475;
    END;
  
    --//-----------------------------------------------------------------Termino--\\
    x_Cod_Error := 0;
    -- -- Obtiene informacion de la trama DV
    -- l_DBG_MENSAJE := 'Obtener informacion de la trama DV';
    -- l_trama_dv    := scfr_trx_dyn_utl_pk.carga_trama_dv(p_Transaccion.Trama_Pos,p_transaccion.cuerpo_tx );
    -- Obtiene informacion de la trama PM
    l_Dbg_Mensaje := 'Obtener informacion de la trama PM';
    --RESUELVE
    l_Trama_Pm := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Pm(p_Transaccion.Trama_Pos
                                                    ,p_Transaccion.Cuerpo_Tx);
    -- Verifica si cliente es fidelizado o no
    l_Party_Id_Rel := Scfr_Trx_Util_Pk.Busca_Party_Id_Relacion(p_Transaccion.Trama_Boc.Party_Id
                                                              ,Scfr_Trx_Util_Pk.Obtiene_Party_Id(Scfr_Trx_Util_Pk.Rut_Con_Org_Id(p_Transaccion.Trama_Pos.Empresa
                                                                                                                                ,Scfr_Trx_Util_Pk.Instancia))
                                                              ,'ES_FIDELIZADO'
                                                              ,p_Transaccion.Trama_Pos.Empresa
                                                              ,l_Id_Relacion);
    -- Verifica que los descuentos esten al final del detalle de productos
    -- de caso contrario se reordenan (NO SE EVALUO SI ESTO PODRIA PROVOCAR ERRORES EN OTRA PARTE)
    l_Productos_Ordenados := Scfr_Trx_Gnc_Utl_Pk.Ordena_Productos(l_Trama_Pm);
    -- Recorre detalle de productos
    l_Dbg_Mensaje := 'Recorrer detalle de la trama PM (productos)';
    --for l_itm in 1..l_trama_pm.count loop
    --nuevo ASV
    FOR l_Pos IN 1 .. l_Productos_Ordenados.Count
    LOOP
      l_Itm := l_Productos_Ordenados(l_Pos);
      --fin nuevo ASV
      -- Obtiene codigo personal del vendedor
      BEGIN
        SELECT Codigo_Personal INTO l_Codigo_Personal FROM Scfr_Personal WHERE Rut_Personal = l_Trama_Pm(l_Itm).Rut_Vendedor;
      EXCEPTION
        WHEN OTHERS THEN
          l_Codigo_Personal := 0;
      END;
      -- Devolver Rut Vendedor
      IF Nvl(x_Rut_Vendedor
            ,0) = 0 THEN
        x_Rut_Vendedor := l_Trama_Pm(l_Itm).Rut_Vendedor;
        x_Dv_Vendedor  := l_Trama_Pm(l_Itm).Dv_Rut_Vendedor;
        
        x_Rut_Vendedor := TO_NUMBER(REGEXP_REPLACE(l_Trama_Pm(l_Itm).Identi_Vendedor, '[^0-9]', '')); --JAGC NEC 20250306
        x_Dv_Vendedor := TO_CHAR(MOD(x_Rut_Vendedor, 10)); --JAGC NEC 20250306
      END IF;
      -- Obtiene id para la tabla scfr_mov_productos_txs
      l_Dbg_Mensaje := 'Obtener folio para la tabla SCFR_MOV_PRODUCTOS_TXS';
      SELECT Scfr_Mov_Productos_Txs_s.Nextval INTO l_Codigo_Detalle FROM Dual;
      -- Obtiene codigo y categoria de productos
      l_Codigo_Interno := Scfr_Trx_Util_Pk.Parche_Producto(p_Transaccion.Trama_Pos.Empresa
                                                          ,l_Trama_Pm(l_Itm).Producto);
      l_Categoria      := Scfr_Trx_Util_Pk.Cat_Prod(p_Transaccion.Trama_Pos.Empresa
                                                   ,Scfr_Trx_Util_Pk.Parche_Producto(p_Transaccion.Trama_Pos.Empresa
                                                                                    ,l_Trama_Pm(l_Itm).Producto));
      IF (l_Codigo_Interno = l_Pro_Ajuste_Cia) THEN
        l_Ajuste_Cia := 1;
      END IF;
      -- Determinar el valor de Precio_Final y Cantidad
      l_Dbg_Mensaje := 'Calcular valores para el Precio Final y la Cantidad';
      IF l_Trama_Pm(l_Itm).Accion_Sobre_Existencia = 'E' THEN
        l_Precio_Final := l_Trama_Pm(l_Itm).Precio_Final * -1;
        l_Cantidad     := l_Trama_Pm(l_Itm).Cantidad * -1;
        l_Signo        := 1;
      ELSIF l_Trama_Pm(l_Itm).Accion_Sobre_Existencia = 'S' THEN
        l_Precio_Final := l_Trama_Pm(l_Itm).Precio_Final;
        l_Cantidad     := l_Trama_Pm(l_Itm).Cantidad;
        l_Signo        := -1;
      ELSE
        l_Precio_Final := l_Trama_Pm(l_Itm).Precio_Final;
        l_Cantidad     := l_Trama_Pm(l_Itm).Cantidad;
        l_Signo        := 1;
      END IF;
      IF l_Trama_Pm(l_Itm).Exento_Iva = '-1' THEN
        l_Trama_Pm(l_Itm).Exento_Iva := NULL;
      END IF;
      IF l_Trama_Pm(l_Itm).Controla_Stock = '-1' THEN
        l_Trama_Pm(l_Itm).Controla_Stock := NULL;
      END IF;
      IF l_Trama_Pm(l_Itm).Permite_Devolucion = '-1' THEN
        l_Trama_Pm(l_Itm).Permite_Devolucion := NULL;
      END IF;
      -- inserta en tabla scfr_mov_productos_txs
      l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_PRODUCTOS_TXS';
      INSERT INTO Scfr_Mov_Productos_Txs
        (Codigo_Detalle
        ,Txo_Codigo_Tx
        ,Pt_Party_Id_Titular
        ,Pro_Codigo_Interno
        ,Cat_Categoria
        ,Txo_Correlativo_Tx
        ,Per_Codigo_Personal
        ,Pro_Precio_Lista
        ,Precio_Final
        ,Cantidad
        ,Per_Rut_Vendedor
        ,Per_Dv_Vendedor
        ,Tipo_Identi_Vendedor
        ,Identi_Vendedor
        ,Costo
        ,Codigo_Barra
        ,Emp_Empresa
        ,Cad_Cadena
        ,Loc_Local
        ,Tipo_Alta_Baja
        ,Cantidad_Acumulada_Psalud
        ,Consejo_Aplicado
        ,Accion_Sobre_Existencia
        ,Permitido_Por_Cnv
        ,Puf_Uso_Frecuente
        ,Campana_Promocion
        ,Campana_Aditiva
        ,Pendiente_Beneficio_Ps
        ,Exento_Iva
        ,Controla_Stock
        ,Permite_Devolucion
        ,Producto_Demandado
        ,Deduccion
        ,Nombre_Vendedor -- JAGC NEC 20240909
        )
      VALUES
        (l_Codigo_Detalle -- codigo_detalle
        ,p_Transaccion.Codigo_Tx -- txo_codigo_tx
        ,p_Transaccion.Trama_Boc.Party_Id -- pt_party_id_titular
        ,l_Codigo_Interno -- pro_codigo_interno
        ,l_Categoria -- cat_categoria
        ,p_Transaccion.Correlativo_Tx -- txo_correlativo_tx
        ,l_Codigo_Personal -- per_codigo_personal
        ,l_Trama_Pm(l_Itm).Precio_Lista -- pro_precio_lista
        ,l_Precio_Final -- precio_final
        ,l_Cantidad -- cantidad
        ,l_Trama_Pm(l_Itm).Rut_Vendedor -- per_rut_vendedor
        ,l_Trama_Pm(l_Itm).Dv_Rut_Vendedor -- scfr_trx_util_pk.dv_rut( l_trama_pm(l_itm).rut_vendedor ) -- per_dv_vendedor
        ,Substr(l_Trama_Pm(l_Itm).Identi_Vendedor
               ,1
               ,1)
        ,Substr(l_Trama_Pm(l_Itm).Identi_Vendedor
               ,2
               ,30)
        ,l_Trama_Pm(l_Itm).Costo_Unitario -- costo
        ,l_Trama_Pm(l_Itm).Codigo_Barra -- codigo barra
        ,p_Transaccion.Trama_Pos.Empresa -- emp_empresa
        ,p_Transaccion.Trama_Pos.Cadena -- cad_cadena
        ,p_Transaccion.Trama_Pos.Local -- loc_local
        ,'BAJA' -- tipo_alta_baja
        ,l_Trama_Pm(l_Itm).Cantidad_Acumulada_Psalud
        ,l_Trama_Pm(l_Itm).Numero_Consejo
        ,l_Trama_Pm(l_Itm).Accion_Sobre_Existencia
        ,l_Trama_Pm(l_Itm).Permitido_Por_Convenio
        ,l_Trama_Pm(l_Itm).Uso_Frecuente
        ,l_Trama_Pm(l_Itm).Campana_Promocion
        ,l_Trama_Pm(l_Itm).Campana_Aditiva
        ,l_Trama_Pm(l_Itm).Beneficio_Pendiente_Ps
        ,l_Trama_Pm(l_Itm).Exento_Iva
        ,l_Trama_Pm(l_Itm).Controla_Stock
        ,l_Trama_Pm(l_Itm).Permite_Devolucion
        ,l_Trama_Pm(l_Itm).Producto_Original_Demandado
        ,l_Trama_Pm(l_Itm).Deduccion_Producto
        ,l_Trama_Pm(l_Itm).Nombre_Vendedor -- JAGC NEC 20240909
        );
      
      DBMS_OUTPUT.PUT_LINE('Recorre Impuestos Aplicados');   
      DBMS_OUTPUT.PUT_LINE('p_Transaccion.Correlativo_Tx: ' || p_Transaccion.Correlativo_Tx);      
      -- Recorre Impuestos Aplicados
      Trama_Pm_Impuestos_Aplicados(p_Transaccion
                                  ,l_Trama_Pm(l_Itm) -- envio solo los datos de un producto y no todo el detalle
                                  --,p_Trama_Dv --l_trama_dv
                                  ,p_Transaccion.Correlativo_Tx
                                  ,l_Codigo_Detalle
                                  ,x_Cod_Error
                                  ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;  
      
      --Recorre subtrama documentos de referencia
      Scfr_Trx_Gnc_Utl_Pk.Trama_Pm_Doctos_Referencia(p_Transaccion
                                                    ,l_Trama_Pm(l_Itm)
                                                    ,p_Trama_Dv
                                                    ,p_Doc_Emitidos
                                                    ,l_Codigo_Detalle
                                                    ,p_Tipo_Tx
                                                    ,x_Cod_Error
                                                    ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
      -- Recorre descuentos aplicados
      Trama_Pm_Desctos_Aplicados(p_Transaccion
                                ,l_Trama_Pm(l_Itm)
                                ,p_Trama_Dv
                                ,l_Codigo_Detalle
                                ,'UTI'
                                ,p_Tipo_Tx
                                ,l_Puntos_Canjeados
                                ,x_Cod_Error
                                ,x_Msg_Error); --out
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
      -- Acumula los puntos canjeados de todos los productos
      --l_tot_ptos_canjeados := l_tot_ptos_canjeados + l_puntos_canjeados;
      -- Recorre puntos generados
      Trama_Pm_Puntos_Generados(p_Transaccion
                               ,l_Trama_Pm(l_Itm) -- envio solo los datos de un producto y no todo el detalle
                               ,l_Codigo_Detalle
                               ,p_Tipo_Tx
                               ,x_Cod_Error
                               ,x_Msg_Error);                                          
                               
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;      
      
      -- INI JAGC NEC 20240909                         
      Trama_Pm_Eventos_Perdidos(p_Transaccion
                               ,l_Trama_Pm(l_Itm) -- envio solo los datos de un producto y no todo el detalle
                               ,l_Codigo_Detalle
                               ,p_Tipo_Tx
                               ,x_Cod_Error
                               ,x_Msg_Error);                                           
                               
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;     
      -- FIN JAGC NEC 20240909  
      
      -- Recorre distribucion convenios
      Trama_Pm_Distrib_Convenios(p_Transaccion
                                ,l_Trama_Pm(l_Itm) -- envio solo los datos de un producto y no todo el detalle
                                ,p_Trama_Dv --l_trama_dv
                                ,l_Codigo_Detalle
                                ,x_Cod_Error
                                ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    
      -- Recorre Recargas y Telepeajes
      Trama_Pm_Recargas_Telepeajes(p_Transaccion
                                  ,l_Trama_Pm(l_Itm) -- envio solo los datos de un producto y no todo el detalle
                                  ,p_Trama_Dv --l_trama_dv
                                  ,l_Codigo_Detalle
                                  ,p_Tipo_Tx
                                  ,x_Cod_Error
                                  ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    
      -- Recorre Mejor Opcion
      Trama_Pm_Mejor_Opcion(p_Transaccion
                           ,l_Trama_Pm(l_Itm) -- envio solo los datos de un producto y no todo el detalle
                           ,p_Trama_Dv --l_trama_dv
                           ,l_Codigo_Detalle
                           ,x_Cod_Error
                           ,x_Msg_Error);
    
      -- Recorre Productos Controlados
      Trama_Pm_Prds_Controlados(p_Transaccion
                               ,l_Trama_Pm(l_Itm) -- envio solo los datos de un producto y no todo el detalle
                               ,p_Trama_Dv --l_trama_dv
                               ,l_Codigo_Detalle
                               ,x_Cod_Error
                               ,x_Msg_Error);
    
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    
      IF l_Trama_Pm(l_Itm).Accion_Sobre_Existencia IN ('E'
                                     ,'S') THEN
        l_Dbg_Mensaje := 'Actualizar Stock en Linea';
        Scfr_Trx_Exc_Pk.Actualizastockenlinea(0
                                             ,l_Datos_Inventario
                                             ,l_Trama_Pm                     (l_Itm).Producto
                                             ,p_Transaccion.Trama_Pos.Empresa
                                             ,p_Transaccion.Trama_Pos.Cadena
                                             ,p_Transaccion.Trama_Pos.Local
                                             ,l_Trama_Pm                     (l_Itm).Cantidad * l_Signo
                                             ,p_Transaccion.Codigo_Tx
                                             ,l_Auxiliar);
      END IF;
      /*
            -- Actualiza Inventario
            trama_pm_inventario( p_transaccion
                               , l_trama_pm(l_itm)
                               , p_trama_dv    --l_trama_dv
                               , p_tipo_tx   --'GNCU01'
                               , l_itm
                               , x_cod_error
                               , x_msg_error );
            if nvl(x_cod_error,0) != 0 then
              raise l_ERROR_CONTROLADO;
            end if;
      */
    END LOOP;
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'party id cliente=>' || Nvl(p_Transaccion.Trama_Boc.Party_Id
                                                                       ,0));
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'party id relacion=>' || Nvl(l_Party_Id_Rel
                                                                        ,0));
    -- Agrega movimientos para puntos ganados por documento (SOLO SI CLIENTE SE FIDELIZO)
    -- JRG 18012016                                                                                                                     'ES_FIDELIZADO',
    IF (Nvl(l_Party_Id_Rel
           ,0) <= 0) THEN
      BEGIN
        SELECT Party_Id
          INTO l_Party_Id_Rel
          FROM Scfr_Tmp_Clientes
         WHERE Rut = p_Transaccion.Rut_Titular
           AND Inscrito_Mas_Cruz_Verde = 'S';
      EXCEPTION
        WHEN No_Data_Found THEN
          l_Party_Id_Rel := -1;
      END;
    END IF; -- if (Nvl(l_Party_Id_Rel   ,0) > 0) then
    IF (l_Es_Loyalty = TRUE AND l_Puntos_Canjeados.Count > 0) OR
       (l_Puntos_Canjeados.Count > 0 AND Nvl(p_Transaccion.Trama_Boc.Party_Id
                                            ,0) != 0 AND l_Party_Id_Rel > 0) THEN
      -- Agrega movimiento para puntos canjeados
      Trama_Pm_Agrega_Ptos_Can(p_Transaccion
                              ,l_Puntos_Canjeados
                              ,x_Cod_Error
                              ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    END IF;
    IF (Nvl(p_Transaccion.Trama_Boc.Party_Id
           ,0) != 0 AND l_Party_Id_Rel > 0) OR
       (l_Es_Loyalty = TRUE) THEN
      Trama_Pm_Agrega_Ptos_Gan(p_Transaccion
                              ,x_Cod_Error
                              ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    END IF;
  
    IF p_Tipo_Tx IN ('GNCU01'
                    ,'GNCU02') AND
       (l_Ajuste_Cia = 1) THEN
      -- Aplica ajuste GUIA compania seguros
      UPDATE Scfr_Mov_Productos_Txs
         SET (Pro_Precio_Lista
            ,Precio_Final) =
             (SELECT (Precio_Final +
                     (Scfr_Mov_Documentos_Txs.Monto -
                     (SELECT SUM(Pro2.Precio_Final) FROM Scfr_Mov_Productos_Txs Pro2 WHERE Pro2.Txo_Codigo_Tx = Scfr_Mov_Transacciones.Codigo_Tx)))
                    ,(Precio_Final +
                     (Scfr_Mov_Documentos_Txs.Monto -
                     (SELECT SUM(Pro2.Precio_Final) FROM Scfr_Mov_Productos_Txs Pro2 WHERE Pro2.Txo_Codigo_Tx = Scfr_Mov_Transacciones.Codigo_Tx)))
                FROM Scfr_Mov_Transacciones
                    ,Scfr_Mov_Documentos_Txs
               WHERE Scfr_Mov_Transacciones.Codigo_Tx = Scfr_Mov_Documentos_Txs.Txo_Codigo_Tx
                 AND Tmo_Movimiento IN ('VENGUI'
                                       ,'ANUGUI')
                 AND Scfr_Mov_Transacciones.Codigo_Tx = Scfr_Mov_Productos_Txs.Txo_Codigo_Tx)
       WHERE Txo_Codigo_Tx = p_Transaccion.Codigo_Tx
         AND Pro_Codigo_Interno = l_Pro_Ajuste_Cia;
    END IF;
  
    --//--------------------------------------------------------------------------\\
    --// CBR 22/08/2018 11:55                                                     \\
    --// EMPRESA MAICAO GESTIONA SUS PROPIOS PUNTOS                               \\
    --//-----------------------------------------------------------------Inicio---\\
    IF (l_Es_Loyalty = TRUE) AND
       p_Tipo_Tx IN ('GNCU01'
                    ,'GNCU05'
                    ,'GNCU02'
                    ,'GNCU06') THEN
      Scfr_Trx_Puntos_Pk.Informa_Puntos_Loyalty(p_Transaccion
                                               ,p_Tipo_Tx
                                               ,x_Cod_Error
                                               ,x_Msg_Error);
    END IF;
    --//-----------------------------------------------------------------Termino--\\
  
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Trama PM resuelta correctamente');
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  PROCEDURE Trama_Pm_Resuelve(p_Transaccion  IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,p_Doc_Emitidos IN Scfr_Trx_Gnc_Pk.Tab_Doc_Emitidos
                             ,p_Trama_Dv     IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                             ,p_Tipo_Tx      IN VARCHAR2
                             ,x_Cod_Error    OUT NUMBER
                             ,x_Msg_Error    OUT VARCHAR2) IS
    l_Rut_Vendedor NUMBER;
    l_Dv_Vendedor  VARCHAR2(1);
  BEGIN
    Trama_Pm_Resuelve(p_Transaccion
                     ,p_Doc_Emitidos
                     ,p_Trama_Dv
                     ,p_Tipo_Tx
                     ,l_Rut_Vendedor
                     ,l_Dv_Vendedor
                     ,x_Cod_Error
                     ,x_Msg_Error);
  END Trama_Pm_Resuelve;

  PROCEDURE Trama_Pm_Reversa(p_Transaccion  IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                            ,p_Doc_Emitidos IN Scfr_Trx_Gnc_Pk.Tab_Doc_Emitidos
                            ,p_Trama_Dv     IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                            ,p_Tipo_Tx      IN VARCHAR2
                            ,x_Cod_Error    OUT NUMBER
                            ,x_Msg_Error    OUT VARCHAR2) IS
    l_Trama_Pm         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm;
    l_Trama_Dv         Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv;
    l_Codigo_Personal  Scfr_Mov_Productos_Txs.Per_Codigo_Personal%TYPE;
    l_Codigo_Detalle   Scfr_Mov_Productos_Txs.Codigo_Detalle%TYPE;
    l_Codigo_Interno   Scfr_Mov_Productos_Txs.Pro_Codigo_Interno%TYPE;
    l_Categoria        Scfr_Mov_Productos_Txs.Cat_Categoria%TYPE;
    l_Itm              NUMBER;
    l_Puntos_Canjeados Scfr_Trx_Gnc_Pk.Tab_Puntos_Canjeados;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_pm_reversa';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    l_Cantidad         Scfr_Mov_Productos_Txs.Cantidad%TYPE;
    l_Precio_Final     Scfr_Mov_Productos_Txs.Precio_Final%TYPE;
    l_Datos_Inventario Scfr_Trx_Exc_Pk.t_Datos_Inventario;
    l_Auxiliar         BLOB;
    l_Signo            NUMBER;
    l_Es_Loyalty       BOOLEAN;
    l_Ajuste_Cia       NUMBER(1) := 0;
    l_Pro_Ajuste_Cia   NUMBER;
  BEGIN
    --//--------------------------------------------------------------------------\\
    --// CBR 13/08/2018 10:20                                                     \\
    --// BIFURCAR EMPRESA MAICAO EN GNCC01                                        \\
    --//-----------------------------------------------------------------Inicio---\\
    l_Es_Loyalty := FALSE;
    ----- REVERSA
    IF Es_Consulta_Loyalty(p_Transaccion.Trama_Pos.Empresa
                          ,p_Transaccion.Trama_Pos.Cadena
                          ,p_Transaccion.Trama_Pos.Local) = 'SI' THEN
      l_Es_Loyalty := TRUE;
    END IF;
  
    BEGIN
      l_Pro_Ajuste_Cia := To_Number(Scfr_Trx_Util_Pk.Det_Valor_Parametro_Por_Cod('PROAJUCIA'));
      IF (l_Pro_Ajuste_Cia = 0) THEN
        l_Pro_Ajuste_Cia := 297475;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        l_Pro_Ajuste_Cia := 297475;
    END;
  
    --//-----------------------------------------------------------------Termino--\\
    x_Cod_Error := 0;
    -- -- Obtiene informacion de la trama DV
    -- l_DBG_MENSAJE := 'Obtener informacion de la trama DV';
    -- l_trama_dv    := scfr_trx_dyn_utl_pk.carga_trama_dv(p_Transaccion.Trama_Pos,p_transaccion.cuerpo_tx );
    -- Obtiene informacion de la trama DV
    l_Dbg_Mensaje := 'Obtener informacion de la trama PM';
    l_Trama_Pm    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Pm(p_Transaccion.Trama_Pos
                                                       ,p_Transaccion.Cuerpo_Tx);
    -- Recorre detalle de productos
    l_Dbg_Mensaje := 'Recorrer detalle de la trama PM (productos)';
    FOR l_Itm IN 1 .. l_Trama_Pm.Count
    LOOP
      -- Obtiene codigo personal del vendedor
      BEGIN
        SELECT Codigo_Personal INTO l_Codigo_Personal FROM Scfr_Personal WHERE Rut_Personal = l_Trama_Pm(l_Itm).Rut_Vendedor;
      EXCEPTION
        WHEN OTHERS THEN
          l_Codigo_Personal := 0;
      END;
      -- Obtiene id para la tabla scfr_mov_productos_txs
      l_Dbg_Mensaje := 'Obtener folio para la tabla SCFR_MOV_PRODUCTOS_TXS';
      SELECT Scfr_Mov_Productos_Txs_s.Nextval INTO l_Codigo_Detalle FROM Dual;
      -- Obtiene codigo y categoria de productos
      l_Codigo_Interno := Scfr_Trx_Util_Pk.Parche_Producto(p_Transaccion.Trama_Pos.Empresa
                                                          ,l_Trama_Pm(l_Itm).Producto);
      l_Categoria      := Scfr_Trx_Util_Pk.Cat_Prod(p_Transaccion.Trama_Pos.Empresa
                                                   ,Scfr_Trx_Util_Pk.Parche_Producto(p_Transaccion.Trama_Pos.Empresa
                                                                                    ,l_Trama_Pm(l_Itm).Producto));
      -- Determinar el valor de Precio_Final y Cantidad
      l_Dbg_Mensaje := 'Calcular valores para el Precio Final y la Cantidad';
      --if l_trama_pm(l_itm).accion_sobre_existencia = 'S' then
      --  l_precio_final := l_trama_pm(l_itm).precio_final * -1;
      --  l_cantidad     := l_trama_pm(l_itm).cantidad     * -1;
      --  l_signo        := 1;
      --els
      IF (l_Codigo_Interno = l_Pro_Ajuste_Cia) THEN
        l_Ajuste_Cia := 1;
      END IF;
      IF l_Trama_Pm(l_Itm).Accion_Sobre_Existencia = 'E' THEN
        l_Precio_Final := l_Trama_Pm(l_Itm).Precio_Final;
        l_Cantidad     := l_Trama_Pm(l_Itm).Cantidad;
        l_Signo        := 1;
      ELSE
        l_Precio_Final := l_Trama_Pm(l_Itm).Precio_Final;
        l_Cantidad     := l_Trama_Pm(l_Itm).Cantidad;
        l_Signo        := 1;
      END IF;
      IF l_Trama_Pm(l_Itm).Exento_Iva = '-1' THEN
        l_Trama_Pm(l_Itm).Exento_Iva := NULL;
      END IF;
      IF l_Trama_Pm(l_Itm).Controla_Stock = '-1' THEN
        l_Trama_Pm(l_Itm).Controla_Stock := NULL;
      END IF;
      IF l_Trama_Pm(l_Itm).Permite_Devolucion = '-1' THEN
        l_Trama_Pm(l_Itm).Permite_Devolucion := NULL;
      END IF;
      -- inserta en tabla scfr_mov_productos_txs
      l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_PRODUCTOS_TXS';
      INSERT INTO Scfr_Mov_Productos_Txs
        (Codigo_Detalle
        ,Txo_Codigo_Tx
        ,Pt_Party_Id_Titular
        ,Pro_Codigo_Interno
        ,Cat_Categoria
        ,Txo_Correlativo_Tx
        ,Per_Codigo_Personal
        ,Pro_Precio_Lista
        ,Precio_Final
        ,Cantidad
        ,Per_Rut_Vendedor
        ,Per_Dv_Vendedor
        ,Tipo_Identi_Vendedor
        ,Identi_Vendedor
        ,Costo
        ,Codigo_Barra
        ,Emp_Empresa
        ,Cad_Cadena
        ,Loc_Local
        ,Tipo_Alta_Baja
        ,Cantidad_Acumulada_Psalud
        ,Accion_Sobre_Existencia
        ,Permitido_Por_Cnv
        ,Puf_Uso_Frecuente
        ,Campana_Promocion
        ,Campana_Aditiva
        ,Exento_Iva
        ,Controla_Stock
        ,Permite_Devolucion
        ,Producto_Demandado
        ,Nombre_Vendedor -- JAGC NEC 20240909
        )
      VALUES
        (l_Codigo_Detalle -- codigo_detalle
        ,p_Transaccion.Codigo_Tx -- txo_codigo_tx
        ,p_Transaccion.Trama_Boc.Party_Id -- pt_party_id_titular
        ,l_Codigo_Interno -- pro_codigo_interno
        ,l_Categoria -- cat_categoria
        ,p_Transaccion.Correlativo_Tx -- txo_correlativo_tx
        ,l_Codigo_Personal -- per_codigo_personal
        ,l_Trama_Pm(l_Itm).Precio_Lista -- pro_precio_lista
        ,l_Precio_Final * -1 -- precio_final
        ,l_Cantidad * -1 -- cantidad
        ,l_Trama_Pm(l_Itm).Rut_Vendedor -- per_rut_vendedor
        ,l_Trama_Pm(l_Itm).Dv_Rut_Vendedor -- scfr_trx_util_pk.dv_rut( l_trama_pm(l_itm).rut_vendedor ) -- per_dv_vendedor
        ,Substr(l_Trama_Pm(l_Itm).Identi_Vendedor
               ,1
               ,1)
        ,Substr(l_Trama_Pm(l_Itm).Identi_Vendedor
               ,2
               ,30)
        ,l_Trama_Pm(l_Itm).Costo_Unitario -- costo
        ,l_Trama_Pm(l_Itm).Codigo_Barra -- codigo barra
        ,p_Transaccion.Trama_Pos.Empresa -- emp_empresa
        ,p_Transaccion.Trama_Pos.Cadena -- cad_cadena
        ,p_Transaccion.Trama_Pos.Local -- loc_local
        ,'ALTA' -- tipo_alta_baja ASV
        ,l_Trama_Pm(l_Itm).Cantidad_Acumulada_Psalud
        ,l_Trama_Pm(l_Itm).Accion_Sobre_Existencia
        ,l_Trama_Pm(l_Itm).Permitido_Por_Convenio
        ,l_Trama_Pm(l_Itm).Uso_Frecuente
        ,l_Trama_Pm(l_Itm).Campana_Promocion
        ,l_Trama_Pm(l_Itm).Campana_Aditiva
        ,l_Trama_Pm(l_Itm).Exento_Iva
        ,l_Trama_Pm(l_Itm).Controla_Stock
        ,l_Trama_Pm(l_Itm).Permite_Devolucion
        ,l_Trama_Pm(l_Itm).Producto_Original_Demandado
        ,l_Trama_Pm(l_Itm).Nombre_Vendedor -- JAGC NEC 20240909
        );
      -- Recorre subtrama documentos de referencia
      Scfr_Trx_Gnc_Utl_Pk.Trama_Pm_Doctos_Referencia(p_Transaccion
                                                    ,l_Trama_Pm(l_Itm) -- envio solo los datos de un producto y no todo el detalle
                                                    ,p_Trama_Dv --l_trama_dv
                                                    ,p_Doc_Emitidos
                                                    ,l_Codigo_Detalle
                                                    ,p_Tipo_Tx
                                                    ,x_Cod_Error
                                                    ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
      -- Recorre descuentos aplicados
      Trama_Pm_Desctos_Aplicados(p_Transaccion --in out
                                ,l_Trama_Pm(l_Itm) --in out //envio solo los datos de un producto y no todo el detalle
                                ,p_Trama_Dv -- l_trama_dv
                                ,l_Codigo_Detalle --in
                                ,'ACT' --deja el cupon activo nuevamente
                                ,p_Tipo_Tx
                                ,l_Puntos_Canjeados --out
                                ,x_Cod_Error --out
                                ,x_Msg_Error); --out
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
      -- Recorre puntos generados
      Trama_Pm_Puntos_Generados(p_Transaccion
                               ,l_Trama_Pm(l_Itm) -- envio solo los datos de un producto y no todo el detalle
                               ,l_Codigo_Detalle
                               ,p_Tipo_Tx
                               ,x_Cod_Error
                               ,x_Msg_Error);    
                                                   
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
                               
      -- INI JAGC NEC 20240909                         
      Trama_Pm_Eventos_Perdidos(p_Transaccion
                               ,l_Trama_Pm(l_Itm) -- envio solo los datos de un producto y no todo el detalle
                               ,l_Codigo_Detalle
                               ,p_Tipo_Tx
                               ,x_Cod_Error
                               ,x_Msg_Error); 
                                                      
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;      
      -- FIN JAGC NEC 20240909  
      
      -- Recorre distribucion convenios
      Trama_Pm_Distrib_Convenios(p_Transaccion
                                ,l_Trama_Pm(l_Itm) -- envio solo los datos de un producto y no todo el detalle
                                ,p_Trama_Dv --l_trama_dv
                                ,l_Codigo_Detalle
                                ,x_Cod_Error
                                ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    
      -- Recorre Impuestos Aplicados
      Trama_Pm_Impuestos_Aplicados(p_Transaccion
                                  ,l_Trama_Pm(l_Itm) -- envio solo los datos de un producto y no todo el detalle
                                  --,p_Trama_Dv --l_trama_dv
                                  ,p_Transaccion.Correlativo_Tx
                                  ,l_Codigo_Detalle
                                  ,x_Cod_Error
                                  ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    
      -- Recorre Recargas y Telepeajes
      Trama_Pm_Recargas_Telepeajes(p_Transaccion
                                  ,l_Trama_Pm(l_Itm) -- envio solo los datos de un producto y no todo el detalle
                                  ,p_Trama_Dv --l_trama_dv
                                  ,l_Codigo_Detalle
                                  ,p_Tipo_Tx
                                  ,x_Cod_Error
                                  ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    
      -- Recorre Mejor Opcion
      Trama_Pm_Mejor_Opcion(p_Transaccion
                           ,l_Trama_Pm(l_Itm) -- envio solo los datos de un producto y no todo el detalle
                           ,p_Trama_Dv --l_trama_dv
                           ,l_Codigo_Detalle
                           ,x_Cod_Error
                           ,x_Msg_Error);
    
      -- Recorre Productos Controlados
      Trama_Pm_Prds_Controlados(p_Transaccion
                               ,l_Trama_Pm(l_Itm) -- envio solo los datos de un producto y no todo el detalle
                               ,p_Trama_Dv --l_trama_dv
                               ,l_Codigo_Detalle
                               ,x_Cod_Error
                               ,x_Msg_Error);
    
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    
      -- Actualiza Inventario
      IF l_Trama_Pm(l_Itm).Accion_Sobre_Existencia IN ('E'
                                     ,'S') THEN
        l_Dbg_Mensaje := 'Actualizar Stock en Linea';
        Scfr_Trx_Exc_Pk.Actualizastockenlinea(0
                                             ,l_Datos_Inventario
                                             ,l_Trama_Pm                     (l_Itm).Producto
                                             ,p_Transaccion.Trama_Pos.Empresa
                                             ,p_Transaccion.Trama_Pos.Cadena
                                             ,p_Transaccion.Trama_Pos.Local
                                             ,l_Trama_Pm                     (l_Itm).Cantidad * l_Signo
                                             ,p_Transaccion.Codigo_Tx
                                             ,l_Auxiliar);
      END IF;
      /*
            -- Actualiza Inventario
            trama_pm_inventario( p_transaccion
                               , l_trama_pm(l_itm)
                               , p_trama_dv   --l_trama_dv
                               , p_tipo_tx --'GNCU02'
                               , l_itm
                               , x_cod_error
                               , x_msg_error );
            if nvl(x_cod_error,0) != 0 then
              raise l_ERROR_CONTROLADO;
            end if;
      */
    END LOOP;
  
    IF p_Tipo_Tx IN ('GNCU01'
                    ,'GNCU02') AND
       (l_Ajuste_Cia = 1) THEN
      -- Aplica ajuste GUIA compania seguros
      UPDATE Scfr_Mov_Productos_Txs
         SET (Pro_Precio_Lista
            ,Precio_Final) =
             (SELECT (Precio_Final +
                     (Scfr_Mov_Documentos_Txs.Monto -
                     (SELECT SUM(Pro2.Precio_Final) FROM Scfr_Mov_Productos_Txs Pro2 WHERE Pro2.Txo_Codigo_Tx = Scfr_Mov_Transacciones.Codigo_Tx)))
                    ,(Precio_Final +
                     (Scfr_Mov_Documentos_Txs.Monto -
                     (SELECT SUM(Pro2.Precio_Final) FROM Scfr_Mov_Productos_Txs Pro2 WHERE Pro2.Txo_Codigo_Tx = Scfr_Mov_Transacciones.Codigo_Tx)))
                FROM Scfr_Mov_Transacciones
                    ,Scfr_Mov_Documentos_Txs
               WHERE Scfr_Mov_Transacciones.Codigo_Tx = Scfr_Mov_Documentos_Txs.Txo_Codigo_Tx
                 AND Tmo_Movimiento IN ('VENGUI'
                                       ,'ANUGUI')
                 AND Scfr_Mov_Transacciones.Codigo_Tx = Scfr_Mov_Productos_Txs.Txo_Codigo_Tx)
       WHERE Txo_Codigo_Tx = p_Transaccion.Codigo_Tx
         AND Pro_Codigo_Interno = l_Pro_Ajuste_Cia;
    END IF;
  
    --//--------------------------------------------------------------------------\\
    --// CBR 22/08/2018 11:55                                                     \\
    --// EMPRESA MAICAO GESTIONA SUS PROPIOS PUNTOS                               \\
    --//-----------------------------------------------------------------Inicio---\\
    IF (l_Es_Loyalty = TRUE) AND
       p_Tipo_Tx IN ('GNCU01'
                    ,'GNCU05'
                    ,'GNCU02'
                    ,'GNCU06') THEN
      Scfr_Trx_Puntos_Pk.Informa_Puntos_Loyalty(p_Transaccion
                                               ,p_Tipo_Tx
                                               ,x_Cod_Error
                                               ,x_Msg_Error);
    END IF;
    --//-----------------------------------------------------------------Termino--\\
  
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Trama PM resuelta correctamente');
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  FUNCTION Trama_Pm_Prepara(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,l_Trama_Vt    IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vt
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm IS
    CURSOR c_Productos(p_Codigo_Tx IN NUMBER
                      ,p_Folio     IN NUMBER) IS
      SELECT Mpr.Codigo_Detalle
            ,Mpr.Pro_Codigo_Interno
            ,Mpr.Codigo_Barra
            ,Mpr.Pro_Precio_Lista
            ,Mpr.Precio_Final
            ,Mpr.Costo
            ,Mpr.Cantidad
            ,Mpr.Cantidad_Acumulada_Psalud
            ,Mpr.Per_Rut_Vendedor
            ,Mpr.Per_Dv_Vendedor
            ,Mpr.Autorizacion_Cnv_Pro
            ,Decode(Nvl(Mpr.Accion_Sobre_Existencia
                       ,' ')
                   ,'E'
                   ,'I'
                   ,'N') Aplicacion_Item
            ,Mpr.Accion_Sobre_Existencia
             -- Aqui faltaban 5 campos, por ahora se devuelve en duro puros 0 no mas. Acordado esto con Alvaro el 5/3/2004.
            ,0                            Campana_Puntos
            ,0                            Campana_Puntos_Factor
            ,0                            Campana_Puntos_Porcentaje
            ,0                            Saldo_Compra_Frecuente
            ,0                            Acumulador_Entrega
            ,Mpr.Puntos_Generados
            ,Mpr.Consejo_Aplicado
            ,Mpr.Porcentaje_Bonificacion
            ,Mpr.Cantidad_Canjeada
            ,Mpr.Canje_Transaccion_Origen
            ,Mpr.Canje_Local_Origen
            ,Mpr.Permitido_Por_Cnv
            ,Mpr.Puf_Uso_Frecuente
            ,Mpr.Campana_Promocion
            ,Mpr.Campana_Aditiva
            ,Mpr.Pendiente_Beneficio_Ps
            ,Mpr.Exento_Iva
            ,Mpr.Controla_Stock
            ,Mpr.Permite_Devolucion
            ,Mpr.Producto_Demandado
        FROM Scfr_Mov_Productos_Txs Mpr
       WHERE Mpr.Txo_Codigo_Tx = p_Codigo_Tx;
    CURSOR c_Doctos_Referencia(p_Codigo_Tx IN NUMBER
                              ,p_Producto  IN NUMBER) IS
      SELECT Mdo.Secuencia
            ,Mpd.Precio_Final
        FROM Scfr_Mov_Documentos_Txs       Mdo
            ,Scfr_Mov_Productos_Documentos Mpd
       WHERE Mdo.Txo_Codigo_Tx = p_Codigo_Tx
         AND Mdo.Mov_Documentos = Mpd.Dte_Mov_Documentos
         AND Mdo.Txo_Codigo_Tx = Mpd.Txo_Codigo_Tx
         AND Mpd.Pro_Codigo_Interno = p_Producto;
    CURSOR c_Descuentos(p_Codigo_Tx IN NUMBER
                       ,p_Producto  IN NUMBER) IS
      SELECT Secuencia_Descuento
            ,Tipo_Descuento
            ,Campana_Convenio
            ,Mcu_Codigo_Cupon
            ,Monto
            ,Puntos_Canjeados
            ,Convertibilidad_Puntos
            ,Tipo_Aplicacion_Descuento --'AP'
            ,Id_Dcto_Complem --'AJU'
            ,Financiado
            ,Sec_Financiamiento
            ,Descuento_Referencial
            ,Unidades_Descuento
            ,Rut_Supervisor
            ,Dv_Supervisor
            ,Nvl(Pertenece_Club
                ,'N') Pertenece_Club
        FROM Scfr_Mov_Descuentos_Productos
       WHERE Txo_Codigo_Tx = p_Codigo_Tx
         AND Pro_Codigo_Interno = p_Producto;
    CURSOR c_Detalle_Descto(p_Codigo_Tx IN NUMBER
                           ,p_Secuencia IN NUMBER) IS
      SELECT Ciclo
            ,Monto_Descuento
            ,Secuencia_Ciclo
            ,Unidades_Descuento
        FROM Scfr_Mov_Det_Desc_Producto
       WHERE Txo_Codigo_Tx = p_Codigo_Tx
         AND Secuencia_Descuento = p_Secuencia;
    CURSOR c_Puntos(p_Codigo_Tx IN NUMBER
                   ,p_Producto  IN NUMBER) IS
      SELECT Mpp.Cam_Campana
            ,Mpp.Puntos_Generados
        FROM Scfr_Mov_Productos_Documentos Mpd
            ,Scfr_Mov_Puntos_Productos     Mpp
       WHERE Mpd.Txo_Codigo_Tx = p_Codigo_Tx
         AND Mpd.Pro_Codigo_Interno = p_Producto
         AND Mpd.Mov_Productos_Documentos = Mpp.Mov_Productos_Documentos
         AND Mpd.Pro_Codigo_Interno = Mpp.Pro_Codigo_Interno;
    CURSOR c_Distribucion(p_Codigo_Detalle IN NUMBER
                         ,p_Producto       IN NUMBER) IS
      SELECT Tipo_Distribucion
            ,Monto_Distribucion
        FROM Scfr_Mov_Productos_Dis
       WHERE Prt_Codigo_Detalle = p_Codigo_Detalle
         AND Pro_Codigo_Interno = p_Producto;
    l_Trama_Pm         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm;
    l_Boleta_Inscrip   NUMBER;
    l_Codigo_Tx_Rel    NUMBER;
    l_Itm              NUMBER;
    l_Itm2             NUMBER;
    l_Itm3             NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_pm_prepara';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Obtener datos desde la tabla SCFR_MOV_PRODUCTOS_TXS para la subtrama PM';
    l_Itm         := 1;
    FOR r_Productos IN c_Productos(p_Transaccion.Codigo_Tx
                                  ,l_Trama_Vt.Folio)
    LOOP
      l_Trama_Pm(l_Itm).Producto := r_Productos.Pro_Codigo_Interno;
      l_Trama_Pm(l_Itm).Codigo_Barra := r_Productos.Codigo_Barra;
      l_Trama_Pm(l_Itm).Precio_Lista := r_Productos.Pro_Precio_Lista;
      l_Trama_Pm(l_Itm).Precio_Final := Abs(r_Productos.Precio_Final);
      l_Trama_Pm(l_Itm).Costo_Unitario := r_Productos.Costo;
      l_Trama_Pm(l_Itm).Cantidad := Abs(r_Productos.Cantidad);
      l_Trama_Pm(l_Itm).Cantidad_Acumulada_Psalud := r_Productos.Cantidad_Acumulada_Psalud;
      l_Trama_Pm(l_Itm).Rut_Vendedor := r_Productos.Per_Rut_Vendedor;
      l_Trama_Pm(l_Itm).Dv_Rut_Vendedor := r_Productos.Per_Dv_Vendedor;
      l_Trama_Pm(l_Itm).Codigo_Autorizacion := r_Productos.Autorizacion_Cnv_Pro;
      l_Trama_Pm(l_Itm).Aplicacion_Item := r_Productos.Aplicacion_Item;
      l_Trama_Pm(l_Itm).Accion_Sobre_Existencia := r_Productos.Accion_Sobre_Existencia;
      l_Trama_Pm(l_Itm).Saldo_Compra_Frecuente := r_Productos.Saldo_Compra_Frecuente;
      l_Trama_Pm(l_Itm).Acumulador_Entrega := r_Productos.Acumulador_Entrega;
      l_Trama_Pm(l_Itm).Numero_Consejo := r_Productos.Consejo_Aplicado;
      l_Trama_Pm(l_Itm).Porcentaje_Bonificacion := r_Productos.Porcentaje_Bonificacion;
      l_Trama_Pm(l_Itm).Cantidad_Canjeada := r_Productos.Cantidad_Canjeada;
      l_Trama_Pm(l_Itm).Canje_Transaccion_Origen := r_Productos.Canje_Transaccion_Origen;
      l_Trama_Pm(l_Itm).Canje_Local_Origen := r_Productos.Canje_Local_Origen;
      l_Trama_Pm(l_Itm).Permitido_Por_Convenio := r_Productos.Permitido_Por_Cnv;
      l_Trama_Pm(l_Itm).Campana_Promocion := r_Productos.Campana_Promocion;
      l_Trama_Pm(l_Itm).Campana_Aditiva := r_Productos.Campana_Aditiva;
      l_Trama_Pm(l_Itm).Beneficio_Pendiente_Ps := r_Productos.Pendiente_Beneficio_Ps;
      l_Trama_Pm(l_Itm).Exento_Iva := r_Productos.Exento_Iva;
      l_Trama_Pm(l_Itm).Controla_Stock := r_Productos.Controla_Stock;
      l_Trama_Pm(l_Itm).Permite_Devolucion := r_Productos.Permite_Devolucion;
      l_Trama_Pm(l_Itm).Producto_Original_Demandado := r_Productos.Producto_Demandado;
      l_Dbg_Mensaje := 'Determinar si producto es de uso frecuente para el cliente';
      BEGIN
        SELECT Ufr.Uso_Frecuente
              ,Cuf.Documento_Venta
          INTO l_Trama_Pm(l_Itm).Uso_Frecuente
              ,l_Boleta_Inscrip
          FROM Scfr_Uso_Frecuente          Ufr
              ,Scfr_Clientes_Uso_Frecuente Cuf
         WHERE Ufr.Uso_Frecuente = Cuf.Puf_Uso_Frecuente
              --and ufr.pro_codigo_compra = l_trama_pm(l_itm).producto
           AND Ufr.Uso_Frecuente = r_Productos.Puf_Uso_Frecuente
           AND Cuf.Pt_Party_Id = p_Transaccion.Trama_Boc.Party_Id
           AND Cuf.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa;
      EXCEPTION
        WHEN OTHERS THEN
          l_Trama_Pm(l_Itm).Uso_Frecuente := 0;
          l_Boleta_Inscrip := 0;
      END;
      l_Trama_Pm(l_Itm).Uso_Frecuente := r_Productos.Puf_Uso_Frecuente;
      IF l_Boleta_Inscrip = l_Trama_Vt.Folio THEN
        l_Trama_Pm(l_Itm).Inscrito_Programa_Salud := 'SI';
      ELSE
        l_Trama_Pm(l_Itm).Inscrito_Programa_Salud := 'NO';
      END IF;
      l_Dbg_Mensaje := 'Obtener datos desde la tabla SCFR_MOV_PUNTOS_PRODUCTOS para la subtrama PM1 (Documentos Referencia)';
      l_Itm2        := 1;
      FOR r_Doctos_Referencia IN c_Doctos_Referencia(p_Transaccion.Codigo_Tx
                                                    ,l_Trama_Pm(l_Itm).Producto)
      LOOP
        l_Trama_Pm(l_Itm).Subtrama_Pm1(l_Itm2).Secuencia_b := r_Doctos_Referencia.Secuencia;
        l_Trama_Pm(l_Itm).Subtrama_Pm1(l_Itm2).Total_Item_Por_Documento := r_Doctos_Referencia.Precio_Final;
        l_Itm2 := l_Itm2 + 1;
      END LOOP;
      l_Dbg_Mensaje := 'Obtener datos desde la tabla SCFR_MOV_PUNTOS_PRODUCTOS para la subtrama PM2 (Descuentos Aplicados)';
      l_Itm2        := 1;
      FOR r_Descuentos IN c_Descuentos(p_Transaccion.Codigo_Tx
                                      ,l_Trama_Pm(l_Itm).Producto)
      LOOP
        l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Secuencia_b := r_Descuentos.Secuencia_Descuento;
        l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Tipo_Descuento := r_Descuentos.Tipo_Descuento;
        l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Campana_o_Convenio := r_Descuentos.Campana_Convenio;
        l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Codigo_Cupon := r_Descuentos.Mcu_Codigo_Cupon;
        l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Monto_Documento := r_Descuentos.Monto;
        l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Puntos_Canjeados := r_Descuentos.Puntos_Canjeados;
        l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Convertibilidad_Pesos_Puntos := r_Descuentos.Convertibilidad_Puntos;
        l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Tipo_Aplicacion_Descuento := r_Descuentos.Tipo_Aplicacion_Descuento;
        l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Id_Descuento_Complementario := r_Descuentos.Id_Dcto_Complem;
        l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Descuento_Financiado := r_Descuentos.Financiado;
        l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Secuencia_Financiamiento := r_Descuentos.Sec_Financiamiento;
        l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Descuento_Referencial := r_Descuentos.Descuento_Referencial;
        l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Unidades_Beneficio := r_Descuentos.Unidades_Descuento;
        l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Detalle_Descuento_Producto := '';
        l_Trama_Pm(l_Itm).Rut_Supervisor := Nvl(r_Descuentos.Rut_Supervisor
                                               ,'0');
        l_Trama_Pm(l_Itm).Dv_Rut_Supervisor := r_Descuentos.Dv_Supervisor;
        --//--------------------------------------------------------------------------\\
        --// CBR 11/11/2014 18:05                                                     \\
        --// Se asigna valor a SIGNO (P/N) dependiendo de MONTO (Positivo/Negativo)   \\
        --//-----------------------------------------------------------------Inicio---\\
        l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Signo := 'P';
        IF r_Descuentos.Monto < 0 THEN
          l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Signo := 'N';
        END IF;
        --//-----------------------------------------------------------------Termino--\\
        --//--------------------------------------------------------------------------\\
        --// CBR 27/12/2017 12:30 BOX AHORRO                                          \\
        --//-----------------------------------------------------------------Inicio---\\
        l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Pertenece_Club := r_Descuentos.Pertenece_Club;
        --//-----------------------------------------------------------------Termino--\\
        l_Itm3 := 0;
        FOR r_Detalle_Descto IN c_Detalle_Descto(p_Transaccion.Codigo_Tx
                                                ,r_Descuentos.Secuencia_Descuento)
        LOOP
          l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Detalle_Descuento_Producto := l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Detalle_Descuento_Producto ||
                                                                                Ltrim(Rtrim(To_Char(r_Detalle_Descto.Ciclo
                                                                                                                                         ,'009'))) ||
                                                                                Ltrim(Rtrim(To_Char(r_Detalle_Descto.Monto_Descuento
                                                                                                                                         ,'0000000009'))) ||
                                                                                Ltrim(Rtrim(Lpad(Nvl(r_Detalle_Descto.Secuencia_Ciclo
                                                                                                                                          ,'0')
                                                                                                                                      ,3
                                                                                                                                      ,'0'))) ||
                                                                                Ltrim(Rtrim(To_Char(r_Detalle_Descto.Unidades_Descuento
                                                                                                                                         ,'009')));
          l_Itm3 := l_Itm3 + 1;
        END LOOP;
        IF l_Itm3 > 0 THEN
          l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Detalle_Descuento_Producto := Ltrim(To_Char(l_Itm3
                                                                                            ,'09') || l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Detalle_Descuento_Producto);
        ELSE
          l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Detalle_Descuento_Producto := '00';
        END IF;
        l_Itm2 := l_Itm2 + 1;
      END LOOP;
      l_Dbg_Mensaje := 'Obtener datos desde la tabla SCFR_MOV_PUNTOS_PRODUCTOS para la subtrama PM3 (Puntos Generados)';
      l_Itm2        := 1;
      FOR r_Puntos IN c_Puntos(p_Transaccion.Codigo_Tx
                              ,l_Trama_Pm(l_Itm).Producto)
      LOOP
        l_Trama_Pm(l_Itm).Subtrama_Pm3(l_Itm2).Campana := r_Puntos.Cam_Campana;
        l_Trama_Pm(l_Itm).Subtrama_Pm3(l_Itm2).Puntos := r_Puntos.Puntos_Generados;
        IF r_Puntos.Puntos_Generados >= 0 THEN
          l_Trama_Pm(l_Itm).Subtrama_Pm3(l_Itm2).Signo := 'P';
        ELSE
          l_Trama_Pm(l_Itm).Subtrama_Pm3(l_Itm2).Signo := 'N';
        END IF;
        -- 'Obtener valor de dias vencimiento de puntos';
        l_Trama_Pm(l_Itm).Subtrama_Pm3(l_Itm2).Vigencia := Scfr_Trx_Util_Pk.Det_Valor_Parametro_Por_Cod('DIVEPU');
        l_Itm2 := l_Itm2 + 1;
      END LOOP;
      l_Dbg_Mensaje := 'Obtener datos desde la tabla SCFR_MOV_PUNTOS_PRODUCTOS para la subtrama PM4 (Distribucion Convenios)';
      l_Itm2        := 1;
      FOR r_Distribucion IN c_Distribucion(r_Productos.Codigo_Detalle
                                          ,l_Trama_Pm(l_Itm).Producto)
      LOOP
        l_Trama_Pm(l_Itm).Subtrama_Pm4(l_Itm2).Tipo_Distribucion := r_Distribucion.Tipo_Distribucion;
        l_Trama_Pm(l_Itm).Subtrama_Pm4(l_Itm2).Monto_Distribucion := r_Distribucion.Monto_Distribucion;
        l_Itm2 := l_Itm2 + 1;
      END LOOP;
      l_Trama_Pm(l_Itm).Documentos_Referencia := l_Trama_Pm(l_Itm).Subtrama_Pm1.Count;
      l_Trama_Pm(l_Itm).Descuentos_Aplicados := l_Trama_Pm(l_Itm).Subtrama_Pm2.Count;
      l_Trama_Pm(l_Itm).Puntos_Generados := l_Trama_Pm(l_Itm).Subtrama_Pm3.Count;
      l_Trama_Pm(l_Itm).Distribucion_Convenio := l_Trama_Pm(l_Itm).Subtrama_Pm4.Count;
      l_Itm := l_Itm + 1;
    END LOOP;
    RETURN l_Trama_Pm;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Trama_Mp_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Mp         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Mp;
    l_Codigo_Detalle   Scfr_Mov_Productos_Txs.Codigo_Detalle%TYPE;
    l_Itm              NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_mp_resuelve';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    l_Fecha_Vcto       DATE;
    l_Fecha_Tx         DATE;
  BEGIN
    x_Cod_Error := 0;
    -- Obtiene informacion de la trama MP
    l_Dbg_Mensaje := 'Obtener informacion de la trama MP';
    l_Trama_Mp    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Mp(p_Transaccion.Cuerpo_Tx);
    -- Obtiene id actual de la tabla scfr_mov_productos_txs
    l_Dbg_Mensaje := 'Obtener folio de la tabla SCFR_MOV_PRODUCTOS_TXS';
    SELECT Scfr_Mov_Productos_Txs_s.Currval INTO l_Codigo_Detalle FROM Dual;
    l_Dbg_Mensaje := 'Recorrer detalle de la trama MP (Movimiento Pines)';
    FOR l_Itm IN 1 .. l_Trama_Mp.Count
    LOOP
      l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_AUT_PRODUCTO';
      IF l_Trama_Mp(l_Itm).Fecha_Vencimiento = 0 THEN
        l_Fecha_Vcto := NULL;
      ELSE
        l_Fecha_Vcto := To_Date(To_Char(l_Trama_Mp(l_Itm).Fecha_Vencimiento)
                               ,'yyyymmdd');
      END IF;
      IF l_Trama_Mp(l_Itm).Fecha_Transaccion = 0 THEN
        l_Fecha_Tx := NULL;
      ELSE
        l_Fecha_Tx := To_Date(To_Char(l_Trama_Mp(l_Itm).Fecha_Transaccion)
                             ,'yyyymmddhh24miss');
      END IF;
      INSERT INTO Scfr_Mov_Aut_Producto
        (Txo_Codigo_Tx
        ,Txo_Correlativo_Tx
        ,Pro_Codigo_Interno
        ,Codigo_Autorizacion
        ,Numero_Id
        ,Monto
        ,Codigo_Aut_Empresa
        ,Numero_Folio
        ,Fecha_Vencimiento
        ,Comtx_Empresa
        ,Comtx_Cadena
        ,Comtx_Numero_Local
        ,Comtx_Numero_Pos
        ,Comtx_Destino
        ,Comtx_Sistema
        ,Comtx_Funcion
        ,Comtx_Secuencia
        ,Comtx_Fecha
        ,Comtx_Correlativo
        ,Comtx_Numero_Trama
        ,Prt_Codigo_Detalle
        ,Telefono
        ,Bono_Adicional
        ,Nuevo_Saldo
        ,Dias_Vigencia
        ,Incluido_En_Journal
        ,Forma_Pago
        ,Descuento
        ,Id_Unico)
      VALUES
        (p_Transaccion.Codigo_Tx
        ,l_Trama_Mp(l_Itm).Correlativo_Tx
        ,l_Trama_Mp(l_Itm).Codigo_Interno
        ,Nvl(TRIM(l_Trama_Mp(l_Itm).Codigo_Autorizacion)
            ,0)
        ,l_Trama_Mp(l_Itm).Numero_Id
        ,l_Trama_Mp(l_Itm).Monto
        ,Nvl(TRIM(l_Trama_Mp(l_Itm).Codigo_Autorizacion_Empresa)
            ,0)
        ,l_Trama_Mp(l_Itm).Numero_Folio
        ,l_Fecha_Vcto
        ,l_Trama_Mp(l_Itm).Empresa
        ,l_Trama_Mp(l_Itm).Cadena
        ,l_Trama_Mp(l_Itm).Numero_Local
        ,l_Trama_Mp(l_Itm).Numero_Pos
        ,l_Trama_Mp(l_Itm).Destino
        ,l_Trama_Mp(l_Itm).Sistema
        ,l_Trama_Mp(l_Itm).Funcion
        ,l_Trama_Mp(l_Itm).Secuencia
        ,l_Fecha_Tx
        ,l_Trama_Mp(l_Itm).Correlativo
        ,l_Trama_Mp(l_Itm).Numero_Trama
        ,l_Codigo_Detalle
        ,l_Trama_Mp(l_Itm).Telefono
        ,l_Trama_Mp(l_Itm).Bono_Adicional
        ,l_Trama_Mp(l_Itm).Nuevo_Saldo
        ,l_Trama_Mp(l_Itm).Dias_Vigencia
        ,l_Trama_Mp(l_Itm).Incluido_En_Journal
        ,l_Trama_Mp(l_Itm).Forma_Pago
        ,l_Trama_Mp(l_Itm).Descuento
        ,l_Trama_Mp(l_Itm).Id_Unico);
    END LOOP;
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Trama MP resuelta correctamente');
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  /*
    cupones generados impresos
  */
  PROCEDURE Trama_Cp_Resuelve(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Cp          Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cp;
    l_Itm               NUMBER;
    l_Fecha_Vencimiento DATE;
    l_Monto_Descuento   NUMBER;
    l_Porc_Descuento    NUMBER;
    l_Dbg_Proceso       VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_cp_resuelve';
    l_Dbg_Mensaje       VARCHAR2(250) := 'Error General';
    l_Error_Controlado  EXCEPTION;
  BEGIN
    x_Cod_Error := 0;
    -- Obtiene informacion de la trama DV
    l_Dbg_Mensaje := 'Obtener informacion de la trama CP (Cupones Generados Impresos)';
    l_Trama_Cp    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Cp(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje := 'Recorrer detalle de la trama CP (Cupones Generados Impresos)';
    FOR l_Itm IN 1 .. l_Trama_Cp.Count
    LOOP
      IF l_Trama_Cp(l_Itm).Familia_Comercial = 0 THEN
        l_Trama_Cp(l_Itm).Familia_Comercial := NULL;
      END IF;
      -- Determina fecha de vigencia para los cupones
      l_Dbg_Mensaje := 'Determinar fecha de vigencia para los cupones';
      IF To_Number(To_Char(p_Transaccion.Fecha_Tx
                          ,'MM')) > l_Trama_Cp(l_Itm).Vencimiento THEN
        -- Si MES_ACTUAL > MES_VCMTO, FECHA_VIGENCIA => (A?O_ACTUAL+1)+MES_VCMTOL+ULTIMO_DIA_MES_VCMTO
        l_Fecha_Vencimiento := Last_Day(To_Date(To_Char(p_Transaccion.Fecha_Tx
                                                       ,'yyyy') + 1 || To_Char(l_Trama_Cp(l_Itm).Vencimiento
                                                                              ,'09')
                                               ,'yyyymm'));
      ELSE
        -- Si MES_ACTUAL <= MES_VCMTO, FECHA_VIGENCIA => (A?O_ACTUAL)+MES_VCMTOL+ULTIMO_DIA_MES_VCMTO
        l_Fecha_Vencimiento := Last_Day(To_Date(To_Char(p_Transaccion.Fecha_Tx
                                                       ,'yyyy') || To_Char(l_Trama_Cp(l_Itm).Vencimiento
                                                                          ,'09')
                                               ,'yyyymm'));
      END IF;
      -- Determina la forma en que debe registrar el descuento
      l_Dbg_Mensaje := 'Determinar forma en que debe registrar el descuento';
      IF l_Trama_Cp(l_Itm).Tipo_Descuento = 'CPR' THEN
        l_Monto_Descuento := 0;
        l_Porc_Descuento  := l_Trama_Cp(l_Itm).Descuento / 100;
      ELSE
        l_Monto_Descuento := l_Trama_Cp(l_Itm).Descuento;
        l_Porc_Descuento  := 0;
      END IF;
      -- *********************************************************************************
      -- SOLO LOS CUPONES EMITIDOS A TRAVES DE CAMPA?AS PERSONALIZADAS (CRM='S') TIENEN
      -- CODIGO INTERNO (ID DEL CUPON EN LA TABLA SCFR_CUPONES) Y DEBEN SER ACTUALIZADOS
      -- LOS CUPONES EMITIDOS A TRAVES DE CAMPA?AS MASIVAS (CRM='N') DEBER SER INSERTADOS.
      -- *********************************************************************************
      IF Nvl(l_Trama_Cp(l_Itm).Codigo_Interno_Cupon
            ,0) = 0 THEN
        BEGIN
          l_Dbg_Mensaje := 'Insertar en tabla SCFR_CUPONES';
          INSERT INTO Scfr_Cupones
            (Cupones
            ,Pt_Party_Id
            ,Emp_Empresa
            ,Cad_Cadena
            ,Tipo_Cupon
            ,Estado_Cupon
            ,Canal_Emision
            ,Fecha_Emision
            ,Fecha_Vigencia
             --                                  , numero_reimpresion
            ,Codigo_Cupon
            ,Monto_Descuento
            ,Porc_Descuento
            ,Txo_Codigo_Tx_Emision
            ,Txo_Codigo_Tx_Canje
            ,Cam_Campana
            ,Puf_Uso_Frecuente
            ,Spv_Codigo
            ,Fco_Familia_Comercial
            ,Rut_Cliente
            ,Dv_Cliente)
          VALUES
            (Scfr_Cupones_s.Nextval -- cupones
            ,p_Transaccion.Trama_Boc.Party_Id -- pt_party_id
            ,p_Transaccion.Trama_Pos.Empresa -- emp_empresa
            ,p_Transaccion.Trama_Pos.Cadena -- cad_cadena
            ,l_Trama_Cp(l_Itm).Tipo_Cupon -- tipo_cupon
            ,'ACT' -- estado_cupon
            ,'POS' -- canal_emision
            ,p_Transaccion.Fecha_Tx -- fecha_emision
            ,l_Fecha_Vencimiento -- fecha_vigencia
             --                                  , 1                                 -- numero_reimpresion
            ,l_Trama_Cp(l_Itm).Codigo_Cupon -- codigo_cupon
            ,l_Monto_Descuento -- monto_descuento
            ,l_Porc_Descuento -- porc_descuento
            ,p_Transaccion.Codigo_Tx -- txo_codigo_tx_emision
            ,NULL -- txo_codigo_tx_canje
            ,l_Trama_Cp(l_Itm).Campana -- cam_campana
            ,NULL -- puf_uso_frecuente
            ,l_Trama_Cp(l_Itm).Producto -- spv_codigo
            ,l_Trama_Cp(l_Itm).Familia_Comercial -- fco_familia_comercial
            ,p_Transaccion.Rut_Titular
            ,p_Transaccion.Dv_Rut_Titular);
        EXCEPTION
          WHEN OTHERS THEN
            Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                      ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || SQLERRM);
        END;
      ELSE
        -- Actualiza los cupones pre-inscritos
        l_Dbg_Mensaje := 'Actualizar Cupones Pre-Inscritos';
        UPDATE Scfr_Cupones
           SET Estado_Cupon   = 'ACT'
              ,Fecha_Emision  = p_Transaccion.Fecha_Tx
              ,Fecha_Vigencia = l_Fecha_Vencimiento
              ,Codigo_Cupon   = l_Trama_Cp(l_Itm).Codigo_Cupon
         WHERE Cupones = l_Trama_Cp(l_Itm).Codigo_Interno_Cupon;
      END IF;
    END LOOP;
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Trama CP resuelta correctamente');
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      --scfr_trx_util_pk.error_msg( p_proceso=>l_DBG_PROCESO, p_msg=>l_DBG_MENSAJE );
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || SQLERRM);
      x_Cod_Error := 0;
  END;

  PROCEDURE Trama_Ci_Reversa(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                            ,x_Cod_Error   OUT NUMBER
                            ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Ci         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ci;
    l_Profile_Id       NUMBER;
    l_Itm              NUMBER;
    l_Cod_Error        VARCHAR2(100);
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_ci_resuelve';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    -- Obtiene informacion de la trama db
    l_Dbg_Mensaje := 'Obtener informacion de la trama CI (Cupones Generados Impresos)';
    l_Trama_Ci    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Ci(p_Transaccion.Cuerpo_Tx);
    FOR l_Itm IN 1 .. l_Trama_Ci.Count
    LOOP
      UPDATE Scfr_Cupones
         SET Estado_Cupon = 'INA'
            ,Procesado    = Nvl2(Procesado
                                ,2
                                ,Procesado)
       WHERE Codigo_Cupon = l_Trama_Ci(l_Itm).Codigo_Cupon;
    END LOOP;
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  PROCEDURE Trama_Cp_Reversa(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                            ,x_Cod_Error   OUT NUMBER
                            ,x_Msg_Error   OUT VARCHAR2) IS
    l_Itm              NUMBER;
    l_Cod_Error        VARCHAR2(100);
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_cp_reversa';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Reversar cupones emitidos impresos';
    UPDATE Scfr_Cupones
       SET Estado_Cupon = 'INA'
          ,Procesado    = Nvl2(Procesado
                              ,2
                              ,Procesado)
     WHERE Txo_Codigo_Tx_Emision = p_Transaccion.Codigo_Tx
       AND Estado_Cupon = 'ACT';
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  /*
    FUNCTION devuelve_party_beneficiario( p_rut_beneficiario IN NUMBER
                                        , p_party_id         IN NUMBER )
    RETURN NUMBER
    IS
      l_party NUMBER;
    BEGIN
      SELECT party_id
        INTO l_party
        FROM hz_parties
       WHERE jgzz_fiscal_code = RTRIM( LTRIM( TO_CHAR( p_rut_beneficiario ) ) );
      RETURN l_party;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN p_party_id;
    END devuelve_party_beneficiario;
  */
  PROCEDURE Trama_Db_Resuelve(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Db         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Db;
    l_Datos_Dp         Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp;
    l_Profile_Id       NUMBER;
    l_Itm              NUMBER;
    l_Cod_Error        VARCHAR2(100);
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_db_resuelve';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    l_Party_Id         NUMBER;
  BEGIN
    x_Cod_Error := 0;
    -- Obtiene informacion de la trama db
    l_Dbg_Mensaje := 'Obtener informacion de la trama DB (Datos Beneficiario/Paciente)';
    l_Trama_Db    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Db(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje := 'Recorrer detalle de la tama DB (Datos Beneficiario/Paciente)';
    FOR l_Itm IN 1 .. l_Trama_Db.Count
    LOOP
      l_Dbg_Mensaje               := 'Ejecutar scfr_clientes_pk.actualiza_persona';
      l_Datos_Dp.Apellido_Paterno := l_Trama_Db(l_Itm).Apellido_Paterno;
      l_Datos_Dp.Apellido_Materno := l_Trama_Db(l_Itm).Apellido_Materno;
      l_Datos_Dp.Nombres          := l_Trama_Db(l_Itm).Nombre;
      l_Party_Id                  := Scfr_Trx_Gnc_Utl_Pk.Devuelve_Party_Beneficiario(l_Trama_Db(l_Itm).Rut_Beneficiario
                                                                                    ,l_Trama_Db(l_Itm).Party_Id);
      Scfr_Trx_Fid_Pk.Actualiza_Persona(p_Party_Id      => l_Party_Id --l_trama_db(l_itm).party_id
                                       ,p_Rut_Cliente   => l_Trama_Db(l_Itm).Rut_Beneficiario
                                       ,p_Dvr_Cliente   => l_Trama_Db(l_Itm).Dv_Rut_Beneficiario
                                       ,p_Datos_Dp      => l_Datos_Dp
                                       ,p_Empresa       => p_Transaccion.Trama_Pos.Empresa
                                       ,p_Nombre_Respo  => NULL
                                       ,p_En_Linea      => 'SI'
                                       ,x_Return_Status => l_Cod_Error
                                       ,x_Msg_Data      => x_Msg_Error);
      /*
            scfr_clientes_pk.actualiza_persona ( l_trama_db(l_itm).party_id
                                               , l_trama_db(l_itm).rut_beneficiario
                                               , l_trama_db(l_itm).dv_rut_beneficiario
                                               , null
                                               , l_trama_db(l_itm).apellido_paterno
                                               , l_trama_db(l_itm).apellido_materno
                                               , l_trama_db(l_itm).nombre
                                               , null
                                               , null
                                               , null
                                               , null
                                               , null
                                               , null
                                               , null
                                               , null
                                               , null
                                               , l_profile_id
                                               , l_cod_error
                                               , x_msg_error );
      */
      BEGIN
        IF Ltrim(Rtrim(Nvl(l_Cod_Error
                          ,'0'))) IN ('0'
                                     ,'1'
                                     ,'2'
                                     ,'3'
                                     ,'4'
                                     ,'5'
                                     ,'6'
                                     ,'7'
                                     ,'8'
                                     ,'9'
                                     ,'E') THEN
          x_Cod_Error := l_Cod_Error;
        ELSE
          x_Cod_Error := 0;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          x_Cod_Error := 1;
      END;
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        Raise_Application_Error(-20000
                               ,x_Msg_Error);
      END IF;
    END LOOP;
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Trama DB resuelta correctamente');
  EXCEPTION
    WHEN l_Error_Controlado THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  FUNCTION Trama_Db_Prepara(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,l_Trama_Vt    IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vt
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Db IS
    l_Trama_Db         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Db;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_db_prepara';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    -- obtiene datos del beneficiario desde la transaccion original
    l_Dbg_Mensaje := 'Obtener datos del beneficiario desde la tabla SCFR_MOV_TRANSACCIONES';
    SELECT Rut_Beneficiario
          ,Dv_Beneficiario
          ,Pt_Party_Id_Beneficiario
          ,Secuencia_Beneficiario
      INTO l_Trama_Db(1).Rut_Beneficiario
          ,l_Trama_Db(1).Dv_Rut_Beneficiario
          ,l_Trama_Db(1).Party_Id
          ,l_Trama_Db(1).Secuencia_b
      FROM Scfr_Mov_Transacciones
     WHERE Codigo_Tx = p_Transaccion.Codigo_Tx;
    l_Dbg_Mensaje := 'Obtener datos del beneficiario desde la tabla HZ_PARTIES';
    IF Nvl(l_Trama_Db(1).Party_Id
          ,0) > 0 THEN
      SELECT Person_Last_Name
            ,Person_Middle_Name
            ,Person_First_Name
        INTO l_Trama_Db(1).Apellido_Paterno
            ,l_Trama_Db(1).Apellido_Materno
            ,l_Trama_Db(1).Nombre
        FROM Hz_Parties
       WHERE Party_Id = l_Trama_Db(1).Party_Id;
    END IF;
    RETURN l_Trama_Db;
  EXCEPTION
    WHEN OTHERS THEN
      l_Trama_Db(1).Rut_Beneficiario := NULL;
      RETURN l_Trama_Db;
      --scfr_trx_util_pk.error_msg( p_proceso=>l_DBG_PROCESO, p_msg=>'Error al intentar '||l_DBG_MENSAJE );
    --x_cod_error := sqlcode;
    --x_msg_error := sqlerrm;
  END;

  PROCEDURE Trama_Pa_Resuelve(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Pa         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pa;
    l_Itm              NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_pa_resuelve';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    x_Cod_Error := 0;
    -- Obtiene informacion de la trama pa
    l_Dbg_Mensaje := 'Obtener informacion de la trama PA (Producto Fidelizado CRM)';
    l_Trama_Pa    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Pa(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje := 'Recorrer detalle de la trama PA (Producto Fidelizado CRM)';
    FOR l_Itm IN 1 .. l_Trama_Pa.Count
    LOOP
      l_Dbg_Mensaje := 'Actualiza datos de la tabla SCFR_CLIENTES_USO_FRECUENTE';
      UPDATE Scfr_Clientes_Uso_Frecuente
         SET Estado_Uso_Frec = Decode(l_Trama_Pa(l_Itm).Estado_Crm
                                     ,'ACE'
                                     ,'ACT'
                                     ,'REC'
                                     ,'REC'
                                     ,'PEN'
                                     ,'PRE'
                                     ,'CAN'
                                     ,'CAN'
                                     ,l_Trama_Pa(l_Itm).Estado_Crm)
       WHERE Pt_Party_Id = p_Transaccion.Trama_Boc.Party_Id
         AND Puf_Uso_Frecuente = l_Trama_Pa(l_Itm).Uso_Frecuente;
    END LOOP;
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  PROCEDURE Trama_Pr_Resuelve(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Pr         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pr;
    l_Itm              NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_pr_resuelve';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    x_Cod_Error := 0;
    -- Obtiene informacion de la trama pa
    l_Dbg_Mensaje := 'Obtener informacion de la trama PR (Producto Compra Frecuente CRM)';
    l_Trama_Pr    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Pr(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje := 'Recorrer detalle de la trama PR (Producto Compra Frecuente CRM)';
    FOR l_Itm IN 1 .. l_Trama_Pr.Count
    LOOP
      l_Dbg_Mensaje := 'Actualiza datos de la tabla SCFR_CLIENTES_USO_FRECUENTE';
      UPDATE Scfr_Clientes_Uso_Frecuente
         SET Estado_Uso_Frec = Decode(l_Trama_Pr(l_Itm).Estado_Crm
                                     ,'ACE'
                                     ,'ACT'
                                     ,'REC'
                                     ,'REC'
                                     ,'PEN'
                                     ,'PRE'
                                     ,'CAN'
                                     ,'CAN'
                                     ,l_Trama_Pr(l_Itm).Estado_Crm)
       WHERE Pt_Party_Id = p_Transaccion.Trama_Boc.Party_Id
         AND Puf_Uso_Frecuente = l_Trama_Pr(l_Itm).Uso_Frecuente;
    END LOOP;
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  PROCEDURE Trama_Fp_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Fp            Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Fp;
    l_Itm                 NUMBER;
    l_Itm2                NUMBER;
    l_Existe              NUMBER;
    l_Mov_Pagos           NUMBER;
    l_Codigo_Tx           NUMBER;
    l_Fecha_Vencto        DATE;
    l_Dbg_Proceso         VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_fp_resuelve';
    l_Dbg_Mensaje         VARCHAR2(250) := 'Error General';
    l_Error_Controlado    EXCEPTION;
    x_Codigo_Autorizacion VARCHAR2(20);
    x_Sec_Cod_Auto        NUMBER := 1;
    l_Canreg              NUMBER := 0;
    l_Movcja              NUMBER := 0;
    l_Movpag              NUMBER := 1;
    l_Tipmov              VARCHAR2(6);
    p_Iva                 NUMBER := 0;
    l_Folio_Docto_Venta   Scfr_Mov_Documentos_Txs.Folio%TYPE;
  
    --//--------------------------------------------------------------------------\\
    --// CBR 04/04/2018 13:05  XML Local Aeropuerto                               \\
    --// Constante que indica el numero de local para generar XML solicitado      \\
    --//-----------------------------------------------------------------Inicio---\\
    l_Local_Aeropuerto NUMBER := 77;
    --//-----------------------------------------------------------------Termino--\\
    l_Comercio        VARCHAR2(30);
    l_Rut_Proveedor   VARCHAR2(30);
    l_Origen          VARCHAR2(30);
    l_Canal           VARCHAR2(30);
    l_Id_Tx           NUMBER;
    l_Id_Dev_Tx       VARCHAR2(30);
    l_Rut_Exc         NUMBER;
    l_Consulta        VARCHAR2(2000);
    l_Tipo_Doc        NUMBER;
    l_Cod_Rev         VARCHAR2(30);
    l_Cod_Error       VARCHAR2(2000);
    l_Msg_Error       VARCHAR2(2000);
    l_Respuesta       VARCHAR2(2000);
    l_Rev_Enviada     VARCHAR2(30);
    l_Fecha_Inicio    DATE;
    l_Es_Anulacion    VARCHAR2(30);
    l_Tipo_Doc_Ine    VARCHAR2(30);
    l_Numero_Convenio NUMBER(15);
    vlc_hash_tarjeta  varchar2(150); -- IDHC
    vlb_banda_magnetica blob; -- IDHC
    
    l_medio_pago_aux  varchar2(3); --JAGC 20250716 INMEDICAL MEDIO_PAGO 
    
  BEGIN
    x_Cod_Error := 0;
    l_Existe    := 0;
    -- Obtiene informacion de la trama fp
    l_Dbg_Mensaje := 'Obtener informacion de la trama FP (Forma de Pago)';
    l_Trama_Fp    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Fp(p_Transaccion.Cuerpo_Tx);
    /*
    select nvl(max(mov_pagos),0) + 1
      into Vmov_pagos
      from scfr_mov_pagos;
    */
    IF l_Trama_Fp.Count > 0 THEN
    
      IF Scfr_Trx_Dyn_Pk.Agrega_Iva(p_Transaccion.Trama_Pos.Cadena
                                   ,p_Transaccion.Trama_Pos.Empresa
                                   ,p_Transaccion.Trama_Pos.Local
                                   ,p_Iva) = 'SI' THEN
        FOR l_Item IN 1 .. l_Trama_Fp.Count
        LOOP
          IF l_Trama_Fp(l_Item).Medio_Pago = 'GUI' THEN
            -- l_Trama_Fp(l_Item).Monto_Documento := Round(l_Trama_Fp(l_Item).Monto_Documento * (1 + p_Iva / 100),0);
            -- l_Trama_Fp(l_Item).Monto_Forma_Pago := Round(l_Trama_Fp(l_Item).Monto_Forma_Pago * (1 + p_Iva / 100),0);
          
            l_Trama_Fp(l_Item).Monto_Documento := Ceil(l_Trama_Fp(l_Item).Monto_Documento * (1 + p_Iva / 100));
            l_Trama_Fp(l_Item).Monto_Forma_Pago := Ceil(l_Trama_Fp(l_Item).Monto_Forma_Pago * (1 + p_Iva / 100));
            FOR l_Itm2 IN 1 .. l_Trama_Fp(l_Item).Documentos_a_Cancelar
            LOOP
              IF l_Trama_Fp(l_Item).Subtrama_Fp1(l_Itm2).Tipo_Tx = 'RECAUD' THEN
                BEGIN
                  SELECT Codigo_Tx
                    INTO l_Codigo_Tx
                    FROM Scfr_Mov_Transacciones
                   WHERE Correlativo_Tx = l_Trama_Fp(l_Item).Subtrama_Fp1(l_Itm2).Correlativo_Tx
                     AND Loc_Local = p_Transaccion.Trama_Pos.Local
                     AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
                     AND Tmo_Movimiento_Padre = l_Trama_Fp(l_Item).Subtrama_Fp1(l_Itm2).Tipo_Tx
                     AND To_Char(Fecha_Tx
                                ,'yyyymm') = To_Char(To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Contable
                                                            ,'yyyymmdd')
                                                    ,'yyyymm');
                
                  UPDATE Scfr_Mov_Documentos_Txs t
                     SET t.Afecto = t.Monto
                        ,t.Monto  = Ceil(t.Monto * (1 + p_Iva / 100))
                        ,t.Iva    = t.Monto - t.Afecto
                   WHERE t.Txo_Codigo_Tx = l_Codigo_Tx;
                
                  UPDATE Scfr_Mov_Pagos p
                     SET p.Monto = Ceil(p.Monto * (1 + p_Iva / 100))
                   WHERE p.Mov_Pagos IN (SELECT t.Mpa_Mov_Pagos FROM Scfr_Mov_Transacciones_Pago t WHERE t.Txo_Codigo_Tx = l_Codigo_Tx);
                
                  UPDATE Scfr_Mov_Productos_Txs p
                     SET p.Pro_Precio_Lista = Ceil(p.Pro_Precio_Lista * (1 + p_Iva / 100))
                        ,p.Precio_Final     = Ceil(p.Precio_Final * (1 + p_Iva / 100))
                   WHERE p.Txo_Codigo_Tx = l_Codigo_Tx;
                
                  UPDATE Scfr_Mov_Productos_Documentos d
                     SET d.Precio_Final = Ceil(d.Precio_Final * (1 + p_Iva / 100))
                   WHERE d.Txo_Codigo_Tx = l_Codigo_Tx;
                
                  UPDATE Scfr_Mov_Productos_Dis i
                     SET i.Monto_Distribucion = Ceil(i.Monto_Distribucion * (1 + p_Iva / 100))
                   WHERE i.Txo_Codigo_Tx = l_Codigo_Tx;
                
                EXCEPTION
                  WHEN No_Data_Found THEN
                    NULL;
                  WHEN OTHERS THEN
                    NULL;
                END;
              
              END IF;
            END LOOP;
          END IF;
        END LOOP;
      END IF;
    
      -- ACJ 20100802  INICIO
      -- Prueba para eliminar ls transacciones que inicialmente fueron generadas como TBK inalambrico.
      -- Lo anterior, es para regularizar los valores finales de estas transacciones y enviar los
      -- valores correspondientes a locales para las anulaciones.
      BEGIN
        SELECT COUNT(1)
          INTO l_Canreg
          FROM Scfr_Mov_Transacciones      t
              ,Scfr_Mov_Transacciones_Pago Tp
         WHERE t.Correlativo_Tx = l_Trama_Fp(1).Subtrama_Fp1(1).Correlativo_Tx
           AND t.Loc_Local = p_Transaccion.Trama_Pos.Local
           AND t.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
           AND t.Tmo_Movimiento_Padre IN ('VENTAS'
                                         ,'RECAUD')
           AND To_Char(t.Fecha_Tx
                      ,'yyyymm') = To_Char(To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Contable
                                                  ,'yyyymmdd')
                                          ,'yyyymm')
              -- Mantis Nro 4188 --AND t.numero_maquina = p_transaccion.trama_pos.numero_pos
           AND Tp.Txo_Codigo_Tx = t.Codigo_Tx
           AND Tp.Tfp_Forma_Pago IN ('VOUCRI'
                                    ,'VOUDEI');
      EXCEPTION
        WHEN OTHERS THEN
          l_Canreg := 0;
      END;
      IF l_Canreg > 0 THEN
        FOR Reg IN (SELECT DISTINCT Tp.Mpa_Mov_Pagos
                      FROM Scfr_Mov_Transacciones      t
                          ,Scfr_Mov_Transacciones_Pago Tp
                     WHERE t.Correlativo_Tx = l_Trama_Fp(1).Subtrama_Fp1(1).Correlativo_Tx
                       AND t.Loc_Local = p_Transaccion.Trama_Pos.Local
                       AND t.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
                       AND t.Tmo_Movimiento_Padre IN ('VENTAS'
                                                     ,'RECAUD')
                       AND To_Char(t.Fecha_Tx
                                  ,'yyyymm') = To_Char(To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Contable
                                                              ,'yyyymmdd')
                                                      ,'yyyymm')
                          -- Mantis Nro 4188 --AND t.numero_maquina = p_transaccion.trama_pos.numero_pos
                       AND Tp.Txo_Codigo_Tx = t.Codigo_Tx)
        LOOP
          BEGIN
            DELETE Scfr_Mov_Detalle_Pagos d WHERE d.Mpa_Mov_Pagos = Reg.Mpa_Mov_Pagos;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
          BEGIN
            DELETE Scfr_Mov_Transacciones_Pago t WHERE t.Mpa_Mov_Pagos = Reg.Mpa_Mov_Pagos;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
          BEGIN
            DELETE Scfr_Mov_Pagos l WHERE l.Mov_Pagos = Reg.Mpa_Mov_Pagos;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
        END LOOP;
      END IF;
      -- ACJ 20100802  FIN
      -- CGC 20120109  INI /* Buscar si ya existen registros insertados asociados a CODIGO_TX */
      SELECT COUNT(1)
        INTO l_Existe
        FROM Scfr_Mov_Transacciones      t
            ,Scfr_Mov_Transacciones_Pago Tp
            ,Scfr_Mov_Pagos              Mp
       WHERE t.Correlativo_Tx = l_Trama_Fp(1).Subtrama_Fp1(1).Correlativo_Tx
         AND t.Loc_Local = p_Transaccion.Trama_Pos.Local
         AND t.Tmo_Movimiento_Padre = l_Trama_Fp(1).Subtrama_Fp1(1).Tipo_Tx
         AND t.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
         AND Tp.Txo_Codigo_Tx = t.Codigo_Tx
         AND Mp.Mov_Pagos = Tp.Mpa_Mov_Pagos
         AND Mp.Tfp_Forma_Pago = Tp.Tfp_Forma_Pago
         AND Mp.Codigo_Autorizacion = Tp.Codigo_Autorizacion;
      -- CGC 20120109  FIN
    END IF;
    -- Retornar si no se debe crear registros, cuando no trae formas de pago en trama FP o si ya se crearon registros en otra GNCU03.
    IF l_Trama_Fp.Count = 0 OR
       l_Trama_Fp.Count = l_Existe THEN
      RAISE l_Error_Controlado;
    END IF;
    l_Dbg_Mensaje := 'Obtener Folio para la tabla SCFR_MOV_PAGOS';
    SELECT Scfr_Mov_Pagos_s.Nextval INTO l_Mov_Pagos FROM Dual;
    l_Dbg_Mensaje := 'Recorrer detalle de la trama FP (Forma de Pago)';
    FOR l_Itm IN 1 .. l_Trama_Fp.Count
    LOOP
      l_Dbg_Mensaje := 'Chequear que Banco ' || l_Trama_Fp(l_Itm).Banco || ' exista';
      BEGIN
        SELECT 1 INTO l_Existe FROM Scfr_Bancos WHERE Banco = l_Trama_Fp(l_Itm).Banco;
      EXCEPTION
        WHEN OTHERS THEN
          l_Trama_Fp(l_Itm).Banco := 1; -- estaba en null se cambia a 1 para dejarlo igual a batc
      END;
      Dbms_Output.Put_Line(' FECHA VENCIMIENTO 1 ' || l_Trama_Fp(l_Itm).Fecha_Vencimiento);
      l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_PAGOS';
      IF Nvl(l_Trama_Fp(l_Itm).Fecha_Vencimiento
            ,0) = 0 THEN
        l_Fecha_Vencto := NULL;
      ELSE
        l_Fecha_Vencto := To_Date(l_Trama_Fp(l_Itm).Fecha_Vencimiento
                                 ,'YYYYMMDD');
      END IF;
      Dbms_Output.Put_Line(' FECHA VENCIMIENTO 2 ' || l_Fecha_Vencto);
      IF l_Trama_Fp(l_Itm).Codigo_Autorizacion IS NOT NULL AND
          Ltrim(Rtrim(l_Trama_Fp(l_Itm).Codigo_Autorizacion)) IS NOT NULL THEN
        l_Trama_Fp(l_Itm).Codigo_Autorizacion := Ltrim(Rtrim(l_Trama_Fp(l_Itm).Codigo_Autorizacion));
      END IF;
      -- Cambia el valor si se trata de un movimiento asociado a una anulacion (S = Salida) distinto avance
      IF l_Trama_Fp(l_Itm).Movimiento_Caja = 'S' AND
         l_Trama_Fp(l_Itm).Subtrama_Fp1(1).Tipo_Tx <> 'AVANCE' THEN
        l_Movpag := -1;
      END IF;
      -- Cambia el valor si se trata de un movimiento asociado a una entrada (E = Entrada) tipo avance
      IF l_Trama_Fp(l_Itm).Movimiento_Caja = 'E' AND
         l_Trama_Fp(l_Itm).Subtrama_Fp1(1).Tipo_Tx = 'AVANCE' THEN
        l_Movpag := -1;
      END IF;
    
      -- Coloco una secuencia numerica para poder guardar el dato cuando es movmiento Padre MVCAJA
      x_Codigo_Autorizacion := Nvl(TRIM(l_Trama_Fp(l_Itm).Codigo_Autorizacion)
                                  ,'0');
      IF l_Trama_Fp(l_Itm).Subtrama_Fp1(1).Tipo_Tx = 'MVCAJA' AND
          x_Codigo_Autorizacion = '0' THEN
        x_Codigo_Autorizacion := TRIM(To_Char(x_Sec_Cod_Auto));
        x_Sec_Cod_Auto        := x_Sec_Cod_Auto + 1;
      END IF;
      
      --INI JAGC 20250716 INMEDICAL MEDIO_PAGO
      l_medio_pago_aux := l_Trama_Fp(l_Itm).Medio_Pago; 
      
      DBMS_OUTPUT.PUT_LINE('l_Trama_Fp(l_Itm).Medio_Pago: ' || l_Trama_Fp(l_Itm).Medio_Pago);
      DBMS_OUTPUT.PUT_LINE('l_Trama_Fp(l_Itm).Forma_Pago: ' || l_Trama_Fp(l_Itm).Forma_Pago);
      
      IF l_Trama_Fp(l_Itm).Forma_Pago = 'VOUCNV' THEN
        BEGIN
          SELECT NVL(SUBSTR(trim(x.rv_abbreviation), 1, 3), '') INTO l_medio_pago_aux
          FROM FID.cg_ref_codes x
          WHERE x.rv_domain = 'ABF SERVICIOS'
          and x.rv_low_value = 'MEDIO_PAGO_EQUIVALENTE'
          and x.rv_high_value = TRIM(l_Trama_Fp(l_Itm).Medio_Pago)
          and ROWNUM = 1;   
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             l_medio_pago_aux := l_Trama_Fp(l_Itm).Medio_Pago;
        END;            
      END IF;
      
      IF l_medio_pago_aux = '' OR l_medio_pago_aux IS NULL THEN
        l_medio_pago_aux := l_Trama_Fp(l_Itm).Medio_Pago;
      END IF;
      
      DBMS_OUTPUT.PUT_LINE('l_medio_pago_aux: ' || l_medio_pago_aux);
      --INI JAGC 20250716 INMEDICAL MEDIO_PAGO
    
      INSERT INTO Scfr_Mov_Pagos
        (Mov_Pagos
        ,Tfp_Forma_Pago
        ,Medio_Pago
        ,Monto
        ,Per_Rut_Cajero
        ,Per_Dv_Cajero
        ,Tipo_Identi_Cajero
        ,Identi_Cajero
        ,Per_Codigo_Personal
        ,Maq_Maquina
        ,Emp_Empresa
        ,Cad_Cadena
        ,Loc_Local
        ,Codigo_Autorizacion
        ,Flujo_Caja
        ,Importe_Pago
        ,Importe_Cambio
        ,Importe_Pago_Usd
        ,Tipo_Cambio
        ,Secuencia_Int
        ,Autorizacion_Online) --FCG Nuevo campo Autorizacion online  origen OMS
      VALUES
        (l_Mov_Pagos --mov_pagos
        ,l_Trama_Fp(l_Itm).Forma_Pago --tfp_forma_pago
        ,l_medio_pago_aux --l_Trama_Fp(l_Itm).Medio_Pago --medio_pago --JAGC 20250716 INMEDICAL MEDIO_PAGO
        ,l_Trama_Fp(l_Itm).Monto_Forma_Pago * l_Movpag --monto
        ,l_Trama_Fp(l_Itm).Rut --per_rut_cajero
        ,l_Trama_Fp(l_Itm).Dv --per_dv_cajero
        ,Substr(l_Trama_Fp(l_Itm).Identi_Cajero
               ,1
               ,1)
        ,Substr(l_Trama_Fp(l_Itm).Identi_Cajero
               ,2
               ,30)
        ,l_Trama_Fp(l_Itm).Codigo_Personal --per_codigo_personal
        ,l_Trama_Fp(l_Itm).Id_Maquina --maq_maquina
        ,p_Transaccion.Trama_Pos.Empresa --emp_empresa
        ,p_Transaccion.Trama_Pos.Cadena --cad_cadena
        ,p_Transaccion.Trama_Pos.Local --loc_local
        ,x_Codigo_Autorizacion --codigo_autorizacion
        ,l_Trama_Fp(l_Itm).Flujo_Caja
        ,l_Trama_Fp(l_Itm).Importe_Pago
        ,l_Trama_Fp(l_Itm).Importe_Cambio
        ,l_Trama_Fp(l_Itm).Importe_Pago_Usd
        ,l_Trama_Fp(l_Itm).Tipo_Cambio
        ,l_Itm
        ,l_Trama_Fp(l_Itm).Autorizacion_Online);
    
      l_Dbg_Mensaje := 'Recorrer detalle la subtrama FP1 (Documentos a Cancelar)';
      FOR l_Itm2 IN 1 .. l_Trama_Fp(l_Itm).Subtrama_Fp1.Count
      LOOP
        l_Dbg_Mensaje := 'Buscar documentos a cancelar (correlativo_tx=>' || l_Trama_Fp(l_Itm).Subtrama_Fp1(l_Itm2).Correlativo_Tx || ', local=>' ||
                         p_Transaccion.Trama_Pos.Local || ')';
        SELECT Codigo_Tx
          INTO p_Transaccion.Codigo_Tx
          FROM Scfr_Mov_Transacciones
         WHERE Correlativo_Tx = l_Trama_Fp(l_Itm).Subtrama_Fp1(l_Itm2).Correlativo_Tx
           AND Loc_Local = p_Transaccion.Trama_Pos.Local
           AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
           AND Tmo_Movimiento_Padre = l_Trama_Fp(l_Itm).Subtrama_Fp1(l_Itm2).Tipo_Tx
           AND To_Char(Fecha_Tx
                      ,'yyyymm') = To_Char(To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Contable
                                                  ,'yyyymmdd')
                                          ,'yyyymm');
        -- Mantis Nro 4188 --AND numero_maquina = p_transaccion.trama_pos.numero_pos;
        -- CGC INI 25/01/2013
        -- Obtener tipo de movimiento hijo antes de actualizar
        SELECT d.Tmo_Movimiento
          INTO l_Tipmov
          FROM Scfr_Mov_Documentos_Txs d
         WHERE d.Txo_Codigo_Tx = p_Transaccion.Codigo_Tx
           AND Rownum = 1;
        -- Actualiza el codigo de la transaccion (Se excluye Vission/Paris)
        IF l_Tipmov NOT IN ('RECPAR'
                           ,'RECVIS'
                           ,'ANUPAR'
                           ,'ANUVIS') THEN
          UPDATE Scfr_Mov_Transacciones
             SET Estx_Codigo_Tx    = TRIM(l_Trama_Fp(l_Itm).Codigo_Transaccion)
                ,Estx_Correlativo  = l_Trama_Fp(l_Itm).Correlativo
                ,Estx_Destino      = l_Trama_Fp(l_Itm).Destino
                ,Estx_Fecha        = To_Date(l_Trama_Fp(l_Itm).Fecha_Transaccion
                                            ,'yyyymmddhh24miss')
                ,Estx_Funcion      = l_Trama_Fp(l_Itm).Funcion
                ,Estx_Numero_Local = l_Trama_Fp(l_Itm).Local
                ,Estx_Numero_Pos   = l_Trama_Fp(l_Itm).Numero_Pos
                ,Estx_Numero_Trama = l_Trama_Fp(l_Itm).Numero_Trama
                ,Estx_Secuencia    = l_Trama_Fp(l_Itm).Secuencia_c
                ,Estx_Sistema      = l_Trama_Fp(l_Itm).Sistema
                ,Estx_Srv_Codigo   = l_Trama_Fp(l_Itm).Codigo_Servicio
           WHERE Codigo_Tx = p_Transaccion.Codigo_Tx;
        END IF;
        -- CGC FIN 25/01/2013
        l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_TRANSACCIONES_PAGO';
        INSERT INTO Scfr_Mov_Transacciones_Pago
          (Txo_Codigo_Tx
          ,Mpa_Mov_Pagos
          ,Tfp_Forma_Pago
          ,Txo_Correlativo_Tx
          ,Codigo_Autorizacion
          ,Empresa
          ,Cadena
          ,Loc_Local
          ,Secuencia_Int)
        VALUES
          (p_Transaccion.Codigo_Tx
          ,l_Mov_Pagos
          ,l_Trama_Fp(l_Itm).Forma_Pago
          ,l_Trama_Fp(l_Itm).Subtrama_Fp1(l_Itm2).Correlativo_Tx
          ,x_Codigo_Autorizacion
          ,p_Transaccion.Trama_Pos.Empresa
          ,p_Transaccion.Trama_Pos.Cadena
          ,p_Transaccion.Trama_Pos.Local
          ,l_Itm);
        -- Cuenta si documento a cancelar es MVCAJA o CIERRE
        IF l_Trama_Fp(l_Itm).Subtrama_Fp1(l_Itm2).Tipo_Tx IN ('MVCAJA'
                       ,'CIERRE') THEN
          l_Movcja := l_Movcja + 1;
        END IF;
      END LOOP;
      IF Upper(Ltrim(Rtrim(l_Trama_Fp(l_Itm).Forma_Pago))) != 'EFECTI' AND
         l_Movcja = 0 THEN
        l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_DETALLE_PAGOS';
        /*
                scfr_trx_util_pk.debug_msg(p_proceso=>l_DBG_PROCESO, p_msg=>'mov_detalle_pagos.mpa_mov_pagos=>'||l_mov_pagos, x_coderror=>x_cod_error, x_msgerror=>x_msg_error);
                scfr_trx_util_pk.debug_msg(p_proceso=>l_DBG_PROCESO, p_msg=>'mov_detalle_pagos.tfp_forma_pago=>'||l_trama_fp(l_itm).forma_pago, x_coderror=>x_cod_error, x_msgerror=>x_msg_error);
                scfr_trx_util_pk.debug_msg(p_proceso=>l_DBG_PROCESO, p_msg=>'mov_detalle_pagos.codigo_autorizacion=>'||l_trama_fp(l_itm).cod_autorizacion, x_coderror=>x_cod_error, x_msgerror=>x_msg_error);
                scfr_trx_util_pk.debug_msg(p_proceso=>l_DBG_PROCESO, p_msg=>'mov_detalle_pagos.rut_titular=>'||l_trama_fp(l_itm).rut_titular, x_coderror=>x_cod_error, x_msgerror=>x_msg_error);
                scfr_trx_util_pk.debug_msg(p_proceso=>l_DBG_PROCESO, p_msg=>'mov_detalle_pagos.dv_titular=>'||l_trama_fp(l_itm).dv_titular, x_coderror=>x_cod_error, x_msgerror=>x_msg_error);
                scfr_trx_util_pk.debug_msg(p_proceso=>l_DBG_PROCESO, p_msg=>'mov_detalle_pagos.numero_cheque=>'||l_trama_fp(l_itm).numero_documento, x_coderror=>x_cod_error, x_msgerror=>x_msg_error);
                scfr_trx_util_pk.debug_msg(p_proceso=>l_DBG_PROCESO, p_msg=>'mov_detalle_pagos.numero_cuenta_tarjeta=>'||l_trama_fp(l_itm).numero_cuenta, x_coderror=>x_cod_error, x_msgerror=>x_msg_error);
                scfr_trx_util_pk.debug_msg(p_proceso=>l_DBG_PROCESO, p_msg=>'mov_detalle_pagos.bnc_banco=>'||l_trama_fp(l_itm).banco, x_coderror=>x_cod_error, x_msgerror=>x_msg_error);
                scfr_trx_util_pk.debug_msg(p_proceso=>l_DBG_PROCESO, p_msg=>'mov_detalle_pagos.fecha_vencimiento=>'||l_fecha_vencto, x_coderror=>x_cod_error, x_msgerror=>x_msg_error);
                scfr_trx_util_pk.debug_msg(p_proceso=>l_DBG_PROCESO, p_msg=>'mov_detalle_pagos.monto_cheque=>'||l_trama_fp(l_itm).monto_documento, x_coderror=>x_cod_error, x_msgerror=>x_msg_error);
                scfr_trx_util_pk.debug_msg(p_proceso=>l_DBG_PROCESO, p_msg=>'mov_detalle_pagos.monto_aplicado=>'||l_trama_fp(l_itm).monto_documento, x_coderror=>x_cod_error, x_msgerror=>x_msg_error);
                scfr_trx_util_pk.debug_msg(p_proceso=>l_DBG_PROCESO, p_msg=>'mov_detalle_pagos.tipo_autorizacion=>'||l_trama_fp(l_itm).tipo_autorizacion, x_coderror=>x_cod_error, x_msgerror=>x_msg_error);
                scfr_trx_util_pk.debug_msg(p_proceso=>l_DBG_PROCESO, p_msg=>'mov_detalle_pagos.movimiento_e_s=>'||l_trama_fp(l_itm).movimiento_caja, x_coderror=>x_cod_error, x_msgerror=>x_msg_error);
        */
        --//--------------------------------------------------------------------------\\
        --// CBR 18/02/2011 15:30 REP. Problemas en Piloto 57 con anulacion TBK       \\
        --//-----------------------------------------------------------------Inicio---\\
        --Si no trae marca TBK, el valor del campo a insertar es NULL (este campo es nuevo)
        -- IF p_Transaccion.Trama_Pos.Origen_Transaccion != 'TBK' THEN
        -- l_Trama_Fp(l_Itm).Id_Transaccion := NULL;
        -- l_Trama_Fp(l_Itm).Valor_Cuota := NULL;
        -- END IF;
        --//-----------------------------------------------------------------Termino--\\
        if l_Trama_Fp(l_Itm).Forma_Pago = 'P2PPEY' and 
          length(Ltrim(Rtrim(l_Trama_Fp(l_Itm).Numero_Cuenta)))<=6 and 
          trim(Utl_Raw.Cast_To_Varchar2(l_Trama_Fp(l_Itm).Banda_Magnetica)) is null then -- IDHC 
          
          vlc_hash_tarjeta := Ltrim(Rtrim(l_Trama_Fp(l_Itm).Numero_Cuenta));
          vlb_banda_magnetica := utl_raw.cast_to_raw(vlc_hash_tarjeta);
        else
          vlc_hash_tarjeta := Substr(Utl_Raw.Cast_To_Varchar2(l_Trama_Fp(l_Itm).Banda_Magnetica)
                 ,1
                 ,250);
          vlb_banda_magnetica := Utl_Raw.cast_to_raw(Utl_Raw.Cast_To_Varchar2(l_Trama_Fp(l_Itm).Banda_Magnetica));
        end if;
        
        INSERT INTO Scfr_Mov_Detalle_Pagos
          (Mpa_Mov_Pagos
          ,Tfp_Forma_Pago
          ,Codigo_Autorizacion
          ,Rut_Titular
          ,Dv_Titular
          ,Tipo_Identi_Titular
          ,Identi_Titular
          ,Numero_Cheque
          ,Numero_Cuenta_Tarjeta
          ,Bnc_Banco
          ,Fecha_Vencimiento
          ,Monto_Cheque
          ,Monto_Aplicado
          ,Tipo_Autorizacion
          ,Movimiento_e_s
          ,Numero_Cuotas
          ,Interes
          ,Banda_Magnetica
          ,Estx_Funcion
          ,Estx_Codigo_Tx
          ,Estx_Srv_Codigo
          ,Estx_Fecha
          ,Estx_Numero_Pos
          ,Secuencia_Pago
          ,Meses_Diferido
          ,Tipo_Cuotas
          ,Numero_Tx_Comercio
          ,Id_Transaccion
          ,Valor_Cuota
          ,Empresa
          ,Cadena
          ,Loc_Local
          ,Modo_Ingreso_Tarjeta
          ,Secuencia_Int
          ,Cliente_Tarjeta
          ,Telefono_Cliente
          ,Hash_Tarjeta
          ,Celular_Cliente
          ,Direccion_Cliente
          ,Genero
          ,Nacimiento)
        VALUES
          (l_Mov_Pagos
          ,l_Trama_Fp(l_Itm).Forma_Pago
          ,x_Codigo_Autorizacion
          ,l_Trama_Fp(l_Itm).Rut_Titular
          ,l_Trama_Fp(l_Itm).Dv_Titular
          ,Substr(l_Trama_Fp(l_Itm).Identi_Titular
                 ,1
                 ,1)
          ,Substr(l_Trama_Fp(l_Itm).Identi_Titular
                 ,2
                 ,30)
          ,Nvl(TRIM(l_Trama_Fp(l_Itm).Numero_Documento)
              ,0)
          ,Ltrim(Rtrim(l_Trama_Fp(l_Itm).Numero_Cuenta))
          ,Nvl(l_Trama_Fp(l_Itm).Banco,0)
          ,l_Fecha_Vencto
          ,l_Trama_Fp(l_Itm).Monto_Documento
          ,l_Trama_Fp(l_Itm).Monto_Forma_Pago
          ,l_Trama_Fp(l_Itm).Tipo_Autorizacion
          ,l_Trama_Fp(l_Itm).Movimiento_Caja
          ,l_Trama_Fp(l_Itm).Cantidad_Cuotas
          ,To_Number(l_Trama_Fp(l_Itm).Interes)
          ,vlb_banda_magnetica -- IDHC --l_Trama_Fp(l_Itm).Banda_Magnetica
          ,l_Trama_Fp(l_Itm).Funcion
          ,TRIM(l_Trama_Fp(l_Itm).Codigo_Transaccion)
          ,l_Trama_Fp(l_Itm).Codigo_Servicio
          ,To_Date(l_Trama_Fp(l_Itm).Fecha_Transaccion
                  ,'yyyymmddhh24miss')
          ,l_Trama_Fp(l_Itm).Numero_Pos
          ,l_Trama_Fp(l_Itm).Secuencia_Pago
          ,l_Trama_Fp(l_Itm).Meses_Diferido
          ,l_Trama_Fp(l_Itm).Tipo_Cuotas
          ,l_Trama_Fp(l_Itm).Numero_Tx_Comercio
          ,Nvl(TRIM(l_Trama_Fp(l_Itm).Id_Transaccion)
              ,0)
          ,l_Trama_Fp(l_Itm).Valor_Cuota
          ,p_Transaccion.Trama_Pos.Empresa
          ,p_Transaccion.Trama_Pos.Cadena
          ,p_Transaccion.Trama_Pos.Local
          ,l_Trama_Fp(l_Itm).Modo_Ingreso_Tarjeta
          ,l_Itm
          ,TRIM(l_Trama_Fp(l_Itm).Cliente_Tarjeta)
          ,TRIM(l_Trama_Fp(l_Itm).Telefono_Cliente)
          ,vlc_hash_tarjeta -- IDHC --Substr(Utl_Raw.Cast_To_Varchar2(l_Trama_Fp(l_Itm).Banda_Magnetica),1,250)
          ,TRIM(l_Trama_Fp(l_Itm).Celular_Cliente)
          ,TRIM(l_Trama_Fp(l_Itm).Direccion_Cliente)
          ,l_Trama_Fp(l_Itm).Genero
          ,l_Trama_Fp(l_Itm).Nacimiento);
      
        -- Actualiza numero de convenio para venta como medio de pago CNVEMP
        IF (l_Trama_Fp(l_Itm).Forma_Pago = 'CNVEMP') THEN
        
          BEGIN
            SELECT Convenio
              INTO l_Numero_Convenio
              FROM Vitalcard.Vc_Tarjetas@Appdfm_To_Prod.uio
             WHERE Numero_Tarjeta = TRIM(Substr(Utl_Raw.Cast_To_Varchar2(l_Trama_Fp(l_Itm).Banda_Magnetica)
                                               ,1
                                               ,250))
               AND Rownum = 1;
          EXCEPTION
            WHEN OTHERS THEN
              l_Numero_Convenio := NULL;
          END;
          IF (l_Numero_Convenio IS NOT NULL) THEN
            UPDATE Scfr_Mov_Transacciones SET Con_Numero_Convenio = l_Numero_Convenio WHERE Codigo_Tx = p_Transaccion.Codigo_Tx;
          END IF;
        END IF;
      
      END IF;
      IF Upper(Ltrim(Rtrim(l_Trama_Fp(l_Itm).Forma_Pago))) = 'VOUEXC' THEN
        BEGIN
          SELECT b.Codigo_Autorizacion_Fcv
                ,b.Codigo_Autorizacion_Ext
                ,b.Rut
                ,b.Comercio
                ,TRIM(Substr(b.Consulta
                            ,Instr(b.Consulta
                                  ,'|'
                                  ,1
                                  ,11) + 1
                            ,Instr(b.Consulta
                                  ,'|'
                                  ,1
                                  ,12) - Instr(b.Consulta
                                              ,'|'
                                              ,1
                                              ,11) - 1)) Tipo_Docto
            INTO l_Id_Tx
                ,l_Id_Dev_Tx
                ,l_Rut_Exc
                ,l_Comercio
                ,l_Tipo_Doc_Ine
            FROM Scfr_Log_Autorizacion_Mdp b
           WHERE b.Codigo_Autorizacion_Fcv = l_Trama_Fp(l_Itm).Codigo_Autorizacion
             AND b.Tipo_Operacion = 'INE';
        EXCEPTION
          WHEN OTHERS THEN
            l_Id_Tx := 0;
        END;
        BEGIN
          SELECT a.Attribute1
                ,a.Attribute2
                ,a.Attribute3
            INTO l_Rut_Proveedor
                ,l_Origen
                ,l_Canal
            FROM Scfr_Comn_Externa a
           WHERE a.Proceso = 'EXCEDENTE_MDP'
             AND a.Empresa_Que_Autoriza = l_Comercio;
        EXCEPTION
          WHEN OTHERS THEN
            l_Rut_Proveedor := NULL;
            l_Origen        := NULL;
            l_Canal         := NULL;
        END;
        BEGIN
          SELECT 'SI'
            INTO l_Rev_Enviada
            FROM Scfr_Log_Autorizacion_Mdp b
           WHERE b.Codigo_Autorizacion_Fcv = l_Trama_Fp(l_Itm).Codigo_Autorizacion
             AND b.Tipo_Operacion = 'REV'
             AND b.Codigo_Resultado = '0';
        EXCEPTION
          WHEN OTHERS THEN
            l_Rev_Enviada := 'NO';
        END;
        BEGIN
          SELECT 'SI'
            INTO l_Es_Anulacion
            FROM Scfr_Mov_Documentos_Txs b
                ,Scfr_Mov_Transacciones  a
           WHERE a.Correlativo_Tx = l_Trama_Fp(l_Itm).Subtrama_Fp1(1).Correlativo_Tx
             AND a.Loc_Local = p_Transaccion.Trama_Pos.Local
             AND a.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
             AND a.Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
             AND b.Txo_Codigo_Tx = a.Codigo_Tx
             AND b.Tmo_Movimiento = 'ANUEXC';
        EXCEPTION
          WHEN OTHERS THEN
            l_Es_Anulacion := 'NO';
        END;
        IF l_Id_Tx > 0 AND
           l_Rev_Enviada = 'NO' AND
           l_Es_Anulacion = 'SI' THEN
          BEGIN
            SELECT a.Doc_Interno1
              INTO l_Tipo_Doc
              FROM Scfr_Comercios_Doc a
             WHERE a.Comercio = l_Comercio --Upper(Ltrim(Rtrim(l_Trama_Fp(l_Itm).Medio_Pago)))
               AND a.Cadena = p_Transaccion.Trama_Pos.Empresa
               AND a.Doc_Externo = l_Tipo_Doc_Ine;
          EXCEPTION
            WHEN OTHERS THEN
              l_Tipo_Doc := 1;
          END;
        
          -- Crea_Lst('LOG_EXC ' || l_Id_Tx || '.TXT','ANULA ENVIADO ====> ' || l_Consulta);
          l_Fecha_Inicio := SYSDATE;
        
          --//--------------------------------------------------------------------------\\
          --// CBR 03/27/2020 6:29PM                                                    \\
          --// Rescato el folio de venta ORIGINAL (vengui/venbol)                       \\
          --//-----------------------------------------------------------------Inicio---\\
          BEGIN
            SELECT Folio
              INTO l_Folio_Docto_Venta
              FROM Scfr_Mov_Documentos_Txs
             WHERE Txo_Correlativo_Tx = (SELECT o.Txo_Codigo_Tx_Relacionado
                                           FROM Scfr_Mov_Transacciones o
                                          WHERE o.Correlativo_Tx = l_Trama_Fp(l_Itm).Subtrama_Fp1(1).Correlativo_Tx)
               AND Tmo_Movimiento IN ('VENBOL'
                                     ,'VENGUI')
               AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
               AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
               AND Loc_Local = l_Trama_Fp(l_Itm).Local;
          EXCEPTION
            WHEN OTHERS THEN
              l_Folio_Docto_Venta := 0;
          END;
          --//-----------------------------------------------------------------Termino--\\
          l_Consulta := p_Transaccion.Trama_Pos.Empresa || '|' || p_Transaccion.Trama_Pos.Cadena || '|' || p_Transaccion.Trama_Pos.Local || '|' ||
                        l_Comercio || '|' || l_Rut_Proveedor || '|' || l_Rut_Exc || '|' || l_Id_Tx || '|' || l_Id_Dev_Tx || '|' || l_Tipo_Doc || '|' ||
                        l_Folio_Docto_Venta || '|' || l_Origen || '|' || l_Canal;
        
          BEGIN
            Pkg_Excedentes_Mp.Proc_Anulacion_Excendentes(p_Empresa       => p_Transaccion.Trama_Pos.Empresa
                                                        ,p_Cadena        => p_Transaccion.Trama_Pos.Cadena
                                                        ,p_Local         => p_Transaccion.Trama_Pos.Local
                                                        ,p_Comercio      => l_Comercio --Upper(Ltrim(Rtrim(l_Trama_Fp(l_Itm).Medio_Pago)))
                                                        ,p_Fecha         => SYSDATE
                                                        ,p_Rut_Proveedor => l_Rut_Proveedor
                                                        ,p_Rut_Cliente   => l_Rut_Exc
                                                        ,p_Id_Tx         => l_Id_Tx
                                                        ,p_Id_Dev_Tx     => l_Id_Dev_Tx
                                                        ,p_Tipo_Doc      => l_Tipo_Doc
                                                        ,p_Folio         => l_Folio_Docto_Venta
                                                        ,p_Origen        => l_Origen
                                                        ,p_Canal         => l_Canal
                                                        ,x_Respuesta     => l_Cod_Rev
                                                        ,x_Cod_Error     => l_Cod_Error
                                                        ,x_Des_Error     => l_Msg_Error);
          
            l_Respuesta := l_Cod_Rev || '|' || l_Cod_Error || '|' || l_Msg_Error;
            -- Crea_Lst('LOG_EXC ' || l_Id_Tx || '.TXT','ANULA RESPUESTA ====> ' || l_Respuesta);
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
          Log_Autext(p_Proceso                 => Upper(Ltrim(Rtrim(l_Trama_Fp(l_Itm).Medio_Pago)))
                    ,p_Tipo_Operacion          => 'REV'
                    ,p_Fecha_Autorizacion      => l_Fecha_Inicio
                    ,p_Fecha_Confirmacion      => SYSDATE
                    ,p_Codigo_Resultado        => l_Cod_Error
                    ,p_Codigo_Autorizacion_Fcv => l_Id_Tx
                    ,p_Codigo_Autorizacion_Ext => l_Cod_Rev
                    ,p_Consulta                => l_Consulta
                    ,p_Respuesta               => l_Respuesta
                    ,p_Glosa_Respuesta         => 'FP-Resp Anulaion Excedente ' || SQLERRM
                    ,p_Rut                     => p_Transaccion.Rut_Titular
                    ,p_Local                   => p_Transaccion.Trama_Pos.Local
                    ,x_Cod_Error               => l_Cod_Error
                    ,x_Msg_Error               => l_Msg_Error);
        
        END IF;
      END IF;
    END LOOP;
    -- LLama a servicio Convenio Empresarial
    Scfr_Trx_Conv_Empresarial_Pk.Registra_Venta_Empresarial(p_Codigo_Tx => p_Transaccion.Codigo_Tx
                                                           ,x_Cod_Error => x_Cod_Error
                                                           ,x_Msg_Error => x_Msg_Error);
    --//--------------------------------------------------------------------------\\
    --// CBR 04/04/2018 13:05  XML Local Aeropuerto                               \\
    --//-----------------------------------------------------------------Inicio---\\
    --  IF p_Transaccion.Local_Origen = l_Local_Aeropuerto AND
    IF p_Transaccion.Trama_Pos.Local = l_Local_Aeropuerto AND
       l_Trama_Fp(1).Subtrama_Fp1(1).Tipo_Tx = 'VENTAS' AND
       Nvl(p_Transaccion.Codigo_Tx
          ,0) > 0 THEN
    
      Arma_Xml_Aeropuerto(p_Transaccion.Codigo_Tx
                         ,l_Trama_Fp(1).Subtrama_Fp1(1).Correlativo_Tx
                         ,x_Cod_Error
                         ,x_Msg_Error);
    
    END IF;
    Scfr_Trx_Conv_Empresarial_Pk.Registra_Venta_Sam(p_Transaccion.Codigo_Tx
                                                   ,x_Cod_Error
                                                   ,x_Msg_Error);
    Scfr_Trx_Conv_Empresarial_Pk.Carga_Int_Abf_Online(p_Transaccion.Codigo_Tx);
    --//---------------------------------------------------------------Termino--\\
    -- metodo que trae de la tabla stageAbf para insertar en mov_integracion_abf
    -- solo se ejecuta si hay registro en en el stage sin procesar
    Scfr_Trx_Conv_Empresarial_Pk.Carga_Int_Abf_Online_V2(
                                                          p_Transaccion.Codigo_Tx,
                                                          x_Cod_Error,
                                                          x_Msg_Error
                                                          );
  EXCEPTION
    WHEN Dup_Val_On_Index THEN
      ROLLBACK;
      x_Cod_Error := 0;
      x_Msg_Error := '';
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  --//--------------------------------------------------------------------------\\
  --// CBR 13/04/2020 12:44                                                     \\
  --// Validacion numero de serie en Biometria                                  \\
  --//-----------------------------------------------------------------Inicio---\\
  PROCEDURE Trama_Ns_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Ns            Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ns;
    l_Itm                 NUMBER;
    l_Itm2                NUMBER;
    l_Existe              NUMBER;
    l_Id_Secuencia        NUMBER;
    l_Codigo_Tx           NUMBER;
    l_Fecha_Vencto        DATE;
    l_Dbg_Proceso         VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_NS_Resuelve';
    l_Dbg_Mensaje         VARCHAR2(250) := 'Error General';
    l_Error_Controlado    EXCEPTION;
    x_Codigo_Autorizacion VARCHAR2(30);
    x_Sec_Cod_Auto        NUMBER := 1;
    l_Canreg              NUMBER := 0;
    l_Movcja              NUMBER := 0;
    l_Movpag              NUMBER := 1;
    l_Tipmov              VARCHAR2(6);
    p_Iva                 NUMBER := 0;
  
  BEGIN
    x_Cod_Error := 0;
    l_Existe    := 0;
    -- Obtiene informacion de la trama Sk
    l_Dbg_Mensaje := 'Obtener informacion de la trama Ns (Validacion Serie Biometria)';
    l_Trama_Ns    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Ns(p_Transaccion.Cuerpo_Tx);
  
    FOR l_Itm1 IN 1 .. l_Trama_Ns.Count
    LOOP
      l_Dbg_Mensaje := 'Grabar datos de Trama Ns, en tabla SCFR_EVENTOS_BIOMETRIA (' || l_Itm1 || ')';
      INSERT INTO Scfr_Eventos_Biometria
        (Emp_Empresa
        ,Cad_Cadena
        ,Loc_Local
        ,Numero_Pos
        ,Correlativo_Tx
        ,Tipo_Tx
        ,Fecha_Hora_Validacion
        ,Rut_Cliente
        ,Dv_Rut_Cliente
        ,Validacion_Biometria
        ,Codigo_Validacion_Biometria
        ,Descrip_Validacion_Biometria
        ,Validacion_Nro_Serie_Cedula
        ,Codigo_Validacion_Cedula
        ,Descrip_Validacion_Cedula
        ,Resultado_Firma_Electronica
        ,Mensaje_Firma_Electronica
        ,Codigo_Dec
        ,Resultado_Digitalizacion
        ,Documentos_Postergados
        ,Ticket_Postergacion_Digital
        ,Trace
        ,Serie_Dcto_Ingresado
        ,Json_Utilizado)
      VALUES
        (p_Transaccion.Trama_Pos.Empresa
        ,p_Transaccion.Trama_Pos.Cadena
        ,p_Transaccion.Trama_Pos.Local
        ,p_Transaccion.Trama_Pos.Numero_Pos
        ,l_Trama_Ns(l_Itm1).Correlativo_Tx
        ,l_Trama_Ns(l_Itm1).Tipo_Tx
        ,To_Date(To_Char(l_Trama_Ns(l_Itm1).Fecha_Hora_Validacion)
                ,'yyyymmddhh24miss')
        ,l_Trama_Ns(l_Itm1).Rut_Cliente
        ,l_Trama_Ns(l_Itm1).Dv_Rut_Cliente
        ,l_Trama_Ns(l_Itm1).Validacion_Biometria
        ,l_Trama_Ns(l_Itm1).Codigo_Validacion_Biometria
        ,l_Trama_Ns(l_Itm1).Descrip_Validacion_Biometria
        ,l_Trama_Ns(l_Itm1).Validacion_Nro_Serie_Cedula
        ,l_Trama_Ns(l_Itm1).Codigo_Validacion_Serie_Cedula
        ,l_Trama_Ns(l_Itm1).Descrip_Validacion_Cedula
        ,l_Trama_Ns(l_Itm1).Resultado_Firma_Electronica
        ,l_Trama_Ns(l_Itm1).Mensaje_Firma_Electronica
        ,l_Trama_Ns(l_Itm1).Codigo_Dec
        ,l_Trama_Ns(l_Itm1).Resultado_Digitalizacion
        ,l_Trama_Ns(l_Itm1).Documentos_Postergados
        ,l_Trama_Ns(l_Itm1).Ticket_Postergacion_Digital
        ,l_Trama_Ns(l_Itm1).Trace
        ,l_Trama_Ns(l_Itm1).Serie_Dcto_Ingresado
        ,l_Trama_Ns(l_Itm1).Json_Utilizado);
    END LOOP;
  
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN Dup_Val_On_Index THEN
      ROLLBACK;
      x_Cod_Error := 0;
      x_Msg_Error := '';
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;
  --//-----------------------------------------------------------------Termino--\\

  --//--------------------------------------------------------------------------\\
  --// CBR 13/05/2019 17:19  TRANSACCION GNCU12 TURNOMATICO                     \\
  --//-----------------------------------------------------------------Inicio---\\
  PROCEDURE Trama_Na_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Na            Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Na;
    l_Itm                 NUMBER;
    l_Itm2                NUMBER;
    l_Existe              NUMBER;
    l_Secuencia_Turnos    NUMBER;
    l_Codigo_Tx           NUMBER;
    l_Fecha_Vencto        DATE;
    l_Dbg_Proceso         VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_na_resuelve';
    l_Dbg_Mensaje         VARCHAR2(250) := 'Error General';
    l_Error_Controlado    EXCEPTION;
    x_Codigo_Autorizacion VARCHAR2(30);
    x_Sec_Cod_Auto        NUMBER := 1;
    l_Canreg              NUMBER := 0;
    l_Movcja              NUMBER := 0;
    l_Movpag              NUMBER := 1;
    l_Tipmov              VARCHAR2(6);
    p_Iva                 NUMBER := 0;
  
  BEGIN
    x_Cod_Error := 0;
    l_Existe    := 0;
    -- Obtiene informacion de la trama Na
    l_Dbg_Mensaje := 'Obtener informacion de la trama NA (Numero Atencion)';
    l_Trama_Na    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Na(p_Transaccion.Cuerpo_Tx);
  
    l_Dbg_Mensaje := 'Obtener Secuencia para grabar en tabla SCFR_TURNOS_ATENCION';
    SELECT Scfr_Turnos_Atencion_s.Nextval INTO l_Secuencia_Turnos FROM Dual;
  
    --FOR l_Itm1 IN 1 .. l_Trama_Na.Count
    --LOOP
  
    l_Dbg_Mensaje := 'Grabar datos de Trama NA, en tabla SCFR_TURNOS_ATENCION';
    INSERT INTO Scfr_Turnos_Atencion
      (Correlativo_Secuencia
      ,Emp_Empresa
      ,Cad_Cadena
      ,Loc_Local
      ,Numero_Pos
      ,Tipo_Llamado
      ,Llamado_Fecha_Hora
      ,Numero_Turno
      ,Rut_Atencion
      ,Dv_Atencion
      ,Tiempo_Espera
      ,Inicio_Servicio_Fecha_Hora
      ,Cod_Vendedor
      ,Cod_Autorizacion
      ,Fin_Servicio_Fecha_Hora)
    VALUES
      (l_Secuencia_Turnos
      ,p_Transaccion.Trama_Pos.Empresa
      ,p_Transaccion.Trama_Pos.Cadena
      ,p_Transaccion.Trama_Pos.Local
      ,p_Transaccion.Trama_Pos.Numero_Pos
      ,l_Trama_Na.Tipo_Llamado
      ,To_Date(l_Trama_Na.Llamado
              ,'YYYYMMDDHH24MISS')
      ,Rtrim(Ltrim(l_Trama_Na.Numero_De_Turno))
      ,l_Trama_Na.Rut_Atencion
      ,Scfr_Trx_Gnc_Utl_Pk.Obtiene_Digito_Verificador(l_Trama_Na.Rut_Atencion)
      ,Rtrim(Ltrim(l_Trama_Na.Tiempo_Espera))
      ,To_Date(l_Trama_Na.Inicio_Servicio
              ,'YYYYMMDDHH24MISS')
      ,l_Trama_Na.Codigo_Vendedor
      ,l_Trama_Na.Autorizacion
      ,To_Date(l_Trama_Na.Fin_Servicio
              ,'YYYYMMDDHH24MISS'));
  
    FOR l_Itm2 IN 1 .. l_Trama_Na.Subtrama_Na1.Count
    LOOP
    
      l_Dbg_Mensaje := 'Grabar detalle de Trama NA, en tabla SCFR_TURNOS_ATENCION_DET (' ||
                       Ltrim(Rtrim(l_Trama_Na.Subtrama_Na1(l_Itm2).Secuencia_Atencion)) || ')';
    
      IF p_Transaccion.Trama_Pos.Origen_Transaccion IN ('TUR') AND
         Nvl(l_Trama_Na.Subtrama_Na1(l_Itm2).Inicio_Consulta_Perfil
            ,0) > 0 THEN
        INSERT INTO Scfr_Turnos_Atencion_Det
          (Correlativo_Secuencia
          ,Inicio_Atencion
          ,Secuencia_Atencion
          ,Rut_Cliente
          ,Dv_Cliente
          ,Opcion_Atencion
          ,Id_Transaccion
          ,Fin_Atencion
          ,Inicio_Consulta_Perfil)
        VALUES
          (l_Secuencia_Turnos
          ,To_Date(l_Trama_Na.Subtrama_Na1(l_Itm2).Inicio_Atencion
                  ,'YYYYMMDDHH24MISS')
          ,l_Trama_Na.Subtrama_Na1(l_Itm2).Secuencia_Atencion
          ,l_Trama_Na.Subtrama_Na1(l_Itm2).Rut_Cliente
          ,Scfr_Trx_Gnc_Utl_Pk.Obtiene_Digito_Verificador(l_Trama_Na.Subtrama_Na1(l_Itm2).Rut_Cliente)
          ,Rtrim(Ltrim(l_Trama_Na.Subtrama_Na1(l_Itm2).Opcion_Atencion))
          ,l_Trama_Na.Subtrama_Na1(l_Itm2).Id_Transaccion
          ,To_Date(l_Trama_Na.Subtrama_Na1(l_Itm2).Fin_Atencion
                  ,'YYYYMMDDHH24MISS')
          ,To_Date(l_Trama_Na.Subtrama_Na1(l_Itm2).Inicio_Consulta_Perfil
                  ,'YYYYMMDDHH24MISS'));
      ELSE
        INSERT INTO Scfr_Turnos_Atencion_Det
          (Correlativo_Secuencia
          ,Inicio_Atencion
          ,Secuencia_Atencion
          ,Rut_Cliente
          ,Dv_Cliente
          ,Opcion_Atencion
          ,Id_Transaccion
          ,Fin_Atencion)
        VALUES
          (l_Secuencia_Turnos
          ,To_Date(l_Trama_Na.Subtrama_Na1(l_Itm2).Inicio_Atencion
                  ,'YYYYMMDDHH24MISS')
          ,l_Trama_Na.Subtrama_Na1(l_Itm2).Secuencia_Atencion
          ,l_Trama_Na.Subtrama_Na1(l_Itm2).Rut_Cliente
          ,Scfr_Trx_Gnc_Utl_Pk.Obtiene_Digito_Verificador(l_Trama_Na.Subtrama_Na1(l_Itm2).Rut_Cliente)
          ,Rtrim(Ltrim(l_Trama_Na.Subtrama_Na1(l_Itm2).Opcion_Atencion))
          ,l_Trama_Na.Subtrama_Na1(l_Itm2).Id_Transaccion
          ,To_Date(l_Trama_Na.Subtrama_Na1(l_Itm2).Fin_Atencion
                  ,'YYYYMMDDHH24MISS'));
      END IF;
    END LOOP;
  
    --END LOOP;
  
  EXCEPTION
    WHEN Dup_Val_On_Index THEN
      ROLLBACK;
      x_Cod_Error := 0;
      x_Msg_Error := '';
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;
  --//-----------------------------------------------------------------Termino--\\

  --//--------------------------------------------------------------------------\\
  --// CBR 01/10/2019 10:54  TRANSACCION GNCU12 PICKING Y PACKING ECOMMERCE     \\
  --//-----------------------------------------------------------------Inicio---\\
  /*
  PROCEDURE Trama_Sk_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Sk     Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Sk;
    l_Itm          NUMBER;
    l_Itm2         NUMBER;
    l_Existe       NUMBER;
    l_Id_Secuencia NUMBER;
    l_Codigo_Tx    NUMBER;
    l_Fecha_Vencto DATE;
    l_Dbg_Proceso  VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_Sk_resuelve';
    l_Dbg_Mensaje  VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    x_Codigo_Autorizacion VARCHAR2(30);
    x_Sec_Cod_Auto        NUMBER := 1;
    l_Canreg              NUMBER := 0;
    l_Movcja              NUMBER := 0;
    l_Movpag              NUMBER := 1;
    l_Tipmov              VARCHAR2(6);
    p_Iva                 NUMBER := 0;
  
  BEGIN
    x_Cod_Error := 0;
    l_Existe    := 0;
    -- Obtiene informacion de la trama Sk
    l_Dbg_Mensaje := 'Obtener informacion de la trama Sk (Picking y Packing)';
    l_Trama_Sk    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Sk(p_Transaccion.Cuerpo_Tx);
  
    l_Dbg_Mensaje := 'Obtener Secuencia para grabar en tabla SCFR_PICKING_PACKING';
    SELECT Scfr_Picking_Packing_s.Nextval INTO l_Id_Secuencia FROM Dual;
  
    --FOR l_Itm1 IN 1 .. l_Trama_Sk.Count
    --LOOP
  
    l_Dbg_Mensaje := 'Grabar datos de Trama Sk, en tabla SCFR_PICKING_PACKING';
    INSERT INTO Scfr_Picking_Packing
      (Id_Secuencia
      ,Emp_Empresa
      ,Cad_Cadena
      ,Loc_Local
      ,Numero_Pos
      ,Correlativo_Tx
      ,Fecha_Registro)
    VALUES
      (l_Id_Secuencia
      ,p_Transaccion.Trama_Pos.Empresa
      ,p_Transaccion.Trama_Pos.Cadena
      ,p_Transaccion.Trama_Pos.Local
      ,p_Transaccion.Trama_Pos.Numero_Pos
      ,l_Trama_Sk.Correlativo_Tx
      ,To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
              ,'yyyy/mm/dd hh24:mi:ss'));
  
    FOR l_Itm2 IN 1 .. l_Trama_Sk.Subtrama_Sk1.Count
    LOOP
      l_Dbg_Mensaje := 'Grabar detalle de Trama SK, en tabla SCFR_PICKING_PACKING_DET (' || l_Itm2 || ')';
      INSERT INTO Scfr_Picking_Packing_Det
        (Id_Secuencia
        ,Pro_Codigo_Interno
        ,Pro_Vendidos
        ,Pro_Picking
        ,Pro_Packing
        ,Rut_Vendedor
        ,Dv_Vendedor)
      VALUES
        (l_Id_Secuencia
        ,l_Trama_Sk.Subtrama_Sk1(l_Itm2).Pro_Codigo_Interno
        ,l_Trama_Sk.Subtrama_Sk1(l_Itm2).Pro_Vendidos
        ,l_Trama_Sk.Subtrama_Sk1(l_Itm2).Pro_Picking
        ,l_Trama_Sk.Subtrama_Sk1(l_Itm2).Pro_Packing
        ,l_Trama_Sk.Subtrama_Sk1(l_Itm2).Rut_Vendedor
        ,Scfr_Trx_Gnc_Utl_Pk.Obtiene_Digito_Verificador(l_Trama_Sk.Subtrama_Sk1(l_Itm2).Rut_Vendedor));
    END LOOP;
  
    --END LOOP;
  
  EXCEPTION
    WHEN Dup_Val_On_Index THEN
      ROLLBACK;
      x_Cod_Error := 0;
      x_Msg_Error := '';
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;
  */
  --//-----------------------------------------------------------------Termino--\\

  FUNCTION Trama_Fp_Prepara(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Fp IS
    CURSOR c_Forma_Pago(p_Codigo_Tx IN NUMBER) IS
      SELECT DISTINCT Mpa.Per_Codigo_Personal
                     ,Mpa.Per_Rut_Cajero
                     ,Mpa.Per_Dv_Cajero
                     ,Mpa.Maq_Maquina
                     ,Mdp.Rut_Titular
                     ,Mdp.Dv_Titular
                     ,Mpa.Tfp_Forma_Pago
                     ,Mpa.Medio_Pago
                     ,Mdp.Codigo_Autorizacion
                     ,Mdp.Numero_Cheque
                     ,Mdp.Numero_Cuenta_Tarjeta
                     ,Mdp.Bnc_Banco
                     ,Mdp.Fecha_Vencimiento Fecha_Vencimiento
                     ,Mpa.Monto
                     ,Mdp.Monto_Aplicado
                     ,Mdp.Movimiento_e_s
                     ,Mdp.Tipo_Autorizacion
                     ,Mdp.Estx_Srv_Codigo Codigo_Servicio
                     ,Mtx.Estx_Numero_Local Numero_Local
                     ,Mdp.Estx_Numero_Pos Numero_Pos
                     ,Mtx.Estx_Destino Destino
                     ,Mtx.Estx_Sistema Sistema
                     ,Mdp.Estx_Funcion Funcion
                     ,Mtx.Estx_Secuencia Secuencia
                     ,Mdp.Estx_Fecha Fecha_Transaccion
                     ,Mtx.Estx_Correlativo Correlativo
                     ,Mtx.Estx_Numero_Trama Numero_Trama
                     ,Mdp.Estx_Codigo_Tx Codigo_Transaccion
                     ,Mdp.Numero_Cuotas
                     ,Mdp.Interes
                     ,Utl_Raw.Cast_To_Varchar2(Mdp.Banda_Magnetica) Banda_Magnetica
                     ,Mdp.Secuencia_Pago
                     ,Mdp.Meses_Diferido
                     ,Mdp.Tipo_Cuotas
                     ,Mdp.Numero_Tx_Comercio
                     ,Mdp.Id_Transaccion
                     ,Mdp.Valor_Cuota
                     ,Mdp.Modo_Ingreso_Tarjeta
                     ,Mpa.Flujo_Caja
        FROM Scfr_Mov_Transacciones_Pago Mtp
            ,Scfr_Mov_Pagos              Mpa
            ,Scfr_Mov_Detalle_Pagos      Mdp
            ,Scfr_Mov_Transacciones      Mtx
       WHERE Mtp.Txo_Codigo_Tx = p_Codigo_Tx
         AND Mtp.Txo_Codigo_Tx = Mtx.Codigo_Tx
         AND Mtp.Mpa_Mov_Pagos = Mpa.Mov_Pagos
         AND Mtp.Tfp_Forma_Pago = Mpa.Tfp_Forma_Pago
         AND Mtp.Codigo_Autorizacion = Mpa.Codigo_Autorizacion
         AND Mpa.Mov_Pagos = Mdp.Mpa_Mov_Pagos(+)
         AND Mpa.Tfp_Forma_Pago = Mdp.Tfp_Forma_Pago(+)
         AND Mpa.Codigo_Autorizacion = Mdp.Codigo_Autorizacion(+);
    Fecha_Venc         NUMBER;
    l_Trama_Fp         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Fp;
    l_Itm              NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_fp_prepara';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    -- obtiene datos del beneficiario desde la transaccion original
    l_Dbg_Mensaje := 'Obtener datos del convenio desde la tabla SCFR_MOV_TRANSACCIONES' || p_Transaccion.Codigo_Tx;
    l_Itm         := 1;
    FOR r_Forma_Pago IN c_Forma_Pago(p_Transaccion.Codigo_Tx)
    LOOP
      BEGIN
        SELECT To_Number(To_Char(r_Forma_Pago.Fecha_Vencimiento
                                ,'yyyymmdd'))
          INTO Fecha_Venc
          FROM Dual;
      EXCEPTION
        WHEN OTHERS THEN
          Fecha_Venc := 0;
      END;
      Dbms_Output.Put_Line(' FECHA VENC 1' || r_Forma_Pago.Fecha_Vencimiento);
      l_Trama_Fp(l_Itm).Codigo_Personal := r_Forma_Pago.Per_Codigo_Personal;
      l_Trama_Fp(l_Itm).Rut := r_Forma_Pago.Per_Rut_Cajero;
      l_Trama_Fp(l_Itm).Dv := r_Forma_Pago.Per_Dv_Cajero;
      l_Trama_Fp(l_Itm).Id_Maquina := r_Forma_Pago.Maq_Maquina;
      l_Trama_Fp(l_Itm).Rut_Titular := r_Forma_Pago.Rut_Titular;
      l_Trama_Fp(l_Itm).Dv_Titular := r_Forma_Pago.Dv_Titular;
      l_Trama_Fp(l_Itm).Forma_Pago := r_Forma_Pago.Tfp_Forma_Pago;
      l_Trama_Fp(l_Itm).Medio_Pago := r_Forma_Pago.Medio_Pago;
      l_Trama_Fp(l_Itm).Codigo_Autorizacion := r_Forma_Pago.Codigo_Autorizacion;
      l_Trama_Fp(l_Itm).Numero_Documento := r_Forma_Pago.Numero_Cheque;
      l_Trama_Fp(l_Itm).Numero_Cuenta := r_Forma_Pago.Numero_Cuenta_Tarjeta;
      l_Trama_Fp(l_Itm).Banco := r_Forma_Pago.Bnc_Banco;
      l_Trama_Fp(l_Itm).Fecha_Vencimiento := Fecha_Venc; --r_forma_pago.fecha_vencimiento;
      l_Trama_Fp(l_Itm).Monto_Documento := r_Forma_Pago.Monto_Aplicado;
      l_Trama_Fp(l_Itm).Monto_Forma_Pago := r_Forma_Pago.Monto;
      l_Trama_Fp(l_Itm).Movimiento_Caja := r_Forma_Pago.Movimiento_e_s;
      l_Trama_Fp(l_Itm).Tipo_Autorizacion := r_Forma_Pago.Tipo_Autorizacion;
      l_Trama_Fp(l_Itm).Cantidad_Cuotas := r_Forma_Pago.Numero_Cuotas;
      l_Trama_Fp(l_Itm).Interes := r_Forma_Pago.Interes * 100;
      l_Trama_Fp(l_Itm).Banda_Magnetica := Utl_Raw.Cast_To_Raw(r_Forma_Pago.Banda_Magnetica);
      l_Trama_Fp(l_Itm).Codigo_Servicio := r_Forma_Pago.Codigo_Servicio;
      l_Trama_Fp(l_Itm).Local := r_Forma_Pago.Numero_Local;
      l_Trama_Fp(l_Itm).Numero_Pos := r_Forma_Pago.Numero_Pos;
      l_Trama_Fp(l_Itm).Destino := r_Forma_Pago.Destino;
      l_Trama_Fp(l_Itm).Sistema := r_Forma_Pago.Sistema;
      l_Trama_Fp(l_Itm).Funcion := r_Forma_Pago.Funcion;
      l_Trama_Fp(l_Itm).Secuencia_c := r_Forma_Pago.Secuencia;
      l_Trama_Fp(l_Itm).Fecha_Transaccion := To_Number(To_Char(r_Forma_Pago.Fecha_Transaccion
                                                              ,'yyyymmddhh24miss'));
      l_Trama_Fp(l_Itm).Correlativo := r_Forma_Pago.Correlativo;
      l_Trama_Fp(l_Itm).Numero_Trama := r_Forma_Pago.Numero_Trama;
      l_Trama_Fp(l_Itm).Codigo_Transaccion := r_Forma_Pago.Codigo_Transaccion;
      l_Trama_Fp(l_Itm).Secuencia_Pago := r_Forma_Pago.Secuencia_Pago;
      l_Trama_Fp(l_Itm).Meses_Diferido := r_Forma_Pago.Meses_Diferido;
      l_Trama_Fp(l_Itm).Tipo_Cuotas := r_Forma_Pago.Tipo_Cuotas;
      l_Trama_Fp(l_Itm).Numero_Tx_Comercio := r_Forma_Pago.Numero_Tx_Comercio;
      --//--------------------------------------------------------------------------\\
      --// CBR 18/02/2011 15:30 REP. Problemas en Piloto 57 con anulacion TBK       \\
      --//-----------------------------------------------------------------Inicio---\\
      -- IF p_Transaccion.Trama_Pos.Origen_Transaccion IN ('TBK', 'DEV') THEN
      l_Trama_Fp(l_Itm).Id_Transaccion := r_Forma_Pago.Id_Transaccion;
      l_Trama_Fp(l_Itm).Valor_Cuota := r_Forma_Pago.Valor_Cuota;
      -- END IF;
      --//-----------------------------------------------------------------Termino--\\
      IF p_Transaccion.Trama_Pos.Origen_Transaccion IN ('MAG') THEN
        l_Trama_Fp(l_Itm).Modo_Ingreso_Tarjeta := r_Forma_Pago.Modo_Ingreso_Tarjeta;
        l_Trama_Fp(l_Itm).Flujo_Caja := r_Forma_Pago.Flujo_Caja;
      END IF;
      IF p_Transaccion.Trama_Pos.Origen_Transaccion IN ('FJC'
                                                       ,'PRE') THEN
        l_Trama_Fp(l_Itm).Flujo_Caja := r_Forma_Pago.Flujo_Caja;
      END IF;
      l_Trama_Fp(l_Itm).Documentos_a_Cancelar := 0;
      Dbms_Output.Put_Line(' FECHA VENC 2' || l_Trama_Fp(l_Itm).Fecha_Vencimiento);
      l_Itm := l_Itm + 1;
    END LOOP;
    RETURN(l_Trama_Fp);
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Trama_Cv_Reversa(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                            ,p_Trama_Dv    IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                            ,x_Cod_Error   OUT NUMBER
                            ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Cv Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv;
    l_Data_Com Scfr_Trx_Dyn_Types_Pk.Rec_Data_Com;
    --l_trama_dv             scfr_trx_dyn_types_pk.rec_trama_dv;
    l_Dv_Cod_Autoriza      VARCHAR2(1);
    l_Folio                NUMBER;
    l_Cod_Autorizacion     NUMBER;
    l_Cod_Autorizacion_Cnv NUMBER;
    l_Cod_Autoriza_Cnv1    VARCHAR2(50);
    l_Cod_Autoriza_Rev     NUMBER;
    l_Itm                  NUMBER;
    l_Cod_Autoriza_Rev_Pos VARCHAR2(20);
    l_Cod_Autoriza_Ext     VARCHAR2(10);
    l_Cod_Error            VARCHAR2(100);
    l_Reversa_Autorizada   VARCHAR2(100);
    l_Dbg_Proceso          VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_cv_reversa';
    l_Dbg_Mensaje          VARCHAR2(250) := 'Error General';
    l_Flag_Ban             VARCHAR2(3);
    l_Monto_Copago_Ges     NUMBER;
    l_Error_Controlado     EXCEPTION;
    l_Convenio             NUMBER;
    l_Es_Exc_Mdp           VARCHAR2(3);
  BEGIN
    l_Dbg_Mensaje := 'Obtener informacion del Header';
    l_Data_Com    := Scfr_Trx_Dyn_Utl_Pk.Carga_Datos_Com(p_Transaccion);
    l_Dbg_Mensaje := 'Obtener informacion de la trama CV';
    l_Trama_Cv    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Cv(p_Transaccion.Cuerpo_Tx);
    IF l_Trama_Cv.Count = 0 THEN
      RAISE l_Error_Controlado;
    END IF;
    --l_DBG_MENSAJE := 'Obtener informacion de la trama DV';
    --l_trama_dv    := scfr_trx_dyn_utl_pk.carga_trama_dv(p_Transaccion.Trama_Pos,p_transaccion.cuerpo_tx );
    -- Determinar modalidad BAN-FCV
    -- Modificado por ESILVA
    /*IF p_transaccion.trama_pos.origen_transaccion = 'BNM' THEN
       l_flag_ban := 'NEW';
    ELSE
       l_flag_ban := 'OLD';
    END IF;*/
    -- Modificado por ESILVA
    l_Dbg_Mensaje := 'Determinar si codigo de autorizacion fue dado en Linea';
    BEGIN
      l_Cod_Autoriza_Rev     := To_Number(l_Trama_Cv(1).Codigo_Autorizacion);
      l_Cod_Autoriza_Rev_Pos := NULL;
    EXCEPTION
      WHEN OTHERS THEN
        l_Cod_Autoriza_Rev     := NULL;
        l_Cod_Autoriza_Rev_Pos := l_Trama_Cv(1).Codigo_Autorizacion;
    END;
    IF p_Trama_Dv.Subtrama_Dv1.Count > 0 THEN
      FOR l_Itm IN 1 .. p_Trama_Dv.Subtrama_Dv1.Count
      LOOP
        IF p_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Movimiento_Hijo != 'ANUDIC' THEN
          l_Folio := p_Trama_Dv.Subtrama_Dv1(l_Itm).Folio;
          EXIT;
        END IF;
      END LOOP;
    ELSE
      l_Folio := NULL;
    END IF;
    BEGIN
      -- obtiene codigo de autorizacion convenio sobre la venta original
      SELECT Autorizacion_Cnv_Tx
            ,Con_Numero_Convenio
        INTO l_Cod_Autorizacion_Cnv
            ,l_Convenio
        FROM Scfr_Mov_Transacciones
       WHERE Correlativo_Tx = p_Trama_Dv.Correlativo_Tx_Asociado
         AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
         AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
         AND Loc_Local = p_Trama_Dv.Local
         AND Tmo_Movimiento_Padre = p_Trama_Dv.Tipo_Movimiento_Padre;
    EXCEPTION
      WHEN No_Data_Found THEN
        BEGIN
          -- obtiene codigo de autorizacion convenio sobre la venta original
          SELECT Autorizacion_Cnv_Tx
                ,Con_Numero_Convenio
            INTO l_Cod_Autorizacion_Cnv
                ,l_Convenio
            FROM Batc_Mov_Transacciones
           WHERE Correlativo_Tx = p_Trama_Dv.Correlativo_Tx_Asociado
             AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
             AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
             AND Loc_Local = p_Trama_Dv.Local
             AND Tmo_Movimiento_Padre = p_Trama_Dv.Tipo_Movimiento_Padre;
        EXCEPTION
          WHEN OTHERS THEN
            l_Cod_Autorizacion_Cnv := NULL;
        END;
      WHEN OTHERS THEN
        l_Cod_Autorizacion_Cnv := NULL;
    END;
    BEGIN
      SELECT 'SI'
        INTO l_Es_Exc_Mdp
        FROM Scfr_Convenios a
       WHERE a.Emp_Codigo = 1
         AND a.Numero_Convenio = l_Convenio
         AND a.Exc_Medio_Pago = 'MDP';
    EXCEPTION
      WHEN OTHERS THEN
        l_Es_Exc_Mdp := 'NO';
    END;
    IF l_Es_Exc_Mdp = 'SI' THEN
      x_Cod_Error := '0';
      RETURN;
    END IF;
    IF l_Cod_Autoriza_Rev IS NOT NULL THEN
      -- valida si el codigo efectivamente corresponde a una reversa o si es de una directa
      -- esto solo en caso de reversas hechas antes de 02/07/2007 (aprox)
      IF l_Cod_Autoriza_Rev = l_Cod_Autorizacion_Cnv THEN
        -- en este caso, debemos pedir autorizacion para esta reversa utilizando la directa
        l_Cod_Autoriza_Rev := 0;
      END IF;
    END IF;
    IF l_Cod_Autoriza_Rev IS NULL THEN
      -- LLama a convenios SOLO SI la transaccion original (VENTA/RECAUDACION) es encontrada
      -- de lo contrario, REGISTRA el error (como log) y continua con la reversa
      IF l_Cod_Autorizacion_Cnv IS NOT NULL THEN
        -- Modificado por ESILVA
        BEGIN
          /*          SELECT DECODE(b.agrupacion_perfil, 'BAN', 'NEW', 'VDT', 'NEW', 'OLD')
                    INTO l_flag_ban
                    FROM scfr_convenios b,
                         scfr_detalle_consumos a
                    WHERE a.codigo_autorizacion = l_cod_autorizacion_cnv
                      AND a.numero_linea = 0
                      AND b.emp_codigo = a.emp_codigo
                      AND b.numero_convenio = a.con_numero_convenio;
          */
          SELECT Decode(b.Agrupacion_Perfil
                       ,'BAN'
                       ,'NEW'
                       ,'VDT'
                       ,'NEW'
                       ,'OLD')
            INTO l_Flag_Ban
            FROM Scfr_Convenios b
           WHERE b.Emp_Codigo = 1
             AND b.Numero_Convenio = l_Trama_Cv(1).Convenio;
        EXCEPTION
          WHEN OTHERS THEN
            l_Flag_Ban := 'OLD';
        END;
        -- Modificado por ESILVA
        Scfr_Conv_Pk.Autorizacion_Reversa_Trx(p_Cod_Autorizacion_Cnv     => l_Cod_Autorizacion_Cnv
                                             ,p_Folio                    => l_Folio
                                             ,p_Cod_Autorizacion_Pos     => NULL
                                             ,p_Local                    => p_Trama_Dv.Local
                                             , --p_transaccion.trama_pos.LOCAL
                                              p_Reversa_Online           => 'NO'
                                             ,p_Cod_Autorizacion_Rev_Pos => l_Cod_Autoriza_Rev_Pos
                                             ,p_Fecha_Reversa            => To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                                                                   ,'yyyy/mm/dd hh24:mi:ss')
                                             ,p_Flag_Ban                 => l_Flag_Ban
                                             ,p_Param_Ws                 => l_Data_Com
                                             ,x_Reversa_Autorizada       => l_Reversa_Autorizada
                                             ,x_Codigo_Autorizacion_Rev  => l_Cod_Autoriza_Rev
                                             ,x_Codigo_Autorizacion_Ext  => l_Cod_Autoriza_Ext
                                             ,x_Monto_Copago_Ges         => l_Monto_Copago_Ges
                                             ,x_Error                    => l_Cod_Error
                                             ,x_Msg_Error                => x_Msg_Error);
        BEGIN
          x_Cod_Error := To_Number(l_Cod_Error);
        EXCEPTION
          WHEN OTHERS THEN
            x_Cod_Error := -1;
        END;
        IF x_Cod_Error = Scfr_Conv_Pk.Err_Transaccion_No_Existe THEN
          -- registra el problema (cod.autorizacion de la venta no esta en convenios)
          Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                    ,p_Msg     => 'Codigo de autorizacion Venta ' || l_Cod_Autorizacion_Cnv || ' no fue encontrado en convenios');
        END IF;
        IF Nvl(x_Cod_Error
              ,0) != 0 THEN
          Raise_Application_Error(-20000
                                 ,l_Cod_Error || '-' || x_Msg_Error);
        END IF;
      ELSE
        -- registra el error. transaccion original (VENTA/RECAUDACION) es encontrada
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => 'Transaccion origen (Venta/Recaudacion) correlativo_tx = ' || p_Trama_Dv.Correlativo_Tx_Asociado ||
                                                ' no fue encontrado en modelo online');
      END IF;
    END IF;
    IF l_Cod_Autoriza_Rev IS NOT NULL THEN
      -- Modificado por ESILVA
      BEGIN
        /*      SELECT DECODE(b.agrupacion_perfil, 'BAN', 'NEW', 'VDT', 'NEW', 'OLD')
        INTO l_flag_ban
        FROM scfr_convenios b,
             scfr_detalle_consumos a
        WHERE a.codigo_autorizacion = l_cod_autoriza_rev
          AND a.numero_linea = 0
          AND b.emp_codigo = a.emp_codigo
          AND b.numero_convenio = a.con_numero_convenio;*/
        SELECT Decode(b.Agrupacion_Perfil
                     ,'BAN'
                     ,'NEW'
                     ,'VDT'
                     ,'NEW'
                     ,'OLD')
          INTO l_Flag_Ban
          FROM Scfr_Convenios b
         WHERE b.Emp_Codigo = 1
           AND b.Numero_Convenio = l_Trama_Cv(1).Convenio;
      EXCEPTION
        WHEN OTHERS THEN
          l_Flag_Ban := 'OLD';
      END;
      -- Modificado por ESILVA
      Scfr_Conv_Pk.Reversa_Trx(p_Codigo_Autorizacion => l_Cod_Autoriza_Rev
                              ,p_Folio               => l_Folio
                              , --p_transaccion.codigo_tx_origen -- codigo tx de la venta
                               p_Local               => p_Trama_Dv.Local
                              , -- p_transaccion.trama_pos.LOCAL
                               p_Flag_Ban            => l_Flag_Ban
                              ,p_Param_Ws            => l_Data_Com
                              ,x_Codigo_Autorizacion => l_Cod_Autorizacion
                              ,x_Error               => l_Cod_Error
                              ,x_Msg_Error           => x_Msg_Error);
    END IF;
    BEGIN
      x_Cod_Error := To_Number(l_Cod_Error);
    EXCEPTION
      WHEN OTHERS THEN
        x_Cod_Error := -1;
    END;
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      Raise_Application_Error(-20000
                             ,l_Cod_Error || '-' || x_Msg_Error);
    END IF;
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  FUNCTION Trama_Cv_Prepara(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,l_Trama_Vt    IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vt
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv IS
    CURSOR c_Convenios IS
      SELECT c.Con_Numero_Convenio
            ,c.Pla_Codigo          Pla_Numero_Plan
            ,c.Codigo_Autorizacion Autorizacion_Cnv_Tx
            ,t.Rut_Titular
            ,t.Dv_Titular
            ,t.Pt_Party_Id_Titular
        FROM Scfr_Mov_Transacciones t
            ,Scfr_Detalle_Consumos  c
       WHERE t.Codigo_Tx = p_Transaccion.Codigo_Tx
         AND Txo_Codigo_Tx = t.Codigo_Tx
         AND Numero_Linea = 0;
    l_Itm              NUMBER;
    l_Trama_Cv         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_cv_prepara';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    -- obtiene datos del beneficiario desde la transaccion original
    l_Dbg_Mensaje := 'Obtener datos del convenio desde la tabla SCFR_MOV_TRANSACCIONES';
    BEGIN
      l_Itm := 1;
      FOR r_Convenios IN c_Convenios
      LOOP
        l_Trama_Cv(l_Itm).Convenio := r_Convenios.Con_Numero_Convenio;
        l_Trama_Cv(l_Itm).Plan := r_Convenios.Pla_Numero_Plan;
        l_Trama_Cv(l_Itm).Codigo_Autorizacion := r_Convenios.Autorizacion_Cnv_Tx;
        l_Trama_Cv(l_Itm).Rut_Titular := r_Convenios.Rut_Titular;
        l_Trama_Cv(l_Itm).Dv_Titular := r_Convenios.Dv_Titular;
        l_Trama_Cv(l_Itm).Party_Id := r_Convenios.Pt_Party_Id_Titular;
        l_Itm := l_Itm + 1;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
    END;
    RETURN l_Trama_Cv;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Trama_Dr_Resuelve_Anu(p_Transaccion  IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                 ,x_Doc_Emitidos OUT Scfr_Trx_Gnc_Pk.Tab_Doc_Emitidos
                                 ,x_Cod_Error    OUT NUMBER
                                 ,x_Msg_Error    OUT VARCHAR2) IS
    l_Trama_Dr                  Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dr;
    l_Resultado                 NUMBER;
    l_Fecha_Tx                  DATE;
    l_Fecha_Tx_Origen           DATE; --incidencia 3241
    l_Diferencia                NUMBER;
    l_Codigo_Tx                 NUMBER;
    l_Codigo_Tx_Rela            NUMBER;
    l_Diferencia                NUMBER;
    l_Mov_Documentos            NUMBER;
    l_Dbg_Proceso               VARCHAR2(100) := 'SCFR_TRX_GNC_PK.GNCU06.trama_dr_resuelve_anu';
    l_Dbg_Mensaje               VARCHAR2(250) := 'Error General';
    l_Error_Controlado          EXCEPTION;
    l_Txo_Codigo_Tx_Relacionado NUMBER;
    l_Recaudacion               NUMBER;
    l_Recaudacion_Hcr           NUMBER;
    l_Corr_Rel                  NUMBER;
    l_Tipo_Mov                  VARCHAR(10);
    l_Origen_Anulacion          VARCHAR2(3);
    Mes_Venta                   NUMBER;
    Mes_Anulacion               NUMBER;
    Dia_Venta                   NUMBER;
    Dia_Anulacion               NUMBER;
  BEGIN
    l_Dbg_Mensaje := 'Obteniendo solictud de anulacion generica de recaudacion';
    l_Trama_Dr    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Dr(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje := 'Obteniendo Fecha y hora de la anulacion';
    SELECT To_Date((To_Char(l_Trama_Dr.Fecha) || To_Char(Lpad(l_Trama_Dr.Hora_Recaudacion
                                                             ,6
                                                             ,0)))
                  ,'yyyymmddhh24:mi:ss')
      INTO l_Fecha_Tx
      FROM Dual;
    l_Dbg_Mensaje := ' Recorre detalle de documentos emitidos.';
    FOR l_Itm IN 1 .. l_Trama_Dr.Documentos_Emitidos
    LOOP
      l_Dbg_Mensaje := 'Valida completitud de datos obligatorios.' || l_Itm;
      IF l_Trama_Dr.Subtrama_Dr1(l_Itm).Secuencia_b IS NULL OR
         l_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Movimiento_Hijo IS NULL OR
         l_Trama_Dr.Subtrama_Dr1(l_Itm).Anulado IS NULL OR
         l_Trama_Dr.Subtrama_Dr1(l_Itm).Total_Iva_Incluido IS NULL THEN
        x_Cod_Error := -2000;
        x_Msg_Error := l_Dbg_Mensaje;
        RAISE l_Error_Controlado;
      END IF;
    END LOOP;
    -- Si viene el campo venta_relacionada ==> es anulacion de recaudacion con donacion hogar de cristo
    IF Nvl(l_Trama_Dr.Venta_Relacionada
          ,0) <> 0 THEN
      l_Dbg_Mensaje := ' Obtiene txo_codigo_tx_relacionado';
      --  si viene el campo secuencia_b ==> es la recaudaci? principal (no la rechcr)
      --Incidencia 3241, se agrega fecha_tx
      IF Nvl(l_Trama_Dr.Secuencia_b
            ,0) <> 0 THEN
        --
        BEGIN
          SELECT Txo_Correlativo_Tx_Relacionado
                ,Fecha_Tx
            INTO l_Recaudacion
                ,l_Fecha_Tx_Origen
            FROM Scfr_Mov_Transacciones
           WHERE Correlativo_Tx = l_Trama_Dr.Secuencia_b
             AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
             AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
             AND Loc_Local = l_Trama_Dr.Local_Relacionado
             AND Fecha_Tx >= To_Date(l_Trama_Dr.Fecha
                                    ,'yyyymmdd') - 90;
          BEGIN
            SELECT Mt.Codigo_Tx
              INTO l_Txo_Codigo_Tx_Relacionado
              FROM Scfr_Mov_Transacciones Mt
             WHERE Mt.Loc_Local = p_Transaccion.Trama_Pos.Local
               AND Mt.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
               AND Mt.Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
               AND Mt.Correlativo_Tx = l_Recaudacion --l_trama_dr.secuencia_b
               AND Mt.Fecha_Tx >= To_Date(l_Trama_Dr.Fecha
                                         ,'yyyymmdd') - 90;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
        EXCEPTION
          WHEN No_Data_Found THEN
            -- asume que la transaccion es de hace varios dias. se busca en modelo batc
            -- Incidencia 3241, se agrega fecha_tx
            BEGIN
              SELECT Txo_Correlativo_Tx_Relacionado
                    ,Fecha_Tx
                INTO l_Recaudacion
                    ,l_Fecha_Tx_Origen
                FROM Batc_Mov_Transacciones
               WHERE Correlativo_Tx = l_Trama_Dr.Secuencia_b
                 AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
                 AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
                 AND Loc_Local = l_Trama_Dr.Local_Relacionado
                 AND Fecha_Tx >= To_Date(l_Trama_Dr.Fecha
                                        ,'yyyymmdd') - 90;
              BEGIN
                SELECT Mt.Codigo_Tx
                  INTO l_Txo_Codigo_Tx_Relacionado
                  FROM Batc_Mov_Transacciones Mt
                 WHERE Mt.Loc_Local = p_Transaccion.Trama_Pos.Local
                   AND Mt.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
                   AND Mt.Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
                   AND Mt.Correlativo_Tx = l_Recaudacion --l_trama_dr.secuencia_b
                   AND Mt.Fecha_Tx >= To_Date(l_Trama_Dr.Fecha
                                             ,'yyyymmdd') - 90;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END;
          WHEN OTHERS THEN
            NULL;
        END;
      ELSE
        l_Recaudacion := l_Trama_Dr.Venta_Relacionada;
        l_Dbg_Mensaje := ' Obtiene codigo TX de la venta relacionada';
        BEGIN
          SELECT Mt.Codigo_Tx
                ,Mt.Fecha_Tx
            INTO l_Txo_Codigo_Tx_Relacionado
                ,l_Fecha_Tx_Origen
            FROM Scfr_Mov_Transacciones Mt
           WHERE Mt.Correlativo_Tx = l_Recaudacion
             AND Mt.Loc_Local = l_Trama_Dr.Local_Relacionado
             AND Mt.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
             AND Mt.Tmo_Movimiento_Padre = 'VENTAS';
        EXCEPTION
          WHEN OTHERS THEN
            l_Fecha_Tx_Origen           := Scfr_Trx_Util_Pk.Get_Sysdate();
            l_Txo_Codigo_Tx_Relacionado := NULL;
        END;
      END IF;
    ELSE
      l_Recaudacion := l_Trama_Dr.Secuencia_b;
      BEGIN
        SELECT t.Codigo_Tx
              ,t.Fecha_Tx
          INTO l_Txo_Codigo_Tx_Relacionado
              ,l_Fecha_Tx_Origen
        --SELECT t.fecha_tx
        --INTO l_fecha_tx_origen
          FROM Scfr_Mov_Transacciones t
         WHERE t.Correlativo_Tx = l_Recaudacion
           AND t.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
           AND t.Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
           AND t.Loc_Local = l_Trama_Dr.Local_Relacionado
           AND t.Fecha_Tx >= To_Date(l_Trama_Dr.Fecha
                                    ,'yyyymmdd') - 90;
      EXCEPTION
        WHEN OTHERS THEN
          l_Fecha_Tx_Origen           := Scfr_Trx_Util_Pk.Get_Sysdate();
          l_Txo_Codigo_Tx_Relacionado := NULL;
      END;
    END IF;
    l_Dbg_Mensaje := 'Actualiza scfr_mov_documentos_txs.' || l_Trama_Dr.Secuencia_b || ' ' || p_Transaccion.Trama_Pos.Empresa || ' ' ||
                     p_Transaccion.Trama_Pos.Cadena || ' ' || l_Trama_Dr.Local_Relacionado;
    Mes_Venta     := Extract(MONTH FROM To_Date(l_Fecha_Tx_Origen
                                    ,'dd/mm/yyyy hh24:mi:ss'));
    Mes_Anulacion := Extract(MONTH FROM To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                    ,'yyyymmddhh24miss'));
    Dia_Venta     := Extract(DAY FROM To_Date(l_Fecha_Tx_Origen
                                    ,'dd/mm/yyyy hh24:mi:ss'));
    Dia_Anulacion := Extract(DAY FROM To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                    ,'yyyymmddhh24miss'));
    IF (Mes_Venta = Mes_Anulacion) THEN
      IF (Dia_Venta = Dia_Anulacion) THEN
        l_Origen_Anulacion := 'DIA';
      ELSE
        l_Origen_Anulacion := 'ANT';
      END IF;
    ELSE
      l_Origen_Anulacion := 'MAN';
    END IF;
    UPDATE Scfr_Mov_Documentos_Txs
       SET Anulado          = 'S'
          ,Origen_Anulacion = l_Origen_Anulacion
          ,Procesado        = Nvl2(Procesado
                                  ,2
                                  ,Procesado)
     WHERE Txo_Correlativo_Tx = l_Recaudacion --l_trama_dr.secuencia_b
       AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
       AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
       AND Loc_Local = l_Trama_Dr.Local_Relacionado;
    IF SQL%ROWCOUNT = 0 THEN
      --  se asume que la transacciones es de hace varios dias, se actualiza modelo batc
      UPDATE Batc_Mov_Documentos_Txs
         SET Anulado = 'S'
       WHERE Txo_Correlativo_Tx = l_Recaudacion --l_trama_dr.secuencia_b
         AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
         AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
         AND Loc_Local = l_Trama_Dr.Local_Relacionado;
    END IF;
    l_Dbg_Mensaje := ' Obtiene folio para codigo TX.';
    --select scfr_mov_transacciones_s.nextval
    --  into l_codigo_tx
    --  from dual;
    l_Dbg_Mensaje := 'Obtener folio desde scfr_mov_transacciones_s';
    SELECT Scfr_Mov_Transacciones_s.Nextval INTO p_Transaccion.Codigo_Tx FROM Dual;
    p_Transaccion.Fecha_Tx       := To_Date(Ltrim(Rtrim(l_Trama_Dr.Fecha)) || Ltrim(Rtrim(To_Char(l_Trama_Dr.Hora_Recaudacion
                                                                                                 ,'000009')))
                                           ,'yyyymmddhh24miss');
    p_Transaccion.Correlativo_Tx := l_Trama_Dr.Correlativo_Tx;
    l_Dbg_Mensaje                := 'Inserta  scfr_mov_transacciones.';
    INSERT INTO Scfr_Mov_Transacciones
      (Codigo_Tx
      ,Correlativo_Tx
      ,Tmo_Movimiento_Padre
      ,Fecha_Tx
      ,Emp_Empresa
      ,Cad_Cadena
      ,Loc_Local
      ,Estado_Registro
      ,Numero_Maquina
      ,Proceso_Dwh
      ,Numero_Cuenta_Tarjeta
      ,Codigo_Autorizacion_Tx
      ,Estx_Srv_Codigo
      ,Estx_Numero_Pos
      ,Estx_Fecha
      ,Estx_Codigo_Tx
      ,Sec_Recaudacion
      ,Txo_Correlativo_Tx_Relacionado
      ,Estx_Destino
      ,Estx_Sistema
      ,Estx_Funcion
      ,Estx_Secuencia
      ,Estx_Numero_Trama
      ,Txo_Codigo_Tx_Relacionado
      ,Cuadrar_Transacciones
      ,Docs_Emitir_Liq_Pag
      ,Docs_Emitir_Liq_Emp
      ,Autorizacion_Cnv_Ext
      ,Transaccion_Manual
      ,Numero_Tav
      ,Fecha_Inicio_Tx
      ,Fecha_Cierre_Tx
      ,Fecha_Generacion_Registro
      ,Numero_Tx_Comercio
      ,Loc_Local_Relacionado)
    VALUES
      (p_Transaccion.Codigo_Tx
      ,l_Trama_Dr.Correlativo_Tx
      ,l_Trama_Dr.Tipo_Movimiento_Padre
      ,l_Fecha_Tx
      ,p_Transaccion.Trama_Pos.Empresa
      ,p_Transaccion.Trama_Pos.Cadena
      ,l_Trama_Dr.Local
      ,'VIG'
      ,p_Transaccion.Trama_Pos.Numero_Pos
      ,0
      ,TRIM(l_Trama_Dr.Numero_Cuenta)
      ,TRIM(l_Trama_Dr.Codigo_Autorizacion)
      ,l_Trama_Dr.Codigo_Servicio
      ,l_Trama_Dr.Numero_Pos
      ,To_Date(l_Trama_Dr.Fecha_Transaccion
              ,'yyyymmddhh24miss')
      ,TRIM(l_Trama_Dr.Codigo_Transaccion)
      ,l_Recaudacion
      ,Decode(l_Trama_Dr.Venta_Relacionada
             ,0
             ,Decode(l_Trama_Dr.Secuencia_b
                    ,0
                    ,NULL
                    ,l_Trama_Dr.Secuencia_b)
             ,l_Trama_Dr.Venta_Relacionada)
      ,l_Trama_Dr.Destino
      ,l_Trama_Dr.Sistema
      ,l_Trama_Dr.Funcion
      ,l_Trama_Dr.Secuencia_c
      ,l_Trama_Dr.Numero_Trama
      ,l_Txo_Codigo_Tx_Relacionado
      ,l_Trama_Dr.Cuadra_Transaccion
      ,l_Trama_Dr.Documento_Liquidacion_Pago
      ,l_Trama_Dr.Documento_Liquidacion_Empresa
      ,l_Trama_Dr.Codigo_Autorizacion_Externo
      ,l_Trama_Dr.Transaccion_Manual
      ,TRIM(p_Transaccion.Trama_Pos.Id_Maquina)
      ,To_Date(Decode(l_Trama_Dr.Fecha_Inicio_Tx
                     ,0
                     ,NULL
                     ,l_Trama_Dr.Fecha_Inicio_Tx)
              ,'yyyymmddhh24miss')
      ,To_Date(Decode(l_Trama_Dr.Fecha_Cierre_Tx
                     ,0
                     ,NULL
                     ,l_Trama_Dr.Fecha_Cierre_Tx)
              ,'yyyymmddhh24miss')
      ,Trunc(To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Proceso
                    ,'yyyymmddhh24miss'))
      ,l_Trama_Dr.Numero_Tx_Comercio
      ,l_Trama_Dr.Local_Relacionado);
    Dbms_Output.Put_Line('Insertando transacciones ');
    FOR l_Itm IN 1 .. l_Trama_Dr.Subtrama_Dr1.Count
    LOOP
      l_Dbg_Mensaje := 'obtiene folio para documentos TXS.';
      SELECT Scfr_Mov_Documentos_Txs_s.Nextval INTO l_Mov_Documentos FROM Dual;
      x_Doc_Emitidos(l_Itm) := l_Mov_Documentos;
      l_Dbg_Mensaje := 'inserta documentos de transaccion.  DR1';
      --//--------------------------------------------------------------------------\\
      --// CBR 30/08/2017 14:48                                                     \\
      --//-----------------------------------------------------------------Inicio---\\
      IF p_Transaccion.Trama_Pos.Origen_Transaccion IN ('AUC'
                                                       ,'BOX'
                                                       ,'GLO'
                                                       ,'FEL'
                                                       ,'FAT'
                                                       ,'CIA'
                                                       ,'EMP'
                                                       ,'DEC') AND
         l_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Movimiento_Hijo IN ('ANUAJU'
                                                                ,'RECAJU') THEN
        IF l_Trama_Dr.Subtrama_Dr1(l_Itm).Signo = 'N' THEN
          l_Trama_Dr.Subtrama_Dr1(l_Itm).Total_Iva_Incluido := l_Trama_Dr.Subtrama_Dr1(l_Itm).Total_Iva_Incluido * -1;
          l_Trama_Dr.Subtrama_Dr1(l_Itm).Iva := l_Trama_Dr.Subtrama_Dr1(l_Itm).Iva * -1;
        END IF;
      
        IF l_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Movimiento_Hijo = 'ANUAJU' THEN
          l_Trama_Dr.Subtrama_Dr1(l_Itm).Total_Iva_Incluido := l_Trama_Dr.Subtrama_Dr1(l_Itm).Total_Iva_Incluido * -1;
          l_Trama_Dr.Subtrama_Dr1(l_Itm).Iva := l_Trama_Dr.Subtrama_Dr1(l_Itm).Iva * -1;
        END IF;
      
      ELSE
        l_Trama_Dr.Subtrama_Dr1(l_Itm).Total_Iva_Incluido := l_Trama_Dr.Subtrama_Dr1(l_Itm).Total_Iva_Incluido * -1;
        l_Trama_Dr.Subtrama_Dr1(l_Itm).Iva := l_Trama_Dr.Subtrama_Dr1(l_Itm).Iva * -1;
      END IF;
      --//-----------------------------------------------------------------Termino--\\
    
      INSERT INTO Scfr_Mov_Documentos_Txs
        (Mov_Documentos
        ,Txo_Codigo_Tx
        ,Txo_Correlativo_Tx
        ,Secuencia
        ,Tmo_Movimiento
        ,Dfi_Numero_Asignacion
        ,Monto
        ,Anulado
        ,Iva
        ,Folio
        ,Folio_Dicc
        ,Tipo_Dicc
        ,Pin_Ot_Recetario
        ,Estado_Movimiento_Caja
        ,Fecha_Regularizacion
        ,Numero_Pedido
        ,Pvr_Rut_Proveedor
        ,Pvr_Sucursal_Proveedor
        ,Folio_Reclamo_Canje
        ,Matricula_Bulto
        ,Sello_Seguro_Uno
        ,Sello_Seguro_Dos
        ,Facturado
        ,Periodo_Facturacion
        ,Puntos_Asignados
        ,Emp_Empresa
        ,Cad_Cadena
        ,Loc_Local
        ,Tipo_Distribucion
        ,Campana
        ,Documento_Fiscal
        ,Sec_Financiamiento
        ,Origen_Anulacion
        ,Institucion
        ,Motivo2)
      VALUES
        (l_Mov_Documentos -- mov_documentos                    not null
        ,p_Transaccion.Codigo_Tx -- txo_codigo_tx                     not null
        ,l_Trama_Dr.Correlativo_Tx -- txo_correlativo_tx                not null
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Secuencia_b -- secuencia                         not null
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Movimiento_Hijo -- tmo_movimiento                    not null
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Numero_Asignacion -- dfi_numero_asignacion                 null
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Total_Iva_Incluido -- monto                             not null
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Anulado -- anulado                           not null
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Iva -- iva                                   null
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Folio -- folio                                 null
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Folio_Dicc -- folio_dicc                            null
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Dicc -- tipo_dicc                             null
        ,l_Trama_Dr.Ot -- pin_ot_recetario
        ,NULL -- estado_movimiento_caja                null
        ,NULL -- fecha_regularizacion                  null
        ,NULL -- numero_pedido                         null
        ,NULL -- pvr_rut_proveedor                     null
        ,NULL -- pvr_sucursal_proveedor                null
        ,NULL -- folio_reclamo_canje                   null
        ,NULL -- matricula_bulto                       null
        ,NULL -- sello_seguro_uno                      null
        ,NULL -- sello_seguro_dos                      null
        ,NULL -- facturado                             null
        ,NULL -- periodo_facturacion                   null
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Puntos_Asignados -- puntos_asignados                      null
        ,p_Transaccion.Trama_Pos.Empresa -- emp_empresa                           null
        ,p_Transaccion.Trama_Pos.Cadena -- cad_cadena                            null
        ,p_Transaccion.Trama_Pos.Local -- loc_local                             null
        ,TRIM(l_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Distribucion) -- tipo_distribucion                     null
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Campana -- campana
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Documento_Fiscal -- documento_fiscal                     null
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Secuencia_Financiamiento -- secuencia_financiamiento
        ,l_Origen_Anulacion
        ,TRIM(l_Trama_Dr.Subtrama_Dr1(l_Itm).Institucion)
        ,NVL(TRIM(l_Trama_Dr.Subtrama_Dr1(l_Itm).Ruc_Institucion),'-'));
    
      --//--------------------------------------------------------------------------\\
      --// CBR 05/04/2016 04/05/2016 13:27                                          \\
      --// FONDO DE SENCILLO                                                        \\
      --//-----------------------------------------------------------------Inicio---\\
      IF Upper(l_Trama_Dr.Tipo_Movimiento_Padre) = 'RECAUD' AND
         Upper(l_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Movimiento_Hijo) = 'ANUFSC' THEN
        l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_DETALLE_DEPOSITO';
        INSERT INTO Scfr_Mov_Detalle_Deposito
          (Txo_Codigo_Tx
          ,Codigo_Deposito
          ,Monto_Deposito
          ,Numero_Colilla
          ,Registro_Devolucion
          ,Empresa
          ,Cadena
          ,Loc_Local)
        VALUES
          (p_Transaccion.Codigo_Tx
          ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Movimiento_Hijo
          ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Total_Iva_Incluido
          ,TRIM(l_Trama_Dr.Subtrama_Dr1(l_Itm).Folio)
          ,l_Trama_Dr.Registro_Recepcion_1
          ,p_Transaccion.Trama_Pos.Empresa
          ,p_Transaccion.Trama_Pos.Cadena
          ,p_Transaccion.Trama_Pos.Local);
      END IF;
      --//-----------------------------------------------------------------Termino--\\
      Dbms_Output.Put_Line('Insertando documentos ');
    END LOOP;
  EXCEPTION
    WHEN l_Error_Controlado THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Trama_Dr_Resuelve_Act(p_Transaccion  IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                 ,x_Doc_Emitidos OUT Scfr_Trx_Gnc_Pk.Tab_Doc_Emitidos
                                 ,x_Cod_Error    OUT NUMBER
                                 ,x_Msg_Error    OUT VARCHAR2) IS
    l_Trama_Cv                  Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv;
    l_Trama_Dr                  Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dr;
    l_Trama_Pm                  Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm;
    l_Cod_Autorizacion          NUMBER;
    l_Monto_Bonificado          NUMBER;
    l_Banda                     VARCHAR2(30);
    l_Item                      NUMBER;
    l_Fecha_Tx                  DATE;
    l_Diferencia                NUMBER;
    l_Existe_Dominio            NUMBER;
    l_Codigo_Tx                 NUMBER;
    l_Fecha_Transacc            DATE;
    l_Mov_Documentos            NUMBER;
    l_Rut_Personal              NUMBER;
    l_Scfr_Mov_Transacciones_s  NUMBER;
    l_Scfr_Mov_Documentos_Txs_s NUMBER;
    l_Mov_Pagos                 NUMBER;
    l_Codigo_Personal           NUMBER;
    l_Dv_Rut_Personal           VARCHAR2(1);
    l_Total_Gral                NUMBER;
    l_Resultado                 NUMBER;
    l_Cod_Error                 NUMBER;
    l_Msg_Error                 VARCHAR2(2000);
    l_Dbg_Proceso               VARCHAR2(100) := 'SCFR_TRX_GNC_PK.GNCU05.trama_dr_resuelve_act';
    l_Dbg_Mensaje               VARCHAR2(250) := 'Error General';
    l_Error_Contralado          EXCEPTION;
    l_Recaudacion               NUMBER;
    --l_txo_codigo_tx_relacionado NUMBER;
    l_Tipo_Identi_Titular VARCHAR2(1);
    l_Identi_Titular      VARCHAR2(30);
    l_Convenio            VARCHAR2(50);
    l_Signo               NUMBER := 1;
  
  BEGIN
  
    --***********************************************************************
    -- Actualizacion genericac de recaudacion
    --***********************************************************************
    l_Dbg_Mensaje := 'Obtener Antecedentes transaccion padre   Trama DR';
    l_Trama_Dr    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Dr(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje := 'Valida completitud de datos obligatorios.' || l_Trama_Dr.Correlativo_Tx || ' ' || l_Trama_Dr.Tipo_Movimiento_Padre || ' ' ||
                     l_Trama_Dr.Fecha || ' ' || l_Trama_Dr.Hora_Recaudacion || ' ' || l_Trama_Dr.Documentos_Emitidos;
    IF (Nvl(l_Trama_Dr.Correlativo_Tx
           ,0) < 1) OR
       (Nvl(l_Trama_Dr.Tipo_Movimiento_Padre
           ,'NADA01') = 'NADA01') OR
       (Nvl(l_Trama_Dr.Fecha
           ,0) < 1) OR
       (Nvl(l_Trama_Dr.Hora_Recaudacion
           ,0) < 1) OR
       (Nvl(l_Trama_Dr.Documentos_Emitidos
           ,0) < 1) THEN
      x_Cod_Error := -2000;
      x_Msg_Error := 'datos obligatorios.  Nulos trama DR';
      RAISE l_Error_Contralado;
    END IF;
    l_Dbg_Mensaje := 'Valida Verificando FechaS.';
    l_Fecha_Tx    := To_Date(To_Char(l_Trama_Dr.Fecha) || Lpad(To_Char(l_Trama_Dr.Hora_Recaudacion)
                                                              ,6
                                                              ,'0')
                            ,'yyyymmdd hh24:mi:ss');
    l_Dbg_Mensaje := 'Recorre detalle de documentos emitidos.';
    --l_diferencia   := 0;
    FOR l_Itm IN 1 .. l_Trama_Dr.Documentos_Emitidos
    LOOP
      l_Dbg_Mensaje := ' Valida completitud de datos obligatorios.';
      IF (l_Trama_Dr.Subtrama_Dr1(l_Itm).Secuencia_b IS NULL) OR
         (l_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Movimiento_Hijo IS NULL) OR
         (l_Trama_Dr.Subtrama_Dr1(l_Itm).Anulado IS NULL) OR
         (l_Trama_Dr.Subtrama_Dr1(l_Itm).Total_Iva_Incluido IS NULL) THEN
        x_Cod_Error   := -2000;
        x_Msg_Error   := 'datos obligatorios.  Nulos Trama DR1';
        l_Dbg_Mensaje := x_Msg_Error || ' ' || x_Cod_Error;
        RAISE l_Error_Contralado;
      END IF;
      l_Dbg_Mensaje := 'Chequea que valor para campo anulado sea valido.';
      SELECT 1
        INTO l_Existe_Dominio
        FROM Cg_Ref_Codes
       WHERE Rv_Domain = 'SI/NO'
         AND Substr(Rv_Low_Value
                   ,1
                   ,1) = l_Trama_Dr.Subtrama_Dr1(l_Itm).Anulado;
      --l_diferencia := l_diferencia + 19;
                  
      IF l_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Movimiento_Hijo = 'RECCOU' THEN
        l_Signo := -1;
      END IF;  
      
    END LOOP;
    IF l_Trama_Dr.Venta_Relacionada IS NOT NULL THEN
      /*      l_dbg_mensaje := ' Obtiene codigo TX de la venta relacionada';
      BEGIN
        SELECT mt.codigo_tx
          INTO l_txo_codigo_tx_relacionado
          FROM scfr_mov_transacciones mt
         WHERE mt.correlativo_tx = l_trama_dr.venta_relacionada
           AND mt.loc_local = l_trama_dr.local_relacionado
           AND mt.emp_empresa = p_transaccion.trama_pos.empresa
           AND mt.tmo_movimiento_padre = 'VENTAS';
      EXCEPTION
        WHEN OTHERS THEN
          l_txo_codigo_tx_relacionado := NULL;
      END;*/
      l_Recaudacion := l_Trama_Dr.Venta_Relacionada;
    ELSE
      l_Recaudacion := l_Trama_Dr.Secuencia_b;
    END IF;
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'CV') THEN
      l_Dbg_Mensaje := 'Obtener informacion de la trama CV';
      l_Trama_Cv    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Cv(p_Transaccion.Cuerpo_Tx);
      /* Para controlar cuando mandan encabezado de trama CV con 0 registros */
      IF l_Trama_Cv.Count = 0 THEN
        l_Trama_Cv(1).Convenio := NULL;
        l_Trama_Cv(1).Plan := NULL;
        l_Trama_Cv(1).Codigo_Autorizacion := NULL;
      END IF;
    ELSE
      l_Trama_Cv(1).Convenio := NULL;
      l_Trama_Cv(1).Plan := NULL;
      l_Trama_Cv(1).Codigo_Autorizacion := NULL;
    END IF;
    l_Dbg_Mensaje := 'Obtener folio desde scfr_mov_transacciones_s';
    SELECT Scfr_Mov_Transacciones_s.Nextval INTO p_Transaccion.Codigo_Tx FROM Dual;
    p_Transaccion.Fecha_Tx       := To_Date(Ltrim(Rtrim(l_Trama_Dr.Fecha)) || Ltrim(Rtrim(To_Char(l_Trama_Dr.Hora_Recaudacion
                                                                                                 ,'000009')))
                                           ,'yyyymmddhh24miss');
    p_Transaccion.Correlativo_Tx := l_Trama_Dr.Correlativo_Tx;
    IF l_Fecha_Tx IS NULL THEN
      l_Fecha_Transacc := To_Date(l_Fecha_Tx
                                 ,'yyyymmddhh24miss');
    END IF;  
    
    BEGIN
      -- OBTIENE DATOS DE     Identi_Titular  DE LA TX ORIGINAL
      SELECT Tipo_Identi_Titular
            ,Identi_Titular
        INTO l_Tipo_Identi_Titular
            ,l_Identi_Titular
        FROM Scfr_Mov_Datos_Ventas
       WHERE Txo_Codigo_Tx IN (SELECT Codigo_Tx
                                 FROM Scfr_Mov_Transacciones
                                WHERE Correlativo_Tx = l_Trama_Dr.Venta_Relacionada
                                  AND Loc_Local = l_Trama_Dr.Local_Relacionado)
         AND Identi_Titular IS NOT NULL;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Tipo_Identi_Titular := NULL;
        l_Identi_Titular      := NULL;
    END;
  
    IF (l_Trama_Cv(1).Convenio >= 1000000000) THEN
      l_Convenio := To_Char(To_Number(Substr(To_Char(l_Trama_Cv(1).Convenio)
                                            ,3
                                            ,10)));
    ELSE
      l_Convenio := To_Char(To_Number(To_Char(l_Trama_Cv(1).Convenio)));
    END IF;
  
    l_Dbg_Mensaje := 'Inserta transaccion';
    INSERT INTO Scfr_Mov_Transacciones
      (Codigo_Tx
      ,Correlativo_Tx
      ,Tmo_Movimiento_Padre
      ,Fecha_Tx
      ,Emp_Empresa
      ,Cad_Cadena
      ,Loc_Local
      ,Numero_Maquina
      ,Pt_Party_Id_Titular
      ,Rut_Titular
      ,Dv_Titular
      ,Estado_Registro
      ,Sec_Recaudacion
      ,Proceso_Dwh
      ,Numero_Cuenta_Tarjeta
      ,Codigo_Autorizacion_Tx
      ,Estx_Srv_Codigo
      ,Estx_Numero_Pos
      ,Estx_Fecha
      ,
       --txo_correlativo_tx_relacionado,
       Estx_Destino
      ,Estx_Sistema
      ,Estx_Funcion
      ,Estx_Secuencia
      ,Estx_Numero_Trama
      ,Estx_Codigo_Tx
      ,Estx_Numero_Local
      ,
       --txo_codigo_tx_relacionado,
       Con_Numero_Convenio
      ,Pla_Numero_Plan
      ,Autorizacion_Cnv_Tx
      ,Cuadrar_Transacciones
      ,Docs_Emitir_Liq_Pag
      ,Docs_Emitir_Liq_Emp
      ,Autorizacion_Cnv_Ext
      ,Transaccion_Manual
      ,Numero_Tav
      ,Fecha_Inicio_Tx
      ,Fecha_Cierre_Tx
      ,Fecha_Generacion_Registro
      ,Numero_Tx_Comercio
      ,Tipo_Identi_Titular
      ,Identi_Titular)
    VALUES
      (p_Transaccion.Codigo_Tx
      ,l_Trama_Dr.Correlativo_Tx
      ,l_Trama_Dr.Tipo_Movimiento_Padre
      ,l_Fecha_Tx
      ,p_Transaccion.Trama_Pos.Empresa
      ,p_Transaccion.Trama_Pos.Cadena
      ,p_Transaccion.Trama_Pos.Local
      ,p_Transaccion.Trama_Pos.Numero_Pos
      ,p_Transaccion.Trama_Boc.Party_Id -- pt_party_id_titular
      ,p_Transaccion.Rut_Titular -- rut_titular
      ,p_Transaccion.Dv_Rut_Titular -- dv_titular
      ,'VIG'
      ,l_Recaudacion
      ,0
      ,Ltrim(Rtrim(l_Trama_Dr.Numero_Cuenta))
      ,Ltrim(Rtrim(l_Trama_Dr.Codigo_Autorizacion))
      ,l_Trama_Dr.Codigo_Servicio
      ,l_Trama_Dr.Numero_Pos
      ,To_Date(l_Trama_Dr.Fecha_Transaccion
              ,'yyyymmddhh24miss')
      ,
       --l_trama_dr.venta_relacionada,
       l_Trama_Dr.Destino
      ,l_Trama_Dr.Sistema
      ,l_Trama_Dr.Funcion
      ,l_Trama_Dr.Secuencia_c
      ,l_Trama_Dr.Numero_Trama
      ,TRIM(l_Trama_Dr.Codigo_Transaccion)
      ,l_Trama_Dr.Local
      ,
       --l_txo_codigo_tx_relacionado,
       l_Convenio -- l_Trama_Cv(1).Convenio
      ,l_Trama_Cv(1).Plan
      ,TRIM(l_Trama_Cv(1).Codigo_Autorizacion)
      ,l_Trama_Dr.Cuadra_Transaccion
      ,l_Trama_Dr.Documento_Liquidacion_Pago
      ,l_Trama_Dr.Documento_Liquidacion_Empresa
      ,l_Trama_Dr.Codigo_Autorizacion_Externo
      ,l_Trama_Dr.Transaccion_Manual
      ,TRIM(p_Transaccion.Trama_Pos.Id_Maquina)
      ,To_Date(Decode(l_Trama_Dr.Fecha_Inicio_Tx
                     ,0
                     ,NULL
                     ,l_Trama_Dr.Fecha_Inicio_Tx)
              ,'yyyymmddhh24miss')
      ,To_Date(Decode(l_Trama_Dr.Fecha_Cierre_Tx
                     ,0
                     ,NULL
                     ,l_Trama_Dr.Fecha_Cierre_Tx)
              ,'yyyymmddhh24miss')
      ,Trunc(To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Proceso
                    ,'yyyymmddhh24miss'))
      ,l_Trama_Dr.Numero_Tx_Comercio
      ,l_Tipo_Identi_Titular
      ,l_Identi_Titular);
    FOR l_Itm IN 1 .. l_Trama_Dr.Documentos_Emitidos
    LOOP
      l_Dbg_Mensaje := ' obtiene folio para documentos TXS.';
      SELECT Scfr_Mov_Documentos_Txs_s.Nextval INTO l_Mov_Documentos FROM Dual;
      x_Doc_Emitidos(l_Itm) := l_Mov_Documentos;
      l_Dbg_Mensaje := ' inserta documentos de transaccion.';
    
      --//--------------------------------------------------------------------------\\
      --// CBR 30/08/2017 14:48                                                     \\
      --//-----------------------------------------------------------------Inicio---\\
      IF p_Transaccion.Trama_Pos.Origen_Transaccion IN ('AUC'
                                                       ,'BOX'
                                                       ,'GLO'
                                                       ,'FEL'
                                                       ,'FAT'
                                                       ,'CIA'
                                                       ,'EMP'
                                                       ,'DEC') AND
         l_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Movimiento_Hijo IN ('ANUAJU'
                                                                ,'RECAJU') THEN
        IF l_Trama_Dr.Subtrama_Dr1(l_Itm).Signo = 'N' THEN
          l_Trama_Dr.Subtrama_Dr1(l_Itm).Total_Iva_Incluido := (l_Trama_Dr.Subtrama_Dr1(l_Itm).Total_Iva_Incluido * -1);
          l_Trama_Dr.Subtrama_Dr1(l_Itm).Iva := (l_Trama_Dr.Subtrama_Dr1(l_Itm).Iva * -1);
        END IF;
      END IF;
      --//-----------------------------------------------------------------Termino--\\
    
      INSERT INTO Scfr_Mov_Documentos_Txs
        (Mov_Documentos
        ,Txo_Codigo_Tx
        ,Txo_Correlativo_Tx
        ,Secuencia
        ,Tmo_Movimiento
        ,Dfi_Numero_Asignacion
        ,Monto
        ,Afecto
        ,Anulado
        ,Iva
        ,Folio
        ,Folio_Dicc
        ,Tipo_Dicc
        ,Pin_Ot_Recetario
        ,Estado_Movimiento_Caja
        ,Fecha_Regularizacion
        ,Numero_Pedido
        ,Pvr_Rut_Proveedor
        ,Pvr_Sucursal_Proveedor
        ,Folio_Reclamo_Canje
        ,Matricula_Bulto
        ,Sello_Seguro_Uno
        ,Sello_Seguro_Dos
        ,Facturado
        ,Periodo_Facturacion
        ,Puntos_Asignados
        ,Emp_Empresa
        ,Cad_Cadena
        ,Loc_Local
        ,Tipo_Distribucion
        ,Campana
        ,Documento_Fiscal
        ,Sec_Financiamiento
        ,Institucion
        ,Motivo2)
      VALUES
        (l_Mov_Documentos -- mov_documentos                    not null
        ,p_Transaccion.Codigo_Tx -- txo_codigo_tx                     not null
        ,l_Trama_Dr.Correlativo_Tx -- txo_correlativo_tx                not null
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Secuencia_b -- secuencia                         not null
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Movimiento_Hijo -- tmo_movimiento                    not null
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Numero_Asignacion -- dfi_numero_asignacion                 null
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Total_Iva_Incluido * l_Signo -- monto                    null
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Total_Iva_Incluido * l_Signo -- monto                           not null
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Anulado -- anulado                           not null
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Iva * l_Signo -- iva                                   null
        ,p_Transaccion.Trama_Pos.Numero_Pos || '-' || l_Trama_Dr.Subtrama_Dr1(l_Itm).Folio -- folio                                 null
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Folio_Dicc -- folio_dicc                            null
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Dicc -- tipo_dicc                             null
        ,l_Trama_Dr.Ot -- pin_ot_recetario
        ,NULL -- estado_movimiento_caja                null
        ,NULL -- fecha_regularizacion                  null
        ,NULL -- numero_pedido                         null
        ,NULL -- pvr_rut_proveedor                     null
        ,NULL -- pvr_sucursal_proveedor                null
        ,NULL -- folio_reclamo_canje                   null
        ,NULL -- matricula_bulto                       null
        ,NULL -- sello_seguro_uno                      null
        ,NULL -- sello_seguro_dos                      null
        ,NULL -- facturado                             null
        ,NULL -- periodo_facturacion                   null
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Puntos_Asignados -- puntos_asignados                      null
        ,p_Transaccion.Trama_Pos.Empresa -- emp_empresa                           null
        ,p_Transaccion.Trama_Pos.Cadena -- cad_cadena                            null
        ,p_Transaccion.Trama_Pos.Local -- loc_local                             null
        ,TRIM(l_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Distribucion) -- tipo_distribucion                     null
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Campana
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Documento_Fiscal
        ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Secuencia_Financiamiento
        ,TRIM(l_Trama_Dr.Subtrama_Dr1(l_Itm).Institucion)
        ,NVL(TRIM(l_Trama_Dr.Subtrama_Dr1(l_Itm).Ruc_Institucion),'-'));
    
      --//--------------------------------------------------------------------------\\
      --// CBR 05/04/2016 04/05/2016 13:27                                          \\
      --// FONDO DE SENCILLO                                                        \\
      --//-----------------------------------------------------------------Inicio---\\
      IF Upper(l_Trama_Dr.Tipo_Movimiento_Padre) = 'RECAUD' AND
         Upper(l_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Movimiento_Hijo) = 'RECFSC' THEN
        l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_DETALLE_DEPOSITO';
        INSERT INTO Scfr_Mov_Detalle_Deposito
          (Txo_Codigo_Tx
          ,Codigo_Deposito
          ,Monto_Deposito
          ,Numero_Colilla
          ,Registro_Recepcion_1
          ,Empresa
          ,Cadena
          ,Loc_Local)
        VALUES
          (p_Transaccion.Codigo_Tx
          ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Movimiento_Hijo
          ,l_Trama_Dr.Subtrama_Dr1(l_Itm).Total_Iva_Incluido * l_Signo
          ,TRIM(l_Trama_Dr.Subtrama_Dr1(l_Itm).Folio)
          ,l_Trama_Dr.Registro_Recepcion_1
          ,p_Transaccion.Trama_Pos.Empresa
          ,p_Transaccion.Trama_Pos.Cadena
          ,p_Transaccion.Trama_Pos.Local);
      END IF;
      --//-----------------------------------------------------------------Termino--\\
    END LOOP;
    -- Actualiza codigo_tx de la recaudacion para la venta relacionada en SCFR_MOV_TX_RELACIONADAS
    UPDATE Scfr_Mov_Tx_Relacionadas
       SET Txo_Codigo_Tx_Relacionado = p_Transaccion.Codigo_Tx
          ,Procesado                 = Nvl2(Procesado
                                           ,2
                                           ,Procesado)
     WHERE Correlativo_Tx_Relacionado = p_Transaccion.Correlativo_Tx
       AND LOCAL = p_Transaccion.Trama_Pos.Local
       AND Trunc(Fecha_Tx) = Trunc(l_Fecha_Tx)
       AND Numero_Maquina = p_Transaccion.Trama_Pos.Numero_Pos;
  
  EXCEPTION
    WHEN l_Error_Contralado THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  FUNCTION Trama_Dr_Prepara(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dr IS
    l_Correlativo_Tx NUMBER;
    l_Local          NUMBER;
    l_Codigo_Tx      NUMBER;
    l_Trama_Dh       Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dh;
    l_Trama_Dr       Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dr;
    CURSOR c_Doctos_Trx(l_Codigo_Tx IN NUMBER) IS
    --      select secuencia                   secuencia
    --           , tmo_movimiento              tipo_mov_hijo
    --           , anulado                     anulado
    --           , nvl(monto,0) + nvl(iva,0)   total
    --           , nvl(pin_ot_recetario,' ')   pin_ot_recetario
    --        from scfr_mov_documentos_txs
    --       where txo_codigo_tx = l_codigo_tx;
      SELECT Txo_Codigo_Tx
            ,Secuencia
            ,Tmo_Movimiento
            ,Dfi_Numero_Asignacion
            ,Anulado
            ,Folio
            ,Tipo_Dicc
            ,Folio_Dicc
            ,Monto
            ,Iva
            ,Puntos_Asignados
            ,Tipo_Distribucion
            ,Pin_Ot_Recetario
            ,Campana
            ,Documento_Fiscal
            ,Sec_Financiamiento
        FROM Scfr_Mov_Documentos_Txs
       WHERE Txo_Codigo_Tx = l_Codigo_Tx;
    i                  NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.DOCUMENTO_RECAUDACION';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Contralado EXCEPTION;
    l_Codigo_Resp      NUMBER;
  BEGIN
    l_Dbg_Mensaje := 'Obtener informacion de la trama DH (Documento de Recaudacion a Consulta)';
    l_Trama_Dh    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Dh(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje := 'Chequear forma idententificacion recaudacion (CODIGO_TX o N? OT)';
    IF Nvl(l_Trama_Dh.Correlativo_Tx
          ,0) = 0 THEN
      IF l_Trama_Dh.Ot IS NULL THEN
        Raise_Application_Error(-20000
                               ,'Correlativo TX y N? OT invalidos');
      END IF;
      l_Dbg_Mensaje := 'Buscar CORRELATIVO_TX por el N? OT ' || l_Trama_Dh.Ot;
      SELECT Txo_Correlativo_Tx
        INTO l_Correlativo_Tx
        FROM Scfr_Mov_Documentos_Txs
       WHERE Pin_Ot_Recetario = l_Trama_Dh.Ot
         AND Tmo_Movimiento = 'RECRMA';
    ELSE
      l_Correlativo_Tx := l_Trama_Dh.Correlativo_Tx;
    END IF;
    IF Nvl(l_Trama_Dh.Local
          ,0) = 0 THEN
      l_Local := To_Number(Substr(l_Trama_Dh.Ot
                                 ,6
                                 ,3));
    ELSE
      l_Local := l_Trama_Dh.Local;
    END IF;
    l_Dbg_Mensaje := 'Obtener Transaccion de recaudacion - correlatico=>' || l_Correlativo_Tx || '/local=>' || l_Local;
    SELECT Tmo_Movimiento_Padre Tipo_Mov_Padre
          ,To_Char(Fecha_Tx
                  ,'yyyymmdd') Fecha
          ,To_Char(Fecha_Tx
                  ,'hh24miss') Hora
          ,Sec_Recaudacion Secuencia_Num
          ,Nvl(Numero_Cuenta_Tarjeta
              ,' ') Numero_Cuenta
          ,Nvl(Substr(Codigo_Autorizacion_Tx
                     ,1
                     ,20)
              ,' ') Cod_Aut
          ,Nvl(Pin_Transaccion
              ,' ') Folio_Ot
           --, nvl(sec_recaudacion,0)                       secuencia_num
          ,Nvl(Txo_Correlativo_Tx_Relacionado
              ,0) Recaud_Relacionada
          ,Nvl(Estx_Srv_Codigo
              ,' ') Cod_Serv
          ,Loc_Local LOCAL
          ,Estx_Numero_Local
          ,Estx_Numero_Pos Pos
          ,' ' Destino
          ,' ' Sistema
          ,' ' Funcion
          ,'00' Secuencia_Char
          ,0 Fecha_Trx
          ,0 Correlativo
          ,0 Numero_Trama
          ,' ' Cod_Trx
          ,Correlativo_Tx l_Correlativo_Tx
          ,Codigo_Tx Codigo_Tx
          ,Cuadrar_Transacciones
          ,Docs_Emitir_Liq_Pag
          ,Docs_Emitir_Liq_Emp
          ,Autorizacion_Cnv_Ext
          ,Transaccion_Manual
          ,Numero_Tx_Comercio
      INTO l_Trama_Dr.Tipo_Movimiento_Padre
          ,l_Trama_Dr.Fecha
          ,l_Trama_Dr.Hora_Recaudacion
          ,l_Trama_Dr.Secuencia_b
          ,l_Trama_Dr.Numero_Cuenta
          ,l_Trama_Dr.Codigo_Autorizacion
          ,l_Trama_Dr.Ot
          ,l_Trama_Dr.Venta_Relacionada
          ,l_Trama_Dr.Codigo_Servicio
          ,l_Trama_Dr.Local_Relacionado
          ,l_Trama_Dr.Local
          ,l_Trama_Dr.Numero_Pos
          ,l_Trama_Dr.Destino
          ,l_Trama_Dr.Sistema
          ,l_Trama_Dr.Funcion
          ,l_Trama_Dr.Secuencia_c
          ,l_Trama_Dr.Fecha_Transaccion
          ,l_Trama_Dr.Correlativo
          ,l_Trama_Dr.Numero_Trama
          ,l_Trama_Dr.Codigo_Transaccion
          ,l_Trama_Dr.Correlativo_Tx
          ,l_Codigo_Tx
          ,l_Trama_Dr.Cuadra_Transaccion
          ,l_Trama_Dr.Documento_Liquidacion_Pago
          ,l_Trama_Dr.Documento_Liquidacion_Empresa
          ,l_Trama_Dr.Codigo_Autorizacion_Externo
          ,l_Trama_Dr.Transaccion_Manual
          ,l_Trama_Dr.Numero_Tx_Comercio
      FROM Scfr_Mov_Transacciones
     WHERE (Correlativo_Tx = l_Correlativo_Tx OR Codigo_Autorizacion_Tx = l_Trama_Dh.Ot)
       AND Loc_Local = l_Local
       AND Tmo_Movimiento_Padre = 'RECAUD'
       AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
       AND Fecha_Tx = (SELECT MAX(Fecha_Tx)
                         FROM Scfr_Mov_Transacciones
                        WHERE (Correlativo_Tx = l_Correlativo_Tx OR Codigo_Autorizacion_Tx = l_Trama_Dh.Ot)
                          AND Loc_Local = l_Local
                          AND Tmo_Movimiento_Padre = 'RECAUD'
                          AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa);
    IF l_Trama_Dr.Ot IS NULL THEN
      l_Trama_Dr.Ot := l_Trama_Dh.Ot;
    END IF;
    l_Dbg_Mensaje           := 'Obtener detalle de documentos';
    p_Transaccion.Codigo_Tx := l_Codigo_Tx;
    i                       := 0;
    FOR r IN c_Doctos_Trx(l_Codigo_Tx)
    LOOP
      i := i + 1;
      l_Trama_Dr.Subtrama_Dr1(i).Secuencia_b := r.Secuencia;
      l_Trama_Dr.Subtrama_Dr1(i).Tipo_Movimiento_Hijo := r.Tmo_Movimiento;
      l_Trama_Dr.Subtrama_Dr1(i).Numero_Asignacion := r.Dfi_Numero_Asignacion;
      l_Trama_Dr.Subtrama_Dr1(i).Anulado := r.Anulado;
      l_Trama_Dr.Subtrama_Dr1(i).Folio := r.Folio;
      l_Trama_Dr.Subtrama_Dr1(i).Tipo_Dicc := r.Tipo_Dicc;
      l_Trama_Dr.Subtrama_Dr1(i).Folio_Dicc := r.Folio_Dicc;
      l_Trama_Dr.Subtrama_Dr1(i).Total_Iva_Incluido := r.Monto;
      l_Trama_Dr.Subtrama_Dr1(i).Iva := r.Iva;
      l_Trama_Dr.Subtrama_Dr1(i).Puntos_Asignados := r.Puntos_Asignados;
      l_Trama_Dr.Subtrama_Dr1(i).Tipo_Distribucion := r.Tipo_Distribucion;
      l_Trama_Dr.Subtrama_Dr1(i).Campana := r.Campana;
      l_Trama_Dr.Subtrama_Dr1(i).Documento_Fiscal := r.Documento_Fiscal;
      l_Trama_Dr.Subtrama_Dr1(i).Secuencia_Financiamiento := r.Sec_Financiamiento;
    
      IF r.Tmo_Movimiento = 'RECFSC' OR
         r.Tmo_Movimiento = 'ANUFSC' THEN
        l_Dbg_Mensaje := 'Obtener detalle Deposito';
        SELECT Decode(r.Tmo_Movimiento
                     ,'RECFSC'
                     ,Dep.Registro_Recepcion_1
                     ,'ANUFSC'
                     ,Dep.Registro_Devolucion)
          INTO l_Trama_Dr.Registro_Recepcion_1
          FROM Scfr_Mov_Detalle_Deposito Dep
         WHERE r.Txo_Codigo_Tx = Dep.Txo_Codigo_Tx
           AND r.Tmo_Movimiento = Dep.Codigo_Deposito;
      END IF;
    
      IF l_Trama_Dr.Ot IS NULL THEN
        l_Trama_Dr.Ot := r.Pin_Ot_Recetario;
      END IF;
    END LOOP;
    /*    i                       := 0;
        l_DBG_MENSAJE           := 'Obtener detalle de documentos';
        for r in C_doctos_trx(l_codigo_tx) loop
          i                                               := i + 1;
          l_trama_dr.subtrama_dr1(i).secuencia_b          := r.secuencia    ;
          l_trama_dr.subtrama_dr1(i).tipo_movimiento_hijo := r.tipo_mov_hijo;
          l_trama_dr.subtrama_dr1(i).anulado              := r.anulado      ;
          l_trama_dr.subtrama_dr1(i).total_iva_incluido   := r.total        ;
          if l_trama_dr.ot is null then
            l_trama_dr.ot := r.pin_ot_recetario;
          end if;
        end loop;
    */
    l_Trama_Dr.Documentos_Emitidos := i;
    RETURN(l_Trama_Dr);
  EXCEPTION
    WHEN No_Data_Found THEN
      x_Cod_Error := 7;
      RETURN l_Trama_Dr;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
      RETURN l_Trama_Dr;
  END;

  PROCEDURE Trama_Vd_Resuelve_Anu(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                 ,p_Multiplo    IN NUMBER
                                 ,x_Cod_Error   OUT NUMBER
                                 ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Vd                  Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vd;
    i                           NUMBER;
    l_Rut                       NUMBER;
    l_Dv                        VARCHAR2(1);
    l_Fecha_Hora                DATE;
    l_Rut_Personal              NUMBER;
    l_Dv_Rut_Personal           VARCHAR2(1);
    l_Scfr_Mov_Transacciones_s  NUMBER(15) := 0;
    l_Scfr_Mov_Documentos_Txs_s NUMBER(15) := 0;
    l_Mov_Pagos                 NUMBER;
    l_Codigo_Personal           NUMBER;
    l_Total_Gral                NUMBER;
    l_Resultado                 NUMBER;
    l_Dbg_Proceso               VARCHAR2(100);
    l_Dbg_Mensaje               VARCHAR2(250) := 'Error General';
    l_Error_Controlado          EXCEPTION;
    l_Origen_Anulacion          VARCHAR2(3);
    Mes_Venta                   NUMBER;
    Mes_Anulacion               NUMBER;
    Dia_Venta                   NUMBER;
    Dia_Anulacion               NUMBER;
    l_Fecha_Tx_Origen           DATE;
    l_Txo_Codigo_Tx_Relacionado NUMBER;
    l_Convenio                  VARCHAR2(50);
  BEGIN
    l_Dbg_Proceso := 'SCFR_TRX_GNC_PK.' || 'trama_vd_resuelve_anu';
    l_Dbg_Mensaje := 'Obtener informacion de la trama VD (Avances)';
    l_Trama_Vd    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Vd(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje := 'Preparar fecha';
    BEGIN
      l_Fecha_Hora := To_Date(Ltrim(Rtrim(To_Char(l_Trama_Vd.Fecha))) || Ltrim(Rtrim(To_Char(l_Trama_Vd.Hora_Venta
                                                                                            ,'000009')))
                             ,'yyyymmddhh24miss');
    EXCEPTION
      WHEN OTHERS THEN
        l_Fecha_Hora := Scfr_Trx_Util_Pk.Get_Sysdate();
    END;
    l_Dbg_Mensaje := 'Obtener Rut';
    Scfr_Trx_Util_Pk.Obtiene_Rut(p_Transaccion.Trama_Boc.Party_Id
                                ,p_Transaccion.Rut_Titular
                                ,p_Transaccion.Dv_Rut_Titular);
    l_Dbg_Mensaje := 'Buscar Movimiento Original para Actualizar';
    IF Nvl(l_Trama_Vd.Secuencia_b
          ,0) <> 0 THEN
      BEGIN
        SELECT Codigo_Tx
              ,Fecha_Tx
          INTO l_Txo_Codigo_Tx_Relacionado
              ,l_Fecha_Tx_Origen
          FROM Scfr_Mov_Transacciones
         WHERE Correlativo_Tx = l_Trama_Vd.Secuencia_b
           AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
           AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
           AND Loc_Local = l_Trama_Vd.Local_Relacionado
           AND Fecha_Tx >= To_Date(l_Trama_Vd.Fecha
                                  ,'yyyymmdd') - 90;
        l_Dbg_Mensaje := 'Determinar Origen Anulacion';
        Mes_Venta     := Extract(MONTH FROM To_Date(l_Fecha_Tx_Origen
                                        ,'dd/mm/yyyy hh24:mi:ss'));
        Mes_Anulacion := Extract(MONTH FROM To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                        ,'yyyymmddhh24miss'));
        Dia_Venta     := Extract(DAY FROM To_Date(l_Fecha_Tx_Origen
                                        ,'dd/mm/yyyy hh24:mi:ss'));
        Dia_Anulacion := Extract(DAY FROM To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                        ,'yyyymmddhh24miss'));
        IF (Mes_Venta = Mes_Anulacion) THEN
          IF (Dia_Venta = Dia_Anulacion) THEN
            l_Origen_Anulacion := 'DIA';
          ELSE
            l_Origen_Anulacion := 'ANT';
          END IF;
        ELSE
          l_Origen_Anulacion := 'MAN';
        END IF;
        -- CGC INI 25/01/2013
        -- Se obtiene secuencia antes de actualizar el movimiento original, y asi no se consume la secuencia en caso de falla.
        l_Dbg_Mensaje := 'Obtener folio desde scfr_mov_transacciones_s';
        SELECT Scfr_Mov_Transacciones_s.Nextval INTO l_Scfr_Mov_Transacciones_s FROM Dual;
        UPDATE Scfr_Mov_Documentos_Txs
           SET Anulado          = 'S'
              ,Origen_Anulacion = l_Origen_Anulacion
              ,Procesado        = Nvl2(Procesado
                                      ,2
                                      ,Procesado)
         WHERE Txo_Correlativo_Tx = l_Trama_Vd.Secuencia_b
           AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
           AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
           AND Loc_Local = l_Trama_Vd.Local_Relacionado;
        UPDATE Scfr_Mov_Transacciones
           SET Txo_Correlativo_Tx_Relacionado = l_Trama_Vd.Correlativo_Tx
              ,Txo_Codigo_Tx_Relacionado      = l_Scfr_Mov_Transacciones_s
              ,Procesado                      = Nvl2(Procesado
                                                    ,2
                                                    ,Procesado)
         WHERE Correlativo_Tx = l_Trama_Vd.Secuencia_b
           AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
           AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
           AND Loc_Local = l_Trama_Vd.Local_Relacionado;
        -- CGC FIN 25/01/2013
      EXCEPTION
        WHEN OTHERS THEN
          l_Txo_Codigo_Tx_Relacionado := NULL;
          l_Fecha_Tx_Origen           := NULL;
      END;
      -- Registra Movimiento Reversa de Avance
      l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_TRANSACCIONES';
      INSERT INTO Scfr_Mov_Transacciones
        (Codigo_Tx
        ,Correlativo_Tx
        ,Tmo_Movimiento_Padre
        ,Fecha_Tx
        ,Estado_Registro
        ,Proceso_Dwh
        ,Numero_Maquina
        ,Emp_Empresa
        ,Cad_Cadena
        ,Loc_Local
        ,Pos_Tipo_Transaccion
        ,Pt_Party_Id_Titular
        ,Rut_Titular
        ,Dv_Titular
        ,Secuencia_Beneficiario
        ,Rut_Beneficiario
        ,Dv_Beneficiario
        ,Pt_Party_Id_Beneficiario
        ,Con_Numero_Convenio
        ,Pla_Numero_Plan
        ,Rut_Fidelizado
        ,Dv_Fidelizado
        ,Pt_Party_Id_Fidelizado
        ,Cot_Cotizacion
        ,Numero_Preventa
        ,Txo_Correlativo_Tx_Relacionado
        ,Txo_Codigo_Tx_Relacionado
        ,Loc_Local_Relacionado
        ,Codigo_Autorizacion_Tx
        ,Num_Service_Request
        ,Agente_Ddo
        ,Rut_Agente_Ddo
        ,Sec_Recaudacion
        ,Pin_Transaccion
        ,Rut_Retira
        ,Dv_Retira
        ,Nombre_Retira
        ,Cad_Cadena_Traspaso
        ,Loc_Local_Traspaso
        ,Canal
        ,Estx_Numero_Local
        ,Estx_Destino
        ,Estx_Sistema
        ,Estx_Funcion
        ,Estx_Secuencia
        ,Estx_Correlativo
        ,Estx_Numero_Trama
        ,Estx_Srv_Codigo
        ,Estx_Numero_Pos
        ,Estx_Fecha
        ,Estx_Codigo_Tx
        ,Numero_Tav
        ,Fecha_Inicio_Tx
        ,Fecha_Cierre_Tx
        ,Numero_Cuenta_Tarjeta
        ,Numero_Cuotas
        ,Fecha_Generacion_Registro)
      VALUES
        (l_Scfr_Mov_Transacciones_s
        ,l_Trama_Vd.Correlativo_Tx
        ,TRIM(l_Trama_Vd.Tipo_Movimiento_Padre)
        ,l_Fecha_Hora
        ,'VIG'
        ,0
        ,p_Transaccion.Trama_Pos.Numero_Pos
        ,p_Transaccion.Trama_Pos.Empresa
        ,p_Transaccion.Trama_Pos.Cadena
        ,l_Trama_Vd.Local_Relacionado
        ,NULL
        ,p_Transaccion.Trama_Boc.Party_Id
        ,p_Transaccion.Rut_Titular
        ,p_Transaccion.Dv_Rut_Titular
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,p_Transaccion.Rut_Titular
        ,p_Transaccion.Dv_Rut_Titular
        ,NULL
        ,NULL
        ,NULL
        ,l_Trama_Vd.Secuencia_b
        ,l_Txo_Codigo_Tx_Relacionado
        ,NULL
        ,TRIM(l_Trama_Vd.Codigo_Autorizacion)
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,'POS'
        ,l_Trama_Vd.Local
        ,l_Trama_Vd.Destino
        ,l_Trama_Vd.Sistema
        ,l_Trama_Vd.Funcion
        ,l_Trama_Vd.Secuencia_c
        ,l_Trama_Vd.Correlativo
        ,l_Trama_Vd.Numero_Trama
        ,l_Trama_Vd.Codigo_Servicio
        ,l_Trama_Vd.Numero_Pos
        ,To_Date(l_Trama_Vd.Fecha
                ,'yyyymmdd hh24:mi:ss')
        ,TRIM(l_Trama_Vd.Codigo_Transaccion)
        ,TRIM(p_Transaccion.Trama_Pos.Id_Maquina)
        ,To_Date(Decode(l_Trama_Vd.Fecha_Inicio_Tx
                       ,0
                       ,NULL
                       ,l_Trama_Vd.Fecha_Inicio_Tx)
                ,'yyyymmddhh24miss')
        ,To_Date(Decode(l_Trama_Vd.Fecha_Cierre_Tx
                       ,0
                       ,NULL
                       ,l_Trama_Vd.Fecha_Cierre_Tx)
                ,'yyyymmddhh24miss')
        ,l_Trama_Vd.Numero_Cuenta
        ,l_Trama_Vd.Numero_Cuotas
        ,Trunc(To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Proceso
                      ,'yyyymmddhh24miss')));
      l_Total_Gral  := 0;
      i             := 0;
      l_Dbg_Mensaje := 'Preparo transaccion Hijo ';
      WHILE i < l_Trama_Vd.Documentos_Emitidos
      LOOP
        i             := i + 1;
        l_Total_Gral  := l_Total_Gral + l_Trama_Vd.Subtrama_Vd1(i).Total_Iva_Incluido;
        l_Dbg_Mensaje := 'Obtengo numero de mov hijo ';
        SELECT Scfr_Mov_Documentos_Txs_s.Nextval INTO l_Scfr_Mov_Documentos_Txs_s FROM Dual;
        l_Dbg_Mensaje := 'Insert Hijo scfr_mov_documentos_txs ' || l_Scfr_Mov_Documentos_Txs_s || ' ' || i;
        INSERT INTO Scfr_Mov_Documentos_Txs
          (Mov_Documentos
          ,Txo_Codigo_Tx
          ,Txo_Correlativo_Tx
          ,Secuencia
          ,Tmo_Movimiento
          ,Dfi_Numero_Asignacion
          ,Monto
          ,Anulado
          ,Iva
          ,Folio
          ,Folio_Dicc
          ,Tipo_Dicc
          ,Estado_Movimiento_Caja
          ,Fecha_Regularizacion
          ,Numero_Pedido
          ,Pvr_Rut_Proveedor
          ,Pvr_Sucursal_Proveedor
          ,Folio_Reclamo_Canje
          ,Matricula_Bulto
          ,Sello_Seguro_Uno
          ,Sello_Seguro_Dos
          ,Facturado
          ,Periodo_Facturacion
          ,Puntos_Asignados
          ,Emp_Empresa
          ,Cad_Cadena
          ,Loc_Local
          ,Tipo_Distribucion
          ,Origen_Anulacion)
        VALUES
          (l_Scfr_Mov_Documentos_Txs_s
          ,l_Scfr_Mov_Transacciones_s
          ,l_Trama_Vd.Correlativo_Tx
          ,l_Trama_Vd.Subtrama_Vd1(i).Secuencia_b
          ,l_Trama_Vd.Subtrama_Vd1(i).Tipo_Movimiento_Hijo
          ,NULL
          ,l_Trama_Vd.Subtrama_Vd1(i).Total_Iva_Incluido * p_Multiplo
          ,l_Trama_Vd.Subtrama_Vd1(i).Anulado
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,p_Transaccion.Trama_Pos.Empresa
          ,p_Transaccion.Trama_Pos.Cadena
          ,p_Transaccion.Trama_Pos.Local
          ,NULL
          ,l_Origen_Anulacion);
      END LOOP;
      p_Transaccion.Codigo_Tx      := l_Scfr_Mov_Transacciones_s;
      p_Transaccion.Fecha_Tx       := To_Date(Ltrim(Rtrim(l_Trama_Vd.Fecha)) || Ltrim(Rtrim(To_Char(l_Trama_Vd.Hora_Venta
                                                                                                   ,'000009')))
                                             ,'yyyymmddhh24miss');
      p_Transaccion.Correlativo_Tx := l_Trama_Vd.Correlativo_Tx;
    ELSE
      RAISE l_Error_Controlado;
    END IF;
  EXCEPTION
    WHEN l_Error_Controlado THEN
      x_Cod_Error := 2000;
      x_Msg_Error := 'No encuentra movimiento Original';
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Trama_Vd_Resuelve_Act(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                 ,p_Multiplo    IN NUMBER
                                 ,x_Cod_Error   OUT NUMBER
                                 ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Vd                  Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vd;
    i                           NUMBER;
    l_Rut                       NUMBER;
    l_Dv                        VARCHAR2(1);
    l_Fecha_Hora                DATE;
    l_Rut_Personal              NUMBER;
    l_Dv_Rut_Personal           VARCHAR2(1);
    l_Scfr_Mov_Transacciones_s  NUMBER(15) := 0;
    l_Scfr_Mov_Documentos_Txs_s NUMBER(15) := 0;
    l_Mov_Pagos                 NUMBER;
    l_Codigo_Personal           NUMBER;
    l_Total_Gral                NUMBER;
    l_Resultado                 NUMBER;
    l_Dbg_Proceso               VARCHAR2(100);
    l_Dbg_Mensaje               VARCHAR2(250) := 'Error General';
    l_Error_Controlado          EXCEPTION;
  BEGIN
    l_Dbg_Proceso := 'SCFR_TRX_GNC_PK.' || 'trama_vd_resuelve_act';
    l_Dbg_Mensaje := 'Obtener informacion de la trama VD (Avances)';
    l_Trama_Vd    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Vd(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje := 'Preparo fechas';
    BEGIN
      l_Fecha_Hora := To_Date(Ltrim(Rtrim(To_Char(l_Trama_Vd.Fecha))) || Ltrim(Rtrim(To_Char(l_Trama_Vd.Hora_Venta
                                                                                            ,'000009')))
                             ,'yyyymmddhh24miss');
    EXCEPTION
      WHEN OTHERS THEN
        l_Fecha_Hora := Scfr_Trx_Util_Pk.Get_Sysdate();
    END;
    l_Dbg_Mensaje := 'Obtengo Rut';
    Scfr_Trx_Util_Pk.Obtiene_Rut(p_Transaccion.Trama_Boc.Party_Id
                                ,p_Transaccion.Rut_Titular
                                ,p_Transaccion.Dv_Rut_Titular);
    l_Dbg_Mensaje := 'Obtengo Rut nro Transac ' || l_Scfr_Mov_Transacciones_s;
    SELECT Scfr_Mov_Transacciones_s.Nextval INTO l_Scfr_Mov_Transacciones_s FROM Dual;
    l_Dbg_Mensaje := 'Insert Transaccion Padre ' || l_Scfr_Mov_Transacciones_s;
    INSERT INTO Scfr_Mov_Transacciones
      (Codigo_Tx
      ,Correlativo_Tx
      ,Tmo_Movimiento_Padre
      ,Fecha_Tx
      ,Estado_Registro
      ,Proceso_Dwh
      ,Numero_Maquina
      ,Emp_Empresa
      ,Cad_Cadena
      ,Loc_Local
      ,Pos_Tipo_Transaccion
      ,Pt_Party_Id_Titular
      ,Rut_Titular
      ,Dv_Titular
      ,Secuencia_Beneficiario
      ,Rut_Beneficiario
      ,Dv_Beneficiario
      ,Pt_Party_Id_Beneficiario
      ,Con_Numero_Convenio
      ,Pla_Numero_Plan
      ,Rut_Fidelizado
      ,Dv_Fidelizado
      ,Pt_Party_Id_Fidelizado
      ,Cot_Cotizacion
      ,Numero_Preventa
      ,Loc_Local_Relacionado
      ,Codigo_Autorizacion_Tx
      ,Num_Service_Request
      ,Agente_Ddo
      ,Rut_Agente_Ddo
      ,Sec_Recaudacion
      ,Pin_Transaccion
      ,Rut_Retira
      ,Dv_Retira
      ,Nombre_Retira
      ,Cad_Cadena_Traspaso
      ,Loc_Local_Traspaso
      ,Canal
      ,Estx_Numero_Local
      ,Estx_Destino
      ,Estx_Sistema
      ,Estx_Funcion
      ,Estx_Secuencia
      ,Estx_Correlativo
      ,Estx_Numero_Trama
      ,Estx_Srv_Codigo
      ,Estx_Numero_Pos
      ,Estx_Fecha
      ,Estx_Codigo_Tx
      ,Numero_Tav
      ,Fecha_Inicio_Tx
      ,Fecha_Cierre_Tx
      ,Numero_Cuenta_Tarjeta
      ,Numero_Cuotas
      ,Fecha_Generacion_Registro)
    VALUES
      (l_Scfr_Mov_Transacciones_s -- codigo_tx                         not null
      ,l_Trama_Vd.Correlativo_Tx -- correlativo_tx                    not null
      ,TRIM(l_Trama_Vd.Tipo_Movimiento_Padre) -- tmo_movimiento_padre              not null
      ,l_Fecha_Hora -- fecha_tx                          not null
      ,'VIG' -- estado_registro                   not null
      ,0 -- proceso_dwh                       not null
      ,p_Transaccion.Trama_Pos.Numero_Pos -- numero_maquina                    not null
      ,p_Transaccion.Trama_Pos.Empresa -- emp_empresa                       not null
      ,p_Transaccion.Trama_Pos.Cadena -- cad_cadena                        not null
      ,p_Transaccion.Trama_Pos.Local -- loc_local                         not null
      ,NULL -- pos_tipo_transaccion                  null
      ,p_Transaccion.Trama_Boc.Party_Id -- pt_party_id_titular                   null
      ,p_Transaccion.Rut_Titular -- rut_titular                           null
      ,p_Transaccion.Dv_Rut_Titular -- dv_titular                            null
      ,NULL -- secuencia_beneficiario                null
      ,NULL -- rut_beneficiario                      null
      ,NULL -- dv_beneficiario                       null
      ,NULL -- pt_party_id_beneficiario              null
      ,NULL -- con_numero_convenio                   null
      ,NULL -- pla_numero_plan                       null
      ,p_Transaccion.Rut_Titular -- rut_fidelizado                        null
      ,p_Transaccion.Dv_Rut_Titular -- dv_fidelizado                         null
      ,NULL -- pt_party_id_fidelizado                null
      ,NULL -- cot_cotizacion                        null
      ,NULL -- numero_preventa                       null
      ,NULL -- loc_local_relacionado                 null
      ,TRIM(l_Trama_Vd.Codigo_Autorizacion) -- autorizacion_cnv_tx                   null
      ,NULL -- num_service_request                   null
      ,NULL -- agente_ddo                            null
      ,NULL -- rut_agente_ddo                        null
      ,NULL -- sec_recaudacion                       null
      ,NULL -- pin_transaccion                       null
      ,NULL -- rut_retira                            null
      ,NULL -- dv_retira                             null
      ,NULL -- nombre_retira                         null
      ,NULL -- cad_cadena_traspaso                   null
      ,NULL -- loc_local_traspaso                    null
      ,'POS' -- canal                                 null
      ,l_Trama_Vd.Local -- estx_numero_local                     null
      ,l_Trama_Vd.Destino
      ,l_Trama_Vd.Sistema
      ,l_Trama_Vd.Funcion
      ,l_Trama_Vd.Secuencia_c
      ,l_Trama_Vd.Correlativo
      ,l_Trama_Vd.Numero_Trama
      ,l_Trama_Vd.Codigo_Servicio
      ,l_Trama_Vd.Numero_Pos
      ,To_Date(l_Trama_Vd.Fecha
              ,'yyyymmdd hh24:mi:ss')
      ,TRIM(l_Trama_Vd.Codigo_Transaccion)
      ,TRIM(p_Transaccion.Trama_Pos.Id_Maquina)
      ,To_Date(Decode(l_Trama_Vd.Fecha_Inicio_Tx
                     ,0
                     ,NULL
                     ,l_Trama_Vd.Fecha_Inicio_Tx)
              ,'yyyymmddhh24miss')
      ,To_Date(Decode(l_Trama_Vd.Fecha_Cierre_Tx
                     ,0
                     ,NULL
                     ,l_Trama_Vd.Fecha_Cierre_Tx)
              ,'yyyymmddhh24miss')
      ,l_Trama_Vd.Numero_Cuenta
      ,l_Trama_Vd.Numero_Cuotas
      ,Trunc(To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Proceso
                    ,'yyyymmddhh24miss')));
    l_Total_Gral  := 0;
    i             := 0;
    l_Dbg_Mensaje := 'Preparo transaccion Hijo ';
    WHILE i < l_Trama_Vd.Documentos_Emitidos
    LOOP
      i             := i + 1;
      l_Total_Gral  := l_Total_Gral + l_Trama_Vd.Subtrama_Vd1(i).Total_Iva_Incluido;
      l_Dbg_Mensaje := 'Obtengo numero de mov hijo ';
      SELECT Scfr_Mov_Documentos_Txs_s.Nextval INTO l_Scfr_Mov_Documentos_Txs_s FROM Dual;
      l_Dbg_Mensaje := 'Insert Hijo scfr_mov_documentos_txs ' || l_Scfr_Mov_Documentos_Txs_s || ' ' || i;
      INSERT INTO Scfr_Mov_Documentos_Txs
        (Mov_Documentos
        ,Txo_Codigo_Tx
        ,Txo_Correlativo_Tx
        ,Secuencia
        ,Tmo_Movimiento
        ,Dfi_Numero_Asignacion
        ,Monto
        ,Anulado
        ,Iva
        ,Folio
        ,Folio_Dicc
        ,Tipo_Dicc
        ,Estado_Movimiento_Caja
        ,Fecha_Regularizacion
        ,Numero_Pedido
        ,Pvr_Rut_Proveedor
        ,Pvr_Sucursal_Proveedor
        ,Folio_Reclamo_Canje
        ,Matricula_Bulto
        ,Sello_Seguro_Uno
        ,Sello_Seguro_Dos
        ,Facturado
        ,Periodo_Facturacion
        ,Puntos_Asignados
        ,Emp_Empresa
        ,Cad_Cadena
        ,Loc_Local
        ,Tipo_Distribucion)
      VALUES
        (l_Scfr_Mov_Documentos_Txs_s -- mov_documentos                    not null
        ,l_Scfr_Mov_Transacciones_s -- txo_codigo_tx                     not null
        ,l_Trama_Vd.Correlativo_Tx -- txo_correlativo_tx                not null
        ,l_Trama_Vd.Subtrama_Vd1(i).Secuencia_b -- secuencia                         not null
        ,l_Trama_Vd.Subtrama_Vd1(i).Tipo_Movimiento_Hijo -- tmo_movimiento                    not null
        ,NULL -- dfi_numero_asignacion                 null
        ,l_Trama_Vd.Subtrama_Vd1(i).Total_Iva_Incluido * p_Multiplo -- monto                             not null
        ,l_Trama_Vd.Subtrama_Vd1(i).Anulado -- anulado                           not null
        ,NULL -- iva                                   null
        ,NULL -- folio                                 null
        ,NULL -- folio_dicc                            null
        ,NULL -- tipo_dicc                             null
        ,NULL -- estado_movimiento_caja                null
        ,NULL -- fecha_regularizacion                  null
        ,NULL -- numero_pedido                         null
        ,NULL -- pvr_rut_proveedor                     null
        ,NULL -- pvr_sucursal_proveedor                null
        ,NULL -- folio_reclamo_canje                   null
        ,NULL -- matricula_bulto                       null
        ,NULL -- sello_seguro_uno                      null
        ,NULL -- sello_seguro_dos                      null
        ,NULL -- facturado                             null
        ,NULL -- periodo_facturacion                   null
        ,NULL -- puntos_asignados                      null
        ,p_Transaccion.Trama_Pos.Empresa -- emp_empresa                       not null
        ,p_Transaccion.Trama_Pos.Cadena -- cad_cadena                        not null
        ,p_Transaccion.Trama_Pos.Local -- loc_local                             null
        ,NULL -- tipo_distribucion                     null
         );
    END LOOP;
    p_Transaccion.Codigo_Tx      := l_Scfr_Mov_Transacciones_s;
    p_Transaccion.Fecha_Tx       := To_Date(Ltrim(Rtrim(l_Trama_Vd.Fecha)) || Ltrim(Rtrim(To_Char(l_Trama_Vd.Hora_Venta
                                                                                                 ,'000009')))
                                           ,'yyyymmddhh24miss');
    p_Transaccion.Correlativo_Tx := l_Trama_Vd.Correlativo_Tx;
  EXCEPTION
    WHEN l_Error_Controlado THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  FUNCTION Trama_Vd_Prepara(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Fecha       OUT DATE
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vd IS
    l_Trama_Vc    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vc;
    l_Trama_Vd    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vd;
    l_Transaccion Pkg_Com_Transacciones_Locales.Refcursor;
    l_Codigo_Tx   NUMBER;
    CURSOR c_Documentos IS
      SELECT Secuencia
            ,Tmo_Movimiento Tipo_Mov_Hijo
            ,Nvl(Anulado
                ,' ') Anulado
            ,Nvl(Monto
                ,0) + Nvl(Iva
                         ,0) Total
        FROM Scfr_Mov_Documentos_Txs
       WHERE Txo_Codigo_Tx = p_Transaccion.Codigo_Tx
       ORDER BY Secuencia;
    r                    c_Documentos%ROWTYPE;
    i                    NUMBER;
    x                    NUMBER;
    l_Version_Primaria   NUMBER;
    l_Version_Secundaria NUMBER;
    l_Nulos              VARCHAR2(100);
    l_Rut_Tit            VARCHAR2(10);
    l_Fecha_Date         DATE;
    l_Salida1            BLOB;
    l_Salida2            BLOB;
    l_Salida3            BLOB;
    l_Salida4            BLOB;
    l_Aux_Dato           BLOB;
    l_Largo_To           NUMBER;
    l_Folio_Fiscal       NUMBER := NULL;
    l_Resultado          NUMBER;
    l_Cantidad_Registros NUMBER;
    l_Largo_Buffers      NUMBER;
    l_Tx_Timestamp       TIMESTAMP;
    l_Rx_Timestamp       TIMESTAMP;
    l_Tx_Pos             BLOB;
    l_Rx_Pos             BLOB;
    l_Dbg_Proceso        VARCHAR2(100) := 'SCFR_TRX_GNC_PK.GNCC04';
    l_Dbg_Mensaje        VARCHAR2(250) := 'Error General';
    l_Error_Contralado   EXCEPTION;
  BEGIN
    --********************************************************************
    --           Consulta de avances
    --********************************************************************
    l_Dbg_Mensaje := 'Obtener Antecedentes transaccion padre   Trama vd';
    l_Trama_Vc    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Vc(p_Transaccion.Cuerpo_Tx);
    SELECT Correlativo_Tx
          ,Tmo_Movimiento_Padre
          ,To_Number(To_Char(Fecha_Tx
                            ,'yyyymmdd'))
          ,To_Number(To_Char(Fecha_Tx
                            ,'hh24miss'))
          ,1
          ,Numero_Cuenta_Tarjeta
          ,Numero_Cuotas
          ,Codigo_Autorizacion_Tx
          ,Estx_Srv_Codigo
          ,Estx_Numero_Local
          ,Loc_Local
          ,Estx_Numero_Pos
          ,Estx_Destino
          ,Estx_Sistema
          ,Estx_Funcion
          ,Estx_Secuencia
          ,To_Number(To_Char(Estx_Fecha
                            ,'yyyymmddhh24miss'))
          ,Estx_Correlativo
          ,Estx_Numero_Trama
          ,Estx_Codigo_Tx
          ,Estx_Fecha
          ,Codigo_Tx
          ,Rut_Titular || Dv_Titular
      INTO l_Trama_Vd.Correlativo_Tx
          ,l_Trama_Vd.Tipo_Movimiento_Padre
          ,l_Trama_Vd.Fecha
          ,l_Trama_Vd.Hora_Venta
          ,l_Trama_Vd.Secuencia_b
          ,l_Trama_Vd.Numero_Cuenta
          ,l_Trama_Vd.Numero_Cuotas
          ,l_Trama_Vd.Codigo_Autorizacion
          ,l_Trama_Vd.Codigo_Servicio
          ,l_Trama_Vd.Local
          ,l_Trama_Vd.Local_Relacionado
          ,l_Trama_Vd.Numero_Pos
          ,l_Trama_Vd.Destino
          ,l_Trama_Vd.Sistema
          ,l_Trama_Vd.Funcion
          ,l_Trama_Vd.Secuencia_c
          ,l_Trama_Vd.Fecha_Transaccion
          ,l_Trama_Vd.Correlativo
          ,l_Trama_Vd.Numero_Trama
          ,l_Trama_Vd.Codigo_Transaccion
          ,l_Fecha_Date
          ,p_Transaccion.Codigo_Tx
          ,l_Rut_Tit
      FROM Scfr_Mov_Transacciones
     WHERE Correlativo_Tx = l_Trama_Vc.Correlativo_Tx
       AND Loc_Local = l_Trama_Vc.Local
       AND Tmo_Movimiento_Padre = 'AVANCE';
    p_Transaccion.Trama_Boc.Forma_Identificacion  := 'R';
    p_Transaccion.Trama_Boc.String_Identificacion := l_Rut_Tit;
    x_Fecha                                       := l_Fecha_Date;
    i                                             := 0;
    l_Salida1                                     := NULL;
    OPEN c_Documentos;
    FETCH c_Documentos
      INTO r;
    WHILE c_Documentos%FOUND
    LOOP
      i := i + 1;
      l_Dbg_Mensaje := 'Generando trama vd1 ' || i;
      l_Trama_Vd.Subtrama_Vd1(i).Secuencia_b := r.Secuencia;
      l_Trama_Vd.Subtrama_Vd1(i).Tipo_Movimiento_Hijo := r.Tipo_Mov_Hijo;
      l_Trama_Vd.Subtrama_Vd1(i).Anulado := r.Anulado;
      l_Trama_Vd.Subtrama_Vd1(i).Total_Iva_Incluido := r.Total;
      FETCH c_Documentos
        INTO r;
    END LOOP;
    l_Trama_Vd.Documentos_Emitidos := i;
    CLOSE c_Documentos;
    l_Dbg_Mensaje := 'Preparo la salida trama VD y VD1 ';
    RETURN l_Trama_Vd;
  EXCEPTION
    WHEN l_Error_Contralado THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      RETURN(NULL);
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
      RETURN(NULL);
  END;

  PROCEDURE Trama_Rx_Tx_Prepara(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                               ,x_Trama_Vd    IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vd
                               ,x_Fecha       IN DATE
                               ,x_Trama_Tx    OUT Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tx
                               ,x_Trama_Rx    OUT Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rx
                               ,x_Cod_Error   OUT NUMBER
                               ,x_Msg_Error   OUT VARCHAR2) IS
    l_Transaccion        Pkg_Com_Transacciones_Locales.Refcursor;
    l_Codigo_Tx          NUMBER;
    i                    NUMBER;
    x                    NUMBER;
    l_Version_Primaria   NUMBER;
    l_Version_Secundaria NUMBER;
    l_Nulos              VARCHAR2(100);
    l_Tx_Timestamp       TIMESTAMP;
    l_Rx_Timestamp       TIMESTAMP;
    l_Tx_Pos             BLOB;
    l_Rx_Pos             BLOB;
    l_Trama_Tx           Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tx;
    l_Trama_Rx           Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rx;
    l_Dbg_Proceso        VARCHAR2(100) := 'SCFR_TRX_GNC_PK.GNCC04';
    l_Dbg_Mensaje        VARCHAR2(250) := 'Error General';
    l_Error_Controlado   EXCEPTION;
  BEGIN
    IF x_Trama_Vd.Codigo_Servicio = 'BOC' THEN
      Pkg_Com_Transacciones_Clientes.Obtener_Transaccion(x_Trama_Vd.Codigo_Servicio
                                                        ,x_Trama_Vd.Local
                                                        ,x_Trama_Vd.Numero_Pos
                                                        ,x_Trama_Vd.Destino
                                                        ,x_Trama_Vd.Sistema
                                                        ,x_Trama_Vd.Funcion
                                                        ,x_Trama_Vd.Secuencia_b
                                                        ,x_Fecha
                                                        ,x_Trama_Vd.Codigo_Transaccion
                                                        ,x_Trama_Vd.Numero_Trama
                                                        ,l_Transaccion
                                                        ,x_Cod_Error
                                                        ,x_Msg_Error);
    ELSE
      Pkg_Com_Transacciones_Clientes.Obtener_Transaccion(x_Trama_Vd.Codigo_Servicio
                                                        ,x_Trama_Vd.Local
                                                        ,x_Trama_Vd.Numero_Pos
                                                        ,x_Trama_Vd.Funcion
                                                        ,x_Fecha
                                                        ,x_Trama_Vd.Codigo_Transaccion
                                                        ,l_Transaccion
                                                        ,x_Cod_Error
                                                        ,x_Msg_Error);
    END IF;
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      RAISE l_Error_Controlado;
    END IF;
    IF l_Transaccion%ROWCOUNT > 0 AND
       Nvl(x_Cod_Error
          ,0) = 0 THEN
      i := 0;
      LOOP
        i             := i + 1;
        l_Dbg_Mensaje := 'Muevo Transaccion TX ' || i;
        FETCH l_Transaccion
          INTO l_Version_Primaria
              ,l_Version_Secundaria
              ,l_Tx_Timestamp
              ,l_Rx_Timestamp
              ,l_Tx_Pos
              ,l_Rx_Pos
              ,l_Trama_Tx          (i).Tx_Respuesta
              ,l_Trama_Tx          (i).Tx_No_Enrutada
              ,l_Trama_Tx          (i).Tx_No_Existe
              ,l_Trama_Tx          (i).Tx_Timeout
              ,l_Trama_Tx          (i).Tx_Erronea
              ,l_Trama_Tx          (i).Tx_Expirada
              ,l_Trama_Tx          (i).Tx_Online
              ,l_Trama_Tx          (i).Tx_Confirmada
              ,l_Nulos
              ,l_Trama_Rx          (i).Rx_Ack
              ,l_Trama_Rx          (i).Rx_Nack
              ,l_Trama_Rx          (i).Rx_Timeout
              ,l_Trama_Rx          (i).Rx_Erronea
              ,l_Trama_Rx          (i).Rx_Con_Servicio
              ,l_Trama_Rx          (i).Rx_Sin_Servicio;
        l_Trama_Tx(i).Codigo_Servicio := x_Trama_Vd.Codigo_Servicio;
        l_Trama_Tx(i).Timespan := To_Number(To_Char(l_Tx_Timestamp
                                                   ,'yyyymmdd'));
        l_Trama_Rx(i).Timespan := To_Number(To_Char(l_Rx_Timestamp
                                                   ,'yyyymmdd'));
        l_Trama_Tx(i).Tx := Scfr_Trx_Util_Pk.Bin2num(l_Tx_Pos);
        l_Trama_Rx(i).Rx := Scfr_Trx_Util_Pk.Bin2num(l_Rx_Pos);
        EXIT WHEN l_Transaccion%NOTFOUND;
      END LOOP;
      x_Trama_Tx := l_Trama_Tx;
      x_Trama_Rx := l_Trama_Rx;
    END IF;
  EXCEPTION
    WHEN l_Error_Controlado THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  FUNCTION Trama_Hc_Prepara(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Hc IS
    CURSOR c_Historial_Compra(p_Party_Id IN NUMBER) IS
      SELECT /*+ RULE */
       Mopt.Pro_Codigo_Interno Codigo_Interno
      ,To_Char(Motr.Fecha_Tx
              ,'yyyymmdd') Fecha_Tx
      ,SUM(Mopt.Cantidad) Cantidad
      ,Mopt.Consejo_Aplicado Consejo
        FROM Scfr_Mov_Transacciones Motr
            ,Scfr_Mov_Productos_Txs Mopt
       WHERE Motr.Codigo_Tx = Mopt.Txo_Codigo_Tx
         AND Motr.Codigo_Tx > 0 -- sirve para que tome el indice de la tabla SCFR_MOV_TRANSACCIONES
         AND Motr.Pt_Party_Id_Titular = p_Party_Id
         AND Motr.Fecha_Tx BETWEEN Add_Months(Scfr_Trx_Util_Pk.Get_Sysdate()
                                             ,-1 * Scfr_Trx_Util_Pk.Det_Valor_Parametro_Por_Cod('NMBUHI')) AND Scfr_Trx_Util_Pk.Get_Sysdate()
       GROUP BY Mopt.Pro_Codigo_Interno
               ,To_Char(Motr.Fecha_Tx
                       ,'yyyymmdd')
               ,Mopt.Consejo_Aplicado
      HAVING SUM(Mopt.Cantidad) > 0
       ORDER BY Fecha_Tx DESC;
    l_Trama_Hc Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Hc;
    l_Itm      NUMBER;
    l_Max_Hist NUMBER;
  BEGIN
    -- Obtiene el maximo numero de registros a obtener como historia
    l_Max_Hist := Scfr_Trx_Util_Pk.Det_Valor_Parametro_Por_Cod('NMHICO');
    l_Itm      := 0;
    FOR r_Historia IN c_Historial_Compra(p_Transaccion.Trama_Boc.Party_Id)
    LOOP
      l_Itm := l_Itm + 1;
      l_Trama_Hc(l_Itm).Codigo_Producto_Interno := r_Historia.Codigo_Interno;
      l_Trama_Hc(l_Itm).Fecha := r_Historia.Fecha_Tx;
      l_Trama_Hc(l_Itm).Cantidad := r_Historia.Cantidad;
      l_Trama_Hc(l_Itm).Numero_Consejo := r_Historia.Consejo;
      IF l_Itm = l_Max_Hist THEN
        EXIT;
      END IF;
    END LOOP;
    RETURN l_Trama_Hc;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_Trama_Hc;
  END;

  /*PROCEDURE trama_pv_resuelve(p_transaccion IN OUT scfr_trx_dyn_pk.rec_transaccion, x_cod_error OUT NUMBER, x_msg_error OUT VARCHAR2) IS
    l_itm NUMBER;
    l_trama_pv scfr_trx_dyn_types_pk.tab_trama_pv;
    l_dbg_proceso VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_pv_resuelve';
    l_dbg_mensaje VARCHAR2(250) := 'Error General';
    l_error_contralado EXCEPTION;
    l_txo_codigo_tx_relacionado NUMBER;
  BEGIN
    -- registra detalle de copagos recaudados.
    l_dbg_mensaje := 'Obtener detalle de la trama Trama PV';
    l_trama_pv := scfr_trx_dyn_utl_pk.carga_trama_pv(p_transaccion.cuerpo_tx);
    FOR l_itm IN 1 .. l_trama_pv.COUNT LOOP
      l_dbg_mensaje := 'Inserta transaccion';
      INSERT INTO scfr_periodos_autorizados
        (id_periodo,
         fecha_inicio,
         fecha_termino,
         monto_copago,
         folio_copago,
         pagado,
         txo_codigo_tx)
      VALUES
        (l_trama_pv(l_itm).id_periodo,
         to_date(l_trama_pv(l_itm).fecha_inicio, 'yyyy/mm/dd'),
         to_date(l_trama_pv(l_itm).fecha_termino, 'yyyy/mm/dd'),
         l_trama_pv(l_itm).monto_copago,
         l_trama_pv(l_itm).folio_copago,
         l_trama_pv(l_itm).periodo_pagado,
         p_transaccion.codigo_tx);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      scfr_trx_util_pk.error_msg(l_dbg_proceso, l_dbg_mensaje);
      x_cod_error := SQLCODE;
      x_msg_error := SQLERRM;
  END;*/
  PROCEDURE Trama_Pe_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Pe         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pe;
    l_Trama_Cv         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv;
    l_Itm              NUMBER;
    l_Dbg_Proceso      VARCHAR2(100);
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    l_Local            VARCHAR2(10);
    l_Fecha_Inicio     DATE;
    l_Fecha_Termino    DATE;
    l_Party_Paciente   NUMBER;
  BEGIN
    l_Dbg_Proceso := 'SCFR_TRX_GNC_PK.trama_pe_resuelve';
    l_Dbg_Mensaje := 'Obtener trama PE (Periodos autorizados)';
    l_Trama_Pe    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Pe(p_Transaccion.Cuerpo_Tx);
    l_Trama_Cv    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Cv(p_Transaccion.Cuerpo_Tx);
    /* Para controlar cuando mandan encabezado de trama CV con 0 registros */
    IF l_Trama_Cv.Count = 0 THEN
      l_Trama_Cv(1).Convenio := NULL;
      l_Trama_Cv(1).Plan := NULL;
      l_Trama_Cv(1).Codigo_Autorizacion := NULL;
    END IF;
    l_Party_Paciente := Scfr_Trx_Gnc_Utl_Pk.Obtiene_Party_Paciente(Scfr_Conv_Pk.Entrega_Codigo_Empresa(p_Transaccion.Trama_Pos.Empresa)
                                                                  ,l_Trama_Cv(1).Codigo_Autorizacion);
    FOR l_Itm IN 1 .. l_Trama_Pe.Count
    LOOP
      IF l_Trama_Pe(l_Itm).Fecha_Inicio = 0 THEN
        SELECT Fecha_Inicio
          INTO l_Fecha_Inicio
          FROM Scfr_Periodos
         WHERE Emp_Codigo = Scfr_Conv_Pk.Entrega_Codigo_Empresa(p_Transaccion.Trama_Pos.Empresa)
           AND Con_Numero_Convenio = l_Trama_Cv(1).Convenio
           AND Pla_Numero_Plan = l_Trama_Cv(1).Plan
           AND Pt_Party_Id = l_Party_Paciente
           AND Id_Periodo = l_Trama_Pe(l_Itm).Id_Periodo;
        --   l_fecha_inicio := null;
      ELSE
        l_Fecha_Inicio := To_Date(l_Trama_Pe(l_Itm).Fecha_Inicio
                                 ,'YYYY/MM/DD');
      END IF;
      IF l_Trama_Pe(l_Itm).Fecha_Termino = 0 THEN
        SELECT Fecha_Termino
          INTO l_Fecha_Termino
          FROM Scfr_Periodos
         WHERE Emp_Codigo = Scfr_Conv_Pk.Entrega_Codigo_Empresa(p_Transaccion.Trama_Pos.Empresa)
           AND Con_Numero_Convenio = l_Trama_Cv(1).Convenio
           AND Pla_Numero_Plan = l_Trama_Cv(1).Plan
           AND Pt_Party_Id = l_Party_Paciente
           AND Id_Periodo = l_Trama_Pe(l_Itm).Id_Periodo;
        --  l_fecha_termino := null;
      ELSE
        l_Fecha_Termino := To_Date(l_Trama_Pe(l_Itm).Fecha_Termino
                                  ,'YYYY/MM/DD');
      END IF;
      l_Dbg_Mensaje := 'Insertar en SCFR_MOV_RECAUDACION_COPAGOS';
      INSERT INTO Scfr_Mov_Recaudacion_Copagos
        (Id_Periodo
        ,Txo_Codigo_Tx
        ,Txo_Correlativo_Tx
        ,Fecha_Inicio
        ,Fecha_Termino
        ,Monto_Copago
        ,Empresa
        ,Cadena
        ,Loc_Local)
      VALUES
        (l_Trama_Pe(l_Itm).Id_Periodo
        ,p_Transaccion.Codigo_Tx
        ,p_Transaccion.Correlativo_Tx
        ,l_Fecha_Inicio
        ,l_Fecha_Termino
        ,l_Trama_Pe(l_Itm).Monto_Copago
        ,p_Transaccion.Trama_Pos.Empresa
        ,p_Transaccion.Trama_Pos.Cadena
        ,p_Transaccion.Trama_Pos.Local);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Trama_Mc_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cierre_Dep  OUT NUMBER
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Mc         Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Mc;
    l_Itm              NUMBER;
    l_Fecha_Hora       DATE;
    l_Mov_Documentos   NUMBER;
    l_Mov_Pagos        NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_mc_resuelve';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    l_Signo            NUMBER;
    l_Idem_Titular     NUMBER;
  BEGIN
    x_Cod_Error  := 0;
    x_Cierre_Dep := 0;
    -- Obtiene informacion de la trama MC
    l_Dbg_Mensaje := 'Obtener informacion de la trama MC';
    l_Trama_Mc    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Mc(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje := 'Preparo fechas';
    BEGIN
      l_Fecha_Hora := To_Date(Ltrim(Rtrim(To_Char(l_Trama_Mc.Fecha))) || Ltrim(Rtrim(To_Char(l_Trama_Mc.Hora
                                                                                            ,'000009')))
                             ,'yyyymmddhh24miss');
    EXCEPTION
      WHEN OTHERS THEN
        l_Fecha_Hora := Scfr_Trx_Util_Pk.Get_Sysdate();
    END;
    BEGIN
      l_Idem_Titular := To_Number(Substr(TRIM(l_Trama_Mc.Identi_Titular)
                                        ,2
                                        ,Length(TRIM(l_Trama_Mc.Identi_Titular))));
    EXCEPTION
      WHEN OTHERS THEN
        l_Idem_Titular := 0;
    END;
    l_Dbg_Mensaje := 'Obtener secuencia para SCFR_MOV_TRANSACCIONES';
    SELECT Scfr_Mov_Transacciones_s.Nextval INTO p_Transaccion.Codigo_Tx FROM Dual;
    -- Insertar en SCFR_MOV_TRANSACCIONES
    l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_TRANSACCIONES';
    INSERT INTO Scfr_Mov_Transacciones
      (Codigo_Tx
      ,Correlativo_Tx
      ,Tmo_Movimiento_Padre
      ,Fecha_Tx
      ,Fecha_Generacion_Registro
      ,Tipo_Identi_Titular
      ,Identi_Titular
      ,Rut_Titular
      ,Dv_Titular
      ,Estado_Registro
      ,Numero_Maquina
      ,Emp_Empresa
      ,Cad_Cadena
      ,Loc_Local
      ,Canal
      ,Reg_Electronico
      ,Txo_Correlativo_Tx_Relacionado
      ,Remesas_Depositadas
      ,Monto_No_Depositado
      ,Remesas_No_Depositadas)
    VALUES
      (p_Transaccion.Codigo_Tx
      ,l_Trama_Mc.Correlativo
      ,TRIM(l_Trama_Mc.Tipo_Movimiento_Padre)
      ,l_Fecha_Hora
      ,Trunc(To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Proceso
                    ,'yyyymmddhh24miss'))
      ,Substr(TRIM(l_Trama_Mc.Identi_Titular)
             ,1
             ,1)
      ,Substr(TRIM(l_Trama_Mc.Identi_Titular)
             ,2
             ,Length(TRIM(l_Trama_Mc.Identi_Titular)))
      ,l_Idem_Titular
      ,NULL
      ,'VIG'
      ,p_Transaccion.Trama_Pos.Numero_Pos
      ,p_Transaccion.Trama_Pos.Empresa
      ,p_Transaccion.Trama_Pos.Cadena
      ,p_Transaccion.Trama_Pos.Local
      ,'POS'
      ,Nvl(l_Trama_Mc.Registro_Electronico
          ,'NO')
      ,Decode(l_Trama_Mc.Correlativo_Tx
             ,0
             ,NULL
             ,l_Trama_Mc.Correlativo_Tx)
      ,l_Trama_Mc.Cant_Remesas_Depo
      ,l_Trama_Mc.Monto_No_Depositado
      ,l_Trama_Mc.Cant_Remesas_No_Depo);
  
    -- Recorre cantidad documentos
    l_Dbg_Mensaje := 'Recorrer documentos (MC1)';
    FOR l_Itm IN 1 .. l_Trama_Mc.Subtrama_Mc1.Count
    LOOP
      l_Dbg_Mensaje := 'Obtener secuencia para SCFR_MOV_DOCUMENTOS_TXS';
      SELECT Scfr_Mov_Documentos_Txs_s.Nextval INTO l_Mov_Documentos FROM Dual;
      -- Insertar en SCFR_MOV_DOCUMENTOS_TXS
      l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_DOCUMENTOS_TXS';
      IF l_Trama_Mc.Subtrama_Mc1(l_Itm).Tipo_Movimiento = 'CIEFMA' THEN
        l_Signo := -1;
      ELSIF l_Trama_Mc.Subtrama_Mc1(l_Itm).Tipo_Movimiento = 'CIEFME' THEN
        l_Signo := -1;
      ELSIF l_Trama_Mc.Subtrama_Mc1(l_Itm).Tipo_Movimiento = 'CAJRBC' THEN
        l_Signo := -1;
      ELSE
        l_Signo := 1;
      END IF;
      INSERT INTO Scfr_Mov_Documentos_Txs
        (Mov_Documentos
        ,Txo_Codigo_Tx
        ,Txo_Correlativo_Tx
        ,Secuencia
        ,Tmo_Movimiento
        ,Monto
        ,Folio
        ,Anulado
        ,Estado_Movimiento_Caja
        ,Emp_Empresa
        ,Cad_Cadena
        ,Loc_Local
        ,Fecha_Regularizacion)
      VALUES
        (l_Mov_Documentos
        ,p_Transaccion.Codigo_Tx
        ,l_Trama_Mc.Correlativo
        ,l_Trama_Mc.Subtrama_Mc1(l_Itm).Secuencia
        ,l_Trama_Mc.Subtrama_Mc1(l_Itm).Tipo_Movimiento
        ,l_Trama_Mc.Subtrama_Mc1(l_Itm).Monto * l_Signo
        ,l_Trama_Mc.Subtrama_Mc1(l_Itm).Folio
        ,l_Trama_Mc.Subtrama_Mc1(l_Itm).Anulado
        ,l_Trama_Mc.Subtrama_Mc1(l_Itm).Estado
        ,p_Transaccion.Trama_Pos.Empresa
        ,p_Transaccion.Trama_Pos.Cadena
        ,p_Transaccion.Trama_Pos.Local
        ,Decode(l_Trama_Mc.Subtrama_Mc1(l_Itm).Fecha_Regularizacion
               ,0
               ,NULL
               ,-1
               ,NULL
               ,To_Date(l_Trama_Mc.Subtrama_Mc1(l_Itm).Fecha_Regularizacion
                       ,'yyyymmdd')));
      IF l_Trama_Mc.Subtrama_Mc1(l_Itm).Tipo_Movimiento = 'CIEDEP' THEN
        x_Cierre_Dep := x_Cierre_Dep + 1;
      END IF;
    END LOOP;
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Trama MC resuelta correctamente');
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  PROCEDURE Trama_Mc_Reversa(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                            ,x_Cod_Error   OUT NUMBER
                            ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Mc         Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Mc;
    l_Itm              NUMBER;
    l_Fecha_Hora       DATE;
    l_Mov_Documentos   NUMBER;
    l_Mov_Pagos        NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_mc_resuelve';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    l_Signo            NUMBER;
  BEGIN
    x_Cod_Error := 0;
    -- Obtiene informacion de la trama MC
    l_Dbg_Mensaje := 'Obtener informacion de la trama MC';
    l_Trama_Mc    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Mc(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje := 'Preparo fechas';
    BEGIN
      l_Fecha_Hora := To_Date(Ltrim(Rtrim(To_Char(l_Trama_Mc.Fecha))) || Ltrim(Rtrim(To_Char(l_Trama_Mc.Hora
                                                                                            ,'000009')))
                             ,'yyyymmddhh24miss');
    EXCEPTION
      WHEN OTHERS THEN
        l_Fecha_Hora := Scfr_Trx_Util_Pk.Get_Sysdate();
    END;
    l_Dbg_Mensaje := 'Obtener secuencia para SCFR_MOV_TRANSACCIONES';
    SELECT Scfr_Mov_Transacciones_s.Nextval INTO p_Transaccion.Codigo_Tx FROM Dual;
    -- Insertar en SCFR_MOV_TRANSACCIONES
    l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_TRANSACCIONES';
    INSERT INTO Scfr_Mov_Transacciones
      (Codigo_Tx
      ,Correlativo_Tx
      ,Tmo_Movimiento_Padre
      ,Fecha_Tx
      ,Fecha_Generacion_Registro
      ,Rut_Titular
      ,Dv_Titular
      ,Estado_Registro
      ,Numero_Maquina
      ,Emp_Empresa
      ,Cad_Cadena
      ,Loc_Local
      ,Canal
      ,Reg_Electronico
      ,Txo_Correlativo_Tx_Relacionado)
    VALUES
      (p_Transaccion.Codigo_Tx
      ,l_Trama_Mc.Correlativo
      ,TRIM(l_Trama_Mc.Tipo_Movimiento_Padre)
      ,l_Fecha_Hora
      ,Trunc(To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Proceso
                    ,'yyyymmddhh24miss'))
      ,l_Trama_Mc.Rut_Titular
      ,l_Trama_Mc.Dv_Titular
      ,'VIG'
      ,p_Transaccion.Trama_Pos.Numero_Pos
      ,p_Transaccion.Trama_Pos.Empresa
      ,p_Transaccion.Trama_Pos.Cadena
      ,p_Transaccion.Trama_Pos.Local
      ,'POS'
      ,Nvl(l_Trama_Mc.Registro_Electronico
          ,'NO')
      ,Decode(l_Trama_Mc.Correlativo_Tx
             ,0
             ,NULL
             ,l_Trama_Mc.Correlativo_Tx));
    -- Recorre cantidad documentos
    l_Dbg_Mensaje := 'Recorrer documentos (MC1)';
    FOR l_Itm IN 1 .. l_Trama_Mc.Subtrama_Mc1.Count
    LOOP
      l_Dbg_Mensaje := 'Obtener secuencia para SCFR_MOV_DOCUMENTOS_TXS';
      SELECT Scfr_Mov_Documentos_Txs_s.Nextval INTO l_Mov_Documentos FROM Dual;
      -- Insertar en SCFR_MOV_DOCUMENTOS_TXS
      l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_DOCUMENTOS_TXS';
      IF l_Trama_Mc.Subtrama_Mc1(l_Itm).Tipo_Movimiento = 'CIEFMA' THEN
        l_Signo := 1;
      ELSIF l_Trama_Mc.Subtrama_Mc1(l_Itm).Tipo_Movimiento = 'CIEFME' THEN
        l_Signo := 1;
      ELSIF l_Trama_Mc.Subtrama_Mc1(l_Itm).Tipo_Movimiento = 'CAJRBC' THEN
        l_Signo := 1;
      ELSE
        l_Signo := -1;
      END IF;
      INSERT INTO Scfr_Mov_Documentos_Txs
        (Mov_Documentos
        ,Txo_Codigo_Tx
        ,Txo_Correlativo_Tx
        ,Secuencia
        ,Tmo_Movimiento
        ,Monto
        ,Folio
        ,Anulado
        ,Estado_Movimiento_Caja
        ,Emp_Empresa
        ,Cad_Cadena
        ,Loc_Local
        ,Fecha_Regularizacion)
      VALUES
        (l_Mov_Documentos
        ,p_Transaccion.Codigo_Tx
        ,l_Trama_Mc.Correlativo
        ,l_Trama_Mc.Subtrama_Mc1(l_Itm).Secuencia
        ,l_Trama_Mc.Subtrama_Mc1(l_Itm).Tipo_Movimiento
        ,l_Trama_Mc.Subtrama_Mc1(l_Itm).Monto
        ,l_Trama_Mc.Subtrama_Mc1(l_Itm).Folio
        ,l_Trama_Mc.Subtrama_Mc1(l_Itm).Anulado
        ,l_Trama_Mc.Subtrama_Mc1(l_Itm).Estado
        ,p_Transaccion.Trama_Pos.Empresa
        ,p_Transaccion.Trama_Pos.Cadena
        ,p_Transaccion.Trama_Pos.Local
        ,Decode(l_Trama_Mc.Subtrama_Mc1(l_Itm).Fecha_Regularizacion
               ,0
               ,NULL
               ,-1
               ,NULL
               ,To_Date(l_Trama_Mc.Subtrama_Mc1(l_Itm).Fecha_Regularizacion
                       ,'yyyymmdd')));
    END LOOP;
    l_Dbg_Mensaje := 'Actualizar documento original en tabla SCFR_MOV_DOCUMENTOS';
    UPDATE Scfr_Mov_Documentos_Txs
       SET Anulado          = 'S'
          ,Origen_Anulacion = 'DIA'
     WHERE Txo_Correlativo_Tx = l_Trama_Mc.Correlativo_Tx
       AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
       AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
       AND Loc_Local = p_Transaccion.Trama_Pos.Local;
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Trama MC resuelta correctamente');
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  PROCEDURE Trama_Gd_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Gd         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Gd;
    l_Itm              NUMBER;
    l_Itm2             NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_gd_resuelve';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    x_Cod_Error := 0;
    -- Obtiene informacion de la trama GD
    l_Dbg_Mensaje := 'Obtener informacion de la trama GD';
    l_Trama_Gd    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Gd(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje := 'Recorrer detalle de la trama GD (Desglose Deposito)';
    FOR l_Itm IN 1 .. l_Trama_Gd.Count
    LOOP
      l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_DETALLE_DEPOSITO';
      INSERT INTO Scfr_Mov_Detalle_Deposito
        (Txo_Codigo_Tx
        ,Codigo_Deposito
        ,Monto_Deposito
        ,Numero_Colilla
        ,Registro_Recepcion_1
        ,Registro_Recepcion_2
        ,Registro_Devolucion
        ,Empresa
        ,Cadena
        ,Loc_Local)
      VALUES
        (p_Transaccion.Codigo_Tx
        ,l_Trama_Gd(l_Itm).Codigo_Deposito
        ,l_Trama_Gd(l_Itm).Monto_Deposito
        ,TRIM(l_Trama_Gd(l_Itm).Numero_Colilla)
        ,l_Trama_Gd(l_Itm).Registro_Recepcion_1
        ,l_Trama_Gd(l_Itm).Registro_Recepcion_2
        ,l_Trama_Gd(l_Itm).Registro_Devolucion
        ,p_Transaccion.Trama_Pos.Empresa
        ,p_Transaccion.Trama_Pos.Cadena
        ,p_Transaccion.Trama_Pos.Local);
      l_Dbg_Mensaje := 'Recorrer detalle la subtrama GD1 (Documentos Remesas)';
      FOR l_Itm2 IN 1 .. l_Trama_Gd(l_Itm).Subtrama_Gd1.Count
      LOOP
        l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_DESGLOSE_DET_DEPO';
        INSERT INTO Scfr_Mov_Desglose_Det_Depo
          (Txo_Codigo_Tx
          ,Correlativo_Tx_Remesa
          ,Empresa
          ,Cadena
          ,Loc_Local
          ,Tipo_Remesa
          ,Cant_Doctos_Remesa
          ,Monto_Remesa
          ,Validada
          ,Tipo_Validacion
          ,Codigo_Barra_Remesa)
        VALUES
          (p_Transaccion.Codigo_Tx
          ,l_Trama_Gd(l_Itm).Subtrama_Gd1(l_Itm2).Correlativo
          ,p_Transaccion.Trama_Pos.Empresa
          ,p_Transaccion.Trama_Pos.Cadena
          ,p_Transaccion.Trama_Pos.Local
          ,l_Trama_Gd(l_Itm).Subtrama_Gd1(l_Itm2).Tipo_Remesa
          ,l_Trama_Gd(l_Itm).Subtrama_Gd1(l_Itm2).Cant_Doctos_Remesa
          ,l_Trama_Gd(l_Itm).Subtrama_Gd1(l_Itm2).Monto_Remesa
          ,l_Trama_Gd(l_Itm).Subtrama_Gd1(l_Itm2).Validada
          ,l_Trama_Gd(l_Itm).Subtrama_Gd1(l_Itm2).Tipo_Validacion
          ,l_Trama_Gd(l_Itm).Subtrama_Gd1(l_Itm2).Codigo_Barra_Remesa);
      END LOOP;
    END LOOP;
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  FUNCTION Actualiza_Trama_Ca(p_Trama_Ca IN OUT Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ca
                             ,p_Campana  IN NUMBER
                             ,p_Aplica   IN VARCHAR2) RETURN NUMBER IS
    l_Existe      NUMBER := 0;
    l_Maximo      NUMBER := p_Trama_Ca.Count;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_GNC_PK.actualiza_trama_ca';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
  BEGIN
    l_Dbg_Mensaje := 'Actualiza informacion de la trama CA';
    FOR l_Itm IN 1 .. l_Maximo
    LOOP
      IF p_Trama_Ca(l_Itm).Campana = p_Campana THEN
        p_Trama_Ca(l_Itm).Control_Eventos := p_Aplica;
        l_Existe := 1;
        EXIT;
      END IF;
    END LOOP;
    l_Dbg_Mensaje := 'Agrega nueva campa?a a la trama CA';
    IF l_Existe = 0 THEN
      p_Trama_Ca(l_Maximo + 1).Campana := p_Campana;
      p_Trama_Ca(l_Maximo + 1).Control_Eventos := p_Aplica;
    END IF;
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => l_Dbg_Mensaje || '. ' || SQLERRM);
      RETURN 1;
  END;

  PROCEDURE Obtiene_Rut_Perfil(p_Forma_Identificacion  IN VARCHAR2
                              ,p_String_Identificacion IN VARCHAR2
                              ,p_Rut_Identificacion    IN NUMBER
                              ,x_Rut_Perfil            OUT NUMBER) IS
    l_Forma_Identifica  VARCHAR2(100);
    l_String_Identifica VARCHAR2(150);
  BEGIN
    l_Forma_Identifica  := Ltrim(Rtrim(p_Forma_Identificacion));
    l_String_Identifica := p_String_Identificacion;
    IF l_Forma_Identifica = 'R' THEN
      l_String_Identifica := Ltrim(Rtrim(REPLACE(l_String_Identifica
                                                ,'	')));
      l_String_Identifica := Substr(l_String_Identifica
                                   ,1
                                   ,Length(l_String_Identifica) - 1);
      x_Rut_Perfil        := To_Number(l_String_Identifica);
    END IF;
    IF l_Forma_Identifica = 'C' THEN
      l_String_Identifica := Substr(Ltrim(Rtrim(l_String_Identifica))
                                   ,16);
      l_String_Identifica := Ltrim(Rtrim(REPLACE(l_String_Identifica
                                                ,'	')));
      l_String_Identifica := Substr(l_String_Identifica
                                   ,1
                                   ,Length(l_String_Identifica) - 1);
      x_Rut_Perfil        := To_Number(l_String_Identifica);
    END IF;
    IF l_Forma_Identifica = 'B' THEN
      x_Rut_Perfil := p_Rut_Identificacion;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_Rut_Perfil := p_Rut_Identificacion;
  END Obtiene_Rut_Perfil;

  --//--------------------------------------------------------------------------\\
  --// CBR 04/04/2018 13:05  XML Local Aeropuerto                               \\
  --//-----------------------------------------------------------------Inicio---\\
  PROCEDURE Arma_Xml_Aeropuerto(p_Txo_Codigo_Tx      IN NUMBER
                               ,p_Txo_Correlativo_Tx IN NUMBER
                               ,x_Cod_Error          OUT NUMBER
                               ,x_Msg_Error          OUT VARCHAR2) IS
  
    v_Tasaiva         NUMBER := 0;
    n_Val_Neto        NUMBER := 0;
    v_Val_Iva         NUMBER := 0;
    n_Val_Total       NUMBER := 0;
    v_Segmento_Pr     VARCHAR2(4) := '';
    v_Sgmnt_Defecto   VARCHAR2(4) := 'C020';
    v_Cdg_Defecto     VARCHAR2(8) := '2018037';
    v_Signo_Valor     VARCHAR2(1) := NULL;
    v_Continuar       VARCHAR2(2) := 'NO';
    v_Nrolindet       Scfr_Mov_Xml_Aero_Detalle.Nrolindet%TYPE;
    v_Zcant           Scfr_Mov_Xml_Aero_Detalle.Zcant%TYPE;
    v_Zcodp           Scfr_Mov_Xml_Aero_Detalle.Zcodp%TYPE;
    v_Zcate           Scfr_Mov_Xml_Aero_Detalle.Zcate%TYPE;
    v_Zsubc           Scfr_Mov_Xml_Aero_Detalle.Zsubc%TYPE;
    v_Zsegm           Scfr_Mov_Xml_Aero_Detalle.Zsegm%TYPE;
    v_Zsubs           Scfr_Mov_Xml_Aero_Detalle.Zsubs%TYPE;
    v_Betrw           Scfr_Mov_Xml_Aero_Detalle.Betrw%TYPE;
    v_Betrw_c_Iva     Scfr_Mov_Xml_Aero_Detalle.Betrw%TYPE;
    v_Descuentomonto  Scfr_Mov_Xml_Aero_Detalle.Descuentomonto%TYPE;
    v_Descuento_c_Iva Scfr_Mov_Xml_Aero_Detalle.Descuentomonto%TYPE;
    v_Zimad           Scfr_Mov_Xml_Aero_Detalle.Zimad%TYPE;
  
    CURSOR c_Origen_Detalle(p_Codigo_Tx      IN NUMBER
                           ,p_Correlativo_Tx IN NUMBER) IS
      SELECT SUM(Cantidad)
            ,Codigo_Scnp
             --,Segment4
            ,SUM(Venta) Vta_c_Iva
            ,Round(SUM(Venta) / (1 + v_Tasaiva / 100)
                  ,0) Vta_s_Iva
            ,SUM(Descuento) Dto_c_Iva
            ,Round(SUM(Descuento) / (1 + v_Tasaiva / 100)
                  ,0) Dto_s_Iva
            ,'000'
        FROM (SELECT Nvl(h.Codigo_Scnp
                        ,v_Cdg_Defecto) Codigo_Scnp
                    ,p.Cantidad Cantidad
                    ,Nvl(p.Precio_Final
                        ,0) Venta
                    ,Desp.Mtodes Descuento
              --,Cp.Segment4
                FROM Scfr_Mov_Transacciones t
                    ,Scfr_Mov_Productos_Txs p
                    ,Xml_Aero_Homologacion h
                    ,Scfr_Producto_Categoria_Vm Cp
                    ,(SELECT Dp.Pro_Codigo_Interno
                            ,Nvl(SUM(Dp.Monto)
                                ,0) Mtodes
                        FROM Scfr_Mov_Descuentos_Productos Dp
                       WHERE Dp.Txo_Codigo_Tx(+) = p_Codigo_Tx
                         AND Dp.Txo_Correlativo_Tx(+) = p_Correlativo_Tx
                       GROUP BY Dp.Pro_Codigo_Interno) Desp
               WHERE t.Codigo_Tx = p_Codigo_Tx
                 AND t.Correlativo_Tx = p_Correlativo_Tx
                 AND p.Txo_Codigo_Tx = t.Codigo_Tx
                 AND p.Txo_Correlativo_Tx = t.Correlativo_Tx
                 AND p.Pro_Codigo_Interno NOT IN (999997)
                 AND Desp.Pro_Codigo_Interno(+) = p.Pro_Codigo_Interno
                 AND Cp.Codigo(+) = p.Pro_Codigo_Interno
                 AND h.Segment4(+) = Nvl(Cp.Segment4
                                        ,v_Sgmnt_Defecto)) x
       GROUP BY Codigo_Scnp;
  
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_GNC_PK.Arma_Xml_Aeropuerto';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
  
  BEGIN
    BEGIN
      SELECT 'SI'
        INTO v_Continuar
        FROM Scfr_Mov_Transacciones  t
            ,Scfr_Mov_Documentos_Txs d
       WHERE t.Codigo_Tx = p_Txo_Codigo_Tx
         AND t.Correlativo_Tx = p_Txo_Correlativo_Tx
         AND t.Codigo_Tx = d.Txo_Codigo_Tx
         AND d.Secuencia = 1
         AND d.Tmo_Movimiento IN ('VENBOL' -- ,'VENGUI'
                                 ,'VENFAC'
                                 ,'ANUBOL' -- ,'ANUGUI'
                                 ,'ANUFAC');
    EXCEPTION
      WHEN No_Data_Found THEN
        v_Continuar := 'NO';
    END;
  
    IF v_Continuar = 'SI' THEN
    
      x_Cod_Error := 0;
      --//--------------------------------------------------------------------------\\
      --// CBR 17/04/2018 18:08   ARCHIVO XML AEROPUERTO                            \\
      --// Inserto directamente en la tabla de cabecera que va a generar el XML     \\
      --//-----------------------------------------------------------------Inicio---\\
      l_Dbg_Mensaje := 'Insertar informacion para la cabecera del XML';
    
      INSERT INTO Scfr_Mov_Xml_Aero_Cabecera
        (Txo_Codigo_Tx
        ,Txo_Correlativo_Tx
        ,Blart
        ,Znumd
        ,Zarri
        ,Waers
        ,Bldat
        ,Zhora
        ,Budat
        ,Bupla
        ,Tvorg
        ,Zsect
        ,Mwskz
        ,Vkont
        ,Rutemisor
        ,Rznsocemisor
        ,Giroemisor
        ,Cdgsiisucur
        ,Dirorigen
        ,Cmnaorigen
        ,Ciudadorigen
        ,Rutrecep
        ,Rznsocrecep
        ,Contacto
        ,Dirrecep
        ,Cmnarecep
        ,Ciudadrecep)
        SELECT p_Txo_Codigo_Tx
              ,p_Txo_Correlativo_Tx
              ,Decode(d.Tmo_Movimiento
                     ,'VENBOL' -- ,'VENGUI'
                     ,'BO' -- ,'GD'
                     ,'VENFAC'
                     ,'FA'
                     ,'ANUBOL' -- ,'ANUGUI'
                     ,'NC' -- ,'NC'
                     ,'ANUFAC'
                     ,'NC')
              ,d.Folio
              ,NULL -- dentro del Sector de arribo ???
              ,'CLP'
              ,To_Char(t.Grabado
                      ,'DD.MM.YYYY')
              ,To_Char(t.Grabado
                      ,'HH24:MI:SS')
              ,To_Char(t.Fecha_Tx
                      ,'DD.MM.YYYY')
              ,'0077' -- Numero Local FCV ????
              ,NULL -- Codigo Estructura de Ingreso
              ,NULL -- Sector
              ,'C1' -- por defecto CON IMPUESTO IVA
              ,NULL -- Nro. Cuenta Contrato
              ,'898072002'
              ,'FARMACIAS CRUZ VERDE S.A.'
              ,'FARMACIAS Y PERFUMERIAS, SERVI' -- 'CIOS DE ENFERMERIA, VENTA DE PRODUCTOS ALIMENTICIO'
              ,'059291896' -- CODIGO_SII encontre este codigo por ahi.
              ,'AV. EL SALTO 4875'
              ,'HUECHURABA'
              ,'SANTIAGO'
              ,TRIM(c.Rut) || TRIM(c.Dv)
              ,Substr(TRIM(c.Nombres) || ' ' || TRIM(c.Apellido_Paterno) || ' ' || TRIM(c.Apellido_Materno)
                     ,1
                     ,38)
              ,Substr((SELECT TRIM(r.Nombres) || ' ' || TRIM(r.Apellido_Paterno) || ' ' || TRIM(r.Apellido_Materno)
                        FROM Scfr_Tmp_Clientes r
                       WHERE r.Rut(+) = t.Rut_Fidelizado)
                     ,1
                     ,38)
              ,TRIM(Substr(c.Direccion
                          ,1
                          ,38))
              ,(SELECT Cc.Descripcion
                 FROM Scfrt_Comunas_Ciudades Cc
                WHERE Cc.Tipo = 'COMUNA'
                  AND Cc.Codigo = c.Comuna)
              ,(SELECT Cc.Descripcion
                 FROM Scfrt_Comunas_Ciudades Cc
                WHERE Cc.Tipo = 'CIUDAD'
                  AND Cc.Codigo = c.Ciudad)
          FROM Scfr_Mov_Transacciones  t
              ,Scfr_Mov_Documentos_Txs d
              ,Scfr_Tmp_Clientes       c
         WHERE t.Codigo_Tx = p_Txo_Codigo_Tx
           AND t.Correlativo_Tx = p_Txo_Correlativo_Tx
           AND d.Secuencia = 1
           AND d.Tmo_Movimiento IN ('VENBOL' -- ,'VENGUI'
                                   ,'VENFAC'
                                   ,'ANUBOL' -- ,'ANUGUI'
                                   ,'ANUFAC')
           AND t.Codigo_Tx = d.Txo_Codigo_Tx
           AND c.Rut(+) = t.Rut_Titular;
    
      --//--------------------------------------------------------------------------\\
      --// CBR 18/04/2018 10:53   ARCHIVO XML AEROPUERTO                            \\
      --// recorro el cursor que grabara en el detalle que va a generar el XML      \\
      --//-----------------------------------------------------------------Inicio---\\
      l_Dbg_Mensaje := 'Insertar informacion para el detalle del XML';
    
      SELECT t.Rv_Low_Value INTO v_Tasaiva FROM Fid.Cg_Ref_Codes t WHERE t.Rv_Domain = 'IVA';
    
      BEGIN
        SELECT '-'
          INTO v_Signo_Valor
          FROM Scfr_Mov_Documentos_Txs t
         WHERE t.Txo_Codigo_Tx = p_Txo_Codigo_Tx
           AND t.Secuencia = 1
           AND t.Tmo_Movimiento IN ('ANUBOL' -- ,'ANUGUI'
                                   ,'ANUFAC')
           AND Rownum = 1;
      EXCEPTION
        WHEN OTHERS THEN
          v_Signo_Valor := '';
      END;
    
      v_Nrolindet := '01';
      OPEN c_Origen_Detalle(p_Txo_Codigo_Tx
                           ,p_Txo_Correlativo_Tx);
      LOOP
        FETCH c_Origen_Detalle
          INTO v_Zcant
              ,v_Zcodp
              ,v_Betrw_c_Iva
              ,v_Betrw
              ,v_Descuento_c_Iva
              ,v_Descuentomonto
              ,v_Zimad;
        EXIT WHEN c_Origen_Detalle%NOTFOUND;
      
        n_Val_Total := n_Val_Total + v_Betrw_c_Iva;
        n_Val_Neto  := n_Val_Neto + v_Betrw;
      
        SELECT c.Descripcion_Categoria
              ,Sc.Descripcion_Subcategoria
              ,s.Descripcion_Segmento
              ,Ss.Descripcion_Subsegmento
          INTO v_Zcate
              ,v_Zsubc
              ,v_Zsegm
              ,v_Zsubs
          FROM Xml_Aero_Categoria    c
              ,Xml_Aero_Subcategoria Sc
              ,Xml_Aero_Segmento     s
              ,Xml_Aero_Subsegmento  Ss
              ,Xml_Aero_Homologacion h
         WHERE h.Codigo_Scnp = Nvl(v_Zcodp
                                  ,v_Cdg_Defecto)
           AND c.Codigo_Categoria = Sc.Codigo_Categoria
           AND Sc.Codigo_Categoria = s.Codigo_Categoria
           AND Sc.Codigo_Subcategoria = s.Codigo_Subcategoria
           AND s.Codigo_Categoria = Ss.Codigo_Categoria
           AND s.Codigo_Subcategoria = Ss.Codigo_Subcategoria
           AND s.Codigo_Segmento = Ss.Codigo_Segmento
           AND h.Codigo_Categoria = Ss.Codigo_Categoria
           AND h.Codigo_Subcategoria = Ss.Codigo_Subcategoria
           AND h.Codigo_Segmento = Ss.Codigo_Segmento
           AND h.Codigo_Subsegmento = Ss.Codigo_Subsegmento
           AND Rownum = 1;
      
        INSERT INTO Scfr_Mov_Xml_Aero_Detalle
          (Txo_Codigo_Tx
          ,Txo_Correlativo_Tx
          ,Nrolindet
          ,Zcant
          ,Zcodp
          ,Zcate
          ,Zsubc
          ,Zsegm
          ,Zsubs
          ,Betrw
          ,Descuentomonto
          ,Zimad)
        VALUES
          (p_Txo_Codigo_Tx
          ,p_Txo_Correlativo_Tx
          ,v_Nrolindet
          ,v_Zcant
          ,v_Zcodp
          ,v_Zcate
          ,v_Zsubc
          ,v_Zsegm
          ,v_Zsubs
          ,v_Signo_Valor || TRIM(To_Char(Abs(v_Betrw)))
          ,v_Descuentomonto
          ,v_Zimad);
      
        v_Nrolindet := TRIM(To_Char(To_Number(v_Nrolindet) + 1
                                   ,'09'));
      END LOOP;
    
      --//--------------------------------------------------------------------------\\
      --// CBR 18/04/2018 10:53   ARCHIVO XML AEROPUERTO                            \\
      --// grabo en tabla Totales que va a generar el XML solo campos obligatorios  \\
      --//-----------------------------------------------------------------Inicio---\\
      l_Dbg_Mensaje := 'Insertar informacion para el total del XML';
    
      IF Abs(n_Val_Neto) > 0 THEN
        v_Val_Iva := Abs(n_Val_Total) - Abs(n_Val_Neto);
      ELSE
        n_Val_Neto  := 1;
        v_Val_Iva   := 0;
        n_Val_Total := 1;
        -- v_Signo_Valor := '';
      END IF;
    
      INSERT INTO Scfr_Mov_Xml_Aero_Totales
        (Txo_Codigo_Tx
        ,Txo_Correlativo_Tx
        ,Mntneto
        ,Tasaiva
        ,Iva
        ,Mnttotal)
      VALUES
        (p_Txo_Codigo_Tx
        ,p_Txo_Correlativo_Tx
        ,v_Signo_Valor || TRIM(To_Char(Abs(n_Val_Neto)))
        ,v_Tasaiva
        ,v_Signo_Valor || TRIM(To_Char(Abs(v_Val_Iva)))
        ,v_Signo_Valor || TRIM(To_Char(Abs(n_Val_Total))));
    
      --//--------------------------------------------------------------------------\\
      --// CBR 18/04/2018 11:38   ARCHIVO XML AEROPUERTO                            \\
      --// Ejecuto package que genera y envia XML por ws                            \\
      --//-----------------------------------------------------------------Inicio---\\
      Pkg_Aeropuerto_Ws.Inserta_Tx(p_Txo_Codigo_Tx
                                  ,p_Txo_Correlativo_Tx);
    
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Trama_Vx_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Vx         Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vx;
    l_Resultado        NUMBER;
    l_Cod_Error        NUMBER;
    l_Mov_Documentos   NUMBER;
    l_Fecha_Tx         DATE;
    l_Fecha_Transacc   DATE;
    l_Msg_Error        VARCHAR2(2000);
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.GNCU15.Trama_vx_Resuelve';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Contralado EXCEPTION;
    l_Recaudacion      NUMBER;
    --l_txo_codigo_tx_relacionado NUMBER;
  BEGIN
    --***********************************************************************
    -- Actualizacion genericac de recaudacion
    --***********************************************************************
    l_Dbg_Mensaje := 'Obtener Antecedentes transaccion padre   Trama DR';
    l_Trama_Vx    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Vx(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje := 'Valida completitud de datos obligatorios.' || l_Trama_Vx.Correlativo_Tx || ' ' || l_Trama_Vx.Tipo_Movimiento_Padre || ' ' ||
                     l_Trama_Vx.Fecha || ' ' || l_Trama_Vx.Hora_Retencion || ' ' || l_Trama_Vx.Documentos_Emitidos;
    IF (Nvl(l_Trama_Vx.Correlativo_Tx
           ,0) < 1) OR
       (Nvl(l_Trama_Vx.Tipo_Movimiento_Padre
           ,'NAN') = 'NAN') OR
       (Nvl(l_Trama_Vx.Fecha
           ,0) < 1) OR
      --       (Nvl(l_Trama_Vx.Hora_Retencion  ,0) < 1) OR
       (Nvl(l_Trama_Vx.Documentos_Emitidos
           ,0) < 1) THEN
      x_Cod_Error := -2000;
      x_Msg_Error := 'Datos obligatorios.  Nulos trama Vx';
      RAISE l_Error_Contralado;
    END IF;
    l_Dbg_Mensaje := 'Valida Verificando FechaS.';
    BEGIN
      l_Fecha_Tx := To_Date(To_Char(l_Trama_Vx.Fecha) || Lpad(To_Char(l_Trama_Vx.Hora_Retencion)
                                                             ,6
                                                             ,'0')
                           ,'yyyymmdd hh24:mi:ss');
    EXCEPTION
      WHEN OTHERS THEN
        l_Fecha_Tx := To_Date(To_Char(l_Trama_Vx.Fecha)
                             ,'yyyymmdd');
    END;
    l_Dbg_Mensaje := 'Recorre detalle de documentos emitidos.';
    --l_diferencia   := 0;
    FOR l_Itm IN 1 .. l_Trama_Vx.Documentos_Emitidos
    LOOP
      l_Dbg_Mensaje := ' Valida completitud de datos obligatorios.';
    
      l_Dbg_Mensaje := 'Valida 2 completitud de datos obligatorios.' || l_Trama_Vx.Subtrama_Vx1(l_Itm).Secuencia || ' ' || l_Trama_Vx.Subtrama_Vx1(l_Itm).Tipo_Movimiento_Hijo || ' ' || l_Trama_Vx.Subtrama_Vx1(l_Itm).Tipo_Retencion || ' ' || l_Trama_Vx.Subtrama_Vx1(l_Itm).Numero_Factura || ' ' || l_Trama_Vx.Subtrama_Vx1(l_Itm).Numero_Retencion || ' ' || l_Trama_Vx.Subtrama_Vx1(l_Itm).Monto;
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
    
      IF (l_Trama_Vx.Subtrama_Vx1(l_Itm).Secuencia IS NULL) OR
         (l_Trama_Vx.Subtrama_Vx1(l_Itm).Tipo_Movimiento_Hijo IS NULL) OR
         (l_Trama_Vx.Subtrama_Vx1(l_Itm).Tipo_Retencion IS NULL) OR
         (l_Trama_Vx.Subtrama_Vx1(l_Itm).Numero_Factura IS NULL) OR
         (l_Trama_Vx.Subtrama_Vx1(l_Itm).Numero_Retencion IS NULL) OR
         (l_Trama_Vx.Subtrama_Vx1(l_Itm).Monto IS NULL) THEN
        x_Cod_Error   := -2000;
        x_Msg_Error   := 'datos obligatorios.  Nulos Trama Vx1';
        l_Dbg_Mensaje := x_Msg_Error || ' ' || x_Cod_Error;
        RAISE l_Error_Contralado;
      END IF;
    END LOOP;
  
    l_Dbg_Mensaje := 'Obtener folio desde scfr_mov_transacciones_s';
    SELECT Scfr_Mov_Transacciones_s.Nextval INTO p_Transaccion.Codigo_Tx FROM Dual;
    p_Transaccion.Fecha_Tx       := To_Date(Ltrim(Rtrim(l_Trama_Vx.Fecha)) || Ltrim(Rtrim(To_Char(l_Trama_Vx.Hora_Retencion
                                                                                                 ,'000009')))
                                           ,'yyyymmddhh24miss');
    p_Transaccion.Correlativo_Tx := l_Trama_Vx.Correlativo_Tx;
    IF l_Fecha_Tx IS NULL THEN
      l_Fecha_Transacc := To_Date(l_Fecha_Tx
                                 ,'yyyymmddhh24miss');
    END IF;
    l_Dbg_Mensaje := 'Inserta transaccion';
    INSERT INTO Scfr_Mov_Transacciones
      (Codigo_Tx
      ,Correlativo_Tx
      ,Tmo_Movimiento_Padre
      ,Fecha_Tx
      ,Emp_Empresa
      ,Cad_Cadena
      ,Loc_Local
      ,Numero_Maquina
      ,Pt_Party_Id_Titular
      ,Rut_Titular
      ,Dv_Titular
      ,Estado_Registro
      ,Sec_Recaudacion
      ,Proceso_Dwh
      ,Numero_Cuenta_Tarjeta
      ,Codigo_Autorizacion_Tx
      ,Estx_Srv_Codigo
      ,Estx_Numero_Pos
      ,Estx_Fecha
      ,
       --txo_correlativo_tx_relacionado,
       Estx_Destino
      ,Estx_Sistema
      ,Estx_Funcion
      ,Estx_Secuencia
      ,Estx_Numero_Trama
      ,Estx_Codigo_Tx
      ,Estx_Numero_Local
      ,
       --txo_codigo_tx_relacionado,
       Con_Numero_Convenio
      ,Pla_Numero_Plan
      ,Autorizacion_Cnv_Tx
      ,Cuadrar_Transacciones
      ,Docs_Emitir_Liq_Pag
      ,Docs_Emitir_Liq_Emp
      ,Autorizacion_Cnv_Ext
      ,Transaccion_Manual
      ,Numero_Tav
      ,Fecha_Inicio_Tx
      ,Fecha_Cierre_Tx
      ,Fecha_Generacion_Registro
      ,Numero_Tx_Comercio)
    VALUES
      (p_Transaccion.Codigo_Tx
      ,l_Trama_Vx.Correlativo_Tx
      ,l_Trama_Vx.Tipo_Movimiento_Padre
      ,l_Fecha_Tx
      ,p_Transaccion.Trama_Pos.Empresa
      ,p_Transaccion.Trama_Pos.Cadena
      ,p_Transaccion.Trama_Pos.Local
      ,p_Transaccion.Trama_Pos.Numero_Pos
      ,p_Transaccion.Trama_Boc.Party_Id -- pt_party_id_titular
      ,p_Transaccion.Rut_Titular -- rut_titular
      ,p_Transaccion.Dv_Rut_Titular -- dv_titular
      ,'VIG'
      ,0
      ,0
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,'NO'
      ,NULL
      ,NULL
      ,NULL
      ,'NO'
      ,TRIM(p_Transaccion.Trama_Pos.Id_Maquina)
      ,NULL
      ,l_Fecha_Tx
      ,l_Fecha_Tx
      ,NULL);
    FOR l_Itm IN 1 .. l_Trama_Vx.Documentos_Emitidos
    LOOP
      l_Dbg_Mensaje := ' obtiene folio para documentos TXS.';
      SELECT Scfr_Mov_Documentos_Txs_s.Nextval INTO l_Mov_Documentos FROM Dual;
      --      x_Doc_Emitidos(l_Itm) := l_Mov_Documentos;
      l_Dbg_Mensaje := ' inserta documentos de transaccion.';
    
      --//-----------------------------------------------------------------Termino--\\
    
      INSERT INTO Scfr_Mov_Documentos_Txs
        (Mov_Documentos
        ,Txo_Codigo_Tx
        ,Txo_Correlativo_Tx
        ,Secuencia
        ,Tmo_Movimiento
        ,Dfi_Numero_Asignacion
        ,Monto
        ,Anulado
        ,Iva
        ,Folio
        ,Folio_Dicc
        ,Tipo_Dicc
        ,Pin_Ot_Recetario
        ,Estado_Movimiento_Caja
        ,Fecha_Regularizacion
        ,Numero_Pedido
        ,Pvr_Rut_Proveedor
        ,Pvr_Sucursal_Proveedor
        ,Folio_Reclamo_Canje
        ,Matricula_Bulto
        ,Sello_Seguro_Uno
        ,Sello_Seguro_Dos
        ,Facturado
        ,Periodo_Facturacion
        ,Puntos_Asignados
        ,Emp_Empresa
        ,Cad_Cadena
        ,Loc_Local
        ,Tipo_Distribucion
        ,Campana
        ,Documento_Fiscal
        ,Sec_Financiamiento)
      VALUES
        (l_Mov_Documentos -- mov_documentos                    not null
        ,p_Transaccion.Codigo_Tx -- txo_codigo_tx                     not null
        ,l_Trama_Vx.Correlativo_Tx -- txo_correlativo_tx                not null
        ,l_Trama_Vx.Subtrama_Vx1(l_Itm).Secuencia -- secuencia                         not null
        ,l_Trama_Vx.Subtrama_Vx1(l_Itm).Tipo_Movimiento_Hijo -- tmo_movimiento                    not null
        ,0
        ,l_Trama_Vx.Subtrama_Vx1(l_Itm).Monto -- monto                             not null
        ,'N'
        ,0
        ,l_Trama_Vx.Subtrama_Vx1(l_Itm).Numero_Factura -- folio                                 null
        ,l_Trama_Vx.Subtrama_Vx1(l_Itm).Numero_Retencion -- folio_dicc                            null
        ,l_Trama_Vx.Subtrama_Vx1(l_Itm).Tipo_Retencion -- tipo_dicc                             null
        ,NULL -- pin_ot_recetario
        ,NULL -- estado_movimiento_caja                null
        ,NULL -- fecha_regularizacion                  null
        ,NULL -- numero_pedido                         null
        ,NULL -- pvr_rut_proveedor                     null
        ,NULL -- pvr_sucursal_proveedor                null
        ,NULL -- folio_reclamo_canje                   null
        ,NULL -- matricula_bulto                       null
        ,NULL -- sello_seguro_uno                      null
        ,NULL -- sello_seguro_dos                      null
        ,NULL -- facturado                             null
        ,NULL -- periodo_facturacion                   null
        ,NULL -- puntos_asignados                      null
        ,p_Transaccion.Trama_Pos.Empresa -- emp_empresa                           null
        ,p_Transaccion.Trama_Pos.Cadena -- cad_cadena                            null
        ,p_Transaccion.Trama_Pos.Local -- loc_local                             null
        ,NULL -- tipo_distribucion                     null
        ,0
        ,NULL
        ,0);
    
    --//-----------------------------------------------------------------Termino--\\
    END LOOP;
  
    INSERT INTO Scfr_Mov_Datos_Ventas
      (Txo_Codigo_Tx
      ,Txo_Correlativo_Tx
      ,Tmo_Movimiento_Padre
      ,Fecha_Tx
      ,Tipo_Identi_Titular
      ,Identi_Titular
      ,Emp_Empresa
      ,Cad_Cadena
      ,Loc_Local)
    VALUES
      (p_Transaccion.Codigo_Tx
      ,l_Trama_Vx.Correlativo_Tx
      ,l_Trama_Vx.Tipo_Movimiento_Padre
      ,l_Fecha_Tx
      ,Substr(p_Transaccion.Trama_Boc.Forma_Identificacion
             ,1
             ,1)
      ,TRIM(p_Transaccion.Trama_Boc.String_Identificacion)
      ,p_Transaccion.Trama_Pos.Empresa
      ,p_Transaccion.Trama_Pos.Cadena
      ,p_Transaccion.Trama_Pos.Local);
  
    -- Actualiza codigo_tx de la recaudacion para la venta relacionada en SCFR_MOV_TX_RELACIONADAS
    UPDATE Scfr_Mov_Tx_Relacionadas
       SET Txo_Codigo_Tx_Relacionado = p_Transaccion.Codigo_Tx
          ,Procesado                 = Nvl2(Procesado
                                           ,2
                                           ,Procesado)
     WHERE Correlativo_Tx_Relacionado = p_Transaccion.Correlativo_Tx
       AND LOCAL = p_Transaccion.Trama_Pos.Local
       AND Trunc(Fecha_Tx) = Trunc(l_Fecha_Tx)
       AND Numero_Maquina = p_Transaccion.Trama_Pos.Numero_Pos;
    Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                              ,l_Dbg_Mensaje);
  
  EXCEPTION
    WHEN l_Error_Contralado THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  --//-----------------------------------------------------------------Termino--\\

  /*
    FUNCTION complementa_trama_ca( l_trama_ca  IN  OUT Scfr_Trx_Dyn_Types_Pk.tab_trama_ca
                                 , p_party_id  IN  NUMBER
                                 , x_cod_error OUT NUMBER
                                 , x_msg_error OUT VARCHAR2 )
    RETURN Scfr_Trx_Dyn_Types_Pk.tab_trama_ca IS
      CURSOR c_campanas_control IS
        SELECT cam_campana
          FROM scfr_control_frecuencia
         WHERE pt_party_id                 = p_party_id
           AND Scfr_Trx_Gnc_Utl_Pk.esta_vigente( cam_campana ) = 'ACT';
           --and tiene_control_frecuencia( p_campana ) = 'SI';
  
      l_periodo          NUMBER;
      l_restric_min      NUMBER;
      l_resultado        NUMBER;
      l_eventos          NUMBER;
      l_eventos_suman    NUMBER;
      l_eventos_restan   NUMBER;
      l_restric_eventos  NUMBER;
      l_aplica           VARCHAR2(2);
      l_dbg_proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.complementa_trama_ca';
      l_dbg_mensaje      VARCHAR2(250) := 'Error General';
    BEGIN
      x_cod_error := 0;
      x_msg_error := NULL;
  
      l_dbg_mensaje := 'Recorrer las campanas posibles';
      FOR campanas IN c_campanas_control LOOP
        BEGIN
          l_dbg_mensaje := 'Obtener el periodo (en dias) a evaluar';
          BEGIN
            SELECT NVL( restriccion_minima , 0 ) -- - 1
              INTO l_periodo
              FROM scfr_condiciones
             WHERE cam_campana    = campanas.cam_campana
               AND tipo_condicion = 'DEV';
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_periodo := 0;
              Scfr_Trx_Util_Pk.debug_msg(p_proceso=>l_DBG_PROCESO, p_msg=>l_DBG_MENSAJE||'. No hay datos para Campana '||campanas.cam_campana||'/DEV');
            WHEN OTHERS THEN
              l_periodo := 0;
              Scfr_Trx_Util_Pk.debug_msg(p_proceso=>l_DBG_PROCESO, p_msg=>l_DBG_MENSAJE||'. '||SQLERRM);
          END;
  
          IF l_periodo > 0 THEN
            l_dbg_mensaje := 'Obtener la cantidad de eventos definidos para el periodo';
            BEGIN
              SELECT NVL( restriccion_minima , 0 )
                INTO l_restric_eventos
                FROM scfr_condiciones
               WHERE cam_campana    = campanas.cam_campana
                 AND tipo_condicion = 'EVE';
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_restric_eventos := 0;
                Scfr_Trx_Util_Pk.debug_msg(p_proceso=>l_DBG_PROCESO, p_msg=>l_DBG_MENSAJE||'. No hay datos para Campana '||campanas.cam_campana||'/EVE');
              WHEN OTHERS THEN
                l_restric_eventos := 0;
                Scfr_Trx_Util_Pk.debug_msg(p_proceso=>l_DBG_PROCESO, p_msg=>l_DBG_MENSAJE||'. '||SQLERRM);
            END;
  
            l_dbg_mensaje := 'Obtener la cantidad de eventos que suman';
            BEGIN
              SELECT COUNT(*)
                INTO l_eventos_suman
                FROM scfr_control_frecuencia
               WHERE cam_campana                 = campanas.cam_campana
                 AND pt_party_id                 = p_party_id
                 AND tipo_movimiento_frecuencia IN ( 'COM' , 'AJP' )
                 AND TRUNC(fecha_venta)         >= TRUNC(Scfr_Trx_Util_Pk.get_sysdate()) - (l_periodo - 1)
                 AND TRUNC(fecha_venta)         <= TRUNC(Scfr_Trx_Util_Pk.get_sysdate());
             EXCEPTION
               WHEN OTHERS THEN
                 l_eventos_suman := 0;
             END;
  
            l_dbg_mensaje := 'Obtener la cantidad de eventos que restan';
            BEGIN
              SELECT COUNT(*)
                INTO l_eventos_restan
                FROM scfr_control_frecuencia
               WHERE cam_campana                 = campanas.cam_campana
                 AND pt_party_id                 = p_party_id
                 AND tipo_movimiento_frecuencia IN ( 'REV' , 'AJN' )
                 AND TRUNC(fecha_venta)         >= TRUNC(Scfr_Trx_Util_Pk.get_sysdate()) - (l_periodo - 1)
                 AND TRUNC(fecha_venta)         <= TRUNC(Scfr_Trx_Util_Pk.get_sysdate());
            EXCEPTION
              WHEN OTHERS THEN
                l_eventos_restan := 0;
            END;
  
            l_dbg_mensaje := 'Obtener la cantidad de eventos efectivos a evaluar';
            l_eventos := l_eventos_suman - l_eventos_restan;
  
            l_aplica := 'NO';
            IF l_eventos < l_restric_eventos THEN
              l_aplica := 'SI';
            END IF;
  
            l_dbg_mensaje := 'Actualizar la trama CA';
            l_resultado := actualiza_trama_ca( l_trama_ca , campanas.cam_campana , l_aplica );
            IF l_resultado != 0 THEN
              Scfr_Trx_Util_Pk.debug_msg(p_proceso=>l_DBG_PROCESO, p_msg=>l_DBG_MENSAJE||'. Problemas al ejecutar actualiza_trama_ca');
            END IF;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            Scfr_Trx_Util_Pk.debug_msg(p_proceso=>l_DBG_PROCESO, p_msg=>l_DBG_MENSAJE);
        END;
      END LOOP;
      RETURN l_trama_ca;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN l_trama_ca;
    END;
  
    PROCEDURE arma_trama_dv_desde_dr( p_transaccion IN OUT Scfr_Trx_Dyn_Pk.rec_transaccion
                                    , x_trama_dv       OUT Scfr_Trx_Dyn_Types_Pk.rec_trama_dv
                                    , x_cod_error      OUT NUMBER
                                    , x_msg_error      OUT VARCHAR2 ) IS
      l_trama_dr    Scfr_Trx_Dyn_Types_Pk.rec_trama_dr;
      l_trama_dv    Scfr_Trx_Dyn_Types_Pk.rec_trama_dv;
      l_DBG_PROCESO VARCHAR2(100) := 'SCFR_TRX_GNC_PK.arma_trama_dv_desde_dr';
      l_DBG_MENSAJE VARCHAR2(250) := 'Error General';
    BEGIN
      x_cod_error := 0;
      x_msg_error := NULL;
  
      l_DBG_MENSAJE := 'Cargar trama DR';
      l_trama_dr    := Scfr_Trx_Dyn_Utl_Pk.carga_trama_dr( p_transaccion.cuerpo_tx );
  
      l_DBG_MENSAJE := 'Cargar trama DV a partir de la trama DR';
      x_trama_dv.correlativo_tx          := l_trama_dr.correlativo_tx;
      x_trama_dv.correlativo_tx_asociado := l_trama_dr.secuencia_b;
      x_trama_dv.tipo_movimiento_padre   := l_trama_dr.tipo_movimiento_padre;
      x_trama_dv.fecha                   := l_trama_dr.fecha;
      x_trama_dv.hora_venta              := l_trama_dr.hora_recaudacion;
      x_trama_dv.LOCAL                   := l_trama_dr.LOCAL;
      x_trama_dv.ot                      := l_trama_dr.ot;
      x_trama_dv.documentos_emitidos     := l_trama_dr.subtrama_dr1.COUNT;
  
      l_DBG_MENSAJE := 'Carga Docs. emitidos trama DV a partir de la trama DR ';
      FOR l_itm IN 1..l_trama_dr.subtrama_dr1.COUNT LOOP
        x_trama_dv.subtrama_dv1(l_itm).secuencia_b              := l_trama_dr.subtrama_dr1(l_itm).secuencia_b;
        x_trama_dv.subtrama_dv1(l_itm).tipo_movimiento_hijo     := l_trama_dr.subtrama_dr1(l_itm).tipo_movimiento_hijo;
        x_trama_dv.subtrama_dv1(l_itm).numero_asignacion        := l_trama_dr.subtrama_dr1(l_itm).numero_asignacion;
        x_trama_dv.subtrama_dv1(l_itm).anulado                  := l_trama_dr.subtrama_dr1(l_itm).anulado;
        x_trama_dv.subtrama_dv1(l_itm).folio                    := l_trama_dr.subtrama_dr1(l_itm).folio;
        x_trama_dv.subtrama_dv1(l_itm).tipo_dicc                := l_trama_dr.subtrama_dr1(l_itm).tipo_dicc;
        x_trama_dv.subtrama_dv1(l_itm).folio_dicc               := l_trama_dr.subtrama_dr1(l_itm).folio_dicc;
        x_trama_dv.subtrama_dv1(l_itm).total_iva_incluido       := l_trama_dr.subtrama_dr1(l_itm).total_iva_incluido;
        x_trama_dv.subtrama_dv1(l_itm).iva                      := l_trama_dr.subtrama_dr1(l_itm).iva;
        x_trama_dv.subtrama_dv1(l_itm).puntos_asignados         := l_trama_dr.subtrama_dr1(l_itm).puntos_asignados;
        x_trama_dv.subtrama_dv1(l_itm).tipo_distribucion        := l_trama_dr.subtrama_dr1(l_itm).tipo_distribucion;
        x_trama_dv.subtrama_dv1(l_itm).campana                  := l_trama_dr.subtrama_dr1(l_itm).campana;
        x_trama_dv.subtrama_dv1(l_itm).secuencia_financiamiento := l_trama_dr.subtrama_dr1(l_itm).secuencia_financiamiento;
        x_trama_dv.subtrama_dv1(l_itm).documento_fiscal         := l_trama_dr.subtrama_dr1(l_itm).documento_fiscal;
  
      END LOOP;
  
    EXCEPTION
      WHEN OTHERS THEN
        Scfr_Trx_Util_Pk.error_msg(l_DBG_PROCESO,l_DBG_MENSAJE);
        x_cod_error := SQLCODE;
        x_msg_error := SQLERRM;
    END;
  */
  -- Implementacion de procedimientos publicos del package
  /*****************************************************************************
  Consulta Perfil de Cliente. Obtiene informacion relacionada al cliente
  Parametros Entrada:
    p_transaccion => Transaccion que contiene la peticion del perfil en forma de arreglo
  Parametros Salida:
    x_respuesta   => Transaccion que contiene el perfil en formato BLOB
    x_cod_error   => Codigo de error, si es que hubo algun problema
    x_msg_error   => Mensaje de error, si es que hubo algun problema
  *****************************************************************************/
  PROCEDURE Gncc01(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Dp Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp;
    l_Trama_Dc Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dc;
  
    l_Trama_Ms Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ms;
    l_Trama_Pu Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pu;
    l_Trama_Ca Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ca;
    l_Trama_Pf Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pf;
    l_Trama_Pz Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pz;
  
    l_Trama_Cf Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cf;
    l_Trama_Pc Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pc;
  
    l_Trama_Rf Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rf;
  
    l_Trama_Rc Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rc;
  
    l_Trama_Cu Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cu;
    l_Trama_Cm Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cm;
    l_Trama_Cc Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cc;
  
    l_Trama_Ce Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ce;
 
    l_Trama_In  Scfr_Trx_Dyn_Types_Pk.Tab_Trama_In; -- JAGC NEC 09/09/2024
  
    l_Trama_Hc             Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Hc;
    l_Trama_Co             Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Co;
    l_Trama_Rp             Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp;
    l_Trama_Fm             Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Fm;
    l_Convenios            Scfr_Conv_Pk.t_Linea_Perfil_Pos;
    p_Param_Ws             Scfr_Trx_Dyn_Types_Pk.Rec_Data_Com;
    l_Nombre_Cli           VARCHAR2(150);
    l_Cod_Error            NUMBER;
    l_Msg_Error            VARCHAR2(2000);
    l_Datos_Cli            Scfr_Conv_Pk.Reg_Benef_Nombres;
    x_Error                VARCHAR2(15);
    l_Valida_Cli_Exc       VARCHAR2(2);
    l_Rut_Cliente          NUMBER;
    l_Id_Relacion          NUMBER;
    l_Rut_Titular          VARCHAR2(10);
    l_Cuerpo_Tx            BLOB;
    l_Resultado            NUMBER;
    l_Largo_Ctx            NUMBER;
    l_Largo_Tot            NUMBER;
    l_Party_Id_Rel         NUMBER;
    l_Dbg_Proceso          VARCHAR2(100) := 'SCFR_TRX_GNC_PK.gncc01';
    l_Dbg_Mensaje          VARCHAR2(250) := 'Error General';
    l_Flag_Hc              NUMBER;
    l_Error_Controlado     EXCEPTION;
    l_Perfil               VARCHAR2(2);
    l_Rut_Perfil           NUMBER;
    l_Forma_Identifica     VARCHAR2(100);
    l_String_Identifica    VARCHAR2(150);
    x_Id_Consulta_Json     NUMBER;
    x_Id_Consulta_Json_Nec     NUMBER;-- JAGC NEC 09/09/2024
    x_Id_Sec_Lotalty       NUMBER;
    l_Es_Maicao            BOOLEAN;
    l_Forma_Identif_Online VARCHAR2(1);
    l_Error_Dp             NUMBER := 0;
    
  BEGIN
    l_Forma_Identifica  := p_Transaccion.Trama_Boc.Forma_Identificacion;
    l_String_Identifica := p_Transaccion.Trama_Boc.String_Identificacion;
    l_Trama_Dp          := Scfr_Trx_Fid_Pk.Trama_Dp_Prepara(p_Transaccion
                                                           ,x_Id_Consulta_Json
                                                           ,x_Id_Consulta_Json_Nec-- JAGC NEC 09/09/2024
                                                           ,x_Id_Sec_Lotalty
                                                           ,x_Cod_Error
                                                           ,x_Msg_Error);
  
    IF Nvl(x_Cod_Error
          ,0) <> 0 THEN
      -- Informa al POS del error
      x_Respuesta                                := NULL;
      p_Transaccion.Trama_Pos.Codigo_Respuesta   := x_Cod_Error;
      p_Transaccion.Trama_Pos.Largo_Total_Buffer := Scfr_Trx_Dyn_Pk.Obtiene_Largo_Trama(Scfr_Trx_Dyn_Pk.k_Trama_Header_Boc);
      x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                  ,Scfr_Trx_Dyn_Pk.Arma_Trama_Pos(p_Transaccion));
      p_Transaccion.Trama_Boc.Codigo_Respuesta   := x_Cod_Error;
      p_Transaccion.Trama_Boc.Largo_Total_Buffer := 0;
      x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                  ,Scfr_Trx_Dyn_Pk.Arma_Trama_Boc(p_Transaccion));
      x_Cod_Error                                := 0;
      l_Trama_Dp                                 := NULL;
      l_Error_Dp                                 := 1;
      --      RETURN;
    END IF;
    l_Dbg_Mensaje := 'Obtener informacion trama PU (Puntos)';
    l_Trama_Pu    := Scfr_Trx_Fid_Pk.Trama_Pu_Prepara(p_Transaccion
                                                     ,x_Cod_Error
                                                     ,x_Msg_Error);
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => l_Dbg_Mensaje || '.' || x_Cod_Error || '-' || x_Msg_Error);
      x_Cod_Error := 0;
      x_Msg_Error := NULL;
    END IF;
    --    IF l_Es_Loyalty = FALSE THEN
    l_Dbg_Mensaje := 'Obtener informacion trama CA (Campa?as)';
    l_Trama_Ca    := Scfr_Trx_Fid_Pk.Trama_Ca_Prepara(p_Transaccion
                                                     ,x_Cod_Error
                                                     ,x_Msg_Error);
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => l_Dbg_Mensaje || '.' || x_Cod_Error || '-' || x_Msg_Error);
      x_Cod_Error := 0;
      x_Msg_Error := NULL;
    ELSE
      l_Dbg_Mensaje := 'Complementar informacion de la trama CA con el Control de Frecuencias';
      l_Trama_Ca    := Scfr_Trx_Gnc_Utl_Pk.Complementa_Trama_Ca(l_Trama_Ca
                                                               ,p_Transaccion.Trama_Boc.Party_Id
                                                               ,x_Cod_Error
                                                               ,x_Msg_Error);
      x_Cod_Error   := 0;
      x_Msg_Error   := NULL;
    END IF;
    l_Dbg_Mensaje := 'Obtener informacion trama PF (Producto Fidelizado)';
    l_Trama_Pf    := Scfr_Trx_Fid_Pk.Trama_Pf_Prepara(p_Transaccion
                                                     ,x_Cod_Error
                                                     ,x_Msg_Error);
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => l_Dbg_Mensaje || '.' || x_Cod_Error || '-' || x_Msg_Error);
      x_Cod_Error := 0;
      x_Msg_Error := NULL;
    END IF;
    l_Dbg_Mensaje := 'Obtener informacion trama CF (Compra Frecuente)';
    l_Trama_Cf    := Scfr_Trx_Fid_Pk.Trama_Cf_Prepara(p_Transaccion
                                                     ,x_Cod_Error
                                                     ,x_Msg_Error);
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => l_Dbg_Mensaje || '.' || x_Cod_Error || '-' || x_Msg_Error);
      x_Cod_Error := 0;
      x_Msg_Error := NULL;
    END IF;
    l_Dbg_Mensaje := 'Obtener informacion trama CU (Cupones Emitidos)';
    l_Trama_Cu    := Scfr_Trx_Fid_Pk.Trama_Cu_Prepara(p_Transaccion
                                                     ,NULL
                                                     ,x_Cod_Error
                                                     ,x_Msg_Error);
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => l_Dbg_Mensaje || '.' || x_Cod_Error || '-' || x_Msg_Error);
      x_Cod_Error := 0;
      x_Msg_Error := NULL;
    END IF;
    l_Dbg_Mensaje := 'Obtener informacion trama CM (Cupones Uno o Uno)';
    l_Trama_Cm    := Scfr_Trx_Fid_Pk.Trama_Cm_Prepara(p_Transaccion
                                                     ,x_Cod_Error
                                                     ,x_Msg_Error);
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => l_Dbg_Mensaje || '.' || x_Cod_Error || '-' || x_Msg_Error);
      x_Cod_Error := 0;
      x_Msg_Error := NULL;
    END IF;
    IF (l_Flag_Hc = 1) THEN
      l_Dbg_Mensaje := 'Obtener informacion trama HC (Historial de Compra)';
      l_Trama_Hc    := Trama_Hc_Prepara(p_Transaccion
                                       ,x_Cod_Error
                                       ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => l_Dbg_Mensaje || '.' || x_Cod_Error || '-' || x_Msg_Error);
        x_Cod_Error := 0;
        x_Msg_Error := NULL;
      END IF;
    END IF;
    
    l_Dbg_Mensaje := 'Obtener informacion trama CO (Convenios)';
    l_Trama_Co    := Scfr_Trx_Conv_Empresarial_Pk.Trama_Co_Prepara(p_Transaccion
                                                                  ,x_Id_Consulta_Json
                                                                  ,l_Trama_Dp
                                                                  ,x_Cod_Error
                                                                  ,x_Msg_Error);                                       
                                                                      
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => l_Dbg_Mensaje || '.' || x_Cod_Error || '-' || x_Msg_Error);
      x_Cod_Error := 0;
      x_Msg_Error := NULL;
    END IF;
    --//--------------------------------------------------------------------------\\
    --// CBR 20/08/2020 15:31                                                     \\
    --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
    --// Saco trama RP hasta que se soluciones                                    \\
    --//-----------------------------------------------------------------Inicio---\\
    /*
      l_Dbg_Mensaje := 'Obtener informacion trama RP (Recetas)';
      IF p_Transaccion.Trama_Pos.Origen_Transaccion IN ('CCR'
                                                       ,'ISP'
                                                       ,'SQF'
                                                       ,'CCV'
                                                       ,'SPA'
                                                       ,'BIO'
                                                       ,'GLO'
                                                       ,'BOX'
                                                       ,'FEL'
                                                       ,'FAT'
                                                       ,'CIA'
                                                       ,'EMP'
                                                       ,'DEC') THEN
        -- erika 29112018
        l_Trama_Rp := Registro_Recetas_Pkg.Trama_Rp_Prepara(p_Transaccion
                                                           ,x_Cod_Error
                                                           ,x_Msg_Error);
      ELSE
        l_Trama_Rp := Scfr_Trx_Gnc_Utl_Pk.Trama_Rp_Prepara(p_Transaccion
                                                          ,'PEN'
                                                          ,x_Cod_Error
                                                          ,x_Msg_Error);
      END IF;
    */
    --//-----------------------------------------------------------------Termino--\\
  
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => l_Dbg_Mensaje || '.' || x_Cod_Error || '-' || x_Msg_Error);
      x_Cod_Error := 0;
      x_Msg_Error := NULL;
    END IF;
    l_Dbg_Mensaje := 'Obtener informacion trama FM (Fecha Movimientos)';
    l_Trama_Fm    := Scfr_Trx_Gnc_Utl_Pk.Trama_Fm_Prepara(p_Transaccion
                                                         ,p_Transaccion.Rut_Titular
                                                         ,x_Cod_Error
                                                         ,x_Msg_Error);
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => l_Dbg_Mensaje || '.' || x_Cod_Error || '-' || x_Msg_Error);
      x_Cod_Error := 0;
      x_Msg_Error := NULL;
    END IF;
    
    -- INI JAGC NEC 20240909
    l_Dbg_Mensaje := 'Obtener informacion trama IN (Necesidades Salud)';
    Dbms_Output.Put_Line(l_Dbg_Mensaje || ' Id_Json=>' || x_Id_Consulta_Json_Nec);
    IF (Nvl(x_Id_Consulta_Json_Nec
           ,0) <> 0) THEN
      l_Trama_In := Scfr_Necesidades_Salud_Pk.Trama_In_Prepara(p_Transaccion
                                                              ,x_Id_Consulta_Json_Nec
                                                              ,x_Cod_Error
                                                              ,x_Msg_Error);
    END IF;
    -- FIN JAGC NEC 20240909
    
    --    END IF;
    --l_DBG_MENSAJE := 'Obtener informacion trama SC (Saldo/Puntos/Convenios N-POS)';
    --l_trama_sc    := scfr_trx_conv_pk.trama_sc_prepara( p_transaccion, l_convenios, x_cod_error, x_msg_error );
    IF (l_Error_Dp = 0) THEN
      l_Dbg_Mensaje := 'Armar cuerpo TX (trama DP)';
      l_Cuerpo_Tx   := NULL;
      Dbms_Output.Put_Line('ORIGEN=>' || p_Transaccion.Trama_Pos.Origen_Transaccion);
      l_Cuerpo_Tx := Utl_Raw.Concat(l_Cuerpo_Tx
                                   ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Dp(l_Trama_Dp
                                                                     ,p_Transaccion.Trama_Pos.Origen_Transaccion));
    END IF;
    Dbms_Output.Put_Line('x_Id_Consulta_Json=>' || x_Id_Consulta_Json);
    p_Transaccion.Trama_Boc.Codigo_Respuesta := 0;
    IF (x_Id_Consulta_Json <> 0) THEN
      BEGIN
        SELECT Forma_Identificacion INTO l_Forma_Identif_Online FROM Consulta_Cliente_Json WHERE Id = x_Id_Consulta_Json;
      EXCEPTION
        WHEN OTHERS THEN
          l_Forma_Identif_Online := NULL;
      END;
      IF (l_Forma_Identif_Online = 'A') THEN
        Dbms_Output.Put_Line('l_Forma_Identif_Online=>' || l_Forma_Identif_Online);
        l_Dbg_Mensaje := 'Obtener informacion trama MS (Mensajeria)';
        l_Trama_Ms    := Scfr_Trx_Conv_Empresarial_Pk.Trama_Ms_Prepara(p_Transaccion
                                                                      ,x_Id_Consulta_Json
                                                                      ,x_Cod_Error
                                                                      ,x_Msg_Error);
        IF Nvl(x_Cod_Error
              ,0) != 0 THEN
          Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                    ,p_Msg     => l_Dbg_Mensaje || '.' || x_Cod_Error || '-' || x_Msg_Error);
          x_Cod_Error := 0;
          x_Msg_Error := NULL;
        END IF;
      END IF;
    END IF; -- IF (x_Id_Consulta_Json <> 0 ) THEN
  
    l_Dbg_Mensaje := 'Armar cuerpo TX (trama MS)';
    IF l_Trama_Ms.Count > 0 THEN
      l_Cuerpo_Tx := Utl_Raw.Concat(l_Cuerpo_Tx
                                   ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Ms(l_Trama_Ms));
    END IF;
  
    --    IF l_Es_Loyalty = FALSE THEN
    --      l_Dbg_Mensaje := 'Armar cuerpo TX (trama MS)';
    --      IF l_Trama_Ms.Count > 0 THEN
    --        l_Cuerpo_Tx := Utl_Raw.Concat(l_Cuerpo_Tx
    --                                     ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Ms(l_Trama_Ms));
    --      END IF;
    --    END IF;
    --    l_Dbg_Mensaje := 'Armar cuerpo TX (trama PU)';
    --    if l_trama_pu.puntos != 0 then
    -- Verifica si cliente es fidelizado o no
    --    IF l_Es_Loyalty = FALSE THEN
    --      l_Party_Id_Rel := Scfr_Trx_Util_Pk.Busca_Party_Id_Relacion(p_Transaccion.Trama_Boc.Party_Id
    --                                                                ,Scfr_Trx_Util_Pk.Obtiene_Party_Id(Scfr_Trx_Util_Pk.Rut_Con_Org_Id(p_Transaccion.Trama_Pos.Empresa
    --                                                                                                                                  ,Scfr_Trx_Util_Pk.Instancia))
    --                                                                ,'ES_FIDELIZADO'
    --                                                                ,p_Transaccion.Trama_Pos.Empresa
    --                                                                ,l_Id_Relacion);
    --      IF (Nvl(l_Party_Id_Rel
    --             ,0) <= 0) THEN
    --        BEGIN
    --          SELECT Party_Id
    --            INTO l_Party_Id_Rel
    --            FROM Scfr_Tmp_Clientes
    --           WHERE Rut = p_Transaccion.Rut_Titular
    --             AND Inscrito_Mas_Cruz_Verde = 'S';
    --        EXCEPTION
    --          WHEN No_Data_Found THEN
    --            l_Party_Id_Rel := -1;
    --        END;
    --      END IF; -- if (Nvl(l_Party_Id_Rel   ,0) > 0) then
    --    ELSE
    --      l_Party_Id_Rel := 1;
    --    END IF;
    --    IF l_Party_Id_Rel > 0 THEN
    --      l_Cuerpo_Tx := Utl_Raw.Concat(l_Cuerpo_Tx
    --                                   ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Pu(l_Trama_Pu
    --                                                                     ,p_Transaccion.Trama_Pos.Origen_Transaccion));
    --    END IF;
    --    l_Dbg_Mensaje := 'Armar cuerpo TX (trama CA)';
    --    IF l_Trama_Ca.Count > 0 THEN
    --      l_Cuerpo_Tx := Utl_Raw.Concat(l_Cuerpo_Tx
    --                                   ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Ca(l_Trama_Ca
    --                                                                     ,p_Transaccion.Trama_Pos.Origen_Transaccion));
    --    END IF;
    --    l_Dbg_Mensaje := 'Armar cuerpo TX (trama PF)';
    --    IF l_Trama_Pf.Count > 0 THEN
    --      l_Cuerpo_Tx := Utl_Raw.Concat(l_Cuerpo_Tx
    --                                   ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Pf(l_Trama_Pf));
    --    END IF;
    l_Dbg_Mensaje := 'Armar cuerpo TX (trama CF)';
    IF (l_Trama_Cf.Count > 0) AND
       (l_Error_Dp = 0) THEN
      l_Cuerpo_Tx := Utl_Raw.Concat(l_Cuerpo_Tx
                                   ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Cf(l_Trama_Cf));
    END IF;
    --    l_Dbg_Mensaje := 'Armar cuerpo TX (trama CU)';
    --    IF l_Trama_Cu.Count > 0 THEN
    --      l_Cuerpo_Tx := Utl_Raw.Concat(l_Cuerpo_Tx
    --                                   ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Cu(l_Trama_Cu));
    --    END IF;
    --    l_Dbg_Mensaje := 'Armar cuerpo TX (trama CM)';
    --    IF l_Trama_Cm.Count > 0 THEN
    --      l_Cuerpo_Tx := Utl_Raw.Concat(l_Cuerpo_Tx
    --                                   ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Cm(l_Trama_Cm));
    --    END IF;
    --    l_Dbg_Mensaje := 'Armar cuerpo TX (trama HC)';
    --    IF l_Trama_Hc.Count > 0 THEN
    --      l_Cuerpo_Tx := Utl_Raw.Concat(l_Cuerpo_Tx
    --                                   ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Hc(l_Trama_Hc));
    --    END IF;
    --    l_Dbg_Mensaje := 'Armar cuerpo TX (trama CO)';
    
    IF (l_Trama_Co.Count > 0) AND
       (l_Error_Dp = 0) THEN
      l_Cuerpo_Tx := Utl_Raw.Concat(l_Cuerpo_Tx
                                   ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Co(l_Trama_Co
                                                                     ,p_Transaccion.Trama_Pos.Origen_Transaccion));
    END IF;
    --    l_Dbg_Mensaje := 'Armar cuerpo TX (trama RP)';
    --    IF l_Trama_Rp.Count > 0 THEN
    --      l_Cuerpo_Tx := Utl_Raw.Concat(l_Cuerpo_Tx
    --                                   ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Rp(l_Trama_Rp
    --                                                                     ,p_Transaccion.Trama_Pos.Origen_Transaccion));
    --    END IF;
    --    l_Dbg_Mensaje := 'Armar cuerpo TX (trama FM)';
    --    IF l_Trama_Fm.Count > 0 THEN
    --      l_Cuerpo_Tx := Utl_Raw.Concat(l_Cuerpo_Tx
    --                                   ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Fm(l_Trama_Fm));
    --    END IF;
    --l_DBG_MENSAJE := 'Armar cuerpo TX (trama SC)';
    --if l_trama_sc.cantidad_productos > 0 or l_trama_sc.lista_beneficiarios > 0 then
    --  l_cuerpo_tx := utl_raw.concat( l_cuerpo_tx, scfr_trx_dyn_raw_pk.arma_trama_sc( l_trama_sc ) );
    --end if;
    -- Asigna identificacion del cliente
    
    -- INI JAGC NEC 20240909
    --l_Dbg_Mensaje := 'Armar cuerpo TX (trama IN)';
    IF (l_Trama_In.Count > 0) AND
       (l_Error_Dp = 0) THEN
      l_Cuerpo_Tx := Utl_Raw.Concat(l_Cuerpo_Tx
                                   ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_In(l_Trama_In));
    END IF;
    -- FIN JAGC NEC 20240909
    
    l_Dbg_Mensaje := 'Asignar identificacion del cliente';
  
    --    p_Transaccion.Trama_Boc.Forma_Identificacion  := l_Forma_Identifica;
    --    p_Transaccion.Trama_Boc.String_Identificacion := l_String_Identifica;
    --    IF p_Transaccion.Rut_Titular IS NOT NULL THEN
    --      p_Transaccion.Trama_Boc.Forma_Identificacion  := 'R';
    --      p_Transaccion.Trama_Boc.String_Identificacion := To_Char(p_Transaccion.Rut_Titular) || p_Transaccion.Dv_Rut_Titular;
    --    END IF;
    l_Dbg_Mensaje                              := 'Determinar Largo de la trama';
    l_Largo_Ctx                                := Dbms_Lob.Getlength(l_Cuerpo_Tx);
    l_Largo_Tot                                := l_Largo_Ctx + Scfr_Trx_Dyn_Pk.Obtiene_Largo_Trama(Scfr_Trx_Dyn_Pk.k_Trama_Header_Boc);
    l_Dbg_Mensaje                              := 'Armar Respuesta (trama POS)';
    x_Respuesta                                := NULL;
    p_Transaccion.Trama_Pos.Largo_Total_Buffer := l_Largo_Tot;
    x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                ,Scfr_Trx_Dyn_Pk.Arma_Trama_Pos(p_Transaccion));
    l_Dbg_Mensaje                              := 'Armar Respuesta (trama BOC)';
    p_Transaccion.Trama_Boc.Largo_Total_Buffer := l_Largo_Ctx;
    x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                ,Scfr_Trx_Dyn_Pk.Arma_Trama_Boc(p_Transaccion));
    l_Dbg_Mensaje                              := 'Armar Respuesta (cuerpo TX)';
    x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                ,l_Cuerpo_Tx);
    x_Cod_Error                                := 0; -- nunca devuelve un error oracle
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  /*****************************************************************************
  Consulta Generica de Venta. Obtiene informacion relacionada a una venta.
  Parametros Entrada:
    p_transaccion => Transaccion que contiene la peticion de la venta en forma de arreglo
  Parametros Salida:
    x_respuesta   => Transaccion que contiene la venta en formato RAW
    x_cod_error   => Codigo de error, si es que hubo algun problema
    x_msg_error   => Mensaje de error, si es que hubo algun problema
  *****************************************************************************/
  PROCEDURE Gncc02(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Vt  Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vt;
    l_Trama_Db  Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Db;
    l_Trama_Cv  Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv;
    l_Trama_Dv  Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv;
    l_Trama_Pm  Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm;
    l_Trama_Fp  Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Fp;
    l_Trama_Tx  Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tx;
    l_Trama_Rx  Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rx;
    l_Cuerpo_Tx BLOB;
    l_Resultado NUMBER;
    l_Largo_Ctx NUMBER;
  
    l_Largo_Tot         NUMBER;
    l_Itm               NUMBER;
    l_Dbg_Proceso       VARCHAR2(100) := 'SCFR_TRX_GNC_PK.gncc02';
    l_Dbg_Mensaje       VARCHAR2(250) := 'Error General';
    l_Error_Controlado  EXCEPTION;
    l_Fecha_Tx_Original DATE;
  BEGIN
    -- Obtiene informacion de la trama vt
    l_Dbg_Mensaje := 'Obtener informacion de la trama VT';
    l_Trama_Vt    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Vt(p_Transaccion.Cuerpo_Tx);
    BEGIN
      SELECT Trunc(t.Fecha_Tx)
        INTO l_Fecha_Tx_Original
        FROM Scfr_Mov_Transacciones  t
            ,Scfr_Mov_Documentos_Txs d
       WHERE t.Codigo_Tx = d.Txo_Codigo_Tx
         AND d.Folio = l_Trama_Vt.Folio
         AND d.Loc_Local = l_Trama_Vt.Local
         AND d.Tmo_Movimiento = l_Trama_Vt.Tipo_Movimiento_Hijo;
    EXCEPTION
      WHEN No_Data_Found THEN
        BEGIN
          SELECT Trunc(t.Fecha_Tx)
            INTO l_Fecha_Tx_Original
            FROM Batc_Mov_Transacciones  t
                ,Batc_Mov_Documentos_Txs d
           WHERE t.Codigo_Tx = d.Txo_Codigo_Tx
             AND d.Folio = l_Trama_Vt.Folio
             AND d.Loc_Local = l_Trama_Vt.Local
             AND d.Tmo_Movimiento = l_Trama_Vt.Tipo_Movimiento_Hijo;
        EXCEPTION
          WHEN OTHERS THEN
            l_Fecha_Tx_Original := NULL;
        END;
      WHEN OTHERS THEN
        l_Fecha_Tx_Original := NULL;
    END;
    -- ajuste 28-08-2007 para que no vaya al batc
    --  l_fecha_tx_original := trunc( Scfr_Trx_Util_Pk.get_sysdate + 1 );
    -- fin ajuste
    -- Valida que el Documento corresponda al mismo due?o del local
    IF Scfr_Trx_Gnc_Utl_Pk.Dueno_Local(p_Transaccion.Trama_Pos.Empresa
                                      ,p_Transaccion.Trama_Pos.Cadena
                                      ,l_Trama_Vt.Local) <>
       Scfr_Trx_Gnc_Utl_Pk.Dueno_Local(p_Transaccion.Trama_Pos.Empresa
                                      ,p_Transaccion.Trama_Pos.Cadena
                                      ,p_Transaccion.Trama_Pos.Local) THEN
      p_Transaccion.Trama_Boc.Codigo_Respuesta := 11;
    END IF;
    -- Obtener documentos
    l_Dbg_Mensaje := 'Preparar datos para armar trama DV';
    IF l_Fecha_Tx_Original < Trunc(Scfr_Trx_Util_Pk.Get_Sysdate) THEN
      -- Intentar prepara la informacion desde BATC
      Batc_Trx_Gnc_Pk.Gncc02(p_Transaccion
                            ,x_Respuesta
                            ,x_Cod_Error
                            ,x_Msg_Error);
    ELSE
      l_Trama_Dv := Trama_Dv_Prepara(p_Transaccion
                                    ,l_Trama_Vt
                                    ,x_Cod_Error
                                    ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
      IF l_Trama_Dv.Subtrama_Dv1.Count = 0 THEN
        -- Intentar prepara la informacion desde BATC
        Batc_Trx_Gnc_Pk.Gncc02(p_Transaccion
                              ,x_Respuesta
                              ,x_Cod_Error
                              ,x_Msg_Error);
      ELSE
        l_Dbg_Mensaje := 'Preparar datos para armar trama DV';
        l_Trama_Dv    := Trama_Dv_Prepara(p_Transaccion
                                         ,l_Trama_Vt
                                         ,x_Cod_Error
                                         ,x_Msg_Error);
        IF Nvl(x_Cod_Error
              ,0) != 0 THEN
          RAISE l_Error_Controlado;
        END IF;
        IF l_Trama_Dv.Subtrama_Dv1.Count = 0 THEN
          -- No se encontro documento y se debe informar al POS.
          l_Dbg_Mensaje                              := 'Armar Respuesta (trama POS)';
          l_Largo_Tot                                := Scfr_Trx_Dyn_Pk.Obtiene_Largo_Trama(Scfr_Trx_Dyn_Pk.k_Trama_Header_Boc);
          x_Respuesta                                := NULL;
          p_Transaccion.Trama_Pos.Largo_Total_Buffer := l_Largo_Tot;
          x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                      ,Scfr_Trx_Dyn_Pk.Arma_Trama_Pos(p_Transaccion));
          l_Dbg_Mensaje                              := 'Armar Respuesta (trama BOC)';
          p_Transaccion.Trama_Boc.Codigo_Respuesta   := 7;
          p_Transaccion.Trama_Boc.Largo_Total_Buffer := 0;
          x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                      ,Scfr_Trx_Dyn_Pk.Arma_Trama_Boc(p_Transaccion)); -- largo ctx
          RETURN;
        END IF;
        l_Dbg_Mensaje := 'Preparar datos para armar trama DB';
        l_Trama_Db    := Trama_Db_Prepara(p_Transaccion
                                         ,l_Trama_Vt
                                         ,x_Cod_Error
                                         ,x_Msg_Error);
        IF Nvl(x_Cod_Error
              ,0) != 0 THEN
          RAISE l_Error_Controlado;
        END IF;
        l_Dbg_Mensaje := 'Preparar datos para armar trama CV';
        l_Trama_Cv    := Trama_Cv_Prepara(p_Transaccion
                                         ,l_Trama_Vt
                                         ,x_Cod_Error
                                         ,x_Msg_Error);
        IF Nvl(x_Cod_Error
              ,0) != 0 THEN
          RAISE l_Error_Controlado;
        END IF;
        l_Dbg_Mensaje := 'Preparar datos para armar trama PM';
        l_Trama_Pm    := Trama_Pm_Prepara(p_Transaccion
                                         ,l_Trama_Vt
                                         ,x_Cod_Error
                                         ,x_Msg_Error);
        IF Nvl(x_Cod_Error
              ,0) != 0 THEN
          RAISE l_Error_Controlado;
        END IF;
        l_Dbg_Mensaje := 'Preparar datos para armar trama FP';
        l_Trama_Fp    := Trama_Fp_Prepara(p_Transaccion
                                         ,x_Cod_Error
                                         ,x_Msg_Error);
        IF Nvl(x_Cod_Error
              ,0) != 0 THEN
          RAISE l_Error_Controlado;
        END IF;
        l_Dbg_Mensaje := 'Armar cuerpo TX (trama DB)';
        l_Cuerpo_Tx   := NULL;
        IF Nvl(l_Trama_Db(1).Rut_Beneficiario
              ,0) != 0 THEN
          l_Cuerpo_Tx := Utl_Raw.Concat(l_Cuerpo_Tx
                                       ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Db(l_Trama_Db));
        END IF;
        l_Dbg_Mensaje := 'Armar cuerpo TX (trama CV)';
        IF l_Trama_Cv.Count > 0 THEN
          l_Cuerpo_Tx := Utl_Raw.Concat(l_Cuerpo_Tx
                                       ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Cv(l_Trama_Cv
                                                                         ,p_Transaccion.Trama_Pos.Origen_Transaccion));
        END IF;
        l_Dbg_Mensaje := 'Armar cuerpo TX (trama DV)';
        l_Cuerpo_Tx   := Utl_Raw.Concat(l_Cuerpo_Tx
                                       ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Dv(l_Trama_Dv
                                                                         ,p_Transaccion.Trama_Pos.Origen_Transaccion));
        l_Dbg_Mensaje := 'Armar cuerpo TX (trama PM)';
        IF l_Trama_Pm.Count > 0 THEN
          l_Cuerpo_Tx := Utl_Raw.Concat(l_Cuerpo_Tx
                                       ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Pm(l_Trama_Pm
                                                                         ,p_Transaccion.Trama_Pos.Origen_Transaccion));
        ELSE
          p_Transaccion.Trama_Boc.Codigo_Respuesta := 7;
        END IF;
        l_Dbg_Mensaje := 'Armar cuerpo TX (trama FP)';
        IF l_Trama_Fp.Count > 0 THEN
          l_Cuerpo_Tx := Utl_Raw.Concat(l_Cuerpo_Tx
                                       ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Fp(l_Trama_Fp
                                                                         ,p_Transaccion.Trama_Pos.Origen_Transaccion));
        ELSE
          p_Transaccion.Trama_Boc.Codigo_Respuesta := 7;
        END IF;
        -- Asigna identificacion del cliente
        l_Dbg_Mensaje                                 := 'Asigna identificacion del cliente';
        p_Transaccion.Trama_Boc.Forma_Identificacion  := 'S';
        p_Transaccion.Trama_Boc.String_Identificacion := ' ';
        IF p_Transaccion.Rut_Titular IS NOT NULL THEN
          p_Transaccion.Trama_Boc.Forma_Identificacion  := 'R';
          p_Transaccion.Trama_Boc.String_Identificacion := To_Char(p_Transaccion.Rut_Titular) || p_Transaccion.Dv_Rut_Titular;
        END IF;
        l_Dbg_Mensaje                              := 'Determinar Largos de la trama';
        l_Largo_Ctx                                := Dbms_Lob.Getlength(l_Cuerpo_Tx);
        l_Largo_Tot                                := l_Largo_Ctx + Scfr_Trx_Dyn_Pk.Obtiene_Largo_Trama(Scfr_Trx_Dyn_Pk.k_Trama_Header_Boc);
        l_Dbg_Mensaje                              := 'Armar Respuesta (trama POS)';
        x_Respuesta                                := NULL;
        p_Transaccion.Trama_Pos.Largo_Total_Buffer := l_Largo_Tot;
        x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                    ,Scfr_Trx_Dyn_Pk.Arma_Trama_Pos(p_Transaccion));
        l_Dbg_Mensaje                              := 'Armar Respuesta (trama BOC)';
        IF p_Transaccion.Trama_Boc.Codigo_Respuesta NOT IN (11
                                                           ,7) THEN
          p_Transaccion.Trama_Boc.Codigo_Respuesta := 0;
        END IF;
        p_Transaccion.Trama_Boc.Largo_Total_Buffer := l_Largo_Ctx;
        x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                    ,Scfr_Trx_Dyn_Pk.Arma_Trama_Boc(p_Transaccion));
        l_Dbg_Mensaje                              := 'Armar Respuesta (cuerpo TX)';
        x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                    ,l_Cuerpo_Tx);
      END IF;
    END IF;
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  /*****************************************************************************
  Consulta de Recaudacion. Obtiene informacion relacionada a una recaudacion.
  Parametros Entrada:
    p_transaccion => Transaccion que contiene la peticion de la racaudacion en forma de arreglo
  Parametros Salida:
    x_respuesta   => Transaccion que contiene la recaudacion en formato RAW
    x_cod_error   => Codigo de error, si es que hubo algun problema
    x_msg_error   => Mensaje de error, si es que hubo algun problema
  *****************************************************************************/
  PROCEDURE Gncc03(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Dh           Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dh;
    l_Trama_Cv           Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv;
    l_Trama_Fp           Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Fp;
    l_Trama_Tx           Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tx;
    l_Trama_Rx           Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rx;
    l_Trama_Dr           Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dr;
    l_Trama_Pm           Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm;
    l_Trama_Vt           Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vt;
    l_Cuerpo_Tx          BLOB;
    l_Largo_Ctx          NUMBER;
    l_Largo_Tot          NUMBER;
    l_Largo_t            NUMBER;
    l_Largo_Reg          NUMBER;
    l_Local_Recaudacion  NUMBER;
    l_Rut_Tit            VARCHAR2(10);
    l_Party_Id           Scfr_Mov_Transacciones.Pt_Party_Id_Titular%TYPE;
    l_Transaccion        Pkg_Com_Transacciones_Locales.Refcursor;
    i                    NUMBER;
    l_Codigo_Servicio    VARCHAR2(4);
    l_Local              NUMBER;
    l_Numero_Pos         NUMBER;
    l_Destino            VARCHAR2(4);
    l_Sistema            VARCHAR2(3);
    l_Funcion            VARCHAR2(1);
    l_Secuencia_c        VARCHAR2(2);
    l_Fecha_Date         DATE;
    l_Codigo_Tx          NUMBER;
    l_Numero_Trama       NUMBER;
    l_Correlativo        NUMBER;
    l_Nulos              VARCHAR2(10);
    l_Version_Primaria   NUMBER;
    l_Version_Secundaria NUMBER;
    l_Tx_Timestamp       TIMESTAMP;
    l_Rx_Timestamp       TIMESTAMP;
    l_Tx_Pos             BLOB;
    l_Rx_Pos             BLOB;
    l_Largo_Buffers      NUMBER;
    l_Resultado          NUMBER;
    l_Dbg_Proceso        VARCHAR2(100) := 'SCFR_TRX_GNC_PK.GNCC03';
    l_Dbg_Mensaje        VARCHAR2(250) := 'Error General';
    l_Error_Controlado   EXCEPTION;
    l_Correlativo_Tx     VARCHAR2(50);
    l_Local_Tx           VARCHAR2(50);
    l_Fecha_Tx_Original  DATE;
  BEGIN
    --  consulta recaudacion
    IF p_Transaccion.Trama_Boc.Forma_Identificacion <> 'S' THEN
      l_Dbg_Mensaje := 'Validacion l_party_id consulta avances';
      l_Resultado   := Scfr_Trx_Fid_Pk.Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                                          ,p_Transaccion.Trama_Boc.String_Identificacion
                                                          ,p_Transaccion.Trama_Pos.Empresa
                                                          ,p_Transaccion.Trama_Pos.Cadena
                                                          ,p_Transaccion.Trama_Boc.Party_Id);
      IF l_Resultado != 0 THEN
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
        x_Cod_Error := l_Resultado;
      END IF;
    END IF;
    l_Dbg_Mensaje := 'Obtener informacion trama DH (Docto. de Rec. a consultar)';
    l_Largo_Tot   := Scfr_Trx_Dyn_Pk.Obtiene_Largo_Trama(Scfr_Trx_Dyn_Pk.k_Trama_Header_Boc);
    l_Trama_Dh    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Dh(p_Transaccion.Cuerpo_Tx);
    IF Nvl(l_Trama_Dh.Local
          ,0) = 0 THEN
      IF Nvl(p_Transaccion.Trama_Pos.Origen_Transaccion
            ,'POS') IN ('OTN') THEN
        l_Local_Tx := To_Number(Substr(l_Trama_Dh.Ot
                                      ,5
                                      ,5));
      ELSE
        l_Local_Tx := To_Number(Substr(l_Trama_Dh.Ot
                                      ,6
                                      ,3));
      END IF;
    ELSE
      l_Local_Tx := l_Trama_Dh.Local;
    END IF;
    BEGIN
      IF Nvl(l_Trama_Dh.Correlativo_Tx
            ,0) = 0 THEN
        SELECT Txo_Correlativo_Tx
          INTO l_Correlativo_Tx
          FROM Scfr_Mov_Documentos_Txs
         WHERE Pin_Ot_Recetario = l_Trama_Dh.Ot
           AND Tmo_Movimiento = 'RECRMA';
      ELSE
        l_Correlativo_Tx := l_Trama_Dh.Correlativo_Tx;
      END IF;
      SELECT Trunc(Fecha_Tx)
        INTO l_Fecha_Tx_Original
        FROM Scfr_Mov_Transacciones
       WHERE (Correlativo_Tx = l_Correlativo_Tx OR Codigo_Autorizacion_Tx = l_Trama_Dh.Ot)
         AND Loc_Local = l_Local_Tx
         AND Tmo_Movimiento_Padre = 'RECAUD'
         AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa;
    EXCEPTION
      WHEN No_Data_Found THEN
        BEGIN
          IF Nvl(l_Trama_Dh.Correlativo_Tx
                ,0) = 0 THEN
            SELECT Txo_Correlativo_Tx
              INTO l_Correlativo_Tx
              FROM Batc_Mov_Documentos_Txs
             WHERE Pin_Ot_Recetario = l_Trama_Dh.Ot
               AND Tmo_Movimiento = 'RECRMA';
          ELSE
            l_Correlativo_Tx := l_Trama_Dh.Correlativo_Tx;
          END IF;
          SELECT Trunc(Fecha_Tx)
            INTO l_Fecha_Tx_Original
            FROM Batc_Mov_Transacciones
           WHERE (Correlativo_Tx = l_Correlativo_Tx OR Codigo_Autorizacion_Tx = l_Trama_Dh.Ot)
             AND Loc_Local = l_Local_Tx
             AND Tmo_Movimiento_Padre = 'RECAUD'
             AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa;
        EXCEPTION
          WHEN OTHERS THEN
            l_Fecha_Tx_Original := NULL;
        END;
      WHEN OTHERS THEN
        l_Fecha_Tx_Original := NULL;
    END;
    -- ajuste 28-08-2007 para que no vaya al batc
    --  l_fecha_tx_original := trunc( Scfr_Trx_Util_Pk.get_sysdate + 1 );
    -- fin ajuste
    IF Nvl(x_Cod_Error
          ,0) = 0 THEN
      l_Dbg_Mensaje := 'Preparar datos trama DR (Documento de recaudacion)';
      IF l_Fecha_Tx_Original < Trunc(Scfr_Trx_Util_Pk.Get_Sysdate) THEN
        -- Intentar prepara la informacion desde BATC
        Batc_Trx_Gnc_Pk.Gncc03(p_Transaccion
                              ,x_Respuesta
                              ,x_Cod_Error
                              ,x_Msg_Error);
      ELSE
        l_Trama_Dr := Trama_Dr_Prepara(p_Transaccion
                                      ,x_Cod_Error
                                      ,x_Msg_Error);
        IF l_Trama_Dr.Subtrama_Dr1.Count = 0 THEN
          Batc_Trx_Gnc_Pk.Gncc03(p_Transaccion
                                ,x_Respuesta
                                ,x_Cod_Error
                                ,x_Msg_Error);
        ELSE
          IF Nvl(x_Cod_Error
                ,0) NOT IN (0
                           ,7) THEN
            RAISE l_Error_Controlado;
          ELSE
            l_Dbg_Mensaje := 'Preparar datos trama FP (formas de pago)';
            l_Trama_Fp    := Trama_Fp_Prepara(p_Transaccion
                                             ,x_Cod_Error
                                             ,x_Msg_Error);
            IF Nvl(x_Cod_Error
                  ,0) != 0 THEN
              RAISE l_Error_Controlado;
            END IF;
          END IF;
          l_Dbg_Mensaje := 'Preparar datos para armar trama CV';
          l_Trama_Cv    := Trama_Cv_Prepara(p_Transaccion
                                           ,l_Trama_Vt
                                           ,x_Cod_Error
                                           ,x_Msg_Error);
          IF Nvl(x_Cod_Error
                ,0) != 0 THEN
            RAISE l_Error_Controlado;
          END IF;
          l_Dbg_Mensaje := 'Preparar datos para armar trama PM';
          l_Trama_Pm    := Trama_Pm_Prepara(p_Transaccion
                                           ,l_Trama_Vt
                                           ,x_Cod_Error
                                           ,x_Msg_Error);
          IF Nvl(x_Cod_Error
                ,0) != 0 THEN
            RAISE l_Error_Controlado;
          END IF;
          l_Dbg_Mensaje := 'Obtener parametros para llamar a PKG_COM_TRANSACCIONES_LOCALES.Obtener_Transaccion()';
          BEGIN
            l_Correlativo_Tx := l_Trama_Dh.Correlativo_Tx;
            l_Local_Tx       := l_Trama_Dh.Local;
            IF Nvl(l_Trama_Dh.Correlativo_Tx
                  ,0) = 0 THEN
              SELECT Txo_Correlativo_Tx
                    ,Loc_Local
                INTO l_Correlativo_Tx
                    ,l_Local_Tx
                FROM Scfr_Mov_Documentos_Txs
               WHERE Pin_Ot_Recetario = l_Trama_Dh.Ot
                 AND Tmo_Movimiento = 'RECRMA';
            END IF;
            SELECT Estx_Srv_Codigo
                  ,Estx_Numero_Local
                  ,Estx_Numero_Pos
                  ,Estx_Destino
                  ,Estx_Sistema
                  ,Estx_Funcion
                  ,Estx_Secuencia
                  ,Estx_Fecha
                  ,Estx_Correlativo
                  ,Estx_Numero_Trama
                  ,Codigo_Tx
                  ,Rut_Titular || Dv_Titular
              INTO l_Codigo_Servicio
                  ,l_Local
                  ,l_Numero_Pos
                  ,l_Destino
                  ,l_Sistema
                  ,l_Funcion
                  ,l_Secuencia_c
                  ,l_Fecha_Date
                  ,l_Correlativo
                  ,l_Numero_Trama
                  ,l_Codigo_Tx
                  ,l_Rut_Tit
              FROM Scfr_Mov_Transacciones
             WHERE Correlativo_Tx = l_Correlativo_Tx
               AND Loc_Local = l_Local_Tx
               AND Tmo_Movimiento_Padre = 'RECAUD'
               AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
               AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena;
            l_Dbg_Mensaje := 'Obtener datos de las transacciones TX/RX desde PKG_COM_TRANSACCIONES_LOCALES.Obtener_Transaccion()';
            IF l_Codigo_Servicio = 'BOC' THEN
              Pkg_Com_Transacciones_Clientes.Obtener_Transaccion(l_Codigo_Servicio
                                                                ,l_Local
                                                                ,l_Numero_Pos
                                                                ,l_Destino
                                                                ,l_Sistema
                                                                ,l_Funcion
                                                                ,l_Secuencia_c
                                                                ,l_Fecha_Date
                                                                ,l_Codigo_Tx
                                                                ,l_Numero_Trama
                                                                ,l_Transaccion
                                                                ,x_Cod_Error
                                                                ,x_Msg_Error);
            ELSE
              Pkg_Com_Transacciones_Clientes.Obtener_Transaccion(l_Codigo_Servicio
                                                                ,l_Local
                                                                ,l_Numero_Pos
                                                                ,l_Funcion
                                                                ,l_Fecha_Date
                                                                ,l_Codigo_Tx
                                                                ,l_Transaccion
                                                                ,x_Cod_Error
                                                                ,x_Msg_Error);
            END IF;
            IF Nvl(x_Cod_Error
                  ,0) != 0 THEN
              Raise_Application_Error(-20000
                                     ,'Error ' || x_Cod_Error || '-' || x_Msg_Error);
            END IF;
            IF l_Transaccion%ROWCOUNT > 0 THEN
              i := 0;
              LOOP
                i             := i + 1;
                l_Dbg_Mensaje := 'Leer Transaccion TX ';
                FETCH l_Transaccion
                  INTO l_Version_Primaria
                      ,l_Version_Secundaria
                      ,l_Tx_Timestamp
                      ,l_Rx_Timestamp
                      ,l_Tx_Pos
                      ,l_Rx_Pos
                      ,l_Trama_Tx          (i).Tx_Respuesta
                      ,l_Trama_Tx          (i).Tx_No_Enrutada
                      ,l_Trama_Tx          (i).Tx_No_Existe
                      ,l_Trama_Tx          (i).Tx_Timeout
                      ,l_Trama_Tx          (i).Tx_Erronea
                      ,l_Trama_Tx          (i).Tx_Expirada
                      ,l_Trama_Tx          (i).Tx_Online
                      ,l_Trama_Tx          (i).Tx_Confirmada
                      ,l_Trama_Tx          (i).Tx_Nack
                      ,l_Trama_Rx          (i).Rx_Ack
                      ,l_Trama_Rx          (i).Rx_Nack
                      ,l_Trama_Rx          (i).Rx_Timeout
                      ,l_Trama_Rx          (i).Rx_Erronea
                      ,l_Trama_Rx          (i).Rx_Con_Servicio
                      ,l_Trama_Rx          (i).Rx_Sin_Servicio;
                l_Trama_Tx(i).Codigo_Servicio := l_Codigo_Servicio;
                l_Trama_Tx(i).Timespan := To_Number(To_Char(l_Tx_Timestamp
                                                           ,'yyyymmdd'));
                l_Trama_Rx(i).Timespan := To_Number(To_Char(l_Rx_Timestamp
                                                           ,'yyyymmdd'));
                l_Trama_Tx(i).Tx := Scfr_Trx_Util_Pk.Bin2num(l_Tx_Pos);
                l_Trama_Rx(i).Rx := Scfr_Trx_Util_Pk.Bin2num(l_Rx_Pos);
                l_Trama_Tx(i).Codigo_Servicio := l_Codigo_Servicio;
                EXIT WHEN l_Transaccion%NOTFOUND;
              END LOOP;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                        ,l_Dbg_Mensaje);
              x_Cod_Error := SQLCODE;
              x_Msg_Error := SQLERRM;
              x_Cod_Error := 7;
          END;
          l_Cuerpo_Tx   := NULL;
          l_Dbg_Mensaje := 'Armar cuerpo TX (trama DR)';
          l_Cuerpo_Tx   := Utl_Raw.Concat(l_Cuerpo_Tx
                                         ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Dr(l_Trama_Dr
                                                                           ,p_Transaccion.Trama_Pos.Origen_Transaccion));
          l_Dbg_Mensaje := 'Armar cuerpo TX (trama FP)';
          IF l_Trama_Fp.Count > 0 THEN
            l_Cuerpo_Tx := Utl_Raw.Concat(l_Cuerpo_Tx
                                         ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Fp(l_Trama_Fp
                                                                           ,p_Transaccion.Trama_Pos.Origen_Transaccion));
          ELSE
            p_Transaccion.Trama_Boc.Codigo_Respuesta := 7;
          END IF;
          l_Dbg_Mensaje := 'Armar cuerpo TX (trama CV)';
          IF l_Trama_Cv.Count > 0 THEN
            l_Cuerpo_Tx := Utl_Raw.Concat(l_Cuerpo_Tx
                                         ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Cv(l_Trama_Cv
                                                                           ,p_Transaccion.Trama_Pos.Origen_Transaccion));
          END IF;
          l_Dbg_Mensaje := 'Armar cuerpo TX (trama PM)';
          l_Cuerpo_Tx   := Utl_Raw.Concat(l_Cuerpo_Tx
                                         ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Pm(l_Trama_Pm
                                                                           ,p_Transaccion.Trama_Pos.Origen_Transaccion));
          l_Dbg_Mensaje := 'Armar cuerpo TX (trama TX)';
          IF l_Trama_Tx.Count > 0 THEN
            l_Cuerpo_Tx := Utl_Raw.Concat(l_Cuerpo_Tx
                                         ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Tx(l_Trama_Tx));
          END IF;
          l_Dbg_Mensaje := 'Armar cuerpo TX (trama RX)';
          IF l_Trama_Rx.Count > 0 THEN
            l_Cuerpo_Tx := Utl_Raw.Concat(l_Cuerpo_Tx
                                         ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Rx(l_Trama_Rx));
          END IF;
          l_Dbg_Mensaje                                 := 'Determina el largo de la trama';
          l_Largo_Ctx                                   := Dbms_Lob.Getlength(l_Cuerpo_Tx);
          l_Largo_Tot                                   := l_Largo_Ctx + Scfr_Trx_Dyn_Pk.Obtiene_Largo_Trama(Scfr_Trx_Dyn_Pk.k_Trama_Header_Boc);
          x_Respuesta                                   := NULL;
          p_Transaccion.Trama_Pos.Largo_Total_Buffer    := l_Largo_Tot;
          l_Dbg_Mensaje                                 := 'Armar Respuesta (trama POS)';
          x_Respuesta                                   := Utl_Raw.Concat(x_Respuesta
                                                                         ,Scfr_Trx_Dyn_Pk.Arma_Trama_Pos(p_Transaccion));
          l_Dbg_Mensaje                                 := 'Armar Respuesta (trama BOC)';
          p_Transaccion.Trama_Boc.Forma_Identificacion  := 'R';
          p_Transaccion.Trama_Boc.String_Identificacion := l_Rut_Tit;
          p_Transaccion.Trama_Boc.Largo_Total_Buffer    := l_Largo_Ctx;
          IF p_Transaccion.Trama_Boc.Codigo_Respuesta NOT IN (11
                                                             ,7) THEN
            p_Transaccion.Trama_Boc.Codigo_Respuesta := 0;
          END IF;
          x_Respuesta   := Utl_Raw.Concat(x_Respuesta
                                         ,Scfr_Trx_Dyn_Pk.Arma_Trama_Boc(p_Transaccion));
          l_Dbg_Mensaje := 'Armar Respuesta (cuerpo TX)';
          x_Respuesta   := Utl_Raw.Concat(x_Respuesta
                                         ,l_Cuerpo_Tx);
          Dbms_Output.Put_Line(l_Dbg_Mensaje);
        END IF; --l_trama_dr.subtrama_dr1.count = 0
      END IF; --trunc( p_transaccion.fecha_tx ) < trunc( sysdate )
    END IF; --nvl(x_cod_error,0) = 0
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Gncc04(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Vc          Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vc;
    l_Trama_Vd          Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vd;
    l_Trama_Tx          Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tx;
    l_Trama_Rx          Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rx;
    l_Trama_Fp          Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Fp;
    l_Codigo_Tx         NUMBER;
    l_Largo_Tot         NUMBER;
    l_Largo_To          NUMBER;
    l_Fecha_Vd          DATE;
    l_Resultado         NUMBER;
    l_Salida1           BLOB;
    l_Salida2           BLOB;
    l_Salida3           BLOB;
    l_Salida4           BLOB;
    l_Fecha_Tx_Original DATE;
    CURSOR c_Documentos IS
      SELECT Secuencia
            ,Tmo_Movimiento Tipo_Mov_Hijo
            ,Nvl(Anulado
                ,' ') Anulado
            ,Nvl(Monto
                ,0) + Nvl(Iva
                         ,0) Total
        FROM Scfr_Mov_Documentos_Txs
       WHERE Txo_Codigo_Tx = l_Codigo_Tx
       ORDER BY Secuencia;
    r                  c_Documentos%ROWTYPE;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.GNCC04';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    --********************************************************************
    --           Consulta de avances
    --********************************************************************
    IF p_Transaccion.Trama_Boc.Forma_Identificacion <> 'S' THEN
      l_Dbg_Mensaje := 'Validacion l_party_id consulta avances';
      l_Resultado   := Scfr_Trx_Fid_Pk.Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                                          ,p_Transaccion.Trama_Boc.String_Identificacion
                                                          ,p_Transaccion.Trama_Pos.Empresa
                                                          ,p_Transaccion.Trama_Pos.Cadena
                                                          ,p_Transaccion.Trama_Boc.Party_Id);
      IF l_Resultado != 0 THEN
        x_Cod_Error := l_Resultado;
        x_Msg_Error := 'Error de Valida Party_id en transaccion';
        RAISE l_Error_Controlado;
      END IF;
    END IF;
    l_Largo_Tot := Scfr_Trx_Dyn_Pk.Obtiene_Largo_Trama(Scfr_Trx_Dyn_Pk.k_Trama_Header_Boc);
    l_Trama_Vc  := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Vc(p_Transaccion.Cuerpo_Tx);
    BEGIN
      SELECT Trunc(Fecha_Tx)
        INTO l_Fecha_Tx_Original
        FROM Scfr_Mov_Transacciones
       WHERE Correlativo_Tx = l_Trama_Vc.Correlativo_Tx
         AND Loc_Local = l_Trama_Vc.Local
         AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa;
    EXCEPTION
      WHEN No_Data_Found THEN
        BEGIN
          SELECT Trunc(Fecha_Tx)
            INTO l_Fecha_Tx_Original
            FROM Batc_Mov_Transacciones
           WHERE Correlativo_Tx = l_Trama_Vc.Correlativo_Tx
             AND Loc_Local = l_Trama_Vc.Local
             AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa;
        EXCEPTION
          WHEN OTHERS THEN
            l_Fecha_Tx_Original := NULL;
        END;
      WHEN OTHERS THEN
        l_Fecha_Tx_Original := NULL;
    END;
    -- ajuste 28-08-2007 para que no vaya al batc
    --  l_fecha_tx_original := trunc( Scfr_Trx_Util_Pk.get_sysdate + 1 );
    -- fin ajuste
    IF l_Fecha_Tx_Original < Trunc(Scfr_Trx_Util_Pk.Get_Sysdate) THEN
      -- Intentar prepara la informacion desde BATC
      Batc_Trx_Gnc_Pk.Gncc04(p_Transaccion
                            ,x_Respuesta
                            ,x_Cod_Error
                            ,x_Msg_Error);
    ELSE
      l_Trama_Vd := Trama_Vd_Prepara(p_Transaccion
                                    ,l_Fecha_Vd
                                    ,x_Cod_Error
                                    ,x_Msg_Error);
      IF l_Trama_Vd.Subtrama_Vd1.Count = 0 THEN
        Batc_Trx_Gnc_Pk.Gncc04(p_Transaccion
                              ,x_Respuesta
                              ,x_Cod_Error
                              ,x_Msg_Error);
      ELSE
        IF Nvl(x_Cod_Error
              ,0) != 0 THEN
          l_Dbg_Mensaje                              := 'No existe datos del avance trama VD';
          x_Respuesta                                := NULL;
          p_Transaccion.Trama_Pos.Largo_Total_Buffer := l_Largo_Tot;
          x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                      ,Scfr_Trx_Dyn_Pk.Arma_Trama_Pos(p_Transaccion));
          l_Dbg_Mensaje                              := 'Armando Trama Del Boc';
          p_Transaccion.Trama_Boc.Codigo_Respuesta   := 1;
          p_Transaccion.Trama_Boc.Largo_Total_Buffer := 0;
          x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                      ,Scfr_Trx_Dyn_Pk.Arma_Trama_Boc(p_Transaccion));
        END IF;
        l_Salida1     := Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Vd(l_Trama_Vd);
        l_Dbg_Mensaje := 'Obtengo transaciones Formas de Pagos FP';
        l_Trama_Fp    := Trama_Fp_Prepara(p_Transaccion
                                         ,x_Cod_Error
                                         ,x_Msg_Error);
        l_Dbg_Mensaje := 'Preparo la salida trama FP ';
        l_Salida2     := Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Fp(l_Trama_Fp
                                                          ,p_Transaccion.Trama_Pos.Origen_Transaccion);
        l_Dbg_Mensaje := 'Obtengo transaciones pkg_com_transacciones_locales';
        Trama_Rx_Tx_Prepara(p_Transaccion
                           ,l_Trama_Vd
                           ,l_Fecha_Vd
                           ,l_Trama_Tx
                           ,l_Trama_Rx
                           ,x_Cod_Error
                           ,x_Msg_Error);
        IF Nvl(x_Cod_Error
              ,0) != 0 THEN
          RAISE l_Error_Controlado;
        END IF;
        l_Dbg_Mensaje := 'Preparo la salida trama tx ';
        l_Salida3     := Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Tx(l_Trama_Tx);
        l_Dbg_Mensaje := 'Preparo la salida trama RX ';
        l_Salida4     := Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Rx(l_Trama_Rx);
        l_Dbg_Mensaje := 'Calcula Largo total';
        Dbms_Output.Put_Line(l_Dbg_Mensaje);
        SELECT Nvl(Length(l_Salida1)
                  ,0) + Nvl(Length(l_Salida2)
                           ,0)
        --          nvl(length(l_salida3),0) +
        --          nvl(length(l_salida4),0)
          INTO l_Largo_To
          FROM Dual;
        Dbms_Output.Put_Line(l_Dbg_Mensaje || ' ' || l_Largo_To);
        l_Dbg_Mensaje := 'Armando Trama Del POS';
        Dbms_Output.Put_Line(l_Dbg_Mensaje);
        x_Respuesta                                := NULL;
        p_Transaccion.Trama_Pos.Largo_Total_Buffer := l_Largo_Tot + l_Largo_To;
        x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                    ,Scfr_Trx_Dyn_Pk.Arma_Trama_Pos(p_Transaccion));
        p_Transaccion.Trama_Boc.Codigo_Respuesta   := 0;
        p_Transaccion.Trama_Boc.Largo_Total_Buffer := l_Largo_To;
        x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                    ,Scfr_Trx_Dyn_Pk.Arma_Trama_Boc(p_Transaccion));
        l_Dbg_Mensaje                              := 'Armando Cuerpo VD';
        Dbms_Output.Put_Line(l_Dbg_Mensaje);
        x_Respuesta   := Utl_Raw.Concat(x_Respuesta
                                       ,l_Salida1);
        l_Dbg_Mensaje := 'Armando Cuerpo FP';
        Dbms_Output.Put_Line(l_Dbg_Mensaje);
        x_Respuesta   := Utl_Raw.Concat(x_Respuesta
                                       ,l_Salida2);
        l_Dbg_Mensaje := 'Armando Cuerpo TX';
        /*    if nvl(l_salida3,'V') != 'V' then
              dbms_output.put_line(l_dbg_mensaje);
              x_respuesta:= utl_raw.CONCAT(x_respuesta,l_salida3);
           end if;
        
           l_DBG_MENSAJE := 'Armando Cuerpo RX';
           if nvl(l_salida4,'V') != 'V' then
              dbms_output.put_line(l_dbg_mensaje);
              x_respuesta := utl_raw.CONCAT(x_respuesta,l_salida4);
           end if;
        */
      END IF;
    END IF;
  EXCEPTION
    WHEN l_Error_Controlado THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  /*****************************************************************************
  Consulta Vademecum Ecuador
  Parametros Entrada:
    p_transaccion => Transaccion que contiene la peticion del cierre de la venta en forma de arreglo
  Parametros Salida:
    x_respuesta   => ninguna
    x_cod_error   => Codigo de error, si es que hubo algun problema
    x_msg_error   => Mensaje de error, si es que hubo algun problema
  *****************************************************************************/
  PROCEDURE Gncc10(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Ve          Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ve;
    l_Trama_Vm          Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vm;
    l_Codigo_Tx         NUMBER;
    l_Largo_To          NUMBER;
    l_Fecha_Vd          DATE;
    l_Resultado         NUMBER;
    p_Respuesta         CLOB;
    l_Cuerpo_Tx         BLOB;
    l_Resultado         NUMBER;
    l_Largo_Ctx         NUMBER;
    l_Largo_Tot         NUMBER;
    l_Fecha_Tx_Original DATE;
    l_Dbg_Proceso       VARCHAR2(100) := 'SCFR_TRX_GNC_PK.GNCC10';
    l_Dbg_Mensaje       VARCHAR2(250) := 'Error General';
    l_Error_Controlado  EXCEPTION;
  BEGIN
    l_Trama_Vm := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Vm(p_Transaccion.Cuerpo_Tx);
    BEGIN
      Pkg_Vademecum.Proc_Query(p_Transaccion.Trama_Pos.Empresa
                              ,p_Transaccion.Trama_Pos.Local
                              ,p_Transaccion.Trama_Pos.Numero_Pos
                              ,p_Transaccion.Fecha_Tx
                              ,Nvl(l_Trama_Vm.Codigo_Producto
                                  ,0)
                              ,Ltrim(Rtrim(l_Trama_Vm.Descripcion_Producto))
                              ,Ltrim(Rtrim(l_Trama_Vm.Principio_Activo))
                              ,p_Respuesta
                              ,x_Cod_Error
                              ,x_Msg_Error);
    
    EXCEPTION
      WHEN OTHERS THEN
        Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                  ,l_Dbg_Mensaje);
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
    END;
  
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      --//--------------------------------------------------------------------------\\
      --// CBR 23/11/2020 14:26                                                     \\
      --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
      --// Esto simula un TRAMA_VE_PREPARA                                          \\
      --//-----------------------------------------------------------------Inicio---\\
      IF Nvl(Ltrim(Rtrim(l_Trama_Vm.Principio_Activo))
            ,'XXX') = 'XXX' THEN
        l_Trama_Ve.Tipo_Consulta := 'Query';
      ELSE
        l_Trama_Ve.Tipo_Consulta := 'PrincipioActivo';
      END IF;
    
      l_Trama_Ve.String_01 := Substr(p_Respuesta
                                    ,1
                                    ,1000);
      l_Trama_Ve.String_02 := Substr(p_Respuesta
                                    ,1001
                                    ,1000);
      l_Trama_Ve.String_03 := Substr(p_Respuesta
                                    ,2001
                                    ,1000);
      l_Trama_Ve.String_04 := Substr(p_Respuesta
                                    ,3001
                                    ,1000);
      l_Trama_Ve.String_05 := Substr(p_Respuesta
                                    ,4001
                                    ,1000);
      --//-----------------------------------------------------------------Termino--\\
    END IF;
  
    l_Cuerpo_Tx := NULL;
    l_Cuerpo_Tx := Utl_Raw.Concat(l_Cuerpo_Tx
                                 ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Ve(l_Trama_Ve
                                                                   ,p_Transaccion.Trama_Pos.Origen_Transaccion));
  
    l_Dbg_Mensaje                              := 'Determinar Largo de la trama';
    l_Largo_Ctx                                := Dbms_Lob.Getlength(l_Cuerpo_Tx);
    l_Largo_Tot                                := l_Largo_Ctx + Scfr_Trx_Dyn_Pk.Obtiene_Largo_Trama(Scfr_Trx_Dyn_Pk.k_Trama_Header_Boc);
    l_Dbg_Mensaje                              := 'Armar Respuesta (trama POS)';
    x_Respuesta                                := NULL;
    p_Transaccion.Trama_Pos.Largo_Total_Buffer := l_Largo_Tot;
    x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                ,Scfr_Trx_Dyn_Pk.Arma_Trama_Pos(p_Transaccion));
    l_Dbg_Mensaje                              := 'Armar Respuesta (trama BOC)';
    p_Transaccion.Trama_Boc.Codigo_Respuesta   := 0;
    p_Transaccion.Trama_Boc.Largo_Total_Buffer := l_Largo_Ctx;
    x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                ,Scfr_Trx_Dyn_Pk.Arma_Trama_Boc(p_Transaccion));
    l_Dbg_Mensaje                              := 'Armar Respuesta (cuerpo TX)';
    x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                ,l_Cuerpo_Tx);
    x_Cod_Error                                := 0;
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  /*****************************************************************************
  Actualizacion Generica de Venta. Registra el cierre de una venta.
  Parametros Entrada:
    p_transaccion => Transaccion que contiene la peticion del cierre de la venta en forma de arreglo
  Parametros Salida:
    x_respuesta   => ninguna
    x_cod_error   => Codigo de error, si es que hubo algun problema
    x_msg_error   => Mensaje de error, si es que hubo algun problema
  *****************************************************************************/
  PROCEDURE Gncu01(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Dp         Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp;
    l_Trama_Dv         Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv;
    l_Trama_Cv         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv;
    l_Trama_Db         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Db;
    l_Party_Id         Scfr_Mov_Transacciones.Pt_Party_Id_Titular%TYPE;
    l_Doc_Emitidos     Scfr_Trx_Gnc_Pk.Tab_Doc_Emitidos;
    l_Resultado        NUMBER;
    l_Tiene_Trama_Dp   BOOLEAN;
    l_Tiene_Trama_Cv   BOOLEAN;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.GNCU01';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    l_Respuesta        BLOB;
    l_Rut_Perfil       NUMBER;
    l_Rut_Vendedor     NUMBER;
    l_Dv_Vendedor      VARCHAR2(1);
    l_Es_Loyalty       BOOLEAN;
    l_Item             NUMBER;
    l_Mdp              VARCHAR2(3);
    -- INI JAGC NEC 20240909
    x_Cod              NUMBER;  
    l_Tx_Necesidades   NUMBER;
    l_Cod_Error        NUMBER;
    l_Msg_Error        VARCHAR2(300);
    -- FIN JAGC NEC 20240909    
  BEGIN
    g_Codigo_Transaccion := 'GNCU01';
    l_Resultado          := 0;
    Scfr_Trx_Gnc_Utl_Pk.Set_Nls('NLS_LANGUAGE');
    --//--------------------------------------------------------------------------\\
    --// CBR 13/08/2018 10:20                                                     \\
    --// BIFURCAR EMPRESA MAICAO EN GNCC01                                        \\
    --//-----------------------------------------------------------------Inicio---\\
    l_Es_Loyalty := FALSE;
    IF Es_Consulta_Loyalty(p_Transaccion.Trama_Pos.Empresa
                          ,p_Transaccion.Trama_Pos.Cadena
                          ,p_Transaccion.Trama_Pos.Local) = 'SI' THEN
      l_Es_Loyalty := TRUE;
    END IF;
    --//-----------------------------------------------------------------Termino--\\
  
    -- Valida si transaccion contiene trama PM (detalle de productos), de no ser asi, no continua
    IF NOT Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                         ,'PM') THEN
      Raise_Application_Error(-20000
                             ,'Transaccion no contiene trama de productos (PM)');
    END IF;
  
    IF l_Es_Loyalty = FALSE THEN
      -- Determina PARTY ID de acuerdo a string de identificacion enviado
      l_Dbg_Mensaje := 'Determinar Party ID para Forma ID = ' || p_Transaccion.Trama_Boc.Forma_Identificacion || ' y String ID = ' ||
                       p_Transaccion.Trama_Boc.String_Identificacion;
      l_Resultado   := Scfr_Trx_Fid_Pk.Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                                          ,p_Transaccion.Trama_Boc.String_Identificacion
                                                          ,p_Transaccion.Trama_Pos.Empresa
                                                          ,p_Transaccion.Trama_Pos.Cadena
                                                          ,p_Transaccion.Trama_Boc.Party_Id);
    END IF;
    l_Tiene_Trama_Dp := Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                                      ,'DP');
    --    if l_resultado != 0 and not l_tiene_trama_dp then
    --      l_DBG_MENSAJE := l_DBG_MENSAJE || 'Error='||l_resultado;
    --      raise l_ERROR_CONTROLADO;
    --    end if;
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Resolviendo Transaccion');
    -- Resuelve de acuerdo a las tramas enviadas
    --    IF l_Tiene_Trama_Dp AND
    --       l_Resultado != 0 THEN
    --      -- Actualiza datos personales
    --      l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_FID_PK.FIDI01 para trama DP';
    --      Scfr_Trx_Fid_Pk.Fidi01(p_Transaccion
    --                            ,l_Respuesta
    --                            ,'SI'
    --                            ,x_Cod_Error
    --                            ,x_Msg_Error);
    --      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
    --                                ,p_Msg     => 'resultado FIDI01=' || x_Cod_Error || '-' || x_Msg_Error);
    --      --      if nvl( x_cod_error, 0 ) != 0 then
    --      l_Resultado := Scfr_Trx_Fid_Pk.Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
    --                                                        ,p_Transaccion.Trama_Boc.String_Identificacion
    --                                                        ,p_Transaccion.Trama_Pos.Empresa
    --                                                        ,p_Transaccion.Trama_Pos.Cadena
    --                                                        ,p_Transaccion.Trama_Boc.Party_Id);
    --      --      end if;
    --    END IF;
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'DC') THEN
      -- Actualiza datos comerciales
      l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_FID_PK.act_datos_comer() para trama DC';
      Scfr_Trx_Fid_Pk.Act_Datos_Comer(p_Transaccion);
    END IF;
    /*
        if scfr_trx_dyn_pk.contiene_trama( p_transaccion.cuerpo_tx, 'DB' ) then
    
          -- Actualiza datos beneficiario
          l_DBG_MENSAJE := 'Ejecutar SCFR_TRX_GNC_PK.trama_db() para trama DB';
          trama_db_resuelve( p_transaccion, x_cod_error, x_msg_error );
          if nvl(x_cod_error,0) != 0 then
            scfr_trx_util_pk.debug_msg(p_proceso=>l_DBG_PROCESO, p_msg=>x_msg_error );
          end if;
        end if;
    */
    --//--------------------------------------------------------------------------\\
    --// CBR 05/02/2015 18:59                                                     \\
    --// Valida si hay campanas de mensajes con control de eventos que cumplieron \\
    --// su numero maximo de eventos, y que a su vez tengan relacionadas una cam- \\
    --// pana de descuento con inscripcion automatica.                            \\
    --//                                                                          \\
    --//-----------------------------------------------------------------Inicio---\\
    Scfr_Trx_Fid_Pk.Dto_x_Evento_Mensajeria(p_Transaccion
                                           ,x_Cod_Error
                                           ,x_Msg_Error);
    --//-----------------------------------------------------------------Termino--\\
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'DV') THEN
      -- Actualiza documento de venta
      l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_GNC_PK.TRAMA_DV()';
      Trama_Dv_Resuelve(p_Transaccion
                       ,l_Trama_Dv
                       ,l_Trama_Cv
                       ,l_Tiene_Trama_Cv
                       ,l_Doc_Emitidos
                       ,x_Cod_Error
                       ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    ELSE
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Trama DV no encontrada');
    END IF;
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'PM') THEN
      -- Carga trama dv para pasarla como parametro
      -- l_trama_dv := scfr_trx_dyn_utl_pk.carga_trama_dv(p_Transaccion.Trama_Pos,p_transaccion.cuerpo_tx);
      -- Actualiza movimiento de productos
      l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_GNC_PK.TRAMA_PM()';
      Trama_Pm_Resuelve(p_Transaccion
                       ,l_Doc_Emitidos
                       ,l_Trama_Dv
                       ,'GNCU01'
                       ,l_Rut_Vendedor
                       ,l_Dv_Vendedor
                       ,x_Cod_Error
                       ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    ELSE
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Trama PM no encontrada');
    END IF;
    /* INI CGC 22/06/2010 Proyecto Pines, grabar en SCFR_MOV_AUT_PRODUCTO */
    -- Debe ir despues de Resolver trama PM y ista tambiin debe venir
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'MP') AND
       Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'PM') THEN
      l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_GNC_PK.TRAMA_MP()';
      Trama_Mp_Resuelve(p_Transaccion
                       ,x_Cod_Error
                       ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    ELSE
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Trama MP no encontrada');
    END IF;
    -- JRG 08032016 Actualiza puntos utilizados en campanas de descuento del programa MCV
    Rebaja_Puntos_Mcv_Desc(p_Transaccion => p_Transaccion
                          ,x_Cod_Error   => x_Cod_Error
                          ,x_Msg_Error   => x_Msg_Error);
    /* FIN CGC 22/06/2010 Proyecto Pines, grabar en SCFR_MOV_AUT_PRODUCTO */
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'PA') THEN
      -- Inscribe producto fidelizado CRM
      l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_GNC_PK.trama_pa_resuelve() para trama PA';
      Trama_Pa_Resuelve(p_Transaccion
                       ,x_Cod_Error
                       ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    END IF;
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'PR') THEN
      -- Inscribe compra frecuente CRM
      l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_FID_PK.trama_pr_resuelve() para trama PR';
      Trama_Pr_Resuelve(p_Transaccion
                       ,x_Cod_Error
                       ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    END IF;
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'RF') THEN
      NULL;
    END IF;
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'RC') THEN
      NULL;
    END IF;
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'CP') THEN
      -- Actualiza cupones generados impresos
      l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_GNC_PK.trama_cp_resuelve() para trama CP';
      Trama_Cp_Resuelve(p_Transaccion
                       ,x_Cod_Error
                       ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    END IF;
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'CV') THEN
      l_Trama_Cv := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Cv(p_Transaccion.Cuerpo_Tx);
      FOR l_Item IN 1 .. l_Trama_Cv.Last -- actualizar cod_aut_mdp para excedente como medio de pago todas las isapres
      LOOP
        BEGIN
          SELECT 'SI'
            INTO l_Mdp
            FROM Scfr_Convenios a
           WHERE a.Numero_Convenio = l_Trama_Cv(l_Item).Convenio
             AND a.Exc_Medio_Pago = 'MDP';
        EXCEPTION
          WHEN OTHERS THEN
            l_Mdp := 'NO';
        END;
        IF l_Mdp = 'SI' AND
           Nvl(l_Trama_Cv(l_Item).Codigo_Autorizacion
              ,0) <> 0 THEN
          UPDATE Scfr_Mov_Documentos_Txs a
             SET a.Folio_Dicc = l_Trama_Cv(l_Item).Codigo_Autorizacion
           WHERE a.Txo_Correlativo_Tx = l_Trama_Dv.Correlativo_Tx
             AND a.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
             AND a.Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
             AND a.Loc_Local = p_Transaccion.Trama_Pos.Local
             AND a.Tmo_Movimiento IN ('VENEXC'
                                     ,'VENGUI');
        END IF;
      END LOOP;
    END IF;
    /*  ESTE CODIGO FUE MOVIDO A LA RUTINA EJECUTAR_DESDE_CONCENTRADOR del package SCFR_EJEC_DESDE_CONC_PK
        -- Realiza cierre de convenio
        if scfr_trx_dyn_pk.contiene_trama( p_transaccion.cuerpo_tx, 'CV' ) then
          begin
            l_trama_dv := scfr_trx_dyn_utl_pk.carga_trama_dv(p_Transaccion.Trama_Pos,p_transaccion.cuerpo_tx );
            if nvl(ltrim(rtrim(l_trama_dv.ot)),'0') = '0' then
    
              l_DBG_MENSAJE := 'Ejecutar SCFR_CONV_PK.cierre_transacciones';
              scfr_trx_util_pk.debug_msg( p_proceso => 'SCFR_TRX_GNC_PK.gncu01', p_msg =>'llamando a scfr_conv_pk.cierre_transacion' );
              scfr_conv_pk.cierre_transacciones( p_transaccion.codigo_tx
                                               , p_transaccion.trama_pos.local
                                               , x_cod_error
                                               , x_msg_error );
              if nvl(x_cod_error,0) != 0 then
                --raise l_ERROR_CONTROLADO;
                x_cod_error := 0;
              end if;
            end if;
          exception
            when others then
              -- No registra como error, solo como log. Transaccion termina correctamente.
              scfr_trx_util_pk.debug_msg( p_proceso=>l_DBG_PROCESO
                                    , p_msg=>'Error al intentar '||l_DBG_MENSAJE||' - codigo_tx='||p_transaccion.codigo_tx||',LOCAL='||p_transaccion.trama_pos.local );
          end;
        end if;
    */
    --//--------------------------------------------------------------------------\\
    --// CBR 20/08/2020 15:31                                                     \\
    --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
    --// Saco trama RP hasta que se soluciones                                    \\
    --//-----------------------------------------------------------------Inicio---\\
    /*
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'RP') THEN
      l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_GNC_UTL_PK.TRAMA_RP_RESUELVE()';
      Scfr_Trx_Gnc_Utl_Pk.Trama_Rp_Resuelve(p_Transaccion
                                           ,x_Cod_Error
                                           ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    ELSE
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Trama RP no encontrada');
    END IF;
    */
    --//-----------------------------------------------------------------Termino--\\
  
    /* ============================================================
     DESARROLLO CUENTA CORRIENTE RECETA (CGC 16-12-2015)
    ============================================================*/
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'RI') THEN
      l_Dbg_Mensaje := 'Ejecutar REGISTRO_RECETAS_PKG.TRAMA_RI_RESUELVE()';
      
      dbms_output.put_line('l_Rut_Vendedor: ' || l_Rut_Vendedor);
      dbms_output.put_line('l_Dv_Vendedor: ' || l_Dv_Vendedor);
      
      Registro_Recetas_Pkg.Trama_Ri_Resuelve(p_Transaccion
                                            ,l_Rut_Vendedor
                                            ,l_Dv_Vendedor
                                            ,x_Cod_Error
                                            ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    ELSE
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Trama RI no encontrada');
    END IF;
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'RV') THEN
      l_Dbg_Mensaje := 'Ejecutar REGISTRO_RECETAS_PKG.TRAMA_RV_RESUELVE()';
      IF l_Tiene_Trama_Cv THEN
        Registro_Recetas_Pkg.Trama_Rv_Resuelve(p_Transaccion
                                              ,l_Trama_Dv
                                              ,l_Trama_Cv
                                              ,x_Cod_Error
                                              ,x_Msg_Error);
      ELSE
        Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' => No existe Trama CV');
        RAISE l_Error_Controlado;
      END IF;
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    ELSE
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Trama RV no encontrada');
    END IF;
    
     DBMS_OUTPUT.PUT_LINE('PASA RV');
    
    -- ============================================================
    -- DESARROLLO CUENTA CORRIENTE RECETA ( FIN )
    -- ============================================================
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'DE') THEN
      l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_GNC_UTL_PK.trama_de_resuelve()';
      Scfr_Trx_Gnc_Utl_Pk.Trama_De_Resuelve(p_Transaccion
                                           ,x_Cod_Error
                                           ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    ELSE
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Trama DE no encontrada');
    END IF;
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'DB') THEN
      l_Trama_Db   := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Db(p_Transaccion.Cuerpo_Tx);
      l_Rut_Perfil := l_Trama_Db(1).Rut_Beneficiario;
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
      -- actualiza datos ultima compra del beneficiario
      Scfr_Trx_Gnc_Utl_Pk.Registra_Datos_Ult_Compra(l_Rut_Perfil
                                                   ,p_Transaccion.Fecha_Tx
                                                   ,p_Transaccion.Trama_Pos.Local);
      -- ahora actualiza datos ultima compra del titular
      l_Rut_Perfil := p_Transaccion.Rut_Titular;
    ELSE
      l_Rut_Perfil := p_Transaccion.Rut_Titular;
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Trama DB no encontrada');
    END IF;
    -- actualiza datos ultima compra del cliente
    Scfr_Trx_Gnc_Utl_Pk.Registra_Datos_Ult_Compra(l_Rut_Perfil
                                                 ,p_Transaccion.Fecha_Tx
                                                 ,p_Transaccion.Trama_Pos.Local);
    -- agrega registro de numero de venta
    Scfr_Trx_Gnc_Utl_Pk.Registra_Vta(SYSDATE
                                    ,p_Transaccion
                                    ,p_Transaccion.Rut_Titular);
    -- Fin de la transaccion.
    Agrega_Respuesta(p_Transaccion
                    ,k_Cod_Resp_Ok
                    ,x_Respuesta);
  
    -- Se llama a servicio PMC
    Scfr_Trx_Fid_Pk.Registra_Pmc(p_Transaccion => p_Transaccion
                                ,x_Cod_Error   => x_Cod_Error
                                ,x_Msg_Error   => x_Msg_Error);
    --//-----------------------------------------------------------------Inicio---\\
    Scfr_Sms_Encuesta_Pk.Envio_Sms_Mail_Encuesta(p_Transaccion => p_Transaccion
                                                ,x_Cod_Error   => x_Cod_Error
                                                ,x_Msg_Error   => x_Msg_Error);
    
    
     DBMS_OUTPUT.PUT_LINE('PASA Envio_Sms_Mail_Encuesta');                                            
    --//-----------------------------------------------------------------Termino--\\
  
  
    --//--------------------------------------------------------------------------\\
    --// CBR 03/25/2020 4:39AM                                                    \\
    --// actualiza folio documento en uso de excedentes                           \\
    --//-----------------------------------------------------------------Inicio---\\
    Update_Folio_Excedente(p_Transaccion => p_Transaccion
                          ,x_Cod_Error   => x_Cod_Error
                          ,x_Msg_Error   => x_Msg_Error);
                          
     DBMS_OUTPUT.PUT_LINE('PASA Update_Folio_Excedente');  
    --//-----------------------------------------------------------------Termino--\\
  
    --//--------------------------------------------------------------------------\\
    --// CBR 23/11/2020 16:42                                                     \\
    --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
    --// Graba valores originales en tabla SCFR_MOV_DATOS_VENTAS                  \\
    --// invoca el servicio ubicado en Pkg_Sri.Proc_Procesa                       \\
    --//-----------------------------------------------------------------Inicio---\\
    l_Trama_Dp := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Dp(p_Transaccion.Cuerpo_Tx);
    DBMS_OUTPUT.PUT_LINE('CARGA l_Trama_Dp');  
    Scfr_Trx_Gnc_Utl_Pk.Registra_Datos_Ventas_Sri(p_Transaccion
                                                 ,l_Trama_Dp
                                                 ,l_Trama_Dv
                                                 ,x_Cod_Error
                                                 ,x_Msg_Error);
    
    DBMS_OUTPUT.PUT_LINE('PASA Registra_Datos_Ventas_Sri');  
  
    --//-----------------------------------------------------------------Termino--\\
  
    
    -- INI JAGC NEC 20240909
    --//--RECETA ELECTRONICA---------------------------------------------Inicio---\\
    --l_Dbg_Mensaje := 'Ejecutar PRODUCTOS_MINSAL()';
    --x_Cod         := 1;
    --Productos_Minsal(p_Transaccion => p_Transaccion
    --                ,x_Cod         => x_Cod);
  
    --IF p_Transaccion.Trama_Pos.Empresa = 86 THEN
    --  Datos_Cartola_2(p_Transaccion => p_Transaccion
    --                 ,x_Cod_Error   => x_Cod_Error
    --                 ,x_Msg_Error   => x_Msg_Error);
    --END IF;
  
    -- Valida Transaccion de NEcesidades de saluds
    BEGIN
      SELECT 1
        INTO l_Tx_Necesidades
        FROM Scfr_Mov_Descuentos_Productos Des
            ,Scfr_Mov_Det_Desc_Producto    Dpro
       WHERE Des.Txo_Codigo_Tx = Dpro.Txo_Codigo_Tx
         AND Des.Txo_Codigo_Tx = p_Transaccion.Codigo_Tx
         AND Dpro.Id_Promocion IS NOT NULL
         AND Rownum = 1;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Tx_Necesidades := 0;
    END;
    
    Dbms_Output.Put_Line('l_Tx_Necesidades=>' || l_Tx_Necesidades);
    IF (l_Tx_Necesidades = 1) THEN
      Dbms_Output.Put_Line('p_Txo_Codigo_Tx=>' || p_Transaccion.Codigo_Tx);

      Scfr_Necesidades_Salud_Pk.Cierre_Venta(p_Txo_Codigo_Tx => p_Transaccion.Codigo_Tx
                                            ,c_Forma_Identificacion => trim(p_Transaccion.Trama_Boc.Forma_Identificacion)
                                            ,c_String_Identificacion => trim(p_Transaccion.Trama_Boc.String_Identificacion)                 
                                            ,x_Cod_Error     => l_Cod_Error
                                            ,x_Msg_Error     => l_Msg_Error);
                                            
      Dbms_Output.Put_Line('x_Cod_Error=>' || x_Cod_Error);
      Dbms_Output.Put_Line('l_Msg_Error=>' || l_Msg_Error);
    END IF;
    
    --INI JAGC PROVISIONAL 20241204
    --IF (p_Transaccion.Trama_Pos.Local IN (4)) THEN
    -- x_Cod_Error :=60000;
    --END IF;
        
    --IF Nvl(x_Cod_Error,-1) != 0 THEN
    --       RAISE l_Error_Controlado;
    --END IF;
    -- FIN JAGC PROVISIONAL 20241204
    
  
    --//-----------------------------------------------------------------Termino--\\
    -- FIN JAGC NEC 20240909
  EXCEPTION
    WHEN l_Error_Controlado THEN
      Agrega_Respuesta(p_Transaccion
                      ,k_Cod_Resp_Nok
                      ,x_Respuesta);
    WHEN OTHERS THEN
      Agrega_Respuesta(p_Transaccion
                      ,k_Cod_Resp_Nok
                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  /*****************************************************************************
  Reversa Generica de Venta. Registra la reversa de una venta.
  Parametros Entrada:
    p_transaccion => Transaccion que contiene la peticion de la reversa de venta en forma de arreglo
  Parametros Salida:
    x_respuesta   => ninguna
    x_cod_error   => Codigo de error, si es que hubo algun problema
    x_msg_error   => Mensaje de error, si es que hubo algun problema
  *****************************************************************************/
  PROCEDURE Gncu02(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Dv         Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv;
    l_Trama_Dp         Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp;
    l_Trama_Cv         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv;
    l_Party_Id         Scfr_Mov_Transacciones.Pt_Party_Id_Titular%TYPE;
    l_Doc_Emitidos     Scfr_Trx_Gnc_Pk.Tab_Doc_Emitidos;
    l_Resultado        NUMBER;
    l_Tiene_Trama_Dp   BOOLEAN;
    l_Tiene_Trama_Cv   BOOLEAN;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.GNCU02';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    x_Offline          Scfr_Cuenta_Cte_Descuentos.Movimiento_Offline%TYPE := 'NO';
    l_Cod_Error        NUMBER;
    l_Msg_Error        VARCHAR2(1000);
    l_Rut_Titular      VARCHAR2(10);
    l_Respuesta        BLOB;
    
    -- INI JAGC NEC 20240909
    --x_Cod              NUMBER;  
    l_Tx_Necesidades   NUMBER;
    -- FIN JAGC NEC 20240909
    
  BEGIN
    g_Codigo_Transaccion := 'GNCU02';
    x_Cod_Error          := 0;
    -- Determina PARTY ID de acuerdo a string de identificacion enviado
    l_Dbg_Mensaje    := 'Determinar Party ID para Forma ID = ' || p_Transaccion.Trama_Boc.Forma_Identificacion || ' y String ID = ' ||
                        p_Transaccion.Trama_Boc.String_Identificacion;
    l_Resultado      := Scfr_Trx_Fid_Pk.Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                                           ,p_Transaccion.Trama_Boc.String_Identificacion
                                                           ,p_Transaccion.Trama_Pos.Empresa
                                                           ,p_Transaccion.Trama_Pos.Cadena
                                                           ,p_Transaccion.Trama_Boc.Party_Id);
    l_Tiene_Trama_Dp := Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                                      ,'DP');
    --    if l_resultado != 0 and not l_tiene_trama_dp then
    --      l_DBG_MENSAJE := l_DBG_MENSAJE || 'Error='||l_resultado;
    --      raise l_ERROR_CONTROLADO;
    --    end if;
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Resolviendo Transaccion');
    -- Resuelve de acuerdo a las tramas enviadas
    IF l_Tiene_Trama_Dp AND
       l_Resultado != 0 THEN
      -- Actualiza datos personales
      l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_FID_PK.FIDI01 para trama DP';
      Scfr_Trx_Fid_Pk.Fidi01(p_Transaccion
                            ,l_Respuesta
                            ,'SI'
                            ,x_Cod_Error
                            ,x_Msg_Error);
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'resultado FIDI01=' || x_Cod_Error || '-' || x_Msg_Error);
      --      if nvl( x_cod_error, 0 ) != 0 then
      l_Resultado := Scfr_Trx_Fid_Pk.Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                                        ,p_Transaccion.Trama_Pos.Empresa
                                                        ,p_Transaccion.Trama_Pos.Cadena
                                                        ,p_Transaccion.Trama_Boc.Party_Id);
      --      end if;
    END IF;
    -- Resuelve de acuerdo a las tramas enviadas
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'DV') THEN
      -- Actualiza documento de venta
      l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_GNC_PK.TRAMA_DV_REVERSA()';
      Trama_Dv_Reversa(p_Transaccion
                      ,l_Trama_Dv
                      ,l_Trama_Cv
                      ,l_Tiene_Trama_Cv
                      ,l_Doc_Emitidos
                      ,x_Cod_Error
                      ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    END IF;
    -- Carga trama dv para pasarla como parametro
    l_Trama_Dv := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Dv(p_Transaccion.Trama_Pos
                                                    ,p_Transaccion.Cuerpo_Tx);
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'PM') THEN
      -- Actualiza documento de venta
      l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_GNC_PK.TRAMA_PM_REVERSA()';
      Trama_Pm_Reversa(p_Transaccion
                      ,l_Doc_Emitidos
                      ,l_Trama_Dv
                      ,'GNCU02'
                      ,x_Cod_Error
                      ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    END IF;
    /* NO LLEGA LA TRAMA CI DESDE EL POS (PLOP). se cambia por una llamada obligada
    if scfr_trx_dyn_pk.contiene_trama( p_transaccion.cuerpo_tx, 'CI' ) then
    
      -- Actualiza documento de venta
      l_DBG_MENSAJE := 'Ejecutar SCFR_TRX_GNC_PK.TRAMA_CI_REVERSA()';
      trama_ci_reversa( p_transaccion, x_cod_error, x_msg_error );
      if nvl(x_cod_error,0) != 0 then
        raise l_ERROR_CONTROLADO;
      end if;
    end if;
    */
    l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_GNC_PK.TRAMA_CP_REVERSA()';
    Trama_Cp_Reversa(p_Transaccion
                    ,x_Cod_Error
                    ,x_Msg_Error);
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'CV') THEN
      BEGIN
        l_Trama_Dv := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Dv(p_Transaccion.Trama_Pos
                                                        ,p_Transaccion.Cuerpo_Tx);
        IF Nvl(Ltrim(Rtrim(l_Trama_Dv.Ot))
              ,'0') = '0' THEN
          l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_GNC_PK.TRAMA_CV_REVERSA()';
          Trama_Cv_Reversa(p_Transaccion
                          ,l_Trama_Dv
                          ,x_Cod_Error
                          ,x_Msg_Error);
          IF Nvl(x_Cod_Error
                ,0) != 0 THEN
            RAISE l_Error_Controlado;
          END IF;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          -- No registra como error, solo como log. Transaccion termina correctamente.
          Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                    ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - codigo_tx=' || p_Transaccion.Codigo_Tx || ',LOCAL=' ||
                                                  p_Transaccion.Trama_Pos.Local);
      END;
    END IF;
    l_Dbg_Mensaje := 'Registrar movimiento en Cta. Cte. Descuentos';
    Scfr_Trx_Gnc_Utl_Pk.Registra_En_Cta_Cte_Descuento1(p_Transaccion => p_Transaccion
                                                      ,p_Tipo        => 'REV'
                                                      ,p_Offline     => x_Offline
                                                      ,p_Incluido    => 'SI'
                                                      ,p_Observacion => NULL
                                                      ,x_Cod_Error   => l_Cod_Error
                                                      ,x_Msg_Error   => l_Msg_Error);
    IF l_Cod_Error <> 0 THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - Cod_tx=>' || p_Transaccion.Codigo_Tx || ',Local=>' ||
                                              p_Transaccion.Trama_Pos.Local);
    END IF;
    /*    l_dbg_mensaje := 'Registrar movimiento en Cta. Cte. Recetas';
    scfr_trx_gnc_utl_pk.registra_en_cta_cte_recetas(p_transaccion => p_transaccion,
                                                    p_tipo        => 'REV',
                                                    x_cod_error   => l_cod_error,
                                                    x_msg_error   => l_msg_error);*/
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'RV') THEN
      l_Dbg_Mensaje := 'Ejecutar REGISTRO_RECETAS_PKG.TRAMA_RV_REVERSA()';
      IF l_Tiene_Trama_Cv THEN
        Registro_Recetas_Pkg.Trama_Rv_Reversa(p_Transaccion
                                             ,l_Trama_Dv
                                             ,l_Trama_Cv
                                             ,x_Cod_Error
                                             ,x_Msg_Error);
      ELSE
        Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' => No existe Trama CV');
        RAISE l_Error_Controlado;
      END IF;
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    ELSE
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Trama RV no encontrada');
    END IF;
  
    -- Se llama a servicio PMC
    Scfr_Trx_Fid_Pk.Registra_Pmc(p_Transaccion => p_Transaccion
                                ,x_Cod_Error   => x_Cod_Error
                                ,x_Msg_Error   => x_Msg_Error);
  
    --//--------------------------------------------------------------------------\\
    --// CBR 23/11/2020 16:42                                                     \\
    --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
    --// Graba valores originales en tabla SCFR_MOV_DATOS_VENTAS                  \\
    --// invoca el servicio ubicado en Pkg_Sri.Proc_Procesa                       \\
    --//-----------------------------------------------------------------Inicio---\\
    l_Trama_Dp := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Dp(p_Transaccion.Cuerpo_Tx);
    Scfr_Trx_Gnc_Utl_Pk.Registra_Datos_Ventas_Sri(p_Transaccion
                                                 ,l_Trama_Dp
                                                 ,l_Trama_Dv
                                                 ,x_Cod_Error
                                                 ,x_Msg_Error);
    Scfr_Trx_Conv_Empresarial_Pk.Registra_Venta_Sam(p_Transaccion.Codigo_Tx
                                                   ,x_Cod_Error
                                                   ,x_Msg_Error);
    --//-----------------------------------------------------------------Termino--\\
  
    IF l_Cod_Error <> 0 THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - Cod_tx=>' || p_Transaccion.Codigo_Tx || ',Local=>' ||
                                              p_Transaccion.Trama_Pos.Local);
    END IF;
    Agrega_Respuesta(p_Transaccion
                    ,k_Cod_Resp_Ok
                    ,x_Respuesta);
                    
    -- INI JAGC NEC 20240909  
    --//--RECETA ELECTRONICA---------------------------------------------Inicio---\\
  
    -- Valida Transaccion de NEcesidades de saluds
    BEGIN
      SELECT 1
        INTO l_Tx_Necesidades
        FROM Scfr_Mov_Descuentos_Productos Des
            ,Scfr_Mov_Det_Desc_Producto    Dpro
       WHERE Des.Txo_Codigo_Tx = Dpro.Txo_Codigo_Tx
         AND Des.Txo_Codigo_Tx = p_Transaccion.Codigo_Tx
         AND Dpro.Id_Promocion IS NOT NULL
         AND Rownum = 1;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Tx_Necesidades := 0;
    END;
    IF (l_Tx_Necesidades = 1) THEN
      Scfr_Necesidades_Salud_Pk.Cierre_Venta(p_Txo_Codigo_Tx => p_Transaccion.Codigo_Tx
                                            ,c_Forma_Identificacion => p_Transaccion.Trama_Boc.Forma_Identificacion
                                            ,c_String_Identificacion => p_Transaccion.Trama_Boc.String_Identificacion   
                                            ,x_Cod_Error     => l_Cod_Error
                                            ,x_Msg_Error     => l_Msg_Error);
    END IF;
  
    --INI JAGC PROVISIONAL 20241204
    --IF (p_Transaccion.Trama_Pos.Local IN (148)) THEN
    -- x_Cod_Error :=60000;
    --END IF;
    -- FIN JAGC PROVISIONAL 20241204
  
    --x_Cod := 2;
    --Productos_Minsal(p_Transaccion => p_Transaccion
    --                ,x_Cod         => x_Cod);
  
    --//-----------------------------------------------------------------Termino--\\
    --IF p_Transaccion.Trama_Pos.Empresa = 86 THEN
    --  Datos_Cartola_2(p_Transaccion => p_Transaccion
    --                 ,x_Cod_Error   => x_Cod_Error
    --                 ,x_Msg_Error   => x_Msg_Error);
    --END IF;
    -- FIN JAGC NEC 20240909
                    
  EXCEPTION
    WHEN l_Error_Controlado THEN
      Agrega_Respuesta(p_Transaccion
                      ,k_Cod_Resp_Nok
                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
    WHEN OTHERS THEN
      Agrega_Respuesta(p_Transaccion
                      ,k_Cod_Resp_Nok
                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  /*****************************************************************************
  Forma de pago. Registra la forma de pago asociada a una venta.
  Parametros Entrada:
    p_transaccion => Transaccion que contiene la peticion de la forma de pago en forma de arreglo
  Parametros Salida:
    x_respuesta   => ninguna
    x_cod_error   => Codigo de error, si es que hubo algun problema
    x_msg_error   => Mensaje de error, si es que hubo algun problema
  *****************************************************************************/
  PROCEDURE Gncu03(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Resultado        NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.GNCU03';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    -- LLamar a rutina que registra el pago
    Trama_Fp_Resuelve(p_Transaccion
                     ,x_Cod_Error
                     ,x_Msg_Error);
    Agrega_Respuesta(p_Transaccion
                    ,k_Cod_Resp_Ok
                    ,x_Respuesta);
  EXCEPTION
    WHEN OTHERS THEN
      Agrega_Respuesta(p_Transaccion
                      ,k_Cod_Resp_Nok
                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  /*****************************************************************************
  Autorizacion. Registra la autorizacion.
  Parametros Entrada:
    p_transaccion => Transaccion que contiene la peticion de la autorizacion en forma de arreglo
  Parametros Salida:
    x_respuesta   => ninguna
    x_cod_error   => Codigo de error, si es que hubo algun problema
    x_msg_error   => Mensaje de error, si es que hubo algun problema
  *****************************************************************************/
  PROCEDURE Gncu04(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Tx         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tx;
    l_Trama_Rx         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rx;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.GNCU04';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    -- Obtiene informacion de la trama tx
    l_Dbg_Mensaje := 'Obtener informacion de la trama TX';
    l_Trama_Tx    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Tx(p_Transaccion.Cuerpo_Tx);
    -- Obtiene informacion de la trama rx
    l_Dbg_Mensaje := 'Obtener informacion de la trama RX';
    l_Trama_Rx    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Rx(p_Transaccion.Cuerpo_Tx);
    FOR l_Itm IN 1 .. l_Trama_Tx.Count
    LOOP
      -- Llama a API que realiza la grabacion de la "transaccion de autorizacion".
      Pkg_Com_Transacciones_Clientes.Grabar_Transaccion(l_Trama_Tx (l_Itm).Codigo_Servicio -- in  varchar2
                                                       ,NULL --l_trama_tx(l_itm).tx                -- in  blob default empty_blob()
                                                       ,NULL --to_date(l_trama_tx(l_itm).timespan,'yyyymmddhh24miss')          -- in  date
                                                       ,l_Trama_Tx (l_Itm).Tx_Respuesta -- in  varchar2 default 'NO'
                                                       ,l_Trama_Tx (l_Itm).Tx_No_Enrutada -- in  varchar2 default 'NO'
                                                       ,l_Trama_Tx (l_Itm).Tx_No_Existe -- in  varchar2 default 'NO'
                                                       ,l_Trama_Tx (l_Itm).Tx_Timeout -- in  varchar2 default 'NO'
                                                       ,l_Trama_Tx (l_Itm).Tx_Erronea -- in  varchar2 default 'NO'
                                                       ,l_Trama_Tx (l_Itm).Tx_Expirada -- in  varchar2 default 'NO'
                                                       ,l_Trama_Tx (l_Itm).Tx_Online -- in  varchar2 default 'NO'
                                                       ,l_Trama_Tx (l_Itm).Tx_Confirmada -- in  varchar2 default 'NO'
                                                       ,l_Trama_Tx (l_Itm).Tx_Nack -- in  varchar2 default 'NO'
                                                       ,NULL --l_trama_rx(l_itm).rx                -- in  blob default empty_blob()
                                                       ,NULL --to_date(l_trama_rx(l_itm).timespan,'yyyymmddhh24miss')          -- in  date
                                                       ,l_Trama_Rx (l_Itm).Rx_Ack -- in  varchar2 default 'NO'
                                                       ,l_Trama_Rx (l_Itm).Rx_Nack -- in  varchar2 default 'NO'
                                                       ,l_Trama_Rx (l_Itm).Rx_Con_Servicio -- in  varchar2 default 'NO'
                                                       ,l_Trama_Rx (l_Itm).Rx_Sin_Servicio -- in  varchar2 default 'NO'
                                                       ,l_Trama_Rx (l_Itm).Rx_Timeout -- in  varchar2 default 'NO'
                                                       ,l_Trama_Rx (l_Itm).Rx_Erronea -- in  varchar2 default 'NO'
                                                       ,x_Cod_Error -- out number
                                                       ,x_Msg_Error -- out varchar2
                                                        );
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    END LOOP;
    Agrega_Respuesta(p_Transaccion
                    ,k_Cod_Resp_Ok
                    ,x_Respuesta);
  EXCEPTION
    WHEN l_Error_Controlado THEN
      Agrega_Respuesta(p_Transaccion
                      ,k_Cod_Resp_Nok
                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
    WHEN OTHERS THEN
      Agrega_Respuesta(p_Transaccion
                      ,k_Cod_Resp_Nok
                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  /*****************************************************************************
  Actualizacion Generica de Recaudacion.
  Parametros Entrada:
    p_transaccion => Transaccion que contiene la peticion de la actualizacion en forma de arreglo
  Parametros Salida:
    x_respuesta   => ninguna
    x_cod_error   => Codigo de error, si es que hubo algun problema
    x_msg_error   => Mensaje de error, si es que hubo algun problema
  *****************************************************************************/
  PROCEDURE Gncu05(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Dv         Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv;
    l_Trama_Dr         Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dr;
    l_Trama_Dp         Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp;
    l_Tiene_Trama_Dp   BOOLEAN;
    l_Docs_Emitidos    Scfr_Trx_Gnc_Pk.Tab_Doc_Emitidos;
    l_Resultado        NUMBER;
    l_Tipo_Recaudacion Scfr_Recauda_Movimientos.Codigo_Movimiento%TYPE;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.GNCU05';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    
    g_Codigo_Transaccion := 'GNCU05';
    --***********************************************************************
    -- Actualizacion generica de recaudacion
    --***********************************************************************
    -- Determina PARTY ID de acuerdo a string de identificacion enviado
    l_Dbg_Mensaje := 'Determinar Party ID para Forma ID = ' || p_Transaccion.Trama_Boc.Forma_Identificacion || ' y String ID = ' ||
                     p_Transaccion.Trama_Boc.String_Identificacion;
    l_Resultado   := Scfr_Trx_Fid_Pk.Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                                        ,p_Transaccion.Trama_Pos.Empresa
                                                        ,p_Transaccion.Trama_Pos.Cadena
                                                        ,p_Transaccion.Trama_Boc.Party_Id);
    IF l_Resultado = 0 THEN
      l_Dbg_Mensaje := 'Obtener rut titular';
      Scfr_Trx_Util_Pk.Obtiene_Rut(p_Transaccion.Trama_Boc.Party_Id
                                  ,p_Transaccion.Rut_Titular
                                  ,p_Transaccion.Dv_Rut_Titular);
    END IF;
    l_Dbg_Mensaje := 'Obtener Antecedentes transaccion padre   Trama DR';
    Trama_Dr_Resuelve_Act(p_Transaccion
                         ,l_Docs_Emitidos
                         ,x_Cod_Error
                         ,x_Msg_Error);
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      RAISE l_Error_Controlado;
    END IF;
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'PM') THEN
      -- Prepara trama_dv ficticia
      Scfr_Trx_Gnc_Utl_Pk.Arma_Trama_Dv_Desde_Dr(p_Transaccion
                                                ,l_Trama_Dv
                                                ,x_Cod_Error
                                                ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      ELSE
        x_Cod_Error := 0;
        x_Msg_Error := NULL;
      END IF;
      l_Trama_Dr         := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Dr(p_Transaccion.Cuerpo_Tx);
      l_Tipo_Recaudacion := Scfr_Trx_Gnc_Utl_Pk.Obtiene_Mov_Hijo(l_Trama_Dr);
      IF l_Tipo_Recaudacion IS NOT NULL THEN
        -- Actualiza movimiento de productos
        l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_GNC_PK.TRAMA_PM()';
        Scfr_Trx_Gnc_Utl_Pk.Trama_Pm_Resuelve_Seg(p_Transaccion
                                                 ,l_Docs_Emitidos
                                                 ,l_Trama_Dv
                                                 ,'GNCU05'
                                                 ,l_Tipo_Recaudacion
                                                 ,x_Cod_Error
                                                 ,x_Msg_Error);
      ELSE
        -- Actualiza movimiento de productos
        l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_GNC_PK.TRAMA_PM()';
        Trama_Pm_Resuelve(p_Transaccion
                         ,l_Docs_Emitidos
                         ,l_Trama_Dv
                         ,'GNCU05'
                         ,x_Cod_Error
                         ,x_Msg_Error);
      END IF;
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    ELSE
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Trama PM no encontrada');
    END IF;
    /* INI CGC 22/06/2010 Proyecto Pines, grabar en SCFR_MOV_AUT_PRODUCTO */
    -- Debe ir despues de Resolver trama PM y esta tambien debe venir
    
    l_Tiene_Trama_Dp := Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                                      ,'DP');
                                                      
    IF l_Tiene_Trama_Dp THEN
      
       l_Trama_Dp := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Dp(p_Transaccion.Cuerpo_Tx);
       DBMS_OUTPUT.PUT_LINE('CARGA l_Trama_Dp');  
       Scfr_Trx_Gnc_Utl_Pk.Registra_Datos_Ventas_Recaud(p_Transaccion
                                                   ,l_Trama_Dp
                                                   ,l_Trama_Dr
                                                   ,x_Cod_Error
                                                   ,x_Msg_Error);
    
    ELSE  
       Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Trama DP no encontrada');
    END IF;
    
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'MP') AND
       Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'PM') THEN
      l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_GNC_PK.TRAMA_MP()';
      Trama_Mp_Resuelve(p_Transaccion
                       ,x_Cod_Error
                       ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    ELSE
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Trama MP no encontrada');
    END IF;
    /* FIN CGC 22/06/2010 Proyecto Pines, grabar en SCFR_MOV_AUT_PRODUCTO */
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'PE') THEN
      -- Actualiza periodos autorizados
      l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_GNC_PK.trama_pe_resuelve()';
      Trama_Pe_Resuelve(p_Transaccion
                       ,x_Cod_Error
                       ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    ELSE
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Trama PE no encontrada');
    END IF;
    /* l_dbg_mensaje := 'Obtener Antecedentes transaccion Trama PV';
    trama_pv_resuelve(p_transaccion, x_cod_error, x_msg_error);
    IF nvl(x_cod_error, 0) != 0 THEN
      RAISE l_error_controlado;
    END IF;*/
    /*  ESTE CODIGO FUE MOVIDO A LA RUTINA EJECUTAR_DESDE_CONCENTRADOR del package SCFR_EJEC_DESDE_CONC_PK
        -- Realiza cierre de convenio
        if scfr_trx_dyn_pk.contiene_trama( p_transaccion.cuerpo_tx, 'CV' ) then
          begin
            l_DBG_MENSAJE := 'Ejecutar SCFR_CONV_PK.cierre_transacciones';
            scfr_conv_pk.cierre_transacciones( p_transaccion.codigo_tx , p_transaccion.trama_pos.local , x_cod_error  , x_msg_error );
            if nvl(x_cod_error,0) != 0 then
              raise l_ERROR_CONTROLADO;
            end if;
    
          exception
            when others then
              -- No registra como error, solo como log. Transaccion termina correctamente.
              scfr_trx_util_pk.debug_msg( p_proceso=>l_DBG_PROCESO , p_msg=>'Error al intentar '||l_DBG_MENSAJE||' - codigo_tx='||p_transaccion.codigo_tx||',LOCAL='||p_transaccion.trama_pos.local );
              x_cod_error := 0;
          end;
        end if;
    */
    -- actualiza datos ultima compra del cliente
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'PM') THEN
      Scfr_Trx_Gnc_Utl_Pk.Registra_Datos_Ult_Compra(p_Transaccion.Rut_Titular
                                                   ,p_Transaccion.Fecha_Tx
                                                   ,p_Transaccion.Trama_Pos.Local);
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'fecha_tx:' || p_Transaccion.Fecha_Tx || ' local:' || p_Transaccion.Trama_Pos.Local);
    END IF;
  
    --//--------------------------------------------------------------------------\\
    --// CBR 03/25/2020 4:39AM                                                    \\
    --// actualiza folio documento en uso de excedentes                           \\
    --//-----------------------------------------------------------------Inicio---\\
    Update_Folio_Excedente(p_Transaccion => p_Transaccion
                          ,x_Cod_Error   => x_Cod_Error
                          ,x_Msg_Error   => x_Msg_Error);
    --//-----------------------------------------------------------------Termino--\\
  
    Agrega_Respuesta(p_Transaccion
                    ,k_Cod_Resp_Ok
                    ,x_Respuesta);
  EXCEPTION
    WHEN l_Error_Controlado THEN
      Agrega_Respuesta(p_Transaccion
                      ,k_Cod_Resp_Nok
                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
    WHEN OTHERS THEN
      Agrega_Respuesta(p_Transaccion
                      ,k_Cod_Resp_Nok
                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  /*****************************************************************************
  Anulacion Generica de Recaudacion.
  Parametros Entrada:
    p_transaccion => Transaccion que contiene la peticion de la venta en forma de arreglo
  Parametros Salida:
    x_respuesta   => Transaccion que contiene la venta en formato RAW
    x_cod_error   => Codigo de error, si es que hubo algun problema
    x_msg_error   => Mensaje de error, si es que hubo algun problema
  *****************************************************************************/
  PROCEDURE Gncu06(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Dv         Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv;
    l_Trama_Dv_Vacia   Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv;
    l_Docs_Emitidos    Scfr_Trx_Gnc_Pk.Tab_Doc_Emitidos;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.GNCU06';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    l_Resultado        NUMBER;
  BEGIN
    g_Codigo_Transaccion := 'GNCU06';
    -- LLamar a rutina que registra la anulacion de la recaudacion
    Trama_Dr_Resuelve_Anu(p_Transaccion
                         ,l_Docs_Emitidos
                         ,x_Cod_Error
                         ,x_Msg_Error);
    l_Resultado := Scfr_Trx_Fid_Pk.Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                                      ,p_Transaccion.Trama_Boc.String_Identificacion
                                                      ,p_Transaccion.Trama_Pos.Empresa
                                                      ,p_Transaccion.Trama_Pos.Cadena
                                                      ,p_Transaccion.Trama_Boc.Party_Id);
    IF l_Resultado = 0 THEN
      l_Dbg_Mensaje := 'Obtener rut titular';
      Scfr_Trx_Util_Pk.Obtiene_Rut(p_Transaccion.Trama_Boc.Party_Id
                                  ,p_Transaccion.Rut_Titular
                                  ,p_Transaccion.Dv_Rut_Titular);
    END IF;
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'PM') THEN
      -- Prepara trama_dv ficticia
      Scfr_Trx_Gnc_Utl_Pk.Arma_Trama_Dv_Desde_Dr(p_Transaccion
                                                ,l_Trama_Dv
                                                ,x_Cod_Error
                                                ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      ELSE
        x_Cod_Error := 0;
        x_Msg_Error := NULL;
      END IF;
      -- Actualiza movimiento de productos
      l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_GNC_PK.trama_pm_reversa()';
      Trama_Pm_Reversa(p_Transaccion
                      ,l_Docs_Emitidos
                      ,l_Trama_Dv
                      ,'GNCU06'
                      ,x_Cod_Error
                      ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
      Scfr_Trx_Gnc_Utl_Pk.Reversa_Seguro(p_Transaccion
                                        ,x_Cod_Error
                                        ,x_Msg_Error);
      IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                       ,'CV') THEN
        l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_GNC_PK.TRAMA_CV_REVERSA()';
        Trama_Cv_Reversa(p_Transaccion
                        ,l_Trama_Dv
                        ,x_Cod_Error
                        ,x_Msg_Error);
        IF Nvl(x_Cod_Error
              ,0) != 0 THEN
          RAISE l_Error_Controlado;
        END IF;
      END IF;
    ELSE
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Trama PM no encontrada');
    END IF;
    -- actualiza datos ultima compra del cliente
    IF p_Transaccion.Trama_Pos.Origen_Transaccion IN ('EMP'
                                                     ,'DEC') THEN
      Scfr_Trx_Gnc_Utl_Pk.Registra_Datos_Ult_Compra(p_Transaccion.Rut_Titular
                                                   ,p_Transaccion.Fecha_Tx
                                                   ,p_Transaccion.Trama_Pos.Local);
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'fecha_tx:' || p_Transaccion.Fecha_Tx || ' local:' || p_Transaccion.Trama_Pos.Local);
    END IF;
    Agrega_Respuesta(p_Transaccion
                    ,k_Cod_Resp_Ok
                    ,x_Respuesta);
  EXCEPTION
    WHEN OTHERS THEN
      Agrega_Respuesta(p_Transaccion
                      ,k_Cod_Resp_Nok
                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  /*****************************************************************************
  Actualizacion Generica de Avance.
  Parametros Entrada:
    p_transaccion => Transaccion que contiene la peticion de la actualizacion en forma de arreglo
  Parametros Salida:
    x_respuesta   => ninguna
    x_cod_error   => Codigo de error, si es que hubo algun problema
    x_msg_error   => Mensaje de error, si es que hubo algun problema
  *****************************************************************************/
  PROCEDURE Gncu07(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Resultado        NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.GNCU07';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    --****************************************************************************
    --                     Actualizacion  Generica de avances
    --****************************************************************************
    l_Dbg_Mensaje := 'Verificacion Party_id en transaccion      ' || ' ' || p_Transaccion.Trama_Boc.Forma_Identificacion || ' ' ||
                     p_Transaccion.Trama_Boc.String_Identificacion;
    l_Resultado   := Scfr_Trx_Fid_Pk.Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                                        ,p_Transaccion.Trama_Pos.Empresa
                                                        ,p_Transaccion.Trama_Pos.Cadena
                                                        ,p_Transaccion.Trama_Boc.Party_Id);
    l_Dbg_Mensaje := 'Ejecutar trama_vd_resuelve_act';
    Trama_Vd_Resuelve_Act(p_Transaccion
                         ,1
                         ,x_Cod_Error
                         ,x_Msg_Error);
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      RAISE l_Error_Controlado;
    END IF;
    Agrega_Respuesta(p_Transaccion
                    ,k_Cod_Resp_Ok
                    ,x_Respuesta);
  EXCEPTION
    WHEN l_Error_Controlado THEN
      Agrega_Respuesta(p_Transaccion
                      ,k_Cod_Resp_Nok
                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,'Error al intentar ' || l_Dbg_Mensaje);
    WHEN OTHERS THEN
      Agrega_Respuesta(p_Transaccion
                      ,k_Cod_Resp_Nok
                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  /*****************************************************************************
  Anulacion Generica de Avance.
  Parametros Entrada:
    p_transaccion => Transaccion que contiene la peticion de la anulacion en forma de arreglo
  Parametros Salida:
    x_respuesta   => ninguna
    x_cod_error   => Codigo de error, si es que hubo algun problema
    x_msg_error   => Mensaje de error, si es que hubo algun problema
  *****************************************************************************/
  PROCEDURE Gncu08(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Resultado        NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.GNCU08';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    --********************************************************************
    --   Anulacion Generica de Avances
    --********************************************************************
    l_Dbg_Mensaje := 'Obtener direcciones del cliente';
    l_Resultado   := Scfr_Trx_Fid_Pk.Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                                        ,p_Transaccion.Trama_Pos.Empresa
                                                        ,p_Transaccion.Trama_Pos.Cadena
                                                        ,p_Transaccion.Trama_Boc.Party_Id);
    IF l_Resultado != 0 THEN
      x_Cod_Error := l_Resultado;
      x_Msg_Error := 'Error de Valida Party_id en transaccion';
      RAISE l_Error_Controlado;
    END IF;
    l_Dbg_Mensaje := 'Ejecutar trama_vd_resuelve_anu';
    Trama_Vd_Resuelve_Anu(p_Transaccion
                         ,-1
                         ,x_Cod_Error
                         ,x_Msg_Error);
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      RAISE l_Error_Controlado;
    END IF;
    Agrega_Respuesta(p_Transaccion
                    ,k_Cod_Resp_Ok
                    ,x_Respuesta);
  EXCEPTION
    WHEN l_Error_Controlado THEN
      Agrega_Respuesta(p_Transaccion
                      ,k_Cod_Resp_Nok
                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,'Error al intentar ' || l_Dbg_Mensaje);
    WHEN OTHERS THEN
      Agrega_Respuesta(p_Transaccion
                      ,k_Cod_Resp_Nok
                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  /*****************************************************************************
  Movimientos de Caja y Cierre. Registra los movimientos de caja y cierre del local.
  Parametros Entrada:
    p_transaccion => Transaccion que contiene los movimientos del local.
  Parametros Salida:
    x_respuesta   => ninguna
    x_cod_error   => Codigo de error, si es que hubo algun problema
    x_msg_error   => Mensaje de error, si es que hubo algun problema
  *****************************************************************************/
  PROCEDURE Gncu10(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Resultado  NUMBER;
    l_Cierre_Dep NUMBER;
  
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.GNCU10';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Cierre_Dep := 0;
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'MC') THEN
      -- Registrar los movimientos de caja y cierre
      Trama_Mc_Resuelve(p_Transaccion
                       ,l_Cierre_Dep
                       ,x_Cod_Error
                       ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
      IF l_Cierre_Dep > 0 THEN
        IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                         ,'GD') THEN
          -- Registrar datos del movimiento CIEDEP
          Trama_Gd_Resuelve(p_Transaccion
                           ,x_Cod_Error
                           ,x_Msg_Error);
          IF Nvl(x_Cod_Error
                ,0) != 0 THEN
            RAISE l_Error_Controlado;
          END IF;
        
          -- Genero Archivo para ETV
          Genera_Archivo_Etv(p_Transaccion.Codigo_Tx
                            ,p_Transaccion.Trama_Pos.Empresa
                            ,p_Transaccion.Trama_Pos.Cadena
                            ,p_Transaccion.Trama_Pos.Local
                            ,x_Cod_Error
                            ,x_Msg_Error);
          IF Nvl(x_Cod_Error
                ,0) != 0 THEN
            Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => 'Escribir archvio de Salida para ETV'
                                      ,p_Msg     => 'Error : ' || x_Msg_Error);
            x_Cod_Error := 0;
            x_Msg_Error := '';
          END IF;
        
        ELSE
          Raise_Application_Error(-20000
                                 ,'Transaccion no contiene trama de movimientos de cierre (GD)');
        END IF;
      END IF;
    ELSE
      Raise_Application_Error(-20000
                             ,'Transaccion no contiene trama de movimientos de caja y/o cierre (MC)');
    END IF;
    Agrega_Respuesta(p_Transaccion
                    ,k_Cod_Resp_Ok
                    ,x_Respuesta);
  EXCEPTION
    WHEN l_Error_Controlado THEN
      Agrega_Respuesta(p_Transaccion
                      ,k_Cod_Resp_Nok
                      ,x_Respuesta);
    WHEN OTHERS THEN
      Agrega_Respuesta(p_Transaccion
                      ,k_Cod_Resp_Nok
                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  /*****************************************************************************
  Movimientos de Caja y Cierre Reversas.
  Parametros Entrada:
    p_transaccion => Transaccion que contiene los movimientos del local.
  Parametros Salida:
    x_respuesta   => ninguna
    x_cod_error   => Codigo de error, si es que hubo algun problema
    x_msg_error   => Mensaje de error, si es que hubo algun problema
  *****************************************************************************/
  PROCEDURE Gncu11(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Resultado        NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.GNCU11';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'MC') THEN
      Trama_Mc_Reversa(p_Transaccion
                      ,x_Cod_Error
                      ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    ELSE
      Raise_Application_Error(-20000
                             ,'Transaccion no contiene trama de movimientos de caja y/o cierre (MC)');
    END IF;
    Agrega_Respuesta(p_Transaccion
                    ,k_Cod_Resp_Ok
                    ,x_Respuesta);
  EXCEPTION
    WHEN l_Error_Controlado THEN
      Agrega_Respuesta(p_Transaccion
                      ,k_Cod_Resp_Nok
                      ,x_Respuesta);
    WHEN OTHERS THEN
      Agrega_Respuesta(p_Transaccion
                      ,k_Cod_Resp_Nok
                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  --//--------------------------------------------------------------------------\\
  --// CBR 05/13/2019 5:13PM  TRANSACCION TURNOMATICO                           \\
  --// 13/05/2019 17:13                                                         \\
  --//-----------------------------------------------------------------Inicio---\\
  PROCEDURE Gncu12(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Resultado        NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.GNCU12';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    -- LLamar a rutina que registra el pago
    Trama_Na_Resuelve(p_Transaccion
                     ,x_Cod_Error
                     ,x_Msg_Error);
    Agrega_Respuesta(p_Transaccion
                    ,k_Cod_Resp_Ok
                    ,x_Respuesta);
  EXCEPTION
    WHEN OTHERS THEN
      Agrega_Respuesta(p_Transaccion
                      ,k_Cod_Resp_Nok
                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;
  --//-----------------------------------------------------------------Termino--\\

  --//--------------------------------------------------------------------------\\
  --// CBR 01/10/2019 10:56  TRANSACCION ECOMMERCE                              \\
  --//-----------------------------------------------------------------Inicio---\\
  /*
  PROCEDURE Gncu13(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Resultado   NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_GNC_PK.GNCU13';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    -- LLamar a rutina que registra el pago
    Trama_Sk_Resuelve(p_Transaccion
                     ,x_Cod_Error
                     ,x_Msg_Error);
    Agrega_Respuesta(p_Transaccion
                    ,k_Cod_Resp_Ok
                    ,x_Respuesta);
  EXCEPTION
    WHEN OTHERS THEN
      Agrega_Respuesta(p_Transaccion
                      ,k_Cod_Resp_Nok
                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;
  */
  --//-----------------------------------------------------------------Termino--\\

  --//--------------------------------------------------------------------------\\
  --// CBR 13/04/2020 14:41 Validacion numero de serie en Biometria             \\
  --//-----------------------------------------------------------------Inicio---\\
  PROCEDURE Gncu14(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Resultado        NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.GNCU14';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    -- LLamar a rutina que registra el pago
    Trama_Ns_Resuelve(p_Transaccion
                     ,x_Cod_Error
                     ,x_Msg_Error);
    Agrega_Respuesta(p_Transaccion
                    ,k_Cod_Resp_Ok
                    ,x_Respuesta);
  EXCEPTION
    WHEN OTHERS THEN
      Agrega_Respuesta(p_Transaccion
                      ,k_Cod_Resp_Nok
                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;
  --//-----------------------------------------------------------------Termino--\\

  -- GNC015 Retencion IVA
  PROCEDURE Gncu15(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Resultado        NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.GNCU15';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    -- *
    Trama_Vx_Resuelve(p_Transaccion
                     ,x_Cod_Error
                     ,x_Msg_Error);
    Agrega_Respuesta(p_Transaccion
                    ,k_Cod_Resp_Ok
                    ,x_Respuesta);
  EXCEPTION
    WHEN OTHERS THEN
      Agrega_Respuesta(p_Transaccion
                      ,k_Cod_Resp_Nok
                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;
  --//-----------------------------------------------------------------Termino--\\

  PROCEDURE Update_Codigo_Cotizacion(p_Secuencia_Ot IN Scfr_Rm_Cotizacion.Secuencia_Ot%TYPE
                                    ,p_Codigo_Tx    IN Scfr_Rm_Cotizacion.Codigo_Tx_Vta%TYPE
                                    ,p_Trx_Codigo   IN Scfr_Trx_Rec_Pos.Codigo_Transaccion%TYPE
                                    ,x_Cod_Error    OUT NUMBER
                                    ,x_Msg_Error    OUT VARCHAR2) IS
    l_Retirado  VARCHAR2(6) := 'RETIRA';
    l_Recepcion VARCHAR2(6) := 'RECEPC';
  BEGIN
    IF Nvl(p_Secuencia_Ot
          ,'NO') <> 'NO' AND
       Length(TRIM(p_Secuencia_Ot)) > 0 THEN
      BEGIN
        IF p_Trx_Codigo = 'GNCU01' THEN
          UPDATE Scfr_Rm_Cotizacion Src
             SET Src.Codigo_Tx_Vta = p_Codigo_Tx
                ,Estado            = l_Retirado
           WHERE Src.Secuencia_Ot = p_Secuencia_Ot;
        ELSIF p_Trx_Codigo = 'GNCU02' THEN
          UPDATE Scfr_Rm_Cotizacion Src
             SET Src.Codigo_Tx_Vta = NULL
                ,Estado            = l_Recepcion
           WHERE Src.Secuencia_Ot = p_Secuencia_Ot;
        END IF;
      EXCEPTION
        WHEN No_Data_Found THEN
          x_Cod_Error := 5010;
          IF p_Trx_Codigo = 'GNCU01' THEN
            x_Msg_Error := 'Numero de secuencia no encontrada para actualizar codigo_tx_vta en la tabla scfr_rm_cotizacion';
          ELSIF p_Trx_Codigo = 'GNCU02' THEN
            x_Msg_Error := 'Numero de secuencia no encontrada para actualizar Estado (GNCU02) en la tabla scfr_rm_cotizacion';
          END IF;
        WHEN OTHERS THEN
          x_Cod_Error := SQLCODE;
          x_Msg_Error := SQLERRM;
      END;
    END IF;
  END Update_Codigo_Cotizacion;

  PROCEDURE Update_Folio_Excedente(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                  ,x_Cod_Error   OUT NUMBER
                                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Dv       Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv;
    l_Trama_Cv       Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv;
    l_Trama_Dr       Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dr;
    l_Itm            NUMBER;
    l_Itm2           NUMBER;
    l_Tiene_Venexc   BOOLEAN;
    l_Tiene_Mdp      BOOLEAN;
    l_Es_Trama_Dv    BOOLEAN := FALSE;
    l_Es_Trama_Dr    BOOLEAN := FALSE;
    l_Que_Trama      VARCHAR2(2);
    l_Id_Txs         NUMBER;
    l_Id_Ext         NUMBER;
    l_Folio_Docto    NUMBER;
    l_Folio_Venexc   NUMBER;
    l_Folio_Envio    NUMBER;
    l_Ot_Recetario   VARCHAR2(14);
    l_Mdp            VARCHAR2(2);
    l_Dbg_Mensaje    VARCHAR2(200);
    l_Dbg_Cadena     VARCHAR2(500);
    l_Correlativo_Tx NUMBER(15);
    l_Tipo_Docto     NUMBER(1) := 5;
  
  BEGIN
    l_Tiene_Venexc := FALSE;
    l_Tiene_Mdp    := FALSE;
    l_Ot_Recetario := '';
    l_Folio_Docto  := 0;
    l_Folio_Venexc := 0;
    l_Id_Txs       := 0;
    l_Id_Ext       := 0;
  
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'DR') THEN
      l_Es_Trama_Dr    := TRUE;
      l_Que_Trama      := 'DR';
      l_Trama_Dr       := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Dr(p_Transaccion.Cuerpo_Tx);
      l_Ot_Recetario   := TRIM(l_Trama_Dr.Ot);
      l_Correlativo_Tx := l_Trama_Dr.Correlativo_Tx;
      l_Dbg_Mensaje    := 'Recorrer documentos emitidos (DR1)';
      FOR l_Itm IN 1 .. l_Trama_Dr.Documentos_Emitidos
      LOOP
        IF l_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Movimiento_Hijo IN ('VENEXC') THEN
          l_Tiene_Venexc := TRUE;
          l_Folio_Venexc := l_Trama_Dr.Subtrama_Dr1(l_Itm).Folio;
        END IF;
      END LOOP;
    
    ELSIF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                        ,'DV') THEN
      l_Es_Trama_Dv    := TRUE;
      l_Que_Trama      := 'DV';
      l_Trama_Dv       := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Dv(p_Transaccion.Trama_Pos
                                                            ,p_Transaccion.Cuerpo_Tx);
      l_Ot_Recetario   := TRIM(l_Trama_Dv.Ot);
      l_Correlativo_Tx := l_Trama_Dv.Correlativo_Tx;
      l_Dbg_Mensaje    := 'Recorrer documentos emitidos (DV1)';
      FOR l_Itm IN 1 .. l_Trama_Dv.Subtrama_Dv1.Count
      LOOP
        IF l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Movimiento_Hijo IN ('VENGUI'
                                    ,'VENBOL') THEN
          l_Tipo_Docto := 1;
          IF l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Movimiento_Hijo = 'VENGUI' THEN
            l_Tipo_Docto := 4;
          END IF;
          l_Folio_Docto := l_Trama_Dv.Subtrama_Dv1(l_Itm).Folio;
        ELSIF l_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Movimiento_Hijo IN ('VENEXC') THEN
          l_Tiene_Venexc := TRUE;
          l_Folio_Venexc := l_Trama_Dv.Subtrama_Dv1(l_Itm).Folio;
        END IF;
      END LOOP;
    END IF;
  
    l_Dbg_Mensaje := 'Recorrer Convenios Venta (CV)';
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'CV') THEN
      l_Trama_Cv := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Cv(p_Transaccion.Cuerpo_Tx);
      FOR l_Item IN 1 .. l_Trama_Cv.Last --exedente como medio de pago todas las isapres
      LOOP
        BEGIN
          SELECT 'SI'
            INTO l_Mdp
            FROM Scfr_Convenios a
           WHERE a.Numero_Convenio = l_Trama_Cv(l_Item).Convenio
             AND a.Exc_Medio_Pago = 'MDP';
        EXCEPTION
          WHEN OTHERS THEN
            l_Mdp := 'NO';
        END;
        IF l_Mdp = 'SI' AND
           Nvl(l_Trama_Cv(l_Item).Codigo_Autorizacion
              ,0) <> 0 THEN
          l_Tiene_Mdp := TRUE;
          l_Id_Txs    := l_Trama_Cv(l_Item).Codigo_Autorizacion;
        END IF;
      END LOOP;
    END IF;
  
    IF l_Es_Trama_Dv = TRUE THEN
      IF l_Id_Txs = 0 AND
         l_Tiene_Venexc = TRUE THEN
        BEGIN
          SELECT Codigo_Autorizacion
            INTO l_Id_Txs
            FROM Scfr_Mov_Transacciones_Pago
           WHERE Txo_Correlativo_Tx = l_Trama_Dv.Correlativo_Tx
             AND Empresa = p_Transaccion.Trama_Pos.Empresa
             AND Cadena = p_Transaccion.Trama_Pos.Cadena
             AND Loc_Local = p_Transaccion.Trama_Pos.Local
             AND Tfp_Forma_Pago = 'VOUEXC';
        EXCEPTION
          WHEN OTHERS THEN
            l_Id_Txs := 0;
        END;
      END IF;
    END IF;
  
    IF l_Id_Txs = 0 AND
       Nvl(l_Ot_Recetario
          ,0) > 0 THEN
      BEGIN
        SELECT p.Codigo_Autorizacion
          INTO l_Id_Txs
          FROM Scfr_Mov_Transacciones_Pago p
              ,Scfr_Mov_Documentos_Txs     d
         WHERE p.Txo_Codigo_Tx = d.Txo_Codigo_Tx
           AND d.Pin_Ot_Recetario = l_Ot_Recetario
           AND d.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
           AND d.Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
           AND d.Loc_Local = p_Transaccion.Trama_Pos.Local
           AND d.Txo_Correlativo_Tx <> l_Trama_Dv.Correlativo_Tx
           AND d.Tmo_Movimiento = 'VENEXC'
           AND p.Tfp_Forma_Pago = 'VOUEXC';
        /*
                SELECT Codigo_Autorizacion
                  INTO l_Id_Txs
                  FROM Scfr_Mov_Transacciones_Pago
                 WHERE Txo_Correlativo_Tx = (SELECT t.Txo_Correlativo_Tx
                                               FROM Scfr_Mov_Documentos_Txs t
                                              WHERE t.Pin_Ot_Recetario = Nvl(l_Ot_Recetario
                                                                            ,0)
                                                AND t.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
                                                AND t.Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
                                                AND t.Loc_Local = p_Transaccion.Trama_Pos.Local
                                                AND t.Txo_Correlativo_Tx <> l_Trama_Dv.Correlativo_Tx
                                                AND t.Tmo_Movimiento = 'VENEXC')
                   AND Empresa = p_Transaccion.Trama_Pos.Empresa
                   AND Cadena = p_Transaccion.Trama_Pos.Cadena
                   AND Loc_Local = p_Transaccion.Trama_Pos.Local
                   AND Tfp_Forma_Pago = 'VOUEXC';
        */
      EXCEPTION
        WHEN OTHERS THEN
          l_Id_Txs := 0;
      END;
    END IF;
  
    IF l_Id_Txs > 0 THEN
      BEGIN
        SELECT t.Codigo_Autorizacion_Ext
          INTO l_Id_Ext
          FROM Scfr_Log_Autorizacion_Mdp t
         WHERE t.Codigo_Autorizacion_Fcv = l_Id_Txs
           AND t.Local_Fcv = p_Transaccion.Trama_Pos.Local
           AND Nvl(t.Codigo_Autorizacion_Ext
                  ,0) > 0;
      EXCEPTION
        WHEN OTHERS THEN
          l_Id_Ext := 0;
      END;
    END IF;
  
    l_Folio_Envio := l_Folio_Docto;
    IF l_Es_Trama_Dr THEN
      l_Folio_Envio := l_Folio_Venexc;
    END IF;
    /*
        l_Dbg_Cadena := '    {Antes} correlativo_tx : ' || l_Correlativo_Tx || ', Trama_Txs : ' || l_Que_Trama || ', ID_Colmena : ' ||
                        Lpad(l_Id_Ext
                            ,10
                            ,' ') || ', ID_Txs : ' || Lpad(l_Id_Txs
                                                          ,10
                                                          ,' ') || ', Folio_Informado : ' ||
                        Lpad(l_Folio_Envio
                            ,15
                            ,' ') || ', Folio_Docto : ' || Lpad(l_Folio_Docto
                                                               ,15
                                                               ,' ') || ', Folio_VenExc : ' ||
                        Lpad(l_Folio_Venexc
                            ,15
                            ,' ') || ', Cod_Error : ' || x_Cod_Error || ', Msg_Error : ' || TRIM(x_Msg_Error) || ', SQLCODE : ' || SQLCODE ||
                        ', SQLERRM : ' || TRIM(SQLERRM);
        Crea_Lst('LOG_CBR_REGISTRO.TXT'
                ,l_Dbg_Cadena);
    */
    IF l_Id_Ext > 0 AND
       (l_Folio_Docto > 0 OR l_Folio_Venexc > 0) THEN
    
      BEGIN
        Pkg_Excedentes_Mp.Proc_Registrar_Documento(p_Idtransaccion => l_Id_Ext
                                                  ,p_Id_Tx         => l_Id_Txs
                                                  ,p_Ndocumento    => l_Folio_Envio
                                                  ,p_Tipodoc       => l_Tipo_Docto
                                                  ,x_Cod_Error     => x_Cod_Error
                                                  ,x_Des_Error     => x_Msg_Error);
      
        /*
                l_Dbg_Cadena := '  {Despues} correlativo_tx : ' || l_Correlativo_Tx || ', Trama_Txs : ' || l_Que_Trama || ', ID_Colmena : ' ||
                                Lpad(l_Id_Ext
                                    ,10
                                    ,' ') || ', ID_Txs : ' || Lpad(l_Id_Txs
                                                                  ,10
                                                                  ,' ') || ', Folio_Informado : ' ||
                                Lpad(l_Folio_Envio
                                    ,15
                                    ,' ') || ', Folio_Docto : ' || Lpad(l_Folio_Docto
                                                                       ,15
                                                                       ,' ') || ', Folio_VenExc : ' ||
                                Lpad(l_Folio_Venexc
                                    ,15
                                    ,' ') || ', Cod_Error : ' || x_Cod_Error || ', Msg_Error : ' || TRIM(x_Msg_Error) || ', SQLCODE : ' || SQLCODE ||
                                ', SQLERRM : ' || TRIM(SQLERRM);
                Crea_Lst('LOG_CBR_REGISTRO.TXT'
                        ,l_Dbg_Cadena);
        */
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
          /*
                    l_Dbg_Cadena := '{Exception} correlativo_tx : ' || l_Correlativo_Tx || ', Trama_Txs : ' || l_Que_Trama || ', ID_Colmena : ' ||
                                    Lpad(l_Id_Ext
                                        ,10
                                        ,' ') || ', ID_Txs : ' || Lpad(l_Id_Txs
                                                                      ,10
                                                                      ,' ') || ', Folio_Informado : ' ||
                                    Lpad(l_Folio_Envio
                                        ,15
                                        ,' ') || ', Folio_Docto : ' || Lpad(l_Folio_Docto
                                                                           ,15
                                                                           ,' ') || ', Folio_VenExc : ' ||
                                    Lpad(l_Folio_Venexc
                                        ,15
                                        ,' ') || ', Cod_Error : ' || x_Cod_Error || ', Msg_Error : ' || TRIM(x_Msg_Error) || ', SQLCODE : ' || SQLCODE ||
                                    ', SQLERRM : ' || TRIM(SQLERRM);
                    Crea_Lst('LOG_CBR_REGISTRO.TXT'
                            ,l_Dbg_Cadena);
          */
      END;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END Update_Folio_Excedente;


  FUNCTION Es_Consulta_Loyalty(p_Empresa IN NUMBER
                              ,p_Cadena  IN NUMBER
                              ,p_Local   IN NUMBER) RETURN VARCHAR2 AS
    p_Es_Loyalty VARCHAR2(2);
  BEGIN
    p_Es_Loyalty := 'NO';
    BEGIN
      SELECT 'SI'
        INTO p_Es_Loyalty
        FROM Scfr_Locales_Loyalty t
       WHERE t.Emp_Empresa = p_Empresa
         AND t.Cad_Cadena = p_Cadena
         AND t.Loc_Local = p_Local;
    EXCEPTION
      WHEN No_Data_Found THEN
        p_Es_Loyalty := 'NO';
      WHEN OTHERS THEN
        p_Es_Loyalty := 'NO';
    END;
    RETURN p_Es_Loyalty;
  END Es_Consulta_Loyalty;
  
   -- -------------------------------------------------------------------------
  -- Obtiene URL Servicio REST
  -- -------------------------------------------------------------------------
  Function Obtiene_url(L_id_servicio_ws In Varchar2,
                       X_msg_error      Out Varchar2) Return Varchar2 Is

    Lwsdir Varchar2(200);
  Begin
    Select Wsdir
      Into Lwsdir
      From Scfr_comercios_externos
     Where Comercio = L_id_servicio_ws;
    Return Lwsdir;
  Exception
    When No_data_found Then
      X_msg_error := 'No hay datos en SCFR_COMERCIOS_EXTERNOS para destino = "' ||
                     L_id_servicio_ws || '"';
      Lwsdir      := Null;
      Return Lwsdir;
    When Others Then
      X_msg_error := 'Problemas al obtener informacion de SCFR_COMERCIOS_EXTERNOS para destino = "' ||
                     L_id_servicio_ws || '" - ' || Sqlerrm;
      Lwsdir      := Null;
      Return Lwsdir;
  End Obtiene_url;

  PROCEDURE LOG_DEBUG ( TIPO_PRUEBA IN VARCHAR2,
                        descripcion IN VARCHAR2,
                        id_cliente IN VARCHAR2,
                        local IN number,
                        codigo_tx IN number
                  ) IS
  PRAGMA AUTONOMOUS_TRANSACTION; 
  BEGIN
    
  INSERT INTO Scfr_Log_Debug
                VALUES
                  (Scfr_Log_Debug_s.Nextval
                  ,TIPO_PRUEBA
                  ,SYSDATE
                  ,'10000'
                  ,descripcion
                  ,id_cliente
                  ,local
                  ,codigo_tx);
                  
   
  COMMIT;
  END; 
END Scfr_Trx_Gnc_Pk;
/
