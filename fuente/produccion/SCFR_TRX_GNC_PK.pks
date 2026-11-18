CREATE OR REPLACE PACKAGE TRX3.Scfr_Trx_Gnc_Pk IS

  -- Author      : USER_PIVOT2
  -- Modified by : JESUS GUERRA CEDENO
  -- Modified    : 28/10/2026
  -- Purpose     : Corrección RECAUDOS 

  Vversion VARCHAR2(25) := 'GEO.09.09.2024';

  FUNCTION Version_Pkg RETURN VARCHAR2;

  /******************************************************************************
     NAME:      SCFR_TRX_GNC_PK
     PURPOSE:   Implementacion de transacciones genericas
                GNCC01 : Consulta de Perfil
                GNCC02 : Consulta de Venta
                GNCC03 : Consulta de Recaudacion
                GNCC04 : Consulta de Avance
                GNCU01 : Cierre de Venta
                GNCU02 : Reversa de Venta
                GNCU03 : Forma de Pago Transacciones
                GNCU04 : Transaccion de Autorizacion
                GNCU05 : Actualizacion de Recaudacion
                GNCU06 : Anulacion de Recaudacion
                GNCU07 : Actualizacion de Avance
                GNCU08 : Anulacion de Avance

     REVISIONS:
     Ver        Date        Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.0        30-12-2004  ASANCHEZ         1. Created this package.
            25-01-2008  SJC      2. Corrigue tema de las reversas que no podian anular programa de Salud
  ******************************************************************************/
  /*****************************************************************************
                              DEFINICIoN DE CONSTANTES Y TIPOS
  *****************************************************************************/
  k_Cod_Resp_Ok CONSTANT NUMBER := 0;

  k_Cod_Resp_Nok CONSTANT NUMBER := 1;

  g_Codigo_Transaccion VARCHAR2(10);

  TYPE Tab_Productos IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  TYPE Tab_Doc_Emitidos IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  TYPE r_Puntos_Canjeados IS RECORD(
     Folio        NUMBER
    ,Total_Puntos NUMBER);

  TYPE Tab_Puntos_Canjeados IS TABLE OF r_Puntos_Canjeados INDEX BY BINARY_INTEGER;

  TYPE r_Doctos_Emitidos IS RECORD(
     Secuencia     Scfr_Mov_Documentos_Txs.Secuencia%TYPE
    ,Tipo_Mov_Hijo Scfr_Mov_Documentos_Txs.Tmo_Movimiento%TYPE
    ,Anulado       Scfr_Mov_Documentos_Txs.Anulado%TYPE
    ,Total         Scfr_Mov_Documentos_Txs.Monto%TYPE);

  TYPE t_Doctos_Emitidos IS TABLE OF r_Doctos_Emitidos INDEX BY BINARY_INTEGER;

  --//--------------------------------------------------------------------------\\
  --// CBR 24/07/2018 20:11                                                     \\
  --// BIFURCAR EMPRESA MAICAO EN GNCC01                                        \\
  --//-----------------------------------------------------------------Inicio---\\
  l_Es_Loyalty BOOLEAN := FALSE;
  --//-----------------------------------------------------------------Termino--\\

  /*****************************************************************************
                  ESPECIFICACIoN DE PROCEDIMIENTOS Y FUNCIONES
  *****************************************************************************/
  PROCEDURE Agrega_Respuesta(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                            ,p_Cod_Resp    IN NUMBER
                            ,x_Respuesta   OUT BLOB);

  PROCEDURE Arma_Xml_Aeropuerto(p_Txo_Codigo_Tx      IN NUMBER
                               ,p_Txo_Correlativo_Tx IN NUMBER
                               ,x_Cod_Error          OUT NUMBER
                               ,x_Msg_Error          OUT VARCHAR2);

  FUNCTION Es_Consulta_Loyalty(p_Empresa IN NUMBER
                              ,p_Cadena  IN NUMBER
                              ,p_Local   IN NUMBER) RETURN VARCHAR2;
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
                  ,x_Msg_Error   OUT VARCHAR2);

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
                  ,x_Msg_Error   OUT VARCHAR2);

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
                  ,x_Msg_Error   OUT VARCHAR2);

  /*****************************************************************************
  Consulta de Avance. Obtiene informacion relacionada a un avance.
  Parametros Entrada:
    p_transaccion => Transaccion que contiene la peticion del avance en forma de arreglo
  Parametros Salida:
    x_respuesta   => Transaccion que contiene el avance en formato RAW
    x_cod_error   => Codigo de error, si es que hubo algun problema
    x_msg_error   => Mensaje de error, si es que hubo algun problema
  *****************************************************************************/
  PROCEDURE Gncc04(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  /*****************************************************************************
  Consulta Vademecum Ecuador.
  Parametros Entrada:
    p_transaccion => Transaccion que contiene la peticion del avance en forma de arreglo
  Parametros Salida:
    x_respuesta   => Transaccion que contiene el avance en formato RAW
    x_cod_error   => Codigo de error, si es que hubo algun problema
    x_msg_error   => Mensaje de error, si es que hubo algun problema
  *****************************************************************************/
  PROCEDURE Gncc10(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

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
                  ,x_Msg_Error   OUT VARCHAR2);

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
                  ,x_Msg_Error   OUT VARCHAR2);

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
                  ,x_Msg_Error   OUT VARCHAR2);

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
                  ,x_Msg_Error   OUT VARCHAR2);

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
                  ,x_Msg_Error   OUT VARCHAR2);

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
                  ,x_Msg_Error   OUT VARCHAR2);

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
                  ,x_Msg_Error   OUT VARCHAR2);

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
                  ,x_Msg_Error   OUT VARCHAR2);

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
                  ,x_Msg_Error   OUT VARCHAR2);

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
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Gncu12(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);
  /*
    PROCEDURE Gncu13(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                    ,x_Respuesta   OUT BLOB
                    ,x_Cod_Error   OUT NUMBER
                    ,x_Msg_Error   OUT VARCHAR2);
  */

  PROCEDURE Gncu14(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  -- GNC015 Retencion IVA
  PROCEDURE Gncu15(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Update_Codigo_Cotizacion(p_Secuencia_Ot IN Scfr_Rm_Cotizacion.Secuencia_Ot%TYPE
                                    ,p_Codigo_Tx    IN Scfr_Rm_Cotizacion.Codigo_Tx_Vta%TYPE
                                    ,p_Trx_Codigo   IN Scfr_Trx_Rec_Pos.Codigo_Transaccion%TYPE
                                    ,x_Cod_Error    OUT NUMBER
                                    ,x_Msg_Error    OUT VARCHAR2); 

  PROCEDURE Update_Folio_Excedente(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                  ,x_Cod_Error   OUT NUMBER
                                  ,x_Msg_Error   OUT VARCHAR2);
                                  
  Function Obtiene_url(L_id_servicio_ws In Varchar2,
                       X_msg_error      Out Varchar2) Return Varchar2;
                                  
   PROCEDURE LOG_DEBUG ( TIPO_PRUEBA IN VARCHAR2,
                        descripcion IN VARCHAR2,
                        id_cliente IN VARCHAR2,
                        local IN number,
                        codigo_tx IN number);    
  
  PROCEDURE Trama_Pm_Recargas_Telepeajes(p_Transaccion    IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                        ,p_Trama_Pm       IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pm
                                        ,p_Trama_Dv       IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                                        ,p_Codigo_Detalle IN NUMBER
                                        ,p_Tipo_Tx        IN VARCHAR2
                                        ,x_Cod_Error      OUT NUMBER
                                        ,x_Msg_Error      OUT NUMBER) ;                           

END Scfr_Trx_Gnc_Pk;
/
