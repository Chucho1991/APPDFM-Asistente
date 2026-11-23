CREATE OR REPLACE PACKAGE TRX3.Scfr_Trx_Dyn_Pk AS

  -- Author      : USER_PIVOT2
  -- Modified by : JESUS GUERRA CEDENO
  -- Modified    : 22/10/2026
  -- Purpose     : Cambio Boletos / Recaudos - origen transaccion OBE 

  --Vversion VARCHAR2(25) := 'GEO.11.09.2023';
  Vversion VARCHAR2(25) := 'GEO.23.04.2024';

  FUNCTION Version_Pkg RETURN VARCHAR2;

  /******************************************************************************
   NAME:    scfr_trx_dyn__pk
   PURPOSE: Utilidad para manejo de transacciones dinamicas

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        02-12-2004             1. Created this package.
  ******************************************************************************/
  -- Constantes.
  k_Trama_Header_Pos CONSTANT VARCHAR2(3) := 'HPO';

  k_Trama_Header_Boc CONSTANT VARCHAR2(3) := 'HBO';

  k_Trama_Header_Ctx CONSTANT VARCHAR2(3) := 'HTX';

  k_Tipo_Binario CONSTANT VARCHAR2(1) := 'B';

  k_Tipo_Caracter CONSTANT VARCHAR2(1) := 'C';

  k_Tipo_Numerico CONSTANT VARCHAR2(1) := 'N';

  k_Si_Itera CONSTANT VARCHAR2(1) := 'S';

  k_No_Itera CONSTANT VARCHAR2(1) := 'N';

  k_Largo_Registro CONSTANT VARCHAR2(100) := 'LARGO_REGISTRO';

  k_Largo_Campo CONSTANT VARCHAR2(100) := 'LARGO_CAMPO';

  k_Sistema CONSTANT VARCHAR2(100) := 'SISTEMA';

  k_Funcion CONSTANT VARCHAR2(100) := 'FUNCION';

  k_Secuencia CONSTANT VARCHAR2(100) := 'SECUENCIA_C';

  k_Tipo_Informacion CONSTANT VARCHAR2(100) := 'TIPO_INFORMACION';

  k_Cantidad_Registros CONSTANT VARCHAR2(100) := 'CANTIDAD_REGISTROS';

  k_Largo_Varchar2 CONSTANT NUMBER := 1000;

  TYPE Rec_Cuerpo_Tx IS RECORD(
     Codigo_Trx   Scfr_Transaccion.Codigo_Tx%TYPE
    ,Codigo_Trama Scfr_Catalogo.Tipo_Info%TYPE
    ,Nombre_Trama Scfr_Catalogo.Descripcion%TYPE
    ,Itera_Trama  Scfr_Catalogo.Iterativo%TYPE
    ,Itera_Valor  NUMBER
    ,Itera_Indice NUMBER DEFAULT 1
    ,Itera_Nivel  NUMBER DEFAULT 0
    ,Codigo_Campo Scfr_Diccionario.Codigo_Diccionario%TYPE
    ,Desc_Campo   Scfr_Diccionario.Descripcion%TYPE
    ,Nombre_Campo Scfr_Diccionario.Nombre_Campo%TYPE
    ,Largo_Campo  Scfr_Diccionario.Largo%TYPE
    ,Tipo_Campo   Scfr_Diccionario.Tipo%TYPE
    ,Valor_Campo  BLOB
    ,Valor_Campon NUMBER
    ,Valor_Campoc VARCHAR2(32760)
    ,Codigo_Padre Scfr_Catalogo.Tipo_Info%TYPE
    ,Pos_Relativa NUMBER
    ,Pos_Absoluta NUMBER
    ,Trama_Nivel  NUMBER DEFAULT 1 -- usado solo para el visualizador
    );

  -- Estructura de tipo tabla (arreglo) con los datos de la transacci?n enviada.
  TYPE Tab_Cuerpo_Tx IS TABLE OF Rec_Cuerpo_Tx INDEX BY BINARY_INTEGER;

  -- Estructura de tipo tabla (arreglo) con los datos de una trama
  TYPE Tab_Trama IS TABLE OF Scfr_Catalogo%ROWTYPE INDEX BY BINARY_INTEGER;

  -- Estructura de la transacci?n
  -- Contiene todos los datos enviados por el pos + los datos relacionados al modelo ON-LINE
  TYPE Rec_Transaccion IS RECORD(
    Codigo_Tx        Scfr_Mov_Transacciones.Codigo_Tx%TYPE
    ,Codigo_Tx_Origen Scfr_Mov_Transacciones.Codigo_Tx%TYPE
    ,Fecha_Tx         Scfr_Mov_Transacciones.Fecha_Tx%TYPE
    ,Fecha_Tx_Origen  Scfr_Mov_Transacciones.Fecha_Tx%TYPE
    ,Local_Origen     Scfr_Mov_Transacciones.Loc_Local%TYPE
    ,Correlativo_Tx   Scfr_Mov_Transacciones.Correlativo_Tx%TYPE
    ,Rut_Titular      Scfr_Mov_Transacciones.Rut_Titular%TYPE
    ,Dv_Rut_Titular   Scfr_Mov_Transacciones.Dv_Titular%TYPE
    ,Trama_Pos        Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Hpo -- se genera dependencia de scfr_trx_dyn_types_pk
    ,Trama_Boc        Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Hbo -- se genera dependencia de scfr_trx_dyn_types_pk
    ,Cuerpo_Tx        Tab_Cuerpo_Tx);

  -- Variable global que contiene el correlativo interno (ID) de la transacci?n en la
  -- tabla scfr_trx_rec_pos
  g_Correlativo_Trp NUMBER DEFAULT 0;

  FUNCTION Obtiene_Nro_Campos_Trama(p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE) RETURN NUMBER;

  FUNCTION Busca_Campo(p_Datos_Trx    IN Tab_Cuerpo_Tx
                      ,p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                      ,p_Codigo_Campo IN Scfr_Diccionario.Codigo_Diccionario%TYPE
                      ,p_Itera_Valor  IN NUMBER DEFAULT 1
                      ,p_Itera_Indice IN NUMBER DEFAULT 1) RETURN NUMBER;

  FUNCTION Busca_Campo(p_Datos_Trx    IN Tab_Cuerpo_Tx
                      ,p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                      ,p_Nombre_Campo IN Scfr_Diccionario.Nombre_Campo%TYPE
                      ,p_Itera_Valor  IN NUMBER DEFAULT 1
                      ,p_Itera_Indice IN NUMBER DEFAULT 1) RETURN NUMBER;

  FUNCTION Obtiene_Codigo_Transaccion(p_Transaccion      IN BLOB
                                     ,p_Codigo_Trama_Hpo IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION Setea_Transaccion(p_Transaccion   IN BLOB
                            ,x_Codigo_Error  OUT NUMBER
                            ,x_Mensaje_Error OUT VARCHAR2) RETURN Rec_Transaccion;

  FUNCTION Parsea_Transaccion(p_Transaccion   IN BLOB
                             ,x_Codigo_Error  OUT NUMBER
                             ,x_Mensaje_Error OUT VARCHAR2) RETURN Tab_Cuerpo_Tx;

  FUNCTION Parsea_Transaccion(p_Correlativo   IN NUMBER
                             ,p_Origen_Trx    IN VARCHAR2 DEFAULT 'P' -- (p)os, (c)entral
                             ,p_Tabla         IN VARCHAR2 DEFAULT 'L' -- (l)inea , (h)istorica
                             ,x_Codigo_Error  OUT NUMBER
                             ,x_Mensaje_Error OUT VARCHAR2) RETURN Tab_Cuerpo_Tx;

  FUNCTION Setea_Nvalor_Trx(p_Cuerpo_Tx    IN OUT Tab_Cuerpo_Tx
                           ,p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                           ,p_Codigo_Campo IN Scfr_Diccionario.Codigo_Diccionario%TYPE
                           ,p_Itera_Valor  IN NUMBER DEFAULT 1
                           ,p_Itera_Indice IN NUMBER DEFAULT 1
                           ,p_Data         IN NUMBER) RETURN NUMBER;

  FUNCTION Obtiene_Nvalor_Trx(p_Cuerpo_Tx    IN Tab_Cuerpo_Tx
                             ,p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                             ,p_Codigo_Campo IN Scfr_Diccionario.Codigo_Diccionario%TYPE
                             ,p_Itera_Valor  IN NUMBER DEFAULT 1
                             ,p_Itera_Indice IN NUMBER DEFAULT 1) RETURN NUMBER;

  FUNCTION Obtiene_Cvalor_Trx(p_Cuerpo_Tx    IN Tab_Cuerpo_Tx
                             ,p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                             ,p_Codigo_Campo IN Scfr_Diccionario.Codigo_Diccionario%TYPE
                             ,p_Itera_Valor  IN NUMBER DEFAULT 1
                             ,p_Itera_Indice IN NUMBER DEFAULT 1) RETURN VARCHAR2;

  FUNCTION Setea_Nvalor_Trx(p_Cuerpo_Tx    IN OUT Tab_Cuerpo_Tx
                           ,p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                           ,p_Nombre_Campo IN Scfr_Diccionario.Nombre_Campo%TYPE
                           ,p_Itera_Valor  IN NUMBER DEFAULT 1
                           ,p_Itera_Indice IN NUMBER DEFAULT 1
                           ,p_Data         IN NUMBER) RETURN NUMBER;

  FUNCTION Obtiene_Nvalor_Trx(p_Cuerpo_Tx    IN Tab_Cuerpo_Tx
                             ,p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                             ,p_Nombre_Campo IN Scfr_Diccionario.Nombre_Campo%TYPE
                             ,p_Itera_Valor  IN NUMBER DEFAULT 1
                             ,p_Itera_Indice IN NUMBER DEFAULT 1) RETURN NUMBER;

  FUNCTION Obtiene_Cvalor_Trx(p_Cuerpo_Tx    IN Tab_Cuerpo_Tx
                             ,p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                             ,p_Nombre_Campo IN Scfr_Diccionario.Nombre_Campo%TYPE
                             ,p_Itera_Valor  IN NUMBER DEFAULT 1
                             ,p_Itera_Indice IN NUMBER DEFAULT 1) RETURN VARCHAR2;

  FUNCTION Obtiene_Bvalor_Trx(p_Cuerpo_Tx    IN Tab_Cuerpo_Tx
                             ,p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                             ,p_Nombre_Campo IN Scfr_Diccionario.Nombre_Campo%TYPE
                             ,p_Itera_Valor  IN NUMBER DEFAULT 1
                             ,p_Itera_Indice IN NUMBER DEFAULT 1) RETURN BLOB;

  FUNCTION Arma_Trama_Pos(p_Transaccion IN OUT Rec_Transaccion) RETURN BLOB;

  FUNCTION Arma_Trama_Boc(p_Transaccion IN Rec_Transaccion) RETURN BLOB;

  PROCEDURE Agrega_Nvalor_Trx(p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                             ,p_Nombre_Campo IN Scfr_Diccionario.Nombre_Campo%TYPE
                             ,p_Valor_Campo  IN NUMBER
                             ,x_Datos_Trx    IN OUT BLOB);

  PROCEDURE Agrega_Cvalor_Trx(p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                             ,p_Nombre_Campo IN Scfr_Diccionario.Nombre_Campo%TYPE
                             ,p_Valor_Campo  IN VARCHAR2
                             ,x_Datos_Trx    IN OUT BLOB);

  PROCEDURE Agrega_Bvalor_Trx(p_Valor     IN BLOB
                             ,x_Datos_Trx IN OUT BLOB);

  FUNCTION Obtiene_Largo_Trama(p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE) RETURN NUMBER;

  PROCEDURE Setea_Correlativo_Trp(p_Correlativo_Trp IN Scfr_Log_Debug.Correlativo_Trp%TYPE);

  FUNCTION Obtiene_Correlativo_Trp RETURN NUMBER;

  FUNCTION Contiene_Trama(p_Cuerpo_Tx    IN Tab_Cuerpo_Tx
                         ,p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE) RETURN BOOLEAN;

  PROCEDURE Obtiene_Datos_Campo(p_Nombre_Campo IN Scfr_Diccionario.Nombre_Campo%TYPE
                               ,x_Diccionario  OUT Scfr_Diccionario%ROWTYPE);

  PROCEDURE Obtiene_Datos_Campo(p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                               ,p_Nombre_Campo IN Scfr_Diccionario.Nombre_Campo%TYPE
                               ,x_Diccionario  OUT Scfr_Diccionario%ROWTYPE);

  PROCEDURE Genera_Tipos_Dinamicos;

  PROCEDURE Genera_Carga_Tipos_Dinamicos;

  PROCEDURE Genera_Arma_Raw_Tramas;

  FUNCTION Agrega_Iva(p_Cad_Cadena  IN NUMBER
                     ,p_Emp_Empresa IN NUMBER
                     ,p_Loc_Local   IN NUMBER
                     ,p_Iva         IN OUT NUMBER) RETURN VARCHAR2;   
  
  --INI JAGC 20250818
  --FUNCTION Limpia_ANSI(p_Texto IN VARCHAR2, p_Tamano IN PLS_INTEGER) RETURN VARCHAR2;                  
  --FIN JAGC 20250818
  
  --funcion para limpiar string DQUEZADA
  FUNCTION Limpiar_String(p_Texto IN VARCHAR2) RETURN VARCHAR2;
  
END Scfr_Trx_Dyn_Pk;
/
CREATE OR REPLACE PACKAGE BODY TRX3.Scfr_Trx_Dyn_Pk AS

  FUNCTION Version_Pkg RETURN VARCHAR2 AS
  BEGIN
    RETURN Vversion;
  END;

  /******************************************************************************
   NAME:       scfr_trx_dyn_pk
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        02-12-2004             1. Created this package..
  ******************************************************************************/
  FUNCTION Obtiene_Hijos(p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                        ,x_Lista_Tramas OUT Tab_Trama) RETURN BOOLEAN IS
    l_Hijos Tab_Trama;
    l_Itm   NUMBER := 1;
  BEGIN
    x_Lista_Tramas := Scfr_Trx_Dyn_Def_Pk.Get_Dat_Trama(p_Codigo_Trama);
    l_Itm          := x_Lista_Tramas.Count;
    IF l_Itm > 0 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20000
                             ,'Hijos no encontrados - ' || SQLERRM);
  END;

  -- Obtiene VARCHAR2 Transaccion
  FUNCTION Campo_Tx_Varchar2(p_Transaccion IN BLOB
                            ,p_Largo       IN NUMBER
                            ,p_Posicion    IN NUMBER) RETURN VARCHAR2 IS
    l_To_Charset   VARCHAR2(100);
    l_From_Charset VARCHAR2(100);
  BEGIN
    BEGIN
      SELECT Nvl(TRIM(Rv_Low_Value)
                ,'UTF8') To_Charset
            ,Nvl(TRIM(Rv_High_Value)
                ,'WE8MSWIN1252') From_Charset
        INTO l_To_Charset
            ,l_From_Charset
        FROM Cg_Ref_Codes
       WHERE Rv_Domain = 'PARAMETROS'
         AND Rv_Abbreviation = 'CONVERT_BLOB'
         AND Rownum = 1;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_To_Charset   := NULL;
        l_From_Charset := NULL;
    END;
    IF (l_To_Charset IS NULL) THEN
      RETURN Utl_Raw.Cast_To_Varchar2(Dbms_Lob.Substr(p_Transaccion
                                                     ,p_Largo
                                                     ,p_Posicion));
    ELSE
      IF (p_Largo = 0) THEN
        RETURN '';
      ELSE

        RETURN Utl_Raw.Cast_To_Varchar2(Utl_Raw.Convert(Dbms_Lob.Substr(p_Transaccion
                                                                       ,p_Largo
                                                                       ,p_Posicion)
                                                       ,l_To_Charset
                                                       ,l_From_Charset));
      END IF;
    END IF;

  END Campo_Tx_Varchar2;

  FUNCTION Obtiene_Nro_Campos_Trama(p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE) RETURN NUMBER IS
    l_Nro_Campos_Trama NUMBER;
    l_Def_Trama        Scfr_Trx_Dyn_Def_Pk.Tab_Def_Mod_Dyn;
  BEGIN
    l_Def_Trama := Scfr_Trx_Dyn_Def_Pk.Get_Def_Trama(p_Codigo_Trama);
    RETURN l_Def_Trama.Count;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  PROCEDURE Obtiene_Datos_Campo(p_Nombre_Campo IN Scfr_Diccionario.Nombre_Campo%TYPE
                               ,x_Diccionario  OUT Scfr_Diccionario%ROWTYPE) IS
  BEGIN
    -- Dbms_Output.Put_Line('campo=>' || p_Nombre_Campo);
    -- busca datos del campo.
    SELECT * INTO x_Diccionario FROM Scfr_Diccionario WHERE Nombre_Campo = Upper(Ltrim(p_Nombre_Campo));
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20000
                             ,'Datos del campo no encontrado - ' || SQLERRM);
  END;

  PROCEDURE Obtiene_Datos_Campo(p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                               ,p_Nombre_Campo IN Scfr_Diccionario.Nombre_Campo%TYPE
                               ,x_Diccionario  OUT Scfr_Diccionario%ROWTYPE) IS
  BEGIN
    -- busca datos del campo (pero tomando el largo de la definicion de la trama).
    SELECT Di.Codigo_Diccionario
          ,Di.Descripcion
          ,Di.Tipo
          ,Cd.Largo
          ,Di.Nombre_Campo
      INTO x_Diccionario
      FROM Scfr_Diccionario          Di
          ,Scfr_Catalogo_Diccionario Cd
     WHERE Di.Nombre_Campo = Upper(p_Nombre_Campo)
       AND Di.Codigo_Diccionario = Cd.Codigo_Diccionario
       AND Cd.Tipo_Info = p_Codigo_Trama;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20000
                             ,'Datos del campo no encontrado en SCFR_CATALOGO_DICCIONARIO para des=>' || p_Nombre_Campo || ' trama=> ' ||
                              p_Codigo_Trama || '- ' || SQLERRM);
  END;

  FUNCTION Busca_Campo(p_Datos_Trx    IN Tab_Cuerpo_Tx
                      ,p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                      ,p_Codigo_Campo IN Scfr_Diccionario.Codigo_Diccionario%TYPE
                      ,p_Itera_Valor  IN NUMBER DEFAULT 1
                      ,p_Itera_Indice IN NUMBER DEFAULT 1) RETURN NUMBER IS
    l_Itm NUMBER;
    l_Pos NUMBER;
  BEGIN
    l_Pos := 0;
    FOR l_Itm IN 1 .. p_Datos_Trx.Count
    LOOP
      IF p_Datos_Trx(l_Itm).Codigo_Trama = p_Codigo_Trama AND
         p_Datos_Trx(l_Itm).Codigo_Campo = p_Codigo_Campo AND
         p_Datos_Trx(l_Itm).Itera_Valor = p_Itera_Valor AND
         p_Datos_Trx(l_Itm).Itera_Indice = p_Itera_Indice THEN
        l_Pos := l_Itm;
        EXIT;
      END IF;
    END LOOP;
    RETURN l_Pos;
  END;

  FUNCTION Busca_Campo(p_Datos_Trx    IN Tab_Cuerpo_Tx
                      ,p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                      ,p_Nombre_Campo IN Scfr_Diccionario.Nombre_Campo%TYPE
                      ,p_Itera_Valor  IN NUMBER DEFAULT 1
                      ,p_Itera_Indice IN NUMBER DEFAULT 1) RETURN NUMBER IS
    l_Itm NUMBER;
    l_Pos NUMBER;
  BEGIN
    l_Pos := 0;
    -- busca por el nombre del campo o por la descripci?n.
    FOR l_Itm IN 1 .. p_Datos_Trx.Count
    LOOP
      IF p_Datos_Trx(l_Itm).Codigo_Trama = p_Codigo_Trama AND
          (p_Datos_Trx(l_Itm).Nombre_Campo = p_Nombre_Campo OR p_Datos_Trx(l_Itm).Desc_Campo = p_Nombre_Campo) AND
         p_Datos_Trx(l_Itm).Itera_Valor = p_Itera_Valor AND
         p_Datos_Trx(l_Itm).Itera_Indice = p_Itera_Indice THEN
        l_Pos := l_Itm;
        EXIT;
      END IF;
    END LOOP;
    RETURN l_Pos;
  END;

  FUNCTION Obtiene_Codigo_Transaccion(p_Transaccion      IN BLOB
                                     ,p_Codigo_Trama_Hpo IN VARCHAR2) RETURN VARCHAR2 IS
    l_Orden      NUMBER;
    l_Largo      NUMBER;
    l_Pos        NUMBER;
    l_Itm        NUMBER;
    l_Codigo_Trx VARCHAR2(6);
    l_Def_Trama  Scfr_Trx_Dyn_Def_Pk.Tab_Def_Mod_Dyn;
  BEGIN
    l_Pos       := 1;
    l_Largo     := 0;
    l_Def_Trama := Scfr_Trx_Dyn_Def_Pk.Get_Def_Trama(p_Codigo_Trama_Hpo);
    -- Dbms_Output.Put_Line('trama =>' || l_Def_Trama.Count);
    FOR l_Itm IN 1 .. l_Def_Trama.Count
    LOOP
      -- Dbms_Output.Put_Line(l_Def_Trama(l_Itm).Nombre_Campo);
      IF l_Def_Trama(l_Itm).Nombre_Campo IN (k_Sistema
                          ,k_Funcion
                          ,k_Secuencia) THEN
        l_Largo := l_Largo + l_Def_Trama(l_Itm).Largo_Campo;
        IF l_Def_Trama(l_Itm).Nombre_Campo = k_Secuencia THEN
          EXIT;
        END IF;
      ELSE
        l_Pos := l_Pos + l_Def_Trama(l_Itm).Largo_Campo;
      END IF;
    END LOOP;
    --    l_Codigo_Trx := Utl_Raw.Cast_To_Varchar2(Dbms_Lob.Substr(p_Transaccion
    --                                                            ,l_Largo
    --                                                            ,l_Pos));
    l_Codigo_Trx := Campo_Tx_Varchar2(p_Transaccion
                                     ,l_Largo
                                     ,l_Pos);
    RETURN l_Codigo_Trx;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20000
                             ,'C?digo TRX no encontrado - ' || SQLERRM);
  END;

  PROCEDURE Agrega_Trama(p_Transaccion  IN BLOB
                        ,p_Codigo_Trx   IN VARCHAR2
                        ,p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                        ,p_Itm          IN OUT NUMBER
                        ,p_Pos          IN OUT NUMBER
                        ,x_Datos_Trx    IN OUT Tab_Cuerpo_Tx) IS
    l_Pos_Relativa NUMBER := 1;
    l_Cod_Error    NUMBER;
    l_Msg_Error    VARCHAR2(100);
    l_Def_Trama    Scfr_Trx_Dyn_Def_Pk.Tab_Def_Mod_Dyn;
    r_Trama        Scfr_Trx_Dyn_Def_Pk.Rec_Def_Mod_Dyn;
    l_Itm          NUMBER;
  BEGIN
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                              ,p_Msg     => 'Obteniendo detalle de trama');
    --for r_trama in c_trama(p_codigo_trama) loop
    l_Def_Trama := Scfr_Trx_Dyn_Def_Pk.Get_Def_Trama(p_Codigo_Trama);
    FOR l_Itm IN 1 .. l_Def_Trama.Count
    LOOP
      r_Trama := l_Def_Trama(l_Itm);
      x_Datos_Trx(p_Itm).Codigo_Trx := p_Codigo_Trx;
      x_Datos_Trx(p_Itm).Codigo_Trama := r_Trama.Codigo_Trama;
      x_Datos_Trx(p_Itm).Nombre_Trama := r_Trama.Nombre_Trama;
      x_Datos_Trx(p_Itm).Itera_Trama := r_Trama.Itera_Trama;
      x_Datos_Trx(p_Itm).Itera_Valor := 1;
      x_Datos_Trx(p_Itm).Codigo_Campo := r_Trama.Codigo_Campo;
      x_Datos_Trx(p_Itm).Desc_Campo := r_Trama.Desc_Campo;
      x_Datos_Trx(p_Itm).Nombre_Campo := r_Trama.Nombre_Campo;
      x_Datos_Trx(p_Itm).Largo_Campo := r_Trama.Largo_Campo;
      x_Datos_Trx(p_Itm).Tipo_Campo := r_Trama.Tipo_Campo;
      x_Datos_Trx(p_Itm).Pos_Relativa := l_Pos_Relativa;
      x_Datos_Trx(p_Itm).Pos_Absoluta := p_Pos;
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                ,p_Msg     => '  -> Campo (' || r_Trama.Codigo_Campo || ')' || r_Trama.Nombre_Campo || ' Tipo=>' ||
                                              r_Trama.Tipo_Campo || ' Largo=>' || r_Trama.Largo_Campo || ' pos=>' || x_Datos_Trx(p_Itm).Pos_Absoluta);
      x_Datos_Trx(p_Itm).Valor_Campo := Dbms_Lob.Substr(p_Transaccion
                                                       ,x_Datos_Trx(p_Itm).Largo_Campo
                                                       ,p_Pos);
      IF x_Datos_Trx(p_Itm).Tipo_Campo = k_Tipo_Numerico THEN
        x_Datos_Trx(p_Itm).Valor_Campon := Scfr_Trx_Util_Pk.Bin2num(Dbms_Lob.Substr(p_Transaccion
                                                                                   ,x_Datos_Trx(p_Itm).Largo_Campo
                                                                                   ,p_Pos));
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                  ,p_Msg     => '    -> Valor Campo =>' || x_Datos_Trx(p_Itm).Valor_Campon);
      ELSIF x_Datos_Trx(p_Itm).Tipo_Campo = k_Tipo_Caracter THEN
        --        x_Datos_Trx(p_Itm).Valor_Campoc := Utl_Raw.Cast_To_Varchar2(Dbms_Lob.Substr(p_Transaccion
        --                                                                                   ,x_Datos_Trx(p_Itm).Largo_Campo
        --                                                                                   ,p_Pos));
        x_Datos_Trx(p_Itm).Valor_Campoc := Campo_Tx_Varchar2(p_Transaccion
                                                            ,x_Datos_Trx(p_Itm).Largo_Campo
                                                            ,p_Pos);
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                  ,p_Msg     => '    -> Valor Campo =>' || x_Datos_Trx(p_Itm).Valor_Campoc);
      ELSE
        x_Datos_Trx(p_Itm).Valor_Campon := NULL;
        x_Datos_Trx(p_Itm).Valor_Campoc := NULL;
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                  ,p_Msg     => '    -> Valor Campo => NULO');
      END IF;
      p_Pos          := p_Pos + x_Datos_Trx(p_Itm).Largo_Campo;
      p_Itm          := p_Itm + 1;
      l_Pos_Relativa := p_Pos;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20000
                             ,'Trama ' || p_Codigo_Trama || ' no agregada - ' || SQLERRM);
  END;

  PROCEDURE Agrega_Trama_Htx(p_Transaccion  IN BLOB
                            ,p_Codigo_Trx   IN VARCHAR2
                            ,p_Itm          IN OUT NUMBER
                            ,p_Pos          IN OUT NUMBER
                            ,x_Datos_Trx    IN OUT Tab_Cuerpo_Tx
                            ,x_Codigo_Trama IN OUT Scfr_Catalogo.Tipo_Info%TYPE
                            ,x_Cantidad_Reg IN OUT NUMBER) IS
    l_Itm_Ini NUMBER;
    l_Itm_Aux NUMBER;
  BEGIN
    l_Itm_Ini := p_Itm;
    Agrega_Trama(p_Transaccion
                ,p_Codigo_Trx
                ,k_Trama_Header_Ctx
                ,p_Itm -- OUT.
                ,p_Pos -- OUT.
                ,x_Datos_Trx); -- OUT.
    -- Recupera Trama y cantidad de registros.
    x_Codigo_Trama := Obtiene_Cvalor_Trx(x_Datos_Trx
                                        ,k_Trama_Header_Ctx
                                        ,k_Tipo_Informacion);
    x_Cantidad_Reg := Obtiene_Nvalor_Trx(x_Datos_Trx
                                        ,k_Trama_Header_Ctx
                                        ,k_Cantidad_Registros);
    FOR l_Itm_Aux IN l_Itm_Ini .. x_Datos_Trx.Count
    LOOP
      IF l_Itm_Aux = l_Itm_Ini THEN
        x_Datos_Trx(l_Itm_Aux).Trama_Nivel := 0;
      END IF;
      x_Datos_Trx(l_Itm_Aux).Codigo_Trama := x_Codigo_Trama;
    END LOOP;
  END;

  FUNCTION Setea_Transaccion(p_Transaccion   IN BLOB
                            ,x_Codigo_Error  OUT NUMBER
                            ,x_Mensaje_Error OUT VARCHAR2) RETURN Rec_Transaccion IS
    l_Transaccion Rec_Transaccion;
  BEGIN
    l_Transaccion.Cuerpo_Tx := Parsea_Transaccion(p_Transaccion
                                                 ,x_Codigo_Error
                                                 ,x_Mensaje_Error);
    l_Transaccion.Trama_Pos := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Hpo(l_Transaccion.Cuerpo_Tx);
    l_Transaccion.Trama_Boc := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Hbo(l_Transaccion.Cuerpo_Tx);
    RETURN l_Transaccion;
  END;

  FUNCTION Devuelve_Tabla(p_Tipo IN VARCHAR2) RETURN VARCHAR2 IS
    l_Tabla      VARCHAR2(100);
    l_Tipo_Tabla VARCHAR2(20);
  BEGIN
    IF p_Tipo = 'L' THEN
      l_Tipo_Tabla := 'EN_LINEA';
    ELSIF p_Tipo = 'H' THEN
      l_Tipo_Tabla := 'HISTORICA';
    ELSE
      l_Tipo_Tabla := 'EN_LINEA';
    END IF;
    BEGIN
      SELECT Rv_High_Value
        INTO l_Tabla
        FROM Cg_Ref_Codes
       WHERE Rv_Domain = 'TABLAS_RESOLUTOR'
         AND Rv_Low_Value = l_Tipo_Tabla;
    EXCEPTION
      WHEN OTHERS THEN
        l_Tabla := 'SCFR_TRX_REC_POS';
    END;
    RETURN l_Tabla;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'SCFR_TRX_REC_POS';
  END Devuelve_Tabla;

  FUNCTION Parsea_Transaccion(p_Correlativo   IN NUMBER
                             ,p_Origen_Trx    IN VARCHAR2 DEFAULT 'P' -- (p)os, (c)entral
                             ,p_Tabla         IN VARCHAR2 DEFAULT 'L' -- (l)inea , (h)istorica
                             ,x_Codigo_Error  OUT NUMBER
                             ,x_Mensaje_Error OUT VARCHAR2) RETURN Tab_Cuerpo_Tx IS
    l_Entrada   BLOB;
    l_Cuerpo_Tx Tab_Cuerpo_Tx;
    l_Sql       VARCHAR2(1000);
    l_Tabla     VARCHAR2(100);
    --
    l_Avanza NUMBER;
    --
  BEGIN
    l_Tabla := Devuelve_Tabla(p_Tabla);
    l_Sql   := 'SELECT ';
    IF p_Origen_Trx = 'P' THEN
      l_Sql := l_Sql || 'string_entrada ';
    ELSE
      l_Sql := l_Sql || 'string_salida ';
    END IF;
    l_Sql := l_Sql || ' FROM ' || l_Tabla || ' WHERE correlativo = ' || To_Char(p_Correlativo);

    EXECUTE IMMEDIATE l_Sql
      INTO l_Entrada;

    l_Cuerpo_Tx := Parsea_Transaccion(l_Entrada
                                     ,x_Codigo_Error
                                     ,x_Mensaje_Error);
    --
    FOR l_Avanza IN 1 .. l_Cuerpo_Tx.Count
    LOOP
      l_Cuerpo_Tx(l_Avanza).Valor_Campo := NULL;
    END LOOP;
    --
    RETURN l_Cuerpo_Tx;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_Cuerpo_Tx;
  END;

  FUNCTION Parsea_Transaccion(p_Transaccion   IN BLOB
                             ,x_Codigo_Error  OUT NUMBER
                             ,x_Mensaje_Error OUT VARCHAR2) RETURN Tab_Cuerpo_Tx IS
    l_Cuerpo_Tx         Tab_Cuerpo_Tx;
    l_Transaccion_Aux   BLOB;
    l_Itmtrama          NUMBER;
    l_Itmtramahijo      NUMBER;
    l_Itm               NUMBER := 1;
    l_Pos               NUMBER := 1;
    l_Pos_Aux           NUMBER;
    l_Largo_Registro    NUMBER;
    l_Origen_Trx        VARCHAR2(3);
    l_Codigo_Trama_Aux  Scfr_Catalogo.Tipo_Info%TYPE;
    l_Codigo_Trama_Aux2 Scfr_Catalogo.Tipo_Info%TYPE;
    l_Codigo_Trama_Aux3 Scfr_Catalogo.Tipo_Info%TYPE;
    l_Codigo_Trx        VARCHAR2(6);
    l_Codigo_Trx_Aux    VARCHAR2(6);
    l_Orden             NUMBER;
    l_Largo             NUMBER;
    l_Largo_Trx_Def     NUMBER;
    l_Largo_Trx_Real    NUMBER;
    l_Cantidad_Reg      NUMBER;
    l_Agrega_Htx        BOOLEAN;
    l_Numreg            NUMBER;
    l_Nro_Campos_Trama  NUMBER;
    l_Cuenta_Campos     NUMBER;
    l_Contador_Hijo     NUMBER;
    l_Cantidad_Reg_Hijo NUMBER;
    l_Largo_Campo       NUMBER;
    l_Cod_Error         NUMBER;
    l_Aux10             NUMBER;
    l_Msg_Error         VARCHAR2(100);
    l_Modo_Largo_Campos Scfr_Catalogo.Modo_Largo_Campos%TYPE;
    l_Codigo_Trama      Scfr_Catalogo.Tipo_Info%TYPE;
    r_Hijos             Tab_Trama;
    r_Diccionario       Scfr_Diccionario%ROWTYPE;
    l_Def_Trama         Scfr_Trx_Dyn_Def_Pk.Tab_Def_Mod_Dyn;
    l_Def_Trama_Hija    Scfr_Trx_Dyn_Def_Pk.Tab_Def_Mod_Dyn;
    r_Trama             Scfr_Trx_Dyn_Def_Pk.Rec_Def_Mod_Dyn;
    r_Trama_Hija        Scfr_Trx_Dyn_Def_Pk.Rec_Def_Mod_Dyn;
    VARIABLE            RAW(2);
  BEGIN

    Scfr_Trx_Gnc_Utl_Pk.Set_Nls('NLS_LANGUAGE');

    x_Codigo_Error  := 0;
    x_Mensaje_Error := NULL;
    -- obtiene c?digo de transacci?n (genera exception).
    -- ejemplo => 'GNCU01', 'EXCU01', 'FIDI01'.
    l_Codigo_Trx := Obtiene_Codigo_Transaccion(p_Transaccion
                                              ,k_Trama_Header_Pos);
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                              ,p_Msg     => 'C?digo Transacci?n ' || l_Codigo_Trx || ' encontrado');
    -- Dbms_Output.Put_Line('ENTRO' || l_Codigo_Trx);
    -- Agrega trama POS a transacci?n (genera Exception).
    Agrega_Trama(p_Transaccion
                ,l_Codigo_Trx
                ,k_Trama_Header_Pos
                ,l_Itm -- OUT.
                ,l_Pos -- OUT.
                ,l_Cuerpo_Tx); -- OUT.
    -- Agrega trama HBO a transacci?n (genera Exception).
    Agrega_Trama(p_Transaccion
                ,l_Codigo_Trx
                ,k_Trama_Header_Boc
                ,l_Itm -- OUT.
                ,l_Pos -- OUT.
                ,l_Cuerpo_Tx); -- OUT.
    l_Origen_Trx := Ltrim(Rtrim(Obtiene_Cvalor_Trx(l_Cuerpo_Tx
                                                  ,k_Trama_Header_Pos
                                                  ,'ORIGEN_TRANSACCION')));
    -- Obtiene el largo que deber?a tener la transacci?n (seg?n modelo dinamico)
    l_Largo_Trx_Def := Obtiene_Largo_Trama(k_Trama_Header_Pos) + Obtiene_Nvalor_Trx(l_Cuerpo_Tx
                                                                                   ,Scfr_Trx_Dyn_Pk.k_Trama_Header_Pos
                                                                                   ,'LARGO_TOTAL_BUFFER');
    -- Obtiene el largo real de la transacci?n
    --l_largo_trx_real := utl_raw.length( p_transaccion );
    l_Largo_Trx_Real := Dbms_Lob.Getlength(p_Transaccion);
    -- chequea que los largos sean iguales, sino registra el problema
    IF l_Largo_Trx_Def != l_Largo_Trx_Real THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.PARSEA_TRANSACCION'
                                ,p_Msg     => 'Inconsistencia en Largo Real (' || l_Largo_Trx_Real || ') y Largo Registrado en transacci?n (' ||
                                              l_Largo_Trx_Def || ')');
    END IF;
    -- revisa las tramas que vienen en la transacci?n.
    WHILE (l_Pos < l_Largo_Trx_Def)
    LOOP
      -- Agrega trama (cabecera) HTX a estructura temporal (genera Exception).
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                ,p_Msg     => '    -> (1)Pos =>' || l_Pos);
      Agrega_Trama_Htx(p_Transaccion
                      ,l_Codigo_Trx
                      ,l_Itm -- OUT.
                      ,l_Pos -- OUT.
                      ,l_Cuerpo_Tx -- OUT.
                      ,l_Codigo_Trama -- OUT.
                      ,l_Cantidad_Reg -- OUT.
                       );
      -- Obtiene Modo Largo de los Campos (genera Exception).
      l_Modo_Largo_Campos := Obtiene_Cvalor_Trx(l_Cuerpo_Tx
                                               ,l_Codigo_Trama
                                               ,'MODO_LARGO_CAMPOS');
      -- soluci?n agregada solo para dar soluci?n a cambios por PinCenter
      --dbms_output.put_line( 'codigo_trama=>'||l_codigo_trama||' origen=>'||l_origen_trx );
      l_Codigo_Trama_Aux  := NULL;
      l_Codigo_Trama_Aux2 := NULL;

      IF l_Codigo_Trama = 'AE' THEN
        IF l_Origen_Trx IN ('SOL') THEN
          l_Codigo_Trama_Aux := 'AE9';
        END IF;
      END IF;

      --JRC 11/03/2020 Origen_Trx 'EMP' Excendemte al medio de pago
      --Se agregan a la trama RR campos Tipo de Documento y Folio
      IF l_Codigo_Trama = 'RR' THEN
        IF l_Origen_Trx IN ('EMP'
                           ,'CPE') THEN
          l_Codigo_Trama_Aux := 'RR1';
        END IF;
      END IF;

      --//--------------------------------------------------------------------------\\
      --// CBR 17/06/2020 00:15                                                     \\
      --// Validacion numero de serie en Biometria                                  \\
      --// Nueva Trama NS con Origen_transaccion NRB                                \\
      --//-----------------------------------------------------------------Inicio---\\
      IF l_Codigo_Trama = 'NS' THEN
        IF l_Origen_Trx IN ('NRB') THEN
          l_Codigo_Trama_Aux := 'NS9';
        ELSE
          l_Codigo_Trama_Aux := NULL;
        END IF;
      END IF;
      --//-----------------------------------------------------------------Termino--\\

      --
      --//--------------------------------------------------------------------------\\
      --// CBR 17/08/2020 04:14                                                     \\
      --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
      --//                                                                          \\
      --//-----------------------------------------------------------------Inicio---\\
      IF l_Codigo_Trama = 'DB' THEN
        IF l_Origen_Trx IN ('DEC'
                           ,'ABF'
                           ,'SAL' -- LMP 2023 GPF Ecuador
                           ,'ADR'
                           ,'PEX'
                           ,'EC1'
                           ,'RYT') THEN
          l_Codigo_Trama_Aux := 'DB9';
        ELSIF l_Origen_Trx IN ('SAM'
                              ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                              ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                              ,'VCO'
                              ,'DON'
                              ,'MOP'
                              ,'OMS') THEN
          l_Codigo_Trama_Aux := 'DB1';
        END IF;
      END IF;
      IF l_Codigo_Trama = 'CV' THEN
        IF l_Origen_Trx IN ('DEC') THEN
          l_Codigo_Trama_Aux := 'CV9';
        ELSIF l_Origen_Trx IN ('ABF'
                              ,'SAL' -- LMP 2023 GPF Ecuador
                              ,'ADR'
                              ,'PEX'
                              ,'EC1'
                              ,'RYT') THEN
          l_Codigo_Trama_Aux := 'CV1';
        ELSIF l_Origen_Trx IN ('SAM'
                              ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                              ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                              ,'VCO'
                              ,'DON'
                              ,'MOP'
                              ,'OMS') THEN
          l_Codigo_Trama_Aux := 'CV3';

        END IF;
      END IF;
      --//-----------------------------------------------------------------Termino--\\
      IF l_Codigo_Trama = 'PM' THEN
        IF l_Origen_Trx IN ('SGN'
                           ,'OTN'
                           ,'CCR'
                           ,'ISP'
                           ,'COR'
                           ,'SQF'
                           ,'CCV') THEN
          l_Codigo_Trama_Aux := 'PM9';
        ELSIF l_Origen_Trx IN ('PRE'
                              ,'FFR'
                              ,'DFS'
                              ,'AUC'
                              ,'BOX'
                              ,'GLO'
                              ,'FEL'
                              ,'FAT'
                              ,'CIA'
                              ,'EMP') THEN
          l_Codigo_Trama_Aux := 'PM8';
        ELSIF l_Origen_Trx IN ('DEC'
                              ,'ABF'
                              ,'SAL' -- LMP 2023 GPF Ecuador
                              ,'ADR'
                              ,'PEX'
                              ,'EC1') THEN
          l_Codigo_Trama_Aux := 'PM0';
        ELSIF l_Origen_Trx IN ('RYT'
                              ,'SAM'
                              ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              --,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                              ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                              ,'VCO'
                              ,'DON'
                              ,'MOP'
                              ,'OMS') THEN
          l_Codigo_Trama_Aux := 'P10';
        ELSIF l_Origen_Trx IN (
                              'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                             ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ) THEN
          l_Codigo_Trama_Aux := 'P15';
        ELSE
          l_Codigo_Trama_Aux := NULL; -- 'MET'
        END IF;
      END IF;
      IF l_Codigo_Trama = 'DR' THEN
        IF l_Origen_Trx IN ('MET' -- 'EMP',
                           ,'TBK'
                           ,'DEV'
                           ,'PRM') THEN
          l_Codigo_Trama_Aux := 'DR9';
        ELSIF l_Origen_Trx IN ('FEC'
                              ,'FJC'
                              ,'MAG') THEN
          l_Codigo_Trama_Aux := 'DR8';
        ELSIF l_Origen_Trx IN ('PRE'
                              ,'SGN') THEN
          l_Codigo_Trama_Aux := 'DR7';
        ELSIF l_Origen_Trx IN ('OTN') THEN
          l_Codigo_Trama_Aux := 'DR6';
        ELSIF l_Origen_Trx IN ('DFS'
                              ,'AUC'
                              ,'BOX'
                              ,'GLO'
                              ,'FEL'
                              ,'FAT'
                              ,'CIA'
                              ,'EMP'
                              ,'DEC'
                              ,'ABF'
                              ,'SAL' -- LMP 2023 GPF Ecuador
                              ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                              ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                              ,'ADR'
                              ,'PEX'
                              ,'EC1'
                              ,'RYT'
                              ,'SAM'
                              ,'VCO'
                              ,'DON'
                              ,'MOP'
                              ,'OMS') THEN
          l_Codigo_Trama_Aux := 'DR5';
        ELSE
          l_Codigo_Trama_Aux := 'DR';
        END IF;
      END IF;
      
      IF l_Codigo_Trama = 'DH' THEN
        IF l_Origen_Trx IN ('OTN') THEN
          l_Codigo_Trama_Aux := 'DH9';
        ELSE
          l_Codigo_Trama_Aux := NULL;
        END IF;
      END IF;
      IF l_Codigo_Trama = 'PI' THEN
        IF l_Origen_Trx IN ('VRM') THEN
          l_Codigo_Trama_Aux := 'PI8';
        ELSIF l_Origen_Trx IN ('OTN') THEN
          l_Codigo_Trama_Aux := 'PI7';
        ELSIF l_Origen_Trx IN ('STS'
                              ,'DEC'
                              ,'ABF'
                              ,'SAL' -- LMP 2023 GPF Ecuador
                              ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                              ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                              ,'ADR'
                              ,'PEX'
                              ,'EC1'
                              ,'SAM') THEN
          --JRC 19/12/2019 Agrega campo Motivo en la trama PI de la EXCU01
          l_Codigo_Trama_Aux := 'PI3';
        ELSIF l_Origen_Trx IN ('ERP') THEN
          l_Codigo_Trama_Aux := 'PI5';
        ELSIF l_Origen_Trx IN ('TRA') THEN --JRC 27/04/2023 PI9 nace de PI5
          l_Codigo_Trama_Aux := 'PI9';
        ELSIF l_Origen_Trx IN ('FGI') THEN --JAGC 20250414 ORIGEN FGI
          l_Codigo_Trama_Aux := 'PIA';
        ELSIF l_Origen_Trx IN ('SLV') THEN --IDHC 20260623 ORIGEN SLV
          l_Codigo_Trama_Aux := 'PI11'; -- nace de PIA
        ELSE
          l_Codigo_Trama_Aux := 'PI';
        END IF;
      END IF;
      IF l_Codigo_Trama = 'MD' THEN
        IF l_Origen_Trx IN ('VRM') THEN
          l_Codigo_Trama_Aux := 'MD8';
        ELSIF l_Origen_Trx IN ('STS') THEN
          --JRC 19/12/2019
          l_Codigo_Trama_Aux := 'MD4';
        ELSIF l_Origen_Trx IN ('DEC'
                              ,'ABF'
                              ,'SAL' -- LMP 2023 GPF Ecuador
                              ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                              ,'ADR'
                              ,'PEX'
                              ,'EC1'
                              ,'SAM'
                              ,'TRA'
          ) --JRC 25/07/2023 para la SubTrama MD campo Numero Item largo 4
         THEN
          l_Codigo_Trama_Aux := 'MD7';
        ELSIF l_Origen_Trx IN ('IVA') THEN
          --JRC 20/07/2027 campo motivo de 25 a 250 con origen IVA
          l_Codigo_Trama_Aux := 'MD9';
        ELSIF l_Origen_Trx IN ('FTR'
          ) THEN
          --JRC 27/09/2023 Origen FTR(Factura Transacciones Relacionadas)
          l_Codigo_Trama_Aux := 'MDa';
        ELSIF l_Origen_Trx IN ('FGI' --JAGC 20250414 ORIGEN FGI
          ) THEN
          --JRC 27/09/2023 Origen FTR(Factura Transacciones Relacionadas)
          l_Codigo_Trama_Aux := 'MDB';
        ELSE
          l_Codigo_Trama_Aux := 'MD';
        END IF;
      END IF;
      IF l_Codigo_Trama = 'DP' THEN
        IF l_Origen_Trx IN ('ABF') THEN
          l_Codigo_Trama_Aux := 'DP8';
        ELSIF l_Origen_Trx IN ('ADR'
                              ,'PEX'
                              ,'EC1'
                              ,'RYT'
                              ,'SAM'
                              ,'SAL' -- LMP 2023 GPF Ecuador
                              ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                              ,'VCO'
                              ,'DON'
                              ,'MOP'
                              ,'OMS') THEN
          l_Codigo_Trama_Aux := 'DP5';
        ELSIF l_Origen_Trx IN (
                              'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                             ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ) THEN
          l_Codigo_Trama_Aux := 'DPA';
        ELSIF l_Origen_Trx IN ('BOX') THEN
          l_Codigo_Trama_Aux := 'DP7';
        ELSIF l_Origen_Trx IN ('GLO'
                              ,'FEL'
                              ,'FAT'
                              ,'CIA'
                              ,'EMP') THEN
          l_Codigo_Trama_Aux := 'DP9';
          --//--------------------------------------------------------------------------\\
          --// CBR 16/08/2020 23:47                                                     \\
          --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
          --//-----------------------------------------------------------------Inicio---\\
        ELSIF l_Origen_Trx IN ('DEC') THEN
          l_Codigo_Trama_Aux := 'DP6';
          --//-----------------------------------------------------------------Termino--\\
        ELSE
          l_Codigo_Trama_Aux := 'DP9';
        END IF;
      END IF;
      IF l_Codigo_Trama = 'DV' THEN
        IF l_Origen_Trx IN ('OTN'
                           ,'CCR'
                           ,'ISP'
                           ,'COR'
                           ,'BOX'
                           ,'GLO'
                           ,'FEL') THEN
          l_Codigo_Trama_Aux := 'DV9';
        ELSIF l_Origen_Trx IN ('FAT'
                              ,'CIA'
                              ,'EMP') THEN
          l_Codigo_Trama_Aux := 'DV';
        ELSIF l_Origen_Trx IN ('DEV') THEN
          l_Codigo_Trama_Aux := 'DV7';
        ELSIF l_Origen_Trx IN ('EC1') THEN
          l_Codigo_Trama_Aux := 'DV6';
        ELSIF l_Origen_Trx IN ('RYT'
                              ,'SAM'
                               --,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'VCO') THEN
          l_Codigo_Trama_Aux := 'D10';
        ELSIF l_Origen_Trx IN ('DON') THEN
          --FCG 04082022 DONACIONES MX
          l_Codigo_Trama_Aux := 'D11';
        ELSIF l_Origen_Trx IN ('OMS'
                             -- ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                               ) THEN
          --FCG 21082023
          l_Codigo_Trama_Aux := 'D12';
        ELSIF l_Origen_Trx IN ('CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                               ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                               --,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                               ) THEN
          --FCG 21082023
          l_Codigo_Trama_Aux := 'D13';  
        
        -- INI JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC    
        ELSIF l_Origen_Trx IN (
                                'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                               ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ) THEN
          l_Codigo_Trama_Aux := 'D14';
        -- FIN JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC    
         
          --//--------------------------------------------------------------------------\\
          --// CBR 19/08/2020 10:05                                                     \\
          --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
          --// Se reutiliza trama DV5 por ser la mas antigua                            \\
          --//-----------------------------------------------------------------Inicio---\\
        ELSIF l_Origen_Trx IN ('DEC'
                              ,'ABF'
                              ,'SAL' -- LMP 2023 GPF Ecuador
                              ,'ADR'
                              ,'PEX') THEN
          -- 'FEC','FJC','PRE','MAG','FFR','SGN'
          l_Codigo_Trama_Aux := 'DV5';
          --//-----------------------------------------------------------------Termino--\\
        END IF;
      END IF;

      IF l_Codigo_Trama = 'AR' THEN
        IF l_Origen_Trx IN ('ABF'
                           ,'ADR') THEN
          l_Codigo_Trama_Aux := 'AR9';
        ELSIF l_Origen_Trx IN ('PEX'
                              ,'EC1'
                              ,'SAL' -- LMP 2023 GPF Ecuador
                              ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                              ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                              ,'SAM') THEN
          l_Codigo_Trama_Aux := 'AR7';
        ELSE
          l_Codigo_Trama_Aux := 'AR';
        END IF;
      END IF;

      IF l_Codigo_Trama = 'AC' THEN
        IF l_Origen_Trx IN ('SCB'
                           ,'ATR'
                            --,'EMP'
                           ,'PDM'
                           ,'ASC'
                           ,'MTL'
                           ,'MET') THEN
          l_Codigo_Trama_Aux := 'AC9';
          -- JRG CIA 04/06/219
        ELSIF l_Origen_Trx IN ('CIA'
                              ,'EMP'
                              ,'DEC') THEN
          l_Codigo_Trama_Aux := 'AC2';
        ELSIF l_Origen_Trx IN ('ABF'
                              ,'ADR'
                              ,'PEX'
                              ,'EC1') THEN
          l_Codigo_Trama_Aux := 'AC3';
        ELSIF l_Origen_Trx IN ('BNM') THEN
          l_Codigo_Trama_Aux := 'AC8';
        ELSIF l_Origen_Trx IN ('SAM'
                              --,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                               ) THEN
          l_Codigo_Trama_Aux := 'AC7';
        ELSIF l_Origen_Trx IN ('SAL'
                              ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                              ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                               ) THEN
          -- LMP 2023 GPF Ecuador
          l_Codigo_Trama_Aux := 'AC4';
        ELSE
          l_Codigo_Trama_Aux := 'AC'; -- dto
        END IF;
      END IF;
      IF l_Codigo_Trama = 'PE' THEN
        IF l_Origen_Trx IN ('BNM'
                           ,'PRM'
                           ,'EBM'
                           ,'FEC'
                           ,'PRE'
                           ,'SGN'
                           ,'OTN'
                           ,'DPE'
                           ,'CCR'
                           ,'SQF'
                           ,'CCV'
                           ,'DFS'
                           ,'AUC'
                           ,'BOX'
                           ,'GLO'
                           ,'FEL'
                           ,'FAT'
                           ,'CIA'
                           ,'EMP') THEN
          l_Codigo_Trama_Aux := 'PE9';
        ELSIF l_Origen_Trx IN ('DEC'
                              ,'ABF'
                              ,'SAL' -- LMP 2023 GPF Ecuador
                              ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                              ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                              ,'ADR'
                              ,'PEX'
                              ,'EC1'
                              ,'RYT'
                              ,'SAM'
                              ,'VCO'
                              ,'DON'
                              ,'MOP'
                              ,'OMS') THEN
          l_Codigo_Trama_Aux := 'PE8';
        ELSE
          l_Codigo_Trama_Aux := 'PE';
        END IF;
      END IF;
      IF l_Codigo_Trama = 'MP' THEN
        IF l_Origen_Trx IN ('DEC'
                           ,'ABF'
                           ,'SAL' -- LMP 2023 GPF Ecuador
                           ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                           ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                           ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                           ,'ADR'
                           ,'PEX'
                           ,'EC1'
                           ,'RYT'
                           ,'SAM'
                           ,'VCO'
                           ,'DON'
                           ,'MOP'
                           ,'OMS') THEN
          l_Codigo_Trama_Aux := 'MP9';
        ELSE
          l_Codigo_Trama_Aux := 'MP';
        END IF;
      END IF;
      IF l_Codigo_Trama = 'PO' THEN
        IF l_Origen_Trx IN ('MTL') THEN
          l_Codigo_Trama_Aux := 'PO9';
        ELSIF l_Origen_Trx IN ('MET') THEN
          l_Codigo_Trama_Aux := 'PO8';
        ELSIF l_Origen_Trx IN ('BNM'
                              ,'EBM'
                              ,'DPE'
                              ,'CCR'
                              ,'SQF'
                              ,'CCV'
                              ,'CIA'
                              ,'EMP'
                              ,'DEC'
                              ,'ABF'
                              ,'ADR'
                              ,'PEX'
                              ,'EC1'
                              ,'SAL' -- LMP 2023 GPF Ecuador
                              --,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              --,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                              ,'SAM') THEN
          l_Codigo_Trama_Aux := 'PO7';
         ELSIF l_Origen_Trx IN ('MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                             ) THEN
          l_Codigo_Trama_Aux := 'PO6';
        ELSE
          l_Codigo_Trama_Aux := 'PO'; -- MTL
        END IF;
      END IF;
      IF l_Codigo_Trama = 'PL' THEN
        IF l_Origen_Trx IN ('CCR'
                           ,'COR'
                           ,'SQF'
                           ,'CCV'
                           ,'CIA'
                           ,'EMP'
                           ,'DEC'
                           ,'ABF'
                           ,'ADR'
                           ,'PEX'
                           ,'EC1') THEN
          l_Codigo_Trama_Aux := 'PL9';
        ELSIF l_Origen_Trx IN ('SAM'
                              ,'SAL'
                              ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                              ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                               ) THEN
          -- LMP 2023 GPF Ecuador
          l_Codigo_Trama_Aux := 'PL1';
          /*
          ELSIF l_Origen_Trx IN ('SAL') THEN
            -- LMP 2023 GPF Ecuador
            l_Codigo_Trama_Aux := 'PL';
            */
        ELSE
          l_Codigo_Trama_Aux := NULL; -- MTL
        END IF;
      END IF;
      IF l_Codigo_Trama = 'RP' THEN
        IF l_Origen_Trx IN ('DTO'
                           ,'UNI'
                           ,'REC'
                           ,'ATR'
                            --,'EMP'
                           ,'ASC'
                           ,'MET'
                           ,'CTG'
                           ,'BNM'
                           ,'DEV'
                           ,'PRM'
                           ,'DTE'
                           ,'FEC'
                           ,'FJC'
                           ,'PRE'
                           ,'MAG'
                           ,'FFR'
                           ,'SGN'
                           ,'OTN') THEN
          l_Codigo_Trama_Aux := 'RP9';
        ELSIF l_Origen_Trx IN ('CCR'
                              ,'ISP'
                              ,'COR'
                              ,'SQF'
                              ,'CCV'
                              ,'SPA'
                              ,'BIO'
                              ,'GLO'
                              ,'BOX'
                              ,'FEL'
                              ,'FAT'
                              ,'CIA'
                              ,'EMP') THEN
          --erika 29112018
          l_Codigo_Trama_Aux := 'RP8';
        ELSIF l_Origen_Trx IN ('DEC'
                              ,'ABF'
                              ,'SAL' -- LMP 2023 GPF Ecuador
                              ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                              ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                              ,'ADR'
                              ,'PEX'
                              ,'EC1'
                              ,'SAM') THEN
          l_Codigo_Trama_Aux := 'RP7';
        ELSE
          l_Codigo_Trama_Aux := NULL;
        END IF;
      END IF;
      IF l_Codigo_Trama = 'RI' THEN
        IF l_Origen_Trx IN ('CCR'
                           ,'ISP'
                           ,'SQF'
                           ,'BOX'
                           ,'CCV'
                           ,'GLO'
                           ,'FEL'
                           ,'FAT'
                           ,'CIA'
                           ,'EMP') THEN
          l_Codigo_Trama_Aux := 'RI9';
        ELSIF l_Origen_Trx IN ('DEC'
                              ,'ABF'
                              ,'SAL' -- LMP 2023 GPF Ecuador
                              ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                              ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                              ,'ADR'
                              ,'PEX'
                              ,'EC1'
                              ,'RYT'
                              ,'SAM'
                              ,'VCO'
                              ,'DON'
                              ,'MOP'
                              ,'OMS') THEN
          l_Codigo_Trama_Aux := 'RI8';
        ELSE
          l_Codigo_Trama_Aux := NULL; --CCR
        END IF;
      END IF;
      IF l_Codigo_Trama = 'CA' THEN
        IF l_Origen_Trx IN ('CAM'
                           ,'REC'
                           ,'ATR'
                            --,'EMP'
                           ,'MTL'
                           ,'MET'
                           ,'CTG'
                           ,'BNM') THEN
          l_Codigo_Trama_Aux := 'CA9';
        ELSIF l_Origen_Trx IN ('PRM'
                              ,'FEC'
                              ,'CCR'
                              ,'ISP'
                              ,'COR'
                              ,'SQF'
                              ,'CCV') THEN
          l_Codigo_Trama_Aux := 'CA8';
          -------------------------------------------------------------
          -- LMP 2023 GPF Agregado c?digo para origen tx 'SAL'
          -------------------------------------------------------------
        ELSIF l_Origen_Trx IN ('SPA'
                              ,'BIO'
                              ,'GLO'
                              ,'BOX'
                              ,'FEL'
                              ,'FAT'
                              ,'CIA'
                              ,'EMP'
                              ,'DEC'
                              ,'ABF'
                              ,'SAL' -- LMP Ecuador 2023 GPF
                              ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                              ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                              ,'ADR'
                              ,'PEX'
                              ,'EC1'
                              ,'SAM') THEN
          l_Codigo_Trama_Aux := 'CA7';
        ELSE
          l_Codigo_Trama_Aux := NULL;
        END IF;
      END IF;

      IF l_Codigo_Trama = 'EX' THEN
        IF l_Origen_Trx IN ('EMP'
                           ,'CPE'
                           ,'DEC'
                           ,'ABF'
                           ,'SAL' -- LMP 2023 GPF Ecuador
                           ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                           ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                           ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                           ,'ADR'
                           ,'PEX'
                           ,'EC1'
                           ,'SAM') THEN
          l_Codigo_Trama_Aux := 'EX9';
        ELSE
          l_Codigo_Trama_Aux := NULL;
        END IF;
      END IF;

      IF l_Codigo_Trama = 'PU' THEN
        IF l_Origen_Trx IN ('PRM'
                           ,'FEC'
                           ,'CCR'
                           ,'ISP'
                           ,'COR'
                           ,'SQF'
                           ,'CCV'
                           ,'SPA'
                           ,'BIO'
                           ,'GLO'
                           ,'BOX'
                           ,'FEL'
                           ,'FAT'
                           ,'CIA'
                           ,'EMP') THEN
          l_Codigo_Trama_Aux := 'PU9';
          --//--------------------------------------------------------------------------\\
          --// CBR 16/08/2020 23:21                                                     \\
          --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
          --//-----------------------------------------------------------------Inicio---\\
          -------------------------------------------------------------
          -- LMP 2023 GPF Agregado c?digo para origen tx 'SAL'
          -------------------------------------------------------------
        ELSIF l_Origen_Trx IN ('DEC'
                              ,'ABF'
                              ,'SAL'
                              ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                              ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                              ,'ADR'
                              ,'PEX'
                              ,'EC1'
                              ,'SAM') THEN
          l_Codigo_Trama_Aux := 'PU8';
          --//-----------------------------------------------------------------Termino--\\
        ELSE
          l_Codigo_Trama_Aux := NULL;
        END IF;
      END IF;
      IF l_Codigo_Trama = 'FP' THEN
        IF l_Origen_Trx IN ('REC'
                           ,'ATR'
                            --,'EMP'
                           ,'MET') THEN
          l_Codigo_Trama_Aux := 'FP9';
        ELSIF l_Origen_Trx IN ('TBK'
                              ,'DEV'
                              ,'DTE'
                              ,'PRM'
                              ,'FEC') THEN
          l_Codigo_Trama_Aux := 'FP8';
        ELSIF l_Origen_Trx IN ('EC1') THEN
          l_Codigo_Trama_Aux := 'FP6';
        ELSIF l_Origen_Trx IN ('CHE') THEN
          l_Codigo_Trama_Aux := 'FP4';
        ELSIF l_Origen_Trx IN ('OMS') THEN
          --FCG Nuevo campo Autorizacion online
          l_Codigo_Trama_Aux := 'FP2';
        ELSIF l_Origen_Trx IN ('USD') THEN
          l_Codigo_Trama_Aux := 'FP3';
        ELSIF l_Origen_Trx IN ('FJC'
                              ,'PRE'
                              ,'FFR'
                              ,'SGN'
                              ,'CCR'
                              ,'COR'
                              ,'SQF'
                              ,'CCV') THEN
          l_Codigo_Trama_Aux := 'FP7';
        ELSIF l_Origen_Trx IN ('DEC'
                              ,'ABF'
                              ,'SAL' -- LMP 2023 GPF Ecuador
                              ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                              ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                              ,'ADR'
                              ,'PEX'
                              ,'SAM') THEN
          l_Codigo_Trama_Aux := 'FP5';
        ELSE
          l_Codigo_Trama_Aux := NULL;
        END IF;
      END IF;
      IF l_Codigo_Trama = 'CO' THEN
        IF l_Origen_Trx IN ('PEX'
                           ,'EC1'
                           ,'SAM'
                           ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                           --,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                           ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                            ) THEN
          l_Codigo_Trama_Aux := 'CO';
        ELSIF l_Origen_Trx IN ('CCR'
                              ,'ISP'
                              ,'COR') THEN
          l_Codigo_Trama_Aux := 'CO7';
        ELSIF l_Origen_Trx IN ('SQF') THEN
          l_Codigo_Trama_Aux := 'CO6';
        ELSIF l_Origen_Trx IN ('CCV'
                              ,'SPA') THEN
          l_Codigo_Trama_Aux := 'CO5';
        ELSIF l_Origen_Trx IN ('BOX'
                              ,'BIO'
                              ,'GLO') THEN
          l_Codigo_Trama_Aux := 'CO4';
        ELSIF l_Origen_Trx IN ('FEL'
                              ,'FAT') THEN
          l_Codigo_Trama_Aux := 'CO3';
        ELSIF l_Origen_Trx IN ('CIA'
                              ,'EMP'
                              ,'CPE'
                              ,'DEC'
                              ,'ABF'
                              ,'ADR') THEN
          -- JRG CIA 04/06/219
          l_Codigo_Trama_Aux := 'CO0';
          ----------------------------------------------
          --- LMP 4/2023 Para origen trx SAL... nace de trama CO
          ----------------------------------------------
        ELSIF l_Origen_Trx IN (
                                'SAL'
                                ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ) THEN
          l_Codigo_Trama_Aux := 'COA';
          -----------------------------------------------
        ELSE
          l_Codigo_Trama_Aux := 'CO';
        END IF;
      END IF;
      IF l_Codigo_Trama = 'VA' THEN
        IF l_Origen_Trx IN ('IMV') THEN
          l_Codigo_Trama_Aux := 'VA9';
        ELSIF l_Origen_Trx IN ('ABF'
                              ,'ADR'
                              ,'PEX'
                              ,'EC1'
                               --,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'SAM') THEN
          l_Codigo_Trama_Aux := 'VA3';
        ELSIF l_Origen_Trx IN ('ADE') THEN
          l_Codigo_Trama_Aux := 'VA5';
        ELSIF l_Origen_Trx IN ('CIA'
                              ,'EMP'
                              ,'DEC') THEN
          l_Codigo_Trama_Aux := 'VA2';
          ---------------------------------------------------------
          --- LMP 5/2023 GPF Ecuador
          --  Para origen trx SAL... nace de trama VA5
          ---------------------------------------------------------
        ELSIF l_Origen_Trx IN ('SAL'
                              ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                              ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                               ) THEN
          l_Codigo_Trama_Aux := 'VA6';
          -----------------------------------------------
        ELSIF l_Origen_Trx IN ('CCR'
                              ,'COR'
                              ,'SQF'
                              ,'CCV') THEN
          l_Codigo_Trama_Aux2 := 'VA8';
        END IF;
      END IF;
      IF l_Codigo_Trama = 'PQ' THEN
        IF l_Origen_Trx IN ('MET'
                           ,'BNM'
                           ,'IMV'
                           ,'CCR'
                           ,'COR'
                           ,'SQF'
                           ,'CCV'
                           ,'CIA'
                           ,'EMP'
                           ,'DEC'
                           ,'ABF'
                           ,'ADR'
                           ,'PEX'
                           ,'EC1'
                            --,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                           ,'SAM') THEN
          l_Codigo_Trama_Aux := 'PQ9';
        ELSIF l_Origen_Trx IN ('SAL'
                              ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                              ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                               ) THEN
          -- LMP 5/2023 Para origen trx SAL
          l_Codigo_Trama_Aux := 'PQ7';
        ELSIF l_Origen_Trx IN ('ADE'
                               --,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                               ) THEN
          l_Codigo_Trama_Aux := 'PQ8';
        END IF;
      END IF;

      IF l_Codigo_Trama = 'PX' THEN
        IF l_Origen_Trx IN ('CPE') THEN
          l_Codigo_Trama_Aux := 'PX9';
        END IF;
      END IF;

      IF l_Codigo_Trama = 'VR' THEN
        IF l_Origen_Trx IN ('CCR'
                           ,'COR'
                           ,'SQF'
                           ,'CCV'
                           ,'CIA'
                           ,'EMP'
                           ,'DEC') THEN
          l_Codigo_Trama_Aux := 'VR9';
        ELSIF l_Origen_Trx IN ('ABF'
                              ,'SAL' -- LMP 2023 GPF Ecuador
                              ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                              ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                              ,'ADR'
                              ,'PEX'
                              ,'EC1'
                              ,'SAM') THEN
          l_Codigo_Trama_Aux := 'VR1';
        ELSIF l_Origen_Trx IN ('ADE'
                               --,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
          ) THEN
          l_Codigo_Trama_Aux := 'VR8';
        END IF;
      END IF;
      IF l_Codigo_Trama = 'VD' THEN
        IF l_Origen_Trx IN ('MTL'
                           ,'MET') THEN
          l_Codigo_Trama_Aux := 'VD9';
        ELSIF l_Origen_Trx IN ('FEC'
                              ,'FJC'
                              ,'MAG') THEN
          l_Codigo_Trama_Aux := 'VD8';
        END IF;
      END IF;
      IF l_Codigo_Trama = 'HC' THEN
        IF l_Origen_Trx IN ('CTG') THEN
          l_Codigo_Trama_Aux := 'HC9';
          -------------------------------------------------------------
          -- LMP 2023 GPF Agregado c?digo para origen tx 'SAL'
          -------------------------------------------------------------
        ELSIF l_Origen_Trx IN ('DEC'
                              ,'ABF'
                              ,'SAL'
                              ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                              ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                              ,'ADR'
                              ,'PEX'
                              ,'EC1'
                              ,'SAM') THEN
          l_Codigo_Trama_Aux := 'HC8';
        END IF;
      END IF;
      IF l_Codigo_Trama = 'GD' THEN
        l_Codigo_Trama_Aux := 'GD';

        --        IF l_Origen_Trx IN ('DFS'
        --                           ,'ETV') THEN
        --          l_Codigo_Trama_Aux := 'GD9';
        --        ELSIF l_Origen_Trx IN ('DEC') THEN
        --          l_Codigo_Trama_Aux := 'GD8';
        --        ELSE
        --          l_Codigo_Trama_Aux := NULL;
        --        END IF;
      END IF;
      IF l_Codigo_Trama = 'MC' THEN
        IF l_Origen_Trx IN ('DEC'
                           ,'ABF'
                           ,'SAL' -- LMP 2023 GPF Ecuador
                           ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                           ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                           ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                           ,'ADR'
                           ,'PEX'
                           ,'EC1'
                           ,'SAM') THEN
          l_Codigo_Trama_Aux := 'MC';
        ELSE
          l_Codigo_Trama_Aux := NULL;
        END IF;
      END IF;
      IF l_Codigo_Trama = 'OR' THEN
        IF l_Origen_Trx IN ('EXP') THEN
          l_Codigo_Trama_Aux := 'OR1';
        ELSIF l_Origen_Trx IN ('OTN') THEN
          l_Codigo_Trama_Aux := 'OR2';
        ELSIF l_Origen_Trx IN ('SAP') THEN
          l_Codigo_Trama_Aux := 'OR3';
        ELSE
          l_Codigo_Trama_Aux := NULL;
        END IF;
      END IF;
      IF l_Codigo_Trama = 'OC' THEN
        IF l_Origen_Trx IN ('OTN') THEN
          -- l_Codigo_Trama_Aux := 'OC1';
          l_Codigo_Trama_Aux := 'OC9';
        ELSIF l_Origen_Trx IN ('SAP') THEN
          l_Codigo_Trama_Aux := 'OC8';
        ELSE
          l_Codigo_Trama_Aux := NULL;
        END IF;
      END IF;
      IF l_Codigo_Trama = 'DO' THEN
        IF l_Origen_Trx IN ('OTN') THEN
          l_Codigo_Trama_Aux := 'DO1';
        ELSIF l_Origen_Trx IN ('SAP') THEN
          l_Codigo_Trama_Aux := 'DO2';
        ELSE
          l_Codigo_Trama_Aux := NULL;
        END IF;
      END IF;
      IF l_Codigo_Trama = 'DL' THEN
        IF l_Origen_Trx IN ('EXC'
                            ,'GCC'-- JAGC 20250319
                            ) THEN
          l_Codigo_Trama_Aux := 'DL9';
        ELSIF l_Origen_Trx IN ('FGI' --JAGC 20250414 ORIGEN FGI
                            ) THEN
          l_Codigo_Trama_Aux := 'DLA';  
        ELSIF l_Origen_Trx IN ('DEC'
                              ,'ABF'
                              ,'SAL' -- LMP 2023 GPF Ecuador
                              ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                              ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                              ,'ADR'
                              ,'PEX'
                              ,'EC1'
                              ,'SAM'
                              ,'NLG') THEN -- IDHC origen NLG
          l_Codigo_Trama_Aux := 'DL8';
        ELSE
          l_Codigo_Trama_Aux := 'DL';
        END IF;
      END IF;
      IF l_Codigo_Trama = 'DJ' THEN
        IF l_Origen_Trx IN ('EXC'
                            ,'GCC'-- JAGC 20250319
                            ) THEN
          l_Codigo_Trama_Aux := 'DJ9';
        ELSIF l_Origen_Trx IN ('DEC'
                              ,'ABF'
                              ,'SAL' -- LMP 2023 GPF Ecuador
                              ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                              ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                              ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                              ,'ADR'
                              ,'PEX'
                              ,'EC1'
                              ,'SAM') THEN
          l_Codigo_Trama_Aux := 'DJ8';
        ELSE
          l_Codigo_Trama_Aux := 'DJ';
        END IF;
      END IF;
      IF l_Codigo_Trama = 'AB' THEN
        IF l_Origen_Trx IN ('DEC'
                           ,'ABF'
                           ,'SAL' -- LMP 2023 GPF Ecuador
                           ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                           ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                           ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                           ,'ADR'
                           ,'PEX'
                           ,'EC1'                           
                           ,'SAM') THEN
          l_Codigo_Trama_Aux := 'AB9';
        ELSIF l_Origen_Trx IN ('FGI' --JAGC 20250414 ORIGEN FGI
                           ) THEN
          l_Codigo_Trama_Aux := 'AB10';
        ELSE
          l_Codigo_Trama_Aux := NULL;
        END IF;
      END IF;

      IF l_Codigo_Trama = 'ID' THEN
        IF l_Origen_Trx IN ('EXC'
                            ,'GCC'-- JAGC 20250319
                            ) THEN
          l_Codigo_Trama_Aux := 'ID9';
        ELSE
          l_Codigo_Trama_Aux := 'ID';
        END IF;
      END IF;
      IF l_Codigo_Trama = 'EC' THEN
        IF l_Origen_Trx IN ('EXC'
                           ,'DEC'
                           ,'GCC'-- JAGC 20250319
                           ,'ABF'
                           ,'SAL' -- LMP 2023 GPF Ecuador
                           ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                           ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                           ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                           ,'ADR'
                           ,'PEX'
                           ,'EC1'
                           ,'SAM') THEN
          l_Codigo_Trama_Aux := 'EC9';
        ELSE
          l_Codigo_Trama_Aux := 'EC';
        END IF;
      END IF;
      IF l_Codigo_Trama = 'ED' THEN
        IF l_Origen_Trx IN ('EXC'
                            ,'GCC'-- JAGC 20250319
                            ) THEN
          l_Codigo_Trama_Aux := 'ED9';
        ELSE
          l_Codigo_Trama_Aux := 'ED';
        END IF;
      END IF;
      IF l_Codigo_Trama = 'GF' THEN
        IF l_Origen_Trx IN ('EXC'
                           ,'GCC'-- JAGC 20250319
                           ,'DEC'
                           ,'ABF'
                            --,'SAL' --JRC 30/08/203 Comento -- LMP 2023 GPF Ecuador
                           ,'ADR'
                           ,'PEX'
                           ,'EC1'
                           ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                           ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                           ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                           ,'SAM') THEN
          l_Codigo_Trama_Aux := 'GF9';
        ELSIF l_Origen_Trx IN ('NUF' --JRC 30/08/2023 Unificando EXCU17 desde Yza a Ecuador
                              ,'BNT'
                              ,'SAL'
                              ,'NLG' -- JAGC 20240319
                              ,'FGI' --JAGC 20250414 ORIGEN FGI
                              ) --JRC 30/08/2023 Agrego SAL ac? y la saqu? de arriba
         THEN
          l_Codigo_Trama_Aux := 'GF8'; --JRC 30/08/2023 GF8 tiene un campo(Numero_Factura VARCHAR2(30)) mas que GF9
        ELSE
          l_Codigo_Trama_Aux := 'GF';
        END IF;
      END IF;
      
      --INI JAGC 20240909 NECESIDADES 'NEC' 
      IF l_Codigo_Trama = 'NI' THEN
        IF l_Origen_Trx IN (
                               'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                              ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ) THEN
          l_Codigo_Trama_Aux := 'NI';
        ELSE
          l_Codigo_Trama_Aux := 'NI';
        END IF;
      END IF;
      
      IF l_Codigo_Trama = 'IB' THEN
        IF l_Origen_Trx IN (
                               'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                              ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ) THEN
          l_Codigo_Trama_Aux := 'IB';
        ELSE
          l_Codigo_Trama_Aux := 'IB';
        END IF;
      END IF;
      --FIN JAGC 20240909 NECESIDADES 'NEC' 

      --JRC 28/04/2023
      IF l_Codigo_Trama = 'GP' THEN
        IF l_Origen_Trx IN ('TRA'
                           ,'FGI' --JAGC 20250414 ORIGEN FGI
          ) THEN
          l_Codigo_Trama_Aux := 'GP3';
        ELSE
          l_Codigo_Trama_Aux := 'GP';
        END IF;

      END IF;

      -- Chequea si la trama tiene tramas hijas.
      --//--------------------------------------------------------------------------\\
      --// CBR 10/09/2020 08:35                                                     \\
      --//                                                                          \\
      --//-----------------------------------------------------------------Inicio---\\
      ----------      l_Nro_Campos_Trama := NULL;
      ----------      IF l_Codigo_Trama IN ('PO'
      ----------                           ,) AND
      ----------         l_Origen_Trx = 'GES' THEN
      ----------        IF Obtiene_Hijos(l_Codigo_Trama_Aux
      ----------                        ,r_Hijos) THEN
      ----------          -- si tiene hijos, obtiene el n? de campos que tiene la trama
      ----------          l_Nro_Campos_Trama := Obtiene_Nro_Campos_Trama(Nvl(l_Codigo_Trama_Aux
      ----------                                                            ,l_Codigo_Trama));
      ----------        END IF;
      ----------      ELSE
      ----------        IF l_Origen_Trx NOT IN ('ATR'
      ----------                               ,'MTL'
      ----------                               ,'MET'
      ----------                               ,'CTG'
      ----------                               ,'BNM'
      ----------                               ,'PRM'
      ----------                               ,'FEC'
      ----------                               ,'PRE'
      ----------                               ,'FFR') AND
      ----------           l_Codigo_Trama = 'DP' THEN
      ----------          --  ,'SGN','OTN','CCR','ISP','COR','SQF','CCV','SPA'
      ----------          IF Obtiene_Hijos(l_Codigo_Trama_Aux
      ----------                          ,r_Hijos) THEN
      ----------            -- si tiene hijos, obtiene el n? de campos que tiene la trama
      ----------            l_Nro_Campos_Trama := Obtiene_Nro_Campos_Trama(Nvl(l_Codigo_Trama_Aux
      ----------                                                              ,l_Codigo_Trama));
      ----------          END IF;
      ----------          --//--------------------------------------------------------------------------\\
      ----------          --// CBR 12/27/2019 6:06PM                                                    \\
      ----------          --//                                                                          \\
      ----------          --//-----------------------------------------------------------------Inicio---\\
      ----------          --        ELSIF l_Origen_Trx IN ('VRM','OTN','STS') AND l_Codigo_Trama = 'PI' THEN
      ----------          --            IF l_Origen_Trx IN ('STS') THEN
      ----------          --              l_Codigo_Trama_Aux2 := ''
      ----------          --              --JRC 27/12/2019 agrego STS para campo motivo
      ----------          --              IF Obtiene_Hijos('PI3'
      ----------          --                              ,r_Hijos) THEN
      ----------          --                -- si tiene hijos, obtiene el n? de campos que tiene la trama
      ----------          --                l_Nro_Campos_Trama := Obtiene_Nro_Campos_Trama(Nvl(l_Codigo_Trama_Aux
      ----------          --                                                                  ,l_Codigo_Trama));
      ----------          --              END IF;
      ----------          --            ELSIF Obtiene_Hijos('PI8'
      ----------          --                               ,r_Hijos) THEN
      ----------          --              -- si tiene hijos, obtiene el n? de campos que tiene la trama
      ----------          --              l_Nro_Campos_Trama := Obtiene_Nro_Campos_Trama(Nvl(l_Codigo_Trama_Aux
      ----------          --                                                                ,l_Codigo_Trama));
      ----------          --            END IF;
      ----------          --//-----------------------------------------------------------------Termino--\\
      ----------        ELSIF l_Origen_Trx IN ('ISP' -- 'DTE','PRM','FEC','FJC','PRE','MAG','FFR','SGN','OTN','CCR',
      ----------                              ,'COR'
      ----------                              ,'DFS'
      ----------                              ,'AUC'
      ----------                              ,'SQF'
      ----------                              ,'CCV'
      ----------                              ,'BOX'
      ----------                              ,'GLO'
      ----------                              ,'FEL'
      ----------                              ,'FAT'
      ----------                              ,'CIA'
      ----------                              ,'EMP'
      ----------                              ,'DEC') AND
      ----------              l_Codigo_Trama = 'PM' THEN
      ----------          IF Obtiene_Hijos(l_Codigo_Trama_Aux
      ----------                          ,r_Hijos) THEN
      ----------            -- si tiene hijos, obtiene el n? de campos que tiene la trama
      ----------            l_Nro_Campos_Trama := Obtiene_Nro_Campos_Trama(Nvl(l_Codigo_Trama_Aux
      ----------                                                              ,l_Codigo_Trama));
      ----------          END IF;
      ----------        ELSIF l_Origen_Trx IN ('ISP' --   'DTE','PRM','FEC','FJC','PRE','MAG','FFR','SGN','OTN','CCR'
      ----------                              ,'COR'
      ----------                              ,'SQF'
      ----------                              ,'CCV'
      ----------                              ,'BOX'
      ----------                              ,'GLO'
      ----------                              ,'FEL'
      ----------                              ,'FAT'
      ----------                              ,'CIA'
      ----------                              ,'EMP'
      ----------                              ,'DEC') AND
      ----------              l_Codigo_Trama =  THEN
      ----------          IF Obtiene_Hijos(l_Codigo_Trama_Aux
      ----------                          ,r_Hijos) THEN
      ----------            -- si tiene hijos, obtiene el n? de campos que tiene la trama
      ----------            l_Nro_Campos_Trama := Obtiene_Nro_Campos_Trama(Nvl(l_Codigo_Trama_Aux
      ----------                                                              ,l_Codigo_Trama));
      ----------          END IF;
      ----------        ELSIF l_Origen_Trx IN ('MET'
      ----------                              ,'MTL'
      ----------                              ,'BNM'
      ----------                              ,'EBM'
      ----------                              ,'DPE'
      ----------                              ,'ISP'
      ----------                              ,'CCR'
      ----------                              ,'SQF'
      ----------                              ,'CCV'
      ----------                              ,'BOX'
      ----------                              ,'GLO'
      ----------                              ,'FEL'
      ----------                              ,'FAT'
      ----------                              ,'CIA'
      ----------                              ,'EMP'
      ----------                              ,'DEC') AND
      ----------              l_Codigo_Trama = 'PO' THEN
      ----------          IF Obtiene_Hijos(l_Codigo_Trama_Aux
      ----------                          ,r_Hijos) THEN
      ----------            -- si tiene hijos, obtiene el n? de campos que tiene la trama
      ----------            l_Nro_Campos_Trama := Obtiene_Nro_Campos_Trama(Nvl(l_Codigo_Trama_Aux
      ----------                                                              ,l_Codigo_Trama));
      ----------          END IF;
      ----------        ELSIF l_Origen_Trx IN ('VRM'
      ----------                              ,'STS') AND
      ----------              l_Codigo_Trama = 'MD' THEN
      ----------          IF l_Origen_Trx IN ('STS') THEN
      ----------            --JRC 27/12/2019 Agrego STS campo Motivo
      ----------            IF Obtiene_Hijos('MD4'
      ----------                            ,r_Hijos) THEN
      ----------              -- si tiene hijos, obtiene el n? de campos que tiene la trama
      ----------              l_Nro_Campos_Trama := Obtiene_Nro_Campos_Trama(Nvl(l_Codigo_Trama_Aux
      ----------                                                                ,l_Codigo_Trama));
      ----------            END IF;
      ----------          ELSIF Obtiene_Hijos('MD8'
      ----------                             ,r_Hijos) THEN
      ----------            -- si tiene hijos, obtiene el n? de campos que tiene la trama
      ----------            l_Nro_Campos_Trama := Obtiene_Nro_Campos_Trama(Nvl(l_Codigo_Trama_Aux
      ----------                                                              ,l_Codigo_Trama));
      ----------          END IF;
      ----------        ELSIF l_Origen_Trx IN ('RRM') AND
      ----------              l_Codigo_Trama = 'MD' THEN
      ----------          IF Obtiene_Hijos('MD3'
      ----------                          ,r_Hijos) THEN
      ----------            -- si tiene hijos, obtiene el n? de campos que tiene la trama
      ----------            l_Nro_Campos_Trama := Obtiene_Nro_Campos_Trama(Nvl(l_Codigo_Trama_Aux
      ----------                                                              ,l_Codigo_Trama));
      ----------          END IF;
      ----------          /*
      ----------          ELSIF l_Origen_Trx IN ('CCR'
      ----------                                ,'ISP'
      ----------                                ,'COR'
      ----------                                ,'SQF'
      ----------                                ,'CCV'
      ----------                                ,'SPA'
      ----------                                ,'BIO'
      ----------                                ,'BOX'
      ----------                                ,'GLO'
      ----------                                ,'FEL'
      ----------                                ,'FAT'
      ----------                                ,'CIA'
      ----------                                ,'EMP','DEC') AND
      ----------                l_Codigo_Trama = 'RP' THEN
      ----------            IF Obtiene_Hijos('RP8'
      ----------                            ,r_Hijos) THEN
      ----------              -- si tiene hijos, obtiene el n? de campos que tiene la trama
      ----------              l_Nro_Campos_Trama := Obtiene_Nro_Campos_Trama(Nvl(l_Codigo_Trama_Aux
      ----------                                                                ,l_Codigo_Trama));
      ----------            END IF;
      ----------          */
      ----------        ELSIF l_Origen_Trx NOT IN ('SCB'
      ----------                                  ,'PDM'
      ----------                                  ,'ASC') AND
      ----------              l_Codigo_Trama = 'AR' THEN
      ----------          IF Obtiene_Hijos('AR9'
      ----------                          ,r_Hijos) THEN
      ----------            -- si tiene hijos, obtiene el n? de campos que tiene la trama
      ----------            l_Nro_Campos_Trama := Obtiene_Nro_Campos_Trama(Nvl(l_Codigo_Trama_Aux
      ----------                                                              ,l_Codigo_Trama));
      ----------          END IF;
      ----------           /*
      ----------                   elsif l_origen_trx in ('MTL') and l_codigo_trama = 'AR' then
      ----------                     if obtiene_hijos('AR9', r_hijos ) then
      ----------                       -- si tiene hijos, obtiene el n? de campos que tiene la trama
      ----------                       l_nro_campos_trama := obtiene_nro_campos_trama( nvl(l_codigo_trama_aux,l_codigo_trama) );
      ----------                     end if;
      ----------           */
      ----------        ELSIF Obtiene_Hijos(l_Codigo_Trama
      ----------                           ,r_Hijos) THEN
      ----------          -- si tiene hijos, obtiene el n? de campos que tiene la trama
      ----------          l_Nro_Campos_Trama := Obtiene_Nro_Campos_Trama(Nvl(l_Codigo_Trama_Aux
      ----------                                                            ,l_Codigo_Trama));
      ----------        END IF;
      ----------      END IF;
      --//-----------------------------------------------------------------Termino--\\

      l_Nro_Campos_Trama := NULL;
      IF Obtiene_Hijos(Nvl(l_Codigo_Trama_Aux
                          ,l_Codigo_Trama)
                      ,r_Hijos) THEN
        -- si tiene hijos, obtiene el n? de campos que tiene la trama
        l_Nro_Campos_Trama := Obtiene_Nro_Campos_Trama(Nvl(l_Codigo_Trama_Aux
                                                          ,l_Codigo_Trama));
      END IF;

      -- Busca datos del campo LARGO DE REGISTRO para agregar a la trama.
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                ,p_Msg     => 'Obteniendo detalle de trama ' || l_Codigo_Trama);
      Obtiene_Datos_Campo(k_Largo_Registro
                         ,r_Diccionario);
      -- Itera seg?n la cantidad de registros que vengan en la trama.
      FOR l_Numreg IN 1 .. l_Cantidad_Reg
      LOOP
        -- Agrega datos del largo del registro a la trama.
        l_Cuerpo_Tx(l_Itm).Codigo_Trx := l_Cuerpo_Tx(l_Itm - 1).Codigo_Trx;
        l_Cuerpo_Tx(l_Itm).Codigo_Trama := l_Cuerpo_Tx(l_Itm - 1).Codigo_Trama;
        l_Cuerpo_Tx(l_Itm).Nombre_Trama := l_Cuerpo_Tx(l_Itm - 1).Nombre_Trama;
        l_Cuerpo_Tx(l_Itm).Itera_Trama := l_Cuerpo_Tx(l_Itm - 1).Itera_Trama;
        l_Cuerpo_Tx(l_Itm).Itera_Valor := l_Numreg;
        l_Cuerpo_Tx(l_Itm).Itera_Nivel := 1;
        l_Cuerpo_Tx(l_Itm).Codigo_Campo := r_Diccionario.Codigo_Diccionario;
        l_Cuerpo_Tx(l_Itm).Desc_Campo := Upper(r_Diccionario.Descripcion);
        l_Cuerpo_Tx(l_Itm).Nombre_Campo := Upper(r_Diccionario.Nombre_Campo);
        l_Cuerpo_Tx(l_Itm).Largo_Campo := r_Diccionario.Largo;
        l_Cuerpo_Tx(l_Itm).Tipo_Campo := r_Diccionario.Tipo;
        l_Cuerpo_Tx(l_Itm).Valor_Campo := Dbms_Lob.Substr(p_Transaccion
                                                         ,l_Cuerpo_Tx(l_Itm).Largo_Campo
                                                         ,l_Pos);
        l_Cuerpo_Tx(l_Itm).Valor_Campon := Scfr_Trx_Util_Pk.Bin2num(Dbms_Lob.Substr(p_Transaccion
                                                                                   ,l_Cuerpo_Tx(l_Itm).Largo_Campo
                                                                                   ,l_Pos));
        l_Cuerpo_Tx(l_Itm).Pos_Absoluta := l_Pos;
        l_Largo_Registro := l_Cuerpo_Tx(l_Itm - 1).Valor_Campon;
        -- Obtiene definici?n de la trama (lista con los campos que la componen).
        l_Pos           := l_Pos + l_Cuerpo_Tx(l_Itm).Largo_Campo;
        l_Itm           := l_Itm + 1;
        l_Cuenta_Campos := 0;
        l_Contador_Hijo := 0;
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                  ,p_Msg     => '    -> (2)Pos =>' || l_Pos);
        l_Def_Trama := Scfr_Trx_Dyn_Def_Pk.Get_Def_Trama(Nvl(l_Codigo_Trama_Aux
                                                            ,l_Codigo_Trama));
        FOR l_Itmtrama IN 1 .. l_Def_Trama.Count
        LOOP
          r_Trama := l_Def_Trama(l_Itmtrama);
          IF l_Modo_Largo_Campos = 'V' THEN
            -- obtiene el largo de campo que viene a continuaci?n
            IF r_Trama.Largo_Campo > 0 THEN
              VARIABLE      := Dbms_Lob.Substr(p_Transaccion
                                              ,r_Trama.Largo_Campo
                                              ,l_Pos);
              l_Largo_Campo := Scfr_Trx_Util_Pk.Bin2num(Dbms_Lob.Substr(p_Transaccion
                                                                       ,r_Trama.Largo_Campo
                                                                       ,l_Pos));
              l_Pos         := l_Pos + r_Trama.Largo_Campo;
            ELSE
              l_Largo_Campo := Scfr_Trx_Util_Pk.Bin2num(Dbms_Lob.Substr(p_Transaccion
                                                                       ,1
                                                                       ,l_Pos));
              l_Pos         := l_Pos + 1;
            END IF;
            Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                      ,p_Msg     => '    -> (3)Pos =>' || l_Pos);
          END IF;
          Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                    ,p_Msg     => 'Largo Campo=>' || l_Largo_Campo);
          l_Cuerpo_Tx(l_Itm).Codigo_Trx := l_Codigo_Trx;
          l_Cuerpo_Tx(l_Itm).Codigo_Trama := l_Codigo_Trama;
          l_Cuerpo_Tx(l_Itm).Nombre_Trama := r_Trama.Nombre_Trama;
          l_Cuerpo_Tx(l_Itm).Itera_Trama := r_Trama.Itera_Trama;
          l_Cuerpo_Tx(l_Itm).Itera_Valor := l_Numreg;
          l_Cuerpo_Tx(l_Itm).Itera_Nivel := 1;
          l_Cuerpo_Tx(l_Itm).Codigo_Campo := r_Trama.Codigo_Campo;
          l_Cuerpo_Tx(l_Itm).Desc_Campo := r_Trama.Desc_Campo;
          l_Cuerpo_Tx(l_Itm).Nombre_Campo := r_Trama.Nombre_Campo;
          IF l_Modo_Largo_Campos = 'V' THEN
            Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                      ,p_Msg     => '7');
            l_Cuerpo_Tx(l_Itm).Largo_Campo := l_Largo_Campo;
          ELSE
            Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                      ,p_Msg     => '8');
            l_Cuerpo_Tx(l_Itm).Largo_Campo := r_Trama.Largo_Campo;
          END IF;
          l_Cuerpo_Tx(l_Itm).Tipo_Campo := r_Trama.Tipo_Campo;
          l_Cuerpo_Tx(l_Itm).Pos_Absoluta := l_Pos;
          Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                    ,p_Msg     => '  -> Campo (' || r_Trama.Codigo_Campo || ')' || r_Trama.Nombre_Campo || ' Tipo=>' ||
                                                  r_Trama.Tipo_Campo || ' Largo=>' || l_Cuerpo_Tx(l_Itm).Largo_Campo || ' pos=>' || l_Cuerpo_Tx(l_Itm).Pos_Absoluta);
          IF l_Cuerpo_Tx(l_Itm).Tipo_Campo = k_Tipo_Numerico THEN
            IF l_Cuerpo_Tx(l_Itm).Largo_Campo > 0 THEN
              l_Cuerpo_Tx(l_Itm).Valor_Campo := Dbms_Lob.Substr(p_Transaccion
                                                               ,l_Cuerpo_Tx(l_Itm).Largo_Campo
                                                               ,l_Pos);
              l_Cuerpo_Tx(l_Itm).Valor_Campon := Scfr_Trx_Util_Pk.Bin2num(Dbms_Lob.Substr(p_Transaccion
                                                                                         ,l_Cuerpo_Tx(l_Itm).Largo_Campo
                                                                                         ,l_Pos));
            ELSE
              l_Cuerpo_Tx(l_Itm).Valor_Campon := 0;
            END IF;
            Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                      ,p_Msg     => '    -> Valor Campo =>' || l_Cuerpo_Tx(l_Itm).Valor_Campon);
          ELSIF l_Cuerpo_Tx(l_Itm).Tipo_Campo = k_Tipo_Caracter THEN
            IF l_Cuerpo_Tx(l_Itm).Largo_Campo > 0 THEN
              l_Cuerpo_Tx(l_Itm).Valor_Campo := Dbms_Lob.Substr(p_Transaccion
                                                               ,l_Cuerpo_Tx(l_Itm).Largo_Campo
                                                               ,l_Pos);
              --              l_Cuerpo_Tx(l_Itm).Valor_Campoc := Convert(Utl_Raw.Cast_To_Varchar2(Dbms_Lob.Substr(p_Transaccion
              --                                                                                                 ,l_Cuerpo_Tx(l_Itm).Largo_Campo
              --                                                                                                 ,l_Pos))
              --                                                        ,'UTF8');
              l_Cuerpo_Tx(l_Itm).Valor_Campoc := Campo_Tx_Varchar2(p_Transaccion
                                                                  ,l_Cuerpo_Tx(l_Itm).Largo_Campo
                                                                  ,l_Pos);
            ELSE
              l_Cuerpo_Tx(l_Itm).Valor_Campoc := '';
            END IF;
            IF (Lengthb(l_Cuerpo_Tx(l_Itm).Valor_Campoc) > 60) THEN
              --C
              Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                        ,p_Msg     => '    -> Valor Campo =>' || Substr(l_Cuerpo_Tx(l_Itm).Valor_Campoc
                                                                                       ,1
                                                                                       ,60) || '(+)');
            ELSE
              Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                        ,p_Msg     => '    -> Valor Campo =>' || l_Cuerpo_Tx(l_Itm).Valor_Campoc);
            END IF;
          ELSIF l_Cuerpo_Tx(l_Itm).Tipo_Campo = k_Tipo_Binario THEN
            IF l_Cuerpo_Tx(l_Itm).Largo_Campo > 0 THEN
              l_Cuerpo_Tx(l_Itm).Valor_Campo := Dbms_Lob.Substr(p_Transaccion
                                                               ,l_Cuerpo_Tx(l_Itm).Largo_Campo
                                                               ,l_Pos);
            END IF;
          ELSE
            l_Cuerpo_Tx(l_Itm).Valor_Campon := NULL;
            l_Cuerpo_Tx(l_Itm).Valor_Campoc := NULL;
          END IF;
          l_Pos := l_Pos + l_Cuerpo_Tx(l_Itm).Largo_Campo;
          Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                    ,p_Msg     => '    -> (4)Pos =>' || l_Pos);
          l_Itm           := l_Itm + 1;
          l_Cuenta_Campos := l_Cuenta_Campos + 1;
          IF l_Cuenta_Campos > (l_Nro_Campos_Trama - r_Hijos.Count) THEN
            -- Obtiene n?mero de registros de la subtrama
            l_Contador_Hijo     := l_Contador_Hijo + 1;
            l_Cantidad_Reg_Hijo := l_Cuerpo_Tx(l_Itm - 1).Valor_Campon;
            FOR l_Itm_Hijo IN 1 .. l_Cantidad_Reg_Hijo
            LOOP
              l_Codigo_Trama_Aux2 := NULL;
              Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                        ,p_Msg     => '15');
              -- soluci?n agregada solo para dar soluci?n a cambios por PinCenter
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'DR1' THEN
                IF l_Origen_Trx IN ('AUC'
                                   ,'BOX'
                                   ,'GLO'
                                   ,'FEL'
                                   ,'FAT'
                                   ,'CIA'
                                   ,'EMP') THEN
                  l_Codigo_Trama_Aux2 := 'DR2';
                ELSIF l_Origen_Trx IN ('DEC'
                                      ,'ABF'
                                      ,'SAL' -- LMP 2023 GPF Ecuador
                                      ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                                      ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                      ,'NEU' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                                      ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                                      ,'ADR'
                                      ,'PEX'
                                      ,'EC1'
                                      ,'RYT'
                                      ,'SAM'
                                      ,'VCO'
                                      ,'DON'
                                      ,'MOP'
                                      ,'OMS') THEN
                  l_Codigo_Trama_Aux2 := 'DR3';
                ELSIF l_Origen_Trx IN ('ONS'
                               ,'OBE' --JAGC 20261022
                               ) THEN
                  l_Codigo_Trama_Aux2 := 'DR4';
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'RV1' THEN
                IF l_Origen_Trx IN ('DEC'
                                   ,'ABF'
                                   ,'SAL' -- LMP 2023 GPF Ecuador
                                   ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                                   ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                   ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                                   ,'ADR'
                                   ,'PEX'
                                   ,'EC1'
                                   ,'RYT'
                                   ,'SAM'
                                   ,'VCO'
                                   ,'DON'
                                   ,'MOP'
                                   ,'OMS') THEN
                  l_Codigo_Trama_Aux2 := 'RV2';
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;

              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'DL1' THEN
                IF l_Origen_Trx IN ('DEC'
                                   ,'ABF'
                                   ,'SAL' -- LMP 2023 GPF Ecuador
                                   ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                                   ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                   ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                                   ,'ADR'
                                   ,'PEX'
                                   ,'EC1'
                                   ,'SAM') THEN
                  l_Codigo_Trama_Aux2 := 'DL2';
               -- IDHC origen NLG 
                ELSIF l_Origen_Trx IN ('NLG'
                                      ,'FGI' -- JAGC 20251020 ORIGEN FGI                                       
                                      ) THEN
                  l_Codigo_Trama_Aux2 := 'DL3';
               -- fin IDHC   
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;
              
              -- IDHC origen NGL
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'GF1' THEN
                IF l_Origen_Trx IN ('NLG'
                                   ,'FGI' -- JAGC 20251020 ORIGEN FGI 
                                    ) THEN
                  l_Codigo_Trama_Aux2 := 'GF2';
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;
              -- fin IDHC

              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'DJ1' THEN
                IF l_Origen_Trx IN ('DEC'
                                   ,'ABF'
                                   ,'SAL' -- LMP 2023 GPF Ecuador
                                   ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                                   ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                   ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                                   ,'ADR'
                                   ,'PEX'
                                   ,'EC1'
                                   ,'SAM') THEN
                  l_Codigo_Trama_Aux2 := 'DJ2';
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;

              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'AB1' THEN
                IF l_Origen_Trx IN ('DEC'
                                   ,'ABF'
                                   ,'SAL' -- LMP 2023 GPF Ecuador
                                   ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                                   ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                   ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                                   ,'ADR'
                                   ,'PEX'
                                   ,'EC1'
                                   ,'FGI' -- JAGC 20250414 ORIGEN FGI
                                   ,'SAM') THEN
                  l_Codigo_Trama_Aux2 := 'AB2';
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;

              --//--------------------------------------------------------------------------\\
              --// CBR 12/14/2019 4:32PM                                                    \\
              --// nuevo campo en subrtama NA1                                              \\
              --//-----------------------------------------------------------------Inicio---\\
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'NA1' THEN
                IF l_Origen_Trx IN ('TUR') THEN
                  l_Codigo_Trama_Aux2 := 'NA2';
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;
              --//-----------------------------------------------------------------Termino--\\
              --//--------------------------------------------------------------------------\\
              --// CBR 12/27/2019 6:10PM                                                    \\
              --//-----------------------------------------------------------------Inicio---\\
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'PI1' THEN
                IF l_Origen_Trx IN ('OTN'
                                   ,'VRM'
                                   ,'STS') THEN
                  l_Codigo_Trama_Aux2 := 'PI2';
                  --FCG 19112020 Guias multiples
                ELSIF l_Origen_Trx IN ('DEC'
                                      ,'ABF'
                                      ,'SAL' -- LMP 2023 GPF Ecuador
                                      ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                                      ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                      ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                                      ,'ADR'
                                      ,'PEX'
                                      ,'EC1'
                                      ,'SAM') THEN
                  l_Codigo_Trama_Aux2 := 'PI4';
                ELSIF l_Origen_Trx IN ('ERP'
                                      ,'TRA'  --JRC 27/04/2023 Agrego 'TRA'
                                      ,'FGI'  --JAGC 20250414 ORIGEN FGI
                                      ,'SLV') -- IDHC 20260623 ORIGEN SLV
                                       THEN
                  l_Codigo_Trama_Aux2 := 'PI6';
                END IF;
              END IF;

              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'MD1' THEN
                IF l_Origen_Trx IN ('DEC'
                                   ,'ABF'
                                   ,'SAL' -- LMP 2023 GPF Ecuador
                                   ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                                   ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                   ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                                   ,'ADR'
                                   ,'PEX'
                                   ,'EC1'
                                   ,'SAM') THEN
                  l_Codigo_Trama_Aux2 := 'MD5';
                ELSIF l_Origen_Trx IN ('TRA'
                  ) THEN
                  --JRC 25/07/2023 SubTrama MD3 nace de subTrma MD5 Origen ----> TRA
                  l_Codigo_Trama_Aux2 := 'MD3';
                ELSIF l_Origen_Trx IN ('IVA' --RMC  11-07-2011 SubTrama MD6 nace de subTrma MD5 Origen ----> IVA
                                      ,'FTR'
                                      ,'FGI' --JAGC 20250414 ORIGEN FGI
                                      ) --JRC 27/09/2023 Origen FTR(Factura Transacciones Relacionadas)
                 THEN
                  l_Codigo_Trama_Aux2 := 'MD6';

                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;
              --//-----------------------------------------------------------------Termino--\\
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'DV1' THEN
                --//--------------------------------------------------------------------------\\
                --// CBR 19/08/2020 10:10                                                     \\
                --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
                --// Se reutiliza Subtrama DV8 por ser la mas antigua                         \\
                --//-----------------------------------------------------------------Inicio---\\
                IF l_Origen_Trx IN ('DEC'
                                   ,'ABF'
                                   ,'SAL' -- LMP 2023 GPF Ecuador
                                   ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                                   ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                   ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                                   ,'ADR'
                                   ,'PEX'
                                   ,'EC1'
                                   ,'RYT'
                                   ,'SAM'
                                   ,'VCO'
                                   ,'DON'
                                   ,'MOP'
                                   ,'OMS') THEN
                  -- 'OPC','LNA','GES','DED','UNI','REC','ATR','MET','TBK','DEV','DTE','PRM','FEC','FJC','PRE','MAG'
                  l_Codigo_Trama_Aux2 := 'DV8';
                  --//-----------------------------------------------------------------Termino--\\
                ELSIF l_Origen_Trx IN ('FFR'
                                      ,'SGN'
                                      ,'OTN'
                                      ,'CCR'
                                      ,'ISP'
                                      ,'COR'
                                      ,'SQF'
                                      ,'CCV'
                                      ,'BOX'
                                      ,'GLO'
                                      ,'FEL'
                                      ,'FAT') THEN
                  l_Codigo_Trama_Aux2 := 'DV4';
                  -- JRG CIA 04/06/219
                ELSIF l_Origen_Trx IN ('CIA'
                                      ,'EMP') THEN
                  l_Codigo_Trama_Aux2 := 'DV0';
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'CO1' THEN
                IF l_Origen_Trx IN ('DEC'
                                   ,'ABF'
                                   ,'ADR'
                                   ,'PEX'
                                   ,'EC1') THEN
                  --//--------------------------------------------------------------------------\\
                  --// CBR 17/08/2020 00:16                                                     \\
                  --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
                  --// Se reutiliza por ser la sub_trama mas antigua                            \\
                  --//-----------------------------------------------------------------Inicio---\\
                  l_Codigo_Trama_Aux2 := 'CO8';
                  --//-----------------------------------------------------------------Termino--\\
                ELSIF l_Origen_Trx IN ('SAL') THEN
                  --------------------------------------
                  -- LMP Ecuador GPF 2023
                  --------------------------------------
                  l_Codigo_Trama_Aux2 := 'CO9';
                ELSIF l_Origen_Trx IN ('BOX') THEN
                  --  ******************************
                  l_Codigo_Trama_Aux2 := 'CO8'; --  ****  Separacion de BIO   ****
                ELSIF l_Origen_Trx IN ('BIO'
                                      ,'GLO') THEN
                  --  ****  y BOX               ****
                  l_Codigo_Trama_Aux2 := 'CO9'; --  ******************************
                ELSIF l_Origen_Trx IN ('SAM'
                                      ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                                      ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                      ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                                       ) THEN
                  l_Codigo_Trama_Aux2 := 'CO2'; --  SAM
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;
              --//--------------------------------------------------------------------------\\
              --// CBR 04/09/2020 00:02                                                     \\
              --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
              --//-----------------------------------------------------------------Inicio---\\
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'PM1' THEN
                IF l_Origen_Trx IN ('DEC'
                                   ,'ABF'
                                   ,'SAL' -- LMP 2023 GPF Ecuador
                                   ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                                   ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                   ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                                   ,'ADR'
                                   ,'PEX'
                                   ,'EC1'
                                   ,'RYT'
                                   ,'SAM'
                                   ,'VCO'
                                   ,'DON'
                                   ,'MOP'
                                   ,'OMS') THEN
                  l_Codigo_Trama_Aux2 := 'PM3';
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;
              
              -- INI JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'PM9' THEN
                IF l_Origen_Trx IN (
                                   'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                   ) THEN
                  l_Codigo_Trama_Aux2 := 'PMA';
                ELSIF l_Origen_Trx IN (
                                   'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ) THEN
                  l_Codigo_Trama_Aux2 := 'PMB';  
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;
              -- FIN JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
              
              --//--------------------------------------------------------------------------\\
              --// CBR 04/09/2020 00:02                                                     \\
              --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
              --//-----------------------------------------------------------------Inicio---\\
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'DP2' THEN
                IF l_Origen_Trx IN ('RYT') THEN
                  l_Codigo_Trama_Aux2 := 'DP4';
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;
              --//-----------------------------------------------------------------Termino--\\
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'PM2' THEN
                IF l_Origen_Trx IN ('SGN'
                                   ,'OTN'
                                   ,'CCR'
                                   ,'ISP'
                                   ,'DFS'
                                   ,'AUC'
                                   ,'COR'
                                   ,'SQF'
                                   ,'CCV') THEN
                  l_Codigo_Trama_Aux2 := 'PM7';
                ELSIF l_Origen_Trx IN ('BOX'
                                      ,'GLO'
                                      ,'FEL'
                                      ,'FAT'
                                      ,'CIA'
                                      ,'EMP') THEN
                  l_Codigo_Trama_Aux2 := 'PM5';
                ELSIF l_Origen_Trx IN ('DEC'
                                      ,'ABF'
                                      ,'SAL' -- LMP 2023 GPF Ecuador
                                    --  ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                                     -- ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                                      ,'ADR'
                                      ,'PEX'
                                      ,'EC1'
                                      ,'RYT'
                                      ,'SAM'
                                      ,'VCO'
                                      ,'DON'
                                      ,'MOP'
                                     -- ,'OMS'
                                      ) THEN
                  l_Codigo_Trama_Aux2 := 'PM2';
                ELSIF l_Origen_Trx IN (---- IDHC
                                      'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                                      --,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                      ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                                      ,'OMS') THEN
                 l_Codigo_Trama_Aux2 := 'PM10'; -- IDHC
                
                ELSIF l_Origen_Trx IN (
                                      'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                     ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ) THEN
                  l_Codigo_Trama_Aux2 := 'PM12'; 
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;
              --Cambio debido a nuevo campo en subtrama PM (Puntos Generados) GEOCOM
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'PM3' THEN
                -- 'PRM','FEC','FJC','PRE','MAG','FFR','SGN','OTN','CCR','ISP','DFS','AUC','COR'
                IF l_Origen_Trx IN ('SQF'
                                   ,'CCV'
                                   ,'BOX'
                                   ,'GLO'
                                   ,'FEL'
                                   ,'FAT'
                                   ,'CIA'
                                   ,'EMP'
                                   ,'DEC'
                                   ,'ABF'
                                   ,'SAL' -- LMP 2023 GPF Ecuador
                                   ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                                   ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                   ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                                   ,'ADR'
                                   ,'PEX'
                                   ,'EC1'
                                   ,'RYT'
                                   ,'SAM'
                                   ,'VCO'
                                   ,'DON'
                                   ,'MOP'
                                   ,'OMS') THEN
                  l_Codigo_Trama_Aux2 := 'PM6';
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;
              --//--------------------------------------------------------------------------\\
              --// CBR 04/09/2020 00:10                                                     \\
              --// Desarrollos para resolutor Ecuador con nuevo origen transaccion 'DEC'    \\
              --//-----------------------------------------------------------------Inicio---\\
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'PM4' THEN
                IF l_Origen_Trx IN ('DEC'
                                   ,'ABF'
                                   ,'SAL' -- LMP 2023 GPF Ecuador
                                   ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                                   ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                   ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                                   ,'ADR'
                                   ,'PEX'
                                   ,'EC1'
                                   ,'RYT'
                                   ,'SAM'
                                   ,'VCO'
                                   ,'DON'
                                   ,'MOP'
                                   ,'OMS') THEN
                  l_Codigo_Trama_Aux2 := 'PM7';
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'PM5' THEN
                IF l_Origen_Trx IN ('DEC'
                                   ,'ABF'
                                   ,'SAL' -- LMP 2023 GPF Ecuador
                                   ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                                   ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                   ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                                   ,'ADR'
                                   ,'PEX'
                                   ,'EC1'
                                   ,'RYT'
                                   ,'SAM'
                                   ,'VCO'
                                   ,'DON'
                                   ,'MOP'
                                   ,'OMS') THEN
                  l_Codigo_Trama_Aux2 := 'PM9';
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;

              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'PM6' THEN
                IF l_Origen_Trx IN ('RYT'
                                   ,'SAM'
                                   ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                                   ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                   ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                                   ,'VCO'
                                   ,'DON'
                                   ,'MOP'
                                   ,'OMS') THEN
                  l_Codigo_Trama_Aux2 := 'P11';
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'PM7' THEN
                IF l_Origen_Trx IN ('RYT'
                                   ,'SAM'
                                   ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                                   ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                   ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                                   ,'VCO'
                                   ,'DON'
                                   ,'OMS') THEN
                  l_Codigo_Trama_Aux2 := 'P12';
                ELSIF l_Origen_Trx IN ('MOP') THEN
                  l_Codigo_Trama_Aux2 := 'P14';
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'PM8' THEN
                IF l_Origen_Trx IN ('VCO'
                                   ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                                   ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                   ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                                   ,'DON'
                                   ,'MOP'
                                   ,'OMS') THEN
                  l_Codigo_Trama_Aux2 := 'P13';
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;
              --//-----------------------------------------------------------------Termino--\\
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'RB1' THEN
                IF l_Origen_Trx IN ('SCF') THEN
                  l_Codigo_Trama_Aux2 := 'RB2';
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'MG1' THEN
                IF l_Origen_Trx IN ('EXP'
                                   ,'OTN'
                                   ,'SAP') THEN
                  l_Codigo_Trama_Aux2 := 'MG2';
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'RO1' THEN
                IF l_Origen_Trx IN ('OTN'
                                   ,'SAP') THEN
                  l_Codigo_Trama_Aux2 := 'RO2';
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'OT1' THEN
                IF l_Origen_Trx IN ('OTN'
                                   ,'SAP') THEN
                  l_Codigo_Trama_Aux2 := 'OT2';
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'MC1' THEN
                IF l_Origen_Trx IN ('DEC'
                                   ,'ABF'
                                   ,'SAL' -- LMP 2023 GPF Ecuador
                                   ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                                   ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                   ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                                   ,'ADR'
                                   ,'PEX'
                                   ,'EC1'
                                   ,'SAM') THEN
                  l_Codigo_Trama_Aux2 := 'MC1';
                ELSE
                  l_Codigo_Trama_Aux2 := NULL;
                END IF;
              END IF;
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'GD1' THEN
                l_Codigo_Trama_Aux2 := 'GD1';
                --                IF l_Origen_Trx IN ('ETV') THEN
                --                  l_Codigo_Trama_Aux2 := 'GD2';
                --                ELSIF l_Origen_Trx IN ('DEC') THEN
                --                  l_Codigo_Trama_Aux2 := 'GD3';
                --                ELSE
                --                  l_Codigo_Trama_Aux2 := NULL;
                --                END IF;
              END IF;
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'AR1' THEN
                IF l_Origen_Trx IN ('MTL'
                                   ,'MET'
                                   ,'BNM'
                                   ,'EBM'
                                   ,'DPE'
                                   ,'ISP'
                                   ,'CCR'
                                   ,'SQF'
                                   ,'CCV'
                                   ,'BOX'
                                   ,'GLO'
                                   ,'FEL'
                                   ,'FAT'
                                   ,'CIA'
                                   ,'EMP'
                                   ,'DEC'
                                   ,'ABF'
                                   ,'SAL' -- LMP 2023 GPF Ecuador
                                   ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                                   ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                   ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                                   ,'ADR'
                                   ,'PEX'
                                   ,'EC1'
                                   ,'SAM') THEN
                  l_Codigo_Trama_Aux2 := 'AR8';
                ELSE
                  l_Codigo_Trama_Aux2 := 'AR1';
                END IF;
              END IF;
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'RP1' THEN
                IF l_Origen_Trx IN ('CCR'
                                   ,'ISP'
                                   ,'COR'
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
                                   ,'DEC'
                                   ,'ABF'
                                   ,'SAL' -- LMP 2023 GPF Ecuador
                                   ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                                   ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                   ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                                   ,'ADR'
                                   ,'PEX'
                                   ,'EC1'
                                   ,'SAM') THEN
                  l_Codigo_Trama_Aux2 := 'RP2';
                ELSE
                  l_Codigo_Trama_Aux2 := 'RP1';
                END IF;
              END IF;
              IF r_Hijos(l_Contador_Hijo).Tipo_Info = 'RP2' THEN
                IF l_Origen_Trx IN ('CCR'
                                   ,'ISP'
                                   ,'COR'
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
                                   ,'DEC'
                                   ,'ABF'
                                   ,'SAL' -- LMP 2023 GPF Ecuador
                                   ,'MSP' -- JAGC 20230325 CAMBIO TRAMA POR ORIGEN MSP
                                   ,'NEC' -- JAGC 20240909 CAMBIO TRAMA POR ORIGEN NEC
                                   ,'NEU','ONS' -- JAGC 20250414 CAMBIO TRAMA POR ORIGEN NEU
                               ,'OBE' --JAGC 20261022
                               ,'CON' -- JAGC 20240529 CAMBIO TRAMA POR ORIGEN CON
                                   ,'ADR'
                                   ,'PEX'
                                   ,'EC1'
                                   ,'SAM') THEN
                  l_Codigo_Trama_Aux2 := 'RP3';
                ELSE
                  l_Codigo_Trama_Aux2 := 'RP2';
                END IF;
              END IF;
              -- Obtiene definici?n de la trama.
              l_Def_Trama_Hija := Scfr_Trx_Dyn_Def_Pk.Get_Def_Trama(Nvl(l_Codigo_Trama_Aux2
                                                                       ,r_Hijos(l_Contador_Hijo).Tipo_Info));
              FOR l_Itmtramahijo IN 1 .. l_Def_Trama_Hija.Count
              LOOP
                r_Trama_Hija := l_Def_Trama_Hija(l_Itmtramahijo);
                Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                          ,p_Msg     => '16');
                IF l_Modo_Largo_Campos = 'V' THEN
                  IF r_Trama_Hija.Largo_Campo > 0 THEN
                    l_Largo_Campo := Scfr_Trx_Util_Pk.Bin2num(Dbms_Lob.Substr(p_Transaccion
                                                                             ,r_Trama_Hija.Largo_Campo
                                                                             ,l_Pos));
                    l_Pos         := l_Pos + r_Trama_Hija.Largo_Campo;
                    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                              ,p_Msg     => '17');
                  ELSE
                    l_Largo_Campo := Scfr_Trx_Util_Pk.Bin2num(Dbms_Lob.Substr(p_Transaccion
                                                                             ,1
                                                                             ,l_Pos));
                    l_Pos         := l_Pos + 1;
                    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                              ,p_Msg     => '18');
                  END IF;
                END IF;
                l_Cuerpo_Tx(l_Itm).Codigo_Trx := l_Codigo_Trx;
                --                l_cuerpo_tx(l_itm).codigo_trama := r_trama_hija.codigo_trama;
                l_Cuerpo_Tx(l_Itm).Codigo_Trama := r_Hijos(l_Contador_Hijo).Tipo_Info;
                l_Cuerpo_Tx(l_Itm).Nombre_Trama := r_Trama_Hija.Nombre_Trama;
                l_Cuerpo_Tx(l_Itm).Itera_Trama := r_Trama_Hija.Itera_Trama;
                l_Cuerpo_Tx(l_Itm).Itera_Valor := l_Itm_Hijo;
                l_Cuerpo_Tx(l_Itm).Itera_Indice := l_Numreg;
                l_Cuerpo_Tx(l_Itm).Itera_Nivel := 2;
                l_Cuerpo_Tx(l_Itm).Codigo_Campo := r_Trama_Hija.Codigo_Campo;
                l_Cuerpo_Tx(l_Itm).Desc_Campo := r_Trama_Hija.Desc_Campo;
                l_Cuerpo_Tx(l_Itm).Nombre_Campo := r_Trama_Hija.Nombre_Campo;
                IF l_Modo_Largo_Campos = 'V' THEN
                  l_Cuerpo_Tx(l_Itm).Largo_Campo := l_Largo_Campo;
                ELSE
                  l_Cuerpo_Tx(l_Itm).Largo_Campo := r_Trama_Hija.Largo_Campo;
                END IF;
                l_Cuerpo_Tx(l_Itm).Tipo_Campo := r_Trama_Hija.Tipo_Campo;
                l_Cuerpo_Tx(l_Itm).Pos_Absoluta := l_Pos;
                Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                          ,p_Msg     => '  -> Campo (' || r_Trama_Hija.Codigo_Campo || ')' || r_Trama_Hija.Nombre_Campo || ' Tipo=>' ||
                                                        r_Trama_Hija.Tipo_Campo || ' Largo=>' || r_Trama_Hija.Largo_Campo || ' pos=>' || l_Cuerpo_Tx(l_Itm).Pos_Absoluta);
                IF l_Cuerpo_Tx(l_Itm).Tipo_Campo = k_Tipo_Numerico THEN
                  l_Cuerpo_Tx(l_Itm).Valor_Campo := Dbms_Lob.Substr(p_Transaccion
                                                                   ,l_Cuerpo_Tx(l_Itm).Largo_Campo
                                                                   ,l_Pos);
                  l_Cuerpo_Tx(l_Itm).Valor_Campon := Scfr_Trx_Util_Pk.Bin2num(Dbms_Lob.Substr(p_Transaccion
                                                                                             ,l_Cuerpo_Tx(l_Itm).Largo_Campo
                                                                                             ,l_Pos));
                  Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                            ,p_Msg     => '    -> Valor Campo =>' || l_Cuerpo_Tx(l_Itm).Valor_Campon);
                ELSIF l_Cuerpo_Tx(l_Itm).Tipo_Campo = k_Tipo_Caracter THEN
                  l_Cuerpo_Tx(l_Itm).Valor_Campo := Dbms_Lob.Substr(p_Transaccion
                                                                   ,l_Cuerpo_Tx(l_Itm).Largo_Campo
                                                                   ,l_Pos);
                  --                  l_Cuerpo_Tx(l_Itm).Valor_Campoc := Convert(Utl_Raw.Cast_To_Varchar2(Dbms_Lob.Substr(p_Transaccion
                  --                                                                                                     ,l_Cuerpo_Tx(l_Itm).Largo_Campo
                  --                                                                                                     ,l_Pos))
                  --                                                            ,'UTF8');

                  l_Cuerpo_Tx(l_Itm).Valor_Campoc := Campo_Tx_Varchar2(p_Transaccion
                                                                      ,l_Cuerpo_Tx(l_Itm).Largo_Campo
                                                                      ,l_Pos);

                  Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                            ,p_Msg     => '    -> Valor Campo =>' || l_Cuerpo_Tx(l_Itm).Valor_Campoc);
                ELSIF l_Cuerpo_Tx(l_Itm).Tipo_Campo = k_Tipo_Binario THEN
                  l_Cuerpo_Tx(l_Itm).Valor_Campo := Dbms_Lob.Substr(p_Transaccion
                                                                   ,l_Cuerpo_Tx(l_Itm).Largo_Campo
                                                                   ,l_Pos);
                ELSE
                  l_Cuerpo_Tx(l_Itm).Valor_Campon := NULL;
                  l_Cuerpo_Tx(l_Itm).Valor_Campoc := NULL;
                END IF;
                l_Pos := l_Pos + l_Cuerpo_Tx(l_Itm).Largo_Campo;
                Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => 'scfr_trx_dyn_pk.agrega_trama'
                                          ,p_Msg     => '    -> (5)Pos =>' || l_Pos);
                l_Itm := l_Itm + 1;
              END LOOP;
            END LOOP;
          END IF;
        END LOOP;
      END LOOP;
    END LOOP;
    RETURN l_Cuerpo_Tx;
  EXCEPTION
    WHEN OTHERS THEN
      x_Codigo_Error  := SQLCODE;
      x_Mensaje_Error := SQLERRM;
      RETURN l_Cuerpo_Tx;
  END;

  FUNCTION Setea_Nvalor_Trx(p_Cuerpo_Tx    IN OUT Tab_Cuerpo_Tx
                           ,p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                           ,p_Codigo_Campo IN Scfr_Diccionario.Codigo_Diccionario%TYPE
                           ,p_Itera_Valor  IN NUMBER DEFAULT 1
                           ,p_Itera_Indice IN NUMBER DEFAULT 1
                           ,p_Data         IN NUMBER) RETURN NUMBER IS
    l_Pos NUMBER;
  BEGIN
    l_Pos := Busca_Campo(p_Cuerpo_Tx
                        ,p_Codigo_Trama
                        ,p_Codigo_Campo
                        ,p_Itera_Valor
                        ,p_Itera_Indice);
    IF l_Pos > 0 THEN
      p_Cuerpo_Tx(l_Pos).Valor_Campon := p_Data;
      RETURN 0;
    END IF;
    RETURN - 1;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20000
                             ,'Imposible actualizar el Campo - ' || SQLERRM);
  END;

  FUNCTION Obtiene_Nvalor_Trx(p_Cuerpo_Tx    IN Tab_Cuerpo_Tx
                             ,p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                             ,p_Codigo_Campo IN Scfr_Diccionario.Codigo_Diccionario%TYPE
                             ,p_Itera_Valor  IN NUMBER DEFAULT 1
                             ,p_Itera_Indice IN NUMBER DEFAULT 1) RETURN NUMBER IS
    l_Pos NUMBER;
  BEGIN
    l_Pos := Busca_Campo(p_Cuerpo_Tx
                        ,p_Codigo_Trama
                        ,p_Codigo_Campo
                        ,p_Itera_Valor
                        ,p_Itera_Indice);
    IF l_Pos > 0 THEN
      RETURN p_Cuerpo_Tx(l_Pos).Valor_Campon;
    END IF;
    RETURN - 1;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20000
                             ,'Campo no encontrado - ' || SQLERRM);
  END;

  FUNCTION Obtiene_Cvalor_Trx(p_Cuerpo_Tx    IN Tab_Cuerpo_Tx
                             ,p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                             ,p_Codigo_Campo IN Scfr_Diccionario.Codigo_Diccionario%TYPE
                             ,p_Itera_Valor  IN NUMBER DEFAULT 1
                             ,p_Itera_Indice IN NUMBER DEFAULT 1) RETURN VARCHAR2 IS
    l_Pos NUMBER;
  BEGIN
    l_Pos := Busca_Campo(p_Cuerpo_Tx
                        ,p_Codigo_Trama
                        ,p_Codigo_Campo
                        ,p_Itera_Valor
                        ,p_Itera_Indice);
    IF l_Pos > 0 THEN
      RETURN p_Cuerpo_Tx(l_Pos).Valor_Campoc;
    END IF;
    RETURN '-';
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20000
                             ,'Campo no encontrado - ' || SQLERRM);
  END;

  FUNCTION Setea_Nvalor_Trx(p_Cuerpo_Tx    IN OUT Tab_Cuerpo_Tx
                           ,p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                           ,p_Nombre_Campo IN Scfr_Diccionario.Nombre_Campo%TYPE
                           ,p_Itera_Valor  IN NUMBER DEFAULT 1
                           ,p_Itera_Indice IN NUMBER DEFAULT 1
                           ,p_Data         IN NUMBER) RETURN NUMBER IS
    l_Pos NUMBER;
  BEGIN
    l_Pos := Busca_Campo(p_Cuerpo_Tx
                        ,p_Codigo_Trama
                        ,p_Nombre_Campo
                        ,p_Itera_Valor
                        ,p_Itera_Indice);
    IF l_Pos > 0 THEN
      p_Cuerpo_Tx(l_Pos).Valor_Campon := p_Data;
      RETURN 0;
    END IF;
    RETURN - 1;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20000
                             ,'Imposible actualizar el Campo - ' || SQLERRM);
  END;

  FUNCTION Obtiene_Nvalor_Trx(p_Cuerpo_Tx    IN Tab_Cuerpo_Tx
                             ,p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                             ,p_Nombre_Campo IN Scfr_Diccionario.Nombre_Campo%TYPE
                             ,p_Itera_Valor  IN NUMBER DEFAULT 1
                             ,p_Itera_Indice IN NUMBER DEFAULT 1) RETURN NUMBER IS
    l_Pos   NUMBER;
    l_Valor VARCHAR2(100);
  BEGIN
    l_Pos := Busca_Campo(p_Cuerpo_Tx
                        ,p_Codigo_Trama
                        ,p_Nombre_Campo
                        ,p_Itera_Valor
                        ,p_Itera_Indice);
    IF l_Pos > 0 THEN
      l_Valor := p_Cuerpo_Tx(l_Pos).Valor_Campoc;
      l_Valor := p_Cuerpo_Tx(l_Pos).Valor_Campon;
      RETURN p_Cuerpo_Tx(l_Pos).Valor_Campon;
    END IF;
    RETURN - 1;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20000
                             ,'Campo no encontrado - ' || SQLERRM);
  END;

  FUNCTION Obtiene_Cvalor_Trx(p_Cuerpo_Tx    IN Tab_Cuerpo_Tx
                             ,p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                             ,p_Nombre_Campo IN Scfr_Diccionario.Nombre_Campo%TYPE
                             ,p_Itera_Valor  IN NUMBER DEFAULT 1
                             ,p_Itera_Indice IN NUMBER DEFAULT 1) RETURN VARCHAR2 IS
    l_Pos NUMBER;
  BEGIN
    l_Pos := Busca_Campo(p_Cuerpo_Tx
                        ,p_Codigo_Trama
                        ,p_Nombre_Campo
                        ,p_Itera_Valor
                        ,p_Itera_Indice);
    IF l_Pos > 0 THEN
      -- Dbms_Output.Put_Line('campo=>' || p_Nombre_Campo || ' codigo campo=>' || p_Cuerpo_Tx(l_Pos).Codigo_Campo || ' largo Def=>' || p_Cuerpo_Tx(l_Pos).Largo_Campo ||
      --                      ' largo Real=>' || Length(p_Cuerpo_Tx(l_Pos).Valor_Campoc));
      RETURN p_Cuerpo_Tx(l_Pos).Valor_Campoc;
    END IF;
    RETURN '-';
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20000
                             ,'Campo no encontrado - ' || SQLERRM);
  END;

  FUNCTION Obtiene_Bvalor_Trx(p_Cuerpo_Tx    IN Tab_Cuerpo_Tx
                             ,p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                             ,p_Nombre_Campo IN Scfr_Diccionario.Nombre_Campo%TYPE
                             ,p_Itera_Valor  IN NUMBER DEFAULT 1
                             ,p_Itera_Indice IN NUMBER DEFAULT 1) RETURN BLOB IS
    l_Pos NUMBER;
  BEGIN
    l_Pos := Busca_Campo(p_Cuerpo_Tx
                        ,p_Codigo_Trama
                        ,p_Nombre_Campo
                        ,p_Itera_Valor
                        ,p_Itera_Indice);
    IF l_Pos > 0 THEN
      RETURN p_Cuerpo_Tx(l_Pos).Valor_Campo;
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(-20000
                             ,'Campo no encontrado - ' || SQLERRM);
  END;

  FUNCTION Arma_Trama_Pos(p_Transaccion IN OUT Rec_Transaccion) RETURN BLOB IS
    l_Trama_Pos BLOB;
  BEGIN
    -- momentaneo (SE RECIBEN NULOS DESDE POS)
    p_Transaccion.Trama_Pos.Identificador_Global := NULL;
    p_Transaccion.Trama_Pos.Cliente_Destino      := NULL;
    p_Transaccion.Trama_Pos.Plataforma           := NULL;
    -- fin momentaneo
    p_Transaccion.Trama_Pos.Fecha_Hora_Rx := To_Number(To_Char(SYSDATE
                                                              ,'yyyymmddhh24miss'));
    IF p_Transaccion.Trama_Pos.Tipo_Requerimiento = 'R' THEN
      p_Transaccion.Trama_Pos.Tipo_Requerimiento := 'P';
    END IF;
    l_Trama_Pos := Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Hpo(p_Transaccion.Trama_Pos);
    RETURN l_Trama_Pos;
  END;

  FUNCTION Arma_Trama_Boc(p_Transaccion IN Rec_Transaccion) RETURN BLOB IS
    l_Trama_Boc BLOB;
  BEGIN
    l_Trama_Boc := Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Hbo(p_Transaccion.Trama_Boc);
    RETURN l_Trama_Boc;
  END;

  PROCEDURE Agrega_Nvalor_Trx(p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                             ,p_Nombre_Campo IN Scfr_Diccionario.Nombre_Campo%TYPE
                             ,p_Valor_Campo  IN NUMBER
                             ,x_Datos_Trx    IN OUT BLOB) IS
    r_Diccionario Scfr_Diccionario%ROWTYPE;
    l_Valor_Blob  BLOB;
  BEGIN
    -- Busca datos del campo a insertar
    IF p_Codigo_Trama IS NOT NULL THEN
      Obtiene_Datos_Campo(p_Codigo_Trama
                         ,p_Nombre_Campo
                         ,r_Diccionario);
    ELSE
      Obtiene_Datos_Campo(p_Nombre_Campo
                         ,r_Diccionario);
    END IF;
    l_Valor_Blob := Scfr_Trx_Util_Pk.Num2bin(Nvl(p_Valor_Campo
                                                ,0)
                                            ,r_Diccionario.Largo);
    x_Datos_Trx  := Utl_Raw.Concat(x_Datos_Trx
                                  ,l_Valor_Blob);
  END;

  PROCEDURE Agrega_Cvalor_Trx(p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE
                             ,p_Nombre_Campo IN Scfr_Diccionario.Nombre_Campo%TYPE
                             ,p_Valor_Campo  IN VARCHAR2
                             ,x_Datos_Trx    IN OUT BLOB) IS
    r_Diccionario Scfr_Diccionario%ROWTYPE;
    l_Valor_Blob  BLOB;
  BEGIN
    -- Busca datos del campo a insertar
    Obtiene_Datos_Campo(p_Codigo_Trama
                       ,p_Nombre_Campo
                       ,r_Diccionario);
    --l_valor_blob := utl_raw.cast_to_raw( substr( nvl(p_valor_campo,''), r_diccionario.largo ) );
    l_Valor_Blob := Utl_Raw.Cast_To_Raw(Rpad(Nvl(p_Valor_Campo
                                                ,' ')
                                            ,r_Diccionario.Largo
                                            ,' '));
    x_Datos_Trx  := Utl_Raw.Concat(x_Datos_Trx
                                  ,l_Valor_Blob);
  END;

  PROCEDURE Agrega_Bvalor_Trx(p_Valor     IN BLOB
                             ,x_Datos_Trx IN OUT BLOB) IS
  BEGIN
    x_Datos_Trx := Utl_Raw.Concat(x_Datos_Trx
                                 ,p_Valor);
  END;

  FUNCTION Obtiene_Largo_Trama(p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE) RETURN NUMBER IS
    l_Largo_Buffer NUMBER;
    l_Def_Trama    Scfr_Trx_Dyn_Def_Pk.Tab_Def_Mod_Dyn;
    l_Itm          NUMBER;
  BEGIN
    l_Largo_Buffer := 0;
    l_Def_Trama    := Scfr_Trx_Dyn_Def_Pk.Get_Def_Trama(p_Codigo_Trama);
    FOR l_Itm IN 1 .. l_Def_Trama.Count
    LOOP
      l_Largo_Buffer := l_Largo_Buffer + l_Def_Trama(l_Itm).Largo_Campo;
    END LOOP;
    RETURN l_Largo_Buffer;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  PROCEDURE Setea_Correlativo_Trp(p_Correlativo_Trp IN Scfr_Log_Debug.Correlativo_Trp%TYPE) IS
  BEGIN
    g_Correlativo_Trp := p_Correlativo_Trp;
  END;

  FUNCTION Obtiene_Correlativo_Trp RETURN NUMBER IS
  BEGIN
    RETURN Nvl(g_Correlativo_Trp
              ,0);
  END;

  FUNCTION Contiene_Trama(p_Cuerpo_Tx    IN Tab_Cuerpo_Tx
                         ,p_Codigo_Trama IN Scfr_Catalogo.Tipo_Info%TYPE) RETURN BOOLEAN IS
    l_Itm NUMBER;
    l_Pos NUMBER;
  BEGIN
    FOR l_Itm IN 1 .. p_Cuerpo_Tx.Count
    
    LOOP
      
    --Dbms_Output.Put_Line('CONTIENE TRAMA ' || Ltrim(Rtrim(p_Cuerpo_Tx(l_Itm).Codigo_Trama)));
    
      IF Ltrim(Rtrim(p_Cuerpo_Tx(l_Itm).Codigo_Trama)) = Ltrim(Rtrim(p_Codigo_Trama)) THEN
        l_Pos := l_Itm;
        EXIT;
      END IF;
    END LOOP;
    IF l_Pos <= p_Cuerpo_Tx.Count THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END;

  PROCEDURE Arma_Tipos(p_Trama_Padre IN Scfr_Catalogo.Tipo_Info%TYPE DEFAULT NULL) IS
    CURSOR c_Modelo(p_Trama_Padre IN Scfr_Catalogo.Tipo_Info%TYPE) IS
      SELECT Lower(Cat.Tipo_Info) Tipo_Info
            ,Lower(Cat.Descripcion) Descripcion
            ,Dic.Codigo_Diccionario
            ,Lower(Dic.Nombre_Campo) Nombre_Campo
            ,Dic.Tipo
            ,Cdi.Largo
            ,Cat.Iterativo
        FROM Scfr_Catalogo             Cat
            ,Scfr_Catalogo_Diccionario Cdi
            ,Scfr_Diccionario          Dic
       WHERE Cat.Tipo_Info = Cdi.Tipo_Info
         AND Cdi.Codigo_Diccionario = Dic.Codigo_Diccionario
         AND Nvl(Cat.Cat_Tipo_Info
                ,'PADRE') = Upper(Nvl(p_Trama_Padre
                                     ,'PADRE'))
       ORDER BY Cat.Tipo_Info
               ,Cdi.Orden;
    l_Tipo_Info Scfr_Catalogo.Tipo_Info%TYPE;
    l_Iterativo Scfr_Catalogo.Iterativo%TYPE;
    l_Largo     Scfr_Diccionario.Largo%TYPE;
    r_Hijos     Tab_Trama;
    l_Item      NUMBER;
  BEGIN
    FOR r_Tramas IN c_Modelo(p_Trama_Padre)
    LOOP
      IF l_Tipo_Info IS NULL THEN
        l_Tipo_Info := r_Tramas.Tipo_Info;
        l_Iterativo := r_Tramas.Iterativo;
        -- Verifica si la trama tiene hijos o no
        IF Obtiene_Hijos(Upper(l_Tipo_Info)
                        ,r_Hijos) THEN
          -- LLama recursivamente a la misma funci?n, pero para obtener las tramas hijas
          Arma_Tipos(l_Tipo_Info);
        END IF;
        Dbms_Output.Put_Line(' ');
        Dbms_Output.Put_Line('type rec_trama_' || r_Tramas.Tipo_Info || ' is record (');
        IF r_Tramas.Tipo = k_Tipo_Numerico THEN
          Dbms_Output.Put_Line('  ' || Rpad(r_Tramas.Nombre_Campo
                                           ,40
                                           ,' ') || ' number');
        ELSIF r_Tramas.Tipo = k_Tipo_Binario THEN
          Dbms_Output.Put_Line('  ' || Rpad(r_Tramas.Nombre_Campo
                                           ,40
                                           ,' ') || ' blob');
        ELSE
          IF Nvl(r_Tramas.Largo
                ,0) != 0 THEN
            l_Largo := r_Tramas.Largo;
          ELSE
            l_Largo := k_Largo_Varchar2;
          END IF;
          Dbms_Output.Put_Line('  ' || Rpad(r_Tramas.Nombre_Campo
                                           ,40
                                           ,' ') || ' varchar2(' || l_Largo || ')');
        END IF;
      ELSIF l_Tipo_Info != r_Tramas.Tipo_Info THEN
        -- Agrega atributos con estructura de las tramas hijas
        FOR l_Item IN 1 .. r_Hijos.Count
        LOOP
          Dbms_Output.Put_Line(Rpad(', subtrama_' || Lower(r_Hijos(l_Item).Tipo_Info)
                                   ,42
                                   ,' ') || ' tab_trama_' || Lower(r_Hijos(l_Item).Tipo_Info));
        END LOOP;
        Dbms_Output.Put_Line(');');
        Dbms_Output.Put_Line(' ');
        IF l_Iterativo = 'S' THEN
          Dbms_Output.Put_Line('type tab_trama_' || l_Tipo_Info || ' is table of rec_trama_' || l_Tipo_Info || ' index by binary_integer;');
          Dbms_Output.Put_Line(' ');
        END IF;
        l_Tipo_Info := r_Tramas.Tipo_Info;
        l_Iterativo := r_Tramas.Iterativo;
        -- Verifica si la trama tiene hijos o no
        IF Obtiene_Hijos(Upper(l_Tipo_Info)
                        ,r_Hijos) THEN
          -- LLama recursivamente a la misma funci?n, pero para obtener las tramas hijas
          Arma_Tipos(l_Tipo_Info);
        END IF;
        Dbms_Output.Put_Line('type rec_trama_' || r_Tramas.Tipo_Info || ' is record (');
        IF r_Tramas.Tipo = k_Tipo_Numerico THEN
          Dbms_Output.Put_Line('  ' || Rpad(r_Tramas.Nombre_Campo
                                           ,40
                                           ,' ') || ' number');
        ELSIF r_Tramas.Tipo = k_Tipo_Binario THEN
          Dbms_Output.Put_Line('  ' || Rpad(r_Tramas.Nombre_Campo
                                           ,40
                                           ,' ') || ' blob');
        ELSE
          IF Nvl(r_Tramas.Largo
                ,0) != 0 THEN
            l_Largo := r_Tramas.Largo;
          ELSE
            l_Largo := k_Largo_Varchar2;
          END IF;
          Dbms_Output.Put_Line('  ' || Rpad(r_Tramas.Nombre_Campo
                                           ,40
                                           ,' ') || ' varchar2(' || l_Largo || ')');
        END IF;
      ELSE
        IF r_Tramas.Tipo = k_Tipo_Numerico THEN
          Dbms_Output.Put_Line(', ' || Rpad(r_Tramas.Nombre_Campo
                                           ,40
                                           ,' ') || ' number');
        ELSIF r_Tramas.Tipo = k_Tipo_Binario THEN
          Dbms_Output.Put_Line(', ' || Rpad(r_Tramas.Nombre_Campo
                                           ,40
                                           ,' ') || ' blob');
        ELSE
          IF Nvl(r_Tramas.Largo
                ,0) != 0 THEN
            l_Largo := r_Tramas.Largo;
          ELSE
            l_Largo := k_Largo_Varchar2;
          END IF;
          Dbms_Output.Put_Line(', ' || Rpad(r_Tramas.Nombre_Campo
                                           ,40
                                           ,' ') || ' varchar2(' || l_Largo || ')');
        END IF;
      END IF;
    END LOOP;
    Dbms_Output.Put_Line(');');
    Dbms_Output.Put_Line(' ');
    IF l_Iterativo = 'S' THEN
      Dbms_Output.Put_Line('type tab_trama_' || l_Tipo_Info || ' is table of rec_trama_' || l_Tipo_Info || ' index by binary_integer;');
      Dbms_Output.Put_Line(' ');
    END IF;
  END;

  PROCEDURE Genera_Trama_Pos IS
  BEGIN
    Dbms_Output.Put_Line('  type rec_transaccion is record (');
    Dbms_Output.Put_Line('    codigo_tx         scfr_mov_transacciones.CODIGO_TX%type');
    Dbms_Output.Put_Line('  , fecha_tx          scfr_mov_transacciones.FECHA_TX%type');
    Dbms_Output.Put_Line('  , correlativo_tx    scfr_mov_transacciones.CORRELATIVO_TX%type');
    Dbms_Output.Put_Line('  , rut_titular       scfr_mov_transacciones.RUT_TITULAR%type');
    Dbms_Output.Put_Line('  , dv_rut_titular    scfr_mov_transacciones.DV_TITULAR%type');
    Dbms_Output.Put_Line('  , trama_pos         rec_trama_hpo');
    Dbms_Output.Put_Line('  , trama_boc         rec_trama_hbo');
    Dbms_Output.Put_Line('  , cuerpo_tx         tab_cuerpo_tx');
    Dbms_Output.Put_Line('  );');
  END;

  PROCEDURE Genera_Tipos_Dinamicos IS
  BEGIN
    Dbms_Output.Put_Line('create or replace package SCFR_TRX_DYN_TYPES_PK as');
    Arma_Tipos();
    Dbms_Output.Put_Line('end SCFR_TRX_DYN_TYPES_PK;');
    Dbms_Output.Put_Line('/');
  END;

  FUNCTION Obtiene_Largo_Maximo(p_Tipo_Info IN Scfr_Catalogo.Tipo_Info%TYPE) RETURN NUMBER IS
    l_Largo_Maximo NUMBER;
  BEGIN
    SELECT MAX(Length(Dic.Nombre_Campo))
      INTO l_Largo_Maximo
      FROM Scfr_Catalogo_Diccionario Cdi
          ,Scfr_Diccionario          Dic
     WHERE Cdi.Tipo_Info = Upper(p_Tipo_Info)
       AND Cdi.Codigo_Diccionario = Dic.Codigo_Diccionario;
    RETURN l_Largo_Maximo;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 30; -- Largo del campo "NOMBRE_CAMPO" de la tabla scfr_diccionario
  END;

  FUNCTION Iteracion_Padre(p_Tipo_Info IN Scfr_Catalogo.Tipo_Info%TYPE) RETURN VARCHAR2 IS
    l_Iterativo VARCHAR2(1);
  BEGIN
    SELECT Iterativo
      INTO l_Iterativo
      FROM Scfr_Catalogo
     WHERE Tipo_Info = (SELECT Cat_Tipo_Info FROM Scfr_Catalogo WHERE Tipo_Info = Upper(p_Tipo_Info));
    RETURN l_Iterativo;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END;

  PROCEDURE Arma_Carga_Tipo(p_Tipo_Info   IN OUT Scfr_Catalogo.Tipo_Info%TYPE
                           ,p_Iterativo   IN Scfr_Catalogo.Iterativo%TYPE
                           ,p_Trama_Padre IN Scfr_Catalogo.Cat_Tipo_Info%TYPE DEFAULT NULL) IS
  BEGIN
    Dbms_Output.Put_Line(' ');
    IF p_Iterativo = 'S' THEN
      IF p_Trama_Padre IS NULL THEN
        Dbms_Output.Put_Line('function carga_trama_' || p_Tipo_Info || '( p_cuerpo_tx in scfr_trx_dyn_pk.tab_cuerpo_tx )');
      ELSE
        IF Iteracion_Padre(p_Tipo_Info) = 'S' THEN
          Dbms_Output.Put_Line('function carga_trama_' || p_Tipo_Info ||
                               '( p_cuerpo_tx in scfr_trx_dyn_pk.tab_cuerpo_tx, p_tot_reg in number, p_ind in number )');
        ELSE
          Dbms_Output.Put_Line('function carga_trama_' || p_Tipo_Info || '( p_cuerpo_tx in scfr_trx_dyn_pk.tab_cuerpo_tx, p_tot_reg in number )');
        END IF;
      END IF;
      Dbms_Output.Put_Line('return scfr_trx_dyn_types_pk.tab_trama_' || p_Tipo_Info);
      Dbms_Output.Put_Line('is');
      Dbms_Output.Put_Line('  l_item      number;');
      Dbms_Output.Put_Line('  l_tot_reg   number;');
      Dbms_Output.Put_Line('  l_trama_' || p_Tipo_Info || ' scfr_trx_dyn_types_pk.tab_trama_' || p_Tipo_Info || ';');
      Dbms_Output.Put_Line('begin');
      IF p_Trama_Padre IS NULL THEN
        Dbms_Output.Put_Line('  l_tot_reg  := scfr_trx_dyn_pk.obtiene_nvalor_trx( p_cuerpo_tx, ''' || Upper(p_Tipo_Info) ||
                             ''', ''CANTIDAD_REGISTROS'');');
      ELSE
        Dbms_Output.Put_Line('  l_tot_reg  := p_tot_reg;');
      END IF;
      Dbms_Output.Put_Line('  for l_item in 1..l_tot_reg loop');
    ELSE
      Dbms_Output.Put_Line('function carga_trama_' || p_Tipo_Info || '( p_cuerpo_tx in scfr_trx_dyn_pk.tab_cuerpo_tx )');
      Dbms_Output.Put_Line('return scfr_trx_dyn_types_pk.rec_trama_' || p_Tipo_Info);
      Dbms_Output.Put_Line('is');
      Dbms_Output.Put_Line('  l_trama_' || p_Tipo_Info || ' scfr_trx_dyn_types_pk.rec_trama_' || p_Tipo_Info || ';');
      Dbms_Output.Put_Line('begin');
    END IF;
  END;

  PROCEDURE Genera_Carga_Tipos_Dinamicos IS
    CURSOR c_Spec IS
      SELECT Lower(Cat.Tipo_Info) Tipo_Info
            ,Nvl(Cat.Iterativo
                ,'N') Iterativo
            ,Cat.Cat_Tipo_Info
        FROM Scfr_Catalogo Cat
            ,(SELECT DISTINCT Tipo_Info FROM Scfr_Catalogo_Diccionario) Sq
       WHERE Cat.Tipo_Info = Sq.Tipo_Info;
    CURSOR c_Cuerpo IS
      SELECT Lower(Cat.Tipo_Info) Tipo_Info
            ,Lower(Cat.Descripcion) Descripcion
            ,Dic.Codigo_Diccionario
            ,Lower(Dic.Nombre_Campo) Nombre_Campo
            ,Dic.Tipo
            ,Cdi.Largo
            ,Cat.Iterativo
            ,Cat.Cat_Tipo_Info
        FROM Scfr_Catalogo             Cat
            ,Scfr_Catalogo_Diccionario Cdi
            ,Scfr_Diccionario          Dic
       WHERE Cat.Tipo_Info = Cdi.Tipo_Info
         AND Cdi.Codigo_Diccionario = Dic.Codigo_Diccionario
       ORDER BY Cat.Tipo_Info
               ,Cdi.Orden;
    l_Tipo_Info  Scfr_Catalogo.Tipo_Info%TYPE;
    l_Largo      Scfr_Diccionario.Largo%TYPE;
    l_Iteracion  VARCHAR2(10);
    l_Indice     VARCHAR2(10);
    l_Identado   VARCHAR2(10);
    l_Ind_Padre  VARCHAR2(10);
    r_Hijos      Tab_Trama;
    l_Item       NUMBER;
    l_Nro_Campos NUMBER;
    l_Contador1  NUMBER;
    l_Contador2  NUMBER;
    l_Largo_Max  NUMBER;
    TYPE Tab_Temp IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
    l_Campos      Tab_Temp;
    l_Tabla_Vacia Tab_Temp;
  BEGIN
    -- Crea Spec
    Dbms_Output.Put_Line('create or replace package SCFR_TRX_DYN_UTL_PK as');
    FOR r_Tramas IN c_Spec
    LOOP
      Dbms_Output.Put_Line(' ');
      IF r_Tramas.Cat_Tipo_Info IS NOT NULL THEN
        IF Iteracion_Padre(r_Tramas.Tipo_Info) = 'S' THEN
          Dbms_Output.Put_Line('function carga_trama_' || r_Tramas.Tipo_Info ||
                               '( p_cuerpo_tx in scfr_trx_dyn_pk.tab_cuerpo_tx, p_tot_reg in number, p_ind in number )');
        ELSE
          Dbms_Output.Put_Line('function carga_trama_' || r_Tramas.Tipo_Info ||
                               '( p_cuerpo_tx in scfr_trx_dyn_pk.tab_cuerpo_tx, p_tot_reg in number )');
        END IF;
      ELSE
        Dbms_Output.Put_Line('function carga_trama_' || r_Tramas.Tipo_Info || '( p_cuerpo_tx in scfr_trx_dyn_pk.tab_cuerpo_tx )');
      END IF;
      IF r_Tramas.Iterativo = 'S' THEN
        Dbms_Output.Put_Line('return scfr_trx_dyn_types_pk.tab_trama_' || r_Tramas.Tipo_Info || ';');
      ELSE
        Dbms_Output.Put_Line('return scfr_trx_dyn_types_pk.rec_trama_' || r_Tramas.Tipo_Info || ';');
      END IF;
    END LOOP;
    Dbms_Output.Put_Line(' ');
    Dbms_Output.Put_Line('end SCFR_TRX_DYN_UTL_PK;');
    Dbms_Output.Put_Line('/');
    -- Crea cuerpo
    Dbms_Output.Put_Line('create or replace package body SCFR_TRX_DYN_UTL_PK as');
    FOR r_Tramas IN c_Cuerpo
    LOOP
      IF l_Tipo_Info IS NULL THEN
        l_Largo_Max := Obtiene_Largo_Maximo(r_Tramas.Tipo_Info);
        l_Iteracion := '';
        l_Identado  := '';
        l_Indice    := '';
        l_Ind_Padre := '';
        IF r_Tramas.Iterativo = 'S' THEN
          l_Iteracion := '(l_item)';
          l_Indice    := ', l_item ';
          IF r_Tramas.Cat_Tipo_Info IS NOT NULL THEN
            IF Iteracion_Padre(r_Tramas.Tipo_Info) = 'S' THEN
              l_Ind_Padre := ', p_ind ';
            END IF;
          END IF;
          l_Identado := '  ';
        END IF;
        l_Contador1 := 1;
        l_Contador2 := 1;
        l_Campos    := l_Tabla_Vacia;
        l_Tipo_Info := r_Tramas.Tipo_Info;
        -- obtiene n?mero de campos de la trama
        l_Nro_Campos := Obtiene_Nro_Campos_Trama(Upper(l_Tipo_Info));
        -- Verifica si la trama tiene hijos o no
        IF Obtiene_Hijos(Upper(l_Tipo_Info)
                        ,r_Hijos) THEN
          NULL;
        END IF;
        Arma_Carga_Tipo(l_Tipo_Info
                       ,r_Tramas.Iterativo
                       ,r_Tramas.Cat_Tipo_Info);
        IF r_Tramas.Tipo = k_Tipo_Numerico THEN
          Dbms_Output.Put_Line(l_Identado || '  l_trama_' || r_Tramas.Tipo_Info || l_Iteracion || '.' ||
                               Rpad(r_Tramas.Nombre_Campo
                                   ,l_Largo_Max
                                   ,' ') || ' := scfr_trx_dyn_pk.obtiene_nvalor_trx( p_cuerpo_tx, ''' || Upper(r_Tramas.Tipo_Info) || ''', ' ||
                               Rpad('''' || Upper(r_Tramas.Nombre_Campo) || ''''
                                   ,l_Largo_Max + 2
                                   ,' ') || l_Indice || l_Ind_Padre || ');');
        ELSIF r_Tramas.Tipo = k_Tipo_Binario THEN
          Dbms_Output.Put_Line(l_Identado || '  l_trama_' || r_Tramas.Tipo_Info || l_Iteracion || '.' ||
                               Rpad(r_Tramas.Nombre_Campo
                                   ,l_Largo_Max
                                   ,' ') || ' := scfr_trx_dyn_pk.obtiene_nvalor_trx( p_cuerpo_tx, ''' || Upper(r_Tramas.Tipo_Info) || ''', ' ||
                               Rpad('''' || Upper(r_Tramas.Nombre_Campo) || ''''
                                   ,l_Largo_Max + 2
                                   ,' ') || l_Indice || l_Ind_Padre || ');');
        ELSE
          Dbms_Output.Put_Line(l_Identado || '  l_trama_' || r_Tramas.Tipo_Info || l_Iteracion || '.' ||
                               Rpad(r_Tramas.Nombre_Campo
                                   ,l_Largo_Max
                                   ,' ') || ' := scfr_trx_dyn_pk.obtiene_cvalor_trx( p_cuerpo_tx, ''' || Upper(r_Tramas.Tipo_Info) || ''', ' ||
                               Rpad('''' || Upper(r_Tramas.Nombre_Campo) || ''''
                                   ,l_Largo_Max + 2
                                   ,' ') || l_Indice || l_Ind_Padre || ');');
        END IF;
      ELSIF l_Tipo_Info != r_Tramas.Tipo_Info THEN
        -- Agrega llamada a carga de subtramas
        FOR l_Item IN 1 .. l_Campos.Count
        LOOP
          Dbms_Output.Put_Line(l_Identado || '  l_trama_' || l_Tipo_Info || l_Iteracion || '.' ||
                               Rpad('subtrama_' || Lower(r_Hijos(l_Item).Tipo_Info)
                                   ,l_Largo_Max
                                   ,' ') || ' := carga_trama_' || Lower(r_Hijos(l_Item).Tipo_Info) || '( p_cuerpo_tx, l_trama_' || l_Tipo_Info ||
                               l_Iteracion || '.' || Rpad(l_Campos(l_Item)
                                                         ,l_Largo_Max
                                                         ,' ') || l_Indice || ' );');
        END LOOP;
        IF l_Iteracion = '(l_item)' THEN
          Dbms_Output.Put_Line('  end loop;');
        END IF;
        Dbms_Output.Put_Line('  return l_trama_' || l_Tipo_Info || ';');
        Dbms_Output.Put_Line('end;');
        Dbms_Output.Put_Line(' ');
        l_Largo_Max := Obtiene_Largo_Maximo(r_Tramas.Tipo_Info);
        l_Iteracion := '';
        l_Identado  := '';
        l_Indice    := '';
        l_Ind_Padre := '';
        IF r_Tramas.Iterativo = 'S' THEN
          l_Iteracion := '(l_item)';
          l_Indice    := ', l_item ';
          IF r_Tramas.Cat_Tipo_Info IS NOT NULL THEN
            IF Iteracion_Padre(r_Tramas.Tipo_Info) = 'S' THEN
              l_Ind_Padre := ', p_ind ';
            END IF;
          END IF;
          l_Identado := '  ';
        END IF;
        l_Contador1 := 1;
        l_Contador2 := 1;
        l_Campos    := l_Tabla_Vacia;
        l_Tipo_Info := r_Tramas.Tipo_Info;
        -- obtiene n?mero de campos de la trama
        l_Nro_Campos := Obtiene_Nro_Campos_Trama(Upper(l_Tipo_Info));
        -- Verifica si la trama tiene hijos o no
        IF Obtiene_Hijos(Upper(l_Tipo_Info)
                        ,r_Hijos) THEN
          NULL;
        END IF;
        Arma_Carga_Tipo(l_Tipo_Info
                       ,r_Tramas.Iterativo
                       ,r_Tramas.Cat_Tipo_Info);
        IF r_Tramas.Tipo = k_Tipo_Numerico THEN
          Dbms_Output.Put_Line(l_Identado || '  l_trama_' || r_Tramas.Tipo_Info || l_Iteracion || '.' ||
                               Rpad(r_Tramas.Nombre_Campo
                                   ,l_Largo_Max
                                   ,' ') || ' := scfr_trx_dyn_pk.obtiene_nvalor_trx( p_cuerpo_tx, ''' || Upper(r_Tramas.Tipo_Info) || ''', ' ||
                               Rpad('''' || Upper(r_Tramas.Nombre_Campo) || ''''
                                   ,l_Largo_Max + 2
                                   ,' ') || l_Indice || l_Ind_Padre || ');');
        ELSIF r_Tramas.Tipo = k_Tipo_Binario THEN
          Dbms_Output.Put_Line(l_Identado || '  l_trama_' || r_Tramas.Tipo_Info || l_Iteracion || '.' ||
                               Rpad(r_Tramas.Nombre_Campo
                                   ,l_Largo_Max
                                   ,' ') || ' := scfr_trx_dyn_pk.obtiene_nvalor_trx( p_cuerpo_tx, ''' || Upper(r_Tramas.Tipo_Info) || ''', ' ||
                               Rpad('''' || Upper(r_Tramas.Nombre_Campo) || ''''
                                   ,l_Largo_Max + 2
                                   ,' ') || l_Indice || l_Ind_Padre || ');');
        ELSE
          Dbms_Output.Put_Line(l_Identado || '  l_trama_' || r_Tramas.Tipo_Info || l_Iteracion || '.' ||
                               Rpad(r_Tramas.Nombre_Campo
                                   ,l_Largo_Max
                                   ,' ') || ' := scfr_trx_dyn_pk.obtiene_cvalor_trx( p_cuerpo_tx, ''' || Upper(r_Tramas.Tipo_Info) || ''', ' ||
                               Rpad('''' || Upper(r_Tramas.Nombre_Campo) || ''''
                                   ,l_Largo_Max + 2
                                   ,' ') || l_Indice || l_Ind_Padre || ');');
        END IF;
      ELSE
        IF l_Contador1 >= l_Nro_Campos - r_Hijos.Count THEN
          l_Campos(l_Contador2) := r_Tramas.Nombre_Campo;
          l_Contador2 := l_Contador2 + 1;
        END IF;
        l_Contador1 := l_Contador1 + 1;
        IF r_Tramas.Tipo = k_Tipo_Numerico THEN
          Dbms_Output.Put_Line(l_Identado || '  l_trama_' || r_Tramas.Tipo_Info || l_Iteracion || '.' ||
                               Rpad(r_Tramas.Nombre_Campo
                                   ,l_Largo_Max
                                   ,' ') || ' := scfr_trx_dyn_pk.obtiene_nvalor_trx( p_cuerpo_tx, ''' || Upper(r_Tramas.Tipo_Info) || ''', ' ||
                               Rpad('''' || Upper(r_Tramas.Nombre_Campo) || ''''
                                   ,l_Largo_Max + 2
                                   ,' ') || l_Indice || l_Ind_Padre || ');');
        ELSIF r_Tramas.Tipo = k_Tipo_Binario THEN
          Dbms_Output.Put_Line(l_Identado || '  l_trama_' || r_Tramas.Tipo_Info || l_Iteracion || '.' ||
                               Rpad(r_Tramas.Nombre_Campo
                                   ,l_Largo_Max
                                   ,' ') || ' := scfr_trx_dyn_pk.obtiene_valor_trx( p_cuerpo_tx, ''' || Upper(r_Tramas.Tipo_Info) || ''', ' ||
                               Rpad('''' || Upper(r_Tramas.Nombre_Campo) || ''''
                                   ,l_Largo_Max + 2
                                   ,' ') || l_Indice || l_Ind_Padre || ');');
        ELSE
          Dbms_Output.Put_Line(l_Identado || '  l_trama_' || r_Tramas.Tipo_Info || l_Iteracion || '.' ||
                               Rpad(r_Tramas.Nombre_Campo
                                   ,l_Largo_Max
                                   ,' ') || ' := scfr_trx_dyn_pk.obtiene_cvalor_trx( p_cuerpo_tx, ''' || Upper(r_Tramas.Tipo_Info) || ''', ' ||
                               Rpad('''' || Upper(r_Tramas.Nombre_Campo) || ''''
                                   ,l_Largo_Max + 2
                                   ,' ') || l_Indice || l_Ind_Padre || ');');
        END IF;
      END IF;
    END LOOP;
    -- Agrega llamada a carga de subtramas
    FOR l_Item IN 1 .. l_Campos.Count
    LOOP
      Dbms_Output.Put_Line(l_Identado || '  l_trama_' || l_Tipo_Info || l_Iteracion || '.' ||
                           Rpad('subtrama_' || Lower(r_Hijos(l_Item).Tipo_Info)
                               ,l_Largo_Max
                               ,' ') || ' := carga_trama_' || Lower(r_Hijos(l_Item).Tipo_Info) || '( p_cuerpo_tx, l_trama_' || l_Tipo_Info ||
                           l_Iteracion || '.' || Rpad(l_Campos(l_Item)
                                                     ,l_Largo_Max
                                                     ,' ') || l_Indice || ' );');
    END LOOP;
    IF l_Iteracion = '(l_item)' THEN
      Dbms_Output.Put_Line('  end loop;');
    END IF;
    Dbms_Output.Put_Line('  return l_trama_' || l_Tipo_Info || ';');
    Dbms_Output.Put_Line('end;');
    Dbms_Output.Put_Line(' ');
    Dbms_Output.Put_Line('end SCFR_TRX_DYN_UTL_PK;');
    Dbms_Output.Put_Line('/');
  END;

  PROCEDURE Arma_Raw_Tipo(p_Tipo_Info    IN OUT Scfr_Catalogo.Tipo_Info%TYPE
                         ,p_Iterativo    IN Scfr_Catalogo.Iterativo%TYPE
                         ,p_Largo_Campos IN Scfr_Catalogo.Modo_Largo_Campos%TYPE
                         ,p_Trama_Padre  IN Scfr_Catalogo.Cat_Tipo_Info%TYPE DEFAULT NULL) IS
  BEGIN
    Dbms_Output.Put_Line(' ');
    IF p_Iterativo = 'S' THEN
      Dbms_Output.Put_Line('function arma_trama_' || p_Tipo_Info || '( p_trama_' || p_Tipo_Info || ' in scfr_trx_dyn_types_pk.tab_trama_' ||
                           p_Tipo_Info || ')');
    ELSE
      Dbms_Output.Put_Line('function arma_trama_' || p_Tipo_Info || '( p_trama_' || p_Tipo_Info || ' in scfr_trx_dyn_types_pk.rec_trama_' ||
                           p_Tipo_Info || ')');
    END IF;
    Dbms_Output.Put_Line('return blob');
    Dbms_Output.Put_Line('is');
    IF p_Trama_Padre IS NULL THEN
      Dbms_Output.Put_Line('  l_trama_htx scfr_trx_dyn_types_pk.rec_trama_htx;');
    END IF;
    Dbms_Output.Put_Line('  l_registro  blob;');
    Dbms_Output.Put_Line('  l_largo     number;');
    IF p_Iterativo = 'S' THEN
      Dbms_Output.Put_Line('  l_respuesta blob;');
      Dbms_Output.Put_Line('  l_item      number;');
      Dbms_Output.Put_Line('  l_tot_reg   number;');
      Dbms_Output.Put_Line('begin');
      Dbms_Output.Put_Line('  l_respuesta := null;');
      Dbms_Output.Put_Line('  l_tot_reg   := p_trama_' || p_Tipo_Info || '.count;');
      Dbms_Output.Put_Line('  for l_item in 1..l_tot_reg loop');
      Dbms_Output.Put_Line('    l_registro  := null;');
    ELSE
      Dbms_Output.Put_Line('begin');
      Dbms_Output.Put_Line('  l_registro  := null;');
    END IF;
  END;

  PROCEDURE Genera_Arma_Raw_Tramas IS
    CURSOR c_Spec IS
      SELECT Lower(Cat.Tipo_Info) Tipo_Info
            ,Nvl(Cat.Iterativo
                ,'N') Iterativo
            ,Cat.Cat_Tipo_Info
        FROM Scfr_Catalogo Cat
            ,(SELECT DISTINCT Tipo_Info FROM Scfr_Catalogo_Diccionario) Sq
       WHERE Cat.Tipo_Info = Sq.Tipo_Info;
    CURSOR c_Cuerpo IS
      SELECT Lower(Cat.Tipo_Info) Tipo_Info
            ,Lower(Cat.Descripcion) Descripcion
            ,Dic.Codigo_Diccionario
            ,Lower(Dic.Nombre_Campo) Nombre_Campo
            ,Dic.Tipo
            ,Cdi.Largo
            ,Cat.Iterativo
            ,Cat.Cat_Tipo_Info
            ,Cat.Modo_Largo_Campos
        FROM Scfr_Catalogo             Cat
            ,Scfr_Catalogo_Diccionario Cdi
            ,Scfr_Diccionario          Dic
       WHERE Cat.Tipo_Info = Cdi.Tipo_Info
         AND Cdi.Codigo_Diccionario = Dic.Codigo_Diccionario
       ORDER BY Cat.Tipo_Info
               ,Cdi.Orden;
    l_Tipo_Info   Scfr_Catalogo.Tipo_Info%TYPE;
    l_Iteracion   VARCHAR2(10);
    l_Indice      VARCHAR2(10);
    l_Identado    VARCHAR2(10);
    l_Largo_Campo VARCHAR2(10);
    l_Trama_Padre VARCHAR2(10);
    l_Modo_Largo  VARCHAR2(10);
    l_Largo_Varia NUMBER;
    r_Hijos       Tab_Trama;
    l_Item        NUMBER;
    l_Nro_Campos  NUMBER;
    l_Contador1   NUMBER;
    l_Contador2   NUMBER;
    l_Largo_Max   NUMBER;
    TYPE Tab_Temp IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
    l_Campos      Tab_Temp;
    l_Tabla_Vacia Tab_Temp;
  BEGIN
    -- Crea Spec
    Dbms_Output.Put_Line('create or replace package SCFR_TRX_DYN_RAW_PK as');
    FOR r_Tramas IN c_Spec
    LOOP
      Dbms_Output.Put_Line(' ');
      IF r_Tramas.Iterativo = 'S' THEN
        Dbms_Output.Put_Line('function arma_trama_' || r_Tramas.Tipo_Info || '( p_trama_' || r_Tramas.Tipo_Info ||
                             ' in scfr_trx_dyn_types_pk.tab_trama_' || r_Tramas.Tipo_Info || ' )');
      ELSE
        Dbms_Output.Put_Line('function arma_trama_' || r_Tramas.Tipo_Info || '( p_trama_' || r_Tramas.Tipo_Info ||
                             ' in scfr_trx_dyn_types_pk.rec_trama_' || r_Tramas.Tipo_Info || ' )');
      END IF;
      Dbms_Output.Put_Line('return blob;');
    END LOOP;
    Dbms_Output.Put_Line(' ');
    Dbms_Output.Put_Line('end SCFR_TRX_DYN_RAW_PK;');
    Dbms_Output.Put_Line('/');
    -- Crea cuerpo
    Dbms_Output.Put_Line('create or replace package body SCFR_TRX_DYN_RAW_PK as');
    FOR r_Tramas IN c_Cuerpo
    LOOP
      IF l_Tipo_Info IS NULL THEN
        l_Largo_Max   := Obtiene_Largo_Maximo(r_Tramas.Tipo_Info);
        l_Iteracion   := '';
        l_Identado    := '';
        l_Indice      := '';
        l_Trama_Padre := r_Tramas.Cat_Tipo_Info;
        IF r_Tramas.Iterativo = 'S' THEN
          l_Iteracion := '(l_item)';
          l_Indice    := ', l_item ';
          l_Identado  := '  ';
        END IF;
        l_Contador1  := 1;
        l_Contador2  := 1;
        l_Campos     := l_Tabla_Vacia;
        l_Tipo_Info  := r_Tramas.Tipo_Info;
        l_Modo_Largo := r_Tramas.Modo_Largo_Campos;
        -- obtiene n?mero de campos de la trama
        l_Nro_Campos := Obtiene_Nro_Campos_Trama(Upper(l_Tipo_Info));
        -- Verifica si la trama tiene hijos o no
        IF Obtiene_Hijos(Upper(l_Tipo_Info)
                        ,r_Hijos) THEN
          NULL;
        END IF;
        Arma_Raw_Tipo(l_Tipo_Info
                     ,r_Tramas.Iterativo
                     ,r_Tramas.Modo_Largo_Campos
                     ,r_Tramas.Cat_Tipo_Info);
        IF r_Tramas.Modo_Largo_Campos = 'F' THEN
          l_Largo_Campo := To_Char(r_Tramas.Largo);
        ELSE
          IF Nvl(r_Tramas.Largo
                ,0) > 0 THEN
            l_Largo_Varia := To_Char(Nvl(r_Tramas.Largo
                                        ,1));
          ELSE
            l_Largo_Varia := 1;
          END IF;
          l_Largo_Campo := 'l_largo';
          IF r_Tramas.Tipo = k_Tipo_Numerico THEN
            Dbms_Output.Put_Line(l_Identado || '  l_largo     := length( nvl( p_trama_' || r_Tramas.Tipo_Info || l_Iteracion || '.' ||
                                 Rpad(r_Tramas.Nombre_Campo
                                     ,l_Largo_Max
                                     ,' ') || ', 0 ) );');
          ELSIF r_Tramas.Tipo = k_Tipo_Binario THEN
            Dbms_Output.Put_Line(l_Identado || '  l_largo     := nvl( utl_raw.length( p_trama_' || r_Tramas.Tipo_Info || l_Iteracion || '.' ||
                                 Rpad(r_Tramas.Nombre_Campo
                                     ,l_Largo_Max
                                     ,' ') || ' ), 0 );');
          ELSE
            Dbms_Output.Put_Line(l_Identado || '  l_largo     := length( nvl( p_trama_' || r_Tramas.Tipo_Info || l_Iteracion || '.' ||
                                 Rpad(r_Tramas.Nombre_Campo
                                     ,l_Largo_Max
                                     ,' ') || ', '' '' ) );');
          END IF;
          Dbms_Output.Put_Line(l_Identado || '  l_registro  := utl_raw.concat( l_registro, scfr_trx_util_pk.num2bin( ' || l_Largo_Campo || ', ' ||
                               l_Largo_Varia || ' ) );');
        END IF;
        IF r_Tramas.Tipo = k_Tipo_Numerico THEN
          Dbms_Output.Put_Line(l_Identado || '  l_registro  := utl_raw.concat( l_registro, scfr_trx_util_pk.num2bin( nvl( p_trama_' ||
                               r_Tramas.Tipo_Info || l_Iteracion || '.' || Rpad(r_Tramas.Nombre_Campo
                                                                               ,l_Largo_Max
                                                                               ,' ') || ',0 ), ' || l_Largo_Campo || ' ) );');
        ELSIF r_Tramas.Tipo = k_Tipo_Binario THEN
          Dbms_Output.Put_Line(l_Identado || '  l_registro  := utl_raw.concat( l_registro, p_trama_' || r_Tramas.Tipo_Info || l_Iteracion || '.' ||
                               Rpad(r_Tramas.Nombre_Campo
                                   ,l_Largo_Max
                                   ,' ') || ' );');
        ELSE
          Dbms_Output.Put_Line(l_Identado || '  l_registro  := utl_raw.concat( l_registro, utl_raw.cast_to_raw( convert( rpad( nvl( p_trama_' ||
                               r_Tramas.Tipo_Info || l_Iteracion || '.' || Rpad(r_Tramas.Nombre_Campo
                                                                               ,l_Largo_Max
                                                                               ,' ') || ', '' ''), ' || l_Largo_Campo ||
                               ', '' '' ), ''WE8MSWIN1252'' ) ) );');
        END IF;
      ELSIF l_Tipo_Info != r_Tramas.Tipo_Info THEN
        IF l_Iteracion = '(l_item)' THEN
          IF l_Trama_Padre IS NULL THEN
            Dbms_Output.Put_Line(l_Identado ||
                                 '  l_registro  := utl_raw.concat( scfr_trx_util_pk.num2bin( utl_raw.length(l_registro), 2 ), l_registro );');
            Dbms_Output.Put_Line(l_Identado || '  l_respuesta := utl_raw.concat( l_respuesta, l_registro );');
            Dbms_Output.Put_Line('  end loop;');
            -- nuevo
            Dbms_Output.Put_Line('  l_trama_htx.tipo_informacion   := ''' || Upper(l_Tipo_Info) || ''';');
            Dbms_Output.Put_Line('  l_trama_htx.modo_largo_campos  := ''' || Upper(l_Modo_Largo) || ''';');
            Dbms_Output.Put_Line('  l_trama_htx.largo_buffer_datos := dbms_lob.getlength( l_respuesta );');
            Dbms_Output.Put_Line('  l_trama_htx.cantidad_registros := l_tot_reg;');
            Dbms_Output.Put_Line('  l_respuesta := utl_raw.concat( arma_trama_htx( l_trama_htx ), l_respuesta );');
            -- fin nuevo
          ELSE
            Dbms_Output.Put_Line(l_Identado || '  l_respuesta := utl_raw.concat( l_respuesta, l_registro );');
            Dbms_Output.Put_Line('  end loop;');
          END IF;
          Dbms_Output.Put_Line('  return l_respuesta;');
        ELSE
          IF Upper(l_Tipo_Info) NOT IN (k_Trama_Header_Pos
                                       ,k_Trama_Header_Boc
                                       ,k_Trama_Header_Ctx) THEN
            Dbms_Output.Put_Line(l_Identado ||
                                 '  l_registro  := utl_raw.concat( scfr_trx_util_pk.num2bin( utl_raw.length(l_registro), 2 ), l_registro );');
            -- nuevo
            Dbms_Output.Put_Line(l_Identado || '  l_trama_htx.tipo_informacion   := ''' || Upper(l_Tipo_Info) || ''';');
            Dbms_Output.Put_Line(l_Identado || '  l_trama_htx.modo_largo_campos  := ''' || Upper(l_Modo_Largo) || ''';');
            Dbms_Output.Put_Line(l_Identado || '  l_trama_htx.largo_buffer_datos := dbms_lob.getlength( l_registro );');
            Dbms_Output.Put_Line(l_Identado || '  l_trama_htx.cantidad_registros := 1;');
            Dbms_Output.Put_Line(l_Identado || '  l_registro := utl_raw.concat( arma_trama_htx( l_trama_htx ), l_registro );');
            -- fin nuevo
          END IF;
          Dbms_Output.Put_Line('  return l_registro;');
        END IF;
        Dbms_Output.Put_Line('end;');
        Dbms_Output.Put_Line(' ');
        l_Largo_Max   := Obtiene_Largo_Maximo(r_Tramas.Tipo_Info);
        l_Iteracion   := '';
        l_Identado    := '';
        l_Indice      := '';
        l_Trama_Padre := r_Tramas.Cat_Tipo_Info;
        IF r_Tramas.Iterativo = 'S' THEN
          l_Iteracion := '(l_item)';
          l_Indice    := ', l_item ';
          l_Identado  := '  ';
        END IF;
        l_Contador1  := 1;
        l_Contador2  := 1;
        l_Campos     := l_Tabla_Vacia;
        l_Tipo_Info  := r_Tramas.Tipo_Info;
        l_Modo_Largo := r_Tramas.Modo_Largo_Campos;
        -- obtiene n?mero de campos de la trama
        l_Nro_Campos := Obtiene_Nro_Campos_Trama(Upper(l_Tipo_Info));
        -- Verifica si la trama tiene hijos o no
        IF Obtiene_Hijos(Upper(l_Tipo_Info)
                        ,r_Hijos) THEN
          NULL;
        END IF;
        Arma_Raw_Tipo(l_Tipo_Info
                     ,r_Tramas.Iterativo
                     ,r_Tramas.Modo_Largo_Campos
                     ,r_Tramas.Cat_Tipo_Info);
        IF r_Tramas.Modo_Largo_Campos = 'F' THEN
          l_Largo_Campo := To_Char(r_Tramas.Largo);
        ELSE
          IF Nvl(r_Tramas.Largo
                ,0) > 0 THEN
            l_Largo_Varia := To_Char(Nvl(r_Tramas.Largo
                                        ,1));
          ELSE
            l_Largo_Varia := 1;
          END IF;
          l_Largo_Campo := 'l_largo';
          IF r_Tramas.Tipo = k_Tipo_Numerico THEN
            Dbms_Output.Put_Line(l_Identado || '  l_largo     := length( nvl( p_trama_' || r_Tramas.Tipo_Info || l_Iteracion || '.' ||
                                 Rpad(r_Tramas.Nombre_Campo
                                     ,l_Largo_Max
                                     ,' ') || ', 0 ) );');
          ELSIF r_Tramas.Tipo = k_Tipo_Binario THEN
            Dbms_Output.Put_Line(l_Identado || '  l_largo     := nvl( utl_raw.length( p_trama_' || r_Tramas.Tipo_Info || l_Iteracion || '.' ||
                                 Rpad(r_Tramas.Nombre_Campo
                                     ,l_Largo_Max
                                     ,' ') || '), 0 );');
          ELSE
            Dbms_Output.Put_Line(l_Identado || '  l_largo     := length( nvl( p_trama_' || r_Tramas.Tipo_Info || l_Iteracion || '.' ||
                                 Rpad(r_Tramas.Nombre_Campo
                                     ,l_Largo_Max
                                     ,' ') || ', '' '' ) );');
          END IF;
          Dbms_Output.Put_Line(l_Identado || '  l_registro  := utl_raw.concat( l_registro, scfr_trx_util_pk.num2bin( ' || l_Largo_Campo || ', ' ||
                               l_Largo_Varia || ' ) );');
        END IF;
        IF r_Tramas.Tipo = k_Tipo_Numerico THEN
          Dbms_Output.Put_Line(l_Identado || '  l_registro  := utl_raw.concat( l_registro, scfr_trx_util_pk.num2bin( nvl( p_trama_' ||
                               r_Tramas.Tipo_Info || l_Iteracion || '.' || Rpad(r_Tramas.Nombre_Campo
                                                                               ,l_Largo_Max
                                                                               ,' ') || ',0 ), ' || l_Largo_Campo || ' ) );');
        ELSIF r_Tramas.Tipo = k_Tipo_Binario THEN
          Dbms_Output.Put_Line(l_Identado || '  l_registro  := utl_raw.concat( l_registro, scfr_trx_util_pk.num2bin( nvl( p_trama_' ||
                               r_Tramas.Tipo_Info || l_Iteracion || '.' || Rpad(r_Tramas.Nombre_Campo
                                                                               ,l_Largo_Max
                                                                               ,' ') || ',0 ), ' || l_Largo_Campo || ' ) );');
        ELSE
          Dbms_Output.Put_Line(l_Identado || '  l_registro  := utl_raw.concat( l_registro, utl_raw.cast_to_raw( convert( rpad( nvl( p_trama_' ||
                               r_Tramas.Tipo_Info || l_Iteracion || '.' || Rpad(r_Tramas.Nombre_Campo
                                                                               ,l_Largo_Max
                                                                               ,' ') || ', '' ''), ' || l_Largo_Campo ||
                               ', '' '' ), ''WE8MSWIN1252'' ) ) );');
        END IF;
      ELSE
        IF r_Tramas.Modo_Largo_Campos = 'F' THEN
          l_Largo_Campo := To_Char(r_Tramas.Largo);
        ELSE
          IF Nvl(r_Tramas.Largo
                ,0) > 0 THEN
            l_Largo_Varia := To_Char(Nvl(r_Tramas.Largo
                                        ,1));
          ELSE
            l_Largo_Varia := 1;
          END IF;
          l_Largo_Campo := 'l_largo';
          IF r_Tramas.Tipo = k_Tipo_Numerico THEN
            Dbms_Output.Put_Line(l_Identado || '  l_largo     := length( nvl( p_trama_' || r_Tramas.Tipo_Info || l_Iteracion || '.' ||
                                 Rpad(r_Tramas.Nombre_Campo
                                     ,l_Largo_Max
                                     ,' ') || ', 0 ) );');
          ELSIF r_Tramas.Tipo = k_Tipo_Binario THEN
            Dbms_Output.Put_Line(l_Identado || '  l_largo     := nvl( length( p_trama_' || r_Tramas.Tipo_Info || l_Iteracion || '.' ||
                                 Rpad(r_Tramas.Nombre_Campo
                                     ,l_Largo_Max
                                     ,' ') || ' ), 0 );');
          ELSE
            Dbms_Output.Put_Line(l_Identado || '  l_largo     := length( nvl( p_trama_' || r_Tramas.Tipo_Info || l_Iteracion || '.' ||
                                 Rpad(r_Tramas.Nombre_Campo
                                     ,l_Largo_Max
                                     ,' ') || ', '' '' ) );');
          END IF;
          Dbms_Output.Put_Line(l_Identado || '  l_registro  := utl_raw.concat( l_registro, scfr_trx_util_pk.num2bin( ' || l_Largo_Campo || ', ' ||
                               l_Largo_Varia || ' ) );');
        END IF;
        IF r_Tramas.Tipo = k_Tipo_Numerico THEN
          Dbms_Output.Put_Line(l_Identado || '  l_registro  := utl_raw.concat( l_registro, scfr_trx_util_pk.num2bin( nvl( p_trama_' ||
                               r_Tramas.Tipo_Info || l_Iteracion || '.' || Rpad(r_Tramas.Nombre_Campo
                                                                               ,l_Largo_Max
                                                                               ,' ') || ',0 ), ' || l_Largo_Campo || ' ) );');
        ELSIF r_Tramas.Tipo = k_Tipo_Binario THEN
          Dbms_Output.Put_Line(l_Identado || '  l_registro  := utl_raw.concat( l_registro, p_trama_' || r_Tramas.Tipo_Info || l_Iteracion || '.' ||
                               Rpad(r_Tramas.Nombre_Campo
                                   ,l_Largo_Max
                                   ,' ') || ');');
        ELSE
          Dbms_Output.Put_Line(l_Identado || '  l_registro  := utl_raw.concat( l_registro, utl_raw.cast_to_raw( convert( rpad( nvl( p_trama_' ||
                               r_Tramas.Tipo_Info || l_Iteracion || '.' || Rpad(r_Tramas.Nombre_Campo
                                                                               ,l_Largo_Max
                                                                               ,' ') || ', '' ''), ' || l_Largo_Campo ||
                               ', '' '' ), ''WE8MSWIN1252'' ) ) );');
        END IF;
        IF l_Contador1 >= l_Nro_Campos - r_Hijos.Count THEN
          Dbms_Output.Put_Line(l_Identado || '  l_registro  := utl_raw.concat( l_registro, arma_trama_' || Lower(r_Hijos(l_Contador2).Tipo_Info) ||
                               '( p_trama_' || l_Tipo_Info || l_Iteracion || '.' || Rpad('subtrama_' || Lower(r_Hijos(l_Contador2).Tipo_Info)
                                                                                        ,l_Largo_Max
                                                                                        ,' ') || ') );');
          l_Contador2 := l_Contador2 + 1;
        END IF;
        l_Contador1 := l_Contador1 + 1;
      END IF;
    END LOOP;
    IF l_Iteracion = '(l_item)' THEN
      IF l_Trama_Padre IS NULL THEN
        Dbms_Output.Put_Line(l_Identado ||
                             '  l_registro  := utl_raw.concat( scfr_trx_util_pk.num2bin( utl_raw.length(l_registro), 2 ), l_registro );');
        Dbms_Output.Put_Line(l_Identado || '  l_respuesta := utl_raw.concat( l_respuesta, l_registro );');
        Dbms_Output.Put_Line('  end loop;');
        -- nuevo
        Dbms_Output.Put_Line('  l_trama_htx.tipo_informacion   := ''' || Upper(l_Tipo_Info) || ''';');
        Dbms_Output.Put_Line('  l_trama_htx.modo_largo_campos  := ''' || Upper(l_Modo_Largo) || ''';');
        Dbms_Output.Put_Line('  l_trama_htx.largo_buffer_datos := dbms_lob.getlength( l_respuesta );');
        Dbms_Output.Put_Line('  l_trama_htx.cantidad_registros := l_tot_reg;');
        Dbms_Output.Put_Line('  l_respuesta := utl_raw.concat( arma_trama_htx( l_trama_htx ), l_respuesta );');
        -- fin nuevo
      ELSE
        Dbms_Output.Put_Line(l_Identado || '  l_respuesta := utl_raw.concat( l_respuesta, l_registro );');
        Dbms_Output.Put_Line('  end loop;');
      END IF;
      Dbms_Output.Put_Line('  return l_respuesta;');
    ELSE
      IF Upper(l_Tipo_Info) NOT IN (k_Trama_Header_Pos
                                   ,k_Trama_Header_Boc
                                   ,k_Trama_Header_Ctx) THEN
        Dbms_Output.Put_Line(l_Identado ||
                             '  l_registro  := utl_raw.concat( scfr_trx_util_pk.num2bin( utl_raw.length(l_registro), 2 ), l_registro );');
        -- nuevo
        Dbms_Output.Put_Line(l_Identado || '  l_trama_htx.tipo_informacion   := ''' || Upper(l_Tipo_Info) || ''';');
        Dbms_Output.Put_Line(l_Identado || '  l_trama_htx.modo_largo_campos  := ''' || Upper(l_Modo_Largo) || ''';');
        Dbms_Output.Put_Line(l_Identado || '  l_trama_htx.largo_buffer_datos := dbms_lob.getlength( l_registro );');
        Dbms_Output.Put_Line(l_Identado || '  l_trama_htx.cantidad_registros := 1;');
        Dbms_Output.Put_Line(l_Identado || '  l_registro := utl_raw.concat( arma_trama_htx( l_trama_htx ), l_registro );');
        -- fin nuevo
      END IF;
      Dbms_Output.Put_Line('  return l_registro;');
    END IF;
    Dbms_Output.Put_Line('end;');
    Dbms_Output.Put_Line(' ');
    Dbms_Output.Put_Line(' ');
    Dbms_Output.Put_Line('end SCFR_TRX_DYN_RAW_PK;');
    Dbms_Output.Put_Line('/');
  END;

  FUNCTION Agrega_Iva(p_Cad_Cadena  IN NUMBER
                     ,p_Emp_Empresa IN NUMBER
                     ,p_Loc_Local   IN NUMBER
                     ,p_Iva         IN OUT NUMBER) RETURN VARCHAR2 IS

    l_Agrega_Iva VARCHAR2(2);
  BEGIN
    l_Agrega_Iva := 'NO';

    BEGIN
      SELECT 'SI'
        INTO l_Agrega_Iva
        FROM Scfr_Locales_Rollout t
       WHERE t.Loc_Local = p_Loc_Local
         AND t.Emp_Empresa = p_Emp_Empresa
         AND t.Cad_Cadena = p_Cad_Cadena;

      SELECT t.Rv_Low_Value INTO p_Iva FROM Fid.Cg_Ref_Codes t WHERE t.Rv_Domain = 'IVA';

    EXCEPTION
      WHEN OTHERS THEN
        l_Agrega_Iva := 'NO';
    END;

    RETURN l_Agrega_Iva;
  END;
  
  -- funcion para limpiar caracteres especiales DQUEZADA Receta electronica
      FUNCTION Limpiar_String(p_Texto IN VARCHAR2)
      RETURN VARCHAR2
      IS
          l_Texto VARCHAR2(4000);
      BEGIN

          IF p_Texto IS NULL THEN
              RETURN NULL;
          END IF;

          -- limpiar saltos de linea y tabs
          l_Texto := REPLACE(p_Texto, CHR(10), ' ');
          l_Texto := REPLACE(l_Texto, CHR(13), ' ');
          l_Texto := REPLACE(l_Texto, CHR(9), ' ');

          -- limpiar caracteres especiales / tildes
          l_Texto := TRANSLATE(
              l_Texto,
              '????????????????????????????????????????????????????????',
              'AEIOUAEIOUAEIOUAEIOUANOCYPDOaeiouaeiouaeiouaeiouanocypdo'
          );

          -- caracteres especiales compuestos
          l_Texto := REPLACE(l_Texto, '?', 'AE');
          l_Texto := REPLACE(l_Texto, '?', 'ae');
          l_Texto := REPLACE(l_Texto, '?', 'ss');

          -- espacios sobrantes
          l_Texto := TRIM(l_Texto);

          RETURN l_Texto;

      EXCEPTION
          WHEN OTHERS THEN
              RETURN TRIM(p_Texto);
      END;


END Scfr_Trx_Dyn_Pk;
/
