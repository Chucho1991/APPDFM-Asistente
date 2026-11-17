CREATE OR REPLACE PACKAGE TRX3.Scfr_Trx_Gnc_Utl_Pk IS

  -- Author      : USER_PIVOT2
  -- Modified by : JESUS GUERRA CEDENO
  -- Modified    : 28/10/2026
  -- Purpose     : Correcci�n RECAUDOS 

  Vversion VARCHAR2(25) := 'GEO.21.09.2022';

  /************************************************/
  /** En esta version se incluye el tema de      **/
  /** Anulacion de Recaudacion de Seguros        **/
  /************************************************/
  FUNCTION Version_Pkg RETURN VARCHAR2;

  k_Registro_Receta CONSTANT VARCHAR2(3) := 'REG';

  k_Retiro_Receta CONSTANT VARCHAR2(3) := 'RET';

  k_Reversa_Receta CONSTANT VARCHAR2(3) := 'REV';

  TYPE Reg_Enc_Receta IS RECORD(
     Id_Receta        Scfr_Rec_Recetas.Id_Receta%TYPE
    ,Secuencia_Receta Scfr_Rec_Recetas.Secuencia_Receta%TYPE
    ,Fecha_Emision    Scfr_Rec_Recetas.Fecha_Emision%TYPE
    ,Folio_Receta     Scfr_Rec_Recetas.Folio_Receta%TYPE
    ,Con_Copia        Scfr_Rec_Recetas.Con_Copia%TYPE
    ,Fecha_Ingreso    Scfr_Rec_Recetas.Fecha_Ingreso%TYPE
    ,Tipo_Receta      Scfr_Rec_Recetas.Tipo_Receta%TYPE
    ,Diagnostico      Scfr_Rec_Recetas.Diagnostico%TYPE
    ,Rut_Cliente      Scfr_Rec_Recetas.Rut_Cliente%TYPE
    ,Dv_Cliente       Scfr_Rec_Recetas.Dv_Cliente%TYPE
    ,Rut_Paciente     Scfr_Rec_Recetas.Rut_Paciente%TYPE
    ,Dv_Paciente      Scfr_Rec_Recetas.Dv_Paciente%TYPE
    ,Nombre_Paciente  Scfr_Rec_Recetas.Nombre_Paciente%TYPE
    ,Fono_Paciente    Scfr_Rec_Recetas.Fono_Paciente%TYPE
    ,Rut_Medico       Scfr_Rec_Recetas.Rut_Medico%TYPE
    ,Dv_Medico        Scfr_Rec_Recetas.Dv_Medico%TYPE
    ,Nombre_Medico    Scfr_Rec_Recetas.Nombre_Medico%TYPE
    ,Serie            Scfr_Rec_Recetas.Serie%TYPE
    ,Convenio         Scfr_Rec_Recetas.Convenio%TYPE
    ,Plan             Scfr_Rec_Recetas.Plan%TYPE
    ,Tipo_Medicamento Scfr_Rec_Recetas.Tipo_Medicamento%TYPE
    ,Estado_Receta    Scfr_Rec_Recetas.Estado_Receta%TYPE
    ,Rut_Institucion  Scfr_Rec_Recetas.Rut_Institucion%TYPE
    ,Dv_Institucion   Scfr_Rec_Recetas.Dv_Institucion%TYPE);

  TYPE Reg_Det_Producto IS RECORD(
     Producto           Scfr_Rec_Productos.Producto%TYPE
    ,Dosis              Scfr_Rec_Productos.Dosis%TYPE
    ,Veces              Scfr_Rec_Productos.Veces%TYPE
    ,Dias               Scfr_Rec_Productos.Dias%TYPE
    ,Cantidad           Scfr_Rec_Productos.Cantidad%TYPE
    ,Forma_Farmaceutica Scfr_Rec_Productos.Forma_Farmaceutica%TYPE
    ,Texto              Scfr_Rec_Productos.Texto%TYPE
    ,Id_Detalle         Scfr_Rec_Productos.Id_Detalle%TYPE
    ,Inscribir_Refill   Scfr_Rec_Productos.Inscribir_Refill%TYPE
    ,Rec_Id_Receta      Scfr_Rec_Productos.Rec_Id_Receta%TYPE);

  TYPE Rec_Movimientos IS RECORD(
     Secuencia_Receta NUMBER);

  TYPE Tab_Movimientos IS TABLE OF Rec_Movimientos INDEX BY BINARY_INTEGER;

  TYPE Reg_Prods_Tratamiento IS RECORD(
     Convenio     NUMBER
    ,Plan         NUMBER
    ,Producto     NUMBER
    ,Dias         NUMBER
    ,Inicio       DATE
    ,Termino      DATE
    ,LOCAL        NUMBER
    ,Fecha_Compra DATE);

  TYPE Tab_Prods_Tratamiento IS TABLE OF Reg_Prods_Tratamiento INDEX BY BINARY_INTEGER;

  TYPE Reg_Convenios IS RECORD(
     Convenio NUMBER
    ,Plan     NUMBER);

  TYPE Tab_Convenios IS TABLE OF Reg_Convenios INDEX BY BINARY_INTEGER;

  TYPE Reg_Productos_Trat IS RECORD(
     Producto     NUMBER
    ,Dias         NUMBER
    ,Inicio       DATE
    ,Termino      DATE
    ,LOCAL        NUMBER
    ,Fecha_Compra DATE);

  TYPE Tab_Productos_Trat IS TABLE OF Reg_Productos_Trat INDEX BY BINARY_INTEGER;

  TYPE Reg_Encabezado_Cartola IS RECORD(
     Id_Receta       Scfr_Rec_Recetas.Id_Receta%TYPE
    ,Rut_Paciente    Scfr_Rec_Recetas.Rut_Paciente%TYPE
    ,Dv_Paciente     Scfr_Rec_Recetas.Dv_Paciente%TYPE
    ,Nombre_Paciente Scfr_Rec_Recetas.Nombre_Paciente%TYPE
    ,Diagnostico     Scfr_Rec_Recetas.Diagnostico%TYPE
    ,Fecha_Emision   Scfr_Rec_Recetas.Fecha_Emision%TYPE
    ,Convenio        Scfr_Rec_Recetas.Convenio%TYPE
    ,Plan            Scfr_Rec_Recetas.Plan%TYPE
    ,Rut_Medico      Scfr_Rec_Recetas.Rut_Medico%TYPE
    ,Dv_Medico       Scfr_Rec_Recetas.Dv_Medico%TYPE
    ,Nombre_Medico   Scfr_Rec_Recetas.Nombre_Medico%TYPE
    ,Estado_Receta   Scfr_Rec_Recetas.Estado_Receta%TYPE);

  TYPE Reg_Cartola IS RECORD(
     Fecha             DATE
    ,Concepto          VARCHAR2(100)
    ,Venta_Relacionada NUMBER
    ,LOCAL             NUMBER
    ,Vendedor          VARCHAR2(100)
    ,Producto          NUMBER
    ,Desc_Producto     VARCHAR2(1000)
    ,Abono             NUMBER
    ,Cargo             NUMBER
    ,Saldo             NUMBER);

  TYPE Tab_Cartola IS TABLE OF Reg_Cartola INDEX BY BINARY_INTEGER;

  TYPE Reg_Saldos_Cartola IS RECORD(
     Producto NUMBER
    ,Saldo    NUMBER);

  TYPE Tab_Saldos_Cartola IS TABLE OF Reg_Saldos_Cartola INDEX BY BINARY_INTEGER;

  TYPE Reg_Productos_Aut IS RECORD(
     Producto   NUMBER
    ,Autorizado VARCHAR2(2));

  TYPE Tab_Productos IS TABLE OF Reg_Productos_Aut INDEX BY BINARY_INTEGER;

  TYPE Reg_Receta IS RECORD(
     Serie            VARCHAR2(4)
    ,Secuencia_Receta NUMBER
    ,Rut_Medico       NUMBER(10)
    ,Dv_Medico        VARCHAR2(1)
    ,Nombre_Medico    VARCHAR2(20)
    ,Fecha_Emision    DATE
    ,Diagnostico      VARCHAR2(15)
    ,Tipo_Receta      VARCHAR2(3)
    ,Con_Copia        VARCHAR2(2)
    ,Folio_Receta     NUMBER(15)
    ,Tipo_Medicamento VARCHAR2(3)
    ,Rut_Paciente     NUMBER(10)
    ,Dv_Paciente      VARCHAR2(1)
    ,Nombre_Paciente  VARCHAR2(60)
    ,Fecha_Ingreso    DATE
    ,Fono_Paciente    VARCHAR2(15)
    ,Convenio         NUMBER(15)
    ,Plan             NUMBER(15)
    ,Rut_Cliente      NUMBER(10)
    ,Dv_Cliente       VARCHAR2(1)
    ,Rut_Institucion  NUMBER(10)
    ,Dv_Institucion   VARCHAR2(1));

  TYPE Reg_Producto IS RECORD(
     Rec_Id_Receta      NUMBER(15)
    ,Producto           NUMBER(7)
    ,Cantidad           NUMBER(3)
    ,Dosis              NUMBER(3)
    ,Veces              NUMBER(3)
    ,Dias               NUMBER(3)
    ,Inscribir_Refill   VARCHAR2(2)
    ,Texto              VARCHAR2(100)
    ,Forma_Farmaceutica VARCHAR2(3));

  TYPE Reg_Movimiento IS RECORD(
     Rec_Id_Receta   NUMBER
    ,Fecha           DATE
    ,Tipo_Movimiento VARCHAR2(3)
    ,LOCAL           NUMBER
    ,Txo_Codigo_Tx   NUMBER);

  TYPE Reg_Mov_Producto IS RECORD(
     Cce_Id_Movimiento NUMBER
    ,Producto          NUMBER
    ,Cant_Uni_Venta    NUMBER
    ,Cant_Pills        NUMBER
    ,Boleta            NUMBER);

  TYPE Reg_Boletas IS RECORD(
     Folio            Scfr_Mov_Documentos_Txs.Folio%TYPE
    ,Tipo_Descuento   Scfr_Mov_Descuentos_Productos.Tipo_Aplicacion_Descuento%TYPE
    ,Campana_Convenio Scfr_Mov_Descuentos_Productos.Campana_Convenio%TYPE
    ,Monto            Scfr_Mov_Descuentos_Productos.Monto%TYPE
    ,Unidades         NUMBER);

  TYPE Tab_Descuentos IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  PROCEDURE Gncu09(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  FUNCTION Obtiene_Mov_Hijo(p_Trama_Dr IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dr) RETURN VARCHAR2;

  FUNCTION Retorna_Puntos_Canjeados(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion) RETURN NUMBER;

  FUNCTION Devuelve_Encabezado_Receta(p_Id_Receta IN NUMBER) RETURN Reg_Enc_Receta;

  FUNCTION Devuelve_Detalle_Producto(p_Id_Receta IN NUMBER
                                    ,p_Producto  IN NUMBER) RETURN Reg_Det_Producto;

  PROCEDURE Listado_Receta(p_Receta         IN NUMBER
                          ,x_Cartola_Enc    IN OUT Reg_Encabezado_Cartola
                          ,x_Cartola        IN OUT Tab_Cartola
                          ,x_Cartola_Saldos IN OUT Tab_Saldos_Cartola
                          ,x_Ret            OUT NUMBER
                          ,x_Msg            OUT VARCHAR2);

  FUNCTION Devuelve_Dias(p_Producto IN NUMBER
                        ,p_Dosis    IN NUMBER
                        ,p_Veces    IN NUMBER
                        ,p_Cantidad IN NUMBER) RETURN NUMBER;

  FUNCTION Prepara_Convenios(p_Datos IN Tab_Prods_Tratamiento) RETURN Tab_Convenios;

  FUNCTION Devuelve_Productos_Trat(p_Datos    IN Tab_Prods_Tratamiento
                                  ,p_Convenio IN NUMBER
                                  ,Plan       IN NUMBER) RETURN Tab_Productos_Trat;

  PROCEDURE Setea_Estado_Receta(p_Receta    IN NUMBER
                               ,x_Cod_Error OUT NUMBER
                               ,x_Msg_Error OUT VARCHAR2);

  FUNCTION Autoriza_Producto_Receta(p_Rut          IN NUMBER
                                   ,p_Convenio     IN NUMBER DEFAULT NULL
                                   ,p_Plan         IN NUMBER DEFAULT NULL
                                   ,p_Producto     IN NUMBER
                                   ,p_Receta_Nueva IN VARCHAR2
                                   ,p_Id_Receta    IN NUMBER DEFAULT NULL) RETURN VARCHAR2;

  FUNCTION Devuelve_Cantidad(p_Producto IN NUMBER
                             --                            , p_convenio in number
                             --                            , p_plan     in number
                            ,p_Dosis IN NUMBER
                            ,p_Veces IN NUMBER
                            ,p_Dias  IN NUMBER) RETURN NUMBER;

  FUNCTION Devuelve_Receta(p_Rut      IN NUMBER
                          ,p_Convenio IN NUMBER
                          ,p_Plan     IN NUMBER
                          ,p_Producto IN NUMBER
                          ,x_Ret      OUT NUMBER
                          ,x_Msg      OUT VARCHAR2) RETURN NUMBER;

  PROCEDURE Registra_Ccr_Batch(p_Codigo_Tx IN NUMBER
                              ,p_Receta    IN NUMBER
                              ,x_Ret       OUT NUMBER
                              ,x_Msg       OUT VARCHAR2);

  PROCEDURE Autoriza(p_Receta    IN NUMBER
                    ,p_Convenio  IN NUMBER
                    ,p_Plan      IN NUMBER
                    ,p_Productos IN OUT Tab_Productos
                    ,x_Ret       OUT NUMBER
                    ,x_Msg       OUT VARCHAR2);

  PROCEDURE Reversa_Seguro(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                          ,x_Cod_Error   OUT NUMBER
                          ,x_Msg_Error   OUT VARCHAR2);

  FUNCTION Trama_Rp_Prepara(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,p_Tipo        IN VARCHAR2 DEFAULT 'PEN' -- 'TOT'
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp;

  FUNCTION Trama_Rp_Prepara_New(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                               ,p_Perfil      IN VARCHAR2
                               ,x_Cod_Error   OUT NUMBER
                               ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp;

  FUNCTION Trama_Fm_Prepara(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,p_Rut         IN NUMBER
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Fm;

  PROCEDURE Gncc05(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Gncc06(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Registra_En_Cta_Cte_Recetas(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                       ,p_Tipo        IN VARCHAR2
                                       ,x_Cod_Error   OUT NUMBER
                                       ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Registra_Datos_Ventas_Sri(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                     ,x_Trama_Dp    IN OUT Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp
                                     ,x_Trama_Dv    IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                                     ,x_Cod_Error   OUT NUMBER
                                     ,x_Msg_Error   OUT VARCHAR2);
  
  PROCEDURE Registra_Datos_Ventas_Recaud(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                         ,x_Trama_Dp    IN OUT Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp
                                         ,x_Trama_Dr    IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dr
                                     ,x_Cod_Error   OUT NUMBER
                                     ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Arma_Trama_Dv_Desde_Dr(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                  ,x_Trama_Dv    OUT Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                                  ,x_Cod_Error   OUT NUMBER
                                  ,x_Msg_Error   OUT VARCHAR2);

  FUNCTION Complementa_Trama_Ca(l_Trama_Ca  IN OUT Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ca
                               ,p_Party_Id  IN NUMBER
                               ,x_Cod_Error OUT NUMBER
                               ,x_Msg_Error OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ca;

  FUNCTION Devuelve_Party_Beneficiario(p_Rut_Beneficiario IN NUMBER
                                      ,p_Party_Id         IN NUMBER) RETURN NUMBER;

  PROCEDURE Trama_De_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2);

  FUNCTION Dueno_Local(p_Empresa IN NUMBER
                      ,p_Cadena  IN NUMBER
                      ,p_Local   IN NUMBER) RETURN NUMBER;

  FUNCTION Obtiene_Campana_Puntos(p_Empresa IN NUMBER
                                 ,p_Cadena  IN NUMBER) RETURN NUMBER;

  FUNCTION Arma_Datos_Puntos(p_Accion_Puntos  IN VARCHAR2
                            ,p_Party_Id       IN NUMBER
                            ,p_Monto_Original IN NUMBER
                            ,p_Total_Puntos   IN NUMBER
                            ,p_Codigo_Tx      IN NUMBER
                            ,p_Campana        IN NUMBER
                            ,p_Folio_Docto    IN NUMBER
                            ,p_Empresa        IN NUMBER
                            ,p_Cadena         IN NUMBER
                            ,p_Local          IN NUMBER
                            ,p_Party_Vendedor IN NUMBER) RETURN VARCHAR2;

  FUNCTION Determina_Accion_Puntos(p_Party_Id IN NUMBER) RETURN VARCHAR2;

  FUNCTION Obtiene_Id_Productos_Doctos(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                      ,p_Trama_Pm    IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pm) RETURN NUMBER;

  FUNCTION Obtiene_Folio_Docto(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                              ,p_Trama_Pm    IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pm) RETURN NUMBER;

  FUNCTION Ordena_Productos(p_Trama_Pm IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm) RETURN Scfr_Trx_Gnc_Pk.Tab_Productos;

  FUNCTION Tiene_Control_Frecuencia(p_Campana IN NUMBER) RETURN VARCHAR2;

  FUNCTION Campanas_Frecuencias(p_Campana       IN NUMBER
                               ,p_Party_Id      IN NUMBER
                               ,p_Rut_Cliente   IN NUMBER
                               ,p_Codigo_Tx     IN NUMBER
                               ,p_Fecha_Venta   IN DATE
                               ,p_Tipo_Mov_Frec IN VARCHAR2) RETURN NUMBER;

  FUNCTION Quita_Desc_Repetidos(p_Subtrama_Pm2 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm2) RETURN Scfr_Trx_Gnc_Utl_Pk.Tab_Descuentos;

  FUNCTION Esta_Vigente(p_Campana IN NUMBER) RETURN VARCHAR2;

  PROCEDURE Documento_Recaudacion(p_Correlativo_Tx   IN OUT NUMBER
                                 ,p_Pin_Ot_Recetario IN OUT VARCHAR2
                                 ,p_Local            IN NUMBER
                                 ,x_Largo_Reg        OUT NUMBER
                                 ,x_Salida           OUT Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dr
                                 ,x_Cod_Error        OUT NUMBER
                                 ,x_Msg_Error        OUT VARCHAR2);

  PROCEDURE Registra_Datos_Ult_Compra(p_Rut_Titular IN NUMBER
                                     ,p_Fecha_Venta IN DATE
                                     ,p_Local_Venta IN NUMBER);

  PROCEDURE Obtiene_Datos_Ult_Compra(p_Rut_Titular IN NUMBER
                                    ,x_Trama_Dp    IN OUT Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp);

  PROCEDURE Actualiza_Relacion_Venta(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion);

  PROCEDURE Actualiza_Relacion_Recaud(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion);

  PROCEDURE Actualiza_Relacion_Avance(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion);

  PROCEDURE Actualiza_Relacion_Pagos(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion);

  PROCEDURE Trama_Rp_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Obtener_Fechas(p_Empresa       IN NUMBER
                          ,p_Convenio      IN NUMBER
                          ,p_Plan          IN NUMBER
                          ,p_Party_Id      IN NUMBER
                          ,p_Periodicidad  IN VARCHAR2
                          ,p_Fecha_Consumo IN DATE
                          ,p_Lista_Unica   IN VARCHAR2
                          ,x_Fecha_Ini     OUT VARCHAR2);

  PROCEDURE Registra_En_Cta_Cte_Descuento1(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                          ,p_Tipo        IN VARCHAR2
                                          ,p_Offline     IN VARCHAR2 DEFAULT 'NO'
                                          ,p_Observacion IN VARCHAR2
                                          ,p_Incluido    IN VARCHAR2 DEFAULT 'SI'
                                          ,x_Cod_Error   OUT NUMBER
                                          ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Registra_Cartola_Desde_Batch(p_Fecha IN DATE
                                        ,p_Local IN NUMBER);

  PROCEDURE Trama_Pm_Resuelve_Seg(p_Transaccion  IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                 ,p_Doc_Emitidos IN Scfr_Trx_Gnc_Pk.Tab_Doc_Emitidos
                                 ,p_Trama_Dv     IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                                 ,p_Tipo_Tx      IN VARCHAR2
                                 ,p_Tipo_Mvto    IN Scfr_Recauda_Movimientos.Codigo_Movimiento%TYPE
                                 ,x_Cod_Error    OUT NUMBER
                                 ,x_Msg_Error    OUT VARCHAR2);

  PROCEDURE Trama_Pm_Doctos_Referencia(p_Transaccion    IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                      ,p_Trama_Pm       IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pm
                                      ,p_Trama_Dv       IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                                      ,p_Doc_Emitidos   IN Scfr_Trx_Gnc_Pk.Tab_Doc_Emitidos
                                      ,p_Codigo_Detalle IN NUMBER
                                      ,p_Tipo_Tx        IN VARCHAR2
                                      ,x_Cod_Error      OUT NUMBER
                                      ,x_Msg_Error      OUT VARCHAR2);

  FUNCTION Trama_Tm_Prepara(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tm;

  FUNCTION Obtiene_Party_Paciente(p_Codigo_Empresa      IN NUMBER
                                 ,p_Codigo_Autorizacion IN VARCHAR2) RETURN NUMBER;

  FUNCTION Retorna_Benef_Cam(p_Cam_Campana IN NUMBER
                            ,p_Fecha_Tx    IN DATE
                            ,p_Rut         IN NUMBER
                            ,p_Local       IN NUMBER
                            ,p_Datos       OUT VARCHAR2) RETURN BOOLEAN;

  PROCEDURE Registra_Vta(p_Fecha_Tx    IN DATE
                        ,p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                        ,p_Rut         IN NUMBER);

  PROCEDURE Registra_Log_Benef(p_Fecha          IN DATE DEFAULT SYSDATE
                              ,p_Rut            IN NUMBER DEFAULT NULL
                              ,p_Local          IN NUMBER DEFAULT NULL
                              ,p_Pos            IN NUMBER DEFAULT NULL
                              ,p_Correlativo_Tx IN NUMBER DEFAULT NULL
                              ,p_Rut_Vend       IN NUMBER DEFAULT NULL
                              ,p_Tipo           IN VARCHAR2 DEFAULT NULL
                              ,p_Otros_Datos    IN VARCHAR2 DEFAULT NULL);

  FUNCTION Obtiene_Dia_Num(p_Fecha IN DATE DEFAULT SYSDATE) RETURN NUMBER;

  FUNCTION Obtiene_Digito_Verificador(p_Rut_Sin_Digito IN NUMBER) RETURN VARCHAR2;
  PROCEDURE Set_Nls(Param IN VARCHAR2);
   
  FUNCTION Limpiar_String(input_string VARCHAR2) RETURN VARCHAR2; 
  
  PROCEDURE Trama_Pm_Impuestos_Aplicados(p_Transaccion    IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                        ,p_Trama_Pm       IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pm
                                        --,p_Trama_Dv       IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                                        ,P_Correlativo_Tx   IN NUMBER
                                        ,p_Codigo_Detalle IN NUMBER
                                        ,x_Cod_Error      OUT NUMBER
                                        ,x_Msg_Error      OUT NUMBER);
END Scfr_Trx_Gnc_Utl_Pk;
/
