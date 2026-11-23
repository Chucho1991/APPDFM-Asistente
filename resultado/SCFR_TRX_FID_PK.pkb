CREATE OR REPLACE PACKAGE BODY TRX3.Scfr_Trx_Fid_Pk IS

  -- Para envio correo de Bienvenida programa MCV
  -- JRG 15-04-2015
  Ncount NUMBER;

  Maxconnection NUMBER := 5;

  FUNCTION Version_Pkg RETURN VARCHAR2 AS
  BEGIN
    RETURN Vversion;
  END;

  /* $Header: %M% %I% %E% %U% porting ship $ */
  -- Implementaci?n de procedimientos publicos del package
  PROCEDURE Inserta_Inscripcion_Gestion(p_Rut_Cliente       IN NUMBER
                                       ,p_Rut_Vendedor      IN NUMBER
                                       ,p_Local_Inscripcion IN NUMBER
                                       ,p_Fecha_Carga       IN DATE
                                       ,p_Folio_Inscripcion IN VARCHAR2
                                       ,p_Empresa           IN NUMBER
                                       ,p_Cadena            IN NUMBER
                                       ,x_Cod_Error         OUT NUMBER
                                       ,x_Msg_Error         OUT VARCHAR2) IS
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.inserta_inscripcion()';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Dv_Cliente  Scfr_Inscripciones_Fid.Dv_Cliente%TYPE;
    l_Dv_Vendedor Scfr_Inscripciones_Fid.Dv_Vendedor%TYPE;
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Obtener el digito verificador del rut del cliente';
    BEGIN
      l_Dv_Cliente := Scfr_Trx_Util_Pk.Dv_Rut(p_Rut_Cliente);
    EXCEPTION
      WHEN OTHERS THEN
        l_Dv_Cliente := NULL;
    END;
    l_Dbg_Mensaje := 'Obtener el digito verificador del rut del vendedor';
    BEGIN
      l_Dv_Vendedor := Scfr_Trx_Util_Pk.Dv_Rut(p_Rut_Vendedor);
    EXCEPTION
      WHEN OTHERS THEN
        l_Dv_Vendedor := NULL;
    END;
    l_Dbg_Mensaje := 'Insertar en scfr_inscripcion_clientes';
    INSERT INTO Scfr_Inscripciones_Fid
      (Rut_Cliente
      ,Dv_Cliente
      ,Rut_Vendedor
      ,Dv_Vendedor
      ,Local_Inscripcion
      ,Fecha_Carga
      ,Fecha_Inscripcion
      ,Folio_Inscripcion
      ,Estado
      ,Origen
      ,Emp_Empresa
      ,Cad_Cadena)
    VALUES
      (p_Rut_Cliente
      ,l_Dv_Cliente
      ,p_Rut_Vendedor
      ,l_Dv_Vendedor
      ,p_Local_Inscripcion
      ,p_Fecha_Carga
      ,Trunc(Scfr_Trx_Util_Pk.Get_Sysdate)
      ,p_Folio_Inscripcion
      ,'ACT'
      ,'POS'
      ,p_Empresa
      ,p_Cadena);
    x_Cod_Error := 0;
  EXCEPTION
    WHEN Dup_Val_On_Index THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Ya existe el cliente en SCFR_INSCRIPCIONES_FID: ' || p_Rut_Cliente);
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END Inserta_Inscripcion_Gestion;

  FUNCTION Refresco_En_Curso(p_Tipo_Refresco IN VARCHAR2) RETURN BOOLEAN IS
    l_Nro_Jobs NUMBER(3);
  BEGIN
    SELECT COUNT(*) INTO l_Nro_Jobs FROM User_Jobs WHERE What LIKE '%' || TRIM(p_Tipo_Refresco) || '%';
    IF l_Nro_Jobs > 0 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END;

  FUNCTION Determinar_Party_Id(x_Forma_Identificacion  IN VARCHAR2
                              ,p_String_Identificacion IN OUT VARCHAR2
                              ,p_Empresa               IN Scfr_Programas.Emp_Empresa%TYPE
                              ,p_Cadena                IN Scfr_Programas.Cad_Cadena%TYPE
                              ,x_Party_Id              OUT Hz_Parties.Party_Id%TYPE) RETURN NUMBER IS
    l_Rut_Cliente          Hz_Parties.Jgzz_Fiscal_Code%TYPE;
    l_Fecha_Ingreso        Scfr_Programas.Fecha_Ingreso%TYPE;
    l_Fecha_Termino        Scfr_Programas.Fecha_Termino%TYPE;
    l_Rut_Sin_Espacios     VARCHAR2(20);
    l_Resultado            NUMBER;
    l_Coderror             VARCHAR2(100);
    l_Msgerror             VARCHAR2(100);
    l_Tipo_Tarjeta         VARCHAR2(100);
    l_Desc_Tarjeta         VARCHAR2(100);
    l_Forma_Identifica     VARCHAR2(100);
    l_String_Identifica    VARCHAR2(150);
    l_Digito               VARCHAR2(1);
    l_Banda_Titular        VARCHAR2(100);
    l_Rut_Titular          VARCHAR2(20);
    l_String_Consultado    VARCHAR2(20);
    p_Forma_Identificacion VARCHAR2(1);
    l_Codigo_Convenio      NUMBER;
  BEGIN
    l_Resultado := 0;
    x_Party_Id  := 0;
    Dbms_Output.Put_Line('ENTRE A DETERMINAR_PARTY_ID...');
    Dbms_Output.Put_Line('FORMA=>' || l_Forma_Identifica);
    -- limpia rut de espacios o ceros posibles a la izquierda

    --//--------------------------------------------------------------------------\\
    --// CBR 04/10/2019 10/04/2019 11:32                                          \\
    --// CORRECCION GRABACION DESCUENTOS POR EVENTOS                              \\
    --//-----------------------------------------------------------------Inicio---\\
    p_Forma_Identificacion := x_Forma_Identificacion;
    IF x_Forma_Identificacion = 'D' AND
       Length(Ltrim(Rtrim(p_String_Identificacion))) <= 10 THEN

      p_String_Identificacion := Ltrim(Rtrim(REPLACE(p_String_Identificacion
                                                    ,'	')));
      l_Digito                := Substr(p_String_Identificacion
                                       ,Length(p_String_Identificacion)
                                       ,1);
      p_String_Identificacion := Substr(p_String_Identificacion
                                       ,1
                                       ,Length(p_String_Identificacion) - 1);
      p_String_Identificacion := To_Char(To_Number(p_String_Identificacion)) || l_Digito;

      p_Forma_Identificacion := k_Por_Rut;
      -- p_Transaccion.Trama_Boc.Forma_Identificacion  := k_Por_Rut;
      -- p_Transaccion.Trama_Boc.String_Identificacion := Ltrim(Rtrim(p_String_Identificacion));
    END IF;
    --//-----------------------------------------------------------------Termino--\\

    IF p_Forma_Identificacion = k_Por_Rut AND
       Substr(Ltrim(Rtrim(p_String_Identificacion))
             ,1
             ,1) = '0' THEN
      p_String_Identificacion := Ltrim(Rtrim(REPLACE(p_String_Identificacion
                                                    ,'	')));
      l_Digito                := Substr(p_String_Identificacion
                                       ,Length(p_String_Identificacion)
                                       ,1);
      p_String_Identificacion := Substr(p_String_Identificacion
                                       ,1
                                       ,Length(p_String_Identificacion) - 1);
      p_String_Identificacion := To_Char(To_Number(p_String_Identificacion)) || l_Digito;
    END IF;
    -- Validaci?n previa en caso que la forma de identificaci?n sea BANDA MAGNETICA
    IF p_Forma_Identificacion = k_Por_Banda_Magnetica THEN
      -- Obtiene tipo de identificaci?n desde track original.
      l_Forma_Identifica  := p_Forma_Identificacion;
      l_String_Identifica := p_String_Identificacion;
      Scfr_Track_Tarjetas_Pk.Valida_Banda_Magnetica(Ltrim(Rtrim(p_String_Identificacion))
                                                   ,l_Tipo_Tarjeta
                                                   ,l_Desc_Tarjeta
                                                   ,l_Coderror
                                                   ,l_Msgerror);
      IF Nvl(l_Coderror
            ,0) != 0 THEN
        RETURN - 5;
      END IF;
      -- Determina el tipo de identificaci?n obtenido
      IF l_Tipo_Tarjeta = 'C' THEN
        -- Informa al POS el error
        RETURN - 6;
      ELSE
        -- cambia tipo de identificaci?n a RUT
        l_Forma_Identifica      := l_Tipo_Tarjeta;
        l_String_Identifica     := l_Desc_Tarjeta;
        p_String_Identificacion := l_Desc_Tarjeta;
      END IF;
    ELSE
      l_Forma_Identifica  := p_Forma_Identificacion;
      l_String_Identifica := p_String_Identificacion;
    END IF;
    -- determina si string de identificaci?n es de beneficiario
    -- de ser asi, obtiene su rut o banda (seg?n corresponda)
    --if l_forma_identifica in ( K_POR_RUT, K_POR_CODIGO_CONVENIO ) then
    IF l_Forma_Identifica = k_Por_Codigo_Convenio THEN
      IF l_Forma_Identifica = k_Por_Codigo_Convenio THEN
        -- separa c?digo de convenio y rut
        l_Codigo_Convenio   := To_Number(REPLACE(Substr(Ltrim(Rtrim(l_String_Identifica))
                                                       ,1
                                                       ,15)
                                                ,''));
        l_String_Identifica := Substr(Ltrim(Rtrim(l_String_Identifica))
                                     ,16);
      ELSE
        l_Codigo_Convenio   := NULL;
        l_String_Identifica := Ltrim(Rtrim(l_String_Identifica));
      END IF;
      l_String_Identifica := Substr(Ltrim(Rtrim(l_String_Identifica))
                                   ,1
                                   ,Length(Ltrim(Rtrim(l_String_Identifica))) - 1);
      -- revisa si el rut corresponde a un beneficiario, en tal caso, lo cambia por el del titular
      l_Rut_Titular := Scfr_Conv_Pk.Obtiene_Rut_Titular(Scfr_Conv_Pk.Entrega_Codigo_Empresa(p_Empresa)
                                                       ,l_String_Identifica --, substr( ltrim( rtrim( l_string_consultado ) ), 1, length( ltrim( rtrim( l_string_consultado ) ) )-1)
                                                       ,l_Codigo_Convenio);
      IF l_Rut_Titular IS NOT NULL THEN
        l_String_Identifica     := Lpad(To_Char(l_Codigo_Convenio)
                                       ,15
                                       ,'0') || l_Rut_Titular;
        p_String_Identificacion := l_String_Identifica;
      ELSE
        l_String_Identifica := p_String_Identificacion; -- le reestablece el digito verificador
      END IF;
    ELSIF l_Forma_Identifica = k_Por_Banda_Magnetica THEN
      l_Banda_Titular := Scfr_Conv_Pk.Obtiene_Banda_Titular(Scfr_Conv_Pk.Entrega_Codigo_Empresa(p_Empresa)
                                                           ,Ltrim(Rtrim(l_String_Identifica)));
      IF l_Banda_Titular IS NOT NULL THEN
        l_String_Identifica     := l_Banda_Titular;
        p_String_Identificacion := l_Banda_Titular;
      END IF;
    END IF;
    IF l_Forma_Identifica IN (k_Por_Rut
                             ,k_Por_Codigo_Convenio) THEN
      Dbms_Output.Put_Line('FORMA=>' || l_Forma_Identifica);
      Dbms_Output.Put_Line('STRING=>' || l_String_Identifica);
      BEGIN
        IF l_Forma_Identifica = k_Por_Codigo_Convenio THEN
          l_Rut_Sin_Espacios := Ltrim(Rtrim(REPLACE(Substr(l_String_Identifica
                                                          ,16)
                                                   ,'	')));
        ELSE
          l_Rut_Sin_Espacios := Ltrim(Rtrim(REPLACE(l_String_Identifica
                                                   ,'	')));
        END IF;
        l_Rut_Cliente := Substr(l_Rut_Sin_Espacios
                               ,1
                               ,Length(l_Rut_Sin_Espacios) - 1);
        Dbms_Output.Put_Line('l_rut_cliente=>' || l_Rut_Cliente);
        -- Obtiene party ID desde AR seg?n un rut.
        SELECT Party_Id INTO x_Party_Id FROM Hz_Parties WHERE Jgzz_Fiscal_Code = l_Rut_Cliente;
      EXCEPTION
        WHEN OTHERS THEN
          BEGIN
            SELECT Party_Id INTO x_Party_Id FROM Scfr_Tmp_Clientes WHERE Rut = To_Number(l_Rut_Cliente);
          EXCEPTION
            WHEN No_Data_Found THEN
              l_Resultado := -1;
              x_Party_Id  := 0;
            WHEN OTHERS THEN
              l_Resultado := -4;
              x_Party_Id  := 0;
          END;
      END;
    ELSIF l_Forma_Identifica = k_Por_Banda_Magnetica THEN
      -- Obtiene party ID desde convenios seg?n una banda magnetica.
      Dbms_Output.Put_Line(l_String_Identifica || ' ' || x_Party_Id);
      Scfr_Conv_Pk.Entrega_Party_Id_Credencial(Ltrim(Rtrim(l_String_Identifica))
                                              ,x_Party_Id
                                              ,l_Coderror
                                              ,l_Msgerror);
      Dbms_Output.Put_Line(l_String_Identifica || ' ' || x_Party_Id || ' ' || l_Msgerror || ' ' || l_Coderror);
      --if x_party_id < 1 then
      IF To_Number(l_Coderror) != 0 THEN
        -- No encontro Party ID. Asigna c?digo de error relacionado.
        --if x_party_id = 0 then
        --   x_party_id := -9;
        --end if;
        --l_resultado := x_party_id;
        --x_party_id  := 0;
        --l_resultado := scfr_trx_conv_pk.obtiene_error( to_number( l_coderror ) );
        --l_resultado := to_number( l_coderror );
        -- si no se encuentra banda en tabla de credenciales, se debe buscar en tabla de programas
        l_Forma_Identifica := k_Por_Codigo_Barra;
      END IF;
    END IF;
    IF l_Forma_Identifica IN (k_Por_Codigo_Barra
                             ,k_Por_Tcv_Solventa) THEN
      BEGIN
        SELECT Pt_Party_Id
              ,Decode(Estado_Tarjeta
                     ,'INA'
                     ,-8
                     ,'BLQ'
                     ,-10
                     ,0)
              ,Fecha_Ingreso
              ,Fecha_Termino
          INTO x_Party_Id
              ,l_Resultado
              ,l_Fecha_Ingreso
              ,l_Fecha_Termino
          FROM Scfr_Programas
         WHERE Folio = Ltrim(Rtrim(l_String_Identifica))
           AND Emp_Empresa = p_Empresa
           AND Cad_Cadena = p_Cadena
           AND Estado_Tarjeta != 'REA';
        IF Trunc(Nvl(l_Fecha_Termino
                    ,Scfr_Trx_Util_Pk.Get_Sysdate() + 1)) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) THEN
          l_Resultado := -2;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          BEGIN
            SELECT Party_Id INTO x_Party_Id FROM Scfr_Tmp_Clientes WHERE Folio_Tarjeta_Mcv = Ltrim(Rtrim(l_String_Identifica));
          EXCEPTION
            WHEN OTHERS THEN
              IF l_Forma_Identifica = k_Por_Tcv_Solventa THEN
                l_Resultado := -11;
              ELSE
                l_Resultado := -3;
              END IF;
              x_Party_Id := 0;
          END;
      END;
    END IF;
    RETURN(l_Resultado);
  END;

  PROCEDURE Determina_Cliente(p_Forma_Identificacion  IN VARCHAR2
                             ,p_String_Identificacion IN OUT VARCHAR2
                             ,p_Empresa               IN Scfr_Programas.Emp_Empresa%TYPE
                             ,p_Cadena                IN Scfr_Programas.Cad_Cadena%TYPE
                             ,x_Cliente               OUT Rec_Datos_Cliente
                             ,x_Cod_Error             OUT NUMBER
                             ,x_Msg_Error             OUT VARCHAR2) IS
    l_Rut_Cliente       Hz_Parties.Jgzz_Fiscal_Code%TYPE;
    l_Rut_Sin_Espacios  VARCHAR2(20);
    l_Tipo_Tarjeta      VARCHAR2(100);
    l_Desc_Tarjeta      VARCHAR2(100);
    l_Forma_Identifica  VARCHAR2(100);
    l_String_Identifica VARCHAR2(150);
    l_Dbg_Proceso       VARCHAR2(100) := 'SCFR_TRX_FID_PK.determina_cliente';
    l_Dbg_Mensaje       VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    -- Validaci?n previa en caso que la forma de identificaci?n sea BANDA MAGNETICA
    l_Dbg_Mensaje := 'Validar forma de identificaci?n';
    IF p_Forma_Identificacion = k_Por_Banda_Magnetica THEN
      -- Obtiene tipo de identificaci?n desde track original.
      l_Dbg_Mensaje       := 'LLamar a scfr_track_tarjetas_pk.valida_banda_magnetica';
      l_Forma_Identifica  := p_Forma_Identificacion;
      l_String_Identifica := p_String_Identificacion;
      Scfr_Track_Tarjetas_Pk.Valida_Banda_Magnetica(Ltrim(Rtrim(p_String_Identificacion))
                                                   ,l_Tipo_Tarjeta
                                                   ,l_Desc_Tarjeta
                                                   ,x_Cod_Error
                                                   ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        x_Cliente.Party_Id := -5;
        RAISE l_Error_Controlado;
      END IF;
      -- Valida resultado de la rutina scfr_track_tarjetas_pk.valida_banda_magnetica
      l_Dbg_Mensaje := 'Validar resultado obtenido desde scfr_track_tarjetas_pk.valida_banda_magnetica';
      IF l_Tipo_Tarjeta = 'C' THEN
        -- Informa al POS el error
        x_Cliente.Party_Id := -6;
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
        RAISE l_Error_Controlado;
      ELSE
        -- cambia tipo de identificaci?n a RUT
        l_Forma_Identifica  := l_Tipo_Tarjeta;
        l_String_Identifica := l_Desc_Tarjeta;
      END IF;
    ELSE
      l_Forma_Identifica  := p_Forma_Identificacion;
      l_String_Identifica := p_String_Identificacion;
    END IF;
    IF l_Forma_Identifica IN (k_Por_Rut
                             ,k_Por_Codigo_Convenio) THEN
      BEGIN
        l_Dbg_Mensaje := 'Obtener rut sin digito desde el string de identificaci?n';
        IF l_Forma_Identifica = k_Por_Codigo_Convenio THEN
          l_Rut_Sin_Espacios := Ltrim(Rtrim(REPLACE(Substr(l_String_Identifica
                                                          ,16)
                                                   ,'	')));
        ELSE
          l_Rut_Sin_Espacios := Ltrim(Rtrim(REPLACE(l_String_Identifica
                                                   ,'	')));
        END IF;
        l_Rut_Cliente := Substr(l_Rut_Sin_Espacios
                               ,1
                               ,Length(l_Rut_Sin_Espacios) - 1);
        -- Obtiene datos del cliente seg?n un rut.
        l_Dbg_Mensaje := 'Obtener party ID del cliente desde HZ_PARTIES seg?n rut ' || l_Rut_Cliente;
        SELECT Party_Id
              ,Jgzz_Fiscal_Code
              ,Scfr_Trx_Util_Pk.Dv_Rut(Jgzz_Fiscal_Code)
          INTO x_Cliente.Party_Id
              ,x_Cliente.Rut
              ,x_Cliente.Dv_Rut
          FROM Hz_Parties
         WHERE Jgzz_Fiscal_Code = l_Rut_Cliente;
      EXCEPTION
        WHEN No_Data_Found THEN
          x_Cliente.Party_Id := -1;
          Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                    ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
        WHEN Too_Many_Rows THEN
          x_Cliente.Party_Id := -2;
          Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                    ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
        WHEN OTHERS THEN
          x_Cliente.Party_Id := -4;
          Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                    ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      END;
    ELSIF l_Forma_Identifica = k_Por_Banda_Magnetica THEN
      -- Obtiene party ID desde convenios seg?n una banda magnetica.
      l_Dbg_Mensaje := 'LLamar a scfr_conv_pk.entrega_party_id_credencial()';
      Scfr_Conv_Pk.Entrega_Party_Id_Credencial(Ltrim(Rtrim(l_String_Identifica))
                                              ,x_Cliente.Party_Id
                                              ,x_Cod_Error
                                              ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        x_Cliente.Party_Id := -9;
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => 'Error ' || x_Msg_Error || ' al intentar ' || l_Dbg_Mensaje);
      ELSE
        l_Dbg_Mensaje := 'LLamar a obtiene_rut()';
        Obtiene_Rut(x_Cliente.Party_Id
                   ,x_Cliente.Rut
                   ,x_Cliente.Dv_Rut);
      END IF;
    ELSIF l_Forma_Identifica = k_Por_Codigo_Barra THEN
      -- por C?IGO DE BARRA.
      l_Dbg_Mensaje := 'Obtener party ID desde tabla SCFR_PROGRAMAS';
      BEGIN
        SELECT Pt_Party_Id
          INTO x_Cliente.Party_Id
          FROM Scfr_Programas
         WHERE Folio = Ltrim(Rtrim(l_String_Identifica))
           AND Emp_Empresa = p_Empresa
           AND Cad_Cadena = p_Cadena
           AND Estado_Tarjeta = 'ACT';
        l_Dbg_Mensaje := 'LLamar a obtiene_rut()';
        Obtiene_Rut(x_Cliente.Party_Id
                   ,x_Cliente.Rut
                   ,x_Cliente.Dv_Rut);
      EXCEPTION
        WHEN OTHERS THEN
          x_Cliente.Party_Id := -3;
          Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                    ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      END;
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

  PROCEDURE Determina_Cliente(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cliente     OUT Rec_Datos_Cliente
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
  BEGIN
    Determina_Cliente(p_Transaccion.Trama_Boc.Forma_Identificacion
                     ,p_Transaccion.Trama_Boc.String_Identificacion
                     ,p_Transaccion.Trama_Pos.Empresa
                     ,p_Transaccion.Trama_Pos.Cadena
                     ,x_Cliente
                     ,x_Cod_Error
                     ,x_Msg_Error);
  END;

  PROCEDURE Act_Datos_Perso(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion) IS
  BEGIN
    NULL;
  END;

  PROCEDURE Act_Datos_Comer(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion) IS
  BEGIN
    NULL;
  END;

  PROCEDURE Act_Datos_Benef(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion) IS
  BEGIN
    NULL;
  END;

  PROCEDURE Ins_Produ_Fide_Crm(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion) IS
  BEGIN
    NULL;
  END;

  PROCEDURE Ins_Comp_Frec_Crm(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion) IS
  BEGIN
    NULL;
  END;

  PROCEDURE Act_Cupon_Impreso(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion) IS
  BEGIN
    NULL;
  END;

  PROCEDURE Obtiene_Rut(p_Party_Id IN Scfr_Mov_Transacciones.Pt_Party_Id_Titular%TYPE
                       ,x_Rut      OUT Scfr_Mov_Transacciones.Rut_Titular%TYPE
                       ,x_Dv_Rut   OUT Scfr_Mov_Transacciones.Dv_Titular%TYPE) IS
  BEGIN
    SELECT Jgzz_Fiscal_Code
          ,Scfr_Trx_Util_Pk.Dv_Rut(Jgzz_Fiscal_Code)
      INTO x_Rut
          ,x_Dv_Rut
      FROM Hz_Parties
     WHERE Party_Id = p_Party_Id;
  EXCEPTION
    WHEN No_Data_Found THEN
      BEGIN
        -- puede ser que el cliente haya sido creado en tabla temportal porque la EBSO no esta disponible
        -- en este caso, se debe buscar el rut en tabla temportal
        SELECT Rut
              ,Dv
          INTO x_Rut
              ,x_Dv_Rut
          FROM Scfr_Tmp_Clientes
         WHERE Party_Id = p_Party_Id;
      EXCEPTION
        WHEN OTHERS THEN
          x_Rut    := NULL;
          x_Dv_Rut := NULL;
      END;
    WHEN OTHERS THEN
      x_Rut    := NULL;
      x_Dv_Rut := NULL;
  END;

  PROCEDURE Obtiene_Rut(p_Forma_Identificacion  IN OUT VARCHAR2
                       ,p_String_Identificacion IN OUT VARCHAR2
                       ,p_Empresa               IN NUMBER
                       ,p_Cadena                IN NUMBER
                       ,x_Rut                   OUT Scfr_Mov_Transacciones.Rut_Titular%TYPE
                       ,x_Dv_Rut                OUT Scfr_Mov_Transacciones.Dv_Titular%TYPE) IS
    l_Resultado NUMBER;
    l_Party_Id  NUMBER;
  BEGIN
    l_Resultado := Scfr_Trx_Fid_Pk.Determinar_Party_Id(p_Forma_Identificacion
                                                      ,p_String_Identificacion
                                                      ,p_Empresa
                                                      ,p_Cadena
                                                      ,l_Party_Id);
    Obtiene_Rut(l_Party_Id
               ,x_Rut
               ,x_Dv_Rut);
  EXCEPTION
    WHEN OTHERS THEN
      x_Rut    := NULL;
      x_Dv_Rut := NULL;
  END;

  FUNCTION Obtiene_Rut_Solventa(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion) RETURN VARCHAR2 IS
    l_Consulta_Saldo Scfr_Trx_Solventa_Pk.Rec_Consulta_Saldo;
    l_Cod_Error      NUMBER;
    l_Msg_Error      VARCHAR2(250);
    l_Rut_Cliente    VARCHAR2(20);
  BEGIN
    Scfr_Trx_Solventa_Pk.Ao58(p_Indicador_Tarjeta => p_Transaccion.Trama_Boc.Forma_Identificacion
                             ,p_Banda_Magnetica   => p_Transaccion.Trama_Boc.String_Identificacion
                             ,p_Fecha             => To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                                            ,'YYYY/MM/DD HH24:MI:SS')
                             ,p_Local             => p_Transaccion.Trama_Pos.Local
                             ,p_Numero_Pos        => p_Transaccion.Trama_Pos.Id_Maquina
                             ,p_Id_Maquina        => p_Transaccion.Trama_Pos.Numero_Pos
                             ,p_Responsable       => p_Transaccion.Trama_Pos.Usuario_Responsable
                             ,p_Rut               => NULL
                             ,p_Convenio          => NULL
                             ,p_Folio             => NULL
                             ,x_Consulta_Saldo    => l_Consulta_Saldo
                             ,x_Cod_Error         => l_Cod_Error
                             ,x_Msg_Error         => l_Msg_Error);
    IF Nvl(l_Cod_Error
          ,0) = 0 THEN
      IF l_Consulta_Saldo.Cuentas.Count > 0 THEN
        -- se asume que en este caso de consulta, siempre viene una sola cuenta.
        l_Rut_Cliente := l_Consulta_Saldo.Cuentas(1).Rut_Titular;
      ELSE
        Raise_Application_Error(-20000
                               ,'Respuesta de Solventa no contiene Cuentas');
      END IF;
    ELSE
      Raise_Application_Error(-20000
                             ,'Error=' || l_Cod_Error || '-' || l_Msg_Error);
    END IF;
    RETURN l_Rut_Cliente;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'SCFR_TRX_FID_PK.obtiene_rut_solventa'
                                ,p_Msg     => 'Error al intentar obtener rut desde solventa');
      RETURN NULL;
  END;

  FUNCTION Obtiene_Dcto_Solventa(p_Transaccion   IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                ,p_Folio_Tarjeta IN Scfr_Clientes_Tarjetas_Vm.Folio_Tarjeta%TYPE
                                ,l_Rut           IN Scfr_Mov_Transacciones.Rut_Titular%TYPE
                                ,l_Dv_Rut        IN Scfr_Mov_Transacciones.Dv_Titular%TYPE) RETURN NUMBER IS
    l_Consulta_Saldo Scfr_Trx_Solventa_Pk.Rec_Consulta_Saldo;
    l_Cod_Error      NUMBER;
    l_Msg_Error      VARCHAR2(250);
    l_Saldo_Dcto     NUMBER;
    l_Saldos         NUMBER;
    l_Rut_String     VARCHAR2(10);
    l_Forma_String   VARCHAR2(1);
    l_Banda_String   VARCHAR2(30);
  BEGIN
    l_Saldos       := 0;
    l_Forma_String := Ltrim(Rtrim(p_Transaccion.Trama_Boc.Forma_Identificacion));
    l_Banda_String := Ltrim(Rtrim(p_Transaccion.Trama_Boc.String_Identificacion));
    IF l_Forma_String = 'C' THEN
      l_Forma_String := 'R';
      l_Banda_String := Rtrim(Ltrim(To_Char(l_Rut) || l_Dv_Rut));
    END IF;
    IF l_Rut > 0 THEN
      l_Rut_String := Rtrim(Ltrim(To_Char(l_Rut) || l_Dv_Rut));
    ELSE
      l_Rut_String := '';
    END IF;
    l_Forma_String := 'B';
    l_Banda_String := p_Folio_Tarjeta;
    Scfr_Trx_Solventa_Pk.Ao58(p_Indicador_Tarjeta => l_Forma_String
                             ,p_Banda_Magnetica   => l_Banda_String
                             ,p_Fecha             => To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                                            ,'YYYY/MM/DD HH24:MI:SS')
                             ,p_Local             => p_Transaccion.Trama_Pos.Local
                             ,p_Numero_Pos        => p_Transaccion.Trama_Pos.Id_Maquina
                             ,p_Id_Maquina        => p_Transaccion.Trama_Pos.Numero_Pos
                             ,p_Responsable       => p_Transaccion.Trama_Pos.Usuario_Responsable
                             ,p_Rut               => l_Rut_String
                             ,p_Convenio          => NULL
                             ,p_Folio             => NULL
                             ,x_Consulta_Saldo    => l_Consulta_Saldo
                             ,x_Cod_Error         => l_Cod_Error
                             ,x_Msg_Error         => l_Msg_Error);
    IF Nvl(l_Cod_Error
          ,0) = 0 THEN
      IF l_Consulta_Saldo.Cuentas.Count = 0 THEN
        Raise_Application_Error(-20000
                               ,'Respuesta de Solventa no contiene Cuentas');
      ELSE
        FOR Item IN 1 .. l_Consulta_Saldo.Cuentas.Count
        LOOP
          IF l_Consulta_Saldo.Cuentas(Item).Numero_Tarjeta = p_Folio_Tarjeta THEN
            l_Saldo_Dcto := l_Consulta_Saldo.Cuentas(Item).Monto_Dscto_Disponible;
            l_Saldos     := l_Saldos + 1;
          END IF;
        END LOOP;
      END IF;
    ELSE
      Raise_Application_Error(-20000
                             ,'Error=' || l_Cod_Error || '-' || l_Msg_Error);
    END IF;
    IF l_Saldos > 0 THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'SCFR_TRX_FID_PK.obtiene_dcto_solventa'
                                ,p_Msg     => To_Char(l_Saldos) || ' Saldo(s) descuento encontrado(s) para ' || p_Folio_Tarjeta);
    ELSE
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'SCFR_TRX_FID_PK.obtiene_dcto_solventa'
                                ,p_Msg     => 'No se encontro saldo descuento para ' || p_Folio_Tarjeta);
    END IF;
    RETURN l_Saldo_Dcto;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'SCFR_TRX_FID_PK.obtiene_dcto_solventa'
                                ,p_Msg     => 'Error al intentar obtener saldo descuento desde solventa');
      RETURN NULL;
  END;

  FUNCTION Obtiene_Direccion_Cliente(p_Party_Id       IN NUMBER
                                    ,p_Tipo_Direccion IN VARCHAR2
                                    ,x_Cod_Error      OUT NUMBER
                                    ,x_Msg_Error      OUT VARCHAR2) RETURN Rec_Datos_Direccion IS
    l_Datos_Direccion Rec_Datos_Direccion;
  BEGIN
    SELECT Hpsu.Site_Use_Type Tipo
          ,Ltrim(Rtrim(Hzlo.Street)) Direccion
           --           || ' '  || hzlo.street_number
           --           || ', ' || hzlo.suite
           --           || ', ' || hzlo.building))     direccion
          ,Nvl(Hzlo.Province
              ,0) Comuna
          ,Nvl(Hzlo.City
              ,0) Ciudad
      INTO l_Datos_Direccion.Tipo_Direccion
          ,l_Datos_Direccion.Direccion
          ,l_Datos_Direccion.Comuna
          ,l_Datos_Direccion.Ciudad
      FROM Hz_Locations       Hzlo
          ,Hz_Party_Sites     Hzps
          ,Hz_Party_Site_Uses Hpsu
     WHERE Hzlo.Location_Id = Hzps.Location_Id
       AND Hzps.Party_Site_Id = Hpsu.Party_Site_Id
       AND Hzps.Party_Id = p_Party_Id
       AND Hpsu.Site_Use_Type = p_Tipo_Direccion
       AND Hpsu.Primary_Per_Type = 'Y'
       AND Rownum = 1;
    RETURN l_Datos_Direccion;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_Datos_Direccion;
  END;

  FUNCTION Obtiene_Direccion_Cliente(p_Party_Id  IN NUMBER
                                    ,x_Cod_Error OUT NUMBER
                                    ,x_Msg_Error OUT VARCHAR2) RETURN Tab_Datos_Direccion IS
    l_Datos_Direccion Tab_Datos_Direccion;
    l_Item            NUMBER;
    CURSOR c_Direccion IS
      SELECT Hpsu.Site_Use_Type Tipo
            ,Ltrim(Rtrim(Hzlo.Street)) Direccion
             --             || ' '  || hzlo.street_number
             --             || ', ' || hzlo.suite
             --             || ', ' || hzlo.building))    direccion
            ,Nvl(Hzlo.Province
                ,0) Comuna
            ,Nvl(Hzlo.City
                ,0) Ciudad
        FROM Hz_Locations       Hzlo
            ,Hz_Party_Sites     Hzps
            ,Hz_Party_Site_Uses Hpsu
       WHERE Hzlo.Location_Id = Hzps.Location_Id
         AND Hzps.Party_Site_Id = Hpsu.Party_Site_Id
         AND Hzps.Party_Id = p_Party_Id
            --and    hpsu.site_use_type in ( 'HOME', 'BILL_TO' )
         AND Hpsu.Primary_Per_Type = 'Y';
  BEGIN
    l_Item := 0;
    FOR Reg IN c_Direccion
    LOOP
      l_Item := l_Item + 1;
      l_Datos_Direccion(l_Item).Tipo_Direccion := Reg.Tipo;
      l_Datos_Direccion(l_Item).Direccion := Reg.Direccion;
      l_Datos_Direccion(l_Item).Comuna := Reg.Comuna;
      l_Datos_Direccion(l_Item).Ciudad := Reg.Ciudad;
    END LOOP;
    RETURN l_Datos_Direccion;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_Datos_Direccion;
  END;

  FUNCTION Obtiene_Contacto_Cliente(p_Party_Id      IN NUMBER
                                   ,p_Tipo_Contacto IN VARCHAR2
                                   ,p_Tipo_Fono     IN VARCHAR2 DEFAULT NULL
                                   ,x_Cod_Error     OUT NUMBER
                                   ,x_Msg_Error     OUT VARCHAR2) RETURN Rec_Datos_Contacto IS
    l_Datos_Contacto Rec_Datos_Contacto;
  BEGIN
    SELECT Contact_Point_Type Tipo_Contacto
          ,Phone_Line_Type    Tipo_Fono
          ,Phone_Number       Numero
          ,Email_Address      Email
          ,Primary_By_Purpose
      INTO l_Datos_Contacto.Tipo_Contacto
          ,l_Datos_Contacto.Tipo_Fono
          ,l_Datos_Contacto.Numero
          ,l_Datos_Contacto.Email
          ,l_Datos_Contacto.Primary_By_Purpose
      FROM Hz_Contact_Points
     WHERE Contact_Point_Type = p_Tipo_Contacto
       AND Phone_Line_Type = Nvl(p_Tipo_Fono
                                ,Phone_Line_Type)
       AND Owner_Table_Id = p_Party_Id;
    RETURN l_Datos_Contacto;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_Datos_Contacto;
  END;

  FUNCTION Obtiene_Contacto_Cliente(p_Party_Id  IN NUMBER
                                   ,x_Cod_Error OUT NUMBER
                                   ,x_Msg_Error OUT VARCHAR2) RETURN Tab_Datos_Contacto IS
    CURSOR c_Contactos IS
      SELECT Contact_Point_Type Tipo_Contacto
            ,Phone_Line_Type    Tipo_Fono
            ,Phone_Number       Numero
            ,Email_Address      Email
            ,Primary_By_Purpose
        FROM Hz_Contact_Points
       WHERE Contact_Point_Type IN ('PHONE'
                                   ,'FAX'
                                   ,'EMAIL')
         AND Nvl(Phone_Line_Type
                ,' ') IN ('GEN'
                         ,'MOBILE'
                         ,' ')
         AND Owner_Table_Id = p_Party_Id;
    l_Datos_Contacto Tab_Datos_Contacto;
    l_Item           NUMBER;
  BEGIN
    l_Item := 0;
    FOR Reg IN c_Contactos
    LOOP
      l_Item := l_Item + 1;
      l_Datos_Contacto(l_Item).Tipo_Contacto := Reg.Tipo_Contacto;
      l_Datos_Contacto(l_Item).Tipo_Fono := Reg.Tipo_Fono;
      l_Datos_Contacto(l_Item).Numero := Reg.Numero;
      l_Datos_Contacto(l_Item).Email := Reg.Email;
      l_Datos_Contacto(l_Item).Primary_By_Purpose := Reg.Primary_By_Purpose;
    END LOOP;
    RETURN l_Datos_Contacto;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_Datos_Contacto;
  END;

  FUNCTION Obtiene_Datos_Personales(p_Party_Id  IN NUMBER
                                   ,p_Folio     IN VARCHAR2 DEFAULT NULL
                                   ,p_Empresa   IN NUMBER
                                   ,x_Cod_Error OUT NUMBER
                                   ,x_Msg_Error OUT VARCHAR2) RETURN Rec_Datos_Cliente IS
    l_Datos_Cliente Rec_Datos_Cliente;
    l_Party_Id_Rel  NUMBER;
    l_Item          NUMBER;
    l_Existe        BOOLEAN;
    l_Id_Relacion   NUMBER;
  BEGIN
    BEGIN
      -- busca al cliente desde tabla temporal
      SELECT Substr(Cli.Apellido_Paterno
                   ,1
                   ,30)
            ,Substr(Cli.Apellido_Materno
                   ,1
                   ,30)
            ,Substr(Cli.Nombres
                   ,1
                   ,50)
            ,Cli.Fecha_Hora_Actualizacion
            ,Upper(Substr(Cli.Sexo
                         ,1
                         ,3))
            ,To_Date(Nvl(Cli.Fecha_Nacimiento
                        ,To_Number(To_Char(SYSDATE
                                          ,'yyyymmdd')))
                    ,'yyyy/mm/dd')
            ,Inscrito_Mas_Cruz_Verde -- 'S'
            ,Decode(Inscrito_Mas_Cruz_Verde
                   ,'S'
                   ,Cli.Folio_Tarjeta_Mcv
                   ,NULL)
            ,Cli.Tipo_Creacion
            ,'HOME'
            ,Cli.Direccion
            ,Cli.Comuna
            ,Cli.Ciudad
            ,'PHONE'
            ,'GEN'
            ,Cli.Telefono_Particular
            ,NULL
            ,'N'
            ,'EMAIL'
            ,NULL
            ,NULL
            ,Cli.Email
            ,'Y'
            ,Cli.Empresa
            ,Cli.Institucion_Salud
        INTO l_Datos_Cliente.Apellido_Paterno
            ,l_Datos_Cliente.Apellido_Materno
            ,l_Datos_Cliente.Nombres
            ,l_Datos_Cliente.Fecha_Ultima_Act
            ,l_Datos_Cliente.Sexo
            ,l_Datos_Cliente.Fecha_Nacimiento
            ,l_Datos_Cliente.Inscrito_Mcv
            ,l_Datos_Cliente.Folio_Tmcv
            ,l_Datos_Cliente.Tipo_Creacion
            ,l_Datos_Cliente.Direcciones      (1).Tipo_Direccion
            ,l_Datos_Cliente.Direcciones      (1).Direccion
            ,l_Datos_Cliente.Direcciones      (1).Comuna
            ,l_Datos_Cliente.Direcciones      (1).Ciudad
            ,l_Datos_Cliente.Contactos        (1).Tipo_Contacto
            ,l_Datos_Cliente.Contactos        (1).Tipo_Fono
            ,l_Datos_Cliente.Contactos        (1).Numero
            ,l_Datos_Cliente.Contactos        (1).Email
            ,l_Datos_Cliente.Contactos        (1).Primary_By_Purpose
            ,l_Datos_Cliente.Contactos        (2).Tipo_Contacto
            ,l_Datos_Cliente.Contactos        (2).Tipo_Fono
            ,l_Datos_Cliente.Contactos        (2).Numero
            ,l_Datos_Cliente.Contactos        (2).Email
            ,l_Datos_Cliente.Contactos        (2).Primary_By_Purpose
            ,l_Datos_Cliente.Empresa
            ,l_Datos_Cliente.Institucion_Salud
        FROM Scfr_Tmp_Clientes Cli
       WHERE Cli.Party_Id = p_Party_Id;
      IF p_Empresa != l_Datos_Cliente.Empresa THEN
        l_Datos_Cliente.Inscrito_Mcv     := 'N';
        l_Datos_Cliente.Folio_Tmcv       := NULL;
        l_Datos_Cliente.Tipo_Creacion    := NULL;
        l_Datos_Cliente.Fecha_Ultima_Act := SYSDATE;
      ELSE
        RETURN l_Datos_Cliente;
      END IF;
      /* l_existe := TRUE;
      RETURN l_datos_cliente;    */
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Existe := FALSE;
      WHEN OTHERS THEN
        RAISE;
    END;
    -- JRG si no existe cliente en la SCFR_TMP_CLIENTES, se obtiene datos de tablas de la EBSO. 02072019
    IF NOT l_Existe THEN
      -- Obtiene datos de la tabla HZ_PARTIES
      SELECT Substr(Person_Last_Name
                   ,1
                   ,30)
            ,Substr(Person_Middle_Name
                   ,1
                   ,30)
            ,Substr(Person_First_Name
                   ,1
                   ,50)
            ,Last_Update_Date
        INTO l_Datos_Cliente.Apellido_Paterno
            ,l_Datos_Cliente.Apellido_Materno
            ,l_Datos_Cliente.Nombres
            ,l_Datos_Cliente.Fecha_Ultima_Act
        FROM Hz_Parties
       WHERE Party_Id = p_Party_Id;
      -- Obtiene datos de la tabla hz_person_profiles
      BEGIN
        SELECT Decode(Ltrim(Rtrim(Gender))
                     ,'FEMALE'
                     ,'FEM'
                     ,'MALE'
                     ,'MAS'
                     ,'F'
                     ,'FEM'
                     ,'M'
                     ,'MAS'
                     ,Substr(Gender
                            ,1
                            ,3))
              ,Date_Of_Birth
          INTO l_Datos_Cliente.Sexo
              ,l_Datos_Cliente.Fecha_Nacimiento
          FROM Hz_Person_Profiles
         WHERE Party_Id = p_Party_Id
           AND Person_Profile_Id = (SELECT MAX(Person_Profile_Id) FROM Hz_Person_Profiles WHERE Party_Id = p_Party_Id)
           AND Rownum = 1;
      EXCEPTION
        WHEN OTHERS THEN
          l_Datos_Cliente.Sexo             := 'MAS';
          l_Datos_Cliente.Fecha_Nacimiento := NULL;
      END;
      -- obtiene party id de la relaci?n "ES_FIDELIZADO"
      l_Party_Id_Rel := Scfr_Trx_Util_Pk.Busca_Party_Id_Relacion(p_Party_Id
                                                                ,Scfr_Trx_Util_Pk.Obtiene_Party_Id(Scfr_Trx_Util_Pk.Rut_Con_Org_Id(p_Empresa
                                                                                                                                  ,Scfr_Trx_Util_Pk.Instancia))
                                                                ,'ES_FIDELIZADO'
                                                                ,p_Empresa
                                                                ,l_Id_Relacion);
      IF Nvl(l_Party_Id_Rel
            ,0) > 0 THEN
        l_Datos_Cliente.Inscrito_Mcv := 'S';
      ELSE
        l_Datos_Cliente.Inscrito_Mcv := 'N';
      END IF;
      -- obtiene direcciones del cliente
      l_Datos_Cliente.Direcciones := Obtiene_Direccion_Cliente(l_Party_Id_Rel
                                                              ,x_Cod_Error
                                                              ,x_Msg_Error);
      -- obtiene contactos del cliente
      l_Datos_Cliente.Contactos := Obtiene_Contacto_Cliente(l_Party_Id_Rel
                                                           ,x_Cod_Error
                                                           ,x_Msg_Error);
    END IF;
    BEGIN
      SELECT Folio
            ,Decode(Programa
                   ,'MCV'
                   ,'CRE'
                   ,'CPS') Programa
        INTO l_Datos_Cliente.Folio_Tmcv
            ,l_Datos_Cliente.Tipo_Creacion
        FROM Scfr_Programas
       WHERE Pt_Party_Id = p_Party_Id
         AND Folio = Nvl(p_Folio
                        ,Folio)
         AND Programa IN ('MCV'
                         ,'PSD')
         AND Estado_Tarjeta = 'ACT'
         AND Emp_Empresa = p_Empresa
         AND Trunc(Fecha_Ingreso) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
         AND Trunc(Nvl(Fecha_Termino
                      ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate());
    EXCEPTION
      WHEN OTHERS THEN
        NULL; --l_datos_cliente.folio_tmcv := ' ';
    END;
    RETURN l_Datos_Cliente;
  EXCEPTION
    WHEN OTHERS THEN
      x_Cod_Error                      := SQLCODE;
      x_Msg_Error                      := SQLERRM;
      l_Datos_Cliente.Apellido_Paterno := ' ';
      l_Datos_Cliente.Apellido_Materno := ' ';
      l_Datos_Cliente.Nombres          := ' ';
      l_Datos_Cliente.Fecha_Ultima_Act := NULL;
      RETURN l_Datos_Cliente;
  END;

  --//--------------------------------------------------------------------------\\
  --// CBR 08/13/2018 10:29AM                                                    \\
  --//                                                                          \\
  --//-----------------------------------------------------------------Inicio---\\
  FUNCTION Obtiene_Datos_Loyalty(l_Transaccion    IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                ,x_Id_Sec_Lotalty OUT NUMBER
                                ,x_Cod_Error      OUT NUMBER
                                ,x_Msg_Error      OUT VARCHAR2) RETURN Rec_Datos_Cliente IS

    l_Datos_Cliente Rec_Datos_Cliente;
    l_Party_Id_Rel  NUMBER;
    l_Item          NUMBER;
    l_Itm2          NUMBER;
    l_Existe        BOOLEAN;
    l_Id_Relacion   NUMBER;
    Id_r            NUMBER;
    l_Dbg_Mensaje   VARCHAR2(200);
    
    --INI JAGC F8 20241204 
    cadena_original    VARCHAR2(150);
    tipo_convenio      NUMBER;
    tipo_identificacion VARCHAR2(1);
    identificacion      VARCHAR2(50);    
    --FIN JAGC F8 20241204 
    
  BEGIN
    x_Cod_Error   := 0;
    l_Dbg_Mensaje := 'Obtener datos desde GEOLOYALTY ECUADO';
    l_Itm2        := 1;
    
    --INI JAGC F8 20241204 
    cadena_original := Ltrim(Rtrim(l_Transaccion.Trama_Boc.String_Identificacion));
    
    IF Ltrim(Rtrim(l_Transaccion.Trama_Boc.Forma_Identificacion)) IN ('P') THEN
      tipo_convenio := TO_NUMBER(SUBSTR(cadena_original, 1, 15));
      tipo_identificacion := SUBSTR(cadena_original, 16, 1);
      identificacion := SUBSTR(cadena_original, 17);        
    ELSE 
      tipo_convenio := null;
      tipo_identificacion := Ltrim(Rtrim(l_Transaccion.Trama_Boc.Forma_Identificacion));
      identificacion := Ltrim(Rtrim(l_Transaccion.Trama_Boc.String_Identificacion));    
    END IF; 
    
    DBMS_OUTPUT.PUT_LINE('Forma Identificacion: ' || l_Transaccion.Trama_Boc.Forma_Identificacion);
    DBMS_OUTPUT.PUT_LINE('Tipo de Convenio: ' || tipo_convenio);
    DBMS_OUTPUT.PUT_LINE('Tipo de Identificacion: ' || tipo_identificacion);
    DBMS_OUTPUT.PUT_LINE('Identificacion: ' || identificacion);
    --FIN JAGC F8 20241204     
    
    Pkg_Geoloyalty.Proc_Consulta(tipo_identificacion--Ltrim(Rtrim(l_Transaccion.Trama_Boc.Forma_Identificacion)) --JAGC F8 20241204 
                                ,identificacion--,Ltrim(Rtrim(l_Transaccion.Trama_Boc.String_Identificacion)) --JAGC F8 20241204 
                                ,l_Transaccion.Trama_Pos.Cadena
                                ,l_Transaccion.Trama_Pos.Empresa
                                ,l_Transaccion.Trama_Pos.Local
                                ,Id_r);

    IF Nvl(Id_r
          ,0) > 0 THEN
      -- busca al cliente desde tabla temporal
      x_Id_Sec_Lotalty := Id_r;
      SELECT Cli.Rut
            ,Cli.Dv
            ,Substr(Cli.Apellido_Paterno
                   ,1
                   ,30)
            ,Substr(Cli.Apellido_Materno
                   ,1
                   ,30)
            ,Substr(Cli.Nombres
                   ,1
                   ,50)
            ,Substr(Cli.Segundo_Nombre
                   ,1
                   ,50)
            ,Cli.Fecha_Hora_Actualizacion
            ,(Decode(Ltrim(Rtrim(Cli.Sexo))
                    ,'FEMALE'
                    ,'FEM'
                    ,'MALE'
                    ,'MAS'
                    ,'F'
                    ,'FEM'
                    ,'M'
                    ,'MAS'
                    ,Substr(Ltrim(Rtrim(Cli.Sexo))
                           ,1
                           ,3))) AS Sexo
            ,To_Date(Nvl(Cli.Fecha_Nacimiento
                        ,To_Number(To_Char(SYSDATE
                                          ,'yyyymmdd')))
                    ,'yyyy/mm/dd')
            ,(CASE
               WHEN Cli.Fidelizado IS NOT NULL THEN
                'S'
               ELSE
                'N'
             END) AS Inscrito_Mas_Cruz --  Inscrito_Mas_Cruz_Verde -- 'S'
            ,Decode(Nvl(Cli.Inscrito_Mas_Cruz_Verde
                       ,'0')
                   ,'S'
                   ,Cli.Folio_Tarjeta_Mcv
                   ,'0')
            ,Upper(Substr(Cli.Fidelizado
                         ,1
                         ,3))
            ,'HOME'
            ,Cli.Direccion
            ,Fnc_Datos_Unificados('COMUNA'
                                 ,'CENTRAL'
                                 ,Cli.Comuna
                                 ,l_Transaccion.Trama_Pos.Cadena
                                 ,l_Transaccion.Trama_Pos.Empresa
                                 ,l_Transaccion.Trama_Pos.Local)
            ,Fnc_Datos_Unificados('CIUDAD'
                                 ,'CENTRAL'
                                 ,Cli.Ciudad
                                 ,l_Transaccion.Trama_Pos.Cadena
                                 ,l_Transaccion.Trama_Pos.Empresa
                                 ,l_Transaccion.Trama_Pos.Local)
            ,'PHONE'
            ,'GEN'
            ,Cli.Telefono_Particular
            ,NULL
            ,'N'
            ,'PHONE'
            ,'MOBILE'
            ,Cli.Telefono_Celular
            ,NULL
            ,'N'
            ,'EMAIL'
            ,NULL
            ,NULL
            ,Cli.Email
            ,'Y'
             --,Cli.Empresa
            ,Cli.Institucion_Salud
        INTO l_Datos_Cliente.Rut
            ,l_Datos_Cliente.Dv_Rut
            ,l_Datos_Cliente.Apellido_Paterno
            ,l_Datos_Cliente.Apellido_Materno
            ,l_Datos_Cliente.Nombres
            ,l_Datos_Cliente.Segundo_Nombre
            ,l_Datos_Cliente.Fecha_Ultima_Act
            ,l_Datos_Cliente.Sexo
            ,l_Datos_Cliente.Fecha_Nacimiento
            ,l_Datos_Cliente.Inscrito_Mcv
            ,l_Datos_Cliente.Folio_Tmcv
            ,l_Datos_Cliente.Tipo_Creacion
            ,l_Datos_Cliente.Direcciones     (1).Tipo_Direccion
            ,l_Datos_Cliente.Direcciones     (1).Direccion
            ,l_Datos_Cliente.Direcciones     (1).Comuna
            ,l_Datos_Cliente.Direcciones     (1).Ciudad
            ,l_Datos_Cliente.Contactos       (1).Tipo_Contacto
            ,l_Datos_Cliente.Contactos       (1).Tipo_Fono
            ,l_Datos_Cliente.Contactos       (1).Numero
            ,l_Datos_Cliente.Contactos       (1).Email
            ,l_Datos_Cliente.Contactos       (1).Primary_By_Purpose
            ,l_Datos_Cliente.Contactos       (2).Tipo_Contacto
            ,l_Datos_Cliente.Contactos       (2).Tipo_Fono
            ,l_Datos_Cliente.Contactos       (2).Numero
            ,l_Datos_Cliente.Contactos       (2).Email
            ,l_Datos_Cliente.Contactos       (2).Primary_By_Purpose
            ,l_Datos_Cliente.Contactos       (3).Tipo_Contacto
            ,l_Datos_Cliente.Contactos       (3).Tipo_Fono
            ,l_Datos_Cliente.Contactos       (3).Numero
            ,l_Datos_Cliente.Contactos       (3).Email
            ,l_Datos_Cliente.Contactos       (3).Primary_By_Purpose
             -- ,l_Datos_Cliente.Empresa
            ,l_Datos_Cliente.Institucion_Salud
        FROM Loyalty_Datos_Personales Cli
       WHERE Cli.Id_Con = Id_r;
    ELSE
      IF Nvl(Id_r
            ,0) = -1 THEN
        x_Cod_Error := 1;
        x_Msg_Error := 'Rut Consultado no existe en Loyalty';
      ELSIF Nvl(Id_r
               ,0) = -8 THEN
        x_Cod_Error := 8;
        x_Msg_Error := 'Sin Conexion Loyalty';
      ELSIF Nvl(Id_r
               ,0) = -9 THEN
        x_Cod_Error := 9;
        x_Msg_Error := 'Sin Conexion Middleware';
      END IF;
      -- x_Cod_Error                      := SQLCODE;
      -- x_Msg_Error                      := SQLERRM;
      l_Datos_Cliente.Apellido_Paterno := ' ';
      l_Datos_Cliente.Apellido_Materno := ' ';
      l_Datos_Cliente.Nombres          := ' ';
      l_Datos_Cliente.Segundo_Nombre   := ' ';
      l_Datos_Cliente.Fecha_Ultima_Act := NULL;
    END IF;
    
    --INI JAGC F8 20241204 
    IF Ltrim(Rtrim(l_Transaccion.Trama_Boc.Forma_Identificacion)) IN ('P') THEN       
      l_Datos_Cliente.Forma_Identificacion          := tipo_identificacion;
      l_Datos_Cliente.String_Identificacion         := identificacion;   
    END IF;
    --FIN JAGC F8 20241204  
    
    RETURN l_Datos_Cliente;

  EXCEPTION
    WHEN OTHERS THEN
      x_Cod_Error                      := SQLCODE;
      x_Msg_Error                      := SQLERRM;
      l_Datos_Cliente.Apellido_Paterno := ' ';
      l_Datos_Cliente.Apellido_Materno := ' ';
      l_Datos_Cliente.Nombres          := ' ';
      l_Datos_Cliente.Segundo_Nombre   := ' ';
      l_Datos_Cliente.Fecha_Ultima_Act := NULL;
      RETURN l_Datos_Cliente;
  END;
  --//-----------------------------------------------------------------Termino--\\

  -- ------------------------------------------------------------------------
  -- JRG 15042016 PROCEDIMIENTO PARA ENVIO CORREO PROGRAMA DE FIDELIZACION MCV.
  -- ------------------------------------------------------------------------
  PROCEDURE End_Response(Respuesta IN OUT Utl_Http.Resp) IS
  BEGIN
    Utl_Http.End_Response(Respuesta);
    IF Ncount > 1 THEN
      Ncount := Ncount - 1;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Dbms_Output.Put_Line('Error:' || SQLERRM);
  END End_Response;

  -- ----------------------------------------------------------------------------------------
  -- procedure Crea_beneficia_lista_seg
  -- ----------------------------------------------------------------------------------------
  PROCEDURE Crea_Beneficiario_Lista_Seg(p_Rut_Titular IN NUMBER
                                       ,p_Empresa     IN NUMBER
                                       ,x_Cod_Error   OUT NUMBER
                                       ,x_Msg_Error   OUT VARCHAR2) IS
    CURSOR c_Listas_Clientes_Convenio IS
      SELECT Con_Numero_Convenio
            ,Numero_Plan
            ,Listas_Clientes
        FROM Scfr_Listas_Clientes_Convenio
       WHERE Estado = 'ACT'
         AND Nvl(Defecto
                ,'N') = 'N';

    -- lista clientes segmentados Convenios
    l_Dbg_Proceso    VARCHAR2(100) := 'SCFR_TRX_FID_PK.Crea_beneficiario_lista_seg';
    l_Dbg_Mensaje    VARCHAR2(250) := 'Error General';
    l_Lista_Segmento NUMBER;
    l_Convenio       NUMBER;
    l_Plan           NUMBER;
    l_Party_Id       NUMBER;
    l_Encontrado     NUMBER;
    l_Empresa        NUMBER;
    l_Dv_Titular     VARCHAR2(1);
    l_Error          VARCHAR2(100);
    l_Msg_Data       VARCHAR2(1000);
    l_Entro_Una_Vez  VARCHAR2(1);
    l_Error_Controlado EXCEPTION;
    l_Club_Amigos NUMBER := 0;
  BEGIN
    l_Entro_Una_Vez := 'N';
    x_Cod_Error     := 0;
    -- valida si Rut esta dentro de los beneficiarios de Club Amigos.
    -- En esta caso Rut no es creado en los convenios Club.
    BEGIN
      SELECT 1
        INTO l_Club_Amigos
        FROM Scfr_Beneficiarios Ben
       WHERE Rut_Beneficiario = p_Rut_Titular
         AND Estado_Vigencia = 'ACT'
         AND EXISTS (SELECT 1
                FROM Fid.Scfr_Listas_Clientes_Convenio Lcnv
               WHERE Lcnv.Estado = 'SAM'
                 AND Lcnv.Con_Numero_Convenio = Ben.Con_Numero_Convenio)
         AND Rownum = 1;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Club_Amigos := 0;
    END;
    IF (l_Club_Amigos = 0) THEN
      -- Obtiene datos del Lista, Convenios y Plan de la FID.SCFR_LISTAS_CLIENTES_CONVENIO
      FOR r_Listas_Clientes_Convenio IN c_Listas_Clientes_Convenio
      LOOP
        l_Lista_Segmento := r_Listas_Clientes_Convenio.Listas_Clientes;
        l_Convenio       := r_Listas_Clientes_Convenio.Con_Numero_Convenio;
        l_Plan           := r_Listas_Clientes_Convenio.Numero_Plan;

        IF (l_Lista_Segmento IS NULL) OR
           (l_Lista_Segmento = 0) OR
           (l_Convenio IS NULL) OR
           (l_Convenio = 0) OR
           (l_Plan IS NULL) THEN
          l_Dbg_Mensaje := 'No se definio Lista, cnv y plan en SCFR_LISTAS_CLIENTES_CONVENIO';
          Dbms_Output.Put_Line(l_Error);
        ELSE
          -- Consulta si clientes se encuentra en lista segmentada.
          BEGIN
            SELECT 1
              INTO l_Encontrado
              FROM Scfr_Deta_List_Clientes
             WHERE Sle_Listas_Clientes = l_Lista_Segmento
               AND Rut_Cliente = p_Rut_Titular
               AND (Fecha_Expiracion <= Scfr_Trx_Util_Pk.Get_Sysdate() OR Fecha_Expiracion IS NULL);
          EXCEPTION
            WHEN No_Data_Found THEN
              l_Encontrado := NULL;
          END;
          IF (l_Encontrado = 1) THEN
            l_Party_Id   := Scfr_Trx_Util_Pk.Obtiene_Party_Id(p_Rut_Titular);
            l_Empresa    := Scfr_Conv_Pk.Entrega_Codigo_Empresa(p_Empresa);
            l_Dv_Titular := Scfr_Trx_Util_Pk.Dv_Rut(p_Rut_Titular);
            -- Se es realiza la primera iteracion, significa que no debe ser incrito en el CNV por defecto
            l_Entro_Una_Vez := 'S';

            -- Llama al procedimiento para crear cliente
            Scfr_Conv_Pk.Crea_Beneficiario(p_Emp_Codigo            => l_Empresa
                                          ,p_Con_Numero_Convenio   => l_Convenio
                                          ,p_Pla_Num_Plan          => l_Plan
                                          ,p_Party_Id_Titular      => l_Party_Id
                                          ,p_Rut_Titular           => p_Rut_Titular
                                          ,p_Dv_Titular            => l_Dv_Titular
                                          ,p_Party_Id_Beneficiario => l_Party_Id
                                          ,p_Rut_Beneficiario      => p_Rut_Titular
                                          ,p_Dv_Beneficiario       => l_Dv_Titular
                                          ,p_Correlativo           => 0
                                          ,x_Error                 => l_Error
                                          ,x_Msg_Error             => l_Msg_Data);

            --          Dbms_Output.Put_Line(l_Error);
            --          Dbms_Output.Put_Line(l_Msg_Data);
            IF l_Error != 'S' THEN
              x_Cod_Error   := 1;
              l_Dbg_Mensaje := 'ERROR EN RETORNO DE GET_REGISTRO_BENEFICIARIO:' || l_Msg_Data;
              Dbms_Output.Put_Line(x_Msg_Error);
            ELSE
              l_Entro_Una_Vez := 'S';
              l_Dbg_Mensaje   := 'Clientes incorporado como beneficiario';
              x_Cod_Error     := 0;
            END IF;
          END IF; -- if (l_encontrado is null) then
        END IF; -- if (l_lista_segmento is null) or

      END LOOP; -- for r_listas_clientes_convenio in c_listas_clientes_convenio loop

      --//--------------------------------------------------------------------------\\
      --// CBR 02/21/2018 12:16PM                                                   \\
      --// ACCION de Inscriupcion en Convenio por DEFECTO sino inscribio en otros   \\
      --//-----------------------------------------------------------------Inicio---\\
      IF l_Entro_Una_Vez = 'N' AND
         Nvl(x_Cod_Error
            ,0) = 0 THEN
        BEGIN
          SELECT Con_Numero_Convenio
                ,Numero_Plan
                ,Listas_Clientes
            INTO l_Convenio
                ,l_Plan
                ,l_Lista_Segmento
            FROM Scfr_Listas_Clientes_Convenio
           WHERE Estado = 'ACT'
             AND Defecto = 'S'
             AND Rownum = 1;

          IF Nvl(l_Convenio
                ,0) > 0 THEN
            l_Party_Id   := Scfr_Trx_Util_Pk.Obtiene_Party_Id(p_Rut_Titular);
            l_Empresa    := Scfr_Conv_Pk.Entrega_Codigo_Empresa(p_Empresa);
            l_Dv_Titular := Scfr_Trx_Util_Pk.Dv_Rut(p_Rut_Titular);
            -- Llama al procedimiento para crear cliente
            Scfr_Conv_Pk.Crea_Beneficiario(p_Emp_Codigo            => l_Empresa
                                          ,p_Con_Numero_Convenio   => l_Convenio
                                          ,p_Pla_Num_Plan          => l_Plan
                                          ,p_Party_Id_Titular      => l_Party_Id
                                          ,p_Rut_Titular           => p_Rut_Titular
                                          ,p_Dv_Titular            => l_Dv_Titular
                                          ,p_Party_Id_Beneficiario => l_Party_Id
                                          ,p_Rut_Beneficiario      => p_Rut_Titular
                                          ,p_Dv_Beneficiario       => l_Dv_Titular
                                          ,p_Correlativo           => 0
                                          ,x_Error                 => l_Error
                                          ,x_Msg_Error             => l_Msg_Data);

            Dbms_Output.Put_Line(l_Error);
            Dbms_Output.Put_Line(l_Msg_Data);
            IF l_Msg_Data = 'S' THEN
              l_Dbg_Mensaje := 'Cliente Inscrito en CONVENIO por Defecto';
              x_Cod_Error   := 0;
            ELSIF l_Msg_Data LIKE '%YA EXISTE%' THEN
              l_Entro_Una_Vez := 'S';
              l_Dbg_Mensaje   := 'Cliente YA EXISTE en Convenio por Defecto';
              x_Cod_Error     := 0;
            ELSE
              x_Cod_Error   := 1;
              l_Dbg_Mensaje := 'ERROR al grabar en Convenio por Defecto:' || l_Msg_Data;
              Dbms_Output.Put_Line(x_Msg_Error);
            END IF;
          END IF;

        EXCEPTION
          WHEN No_Data_Found THEN
            NULL;
          WHEN OTHERS THEN
            NULL;
        END;
      END IF;
      --//-----------------------------------------------------------------Termino--\\
    END IF; --     IF (l_club_amigos = 0) THEN

    x_Cod_Error := 0;
    x_Msg_Error := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Request_Ws_Mail(Rut_Cliente   IN NUMBER DEFAULT NULL
                           ,Email_Cliente IN VARCHAR2 DEFAULT NULL
                           ,App_Envio     IN VARCHAR2 DEFAULT NULL
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) AS

    Req     Utl_Http.Req := NULL;
    Resp    Utl_Http.Resp := NULL;
    Respval VARCHAR2(32000);
    Reqxml  VARCHAR2(32000);
    Err_Controlado EXCEPTION;
    Err_Timeout    EXCEPTION;
    Err_Fechatx    EXCEPTION;
    Lxmlns           VARCHAR2(500);
    Lwsdir           VARCHAR2(500);
    Lsalida          VARCHAR2(32000);
    Ldbg             VARCHAR2(4000) := 'General';
    Lengthreqxml     NUMBER;
    l_Id_Servicio_Ws VARCHAR2(3);
    Vtimeout         NUMBER := 15;
    Ncount           NUMBER := 0;
  BEGIN

    IF (TRIM(Email_Cliente) IS NULL) OR
       (Rut_Cliente IS NULL) THEN
      Ldbg := 'No hay datos asociados a Correo  = "' || l_Id_Servicio_Ws || '"';
      RAISE Err_Controlado;
    END IF;
    IF (Upper(App_Envio) = 'MASCV') THEN
      l_Id_Servicio_Ws := 'MCV';
    ELSE
      l_Id_Servicio_Ws := Upper(App_Envio);
    END IF;

    Ldbg := 'Obtener datos de conexion';
    BEGIN
      SELECT Wsdir
            ,Xmlns
        INTO Lwsdir
            ,Lxmlns
        FROM Scfr_Comercios_Externos
       WHERE Comercio = l_Id_Servicio_Ws;
    EXCEPTION
      WHEN No_Data_Found THEN
        Ldbg := 'No hay datos en SCFR_COMERCIOS_EXTERNOS para destino = "' || l_Id_Servicio_Ws || '"';
        RAISE Err_Controlado;
      WHEN OTHERS THEN
        Ldbg := 'Problemas al obtener informacion de SCFR_COMERCIOS_EXTERNOS para destino = "' || l_Id_Servicio_Ws || '" - ' || SQLERRM;
        RAISE Err_Controlado;
    END;
    --dbms_output.put_line('WS-> ' || lwsdir || ' -> ' || to_char(SYSDATE, 'dd-mm-yyyy hh24:mi:ss'));
    Ldbg         := 'Preparar el requerimiento'; /* Generamos un Request a la URL destino, el metodo debe ser POST */
    Req          := Utl_Http.Begin_Request(Lwsdir
                                          ,'POST');
    Ldbg         := 'Preparar el XML Soap'; /* Creamos un mensaje SOAP tal cual se define en el WSDL */
    Reqxml       := '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
    Reqxml       := Reqxml || '    <soap:Body>';
    Reqxml       := Reqxml || '        <ns1:enviarMailInscripcion xmlns:ns1="http://ws.cruzverde.cl/Util/">';
    Reqxml       := Reqxml || '            <rut>' || To_Char(Rut_Cliente) || '</rut>';
    Reqxml       := Reqxml || '            <destinatario>' || Email_Cliente || '</destinatario>';
    Reqxml       := Reqxml || '            <app>' || l_Id_Servicio_Ws || '</app>';
    Reqxml       := Reqxml || '        </ns1:enviarMailInscripcion>';
    Reqxml       := Reqxml || '    </soap:Body>';
    Reqxml       := Reqxml || '</soap:Envelope> ';
    Lengthreqxml := Dbms_Lob.Getlength(Reqxml);
    --dbms_output.put_line(reqxml);
    Dbms_Output.Put_Line(Reqxml);
    Ldbg := 'Preparar el tipo del header'; /* El contenido que enviamos es XML: */
    Utl_Http.Set_Header(Req
                       ,'Content-Type'
                       ,'text/xml');
    Utl_Http.Set_Transfer_Timeout(Vtimeout);
    Ldbg := 'Preparar el size del mensaje'; /* Indicamos en el header el tamano del mensaje enviado: */
    Utl_Http.Set_Header(Req
                       ,'Content-Length'
                       ,Lengthreqxml);
    Ldbg := 'Escribir el body del request'; /* Escribimos el body del request */
    Utl_Http.Write_Text(Req
                       ,Reqxml);
    Ldbg := 'Obtener la respuesta'; /*Obtenemos la respuesta */
    WHILE Ncount >= Maxconnection
    LOOP
      Dbms_Lock.Sleep(0.1);
    END LOOP;
    Resp   := Utl_Http.Get_Response(Req);
    Ncount := Ncount + 1;
    Ldbg   := 'Read text'; /* Cargamos en la variable respVal la devolucion del servidor */
    -- dbms_output.put_line(resp);
    -- utl_http.read_text(resp,respval);
    Ldbg := 'End response'; /* Finalizamos la conexion HTTP */
    End_Response(Resp);
    Utl_Http.Close_Persistent_Conns;
    --lsalida := parsearespuesta(respval,
    --                                                 pdatos.accionsoap);
    x_Cod_Error := 0;
    x_Msg_Error := 'Rut Registrado para envio';
  EXCEPTION
    WHEN Utl_Http.End_Of_Body THEN
      End_Response(Resp);
      x_Cod_Error := 4000;
      x_Msg_Error := 'Problemas de Comunicacion 01 - ' || '(' || Ldbg || ')';
    WHEN Utl_Http.Init_Failed THEN
      Ldbg := Ldbg || '- init_failed ' || ' ' || Utl_Http.Get_Detailed_Sqlcode || ' ' || Utl_Http.Get_Detailed_Sqlerrm;
      End_Response(Resp);
      x_Cod_Error := 4000;
      x_Msg_Error := 'Problemas de Comunicacion 02 - ' || '(' || Ldbg || ')';
    WHEN Utl_Http.Request_Failed THEN
      Ldbg := Ldbg || '- request_failed ' || ' ' || Utl_Http.Get_Detailed_Sqlcode || ' ' || Utl_Http.Get_Detailed_Sqlerrm;
      End_Response(Resp);
      x_Cod_Error := 4100;
      x_Msg_Error := 'Problemas de Comunicacion 03 - ' || '(' || Ldbg || ')';
    WHEN Utl_Http.Bad_Argument THEN
      Ldbg := Ldbg || '- bad_argument ' || ' ' || Utl_Http.Get_Detailed_Sqlcode || ' ' || Utl_Http.Get_Detailed_Sqlerrm;
      End_Response(Resp);
      x_Cod_Error := 4000;
      x_Msg_Error := 'Problemas de Comunicacion 04 - ' || '(' || Ldbg || ')';
    WHEN Utl_Http.Bad_Url THEN
      Ldbg := Ldbg || '- bad_url ' || ' ' || Utl_Http.Get_Detailed_Sqlcode || ' ' || Utl_Http.Get_Detailed_Sqlerrm;
      End_Response(Resp);
      x_Cod_Error := 4000;
      x_Msg_Error := 'Problemas de Comunicacion 05 - ' || '(' || Ldbg || ')';
    WHEN Utl_Http.Protocol_Error THEN
      Ldbg := Ldbg || '- protocol_error ' || ' ' || Utl_Http.Get_Detailed_Sqlcode || ' ' || Utl_Http.Get_Detailed_Sqlerrm;
      End_Response(Resp);
      x_Cod_Error := 4000;
      x_Msg_Error := 'Problemas de Comunicacion 06 - ' || '(' || Ldbg || ')';
    WHEN Utl_Http.Unknown_Scheme THEN
      Ldbg := Ldbg || '- unknown_scheme ' || ' ' || Utl_Http.Get_Detailed_Sqlcode || ' ' || Utl_Http.Get_Detailed_Sqlerrm;
      End_Response(Resp);
      x_Cod_Error := 4000;
      x_Msg_Error := 'Problemas de Comunicacion 07 - ' || '(' || Ldbg || ')';
    WHEN Utl_Http.Header_Not_Found THEN
      Ldbg := Ldbg || '- header_not_found ' || ' ' || Utl_Http.Get_Detailed_Sqlcode || ' ' || Utl_Http.Get_Detailed_Sqlerrm;
      End_Response(Resp);
      x_Cod_Error := 4000;
      x_Msg_Error := 'Problemas de Comunicacion 08 - ' || '(' || Ldbg || ')';
    WHEN Utl_Http.Illegal_Call THEN
      Ldbg := Ldbg || '- illegal_call ' || ' ' || Utl_Http.Get_Detailed_Sqlcode || ' ' || Utl_Http.Get_Detailed_Sqlerrm;
      End_Response(Resp);
      x_Cod_Error := 4000;
      x_Msg_Error := 'Problemas de Comunicacion 09 - ' || '(' || Ldbg || ')';
    WHEN Utl_Http.Http_Client_Error THEN
      Ldbg := Ldbg || '- http_client_error ' || ' ' || Utl_Http.Get_Detailed_Sqlcode || ' ' || Utl_Http.Get_Detailed_Sqlerrm;
      End_Response(Resp);
      x_Cod_Error := 4000;
      x_Msg_Error := 'Problemas de Comunicacion 10 - ' || '(' || Ldbg || ')';
    WHEN Utl_Http.Http_Server_Error THEN
      Ldbg := Ldbg || '- http_server_error ' || ' ' || Utl_Http.Get_Detailed_Sqlcode || ' ' || Utl_Http.Get_Detailed_Sqlerrm;
      End_Response(Resp);
      x_Cod_Error := 4000;
      x_Msg_Error := 'Problemas de Comunicacion 11 - ' || '(' || Ldbg || ')';
    WHEN Utl_Http.Too_Many_Requests THEN
      --UTL_HTTP.CLOSE_PERSISTENT_CONNS;
      Ldbg := Ldbg || '- too_many_requests ' || ' ' || Utl_Http.Get_Detailed_Sqlcode || ' ' || Utl_Http.Get_Detailed_Sqlerrm;
      End_Response(Resp);
      x_Cod_Error := 4000;
      x_Msg_Error := 'Problemas de Comunicacion 12 - ' || '(' || Ldbg || ')';
    WHEN Utl_Http.Partial_Multibyte_Char THEN
      Ldbg := Ldbg || '- partial_multibyte_char ' || ' ' || Utl_Http.Get_Detailed_Sqlcode || ' ' || Utl_Http.Get_Detailed_Sqlerrm;
      End_Response(Resp);
      x_Cod_Error := 4000;
      x_Msg_Error := 'Problemas de Comunicacion 13 - ' || '(' || Ldbg || ')';
    WHEN Utl_Http.Transfer_Timeout THEN
      Ldbg := Ldbg || '- transfer_timeout ' || ' ' || Utl_Http.Get_Detailed_Sqlcode || ' ' || Utl_Http.Get_Detailed_Sqlerrm;
      End_Response(Resp);
      x_Cod_Error := 4100;
      x_Msg_Error := 'Problemas de Comunicacion 14 - ' || '(' || Ldbg || ')';
    WHEN OTHERS THEN
      End_Response(Resp);
      x_Cod_Error := 4000;
      x_Msg_Error := 'Problemas de Comunicacion 15 - ' || '(' || Ldbg || ')';
  END Request_Ws_Mail;

  PROCEDURE Registra_Envio_Mail(Rut_Cliente   IN NUMBER DEFAULT NULL
                               ,Email_Cliente IN VARCHAR2 DEFAULT NULL
                               ,App_Envio     IN VARCHAR2 DEFAULT NULL
                               ,x_Cod_Error   OUT NUMBER
                               ,x_Msg_Error   OUT VARCHAR2) IS
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.Registra_Envio_Mail';
    Error_Controlado EXCEPTION;
    l_Encontrado    NUMBER;
    l_Mail_Generico NUMBER;
  BEGIN
    x_Cod_Error := 0;
    IF (Rut_Cliente IS NULL) THEN
      x_Cod_Error := 1;
      x_Msg_Error := 'Debe indicar RUT Cliente';
    END IF; -- IF (Rut_Cliente IS NULL) THEN
    -- *
    IF (TRIM(Email_Cliente) IS NULL) THEN
      x_Cod_Error := 2;
      x_Msg_Error := 'Debe indicar Mail';
    END IF; -- IF (Email_Cliente IS NULL) THEN
    -- *
    IF (TRIM(App_Envio) IS NULL) THEN
      x_Cod_Error := 3;
      x_Msg_Error := 'Debe indicar App_Envio';
    END IF; -- IF (App_Envio IS NULL) THEN
    IF (x_Cod_Error = 0) THEN
      -- Valida si es mail generico
      BEGIN
        SELECT Nvl(Instr(Upper(Rv_High_Value)
                        ,Upper(TRIM(Email_Cliente)))
                  ,0)
          INTO l_Mail_Generico
          FROM Cg_Ref_Codes
         WHERE Rv_Domain = 'INSCRIPCION_WEB'
           AND Rv_Low_Value = 'MGE'
           AND Rownum = 1;
      EXCEPTION
        WHEN No_Data_Found THEN
          l_Mail_Generico := 0;
      END;
    END IF; --
    IF (x_Cod_Error <> 1) THEN
      BEGIN
        -- Guarda datos del envio correo.
        INSERT INTO Scfr_Validacion_Mail
          (Rut_Cliente
          ,Dv_Cliente
          ,Estado_Validacion
          ,Fecha_Env_Mail
          ,Fecha_Val_Mail
          ,Email
          ,Token
          ,Fecha_Registro
          ,Log_Mensaje)
        VALUES
          (Rut_Cliente
          ,Scfr_Trx_Util_Pk.Dv_Rut(Rut_Cliente)
          ,'SOL'
          ,NULL
          ,NULL
          ,Email_Cliente
          ,NULL
          ,SYSDATE
          ,x_Msg_Error);
        x_Cod_Error := 0;
        x_Msg_Error := 'Registro envio mail creado => ' || Rut_Cliente;
      EXCEPTION
        WHEN Dup_Val_On_Index THEN
          x_Cod_Error := 4;
          x_Msg_Error := 'Cliente ya presenta registro en el envio de correo ' || Rut_Cliente;
        WHEN OTHERS THEN
          x_Cod_Error := 5;
          x_Msg_Error := 'Error en la cracion de envio de mail ' || Rut_Cliente;
      END;
    END IF; -- IF (l_encontrado = 0) THEN

    IF (l_Mail_Generico = 0) AND
       (x_Cod_Error = 0) THEN
      Request_Ws_Mail(Rut_Cliente   => Rut_Cliente
                     ,Email_Cliente => Email_Cliente
                     ,App_Envio     => App_Envio
                     ,x_Cod_Error   => x_Cod_Error
                     ,x_Msg_Error   => x_Msg_Error);
    END IF; --IF (l_mail_generico = 0) THEN

  EXCEPTION
    WHEN OTHERS THEN
      x_Cod_Error := 6;
      x_Msg_Error := 'Error en procedimiento SCFR_TRX_FID_PK.Registra_Envio_Mail';
  END;

  -- ------------------------------------------------------------------------
  -- JRG 23092015 activacion de puntos programa MCV antiguo.
  -- ------------------------------------------------------------------------
  PROCEDURE Activa_Puntos_Mcv(p_Rut_Titular IN NUMBER DEFAULT NULL
                             ,p_Empresa     IN NUMBER DEFAULT 86) IS

    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.Activa_Puntos_MCV';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    l_Puntos_Mcv_Old  NUMBER;
    l_Party_Id        NUMBER;
    l_Party_Id_Rel    NUMBER;
    l_Id_Relacion     NUMBER;
    l_Dias_Vcto_Ptos  NUMBER;
    l_Recupera_Puntos VARCHAR2(3);
  BEGIN

    IF (p_Rut_Titular IS NOT NULL) THEN
      l_Party_Id     := Scfr_Trx_Util_Pk.Obtiene_Party_Id(To_Number(p_Rut_Titular));
      l_Dbg_Mensaje  := 'Buscar relacion ES_FIDELIZADO ';
      l_Party_Id_Rel := Scfr_Trx_Util_Pk.Busca_Party_Id_Relacion(l_Party_Id
                                                                ,Scfr_Trx_Util_Pk.Obtiene_Party_Id(Scfr_Trx_Util_Pk.Rut_Con_Org_Id(p_Empresa
                                                                                                                                  ,Scfr_Trx_Util_Pk.Instancia))
                                                                ,'ES_FIDELIZADO'
                                                                ,p_Empresa
                                                                ,l_Id_Relacion);
      IF (Nvl(l_Party_Id_Rel
             ,0) <= 0) THEN
        BEGIN
          SELECT Party_Id
            INTO l_Party_Id_Rel
            FROM Scfr_Tmp_Clientes
           WHERE Rut = p_Rut_Titular
             AND Inscrito_Mas_Cruz_Verde = 'S';
        EXCEPTION
          WHEN No_Data_Found THEN
            l_Party_Id_Rel := -1;
        END;
      END IF; -- if (Nvl(l_Party_Id_Rel   ,0) > 0) then

      IF Nvl(l_Party_Id_Rel
            ,0) > 0 THEN
        l_Dbg_Mensaje    := 'Obtener puntos DIVEPU';
        l_Dias_Vcto_Ptos := Scfr_Trx_Util_Pk.Det_Valor_Parametro_Por_Cod('DIVEPU');
        -- Si hay puntos disponible vigentes, se activan para retornarlos a la cuenta corriente.
        -- activa puntos programa mcv antiguo.
        BEGIN
          SELECT 'NO'
            INTO l_Recupera_Puntos
            FROM Scfr_Campanas    Cam
                ,Scfr_Condiciones Con
           WHERE Cam.Tipo_Campana = 'PTO'
             AND Cam.Emp_Codigo = p_Empresa
             AND SYSDATE BETWEEN Trunc(Cam.Fecha_Inicio) AND Cam.Fecha_Termino + 1
             AND Cam.Campana = Con.Cam_Campana
             AND Con.Tipo_Condicion = 'RPM'
             AND Con.Dentro_Intervalo = 'SI'
             AND Rownum = 1;
        EXCEPTION
          WHEN No_Data_Found THEN
            l_Recupera_Puntos := 'SI';
        END;

        IF (l_Recupera_Puntos = 'SI') THEN
          l_Dbg_Mensaje := 'Activa puntos programa MCV antiguo.' || l_Puntos_Mcv_Old;
          UPDATE Scfr_Txs_Puntos
             SET Estado_Registro = 'A'
           WHERE Rut_Titular = p_Rut_Titular
             AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
             AND Estado_Registro = 'P';
        END IF; -- IF ( L_Recupera_Puntos ='SI') THEN

        -- JRG 08032016 Da de Baja a cliente de campana con condicion 'DPM', 'D', 'Descuento Programa MCV')
        UPDATE Scfr_Deta_List_Clientes Det
           SET Fecha_Expiracion = Scfr_Trx_Util_Pk.Get_Sysdate() - 1
         WHERE Det.Rut_Cliente = p_Rut_Titular
           AND EXISTS (SELECT 1
                  FROM Scfr_Campanas                 Cam
                      ,Scfr_Condiciones              Con
                      ,Scfr_Listas_Clientes_Campanas Lis
                 WHERE Cam.Campana = Con.Cam_Campana
                   AND Cam.Campana = Lis.Cam_Campana
                   AND Lis.Sle_Listas_Clientes = Det.Sle_Listas_Clientes
                   AND Con.Tipo_Condicion = 'DPM'
                   AND Con.Dentro_Intervalo = 'SI');
      END IF; -- IF l_Party_Id_Rel <> -1 AND
    END IF; -- if (p_Rut_Titular is not null) then
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => l_Dbg_Mensaje);
  END;
  -- Funci?n que retorna los puntos desde diversos puntos de vista. Recibe como parametros un
  -- party_id junto con el "tipo de puntos" que se desea obtener, esto es: puntos
  -- totales (T), puntos recibidos por donacion (D)
  FUNCTION Puntos_Disponibles(p_Party_Id    IN NUMBER DEFAULT NULL
                             ,p_Rut_Titular IN NUMBER DEFAULT NULL
                             ,p_Tipo_Puntos IN VARCHAR2
                             ,p_Emp_Alianza IN VARCHAR2 DEFAULT 'JBM') RETURN NUMBER IS
    l_Puntos                     NUMBER;
    l_Puntos_a                   NUMBER;
    l_Puntos_r                   NUMBER;
    l_Puntos_t                   NUMBER;
    l_Puntos_Forzados            NUMBER;
    l_Puntos_Regulacion          NUMBER;
    l_Puntos_Forzados_Reversados NUMBER;
    l_Dias_Vcto_Ptos             NUMBER;
    l_Resultado                  NUMBER;
    l_Dbg_Proceso                VARCHAR2(100) := 'SCFR_TRX_FID_PK.puntos_disponibles';
    l_Dbg_Mensaje                VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje    := 'Obtener puntos DIVEPU';
    l_Dias_Vcto_Ptos := Scfr_Trx_Util_Pk.Det_Valor_Parametro_Por_Cod('DIVEPU');
    IF p_Party_Id IS NOT NULL THEN
      IF p_Tipo_Puntos = 'T' THEN
        l_Dbg_Mensaje := 'Buscar Puntos Disponibles para Canje ' || p_Tipo_Puntos;
        SELECT SUM(Disponible_Para_Canje)
          INTO l_Puntos
          FROM Scfr_Txs_Puntos
         WHERE Pt_Party_Id = p_Party_Id
           AND Tipo_Tx_Puntos != 'REG'
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Estado_Registro = 'A';
        IF l_Puntos IS NULL THEN
          l_Puntos := 0;
        END IF;
        SELECT SUM(Disponible_Para_Canje)
          INTO l_Puntos_Regulacion
          FROM Scfr_Txs_Puntos
         WHERE Tipo_Tx_Puntos = 'REG'
           AND Pt_Party_Id = p_Party_Id;
        l_Puntos := l_Puntos + Nvl(l_Puntos_Regulacion
                                  ,0);
      ELSIF p_Tipo_Puntos IN ('G'
                             ,'APG') THEN
        l_Dbg_Mensaje := 'Buscar puntos ganados ' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_a
          FROM Scfr_Txs_Puntos
         WHERE Pt_Party_Id = p_Party_Id
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'APG';
        l_Dbg_Mensaje := 'Buscar Reversa Puntos Ganados ' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_r
          FROM Scfr_Txs_Puntos
         WHERE Pt_Party_Id = p_Party_Id
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'RPG';
        l_Puntos := l_Puntos_a - l_Puntos_r;
      ELSIF p_Tipo_Puntos IN ('E'
                             ,'APH') THEN
        l_Dbg_Mensaje := 'Buscar Puntos Heredados ' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_a
          FROM Scfr_Txs_Puntos
         WHERE Pt_Party_Id = p_Party_Id
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'APH';
        l_Dbg_Mensaje := 'Buscar Reversa Puntos Heredados ' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_r
          FROM Scfr_Txs_Puntos
         WHERE Pt_Party_Id = p_Party_Id
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'RPH';
        l_Puntos := l_Puntos_a - l_Puntos_r;
      ELSIF p_Tipo_Puntos IN ('R'
                             ,'APR') THEN
        l_Dbg_Mensaje := 'Buscar Puntos Recuperados ' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_a
          FROM Scfr_Txs_Puntos
         WHERE Pt_Party_Id = p_Party_Id
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'APR';
        l_Dbg_Mensaje := 'Buscar Reversa Puntos Recuperados ' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_r
          FROM Scfr_Txs_Puntos
         WHERE Pt_Party_Id = p_Party_Id
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'RPR';
        l_Puntos := l_Puntos_a - l_Puntos_r;
      ELSIF p_Tipo_Puntos IN ('C'
                             ,'CAN') THEN
        l_Dbg_Mensaje := 'Buscar Puntos Canjeados' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_a
          FROM Scfr_Txs_Puntos
         WHERE Pt_Party_Id = p_Party_Id
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'CAN';
        l_Dbg_Mensaje := 'Buscar Reversa Puntos Canjeados' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_r
          FROM Scfr_Txs_Puntos
         WHERE Pt_Party_Id = p_Party_Id
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'RCA';
        l_Puntos := l_Puntos_a - l_Puntos_r;
      ELSIF p_Tipo_Puntos IN ('D'
                             ,'APD') THEN
        l_Dbg_Mensaje := 'Buscar Puntos Donados ' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_a
          FROM Scfr_Txs_Puntos
         WHERE Pt_Party_Id = p_Party_Id
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'APD';
        l_Dbg_Mensaje := ' Buscar Reversa Puntos Donados' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_r
          FROM Scfr_Txs_Puntos
         WHERE Pt_Party_Id = p_Party_Id
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'RPD';
        l_Puntos := l_Puntos_a - l_Puntos_r;
      ELSIF p_Tipo_Puntos IN ('F'
                             ,'APF') THEN
        l_Dbg_Mensaje := 'Buscar Puntos Forzados' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_a
          FROM Scfr_Txs_Puntos
         WHERE Pt_Party_Id = p_Party_Id
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'APF';
        l_Dbg_Mensaje := 'Buscar Reversa Puntos Forzados' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_r
          FROM Scfr_Txs_Puntos
         WHERE Pt_Party_Id = p_Party_Id
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'RPF';
        l_Puntos := l_Puntos_a - l_Puntos_r;
      ELSIF p_Tipo_Puntos IN ('J'
                             ,'TPT') THEN
        l_Dbg_Mensaje := 'Buscar Puntos a Terceros' || p_Tipo_Puntos;
        /* TPT Traspaso Puntos a Terceros de otras empresas JUMBO */
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_t
          FROM Scfr_Txs_Puntos
         WHERE Pt_Party_Id = p_Party_Id
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'TPT'
           AND Empresa_Alianza_Fidelizacion = p_Emp_Alianza;
        l_Dbg_Mensaje := 'Buscar Reversa Puntos a Terceros' || p_Tipo_Puntos;
        -- RTT Reversa Traspaso Puntos a Terceros de otras empresas
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_r
          FROM Scfr_Txs_Puntos
         WHERE Pt_Party_Id = p_Party_Id
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'RTT'
           AND Empresa_Alianza_Fidelizacion = p_Emp_Alianza;
        l_Puntos := l_Puntos_t - l_Puntos_r;
      ELSIF (p_Tipo_Puntos IN ('P'
                              ,'RPT')) THEN
        /*
              l_DBG_MENSAJE := 'Recepci?n de Puntos otras empresas '||p_tipo_puntos;
              -- RPT Recepci?n de Puntos desde otras empresas
              select NVL(sum(ptos_procesados),0)
                into l_puntos_t
                from scfr_txs_puntos
               where pt_party_id                       = p_party_id
                 and trunc(fecha + l_dias_vcto_ptos ) >= trunc(scfr_trx_util_pk.get_sysdate())
                 and tipo_tx_puntos                    = 'RPT';
              -- RTT RPT Recepci?n de Puntos desde otras empresas
              --if (p_tipo_puntos in ( 'P', 'RPT' )) then
        */
        l_Dbg_Mensaje := 'Recepci?n de Puntos otras empresas ' || p_Tipo_Puntos;
        /* RPT Recepci?n de Puntos desde otras empresas */
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos
          FROM Scfr_Txs_Puntos
         WHERE Pt_Party_Id = p_Party_Id
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'RPT';
        -- -----------------------------------------------------------------
        -- JRG 23092015 Revisa puntos inactivos programa de puntos antiguo.-
        -- -----------------------------------------------------------------
      ELSIF p_Tipo_Puntos = 'I' THEN
        l_Dbg_Mensaje := 'Buscar Puntos programa MCV antiguo ' || p_Tipo_Puntos;
        SELECT SUM(Disponible_Para_Canje)
          INTO l_Puntos
          FROM Scfr_Txs_Puntos
         WHERE Pt_Party_Id = p_Party_Id
           AND Tipo_Tx_Puntos != 'REG'
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Estado_Registro = 'P';
        IF l_Puntos IS NULL THEN
          l_Puntos := 0;
        END IF;
        SELECT SUM(Disponible_Para_Canje)
          INTO l_Puntos_Regulacion
          FROM Scfr_Txs_Puntos
         WHERE Tipo_Tx_Puntos = 'REG'
           AND Estado_Registro = 'P'
           AND Pt_Party_Id = p_Party_Id;
        l_Puntos := l_Puntos + Nvl(l_Puntos_Regulacion
                                  ,0);
      ELSE
        l_Dbg_Mensaje := ' Sin Puntos a devolver' || p_Tipo_Puntos;
        l_Puntos      := 0;
      END IF;
      RETURN(l_Puntos);
    ELSIF p_Rut_Titular IS NOT NULL THEN
      IF p_Tipo_Puntos = 'T' THEN
        l_Dbg_Mensaje := 'Buscar Puntos Disponibles para Canje ' || p_Tipo_Puntos;
        SELECT SUM(Disponible_Para_Canje)
          INTO l_Puntos
          FROM Scfr_Txs_Puntos
         WHERE Rut_Titular = p_Rut_Titular
           AND Tipo_Tx_Puntos != 'REG'
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Estado_Registro = 'A';
        IF l_Puntos IS NULL THEN
          l_Puntos := 0;
        END IF;
        SELECT SUM(Disponible_Para_Canje)
          INTO l_Puntos_Regulacion
          FROM Scfr_Txs_Puntos
         WHERE Tipo_Tx_Puntos = 'REG'
           AND Rut_Titular = p_Rut_Titular;
        l_Puntos := l_Puntos + Nvl(l_Puntos_Regulacion
                                  ,0);
      ELSIF p_Tipo_Puntos IN ('G'
                             ,'APG') THEN
        l_Dbg_Mensaje := 'Buscar puntos ganados ' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_a
          FROM Scfr_Txs_Puntos
         WHERE Rut_Titular = p_Rut_Titular
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'APG';
        l_Dbg_Mensaje := 'Buscar Reversa Puntos Ganados ' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_r
          FROM Scfr_Txs_Puntos
         WHERE Rut_Titular = p_Rut_Titular
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'RPG';
        l_Puntos := l_Puntos_a - l_Puntos_r;
      ELSIF p_Tipo_Puntos IN ('E'
                             ,'APH') THEN
        l_Dbg_Mensaje := 'Buscar Puntos Heredados ' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_a
          FROM Scfr_Txs_Puntos
         WHERE Rut_Titular = p_Rut_Titular
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'APH';
        l_Dbg_Mensaje := 'Buscar Reversa Puntos Heredados ' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_r
          FROM Scfr_Txs_Puntos
         WHERE Rut_Titular = p_Rut_Titular
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'RPH';
        l_Puntos := l_Puntos_a - l_Puntos_r;
      ELSIF p_Tipo_Puntos IN ('R'
                             ,'APR') THEN
        l_Dbg_Mensaje := 'Buscar Puntos Recuperados ' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_a
          FROM Scfr_Txs_Puntos
         WHERE Rut_Titular = p_Rut_Titular
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'APR';
        l_Dbg_Mensaje := 'Buscar Reversa Puntos Recuperados ' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_r
          FROM Scfr_Txs_Puntos
         WHERE Rut_Titular = p_Rut_Titular
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'RPR';
        l_Puntos := l_Puntos_a - l_Puntos_r;
      ELSIF p_Tipo_Puntos IN ('C'
                             ,'CAN') THEN
        l_Dbg_Mensaje := 'Buscar Puntos Canjeados' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_a
          FROM Scfr_Txs_Puntos
         WHERE Rut_Titular = p_Rut_Titular
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'CAN';
        l_Dbg_Mensaje := 'Buscar Reversa Puntos Canjeados' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_r
          FROM Scfr_Txs_Puntos
         WHERE Rut_Titular = p_Rut_Titular
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'RCA';
        l_Puntos := l_Puntos_a - l_Puntos_r;
      ELSIF p_Tipo_Puntos IN ('D'
                             ,'APD') THEN
        l_Dbg_Mensaje := 'Buscar Puntos Donados ' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_a
          FROM Scfr_Txs_Puntos
         WHERE Rut_Titular = p_Rut_Titular
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'APD';
        l_Dbg_Mensaje := ' Buscar Reversa Puntos Donados' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_r
          FROM Scfr_Txs_Puntos
         WHERE Rut_Titular = p_Rut_Titular
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'RPD';
        l_Puntos := l_Puntos_a - l_Puntos_r;
      ELSIF p_Tipo_Puntos IN ('F'
                             ,'APF') THEN
        l_Dbg_Mensaje := 'Buscar Puntos Forzados' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_a
          FROM Scfr_Txs_Puntos
         WHERE Rut_Titular = p_Rut_Titular
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'APF';
        l_Dbg_Mensaje := 'Buscar Reversa Puntos Forzados' || p_Tipo_Puntos;
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_r
          FROM Scfr_Txs_Puntos
         WHERE Rut_Titular = p_Rut_Titular
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'RPF';
        l_Puntos := l_Puntos_a - l_Puntos_r;
      ELSIF p_Tipo_Puntos IN ('J'
                             ,'TPT') THEN
        l_Dbg_Mensaje := 'Buscar Puntos a Terceros' || p_Tipo_Puntos;
        /* TPT Traspaso Puntos a Terceros de otras empresas JUMBO */
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_t
          FROM Scfr_Txs_Puntos
         WHERE Rut_Titular = p_Rut_Titular
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'TPT'
           AND Empresa_Alianza_Fidelizacion = p_Emp_Alianza;
        l_Dbg_Mensaje := 'Buscar Reversa Puntos a Terceros' || p_Tipo_Puntos;
        -- RTT Reversa Traspaso Puntos a Terceros de otras empresas
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos_r
          FROM Scfr_Txs_Puntos
         WHERE Rut_Titular = p_Rut_Titular
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'RTT'
           AND Empresa_Alianza_Fidelizacion = p_Emp_Alianza;
        l_Puntos := l_Puntos_t - l_Puntos_r;
      ELSIF (p_Tipo_Puntos IN ('P'
                              ,'RPT')) THEN
        /*
                l_DBG_MENSAJE := 'Recepci?n de Puntos otras empresas '||p_tipo_puntos;
                -- RPT Recepci?n de Puntos desde otras empresas
                select NVL(sum(ptos_procesados),0)
                  into l_puntos_t
                  from scfr_txs_puntos
                 where rut_titular                       = p_rut_titular
                   and trunc(fecha + l_dias_vcto_ptos ) >= trunc(scfr_trx_util_pk.get_sysdate())
                   and tipo_tx_puntos                    = 'RPT';
                -- RTT RPT Recepci?n de Puntos desde otras empresas
                --if (p_tipo_puntos in ( 'P', 'RPT' )) then
        */
        l_Dbg_Mensaje := 'Recepci?n de Puntos otras empresas ' || p_Tipo_Puntos;
        /* RPT Recepci?n de Puntos desde otras empresas */
        SELECT Nvl(SUM(Ptos_Procesados)
                  ,0)
          INTO l_Puntos
          FROM Scfr_Txs_Puntos
         WHERE Rut_Titular = p_Rut_Titular
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Tipo_Tx_Puntos = 'RPT';
        -- -----------------------------------------------------------------
        -- JRG 23092015 Revisa puntos inactivos programa de puntos antiguo.-
        -- -----------------------------------------------------------------
      ELSIF p_Tipo_Puntos = 'I' THEN
        l_Dbg_Mensaje := 'Buscar Puntos programa MCV antiguo ' || p_Tipo_Puntos;
        SELECT SUM(Disponible_Para_Canje)
          INTO l_Puntos
          FROM Scfr_Txs_Puntos
         WHERE Rut_Titular = p_Rut_Titular
           AND Tipo_Tx_Puntos != 'REG'
           AND Trunc(Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
           AND Estado_Registro = 'P';
        IF l_Puntos IS NULL THEN
          l_Puntos := 0;
        END IF;
        SELECT SUM(Disponible_Para_Canje)
          INTO l_Puntos_Regulacion
          FROM Scfr_Txs_Puntos
         WHERE Tipo_Tx_Puntos = 'REG'
           AND Estado_Registro = 'P'
           AND Rut_Titular = p_Rut_Titular;
        l_Puntos := l_Puntos + Nvl(l_Puntos_Regulacion
                                  ,0);
      ELSE
        l_Dbg_Mensaje := ' Sin Puntos a devolver' || p_Tipo_Puntos;
        l_Puntos      := 0;
      END IF;
      RETURN(l_Puntos);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => l_Dbg_Mensaje);
      RETURN 0;
  END;

  --****
  PROCEDURE Trama_Cz_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS

    CURSOR c_Ins_Automatica(p_Puf_Activacion NUMBER) IS
      SELECT Puf_Relacionado
        FROM Scfr_Campanas_Relacionadas
       WHERE Accion = 'AUT' -- rv_domain  fid.cg_ref_codes 'inscripcion aut. psalud'
         AND Puf_Activacion = p_Puf_Activacion
         AND Puf_Relacionado IS NOT NULL;

    l_Trama_Cz    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cz;
    l_Resultado   NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.trama_cz_resuelve';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Folio_Id    VARCHAR2(150);
    l_Error_Controlado EXCEPTION;
    l_Fecha_Inscripcion DATE;
    l_Campana_Ini       NUMBER;
    l_Fecha_Termino     DATE;
    l_Eliminado         Scfr_Uso_Frecuente.Eliminado%TYPE;
    l_Nro_Dias          NUMBER;
    l_Correlativo       NUMBER;
    l_Rut_Vendedor      NUMBER;
    l_Rut_Cliente       Scfr_Clientes_Uso_Frecuente.Rut_Cliente%TYPE;
    l_Dv_Rut_Cliente    Scfr_Clientes_Uso_Frecuente.Dv_Cliente%TYPE;
    l_Estado            Scfr_Clientes_Uso_Frecuente.Estado_Uso_Frec%TYPE;
  BEGIN
    /*
    l_dbg_mensaje := 'Obtener rut del vendedor desde la trama POS';
    begin
      l_rut_vendedor := substr(ltrim(rtrim(p_transaccion.trama_pos.usuario_responsable)),1,length(ltrim(rtrim(p_transaccion.trama_pos.usuario_responsable)))-1);
    exception
      when others then
        l_rut_vendedor := null;
    end;
    */
    l_Dbg_Mensaje := 'Obtener informaci?n de la trama CZ (Inscripci?n Producto Fidelizado)';
    l_Trama_Cz    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Cz(p_Transaccion.Cuerpo_Tx);
    l_Folio_Id    := To_Char(Nvl(l_Trama_Cz.Numero_Inscripcion
                                ,0));
    l_Dbg_Mensaje := 'LLamar a SCFR_PPROG_SALUD_PK.Inscrip_Cliente_PS';
    Scfr_Pprog_Salud_Pk.Inscrip_Cliente_Ps(p_Party_Id           => p_Transaccion.Trama_Boc.Party_Id
                                          ,p_Puf_Uso_Frecuente  => l_Trama_Cz.Uso_Frecuente
                                          ,p_Fecha_Inscripcion  => To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                                                          ,'yyyy/mm/dd hh24:mi:ss')
                                          ,p_Fecha_Termino      => To_Date(l_Trama_Cz.Fecha_Expiracion
                                                                          ,'yyyymmdd')
                                          ,p_Tipo_Inscripcion   => 'AFI'
                                          ,p_Inscripcion_Refill => 'NO'
                                          ,p_Estado_Uso_Frec    => 'ACT'
                                          ,p_Emp_Empresa        => p_Transaccion.Trama_Pos.Empresa
                                          ,p_Cad_Cadena         => p_Transaccion.Trama_Pos.Cadena
                                          ,p_Rut_Vendedor       => l_Trama_Cz.Rut_Vendedor
                                          ,p_Rut_Medico         => l_Trama_Cz.Rut_Medico
                                          ,p_Local_Inscripcion  => p_Transaccion.Trama_Pos.Local
                                          ,p_Folio              => Ltrim(Rtrim(l_Folio_Id))
                                          ,p_Documento_Venta    => l_Trama_Cz.Folio -- boleta
                                          ,p_Tipo_Banda         => p_Transaccion.Trama_Boc.Forma_Identificacion
                                          ,p_Canal              => 'POS'
                                          ,p_Descripcion_Ins    => 'Inscripcion PS On-Line'
                                          ,p_Cod_Error          => x_Cod_Error
                                          ,p_Msg_Error          => x_Msg_Error
                                          ,p_Corr               => 0);
    -- --------------------------------------------------------------------------------------
    -- JRG 07/07/2017 Inscripcion automatica y programa 2
    -- --------------------------------------------------------------------------------------
    FOR r_Ins_Automatica IN c_Ins_Automatica(l_Trama_Cz.Uso_Frecuente)
    LOOP
      -- Obtiene Campana
      BEGIN
        SELECT Cam_Campana INTO l_Campana_Ini FROM Scfr_Uso_Frecuente WHERE Uso_Frecuente = r_Ins_Automatica.Puf_Relacionado;
      EXCEPTION
        WHEN No_Data_Found THEN
          l_Campana_Ini := NULL;
      END;
      l_Fecha_Termino := Scfr_Pprog_Salud_Pk.Obtfechaterminoins(p_Cam_Campana  => l_Campana_Ini
                                                               ,p_Fecha_Inicio => To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                                                                         ,'yyyy/mm/dd hh24:mi:ss'));
      l_Dbg_Mensaje   := 'LLamar a SCFR_PPROG_SALUD_PK.Inscrip_Cliente_PS';
      Scfr_Pprog_Salud_Pk.Inscrip_Cliente_Ps(p_Party_Id           => p_Transaccion.Trama_Boc.Party_Id
                                            ,p_Puf_Uso_Frecuente  => r_Ins_Automatica.Puf_Relacionado
                                            ,p_Fecha_Inscripcion  => To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                                                            ,'yyyy/mm/dd hh24:mi:ss')
                                            ,p_Fecha_Termino      => l_Fecha_Termino
                                            ,p_Tipo_Inscripcion   => 'AFI'
                                            ,p_Inscripcion_Refill => 'NO'
                                            ,p_Estado_Uso_Frec    => 'ACT'
                                            ,p_Emp_Empresa        => p_Transaccion.Trama_Pos.Empresa
                                            ,p_Cad_Cadena         => p_Transaccion.Trama_Pos.Cadena
                                            ,p_Rut_Vendedor       => l_Trama_Cz.Rut_Vendedor
                                            ,p_Rut_Medico         => l_Trama_Cz.Rut_Medico
                                            ,p_Local_Inscripcion  => p_Transaccion.Trama_Pos.Local
                                            ,p_Folio              => Ltrim(Rtrim(l_Folio_Id))
                                            ,p_Documento_Venta    => l_Trama_Cz.Folio -- boleta
                                            ,p_Tipo_Banda         => p_Transaccion.Trama_Boc.Forma_Identificacion
                                            ,p_Canal              => 'POS'
                                            ,p_Descripcion_Ins    => 'Inscripcion PS On-Line Trasp Puf =>' || To_Char(l_Trama_Cz.Uso_Frecuente)
                                            ,p_Cod_Error          => x_Cod_Error
                                            ,p_Msg_Error          => x_Msg_Error
                                            ,p_Corr               => 0);
    END LOOP; -- for r_ins_automatica in c_ins_automatica(l_Trama_Pb.Uso_Frecuente) loop
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  --
  PROCEDURE Trama_Pd_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Party_Bene  Scfr_Mov_Transacciones.Pt_Party_Id_Titular%TYPE;
    l_Trama_Pd    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pd;
    l_Resultado   NUMBER;
    l_Aux         NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_EXC_PK.FIDU01.trama_pd_resuelve';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := ' Obtencion Antecedentes solicitados por trama ';
    l_Trama_Pd    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Pd(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje := ' Obtencion de Party_id  Beneficiario  ';
    BEGIN
      SELECT Party_Id INTO l_Party_Bene FROM Hz_Parties WHERE Jgzz_Fiscal_Code = l_Trama_Pd.Rut_Beneficiario;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Party_Bene := NULL;
    END;
    l_Dbg_Mensaje := ' Consulta si existe en scfr_red_puntoss ';
    SELECT COUNT(*) INTO l_Aux FROM Scfr_Red_Puntos WHERE Pt_Party_Id = p_Transaccion.Trama_Boc.Party_Id;
    IF Nvl(l_Aux
          ,0) = 0 THEN
      l_Dbg_Mensaje := ' Inserta donacion de puntos ';
      INSERT INTO Scfr_Red_Puntos
        (Pt_Party_Id
        ,Pt_Party_Presentador
        ,Pt_Party_Donante
        ,Fecha_Activacion_Donacion
        ,Fecha_Termino_Donacion
        ,Emp_Empresa
        ,Cad_Cadena)
      VALUES
        (p_Transaccion.Trama_Boc.Party_Id
        ,NULL
        ,l_Party_Bene
        ,To_Date(l_Trama_Pd.Fecha_Inicio
                ,'yyyy/mm/dd')
        ,To_Date(l_Trama_Pd.Fecha_Termino
                ,'yyyy/mm/dd')
        ,p_Transaccion.Trama_Pos.Empresa
        ,p_Transaccion.Trama_Pos.Cadena);
    ELSE
      l_Dbg_Mensaje := ' Actualiza donacion de puntos';
      UPDATE Scfr_Red_Puntos
         SET Pt_Party_Donante          = l_Party_Bene
            ,Fecha_Activacion_Donacion = To_Date(l_Trama_Pd.Fecha_Inicio
                                                ,'yyyy/mm/dd')
            ,Fecha_Termino_Donacion    = To_Date(l_Trama_Pd.Fecha_Termino
                                                ,'yyyy/mm/dd')
       WHERE Pt_Party_Id = p_Transaccion.Trama_Boc.Party_Id;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  --
  PROCEDURE Trama_Pt_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Party_Ve            Scfr_Mov_Transacciones.Pt_Party_Id_Titular%TYPE;
    l_Party_Recibe_Puntos Scfr_Mov_Transacciones.Pt_Party_Id_Titular%TYPE;
    l_Party_Cedente       Scfr_Mov_Transacciones.Pt_Party_Id_Titular%TYPE;
    l_Trama_Pt            Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pt;
    l_Resultado           NUMBER;
    l_Aux                 NUMBER;
    l_Aux1                NUMBER;
    l_Codigo_Tx           NUMBER;
    l_Boleta              NUMBER;
    l_Puntos              NUMBER;
    l_Txs_Puntos          NUMBER;
    l_Ptos_Recuperados    NUMBER;
    l_Aux_Trx             Scfr_Trx_Dyn_Pk.Rec_Transaccion;
    l_Dbg_Proceso         VARCHAR2(100) := 'SCFR_TRX_EXC_PK.FIDU02.trama_pt_resuelve';
    l_Dbg_Mensaje         VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje                             := 'Obtiene informacion desde la trama';
    l_Trama_Pt                                := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Pt(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje                             := 'Obtiene Party_id vendedor';
    l_Aux_Trx.Trama_Boc.String_Identificacion := l_Trama_Pt.Rut_Vendedor || l_Trama_Pt.Dv_Rut_Vendedor;
    l_Resultado                               := Determinar_Party_Id('R'
                                                                    ,l_Aux_Trx.Trama_Boc.String_Identificacion
                                                                    ,p_Transaccion.Trama_Pos.Empresa
                                                                    ,p_Transaccion.Trama_Pos.Cadena
                                                                    ,l_Party_Ve);
    l_Aux                                     := Scfr_Trx_Util_Pk.Det_Valor_Parametro_Por_Cod('DIVEPU');
    l_Aux1                                    := Scfr_Trx_Util_Pk.Retorna_Party_Id_Que_Cede(p_Transaccion.Trama_Boc.Party_Id);
    IF l_Aux1 IS NULL THEN
      l_Party_Recibe_Puntos := p_Transaccion.Trama_Boc.Party_Id;
      l_Party_Cedente       := NULL;
    ELSE
      l_Party_Recibe_Puntos := l_Aux1;
      l_Party_Cedente       := p_Transaccion.Trama_Boc.Party_Id;
    END IF;
    l_Dbg_Mensaje := 'Obtiene informacion scfr_mov_documentos_txs';
    BEGIN
      SELECT Smdt.Txo_Codigo_Tx
            ,Smdt.Folio
        INTO l_Codigo_Tx
            ,l_Boleta
        FROM Scfr_Mov_Documentos_Txs Smdt
       WHERE Smdt.Folio = l_Trama_Pt.Correlativo_Tx
         AND Smdt.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
         AND Smdt.Cad_Cadena = p_Transaccion.Trama_Pos.Cadena;
    EXCEPTION
      WHEN OTHERS THEN
        l_Codigo_Tx := NULL;
        l_Boleta    := NULL;
    END;
    l_Dbg_Mensaje := 'consulta si ya se han recuperado puntos para el documento';
    BEGIN
      SELECT 1 INTO l_Puntos FROM Scfr_Txs_Puntos WHERE Txo_Codigo_Tx = l_Codigo_Tx;
      RETURN; -- No contin?a porque ya se recuperaron puntos.
    EXCEPTION
      WHEN No_Data_Found THEN
        NULL; -- Contin?a porque no se han recuperado puntos.
    END;
    --
    l_Dbg_Mensaje := 'Obtiene desde Nextval l_ptos_recuperados,l_txs_puntos';
    SELECT Scfr_Puntos_Recuperados_s.Nextval INTO l_Ptos_Recuperados FROM Dual;
    SELECT Scfr_Txs_Puntos_s.Nextval INTO l_Txs_Puntos FROM Dual;
    l_Dbg_Mensaje := 'Suma de punto ';
    BEGIN
      SELECT SUM(Nvl(Puntos_Generados
                    ,0))
        INTO l_Puntos
        FROM Scfr_Mov_Productos_Txs
       WHERE Txo_Codigo_Tx = l_Codigo_Tx;
    EXCEPTION
      WHEN OTHERS THEN
        l_Puntos := NULL;
    END;
    l_Dbg_Mensaje := 'Inserta puntos recuperados scfr_puntos_recuperados';
    INSERT INTO Scfr_Puntos_Recuperados
      (Puntos_Recuperados
      ,Pt_Party_Id_Vendedor
      ,Emp_Codigo
      ,Cad_Cadena
      ,Loc_Local
      ,Fecha_Recuperacion)
    VALUES
      (l_Ptos_Recuperados
      ,l_Party_Ve
      ,p_Transaccion.Trama_Pos.Empresa
      ,p_Transaccion.Trama_Pos.Cadena
      ,l_Trama_Pt.Local
      ,Scfr_Trx_Util_Pk.Get_Sysdate());
    l_Dbg_Mensaje := 'Inserta puntos recuperados scfr_txs_puntos';
    INSERT INTO Scfr_Txs_Puntos
      (Tx_Puntos
      ,Pt_Party_Id
      ,Pt_Party_Id_Cedente
      ,Tipo_Tx_Puntos
      ,Ptos_Procesados
      ,Disponible_Para_Canje
      ,Pur_Puntos_Recuperados
      ,Txo_Codigo_Tx
      ,Numero_Boleta
      ,Txp_Tx_Puntos
      ,Fecha_Anulacion
      ,Estado_Registro
      ,Txp_Tx_Puntos_Anulacion
      ,Canal
      ,Fecha
      ,Cam_Campana
      ,Rut_Titular
      ,Dv_Titular)
    VALUES
      (l_Txs_Puntos
      ,l_Party_Recibe_Puntos
      ,l_Party_Cedente
      ,'APR'
      ,l_Puntos
      ,l_Puntos
      ,l_Ptos_Recuperados
      ,l_Codigo_Tx
      ,l_Boleta
      ,NULL
      ,NULL
      ,'A'
      ,NULL
      ,'POS'
      ,Scfr_Trx_Util_Pk.Get_Sysdate()
      ,NULL
      ,p_Transaccion.Trama_Boc.String_Identificacion
      ,p_Transaccion.Trama_Boc.Forma_Identificacion);
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  --
  PROCEDURE Trama_Cd_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Cd      Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cd;
    l_Resultado     NUMBER;
    l_Codigo        NUMBER;
    l_Uso_Frecuente NUMBER;
    --
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_EXC_PK.FIDU05';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Obtencion de Informacion desde trama cd';
    l_Trama_Cd    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Cd(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje := 'Valida Uso Frecuente';
    BEGIN
      SELECT Prod.Codigo
            ,Scuf.Uso_Frecuente
        INTO l_Codigo
            ,l_Uso_Frecuente
        FROM Scfr_Clientes_Uso_Frecuente Cluf
            ,Scfr_Uso_Frecuente          Scuf
            ,Scfr_Productos_v            Prod
       WHERE Cluf.Puf_Uso_Frecuente = Scuf.Uso_Frecuente
         AND Scuf.Pro_Codigo_Compra = Prod.Codigo
         AND Cluf.Pt_Party_Id = p_Transaccion.Trama_Boc.Party_Id
            --            and prod.codigo            = p_transaccion.trama_pos.CODIGO_AUTORIZACION -- --Scfr_trx_Util_Pk.bin2num(-dbms_lob.substr(Pentrada,4,scfr_trx_util_pk.K_TRAMA_CTX_CANT_REG+4))
         AND Prod.Empresa = p_Transaccion.Trama_Pos.Empresa;
    EXCEPTION
      WHEN OTHERS THEN
        l_Codigo        := NULL;
        l_Uso_Frecuente := NULL;
    END;
    IF l_Codigo IS NOT NULL THEN
      l_Dbg_Mensaje := 'Actualiza Uso Frecuente';
      UPDATE Scfr_Uso_Frecuente
         SET Eliminado = 'SI'
       WHERE Uso_Frecuente = l_Uso_Frecuente
         AND Pro_Codigo_Compra = l_Codigo;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  --
  PROCEDURE Trama_Pb_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS

    CURSOR c_Ins_Automatica(p_Puf_Activacion NUMBER) IS
      SELECT Puf_Relacionado
        FROM Scfr_Campanas_Relacionadas
       WHERE Accion = 'AUT' -- rv_domain  fid.cg_ref_codes 'inscripcion aut. psalud'
         AND Puf_Activacion = p_Puf_Activacion
         AND Puf_Relacionado IS NOT NULL;

    l_Trama_Pb          Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pb;
    l_Resultado         NUMBER;
    l_Fecha_Inscripcion DATE;
    l_Nro_Dias          NUMBER;
    l_Rut_Cliente       NUMBER;
    l_Fecha_Termino     DATE;
    l_Campana_Ini       NUMBER;
    l_Eliminado         VARCHAR2(2);
    l_Estado            VARCHAR2(3);
    l_Dv_Rut_Cliente    VARCHAR2(1);
    l_Rut_Vendedor      NUMBER;
    l_Folio_Id          VARCHAR2(150);
    l_Dbg_Proceso       VARCHAR2(100) := 'SCFR_TRX_FID_PK.trama_pb_resuelve';
    l_Dbg_Mensaje       VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    /*
    l_dbg_mensaje := 'Obtener rut del vendedor desde la trama POS';
    begin
      l_rut_vendedor := substr(ltrim(rtrim(p_transaccion.trama_pos.usuario_responsable)),1,length(ltrim(rtrim(p_transaccion.trama_pos.usuario_responsable)))-1);
    exception
      when others then
        l_rut_vendedor := null;
    end;
    */
    
    l_Dbg_Mensaje := 'Obtener informaci?n de la trama PB (Inscripci?n Producto Fidelizado)';
    l_Trama_Pb    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Pb(p_Transaccion.Cuerpo_Tx);
    l_Folio_Id    := To_Char(Nvl(l_Trama_Pb.Numero_Inscripcion
                                ,0));
    l_Dbg_Mensaje := 'LLamar a SCFR_PPROG_SALUD_PK.Inscrip_Cliente_PS';
    Scfr_Pprog_Salud_Pk.Inscrip_Cliente_Ps(p_Party_Id           => p_Transaccion.Trama_Boc.Party_Id
                                          ,p_Puf_Uso_Frecuente  => l_Trama_Pb.Uso_Frecuente
                                          ,p_Fecha_Inscripcion  => To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                                                          ,'yyyy/mm/dd hh24:mi:ss')
                                          ,p_Fecha_Termino      => To_Date(l_Trama_Pb.Fecha_Expiracion
                                                                          ,'yyyymmdd')
                                          ,p_Tipo_Inscripcion   => 'AFI'
                                          ,p_Inscripcion_Refill => 'NO'
                                          ,p_Estado_Uso_Frec    => 'ACT'
                                          ,p_Emp_Empresa        => p_Transaccion.Trama_Pos.Empresa
                                          ,p_Cad_Cadena         => p_Transaccion.Trama_Pos.Cadena
                                          ,p_Rut_Vendedor       => l_Trama_Pb.Rut_Vendedor
                                          ,p_Rut_Medico         => l_Trama_Pb.Rut_Medico
                                          ,p_Local_Inscripcion  => p_Transaccion.Trama_Pos.Local
                                          ,p_Folio              => Ltrim(Rtrim(l_Folio_Id))
                                          ,p_Documento_Venta    => l_Trama_Pb.Folio -- boleta
                                          ,p_Tipo_Banda         => p_Transaccion.Trama_Boc.Forma_Identificacion
                                          ,p_Canal              => 'POS'
                                          ,p_Descripcion_Ins    => 'Inscripcion PS On-Line'
                                          ,p_Cod_Error          => x_Cod_Error
                                          ,p_Msg_Error          => x_Msg_Error
                                          ,p_Corr               => 0);
    -- --------------------------------------------------------------------------------------
    -- JRG 07/07/2017 Inscripcion automatica y programa 2
    -- --------------------------------------------------------------------------------------
    FOR r_Ins_Automatica IN c_Ins_Automatica(l_Trama_Pb.Uso_Frecuente)
    LOOP
      -- Obtiene Campana
      BEGIN
        SELECT Cam_Campana INTO l_Campana_Ini FROM Scfr_Uso_Frecuente WHERE Uso_Frecuente = r_Ins_Automatica.Puf_Relacionado;
      EXCEPTION
        WHEN No_Data_Found THEN
          l_Campana_Ini := NULL;
      END;
      l_Fecha_Termino := Scfr_Pprog_Salud_Pk.Obtfechaterminoins(p_Cam_Campana  => l_Campana_Ini
                                                               ,p_Fecha_Inicio => To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                                                                         ,'yyyy/mm/dd hh24:mi:ss'));
      l_Dbg_Mensaje   := 'LLamar a SCFR_PPROG_SALUD_PK.Inscrip_Cliente_PS';
      Scfr_Pprog_Salud_Pk.Inscrip_Cliente_Ps(p_Party_Id           => p_Transaccion.Trama_Boc.Party_Id
                                            ,p_Puf_Uso_Frecuente  => r_Ins_Automatica.Puf_Relacionado
                                            ,p_Fecha_Inscripcion  => To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                                                            ,'yyyy/mm/dd hh24:mi:ss')
                                            ,p_Fecha_Termino      => l_Fecha_Termino
                                            ,p_Tipo_Inscripcion   => 'AFI'
                                            ,p_Inscripcion_Refill => 'NO'
                                            ,p_Estado_Uso_Frec    => 'ACT'
                                            ,p_Emp_Empresa        => p_Transaccion.Trama_Pos.Empresa
                                            ,p_Cad_Cadena         => p_Transaccion.Trama_Pos.Cadena
                                            ,p_Rut_Vendedor       => l_Trama_Pb.Rut_Vendedor
                                            ,p_Rut_Medico         => l_Trama_Pb.Rut_Medico
                                            ,p_Local_Inscripcion  => p_Transaccion.Trama_Pos.Local
                                            ,p_Folio              => Ltrim(Rtrim(l_Folio_Id))
                                            ,p_Documento_Venta    => l_Trama_Pb.Folio -- boleta
                                            ,p_Tipo_Banda         => p_Transaccion.Trama_Boc.Forma_Identificacion
                                            ,p_Canal              => 'POS'
                                            ,p_Descripcion_Ins    => 'Inscripcion PS On-Line Trasp Puf =>' || To_Char(l_Trama_Pb.Uso_Frecuente)
                                            ,p_Cod_Error          => x_Cod_Error
                                            ,p_Msg_Error          => x_Msg_Error
                                            ,p_Corr               => 0);
    END LOOP; -- for r_ins_automatica in c_ins_automatica(l_Trama_Pb.Uso_Frecuente) loop
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  /*
  * OBJETIVO
  *   Resolver trama ZP (Asignaci?n de puntos)
  * PARAMETROS
  *   p_transaccion  : Transacci?n recibida desde el pos
  *   x_cod_error    : C?digo de error retornado (0    en caso de no existir errores)
  *   x_msg_error    : Mesaje de error retornado (NULL en caso de no existir errores)
  */
  PROCEDURE Trama_Zp_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Zp    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Zp;
    l_Codigo_Tx   NUMBER;
    l_Campana     NUMBER;
    l_Id_Pto      NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.trama_zp_resuelve';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error No Determinado';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Obtener informaci?n de la trama ZP (Acumulaci?n de Puntos)';
    l_Trama_Zp    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Zp(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje := 'Buscar Rut para Party Id:' || p_Transaccion.Trama_Boc.Party_Id || ' en tabla HZ_PARTIES';
    Scfr_Trx_Fid_Pk.Obtiene_Rut(p_Transaccion.Trama_Boc.Party_Id
                               ,p_Transaccion.Rut_Titular
                               ,p_Transaccion.Dv_Rut_Titular);
    -- Valida si el correlativo ya existe, podr?haber llegado antes la FIDU52
    l_Dbg_Mensaje := 'Validar si correlativo TX ' || l_Trama_Zp.Correlativo_Tx || ' existe en tabla SCFR_TMP_TRANSACCIONES';
    BEGIN
      SELECT Codigo_Tx
        INTO l_Codigo_Tx
        FROM Scfr_Tmp_Transacciones
       WHERE Correlativo_Tx = l_Trama_Zp.Correlativo_Tx
         AND Loc_Local = p_Transaccion.Trama_Pos.Local
         AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
         AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena;
    EXCEPTION
      WHEN OTHERS THEN
        l_Codigo_Tx := NULL;
    END;
    IF l_Codigo_Tx IS NULL THEN
      l_Dbg_Mensaje := 'Obtener ID de scfr_mov_transacciones';
      SELECT Scfr_Mov_Transacciones_s.Nextval INTO l_Codigo_Tx FROM Dual;
      l_Dbg_Mensaje := 'Insertar en tabla SCFR_TMP_TRANSACCIONES';
      INSERT INTO Scfr_Tmp_Transacciones
        (Codigo_Tx
        ,Correlativo_Tx
        ,Fecha_Tx
        ,Rut_Titular
        ,Dv_Titular
        ,Pt_Party_Id_Titular
        ,Loc_Local
        ,Emp_Empresa
        ,Cad_Cadena
        ,Pos_Origen)
      VALUES
        (l_Codigo_Tx -- codigo_tx
        ,l_Trama_Zp.Correlativo_Tx -- correlativo_tx
        ,To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                ,'yyyy/mm/dd hh24:mi:ss') -- fecha_tx
        ,p_Transaccion.Rut_Titular -- rut_titular
        ,p_Transaccion.Dv_Rut_Titular -- dv_titular
        ,p_Transaccion.Trama_Boc.Party_Id -- pt_party_id_titular
        ,p_Transaccion.Trama_Pos.Local
        ,p_Transaccion.Trama_Pos.Empresa
        ,p_Transaccion.Trama_Pos.Cadena
        ,'NPO');
    END IF;
    l_Dbg_Mensaje := 'Obtener campa?a generica de puntos';
    l_Campana     := Obtiene_Campana(p_Transaccion.Trama_Pos.Empresa
                                    ,p_Transaccion.Trama_Pos.Cadena);
    l_Dbg_Mensaje := 'Preparar par?tros de entrada para SCFR_TRX_PUNTOS_PK.registra_apg';
    Scfr_Trx_Puntos_Pk.Setea_Local_Trx(p_Transaccion.Trama_Pos.Local);
    l_Id_Pto := Scfr_Trx_Puntos_Pk.Registra_Apg(p_Party_Id     => NULL --p_transaccion.trama_boc.party_id
                                               ,p_Rut_Titular  => p_Transaccion.Rut_Titular
                                               ,p_Puntos       => l_Trama_Zp.Puntos
                                               ,p_Codigo_Tx    => l_Codigo_Tx
                                               ,p_Numero_Docto => l_Trama_Zp.Correlativo_Tx
                                               ,p_Campana      => l_Campana
                                               ,p_Empresa      => p_Transaccion.Trama_Pos.Empresa
                                               ,p_Cadena       => p_Transaccion.Trama_Pos.Cadena
                                               ,p_Fecha        => To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                                                         ,'yyyy/mm/dd hh24:mi:ss')
                                               ,p_Vendedor     => p_Transaccion.Trama_Pos.Usuario_Responsable
                                               ,p_Local        => p_Transaccion.Trama_Pos.Local
                                               ,x_Cod_Error    => x_Cod_Error
                                               ,x_Msg_Error    => x_Msg_Error);
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  /*
  * OBJETIVO
  *   Resolver trama ZJ (Canje de puntos)
  * PARAMETROS
  *   p_transaccion  : Transacci?n recibida desde el pos
  *   x_cod_error    : C?digo de error retornado (0    en caso de no existir errores)
  *   x_msg_error    : Mesaje de error retornado (NULL en caso de no existir errores)
  */
  PROCEDURE Trama_Zj_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Zj    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Zj;
    l_Codigo_Tx   NUMBER;
    l_Campana     NUMBER;
    l_Id_Pto      NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.trama_zj_resuelve';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error No Determinado';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Obtener informaci?n de la trama ZJ (Canje de Puntos)';
    l_Trama_Zj    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Zj(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje := 'Buscar Rut para Party Id:' || p_Transaccion.Trama_Boc.Party_Id || ' en tabla HZ_PARTIES';
    Scfr_Trx_Fid_Pk.Obtiene_Rut(p_Transaccion.Trama_Boc.Party_Id
                               ,p_Transaccion.Rut_Titular
                               ,p_Transaccion.Dv_Rut_Titular);
    -- Valida si el correlativo ya existe, podr?haber llegado antes la FIDU51
    l_Dbg_Mensaje := 'Validar si correlativo TX ' || l_Trama_Zj.Correlativo_Tx || ' existe en tabla SCFR_TMP_TRANSACCIONES';
    BEGIN
      SELECT Codigo_Tx
        INTO l_Codigo_Tx
        FROM Scfr_Tmp_Transacciones
       WHERE Correlativo_Tx = l_Trama_Zj.Correlativo_Tx
         AND Loc_Local = p_Transaccion.Trama_Pos.Local
         AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
         AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena;
    EXCEPTION
      WHEN OTHERS THEN
        l_Codigo_Tx := NULL;
    END;
    IF l_Codigo_Tx IS NULL THEN
      l_Dbg_Mensaje := 'Obtener ID de scfr_mov_transacciones';
      SELECT Scfr_Mov_Transacciones_s.Nextval INTO l_Codigo_Tx FROM Dual;
      l_Dbg_Mensaje := 'Insertar en tabla SCFR_TMP_TRANSACCIONES';
      INSERT INTO Scfr_Tmp_Transacciones
        (Codigo_Tx
        ,Correlativo_Tx
        ,Fecha_Tx
        ,Rut_Titular
        ,Dv_Titular
        ,Pt_Party_Id_Titular
        ,Loc_Local
        ,Emp_Empresa
        ,Cad_Cadena
        ,Pos_Origen)
      VALUES
        (l_Codigo_Tx -- codigo_tx
        ,l_Trama_Zj.Correlativo_Tx -- correlativo_tx
        ,To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                ,'yyyy/mm/dd hh24:mi:ss') -- fecha_tx
        ,p_Transaccion.Rut_Titular -- rut_titular
        ,p_Transaccion.Dv_Rut_Titular -- dv_titular
        ,p_Transaccion.Trama_Boc.Party_Id -- pt_party_id_titular
        ,p_Transaccion.Trama_Pos.Local
        ,p_Transaccion.Trama_Pos.Empresa
        ,p_Transaccion.Trama_Pos.Cadena
        ,'NPO');
    END IF;
    l_Dbg_Mensaje := 'Obtener campa?a generica de puntos';
    l_Campana     := Obtiene_Campana(p_Transaccion.Trama_Pos.Empresa
                                    ,p_Transaccion.Trama_Pos.Cadena);
    l_Dbg_Mensaje := 'Preparar par?tros de entrada para SCFR_TRX_PUNTOS_PK.registra_can';
    Scfr_Trx_Puntos_Pk.Setea_Local_Trx(p_Transaccion.Trama_Pos.Local);
    l_Id_Pto := Scfr_Trx_Puntos_Pk.Registra_Can(p_Party_Id     => NULL --p_transaccion.trama_boc.party_id
                                               ,p_Rut_Titular  => p_Transaccion.Rut_Titular
                                               ,p_Puntos       => l_Trama_Zj.Puntos
                                               ,p_Codigo_Tx    => l_Codigo_Tx
                                               ,p_Numero_Docto => l_Trama_Zj.Correlativo_Tx
                                               ,p_Campana      => l_Campana
                                               ,p_Empresa      => p_Transaccion.Trama_Pos.Empresa
                                               ,p_Cadena       => p_Transaccion.Trama_Pos.Cadena
                                               ,p_Fecha        => To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                                                         ,'yyyy/mm/dd hh24:mi:ss')
                                               ,p_Vendedor     => p_Transaccion.Trama_Pos.Usuario_Responsable
                                               ,p_Local        => p_Transaccion.Trama_Pos.Local
                                               ,x_Cod_Error    => x_Cod_Error
                                               ,x_Msg_Error    => x_Msg_Error);
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  /*
  * OBJETIVO
  *   Resolver trama ZC (Canje de puntos)
  * PARAMETROS
  *   p_transaccion  : Transacci?n recibida desde el pos
  *   x_cod_error    : C?digo de error retornado (0    en caso de no existir errores)
  *   x_msg_error    : Mesaje de error retornado (NULL en caso de no existir errores)
  */
  PROCEDURE Trama_Zc_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Zc           Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Zc;
    l_Codigo_Tx          NUMBER;
    l_Campana            NUMBER;
    l_Id_Pto             NUMBER;
    l_Codigo_Tx_Relacion NUMBER;
    l_Loc_Local          NUMBER;
    l_Fecha_Tx           DATE;
    l_Dbg_Proceso        VARCHAR2(100) := 'SCFR_TRX_FID_PK.trama_zc_resuelve';
    l_Dbg_Mensaje        VARCHAR2(250) := 'Error No Determinado';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Obtener informaci?n de la trama ZC (Reversa de Puntos)';
    l_Trama_Zc    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Zc(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje := 'Buscar Rut para Party Id:' || p_Transaccion.Trama_Boc.Party_Id || ' en tabla HZ_PARTIES';
    Scfr_Trx_Fid_Pk.Obtiene_Rut(p_Transaccion.Trama_Boc.Party_Id
                               ,p_Transaccion.Rut_Titular
                               ,p_Transaccion.Dv_Rut_Titular);
    l_Dbg_Mensaje := 'Obtener ID de la transacci?n original desde scfr_tmp_transacciones - correlativo_tx = ' || l_Trama_Zc.Correlativo_Tx;
    SELECT Codigo_Tx
          ,Loc_Local
          ,Fecha_Tx
      INTO l_Codigo_Tx_Relacion
          ,l_Loc_Local
          ,l_Fecha_Tx
      FROM Scfr_Tmp_Transacciones
     WHERE Correlativo_Tx = l_Trama_Zc.Correlativo_Tx_Asociado
       AND Loc_Local = p_Transaccion.Trama_Pos.Local
       AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
       AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena;
    -- Valida si el correlativo ya existe, podr?haber llegado antes la FIDU56
    l_Dbg_Mensaje := 'Validar si correlativo TX ' || l_Trama_Zc.Correlativo_Tx || ' existe en tabla SCFR_TMP_TRANSACCIONES';
    BEGIN
      SELECT Codigo_Tx
            ,Loc_Local
            ,Fecha_Tx
        INTO l_Codigo_Tx
            ,l_Loc_Local
            ,l_Fecha_Tx
        FROM Scfr_Tmp_Transacciones
       WHERE Correlativo_Tx = l_Trama_Zc.Correlativo_Tx
         AND Loc_Local = p_Transaccion.Trama_Pos.Local
         AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
         AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena;
    EXCEPTION
      WHEN OTHERS THEN
        l_Codigo_Tx := NULL;
    END;
    IF l_Codigo_Tx IS NULL THEN
      l_Dbg_Mensaje := 'Obtener ID de scfr_mov_transacciones';
      SELECT Scfr_Mov_Transacciones_s.Nextval INTO l_Codigo_Tx FROM Dual;
      l_Dbg_Mensaje := 'Insertar en tabla SCFR_TMP_TRANSACCIONES';
      INSERT INTO Scfr_Tmp_Transacciones
        (Codigo_Tx
        ,Correlativo_Tx
        ,Fecha_Tx
        ,Rut_Titular
        ,Dv_Titular
        ,Pt_Party_Id_Titular
        ,Loc_Local
        ,Emp_Empresa
        ,Cad_Cadena
        ,Pos_Origen)
      VALUES
        (l_Codigo_Tx -- codigo_tx
        ,l_Trama_Zc.Correlativo_Tx -- correlativo_tx
        ,To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                ,'yyyy/mm/dd hh24:mi:ss') -- fecha_tx
        ,p_Transaccion.Rut_Titular -- rut_titular
        ,p_Transaccion.Dv_Rut_Titular -- dv_titular
        ,p_Transaccion.Trama_Boc.Party_Id -- pt_party_id_titular
        ,p_Transaccion.Trama_Pos.Local
        ,p_Transaccion.Trama_Pos.Empresa
        ,p_Transaccion.Trama_Pos.Cadena
        ,'NPO');
    END IF;
    l_Dbg_Mensaje := 'Obtener campa?a generica de puntos';
    l_Campana     := Obtiene_Campana(p_Transaccion.Trama_Pos.Empresa
                                    ,p_Transaccion.Trama_Pos.Cadena);
    l_Dbg_Mensaje := 'Preparar par?tros de entrada para SCFR_TRX_PUNTOS_PK.registra_rev';
    Scfr_Trx_Puntos_Pk.Setea_Local_Trx(p_Transaccion.Trama_Pos.Local);
    Scfr_Trx_Puntos_Pk.Registra_Rev(p_Party_Id           => NULL --p_transaccion.trama_boc.party_id
                                   ,p_Rut_Titular        => p_Transaccion.Rut_Titular
                                   ,p_Codigo_Tx          => l_Codigo_Tx
                                   ,p_Codigo_Tx_Original => l_Codigo_Tx_Relacion
                                   ,p_Numero_Docto       => l_Trama_Zc.Correlativo_Tx_Asociado
                                   ,p_Empresa            => p_Transaccion.Trama_Pos.Empresa
                                   ,p_Cadena             => p_Transaccion.Trama_Pos.Cadena
                                   ,p_Fecha              => To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                                                   ,'yyyy/mm/dd hh24:mi:ss')
                                   ,p_Fecha_Venta        => l_Fecha_Tx
                                   ,p_Vendedor           => p_Transaccion.Trama_Pos.Usuario_Responsable
                                   ,p_Local              => p_Transaccion.Trama_Pos.Local
                                   ,p_Local_Venta        => l_Loc_Local
                                   ,x_Cod_Error          => x_Cod_Error
                                   ,x_Msg_Error          => x_Msg_Error);
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Trama_Ra_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Fecha_Escaneo DATE;
    l_Estado_Folio  VARCHAR2(3);
    l_Campana       NUMBER;
    i               NUMBER;
    l_Trama_Ra      Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ra;
    l_Dbg_Proceso   VARCHAR2(100) := 'SCFR_TRX_EXC_PK.FIDI06.trama_ra_resuelve';
    l_Dbg_Mensaje   VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje   := 'Tarjeta Scaneada (dominio ESTADO RED FUTURA).';
    l_Fecha_Escaneo := Scfr_Trx_Util_Pk.Get_Sysdate();
    l_Estado_Folio  := 'SCA';
    l_Dbg_Mensaje   := 'Obtencion de antecedentes trama RA';
    l_Trama_Ra      := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Ra(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje   := 'Obtencion de de Campa?a Asociada';
    l_Campana       := Obtiene_Campana(p_Transaccion.Trama_Pos.Empresa
                                      ,p_Transaccion.Trama_Pos.Cadena);
    IF l_Campana IS NOT NULL THEN
      l_Dbg_Mensaje := ' Inserta cliente en red de amigos (NADIE lo Invito).';
      INSERT INTO Scfr_Red_Puntos
        (Pt_Party_Id
        ,Pt_Party_Presentador
        ,Pt_Party_Donante
        ,Fecha_Activacion_Donacion
        ,Fecha_Termino_Donacion
        ,Emp_Empresa
        ,Cad_Cadena
        ,Cam_Campana
        ,Rut_Cliente
        ,Dv_Cliente
        ,Rut_Presentador
        ,Dv_Presentador
        ,Rut_Donante
        ,Dv_Donante)
      VALUES
        (p_Transaccion.Trama_Boc.Party_Id
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,p_Transaccion.Trama_Pos.Empresa
        ,p_Transaccion.Trama_Pos.Cadena
        ,l_Campana
        ,Substr(p_Transaccion.Trama_Boc.String_Identificacion
               ,1
               ,Length(p_Transaccion.Trama_Boc.String_Identificacion) - 1)
        ,Substr(p_Transaccion.Trama_Boc.String_Identificacion
               ,Length(p_Transaccion.Trama_Boc.String_Identificacion)
               ,1)
        ,NULL
        ,NULL
        ,NULL
        ,NULL);
    END IF;
    l_Dbg_Mensaje := ' Recorre n?mero de tarjetas solicitadas por el cliente.';
    i             := 0;
    --  for  i in 1..l_trama_ra.count loop
    l_Dbg_Mensaje := 'crea tarjetas en tabla SCFR_REDES_FUTURAS.';
    INSERT INTO Scfr_Redes_Futuras
      (Pt_Party_Id
      ,Folio
      ,Fecha_Escaneo
      ,Estado_Folio
      ,Fecha_Activacion)
    VALUES
      (p_Transaccion.Trama_Boc.Party_Id
      ,l_Trama_Ra.Tarjeta_Invitado
      ,l_Fecha_Escaneo
      ,l_Estado_Folio
      ,NULL);
    --  end loop;
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

  PROCEDURE Trama_Tp_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Codigo_Tx   NUMBER;
    l_Tx_Puntos   NUMBER;
    l_Trama_Tp    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Tp;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.trama_tp_resuelve';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error No Determinado';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Obtener informaci?n de la trama TP (Trapaso Puntos)';
    l_Trama_Tp    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Tp(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje := 'Buscar Rut para Party Id:' || p_Transaccion.Trama_Boc.Party_Id || ' en tabla HZ_PARTIES';
    Scfr_Trx_Fid_Pk.Obtiene_Rut(p_Transaccion.Trama_Boc.Party_Id
                               ,p_Transaccion.Rut_Titular
                               ,p_Transaccion.Dv_Rut_Titular);
    l_Dbg_Mensaje := 'Obtener ID de scfr_mov_transacciones';
    SELECT Scfr_Mov_Transacciones_s.Nextval INTO l_Codigo_Tx FROM Dual;
    l_Dbg_Mensaje := 'Insertar en tabla SCFR_TMP_TRANSACCIONES';
    INSERT INTO Scfr_Tmp_Transacciones
      (Codigo_Tx
      ,Correlativo_Tx
      ,Fecha_Tx
      ,Rut_Titular
      ,Dv_Titular
      ,Pt_Party_Id_Titular
      ,Loc_Local
      ,Emp_Empresa
      ,Cad_Cadena
      ,Pos_Origen)
    VALUES
      (l_Codigo_Tx -- codigo_tx
      ,l_Trama_Tp.Correlativo_Tx -- correlativo_tx
      ,To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
              ,'yyyy/mm/dd hh24:mi:ss') -- fecha_tx
      ,p_Transaccion.Rut_Titular -- rut_titular
      ,p_Transaccion.Dv_Rut_Titular -- dv_titular
      ,p_Transaccion.Trama_Boc.Party_Id -- pt_party_id_titular
      ,p_Transaccion.Trama_Pos.Local
      ,p_Transaccion.Trama_Pos.Empresa
      ,p_Transaccion.Trama_Pos.Cadena
      ,'NPO');
    l_Dbg_Mensaje := 'Insertar Traspaso Puntos';
    Scfr_Trx_Puntos_Pk.Setea_Local_Trx(p_Transaccion.Trama_Pos.Local);
    l_Tx_Puntos := Scfr_Trx_Puntos_Pk.Registra_Tpt(p_Party_Id                 => NULL --p_transaccion.trama_boc.party_id
                                                  ,p_Rut_Titular              => p_Transaccion.Rut_Titular
                                                  ,p_Puntos                   => l_Trama_Tp.Puntos
                                                  ,p_Canal                    => 'POS'
                                                  ,p_Codigo_Tx                => l_Codigo_Tx
                                                  ,p_Empresa                  => p_Transaccion.Trama_Pos.Empresa
                                                  ,p_Cadena                   => p_Transaccion.Trama_Pos.Cadena
                                                  ,p_Fecha                    => To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                                                                        ,'yyyy/mm/dd hh24:mi:ss')
                                                  ,p_Empresa_Destino_Traspaso => l_Trama_Tp.Destino
                                                  ,p_Vendedor                 => p_Transaccion.Trama_Pos.Usuario_Responsable
                                                  ,p_Local                    => p_Transaccion.Trama_Pos.Local
                                                  ,x_Cod_Error                => x_Cod_Error
                                                  ,x_Msg_Error                => x_Msg_Error);
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  PROCEDURE Trama_Ta_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Ta           Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ta;
    l_Tx_Puntos          NUMBER;
    l_Codigo_Tx          NUMBER;
    l_Codigo_Tx_Relacion NUMBER;
    l_Fecha_Tx           DATE;
    l_Loc_Local          NUMBER;
    l_Dbg_Proceso        VARCHAR2(100) := 'SCFR_TRX_FID_PK.trama_ta_resuelve';
    l_Dbg_Mensaje        VARCHAR2(250) := 'Error No Determinado';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Obtener informaci?n de la trama TA (Reversa Trapaso Puntos)';
    l_Trama_Ta    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Ta(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje := 'Buscar Rut para Party Id:' || p_Transaccion.Trama_Boc.Party_Id || ' en tabla HZ_PARTIES';
    Scfr_Trx_Fid_Pk.Obtiene_Rut(p_Transaccion.Trama_Boc.Party_Id
                               ,p_Transaccion.Rut_Titular
                               ,p_Transaccion.Dv_Rut_Titular);
    l_Dbg_Mensaje := 'Obtener ID de la transacci?n original desde scfr_tmp_transacciones - correlativo_tx = ' || l_Trama_Ta.Correlativo_Tx_Asociado;
    SELECT Codigo_Tx
          ,Fecha_Tx
          ,Loc_Local
      INTO l_Codigo_Tx_Relacion
          ,l_Fecha_Tx
          ,l_Loc_Local
      FROM Scfr_Tmp_Transacciones
     WHERE Correlativo_Tx = l_Trama_Ta.Correlativo_Tx_Asociado
       AND Loc_Local = p_Transaccion.Trama_Pos.Local
       AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
       AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena;
    l_Dbg_Mensaje := 'Obtener ID de scfr_mov_transacciones';
    SELECT Scfr_Mov_Transacciones_s.Nextval INTO l_Codigo_Tx FROM Dual;
    l_Dbg_Mensaje := 'Insertar en tabla SCFR_TMP_TRANSACCIONES';
    INSERT INTO Scfr_Tmp_Transacciones
      (Codigo_Tx
      ,Correlativo_Tx
      ,Fecha_Tx
      ,Rut_Titular
      ,Dv_Titular
      ,Pt_Party_Id_Titular
      ,Loc_Local
      ,Emp_Empresa
      ,Cad_Cadena
      ,Pos_Origen)
    VALUES
      (l_Codigo_Tx -- codigo_tx
      ,l_Trama_Ta.Correlativo_Tx -- correlativo_tx
      ,To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
              ,'yyyy/mm/dd hh24:mi:ss') -- fecha_tx
      ,p_Transaccion.Rut_Titular -- rut_titular
      ,p_Transaccion.Dv_Rut_Titular -- dv_titular
      ,p_Transaccion.Trama_Boc.Party_Id -- pt_party_id_titular
      ,p_Transaccion.Trama_Pos.Local
      ,p_Transaccion.Trama_Pos.Empresa
      ,p_Transaccion.Trama_Pos.Cadena
      ,'NPO');
    l_Dbg_Mensaje := 'Insertar Reversa Traspaso Puntos';
    Scfr_Trx_Puntos_Pk.Setea_Local_Trx(p_Transaccion.Trama_Pos.Local);
    l_Tx_Puntos := Scfr_Trx_Puntos_Pk.Registra_Rtt(p_Party_Id                 => NULL --p_transaccion.trama_boc.party_id
                                                  ,p_Rut_Titular              => p_Transaccion.Rut_Titular
                                                  ,p_Puntos                   => l_Trama_Ta.Puntos
                                                  ,p_Canal                    => 'POS'
                                                  ,p_Codigo_Tx                => l_Codigo_Tx
                                                  ,p_Codigo_Tx_Original       => l_Codigo_Tx_Relacion
                                                  ,p_Empresa                  => p_Transaccion.Trama_Pos.Empresa
                                                  ,p_Cadena                   => p_Transaccion.Trama_Pos.Cadena
                                                  ,p_Fecha                    => To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                                                                        ,'yyyy/mm/dd hh24:mi:ss')
                                                  ,p_Empresa_Destino_Traspaso => l_Trama_Ta.Destino
                                                  ,p_Vendedor                 => p_Transaccion.Trama_Pos.Usuario_Responsable
                                                  ,p_Local                    => p_Transaccion.Trama_Pos.Local
                                                  ,p_Fecha_Venta              => l_Fecha_Tx
                                                  ,p_Local_Venta              => l_Loc_Local
                                                  ,x_Cod_Error                => x_Cod_Error
                                                  ,x_Msg_Error                => x_Msg_Error);
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  PROCEDURE Trama_Pg_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Pg    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pg;
    l_Itm         NUMBER;
    l_Codigo_Tx   NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.trama_pg_resuelve';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Obtener informaci?n de la trama PG (Acumulaci?n programa salud)';
    l_Trama_Pg    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Pg(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje := 'Buscar Rut para Party Id:' || p_Transaccion.Trama_Boc.Party_Id || ' en tabla HZ_PARTIES';
    Scfr_Trx_Fid_Pk.Obtiene_Rut(p_Transaccion.Trama_Boc.Party_Id
                               ,p_Transaccion.Rut_Titular
                               ,p_Transaccion.Dv_Rut_Titular);
    l_Dbg_Mensaje := 'Validar si correlativo TX ' || l_Trama_Pg.Correlativo_Tx || ' existe en tabla SCFR_TMP_TRANSACCIONES';
    BEGIN
      SELECT Codigo_Tx
        INTO l_Codigo_Tx
        FROM Scfr_Tmp_Transacciones
       WHERE Correlativo_Tx = l_Trama_Pg.Correlativo_Tx
         AND Loc_Local = p_Transaccion.Trama_Pos.Local
         AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
         AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena;
    EXCEPTION
      WHEN OTHERS THEN
        l_Codigo_Tx := NULL;
    END;
    IF l_Codigo_Tx IS NULL THEN
      l_Dbg_Mensaje := 'Obtener ID de scfr_mov_transacciones';
      SELECT Scfr_Mov_Transacciones_s.Nextval INTO l_Codigo_Tx FROM Dual;
      l_Dbg_Mensaje := 'Insertar en tabla SCFR_TMP_TRANSACCIONES';
      INSERT INTO Scfr_Tmp_Transacciones
        (Codigo_Tx
        ,Correlativo_Tx
        ,Fecha_Tx
        ,Rut_Titular
        ,Dv_Titular
        ,Pt_Party_Id_Titular
        ,Loc_Local
        ,Emp_Empresa
        ,Cad_Cadena
        ,Pos_Origen)
      VALUES
        (l_Codigo_Tx -- codigo_tx
        ,l_Trama_Pg.Correlativo_Tx -- correlativo_tx
        ,To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                ,'yyyy/mm/dd hh24:mi:ss') -- fecha_tx
        ,p_Transaccion.Rut_Titular -- rut_titular
        ,p_Transaccion.Dv_Rut_Titular -- dv_titular
        ,p_Transaccion.Trama_Boc.Party_Id -- pt_party_id_titular
        ,p_Transaccion.Trama_Pos.Local
        ,p_Transaccion.Trama_Pos.Empresa
        ,p_Transaccion.Trama_Pos.Cadena
        ,'NPO');
    END IF;
    l_Dbg_Mensaje := 'Recorrer detalle de productos';
    FOR l_Itm IN 1 .. l_Trama_Pg.Subtrama_Pg1.Count
    LOOP
      l_Dbg_Mensaje := 'LLamar a SCFR_PPROG_SALUD_PK.puntos_ps';
      Scfr_Pprog_Salud_Pk.Puntos_Ps_Npos(Pfolio             => l_Trama_Pg.Subtrama_Pg1(l_Itm).Folio
                                        ,Pparty_Id          => p_Transaccion.Trama_Boc.Party_Id
                                        ,Puso_Frecuente     => l_Trama_Pg.Subtrama_Pg1(l_Itm).Uso_Frecuente
                                        ,Pcantidad          => l_Trama_Pg.Subtrama_Pg1(l_Itm).Cantidad
                                        ,Pcant_Prog_Salud   => l_Trama_Pg.Subtrama_Pg1(l_Itm).Cantidad_Acumulada_Psalud
                                        ,Prut_Cliente       => p_Transaccion.Rut_Titular
                                        ,Pdv_Rut_Cliente    => p_Transaccion.Dv_Rut_Titular
                                        ,Ptipo_Tx           => 'VEN'
                                        ,Pcanal             => 'POS'
                                        ,Pdetalle_Descuento => l_Trama_Pg.Subtrama_Pg1(l_Itm).Detalle_Descuento_Producto
                                        ,Plocal             => p_Transaccion.Trama_Pos.Local
                                        ,Pcorrelativo_Tx    => l_Trama_Pg.Correlativo_Tx
                                        ,Pcod_Error         => x_Cod_Error
                                        ,Pmsg_Error         => x_Msg_Error);
    END LOOP;
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Trama_Gs_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Gs    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Gs;
    l_Itm         NUMBER;
    l_Codigo_Tx   NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.trama_gs_resuelve';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Obtener informaci?n de la trama GS (Reversa programa salud)';
    l_Trama_Gs    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Gs(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje := 'Buscar Rut para Party Id:' || p_Transaccion.Trama_Boc.Party_Id || ' en tabla HZ_PARTIES';
    Scfr_Trx_Fid_Pk.Obtiene_Rut(p_Transaccion.Trama_Boc.Party_Id
                               ,p_Transaccion.Rut_Titular
                               ,p_Transaccion.Dv_Rut_Titular);
    -- Valida si el correlativo ya existe, podr?haber llegado antes la FIDU53
    l_Dbg_Mensaje := 'Validar si correlativo TX ' || l_Trama_Gs.Correlativo_Tx || ' existe en tabla SCFR_TMP_TRANSACCIONES';
    BEGIN
      SELECT Codigo_Tx
        INTO l_Codigo_Tx
        FROM Scfr_Tmp_Transacciones
       WHERE Correlativo_Tx = l_Trama_Gs.Correlativo_Tx
         AND Loc_Local = p_Transaccion.Trama_Pos.Local
         AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
         AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena;
    EXCEPTION
      WHEN OTHERS THEN
        l_Codigo_Tx := NULL;
    END;
    l_Dbg_Mensaje := 'Obtener ID de scfr_mov_transacciones';
    IF l_Codigo_Tx IS NULL THEN
      SELECT Scfr_Mov_Transacciones_s.Nextval INTO l_Codigo_Tx FROM Dual;
      l_Dbg_Mensaje := 'Insertar en tabla SCFR_TMP_TRANSACCIONES';
      INSERT INTO Scfr_Tmp_Transacciones
        (Codigo_Tx
        ,Correlativo_Tx
        ,Fecha_Tx
        ,Rut_Titular
        ,Dv_Titular
        ,Pt_Party_Id_Titular
        ,Loc_Local
        ,Emp_Empresa
        ,Cad_Cadena
        ,Pos_Origen)
      VALUES
        (l_Codigo_Tx -- codigo_tx
        ,l_Trama_Gs.Correlativo_Tx -- correlativo_tx
        ,To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                ,'yyyy/mm/dd hh24:mi:ss') -- fecha_tx
        ,p_Transaccion.Rut_Titular -- rut_titular
        ,p_Transaccion.Dv_Rut_Titular -- dv_titular
        ,p_Transaccion.Trama_Boc.Party_Id -- pt_party_id_titular
        ,p_Transaccion.Trama_Pos.Local
        ,p_Transaccion.Trama_Pos.Empresa
        ,p_Transaccion.Trama_Pos.Cadena
        ,'NPO');
    END IF;
    l_Dbg_Mensaje := 'Recorrer detalle de productos';
    FOR l_Itm IN 1 .. l_Trama_Gs.Subtrama_Gs1.Count
    LOOP
      l_Dbg_Mensaje := 'LLamar a SCFR_PPROG_SALUD_PK.puntos_ps';
      Scfr_Pprog_Salud_Pk.Puntos_Ps_Npos(Pfolio             => l_Trama_Gs.Subtrama_Gs1(l_Itm).Folio
                                        ,Pparty_Id          => p_Transaccion.Trama_Boc.Party_Id
                                        ,Puso_Frecuente     => l_Trama_Gs.Subtrama_Gs1(l_Itm).Uso_Frecuente
                                        ,Pcantidad          => l_Trama_Gs.Subtrama_Gs1(l_Itm).Cantidad
                                        ,Pcant_Prog_Salud   => l_Trama_Gs.Subtrama_Gs1(l_Itm).Cantidad
                                        ,Prut_Cliente       => p_Transaccion.Rut_Titular
                                        ,Pdv_Rut_Cliente    => p_Transaccion.Dv_Rut_Titular
                                        ,Ptipo_Tx           => 'REV'
                                        ,Pcanal             => 'POS'
                                        ,Pdetalle_Descuento => '00'
                                        ,Plocal             => p_Transaccion.Trama_Pos.Local
                                        ,Pcorrelativo_Tx    => l_Trama_Gs.Correlativo_Tx
                                        ,Pcod_Error         => x_Cod_Error
                                        ,Pmsg_Error         => x_Msg_Error);
    END LOOP;
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  -- Trama_Dp_Prepara
  
  -- ============================================================================
  -- Trama_Dp_Prepara  (version TEST + fallback Inmedical en rama 400/300)
  -- ============================================================================

 FUNCTION Trama_Dp_Prepara(p_Transaccion      IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Id_Consulta_Json OUT NUMBER
                           ,x_Id_Consulta_Json_Nec OUT NUMBER -- JAGC NEC 09/09/2024
                           ,x_Id_Sec_Lotalty   OUT NUMBER
                           ,x_Cod_Error        OUT NUMBER
                           ,x_Msg_Error        OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp IS

    CURSOR c_Grupos_Loyalty(Id_Reg NUMBER) IS
      SELECT t.Id_Con
            ,t.Id
            ,t.Groupid
            ,t.Groupname
            ,t.Value
            ,To_Char(t.Createdate
                    ,'yyyymmddhh24miss') AS Createdate
            ,To_Char(t.Updatedate
                    ,'yyyymmddhh24miss') AS Updatedate
            ,CASE
               WHEN t.Enabled = 1 THEN
                'SI'
               ELSE
                'NO'
             END AS Habilitado
            ,CASE
               WHEN t.Eliminated = 1 THEN
                'SI'
               ELSE
                'NO'
             END AS Eliminado
        FROM Loyalty_Grupo t
       WHERE t.Id_Con = Id_Reg;

    CURSOR c_Programas_Loyalty(Id_Reg NUMBER) IS
      SELECT p.Id_Con
            ,p.Id_Pro
            ,p.Descripcion
            ,To_Char(p.Createdate
                    ,'yyyymmddhh24miss') AS Createdate
            ,To_Char(p.Updatedate
                    ,'yyyymmddhh24miss') AS Updatedate
            ,CASE
               WHEN p.Enable = 1 THEN
                'SI'
               ELSE
                'NO'
             END AS Habilitado
            ,CASE
               WHEN p.Eliminated = 1 THEN
                'SI'
               ELSE
                'NO'
             END AS Eliminado
            ,CASE
               WHEN p.Fromsystem = 1 THEN
                'SI'
               ELSE
                'NO'
             END AS Sistema
            ,p.Name
            ,c.Id_Con AS Id_Con_Currency
            ,c.Id_Pro AS Id_Pro_Currency
            ,c.Id_Currency
            ,c.Name AS Name_Currency
            ,c.Shortname AS Shortname_Currency
            ,c.Descripcion AS Descripcion_Currency
            ,To_Char(c.Createdate
                    ,'yyyymmddhh24miss') AS Createdate_Currency
            ,CASE
               WHEN c.Eleminated = 1 THEN
                'SI'
               ELSE
                'NO'
             END AS Eliminado_Currency
            ,c.State
        FROM Loyalty_Program  p
            ,Loyalty_Currency c
       WHERE p.Id_Con = Id_Reg
         AND c.Id_Con(+) = Id_Reg
         AND c.Id_Con(+) = p.Id_Con
         AND c.Id_Pro = p.Id_Pro;

    -- INI JAGC NEC 20240909
  
    CURSOR c_Cliente_Necesiadad(p_Id_Json NUMBER) IS
      SELECT Jsont.Codigo
            ,Jsont.Mensaje
            ,Jsont.Idcliente
            ,Jsont.Tipoid
            ,Jsont.Nombres
            ,Jsont.Apellidopaterno
            ,Jsont.Apellidomaterno
            ,Jsont.Estadocivil
            ,Jsont.Sexo
            ,Jsont.Direccion
            ,Jsont.Nrodeptocasa
            ,Jsont.Comuna
            ,Jsont.Ciudad
            ,Jsont.Pais
            ,Jsont.Email
            ,Jsont.Telefonofijo
            ,Jsont.Telefonocelular
            ,Jsont.Fechanacimiento
            ,Jsont.Prevision
            ,Jsont.Estado
            ,Jsont.Fechainscripcion
        FROM Consulta_Cliente_Json Jsonc
            ,Json_Table(Respuesta
                       ,'$' Columns(Codigo VARCHAR2(200) Path '$.codigo'
                ,Mensaje VARCHAR2(200) Path '$.mensaje'
                ,Idcliente VARCHAR2(200) Path '$.idCliente'
                ,Tipoid VARCHAR2(200) Path '$.tipoId'
                ,Nombres VARCHAR2(200) Path '$.nombres'
                ,Apellidopaterno VARCHAR2(200) Path '$.apellidoPaterno'
                ,Apellidomaterno VARCHAR2(200) Path '$.apellidoMaterno'
                ,Estadocivil VARCHAR2(200) Path '$.estadoCivil'
                               ,Sexo VARCHAR2(200) Path '$.genero'--'$.sexo' --JAGC NEC 20250522
                ,Direccion VARCHAR2(200) Path '$.direccion'
                ,Nrodeptocasa VARCHAR2(200) Path '$.nroDeptoCasa'
                ,Comuna VARCHAR2(200) Path '$.comuna'
                ,Ciudad VARCHAR2(200) Path '$.ciudad'
                ,Pais VARCHAR2(200) Path '$.pais'
                ,Email VARCHAR2(200) Path '$.email'
                ,Telefonofijo VARCHAR2(200) Path '$.telefonoFijo'
                ,Telefonocelular VARCHAR2(200) Path '$.telefonoCelular'
                ,Fechanacimiento VARCHAR2(200) Path '$.fechaNacimiento'
                ,Prevision VARCHAR2(200) Path '$.prevision'
                ,Estado VARCHAR2(200) Path '$.estado'
                ,Fechainscripcion VARCHAR2(200) Path '$.fechaInscripcion')) AS Jsont
       WHERE Jsonc.Id = p_Id_Json
         AND Rownum = 1
       ORDER BY Id DESC;

    -- FIN JAGC NEC 20240909

    l_Trama_Dp      Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp;
    l_Datos_Cliente Scfr_Trx_Fid_Pk.Rec_Datos_Cliente;
    l_Datos_Cli_Cnv Scfr_Trx_Fid_Pk.Rec_Datos_Cliente;
    l_Cod_Error_Cnv NUMBER;
    l_Msg_Error_Cnv VARCHAR2(2000);
    l_Fecha_Ini     DATE;
    l_Fecha_Ter     DATE;
    c_Fecha_Ini     VARCHAR2(20);
    c_Fecha_Ter     VARCHAR2(20);
    l_Itm           NUMBER;
    l_Itm2          NUMBER;
    l_Itm3          NUMBER;
    Id_r            NUMBER;
    l_Folio         VARCHAR2(20);
    l_Local_Habil   VARCHAR2(2) := 'NO';
    l_Party_Id_Rel  NUMBER;
    l_Id_Relacion   NUMBER;
    l_Origen_Tcv    Scfr_Clientes_Tarjetas_Vm.Tipo_Origen%TYPE;
    l_Rut           Scfr_Mov_Transacciones.Rut_Titular%TYPE;
    l_Dv_Rut        Scfr_Mov_Transacciones.Dv_Titular%TYPE;
    l_Dbg_Proceso   VARCHAR2(100) := 'SCFR_TRX_FID_PK.trama_dp_prepara';
    l_Dbg_Mensaje   VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    l_Puntos_Disponible NUMBER; -- JRG 06/01/2010
    l_Fidelizado_Ant    NUMBER; -- JRG 01/10/2010
    l_Locales_Piloto    VARCHAR2(240);
    l_Es_Maicao         BOOLEAN;

    -- INI JAGC NEC 20240909
    --l_Exento             Scfr_Tmp_Clientes.Exento%TYPE; -- ESG 03/06/2022 Agregar Atributo con valores EXE o AFE
    l_Str_Identificacion      VARCHAR2(100);
    l_Frm_Identificacion      VARCHAR2(10);
    l_Id_Consulta_Json   NUMBER;
    l_Fecha_Nacimiendo   DATE;
    l_Fecha_Inscripcion  DATE;
    l_Inst_Salud         VARCHAR2(3);
    l_Comuna             NUMBER;
    l_Ciudad             NUMBER;
    l_Mediosnotificacion VARCHAR2(30);
    l_Aux_Notificacion   VARCHAR2(100);
    l_Datos_Nc           NUMBER;
    l_Id_Grupo           NUMBER;
    l_Nombre_Grupo       VARCHAR2(100);
    l_Valor_Grupo        VARCHAR2(100);
    l_Tipo_Creacion      VARCHAR2(3);
    rc SYS_REFCURSOR;

    x_Cod_Error_nec      NUMBER;
    l_Valor_Grupo_Club   BOOLEAN;
    
    l_nec_activo VARCHAR2(10);

    l_club_loyalty_str VARCHAR2(4000);
    l_club_loyalty_tab SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST();
    l_valor_grupo_mcv VARCHAR2(100);
    -- FIN JAGC NEC 20240909

    l_Nombre_Paciente    VARCHAR2(200); -- JAGC INMEDICAL 20250423
    l_Tipo_Identificacion_P VARCHAR2(1);
    l_String_Identificacion_P_Original VARCHAR2(150);
    l_Convenio_P            VARCHAR2(50);
    l_Prefijo_Convenio_P    VARCHAR2(3);
    l_Es_Aseguradora_Receta VARCHAR2(1) := 'N';
    -- INI CAMBIO INMEDICAL (nuevas variables)
    l_Es_Inmedical          VARCHAR2(1) := 'N';
    l_Convenio_Inmedical    VARCHAR2(50);
    -- FIN CAMBIO INMEDICAL
  BEGIN

    -- INI JAGC NEC 20240909
    ---------------------------------------------------------------------------
    -- Conserva la identificacion compuesta original para forma P.
    ---------------------------------------------------------------------------
    IF Trim(p_Transaccion.Trama_Boc.Forma_Identificacion) = 'P' THEN
      l_String_Identificacion_P_Original := Trim(p_Transaccion.Trama_Boc.String_Identificacion);
      IF Length(l_String_Identificacion_P_Original) > 16
         AND Substr(l_String_Identificacion_P_Original, 16, 1) IN ('B','F','R','I') THEN
        l_Tipo_Identificacion_P := Substr(l_String_Identificacion_P_Original, 16, 1);
      END IF;
    END IF;

    ---------------------------------------------------------------------------
    -- Determina, para forma P, si es INMEDICAL o si es otro convenio 400/300.
    ---------------------------------------------------------------------------
    IF Trim(p_Transaccion.Trama_Boc.Forma_Identificacion) = 'P' THEN
      BEGIN
        -- INI CAMBIO INMEDICAL (deteccion explicita)
        l_Convenio_P         := To_Char(To_Number(Substr(l_String_Identificacion_P_Original,1,15)));
        l_Prefijo_Convenio_P := Substr(l_Convenio_P, 1, 3);

        -- Numero de convenio Inmedical (parametrizable; fallback 4002150806)
        BEGIN
          SELECT TRIM(Rv_High_Value)
            INTO l_Convenio_Inmedical
            FROM Cg_Ref_Codes
           WHERE Rv_Domain    = 'CONVENIO_INMEDICAL'
             AND Rv_Low_Value = 'NUMERO'
             AND Rownum = 1;
        EXCEPTION
          WHEN OTHERS THEN
            l_Convenio_Inmedical := '4002150806';
        END;
        IF TRIM(l_Convenio_Inmedical) IS NULL THEN
          l_Convenio_Inmedical := '4002150806';
        END IF;

        IF l_Convenio_P = TRIM(l_Convenio_Inmedical) THEN
          l_Es_Inmedical := 'S';
        ELSE
          l_Es_Inmedical := 'N';
        END IF;

        -- Inmedical NUNCA usa el flujo aseguradora; solo los otros 300/400.
        IF l_Es_Inmedical = 'S' THEN
          l_Es_Aseguradora_Receta := 'N';
        ELSIF l_Prefijo_Convenio_P IN ('400', '300') THEN
          l_Es_Aseguradora_Receta := 'S';
        ELSE
          l_Es_Aseguradora_Receta := 'N';
        END IF;

        Dbms_Output.Put_Line('Convenio forma P: '        || l_Convenio_P);
        Dbms_Output.Put_Line('Prefijo convenio forma P: '|| l_Prefijo_Convenio_P);
        Dbms_Output.Put_Line('Es Inmedical: '            || l_Es_Inmedical);
        Dbms_Output.Put_Line('Es Aseguradora Receta: '   || l_Es_Aseguradora_Receta);
        -- FIN CAMBIO INMEDICAL
      EXCEPTION
        WHEN OTHERS THEN
          l_Convenio_P            := NULL;
          l_Prefijo_Convenio_P    := NULL;
          l_Es_Inmedical          := 'N';
          l_Es_Aseguradora_Receta := 'N';
      END;
    END IF;

    rc := Scfr_Necesidades_Salud_Pk.obtener_identificacion(p_Transaccion.Trama_Boc.String_Identificacion, p_Transaccion.Trama_Boc.Forma_Identificacion);
    FETCH rc INTO l_Str_Identificacion, l_Frm_Identificacion;
    -- FIN JAGC NEC 20240909

    l_Dbg_Mensaje := 'Obtener datos del cliente Convenio Empresarial';
    IF (p_Transaccion.Trama_Boc.Forma_Identificacion IN ('N'
                                                        ,'B'
                                                        ,'F'
                                                        ,'I')) THEN
      l_Datos_Cli_Cnv := Scfr_Trx_Conv_Empresarial_Pk.Identificacion_Cliente(p_Transaccion
                                                                            ,x_Id_Consulta_Json
                                                                            ,l_Cod_Error_Cnv
                                                                            ,l_Msg_Error_Cnv);

      --        IF (Nvl(x_Cod_Error
      --               ,0) <> 0) AND
      --           (Nvl(l_Cod_Error_Cnv
      --               ,0) <> 104) THEN
      --          RAISE l_Error_Controlado;
      --        ELS
      IF (Nvl(l_Cod_Error_Cnv
             ,0) = 104) THEN
        l_Datos_Cliente.Forma_Identificacion          := l_Datos_Cli_Cnv.Forma_Identificacion;
        l_Datos_Cliente.String_Identificacion         := l_Datos_Cli_Cnv.String_Identificacion;
        l_Datos_Cliente.Apellido_Paterno              := l_Datos_Cli_Cnv.Apellido_Paterno;
        l_Datos_Cliente.Apellido_Materno              := l_Datos_Cli_Cnv.Apellido_Materno;
        l_Datos_Cliente.Nombres                       := l_Datos_Cli_Cnv.Nombres;
        p_Transaccion.Trama_Boc.Forma_Identificacion  := l_Datos_Cli_Cnv.Forma_Identificacion;
        p_Transaccion.Trama_Boc.String_Identificacion := l_Datos_Cli_Cnv.String_Identificacion;
      END IF;
    ELSIF (p_Transaccion.Trama_Boc.Forma_Identificacion IN ('A')) THEN
      -- Asegurados Online
      l_Datos_Cli_Cnv := Scfr_Trx_Conv_Empresarial_Pk.Abfaseguradora_Consultadatos(p_Transaccion
                                                                                  ,x_Id_Consulta_Json
                                                                                  ,l_Cod_Error_Cnv
                                                                                  ,l_Msg_Error_Cnv);
      IF (Nvl(l_Cod_Error_Cnv
             ,0) = 104) THEN
        l_Datos_Cliente.Nombres := l_Datos_Cli_Cnv.Nombres;
      END IF;
    ELSIF (p_Transaccion.Trama_Boc.Forma_Identificacion IN ('O')) THEN
      -- Asegurados Online
      l_Datos_Cli_Cnv := Scfr_Trx_Conv_Empresarial_Pk.Corpotativo_Consultadatos(p_Transaccion
                                                                               ,x_Id_Consulta_Json
                                                                               ,l_Cod_Error_Cnv
                                                                               ,l_Msg_Error_Cnv);

      Dbms_Output.Put_Line('l_Datos_Cli_Cnv.Forma_Identificacion=> ' || l_Datos_Cli_Cnv.Forma_Identificacion);
      Dbms_Output.Put_Line('l_Datos_Cli_Cnv.String_Identificacion=> ' || l_Datos_Cli_Cnv.String_Identificacion);
      Dbms_Output.Put_Line('l_Cod_Error_Cnv=> ' || l_Cod_Error_Cnv);
      IF (Nvl(l_Cod_Error_Cnv
             ,0) = 104) THEN
        l_Datos_Cliente.Forma_Identificacion          := l_Datos_Cli_Cnv.Forma_Identificacion;
        l_Datos_Cliente.String_Identificacion         := l_Datos_Cli_Cnv.String_Identificacion;
        -- p_Transaccion.Trama_Boc.Forma_Identificacion  := l_Datos_Cli_Cnv.Forma_Identificacion;
        -- p_Transaccion.Trama_Boc.String_Identificacion := l_Datos_Cli_Cnv.String_Identificacion;
        l_Datos_Cliente.Nombres                       := l_Datos_Cli_Cnv.Nombres;

        x_Cod_Error := 0;
      END IF;
    ELSIF (p_Transaccion.Trama_Boc.Forma_Identificacion IN ('M')) THEN
      -- SAM
      l_Datos_Cli_Cnv := Scfr_Trx_Conv_Empresarial_Pk.Sam_consultadatos(p_Transaccion
                                                                               ,x_Id_Consulta_Json
                                                                               ,l_Cod_Error_Cnv
                                                                               ,l_Msg_Error_Cnv);

      Dbms_Output.Put_Line('l_Datos_Cli_Cnv.Forma_Identificacion=> ' || l_Datos_Cli_Cnv.Forma_Identificacion);
      Dbms_Output.Put_Line('l_Datos_Cli_Cnv.String_Identificacion=> ' || l_Datos_Cli_Cnv.String_Identificacion);
      Dbms_Output.Put_Line('l_Cod_Error_Cnv=> ' || l_Cod_Error_Cnv);
      IF (Nvl(l_Cod_Error_Cnv
             ,0) = 104) THEN
        l_Datos_Cliente.Forma_Identificacion          := l_Datos_Cli_Cnv.Forma_Identificacion;
        l_Datos_Cliente.String_Identificacion         := l_Datos_Cli_Cnv.String_Identificacion;
        -- p_Transaccion.Trama_Boc.Forma_Identificacion  := l_Datos_Cli_Cnv.Forma_Identificacion;
        -- p_Transaccion.Trama_Boc.String_Identificacion := l_Datos_Cli_Cnv.String_Identificacion;
        l_Datos_Cliente.Nombres                       := l_Datos_Cli_Cnv.Nombres;

        x_Cod_Error := 0;
      END IF;
    END IF;

    --ini receta electronica
    IF (p_Transaccion.Trama_Boc.Forma_Identificacion = 'P') THEN

      -- INI CAMBIO INMEDICAL
      -- Solo entran al flujo NUEVO de aseguradora receta los convenios 300/400
      -- que NO sean Inmedical. Inmedical (l_Es_Aseguradora_Receta='N') cae al ELSE
      -- que reproduce EXACTAMENTE el flujo ORIGINAL (Loyalty + Valida_Beneficiario_Receta).
      -- FIN CAMBIO INMEDICAL
      IF l_Es_Aseguradora_Receta = 'S' THEN
        -------------------------------------------------------------------------
        -- Convenios 400/300 (NO Inmedical): flujo NUEVO version TEST.
        -------------------------------------------------------------------------
        BEGIN
          Dbms_Output.Put_Line('consulta Recetas Inmedical (400/300): ' || p_Transaccion.Trama_Boc.String_Identificacion);
          l_Nombre_Paciente := Scfr_Trx_Conv_Empresarial_Pk.Valida_Beneficiario_Receta(
                                 p_Transaccion.Trama_Boc.String_Identificacion,
                                 p_Transaccion.Trama_Pos.Local);
          Dbms_Output.Put_Line('Nombre paciente Inmedical: ' || Nvl(l_Nombre_Paciente,'SIN INFORMACION'));
        EXCEPTION
          WHEN OTHERS THEN
            l_Nombre_Paciente := NULL;
            Dbms_Output.Put_Line('No se pudo consultar Inmedical para forma P. Error: ' || Sqlerrm);
        END;

        IF Trim(l_Nombre_Paciente) IS NOT NULL THEN
          l_Datos_Cliente.Nombres          := l_Nombre_Paciente;
          l_Datos_Cliente.Apellido_Paterno := NULL;
          l_Datos_Cliente.Apellido_Materno := NULL;
          x_Id_Sec_Lotalty := NULL;
          x_Cod_Error      := 0;
          x_Msg_Error      := NULL;
        ELSE
          Dbms_Output.Put_Line('Fallback receta aseguradora para convenio: ' || l_Convenio_P);
          l_Datos_Cli_Cnv := Scfr_Trx_Conv_Empresarial_Pk.AbfaseguradoraReceta_consultadatos(
                               p_Transaccion, x_Id_Consulta_Json, l_Cod_Error_Cnv, l_Msg_Error_Cnv);
          IF Nvl(l_Cod_Error_Cnv, 0) = 104 THEN
            l_Datos_Cliente.Forma_Identificacion  := l_Datos_Cli_Cnv.Forma_Identificacion;
            l_Datos_Cliente.String_Identificacion := l_Datos_Cli_Cnv.String_Identificacion;
            l_Datos_Cliente.Apellido_Paterno      := l_Datos_Cli_Cnv.Apellido_Paterno;
            l_Datos_Cliente.Apellido_Materno      := l_Datos_Cli_Cnv.Apellido_Materno;
            l_Datos_Cliente.Nombres               := l_Datos_Cli_Cnv.Nombres;
            x_Cod_Error      := 0;
            x_Msg_Error      := l_Msg_Error_Cnv;
            x_Id_Sec_Lotalty := NULL;
          ELSE
            x_Cod_Error := Nvl(l_Cod_Error_Cnv, 1);
            x_Msg_Error := l_Msg_Error_Cnv;
          END IF;
        END IF;

      ELSE
        -----------------------------------------------------------------------
        -- INMEDICAL y demas P sin prefijo 300/400: FLUJO ORIGINAL EXACTO
        -- (Loyalty + Valida_Beneficiario_Receta). Igual que la funcion original.
        -----------------------------------------------------------------------
        l_Dbg_Mensaje := 'Obtener datos del cliente (Loyalty Maicao)';
        Dbms_Output.Put_Line('consulta LOYALTY: ' || p_Transaccion.Trama_Boc.Forma_Identificacion);
        l_Datos_Cliente := Scfr_Trx_Fid_Pk.Obtiene_Datos_Loyalty(p_Transaccion, x_Id_Sec_Lotalty, x_Cod_Error, x_Msg_Error);

        Dbms_Output.Put_Line('consulta Recetas Inmedical: ' || p_Transaccion.Trama_Boc.String_Identificacion);
        l_Nombre_Paciente := Scfr_Trx_Conv_Empresarial_Pk.Valida_Beneficiario_Receta(
                               p_Transaccion.Trama_Boc.String_Identificacion,
                               p_Transaccion.Trama_Pos.Local);

        -- INI FIX INMEDICAL 20250921
        -- Si la receta valido al beneficiario, Inmedical NO depende de Loyalty
        -- para identificar al paciente. Se traslada el nombre obtenido por receta
        -- a l_Datos_Cliente y se limpia el error que pudo haber devuelto Loyalty
        -- (p.ej. -29266), de modo que la trama DP se arme y sea devuelta al llamador.
        IF Trim(l_Nombre_Paciente) IS NOT NULL THEN
          IF Trim(l_Datos_Cliente.Nombres) IS NULL THEN
            l_Datos_Cliente.Nombres := l_Nombre_Paciente;
          END IF;
          l_Datos_Cliente.Inscrito_Mcv := 'N';
          x_Cod_Error := 0;
          x_Msg_Error := NULL;
        END IF;
        -- FIN FIX INMEDICAL 20250921
      END IF;

    ELSIF (p_Transaccion.Trama_Boc.Forma_Identificacion NOT IN ('A','M')) THEN
      l_Dbg_Mensaje := 'Obtener datos del cliente (Loyalty Maicao)';
      Dbms_Output.Put_Line('consulta LOYALTY: ' || p_Transaccion.Trama_Boc.Forma_Identificacion);
      l_Datos_Cliente := Scfr_Trx_Fid_Pk.Obtiene_Datos_Loyalty(p_Transaccion, x_Id_Sec_Lotalty, x_Cod_Error, x_Msg_Error);
    END IF;
    --fin receta electronica

    IF (Nvl(x_Cod_Error,0) <> 0) THEN
      IF (Nvl(l_Cod_Error_Cnv,0) <> 104) THEN
        IF (p_Transaccion.Trama_Boc.Forma_Identificacion IN ('A')) THEN
          l_Datos_Cli_Cnv := Scfr_Trx_Conv_Empresarial_Pk.Abfaseguradora_Consultadatos(p_Transaccion, x_Id_Consulta_Json, l_Cod_Error_Cnv, l_Msg_Error_Cnv);
          IF (Nvl(l_Cod_Error_Cnv,0) = 104) THEN
            l_Datos_Cliente.Nombres := l_Datos_Cli_Cnv.Nombres;
          END IF;
        ELSIF (p_Transaccion.Trama_Boc.Forma_Identificacion IN ('O')) THEN
          l_Datos_Cli_Cnv := Scfr_Trx_Conv_Empresarial_Pk.Corpotativo_Consultadatos(p_Transaccion, x_Id_Consulta_Json, l_Cod_Error_Cnv, l_Msg_Error_Cnv);
        ELSIF (p_Transaccion.Trama_Boc.Forma_Identificacion IN ('M')) THEN
          l_Datos_Cli_Cnv := Scfr_Trx_Conv_Empresarial_Pk.Sam_consultadatos(p_Transaccion, x_Id_Consulta_Json, l_Cod_Error_Cnv, l_Msg_Error_Cnv);
        ELSE
          IF (p_Transaccion.Trama_Boc.Forma_Identificacion NOT IN ('P')) THEN --F8 JAGC 20241204
            l_Datos_Cli_Cnv := Scfr_Trx_Conv_Empresarial_Pk.Identificacion_Cliente(p_Transaccion, x_Id_Consulta_Json, l_Cod_Error_Cnv, l_Msg_Error_Cnv);
          END IF;
        END IF;
      END IF;
      -- INI CAMBIO INMEDICAL:
      -- El NOT(P AND aseguradora) es igual que en TEST. Para Inmedical
      -- (l_Es_Aseguradora_Receta='N') esta condicion se comporta como el ORIGINAL
      -- (donde l_Cod_Error_Cnv es NULL para P, por lo que este bloque no aplica).
      IF (Nvl(l_Cod_Error_Cnv,0) = 104)
         AND NOT (p_Transaccion.Trama_Boc.Forma_Identificacion = 'P' AND l_Es_Aseguradora_Receta = 'S') THEN
      -- FIN CAMBIO INMEDICAL
        l_Datos_Cliente.Forma_Identificacion          := l_Datos_Cli_Cnv.Forma_Identificacion;
        l_Datos_Cliente.String_Identificacion         := l_Datos_Cli_Cnv.String_Identificacion;
        l_Datos_Cliente.Apellido_Paterno              := l_Datos_Cli_Cnv.Apellido_Paterno;
        l_Datos_Cliente.Apellido_Materno              := l_Datos_Cli_Cnv.Apellido_Materno;
        l_Datos_Cliente.Nombres                       := l_Datos_Cli_Cnv.Nombres;
        p_Transaccion.Trama_Boc.Forma_Identificacion  := l_Datos_Cli_Cnv.Forma_Identificacion;
        p_Transaccion.Trama_Boc.String_Identificacion := l_Datos_Cli_Cnv.String_Identificacion;
        IF (p_Transaccion.Trama_Boc.Forma_Identificacion IN ('P')) THEN
          p_Transaccion.Trama_Boc.Forma_Identificacion  := l_Datos_Cliente.Forma_Identificacion;
          p_Transaccion.Trama_Boc.String_Identificacion := l_Datos_Cliente.String_Identificacion;
        END IF;
        x_Cod_Error := 0;
      END IF;
    ELSE
      -- INI CAMBIO INMEDICAL (misma proteccion que TEST)
      IF (Nvl(l_Cod_Error_Cnv,0) = 104)
         AND NOT (p_Transaccion.Trama_Boc.Forma_Identificacion = 'P' AND l_Es_Aseguradora_Receta = 'S') THEN
      -- FIN CAMBIO INMEDICAL
        l_Datos_Cliente.Forma_Identificacion          := l_Datos_Cli_Cnv.Forma_Identificacion;
        l_Datos_Cliente.String_Identificacion         := l_Datos_Cli_Cnv.String_Identificacion;
        p_Transaccion.Trama_Boc.Forma_Identificacion  := l_Datos_Cli_Cnv.Forma_Identificacion;
        p_Transaccion.Trama_Boc.String_Identificacion := l_Datos_Cli_Cnv.String_Identificacion;
        IF (p_Transaccion.Trama_Boc.Forma_Identificacion IN ('P')) THEN
          p_Transaccion.Trama_Boc.Forma_Identificacion  := l_Datos_Cliente.Forma_Identificacion;
          p_Transaccion.Trama_Boc.String_Identificacion := l_Datos_Cliente.String_Identificacion;
        END IF;
        x_Cod_Error := 0;
      END IF;
    END IF;

    IF (p_Transaccion.Trama_Boc.Forma_Identificacion = 'P') THEN
      -- INI CAMBIO INMEDICAL
      IF l_Es_Inmedical = 'S' THEN
        -------------------------------------------------------------------
        -- INMEDICAL: reproduce EXACTAMENTE el bloque de la funcion ORIGINAL:
        --   p_Transaccion.Trama_Boc.* := l_Datos_Cliente.*  (viene de Loyalty)
        -------------------------------------------------------------------
        p_Transaccion.Trama_Boc.Forma_Identificacion  := l_Datos_Cliente.Forma_Identificacion;
        p_Transaccion.Trama_Boc.String_Identificacion := l_Datos_Cliente.String_Identificacion;
      ELSIF l_Es_Aseguradora_Receta = 'S' THEN
        -- FIN CAMBIO INMEDICAL
        -- 400/300: datos ya vienen de Inmedical o de receta aseguradora (fallback).
        IF Nvl(l_Cod_Error_Cnv, 0) = 104 OR Trim(l_Nombre_Paciente) IS NOT NULL THEN
          IF Trim(l_Datos_Cliente.Nombres) IS NULL THEN
            l_Datos_Cliente.Nombres := 'ASEGURADORA';
          END IF;
          l_Datos_Cliente.Inscrito_Mcv      := 'N';
          l_Datos_Cliente.Folio_Tmcv        := NULL;
          l_Datos_Cliente.Tipo_Creacion     := NULL;
          l_Datos_Cliente.Institucion_Salud := NULL;
          x_Cod_Error := 0;
          Dbms_Output.Put_Line('Nombre final forma P (400/300): ' || Nvl(l_Datos_Cliente.Nombres,'ASEGURADORA'));
          Dbms_Output.Put_Line('Identificacion de facturacion para DP: ' || Nvl(l_Datos_Cliente.String_Identificacion,'SIN INFORMACION'));
        END IF;
      ELSE
        -- Otros convenios P sin prefijo 300/400: flujo P anterior (version TEST).
        l_Datos_Cliente.Forma_Identificacion := p_Transaccion.Trama_Boc.Forma_Identificacion;
        BEGIN
          l_Datos_Cliente.Nombres := Scfr_Trx_Conv_Empresarial_Pk.Datos_Convenio_P_Nombres(
                                       p_Transaccion.Trama_Boc.String_Identificacion, x_Msg_Error);
        EXCEPTION
          WHEN OTHERS THEN
            l_Datos_Cliente.Nombres := NULL;
            Dbms_Output.Put_Line('No se pudo obtener nombre de aseguradora para forma P. Error: ' || Sqlerrm);
        END;
        IF Trim(l_Datos_Cliente.Nombres) IS NULL THEN
          l_Datos_Cliente.Nombres := 'ASEGURADORA';
        END IF;
        l_Datos_Cliente.Apellido_Paterno  := NULL;
        l_Datos_Cliente.Apellido_Materno  := NULL;
        l_Datos_Cliente.Inscrito_Mcv      := 'N';
        l_Datos_Cliente.Folio_Tmcv        := NULL;
        l_Datos_Cliente.Tipo_Creacion     := NULL;
        l_Datos_Cliente.Institucion_Salud := NULL;
        IF Length(Trim(p_Transaccion.Trama_Boc.String_Identificacion)) > 16
           AND Substr(Trim(p_Transaccion.Trama_Boc.String_Identificacion),16,1) IN ('B','F','R','I') THEN
          l_Tipo_Identificacion_P := Substr(Trim(p_Transaccion.Trama_Boc.String_Identificacion),16,1);
          Dbms_Output.Put_Line('Tipo identificacion Prescription: ' || l_Tipo_Identificacion_P);
          l_Datos_Cliente.Forma_Identificacion := l_Tipo_Identificacion_P;
          p_Transaccion.Trama_Boc.String_Identificacion := Substr(Trim(p_Transaccion.Trama_Boc.String_Identificacion),17);
        END IF;
        x_Cod_Error := 0;
        Dbms_Output.Put_Line('Nombre final forma P: ' || Nvl(l_Datos_Cliente.Nombres,'ASEGURADORA'));
        Dbms_Output.Put_Line('Identificacion final forma P: ' || p_Transaccion.Trama_Boc.String_Identificacion);
      END IF;
    END IF;

    DBMS_OUTPUT.PUT_LINE('BOC_TI: ' || p_Transaccion.Trama_Boc.Forma_Identificacion);
    DBMS_OUTPUT.PUT_LINE('BOC_SI: ' || p_Transaccion.Trama_Boc.String_Identificacion);

    l_Rut    := l_Datos_Cliente.Rut;
    l_Dv_Rut := l_Datos_Cliente.Dv_Rut;

    l_Datos_Nc := 0;

    SELECT NVL(Rv_High_Value, '')
      INTO l_nec_activo
      FROM Cg_Ref_Codes
     WHERE Rv_Domain = 'NECESIDADSALUD'
       AND Rv_Low_Value = 'NECESIDADES_ON'
       AND ROWNUM = 1;

    IF (p_Transaccion.Trama_Pos.Origen_Transaccion IN ('NEC','NEU','ONS','TIN')) THEN
      IF (TRIM(l_Frm_Identificacion) IN ('CI','RUC','PAS') AND l_nec_activo = 'SI') THEN
        Scfr_Necesidades_Salud_Pk.Clientes_Pos_Cl(p_Idcliente        => l_Str_Identificacion
                                                 ,p_Tipoid           => l_Frm_Identificacion
                                                 ,p_Empresa          => p_Transaccion.Trama_Pos.Empresa
                                                 ,p_Cadena           => p_Transaccion.Trama_Pos.Cadena
                                                 ,p_Canal            => 'POS'
                                                 ,p_Local            => p_Transaccion.Trama_Pos.Local
                                                 ,p_Id_Consulta_Json => l_Id_Consulta_Json
                                                 ,x_Cod_Error        => x_Cod_Error_nec
                                                 ,x_Msg_Error        => x_Msg_Error);
        IF x_Cod_Error_nec = 0 THEN
          x_Cod_Error := 0;
          l_Datos_Nc := 1;
        END IF;
      END IF;
    END IF;

    IF (l_Datos_Nc = 1) THEN
      Dbms_Output.Put_Line('json=>  ' || l_Id_Consulta_Json);
      FOR r_Cliente_Necesiadad IN c_Cliente_Necesiadad(l_Id_Consulta_Json)
      LOOP
        x_Id_Consulta_Json_Nec      := l_Id_Consulta_Json;
        l_Dbg_Mensaje               := 'Armar trama DP';
        l_Trama_Dp.Apellido_Paterno := r_Cliente_Necesiadad.Apellidopaterno;
        l_Trama_Dp.Apellido_Materno := r_Cliente_Necesiadad.Apellidomaterno;
        l_Trama_Dp.Nombres          := r_Cliente_Necesiadad.Nombres;
        IF Upper(r_Cliente_Necesiadad.Sexo) IN ('MASCULINO','M') THEN
          l_Trama_Dp.Sexo := 'MAS';
        ELSIF Upper(r_Cliente_Necesiadad.Sexo) IN ('FEMENINO','F') THEN
          l_Trama_Dp.Sexo := 'FEM';
        ELSE
          l_Trama_Dp.Sexo := Substr(Upper(r_Cliente_Necesiadad.Sexo),1,3);
        END IF;
        BEGIN
          l_Fecha_Nacimiendo := To_Date(r_Cliente_Necesiadad.Fechanacimiento,'YYYY-MM-DD');
        EXCEPTION WHEN OTHERS THEN l_Fecha_Nacimiendo := NULL; END;
        l_Trama_Dp.Fecha_Nacimiento := Nvl(To_Number(To_Char(l_Fecha_Nacimiendo,'yyyymmdd')),0);
        IF (Upper(r_Cliente_Necesiadad.Estado) IN ('ACTIVO','VIGENTE')) THEN
          l_Trama_Dp.Inscrito_Mas_Cruz_Verde := 'S';
        ELSE
          l_Trama_Dp.Inscrito_Mas_Cruz_Verde := 'N';
        END IF;
        BEGIN
          SELECT Substr(Nvl(TRIM(Rv_High_Value),'MCV'),1,3)
            INTO l_Tipo_Creacion
            FROM Cg_Ref_Codes t
           WHERE Rv_Domain = 'NECESIDADSALUD' AND Rv_Low_Value = 'TIPO CREACION' AND Rownum = 1;
        EXCEPTION WHEN OTHERS THEN l_Tipo_Creacion := 'MCV'; END;
        l_Trama_Dp.Folio_Tarjeta_Mcv := NULL;
        l_Trama_Dp.Tipo_Creacion     := l_Tipo_Creacion;
        BEGIN
          l_Fecha_Inscripcion := To_Date(r_Cliente_Necesiadad.Fechainscripcion,'YYYY-MM-DD');
        EXCEPTION WHEN OTHERS THEN l_Fecha_Inscripcion := To_Date('01-01-1900','DD-MM-YYYY'); END;
        l_Trama_Dp.Fecha_Inscripcion := Nvl(To_Number(To_Char(l_Fecha_Inscripcion,'yyyymmdd')),'19000101');
        l_Dbg_Mensaje                := 'Obtener Direccion Particular';
        l_Trama_Dp.Direccion         := r_Cliente_Necesiadad.Direccion;
        IF TRIM(l_Trama_Dp.Direccion) IS NULL THEN
          l_Trama_Dp.Direccion := 'Sin Direccion';
        END IF;
        BEGIN
          SELECT Codigo INTO l_Comuna FROM Scfrt_Comunas_Ciudades
           WHERE Tipo = 'COMUNA' AND Descripcion = Upper(r_Cliente_Necesiadad.Comuna) AND Rownum = 1;
        EXCEPTION WHEN OTHERS THEN l_Comuna := 0; END;
        BEGIN
          SELECT Codigo INTO l_Ciudad FROM Scfrt_Comunas_Ciudades
           WHERE Tipo = 'CIUDAD' AND Descripcion = Upper(r_Cliente_Necesiadad.Ciudad) AND Rownum = 1;
        EXCEPTION WHEN OTHERS THEN l_Ciudad := 0; END;
        l_Trama_Dp.Comuna := l_Comuna;
        l_Trama_Dp.Ciudad := l_Ciudad;
        IF (Length(TRIM(Upper(r_Cliente_Necesiadad.Prevision))) > 3) THEN
          BEGIN
            SELECT Codigo_Interno_Institucion INTO l_Inst_Salud FROM Scfr_Instituciones_Salud
             WHERE Upper(Nombre_Institucion) = TRIM(Upper(r_Cliente_Necesiadad.Prevision)) AND Rownum = 1;
          EXCEPTION WHEN OTHERS THEN l_Inst_Salud := 'FON'; END;
          l_Trama_Dp.Institucion_Salud := Nvl(l_Inst_Salud,'FON');
        ELSE
          l_Trama_Dp.Institucion_Salud := Nvl(TRIM(Upper(r_Cliente_Necesiadad.Prevision)),'FON');
        END IF;
        l_Dbg_Mensaje                   := 'Obtener Fono, Celular y Correo Electronico';
        l_Trama_Dp.Telefono_Particularc := r_Cliente_Necesiadad.Telefonofijo;
        l_Trama_Dp.Telefono_Celularc    := r_Cliente_Necesiadad.Telefonocelular;
        IF Upper(r_Cliente_Necesiadad.Estadocivil) IN ('SOLTERO','SOL') THEN
          l_Trama_Dp.Estado_Civil := 'SOL';
        ELSIF Upper(r_Cliente_Necesiadad.Estadocivil) IN ('CASODO','CAS') THEN
          l_Trama_Dp.Estado_Civil := 'CAS';
        ELSIF Upper(r_Cliente_Necesiadad.Estadocivil) IN ('VIUDO','VIU') THEN
          l_Trama_Dp.Estado_Civil := 'VIU';
        ELSIF Upper(r_Cliente_Necesiadad.Estadocivil) IN ('UNION','CIV') THEN
          l_Trama_Dp.Estado_Civil := 'CIV';
        ELSE
          l_Trama_Dp.Estado_Civil := Substr(Upper(r_Cliente_Necesiadad.Estadocivil),1,3);
        END IF;
        l_Trama_Dp.Email := r_Cliente_Necesiadad.Email;
      END LOOP;

      BEGIN
        SELECT Upper(Jsont.Medio_1) || '-' || Upper(Jsont.Medio_2) || '-' || Upper(Jsont.Medio_3) || '-' || Upper(Jsont.Medio_4)
          INTO l_Aux_Notificacion
          FROM Consulta_Cliente_Json Jsonc
              ,Json_Table(Respuesta,'$.mediosNotificacion' Columns(
                   Medio_1 VARCHAR2(200) Path '$[0]'
                  ,Medio_2 VARCHAR2(200) Path '$[1]'
                  ,Medio_3 VARCHAR2(200) Path '$[2]'
                  ,Medio_4 VARCHAR2(200) Path '$[3]')) AS Jsont
         WHERE Jsonc.Id = l_Id_Consulta_Json;
        IF (Instr(l_Aux_Notificacion,'WHATSAPP') > 0) OR (Instr(l_Aux_Notificacion,'WSP') > 0) THEN
          l_Mediosnotificacion := 'WSP';
        END IF;
        IF (Instr(l_Aux_Notificacion,'SMS') > 0) THEN
          IF l_Mediosnotificacion IS NULL THEN l_Mediosnotificacion := 'SMS';
          ELSE l_Mediosnotificacion := l_Mediosnotificacion || '-SMS'; END IF;
        END IF;
        IF (Instr(l_Aux_Notificacion,'EMAIL') > 0) OR (Instr(l_Aux_Notificacion,'MAIL') > 0) THEN
          IF l_Mediosnotificacion IS NULL THEN l_Mediosnotificacion := 'MAIL';
          ELSE l_Mediosnotificacion := l_Mediosnotificacion || '-MAIL'; END IF;
        END IF;
      EXCEPTION WHEN OTHERS THEN l_Mediosnotificacion := NULL; END;
      l_Trama_Dp.Medios_Notificacion := l_Mediosnotificacion;

      BEGIN
        SELECT Rv_High_Value, Rv_Abbreviation, Rv_Meaning
          INTO l_Id_Grupo, l_Nombre_Grupo, l_Valor_Grupo
          FROM Cg_Ref_Codes t
         WHERE Rv_Domain = 'NECESIDADSALUD' AND Rv_Low_Value = 'CLUB MCV' AND Rownum = 1;
      EXCEPTION
        WHEN No_Data_Found THEN
          l_Id_Grupo := 1; l_Nombre_Grupo := 'Compra con Beneficio'; l_Valor_Grupo := 'CLUB CRUZ VERDE';
      END;

      l_Itm2 := 1;
      l_Trama_Dp.Subtrama_Dp2(l_Itm2).Id                  := To_Char(l_Id_Grupo);
      l_Trama_Dp.Subtrama_Dp2(l_Itm2).Id_Grupo            := l_Id_Grupo;
      l_Trama_Dp.Subtrama_Dp2(l_Itm2).Nombre_Grupo        := l_Nombre_Grupo;
      l_Trama_Dp.Subtrama_Dp2(l_Itm2).Valor_Grupo         := l_Valor_Grupo;
      l_Trama_Dp.Subtrama_Dp2(l_Itm2).Fecha_Creacion      := To_Char(SYSDATE,'yyyymmddhh24miss');
      l_Trama_Dp.Subtrama_Dp2(l_Itm2).Fecha_Actualizacion := NULL;
      l_Trama_Dp.Subtrama_Dp2(l_Itm2).Habilitado          := 'SI';
      l_Trama_Dp.Subtrama_Dp2(l_Itm2).Eliminado           := 'NO';

    -- INI CAMBIO INMEDICAL
    -- La rama especial de armado de P de la version TEST se limita a los
    -- convenios NUEVOS (NO Inmedical). Asi Inmedical cae al ELSE final, que es
    -- el armado ESTANDAR identico al de la funcion ORIGINAL.
    ELSIF (p_Transaccion.Trama_Boc.Forma_Identificacion IN ('P') AND l_Es_Inmedical = 'N') THEN
    -- FIN CAMBIO INMEDICAL
      -- Para P (no Inmedical) se arma la DP sin depender de las colecciones de Loyalty.
      l_Dbg_Mensaje                       := 'Armar trama DP para forma P';
      l_Trama_Dp.Apellido_Paterno         := l_Datos_Cliente.Apellido_Paterno;
      l_Trama_Dp.Apellido_Materno         := l_Datos_Cliente.Apellido_Materno;
      l_Trama_Dp.Nombres                  := Nvl(l_Datos_Cliente.Nombres, 'ASEGURADORA');
      l_Trama_Dp.Sexo                     := NULL;
      l_Trama_Dp.Fecha_Nacimiento         := 0;
      l_Trama_Dp.Inscrito_Mas_Cruz_Verde  := 'N';
      l_Trama_Dp.Folio_Tarjeta_Mcv        := NULL;
      l_Trama_Dp.Tipo_Creacion            := NULL;
      l_Trama_Dp.Fecha_Hora_Actualizacion := 0;
      l_Trama_Dp.Direccion                := 'Sin Direccion';
      l_Trama_Dp.Comuna                   := 0;
      l_Trama_Dp.Ciudad                   := 0;
      l_Trama_Dp.Fecha_Inscripcion        := '19000101';
      l_Trama_Dp.Institucion_Salud        := NULL;
      l_Trama_Dp.Telefono_Particularc     := 0;
      l_Trama_Dp.Telefono_Celularc        := 0;
      l_Trama_Dp.Email                    := ' ';
      x_Cod_Error                         := 0;

    ELSE
      -- Armado ESTANDAR (identico al ORIGINAL). Aqui cae INMEDICAL (forma P).
      l_Dbg_Mensaje                       := 'Armar trama DP';
      l_Trama_Dp.Apellido_Paterno         := l_Datos_Cliente.Apellido_Paterno;
      l_Trama_Dp.Apellido_Materno         := l_Datos_Cliente.Apellido_Materno;
      l_Trama_Dp.Nombres                  := l_Datos_Cliente.Nombres;
      l_Trama_Dp.Sexo                     := l_Datos_Cliente.Sexo;
      l_Trama_Dp.Fecha_Nacimiento         := Nvl(To_Number(To_Char(l_Datos_Cliente.Fecha_Nacimiento,'yyyymmdd')),0);
      l_Trama_Dp.Inscrito_Mas_Cruz_Verde  := l_Datos_Cliente.Inscrito_Mcv;
      l_Trama_Dp.Folio_Tarjeta_Mcv        := l_Datos_Cliente.Folio_Tmcv;
      l_Trama_Dp.Tipo_Creacion            := l_Datos_Cliente.Tipo_Creacion;
      l_Trama_Dp.Fecha_Hora_Actualizacion := Nvl(To_Number(To_Char(l_Datos_Cliente.Fecha_Ultima_Act,'yyyymmddhh24miss')),0);
      l_Dbg_Mensaje                       := 'Obtener Direccion Particular';
      l_Trama_Dp.Direccion                := ' ';
      l_Trama_Dp.Comuna                   := 0;
      l_Trama_Dp.Ciudad                   := 0;
      l_Trama_Dp.Fecha_Inscripcion        := '19000101';
      l_Trama_Dp.Institucion_Salud        := l_Datos_Cliente.Institucion_Salud;

      FOR l_Itm IN 1 .. l_Datos_Cliente.Direcciones.Count
      LOOP
        IF l_Datos_Cliente.Direcciones(l_Itm).Tipo_Direccion = k_Dir_Particular THEN
          IF Substr(l_Datos_Cliente.Direcciones(l_Itm).Direccion
                   ,Length(l_Datos_Cliente.Direcciones(l_Itm).Direccion),1) = ',' THEN
            l_Trama_Dp.Direccion := Ltrim(Rtrim(Substr(l_Datos_Cliente.Direcciones(l_Itm).Direccion
                                                      ,1
                                                      ,Length(l_Datos_Cliente.Direcciones(l_Itm).Direccion) - 1)));
          ELSE
            l_Trama_Dp.Direccion := l_Datos_Cliente.Direcciones(l_Itm).Direccion;
          END IF;
          l_Trama_Dp.Comuna := l_Datos_Cliente.Direcciones(l_Itm).Comuna;
          l_Trama_Dp.Ciudad := l_Datos_Cliente.Direcciones(l_Itm).Ciudad;
          EXIT;
        END IF;
      END LOOP;
      IF TRIM(l_Trama_Dp.Direccion) IS NULL THEN
        l_Trama_Dp.Direccion := 'Sin Direccion';
      END IF;

      l_Dbg_Mensaje                   := 'Obtener Fono, Celular y Correo Electronico';
      l_Trama_Dp.Telefono_Particularc := 0;
      l_Trama_Dp.Telefono_Celularc    := 0;
      l_Trama_Dp.Email                := ' ';
      FOR l_Itm IN 1 .. l_Datos_Cliente.Contactos.Count
      LOOP
        IF l_Datos_Cliente.Contactos(l_Itm).Tipo_Contacto = 'PHONE' THEN
          IF l_Datos_Cliente.Contactos(l_Itm).Tipo_Fono = 'GEN' THEN
            l_Trama_Dp.Telefono_Particularc := l_Datos_Cliente.Contactos(l_Itm).Numero;
          ELSIF l_Datos_Cliente.Contactos(l_Itm).Tipo_Fono = 'MOBILE' THEN
            l_Trama_Dp.Telefono_Celularc := l_Datos_Cliente.Contactos(l_Itm).Numero;
          END IF;
        ELSIF l_Datos_Cliente.Contactos(l_Itm).Tipo_Contacto = 'EMAIL' THEN
          IF l_Datos_Cliente.Contactos(l_Itm).Primary_By_Purpose = 'Y' THEN
            l_Trama_Dp.Email := l_Datos_Cliente.Contactos(l_Itm).Email;
          END IF;
        END IF;
      END LOOP;
    END IF;

    --//------------------------------------------------------------------------\\
    --// CBR 27/12/2017  BOX AHORRO - Monto Acumulado de Descuentos Club
    --//------------------------------------------------------------------------\\
    l_Trama_Dp.Monto_Acumulado_Club := 0;
    l_Trama_Dp.Decimal_Acum_Club    := 0;

    IF p_Transaccion.Trama_Pos.Origen_Transaccion IN ('BOX','GLO','FEL','CIA','EBD','NEC','NEU','ONS','IPE','MKP','TIN') THEN
      l_Dbg_Mensaje := 'Obtener Monto Acumulado de Descuentos Club';
      BEGIN
        -- busco rango de fechas en Cg_Ref_Code
        SELECT Nvl(t.Rv_Low_Value ,'NULO')
              ,Nvl(t.Rv_High_Value,'NULO')
          INTO c_Fecha_Ini
              ,c_Fecha_Ter
          FROM Cg_Ref_Codes t
         WHERE t.Rv_Domain = 'RANGO_FECHAS_DESCTO_CLUB';

        IF (c_Fecha_Ini = c_Fecha_Ter) AND c_Fecha_Ini IN ('NULO','SYSDATE') THEN
          SELECT To_Char(Add_Months(SYSDATE,-6),'YYYYMM') || '01000000'
                ,To_Char(SYSDATE - 1,'YYYYMM') || '01235959'
            INTO c_Fecha_Ini
                ,c_Fecha_Ter
            FROM Dual;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          SELECT To_Char(Add_Months(SYSDATE,-6),'YYYYMM') || '01000000'
                ,To_Char(SYSDATE - 1,'YYYYMMDD') || '235959'
            INTO c_Fecha_Ini
                ,c_Fecha_Ter
            FROM Dual;
      END;

      -- INI CALCULO ORIGINAL MONTO CLUB (RESTAURADO)
      -- Igual que la funcion de PRODUCCION: SUM sobre Scfr_Mov_Descuentos_Club
      -- cruzando contra trx3.scfr_mov_datos_ventas. Este calculo NO CAMBIA para
      -- ningun convenio (ni Inmedical, ni actuales, ni los nuevos con forma P).
      BEGIN
        SELECT TRUNC(SUM(t.Monto))
               , TO_NUMBER(SUBSTR(TO_CHAR(SUM(t.Monto), 'FM9999990.999999'), INSTR(TO_CHAR(SUM(t.Monto), 'FM9999990.999999'), '.') + 1)) --JAGC 20250702 NEC
          INTO l_Trama_Dp.Monto_Acumulado_Club 
               , l_Trama_Dp.Decimal_Acum_Club--JAGC 20250702 NEC
          FROM Scfr_Mov_Descuentos_Club t
         WHERE Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
           AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
           --AND Rut_Titular = l_Str_Identificacion --JAGC 20250702 NEC
           --INI JAGC 20250702 NEC
           and t.txo_codigo_tx in (
                select 
                    mdv.txo_codigo_tx 
                from 
                    trx3.scfr_mov_datos_ventas mdv 
                where 
                    mdv.fecha_tx > sysdate - 365 
                    and mdv.cliente_factura like '%'||l_Str_Identificacion||'%'
            )
           --FIN JAGC 20250702 NEC
           AND t.Fecha_Tx BETWEEN To_Date(c_Fecha_Ini
                                         ,'YYYYMMDDHH24MISS') AND To_Date(c_Fecha_Ter
                                                                         ,'YYYYMMDDHH24MISS');
      EXCEPTION
        WHEN OTHERS THEN
          l_Trama_Dp.Monto_Acumulado_Club := 0;
          l_Trama_Dp.Decimal_Acum_Club :=0; --JAGC 20250702 NEC
      END;
      -- FIN CALCULO ORIGINAL MONTO CLUB (RESTAURADO)
    END IF;

    l_Trama_Dp.Lista_Atributos := l_Trama_Dp.Subtrama_Dp1.Count;

    --//------------------------------------------------------------------------\\
    --// CBR 14/11/2017  GEOLOYALTY
    --//------------------------------------------------------------------------\\
    BEGIN
      SELECT 'SI' INTO l_Local_Habil
        FROM Scfr_Locales_Loyalty t
       WHERE t.Loc_Local = p_Transaccion.Trama_Pos.Local
         AND t.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
         AND t.Cad_Cadena = p_Transaccion.Trama_Pos.Cadena;
    EXCEPTION WHEN No_Data_Found THEN l_Local_Habil := 'NO'; END;

    l_Local_Habil := 'SI';
    l_Dbg_Mensaje := 'Obtener Existencia de Grupos desde GEOLOYALTY';

    IF l_Itm2 IS NULL OR l_Itm2 = 0 THEN
      l_Itm2 := 1;
    ELSE
      l_Itm2 := l_Itm2 + 1;
    END IF;

    l_Valor_Grupo_Club := FALSE;

    BEGIN
      IF Nvl(x_Id_Sec_Lotalty,-1) > 0 THEN
        FOR r_Loyalty IN c_Grupos_Loyalty(x_Id_Sec_Lotalty)
        LOOP
          l_Trama_Dp.Subtrama_Dp2(l_Itm2).Id                  := TRIM(r_Loyalty.Id);
          l_Trama_Dp.Subtrama_Dp2(l_Itm2).Id_Grupo            := TRIM(r_Loyalty.Groupid);
          l_Trama_Dp.Subtrama_Dp2(l_Itm2).Nombre_Grupo        := TRIM(r_Loyalty.Groupname);
          l_Trama_Dp.Subtrama_Dp2(l_Itm2).Valor_Grupo         := TRIM(r_Loyalty.Value);
          l_Trama_Dp.Subtrama_Dp2(l_Itm2).Fecha_Creacion      := TRIM(r_Loyalty.Createdate);
          l_Trama_Dp.Subtrama_Dp2(l_Itm2).Fecha_Actualizacion := TRIM(r_Loyalty.Updatedate);
          l_Trama_Dp.Subtrama_Dp2(l_Itm2).Habilitado          := TRIM(r_Loyalty.Habilitado);
          l_Trama_Dp.Subtrama_Dp2(l_Itm2).Eliminado           := TRIM(r_Loyalty.Eliminado);

          SELECT NVL(Rv_High_Value, '') INTO l_club_loyalty_str
            FROM Cg_Ref_Codes
           WHERE Rv_Domain = 'NECESIDADSALUD' AND Rv_Low_Value = 'CLUB_MECANICA_LOYALTY' AND ROWNUM = 1;

          FOR i IN 1 .. REGEXP_COUNT(l_club_loyalty_str, '[^'','']+') LOOP
            l_club_loyalty_tab.EXTEND;
            l_club_loyalty_tab(i) := TRIM(REGEXP_SUBSTR(l_club_loyalty_str, '[^'','']+', 1, i));
          END LOOP;

          l_valor_grupo_mcv := l_Trama_Dp.Subtrama_Dp2(l_Itm2).Valor_Grupo;

          FOR i IN 1 .. l_club_loyalty_tab.COUNT LOOP
            IF l_valor_grupo_mcv = l_club_loyalty_tab(i) THEN
              l_Valor_Grupo_Club := TRUE;
              EXIT;
            END IF;
          END LOOP;

          l_Itm2 := l_Itm2 + 1;
        END LOOP;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        Dbms_Output.Put_Line('cliente RUT=>' || Ltrim(Rtrim(p_Transaccion.Trama_Boc.String_Identificacion)) || ' ERROR=>' || l_Dbg_Mensaje);
    END;

    IF l_Valor_Grupo_Club = FALSE THEN
      l_Trama_Dp.Inscrito_Mas_Cruz_Verde := 'N';
    END IF;

    l_Trama_Dp.Lista_Grupos := l_Trama_Dp.Subtrama_Dp2.Count;

    -- INI CAMBIO INMEDICAL
    -- La reescritura final de Trama_Boc (partir string 16/17) de la version TEST
    -- SOLO aplica a los convenios NUEVOS (no Inmedical). Para Inmedical no se toca
    -- aqui, conservando lo que hizo el flujo original mas arriba.
    IF l_Es_Inmedical = 'N'
       AND l_String_Identificacion_P_Original IS NOT NULL
       AND l_Tipo_Identificacion_P IN ('B', 'F', 'R', 'I') THEN
      p_Transaccion.Trama_Boc.Forma_Identificacion  := l_Tipo_Identificacion_P;
      p_Transaccion.Trama_Boc.String_Identificacion := Trim(Substr(l_String_Identificacion_P_Original, 17));
    END IF;
    -- FIN CAMBIO INMEDICAL

    Dbms_Output.Put_Line('Cod ERROR TRAMA DP=>' || x_Cod_Error);

    RETURN l_Trama_Dp;
  EXCEPTION
    WHEN l_Error_Controlado THEN
      IF l_Es_Maicao = TRUE AND x_Cod_Error = 1 THEN
        Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => 'Rut Consultado no existe en Loyalty');
      END IF;
      RETURN NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
      RETURN NULL;
  END;


 /*
  function trama_dc_prepara( p_transaccion in out scfr_trx_dyn_pk.rec_transaccion
                           , x_cod_error   out number
                           , x_msg_error   out varchar2 )
      return             scfr_trx_dyn_types_pk.rec_trama_dc
   is
      l_trama_dc         scfr_trx_dyn_types_pk.rec_trama_dc;

      l_datos_comercia   scfr_trx_fid_pk.rec_datos_comerciales;
      l_datos_direccion  scfr_trx_fid_pk.tab_datos_direccion;
      l_datos_contacto   scfr_trx_fid_pk.tab_datos_contacto;

      l_resultado        number;

      l_DBG_PROCESO      varchar2(100) := 'SCFR_TRX_EXC_PK.FIDC01.trama_dc_prepara';
      l_DBG_MENSAJE      varchar2(250) := 'Error General';
      l_error_controlado exception;

    begin
      l_DBG_MENSAJE    := ' Obtiene datos comerciales Trama DC';
      l_datos_direccion:= scfr_trx_fid_pk.obtiene_direccion_cliente( p_transaccion.trama_boc.party_id
                                                                   , x_cod_error
                                                                   , x_msg_error );
      if nvl(x_cod_error,0)!= 0 then
         raise l_error_controlado;
      end if;

      l_DBG_MENSAJE    := 'Obtener contactos del cliente';
      l_datos_contacto := scfr_trx_fid_pk.obtiene_contacto_cliente( p_transaccion.trama_boc.party_id
                                                                  , x_cod_error
                                                                  , x_msg_error );
      if nvl(x_cod_error,0)!= 0 then
         raise l_error_controlado;
      end if;
      l_datos_comercia:= scfr_trx_fid_pk.obtiene_datos_comerciales( p_transaccion.trama_boc.party_id
                                                                  , l_datos_direccion
                                                                  , l_datos_contacto
                                                                  , x_cod_error
                                                                  , x_msg_error);
      if nvl(x_cod_error,0) != 0 then
         raise l_error_controlado;
      end if;

      l_trama_dc.rut_facturacion             := l_datos_comercia.rut_facturacion      ;
      l_trama_dc.dv_rut_facturacion          := l_datos_comercia.dv_rut_facturacion   ;
      l_trama_dc.party_id                    := l_datos_comercia.party_id             ;
      l_trama_dc.razon_social                := l_datos_comercia.razon_social         ;
      l_trama_dc.nombre_fantasia             := l_datos_comercia.nombre_fantasia      ;
      l_trama_dc.giro                        := l_datos_comercia.giro                 ;
      l_trama_dc.direccion_facturacion       := l_datos_comercia.direccion_factura    ;
      l_trama_dc.comuna_facturacion          := l_datos_comercia.comuna_factura       ;
      l_trama_dc.ciudad_facturacion          := l_datos_comercia.ciudad_factura       ;
      l_trama_dc.direccion_envio_correo      := l_datos_comercia.direccion_correo     ;
      l_trama_dc.comuna_envio_correspondencia:= l_datos_comercia.comuna_correo        ;
      l_trama_dc.ciudad_envio_correspondencia:= l_datos_comercia.ciudad_correo        ;
      l_trama_dc.telefono                    := l_datos_comercia.telefono             ;
      l_trama_dc.fax                         := l_datos_comercia.fax                  ;
      l_trama_dc.email                       := l_datos_comercia.email                ;
      l_DBG_MENSAJE                          := 'Empaqueta trama DC'                  ;
      return (l_trama_dc);
  Exception when l_error_controlado THEN
                 scfr_trx_util_pk.error_msg(l_DBG_PROCESO,l_DBG_MENSAJE);
                 return(null);
            when others then
                 scfr_trx_util_pk.error_msg(l_DBG_PROCESO,l_DBG_MENSAJE);
                 x_cod_error  := sqlcode;
                 x_msg_error  := sqlerrm;
                 return(null);
  End;
  */
  FUNCTION Trama_Ct_Prepara(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ct IS
    CURSOR c_Ptos_Ganados(l_Party_Id       IN NUMBER
                         ,l_Dias_Vcto_Ptos IN NUMBER) IS
      SELECT Pto.Local_Solventa LOCAL
            ,Pto.Numero_Boleta Folio
            ,Pto.Fecha Fecha
            ,'P' Signo
            ,Pto.Ptos_Procesados Puntos
        FROM Scfr_Txs_Puntos Pto
      -- , SCFR_MOV_TRANSACCIONES  trx
       WHERE Pto.Pt_Party_Id = l_Party_Id
         AND Pto.Tipo_Tx_Puntos = 'APG'
         AND Pto.Estado_Registro = 'A'
            --   AND pto.txo_codigo_tx   = trx.codigo_tx
         AND Trunc(Pto.Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
         AND Pto.Tx_Puntos NOT IN (SELECT Txp_Tx_Puntos_Anulacion
                                     FROM Scfr_Txs_Puntos
                                    WHERE Pt_Party_Id = l_Party_Id
                                      AND Tipo_Tx_Puntos = 'RPG')
         AND Pto.Ptos_Procesados > 0;
    CURSOR c_Puntos(l_Rut_Titular    IN NUMBER
                   ,l_Dias_Vcto_Ptos IN NUMBER) IS
      SELECT Pto.Tipo_Tx_Puntos Tipo_Trx
            ,Pto.Local_Solventa LOCAL
            ,Nvl(Pto.Numero_Boleta
                ,9999999) Folio
            ,Nvl(Pto.Fecha
                ,Pto.Fecha) Fecha
            ,Decode(Pto.Ptos_Procesados
                   ,Abs(Pto.Ptos_Procesados)
                   ,'P'
                   ,'N') Signo
            ,Pto.Ptos_Procesados Puntos
        FROM Scfr_Txs_Puntos Pto
      --   , SCFR_MOV_TRANSACCIONES  trx
      --   , SCFR_MOV_DOCUMENTOS_TXS doc
      --       where pto.pt_party_id     = l_party_id
       WHERE Pto.Rut_Titular = l_Rut_Titular
         AND Pto.Tipo_Tx_Puntos IN ('APG'
                                   ,'RPD'
                                   ,'APF'
                                   ,'APG'
                                   ,'RPG'
                                   ,'APH'
                                   ,'RPH'
                                   ,'CAN'
                                   ,'RCA'
                                   ,'TPT'
                                   ,'RTT')
         AND Pto.Estado_Registro = 'A'
            -- AND pto.txo_codigo_tx   = trx.codigo_tx(+)
            --  AND pto.txo_codigo_tx   = doc.txo_codigo_tx(+)
         AND Trunc(Pto.Fecha + l_Dias_Vcto_Ptos) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
       ORDER BY Fecha DESC;
    l_Trama_St       Scfr_Trx_Dyn_Types_Pk.Rec_Trama_St;
    l_Trama_Ct       Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ct;
    l_Datos_Benef    Rec_Datos_Cliente;
    l_Red_Puntos     Scfr_Red_Puntos%ROWTYPE;
    l_Resultado      NUMBER;
    l_Dias_Vcto_Ptos NUMBER;
    l_Dias_Cartola   NUMBER;
    l_Item           NUMBER;
    l_Dbg_Proceso    VARCHAR2(100) := 'SCFR_TRX_FID_PK.FIDC03.trama_ct_prepara';
    l_Dbg_Mensaje    VARCHAR2(250) := 'Error General';
    l_Es_Loyalty     BOOLEAN;
    l_Error_Controlado EXCEPTION;
  BEGIN
    --//--------------------------------------------------------------------------\\
    --// CBR 24/07/2018 20:11                                                     \\
    --// BIFURCAR EMPRESA MAICAO EN GNCC01                                        \\
    --//-----------------------------------------------------------------Inicio---\\
    l_Es_Loyalty := FALSE;
    IF Scfr_Trx_Gnc_Pk.Es_Consulta_Loyalty(p_Transaccion.Trama_Pos.Empresa
                                          ,p_Transaccion.Trama_Pos.Cadena
                                          ,p_Transaccion.Trama_Pos.Local) = 'SI' THEN
      l_Es_Loyalty := TRUE;
    END IF;
    --//-----------------------------------------------------------------Termino--\\

    IF l_Es_Loyalty = FALSE THEN
      Obtiene_Rut(p_Transaccion.Trama_Boc.Party_Id
                 ,p_Transaccion.Rut_Titular
                 ,p_Transaccion.Dv_Rut_Titular);
      l_Dbg_Mensaje    := 'Obtener dias vencimiento puntos (DIVEPU)';
      l_Dias_Vcto_Ptos := Scfr_Trx_Util_Pk.Det_Valor_Parametro_Por_Cod('DIVEPU');
      BEGIN
        l_Dbg_Mensaje  := 'Obtener cantidad dias para cartola puntos (DICAPU)';
        l_Dias_Cartola := Scfr_Trx_Util_Pk.Det_Valor_Parametro_Por_Cod('DICAPU');
      EXCEPTION
        WHEN OTHERS THEN
          l_Dias_Cartola := 0;
      END;
      l_Dbg_Mensaje     := 'Obtener Total puntos disponibles';
      l_Trama_Ct.Puntos := Puntos_Disponibles(NULL
                                             ,p_Transaccion.Rut_Titular
                                             ,'T');
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
      l_Trama_Ct.Signo := 'P';
      IF l_Trama_Ct.Puntos < 0 THEN
        l_Trama_Ct.Signo := 'N';
      END IF;
      l_Dbg_Mensaje := 'Obtener Beneficiario';
      BEGIN
        SELECT *
          INTO l_Red_Puntos
          FROM Scfr_Red_Puntos
         WHERE Pt_Party_Donante = p_Transaccion.Trama_Boc.Party_Id
           AND Rownum = 1;
      EXCEPTION
        WHEN OTHERS THEN
          l_Red_Puntos.Pt_Party_Id := 0;
      END;
      l_Dbg_Mensaje := 'Obtener Datos del Beneficiario para party id =>' || l_Red_Puntos.Pt_Party_Id;
      l_Datos_Benef := Obtiene_Datos_Personales(p_Party_Id  => l_Red_Puntos.Pt_Party_Id
                                               ,p_Empresa   => p_Transaccion.Trama_Pos.Empresa
                                               ,x_Cod_Error => x_Cod_Error
                                               ,x_Msg_Error => x_Msg_Error);
      /*
      if nvl(x_cod_error,0)         != 0 then
        raise l_error_controlado;
      end if;
      */
      /* Se limpian estas variables para generar error en este nivel */
      x_Cod_Error                    := 0;
      x_Msg_Error                    := NULL;
      l_Trama_Ct.Rut_Beneficiario    := Nvl(l_Datos_Benef.Rut
                                           ,0);
      l_Trama_Ct.Dv_Rut_Beneficiario := '0';
      l_Trama_Ct.Nombre              := Substr(Rtrim(l_Datos_Benef.Nombres) || Rtrim(l_Datos_Benef.Apellido_Paterno) ||
                                               Rtrim(l_Datos_Benef.Apellido_Materno)
                                              ,1
                                              ,20);
      l_Dbg_Mensaje                  := 'Obtener Puntos';
      l_Item                         := 1;
      --    for reg in c_puntos( p_transaccion.rut_titular, l_dias_vcto_ptos ) loop
      FOR Reg IN c_Puntos(p_Transaccion.Rut_Titular
                         ,l_Dias_Cartola)
      LOOP
        l_Trama_Ct.Subtrama_Ct1(l_Item).Tipo_Transaccion := Reg.Tipo_Trx;
        l_Trama_Ct.Subtrama_Ct1(l_Item).Local := Reg.Local;
        l_Trama_Ct.Subtrama_Ct1(l_Item).Folio := Reg.Folio;
        l_Trama_Ct.Subtrama_Ct1(l_Item).Fecha := To_Number(To_Char(Reg.Fecha
                                                                  ,'yyyymmdd'));
        l_Trama_Ct.Subtrama_Ct1(l_Item).Signo := Reg.Signo;
        l_Trama_Ct.Subtrama_Ct1(l_Item).Puntos := Reg.Puntos;
        l_Item := l_Item + 1;
      END LOOP;
      l_Trama_Ct.Cantidad_Tx_Puntos := l_Trama_Ct.Subtrama_Ct1.Count;
      IF l_Resultado = 0 THEN
        Obtiene_Rut(p_Transaccion.Trama_Boc.Party_Id
                   ,p_Transaccion.Rut_Titular
                   ,p_Transaccion.Dv_Rut_Titular);
        p_Transaccion.Trama_Boc.Forma_Identificacion  := 'R';
        p_Transaccion.Trama_Boc.String_Identificacion := To_Char(p_Transaccion.Rut_Titular) || p_Transaccion.Dv_Rut_Titular;
      END IF;
    END IF;
    RETURN(l_Trama_Ct);
  EXCEPTION
    WHEN l_Error_Controlado THEN
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

  -- trama DP 
  FUNCTION Trama_Pp_Prepara(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pp IS
    l_Trama_Sp    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Sp;
    l_Trama_Pp    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pp;
    l_Aux         NUMBER;
    l_Largo       NUMBER;
    l_Resultado   NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_EXC_PK.FIDC04.trama_pp_prepara';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Contralado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Obtener informaci?n de la trama SP';
    l_Trama_Sp    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Sp(p_Transaccion.Cuerpo_Tx);
    l_Aux         := 0;
    l_Dbg_Mensaje := 'Verifico Si Existe scfr_mov_transacciones';
    SELECT COUNT(*)
      INTO l_Aux
      FROM Scfr_Mov_Transacciones
     WHERE Correlativo_Tx = l_Trama_Sp.Folio
       AND Loc_Local = l_Trama_Sp.Local;
    IF Nvl(l_Aux
          ,0) > 0 THEN
      BEGIN
        SELECT SUM(Nvl(Smpt.Puntos_Generados
                      ,0))
              ,To_Char(Scmt.Fecha_Tx
                      ,'yyyymmdd')
          INTO l_Trama_Pp.Puntos
              ,l_Trama_Pp.Fecha
          FROM Scfr_Mov_Transacciones Scmt
              ,Scfr_Mov_Productos_Txs Smpt
         WHERE Scmt.Codigo_Tx = Smpt.Txo_Codigo_Tx
           AND Scmt.Correlativo_Tx = l_Trama_Sp.Folio
           AND Scmt.Loc_Local = l_Trama_Sp.Local
         GROUP BY To_Char(Scmt.Fecha_Tx
                         ,'yyyymmdd');
      EXCEPTION
        WHEN OTHERS THEN
          l_Trama_Pp.Puntos := NULL;
          l_Trama_Pp.Fecha  := NULL;
      END;
      RETURN(l_Trama_Pp);
    ELSE
      l_Dbg_Mensaje := 'Retorno nulo no existe';
      RETURN(NULL);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  --
  FUNCTION Trama_Cg_Prepara(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cg IS
    l_Trama_Cs    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cs;
    l_Trama_Cg    Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cg;
    l_Itm         NUMBER;
    l_Party_Id    NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_EXC_PK.trama_cg_prepara';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    CURSOR c_Cupones IS
      SELECT Cup.Codigo_Cupon
            ,Cup.Estado_Cupon
            ,Cup.Cam_Campana
            ,Cup.Cupones
        FROM Scfr_Cupones Cup
       WHERE Cup.Codigo_Cupon = Nvl(l_Trama_Cs.Codigo_Cupon
                                   ,Cup.Codigo_Cupon)
         AND Cup.Pt_Party_Id = Nvl(l_Party_Id
                                  ,Cup.Pt_Party_Id)
         AND Cup.Tipo_Cupon = 'GEN'
         AND Trunc(Cup.Fecha_Vigencia) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
         AND Cup.Estado_Cupon IN ('ACT'
                                 ,'UTI')
         AND Cup.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
         AND Cup.Cad_Cadena = p_Transaccion.Trama_Pos.Cadena;
  BEGIN
    l_Dbg_Mensaje := 'Obtener datos de la trama CS (Cupones)';
    l_Trama_Cs    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Cs(p_Transaccion.Cuerpo_Tx);
    IF Ltrim(Rtrim(l_Trama_Cs.Codigo_Cupon)) = '0' THEN
      l_Trama_Cs.Codigo_Cupon := NULL;
      l_Party_Id              := p_Transaccion.Trama_Boc.Party_Id;
    ELSE
      l_Party_Id := NULL;
    END IF;
    l_Dbg_Mensaje := 'Recorrer detalle de cupones';
    l_Itm         := 0;
    FOR Rec_Cupones IN c_Cupones
    LOOP
      l_Itm         := l_Itm + 1;
      l_Dbg_Mensaje := 'Buscar datos del documento que utilizo el cup?n';
      BEGIN
        SELECT To_Number(To_Char(Mtr.Fecha_Tx
                                ,'yyyymmdd'))
              ,Mdo.Loc_Local
              ,Mdo.Folio
          INTO l_Trama_Cg(l_Itm).Fecha
              ,l_Trama_Cg(l_Itm).Local
              ,l_Trama_Cg(l_Itm).Folio
          FROM Scfr_Mov_Transacciones        Mtr
              ,Scfr_Mov_Documentos_Txs       Mdo
              ,Scfr_Mov_Descuentos_Productos Mdp
         WHERE Mtr.Codigo_Tx = Mdo.Txo_Codigo_Tx
           AND Mdo.Txo_Codigo_Tx = Mdp.Txo_Codigo_Tx
           AND Mdp.Mcu_Codigo_Cupon = Rec_Cupones.Cupones;
      EXCEPTION
        WHEN OTHERS THEN
          l_Trama_Cg(l_Itm).Fecha := NULL;
          l_Trama_Cg(l_Itm).Local := NULL;
          l_Trama_Cg(l_Itm).Folio := NULL;
      END;
      l_Trama_Cg(l_Itm).Codigo_Cupon := Rec_Cupones.Codigo_Cupon;
      l_Trama_Cg(l_Itm).Estado := Rec_Cupones.Estado_Cupon;
      l_Trama_Cg(l_Itm).Campana := Rec_Cupones.Cam_Campana;
    END LOOP;
    RETURN(l_Trama_Cg);
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Setea_Party_Id_Ebso(p_Party_Id_Ebso IN NUMBER) IS
  BEGIN
    g_Party_Id_Ebso := p_Party_Id_Ebso;
  END;

  FUNCTION Obtiene_Party_Id_Ebso RETURN NUMBER IS
  BEGIN
    RETURN Nvl(g_Party_Id_Ebso
              ,0);
  END;

  -- --------------------------------------------------------------------------------
  -- PROCEDURE Crea_Persona
  -- --------------------------------------------------------------------------------
  PROCEDURE Crea_Persona(p_Rut_Cliente       IN NUMBER
                        ,p_Dvr_Cliente       IN VARCHAR2
                        ,p_Datos_Dp          IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp
                        ,p_Empresa           IN NUMBER
                        ,p_Creado_Por        IN VARCHAR2
                        ,p_Crear_Rel_Cliente IN VARCHAR2 DEFAULT 'SI'
                        ,p_Crear_Cuenta      IN VARCHAR2 DEFAULT 'NO'
                        ,p_En_Linea          IN VARCHAR2 DEFAULT 'SI'
                        ,x_Party_Id_Nuevo    OUT NUMBER
                        ,x_Return_Status     OUT VARCHAR2
                        ,x_Msg_Data          OUT VARCHAR2) IS
    l_Sql_Dyn           VARCHAR2(4000);
    l_Sql_Job           VARCHAR2(1000);
    l_Id_Job            NUMBER;
    l_Party_Id_Tmp      NUMBER;
    l_Party_Id_Hz       NUMBER;
    l_Existe_Tmp        NUMBER := 0;
    l_Sqlcode           NUMBER;
    l_Sqlerrm           VARCHAR2(250);
    l_Fecha_Nacim       DATE;
    l_Fecha_Hora_Act    DATE;
    l_Instancia         VARCHAR2(100);
    p_Institucion_Salud VARCHAR2(5);
  BEGIN
    l_Instancia := Ltrim(Rtrim(Scfr_Trx_Util_Pk.Instancia()));
    IF Nvl(p_Datos_Dp.Fecha_Nacimiento
          ,0) > 0 THEN
      l_Fecha_Nacim := To_Date(p_Datos_Dp.Fecha_Nacimiento
                              ,'yyyy/mm/dd');
    ELSE
      l_Fecha_Nacim := NULL;
    END IF;

    --//--------------------------------------------------------------------------\\
    --// CBR 18/05/2016 13:00   Nueva Marca INSTITUCION_SALUD                     \\
    --//-----------------------------------------------------------------Inicio---\\
    BEGIN
      p_Institucion_Salud := Nvl(p_Datos_Dp.Institucion_Salud
                                ,'.....');

      SELECT t.Codigo_Interno_Institucion
        INTO p_Institucion_Salud
        FROM Scfr_Instituciones_Salud t
       WHERE t.Codigo_Interno_Institucion = TRIM(p_Institucion_Salud);
    EXCEPTION
      WHEN OTHERS THEN
        p_Institucion_Salud := NULL;
    END;
    --//-----------------------------------------------------------------Termino--\\
    -- Valida si existe en SCFR_TMP_CLIENTE
    BEGIN
      SELECT Party_Id
            ,1
        INTO l_Party_Id_Tmp
            ,l_Existe_Tmp
        FROM Scfr_Tmp_Clientes
       WHERE Rut = p_Rut_Cliente;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Party_Id_Tmp := 0;
    END;
    -- Valida si existe en HZ_PARTY
    BEGIN
      SELECT Party_Id INTO l_Party_Id_Hz FROM Hz_Parties WHERE Jgzz_Fiscal_Code = To_Char(p_Rut_Cliente);
    EXCEPTION
      WHEN Too_Many_Rows THEN
        BEGIN
          SELECT Party_Id
            INTO l_Party_Id_Hz
            FROM Hz_Parties
           WHERE Jgzz_Fiscal_Code = To_Char(p_Rut_Cliente)
             AND Party_Type = 'PERSON'
             AND Rownum = 1;
        EXCEPTION
          WHEN OTHERS THEN
            l_Party_Id_Hz := 0;
        END;
      WHEN No_Data_Found THEN
        l_Party_Id_Hz := 0;
    END;

    IF (l_Party_Id_Hz > 0) AND
       (l_Party_Id_Tmp = 0) THEN
      -- Crea en la tabla SCFR_TMP_CLIENTES, con datos de al EBR
      l_Party_Id_Tmp := l_Party_Id_Hz;
      --
    ELSIF (l_Party_Id_Tmp = 0) AND
          (l_Party_Id_Hz = 0) THEN

      SELECT Scfr_Tmp_Clientes_s.Nextval INTO l_Party_Id_Tmp FROM Dual;
      --
    ELSIF (l_Party_Id_Tmp <> l_Party_Id_Hz) AND
          (l_Party_Id_Hz > 0) THEN
      UPDATE Scfr_Tmp_Clientes
         SET Party_Id      = l_Party_Id_Hz
            ,Party_Id_Ebso = l_Party_Id_Hz
       WHERE Rut = p_Rut_Cliente;
      l_Party_Id_Tmp := l_Party_Id_Hz;
    END IF;
    x_Party_Id_Nuevo := l_Party_Id_Tmp;
    -- ****************************************************************
    -- registra SIEMPRE el registro NUEVO en tabla temporal de clientes
    -- ****************************************************************
    BEGIN
      IF Nvl(p_Datos_Dp.Fecha_Hora_Actualizacion
            ,0) > 0 THEN
        l_Fecha_Hora_Act := To_Date(p_Datos_Dp.Fecha_Hora_Actualizacion
                                   ,'yyyy/mm/dd hh24:mi:ss');
      ELSE
        l_Fecha_Hora_Act := Scfr_Trx_Util_Pk.Get_Sysdate();
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        l_Fecha_Hora_Act := Scfr_Trx_Util_Pk.Get_Sysdate();
    END;
    l_Fecha_Hora_Act := Scfr_Trx_Util_Pk.Get_Sysdate(); -- JRG Sacar despues

    -- Si no existe en SCFR_TMP_CLIENTES, se crea registro de usuario.
    IF (l_Existe_Tmp = 0) THEN
      -- registro los datos del cliente en tabla temporal
      INSERT INTO Scfr_Tmp_Clientes
        (Party_Id
        ,Rut
        ,Dv
        ,Apellido_Paterno
        ,Apellido_Materno
        ,Nombres
        ,Sexo
        ,Fecha_Nacimiento
        ,Direccion
        ,Comuna
        ,Ciudad
        ,Telefono_Particular
        ,Telefono_Celular
        ,Inscrito_Mas_Cruz_Verde
        ,Folio_Tarjeta_Mcv
        ,Email
        ,Fecha_Hora_Actualizacion
        ,Tipo_Creacion
        ,Empresa
        ,Responsable
        ,Correlativo_Trp
        ,Party_Id_Ebso
        ,Institucion_Salud
        ,Estado)
      VALUES
        (l_Party_Id_Tmp
        ,p_Rut_Cliente
        ,p_Dvr_Cliente
        ,p_Datos_Dp.Apellido_Paterno
        ,p_Datos_Dp.Apellido_Materno
        ,p_Datos_Dp.Nombres
        ,p_Datos_Dp.Sexo
        ,p_Datos_Dp.Fecha_Nacimiento
        ,p_Datos_Dp.Direccion
        ,p_Datos_Dp.Comuna
        ,p_Datos_Dp.Ciudad
        ,p_Datos_Dp.Telefono_Particular
        ,p_Datos_Dp.Telefono_Celular
        ,p_Datos_Dp.Inscrito_Mas_Cruz_Verde
        ,p_Datos_Dp.Folio_Tarjeta_Mcv
        ,p_Datos_Dp.Email
        ,l_Fecha_Hora_Act
        ,p_Datos_Dp.Tipo_Creacion
        ,p_Empresa
        ,p_Creado_Por
        ,Scfr_Trx_Dyn_Pk.Obtiene_Correlativo_Trp()
        ,l_Party_Id_Tmp
        ,p_Institucion_Salud
        ,'PAE');
      -- actualiza snapshot de clientes para que sea reflejado inmediatamente
    ELSE
      UPDATE Scfr_Tmp_Clientes
         SET Apellido_Paterno         = p_Datos_Dp.Apellido_Paterno
            ,Apellido_Materno         = p_Datos_Dp.Apellido_Materno
            ,Nombres                  = p_Datos_Dp.Nombres
            ,Sexo                     = p_Datos_Dp.Sexo
            ,Fecha_Nacimiento         = p_Datos_Dp.Fecha_Nacimiento
            ,Direccion                = p_Datos_Dp.Direccion
            ,Comuna                   = p_Datos_Dp.Comuna
            ,Ciudad                   = p_Datos_Dp.Ciudad
            ,Telefono_Particular      = p_Datos_Dp.Telefono_Particular
            ,Telefono_Celular         = p_Datos_Dp.Telefono_Celular
            ,Inscrito_Mas_Cruz_Verde  = p_Datos_Dp.Inscrito_Mas_Cruz_Verde
            ,Folio_Tarjeta_Mcv        = p_Datos_Dp.Folio_Tarjeta_Mcv
            ,Email                    = p_Datos_Dp.Email
            ,Fecha_Hora_Actualizacion = l_Fecha_Hora_Act
            ,Tipo_Creacion            = p_Datos_Dp.Tipo_Creacion
            ,Empresa                  = p_Empresa
            ,Responsable              = p_Creado_Por
            ,Party_Id_Ebso            = l_Party_Id_Tmp
            ,Correlativo_Trp          = Scfr_Trx_Dyn_Pk.Obtiene_Correlativo_Trp()
            ,Estado                   = 'PAE'
            ,Institucion_Salud        = Nvl(p_Institucion_Salud
                                           ,Institucion_Salud)
       WHERE Party_Id = l_Party_Id_Tmp;
      IF SQL%ROWCOUNT = 0 THEN
        -- registro los datos del cliente en tabla temporal
        INSERT INTO Scfr_Tmp_Clientes
          (Party_Id
          ,Rut
          ,Dv
          ,Apellido_Paterno
          ,Apellido_Materno
          ,Nombres
          ,Sexo
          ,Fecha_Nacimiento
          ,Direccion
          ,Comuna
          ,Ciudad
          ,Telefono_Particular
          ,Telefono_Celular
          ,Inscrito_Mas_Cruz_Verde
          ,Folio_Tarjeta_Mcv
          ,Email
          ,Fecha_Hora_Actualizacion
          ,Tipo_Creacion
          ,Empresa
          ,Responsable
          ,Correlativo_Trp
          ,Party_Id_Ebso
          ,Institucion_Salud
          ,Estado)
        VALUES
          (l_Party_Id_Tmp
          ,p_Rut_Cliente
          ,p_Dvr_Cliente
          ,p_Datos_Dp.Apellido_Paterno
          ,p_Datos_Dp.Apellido_Materno
          ,p_Datos_Dp.Nombres
          ,p_Datos_Dp.Sexo
          ,p_Datos_Dp.Fecha_Nacimiento
          ,p_Datos_Dp.Direccion
          ,p_Datos_Dp.Comuna
          ,p_Datos_Dp.Ciudad
          ,p_Datos_Dp.Telefono_Particular
          ,p_Datos_Dp.Telefono_Celular
          ,p_Datos_Dp.Inscrito_Mas_Cruz_Verde
          ,p_Datos_Dp.Folio_Tarjeta_Mcv
          ,p_Datos_Dp.Email
          ,l_Fecha_Hora_Act
          ,p_Datos_Dp.Tipo_Creacion
          ,p_Empresa
          ,p_Creado_Por
          ,Scfr_Trx_Dyn_Pk.Obtiene_Correlativo_Trp()
          ,l_Party_Id_Tmp
          ,p_Institucion_Salud
          ,'PAE');
      END IF;
    END IF; --if (l_existe_tmp = 0) then
  EXCEPTION
    WHEN OTHERS THEN
      -- chequea si se encontro la rutina referenciada en el sql dinamico
      -- el error -6550 indica que la rutina a ejecutar debe ser definida.
      l_Sqlcode       := SQLCODE;
      l_Sqlerrm       := SQLERRM;
      x_Return_Status := 'E';
      x_Msg_Data      := SQLERRM;

  END;

  -- --------------------------------------------------------------------------------
  -- PROCEDURE Actualiza_Persona
  -- --------------------------------------------------------------------------------
  PROCEDURE Actualiza_Persona(p_Party_Id      IN NUMBER
                             ,p_Rut_Cliente   IN NUMBER
                             ,p_Dvr_Cliente   IN VARCHAR2
                             ,p_Datos_Dp      IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp
                             ,p_Empresa       IN NUMBER
                             ,p_Nombre_Respo  IN VARCHAR2
                             ,p_En_Linea      IN VARCHAR2 DEFAULT 'SI'
                             ,x_Return_Status OUT VARCHAR2
                             ,x_Msg_Data      OUT VARCHAR2) IS
    l_Sql_Dyn           VARCHAR2(8000);
    l_Party_Id_Tmp      NUMBER;
    l_Profile_Id        NUMBER;
    l_Sqlcode           NUMBER;
    l_Sqlerrm           VARCHAR2(250);
    l_Fecha_Nacim       DATE;
    l_Fecha_Hora_Act    DATE;
    l_Instancia         VARCHAR2(100);
    p_Institucion_Salud VARCHAR2(5);
  BEGIN

    Crea_Persona(p_Rut_Cliente       => p_Rut_Cliente
                ,p_Dvr_Cliente       => p_Dvr_Cliente
                ,p_Datos_Dp          => p_Datos_Dp
                ,p_Empresa           => p_Empresa
                ,p_Creado_Por        => p_Nombre_Respo
                ,p_Crear_Rel_Cliente => 'SI'
                ,p_Crear_Cuenta      => 'NO'
                ,p_En_Linea          => 'SI'
                ,x_Party_Id_Nuevo    => l_Party_Id_Tmp
                ,x_Return_Status     => x_Return_Status
                ,x_Msg_Data          => x_Msg_Data);
  END;

  PROCEDURE Crea_Relacion(p_Party_Id_Nuevo IN NUMBER
                         ,p_Empresa        IN NUMBER DEFAULT 86
                         ,x_Party_Id_Rel   OUT NUMBER
                         ,x_Return_Status  OUT VARCHAR2
                         ,x_Msg_Data       OUT VARCHAR2) IS
    l_Sql_Dyn         VARCHAR2(8000);
    l_Sql_Job         VARCHAR2(1000);
    l_Id_Job          NUMBER;
    l_Relationship_Id NUMBER;
    l_Cod_Error       NUMBER;
    l_Msg_Error       VARCHAR2(100);
    l_Sqlcode         NUMBER;
    l_Sqlerrm         VARCHAR2(250);
    l_Instancia       VARCHAR2(100);
  BEGIN
    NULL;
  END;

  PROCEDURE Crea_Relacion(p_Party_Id_Nuevo IN NUMBER
                         ,p_Empresa        IN NUMBER DEFAULT 86
                         ,p_Tipo_Relacion  IN VARCHAR2
                         ,x_Party_Id_Rel   OUT NUMBER
                         ,x_Return_Status  OUT VARCHAR2
                         ,x_Msg_Data       OUT VARCHAR2) IS
    l_Sql_Dyn         VARCHAR2(8000);
    l_Sql_Job         VARCHAR2(1000);
    l_Id_Job          NUMBER;
    l_Relationship_Id NUMBER;
    l_Cod_Error       NUMBER;
    l_Msg_Error       VARCHAR2(100);
    l_Sqlcode         NUMBER;
    l_Sqlerrm         VARCHAR2(250);
    l_Instancia       VARCHAR2(100);
  BEGIN
    NULL;

  END;

  PROCEDURE Actualiza_Relacion(p_Party_Id_Rel  IN NUMBER
                              ,p_Estado        IN VARCHAR2
                              ,p_Fecha_Hasta   IN DATE
                              ,x_Return_Status OUT VARCHAR2
                              ,x_Msg_Data      OUT VARCHAR2) IS
    l_Sql_Dyn         VARCHAR2(8000);
    l_Sql_Job         VARCHAR2(1000);
    l_Id_Job          NUMBER;
    l_Relationship_Id NUMBER;
    l_Cod_Error       NUMBER;
    l_Msg_Error       VARCHAR2(100);
    l_Sqlcode         NUMBER;
    l_Sqlerrm         VARCHAR2(250);
    l_Instancia       VARCHAR2(100);
  BEGIN
    NULL;
  END;

  PROCEDURE Actualiza_Relacion(p_Party_Id_Rel  IN NUMBER
                              ,x_Return_Status OUT VARCHAR2
                              ,x_Msg_Data      OUT VARCHAR2) IS
    l_Sql_Dyn         VARCHAR2(8000);
    l_Sql_Job         VARCHAR2(1000);
    l_Id_Job          NUMBER;
    l_Relationship_Id NUMBER;
    l_Cod_Error       NUMBER;
    l_Msg_Error       VARCHAR2(100);
    l_Sqlcode         NUMBER;
    l_Sqlerrm         VARCHAR2(250);
    l_Instancia       VARCHAR2(100);
  BEGIN
    NULL;
  END;

  PROCEDURE Crea_Punto_Contacto(p_Party_Id_Rel  IN NUMBER
                               ,p_Fono_Partic   IN VARCHAR2
                               ,p_Tipo_Pc       IN VARCHAR2
                               ,p_Tipo_Fono     IN VARCHAR2
                               ,p_Nombre_Respo  IN VARCHAR2
                               ,x_Return_Status OUT VARCHAR2
                               ,x_Msg_Data      OUT VARCHAR2) IS
    l_Sql_Dyn    VARCHAR2(8000);
    l_Sql_Job    VARCHAR2(1000);
    l_Id_Job     NUMBER;
    l_Contact_Id NUMBER;
    l_Cod_Error  NUMBER;
    l_Msg_Error  VARCHAR2(100);
    l_Sqlcode    NUMBER;
    l_Sqlerrm    VARCHAR2(250);
    l_Instancia  VARCHAR2(100);
  BEGIN
    NULL;
  END;

  PROCEDURE Actualiza_Punto_Contacto(p_Contact_Id    IN NUMBER
                                    ,p_Fono_Partic   IN VARCHAR2
                                    ,x_Return_Status OUT VARCHAR2
                                    ,x_Msg_Data      OUT VARCHAR2) IS
    l_Sql_Dyn   VARCHAR2(8000);
    l_Sqlcode   NUMBER;
    l_Sqlerrm   VARCHAR2(250);
    l_Instancia VARCHAR2(100);
  BEGIN
    NULL;
  END;

  PROCEDURE Crea_Direccion(p_Party_Id_Rel  IN NUMBER
                          ,p_Direccion     IN VARCHAR2
                          ,p_Comuna        IN VARCHAR2
                          ,p_Ciudad        IN VARCHAR2
                          ,p_Nombre_Respo  IN VARCHAR2
                          ,x_Return_Status OUT VARCHAR2
                          ,x_Msg_Data      OUT VARCHAR2) IS
    l_Sql_Dyn     VARCHAR2(8000);
    l_Sql_Job     VARCHAR2(1000);
    l_Id_Job      NUMBER;
    l_Site_Id     NUMBER;
    l_Location_Id NUMBER;
    l_Cod_Error   NUMBER;
    l_Msg_Error   VARCHAR2(100);
    l_Region      NUMBER;
    l_Sqlcode     NUMBER;
    l_Sqlerrm     VARCHAR2(250);
    l_Instancia   VARCHAR2(100);
  BEGIN
    NULL;
  END;

  PROCEDURE Actualiza_Direccion(p_Location_Id   IN NUMBER
                               ,p_Direccion     IN VARCHAR2
                               ,p_Comuna        IN VARCHAR2
                               ,p_Ciudad        IN VARCHAR2
                               ,p_Nombre_Respo  IN VARCHAR2
                               ,x_Return_Status OUT VARCHAR2
                               ,x_Msg_Data      OUT VARCHAR2) IS
    l_Sql_Dyn   VARCHAR2(4000);
    l_Sqlcode   NUMBER;
    l_Sqlerrm   VARCHAR2(250);
    l_Instancia VARCHAR2(100);
  BEGIN
    NULL;
  END;

  FUNCTION Busca_Contact_Id_Phone(p_Party_Id_Cliente IN NUMBER
                                 ,p_Tipo_Fono        IN VARCHAR2) RETURN NUMBER IS
    l_Contact_Id NUMBER;
  BEGIN
    Dbms_Output.Put_Line('party_id=>' || p_Party_Id_Cliente);
    Dbms_Output.Put_Line('p_tipo_fono=>' || p_Tipo_Fono);
    SELECT Contact_Point_Id
      INTO l_Contact_Id
      FROM Hz_Contact_Points
     WHERE Owner_Table_Name = 'HZ_PARTIES'
       AND Owner_Table_Id = p_Party_Id_Cliente
       AND Phone_Line_Type = p_Tipo_Fono;
    RETURN l_Contact_Id;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN - 1;
  END;

  FUNCTION Busca_Contact_Id_Email(p_Party_Id_Cliente IN NUMBER) RETURN NUMBER IS
    l_Contact_Id NUMBER;
  BEGIN
    SELECT Contact_Point_Id
      INTO l_Contact_Id
      FROM Hz_Contact_Points
     WHERE Owner_Table_Name = 'HZ_PARTIES'
       AND Owner_Table_Id = p_Party_Id_Cliente
       AND Contact_Point_Type = 'EMAIL';
    RETURN l_Contact_Id;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN - 1;
  END;

  FUNCTION Obtiene_Campana(p_Empresa IN NUMBER
                          ,p_Cadena  IN NUMBER) RETURN NUMBER IS
    l_Campana NUMBER;
  BEGIN
    SELECT Campana
      INTO l_Campana
      FROM Scfr_Campanas
     WHERE Tipo_Campana = 'PTO'
       AND Emp_Codigo = p_Empresa
       AND Cad_Cadena = p_Cadena
       AND SYSDATE BETWEEN Trunc(Fecha_Inicio) AND Fecha_Termino + 1
       AND Rownum = 1;
    RETURN l_Campana;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION Trama_Pu_Prepara(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pu IS
    l_Trama_Pu                  Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pu;
    l_Fecha_Activacion_Donacion DATE;
    l_Fecha_Termino_Donacion    DATE;
    l_Party_Id_Donante          NUMBER;
    l_Puntos_Canje              NUMBER;
    l_Puntos_Regulacion         NUMBER;
    l_Reg_Id_Con                NUMBER;
    l_Es_Loyalty                BOOLEAN;
  BEGIN

    --//--------------------------------------------------------------------------\\
    --// CBR 13/08/2018 10:20                                                     \\
    --// BIFURCAR EMPRESA MAICAO EN GNCC01                                        \\
    --//-----------------------------------------------------------------Inicio---\\
    -- l_Es_Loyalty         BOOLEAN;
    l_Es_Loyalty := FALSE;
    IF Scfr_Trx_Gnc_Pk.Es_Consulta_Loyalty(p_Transaccion.Trama_Pos.Empresa
                                          ,p_Transaccion.Trama_Pos.Cadena
                                          ,p_Transaccion.Trama_Pos.Local) = 'SI' THEN
      l_Es_Loyalty := TRUE;
    END IF;
    --//-----------------------------------------------------------------Termino--\\

    -- 'Obtener valor de dias vencimiento de puntos';
    l_Trama_Pu(1).Vigencia := Scfr_Trx_Util_Pk.Det_Valor_Parametro_Por_Cod('DIVEPU');

    IF l_Es_Loyalty = TRUE THEN

      SELECT MAX(t.Id)
        INTO l_Reg_Id_Con
        FROM Loyalty_Consulta_Rut t
       WHERE TRIM(t.Rut) = TRIM(p_Transaccion.Trama_Boc.String_Identificacion)
         AND t.Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
         AND t.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
         AND t.Loc_Local = p_Transaccion.Trama_Pos.Local;

      -- l_Dbg_Mensaje := 'Buscar Puntos Disponibles Maicao.';

      SELECT SUM(Lp.Disponible_Para_Canje)
        INTO l_Puntos_Canje
        FROM Loyalty_Puntos Lp
       WHERE Lp.Id_Con = l_Reg_Id_Con
         AND Tipo_Tx_Puntos != 'REG'
         AND Trunc(Fecha + l_Trama_Pu(1).Vigencia) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
         AND Estado_Registro = 'A';

      SELECT SUM(Disponible_Para_Canje)
        INTO l_Puntos_Regulacion
        FROM Loyalty_Puntos Lp
       WHERE Lp.Id_Con = l_Reg_Id_Con
         AND Tipo_Tx_Puntos = 'REG';

      l_Trama_Pu(1).Puntos := Nvl(l_Puntos_Canje
                                 ,0) + Nvl(l_Puntos_Regulacion
                                          ,0);
    ELSE
      --    l_Trama_Pu(1).puntos := scfr_trx_fid_pk.puntos_disponibles( p_transaccion.trama_boc.party_id, 'T' );
      l_Trama_Pu(1).Puntos := Scfr_Trx_Fid_Pk.Puntos_Disponibles(NULL
                                                                ,p_Transaccion.Rut_Titular
                                                                ,'T');
    END IF;

    IF l_Trama_Pu(1).Puntos >= 0 THEN
      l_Trama_Pu(1).Signo := 'P';
    ELSE
      l_Trama_Pu(1).Signo := 'N';
    END IF;

    l_Trama_Pu(1).Puntos := Abs(l_Trama_Pu(1).Puntos);

    BEGIN
      SELECT Fecha_Activacion_Donacion
            ,Fecha_Termino_Donacion
            ,Pt_Party_Donante
        INTO l_Fecha_Activacion_Donacion
            ,l_Fecha_Termino_Donacion
            ,l_Party_Id_Donante
        FROM Scfr_Red_Puntos
       WHERE Pt_Party_Id = p_Transaccion.Trama_Boc.Party_Id;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Fecha_Activacion_Donacion := NULL;
        l_Fecha_Termino_Donacion    := NULL;
        l_Party_Id_Donante          := NULL;
    END;
    l_Trama_Pu(1).Donacion_Vigente := 'N';
    IF l_Fecha_Activacion_Donacion IS NOT NULL OR
       l_Fecha_Termino_Donacion IS NOT NULL THEN
      IF Trunc(Nvl(l_Fecha_Activacion_Donacion
                  ,Scfr_Trx_Util_Pk.Get_Sysdate())) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) AND
         Trunc(Nvl(l_Fecha_Termino_Donacion
                  ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) THEN
        l_Trama_Pu(1).Donacion_Vigente := 'S';
      END IF;
    END IF;
    BEGIN
      SELECT Jgzz_Fiscal_Code
            ,Scfr_Trx_Util_Pk.Dv_Rut(Jgzz_Fiscal_Code)
            ,Substr(Person_First_Name || ' ' || Person_Last_Name || ' ' || Person_Middle_Name
                   ,1
                   ,20)
        INTO l_Trama_Pu(1).Rut_Beneficiario
            ,l_Trama_Pu(1).Dv_Rut_Beneficiario
            ,l_Trama_Pu(1).Nombre
        FROM Hz_Parties
       WHERE Party_Id = l_Party_Id_Donante;
    EXCEPTION
      WHEN OTHERS THEN
        l_Trama_Pu(1).Rut_Beneficiario := NULL;
        l_Trama_Pu(1).Dv_Rut_Beneficiario := NULL;
        l_Trama_Pu(1).Nombre := NULL;
    END;

    --//--------------------------------------------------------------------------\\
    --// CBR 11/09/2018 09/11/2018 12:05                                          \\
    --// PUNTOS POR VENCER GEOLOYALTY LOCALES MAICAO                              \\
    --//-----------------------------------------------------------------Inicio---\\
    IF l_Es_Loyalty = TRUE THEN

      SELECT Lp.Ptos_Procesados
            ,Lp.Fecha
        INTO l_Puntos_Canje
            ,l_Fecha_Termino_Donacion -- solo se reutilizan variables
        FROM Loyalty_Puntos Lp
       WHERE Lp.Id_Con = l_Reg_Id_Con -- solo se reutiliza variable
         AND Tipo_Tx_Puntos != 'REG'
         AND Trunc(Fecha + l_Trama_Pu(1).Vigencia) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
         AND Estado_Registro = 'A';

      IF l_Puntos_Canje >= 0 THEN
        l_Trama_Pu(2).Signo := 'P';
      ELSE
        l_Trama_Pu(2).Signo := 'N';
      END IF;
      l_Trama_Pu(2).Puntos := l_Puntos_Canje;
      l_Trama_Pu(2).Donacion_Vigente := NULL;
      l_Trama_Pu(2).Rut_Beneficiario := l_Trama_Pu(1).Rut_Beneficiario;
      l_Trama_Pu(2).Dv_Rut_Beneficiario := l_Trama_Pu(1).Dv_Rut_Beneficiario;
      l_Trama_Pu(2).Nombre := l_Trama_Pu(1).Nombre;
      l_Trama_Pu(2).Fecha_Inicio := NULL;
      l_Trama_Pu(2).Fecha_Termino := To_Number(To_Char(l_Fecha_Termino_Donacion
                                                      ,'yyyymmdd'));
      l_Trama_Pu(2).Vigencia := NULL;
    END IF;
    --//-----------------------------------------------------------------Termino--\\

    RETURN l_Trama_Pu;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_Trama_Pu;
  END;

  FUNCTION Obtiene_Dia_Semana RETURN VARCHAR2 IS
    l_Dia VARCHAR2(20);
  BEGIN
    l_Dia := Upper(Substr(To_Char(Scfr_Trx_Util_Pk.Get_Sysdate()
                                 ,'DAY'
                                 ,'NLS_DATE_LANGUAGE = SPANISH')
                         ,1
                         ,3));
    IF l_Dia = 'MI' || Chr(50057) THEN
      l_Dia := 'MIE';
    ELSIF l_Dia = 'S' || Chr(50049) || 'B' THEN
      l_Dia := 'SAB';
    END IF;
    RETURN l_Dia;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ' ';
  END;

  FUNCTION Esta_En_Tramo_Horario(p_Campana IN NUMBER) RETURN BOOLEAN IS
    l_Total NUMBER;
    l_Dia   VARCHAR2(3);
  BEGIN
    -- Filtrar por condici?n de tramo horario
    l_Dia := Obtiene_Dia_Semana();
    SELECT COUNT(*) INTO l_Total FROM Scfr_Tramos_Horarios WHERE Cam_Campana = p_Campana;
    IF l_Total > 0 THEN
      SELECT COUNT(*)
        INTO l_Total
        FROM Scfr_Tramos_Horarios
       WHERE Cam_Campana = p_Campana
         AND Dia_Semana = l_Dia
         AND To_Char(Scfr_Trx_Util_Pk.Get_Sysdate()
                    ,'hh24miss') BETWEEN To_Char(Hora_Inicial
                                                ,'hh24miss') AND To_Char(Hora_Final
                                                                        ,'hh24miss');
      IF l_Total = 1 THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    ELSE
      RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END;

  FUNCTION Esta_En_Zona(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                       ,p_Campana     IN NUMBER) RETURN BOOLEAN IS
    l_Total NUMBER;
  BEGIN
    -- Filtrar por condici?n de zona
    SELECT COUNT(*) INTO l_Total FROM Scfr_Campanas_Zonas WHERE Cam_Campana = p_Campana;
    IF l_Total != 0 THEN
      SELECT COUNT(*)
        INTO l_Total
        FROM Scfr_Campanas_Zonas
       WHERE Cam_Campana = p_Campana
         AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
         AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
         AND Loc_Local = p_Transaccion.Trama_Pos.Local;
      IF l_Total = 1 THEN
        RETURN TRUE;
      ELSE
        BEGIN
          SELECT COUNT(*)
            INTO l_Total
            FROM Scfr_Campanas_Zonas Cazo
                ,Scfr_Zonas          Zona
                ,Scfr_Zonas_Locales  Zolo
           WHERE Cazo.Sze_Secuencia_Zona = Zona.Secuencia_Zona
             AND Zona.Secuencia_Zona = Zolo.Sze_Secuencia_Zona
             AND Cazo.Cam_Campana = p_Campana
             AND Zolo.Loc_Local = p_Transaccion.Trama_Pos.Local;
        EXCEPTION
          WHEN OTHERS THEN
            l_Total := 0;
        END;
        IF l_Total = 1 THEN
          RETURN TRUE;
        ELSE
          RETURN FALSE;
        END IF;
      END IF;
    ELSE
      RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END;

  FUNCTION Ms_Esta_En_Zona(p_Empresa IN NUMBER
                          ,p_Cadena  IN NUMBER
                          ,p_Local   IN NUMBER
                          ,p_Campana IN NUMBER) RETURN NUMBER IS
    l_Total NUMBER;
  BEGIN
    -- Filtrar por condici?n de zona
    SELECT COUNT(*) INTO l_Total FROM Scfr_Campanas_Zonas WHERE Cam_Campana = p_Campana;
    IF l_Total != 0 THEN
      SELECT COUNT(*)
        INTO l_Total
        FROM Scfr_Campanas_Zonas
       WHERE Cam_Campana = p_Campana
         AND Emp_Empresa = p_Empresa
         AND Cad_Cadena = p_Cadena
         AND Loc_Local = p_Local;
      IF l_Total = 1 THEN
        RETURN 1;
      ELSE
        BEGIN
          SELECT COUNT(*)
            INTO l_Total
            FROM Scfr_Campanas_Zonas Cazo
                ,Scfr_Zonas          Zona
                ,Scfr_Zonas_Locales  Zolo
           WHERE Cazo.Sze_Secuencia_Zona = Zona.Secuencia_Zona
             AND Zona.Secuencia_Zona = Zolo.Sze_Secuencia_Zona
             AND Cazo.Cam_Campana = p_Campana
             AND Zolo.Loc_Local = p_Local;
        EXCEPTION
          WHEN OTHERS THEN
            l_Total := 0;
        END;
        IF l_Total = 1 THEN
          RETURN 1;
        ELSE
          RETURN 0;
        END IF;
      END IF;
    ELSE
      RETURN 1;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  PROCEDURE Obtener_Fechas_Cam(p_Campana       IN NUMBER
                              ,p_Rut           IN NUMBER
                              ,p_Periodicidad  IN NUMBER
                              ,p_Fecha_Consumo IN DATE
                              ,x_Fecha_Ini     OUT DATE) IS
    l_Tipo_Aplicacion  VARCHAR2(1) := Substr(Ltrim(To_Char(p_Periodicidad))
                                            ,1
                                            ,1);
    l_Periodicidad     VARCHAR2(3) := Substr(Ltrim(To_Char(p_Periodicidad))
                                            ,2
                                            ,3);
    k_Anual            VARCHAR2(3) := '365';
    k_Mensual          VARCHAR2(3) := '030';
    k_Semanal          VARCHAR2(3) := '007';
    k_Diaria           VARCHAR2(3) := '001';
    k_Transaccion      VARCHAR2(3) := '998';
    k_Campana          VARCHAR2(3) := '999';
    k_Tipo_Calendario  VARCHAR2(1) := '1';
    k_Tipo_Primera     VARCHAR2(1) := '2';
    l_Fecha_Inicio_Cam DATE;
    l_Dia_Inicio       NUMBER;
    l_Mes_Inicio       NUMBER;
    l_Ano_Inicio       NUMBER;
    l_Dia_Consumo      NUMBER;
    l_Mes_Consumo      NUMBER;
    l_Ano_Consumo      NUMBER;
    l_Mes_Final        VARCHAR2(30);
    l_Ano_Final        VARCHAR2(30);
    l_Dia              VARCHAR2(3);
    l_Aux              NUMBER;
    l_Cont             NUMBER;
    l_Dia_n            NUMBER;
  BEGIN
    -- Para la periodicidad diaria se devuelve el mismo dia pero hora 00:00:00
    -- Para la periodicidad transaccion se devuelve un dia despues del consumo,
    --  ya que el calculo devolvera no_rows y por lo tanto entregara el saldo de la campa?a
    IF l_Periodicidad = k_Diaria THEN
      -- Diaria / Transaccion / Campa?a
      x_Fecha_Ini := To_Date(To_Char(SYSDATE
                                    ,'ddmmyyyy') || '000000'
                            ,'ddmmyyyyhh24miss');
    ELSIF l_Periodicidad = k_Transaccion THEN
      x_Fecha_Ini := SYSDATE + 1;
    ELSE
      IF l_Tipo_Aplicacion = k_Tipo_Calendario THEN
        -- Calendario
        -- Determinar inicio de la campa?a
        BEGIN
          SELECT Fecha_Inicio INTO l_Fecha_Inicio_Cam FROM Scfr_Campanas WHERE Campana = p_Campana;
        EXCEPTION
          WHEN OTHERS THEN
            l_Fecha_Inicio_Cam := NULL;
        END;
        IF l_Periodicidad = k_Anual THEN
          -- A?o
          -- Se retorna SIEMPRE el 01/01 del a?o del consumo
          x_Fecha_Ini := To_Date('0101' || To_Char(p_Fecha_Consumo
                                                  ,'yyyy') || '000000'
                                ,'ddmmyyyyhh24miss');
        ELSIF l_Periodicidad = k_Mensual THEN
          -- Mes
          -- Se retorna SIEMPRE el 01 del mes y a?o del consumo
          x_Fecha_Ini := To_Date('01' || To_Char(p_Fecha_Consumo
                                                ,'mmyyyy') || '000000'
                                ,'ddmmyyyyhh24miss');
        ELSIF l_Periodicidad = k_Semanal THEN
          -- Semana
          -- Se retorna SIEMPRE el LUNES anterior al consumo
          SELECT To_Date(To_Char(Trunc(Next_Day(SYSDATE - 7
                                               ,'LUN'))
                                ,'ddmmyyyy') || '000000'
                        ,'ddmmyyyyhh24miss')
            INTO x_Fecha_Ini
            FROM Dual;
        ELSIF l_Periodicidad = k_Campana THEN
          -- Semana
          -- Se retorna SIEMPRE la fecha inicio de la campa?a
          x_Fecha_Ini := l_Fecha_Inicio_Cam;
        END IF; -- periodicidad (calendario)
        -- En caso de que la fecha a retornar fuese menor a la fecha de inicio de la campa?a
        -- entonces se devuelve esta ultima fecha
        IF l_Fecha_Inicio_Cam > x_Fecha_Ini THEN
          x_Fecha_Ini := l_Fecha_Inicio_Cam;
        END IF;
      ELSIF l_Tipo_Aplicacion = k_Tipo_Primera THEN
        -- Primera Compra
        -- Determinar fecha primera compra
        BEGIN
          SELECT MIN(Fecha_Hora_Movimiento)
            INTO l_Fecha_Inicio_Cam
            FROM Scfr_Cuenta_Cte_Descuentos
           WHERE Rut = p_Rut
             AND Campana = p_Campana;
        EXCEPTION
          WHEN OTHERS THEN
            l_Fecha_Inicio_Cam := NULL;
        END;
        IF l_Fecha_Inicio_Cam IS NOT NULL THEN
          l_Dia_Inicio  := To_Number(To_Char(l_Fecha_Inicio_Cam
                                            ,'dd'));
          l_Mes_Inicio  := To_Number(To_Char(l_Fecha_Inicio_Cam
                                            ,'mm'));
          l_Ano_Inicio  := To_Number(To_Char(l_Fecha_Inicio_Cam
                                            ,'yyyy'));
          l_Dia_Consumo := To_Number(To_Char(p_Fecha_Consumo
                                            ,'dd'));
          l_Mes_Consumo := To_Number(To_Char(p_Fecha_Consumo
                                            ,'mm'));
          l_Ano_Consumo := To_Number(To_Char(p_Fecha_Consumo
                                            ,'yyyy'));
          IF l_Periodicidad = k_Anual THEN
            -- A?o
            IF l_Ano_Inicio = l_Ano_Consumo THEN
              x_Fecha_Ini := To_Date(To_Char(l_Fecha_Inicio_Cam
                                            ,'ddmmyyyyhh24miss')
                                    ,'ddmmyyyyhh24miss');
            ELSIF l_Ano_Inicio < l_Ano_Consumo THEN
              IF l_Mes_Consumo < l_Mes_Inicio THEN
                x_Fecha_Ini := l_Fecha_Inicio_Cam;
              ELSIF l_Mes_Consumo = l_Mes_Inicio THEN
                IF l_Dia_Consumo < l_Dia_Inicio THEN
                  x_Fecha_Ini := l_Fecha_Inicio_Cam;
                ELSE
                  x_Fecha_Ini := To_Date(Ltrim(To_Char(l_Dia_Inicio
                                                      ,'00')) || Ltrim(To_Char(l_Mes_Inicio
                                                                              ,'00')) ||
                                         Ltrim(To_Char(l_Ano_Consumo
                                                      ,'0000')) || '000000'
                                        ,'ddmmyyyyhh24miss');
                END IF;
              ELSE
                x_Fecha_Ini := To_Date(Ltrim(To_Char(l_Dia_Inicio
                                                    ,'00')) || Ltrim(To_Char(l_Mes_Inicio
                                                                            ,'00')) ||
                                       Ltrim(To_Char(l_Ano_Consumo
                                                    ,'0000')) || '000000'
                                      ,'ddmmyyyyhh24miss');
              END IF;
            END IF;
          ELSIF l_Periodicidad = k_Mensual THEN
            -- Mes
            IF l_Mes_Consumo > 1 THEN
              IF l_Dia_Consumo >= 1 AND
                 l_Dia_Consumo <= l_Dia_Inicio - 1 THEN
                l_Mes_Final := Ltrim(To_Char(l_Mes_Consumo - 1
                                            ,'00'));
              ELSE
                l_Mes_Final := Ltrim(To_Char(l_Mes_Consumo
                                            ,'00'));
              END IF;
              l_Ano_Final := Ltrim(To_Char(l_Ano_Consumo
                                          ,'0000'));
            ELSE
              l_Mes_Final := '12';
              l_Ano_Final := Ltrim(To_Char(l_Ano_Consumo - 1
                                          ,'0000'));
            END IF;
            IF l_Mes_Final = '02' THEN
              IF l_Dia_Inicio > 28 THEN
                l_Dia_Inicio := 28;
              END IF;
            END IF;
            IF l_Mes_Final IN ('04'
                              ,'06'
                              ,'09'
                              ,'11') THEN
              IF l_Dia_Inicio = 31 THEN
                l_Dia_Inicio := 30;
              END IF;
            END IF;
            x_Fecha_Ini := To_Date(Ltrim(To_Char(l_Dia_Inicio
                                                ,'00')) || l_Mes_Final || l_Ano_Final || '000000'
                                  ,'ddmmyyyyhh24miss');
          ELSIF l_Periodicidad = k_Semanal THEN
            -- Semana
            l_Dia := To_Char(l_Fecha_Inicio_Cam
                            ,'DAY'
                            ,'NLS_DATE_LANGUAGE = SPANISH');
            SELECT To_Date(To_Char(Trunc(Next_Day(SYSDATE - 7
                                                 ,l_Dia))
                                  ,'ddmmyyyy') || '000000'
                          ,'ddmmyyyyhh24miss')
              INTO x_Fecha_Ini
              FROM Dual;
          ELSE
            BEGIN
              l_Dia_n := p_Fecha_Consumo - l_Fecha_Inicio_Cam;
              l_Cont  := l_Dia_n;
              WHILE l_Cont > 0
              LOOP
                l_Aux := MOD(l_Cont
                            ,To_Number(l_Periodicidad));
                IF l_Aux = 0 THEN
                  EXIT;
                END IF;
                l_Cont := l_Cont - 1;
              END LOOP;
              x_Fecha_Ini := To_Date(To_Char(l_Fecha_Inicio_Cam + l_Cont
                                            ,'ddmmyyyy') || '000000'
                                    ,'ddmmyyyyhh24miss');
            END;
          END IF; -- periodicidad (primera compra)
        ELSE
          -- Si la fecha primera compra es nula se devuelve el dia sgte al consumo
          -- para obligar a retornar el tope maximo de la campa?a
          x_Fecha_Ini := SYSDATE + 1;
        END IF;
      END IF; -- tipo de aplicacion
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_Fecha_Ini := SYSDATE;
  END Obtener_Fechas_Cam;

  FUNCTION Devuelve_Saldo_Descuento(p_Campana  IN NUMBER
                                   ,p_Party_Id IN NUMBER
                                   ,p_Fecha_Tx IN DATE) RETURN NUMBER IS
    l_Saldo_Descuento         NUMBER;
    l_Aux                     NUMBER := 0;
    l_Controla_Tope_Descuento Scfr_Campanas.Controla_Tope_Descuento%TYPE;
    l_Dbg_Proceso             VARCHAR2(100) := 'SCFR_TRX_FID_PK.obtiene_saldo_descuento()';
    l_Dbg_Mensaje             VARCHAR2(250) := 'Error general';
    e_Salir EXCEPTION;
    l_Rut           VARCHAR2(20);
    l_Dv_Rut        VARCHAR2(1);
    l_Fecha_Inicio  DATE;
    l_Periodicidad  NUMBER;
    l_Fecha_Ini     DATE;
    l_Saldo_Campana NUMBER;
  BEGIN
    l_Dbg_Mensaje := 'Determinar si la campa?a Controla Tope Descuentos';
    BEGIN
      SELECT Nvl(Controla_Tope_Descuento
                ,'NO')
        INTO l_Controla_Tope_Descuento
        FROM Scfr_Campanas
       WHERE Campana = p_Campana;
      IF l_Controla_Tope_Descuento = 'NO' THEN
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => 'La Campa?a ' || p_Campana || ' No Controla Tope de Descuento');
        RETURN 9999999;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => 'Problemas al intentar determinar si la Campa?a ' || p_Campana || ' Controla Tope de Descuento' ||
                                                SQLERRM);
        l_Aux := 0;
        RAISE e_Salir;
    END;
    l_Dbg_Mensaje := 'Obtener el rut a partir del party_id del cliente';
    /*
    BEGIN
      SELECT jgzz_fiscal_code
        INTO l_rut
        FROM hz_parties
       WHERE party_id = p_party_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_rut := NULL;
    END;
    */
    Obtiene_Rut(p_Party_Id
               ,l_Rut
               ,l_Dv_Rut);
    l_Dbg_Mensaje := 'Obtener la periodicidad del descuento de la campa?a';
    BEGIN
      SELECT Restriccion_Minima
            ,Restriccion_Maxima
        INTO l_Saldo_Campana
            ,l_Periodicidad
        FROM Scfr_Condiciones
       WHERE Cam_Campana = p_Campana
         AND Tipo_Condicion = 'CCD';
    EXCEPTION
      WHEN OTHERS THEN
        l_Periodicidad := NULL;
    END;
    l_Dbg_Mensaje := 'Obtener la fecha de inicio';
    Obtener_Fechas_Cam(p_Campana       => p_Campana
                      ,p_Rut           => l_Rut
                      ,p_Periodicidad  => l_Periodicidad
                      ,p_Fecha_Consumo => p_Fecha_Tx
                      ,x_Fecha_Ini     => l_Fecha_Inicio);
    l_Dbg_Mensaje := 'Obtener el Saldo Disponible';
    BEGIN
      -- Obtiene el saldo a partir del saldo disponible por movimiento en la cartola
      SELECT Saldo_Disponible
        INTO l_Saldo_Descuento
        FROM Scfr_Cuenta_Cte_Descuentos a
       WHERE Origen_Movimiento = 'CAM'
         AND Campana = p_Campana
         AND Rut = l_Rut
         AND Incluido_En_Calculo = 'SI'
            /*
                     AND fecha_hora_movimiento = ( SELECT MAX(fecha_hora_movimiento)
                                                     FROM SCFR_CUENTA_CTE_DESCUENTOS
                                                    WHERE origen_movimiento     = a.origen_movimiento
                                                      AND campana               = a.campana
                                                      AND rut                   = a.rut
                                                      AND incluido_en_calculo   = a.incluido_en_calculo
                                                      AND fecha_hora_movimiento >= l_fecha_inicio
                                                      AND fecha_hora_movimiento < p_fecha_tx )
            */
         AND Cta_Cte = (SELECT MAX(Cta_Cte)
                          FROM Scfr_Cuenta_Cte_Descuentos
                         WHERE Origen_Movimiento = a.Origen_Movimiento
                           AND Campana = a.Campana
                           AND Rut = a.Rut
                           AND Incluido_En_Calculo = a.Incluido_En_Calculo
                           AND Fecha_Hora_Movimiento >= l_Fecha_Inicio
                           AND Fecha_Hora_Movimiento < p_Fecha_Tx);
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Saldo_Descuento := l_Saldo_Campana;
      WHEN OTHERS THEN
        l_Saldo_Descuento := 0;
    END;
    RETURN l_Saldo_Descuento;
  EXCEPTION
    WHEN e_Salir THEN
      RETURN l_Aux;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Problemas al intentar ' || l_Dbg_Mensaje || ' - ' || SQLERRM);
      RETURN 0;
  END Devuelve_Saldo_Descuento;

  PROCEDURE Devuelve_Datos_Cliente(p_Party_Id IN NUMBER
                                  ,p_Campana  IN NUMBER
                                  ,x_Saldo    OUT NUMBER
                                  ,x_Folio    OUT VARCHAR2
                                  ,x_Preap    OUT NUMBER) IS
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.devuelve_datos_cliente';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Rut         Scfr_Mov_Transacciones.Rut_Titular%TYPE;
    l_Dv_Rut      Scfr_Mov_Transacciones.Dv_Titular%TYPE;
    l_Campana_Inc NUMBER;

  BEGIN
    l_Dbg_Mensaje := 'Obtener el Rut del Cliente a partir del Party_ID';

    Obtiene_Rut(p_Party_Id
               ,l_Rut
               ,l_Dv_Rut);
    l_Dbg_Mensaje := 'Obtener el saldo primera compra';

    BEGIN
      SELECT Saldo_Primera_Compra
            ,Folio
            ,Cupo_Preaprobado
        INTO x_Saldo
            ,x_Folio
            ,x_Preap
        FROM Scfr_Activa_Tarjeta
       WHERE Rut_Cliente = l_Rut
         AND Cam_Campana = p_Campana
         AND Estado IN ('GEN'
                       ,'ACT');
    EXCEPTION
      WHEN OTHERS THEN
        x_Saldo := 0;
        x_Folio := NULL;
        x_Preap := 0;
    END;
    -- Devuelve numero de cuenta para campana de descuento en primera compra
    IF (x_Folio IS NULL) THEN
      BEGIN
        SELECT Cam.Campana
          INTO l_Campana_Inc
          FROM Scfr_Listas_Clientes_Campanas Lista1
              ,Scfr_Listas_Clientes_Campanas Lista2
              ,Scfr_Campanas                 Cam
         WHERE Lista1.Sle_Listas_Clientes = Lista2.Sle_Listas_Clientes
           AND Lista2.Cam_Campana = Cam.Campana
           AND Cam.Tipo_Campana = 'INC'
           AND Lista1.Cam_Campana = p_Campana
           AND Rownum = 1;
      EXCEPTION
        WHEN No_Data_Found THEN
          l_Campana_Inc := NULL;
      END;
      IF (l_Campana_Inc IS NOT NULL) THEN
        BEGIN
          SELECT Saldo_Primera_Compra
                ,Folio
                ,Cupo_Preaprobado
            INTO x_Saldo
                ,x_Folio
                ,x_Preap
            FROM Scfr_Activa_Tarjeta
           WHERE Rut_Cliente = l_Rut
             AND Cam_Campana = l_Campana_Inc;
        EXCEPTION
          WHEN OTHERS THEN
            x_Saldo := 0;
            x_Folio := NULL;
            x_Preap := 0;
        END;
      END IF; -- if (l_campana_inc is not null ) then
    END IF; -- if ( l_trama_ca(l_itm).numero_cuenta is null) then
  EXCEPTION
    WHEN OTHERS THEN
      x_Saldo := 0;
      x_Folio := NULL;
      x_Preap := 0;
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => l_Dbg_Mensaje);
  END Devuelve_Datos_Cliente;

  FUNCTION Levanta_Campana(p_Party_Id IN NUMBER
                          ,p_Campana  IN NUMBER
                          ,p_Fecha_Tx IN NUMBER) RETURN VARCHAR2 IS
    l_Rut                  NUMBER;
    l_Dv_Rut               VARCHAR2(1);
    l_Restriccion_Diaria   NUMBER;
    l_Restriccion_Global   NUMBER;
    k_Opcion_Quiere        NUMBER := 1;
    k_No_Quiere            NUMBER := 2;
    k_No_Me_Gusta          NUMBER := 4;
    k_Otros_Medios         NUMBER := 5;
    k_Beneficio            NUMBER := 6;
    l_Dbg_Proceso          VARCHAR2(100) := 'SCFR_TRX_FID_PK.levanta_campana';
    l_Dbg_Mensaje          VARCHAR2(250) := 'Error General';
    l_Contador_Diario      NUMBER;
    l_Contador_Total       NUMBER;
    l_Estado               Scfr_Activa_Tarjeta.Estado%TYPE;
    l_Tipo_Campana         Scfr_Campanas.Tipo_Campana%TYPE;
    l_Levanta_Cam          VARCHAR2(2);
    l_Campana_Tcv_Dormidos VARCHAR2(2) := 'NO';
    x_Cod_Error            NUMBER;
    x_Msg_Error            VARCHAR2(250);
  BEGIN
    l_Dbg_Mensaje := 'Obtener el Tipo de la Campa?a';
    BEGIN
      SELECT Tipo_Campana INTO l_Tipo_Campana FROM Scfr_Campanas WHERE Campana = p_Campana;
    EXCEPTION
      WHEN OTHERS THEN
        l_Tipo_Campana := NULL;
    END;
    IF l_Tipo_Campana <> 'INC' THEN
      --//--------------------------------------------------------------------------\\
      --// CBR 05/02/2015 18:57   Mensajes / Eventos / Descuentos                   \\
      --//                                                                          \\
      --//-----------------------------------------------------------------Inicio---\\
      --      RETURN 'SI';
      IF l_Tipo_Campana NOT IN ('DES'
                               ,'MCL') THEN
        RETURN 'SI';
      ELSE
        l_Dbg_Mensaje := 'Obtener el Rut del Cliente a partir del Party_ID';
        BEGIN
          SELECT Jgzz_Fiscal_Code INTO l_Rut FROM Hz_Parties WHERE Party_Id = p_Party_Id;
          l_Dv_Rut := Scfr_Trx_Util_Pk.Dv_Rut(l_Rut);
        EXCEPTION
          WHEN OTHERS THEN
            l_Rut := NULL;
        END;
        l_Dbg_Mensaje := 'Validar si Campana es Descuento por Eventos, resolver si aplica campa?a';

        RETURN Scfr_Trx_Fid_Pk.Dto_x_Evento_Validacion(l_Rut -- p_Rut_Cliente
                                                      ,p_Party_Id -- p_Party_Id
                                                      ,p_Campana -- p_Campana_Descuentos
                                                      ,p_Fecha_Tx -- p_Fecha_Tx
                                                      ,l_Tipo_Campana -- p_Tipo_Campana
                                                      ,x_Cod_Error -- x_Cod_Error
                                                      ,x_Msg_Error); -- x_Msg_Error
      END IF;
      --//-----------------------------------------------------------------Termino--\\
    ELSE
      l_Dbg_Mensaje := 'Obtener el Rut del Cliente a partir del Party_ID';
      BEGIN
        SELECT Jgzz_Fiscal_Code INTO l_Rut FROM Hz_Parties WHERE Party_Id = p_Party_Id;
      EXCEPTION
        WHEN OTHERS THEN
          l_Rut := NULL;
      END;
      l_Dbg_Mensaje := 'Obtener estado de scfr_activa_tarjeta';
      SELECT Estado
        INTO l_Estado
        FROM Scfr_Activa_Tarjeta
       WHERE Rut_Cliente = l_Rut
         AND Cam_Campana = p_Campana;
      IF l_Estado = 'GEN' THEN
        l_Dbg_Mensaje := 'Obtener cantidad de opciones NO_QUIERE del dia que registra el cliente';
        SELECT COUNT(*)
          INTO l_Contador_Diario
          FROM Scfr_Reg_Opcion_Solicitud
         WHERE Rut_Cliente = l_Rut
           AND Cam_Campana = p_Campana
           AND Opcion_Seleccionada IN (k_No_Quiere
                                      ,k_No_Me_Gusta
                                      ,k_Otros_Medios
                                      ,k_Beneficio)
           AND Trunc(Fecha_Hora_Cap) = Trunc(Scfr_Trx_Util_Pk.Get_Sysdate);
        l_Dbg_Mensaje := 'Obtener cantidad de opciones NO_QUIERE totales que registra el cliente';
        SELECT COUNT(*)
          INTO l_Contador_Total
          FROM Scfr_Reg_Opcion_Solicitud
         WHERE Rut_Cliente = l_Rut
           AND Cam_Campana = p_Campana
           AND Opcion_Seleccionada IN (k_No_Quiere
                                      ,k_No_Me_Gusta
                                      ,k_Otros_Medios
                                      ,k_Beneficio);
        l_Dbg_Mensaje := 'Obtener las veces diarias maximas';
        BEGIN
          SELECT Restriccion_Minima
            INTO l_Restriccion_Diaria
            FROM Scfr_Condiciones
           WHERE Cam_Campana = p_Campana
             AND Tipo_Condicion = 'TDC';
        EXCEPTION
          WHEN OTHERS THEN
            l_Restriccion_Diaria := NULL;
        END;
        l_Dbg_Mensaje := 'Obtener las veces totales maximas';
        BEGIN
          SELECT Restriccion_Minima
            INTO l_Restriccion_Global
            FROM Scfr_Condiciones
           WHERE Cam_Campana = p_Campana
             AND Tipo_Condicion = 'TCO';
        EXCEPTION
          WHEN OTHERS THEN
            l_Restriccion_Global := NULL;
        END;
        IF l_Contador_Total < l_Restriccion_Global THEN
          IF l_Contador_Diario < l_Restriccion_Diaria THEN
            l_Levanta_Cam := 'SI';
          ELSE
            l_Levanta_Cam := 'NO';
          END IF;
        ELSE
          l_Levanta_Cam := 'NO';
        END IF;
        -- *
        BEGIN
          SELECT 'SI'
            INTO l_Campana_Tcv_Dormidos
            FROM Scfr_Condiciones
           WHERE Cam_Campana = p_Campana
             AND Tipo_Condicion = 'PTD'
             AND Rownum = 1;
        EXCEPTION
          WHEN No_Data_Found THEN
            l_Campana_Tcv_Dormidos := 'NO';
        END;
        -- Evaluar los QUIERO si corresponde
        IF (l_Levanta_Cam = 'SI') AND
           (l_Campana_Tcv_Dormidos = 'NO') THEN
          l_Dbg_Mensaje := 'Obtener cantidad de opciones QUIERE sin VoBo del QF del dia que registra el cliente';
          SELECT COUNT(*)
            INTO l_Contador_Diario
            FROM Scfr_Reg_Opcion_Solicitud
           WHERE Rut_Cliente = l_Rut
             AND Cam_Campana = p_Campana
             AND Opcion_Seleccionada = k_Opcion_Quiere
             AND Nvl(Vb_Qf
                    ,'NO') = 'NO'
             AND Trunc(Fecha_Hora_Cap) = Trunc(Scfr_Trx_Util_Pk.Get_Sysdate);
          l_Dbg_Mensaje := 'Obtener cantidad de opciones QUIERE sin VoBo del QF totales que registra el cliente';
          SELECT COUNT(*)
            INTO l_Contador_Total
            FROM Scfr_Reg_Opcion_Solicitud
           WHERE Rut_Cliente = l_Rut
             AND Cam_Campana = p_Campana
             AND Nvl(Vb_Qf
                    ,'NO') = 'NO'
             AND Opcion_Seleccionada = k_Opcion_Quiere;
          IF l_Contador_Total < l_Restriccion_Global THEN
            IF l_Contador_Diario < l_Restriccion_Diaria THEN
              l_Levanta_Cam := 'SI';
            ELSE
              l_Levanta_Cam := 'NO';
            END IF;
          ELSE
            l_Levanta_Cam := 'NO';
          END IF;
        END IF;
      ELSE
        l_Levanta_Cam := 'NO';
      END IF;
      RETURN l_Levanta_Cam;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => l_Dbg_Mensaje);
      RETURN 'NO';
  END Levanta_Campana;

  FUNCTION Levanta_Campana_Tcv(p_Rut     IN NUMBER
                              ,p_Campana IN NUMBER) RETURN VARCHAR2 IS
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.levanta_campana_tcv';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Levanta_Cam VARCHAR2(2);
    l_Restri_Cam  NUMBER := 0;
    l_Veces_Cam   NUMBER := 0;
  BEGIN
    l_Dbg_Mensaje := 'Obtener Restriccion de la Campa?a';
    BEGIN
      SELECT Restriccion_Minima
        INTO l_Restri_Cam
        FROM Scfr_Condiciones
       WHERE Cam_Campana = p_Campana
         AND Tipo_Condicion = 'MCM';
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Restri_Cam := 0;
    END;
    IF Nvl(l_Restri_Cam
          ,0) = 0 THEN
      l_Levanta_Cam := 'SI';
    ELSE
      l_Dbg_Mensaje := 'Obtener Cantidad de veces q se ha mostrado una campa?a TCV';
      SELECT COUNT(*)
        INTO l_Veces_Cam
        FROM Scfr_Reg_Opcion_Solicitud
       WHERE Rut_Cliente = p_Rut
         AND Cam_Campana = p_Campana
         AND Opcion_Seleccionada = 1;
      --   AND TRUNC( fecha_hora_cap ) = TRUNC( Scfr_Trx_Util_Pk.get_sysdate );
      IF (l_Veces_Cam < l_Restri_Cam) THEN
        l_Levanta_Cam := 'SI';
      ELSE
        l_Levanta_Cam := 'NO';
      END IF;
    END IF;
    RETURN l_Levanta_Cam;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => l_Dbg_Mensaje);
      RETURN 'NO';
  END Levanta_Campana_Tcv;

  FUNCTION Trama_Ca_Prepara(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ca IS
    CURSOR c_Campanas_Cliente(p_Party_Id IN NUMBER
                             ,p_Rut      IN NUMBER) IS
      SELECT Cam_Campana
        FROM Scfr_Campanas_Clientes
       WHERE Pt_Party_Id = p_Party_Id
         AND Trunc(Fecha_Inscripcion) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
         AND Trunc(Nvl(Fecha_Termino
                      ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
      UNION
      SELECT Licc.Cam_Campana
        FROM Scfr_Deta_List_Clientes       Delc
            ,Scfr_Listas_Clientes          Licl
            ,Scfr_Listas_Clientes_Campanas Licc
       WHERE Delc.Sle_Listas_Clientes = Licl.Listas_Clientes
         AND Licl.Listas_Clientes = Licc.Sle_Listas_Clientes
         AND Delc.Pt_Party_Id_Cliente = p_Party_Id
         AND Trunc(Licl.Fecha_Creacion) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
         AND Trunc(Nvl(Licl.Fecha_Termino
                      ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
         AND Trunc(Licc.Fecha_Asociacion) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
         AND Trunc(Nvl(Licc.Fecha_Termino
                      ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
         AND Trunc(Nvl(Delc.Fecha_Expiracion
                      ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
         AND Licl.Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
         AND Licl.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa;
    CURSOR c_Campanas_Tcv IS
      SELECT Con.Cam_Campana
            ,Cam.Tipo_Campana
        FROM Scfr_Condiciones Con
            ,Scfr_Campanas    Cam
       WHERE Con.Tipo_Condicion = 'TCV'
         AND Cam.Campana = Con.Cam_Campana;
    CURSOR c_Campanas_Cds IS
      SELECT Campana
        FROM Scfr_Campanas
       WHERE Tipo_Campana = 'CDS'
         AND Trunc(Fecha_Inicio) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
         AND Trunc(Nvl(Fecha_Termino
                      ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate());
    -- 13/12/2010 Cambios tramas pruebas FASE I GeoPOS
    -- Campanas de Puntos ACtivas
    -- Actualmente y para la FASE I de GeoPOS sera solo Una.
    CURSOR c_Campanas_Pto IS
      SELECT Campana
        FROM Scfr_Campanas
       WHERE Tipo_Campana = 'PTO'
         AND Trunc(Fecha_Inicio) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
         AND Trunc(Nvl(Fecha_Termino
                      ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate());
    -- FIN 13/12/2010 Cambios tramas pruebas FASE I GeoPOS
    -- 13/12/2010 Cambios tramas pruebas FASE I GeoPOS
    l_Contador_Total NUMBER;
    k_No_Quiere      NUMBER := 2;
    -- FIN 13/12/2010 Cambios tramas pruebas FASE I GeoPOS
    k_Local_Lleno        NUMBER := 3; -- 18/01/2010 Campo para Mensajes No Ofrecidos
    l_Cont_No_Quiere     NUMBER; -- 18/01/2010 Campo para contener total opcion No_Quiere
    l_Cont_Loca_Lleno    NUMBER; -- 18/01/2010 Campo para contener total opcion Local_Lleno
    l_Trama_Ca           Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ca;
    l_Itm                NUMBER;
    l_Total              NUMBER;
    l_Desplegar          BOOLEAN;
    l_Valida_Cliente_Tcv NUMBER;
    l_Rut                Scfr_Mov_Transacciones.Rut_Titular%TYPE;
    l_Dv_Rut             Scfr_Mov_Transacciones.Dv_Titular%TYPE;
    p_Folio_Tarjeta      Scfr_Clientes_Tarjetas_Vm.Folio_Tarjeta%TYPE;
    p_Datos              VARCHAR2(4000);
    l_Existe_Cli_Sms     NUMBER;
    l_Activo_Tcv_Sms     NUMBER;

  BEGIN
    Obtiene_Rut(p_Transaccion.Trama_Boc.Party_Id
               ,l_Rut
               ,l_Dv_Rut);
    l_Itm := 0;
    BEGIN
      SELECT 1
            ,Folio_Tarjeta
        INTO l_Valida_Cliente_Tcv
            ,p_Folio_Tarjeta
        FROM Scfr_Clientes_Tarjetas_Vm
       WHERE Rut_Cliente = l_Rut
         AND Tipo_Origen = 'TCV';
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Valida_Cliente_Tcv := 0;
    END;
    -- JRG 06-08-2018
    -- Actualiza tabla FID.SCFR_SMS_CLIENTES_TCV, para el envio de SMS, si cliente ya se encuentra
    -- en tabla, no se vuelve a grabar
    BEGIN
      SELECT Rv_Low_Value
        INTO l_Activo_Tcv_Sms
        FROM Cg_Ref_Codes
       WHERE Rv_Domain = 'ACTIVA SMS TCV'
         AND Rownum = 1;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Activo_Tcv_Sms := 0;
    END;

    IF (l_Valida_Cliente_Tcv = 1 AND l_Activo_Tcv_Sms = 1) THEN
      BEGIN
        SELECT 1
          INTO l_Existe_Cli_Sms
          FROM Scfr_Sms_Clientes_Tcv
         WHERE Rut_Cliente = l_Rut
           AND Emp_Codigo = p_Transaccion.Trama_Pos.Empresa
           AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena;
      EXCEPTION
        WHEN No_Data_Found THEN
          l_Existe_Cli_Sms := 0;
      END;
      -- Graba cliente en tabla   SCFR_SMS_CLIENTES_TCV
      IF (l_Existe_Cli_Sms = 0) THEN
        BEGIN
          INSERT INTO Scfr_Sms_Clientes_Tcv
            (Rut_Cliente
            ,Dv_Cliente
            ,Loc_Local
            ,Numero_Pos
            ,Fecha_Hora
            ,Emp_Codigo
            ,Cad_Cadena)
          VALUES
            (l_Rut
            ,l_Dv_Rut
            ,p_Transaccion.Trama_Pos.Local
            ,p_Transaccion.Trama_Pos.Numero_Pos
            ,SYSDATE
            ,p_Transaccion.Trama_Pos.Empresa
            ,p_Transaccion.Trama_Pos.Cadena);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END IF; -- if (l_existe_cli_sms = 0) then
    END IF; -- if (l_Valida_Cliente_Tcv  = 1 ) then
    -- Fin grabas clieentes en table FID.SCFR_SMS_CLIENTES_TCV
    FOR r_Campanas IN c_Campanas_Cliente(p_Transaccion.Trama_Boc.Party_Id
                                        ,l_Rut)
    LOOP
      -- Filtrar por tramo horario y zona
      IF Levanta_Campana(p_Transaccion.Trama_Boc.Party_Id
                        ,r_Campanas.Cam_Campana
                        ,p_Transaccion.Trama_Pos.Fecha_Hora_Tx) = 'SI' THEN
        IF Esta_En_Tramo_Horario(r_Campanas.Cam_Campana) AND -- condicion tramo horario
           Esta_En_Zona(p_Transaccion
                       ,r_Campanas.Cam_Campana) THEN
          -- condicion tramo zona
          l_Itm := l_Itm + 1;
          l_Trama_Ca(l_Itm).Campana := r_Campanas.Cam_Campana;
          l_Trama_Ca(l_Itm).Control_Eventos := 'SI';
          l_Trama_Ca(l_Itm).Saldo_Descuento := 0;
          Devuelve_Datos_Cliente(p_Transaccion.Trama_Boc.Party_Id
                                ,r_Campanas.Cam_Campana
                                ,l_Trama_Ca                      (l_Itm).Saldo_Primera_Compra
                                ,l_Trama_Ca                      (l_Itm).Numero_Cuenta
                                ,l_Trama_Ca                      (l_Itm).Cupo_Preaprobado);
          -- 13/12/2010 Cambios tramas pruebas FASE I GeoPOS
          -- Obtener cantidad de opciones NO_QUIERE totales que registra el cliente
          -- 18/01/2010 Cambios tramas pruebas FASE I GeoPOS
          -- Se crea nuevo campo para el envio de datos de numero de veces que no se pudo ofrecer
          -- que corresponde la respuesta de "Local Lleno" en las campanas de Incentivo TCV y dormidos,
          -- este campo complementa los datos enviados en campo "Numero Rechazos" de la misma trama.
          SELECT SUM(Decode(Opcion_Seleccionada
                           ,2
                           ,1
                           ,0)) No_Quiere
                ,SUM(Decode(Opcion_Seleccionada
                           ,3
                           ,1
                           ,0)) Local_Lleno
            INTO l_Cont_No_Quiere
                ,l_Cont_Loca_Lleno
            FROM Scfr_Reg_Opcion_Solicitud
           WHERE Rut_Cliente = l_Rut
             AND Cam_Campana = r_Campanas.Cam_Campana;
          l_Trama_Ca(l_Itm).Numero_Rechazos := l_Cont_No_Quiere;
          l_Trama_Ca(l_Itm).Mensajes_No_Ofrecidos := l_Cont_Loca_Lleno;
          -- FIN 18/01/2010 Cambios tramas pruebas FASE I GeoPOS
          -- FIN 13/12/2010 Cambios tramas pruebas FASE I GeoPOS
          /*                    SELECT COUNT(*)
            INTO l_contador_total
            FROM scfr_reg_opcion_solicitud
           WHERE rut_cliente = l_rut
             AND cam_campana = r_campanas.cam_campana
             AND opcion_seleccionada IN (k_no_quiere);
          l_trama_ca(l_itm).Numero_Rechazos := l_contador_total;*/
          BEGIN
            SELECT Controla_Tope_Descuento INTO l_Trama_Ca(l_Itm).Controla_Tope_Descuento FROM Scfr_Campanas WHERE Campana = r_Campanas.Cam_Campana;
            IF l_Trama_Ca(l_Itm).Controla_Tope_Descuento = 'SI' THEN
              l_Trama_Ca(l_Itm).Saldo_Descuento := Devuelve_Saldo_Descuento(r_Campanas.Cam_Campana
                                                                           ,p_Transaccion.Trama_Boc.Party_Id
                                                                           ,To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                                                                   ,'yyyymmddhh24miss'));
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              l_Trama_Ca(l_Itm).Controla_Tope_Descuento := 'NO';
          END;
        END IF;
      END IF;
    END LOOP;
    -- Valida campa?as TCV
    FOR R1_Campanas IN c_Campanas_Tcv
    LOOP
      -- Filtrar por tramo horario y zona
      IF Levanta_Campana_Tcv(l_Rut
                            ,R1_Campanas.Cam_Campana) = 'SI' THEN
        IF Esta_En_Tramo_Horario(R1_Campanas.Cam_Campana) AND -- condicion tramo horario
           Esta_En_Zona(p_Transaccion
                       ,R1_Campanas.Cam_Campana) AND -- condicion tramo zona
           l_Valida_Cliente_Tcv = 1 THEN
          l_Itm := l_Itm + 1;
          l_Trama_Ca(l_Itm).Campana := R1_Campanas.Cam_Campana;
          l_Trama_Ca(l_Itm).Control_Eventos := 'SI';
          l_Trama_Ca(l_Itm).Saldo_Descuento := 0;
          l_Trama_Ca(l_Itm).Saldo_Primera_Compra := 0;
          l_Trama_Ca(l_Itm).Numero_Cuenta := Substr(p_Folio_Tarjeta
                                                   ,1
                                                   ,20); -- se agrega substr
          -- 13/12/2010 Cambios tramas pruebas FASE I GeoPOS
          -- Obtener cantidad de opciones NO_QUIERE totales que registra el cliente
          -- 18/01/2010 Cambios tramas pruebas FASE I GeoPOS
          -- Se crea nuevo campo para el envio de datos de numero de veces que no se pudo ofrecer
          -- que corresponde la respuesta de "Local Lleno" en las campanas de Incentivo TCV y dormidos,
          -- este campo complementa los datos enviados en campo "Numero Rechazos" de la misma trama.
          SELECT SUM(Decode(Opcion_Seleccionada
                           ,2
                           ,1
                           ,0)) No_Quiere
                ,SUM(Decode(Opcion_Seleccionada
                           ,3
                           ,1
                           ,0)) Local_Lleno
            INTO l_Cont_No_Quiere
                ,l_Cont_Loca_Lleno
            FROM Scfr_Reg_Opcion_Solicitud
           WHERE Rut_Cliente = l_Rut
             AND Cam_Campana = R1_Campanas.Cam_Campana;
          l_Trama_Ca(l_Itm).Numero_Rechazos := l_Cont_No_Quiere;
          l_Trama_Ca(l_Itm).Mensajes_No_Ofrecidos := l_Cont_Loca_Lleno;
          -- FIN 18/01/2010 Cambios tramas pruebas FASE I GeoPOS
          -- FIN 13/12/2010 Cambios tramas pruebas FASE I GeoPOS
          /*                    SELECT COUNT(*)
            INTO l_contador_total
            FROM scfr_reg_opcion_solicitud
          WHERE rut_cliente = l_rut
            AND cam_campana = r1_campanas.cam_campana
            AND opcion_seleccionada IN (k_no_quiere);
            l_trama_ca(l_itm).Numero_Rechazos := l_contador_total;*/
          IF R1_Campanas.Tipo_Campana = 'DCT' THEN
            -- Solventa Decuento Efectivo, Obtener descuento TCV para folio tarjeta
            l_Trama_Ca(l_Itm).Saldo_Descuento := Obtiene_Dcto_Solventa(p_Transaccion
                                                                      ,p_Folio_Tarjeta
                                                                      ,l_Rut
                                                                      ,l_Dv_Rut);
          ELSE
            BEGIN
              SELECT Controla_Tope_Descuento
                INTO l_Trama_Ca(l_Itm).Controla_Tope_Descuento
                FROM Scfr_Campanas
               WHERE Campana = R1_Campanas.Cam_Campana;
              IF l_Trama_Ca(l_Itm).Controla_Tope_Descuento = 'SI' THEN
                l_Trama_Ca(l_Itm).Saldo_Descuento := Devuelve_Saldo_Descuento(R1_Campanas.Cam_Campana
                                                                             ,p_Transaccion.Trama_Boc.Party_Id
                                                                             ,To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                                                                     ,'yyyymmddhh24miss'));
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                l_Trama_Ca(l_Itm).Controla_Tope_Descuento := 'NO';
            END;
          END IF;
        END IF;
      END IF;
    END LOOP;
    FOR R2_Campanas IN c_Campanas_Cds
    LOOP
      IF Esta_En_Tramo_Horario(R2_Campanas.Campana) AND -- condicion tramo horario
         Esta_En_Zona(p_Transaccion
                     ,R2_Campanas.Campana) THEN
        -- condicion tramo zona
        IF Scfr_Trx_Gnc_Utl_Pk.Retorna_Benef_Cam(R2_Campanas.Campana
                                                ,SYSDATE
                                                ,l_Rut
                                                ,p_Transaccion.Trama_Pos.Local
                                                ,p_Datos) THEN
          --      IF  Scfr_Trx_Gnc_Utl_Pk.retorna_benef_cam ( r2_campanas.campana, to_date(substr(p_transaccion.trama_pos.fecha_hora_tx,1,8),'yyyy/mm/dd'), l_rut,  p_transaccion.trama_pos.local, p_datos) then
          l_Itm := l_Itm + 1;
          l_Trama_Ca(l_Itm).Campana := R2_Campanas.Campana;
          l_Trama_Ca(l_Itm).Control_Eventos := 'SI';
          l_Trama_Ca(l_Itm).Saldo_Descuento := 0;
          l_Trama_Ca(l_Itm).Saldo_Primera_Compra := 0;
          l_Trama_Ca(l_Itm).Controla_Tope_Descuento := 'NO';
          Scfr_Trx_Gnc_Utl_Pk.Registra_Log_Benef(To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                                        ,'YYYYMMDDHH24MISS')
                                                ,l_Rut
                                                ,p_Transaccion.Trama_Pos.Local
                                                ,p_Transaccion.Trama_Pos.Numero_Pos
                                                ,NULL
                                                ,p_Transaccion.Trama_Pos.Usuario_Responsable
                                                ,'OFRECE'
                                                ,p_Datos);
        END IF;
      END IF;
    END LOOP;
    -- 13/12/2010 Cambios tramas pruebas FASE I GeoPOS
    -- Campanas de Puntos ACtivas
    -- Actualmente y para la FASE I de GeoPOS sera solo Una.
    FOR r_Campanas_Pto IN c_Campanas_Pto
    LOOP
      -- Filtrar por tramo horario y zona
      IF Levanta_Campana(p_Transaccion.Trama_Boc.Party_Id
                        ,r_Campanas_Pto.Campana
                        ,p_Transaccion.Trama_Pos.Fecha_Hora_Tx) = 'SI' THEN
        IF Esta_En_Tramo_Horario(r_Campanas_Pto.Campana) AND -- condicion tramo horario
           Esta_En_Zona(p_Transaccion
                       ,r_Campanas_Pto.Campana) THEN
          -- condicion tramo zona
          l_Itm := l_Itm + 1;
          l_Trama_Ca(l_Itm).Campana := r_Campanas_Pto.Campana;
          l_Trama_Ca(l_Itm).Control_Eventos := 'SI';
          l_Trama_Ca(l_Itm).Saldo_Descuento := 0;
          l_Trama_Ca(l_Itm).Saldo_Primera_Compra := 0;
          l_Trama_Ca(l_Itm).Controla_Tope_Descuento := 'NO';
          l_Trama_Ca(l_Itm).Puntos_Disponibles := Scfr_Trx_Fid_Pk.Puntos_Disponibles(NULL
                                                                                    ,l_Rut
                                                                                    ,'T');
          -- 'Obtener valor de dias vencimiento de puntos';
          l_Trama_Ca(l_Itm).Vigencia := Scfr_Trx_Util_Pk.Det_Valor_Parametro_Por_Cod('DIVEPU');
          -- 18/01/2010 Cambios tramas pruebas FASE I GeoPOS
          -- Se incorpora campo adicional a campo "Puntos Disponibles" para indicar si saldo de
          -- puntos enviados es en Positivo o Negativo.
          IF l_Trama_Ca(l_Itm).Puntos_Disponibles >= 0 THEN
            l_Trama_Ca(l_Itm).Signo := 'P';
          ELSE
            l_Trama_Ca(l_Itm).Signo := 'N';
          END IF;
          -- FIN 18/01/2010 Cambios tramas pruebas FASE I GeoPOS
        END IF;
      END IF;
    END LOOP;
    -- FIN 13/12/2010 Cambios tramas pruebas FASE I GeoPOS
    RETURN l_Trama_Ca;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_Trama_Ca;
  END;

  FUNCTION Trama_Cx_Prepara(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cx IS
    CURSOR c_Campanas_Cliente(p_Rut IN NUMBER) IS
      SELECT Licc.Cam_Campana
        FROM Scfr_Deta_List_Clientes       Delc
            ,Scfr_Listas_Clientes          Licl
            ,Scfr_Listas_Clientes_Campanas Licc
       WHERE Delc.Sle_Listas_Clientes = Licl.Listas_Clientes
         AND Licl.Listas_Clientes = Licc.Sle_Listas_Clientes
         AND Delc.Rut_Cliente = p_Rut
         AND Trunc(Licl.Fecha_Creacion) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
         AND Trunc(Nvl(Licl.Fecha_Termino
                      ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
         AND Trunc(Licc.Fecha_Asociacion) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
         AND Trunc(Nvl(Licc.Fecha_Termino
                      ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
         AND Trunc(Nvl(Delc.Fecha_Expiracion
                      ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
         AND Licl.Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
         AND Licl.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa;

    -- 13/12/2010 Cambios tramas pruebas FASE I GeoPOS
    -- Campanas de Puntos ACtivas
    -- Actualmente y para la FASE I de GeoPOS sera solo Una.
    CURSOR c_Campanas_Pto IS
      SELECT Campana
        FROM Scfr_Campanas
       WHERE Tipo_Campana = 'PTO'
         AND Trunc(Fecha_Inicio) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
         AND Trunc(Nvl(Fecha_Termino
                      ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate());
    -- FIN 13/12/2010 Cambios tramas pruebas FASE I GeoPOS
    -- 13/12/2010 Cambios tramas pruebas FASE I GeoPOS
    l_Contador_Total NUMBER;
    k_No_Quiere      NUMBER := 2;
    -- FIN 13/12/2010 Cambios tramas pruebas FASE I GeoPOS
    k_Local_Lleno           NUMBER := 3; -- 18/01/2010 Campo para Mensajes No Ofrecidos
    l_Cont_No_Quiere        NUMBER; -- 18/01/2010 Campo para contener total opcion No_Quiere
    l_Cont_Loca_Lleno       NUMBER; -- 18/01/2010 Campo para contener total opcion Local_Lleno
    l_Trama_Cx              Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cx;
    l_Itm                   NUMBER;
    l_Total                 NUMBER;
    l_Desplegar             BOOLEAN;
    l_Rut                   Scfr_Mov_Transacciones.Rut_Titular%TYPE;
    p_Datos                 VARCHAR2(4000);
    l_Party_Id              NUMBER;
    l_Forma_Identificacion  VARCHAR2(1);
    l_String_Identificacion VARCHAR2(150);
    l_Dbg_Proceso           VARCHAR2(100) := 'SCFR_TRX_FID_PK.Trama_cx_prepara';
    l_Dbg_Mensaje           VARCHAR2(250) := 'Error general';
    l_Clientes_Mcv          VARCHAR2(1);
    l_Campana_Mcv           VARCHAR(2);
    l_Levanta_Campana       VARCHAR(2);
  BEGIN
    l_Forma_Identificacion  := p_Transaccion.Trama_Boc.Forma_Identificacion;
    l_String_Identificacion := Rtrim(Ltrim(p_Transaccion.Trama_Boc.String_Identificacion));
    l_Dbg_Mensaje           := '(CNVC05-CX) Forma de Identificacion';
    IF l_Forma_Identificacion = 'E' THEN
      BEGIN
        l_Dbg_Mensaje := '(CNVC05->CX) Procesando Rut ';
        l_Rut         := Substr(l_String_Identificacion
                               ,4
                               ,Length(l_String_Identificacion) - 4);
      EXCEPTION
        WHEN OTHERS THEN
          x_Cod_Error := 1098;
          Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                    ,p_Msg     => 'Error al intentar procesar RUT: ' ||
                                                  Substr(l_String_Identificacion
                                                        ,4
                                                        ,Length(l_String_Identificacion) - 4));

      END;
      l_Itm      := 0;
      l_Party_Id := Scfr_Trx_Util_Pk.Obtiene_Party_Id(l_Rut);

      -- Fin grabas clieentes en table FID.SCFR_SMS_CLIENTES_TCV
      --- Clientes MCV
      BEGIN
        SELECT Nvl(Inscrito_Mas_Cruz_Verde
                  ,'N')
          INTO l_Clientes_Mcv
          FROM Scfr_Tmp_Clientes
         WHERE Rut = l_Rut;
      EXCEPTION
        WHEN OTHERS THEN
          l_Clientes_Mcv := 'N';
      END;
      FOR r_Campanas IN c_Campanas_Cliente(l_Rut)
      LOOP
        -- Filtrar por tramo horario y zona
        BEGIN
          SELECT 'SI'
            INTO l_Campana_Mcv
            FROM Scfr_Condiciones
           WHERE Cam_Campana = r_Campanas.Cam_Campana
             AND Tipo_Condicion = 'MCV'
             AND Rownum = 1;
        EXCEPTION
          WHEN OTHERS THEN
            l_Campana_Mcv := 'NO';
        END;
        IF (l_Campana_Mcv = 'SI') AND
           (l_Clientes_Mcv = 'N') THEN
          l_Levanta_Campana := 'NO';
        ELSE
          l_Levanta_Campana := 'SI';
        END IF;
        -- Filtrar por tramo horario y zona
        IF (Levanta_Campana(l_Party_Id
                           ,r_Campanas.Cam_Campana
                           ,p_Transaccion.Trama_Pos.Fecha_Hora_Tx) = 'SI') AND
           (l_Levanta_Campana = 'SI') THEN
          IF Esta_En_Tramo_Horario(r_Campanas.Cam_Campana) AND -- condicion tramo horario
             Esta_En_Zona(p_Transaccion
                         ,r_Campanas.Cam_Campana) THEN
            -- condicion tramo zona
            l_Itm := l_Itm + 1;
            l_Trama_Cx(l_Itm).Campana := r_Campanas.Cam_Campana;
            l_Trama_Cx(l_Itm).Control_Eventos := 'SI';
            l_Trama_Cx(l_Itm).Saldo_Descuento := 0;
            BEGIN
              SELECT Controla_Tope_Descuento
                INTO l_Trama_Cx(l_Itm).Controla_Tope_Descuento
                FROM Scfr_Campanas
               WHERE Campana = r_Campanas.Cam_Campana;
              IF l_Trama_Cx(l_Itm).Controla_Tope_Descuento = 'SI' THEN
                l_Trama_Cx(l_Itm).Saldo_Descuento := Devuelve_Saldo_Descuento(r_Campanas.Cam_Campana
                                                                             ,l_Party_Id
                                                                             ,To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                                                                     ,'yyyymmddhh24miss'));
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                l_Trama_Cx(l_Itm).Controla_Tope_Descuento := 'NO';
            END;
          END IF;
        END IF;
      END LOOP;
      -- 13/12/2010 Cambios tramas pruebas FASE I GeoPOS
      -- Campanas de Puntos ACtivas
      -- Actualmente y para la FASE I de GeoPOS sera solo Una.
      FOR r_Campanas_Pto IN c_Campanas_Pto
      LOOP
        -- Filtrar por tramo horario y zona
        IF Levanta_Campana(l_Party_Id
                          ,r_Campanas_Pto.Campana
                          ,p_Transaccion.Trama_Pos.Fecha_Hora_Tx) = 'SI' THEN
          IF Esta_En_Tramo_Horario(r_Campanas_Pto.Campana) AND -- condicion tramo horario
             Esta_En_Zona(p_Transaccion
                         ,r_Campanas_Pto.Campana) THEN
            -- condicion tramo zona
            l_Itm := l_Itm + 1;
            l_Trama_Cx(l_Itm).Campana := r_Campanas_Pto.Campana;
            l_Trama_Cx(l_Itm).Control_Eventos := 'SI';
            l_Trama_Cx(l_Itm).Saldo_Descuento := 0;
            l_Trama_Cx(l_Itm).Controla_Tope_Descuento := 'NO';
            -- FIN 18/01/2010 Cambios tramas pruebas FASE I GeoPOS
          END IF;
        END IF;
      END LOOP;
    ELSE
      x_Cod_Error := 6100;
      x_Msg_Error := 'Forma de Identificacion Invalida';
    END IF;
    -- FIN 13/12/2010 Cambios tramas pruebas FASE I GeoPOS
    RETURN l_Trama_Cx;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_Trama_Cx;
  END Trama_Cx_Prepara;

  FUNCTION Trama_Ms_Prepara(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ms IS
    l_Trama_Ms Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ms;
    -- Mensajes 11 Campa?as personalizadas
    CURSOR c_Mensajes(p_Party_Id IN NUMBER) IS
      SELECT Mensaje
            ,Dirigido
            ,Tipo_Ejecucion_Mensaje
            ,Cam_Campana
            ,ROWID
        FROM Scfr_Clientes_Mensajes
       WHERE Pt_Party_Id_Cliente = p_Party_Id
         AND Trunc(Nvl(Fecha_Termino
                      ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
         AND Nvl(Numero_Eventos_Aplicados
                ,0) < Nvl(Numero_Eventos
                         ,0);
    -- Mensajes por lista de clientes
    CURSOR c_Listas_Mensajes(p_Party_Id IN NUMBER) IS
      SELECT Scfr_Lista_Cli_Mensaje.Lista_Cli_Mensaje
            ,Scfr_Lista_Cli_Mensaje.Personalizado
            ,Scfr_Lista_Cli_Mensaje.Mensaje
            ,Scfr_Lista_Cli_Mensaje.Fecha_Creacion
            ,Scfr_Lista_Cli_Mensaje.Fecha_Termino
            ,Scfr_Lista_Cli_Mensaje.Numero_Eventos
            ,Scfr_Lista_Cli_Mensaje.Sle_Listas_Clientes
            ,Scfr_Lista_Cli_Mensaje.Cam_Campana
            ,Scfr_Lista_Cli_Mensaje.Tipo_Ejecucion_Mensaje
            ,Scfr_Lista_Cli_Mensaje.Dirigido
            ,Scfr_Lista_Cli_Mensaje.Activo
            ,Scfr_Det_Cliente_Mensaje.Numero_Eventos_Aplicados
            ,Scfr_Det_Cliente_Mensaje.Rut_Cliente
            ,Scfr_Deta_List_Clientes.Dv_Cliente
            ,Scfr_Deta_List_Clientes.Pt_Party_Id_Cliente
        FROM Scfr_Lista_Cli_Mensaje
            ,Scfr_Det_Cliente_Mensaje
            ,Scfr_Deta_List_Clientes
       WHERE (Scfr_Lista_Cli_Mensaje.Cad_Cadena = p_Transaccion.Trama_Pos.Cadena AND
             Scfr_Lista_Cli_Mensaje.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa AND Scfr_Deta_List_Clientes.Pt_Party_Id_Cliente = p_Party_Id AND
             Scfr_Det_Cliente_Mensaje.Pt_Party_Id_Cliente(+) = p_Party_Id AND
             (Ms_Esta_En_Zona(p_Transaccion.Trama_Pos.Empresa
                              ,p_Transaccion.Trama_Pos.Cadena
                              ,p_Transaccion.Trama_Pos.Local
                              ,Scfr_Lista_Cli_Mensaje.Cam_Campana) = 1) AND
             Trunc(Nvl(Scfr_Lista_Cli_Mensaje.Fecha_Termino
                       ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()))
         AND ((Scfr_Deta_List_Clientes.Sle_Listas_Clientes = Scfr_Lista_Cli_Mensaje.Sle_Listas_Clientes) AND
             (Scfr_Lista_Cli_Mensaje.Lista_Cli_Mensaje = Scfr_Det_Cliente_Mensaje.Lcm_Lista_Cli_Mensaje(+)) AND
             Trunc(Nvl(Scfr_Deta_List_Clientes.Fecha_Expiracion
                       ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) AND
             ((Scfr_Lista_Cli_Mensaje.Numero_Eventos - Nvl(Scfr_Det_Cliente_Mensaje.Numero_Eventos_Aplicados
                                                           ,0)) > 0));
    l_Itm                      NUMBER;
    l_Existe                   NUMBER;
    l_Rut                      Scfr_Mov_Transacciones.Rut_Titular%TYPE;
    l_Dv_Rut                   Scfr_Mov_Transacciones.Dv_Titular%TYPE;
    l_Existe_Uso_Negativo      NUMBER;
    l_Aux_Campana              NUMBER;
    l_Uso_Positivo             VARCHAR2(3);
    p_Numero_Eventos_Aplicados Scfr_Det_Cliente_Mensaje.Numero_Eventos_Aplicados%TYPE;
  BEGIN
    l_Itm := 0;
    -- Mensajes 11 Campa?as personalizadas
    FOR r_Mensajes IN c_Mensajes(p_Transaccion.Trama_Boc.Party_Id)
    LOOP
      l_Itm := l_Itm + 1;
      l_Trama_Ms(l_Itm).Mensaje := r_Mensajes.Mensaje;
      l_Trama_Ms(l_Itm).Dirigido := r_Mensajes.Dirigido;
      l_Trama_Ms(l_Itm).Medio_Comunicacion := r_Mensajes.Tipo_Ejecucion_Mensaje;
      -- Actualiza el n?mero de eventos aplicados.
      UPDATE Scfr_Clientes_Mensajes
         SET Numero_Eventos_Aplicados = Nvl(Numero_Eventos_Aplicados
                                           ,0) + 1
       WHERE ROWID = r_Mensajes.Rowid;
    END LOOP;
    -- Mensajes por lista de clientes
    FOR r_Listas_Mensajes IN c_Listas_Mensajes(p_Transaccion.Trama_Boc.Party_Id)
    LOOP
      l_Itm := l_Itm + 1;
      l_Trama_Ms(l_Itm).Mensaje := r_Listas_Mensajes.Mensaje;
      l_Trama_Ms(l_Itm).Dirigido := r_Listas_Mensajes.Dirigido;
      l_Trama_Ms(l_Itm).Medio_Comunicacion := r_Listas_Mensajes.Tipo_Ejecucion_Mensaje;

      --//--------------------------------------------------------------------------\\
      --// CBR 05/02/2015 18:57                                                     \\
      --// Si la campana de mensajes tiene relacion con una de descuento, entonces  \\
      --// No debe aumentar evento aqui, debe hacerlo cuando se cierra la venta     \\
      --//-----------------------------------------------------------------Inicio---\\
      BEGIN
        SELECT 1
          INTO l_Existe
          FROM Scfr_Campanas_Relacionadas        Scr
              ,Fid.Scfr_Campanas                 Sc
              ,Fid.Scfr_Listas_Clientes_Campanas Slcc
              ,Fid.Scfr_Condiciones              Scond
         WHERE Scr.Cam_Campana_Relacionada = r_Listas_Mensajes.Cam_Campana
           AND Sc.Campana = Scr.Cam_Campana_Activacion
           AND Sc.Tipo_Campana = 'DES'
           AND Sc.Campana = Slcc.Cam_Campana
           AND Sc.Campana = Scond.Cam_Campana
           AND Scond.Tipo_Condicion = 'EVE'
           AND Nvl(Scond.Restriccion_Maxima
                  ,0) > 0;
      EXCEPTION
        WHEN No_Data_Found THEN
          l_Existe := 0;
      END;

      -- Si no existe entonces no es una campana de mensajes asociada con campana de descuento con eventos y puede actualizar evento.
      IF (l_Existe = 0) THEN
        -- Actualiza contador mensaje
        BEGIN
          SELECT 1
                ,Numero_Eventos_Aplicados
            INTO l_Existe
                ,p_Numero_Eventos_Aplicados
            FROM Scfr_Det_Cliente_Mensaje
           WHERE Lcm_Lista_Cli_Mensaje = r_Listas_Mensajes.Lista_Cli_Mensaje
             AND Pt_Party_Id_Cliente = p_Transaccion.Trama_Boc.Party_Id
             AND Rownum = 1;
        EXCEPTION
          WHEN No_Data_Found THEN
            l_Existe := 0;
        END;
        -- Si no existe Crea Contador.
        IF (l_Existe = 0) THEN
          -- Obtiene Rut
          Scfr_Trx_Util_Pk.Obtiene_Rut(p_Transaccion.Trama_Boc.Party_Id
                                      ,l_Rut
                                      ,l_Dv_Rut);
          -- *
          INSERT INTO Scfr_Det_Cliente_Mensaje
            (Lcm_Lista_Cli_Mensaje
            ,Pt_Party_Id_Cliente
            ,Rut_Cliente
            ,Numero_Eventos_Aplicados)
          VALUES
            (r_Listas_Mensajes.Lista_Cli_Mensaje
            ,p_Transaccion.Trama_Boc.Party_Id
            ,l_Rut
            ,1);
        ELSE
          -- Actualiza si existe contador
          UPDATE Scfr_Det_Cliente_Mensaje
             SET Numero_Eventos_Aplicados = Nvl(Numero_Eventos_Aplicados
                                               ,0) + 1
           WHERE Lcm_Lista_Cli_Mensaje = r_Listas_Mensajes.Lista_Cli_Mensaje
             AND Pt_Party_Id_Cliente = p_Transaccion.Trama_Boc.Party_Id;
          -- *
        END IF; --if (l_existe = 0) then

      END IF;
      --//-----------------------------------------------------------------Termino--\\
    END LOOP;
    -- *
    RETURN l_Trama_Ms;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_Trama_Ms;
  END Trama_Ms_Prepara;

  FUNCTION Trama_Cu_Prepara(p_Transaccion  IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,p_Codigo_Cupon IN VARCHAR2 DEFAULT NULL
                           ,x_Cod_Error    OUT NUMBER
                           ,x_Msg_Error    OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cu IS
    CURSOR c_Cupones(p_Party_Id IN NUMBER
                    ,p_Empresa  IN NUMBER
                    ,p_Cadena   IN NUMBER) IS
      SELECT Codigo_Cupon
            ,Estado_Cupon
            ,Cam_Campana
            ,Cupones
        FROM Scfr_Cupones
       WHERE Pt_Party_Id = p_Party_Id
         AND Trunc(Fecha_Vigencia) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
         AND Codigo_Cupon = Nvl(p_Codigo_Cupon
                               ,Codigo_Cupon)
         AND Estado_Cupon IN ('ACT'
                             ,'UTI')
         AND Tipo_Cupon = 'PER'
         AND Emp_Empresa = p_Empresa
         AND Cad_Cadena = p_Cadena;
    l_Trama_Cu Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cu;
    l_Itm      NUMBER;
  BEGIN
    l_Itm := 0;
    FOR r_Cupones IN c_Cupones(p_Transaccion.Trama_Boc.Party_Id
                              ,p_Transaccion.Trama_Pos.Empresa
                              ,p_Transaccion.Trama_Pos.Cadena)
    LOOP
      l_Itm := l_Itm + 1;
      BEGIN
        SELECT To_Number(To_Char(Motr.Fecha_Tx
                                ,'yyyymmdd'))
              ,Modt.Loc_Local
              ,Modt.Folio
          INTO l_Trama_Cu(l_Itm).Fecha
              ,l_Trama_Cu(l_Itm).Local
              ,l_Trama_Cu(l_Itm).Folio
          FROM Scfr_Mov_Transacciones        Motr
              ,Scfr_Mov_Documentos_Txs       Modt
              ,Scfr_Mov_Descuentos_Productos Modp
         WHERE Motr.Codigo_Tx = Modt.Txo_Codigo_Tx
           AND Modt.Txo_Codigo_Tx = Modp.Txo_Codigo_Tx
           AND Modp.Mcu_Codigo_Cupon = r_Cupones.Cupones;
      EXCEPTION
        WHEN OTHERS THEN
          l_Trama_Cu(l_Itm).Fecha := 0;
          l_Trama_Cu(l_Itm).Local := 0;
          l_Trama_Cu(l_Itm).Folio := 0;
      END;
      l_Trama_Cu(l_Itm).Codigo_Cupon := r_Cupones.Codigo_Cupon;
      l_Trama_Cu(l_Itm).Estado := r_Cupones.Estado_Cupon;
      l_Trama_Cu(l_Itm).Campana := r_Cupones.Cam_Campana;
    END LOOP;
    RETURN l_Trama_Cu;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_Trama_Cu;
  END;

  FUNCTION Trama_Cm_Prepara(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cm IS
    CURSOR c_Cupones(p_Party_Id IN NUMBER) IS
      SELECT Cupones               Cupones
            ,Cant_Meses_Benef_Crm  Meses
            ,Lim_Unidad_Crm        Limite
            ,Tipo_Cupon            Tipo_Cupon
            ,Spv_Codigo            Producto
            ,Fco_Familia_Comercial Familia
            ,Monto_Descuento       Monto_Descuento
            ,Porc_Descuento        Porcentaje_Descuento
            ,Cam_Campana           Promocion
        FROM Scfr_Cupones
       WHERE Pt_Party_Id = p_Party_Id
         AND Crm = 'SI'
         AND Estado_Cupon = 'PRE'
         AND Trunc(Fecha_Inscr_En_Crm) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
         AND Trunc(Fecha_Fin_Emision_Crm) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate());
    l_Trama_Cm Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cm;
    l_Itm      NUMBER;
  BEGIN
    l_Itm := 0;
    FOR r_Cupones IN c_Cupones(p_Transaccion.Trama_Boc.Party_Id)
    LOOP
      l_Itm := l_Itm + 1;
      IF r_Cupones.Monto_Descuento IS NULL THEN
        l_Trama_Cm(l_Itm).Descuento := 100 * Nvl(r_Cupones.Porcentaje_Descuento
                                                ,0);
        l_Trama_Cm(l_Itm).Tipo_Beneficio := 'REL';
      ELSE
        l_Trama_Cm(l_Itm).Descuento := r_Cupones.Monto_Descuento;
        l_Trama_Cm(l_Itm).Tipo_Beneficio := 'NOM';
      END IF;
      l_Trama_Cm(l_Itm).Codigo_Interno_Cupon := r_Cupones.Cupones;
      l_Trama_Cm(l_Itm).Mes := r_Cupones.Meses;
      l_Trama_Cm(l_Itm).Limite := r_Cupones.Limite;
      l_Trama_Cm(l_Itm).Tipo_Cupon := r_Cupones.Tipo_Cupon;
      l_Trama_Cm(l_Itm).Producto := r_Cupones.Producto;
      l_Trama_Cm(l_Itm).Familia_Comercial := r_Cupones.Familia;
      l_Trama_Cm(l_Itm).Campana := r_Cupones.Promocion;
    END LOOP;
    RETURN l_Trama_Cm;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_Trama_Cm;
  END;

  FUNCTION Trama_Pf_Prepara(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pf IS
    l_Trama_Pf Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pf;
  BEGIN
    l_Trama_Pf := Scfr_Pprog_Salud_Pk.Productos_Fidelizados(p_Transaccion
                                                           ,x_Cod_Error
                                                           ,x_Msg_Error);
    RETURN l_Trama_Pf;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_Trama_Pf;
  END;

  -- -------------------------------------------------------------------------
  -- Obtiene URL Servicio REST
  -- -------------------------------------------------------------------------
  FUNCTION Obtiene_Url(l_Id_Servicio_Ws IN VARCHAR2
                      ,x_Msg_Error      OUT VARCHAR2) RETURN VARCHAR2 IS

    Lwsdir VARCHAR2(200);
  BEGIN
    SELECT Wsdir INTO Lwsdir FROM Scfr_Comercios_Externos WHERE Comercio = l_Id_Servicio_Ws;
    RETURN Lwsdir;
  EXCEPTION
    WHEN No_Data_Found THEN
      x_Msg_Error := 'No hay datos en SCFR_COMERCIOS_EXTERNOS para destino = "' || l_Id_Servicio_Ws || '"';
      Lwsdir      := NULL;
      RETURN Lwsdir;
    WHEN OTHERS THEN
      x_Msg_Error := 'Problemas al obtener informacion de SCFR_COMERCIOS_EXTERNOS para destino = "' || l_Id_Servicio_Ws || '" - ' || SQLERRM;
      Lwsdir      := NULL;
      RETURN Lwsdir;
  END Obtiene_Url;

  PROCEDURE Registra_Pmc(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                        ,x_Cod_Error   OUT NUMBER
                        ,x_Msg_Error   OUT VARCHAR2) IS

    CURSOR c_Beneficios(p_Codigo_Tx IN NUMBER) IS
      SELECT Pro.Txo_Codigo_Tx
            ,Pro.Pro_Codigo_Interno
            ,(Decode(Doc.Tmo_Movimiento
                    ,'VENFAC'
                    ,1
                    ,1) * Abs(Pro.Cantidad_Acumulada_Psalud)) Cantidad_Acumulada_Psalud
            ,(Decode(Doc.Tmo_Movimiento
                    ,'VENFAC'
                    ,1
                    ,1) * Abs(Nvl(Des.Unidades_Descuento
                                   ,0))) Unidades_Descuento
            ,(Decode(Doc.Tmo_Movimiento
                    ,'VENFAC'
                    ,1
                    ,1) * Abs(Pro.Cantidad)) Cantidad
            ,Pro.Puf_Uso_Frecuente Campana_Convenio
            ,Decode(Doc.Tmo_Movimiento
                   ,'VENFAC'
                   ,'01'
                   ,'02') Tipomovimiento
            ,Pro.Identi_vendedor
            ,Pro.Tipo_identi_vendedor        
        FROM Scfr_Mov_Productos_Txs        Pro
            ,Scfr_Mov_Descuentos_Productos Des
            ,Scfr_Mov_Documentos_Txs       Doc
       WHERE (Pro.Txo_Codigo_Tx = Des.Txo_Codigo_Tx(+) AND Pro.Codigo_Detalle = Des.Prt_Codigo_Detalle(+))
         AND Doc.Txo_Codigo_Tx = Pro.Txo_Codigo_Tx
         AND Doc.Tmo_Movimiento IN ('VENFAC'
                                   ,'ANUFAC')
         AND Nvl(Pro.Cantidad_Acumulada_Psalud
                ,0) <> 0
         AND Pro.Puf_Uso_Frecuente >= 3000000
         AND Des.Campana_Convenio(+) >= 3000000
         AND Pro.Txo_Codigo_Tx = p_Codigo_Tx
       ORDER BY Pro.Txo_Codigo_Tx DESC;

    l_Datos_Dp          Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp;
    l_Itm               NUMBER;
    l_Dbg_Proceso       VARCHAR2(100) := 'SCFR_PPROG_SALUD_PK.compra_frecuente';
    l_Dbg_Mensaje       VARCHAR2(250) := 'Error General';
    Serviciorestaon     VARCHAR2(25) := 'AON';
    v_Url               VARCHAR2(200);
    v_Http_Request      Utl_Http.Req;
    v_Http_Response     Utl_Http.Resp;
    l_Con               INTEGER := 0;
    l_Cod_Resp_Json     VARCHAR2(10);
    l_Desc_Resp_Json    VARCHAR2(200);
    Buffer              VARCHAR2(32000);
    l_Forma_Identifica  VARCHAR2(100);
    l_String_Identifica VARCHAR2(150);
    l_Forma_Ident_Ret   VARCHAR2(100);
    l_Ruta_Servicio     VARCHAR2(500);
    Content             VARCHAR2(4000);
    l_Tipo_Iden         VARCHAR2(1);
    l_Identificacion    VARCHAR2(50);
    l_Error_Controlado EXCEPTION;
    l_Id_Consulta_Json NUMBER := 0;
    l_Id_Json          NUMBER := 0;
    l_Fecha_Solicitud  TIMESTAMP(6);
    l_Codigo_Tx        NUMBER;
    l_Valida_Aplica_Tx NUMBER;
  BEGIN
    l_Codigo_Tx := p_Transaccion.Codigo_Tx;

    BEGIN
      SELECT 1
        INTO l_Valida_Aplica_Tx
        FROM Consulta_Cliente_Json
       WHERE Tipo_Tx = 'APM'
         AND Txo_Codigo_Tx = l_Codigo_Tx
         AND Rownum = 1;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Valida_Aplica_Tx := 0;
    END;
    --
    IF (l_Valida_Aplica_Tx = 0) THEN
      l_Dbg_Mensaje := 'Obtener informaci?n de la trama DP (Datos Personales)';
      IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                       ,'DP') THEN
        l_Datos_Dp := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Dp(p_Transaccion.Cuerpo_Tx);
      ELSE
        l_Datos_Dp.Nombres          := 'CLIENTE INSCRITO SIN DATOS';
        l_Datos_Dp.Segundo_Nombre   := '.';
        l_Datos_Dp.Apellido_Paterno := ' ';
        l_Datos_Dp.Apellido_Materno := ' ';
        l_Datos_Dp.Sexo             := 'MAS';
        l_Datos_Dp.Fecha_Nacimiento := To_Number(To_Char(Scfr_Trx_Util_Pk.Get_Sysdate()
                                                        ,'yyyymmdd'));
      END IF;

      l_Fecha_Solicitud := Systimestamp;
      --Obtiene datos del servicio
      BEGIN
        SELECT Rv_High_Value
              ,Rv_Abbreviation
          INTO l_Ruta_Servicio
              ,Content
          FROM Cg_Ref_Codes
         WHERE Rv_Domain = 'SERVICIOS_PMC'
           AND Rv_Low_Value = 'ACTUALIZAPMC'
           AND Rownum = 1;
      EXCEPTION
        WHEN No_Data_Found THEN
          l_Ruta_Servicio := '/WebApplicationPDV-WEB/rest/PMCServices/AcumulaDebitaSaldos';
          Content         := NULL;
        WHEN OTHERS THEN
          l_Ruta_Servicio := '/WebApplicationPDV-WEB/rest/PMCServices/AcumulaDebitaSaldos';
          Content         := NULL;
      END;
      Scfr_Trx_Gnc_Utl_Pk.SET_NLS('NLS_LANGUAGE');

      FOR r_Beneficios IN c_Beneficios(l_Codigo_Tx)
      LOOP
        SELECT '{"Item":' || r_Beneficios.Pro_Codigo_Interno || ',' || '"CantidadAcumulada": ' || r_Beneficios.Cantidad_Acumulada_Psalud || ' ,' ||
               '"CantidadBeneficio": ' || r_Beneficios.Unidades_Descuento || ', ' || '"CantidadVendidos":' || r_Beneficios.Cantidad_Acumulada_Psalud || ' ,' || -- r_beneficios.Cantidad || ',' ||
               '"Documento":' || l_Codigo_Tx || ', ' || '"Promocion":' || r_Beneficios.Campana_Convenio || ', ' || '"Pos":' ||
               p_Transaccion.Trama_Pos.Numero_Pos || ',' || '"IdentificationType": "' ||
               Decode(TRIM(p_Transaccion.Trama_Boc.Forma_Identificacion)
                     ,'I'
                     ,'C'
                     ,'F'
                     ,'P'
                     ,TRIM(p_Transaccion.Trama_Boc.Forma_Identificacion)) || '",' || '"Identification": "' ||
               TRIM(p_Transaccion.Trama_Boc.String_Identificacion) || '",' || '"IdLocal":' || p_Transaccion.Trama_Pos.Local || ',' || '"Nombre":"' ||
               l_Datos_Dp.Nombres || '",' || '"SegundoNombre":"' || l_Datos_Dp.Segundo_Nombre || '",' || '"PrimerApellido":"' ||
               l_Datos_Dp.Apellido_Paterno || '", ' || '"SegundoApellido":"' || l_Datos_Dp.Apellido_Materno || '",' || '"TipoMovimiento":"' ||
               r_Beneficios.Tipomovimiento || '", ' || '"Telefono":"' || l_Datos_Dp.Telefono_Particular || '"' ||
               ', ' || '"DocNumberUsuario":"' || r_Beneficios.Identi_vendedor || '"' ||
               ', ' || '"DocTypeUsuario":"'   || r_Beneficios.Tipo_identi_vendedor || '"}'
          INTO Content
          FROM Dual;
        Dbms_Output.Put_Line('Content = > ' || Content);
        x_Cod_Error := 0;
        v_Url       := Obtiene_Url(Serviciorestaon
                                  ,x_Msg_Error);
        v_Url       := v_Url || l_Ruta_Servicio;
        Dbms_Output.Put_Line('v_url=>' || v_Url);
        IF (v_Url IS NOT NULL) THEN

          v_Http_Request := Utl_Http.Begin_Request(v_Url
                                                  ,'POST'
                                                  ,'HTTP/1.1');
          Utl_Http.Set_Body_Charset(v_Http_Request
                                   ,'UTF-8');
          Utl_Http.Set_Header(v_Http_Request
                             ,'user-agent'
                             ,'mozilla/4.0');
          Utl_Http.Set_Header(v_Http_Request
                             ,'content-type'
                             ,'application/json');
          Utl_Http.Set_Header(v_Http_Request
                             ,'Content-Length'
                             ,LengthB(Content));

          Utl_Http.Write_Text(v_Http_Request
                             ,Content);
          v_Http_Response := Utl_Http.Get_Response(v_Http_Request);
          BEGIN
            LOOP
              Utl_Http.Read_Line(v_Http_Response
                                ,Buffer
                                ,TRUE);
              INSERT INTO Consulta_Cliente_Json
                (Id --NUMBER  NOT NULL,
                ,Fecha --TIMESTAMP(6),
                ,Fecha_Respuesta
                ,Forma_Identificacion --VARCHAR2(1 BYTE),
                ,String_Identificacion --VARCHAR2(50),
                ,Emp_Empresa --NUMBER,
                ,Loc_Local --NUMBER,
                ,Respuesta
                ,Json_Envio
                ,Tipo_Tx
                ,Txo_Codigo_Tx
                ,Codigo_Autorizacion
                ,Fecha_Envio
                ,url_envio) --CLOB
              VALUES
                (Consulta_Cliente_Json_Seq.Nextval
                ,l_Fecha_Solicitud
                ,Systimestamp
                ,TRIM(p_Transaccion.Trama_Boc.Forma_Identificacion)
                ,TRIM(p_Transaccion.Trama_Boc.String_Identificacion)
                ,p_Transaccion.Trama_Pos.Empresa
                ,p_Transaccion.Trama_Pos.Local
                ,Buffer
                ,Content
                ,'APM'
                ,l_Codigo_Tx
                ,NULL
                ,NULL
                ,v_Url)
              RETURNING Id INTO l_Id_Consulta_Json;
              COMMIT;
            END LOOP;
          EXCEPTION
            WHEN Utl_Http.End_Of_Body THEN
              Dbms_Output.Put_Line('Res Con : ' || Buffer);
              Dbms_Output.Put_Line('error body : ' || SQLCODE || ' Mess ' || SQLERRM);
              l_Con := 0;
            WHEN OTHERS THEN
              Dbms_Output.Put_Line('error otro : ' || SQLCODE || ' Mess ' || SQLERRM);
              Dbms_Output.Put_Line('Res Con otro : ' || Buffer);
              l_Con := 2;
          END;
          Utl_Http.End_Response(v_Http_Response);
        END IF; -- if (Url is not null) then
        BEGIN
          Dbms_Output.Put_Line('grabado : ' || SQL%ROWCOUNT);
          Dbms_Output.Put_Line('id_consulta' || l_Id_Consulta_Json);
        EXCEPTION
          WHEN OTHERS THEN
            Dbms_Output.Put_Line('Error inserccion');
        END;
        IF l_Con = 0 THEN
          BEGIN
            SELECT Jsont.Resp1
                  ,Jsont.Desc_Resp
              INTO l_Cod_Resp_Json
                  ,l_Desc_Resp_Json
              FROM Consulta_Cliente_Json Jsonc
                  ,Json_Table(Respuesta
                             ,'$.status' Columns(Resp1 VARCHAR2(10) Path '$.httpStatus'
                                     ,Desc_Resp VARCHAR2(200) Path '$.mensaje')) AS Jsont
             WHERE Jsonc.Id = l_Id_Consulta_Json;
          EXCEPTION
            WHEN No_Data_Found THEN
              l_Cod_Resp_Json := 0;
          END;
        ELSE
          x_Cod_Error := 1;
          x_Msg_Error := 'Error conexion a Servicio-> ' || v_Url;
        END IF;

        Dbms_Output.Put_Line('l_con : ' || l_Con || ' l_res : ' || l_Cod_Resp_Json);
        IF (x_Cod_Error = 0) THEN
          x_Cod_Error := l_Cod_Resp_Json;
          x_Msg_Error := l_Desc_Resp_Json;
          IF (TRIM(l_Cod_Resp_Json) = '104') THEN
            UPDATE Consulta_Cliente_Json SET Estado_Envio = 'OK' WHERE Id = l_Id_Consulta_Json;
          ELSE
            UPDATE Consulta_Cliente_Json SET Estado_Envio = 'NOK' WHERE Id = l_Id_Consulta_Json;
          END IF;
          COMMIT;
        ELSE
          x_Cod_Error := x_Cod_Error;
          x_Msg_Error := x_Msg_Error;

        END IF;
      END LOOP;
    END IF; -- if (L_valida_aplica_tx = 0) then
  EXCEPTION
    WHEN OTHERS THEN
      
      --JGC 20240222 DEPURACION EXCEPCIONES        
      Utl_http.End_response(V_http_response);
      --JGC 20240222 DEPURACION EXCEPCIONES 
      
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
  END;

  FUNCTION Compra_Frecuente(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cf IS

    CURSOR c_Compra_Frecuente(p_Id_Consulta_Json IN NUMBER) IS
      SELECT Jsont.Coditem
            ,Trunc(To_Number(TRIM(Cajasacumuladas)
                            ,'9999.9999')) Cajasacumuladas
            ,Trunc(To_Number(TRIM(Cajasresiduo)
                            ,'9999.9999')) Cajasresiduo
            ,Signo
            ,Eventoscumplidos
            ,Promocion
            ,Fechavencimiento
        FROM Consulta_Cliente_Json Jsonc
            ,Json_Table(Respuesta
                       ,'$.clientAccounts[*]' Columns(Coditem VARCHAR2(100) Path '$.CodItem'
                               ,Cajasacumuladas VARCHAR2(50) Path '$.CajasAcumuladas'
                               ,Cajasresiduo VARCHAR2(200) Path '$.CajasResiduo'
                               ,Signo VARCHAR2(200) Path '$.Signo'
                               ,Eventoscumplidos VARCHAR2(300) Path '$.EventosCumplidos'
                               ,Promocion VARCHAR2(200) Path '$.Promocion'
                               ,Fechavencimiento VARCHAR2(200) Path '$.FechaVencimiento')) AS Jsont
       WHERE Jsonc.Id = p_Id_Consulta_Json;
    l_Trama_Cf          Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cf;
    l_Itm               NUMBER;
    l_Dbg_Proceso       VARCHAR2(100) := 'SCFR_PPROG_SALUD_PK.compra_frecuente';
    l_Dbg_Mensaje       VARCHAR2(250) := 'Error General';
    Serviciorestaon     VARCHAR2(25) := 'AON';
    v_Url               VARCHAR2(200);
    v_Http_Request      Utl_Http.Req;
    v_Http_Response     Utl_Http.Resp;
    l_Con               INTEGER := 0;
    l_Cod_Resp_Json     VARCHAR2(10);
    l_Desc_Resp_Json    VARCHAR2(200);
    Buffer              CLOB; -- VARCHAR2(32000);
    l_Forma_Identifica  VARCHAR2(100);
    l_String_Identifica VARCHAR2(150);
    l_Datos_Cliente     Scfr_Trx_Fid_Pk.Rec_Datos_Cliente;
    l_Forma_Ident_Ret   VARCHAR2(100);
    l_Ruta_Servicio     VARCHAR2(500);
    Content             VARCHAR2(4000);
    l_Convenio          VARCHAR2(50);
    l_Error_Controlado EXCEPTION;
    l_Id_Consulta_Json NUMBER := 0;
    l_Id_Json          NUMBER := 0;
    l_Fecha_Solicitud  TIMESTAMP(6);
     L_tipo_identificador        Varchar2(1);
    l_Identificador    Varchar2(50);
    l_Fechavencimiento date;
  BEGIN
    l_Fecha_Solicitud := Systimestamp;
    --Obtiene datos del servicio
    BEGIN
      SELECT Rv_High_Value
            ,Rv_Abbreviation
        INTO l_Ruta_Servicio
            ,Content
        FROM Cg_Ref_Codes
       WHERE Rv_Domain = 'SERVICIOS_PMC'
         AND Rv_Low_Value = 'CONSULTASALDOS';
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Ruta_Servicio := '/WebApplicationPDV-WEB/rest/PMCServices/ConsultaSaldos';
        Content         := NULL;
      WHEN OTHERS THEN
        l_Ruta_Servicio := '/WebApplicationPDV-WEB/rest/PMCServices/ConsultaSaldos';
        Content         := NULL;
    END;

      Scfr_Trx_Gnc_Utl_Pk.SET_NLS('NLS_LANGUAGE');
    If (TRIM(p_Transaccion.Trama_Boc.Forma_Identificacion) = 'A')  Then
      Begin
         Select Substr(Trim(p_Transaccion.Trama_Boc.String_Identificacion),16,1) Tipo
               ,Substr(Trim(p_Transaccion.Trama_Boc.String_Identificacion),17,15) Identificacion
         Into   L_tipo_identificador
               ,l_Identificador
         From Dual;
        Exception When Others Then
         L_tipo_identificador  := TRIM(p_Transaccion.Trama_Boc.Forma_Identificacion);
         l_Identificador      := p_Transaccion.Trama_Boc.String_Identificacion;
       End;
    ELSIf (TRIM(p_Transaccion.Trama_Boc.Forma_Identificacion) = 'O')  Then
      Begin
         Select Substr(Trim(p_Transaccion.Trama_Boc.String_Identificacion),16,1) Tipo
               ,Substr(Trim(p_Transaccion.Trama_Boc.String_Identificacion),17,15) Identificacion
         Into   L_tipo_identificador
               ,l_Identificador
         From Dual;
        Exception When Others Then
         L_tipo_identificador  := TRIM(p_Transaccion.Trama_Boc.Forma_Identificacion);
         l_Identificador      := p_Transaccion.Trama_Boc.String_Identificacion;
       End;
    ELSIf (TRIM(p_Transaccion.Trama_Boc.Forma_Identificacion) = 'M')  Then
      Begin
         Select Substr(Trim(p_Transaccion.Trama_Boc.String_Identificacion),16,1) Tipo
               ,Substr(Trim(p_Transaccion.Trama_Boc.String_Identificacion),17,15) Identificacion
         Into   L_tipo_identificador
               ,l_Identificador
         From Dual;
        Exception When Others Then
         L_tipo_identificador  := TRIM(p_Transaccion.Trama_Boc.Forma_Identificacion);
         l_Identificador      := TRIM(p_Transaccion.Trama_Boc.String_Identificacion);
       End;
     else
         L_tipo_identificador  := TRIM(p_Transaccion.Trama_Boc.Forma_Identificacion);
         l_Identificador      := TRIM(p_Transaccion.Trama_Boc.String_Identificacion);
   end if;


    SELECT '{"identificationType": "' || Decode(L_tipo_identificador
                                               ,'I'
                                               ,'C'
                                               ,'F'
                                               ,'P'
                                               ,L_tipo_identificador) || '",' || '"identification": "' ||
           l_Identificador || '", ' || '"idLocal":' || p_Transaccion.Trama_Pos.Local || ' }'
      INTO Content
      FROM Dual;
    Dbms_Output.Put_Line('Content = > ' || Content);
    x_Cod_Error := 0;
    v_Url       := Obtiene_Url(Serviciorestaon
                              ,x_Msg_Error);
    v_Url       := v_Url || l_Ruta_Servicio;
    Dbms_Output.Put_Line('v_url=>' || v_Url);
    IF (v_Url IS NOT NULL) THEN
      BEGIN
        Buffer := Scfr_Trx_Conv_Empresarial_Pk.get_request (v_Url,Content);

          INSERT INTO Consulta_Cliente_Json
            (Id --NUMBER  NOT NULL,
            ,Fecha --TIMESTAMP(6),
            ,Fecha_Respuesta
            ,Forma_Identificacion --VARCHAR2(1 BYTE),
            ,String_Identificacion --VARCHAR2(50),
            ,Emp_Empresa --NUMBER,
            ,Loc_Local --NUMBER,
            ,Respuesta
            ,Json_Envio
            ,Tipo_Tx
            ,Txo_Codigo_Tx
            ,Codigo_Autorizacion
            ,Fecha_Envio
            ,url_envio) --CLOB
          VALUES
            (Consulta_Cliente_Json_Seq.Nextval
            ,l_Fecha_Solicitud
            ,Systimestamp
            ,TRIM(p_Transaccion.Trama_Boc.Forma_Identificacion)
            ,TRIM(p_Transaccion.Trama_Boc.String_Identificacion)
            ,p_Transaccion.Trama_Pos.Empresa
            ,p_Transaccion.Trama_Pos.Local
            ,Buffer
            ,Content
            ,'CPM'
            ,NULL
            ,NULL
            ,NULL
            ,v_Url)
          RETURNING Id INTO l_Id_Consulta_Json;
          COMMIT;
      EXCEPTION
        WHEN Utl_Http.End_Of_Body THEN
          Dbms_Output.Put_Line('Res Con : ' || Buffer);
          Dbms_Output.Put_Line('error body : ' || SQLCODE || ' Mess ' || SQLERRM);
          l_Con := 0;
        WHEN OTHERS THEN
          Dbms_Output.Put_Line('error otro : ' || SQLCODE || ' Mess ' || SQLERRM);
          Dbms_Output.Put_Line('Res Con otro : ' || Buffer);
          l_Con := 2;
      END;
      Utl_Http.End_Response(v_Http_Response);
    END IF; -- if (Url is not null) then
    BEGIN
      Dbms_Output.Put_Line('grabado : ' || SQL%ROWCOUNT);
      Dbms_Output.Put_Line('id_consulta' || l_Id_Consulta_Json);
    EXCEPTION
      WHEN OTHERS THEN
        Dbms_Output.Put_Line('Error inserccion');
    END;
    IF l_Con = 0 THEN
      SELECT Jsont.Resp1
            ,Jsont.Desc_Resp
        INTO l_Cod_Resp_Json
            ,l_Desc_Resp_Json
        FROM Consulta_Cliente_Json Jsonc
            ,Json_Table(Respuesta
                       ,'$.status' Columns(Resp1 VARCHAR2(10) Path '$.httpStatus'
                               ,Desc_Resp VARCHAR2(200) Path '$.mensaje')) AS Jsont
       WHERE Jsonc.Id = l_Id_Consulta_Json;
    ELSE
      x_Cod_Error := 1;
      x_Msg_Error := 'Error conexion a Servicio-> ' || v_Url;
    END IF;

    Dbms_Output.Put_Line('l_con : ' || l_Con || ' l_res : ' || l_Cod_Resp_Json);
    IF (x_Cod_Error = 0) THEN
      x_Cod_Error := l_Cod_Resp_Json;
      x_Msg_Error := l_Desc_Resp_Json;
      IF (TRIM(l_Cod_Resp_Json) = '104') THEN
        UPDATE Consulta_Cliente_Json SET Estado_Envio = 'OK' WHERE Id = l_Id_Consulta_Json;
      ELSE
        UPDATE Consulta_Cliente_Json SET Estado_Envio = 'NOK' WHERE Id = l_Id_Consulta_Json;
      END IF;
      COMMIT;
    ELSE
      x_Cod_Error := x_Cod_Error;
      x_Msg_Error := x_Msg_Error;

    END IF;

    l_Itm         := 0;
    l_Dbg_Mensaje := 'Recorrer detalle de productos fidelizados';
    FOR r_Compra_Frecuente IN c_Compra_Frecuente(l_Id_Consulta_Json)
    LOOP
      begin
         l_Fechavencimiento:=To_Date(r_Compra_Frecuente.Fechavencimiento ,'yyyy-mm-dd');
        exception when others then
        l_Fechavencimiento := trunc(sysdate + 1);
      end;      
      l_Dbg_Mensaje := 'Validar condiciones de filtro';
      l_Itm         := l_Itm + 1;
      -- *
      l_Dbg_Mensaje := 'Preparar datos para la trama CF (Compra Frecuente)';
      l_Trama_Cf(l_Itm).Uso_Frecuente := r_Compra_Frecuente.Coditem;
      l_Trama_Cf(l_Itm).Evento_Actual := 1; --r_Compra_Frecuente.EventosCumplidos;
      l_Trama_Cf(l_Itm).Saldo_Evento_Actual := Abs(r_Compra_Frecuente.Cajasresiduo); -- Abs(r_Compra_Frecuente.CajasAcumuladas);
      l_Trama_Cf(l_Itm).Signo := r_Compra_Frecuente.Signo;
      l_Trama_Cf(l_Itm).Eventos_Cumplidos := r_Compra_Frecuente.Eventoscumplidos;
      l_Trama_Cf(l_Itm).Campana := r_Compra_Frecuente.Promocion;
      l_Trama_Cf(l_Itm).Fecha_Vencimiento := To_Number(To_Char(l_Fechavencimiento
                                                              ,'yyyymmdd'));

    END LOOP;
    RETURN l_Trama_Cf;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      RETURN l_Trama_Cf;
  END;

  FUNCTION Trama_Cf_Prepara(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cf IS
    l_Trama_Cf Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cf;
  BEGIN
    l_Trama_Cf := Compra_Frecuente(p_Transaccion
                                  ,x_Cod_Error
                                  ,x_Msg_Error);
    RETURN l_Trama_Cf;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_Trama_Cf;
  END;

  PROCEDURE Reprocesa_Clientes IS
    CURSOR c_Clientes_Tmp IS
      SELECT Cli.Party_Id
            ,Cli.Rut
            ,Rdp.String_Entrada
            ,Rdp.Correlativo Correlativo_Trp
        FROM Scfr_Tmp_Clientes Cli
            ,Scfr_Trx_Rec_Pos  Rdp
       WHERE Cli.Correlativo_Trp = Rdp.Correlativo
         AND Cli.Estado IS NULL
         AND Nvl(Cli.Estado
                ,' ') != 'CRF';
    l_Transaccion     Scfr_Trx_Dyn_Pk.Rec_Transaccion;
    l_Ultimo_Party_Id NUMBER;
    l_Party_Id_Nuevo  NUMBER;
    l_Cod_Error       NUMBER;
    l_Msg_Error       VARCHAR2(250);
    l_Return_Status   VARCHAR2(4000);
    l_Msg_Data        VARCHAR2(4000);
    l_Respuesta       BLOB;
    l_Nombre_Log      VARCHAR2(50);
    l_Dir             VARCHAR2(500);
    l_Ret             NUMBER;
    l_Int             NUMBER;
    l_Log             Utl_File.File_Type;
    l_Dbg_Proceso     VARCHAR2(100) := 'SCFR_TRX_FID_PK.reprocesa_clientes';
    l_Dbg_Mensaje     VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    -- obtiene directorio en donde escribir el archivo log.
    l_Ret := Dbms_Utility.Get_Parameter_Value('utl_file_dir'
                                             ,l_Int
                                             ,l_Dir
                                             ,1);
    -- genera el nombre del archivo
    l_Nombre_Log := 'SCFR_REPROCESA_CLIENTES.LOG';
    -- intenta abrir el archivo log, de existir, lo abre para seguir insertando
    IF Length(l_Dir) > 0 THEN
      l_Log := Utl_File.Fopen(l_Dir
                             ,l_Nombre_Log
                             ,'w');
    END IF;
    FOR r_Cliente IN c_Clientes_Tmp
    LOOP
      BEGIN
        BEGIN
          -- chequea si el cliente esta en l
          SELECT Party_Id INTO l_Party_Id_Nuevo FROM Hz_Parties WHERE Jgzz_Fiscal_Code = To_Char(r_Cliente.Rut);
        EXCEPTION
          WHEN OTHERS THEN
            l_Party_Id_Nuevo := NULL;
        END;
        -- parsea transaccion
        l_Dbg_Mensaje := 'Parsear transacci?n de inscripci?n cliente';
        l_Transaccion := Scfr_Trx_Dyn_Pk.Setea_Transaccion(r_Cliente.String_Entrada
                                                          ,l_Cod_Error
                                                          ,l_Msg_Error);
        l_Dbg_Mensaje := 'Llamar a scfr_trx_fid_pk.fidi01()';
        Scfr_Trx_Fid_Pk.Fidi01(p_Transaccion => l_Transaccion
                              ,x_Respuesta   => l_Respuesta
                              ,p_En_Linea    => 'NO'
                              ,x_Cod_Error   => l_Cod_Error
                              ,x_Msg_Error   => l_Msg_Error);
        IF l_Party_Id_Nuevo IS NULL AND
           Nvl(l_Cod_Error
              ,0) = 0 THEN
          -- obtiene party id nuevo
          l_Party_Id_Nuevo := Obtiene_Party_Id_Ebso();
        END IF;
        IF l_Party_Id_Nuevo IS NOT NULL THEN
          -- actualiza party id en todas las tablas que corresponda
          -- actualiza scfr_tmp_clientes
          l_Dbg_Mensaje := 'Registrar HZ_PARTIES.Party_Id en tabla scfr_tmp_clientes';
          UPDATE Scfr_Tmp_Clientes SET Party_Id_Ebso = l_Party_Id_Nuevo WHERE Party_Id = r_Cliente.Party_Id;
          -- actualiza scfr_mov_transacciones
          l_Dbg_Mensaje := 'Actualizar HZ_PARTIES.Party_Id en tabla scfr_mov_transacciones';
          UPDATE Scfr_Mov_Transacciones SET Pt_Party_Id_Titular = l_Party_Id_Nuevo WHERE Pt_Party_Id_Titular = r_Cliente.Party_Id;
          -- actualiza scfr_mov_productos_txs
          l_Dbg_Mensaje := 'Actualizar HZ_PARTIES.Party_Id en tabla scfr_mov_productos_txs';
          UPDATE Scfr_Mov_Productos_Txs SET Pt_Party_Id_Titular = l_Party_Id_Nuevo WHERE Pt_Party_Id_Titular = r_Cliente.Party_Id;
          -- actualiza scfr_recetas
          l_Dbg_Mensaje := 'Actualizar HZ_PARTIES.Party_Id en tabla scfr_recetas';
          UPDATE Scfr_Recetas SET Pt_Party_Id = l_Party_Id_Nuevo WHERE Pt_Party_Id = r_Cliente.Party_Id;
          l_Dbg_Mensaje := 'Actualizar HZ_PARTIES.Party_Id en tabla scfr_datos_recolectados';
          --        update scfr_datos_recolectados
          --           set pt_party_id = l_party_id_nuevo
          --         where pt_party_id = r_cliente.party_id;
          l_Dbg_Mensaje := 'Actualizar HZ_PARTIES.Party_Id en tabla scfr_clientes_mensajes';
          --        update scfr_clientes_mensajes
          --           set pt_party_id = l_party_id_nuevo
          --         where pt_party_id = r_cliente.party_id;
          --          update scfr_reasignacion_folios
          --             set pt_party_id_destino = l_party_id_nuevo
          --           where pt_party_id_destino = r_cliente.party_id;
          -- actualiza scfr_beneficiarios
          UPDATE Scfr_Beneficiarios SET Pt_Party_Id = l_Party_Id_Nuevo WHERE Pt_Party_Id = r_Cliente.Party_Id;
          UPDATE Scfr_Beneficiarios SET Pt_Party_Id_Titular = l_Party_Id_Nuevo WHERE Pt_Party_Id_Titular = r_Cliente.Party_Id;
          -- actualiza scfr_param_aplicacion_benef
          UPDATE Scfr_Param_Aplicacion_Benef SET Pt_Party_Id = l_Party_Id_Nuevo WHERE Pt_Party_Id = r_Cliente.Party_Id;
          -- actualiza scfr_credenciales
          UPDATE Scfr_Credenciales SET Pt_Party_Id = l_Party_Id_Nuevo WHERE Pt_Party_Id = r_Cliente.Party_Id;
          UPDATE Scfr_Credenciales SET Pt_Party_Id_Titular = l_Party_Id_Nuevo WHERE Pt_Party_Id_Titular = r_Cliente.Party_Id;
          -- actualiza scfr_detalle_consumos
          UPDATE Scfr_Detalle_Consumos SET Pt_Party_Id_Benef = l_Party_Id_Nuevo WHERE Pt_Party_Id_Benef = r_Cliente.Party_Id;
          -- actualiza programa de salud
          --utilitarios.act_party_ps( r_cliente.party_id, l_party_id_nuevo, l_cod_error, l_msg_error );
          IF Nvl(l_Cod_Error
                ,0) != 0 THEN
            Raise_Application_Error(-20000
                                   ,l_Msg_Error);
          END IF;
          -- actualiza programa de salud
          --utilitarios.act_party_txs_puntos( r_cliente.party_id, l_party_id_nuevo, l_cod_error, l_msg_error );
          IF Nvl(l_Cod_Error
                ,0) != 0 THEN
            Raise_Application_Error(-20000
                                   ,l_Msg_Error);
          END IF;
          -- actualiza programa scfr_clientes_mensajes, scfr_deta_list_clientes, scfr_reasignacion_folios
          --utilitarios.act_party_otras( r_cliente.party_id, l_party_id_nuevo, l_cod_error, l_msg_error );
          IF Nvl(l_Cod_Error
                ,0) != 0 THEN
            Raise_Application_Error(-20000
                                   ,l_Msg_Error);
          END IF;
          -- marca cliente de tabla temporal como ya actualizado
          UPDATE Scfr_Tmp_Clientes SET Estado = 'PRO' WHERE Party_Id = r_Cliente.Party_Id;
          COMMIT;
          Utl_File.Put_Line(l_Log
                           ,'Rut TRP=>' || r_Cliente.Rut || '; Party Id TMP=>' || r_Cliente.Party_Id || '; Party id EBSO=>' || l_Party_Id_Nuevo ||
                            '; correlativo_TRP=>' || r_Cliente.Correlativo_Trp || ' OK');
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          Utl_File.Put_Line(l_Log
                           ,'cliente RUT=>' || r_Cliente.Rut || ' ERROR=>' || SQLERRM);
          ROLLBACK;
      END;
    END LOOP;
  END;

  FUNCTION Busca_Inserta_Inscripcion(p_Rut_Cliente IN NUMBER
                                    ,p_Empresa     IN NUMBER) RETURN NUMBER IS
    l_Existe NUMBER;
  BEGIN
    SELECT 1
      INTO l_Existe
      FROM Scfr_Inscripciones_Fid
     WHERE Rut_Cliente = p_Rut_Cliente
       AND Emp_Empresa = p_Empresa;
    RETURN l_Existe;
  EXCEPTION
    WHEN No_Data_Found THEN
      l_Existe := 0;
      RETURN l_Existe;
  END;

  -- --------------------------------------------------------------------------------
  -- PROCEDURE Fidi01
  -- --------------------------------------------------------------------------------
  PROCEDURE Fidi01(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,p_En_Linea    IN VARCHAR2 DEFAULT 'SI'
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Datos_Dp        Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp;
    l_Datos_Is        Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Is;
    l_Party_Id        Scfr_Mov_Transacciones.Pt_Party_Id_Titular%TYPE;
    l_Party_Id_Nuevo  Scfr_Mov_Transacciones.Pt_Party_Id_Titular%TYPE;
    l_Party_Id_Amigo  Scfr_Mov_Transacciones.Pt_Party_Id_Titular%TYPE;
    l_Party_Id_Rel    Scfr_Mov_Transacciones.Pt_Party_Id_Titular%TYPE;
    l_Party_Id_Aux    Scfr_Mov_Transacciones.Pt_Party_Id_Titular%TYPE;
    l_Nombre_Respo    VARCHAR2(4000);
    l_Rut_Cliente     VARCHAR2(150);
    l_Rut_Cliente_Aux Scfr_Programas.Rut_Cliente%TYPE;
    l_Dvr_Cliente     VARCHAR2(1);
    l_Location_Id     NUMBER;
    l_Profile         NUMBER;
    l_Return_Status   VARCHAR2(4000);
    l_Msg_Data        VARCHAR2(4000);
    l_Campana         NUMBER;
    l_Contact_Id      NUMBER;
    l_Categoria       VARCHAR2(10);
    l_Existe          NUMBER;
    l_Tipo_Creacion   VARCHAR2(3);
    l_Rowid           UROWID;
    l_Id_Relacion     NUMBER;
    l_Folio_Tmcv      Scfr_Programas.Folio%TYPE;
    l_Dbg_Proceso     VARCHAR2(100) := 'SCFR_TRX_FID_PK.FIDI01';
    l_Dbg_Mensaje     VARCHAR2(250) := 'Error General';
    l_Cod_Error       NUMBER;
    l_Error_Controlado EXCEPTION;
    l_Cliente_Inscrito  NUMBER;
    l_Msg_Error         VARCHAR2(1000);
    l_Sql_Dyn           VARCHAR2(4000);
    l_Es_Mcv            VARCHAR2(10);
    p_Institucion_Salud VARCHAR2(5);
    l_Local_Habil       VARCHAR2(2) := 'NO';
    l_Es_Loyalty        BOOLEAN;
    l_Partie_Hz         NUMBER;
    l_tipo_identificacion varchar2(15);
    
  BEGIN
    l_Dbg_Mensaje := 'Obtener informaci?n de la trama DP (Datos Personales)';
    
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'DP') THEN
                                           
      l_Datos_Dp := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Dp(p_Transaccion.Cuerpo_Tx);
    ELSE
      l_Datos_Dp.Nombres          := 'CLIENTE INSCRITO SIN DATOS';
      l_Datos_Dp.Segundo_Nombre   := '.';
      l_Datos_Dp.Apellido_Paterno := ' ';
      l_Datos_Dp.Apellido_Materno := ' ';
      l_Datos_Dp.Sexo             := 'MAS';
      l_Datos_Dp.Fecha_Nacimiento := To_Number(To_Char(Scfr_Trx_Util_Pk.Get_Sysdate()
                                                      ,'yyyymmdd'));
    END IF;
    
    -- INI JAGC NEC 20240909
    -- Necesitadad de Salud
    Dbms_Output.Put_Line('NEC'); 
    Dbms_Output.Put_Line('l_Datos_Dp.Inscrito_Mas_Cruz_Verde' || l_Datos_Dp.Inscrito_Mas_Cruz_Verde || '- FIN');
    IF (p_Transaccion.Trama_Pos.Origen_Transaccion IN ('NEC'
                                                      ,'NEU', 'ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                                                      ,'TIN')) AND  --OR JAGC 20250116 PARA ECUADOR Inscrito_Mas_Cruz_Verde SIEMPRE LLEGA 'S' CUANDO INSCRIBE EN CUALQUIER GRUPO
       (l_Datos_Dp.Inscrito_Mas_Cruz_Verde = 'S') THEN
       
       Dbms_Output.Put_Line('l_Datos_Dp.Inscrito_Mas_Cruz_Verde ' || l_Datos_Dp.Inscrito_Mas_Cruz_Verde);
      --IF l_Es_Maicao = FALSE THEN
        Scfr_Necesidades_Salud_Pk.Inscripcion_Clientes(p_Transaccion => p_Transaccion
                                                      ,p_Datos_Dp    => l_Datos_Dp
                                                      ,x_Cod_Error   => l_Cod_Error
                                                      ,x_Msg_Error   => l_Msg_Error);
      --END IF;
    END IF;
    -- FIN JAGC NEC 20240909

    l_Dbg_Mensaje := 'Inscribir Cliente Loyalty';
    if LENGTH (TRIM (TRANSLATE (TRIM (p_Transaccion.Trama_Pos.Usuario_Responsable), ' +-.0123456789', ' '))) is null then
       l_tipo_identificacion := 'CI';

    else
       l_tipo_identificacion := 'PASSPORT';

    end if;    
    
    BEGIN
      Pkg_Geoloyalty.Proc_In_Cliente_Prog(p_Transaccion.Trama_Pos.Empresa
                                         ,p_Transaccion.Trama_Pos.Cadena
                                         ,Ltrim(Rtrim(p_Transaccion.Trama_Boc.Forma_Identificacion))
                                         ,Ltrim(Rtrim(p_Transaccion.Trama_Boc.String_Identificacion)) --l_Rut_Cliente || l_Dvr_Cliente
                                         ,l_Datos_Dp.Nombres
                                         ,l_Datos_Dp.Segundo_Nombre
                                         ,l_Datos_Dp.Apellido_Paterno
                                         ,l_Datos_Dp.Apellido_Materno
                                         ,l_Datos_Dp.Sexo
                                         ,'ECUADORIAN'
                                         ,'SINGLE'
                                         ,l_Datos_Dp.Email
                                         ,l_Datos_Dp.Fecha_Nacimiento
                                         ,p_Transaccion.Trama_Pos.Local
                                         ,p_Transaccion.Trama_Pos.Numero_Pos
                                         ,l_Datos_Dp.Telefono_Particularc
                                         ,l_Datos_Dp.Telefono_Celularc
                                         ,l_Datos_Dp.Direccion
                                         ,0
                                         ,l_Datos_Dp.Codigo_Region
                                         ,Fnc_Datos_Unificados('CIUDAD'
                                                              ,'POS'
                                                              ,l_Datos_Dp.Ciudad
                                                              ,p_Transaccion.Trama_Pos.Cadena
                                                              ,p_Transaccion.Trama_Pos.Empresa
                                                              ,p_Transaccion.Trama_Pos.Local)
                                         ,Fnc_Datos_Unificados('COMUNA'
                                                              ,'POS'
                                                              ,l_Datos_Dp.Comuna
                                                              ,p_Transaccion.Trama_Pos.Cadena
                                                              ,p_Transaccion.Trama_Pos.Empresa
                                                              ,p_Transaccion.Trama_Pos.Local)
                                         ,l_Datos_Dp.Inscrito_Mas_Cruz_Verde
                                         ,l_tipo_identificacion
                                         ,Ltrim(Rtrim(p_Transaccion.Trama_Pos.Usuario_Responsable))
                                         ,x_Cod_Error
                                         ,x_Msg_Error);

      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => '(LOYALTY) Respuesta : ' || x_Cod_Error || ' - ' || x_Msg_Error);

      Pkg_Geoloyalty.Pro_In_Group_Loyalty(p_Transaccion.Trama_Pos.Empresa
                                             ,p_Transaccion.Trama_Pos.Cadena
                                             ,p_Transaccion.Trama_Pos.Local
                                             ,p_Transaccion.Trama_Pos.Numero_Pos
                                             ,Ltrim(Rtrim(p_Transaccion.Trama_Boc.Forma_Identificacion))
                                             ,Ltrim(Rtrim(p_Transaccion.Trama_Boc.String_Identificacion))
                                             ,l_tipo_identificacion
                                             ,Ltrim(Rtrim(p_Transaccion.Trama_Pos.Usuario_Responsable))
                                             ,l_Datos_Dp
                                             ,x_Cod_Error
                                             ,x_Msg_Error);
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => '(LOYALTY) Respuesta Grupos : ' || x_Cod_Error || ' - ' || x_Msg_Error);
      x_Cod_Error := 0;
      x_Msg_Error := NULL;
    EXCEPTION
      WHEN OTHERS THEN
        Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                        ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                        ,x_Respuesta);
        Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => '(LOYALTY) Error al intentar ' || l_Dbg_Mensaje);
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
    END;
    --//-----------------------------------------------------------------Termino--\\
  EXCEPTION
    WHEN l_Error_Controlado THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
    WHEN OTHERS THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Fidi02(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Resultado   NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.FIDI02';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    
    -- INI JAGC NEC 20250312
    --l_Str_Identificacion      VARCHAR2(100);
    --l_Frm_Identificacion      VARCHAR2(10);
    --x_Cod_Error_nec           NUMBER;
    --l_Id_Consulta_Json        NUMBER;
    --rc                        SYS_REFCURSOR; 
    --l_Datos_Nc                NUMBER;
    l_Datos_Dp                Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp;
    x_Id_Consulta_Json     NUMBER;
    x_Id_Consulta_Json_Nec     NUMBER;-- JAGC NEC 09/09/2024
    x_Id_Sec_Lotalty       NUMBER;
    x_Cod_Error_nec           NUMBER;
    l_Cod_Error               NUMBER;
    l_Msg_Error               VARCHAR2(1000);
    -- FIN JAGC NEC 20250312
    
  BEGIN
    l_Dbg_Mensaje := 'Determinar Party ID';
    
    -- INI COM JAGC NEC 20240909   
    --l_Resultado   := Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
    --                                    ,p_Transaccion.Trama_Boc.String_Identificacion
    --                                    ,p_Transaccion.Trama_Pos.Empresa
    --                                    ,p_Transaccion.Trama_Pos.Cadena
    --                                    ,p_Transaccion.Trama_Boc.Party_Id);
    --IF l_Resultado != 0 THEN
    --  Raise_Application_Error(-20000
    --                         ,'Error=' || Abs(l_Resultado));
    --END IF;
    -- FIN COM JAGC NEC 20240909 
    
    -- FIN JAGC NEC 20250312         
    l_Datos_Dp := Scfr_Trx_Fid_Pk.Trama_Dp_Prepara(p_Transaccion
                                                           ,x_Id_Consulta_Json
                                                           ,x_Id_Consulta_Json_Nec-- JAGC NEC 09/09/2024
                                                           ,x_Id_Sec_Lotalty
                                                           ,x_Cod_Error
                                                           ,x_Msg_Error);
                                                           
    l_Datos_Dp.Fecha_Inscripcion := TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDD'));                                                     
    
    -- Necesitadad de Salud
    IF Nvl(x_Cod_Error
          ,0) = 0 THEN
      Dbms_Output.Put_Line('NEC'); 
      Dbms_Output.Put_Line('l_Datos_Dp.Inscrito_Mas_Cruz_Verde' || l_Datos_Dp.Inscrito_Mas_Cruz_Verde || '- FIN');
      IF (p_Transaccion.Trama_Pos.Origen_Transaccion IN ('NEC'
                                                        ,'NEU', 'ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                                                        ,'TIN')) AND  --OR JAGC 20250116 PARA ECUADOR Inscrito_Mas_Cruz_Verde SIEMPRE LLEGA 'S' CUANDO INSCRIBE EN CUALQUIER GRUPO
         (l_Datos_Dp.Inscrito_Mas_Cruz_Verde = 'S') THEN
         
         Dbms_Output.Put_Line('l_Datos_Dp.Inscrito_Mas_Cruz_Verde ' || l_Datos_Dp.Inscrito_Mas_Cruz_Verde);
        --IF l_Es_Maicao = FALSE THEN
          Scfr_Necesidades_Salud_Pk.Inscripcion_Clientes(p_Transaccion => p_Transaccion
                                                        ,p_Datos_Dp    => l_Datos_Dp
                                                        ,x_Cod_Error   => l_Cod_Error
                                                        ,x_Msg_Error   => l_Msg_Error);
        --END IF;
      END IF;
    END IF;  
    -- FIN JAGC NEC 20250312 
    
    Trama_Pb_Resuelve(p_Transaccion
                     ,x_Cod_Error
                     ,x_Msg_Error);
    Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                    ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                    ,x_Respuesta);
     
    -- INI JAGC NEC 20240909                               
    -- Necesitadad de Salud
  
    IF (p_Transaccion.Trama_Pos.Origen_Transaccion IN ('NEC'
                                                      ,'NEU', 'ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                                                      ,'TIN')) THEN
      Scfr_Necesidades_Salud_Pk.Trama_Ib_Resuelve(p_Transaccion
                                                 ,x_Cod_Error
                                                 ,x_Msg_Error);
                                                 
    -- FIN JAGC NEC 20240909
    END IF;                                
  EXCEPTION
    WHEN l_Error_Controlado THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
    WHEN OTHERS THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  /*
  * OBJETIVO
  *   Inscribir Producto en Comprea Frecuente
  * PARAMETROS
  *   p_transaccion  : Transacci?n recibida desde el pos
  *   x_cod_error    : C?digo de error retornado (0    en caso de no existir errores)
  *   x_msg_error    : Mesaje de error retornado (NULL en caso de no existir errores)
  */
  PROCEDURE Fidi03(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Resultado   NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.FIDI03';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Determinar Party id';
    l_Resultado   := Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                        ,p_Transaccion.Trama_Pos.Empresa
                                        ,p_Transaccion.Trama_Pos.Cadena
                                        ,p_Transaccion.Trama_Boc.Party_Id);
    IF l_Resultado != 0 THEN
      Raise_Application_Error(-20000
                             ,'Error=' || Abs(l_Resultado));
    END IF;
    Trama_Cz_Resuelve(p_Transaccion
                     ,x_Cod_Error
                     ,x_Msg_Error);
    Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                    ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Ok
                                    ,x_Respuesta);
  EXCEPTION
    WHEN l_Error_Controlado THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
    WHEN OTHERS THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  -- Inscripci?n red de amigos
  PROCEDURE Fidi06(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Resultado   NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_EXC_PK.FIDI06';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Determinar Party id';
    l_Resultado   := Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                        ,p_Transaccion.Trama_Pos.Empresa
                                        ,p_Transaccion.Trama_Pos.Cadena
                                        ,p_Transaccion.Trama_Boc.Party_Id);
    IF l_Resultado != 0 THEN
      x_Respuesta                                := NULL;
      p_Transaccion.Trama_Pos.Largo_Total_Buffer := Scfr_Trx_Util_Pk.k_Trama_Hbo_Largo;
      x_Respuesta                                := Scfr_Trx_Dyn_Pk.Arma_Trama_Pos(p_Transaccion);
      x_Cod_Error                                := -2000;
      x_Msg_Error                                := 'Error de Valida Party_id en transaccion';
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      RETURN;
    END IF;
    Trama_Ra_Resuelve(p_Transaccion
                     ,x_Cod_Error
                     ,x_Msg_Error);
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      RAISE l_Error_Controlado;
    END IF;
    Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                    ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Ok
                                    ,x_Respuesta);
  EXCEPTION
    WHEN l_Error_Controlado THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
    WHEN OTHERS THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Fidc01(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Dp Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp;
    --    l_trama_dc         scfr_trx_dyn_types_pk.rec_trama_dc;
    l_Resultado   NUMBER;
    l_Largo_t     NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_EXC_PK.FIDC01';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    x_Id_Consulta_Json NUMBER;
    x_Id_Consulta_Json_Nec NUMBER;-- JAGC NEC 09/09/2024
    l_Id_Sec_Lotalty   NUMBER;
  BEGIN
    l_Trama_Dp := Trama_Dp_Prepara(p_Transaccion
                                  ,x_Id_Consulta_Json
                                  ,x_Id_Consulta_Json_Nec-- JAGC NEC 09/09/2024
                                  ,l_Id_Sec_Lotalty
                                  ,x_Cod_Error
                                  ,x_Msg_Error);
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      RAISE l_Error_Controlado;
    END IF;
    --    l_trama_dc  := trama_dc_prepara (p_transaccion , x_cod_error , x_msg_error );
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      RAISE l_Error_Controlado;
    END IF;
    l_Dbg_Mensaje := 'Sumando Largos de las tramas';
    l_Largo_t     := Nvl(Utl_Raw.Length(Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Dp(l_Trama_Dp
                                                                         ,p_Transaccion.Trama_Pos.Origen_Transaccion))
                        ,0);
    --                     +nvl(utl_raw.length(scfr_trx_dyn_raw_pk.arma_trama_dc(l_trama_dc)),0) ;
    l_Dbg_Mensaje                              := 'Preparando Respuesta al Pos';
    x_Respuesta                                := NULL;
    p_Transaccion.Trama_Pos.Largo_Total_Buffer := Scfr_Trx_Util_Pk.k_Trama_Hbo_Largo + l_Largo_t;
    x_Respuesta                                := Scfr_Trx_Dyn_Pk.Arma_Trama_Pos(p_Transaccion);
    l_Dbg_Mensaje                              := 'Preparando Respuesta al BOC';
    p_Transaccion.Trama_Boc.Codigo_Respuesta   := 0;
    p_Transaccion.Trama_Boc.Largo_Total_Buffer := l_Largo_t;
    x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                ,Scfr_Trx_Dyn_Pk.Arma_Trama_Boc(p_Transaccion));
    l_Dbg_Mensaje                              := 'Preparando Antecedentes personales';
    x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Dp(l_Trama_Dp
                                                                                                  ,p_Transaccion.Trama_Pos.Origen_Transaccion));
    --   l_DBG_MENSAJE                          := 'Preparando Antecedentes comercial';
    --   x_respuesta   := utl_raw.CONCAT(x_respuesta,scfr_trx_dyn_raw_pk.arma_trama_dc(l_trama_dc));
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

  PROCEDURE Fidc02(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Pu    Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pu;
    l_Largo_t     NUMBER;
    l_Resultado   NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_EXC_PK.FIDC02';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Determinar Party ID';
    l_Resultado   := Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                        ,p_Transaccion.Trama_Pos.Empresa
                                        ,p_Transaccion.Trama_Pos.Cadena
                                        ,p_Transaccion.Trama_Boc.Party_Id);
    Obtiene_Rut(p_Transaccion.Trama_Boc.Party_Id
               ,p_Transaccion.Rut_Titular
               ,p_Transaccion.Dv_Rut_Titular);
    IF l_Resultado != 0 THEN
      x_Respuesta                                := NULL;
      p_Transaccion.Trama_Pos.Largo_Total_Buffer := Scfr_Trx_Util_Pk.k_Trama_Hbo_Largo;
      x_Respuesta                                := Scfr_Trx_Dyn_Pk.Arma_Trama_Pos(p_Transaccion);
      x_Cod_Error                                := l_Resultado;
      x_Msg_Error                                := 'Cliente No esta Fidelizados';
      RETURN;
    END IF;
    -- Cuerpo TX de RX
    l_Trama_Pu := Trama_Pu_Prepara(p_Transaccion
                                  ,x_Cod_Error
                                  ,x_Msg_Error);
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      RAISE l_Error_Controlado;
    END IF;
    l_Largo_t                                  := Nvl(Utl_Raw.Length(Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Pu(l_Trama_Pu
                                                                                                      ,p_Transaccion.Trama_Pos.Origen_Transaccion))
                                                     ,0);
    l_Dbg_Mensaje                              := 'Preparando Respuesta al Pos';
    x_Respuesta                                := NULL;
    p_Transaccion.Trama_Pos.Largo_Total_Buffer := Scfr_Trx_Util_Pk.k_Trama_Hbo_Largo + l_Largo_t;
    x_Respuesta                                := Scfr_Trx_Dyn_Pk.Arma_Trama_Pos(p_Transaccion);
    l_Dbg_Mensaje                              := 'Preparando Respuesta al BOC';
    p_Transaccion.Trama_Boc.Codigo_Respuesta   := 0;
    p_Transaccion.Trama_Boc.Largo_Total_Buffer := l_Largo_t;
    x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                ,Scfr_Trx_Dyn_Pk.Arma_Trama_Boc(p_Transaccion));
    l_Dbg_Mensaje                              := 'Preparando Antecedentes Trama PU';
    x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Pu(l_Trama_Pu
                                                                                                  ,p_Transaccion.Trama_Pos.Origen_Transaccion));
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

  PROCEDURE Fidc03(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Ct    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ct;
    l_Resultado   NUMBER;
    l_Largo_t     NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.FIDC03';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Determinar Party ID';
    l_Resultado   := Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                        ,p_Transaccion.Trama_Pos.Empresa
                                        ,p_Transaccion.Trama_Pos.Cadena
                                        ,p_Transaccion.Trama_Boc.Party_Id);
    Obtiene_Rut(p_Transaccion.Trama_Boc.Party_Id
               ,p_Transaccion.Rut_Titular
               ,p_Transaccion.Dv_Rut_Titular);
    l_Trama_Ct := Trama_Ct_Prepara(p_Transaccion
                                  ,x_Cod_Error
                                  ,x_Msg_Error);
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      RAISE l_Error_Controlado;
    END IF;
    l_Largo_t                                  := Utl_Raw.Length(Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Ct(l_Trama_Ct));
    l_Dbg_Mensaje                              := 'Armar respuesta POS';
    x_Respuesta                                := NULL;
    p_Transaccion.Trama_Pos.Largo_Total_Buffer := Scfr_Trx_Util_Pk.k_Trama_Hbo_Largo + l_Largo_t;
    x_Respuesta                                := Scfr_Trx_Dyn_Pk.Arma_Trama_Pos(p_Transaccion);
    l_Dbg_Mensaje                              := 'Armar respuesta BOS';
    p_Transaccion.Trama_Boc.Codigo_Respuesta   := 0;
    p_Transaccion.Trama_Boc.Largo_Total_Buffer := l_Largo_t;
    x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                ,Scfr_Trx_Dyn_Pk.Arma_Trama_Boc(p_Transaccion));
    l_Dbg_Mensaje                              := 'Armar Cuerpo de la trama';
    x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Ct(l_Trama_Ct));
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

  PROCEDURE Fidc04(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Pp    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pp;
    l_Largo       NUMBER;
    l_Resultado   NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_EXC_PK.FIDC04';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Determinar Party ID';
    l_Resultado   := Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                        ,p_Transaccion.Trama_Pos.Empresa
                                        ,p_Transaccion.Trama_Pos.Cadena
                                        ,p_Transaccion.Trama_Boc.Party_Id);
    IF l_Resultado != 0 THEN
      x_Respuesta                                := NULL;
      p_Transaccion.Trama_Pos.Largo_Total_Buffer := Scfr_Trx_Util_Pk.k_Trama_Hbo_Largo;
      x_Respuesta                                := Scfr_Trx_Dyn_Pk.Arma_Trama_Pos(p_Transaccion);
      x_Cod_Error                                := l_Resultado;
      x_Msg_Error                                := 'Cliente No esta Fidelizados';
      RETURN;
    END IF;
    l_Dbg_Mensaje := 'Obtener informaci?n de la trama pp';
    l_Trama_Pp    := Trama_Pp_Prepara(p_Transaccion
                                     ,x_Cod_Error
                                     ,x_Msg_Error);
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      RAISE l_Error_Controlado;
    END IF;
    l_Largo     := Nvl(Utl_Raw.Length(Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Pp(l_Trama_Pp))
                      ,0);
    l_Resultado := 0;
    IF l_Largo = 0 THEN
      l_Resultado := 1;
    END IF;
    x_Respuesta                                := NULL;
    p_Transaccion.Trama_Pos.Largo_Total_Buffer := Scfr_Trx_Util_Pk.k_Trama_Hbo_Largo + l_Largo;
    x_Respuesta                                := Scfr_Trx_Dyn_Pk.Arma_Trama_Pos(p_Transaccion);
    p_Transaccion.Trama_Boc.Codigo_Respuesta   := 0;
    p_Transaccion.Trama_Boc.Largo_Total_Buffer := l_Largo;
    x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                ,Scfr_Trx_Dyn_Pk.Arma_Trama_Boc(p_Transaccion));
    IF l_Largo > 0 THEN
      l_Dbg_Mensaje := 'Prepara Respuesta';
      x_Respuesta   := Utl_Raw.Concat(x_Respuesta
                                     ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Pp(l_Trama_Pp));
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

  PROCEDURE Fidc05(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Ps    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ps;
    l_Tabla_Pf    BLOB;
    l_Party_Id    Scfr_Mov_Transacciones.Pt_Party_Id_Titular%TYPE;
    l_Resultado   NUMBER;
    l_Aux         NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.FIDC05';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Obteniendo Party id trama PS';
    l_Resultado   := Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                        ,p_Transaccion.Trama_Pos.Empresa
                                        ,p_Transaccion.Trama_Pos.Cadena
                                        ,p_Transaccion.Trama_Boc.Party_Id);
    l_Trama_Ps    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Ps(p_Transaccion.Cuerpo_Tx);
    IF l_Resultado <> 0 THEN
      l_Trama_Ps := NULL;
      RETURN;
    END IF;
    /*
        scfr_pprog_salud_pk.productos_fidelizados( p_transaccion.trama_boc.party_id
                                                 , p_transaccion.trama_pos.empresa
                                                 , l_tabla_pf
                                                 , l_aux);
    */
    l_Dbg_Mensaje                              := 'Armando Trama Del POS';
    x_Respuesta                                := NULL;
    p_Transaccion.Trama_Pos.Largo_Total_Buffer := Scfr_Trx_Util_Pk.k_Trama_Hbo_Largo + l_Aux;
    x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                ,Scfr_Trx_Dyn_Pk.Arma_Trama_Pos(p_Transaccion));
    Dbms_Output.Put_Line(l_Dbg_Mensaje);
    l_Dbg_Mensaje                              := 'Armando Trama Del Boc';
    p_Transaccion.Trama_Boc.Codigo_Respuesta   := 0;
    p_Transaccion.Trama_Boc.Largo_Total_Buffer := l_Aux;
    x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                ,Scfr_Trx_Dyn_Pk.Arma_Trama_Boc(p_Transaccion));
    Dbms_Output.Put_Line(l_Dbg_Mensaje);
    l_Dbg_Mensaje := 'Armando cuerpo pf';
    x_Respuesta   := Utl_Raw.Concat(x_Respuesta
                                   ,l_Tabla_Pf);
    Dbms_Output.Put_Line(l_Dbg_Mensaje);
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Fidc06(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Fs    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Fs;
    l_Tabla_Cf    BLOB;
    l_Party_Id    Scfr_Mov_Transacciones.Pt_Party_Id_Titular%TYPE;
    l_Resultado   NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.FIDC06';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    l_Aux    NUMBER;
    i        NUMBER;
    l_Factor NUMBER;
  BEGIN
    l_Dbg_Mensaje := 'Obtiendo Party id Trama FS';
    l_Resultado   := Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                        ,p_Transaccion.Trama_Pos.Empresa
                                        ,p_Transaccion.Trama_Pos.Cadena
                                        ,p_Transaccion.Trama_Boc.Party_Id);
    l_Trama_Fs    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Fs(p_Transaccion.Cuerpo_Tx);
    IF l_Resultado <> 0 THEN
      l_Tabla_Cf := NULL;
      RETURN;
    END IF;
    /*
      scfr_pprog_salud_pk.compra_frecuente( p_transaccion.trama_boc.party_id
                                          , p_transaccion.trama_pos.empresa
                                          , l_tabla_cf
                                          , l_aux);
    */
    IF Nvl(Utl_Raw.Length(l_Tabla_Cf)
          ,0) > 0 THEN
      l_Resultado := 0;
    ELSE
      l_Resultado := 1;
    END IF;
    l_Dbg_Mensaje                              := 'Armando Trama Del POS';
    x_Respuesta                                := NULL;
    p_Transaccion.Trama_Pos.Largo_Total_Buffer := Scfr_Trx_Util_Pk.k_Trama_Hbo_Largo + l_Aux;
    x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                ,Scfr_Trx_Dyn_Pk.Arma_Trama_Pos(p_Transaccion));
    Dbms_Output.Put_Line(l_Dbg_Mensaje);
    l_Dbg_Mensaje                              := 'Armando Trama Del Boc';
    p_Transaccion.Trama_Boc.Codigo_Respuesta   := l_Resultado;
    p_Transaccion.Trama_Boc.Largo_Total_Buffer := l_Aux;
    x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                ,Scfr_Trx_Dyn_Pk.Arma_Trama_Boc(p_Transaccion));
    IF Nvl(l_Resultado
          ,0) > 0 THEN
      Dbms_Output.Put_Line(l_Dbg_Mensaje);
      l_Dbg_Mensaje := 'Armando cuerpo pf';
      x_Respuesta   := Utl_Raw.Concat(x_Respuesta
                                     ,l_Tabla_Cf);
      Dbms_Output.Put_Line(l_Dbg_Mensaje);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Fidc08(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Cg      Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cg;
    l_Resultado     NUMBER;
    l_Total_Cupones NUMBER;
    l_Largo_Ctx     NUMBER;
    l_Cuerpo_Tx     BLOB;
    l_Dbg_Proceso   VARCHAR2(100) := 'SCFR_TRX_FID_PK.FIDC08';
    l_Dbg_Mensaje   VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Determinar Party id trama CG';
    l_Resultado   := Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                        ,p_Transaccion.Trama_Pos.Empresa
                                        ,p_Transaccion.Trama_Pos.Cadena
                                        ,p_Transaccion.Trama_Boc.Party_Id);
    l_Dbg_Mensaje := 'Preparar datos para la trama CG (Cupones Genericos)';
    l_Trama_Cg    := Trama_Cg_Prepara(p_Transaccion
                                     ,x_Cod_Error
                                     ,x_Msg_Error);
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      RAISE l_Error_Controlado;
    END IF;
    l_Dbg_Mensaje := 'Armar Respuesta para trama CG (Cupones Genericos)';
    l_Cuerpo_Tx   := NULL;
    IF l_Trama_Cg.Count > 0 THEN
      l_Cuerpo_Tx := Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Cg(l_Trama_Cg);
    END IF;
    l_Largo_Ctx := Nvl(Dbms_Lob.Getlength(l_Cuerpo_Tx)
                      ,0);
    l_Resultado := 1;
    IF l_Largo_Ctx > 0 THEN
      l_Resultado := 0;
    END IF;
    l_Dbg_Mensaje                              := 'Armar Trama POS';
    p_Transaccion.Trama_Pos.Largo_Total_Buffer := l_Largo_Ctx + Scfr_Trx_Dyn_Pk.Obtiene_Largo_Trama(Scfr_Trx_Dyn_Pk.k_Trama_Header_Boc);
    x_Respuesta                                := Scfr_Trx_Dyn_Pk.Arma_Trama_Pos(p_Transaccion);
    l_Dbg_Mensaje                              := 'Armar Trama BOC';
    p_Transaccion.Trama_Boc.Codigo_Respuesta   := l_Resultado;
    p_Transaccion.Trama_Boc.Largo_Total_Buffer := l_Largo_Ctx;
    x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                ,Scfr_Trx_Dyn_Pk.Arma_Trama_Boc(p_Transaccion));
    IF l_Largo_Ctx > 0 THEN
      l_Dbg_Mensaje := 'Armando transacci?n final';
      x_Respuesta   := Utl_Raw.Concat(x_Respuesta
                                     ,l_Cuerpo_Tx);
    END IF;
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Fidc09(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Resultado   NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.FIDC08';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Determinar Party id y estado de la tarjeta';
    IF p_Transaccion.Trama_Boc.Forma_Identificacion = k_Por_Codigo_Barra THEN
      l_Resultado := Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                        ,p_Transaccion.Trama_Pos.Empresa
                                        ,p_Transaccion.Trama_Pos.Cadena
                                        ,p_Transaccion.Trama_Boc.Party_Id);
    ELSE
      l_Resultado := -1;
    END IF;
    l_Dbg_Mensaje                              := 'Armar Trama POS';
    p_Transaccion.Trama_Pos.Largo_Total_Buffer := Scfr_Trx_Dyn_Pk.Obtiene_Largo_Trama(Scfr_Trx_Dyn_Pk.k_Trama_Header_Boc);
    x_Respuesta                                := Scfr_Trx_Dyn_Pk.Arma_Trama_Pos(p_Transaccion);
    l_Dbg_Mensaje                              := 'Armar Trama BOC';
    p_Transaccion.Trama_Boc.Codigo_Respuesta   := Abs(l_Resultado);
    p_Transaccion.Trama_Boc.Largo_Total_Buffer := 0;
    x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                ,Scfr_Trx_Dyn_Pk.Arma_Trama_Boc(p_Transaccion));
  END;

  PROCEDURE Fidu01(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Party_Bene  Scfr_Mov_Transacciones.Pt_Party_Id_Titular%TYPE;
    l_Trama_Pd    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pd;
    l_Resultado   NUMBER;
    l_Aux         NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_EXC_PK.FIDU01';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Obtencion de Party_id donante ';
    l_Resultado   := Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                        ,p_Transaccion.Trama_Pos.Empresa
                                        ,p_Transaccion.Trama_Pos.Cadena
                                        ,p_Transaccion.Trama_Boc.Party_Id);
    IF l_Resultado != 0 THEN
      x_Cod_Error := -2000;
      x_Msg_Error := 'Error de Valida Party_id en transaccion';
      RETURN;
    END IF;
    Trama_Pd_Resuelve(p_Transaccion
                     ,x_Cod_Error
                     ,x_Msg_Error);
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      RAISE l_Error_Controlado;
    END IF;
    Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                    ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Ok
                                    ,x_Respuesta);
  EXCEPTION
    WHEN l_Error_Controlado THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
    WHEN OTHERS THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Fidu02(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Resultado   NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_EXC_PK.FIDU02';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Obtencion de Party_id donante ';
    l_Resultado   := Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                        ,p_Transaccion.Trama_Pos.Empresa
                                        ,p_Transaccion.Trama_Pos.Cadena
                                        ,p_Transaccion.Trama_Boc.Party_Id);
    IF l_Resultado != 0 THEN
      x_Cod_Error := -2000;
      x_Msg_Error := ':Error en descomposici?n transacci?n.Party Id no se puede convertir';
      RETURN;
    END IF;
    Trama_Pt_Resuelve(p_Transaccion
                     ,x_Cod_Error
                     ,x_Msg_Error);
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      RAISE l_Error_Controlado;
    END IF;
    Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                    ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Ok
                                    ,x_Respuesta);
  EXCEPTION
    WHEN l_Error_Controlado THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
    WHEN OTHERS THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Fidu03(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Party_Bene  NUMBER;
    l_Resultado   NUMBER;
    l_Aux         NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_EXC_PK.FIDU03';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_General EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Obtencion de Party_id donante ';
    l_Resultado   := Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                        ,p_Transaccion.Trama_Pos.Empresa
                                        ,p_Transaccion.Trama_Pos.Cadena
                                        ,p_Transaccion.Trama_Boc.Party_Id);
    IF l_Resultado != 0 THEN
      x_Cod_Error := -2000;
      x_Msg_Error := ':Error en descomposici?n transacci?n.Party Id no se puede convertir';
      RETURN;
    END IF;
    IF Rtrim(Ltrim(p_Transaccion.Trama_Boc.Forma_Identificacion)) IN ('B'
                                                                     ,'C') THEN
      l_Dbg_Mensaje := 'Actualizacion de scfr_programas ';
      UPDATE Scfr_Programas
         SET Estado_Tarjeta = 'INA'
       WHERE Pt_Party_Id = p_Transaccion.Trama_Boc.Party_Id
         AND Folio = p_Transaccion.Trama_Boc.String_Identificacion
         AND Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
         AND Cad_Cadena = p_Transaccion.Trama_Pos.Cadena;
    END IF;
    Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                    ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Ok
                                    ,x_Respuesta);
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Fidu05(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Cd  Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Cd;
    l_Party_Id  Scfr_Mov_Transacciones.Pt_Party_Id_Titular%TYPE;
    l_Resultado NUMBER;
    l_Aux       NUMBER;
    l_Codigo    NUMBER;
    --
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_EXC_PK.FIDU05';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Obtencion de Party_id donante ';
    l_Resultado   := Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                        ,p_Transaccion.Trama_Pos.Empresa
                                        ,p_Transaccion.Trama_Pos.Cadena
                                        ,p_Transaccion.Trama_Boc.Party_Id);
    IF l_Resultado != 0 THEN
      x_Cod_Error := -2000;
      x_Msg_Error := ':Error en descomposici?n transacci?n.Party Id no se puede convertir';
      RETURN;
    END IF;
    l_Dbg_Mensaje := 'Resuelvo trama  cd';
    Trama_Cd_Resuelve(p_Transaccion
                     ,x_Cod_Error
                     ,x_Msg_Error);
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      RAISE l_Error_Controlado;
    END IF;
    Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                    ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Ok
                                    ,x_Respuesta);
  EXCEPTION
    WHEN l_Error_Controlado THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
    WHEN OTHERS THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Fidu07(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Resultado   NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.fidu07';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error No Determinado';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Determinar party ID de acuerdo a la forma de identificaci?n utilizada';
    l_Resultado   := Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                        ,p_Transaccion.Trama_Pos.Empresa
                                        ,p_Transaccion.Trama_Pos.Cadena
                                        ,p_Transaccion.Trama_Boc.Party_Id);
    IF l_Resultado != 0 THEN
      RAISE l_Error_Controlado;
    END IF;
    -- Resuelve trama tp
    l_Dbg_Mensaje := 'LLamar a trama_tp_resuelve';
    Trama_Tp_Resuelve(p_Transaccion
                     ,x_Cod_Error
                     ,x_Msg_Error);
    Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                    ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Ok
                                    ,x_Respuesta);
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  PROCEDURE Fidu08(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Resultado   NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.fidu07';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error No Determinado';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Determinar party ID de acuerdo a la forma de identificaci?n utilizada';
    l_Resultado   := Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                        ,p_Transaccion.Trama_Pos.Empresa
                                        ,p_Transaccion.Trama_Pos.Cadena
                                        ,p_Transaccion.Trama_Boc.Party_Id);
    IF l_Resultado != 0 THEN
      RAISE l_Error_Controlado;
    END IF;
    -- Resuelve trama TP
    Trama_Ta_Resuelve(p_Transaccion
                     ,x_Cod_Error
                     ,x_Msg_Error);
    Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                    ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Ok
                                    ,x_Respuesta);
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END;

  PROCEDURE Trama_Ae_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Ae    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ae;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.trama_ae_resuelve';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    l_Rut_Cliente           VARCHAR2(15);
    l_Existe_Opcion         NUMBER;
    l_Lista_Cliente_Campana NUMBER;
    l_Party_Id              NUMBER;
    l_Campana_Tcv_Dormidos  VARCHAR2(2) := 'NO';
    k_Opcion_Quiere         NUMBER := 1;
    k_No_Quiere             NUMBER := 2;
    k_No_Me_Gusta           NUMBER := 4;
    k_Otros_Medios          NUMBER := 5;
    k_Beneficio             NUMBER := 6;
    l_Restriccion_Global    NUMBER;
    l_Contador_Total        NUMBER;
    CURSOR Lista_Campanas(p_Campana IN NUMBER) IS
      SELECT Slc.Listas_Clientes
        FROM Scfr_Campanas                 Sc
            ,Scfr_Listas_Clientes_Campanas Slcc
            ,Scfr_Listas_Clientes          Slc
       WHERE Sc.Campana = p_Campana
         AND Slc.Vigencia = 'SI'
         AND Sc.Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
         AND Sc.Emp_Codigo = p_Transaccion.Trama_Pos.Empresa
         AND (Trunc(Slc.Fecha_Creacion) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) AND
             Trunc(Nvl(Slc.Fecha_Termino
                       ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) AND
             Trunc(Slcc.Fecha_Asociacion) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) AND
             Trunc(Nvl(Slcc.Fecha_Termino
                       ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()))
         AND ((Sc.Campana = Slcc.Cam_Campana) AND (Slcc.Sle_Listas_Clientes = Slc.Listas_Clientes));
  BEGIN
    x_Cod_Error := 0;
    -- Obtiene informacion de la trama AE
    l_Dbg_Mensaje := 'Obtener informacion de la trama AE';
    l_Trama_Ae    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Ae(p_Transaccion.Cuerpo_Tx);
    BEGIN
      SELECT 1
        INTO l_Existe_Opcion
        FROM Scfr_Reg_Opcion_Solicitud
       WHERE Numero_Preventa = l_Trama_Ae.Numero_Preventa
         AND Loc_Local = p_Transaccion.Trama_Pos.Local;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Existe_Opcion := 0;
    END;
    -- *
    l_Rut_Cliente := Ltrim(Rtrim(p_Transaccion.Trama_Boc.String_Identificacion));
    l_Rut_Cliente := Substr(l_Rut_Cliente
                           ,1
                           ,Length(l_Rut_Cliente) - 1);
    IF (l_Existe_Opcion = 0) THEN
      -- inserta datos
      INSERT INTO Scfr_Reg_Opcion_Solicitud
        (Correlativo
        ,Rut_Cliente
        ,Cam_Campana
        ,Fecha_Hora_Desp
        ,Fecha_Hora_Cap
        ,Rut_Vendedor
        ,Rut_Qf
        ,Opcion_Seleccionada
        ,Vb_Qf
        ,Loc_Local
        ,Numero_Preventa
        ,Txo_Codigo_Tx
        ,Fecha_Recepcion_Opcion
        ,Reintento_Vendedor
        ,Motivo_Rechazo)
      VALUES
        (Scfr_Reg_Opcion_Solicitud_s.Nextval --correlativo
        ,l_Rut_Cliente --rut_cliente
        ,l_Trama_Ae.Campana --cam_campana
        ,To_Date(Substr(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                       ,1
                       ,8) || l_Trama_Ae.Hora_Presentacion_Pop_Up
                ,'yyyymmddhh24miss') --fecha_hora_desp
        ,To_Date(Substr(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                       ,1
                       ,8) || l_Trama_Ae.Hora_Seleccion_Opcion
                ,'yyyymmddhh24miss') --fecha_hora_cap
        ,p_Transaccion.Trama_Pos.Usuario_Responsable --rut_vendedor
        ,NULL --rut_qf
        ,l_Trama_Ae.Opcion_Seleccionada --opcion_seleccionada
        ,NULL --vb_qf
        ,p_Transaccion.Trama_Pos.Local --loc_local
        ,l_Trama_Ae.Numero_Preventa --numero_preventa
        ,NULL --txo_codigo_tx
        ,Scfr_Trx_Util_Pk.Get_Sysdate
        ,l_Trama_Ae.Reintento_Vendedor
        ,l_Trama_Ae.Motivo_Rechazo);

      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Trama AE resuelta correctamente');
    ELSE
      UPDATE Scfr_Reg_Opcion_Solicitud
         SET Opcion_Seleccionada = l_Trama_Ae.Opcion_Seleccionada
            ,Reintento_Vendedor  = l_Trama_Ae.Reintento_Vendedor
            ,Motivo_Rechazo      = l_Trama_Ae.Motivo_Rechazo
       WHERE Numero_Preventa = l_Trama_Ae.Numero_Preventa
         AND Loc_Local = p_Transaccion.Trama_Pos.Local;
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Trama AE resuelta correctamente');
    END IF; -- if  (l_existe_opcion = 0) then
    -- Busca tipo campa?a para expiracion Clientes TCV Dormidos.
    BEGIN
      SELECT 'SI'
        INTO l_Campana_Tcv_Dormidos
        FROM Scfr_Condiciones
       WHERE Cam_Campana = l_Trama_Ae.Campana
         AND Tipo_Condicion = 'PTD'
         AND Rownum = 1;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Campana_Tcv_Dormidos := 'NO';
    END;
    -- Comprueba maximo de preguntas realizadas al usuario para expiracion de clientes en campa?a de descuento
    l_Party_Id := Scfr_Trx_Util_Pk.Obtiene_Party_Id(To_Number(l_Rut_Cliente));
    -- cespejo -- IF (l_campana_tcv_dormidos = 'SI') THEN
    -- *
    l_Dbg_Mensaje := 'Obtener cantidad de opciones Utiliza y no Utiliza totales que registra el cliente';
    SELECT COUNT(*)
      INTO l_Contador_Total
      FROM Scfr_Reg_Opcion_Solicitud
     WHERE Rut_Cliente = To_Number(l_Rut_Cliente)
       AND Cam_Campana = l_Trama_Ae.Campana
       AND Opcion_Seleccionada IN (k_Opcion_Quiere
                                  ,k_No_Quiere
                                  ,k_No_Me_Gusta
                                  ,k_Otros_Medios
                                  ,k_Beneficio);
    l_Dbg_Mensaje := 'Obtener las veces totales maximas';
    BEGIN
      SELECT Restriccion_Minima
        INTO l_Restriccion_Global
        FROM Scfr_Condiciones
       WHERE Cam_Campana = l_Trama_Ae.Campana
         AND Tipo_Condicion = 'TCO';
    EXCEPTION
      WHEN OTHERS THEN
        l_Restriccion_Global := NULL;
    END;
    -- *
    IF (l_Contador_Total >= l_Restriccion_Global) THEN
      -- Obtiene numero de lista
      FOR Reg IN Lista_Campanas(l_Trama_Ae.Campana)
      LOOP
        l_Lista_Cliente_Campana := Nvl(Reg.Listas_Clientes
                                      ,0);
        -- actualiza vigencia clientes.
        UPDATE Scfr_Deta_List_Clientes
           SET Fecha_Expiracion = Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) - 1
         WHERE Rut_Cliente = To_Number(l_Rut_Cliente)
           AND Sle_Listas_Clientes = l_Lista_Cliente_Campana;
      END LOOP;
      -- *
    END IF; -- if (l_contador_total >= l_restriccion_global) then
    -- cespejo -- END IF; -- IF (levanta_campana(l_party_id,l_campana) = 'NO') THEN
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
  END Trama_Ae_Resuelve;

  PROCEDURE Trama_Qf_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Qf    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Qf;
    l_Trama_Ae    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ae;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.trama_qf_resuelve';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    l_Rut_Cliente           NUMBER;
    l_Campana               NUMBER;
    l_Lista_Cliente_Campana NUMBER;
    l_Party_Id              NUMBER;
    l_Campana_Tcv_Dormidos  VARCHAR2(2) := 'NO';
    k_Opcion_Quiere         NUMBER := 1;
    k_No_Quiere             NUMBER := 2;
    k_No_Me_Gusta           NUMBER := 4;
    k_Otros_Medios          NUMBER := 5;
    k_Beneficio             NUMBER := 6;
    l_Restriccion_Global    NUMBER;
    l_Contador_Total        NUMBER;
    CURSOR Lista_Campanas(p_Campana IN NUMBER) IS
      SELECT Slc.Listas_Clientes
        FROM Scfr_Campanas                 Sc
            ,Scfr_Listas_Clientes_Campanas Slcc
            ,Scfr_Listas_Clientes          Slc
       WHERE Sc.Campana = p_Campana
         AND Slc.Vigencia = 'SI'
         AND Sc.Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
         AND Sc.Emp_Codigo = p_Transaccion.Trama_Pos.Empresa
         AND (Trunc(Slc.Fecha_Creacion) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) AND
             Trunc(Nvl(Slc.Fecha_Termino
                       ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) AND
             Trunc(Slcc.Fecha_Asociacion) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) AND
             Trunc(Nvl(Slcc.Fecha_Termino
                       ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()))
         AND ((Sc.Campana = Slcc.Cam_Campana) AND (Slcc.Sle_Listas_Clientes = Slc.Listas_Clientes));
  BEGIN
    x_Cod_Error := 0;
    -- Obtiene informacion de la trama AE
    l_Dbg_Mensaje := 'Obtener informacion de la trama QF';
    l_Trama_Qf    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Qf(p_Transaccion.Cuerpo_Tx);
    l_Trama_Ae    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Ae(p_Transaccion.Cuerpo_Tx); -- CTM 26-09-2016.
    -- datos
    UPDATE Scfr_Reg_Opcion_Solicitud
       SET Rut_Qf             = l_Trama_Qf.Rut_Qf
          ,Vb_Qf              = l_Trama_Qf.Autorizacion_Qf
          ,Fecha_Recepcion_Qf = Scfr_Trx_Util_Pk.Get_Sysdate
     WHERE Loc_Local = p_Transaccion.Trama_Pos.Local
       AND Numero_Preventa = l_Trama_Qf.Numero_Preventa;
    IF SQL%NOTFOUND THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'No se pudo actualizar scfr_reg_opcion_solicitud a partir de trama QF');
    END IF;
    -- *
    BEGIN
      SELECT Rut_Cliente
            ,Cam_Campana
        INTO l_Rut_Cliente
            ,l_Campana
        FROM Scfr_Reg_Opcion_Solicitud
       WHERE Loc_Local = p_Transaccion.Trama_Pos.Local
         AND Numero_Preventa = l_Trama_Qf.Numero_Preventa;
    EXCEPTION
      WHEN OTHERS THEN
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => 'No se pudo obtener rut_cliente y campana');
        l_Rut_Cliente := NULL;
        l_Campana     := NULL;
    END;
    -- Busca tipo campa?a para expiracion Clientes TCV Dormidos.
    BEGIN
      SELECT 'SI'
        INTO l_Campana_Tcv_Dormidos
        FROM Scfr_Condiciones
       WHERE Cam_Campana = l_Campana
         AND Tipo_Condicion = 'PTD'
         AND Rownum = 1;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Campana_Tcv_Dormidos := 'NO';
    END;
    -- *
    l_Party_Id := Scfr_Trx_Util_Pk.Obtiene_Party_Id(To_Number(l_Rut_Cliente));
    -- Obtiene numero de lista
    IF l_Trama_Qf.Autorizacion_Qf = 'SI' THEN
      IF (l_Campana_Tcv_Dormidos = 'SI') THEN
        -- actualiza vigencia clientes.
        FOR Reg IN Lista_Campanas(l_Campana)
        LOOP
          l_Lista_Cliente_Campana := Nvl(Reg.Listas_Clientes
                                        ,0);
          -- actualiza vigencia clientes.
          UPDATE Scfr_Deta_List_Clientes
             SET Fecha_Expiracion = Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) - 1
           WHERE Rut_Cliente = To_Number(l_Rut_Cliente)
             AND Sle_Listas_Clientes = l_Lista_Cliente_Campana;
          IF SQL%NOTFOUND THEN
            Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                      ,p_Msg     => 'No se pudo actualizar scfr_deta_list_clientes');
          END IF;
        END LOOP;
      END IF; -- if (l_Campana_TCV_dormidos = 'SI') then
      -- Actualiza tabla scfr_activa_tarjeta
      -- CTM 26-09-2016
      -- Si respuesta de QF=SI y si opcion seleccionada por el vendedor = 1 y si el motivo
      -- de rechazo por parte de Solventa = 000, entonces cambio el estado a ACT.
      IF l_Trama_Qf.Autorizacion_Qf = 'SI' AND
         l_Trama_Ae.Opcion_Seleccionada = 1 AND
         ((TRIM(l_Trama_Ae.Motivo_Rechazo) = '000' AND p_Transaccion.Trama_Pos.Origen_Transaccion = 'SOL') OR
         p_Transaccion.Trama_Pos.Origen_Transaccion <> 'SOL') THEN

        UPDATE Scfr_Activa_Tarjeta
           SET Estado           = 'ACT'
              ,Fecha_Activacion = Scfr_Trx_Util_Pk.Get_Sysdate
         WHERE Rut_Cliente = l_Rut_Cliente
           AND Cam_Campana = l_Campana;

        IF SQL%NOTFOUND THEN
          Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                    ,p_Msg     => 'No se pudo actualizar scfr_activa_tarjeta');
        END IF;
      END IF; -- CTM 26-09-2016
    ELSE
      -- IF l_trama_qf.autorizacion_qf = 'SI' THEN
      -- Comprueba maximo de preguntas realizadas al usuario para expiracion de clientes en campa?a de descuento
      -- cespejo inicioIF (l_campana_tcv_dormidos = 'SI') THEN
      l_Dbg_Mensaje := 'Obtener cantidad de opciones Utiliza y no Utiliza totales que registra el cliente';
      SELECT COUNT(*)
        INTO l_Contador_Total
        FROM Scfr_Reg_Opcion_Solicitud
       WHERE Rut_Cliente = l_Rut_Cliente
         AND Cam_Campana = l_Campana
         AND Opcion_Seleccionada IN (k_Opcion_Quiere
                                    ,k_No_Quiere
                                    ,k_No_Me_Gusta
                                    ,k_Otros_Medios
                                    ,k_Beneficio);
      l_Dbg_Mensaje := 'Obtener las veces totales maximas';
      BEGIN
        SELECT Restriccion_Minima
          INTO l_Restriccion_Global
          FROM Scfr_Condiciones
         WHERE Cam_Campana = l_Campana
           AND Tipo_Condicion = 'TCO';
      EXCEPTION
        WHEN OTHERS THEN
          l_Restriccion_Global := NULL;
      END;
      -- *
      IF (l_Contador_Total >= l_Restriccion_Global) THEN
        -- actualiza vigencia clientes.
        FOR Reg IN Lista_Campanas(l_Campana)
        LOOP
          l_Lista_Cliente_Campana := Nvl(Reg.Listas_Clientes
                                        ,0);
          -- actualiza vigencia clientes.
          UPDATE Scfr_Deta_List_Clientes
             SET Fecha_Expiracion = Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) - 1
           WHERE Rut_Cliente = To_Number(l_Rut_Cliente)
             AND Sle_Listas_Clientes = l_Lista_Cliente_Campana;
        END LOOP;
      END IF; -- if (l_contador_total >= l_restriccion_global) then
      -- *
      --cespejo fin END IF; -- IF (levanta_campana(l_party_id,l_campana) = 'NO') THEN
    END IF;
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Trama QF resuelta correctamente');
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
  END Trama_Qf_Resuelve;

  PROCEDURE Actualiza_Direccion(p_Location_Id   IN NUMBER
                               ,p_Comuna        IN VARCHAR2
                               ,p_Ciudad        IN VARCHAR2
                               ,p_Numero        IN VARCHAR2
                               ,p_Calle         IN VARCHAR2
                               ,p_Depto         IN VARCHAR2
                               ,p_Block         IN VARCHAR2
                               ,p_Poblacion     IN VARCHAR2
                               ,p_Responsable   IN VARCHAR2
                               ,x_Return_Status OUT VARCHAR2
                               ,x_Msg_Data      OUT VARCHAR2) IS
    l_Sql_Dyn VARCHAR2(4000);
    l_Sqlcode NUMBER;
    l_Sqlerrm VARCHAR2(250);
  BEGIN
    l_Sql_Dyn := 'begin' || '  scfr_clientes_pk.actualiza_direccion( p_location_id     => :1' || ' , p_calle           => :2' ||
                 ' , p_numero          => :3' || ' , p_depto           => :4' || ' , p_block           => :5' || ' , p_poblacion       => :6' ||
                 ' , p_sector          => NULL' || ' , p_comuna          => :7' || ' , p_ciudad          => :8' || ' , p_region          => NULL' ||
                 ' , p_pais            => :9' || ' , p_codigo_postal   => NULL' || ' , p_zona            => NULL' || ' , p_actualizado_por => :10' ||
                 ' , x_return_status   => :11' || ' , x_msg_data        => :12' || ' );' || 'end;';
    -- ejecuta procedimiento dinamicamente
    --    EXECUTE IMMEDIATE l_Sql_Dyn
    --      USING IN p_Location_Id, IN p_Calle, IN p_Numero, IN p_Depto, IN p_Block, IN p_Poblacion, IN p_Comuna, IN p_Ciudad, IN 'CL', IN p_Responsable, OUT x_Return_Status, OUT x_Msg_Data;
  EXCEPTION
    WHEN OTHERS THEN
      -- chequea si se encontro la rutina referenciada en el sql dinamico
      -- el error -6550 indica que la rutina a ejecutar debe ser definida.
      l_Sqlcode := SQLCODE;
      l_Sqlerrm := SQLERRM;
      IF SQLCODE IN (-6550
                    ,-04052
                    ,-04068
                    ,6550
                    ,04052
                    ,04068) THEN
        -- asigna error para controlar en rutina anterior
        x_Return_Status := 'E';
        x_Msg_Data      := k_Error_Ebso;
      ELSE
        -- reenvia el error a rutina anterior
        RAISE;
      END IF;
  END Actualiza_Direccion;

  PROCEDURE Trama_Ad_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Ad    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Ad;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.trama_ad_resuelve';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    l_Return_Status VARCHAR2(10);
    l_Msg_Data      VARCHAR2(1000);
    l_Party_Id_Rel  NUMBER;
    l_Id_Relacion   NUMBER;
    l_Rut_Cliente   VARCHAR2(10);
    l_Party_Id      NUMBER;
    l_Location_Id   NUMBER;
  BEGIN
    x_Cod_Error := 0;
    -- Obtiene informacion de la trama AE
    l_Dbg_Mensaje  := 'Obtener informacion de la trama AD';
    l_Trama_Ad     := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Ad(p_Transaccion.Cuerpo_Tx);
    l_Rut_Cliente  := Ltrim(Rtrim(p_Transaccion.Trama_Boc.String_Identificacion));
    l_Rut_Cliente  := Substr(l_Rut_Cliente
                            ,1
                            ,Length(l_Rut_Cliente) - 1);
    l_Party_Id     := Scfr_Trx_Util_Pk.Obtiene_Party_Id(To_Number(l_Rut_Cliente));
    l_Party_Id_Rel := Scfr_Trx_Util_Pk.Busca_Party_Id_Relacion(l_Party_Id
                                                              ,Scfr_Trx_Util_Pk.Obtiene_Party_Id(Scfr_Trx_Util_Pk.Rut_Con_Org_Id(p_Transaccion.Trama_Pos.Empresa
                                                                                                                                ,Scfr_Trx_Util_Pk.Instancia))
                                                              ,'ES_FIDELIZADO'
                                                              ,p_Transaccion.Trama_Pos.Empresa
                                                              ,l_Id_Relacion);
    l_Location_Id  := Scfr_Trx_Util_Pk.Busca_Party_Site(l_Party_Id_Rel
                                                       ,'HOME');
    Actualiza_Direccion(p_Location_Id   => l_Location_Id -- in number
                       ,p_Comuna        => l_Trama_Ad.Comuna -- in  varchar2
                       ,p_Ciudad        => l_Trama_Ad.Ciudad -- in  varchar2
                       ,p_Numero        => l_Trama_Ad.Numero_Direccion -- in  varchar2
                       ,p_Calle         => l_Trama_Ad.Calle_Direccion -- in  varchar2
                       ,p_Depto         => l_Trama_Ad.Numero_Depto -- in  varchar2
                       ,p_Block         => l_Trama_Ad.Block -- in  varchar2
                       ,p_Poblacion     => l_Trama_Ad.Poblacion -- in  varchar2
                       ,p_Responsable   => p_Transaccion.Trama_Pos.Usuario_Responsable -- in  varchar2
                       ,x_Return_Status => l_Return_Status -- out varchar2
                       ,x_Msg_Data      => l_Msg_Data -- out varchar2
                        );
    IF l_Return_Status <> '00' THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al actualizar Direccion. ' || l_Msg_Data);
    END IF;
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Trama AD resuelta correctamente');
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
  END Trama_Ad_Resuelve;

  PROCEDURE Fidu09(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.fidu09';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error No Determinado';
    l_Error_Controlado EXCEPTION;
    l_Es_Loyalty BOOLEAN;
  BEGIN
    --//--------------------------------------------------------------------------\\
    --// CBR 13/08/2018 10:20                                                     \\
    --// BIFURCAR EMPRESA MAICAO EN GNCC01                                        \\
    --//-----------------------------------------------------------------Inicio---\\
    l_Es_Loyalty := FALSE;
    IF Scfr_Trx_Gnc_Pk.Es_Consulta_Loyalty(p_Transaccion.Trama_Pos.Empresa
                                          ,p_Transaccion.Trama_Pos.Cadena
                                          ,p_Transaccion.Trama_Pos.Local) = 'SI' THEN
      l_Es_Loyalty := TRUE;
    END IF;
    --//-----------------------------------------------------------------Termino--\\

    --//--------------------------------------------------------------------------\\
    --// CBR 20/08/2018 17:47                                                     \\
    --// BIFURCAR EMPRESA MAICAO EN FIDI01                                        \\
    --//-----------------------------------------------------------------Inicio---\\
    -- IF l_Es_Loyalty = FALSE THEN

    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'AE') THEN
      l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_FID_PK.trama_ae_resuelve()';
      Trama_Ae_Resuelve(p_Transaccion
                       ,x_Cod_Error
                       ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    ELSE
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Trama AE no encontrada');
    END IF;
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'QF') THEN
      l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_FID_PK.trama_qf_resuelve()';
      Trama_Qf_Resuelve(p_Transaccion
                       ,x_Cod_Error
                       ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    ELSE
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Trama QF no encontrada');
    END IF;
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'AD') THEN
      l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_FID_PK.trama_ad_resuelve()';
      Trama_Ad_Resuelve(p_Transaccion
                       ,x_Cod_Error
                       ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    ELSE
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Trama AD no encontrada');
    END IF;
    Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                    ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Ok
                                    ,x_Respuesta);
  EXCEPTION
    WHEN l_Error_Controlado THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
    WHEN OTHERS THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END Fidu09;

  --//--------------------------------------------------------------------------\\
  --// CBR 03/08/2017 4:31PM                                                    \\
  --//                                                                          \\
  --//-----------------------------------------------------------------Inicio---\\
  PROCEDURE Fidu10(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.fidu10';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error No Determinado';
    l_Error_Controlado EXCEPTION;
  BEGIN
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'VO') THEN
      l_Dbg_Mensaje := 'Ejecutar SCFR_TRX_FID_PK.trama_VO_resuelve()';
      Trama_Vo_Resuelve(p_Transaccion
                       ,x_Cod_Error
                       ,x_Msg_Error);
      IF Nvl(x_Cod_Error
            ,0) != 0 THEN
        RAISE l_Error_Controlado;
      END IF;
    ELSE
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Trama VO no encontrada');
    END IF;
    Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                    ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Ok
                                    ,x_Respuesta);
  EXCEPTION
    WHEN l_Error_Controlado THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
    WHEN OTHERS THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END Fidu10;

  PROCEDURE Trama_Vo_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Vo    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Vo;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.trama_VO_resuelve';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    l_Rut_Cliente         NUMBER;
    l_Num_Convenio        NUMBER;
    l_Existe_Opcion       NUMBER;
    l_Secuencia_Aplicar   NUMBER;
    l_Opcion_Seleccionada NUMBER := 0;
    k_Opcion_Quiere       NUMBER := 1;
    k_No_Quiere           NUMBER := 2;
    k_Tecla_Escape        NUMBER := 3;
  BEGIN
    x_Cod_Error := 0;
    -- Obtiene informacion de la trama Vo
    l_Dbg_Mensaje := 'Obtener informacion de la trama VO';

    l_Trama_Vo := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Vo(p_Transaccion.Cuerpo_Tx);

    -- l_Rut_Cliente := Ltrim(Rtrim(p_Transaccion.Trama_Boc.String_Identificacion));

    l_Rut_Cliente := l_Trama_Vo.Rut_Cliente;
    /*
    l_Rut_Cliente  := To_Number(Substr(TRIM(To_Char(l_Rut_Cliente))
                                      ,1
                                      ,Length(TRIM(To_Char(l_Rut_Cliente))) - 1));
    */
    l_Num_Convenio := l_Trama_Vo.Convenio;

    BEGIN
      SELECT 1
        INTO l_Existe_Opcion
        FROM Scfr_Reg_Opcion_Convenio
       WHERE Rut_Cliente = l_Rut_Cliente
         AND Numero_Convenio = l_Num_Convenio
         AND Loc_Local = p_Transaccion.Trama_Pos.Local;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Existe_Opcion := 0;
    END;
    -- *

    SELECT Decode(TRIM(l_Trama_Vo.Opcion_Seleccionada)
                 ,'SI'
                 ,k_Opcion_Quiere
                 ,'NO'
                 ,k_No_Quiere
                 ,'ES'
                 ,k_Tecla_Escape
                 ,0)
      INTO l_Opcion_Seleccionada
      FROM Dual;

    IF (l_Existe_Opcion = 0) THEN

      l_Secuencia_Aplicar := Scfr_Reg_Opcion_Convenio_s.Nextval;
      -- inserta datos
      INSERT INTO Scfr_Reg_Opcion_Convenio
        (Correlativo
        ,Rut_Cliente
        ,Numero_Convenio
        ,Fecha_Hora_Desp
        ,Fecha_Hora_Cap
        ,Rut_Vendedor
        ,Rut_Qf
        ,Opcion_Seleccionada
        ,Vb_Qf
        ,Loc_Local
        ,Numero_Preventa
        ,Txo_Codigo_Tx
        ,Fecha_Recepcion_Opcion
        ,Reintento_Vendedor
        ,Motivo_Rechazo)
      VALUES
        (l_Secuencia_Aplicar --correlativo
        ,l_Rut_Cliente --rut_cliente
        ,l_Num_Convenio --numero_convenio
        ,To_Date(Substr(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                       ,1
                       ,8) || l_Trama_Vo.Hora_Presentacion_Pop_Up
                ,'yyyymmddhh24miss') --fecha_hora_desp
        ,To_Date(Substr(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                       ,1
                       ,8) || l_Trama_Vo.Hora_Seleccion_Opcion
                ,'yyyymmddhh24miss') --fecha_hora_cap
        ,l_Trama_Vo.Rut_Vendedor -- p_Transaccion.Trama_Pos.Usuario_Responsable --rut_vendedor
        ,NULL --rut_qf
        ,l_Opcion_Seleccionada --opcion_seleccionada
        ,NULL --vb_qf
        ,p_Transaccion.Trama_Pos.Local --loc_local
        ,l_Secuencia_Aplicar --numero_preventa
        ,NULL --txo_codigo_tx
        ,Scfr_Trx_Util_Pk.Get_Sysdate
        ,NULL
        ,NULL);

      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Trama VO resuelta correctamente');
    ELSE
      -- Actualiza respuesta
      UPDATE Scfr_Reg_Opcion_Convenio
         SET Opcion_Seleccionada = l_Opcion_Seleccionada
       WHERE Rut_Cliente = l_Rut_Cliente
         AND Numero_Convenio = l_Num_Convenio
         AND Loc_Local = p_Transaccion.Trama_Pos.Local;

      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Trama VO resuelta correctamente');
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
  END Trama_Vo_Resuelve;
  --//-----------------------------------------------------------------Termino--\\

  /*
  * OBJETIVO
  *   Acumula puntos ganados (N-POS)
  * PARAMETROS
  *   p_transaccion  : Transacci?n recibida desde el pos
  *   x_cod_error    : C?digo de error retornado (0    en caso de no existir errores)
  *   x_msg_error    : Mesaje de error retornado (NULL en caso de no existir errores)
  */
  PROCEDURE Fidu51(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Resultado   NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.fidu51';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error No Determinado';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Determinar party ID';
    l_Resultado   := Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                        ,p_Transaccion.Trama_Pos.Empresa
                                        ,p_Transaccion.Trama_Pos.Cadena
                                        ,p_Transaccion.Trama_Boc.Party_Id);
    IF l_Resultado != 0 THEN
      x_Cod_Error   := l_Resultado;
      x_Msg_Error   := 'Party ID no determinado';
      l_Dbg_Mensaje := l_Dbg_Mensaje || '-' || x_Msg_Error;
      RAISE l_Error_Controlado;
    ELSE
      l_Dbg_Mensaje := 'LLamar a trama_zp_resuelve';
      Trama_Zp_Resuelve(p_Transaccion
                       ,x_Cod_Error
                       ,x_Msg_Error);
    END IF;
    Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                    ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Ok
                                    ,x_Respuesta);
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  /*
  * OBJETIVO
  *   Canje puntos ganados (N-POS)
  * PARAMETROS
  *   p_transaccion  : Transacci?n recibida desde el pos
  *   x_cod_error    : C?digo de error retornado (0    en caso de no existir errores)
  *   x_msg_error    : Mesaje de error retornado (NULL en caso de no existir errores)
  */
  PROCEDURE Fidu52(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Resultado   NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.fidu52';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error No Determinado';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Determinar party ID';
    l_Resultado   := Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                        ,p_Transaccion.Trama_Pos.Empresa
                                        ,p_Transaccion.Trama_Pos.Cadena
                                        ,p_Transaccion.Trama_Boc.Party_Id);
    IF l_Resultado != 0 THEN
      x_Cod_Error   := l_Resultado;
      x_Msg_Error   := 'Party ID no determinado';
      l_Dbg_Mensaje := l_Dbg_Mensaje || '-' || x_Msg_Error;
      RAISE l_Error_Controlado;
    ELSE
      l_Dbg_Mensaje := 'LLamar a trama_zj_resuelve';
      Trama_Zj_Resuelve(p_Transaccion
                       ,x_Cod_Error
                       ,x_Msg_Error);
    END IF;
    Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                    ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Ok
                                    ,x_Respuesta);
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  /*
  * OBJETIVO
  *   Reversa puntos (N-POS)
  * PARAMETROS
  *   p_transaccion  : Transacci?n recibida desde el pos
  *   x_cod_error    : C?digo de error retornado (0    en caso de no existir errores)
  *   x_msg_error    : Mesaje de error retornado (NULL en caso de no existir errores)
  */
  PROCEDURE Fidu53(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Resultado   NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.fidu53';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error No Determinado';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Determinar party ID';
    l_Resultado   := Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                        ,p_Transaccion.Trama_Pos.Empresa
                                        ,p_Transaccion.Trama_Pos.Cadena
                                        ,p_Transaccion.Trama_Boc.Party_Id);
    IF l_Resultado != 0 THEN
      x_Cod_Error   := l_Resultado;
      x_Msg_Error   := 'Party ID no determinado';
      l_Dbg_Mensaje := l_Dbg_Mensaje || '-' || x_Msg_Error;
      RAISE l_Error_Controlado;
    ELSE
      l_Dbg_Mensaje := 'LLamar a trama_zc_resuelve';
      Trama_Zc_Resuelve(p_Transaccion
                       ,x_Cod_Error
                       ,x_Msg_Error);
    END IF;
    Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                    ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Ok
                                    ,x_Respuesta);
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Fidu55(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Resultado   NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.fidu55';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error No Determinado';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Determinar party ID';
    l_Resultado   := Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                        ,p_Transaccion.Trama_Pos.Empresa
                                        ,p_Transaccion.Trama_Pos.Cadena
                                        ,p_Transaccion.Trama_Boc.Party_Id);
    IF l_Resultado != 0 THEN
      x_Cod_Error   := l_Resultado;
      x_Msg_Error   := 'Party ID no determinado';
      l_Dbg_Mensaje := l_Dbg_Mensaje || '-' || x_Msg_Error;
      RAISE l_Error_Controlado;
    ELSE
      l_Dbg_Mensaje := 'LLamar a trama_zc_resuelve';
      Trama_Pg_Resuelve(p_Transaccion
                       ,x_Cod_Error
                       ,x_Msg_Error);
    END IF;
    Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                    ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Ok
                                    ,x_Respuesta);
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Fidu56(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Resultado   NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_FID_PK.fidu56';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error No Determinado';
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Determinar party ID';
    l_Resultado   := Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                        ,p_Transaccion.Trama_Pos.Empresa
                                        ,p_Transaccion.Trama_Pos.Cadena
                                        ,p_Transaccion.Trama_Boc.Party_Id);
    IF l_Resultado != 0 THEN
      x_Cod_Error   := l_Resultado;
      x_Msg_Error   := 'Party ID no determinado';
      l_Dbg_Mensaje := l_Dbg_Mensaje || '-' || x_Msg_Error;
      RAISE l_Error_Controlado;
    ELSE
      l_Dbg_Mensaje := 'LLamar a trama_gs_resuelve';
      Trama_Gs_Resuelve(p_Transaccion
                       ,x_Cod_Error
                       ,x_Msg_Error);
    END IF;
    Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                    ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Ok
                                    ,x_Respuesta);
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Gnc_Pk.Agrega_Respuesta(p_Transaccion
                                      ,Scfr_Trx_Gnc_Pk.k_Cod_Resp_Nok
                                      ,x_Respuesta);
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Refresca_Cliente_Dat IS
  BEGIN
    Dbms_Mview.Refresh('HZ_PARTIES'
                      ,'F');
    Dbms_Mview.Refresh('HZ_PERSON_PROFILES'
                      ,'F');
  END;

  PROCEDURE Refresca_Cliente_Dir IS
  BEGIN
    Dbms_Mview.Refresh('HZ_LOCATIONS'
                      ,'F');
    Dbms_Mview.Refresh('HZ_PARTY_SITES'
                      ,'F');
    Dbms_Mview.Refresh('HZ_PARTY_SITE_USES'
                      ,'F');
  END;

  PROCEDURE Refresca_Cliente_Con IS
  BEGIN
    Dbms_Mview.Refresh('HZ_CONTACT_POINTS'
                      ,'F');
  END;

  PROCEDURE Refresca_Cliente_Rel IS
  BEGIN
    Dbms_Mview.Refresh('HZ_RELATIONSHIPS'
                      ,'F');
  END;

  --//--------------------------------------------------------------------------\\
  --// CBR 05/02/2015 18:57 Mensajes / Eventos / Descuentos                     \\
  --//-----------------------------------------------------------------Inicio---\\
  --//                                                                          \\
  --//--------------------------------------------------------------------------\\
  PROCEDURE Dto_x_Evento_Mensajeria(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                   ,x_Cod_Error   OUT NUMBER
                                   ,x_Msg_Error   OUT VARCHAR2) IS

    -- Mensajes por lista de clientes
    CURSOR c_Listas_Mensajes(p_Party_Id IN NUMBER) IS
      SELECT Scfr_Lista_Cli_Mensaje.Lista_Cli_Mensaje
            ,Scfr_Lista_Cli_Mensaje.Personalizado
            ,Scfr_Lista_Cli_Mensaje.Mensaje
            ,Scfr_Lista_Cli_Mensaje.Fecha_Creacion
            ,Scfr_Lista_Cli_Mensaje.Fecha_Termino
            ,Scfr_Lista_Cli_Mensaje.Numero_Eventos
            ,Scfr_Lista_Cli_Mensaje.Sle_Listas_Clientes
            ,Scfr_Lista_Cli_Mensaje.Cam_Campana
            ,Scfr_Lista_Cli_Mensaje.Tipo_Ejecucion_Mensaje
            ,Scfr_Lista_Cli_Mensaje.Dirigido
            ,Scfr_Lista_Cli_Mensaje.Activo
            ,Scfr_Det_Cliente_Mensaje.Numero_Eventos_Aplicados
            ,Scfr_Deta_List_Clientes.Rut_Cliente
            ,Scfr_Deta_List_Clientes.Dv_Cliente
            ,Scfr_Deta_List_Clientes.Pt_Party_Id_Cliente
        FROM Scfr_Lista_Cli_Mensaje
            ,Scfr_Det_Cliente_Mensaje
            ,Scfr_Deta_List_Clientes
            ,Scfr_Campanas_Relacionadas
            ,Fid.Scfr_Campanas
            ,Fid.Scfr_Listas_Clientes_Campanas
            ,Fid.Scfr_Condiciones
       WHERE (Scfr_Lista_Cli_Mensaje.Cad_Cadena = p_Transaccion.Trama_Pos.Cadena AND
             Scfr_Lista_Cli_Mensaje.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa AND Scfr_Deta_List_Clientes.Pt_Party_Id_Cliente = p_Party_Id AND
             Scfr_Det_Cliente_Mensaje.Pt_Party_Id_Cliente(+) = p_Party_Id AND
             (Ms_Esta_En_Zona(p_Transaccion.Trama_Pos.Empresa
                              ,p_Transaccion.Trama_Pos.Cadena
                              ,p_Transaccion.Trama_Pos.Local
                              ,Scfr_Lista_Cli_Mensaje.Cam_Campana) = 1) AND
             Trunc(Nvl(Scfr_Lista_Cli_Mensaje.Fecha_Termino
                       ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()))
         AND ((Scfr_Deta_List_Clientes.Sle_Listas_Clientes = Scfr_Lista_Cli_Mensaje.Sle_Listas_Clientes) AND
             (Scfr_Lista_Cli_Mensaje.Lista_Cli_Mensaje = Scfr_Det_Cliente_Mensaje.Lcm_Lista_Cli_Mensaje(+)) AND
             ((Scfr_Lista_Cli_Mensaje.Numero_Eventos - Nvl(Scfr_Det_Cliente_Mensaje.Numero_Eventos_Aplicados
                                                           ,0)) > 0))
         AND Scfr_Campanas_Relacionadas.Cam_Campana_Relacionada = Scfr_Lista_Cli_Mensaje.Cam_Campana
         AND Scfr_Campanas.Campana = Scfr_Campanas_Relacionadas.Cam_Campana_Activacion
         AND Scfr_Campanas.Tipo_Campana = 'DES'
         AND Scfr_Campanas.Campana = Scfr_Listas_Clientes_Campanas.Cam_Campana
         AND Scfr_Campanas.Campana = Scfr_Condiciones.Cam_Campana
         AND Scfr_Condiciones.Tipo_Condicion = 'EVE'
         AND Nvl(Scfr_Condiciones.Restriccion_Maxima
                ,0) > 0;

    l_Itm                      NUMBER;
    l_Existe                   NUMBER;
    l_Rut                      Scfr_Mov_Transacciones.Rut_Titular%TYPE;
    l_Dv_Rut                   Scfr_Mov_Transacciones.Dv_Titular%TYPE;
    l_Existe_Uso_Negativo      NUMBER;
    l_Aux_Campana              NUMBER;
    l_Uso_Positivo             VARCHAR2(3);
    p_Numero_Eventos_Aplicados Scfr_Det_Cliente_Mensaje.Numero_Eventos_Aplicados%TYPE;
    l_Dbg_Proceso              VARCHAR2(100) := 'SCFR_TRX_FID_PK.Dto_X_Evento_Mensajeria';
    l_Dbg_Mensaje              VARCHAR2(250) := 'DTO_X_EVENTO_MENSAJERIA';
    l_Debe_Inscribir           VARCHAR2(2) := 'NO';
  BEGIN

    l_Dbg_Mensaje := 'Incrementar Evento a Camp. Mensajeria con Descuento x Eventos {DTO_X_EVENTO_MENSAJERIA}';

    -- Mensajes por lista de clientes
    FOR r_Listas_Mensajes IN c_Listas_Mensajes(p_Transaccion.Trama_Boc.Party_Id)
    LOOP

      l_Debe_Inscribir := 'NO';
      -- Actualiza contador mensaje
      BEGIN
        SELECT 1
              ,Numero_Eventos_Aplicados
          INTO l_Existe
              ,p_Numero_Eventos_Aplicados
          FROM Scfr_Det_Cliente_Mensaje
         WHERE Lcm_Lista_Cli_Mensaje = r_Listas_Mensajes.Lista_Cli_Mensaje
           AND Pt_Party_Id_Cliente = p_Transaccion.Trama_Boc.Party_Id
           AND Rownum = 1;
      EXCEPTION
        WHEN No_Data_Found THEN
          l_Existe := 0;
      END;

      -- Si no existe Crea Contador.
      IF (l_Existe = 0) THEN
        -- Obtiene Rut
        Scfr_Trx_Util_Pk.Obtiene_Rut(p_Transaccion.Trama_Boc.Party_Id
                                    ,l_Rut
                                    ,l_Dv_Rut);
        -- *
        INSERT INTO Scfr_Det_Cliente_Mensaje
          (Lcm_Lista_Cli_Mensaje
          ,Pt_Party_Id_Cliente
          ,Rut_Cliente
          ,Numero_Eventos_Aplicados)
        VALUES
          (r_Listas_Mensajes.Lista_Cli_Mensaje
          ,p_Transaccion.Trama_Boc.Party_Id
          ,l_Rut
          ,1);

        p_Numero_Eventos_Aplicados := 1;
      ELSE
        -- Actualiza si existe contador
        UPDATE Scfr_Det_Cliente_Mensaje
           SET Numero_Eventos_Aplicados = Nvl(Numero_Eventos_Aplicados
                                             ,0) + 1
         WHERE Lcm_Lista_Cli_Mensaje = r_Listas_Mensajes.Lista_Cli_Mensaje
           AND Pt_Party_Id_Cliente = p_Transaccion.Trama_Boc.Party_Id;
        -- *
        p_Numero_Eventos_Aplicados := Nvl(p_Numero_Eventos_Aplicados
                                         ,0) + 1;
      END IF; --if (l_existe = 0) then

      -- Una Vez Insertado u Actualizado, debo validar si alcanza el numero maximo de eventos
      IF (p_Numero_Eventos_Aplicados >= r_Listas_Mensajes.Numero_Eventos) THEN
        l_Debe_Inscribir := 'SI';
      END IF;

      --//--------------------------------------------------------------------------\\
      --// CBR 05/02/2015 18:58                                                     \\
      --// Campana de Mensajeria/Eventos/Descuento                                  \\
      --//-----------------------------------------------------------------Inicio---\\
      IF l_Debe_Inscribir = 'SI' THEN
        Dto_x_Evento_Inscripcion(r_Listas_Mensajes.Pt_Party_Id_Cliente -- p_Party_Id
                                ,r_Listas_Mensajes.Rut_Cliente -- p_Rut_Cliente
                                ,r_Listas_Mensajes.Dv_Cliente -- p_Dv_Cliente
                                ,r_Listas_Mensajes.Cam_Campana -- p_Campana_Mensajes
                                ,p_Transaccion.Trama_Pos.Fecha_Hora_Tx -- p_Fecha_TX
                                ,x_Cod_Error -- x_Cod_Error
                                ,x_Msg_Error); -- x_Msg_Error
      END IF;
      --//-----------------------------------------------------------------Termino--\\
    END LOOP;
    -- *
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END Dto_x_Evento_Mensajeria;

  --//--------------------------------------------------------------------------\\
  --// CBR 05/02/2015 18:58 Mensajes / Eventos / Descuentos                     \\
  --//-----------------------------------------------------------------Inicio---\\
  --// Si la campana de mensajes  cumplio con su maximo de eventos, y esta a la \\
  --// vez, relacionada a una campana de descuento que controla eventos maximo  \\
  --// de eventos, entonces debo inscribir al cliente en dicha lista de campana \\
  --//--------------------------------------------------------------------------\\
  PROCEDURE Dto_x_Evento_Inscripcion(p_Party_Id         IN NUMBER
                                    ,p_Rut_Cliente      IN NUMBER
                                    ,p_Dv_Cliente       IN VARCHAR2
                                    ,p_Campana_Mensajes IN NUMBER
                                    ,p_Fecha_Tx         IN NUMBER
                                    ,x_Cod_Error        OUT NUMBER
                                    ,x_Msg_Error        OUT VARCHAR2) IS

    p_Campana             Scfr_Campanas.Campana%TYPE;
    p_Sle_Listas_Clientes Scfr_Listas_Clientes_Campanas.Sle_Listas_Clientes%TYPE;
    p_Fecha_Asociacion    Scfr_Listas_Clientes_Campanas.Fecha_Asociacion%TYPE;
    l_Dbg_Proceso         VARCHAR2(100) := 'SCFR_TRX_FID_PK.Dto_X_Evento_Inscripcion';
    l_Dbg_Mensaje         VARCHAR2(250) := 'DTO_X_EVENTO_INSCRIPCION';
    l_Existe              NUMBER;

  BEGIN
    l_Dbg_Mensaje := 'Inscribir al Cliente en Campana Descuento x Eventos {DTO_X_EVENTO_INSCRIPCION}';
    -- Busco por campana de mensajes la relacion de campana de Descuento que tenga Condicion 'EVE' campo RESTRICCION_MAXIMA mayor a cero.
    BEGIN
      SELECT 1
            ,Slcc.Sle_Listas_Clientes
            ,Slcc.Fecha_Asociacion
            ,Sc.Campana
        INTO l_Existe
            ,p_Sle_Listas_Clientes
            ,p_Fecha_Asociacion
            ,p_Campana
        FROM Scfr_Campanas_Relacionadas        Scr
            ,Fid.Scfr_Campanas                 Sc
            ,Fid.Scfr_Listas_Clientes_Campanas Slcc
            ,Fid.Scfr_Condiciones              Scond
       WHERE Scr.Cam_Campana_Relacionada = p_Campana_Mensajes
         AND Sc.Campana = Scr.Cam_Campana_Activacion
         AND Sc.Tipo_Campana = 'DES'
         AND Sc.Campana = Slcc.Cam_Campana
         AND Sc.Campana = Scond.Cam_Campana
         AND Scond.Tipo_Condicion = 'EVE'
         AND Nvl(Scond.Restriccion_Maxima
                ,0) > 0
         AND Rownum = 1;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Existe := 0;
    END;

    -- Si no existe entonces no es una campana de descuento con eventos.
    IF (l_Existe = 0) THEN
      -- Si no existe, no debe hacer nada.
      NULL;
    ELSE
      -- Si existe campana de descuento con eventos.
      -- Debe buscar al Cliente.
      BEGIN
        SELECT 1
          INTO l_Existe
          FROM Fid.Scfr_Deta_List_Clientes Sdlc
         WHERE Sdlc.Sle_Listas_Clientes = p_Sle_Listas_Clientes
           AND Sdlc.Rut_Cliente = p_Rut_Cliente
           AND Rownum = 1;
      EXCEPTION
        WHEN No_Data_Found THEN
          l_Existe := 0;
      END;

      IF (l_Existe = 0) THEN
        -- Si no existe, debe grabar el cliente en la lista Clientes de la campana de descuento.
        INSERT INTO Fid.Scfr_Deta_List_Clientes
          (Sle_Listas_Clientes
          ,Pt_Party_Id_Cliente
          ,Fecha_Carga
          ,Fecha_Expiracion
          ,Rut_Cliente
          ,Dv_Cliente)
        VALUES
          (p_Sle_Listas_Clientes
          ,p_Party_Id
          ,To_Date(p_Fecha_Tx
                  ,'yyyymmddhh24miss') -- SYSDATE --  p_Fecha_Asociacion
          ,NULL
          ,p_Rut_Cliente
          ,p_Dv_Cliente);

        -- Si no existe, se debe crear con evento 0.
        INSERT INTO Fid.Scfr_Det_Cliente_Descuento
          (Cam_Campana
          ,Rut_Cliente
          ,Numero_Eventos_Aplicados
          ,Activo)
        VALUES
          (p_Campana
          ,p_Rut_Cliente
          ,0
          ,'SI');

      ELSE
        -- Si existe, no debe hacer nada.
        NULL;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END Dto_x_Evento_Inscripcion;

  --//--------------------------------------------------------------------------\\
  --// Si la campana es de descuento x eventos, valida si el cliente no ha      \\
  --// cumplido el maximo de eventos, como para entregar la campana en  el      \\
  --// perfil de cliente en la trama CA                                         \\
  --//--------------------------------------------------------------------------\\
  FUNCTION Dto_x_Evento_Validacion(p_Rut_Cliente        IN NUMBER
                                  ,p_Party_Id           IN NUMBER
                                  ,p_Campana_Descuentos IN NUMBER
                                  ,p_Fecha_Tx           IN NUMBER
                                  ,p_Tipo_Campana       IN VARCHAR2
                                  ,x_Cod_Error          OUT NUMBER
                                  ,x_Msg_Error          OUT VARCHAR2) RETURN VARCHAR2 IS

    p_Campana               Scfr_Campanas.Campana%TYPE;
    p_Restriccion_Maxima    Scfr_Condiciones.Restriccion_Maxima%TYPE;
    p_Num_Eventos_Aplicados Fid.Scfr_Det_Cliente_Descuento.Numero_Eventos_Aplicados%TYPE;
    p_Activo                Fid.Scfr_Det_Cliente_Descuento.Activo%TYPE;
    p_Fecha_Inscripcion     NUMBER;
    l_Dbg_Proceso           VARCHAR2(100) := 'SCFR_TRX_FID_PK.Dto_x_Evento_Validacion';
    l_Dbg_Mensaje           VARCHAR2(250) := 'DTO_X_EVENTO_VALIDACION';
    l_Resultado             VARCHAR2(2);
    l_Existe                NUMBER;

  BEGIN
    l_Resultado   := 'SI';
    l_Dbg_Mensaje := 'Validar si la campana Cliente cumple con Descuento x Eventos {DTO_X_EVENTO_VALIDACION}';

    IF p_Tipo_Campana = 'MCL' THEN
      BEGIN
        SELECT 1
              ,Nvl(Slcm.Numero_Eventos
                  ,0)
          INTO l_Existe
              ,p_Restriccion_Maxima
          FROM Scfr_Campanas          Sc
              ,Scfr_Lista_Cli_Mensaje Slcm
         WHERE Sc.Campana = Slcm.Cam_Campana
           AND Sc.Campana = p_Campana_Descuentos -- recordar que la campana es de mensajes.
           AND Rownum = 1;
      EXCEPTION
        WHEN No_Data_Found THEN
          l_Existe := 0;
      END;

      IF (l_Existe = 1) AND
         (p_Restriccion_Maxima > 0) THEN
        BEGIN
          SELECT 1
            INTO l_Existe
            FROM Scfr_Campanas            Sc
                ,Scfr_Lista_Cli_Mensaje   Slcm
                ,Scfr_Det_Cliente_Mensaje Sdcm
           WHERE Sc.Campana = Slcm.Cam_Campana
             AND Slcm.Lista_Cli_Mensaje = Sdcm.Lcm_Lista_Cli_Mensaje(+)
             AND Sc.Campana = p_Campana_Descuentos -- recordar que la campana es de mensajes.
             AND Sdcm.Pt_Party_Id_Cliente(+) = p_Party_Id
             AND Nvl(Slcm.Numero_Eventos
                    ,0) > Nvl(Sdcm.Numero_Eventos_Aplicados
                             ,0)
             AND Rownum = 1;
        EXCEPTION
          WHEN No_Data_Found THEN
            l_Existe    := 0;
            l_Resultado := 'NO';
        END;
      END IF;
    ELSE
      -- si no es MCL entonces es DES
      BEGIN
        SELECT 1
              ,Sc.Campana
              ,Scond.Restriccion_Maxima
              ,To_Number(To_Char(Sdlc.Fecha_Carga
                                ,'yyyymmddhh24miss'))
          INTO l_Existe
              ,p_Campana
              ,p_Restriccion_Maxima
              ,p_Fecha_Inscripcion
          FROM Fid.Scfr_Campanas                 Sc
              ,Fid.Scfr_Listas_Clientes_Campanas Slcc
              ,Fid.Scfr_Deta_List_Clientes       Sdlc
              ,Fid.Scfr_Condiciones              Scond
         WHERE Sc.Campana = p_Campana_Descuentos
           AND Sc.Tipo_Campana = 'DES'
           AND Sc.Campana = Slcc.Cam_Campana
           AND Sc.Campana = Scond.Cam_Campana
           AND Slcc.Sle_Listas_Clientes = Sdlc.Sle_Listas_Clientes
           AND Sdlc.Rut_Cliente = p_Rut_Cliente
           AND Scond.Tipo_Condicion = 'EVE'
           AND Nvl(Scond.Restriccion_Maxima
                  ,0) > 0
           AND Rownum = 1;
      EXCEPTION
        WHEN No_Data_Found THEN
          l_Existe := 0;
      END;

      -- Si no existe entonces no es una campana de descuento con eventos.
      IF (l_Existe = 0) THEN
        -- Si no existe, no debe hacer nada.
        NULL;
      ELSE
        -- Si existe campana de descuento con eventos.
        -- Debe buscar al Cliente.
        BEGIN
          SELECT 1
                ,Numero_Eventos_Aplicados
                ,Activo
            INTO l_Existe
                ,p_Num_Eventos_Aplicados
                ,p_Activo
            FROM Fid.Scfr_Det_Cliente_Descuento
           WHERE Cam_Campana = p_Campana
             AND Rut_Cliente = p_Rut_Cliente
             AND Rownum = 1;
        EXCEPTION
          WHEN No_Data_Found THEN
            l_Existe := 0;
        END;

        -- Si existe debe validar la cantidad de veces usada la campana.
        IF (l_Existe = 1) THEN
          IF (p_Num_Eventos_Aplicados >= p_Restriccion_Maxima) OR
             (p_Fecha_Inscripcion = p_Fecha_Tx) THEN
            -- AND (p_Activo = 'NO') THEN
            l_Resultado := 'NO';
          END IF;
        END IF;
      END IF;
    END IF;

    RETURN l_Resultado;

  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
      RETURN l_Resultado;
  END Dto_x_Evento_Validacion;
  --//--------------------------------------------------------------------------\\
  --//                                                                          \\
  --//                                                                          \\
  --//                                                                          \\
  --//                                                                          \\
  --//                                                                          \\
  --//                                                                          \\
  --//                                                                          \\
  --//                                                                          \\
  --//--------------------------------------------------------------------------\\
  PROCEDURE Dto_x_Evento_Aplicar(p_Accion             IN VARCHAR2
                                ,p_Rut_Cliente        IN NUMBER
                                ,p_Campana_Descuentos IN NUMBER
                                ,x_Cod_Error          OUT NUMBER
                                ,x_Msg_Error          OUT VARCHAR2) IS

    p_Campana               Scfr_Campanas.Campana%TYPE;
    p_Restriccion_Maxima    Scfr_Condiciones.Restriccion_Maxima%TYPE;
    p_Num_Eventos_Aplicados Fid.Scfr_Det_Cliente_Descuento.Numero_Eventos_Aplicados%TYPE;
    p_Registro_Explicito    UROWID;
    p_Activo                Fid.Scfr_Det_Cliente_Descuento.Activo%TYPE;
    l_Dbg_Proceso           VARCHAR2(100) := 'SCFR_TRX_FID_PK.Dto_X_Evento_Aplicar';
    l_Dbg_Mensaje           VARCHAR2(250) := 'DTO_X_EVENTO_APLICAR';
    l_Existe                NUMBER;

  BEGIN
    l_Dbg_Mensaje := 'Validar si es una Campana Descuento x Eventos, para sumar o restar {DTO_X_EVENTO_APLICAR}';
    BEGIN
      SELECT 1
            ,Sc.Campana
            ,Scond.Restriccion_Maxima
        INTO l_Existe
            ,p_Campana
            ,p_Restriccion_Maxima
        FROM Fid.Scfr_Campanas                 Sc
            ,Fid.Scfr_Listas_Clientes_Campanas Slcc
            ,Fid.Scfr_Condiciones              Scond
       WHERE Sc.Campana = p_Campana_Descuentos
         AND Sc.Tipo_Campana = 'DES'
         AND Sc.Campana = Slcc.Cam_Campana
         AND Sc.Campana = Scond.Cam_Campana
         AND Scond.Tipo_Condicion = 'EVE'
         AND Nvl(Scond.Restriccion_Maxima
                ,0) > 0
         AND Rownum = 1;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Existe := 0;
    END;

    -- Si no existe entonces no es una campana de descuento con eventos.
    IF (l_Existe = 0) THEN
      -- Si no existe, no debe hacer nada.
      NULL;
    ELSE
      -- Si existe campana de descuento con eventos.
      -- Debe buscar al Cliente.
      BEGIN
        SELECT 1
              ,Numero_Eventos_Aplicados
              ,Activo
          INTO l_Existe
              ,p_Num_Eventos_Aplicados
              ,p_Activo
          FROM Scfr_Det_Cliente_Descuento
         WHERE Cam_Campana = p_Campana
           AND Rut_Cliente = p_Rut_Cliente
           AND Rownum = 1;
      EXCEPTION
        WHEN No_Data_Found THEN
          l_Existe := 0;
      END;

      -- Si no existe y debe incrementar el Evento, es primera vez que usa la campana.
      IF (l_Existe = 0) AND
         (p_Accion = 'UTI') THEN
        -- Si no existe, se debe crear con evento 1.
        INSERT INTO Fid.Scfr_Det_Cliente_Descuento
          (Cam_Campana
          ,Rut_Cliente
          ,Numero_Eventos_Aplicados
          ,Activo)
        VALUES
          (p_Campana
          ,p_Rut_Cliente
          ,1
          ,'SI');
      ELSE
        -- Si existe, se debe sumar o restar al evento de la campana de descuento.
        IF p_Accion = 'UTI' THEN
          l_Dbg_Mensaje           := 'Sumar numero de eventos al Cliente en campana Descuento x Eventos';
          p_Num_Eventos_Aplicados := p_Num_Eventos_Aplicados + 1;
        ELSIF (p_Accion = 'ACT') AND
              (p_Num_Eventos_Aplicados > 0) THEN
          l_Dbg_Mensaje           := 'Restar numero de eventos al Cliente en campana Descuento x Eventos';
          p_Num_Eventos_Aplicados := p_Num_Eventos_Aplicados - 1;
        END IF;

        IF p_Restriccion_Maxima <= p_Num_Eventos_Aplicados THEN
          p_Activo := 'NO';
        ELSE
          p_Activo := 'SI';
        END IF;

        UPDATE Fid.Scfr_Det_Cliente_Descuento
           SET Numero_Eventos_Aplicados = p_Num_Eventos_Aplicados
              ,Activo                   = p_Activo
         WHERE Cam_Campana = p_Campana
           AND Rut_Cliente = p_Rut_Cliente;
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END Dto_x_Evento_Aplicar;

--//-----------------------------------------------------------------Termino--\\

END Scfr_Trx_Fid_Pk;
/
