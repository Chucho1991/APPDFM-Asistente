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
