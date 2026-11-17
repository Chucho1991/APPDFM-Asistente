CREATE OR REPLACE PACKAGE TRX3.Scfr_Trx_Gnc_Utl_Pk IS

  -- Author      : USER_PIVOT2
  -- Modified by : JESUS GUERRA CEDENO
  -- Modified    : 22/10/2026
  -- Purpose     : Cambio Boletos / Recaudos - origen transaccion OBE 

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
CREATE OR REPLACE PACKAGE BODY TRX3.Scfr_Trx_Gnc_Utl_Pk IS

  TYPE Rec_Productos_Oferta IS RECORD(
     LOCAL    VARCHAR2(10)
    ,Cadena   VARCHAR2(10)
    ,Fecha    DATE
    ,Producto NUMBER
    ,Precio   NUMBER
    ,Fechaact DATE);

  TYPE Tab_Productos_Oferta IS TABLE OF Rec_Productos_Oferta INDEX BY BINARY_INTEGER;

  PROCEDURE Spsendmail(Pivsender    IN VARCHAR2
                      ,Pivrecipient IN VARCHAR2
                      ,Pivcc        IN VARCHAR2 DEFAULT NULL
                      ,Pivsubject   IN VARCHAR2
                      ,Pivmessage   IN VARCHAR2
                      ,Pivattached1 IN VARCHAR2 DEFAULT NULL
                      ,Pivattached2 IN VARCHAR2 DEFAULT NULL
                      ,Pivattached3 IN VARCHAR2 DEFAULT NULL
                      ,Pinmaxsize   IN NUMBER DEFAULT 9999999999) IS
    /*
     Object Type:   procedure
     Object Name:   spSendMail
     Description:   This procedure uses the UTL_SMTP package to send an email message.
                    Up to three TEXT files may be specified as attachments.
                    Only Text files can be sent as attachments now.

                    Sample usage:
                    spSendMail (pivSender      =gt; 'Devang@home.com',
                                pivRecipient   =gt; 'Devang@home.com',
                                pivCc          =gt; 'devang@home.com;devang@home.com',
                                pivSubject     =gt; 'Test',
                                pivMessage     =gt; 'Test',
                                pivAttached1   =gt; '/data/oracle/dev_test1.txt',
                                pivAttached2   =gt; '/data/oracle/dev_test2.txt');

      Created by: Devang      Date (mm/dd/yyyy)   Comments
     ---------------------------------------------------------------------------------------------
               Remove filename="message.txt" from Content-Disposition,
                                              and name="message.txt"; from Content-Type, in order
                                              to display message in the message body, not attachment.
              Allow to send Cc.
               Allow to send multiple Cc separated by semicolon ';'.
     ---------------------------------------------------------------------------------------------
    */
    Lvsmtpserver     VARCHAR2(20) := 'petrohue.cverde.cl';
    Lvsmtpserverport NUMBER := 25;
    Lvdirectory      VARCHAR2(100);
    Lvfilename       VARCHAR2(100);
    Lvline           VARCHAR2(1000);
    Lvcrlf           VARCHAR2(2) := Chr(13) || Chr(10);
    Lvmessage        VARCHAR2(32767);
    Lvconnection     Utl_Smtp.Connection;
    Lvcc             VARCHAR2(100);
    Lncccount        NUMBER(8);
    Lnlastsemicolon  NUMBER(8);
    Lncursemicolon   NUMBER(8);
    TYPE Ltypefile IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;
    Ltabfile                   Ltypefile;
    i                          BINARY_INTEGER;
    Lvfilehandle               Sys.Utl_File.File_Type;
    Lvslashposition            NUMBER;
    Lvmessagelength            NUMBER;
    Lemessagetoolong           EXCEPTION;
    Leinvalidpath              EXCEPTION;
    Lvmessagelengthgthexceeded BOOLEAN := FALSE;
  BEGIN
    -- Load the attached filenames into an array for easier handling.
    Ltabfile(1) := Pivattached1;
    Ltabfile(2) := Pivattached2;
    Ltabfile(3) := Pivattached3;
    -- Open the SMTP connection:
    Lvconnection := Utl_Smtp.Open_Connection(Lvsmtpserver
                                            ,Lvsmtpserverport);
    -- Initial handshaking ...
    Utl_Smtp.Helo(Lvconnection
                 ,Lvsmtpserver);
    Utl_Smtp.Mail(Lvconnection
                 ,Pivsender);
    Utl_Smtp.Rcpt(Lvconnection
                 ,Pivrecipient);
    -- Process multiple CC separated by ';'
    IF Pivcc IS NOT NULL THEN
      Lncccount := 1;
      LOOP
        IF Lncccount = 1 THEN
          Lnlastsemicolon := 0;
        ELSE
          Lnlastsemicolon := Instr(Pivcc
                                  ,';'
                                  ,1
                                  ,Lncccount - 1);
        END IF;
        Lncursemicolon := Instr(Pivcc
                               ,';'
                               ,1
                               ,Lncccount);
        IF Lncursemicolon = 0 THEN
          Lvcc := Substr(Pivcc
                        ,Lnlastsemicolon + 1);
          Utl_Smtp.Rcpt(Lvconnection
                       ,Lvcc);
          EXIT;
        ELSE
          Lvcc := Substr(Pivcc
                        ,Lnlastsemicolon + 1
                        ,Lncursemicolon - Lnlastsemicolon - 1);
          Utl_Smtp.Rcpt(Lvconnection
                       ,Lvcc);
        END IF;
        Lncccount := Lncccount + 1;
      END LOOP;
    END IF;
    Utl_Smtp.Open_Data(Lvconnection);
    -- build the start of the mail message ...
    Lvmessage       :=  --'Date: '||TO_CHAR( SYSDATE, 'dd Mon yy hh24:mi:ss' )|| lvCRLF ||
     'From: ' || Pivsender || Lvcrlf || 'Subject: ' || Pivsubject || Lvcrlf || 'To: ' || Pivrecipient || Lvcrlf || 'Cc: ' || Pivcc ||
                       Lvcrlf || 'Mime-Version: 1.0' || Lvcrlf || 'Content-Type: multipart/mixed; boundary="DMW.Boundary.605592468"' || Lvcrlf ||
                       '--DMW.Boundary.605592468' || Lvcrlf || 'Content-Type: text/plain; charset=US-ASCII' || Lvcrlf ||
                       'Content-Disposition: inline;' || Lvcrlf || 'Content-Transfer-Encoding: 7bit' || Lvcrlf || '' || Lvcrlf || Pivmessage ||
                       Lvcrlf;
    Lvmessagelength := Length(Lvmessage);
    IF Lvmessagelength > Pinmaxsize THEN
      Lvmessagelengthgthexceeded := TRUE;
    END IF;
    Utl_Smtp.Write_Data(Lvconnection
                       ,Lvmessage);
    -- Append the files ...
    FOR i IN 1 .. 3
    LOOP
      -- Exit if message length already exceeded ...
      EXIT WHEN Lvmessagelengthgthexceeded;
      -- If the filename has been supplied ...
      IF Ltabfile(i) IS NOT NULL THEN
        BEGIN
          -- locate the final '/' or '\' in the pathname ...
          Lvslashposition := Instr(Ltabfile(i)
                                  ,'/'
                                  ,-1);
          IF Lvslashposition = 0 THEN
            Lvslashposition := Instr(Ltabfile(i)
                                    ,'\'
                                    ,-1);
          END IF;
          -- separate the filename from the directory name ...
          Lvdirectory := Substr(Ltabfile(i)
                               ,1
                               ,Lvslashposition - 1);
          Lvfilename  := Substr(Ltabfile(i)
                               ,Lvslashposition + 1);
          -- open the file ...
          Lvfilehandle := Utl_File.Fopen(Lvdirectory
                                        ,Lvfilename
                                        ,'r');
          -- generate the MIME boundary line ...
          Lvmessage       := Lvcrlf || '--DMW.Boundary.605592468' || Lvcrlf || 'Content-Type: application/octet-stream; name="' || Lvfilename || '"' ||
                             Lvcrlf || 'Content-Disposition: attachment; filename="' || Lvfilename || '"' || Lvcrlf ||
                             'Content-Transfer-Encoding: 7bit' || Lvcrlf || Lvcrlf;
          Lvmessagelength := Lvmessagelength + Length(Lvmessage);
          Utl_Smtp.Write_Data(Lvconnection
                             ,Lvmessage);
          -- and append the file contents to the end of the message ...
          LOOP
            Utl_File.Get_Line(Lvfilehandle
                             ,Lvline);
            IF Lvmessagelength + Length(Lvline) > Pinmaxsize THEN
              Lvmessage := '*** truncated ***' || Lvcrlf;
              Utl_Smtp.Write_Data(Lvconnection
                                 ,Lvmessage);
              Lvmessagelengthgthexceeded := TRUE;
              RAISE Lemessagetoolong;
            END IF;
            Lvmessage := Lvline || Lvcrlf;
            Utl_Smtp.Write_Data(Lvconnection
                               ,Lvmessage);
            Lvmessagelength := Lvmessagelength + Length(Lvmessage);
          END LOOP;
        EXCEPTION
          WHEN No_Data_Found THEN
            NULL;
          WHEN Utl_File.Invalid_Path THEN
            Raise_Application_Error(-20101
                                   ,'Invalid path while opening attachment ' || Ltabfile(i));
          WHEN OTHERS THEN
            RAISE;
        END;
        Lvmessage := Lvcrlf;
        Utl_Smtp.Write_Data(Lvconnection
                           ,Lvmessage);
        -- close the file ...
        Utl_File.Fclose(Lvfilehandle);
      END IF;
    END LOOP;
    -- append the final boundary line ...
    Lvmessage := Lvcrlf || '--DMW.Boundary.605592468--' || Lvcrlf;
    Utl_Smtp.Write_Data(Lvconnection
                       ,Lvmessage);
    -- and close the SMTP connection  ...
    Utl_Smtp.Close_Data(Lvconnection);
    Utl_Smtp.Quit(Lvconnection);
  END Spsendmail;

  FUNCTION Getdato(Ptipo IN VARCHAR2) RETURN VARCHAR2 IS
    Ldato Cg_Ref_Codes.Rv_Meaning%TYPE;
  BEGIN
    SELECT Rv_Meaning
      INTO Ldato
      FROM Cg_Ref_Codes
     WHERE Rv_Domain = 'LISTAS_DE_CORREO'
       AND Rv_Low_Value = 'CARGA_PRODUCTOS_PRECIOS'
       AND Rv_High_Value = Ptipo;
    RETURN Ldato;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END Getdato;

  FUNCTION Enviacorreo(Plocal IN NUMBER
                      ,Pfecha IN DATE) RETURN NUMBER IS
    l_Proceso     VARCHAR2(50) := 'enviaCorreo()';
    l_Msg         VARCHAR2(500) := 'General';
    l_Remitente   VARCHAR2(1000) := Getdato('REMITENTE'); --'ProcesoCargaPrecioslocales@cverde.cl';
    l_Asunto      VARCHAR2(1000) := Getdato('ASUNTO'); --'Error en carga de precios desde locales';
    l_Mensaje     VARCHAR2(1000) := 'Error en la carga de precios local ' || Plocal ||
                                    '. favor conectar al local y ejecutar en forma manual package PKG_PRODUCTOS_OFERTA_ESPECIAL, procedimiento Proc_Productos_Ofertas.';
    l_Concopia    VARCHAR2(1000) := '';
    Ldestinatario VARCHAR2(200) := Getdato('DESTINO'); --'a_castillo@cverde.cl'; --'soporteinternofcv@cverde.cl';
    l_Correos_Env NUMBER := 0;
  BEGIN
    l_Msg := 'Enviar correo a ' || Ldestinatario;
    Spsendmail(Pivsender    => l_Remitente -- quien lo envia
              ,Pivrecipient => Ldestinatario -- destinatario
              ,Pivsubject   => l_Asunto -- asunto
              ,Pivmessage   => l_Mensaje -- cuerpo
              ,Pivcc        => l_Concopia -- cc (pueden ser varios)
              ,Pivattached1 => NULL -- ruta del archivo adjunto
               );
    l_Correos_Env := l_Correos_Env + 1;
    RETURN l_Correos_Env;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Proceso
                                ,p_Msg     => l_Msg || '-' || SQLERRM);
      RETURN l_Correos_Env;
  END Enviacorreo;

  FUNCTION Cuentaobjetos(Cadena IN VARCHAR2
                        ,Psep   IN VARCHAR2) RETURN NUMBER IS
    Cont      NUMBER := 0;
    Cadenaaux VARCHAR2(32767);
  BEGIN
    Cadenaaux := Cadena;
    IF Substr(Cadenaaux
             ,1
             ,1) <> Psep THEN
      Cadenaaux := Psep || Cadenaaux;
    END IF;
    IF Substr(Cadenaaux
             ,Length(Cadenaaux)
             ,1) <> Psep THEN
      Cadenaaux := Cadenaaux || Psep;
    END IF;
    FOR i IN 1 .. Length(Cadenaaux)
    LOOP
      IF Substr(Cadenaaux
               ,i
               ,1) = Psep THEN
        Cont := Cont + 1;
      END IF;
    END LOOP;
    Cont := Cont - 1;
    RETURN Cont;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END Cuentaobjetos;

  FUNCTION Obtieneobjeto(Cadena IN VARCHAR2
                        ,Psep   IN VARCHAR2
                        ,Indice IN NUMBER) RETURN VARCHAR2 IS
    Ini       NUMBER := 0;
    Fin       NUMBER := 0;
    Cadenaaux VARCHAR2(32767) := Cadena;
    Cant      NUMBER := 0;
    Letra     VARCHAR2(1);
    Cont      NUMBER := 0;
    Sepini    NUMBER := Indice;
    Sepfin    NUMBER := Indice + 1;
  BEGIN
    IF Substr(Cadenaaux
             ,1
             ,1) <> Psep THEN
      Cadenaaux := Psep || Cadenaaux;
    END IF;
    IF Substr(Cadenaaux
             ,Length(Cadenaaux)
             ,1) <> Psep THEN
      Cadenaaux := Cadenaaux || Psep;
    END IF;
    FOR i IN 1 .. Length(Cadenaaux)
    LOOP
      BEGIN
        Letra := Substr(Cadenaaux
                       ,i
                       ,1);
        IF Letra = Psep THEN
          Cont := Cont + 1;
          IF Cont = Sepini THEN
            Ini := i + 1;
            EXIT;
          END IF;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
    --
    Cont := 0;
    FOR i IN 1 .. Length(Cadenaaux)
    LOOP
      BEGIN
        Letra := Substr(Cadenaaux
                       ,i
                       ,1);
        IF Letra = Psep THEN
          Cont := Cont + 1;
          IF Cont = Sepfin THEN
            Fin := i;
            EXIT;
          END IF;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
    RETURN(Substr(Cadenaaux
                 ,Ini
                 ,(Fin - Ini)));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END Obtieneobjeto;

  FUNCTION Numero(Pdata IN VARCHAR2) RETURN NUMBER IS
    Aux NUMBER;
  BEGIN
    Aux := To_Number(Pdata);
    RETURN Aux;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END Numero;

  FUNCTION Fecha(Pdata IN VARCHAR2) RETURN DATE IS
    Aux DATE;
  BEGIN
    Aux := To_Date(Pdata
                  ,'yyyymmdd');
    RETURN Aux;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END Fecha;

  FUNCTION Prepararegistros(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion) RETURN Tab_Productos_Oferta IS
    l_Trama_Gg       Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Gg;
    l_Dbg_Proceso    VARCHAR2(100) := 'SCFR_TRX_GNC_UTL2_PK.preparaRegistros';
    l_Dbg_Mensaje    VARCHAR2(250) := 'Error General';
    Lproductosoferta Tab_Productos_Oferta;
    Lsepregistro     VARCHAR2(10);
    Lsepcampo        VARCHAR2(10);
    Ldata            VARCHAR2(32767);
    Lregistro        VARCHAR2(1000);
    Nregs            NUMBER;
    Lcantregistros   NUMBER;
    Lcamposregistro  NUMBER;
    Ncampos          NUMBER;
    Ncorreos         NUMBER;
    Errorcontrolado  EXCEPTION;
  BEGIN
    l_Dbg_Mensaje   := 'Obtener informacion de la trama TX';
    l_Trama_Gg      := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Gg(p_Transaccion.Cuerpo_Tx);
    Lsepregistro    := l_Trama_Gg.Separador_Registro;
    Lsepcampo       := l_Trama_Gg.Separador_Campo;
    Ldata           := l_Trama_Gg.Data;
    Lcantregistros  := To_Number(l_Trama_Gg.Cantidad_De_Registros);
    Lcamposregistro := To_Number(l_Trama_Gg.Campos_Por_Registro);
    Nregs           := Cuentaobjetos(Ldata
                                    ,Lsepregistro);
    Dbms_Output.Put_Line('Regs.  Calculado : ' || Nregs || ' , Huincha : ' || Lcantregistros);
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Regs.  Calculado : ' || Nregs || ' , Huincha : ' || Lcantregistros);
    l_Dbg_Mensaje := 'Validar huincha de Registros';
    IF Nregs = Lcantregistros THEN
      FOR i IN 1 .. Nregs
      LOOP
        BEGIN
          IF (Ltrim(Rtrim(Upper(p_Transaccion.Trama_Boc.String_Identificacion))) = 'PROMO500') THEN
            Lregistro := Obtieneobjeto(Ldata
                                      ,Lsepregistro
                                      ,i);
            Ncampos   := Cuentaobjetos(Lregistro
                                      ,Lsepcampo);
            Dbms_Output.Put_Line('Campos.  Calculado : ' || Ncampos || ' , Huincha : ' || Lcamposregistro);
            Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                      ,p_Msg     => 'Campos.  Calculado : ' || Nregs || ' , Huincha : ' || Lcamposregistro);
            l_Dbg_Mensaje := 'Validar huincha de Campos';
            IF Ncampos = Lcamposregistro THEN
              Lproductosoferta(i).Local := Numero(Obtieneobjeto(Lregistro
                                                               ,Lsepcampo
                                                               ,1));
              Lproductosoferta(i).Cadena := Numero(Obtieneobjeto(Lregistro
                                                                ,Lsepcampo
                                                                ,2));
              Lproductosoferta(i).Fecha := Fecha(Obtieneobjeto(Lregistro
                                                              ,Lsepcampo
                                                              ,3));
              Lproductosoferta(i).Producto := Numero(Obtieneobjeto(Lregistro
                                                                  ,Lsepcampo
                                                                  ,4));
              Lproductosoferta(i).Precio := Numero(Obtieneobjeto(Lregistro
                                                                ,Lsepcampo
                                                                ,5));
              Lproductosoferta(i).Fechaact := Fecha(Obtieneobjeto(Lregistro
                                                                 ,Lsepcampo
                                                                 ,6));
            ELSE
              Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                        ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
              Ncorreos := Enviacorreo(p_Transaccion.Trama_Pos.Local
                                     ,SYSDATE);
              EXIT;
            END IF;
          END IF;
        EXCEPTION
          WHEN Errorcontrolado THEN
            EXIT;
          WHEN OTHERS THEN
            Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                      ,p_Msg     => 'Problemas al cargar el registro ' || i || ' en el registro. ' || SQLERRM);
            Ncorreos := Enviacorreo(p_Transaccion.Trama_Pos.Local
                                   ,SYSDATE);
            EXIT;
        END;
      END LOOP;
    ELSE
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      Ncorreos := Enviacorreo(p_Transaccion.Trama_Pos.Local
                             ,SYSDATE);
      RAISE Errorcontrolado;
    END IF;
    RETURN Lproductosoferta;
  EXCEPTION
    WHEN Errorcontrolado THEN
      RETURN Lproductosoferta;
    WHEN OTHERS THEN
      RETURN Lproductosoferta;
  END Prepararegistros;

  PROCEDURE Gncu09(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Dbg_Proceso    VARCHAR2(100) := 'SCFR_TRX_GNC_UTL2_PK.gncu09';
    l_Dbg_Mensaje    VARCHAR2(250) := 'Error General';
    Lproductosoferta Tab_Productos_Oferta;
    Lerrores         NUMBER := 0;
    Lcorreos         NUMBER := 0;
  BEGIN
    IF (Ltrim(Rtrim(Upper(p_Transaccion.Trama_Boc.String_Identificacion))) = 'PROMO500') THEN
      IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                       ,'GG') THEN
        Lproductosoferta := Prepararegistros(p_Transaccion);
        FOR i IN 1 .. Lproductosoferta.Count
        LOOP
          BEGIN
            l_Dbg_Mensaje := 'Insertar en tabla SCFR_PRODUCTOS_OFERTA';
            INSERT INTO Scfr_Productos_Oferta
              (Loc_Local
              ,Cad_Cadena
              ,Fecha
              ,Pro_Codigo_Interno
              ,Precio
              ,Fecha_Actualizacion)
            VALUES
              (Lproductosoferta(i).Local
              ,Lproductosoferta(i).Cadena
              ,Lproductosoferta(i).Fecha
              ,Lproductosoferta(i).Producto
              ,Lproductosoferta(i).Precio
              ,Lproductosoferta(i).Fechaact);
          EXCEPTION
            WHEN Dup_Val_On_Index THEN
              NULL;
            WHEN OTHERS THEN
              Dbms_Output.Put_Line('Error al insertar Reg. ' || i || '.  ' || SQLERRM);
              Lerrores := Lerrores + 1;
          END;
        END LOOP;
      ELSE
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => 'Trama GG no encontrada');
      END IF;
      IF Lerrores > 0 THEN
        Lcorreos := Enviacorreo(p_Transaccion.Trama_Pos.Local
                               ,SYSDATE);
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
        Lcorreos    := Enviacorreo(p_Transaccion.Trama_Pos.Local
                                  ,SYSDATE);
      END IF;
  END Gncu09;

  FUNCTION Version_Pkg RETURN VARCHAR2 AS
  BEGIN
    RETURN Vversion;
  END;

  -- Implementacion de procedimientos privados del package
  -- function : devuelve_dias
  --    in :
  --       p_producto : Codigo del Producto
  --       p_dosis    : Dosis indicada en la receta
  --       p_veces    : Veces indicadas en la receta
  --       p_dias     : Dias indicados en la receta
  --    Desc :
  --       Determina la cantidad Total del producto
  --       para la posologia dada
  FUNCTION Devuelve_Dias(p_Producto IN NUMBER
                        ,p_Dosis    IN NUMBER
                        ,p_Veces    IN NUMBER
                        ,p_Cantidad IN NUMBER) RETURN NUMBER IS
    l_Dias_Solicitados      NUMBER;
    l_Dias_Tratamiento      NUMBER;
    l_Envases               NUMBER;
    l_Retorno               VARCHAR2(1000);
    l_Error_c               VARCHAR2(1000);
    l_Msg_Error             VARCHAR2(1000);
    l_Cantidad_Ff           Scfr_Productos_v.Cantidad_Ff%TYPE;
    l_Tipo_Dias_Tratamiento Scfr_Productos_v.Tipo_Dias_Tratamiento%TYPE;
    l_Compra_Max_Tto        NUMBER;
    l_Dias                  NUMBER;
    l_Dias_Tratamiento_p    NUMBER;
  BEGIN
    -- Transformar dosis/veces/dias a cantidades
    BEGIN
      SELECT Cantidad_Pills
            ,Nvl(Tipo_Dias_Tratamiento
                ,'CAL')
            ,Dias_Tratamiento
        INTO l_Cantidad_Ff
            ,l_Tipo_Dias_Tratamiento
            ,l_Dias_Tratamiento_p
        FROM Scfr_Productos_v
       WHERE Codigo = p_Producto;
    EXCEPTION
      WHEN OTHERS THEN
        l_Cantidad_Ff           := 0;
        l_Tipo_Dias_Tratamiento := NULL;
        l_Dias_Tratamiento      := 0;
    END;
    Scfr_Posologia_Pk.Calc_Dias_Tto(p_Tipo_Calculo_Dias_Tto => l_Tipo_Dias_Tratamiento -- IN VARCHAR2
                                   ,p_Dosis                 => p_Dosis -- IN NUMBER
                                   ,p_Veces                 => p_Veces -- IN NUMBER
                                   ,p_Dias                  => NULL -- IN NUMBER
                                   ,p_Cantidad              => p_Cantidad -- IN NUMBER
                                   ,p_Dias_Tto_Maestro      => NULL --l_dias_tratamiento_p                    -- IN NUMBER
                                   ,p_Cantidad_Envase       => l_Cantidad_Ff -- IN NUMBER
                                   ,p_Factor                => 1 -- IN NUMBER
                                   ,p_Codigo_Autorizacion   => -1 -- IN NUMBER
                                   ,p_Codigo_Prod           => p_Producto -- IN NUMBER
                                   ,p_Compra_Max_Tto        => -1 --l_compra_max_tto                        -- IN NUMBER
                                   ,x_Dias_Solicitados      => l_Dias_Solicitados -- OUT NUMBER
                                   ,x_Dias_Tratamiento      => l_Dias_Tratamiento -- OUT NUMBER
                                   ,x_Cantidad_Envases      => l_Envases -- OUT NUMBER
                                   ,x_Retorno               => l_Retorno -- OUT VARCHAR2
                                   ,x_Error                 => l_Error_c -- OUT VARCHAR2
                                   ,x_Msg_Error             => l_Msg_Error -- OUT VARCHAR2
                                    );
    l_Dias := Nvl(l_Dias_Tratamiento
                 ,0);
    RETURN l_Dias;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END Devuelve_Dias;

  FUNCTION Obtiene_Mov_Hijo(p_Trama_Dr IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dr) RETURN VARCHAR2 IS
    l_Itm          NUMBER;
    l_Valor_Recaud VARCHAR2(100) := NULL;
  BEGIN
    FOR l_Itm IN 1 .. p_Trama_Dr.Subtrama_Dr1.Count
    LOOP
      IF (p_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Movimiento_Hijo != 'RECRMA' AND p_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Movimiento_Hijo != 'VENDIC' AND p_Trama_Dr.Subtrama_Dr1(l_Itm)
         .Tipo_Movimiento_Hijo != 'RECPIN' AND p_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Movimiento_Hijo != 'VENCID' AND p_Trama_Dr.Subtrama_Dr1(l_Itm)
         .Tipo_Movimiento_Hijo != 'VENEXC') THEN
        l_Valor_Recaud := p_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Movimiento_Hijo;
        RETURN l_Valor_Recaud;
      END IF;
    END LOOP;
    IF l_Valor_Recaud IS NULL THEN
      RETURN NULL;
    END IF;
  END Obtiene_Mov_Hijo;

  FUNCTION Retorna_Puntos_Canjeados(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion) RETURN NUMBER IS
    l_Trama_Pm       Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm;
    l_Ptos_Canjeados NUMBER;
  BEGIN
    l_Trama_Pm := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Pm(p_Transaccion.Trama_Pos
                                                    ,p_Transaccion.Cuerpo_Tx);
    FOR l_Itm IN 1 .. l_Trama_Pm.Count
    LOOP
      FOR l_Itm2 IN 1 .. l_Trama_Pm(l_Itm).Subtrama_Pm2.Count
      LOOP
        l_Ptos_Canjeados := l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Puntos_Canjeados + l_Ptos_Canjeados;
      END LOOP;
    END LOOP;
    RETURN l_Ptos_Canjeados;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  FUNCTION Prepara_Convenios(p_Datos IN Tab_Prods_Tratamiento) RETURN Tab_Convenios IS
    p_Convenios   Tab_Convenios;
    l_Indice      NUMBER := 2;
    l_Existe      VARCHAR2(2);
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.prepara_convenios()';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
  BEGIN
    p_Convenios(1).Convenio := p_Datos(1).Convenio;
    p_Convenios(1).Plan := p_Datos(1).Plan;
    FOR l_Itm IN 2 .. p_Datos.Count
    LOOP
      BEGIN
        l_Existe := 'NO';
        FOR l_Ind IN 1 .. p_Convenios.Count
        LOOP
          IF p_Convenios(l_Ind).Convenio = p_Datos(l_Itm).Convenio AND
             p_Convenios(l_Ind).Plan = p_Datos(l_Itm).Plan THEN
            l_Existe := 'SI';
            EXIT;
          END IF;
        END LOOP;
        IF l_Existe = 'NO' THEN
          p_Convenios(l_Indice).Convenio := p_Datos(l_Itm).Convenio;
          p_Convenios(l_Indice).Plan := p_Datos(l_Itm).Plan;
          l_Indice := l_Indice + 1;
        END IF;
        --
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
    RETURN p_Convenios;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      RETURN p_Convenios;
  END Prepara_Convenios;

  FUNCTION Devuelve_Productos_Trat(p_Datos    IN Tab_Prods_Tratamiento
                                  ,p_Convenio IN NUMBER
                                  ,Plan       IN NUMBER) RETURN Tab_Productos_Trat IS
    l_Ind         NUMBER;
    p_Productos   Tab_Productos_Trat;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.devuelve_productos_trat()';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
  BEGIN
    l_Ind := 0;
    FOR l_Itm IN 1 .. p_Datos.Count
    LOOP
      IF p_Datos(l_Itm).Convenio = p_Convenio AND
         p_Datos(l_Itm).Plan = Plan THEN
        l_Ind := l_Ind + 1;
        p_Productos(l_Ind).Producto := p_Datos(l_Itm).Producto;
        p_Productos(l_Ind).Dias := p_Datos(l_Itm).Dias;
        p_Productos(l_Ind).Inicio := p_Datos(l_Itm).Inicio;
        p_Productos(l_Ind).Termino := p_Datos(l_Itm).Termino;
        p_Productos(l_Ind).Local := p_Datos(l_Itm).Local;
        p_Productos(l_Ind).Fecha_Compra := p_Datos(l_Itm).Fecha_Compra;
      END IF;
    END LOOP;
    RETURN p_Productos;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      RETURN p_Productos;
  END Devuelve_Productos_Trat;

  FUNCTION Trama_Tm_Prepara(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tm IS
    l_Trama_Tm         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tm;
    l_Itm              NUMBER;
    l_Itm1             NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.trama_tm_prepara()';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    p_Datos            Tab_Prods_Tratamiento;
    p_Convenios        Tab_Convenios;
    p_Productos        Tab_Productos_Trat;
    l_Rut              NUMBER;
    l_Dv_Rut           VARCHAR2(1);
    l_Rut_Completo     VARCHAR2(20);
    l_Cant_Prd_Trat    NUMBER;
    l_Error            VARCHAR2(100);
    l_Msg_Error        VARCHAR2(1000);
    l_Resultado        NUMBER;
    l_Error_Controlado EXCEPTION;
  BEGIN
    -- LLamar a Convenios que devuelve p_datos  tab_prods_tratamiento
    l_Dbg_Mensaje := 'Obtener el Rut consultado a partir de la trama BOC';
    l_Resultado   := Scfr_Trx_Fid_Pk.Determinar_Party_Id(p_Transaccion.Trama_Boc.Forma_Identificacion
                                                        ,p_Transaccion.Trama_Boc.String_Identificacion
                                                        ,p_Transaccion.Trama_Pos.Empresa
                                                        ,p_Transaccion.Trama_Pos.Cadena
                                                        ,p_Transaccion.Trama_Boc.Party_Id);
    IF l_Resultado != 0 THEN
      Raise_Application_Error(-20000
                             ,'Error:' || Abs(l_Resultado) || ' - No se pudo encontrar el cliente para forma ID=' ||
                              p_Transaccion.Trama_Boc.Forma_Identificacion || ' y String ID=' ||
                              Ltrim(Rtrim(p_Transaccion.Trama_Boc.String_Identificacion)));
    END IF;
    Scfr_Trx_Util_Pk.Obtiene_Rut(p_Transaccion.Trama_Boc.Party_Id
                                ,l_Rut
                                ,l_Dv_Rut);
    l_Dbg_Mensaje := 'Obtener Productos en Tratamiento';
    Scfr_Posologia_Pk.Tratamiento_Beneficiario(p_Empresa       => Scfr_Conv_Pk.Entrega_Codigo_Empresa(p_Transaccion.Trama_Pos.Empresa)
                                              ,p_Rut_Benef     => Nvl(l_Rut
                                                                     ,0)
                                              ,x_Cant_Prd_Trat => l_Cant_Prd_Trat
                                              ,x_Tratamiento   => p_Datos
                                              ,x_Error         => l_Error
                                              ,x_Msg_Error     => l_Msg_Error);
    IF Ltrim(Rtrim(l_Error)) <> '0' THEN
      RAISE l_Error_Controlado;
    END IF;
    l_Dbg_Mensaje := 'Preparar arreglo con Convenios en Tratamiento';
    p_Convenios   := Prepara_Convenios(p_Datos);
    l_Dbg_Mensaje := 'Recorrer convenios en tratamiento';
    FOR l_Itm IN 1 .. p_Convenios.Count
    LOOP
      BEGIN
        l_Trama_Tm(l_Itm).Convenio := p_Convenios(l_Itm).Convenio;
        l_Trama_Tm(l_Itm).Plan := p_Convenios(l_Itm).Plan;
        p_Productos := Devuelve_Productos_Trat(p_Datos
                                              ,p_Convenios(l_Itm).Convenio
                                              ,p_Convenios(l_Itm).Plan);
        l_Dbg_Mensaje := 'Recorrer Productos en tratamiento para convenio ' || p_Convenios(l_Itm).Convenio || ' plan ' || p_Convenios(l_Itm).Plan;
        FOR l_Itm1 IN 1 .. p_Productos.Count
        LOOP
          BEGIN
            l_Trama_Tm(l_Itm).Subtrama_Tm1(l_Itm1).Codigo_Producto := p_Productos(l_Itm1).Producto;
            l_Trama_Tm(l_Itm).Subtrama_Tm1(l_Itm1).Dias_Autorizados := p_Productos(l_Itm1).Dias;
            l_Trama_Tm(l_Itm).Subtrama_Tm1(l_Itm1).Fecha_Inicio := To_Number(To_Char(p_Productos(l_Itm1).Inicio
                                                                                    ,'yyyymmdd'));
            l_Trama_Tm(l_Itm).Subtrama_Tm1(l_Itm1).Fecha_Termino := To_Number(To_Char(p_Productos(l_Itm1).Termino
                                                                                     ,'yyyymmdd'));
            l_Trama_Tm(l_Itm).Subtrama_Tm1(l_Itm1).Local := p_Productos(l_Itm1).Local;
            l_Trama_Tm(l_Itm).Subtrama_Tm1(l_Itm1).Fecha_Compra := To_Number(To_Char(p_Productos(l_Itm1).Fecha_Compra
                                                                                    ,'yyyymmdd'));
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
        END LOOP;
        l_Trama_Tm(l_Itm).Lista_Productos := l_Trama_Tm(l_Itm).Subtrama_Tm1.Count;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
    RETURN l_Trama_Tm;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
      RETURN l_Trama_Tm;
  END Trama_Tm_Prepara;

  FUNCTION Obtiene_Party_Paciente(p_Codigo_Empresa      IN NUMBER
                                 ,p_Codigo_Autorizacion IN VARCHAR2) RETURN NUMBER IS
    l_Party NUMBER;
  BEGIN
    BEGIN
      SELECT Pt_Party_Id_Benef
        INTO l_Party
        FROM Scfr_Detalle_Consumos
       WHERE Emp_Codigo = p_Codigo_Empresa
         AND Codigo_Autorizacion = p_Codigo_Autorizacion
         AND Numero_Linea = 0;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Party := 0;
      WHEN OTHERS THEN
        l_Party := 0;
    END;
    RETURN l_Party;
  END;

  PROCEDURE Establece_Fecha_Termino(p_Id_Receta IN NUMBER) IS
    CURSOR Productos IS
      SELECT Producto
            ,Dosis
            ,Veces
            ,Dias
            ,Cantidad
        FROM Scfr_Rec_Productos
       WHERE Rec_Id_Receta = p_Id_Receta;
    l_Dias        NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.establece_fecha_termino()';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Max         NUMBER := 0;
  BEGIN
    l_Dbg_Mensaje := 'Obtener Dias maximos de la receta';
    FOR Fila IN Productos
    LOOP
      BEGIN
        IF Fila.Dias > 0 THEN
          l_Dias := Fila.Dias;
        ELSE
          l_Dias := Scfr_Trx_Gnc_Utl_Pk.Devuelve_Dias(p_Producto => Fila.Producto
                                                     ,p_Dosis    => Fila.Dosis
                                                     ,p_Veces    => Fila.Veces
                                                     ,p_Cantidad => Fila.Cantidad);
        END IF;
        IF l_Dias > l_Max THEN
          l_Max := l_Dias;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
    l_Dias        := l_Max;
    l_Dbg_Mensaje := 'Actualizar Fecha Termino de la Receta';
    UPDATE Scfr_Rec_Recetas SET Fecha_Termino = Fecha_Ingreso + l_Dias WHERE Id_Receta = p_Id_Receta;
    IF SQL%NOTFOUND THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
  END Establece_Fecha_Termino;

  FUNCTION Devuelve_Encabezado_Receta(p_Id_Receta IN NUMBER) RETURN Reg_Enc_Receta IS
    l_Encabezado Reg_Enc_Receta;
  BEGIN
    SELECT Id_Receta
          ,Secuencia_Receta
          ,Fecha_Emision
          ,Folio_Receta
          ,Con_Copia
          ,Fecha_Ingreso
          ,Diagnostico
          ,Rut_Cliente
          ,Dv_Cliente
          ,Rut_Paciente
          ,Dv_Paciente
          ,Nombre_Paciente
          ,Fono_Paciente
          ,Rut_Medico
          ,Dv_Medico
          ,Nombre_Medico
          ,Serie
          ,Convenio
          ,Plan
          ,Tipo_Medicamento
          ,Estado_Receta
          ,Rut_Institucion
          ,Dv_Institucion
      INTO l_Encabezado.Id_Receta
          ,l_Encabezado.Secuencia_Receta
          ,l_Encabezado.Fecha_Emision
          ,l_Encabezado.Folio_Receta
          ,l_Encabezado.Con_Copia
          ,l_Encabezado.Fecha_Ingreso
          ,l_Encabezado.Diagnostico
          ,l_Encabezado.Rut_Cliente
          ,l_Encabezado.Dv_Cliente
          ,l_Encabezado.Rut_Paciente
          ,l_Encabezado.Dv_Paciente
          ,l_Encabezado.Nombre_Paciente
          ,l_Encabezado.Fono_Paciente
          ,l_Encabezado.Rut_Medico
          ,l_Encabezado.Dv_Medico
          ,l_Encabezado.Nombre_Medico
          ,l_Encabezado.Serie
          ,l_Encabezado.Convenio
          ,l_Encabezado.Plan
          ,l_Encabezado.Tipo_Medicamento
          ,l_Encabezado.Estado_Receta
          ,l_Encabezado.Rut_Institucion
          ,l_Encabezado.Dv_Institucion
      FROM Scfr_Rec_Recetas
     WHERE Id_Receta = p_Id_Receta;
    RETURN l_Encabezado;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_Encabezado;
  END Devuelve_Encabezado_Receta;

  FUNCTION Devuelve_Detalle_Producto(p_Id_Receta IN NUMBER
                                    ,p_Producto  IN NUMBER) RETURN Reg_Det_Producto IS
    l_Detalle Reg_Det_Producto;
  BEGIN
    SELECT Producto
          ,Dosis
          ,Veces
          ,Dias
          ,Cantidad
          ,Forma_Farmaceutica
          ,Texto
          ,Id_Detalle
          ,Inscribir_Refill
          ,Rec_Id_Receta
      INTO l_Detalle.Producto
          ,l_Detalle.Dosis
          ,l_Detalle.Veces
          ,l_Detalle.Dias
          ,l_Detalle.Cantidad
          ,l_Detalle.Forma_Farmaceutica
          ,l_Detalle.Texto
          ,l_Detalle.Id_Detalle
          ,l_Detalle.Inscribir_Refill
          ,l_Detalle.Rec_Id_Receta
      FROM Scfr_Rec_Productos
     WHERE Producto = p_Producto
       AND Rec_Id_Receta = p_Id_Receta;
    RETURN l_Detalle;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_Detalle;
  END Devuelve_Detalle_Producto;

  FUNCTION Devuelve_Recetas_Pm(p_Trama_Pm IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm) RETURN Scfr_Trx_Gnc_Utl_Pk.Tab_Movimientos IS
    l_Movimientos Scfr_Trx_Gnc_Utl_Pk.Tab_Movimientos;
    l_Mov         NUMBER;
    l_Existe      VARCHAR2(2);
  BEGIN
    l_Mov := 1;
    FOR l_Itm IN 1 .. p_Trama_Pm.Count
    LOOP
      IF Nvl(p_Trama_Pm(l_Itm).Secuencia_Receta_Relacionada
            ,0) <> 0 THEN
        l_Existe := 'NO';
        FOR Indice IN 1 .. l_Movimientos.Count
        LOOP
          IF l_Movimientos(Indice).Secuencia_Receta = p_Trama_Pm(l_Itm).Secuencia_Receta_Relacionada THEN
            l_Existe := 'SI';
          END IF;
        END LOOP;
        IF l_Existe = 'NO' THEN
          l_Movimientos(l_Mov).Secuencia_Receta := p_Trama_Pm(l_Itm).Secuencia_Receta_Relacionada;
          l_Mov := l_Mov + 1;
        END IF;
      END IF;
    END LOOP;
    RETURN l_Movimientos;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_Movimientos;
  END Devuelve_Recetas_Pm;

  FUNCTION Devuelve_Vendedor(p_Codigo_Tx IN NUMBER) RETURN VARCHAR2 IS
    l_Rut_Cajero    VARCHAR2(10);
    l_Dv_Cajero     VARCHAR2(1);
    l_Nombre_Cajero VARCHAR2(100);
  BEGIN
    SELECT DISTINCT Ltrim(To_Char(Mp.Per_Rut_Cajero))
                   ,Mp.Per_Dv_Cajero
      INTO l_Rut_Cajero
          ,l_Dv_Cajero
      FROM Scfr_Mov_Pagos              Mp
          ,Scfr_Mov_Transacciones_Pago Tp
     WHERE Mp.Mov_Pagos = Tp.Mpa_Mov_Pagos
       AND Tp.Txo_Codigo_Tx = p_Codigo_Tx;
    SELECT Party_Name INTO l_Nombre_Cajero FROM Hz_Parties WHERE Jgzz_Fiscal_Code = l_Rut_Cajero;
    RETURN Substr(l_Rut_Cajero || '-' || l_Dv_Cajero || ' ; ' || l_Nombre_Cajero
                 ,1
                 ,100);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'S/D';
  END Devuelve_Vendedor;

  PROCEDURE Listado_Receta(p_Receta         IN NUMBER
                          ,x_Cartola_Enc    IN OUT Reg_Encabezado_Cartola
                          ,x_Cartola        IN OUT Tab_Cartola
                          ,x_Cartola_Saldos IN OUT Tab_Saldos_Cartola
                          ,x_Ret            OUT NUMBER
                          ,x_Msg            OUT VARCHAR2) IS
    CURSOR Data IS
      SELECT m.Fecha Fecha
            ,Decode(Tipo_Movimiento
                   ,'REG'
                   ,'Inscripcion'
                   ,'RET'
                   ,'Retiro Parcial'
                   ,'REV'
                   ,'Reversa de Boleta') Concepto
            ,m.Txo_Codigo_Tx Venta_Relacionada
            ,m.Local LOCAL
            ,Mp.Producto Producto
            ,p.Descripcion_Corta || ' - Boleta. ' || Mp.Boleta Desc_Producto
            ,Decode(m.Tipo_Movimiento
                   ,'REG'
                   ,Mp.Cant_Uni_Venta
                   ,'REV'
                   ,Mp.Cant_Uni_Venta
                   ,0) Abono
            ,Decode(m.Tipo_Movimiento
                   ,'RET'
                   ,Mp.Cant_Uni_Venta
                   ,0) Cargo
            ,(SELECT SUM(Decode(Mov.Tipo_Movimiento
                               ,'REG'
                               ,Movp.Cant_Uni_Venta
                               ,'REV'
                               ,Movp.Cant_Uni_Venta
                               ,0))
                FROM Scfr_Rec_Movimientos   Mov
                    ,Scfr_Rec_Mov_Productos Movp
               WHERE Movp.Cce_Id_Movimiento = Mov.Id_Movimiento
                 AND Mov.Rec_Id_Receta = m.Rec_Id_Receta
                 AND Movp.Id_Detalle <= Mp.Id_Detalle
                 AND Movp.Producto = Mp.Producto) - (SELECT SUM(Decode(Mov.Tipo_Movimiento
                                                                      ,'RET'
                                                                      ,Movp.Cant_Uni_Venta
                                                                      ,0))
                                                       FROM Scfr_Rec_Movimientos   Mov
                                                           ,Scfr_Rec_Mov_Productos Movp
                                                      WHERE Movp.Cce_Id_Movimiento = Mov.Id_Movimiento
                                                        AND Mov.Rec_Id_Receta = m.Rec_Id_Receta
                                                        AND Movp.Id_Detalle <= Mp.Id_Detalle
                                                        AND Movp.Producto = Mp.Producto) Saldo
        FROM Scfr_Rec_Movimientos   m
            ,Scfr_Rec_Mov_Productos Mp
            ,Scfr_Productos_v       p
       WHERE Mp.Cce_Id_Movimiento = m.Id_Movimiento
         AND Mp.Producto = p.Codigo
         AND m.Rec_Id_Receta = p_Receta
       ORDER BY m.Id_Movimiento
               ,Mp.Id_Detalle;
    l_Itm      NUMBER;
    l_Itm_Prod NUMBER;
    l_Ajustado VARCHAR2(2);
  BEGIN
    -- Prepara el Encabezado de la Receta
    BEGIN
      SELECT Id_Receta
            ,Rut_Paciente
            ,Dv_Paciente
            ,Nombre_Paciente
            ,Diagnostico
            ,Fecha_Emision
            ,Convenio
            ,Plan
            ,Rut_Medico
            ,Dv_Medico
            ,Nombre_Medico
            ,Estado_Receta
        INTO x_Cartola_Enc.Id_Receta
            ,x_Cartola_Enc.Rut_Paciente
            ,x_Cartola_Enc.Dv_Paciente
            ,x_Cartola_Enc.Nombre_Paciente
            ,x_Cartola_Enc.Diagnostico
            ,x_Cartola_Enc.Fecha_Emision
            ,x_Cartola_Enc.Convenio
            ,x_Cartola_Enc.Plan
            ,x_Cartola_Enc.Rut_Medico
            ,x_Cartola_Enc.Dv_Medico
            ,x_Cartola_Enc.Nombre_Medico
            ,x_Cartola_Enc.Estado_Receta
        FROM Scfr_Rec_Recetas
       WHERE Id_Receta = p_Receta;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    -- Prepara el Detalle de la Cartola
    l_Itm      := 0;
    l_Itm_Prod := 0;
    FOR Fila IN Data
    LOOP
      l_Ajustado := 'NO';
      l_Itm := l_Itm + 1;
      x_Cartola(l_Itm).Fecha := Fila.Fecha;
      x_Cartola(l_Itm).Concepto := Fila.Concepto;
      x_Cartola(l_Itm).Venta_Relacionada := Fila.Venta_Relacionada;
      x_Cartola(l_Itm).Local := Fila.Local;
      x_Cartola(l_Itm).Vendedor := Devuelve_Vendedor(Fila.Venta_Relacionada);
      x_Cartola(l_Itm).Producto := Fila.Producto;
      x_Cartola(l_Itm).Desc_Producto := Fila.Desc_Producto;
      x_Cartola(l_Itm).Abono := Fila.Abono;
      x_Cartola(l_Itm).Cargo := Fila.Cargo;
      x_Cartola(l_Itm).Saldo := Fila.Saldo;
      -- Actualiza saldo por producto
      FOR l_Indice IN 1 .. x_Cartola_Saldos.Count
      LOOP
        IF x_Cartola_Saldos(l_Indice).Producto = Fila.Producto THEN
          x_Cartola_Saldos(l_Indice).Saldo := Fila.Saldo;
          l_Ajustado := 'SI';
        END IF;
      END LOOP;
      IF l_Ajustado = 'NO' THEN
        l_Itm_Prod := l_Itm_Prod + 1;
        x_Cartola_Saldos(l_Itm_Prod).Producto := Fila.Producto;
        x_Cartola_Saldos(l_Itm_Prod).Saldo := Fila.Saldo;
      END IF;
    END LOOP;
    x_Ret := 0;
    x_Msg := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      x_Ret := -1;
      x_Msg := SQLERRM;
  END Listado_Receta;

  -- procedure : setea_estado_receta
  --    in :
  --       p_receta : Id unico de la receta (en central)
  --    out :
  --       x_cod_error : 0 - Ejecucion sin errores
  --       x_msg_error : Mensaje de error si corresponde
  --    Desc :
  --       Recorre los productos asociados a la receta p_receta
  --       si hay al menos un producto con cantidad pendientes
  --       entonces la receta queda ABIerta, en caso contrario CERrada
  PROCEDURE Setea_Estado_Receta(p_Receta    IN NUMBER
                               ,x_Cod_Error OUT NUMBER
                               ,x_Msg_Error OUT VARCHAR2) IS
    CURSOR Productos IS
      SELECT Producto FROM Scfr_Rec_Productos WHERE Rec_Id_Receta = p_Receta;
    l_Estado             Scfr_Rec_Recetas.Estado_Receta%TYPE;
    l_Cantidad_Pendiente NUMBER;
    l_Total_Pendientes   NUMBER;
    l_Reversas           NUMBER;
    l_Retiros            NUMBER;
    l_Dbg_Proceso        VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.setea_estado_receta()';
    l_Dbg_Mensaje        VARCHAR2(250) := 'Error General';
  BEGIN
    l_Dbg_Mensaje := 'Obtener la cantidad de movimientos de Reversa de la receta';
    BEGIN
      SELECT COUNT(*)
        INTO l_Reversas
        FROM Scfr_Rec_Movimientos
       WHERE Rec_Id_Receta = p_Receta
         AND Tipo_Movimiento = 'REV';
    EXCEPTION
      WHEN OTHERS THEN
        l_Reversas := 0;
    END;
    l_Dbg_Mensaje := 'Obtener la cantidad de movimientos de Retiros de la receta';
    BEGIN
      SELECT COUNT(*)
        INTO l_Retiros
        FROM Scfr_Rec_Movimientos
       WHERE Rec_Id_Receta = p_Receta
         AND Tipo_Movimiento = 'RET';
    EXCEPTION
      WHEN OTHERS THEN
        l_Retiros := 0;
    END;
    IF l_Retiros = 1 AND
       l_Reversas = 1 THEN
      -- 1 REG 1 RET 1 REV (se anula la primera y unica venta/despacho)
      l_Estado := 'ANU';
    ELSE
      l_Total_Pendientes := 0;
      l_Dbg_Mensaje      := 'Recorrer los productos asociados a la receta';
      FOR Prods IN Productos
      LOOP
        BEGIN
          SELECT SUM(Decode(Mov.Tipo_Movimiento
                           ,'REG'
                           ,1
                           ,'RET'
                           ,-1
                           ,'REV'
                           ,1) * Det.Cant_Uni_Venta)
            INTO l_Cantidad_Pendiente
            FROM Scfr_Rec_Movimientos   Mov
                ,Scfr_Rec_Mov_Productos Det
           WHERE Mov.Id_Movimiento = Det.Cce_Id_Movimiento
             AND Det.Producto = Prods.Producto
             AND Mov.Rec_Id_Receta = p_Receta;
          l_Total_Pendientes := l_Total_Pendientes + l_Cantidad_Pendiente;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END LOOP;
      IF l_Total_Pendientes > 0 THEN
        l_Estado := 'ABI';
      ELSE
        l_Estado := 'CER';
      END IF;
    END IF;
    l_Dbg_Mensaje := 'Actualizar el estado de la receta';
    UPDATE Scfr_Rec_Recetas SET Estado_Receta = l_Estado WHERE Id_Receta = p_Receta;
    IF SQL%NOTFOUND THEN
      x_Cod_Error := -2;
      x_Msg_Error := 'Id => ' || p_Receta || ' estado "' || l_Estado || '"';
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - ' || x_Msg_Error);
    END IF;
    x_Cod_Error := 0;
    x_Msg_Error := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := -1;
      x_Msg_Error := SQLERRM;
  END Setea_Estado_Receta;

  -- function : autoriza_producto_receta
  --    in :
  --       p_convenio : Convenio asociado
  --       p_plan     : Plan asociado
  --       p_producto : Producto a autorizar
  --    Desc :
  --       Evalua si el producto se encuentra en una receta ABIerta
  --       de ser asi no se autoriza su uso
  FUNCTION Autoriza_Producto_Receta(p_Rut          IN NUMBER
                                   ,p_Convenio     IN NUMBER DEFAULT NULL
                                   ,p_Plan         IN NUMBER DEFAULT NULL
                                   ,p_Producto     IN NUMBER
                                   ,p_Receta_Nueva IN VARCHAR2
                                   ,p_Id_Receta    IN NUMBER DEFAULT NULL) RETURN VARCHAR2 IS
    l_Autorizado         VARCHAR2(2) := 'SI';
    l_Id_Receta          Scfr_Rec_Recetas.Id_Receta%TYPE;
    l_Cantidad_Pendiente NUMBER;
    l_Dbg_Proceso        VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.autoriza_producto_receta()';
    l_Dbg_Mensaje        VARCHAR2(250) := 'Error General';
  BEGIN
    IF p_Receta_Nueva = 'SI' THEN
      l_Autorizado := 'SI';
      /*
      begin
        l_DBG_MENSAJE := 'Determinar (para una receta nueva) si el producto ' || p_producto || ' esta en otra receta';
        select  r.id_receta , 'NO'
          into l_id_receta , l_autorizado
          from scfr_rec_recetas   r
             , scfr_rec_productos p
         where r.id_receta     = p.rec_id_receta
           and r.convenio      = nvl( p_convenio , 0 )
           and r.plan          = nvl( p_plan , 0 )
           and r.rut_paciente  = p_rut
           and p.producto      = p_producto
           and r.estado_receta = 'ABI';

        if l_autorizado = 'NO' then
          begin
            l_DBG_MENSAJE := 'Determinar si el producto ' || p_producto || ' de la receta ' || p_id_receta || ' tiene unidades pendientes';
            select sum( decode( mov.tipo_movimiento , 'REG' , 1 , 'RET' , -1 , 'REV' , 1 ) * det.cant_uni_venta )
              into l_cantidad_pendiente
              from scfr_rec_movimientos   mov
                 , scfr_rec_mov_productos det
             where mov.id_movimiento = det.cce_id_movimiento
               and det.producto      = p_producto
               and mov.rec_id_receta = l_id_receta;
          exception
            when others then
              l_cantidad_pendiente := 0;
          end;
          if l_cantidad_pendiente = 0 then
            l_autorizado := 'SI';
          end if;
        end if;
      exception
        when no_data_found then
          l_autorizado := 'SI';
        when others then
          l_autorizado := 'NO';
      end;
      */
    ELSIF p_Receta_Nueva = 'NO' THEN
      -- Autorizar en un retiro
      BEGIN
        l_Dbg_Mensaje := 'Determinar (para una receta existente) si el producto ' || p_Producto || ' esta en la receta ' || p_Id_Receta;
        SELECT 'SI'
          INTO l_Autorizado
          FROM Scfr_Rec_Recetas   r
              ,Scfr_Rec_Productos p
         WHERE r.Id_Receta = p.Rec_Id_Receta
           AND r.Convenio = Nvl(p_Convenio
                               ,0)
           AND r.Plan = Nvl(p_Plan
                           ,0)
           AND r.Id_Receta = p_Id_Receta
           AND p.Producto = p_Producto
           AND r.Estado_Receta = 'ABI';
      EXCEPTION
        WHEN OTHERS THEN
          l_Autorizado := 'NO';
      END;
      IF l_Autorizado = 'SI' THEN
        BEGIN
          l_Dbg_Mensaje := 'Determinar si el producto ' || p_Producto || ' de la receta ' || p_Id_Receta || ' tiene unidades pendientes';
          SELECT Nvl(SUM(Decode(Mov.Tipo_Movimiento
                               ,'REG'
                               ,1
                               ,'RET'
                               ,-1
                               ,'REV'
                               ,1) * Det.Cant_Uni_Venta)
                    ,0)
            INTO l_Cantidad_Pendiente
            FROM Scfr_Rec_Movimientos   Mov
                ,Scfr_Rec_Mov_Productos Det
                ,Scfr_Rec_Recetas       Rec
           WHERE Mov.Id_Movimiento = Det.Cce_Id_Movimiento
             AND Mov.Rec_Id_Receta = Rec.Id_Receta
             AND Det.Producto = p_Producto
             AND Mov.Rec_Id_Receta = p_Id_Receta
             AND Rec.Rut_Paciente = p_Rut;
        EXCEPTION
          WHEN OTHERS THEN
            l_Cantidad_Pendiente := 0;
        END;
        IF l_Cantidad_Pendiente = 0 THEN
          l_Autorizado := 'NO';
        END IF;
      END IF;
    ELSIF p_Receta_Nueva = 'NN' THEN
      -- Autorizar en un retiro
      l_Autorizado := 'SI';
    ELSE
      l_Autorizado := 'NO';
    END IF;
    RETURN l_Autorizado;
  EXCEPTION
    WHEN No_Data_Found THEN
      RETURN 'SI';
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      RETURN 'NO';
  END Autoriza_Producto_Receta;

  -- function : obtiene_numero_boleta
  --    in :
  --       p_codigo_tx : Codigo TX de la venta relacionada
  --    Desc :
  --       Busca el numero de la boleta asociada al producto
  --       dentro de la transaccion asociada
  FUNCTION Obtiene_Numero_Boleta(p_Codigo_Tx IN NUMBER) RETURN NUMBER IS
    l_Boleta NUMBER;
  BEGIN
    SELECT a.Folio
      INTO l_Boleta
      FROM Scfr_Mov_Documentos_Txs a
     WHERE a.Txo_Codigo_Tx = p_Codigo_Tx
       AND a.Tmo_Movimiento = 'VENBOL';
    RETURN l_Boleta;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END Obtiene_Numero_Boleta;

  -- function : obtiene_numero_boleta
  --    in :
  --       p_codigo_tx : Codigo TX de la venta relacionada
  --       p_producto  : Codigo del Producto
  --    Desc :
  --       Busca el numero de la boleta asociada al producto
  --       dentro de la transaccion asociada
  FUNCTION Obtiene_Numero_Boleta(p_Codigo_Tx IN NUMBER
                                ,p_Producto  IN NUMBER) RETURN NUMBER IS
    l_Boleta NUMBER;
  BEGIN
    SELECT a.Folio
      INTO l_Boleta
      FROM Scfr_Mov_Documentos_Txs       a
          ,Scfr_Mov_Productos_Documentos b
     WHERE a.Txo_Codigo_Tx = p_Codigo_Tx
       AND a.Mov_Documentos = b.Dte_Mov_Documentos
       AND b.Txo_Codigo_Tx = a.Txo_Codigo_Tx
       AND b.Pro_Codigo_Interno = p_Producto
       AND a.Tmo_Movimiento = 'VENBOL'
       AND b.Impreso_En_Boleta = 'SI';
    RETURN l_Boleta;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END Obtiene_Numero_Boleta;

  -- function : devuelve_cantidad
  --    in :
  --       p_producto : Codigo del Producto
  --       p_dosis    : Dosis indicada en la receta
  --       p_veces    : Veces indicadas en la receta
  --       p_dias     : Dias indicados en la receta
  --    Desc :
  --       Determina la cantidad Total del producto
  --       para la posologia dada
  FUNCTION Devuelve_Cantidad(p_Producto IN NUMBER
                            ,p_Dosis    IN NUMBER
                            ,p_Veces    IN NUMBER
                            ,p_Dias     IN NUMBER) RETURN NUMBER IS
    l_Dias_Solicitados      NUMBER;
    l_Dias_Tratamiento      NUMBER;
    l_Envases               NUMBER;
    l_Retorno               VARCHAR2(1000);
    l_Error_c               VARCHAR2(1000);
    l_Msg_Error             VARCHAR2(1000);
    l_Cantidad_Ff           Scfr_Productos_v.Cantidad_Ff%TYPE;
    l_Tipo_Dias_Tratamiento Scfr_Productos_v.Tipo_Dias_Tratamiento%TYPE;
    l_Compra_Max_Tto        NUMBER;
    l_Cantidad              NUMBER;
    l_Dias_Tratamiento_p    NUMBER;
  BEGIN
    -- Transformar dosis/veces/dias a cantidades
    BEGIN
      SELECT Cantidad_Pills
            ,Nvl(Tipo_Dias_Tratamiento
                ,'CAL')
            ,Dias_Tratamiento
        INTO l_Cantidad_Ff
            ,l_Tipo_Dias_Tratamiento
            ,l_Dias_Tratamiento_p
        FROM Scfr_Productos_v
       WHERE Codigo = p_Producto;
    EXCEPTION
      WHEN OTHERS THEN
        l_Cantidad_Ff           := 0;
        l_Tipo_Dias_Tratamiento := NULL;
        l_Dias_Tratamiento      := 0;
    END;
    Scfr_Posologia_Pk.Calc_Dias_Tto(p_Tipo_Calculo_Dias_Tto => l_Tipo_Dias_Tratamiento -- IN VARCHAR2
                                   ,p_Dosis                 => p_Dosis -- IN NUMBER
                                   ,p_Veces                 => p_Veces -- IN NUMBER
                                   ,p_Dias                  => p_Dias -- IN NUMBER
                                   ,p_Cantidad              => 0 -- IN NUMBER
                                   ,p_Dias_Tto_Maestro      => l_Dias_Tratamiento_p -- IN NUMBER
                                   ,p_Cantidad_Envase       => l_Cantidad_Ff -- IN NUMBER
                                   ,p_Factor                => 1 -- IN NUMBER
                                   ,p_Codigo_Autorizacion   => -1 -- IN NUMBER
                                   ,p_Codigo_Prod           => p_Producto -- IN NUMBER
                                   ,p_Compra_Max_Tto        => -1 --l_compra_max_tto                        -- IN NUMBER
                                   ,x_Dias_Solicitados      => l_Dias_Solicitados -- OUT NUMBER
                                   ,x_Dias_Tratamiento      => l_Dias_Tratamiento -- OUT NUMBER
                                   ,x_Cantidad_Envases      => l_Envases -- OUT NUMBER
                                   ,x_Retorno               => l_Retorno -- OUT VARCHAR2
                                   ,x_Error                 => l_Error_c -- OUT VARCHAR2
                                   ,x_Msg_Error             => l_Msg_Error -- OUT VARCHAR2
                                    );
    l_Cantidad := Nvl(l_Envases
                     ,0);
    RETURN l_Cantidad;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END Devuelve_Cantidad;

  -- function : devuelve_cantidad
  --    in :
  --       p_trama_rp : Trama RP (receta)
  --       p_itm      : item indicando el producto dentro del arreglo
  --    Desc :
  --       Determina la cantidad Total del producto
  --       para la posologia dada
  FUNCTION Devuelve_Cantidad(p_Trama_Rp IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp
                            ,p_Itm      IN NUMBER) RETURN NUMBER IS
    l_Dias_Solicitados      NUMBER;
    l_Dias_Tratamiento      NUMBER;
    l_Envases               NUMBER;
    l_Retorno               VARCHAR2(1000);
    l_Error_c               VARCHAR2(1000);
    l_Msg_Error             VARCHAR2(1000);
    l_Cantidad_Ff           Scfr_Productos_v.Cantidad_Ff%TYPE;
    l_Tipo_Dias_Tratamiento Scfr_Productos_v.Tipo_Dias_Tratamiento%TYPE;
    l_Compra_Max_Tto        NUMBER;
    l_Cantidad              NUMBER;
    l_Dias_Tratamiento_p    NUMBER;
  BEGIN
    -- Transformar dosis/veces/dias a cantidades
    BEGIN
      SELECT Cantidad_Pills
            ,Nvl(Tipo_Dias_Tratamiento
                ,'CAL')
            ,Dias_Tratamiento
        INTO l_Cantidad_Ff
            ,l_Tipo_Dias_Tratamiento
            ,l_Dias_Tratamiento_p
        FROM Scfr_Productos_v
       WHERE Codigo = p_Trama_Rp(1).Subtrama_Rp1(p_Itm).Producto;
    EXCEPTION
      WHEN OTHERS THEN
        l_Cantidad_Ff           := 0;
        l_Tipo_Dias_Tratamiento := NULL;
        l_Dias_Tratamiento      := 0;
    END;
    Scfr_Posologia_Pk.Calc_Dias_Tto(p_Tipo_Calculo_Dias_Tto => l_Tipo_Dias_Tratamiento -- IN VARCHAR2
                                   ,p_Dosis                 => p_Trama_Rp(1).Subtrama_Rp1(p_Itm).Dosis -- IN NUMBER
                                   ,p_Veces                 => p_Trama_Rp(1).Subtrama_Rp1(p_Itm).Veces -- IN NUMBER
                                   ,p_Dias                  => p_Trama_Rp(1).Subtrama_Rp1(p_Itm).Dias -- IN NUMBER
                                   ,p_Cantidad              => 0 -- IN NUMBER
                                   ,p_Dias_Tto_Maestro      => l_Dias_Tratamiento_p -- IN NUMBER
                                   ,p_Cantidad_Envase       => l_Cantidad_Ff -- IN NUMBER
                                   ,p_Factor                => 1 -- IN NUMBER
                                   ,p_Codigo_Autorizacion   => -1 -- IN NUMBER
                                   ,p_Codigo_Prod           => p_Trama_Rp(1).Subtrama_Rp1(p_Itm).Producto -- IN NUMBER
                                   ,p_Compra_Max_Tto        => -1 -- IN NUMBER
                                   ,x_Dias_Solicitados      => l_Dias_Solicitados -- OUT NUMBER
                                   ,x_Dias_Tratamiento      => l_Dias_Tratamiento -- OUT NUMBER
                                   ,x_Cantidad_Envases      => l_Envases -- OUT NUMBER
                                   ,x_Retorno               => l_Retorno -- OUT VARCHAR2
                                   ,x_Error                 => l_Error_c -- OUT VARCHAR2
                                   ,x_Msg_Error             => l_Msg_Error -- OUT VARCHAR2
                                    );
    l_Cantidad := Nvl(l_Envases
                     ,0);
    RETURN l_Cantidad;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END Devuelve_Cantidad;

  -- procedure : prepara_datos_movimiento
  --    in :
  --       p_movimiento  : Arreglo que contiene el registro de un Movimiento
  --       p_receta      : ID unico de la receta (en central)
  --       p_tipo        : Tipo del Movimiento a registrar (REGistro/RETiro/REVersa)
  --       p_transaccion : Arreglo con toda la transaccion en el resolutor
  --    Desc :
  --       Prepara arreglo con datos a registrar por cada Movimiento de la cartola
  PROCEDURE Prepara_Datos_Movimiento(p_Movimiento  IN OUT Reg_Movimiento
                                    ,p_Receta      IN NUMBER
                                    ,p_Tipo        IN VARCHAR2
                                    ,p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion) IS
  BEGIN
    p_Movimiento.Rec_Id_Receta   := p_Receta;
    p_Movimiento.Fecha           := To_Date(p_Transaccion.Trama_Pos.Fecha_Hora_Tx
                                           ,'yyyymmddhh24miss');
    p_Movimiento.Tipo_Movimiento := p_Tipo;
    p_Movimiento.Local           := p_Transaccion.Trama_Pos.Local;
    p_Movimiento.Txo_Codigo_Tx   := p_Transaccion.Codigo_Tx;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END Prepara_Datos_Movimiento;

  -- procedure : prepara_datos_mov_producto
  --    in :
  --       p_mov_producto   : Arreglo que contiene el registro de un Producto (del movimiento)
  --       p_id_movimiento  : ID unico del movimiento padre de la cartola
  --       p_producto       : Producto
  --       p_cant_uni_venta : Cantidad de envases
  --       p_cant_pills     : Cantidad de pills
  --       p_boleta         : Numero de la boleta asociada al producto
  --    Desc :
  --       Prepara arreglo con datos a registrar por cada producto de un Movimiento de la cartola
  PROCEDURE Prepara_Datos_Mov_Producto(p_Mov_Producto  IN OUT Reg_Mov_Producto
                                      ,p_Id_Movimiento IN NUMBER
                                      ,p_Producto      IN NUMBER
                                      ,p_Cant_Uni_Vta  IN NUMBER
                                      ,p_Cant_Pills    IN NUMBER
                                      ,p_Boleta        IN NUMBER) IS
  BEGIN
    p_Mov_Producto.Cce_Id_Movimiento := p_Id_Movimiento;
    p_Mov_Producto.Producto          := p_Producto;
    p_Mov_Producto.Cant_Uni_Venta    := p_Cant_Uni_Vta;
    p_Mov_Producto.Cant_Pills        := p_Cant_Pills;
    p_Mov_Producto.Boleta            := p_Boleta;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END Prepara_Datos_Mov_Producto;

  -- function : inserta_movimiento
  --    in :
  --       p_movimiento  : Arreglo con datos del movimiento
  --    out :
  --       x_error       : Codigo de retorno de ejecucion (0 Sin error)
  --       x_msg         : Mensaje de error si corresponde
  --    Desc :
  --       Inserta en tabla de Movimientos retornando el ID del movimiento registrado
  FUNCTION Inserta_Movimiento(p_Movimiento IN Reg_Movimiento
                             ,x_Error      OUT NUMBER
                             ,x_Msg        OUT VARCHAR2) RETURN NUMBER IS
    l_Id_Movimiento NUMBER;
  BEGIN
    BEGIN
      SELECT Scfr_Rec_Movimientos_s.Nextval INTO l_Id_Movimiento FROM Dual;
    EXCEPTION
      WHEN OTHERS THEN
        l_Id_Movimiento := NULL;
    END;
    INSERT INTO Scfr_Rec_Movimientos
      (Id_Movimiento
      ,Rec_Id_Receta
      ,Fecha
      ,Tipo_Movimiento
      ,LOCAL
      ,Txo_Codigo_Tx)
    VALUES
      (l_Id_Movimiento
      ,p_Movimiento.Rec_Id_Receta
      ,p_Movimiento.Fecha
      ,p_Movimiento.Tipo_Movimiento
      ,p_Movimiento.Local
      ,p_Movimiento.Txo_Codigo_Tx);
    x_Error := 0;
    x_Msg   := NULL;
    RETURN l_Id_Movimiento;
  EXCEPTION
    WHEN Dup_Val_On_Index THEN
      x_Error := -1;
      x_Msg   := 'Clave duplicada al insertar en SCFR_REC_MOVIMIENTOS';
      RETURN 0;
    WHEN OTHERS THEN
      x_Error := -2;
      x_Msg   := SQLERRM;
      RETURN 0;
  END Inserta_Movimiento;

  -- procedure : inserta_mov_producto
  --    in :
  --       p_mov_producto  : Arreglo con datos del producto del movimiento
  --    out :
  --       x_error       : Codigo de retorno de ejecucion (0 Sin error)
  --       x_msg         : Mensaje de error si corresponde
  --    Desc :
  --       Inserta en tabla de Productos del Movimiento
  PROCEDURE Inserta_Mov_Producto(p_Mov_Producto IN Reg_Mov_Producto
                                ,x_Error        OUT NUMBER
                                ,x_Msg          OUT VARCHAR2) IS
    l_Id_Detalle NUMBER;
  BEGIN
    BEGIN
      SELECT Scfr_Rec_Mov_Productos_s.Nextval INTO l_Id_Detalle FROM Dual;
    EXCEPTION
      WHEN OTHERS THEN
        l_Id_Detalle := NULL;
    END;
    INSERT INTO Scfr_Rec_Mov_Productos
      (Id_Detalle
      ,Cce_Id_Movimiento
      ,Producto
      ,Cant_Uni_Venta
      ,Cant_Pills
      ,Boleta)
    VALUES
      (l_Id_Detalle
      ,p_Mov_Producto.Cce_Id_Movimiento
      ,p_Mov_Producto.Producto
      ,p_Mov_Producto.Cant_Uni_Venta
      ,p_Mov_Producto.Cant_Pills
      ,p_Mov_Producto.Boleta);
    x_Error := 0;
    x_Msg   := NULL;
  EXCEPTION
    WHEN Dup_Val_On_Index THEN
      x_Error := -1;
      x_Msg   := 'Clave duplicada al insertar en SCFR_REC_MOV_PRODUCTOS';
    WHEN OTHERS THEN
      x_Error := -2;
      x_Msg   := SQLERRM;
  END Inserta_Mov_Producto;

  -- procedure : registra_ccr_batch
  --    in :
  --       p_codigo_tx  : Codigo TX on-line de la venta asociada
  --       p_receta     : ID de la receta registrada
  --    out :
  --       x_ret        : Codigo de retorno de ejecucion (0 Sin error)
  --       x_msg        : Mensaje de error si corresponde
  --    Desc :
  --       Registra Movimientos y Productos en la Cte. Cte. de Recetas
  PROCEDURE Registra_Ccr_Batch(p_Codigo_Tx IN NUMBER
                              ,p_Receta    IN NUMBER
                              ,x_Ret       OUT NUMBER
                              ,x_Msg       OUT VARCHAR2) IS
    CURSOR c_Productos_Reg IS
      SELECT T1.Convenio
            ,T1.Plan
            ,T2.Dias
            ,T2.Veces
            ,T2.Dosis
            ,T2.Producto
            ,T2.Cantidad
        FROM Scfr_Rec_Recetas   T1
            ,Scfr_Rec_Productos T2
       WHERE T1.Id_Receta = T2.Rec_Id_Receta
         AND T1.Id_Receta = p_Receta;
    CURSOR c_Productos_Ret IS
      SELECT Pro_Codigo_Interno
            ,Cantidad
        FROM Scfr_Mov_Productos_Txs
       WHERE Txo_Codigo_Tx = p_Codigo_Tx;
    l_Movimiento    Reg_Movimiento;
    l_Mov_Producto  Reg_Mov_Producto;
    l_Error         NUMBER;
    l_Msg           VARCHAR2(1000);
    l_Id_Movimiento NUMBER;
    l_Cant_Uni_Vta  NUMBER;
    l_Cant_Pills    NUMBER;
    l_Boleta        NUMBER;
    l_Dbg_Proceso   VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.registra_ccr_batch()';
    l_Dbg_Mensaje   VARCHAR2(250) := 'Error General';
  BEGIN
    -- Registra el REGistro de la Receta p_receta
    BEGIN
      SELECT Fecha_Ingreso INTO l_Movimiento.Fecha FROM Scfr_Rec_Recetas WHERE Id_Receta = p_Receta;
      SELECT Loc_Local INTO l_Movimiento.Local FROM Scfr_Mov_Transacciones WHERE Codigo_Tx = p_Codigo_Tx;
      l_Movimiento.Rec_Id_Receta   := p_Receta;
      l_Movimiento.Tipo_Movimiento := 'REG';
      l_Movimiento.Txo_Codigo_Tx   := p_Codigo_Tx;
    EXCEPTION
      WHEN OTHERS THEN
        l_Movimiento.Rec_Id_Receta   := NULL;
        l_Movimiento.Tipo_Movimiento := NULL;
        l_Movimiento.Txo_Codigo_Tx   := NULL;
        l_Movimiento.Local           := NULL;
        l_Movimiento.Fecha           := NULL;
    END;
    IF l_Movimiento.Rec_Id_Receta IS NOT NULL THEN
      l_Dbg_Mensaje   := 'Insertar en la tabla scfr_rec_movimientos un Registro';
      l_Id_Movimiento := Inserta_Movimiento(l_Movimiento
                                           ,l_Error
                                           ,l_Msg);
      IF l_Error <> 0 THEN
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - ' || l_Msg);
      END IF;
      FOR Prods_Reg IN c_Productos_Reg
      LOOP
        BEGIN
          l_Dbg_Mensaje := 'Obtener la cant. de "envases" para un Registro';
          BEGIN
            IF Prods_Reg.Cantidad = 0 THEN
              l_Cant_Uni_Vta := Devuelve_Cantidad(p_Producto => Prods_Reg.Producto
                                                  --, p_convenio => prods_reg.convenio
                                                  --, p_plan     => prods_reg.plan
                                                 ,p_Dosis => Prods_Reg.Dosis
                                                 ,p_Veces => Prods_Reg.Veces
                                                 ,p_Dias  => Prods_Reg.Dias);
            ELSE
              l_Cant_Uni_Vta := Prods_Reg.Cantidad;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              l_Cant_Uni_Vta := NULL;
          END;
          l_Dbg_Mensaje := 'Obtener la cantidad de pills para un Registro';
          BEGIN
            l_Cant_Pills := Prods_Reg.Cantidad;
          EXCEPTION
            WHEN OTHERS THEN
              l_Cant_Pills := NULL;
          END;
          l_Dbg_Mensaje := 'Obtener el numero de boleta para un Registro';
          l_Boleta      := Obtiene_Numero_Boleta(p_Codigo_Tx
                                                ,Prods_Reg.Producto);
          l_Dbg_Mensaje := 'Preparar la data para insertar el producto del movimiento para un Registro';
          Prepara_Datos_Mov_Producto(l_Mov_Producto
                                    ,l_Id_Movimiento
                                    ,Prods_Reg.Producto
                                    ,l_Cant_Uni_Vta
                                    ,l_Cant_Pills
                                    ,l_Boleta);
          l_Dbg_Mensaje := 'Insertar en la tabla scfr_rec_mov_productos para un Registro';
          Inserta_Mov_Producto(l_Mov_Producto
                              ,l_Error
                              ,l_Msg);
          IF l_Error <> 0 THEN
            Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                      ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - ' || l_Msg);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                      ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
        END;
      END LOOP;
      -- Registrar el RETiro de la receta p_receta
      l_Movimiento.Tipo_Movimiento := 'RET';
      l_Dbg_Mensaje                := 'Insertar en la tabla scfr_rec_movimientos un Registro';
      l_Id_Movimiento              := Inserta_Movimiento(l_Movimiento
                                                        ,l_Error
                                                        ,l_Msg);
      IF l_Error <> 0 THEN
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - ' || l_Msg);
      END IF;
      FOR Prods_Ret IN c_Productos_Ret
      LOOP
        BEGIN
          l_Dbg_Mensaje := 'Obtener la cant. de "envases" para un Registro';
          BEGIN
            l_Cant_Uni_Vta := Prods_Ret.Cantidad;
          EXCEPTION
            WHEN OTHERS THEN
              l_Cant_Uni_Vta := NULL;
          END;
          l_Dbg_Mensaje := 'Obtener la cantidad de pills para un Registro';
          BEGIN
            l_Cant_Pills := Prods_Ret.Cantidad;
          EXCEPTION
            WHEN OTHERS THEN
              l_Cant_Pills := NULL;
          END;
          l_Dbg_Mensaje := 'Obtener el numero de boleta para un Registro';
          l_Boleta      := Obtiene_Numero_Boleta(p_Codigo_Tx
                                                ,Prods_Ret.Pro_Codigo_Interno);
          l_Dbg_Mensaje := 'Preparar la data para insertar el producto del movimiento para un Registro';
          Prepara_Datos_Mov_Producto(l_Mov_Producto
                                    ,l_Id_Movimiento
                                    ,Prods_Ret.Pro_Codigo_Interno
                                    ,l_Cant_Uni_Vta
                                    ,l_Cant_Pills
                                    ,l_Boleta);
          l_Dbg_Mensaje := 'Insertar en la tabla scfr_rec_mov_productos para un Registro';
          Inserta_Mov_Producto(l_Mov_Producto
                              ,l_Error
                              ,l_Msg);
          IF l_Error <> 0 THEN
            Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                      ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - ' || l_Msg);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                      ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
        END;
      END LOOP;
    ELSE
      NULL;
      -- Registrar debug que no se pudo grabar el REGistro de la receta (1er movimiento)
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - ' || l_Msg);
    END IF;
    x_Ret := 0;
    x_Msg := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      x_Ret := -1;
      x_Msg := 'Se encontraron errores al ejecutar scfr_trx_gnc_utl_pk.registra_ccr_batch().  ' || SQLERRM;
  END Registra_Ccr_Batch;

  -- function : devuelve_receta
  --    in :
  --       p_rut      : Rut de un paciente
  --       p_convenio : Convenio asociado
  --       p_plan     : Plan asociado
  --       p_Producto : Codigo del Producto
  --    out :
  --       x_ret        : Codigo de retorno de ejecucion (0 Sin error)
  --       x_msg        : Mensaje de error si corresponde
  --    Desc :
  --       Devuelve el ID unico en central de una receta a partir del producto
  FUNCTION Devuelve_Receta(p_Rut      IN NUMBER
                          ,p_Convenio IN NUMBER
                          ,p_Plan     IN NUMBER
                          ,p_Producto IN NUMBER
                          ,x_Ret      OUT NUMBER
                          ,x_Msg      OUT VARCHAR2) RETURN NUMBER IS
    l_Receta NUMBER;
  BEGIN
    /*
    select rec_id_receta
      into l_receta
      from scfr_rec_recetas       t1
         , scfr_rec_movimientos   t2
         , scfr_rec_mov_productos t3
     where t1.id_receta       = t2.rec_id_receta
       and t2.id_movimiento   = t3.cce_id_movimiento
       and t1.rut_cliente     = p_rut
       and t1.convenio        = nvl( p_convenio , 0 )
       and t1.plan            = nvl( p_plan , 0 )
       and t3.producto        = p_producto
       and t2.tipo_movimiento = 'REG'
       and t1.estado_receta   = 'ABI';
    */
    SELECT T1.Id_Receta
      INTO l_Receta
      FROM Scfr_Rec_Recetas   T1
          ,Scfr_Rec_Productos T2
     WHERE T1.Id_Receta = T2.Rec_Id_Receta
       AND T1.Rut_Paciente = p_Rut
       AND T1.Convenio = Nvl(p_Convenio
                            ,0)
       AND T1.Plan = Nvl(p_Plan
                        ,0)
       AND T2.Producto = p_Producto
       AND T1.Estado_Receta = 'ABI'
       AND T2.Estado_Producto = 'ACT';
    x_Ret := 0;
    x_Msg := NULL;
    RETURN l_Receta;
  EXCEPTION
    WHEN Too_Many_Rows THEN
      x_Ret := -1;
      x_Msg := 'Se encontraron mas de una receta para el producto ' || p_Producto;
      RETURN 0;
    WHEN OTHERS THEN
      x_Ret := -2;
      x_Msg := 'Error. ' || SQLERRM;
      RETURN 0;
  END Devuelve_Receta;

  -- procedure : autoriza
  --    in :
  --       p_receta    : ID de la receta en central
  --       p_convenio  : Convenio asociado
  --       p_plan      : Plan asociado
  --       p_Productos : Arreglo de Productos a autorizar
  --    out :
  --       x_ret        : Codigo de retorno de ejecucion (0 Sin error)
  --       x_msg        : Mensaje de error si corresponde
  --    Desc :
  --       Devuelve arreglo de productos marcados SI/NO
  PROCEDURE Autoriza(p_Receta    IN NUMBER
                    ,p_Convenio  IN NUMBER
                    ,p_Plan      IN NUMBER
                    ,p_Productos IN OUT Tab_Productos
                    ,x_Ret       OUT NUMBER
                    ,x_Msg       OUT VARCHAR2) IS
    l_Producto NUMBER;
    l_Receta   NUMBER;
    l_Convenio NUMBER;
    l_Plan     NUMBER;
  BEGIN
    FOR l_Itm IN 1 .. p_Productos.Count
    LOOP
      BEGIN
        SELECT T2.Producto
              ,T2.Rec_Id_Receta
              ,T1.Convenio
              ,T1.Plan
          INTO l_Producto
              ,l_Receta
              ,l_Convenio
              ,l_Plan
          FROM Scfr_Rec_Recetas   T1
              ,Scfr_Rec_Productos T2
         WHERE T1.Id_Receta = T2.Rec_Id_Receta
           AND T2.Producto = p_Productos(l_Itm).Producto;
        IF l_Producto = p_Productos(l_Itm).Producto AND
           l_Receta = p_Receta AND
           l_Convenio = p_Convenio AND
           l_Plan = p_Plan THEN
          p_Productos(l_Itm).Autorizado := 'SI';
        ELSE
          p_Productos(l_Itm).Autorizado := 'NO';
        END IF;
      EXCEPTION
        WHEN No_Data_Found THEN
          p_Productos(l_Itm).Autorizado := 'SI';
        WHEN OTHERS THEN
          p_Productos(l_Itm).Autorizado := 'NO';
      END;
    END LOOP;
    x_Ret := 0;
    x_Msg := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      x_Ret := -1;
      x_Msg := 'Se encontraron errores al ejecutar scfr_trx_gnc_utl_pk.autoriza(). ' || SQLERRM;
  END Autoriza;

  PROCEDURE Reversa_Seguro(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                          ,x_Cod_Error   OUT NUMBER
                          ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Dr         Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dr;
    l_Trama_Pm         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm;
    l_Tipo_Recaudacion Scfr_Recauda_Movimientos.Codigo_Movimiento%TYPE;
    l_Dbg_Mensaje      VARCHAR2(200);
    l_Itm              NUMBER;
    x_Rut              NUMBER;
    x_Dv_Rut           VARCHAR2(1);
  BEGIN
    Scfr_Trx_Fid_Pk.Obtiene_Rut(p_Transaccion.Trama_Boc.Forma_Identificacion
                               ,p_Transaccion.Trama_Boc.String_Identificacion
                               ,p_Transaccion.Trama_Pos.Empresa
                               ,p_Transaccion.Trama_Pos.Cadena
                               ,x_Rut
                               ,x_Dv_Rut);
    l_Trama_Dr := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Dr(p_Transaccion.Cuerpo_Tx);
    l_Trama_Pm := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Pm(p_Transaccion.Trama_Pos
                                                    ,p_Transaccion.Cuerpo_Tx);
    IF (l_Trama_Dr.Tipo_Movimiento_Padre IS NOT NULL) THEN
      l_Tipo_Recaudacion := Scfr_Trx_Gnc_Utl_Pk.Obtiene_Mov_Hijo(l_Trama_Dr);
    END IF;
    IF l_Tipo_Recaudacion IS NOT NULL THEN
      l_Dbg_Mensaje := 'Recorrer detalle de la trama PM (productos)';
      FOR l_Itm IN 1 .. l_Trama_Pm.Count
      LOOP
        BEGIN
          UPDATE Scfr_Recauda_Movimientos
             SET Estado = 'ANU'
           WHERE Movimiento_Padre = l_Trama_Dr.Tipo_Movimiento_Padre
             AND Rut_Cliente = x_Rut
             AND Empresa = 12 --l_trama_dr.id_empresa
             AND Codigo_Item = l_Trama_Pm(l_Itm).Producto;
        EXCEPTION
          WHEN OTHERS THEN
            x_Cod_Error := SQLCODE;
            x_Msg_Error := SQLERRM;
            Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => 'Reversa Recaudacion de Seguros'
                                      ,p_Msg     => 'Error al intentar Reversa Recaudacion de Seguros' || ' - ' || x_Msg_Error);
        END;
      END LOOP;
    END IF;
  END;

  -- function : trama_rp_prepara
  --    in :
  --       p_transaccion : Arreglo con toda la transaccion
  --       p_tipo        : Tipo de la preparacion (TOT : Toda una receta ; PEN : Recetas pendientes )
  --    out :
  --       x_cod_error : Codigo de retorno de ejecucion (0 Sin error)
  --       x_msg_error : Mensaje de error si corresponde
  --    Desc :
  --       Prepara arreglo con Receta(s)
  FUNCTION Trama_Rp_Prepara(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,p_Tipo        IN VARCHAR2 DEFAULT 'PEN' -- 'TOT'
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp IS
    CURSOR Productos(p_Receta IN NUMBER) IS
      SELECT Producto
            ,Cantidad
            ,0 Cantidad_Pendiente
            ,Dosis
            ,Veces
            ,Dias
            ,Inscribir_Refill
            ,Texto
            ,Forma_Farmaceutica
        FROM Scfr_Rec_Productos
       WHERE Rec_Id_Receta = p_Receta
         AND Estado_Producto = 'ACT';
    CURSOR c_Recetas(p_Rut IN NUMBER) IS
      SELECT Serie
            ,Id_Receta
            ,Rut_Medico
            ,Dv_Medico
            ,Nombre_Medico
            ,Fecha_Emision
            ,Diagnostico
            ,Tipo_Receta
            ,Con_Copia
            ,Folio_Receta
            ,Tipo_Medicamento
            ,Rut_Paciente
            ,Dv_Paciente
            ,Nombre_Paciente
            ,Fecha_Ingreso
            ,Fono_Paciente
            ,Convenio
            ,Plan
            ,Rut_Institucion
            ,Dv_Institucion
        FROM Scfr_Rec_Recetas
       WHERE Rut_Cliente = p_Rut
         AND Estado_Receta = 'ABI'
         AND Fecha_Termino > Scfr_Trx_Util_Pk.Get_Sysdate
      UNION
      SELECT Serie
            ,Id_Receta
            ,Rut_Medico
            ,Dv_Medico
            ,Nombre_Medico
            ,Fecha_Emision
            ,Diagnostico
            ,Tipo_Receta
            ,Con_Copia
            ,Folio_Receta
            ,Tipo_Medicamento
            ,Rut_Paciente
            ,Dv_Paciente
            ,Nombre_Paciente
            ,Fecha_Ingreso
            ,Fono_Paciente
            ,Convenio
            ,Plan
            ,Rut_Institucion
            ,Dv_Institucion
        FROM Scfr_Rec_Recetas
       WHERE Rut_Paciente = p_Rut
         AND Estado_Receta = 'ABI'
         AND Fecha_Termino > Scfr_Trx_Util_Pk.Get_Sysdate;
    CURSOR Recetas_Det(p_Movimiento IN NUMBER) IS
      SELECT Id_Detalle
            ,Cce_Id_Movimiento
            ,Producto
            ,Cant_Uni_Venta
            ,Cant_Pills
            ,Boleta
        FROM Scfr_Rec_Mov_Productos
       WHERE Cce_Id_Movimiento = p_Movimiento;
    l_Trama_Rp         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp;
    l_Trama_Rz         Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Rz;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.trama_rp_prepara()';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    l_Id_Movimiento    NUMBER;
    l_Party_Medico     NUMBER;
    l_Itm              NUMBER;
    l_Itm1             NUMBER;
    l_Total_Pendientes NUMBER;
    l_Rut              NUMBER;
    l_Rut_Completo     VARCHAR2(20);
  BEGIN
    IF p_Tipo = 'TOT' THEN
      -- Receta Original : se entrega en la consulta GNCC05
      -- Obtiene informacion de la trama vt
      l_Dbg_Mensaje := 'Obtener informacion de la trama RZ';
      l_Trama_Rz    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Rz(p_Transaccion.Cuerpo_Tx);
      l_Dbg_Mensaje := 'Obtener data de scfr_rec_recetas';
      SELECT Serie
            ,Id_Receta
            ,Rut_Medico
            ,Dv_Medico
            ,Nombre_Medico
            ,To_Number(To_Char(Fecha_Emision
                              ,'yyyymmdd'))
            ,Diagnostico
            ,Tipo_Receta
            ,Con_Copia
            ,Folio_Receta
            ,Tipo_Medicamento
            ,Rut_Paciente
            ,Dv_Paciente
            ,Nombre_Paciente
            ,To_Number(To_Char(Fecha_Ingreso
                              ,'yyyymmdd'))
            ,Fono_Paciente
            ,Convenio
            ,Plan
            ,Rut_Institucion
            ,Dv_Institucion
        INTO l_Trama_Rp(1).Serie
            ,l_Trama_Rp(1).Secuencia_Receta
            ,l_Trama_Rp(1).Rut_Medico
            ,l_Trama_Rp(1).Dv_Rut_Medico
            ,l_Trama_Rp(1).Nombre_Medico
            ,l_Trama_Rp(1).Emision
            ,l_Trama_Rp(1).Diagnostico
            ,l_Trama_Rp(1).Tipo_Receta
            ,l_Trama_Rp(1).Con_Copia
            ,l_Trama_Rp(1).Folio_Receta
            ,l_Trama_Rp(1).Tipo_Medicamento
            ,l_Trama_Rp(1).Rut_Paciente
            ,l_Trama_Rp(1).Dv_Paciente
            ,l_Trama_Rp(1).Nombre_Paciente
            ,l_Trama_Rp(1).Fecha_Ingreso_Paciente
            ,l_Trama_Rp(1).Fono_Paciente
            ,l_Trama_Rp(1).Convenio
            ,l_Trama_Rp(1).Plan
            ,l_Trama_Rp(1).Rut_Institucion
            ,l_Trama_Rp(1).Dv_Institucion
        FROM Scfr_Rec_Recetas
       WHERE Id_Receta = l_Trama_Rz.Secuencia_Receta;
      l_Dbg_Mensaje := 'Recorrer productos en scfr_rec_movimientos';
      l_Itm         := 0;
      FOR Prods IN Productos(l_Trama_Rz.Secuencia_Receta)
      LOOP
        BEGIN
          l_Itm := l_Itm + 1;
          l_Dbg_Mensaje := 'Preparar data de productos';
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Producto := Prods.Producto;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Cantidad := Prods.Cantidad;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Cantidad_Pendiente := Prods.Cantidad_Pendiente;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Dosis := Prods.Dosis;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Veces := Prods.Veces;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Dias := Prods.Dias;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Inscribir_En_Refill := Prods.Inscribir_Refill;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Texto := Prods.Texto;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Forma_Farmaceutica := Prods.Forma_Farmaceutica;
        EXCEPTION
          WHEN OTHERS THEN
            NULL; -- Nivel de productos
        END;
      END LOOP;
      l_Trama_Rp(1).Lista_Productos := l_Trama_Rp(1).Subtrama_Rp1.Count;
    ELSE
      -- Recetas Pendientes 'PEN' se entrega en el perfil GNCC01
      l_Dbg_Mensaje := 'Obtener datos de recetas del cliente desde la tabla SCFR_REC_RECETAS';
      l_Itm         := 1;
      FOR Rec IN c_Recetas(p_Transaccion.Rut_Titular)
      LOOP
        BEGIN
          l_Total_Pendientes := 0;
          l_Trama_Rp(l_Itm).Serie := Rec.Serie;
          l_Trama_Rp(l_Itm).Secuencia_Receta := Rec.Id_Receta;
          l_Trama_Rp(l_Itm).Secuencia_b := Rec.Id_Receta;
          l_Trama_Rp(l_Itm).Emision := To_Number(To_Char(Rec.Fecha_Emision
                                                        ,'yyyymmdd'));
          l_Trama_Rp(l_Itm).Diagnostico := Rec.Diagnostico;
          l_Trama_Rp(l_Itm).Tipo_Receta := Rec.Tipo_Receta;
          l_Trama_Rp(l_Itm).Con_Copia := Rec.Con_Copia;
          l_Trama_Rp(l_Itm).Folio_Receta := Rec.Folio_Receta;
          l_Trama_Rp(l_Itm).Tipo_Medicamento := Rec.Tipo_Medicamento;
          l_Trama_Rp(l_Itm).Rut_Paciente := Rec.Rut_Paciente;
          l_Trama_Rp(l_Itm).Dv_Paciente := Rec.Dv_Paciente;
          l_Trama_Rp(l_Itm).Nombre_Paciente := Rec.Nombre_Paciente;
          l_Trama_Rp(l_Itm).Fecha_Ingreso_Paciente := To_Number(To_Char(Rec.Fecha_Ingreso
                                                                       ,'yyyymmdd'));
          l_Trama_Rp(l_Itm).Fono_Paciente := Rec.Fono_Paciente;
          l_Trama_Rp(l_Itm).Convenio := Rec.Convenio;
          l_Trama_Rp(l_Itm).Plan := Rec.Plan;
          l_Trama_Rp(l_Itm).Rut_Medico := Rec.Rut_Medico;
          l_Trama_Rp(l_Itm).Dv_Rut_Medico := Rec.Dv_Medico;
          l_Trama_Rp(l_Itm).Nombre_Medico := Rec.Nombre_Medico;
          l_Trama_Rp(l_Itm).Rut_Institucion := Rec.Rut_Institucion;
          l_Trama_Rp(l_Itm).Dv_Institucion := Rec.Dv_Institucion;
          l_Dbg_Mensaje := 'Obtener datos desde la tabla SCFR_REC_MOV_PRODUCTOS';
          l_Itm1 := 0;
          FOR Prods IN Productos(Rec.Id_Receta)
          LOOP
            BEGIN
              l_Itm1 := l_Itm1 + 1;
              l_Trama_Rp(l_Itm).Subtrama_Rp1(l_Itm1).Producto := Prods.Producto;
              l_Trama_Rp(l_Itm).Subtrama_Rp1(l_Itm1).Cantidad := Prods.Cantidad;
              l_Dbg_Mensaje := 'Obtener cantidad pendiente';
              BEGIN
                SELECT SUM(Decode(Mov.Tipo_Movimiento
                                 ,'REG'
                                 ,1
                                 ,'RET'
                                 ,-1
                                 ,'REV'
                                 ,1) * Det.Cant_Uni_Venta)
                  INTO l_Trama_Rp(l_Itm).Subtrama_Rp1(l_Itm1).Cantidad_Pendiente
                  FROM Scfr_Rec_Movimientos   Mov
                      ,Scfr_Rec_Mov_Productos Det
                 WHERE Mov.Id_Movimiento = Det.Cce_Id_Movimiento
                   AND Det.Producto = Prods.Producto
                   AND Mov.Rec_Id_Receta = Rec.Id_Receta;
              EXCEPTION
                WHEN OTHERS THEN
                  l_Trama_Rp(l_Itm).Subtrama_Rp1(l_Itm1).Cantidad_Pendiente := 0;
              END;
              l_Total_Pendientes := l_Total_Pendientes + l_Trama_Rp(l_Itm).Subtrama_Rp1(l_Itm1).Cantidad_Pendiente;
              l_Trama_Rp(l_Itm).Subtrama_Rp1(l_Itm1).Dosis := Prods.Dosis;
              l_Trama_Rp(l_Itm).Subtrama_Rp1(l_Itm1).Veces := Prods.Veces;
              l_Trama_Rp(l_Itm).Subtrama_Rp1(l_Itm1).Dias := Prods.Dias;
              l_Trama_Rp(l_Itm).Subtrama_Rp1(l_Itm1).Inscribir_En_Refill := Prods.Inscribir_Refill;
              l_Trama_Rp(l_Itm).Subtrama_Rp1(l_Itm1).Texto := Prods.Texto;
              l_Trama_Rp(l_Itm).Subtrama_Rp1(l_Itm1).Forma_Farmaceutica := Prods.Forma_Farmaceutica;
            EXCEPTION
              WHEN OTHERS THEN
                Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                          ,p_Msg     => 'No se pudo cargar el producto => ' || Prods.Producto || ', Receta=>' || Rec.Id_Receta);
            END;
          END LOOP;
          l_Trama_Rp(l_Itm).Lista_Productos := l_Trama_Rp(l_Itm).Subtrama_Rp1.Count;
          -- Solo si la receta tiene al menos un producto con cantidad pendiente se devuelve
          -- en caso contrario no se retorna en el perfil
          IF l_Total_Pendientes > 0 THEN
            l_Itm := l_Itm + 1;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                      ,p_Msg     => 'No se pudo cargar la Receta=>' || Rec.Id_Receta);
        END;
      END LOOP;
    END IF;
    RETURN l_Trama_Rp;
  EXCEPTION
    WHEN No_Data_Found THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'No se encontro la receta secuencia ' || l_Trama_Rz.Secuencia_Receta);
      x_Cod_Error := 0;
      x_Msg_Error := NULL;
      RETURN l_Trama_Rp;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
      RETURN l_Trama_Rp;
  END Trama_Rp_Prepara;

  FUNCTION Trama_Rp_Prepara_New(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                               ,p_Perfil      IN VARCHAR2
                               ,x_Cod_Error   OUT NUMBER
                               ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp IS
    l_Trama_Rp     Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp;
    l_Trama_Br     Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Br;
    l_Dbg_Proceso  VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.trama_rp_prepara()';
    l_Dbg_Mensaje  VARCHAR2(250) := 'Error General';
    l_Rut_Paciente NUMBER;
    l_Convenio     NUMBER;
    l_Plan         NUMBER;
    l_Itm          NUMBER;
    l_Itm1         NUMBER;
  BEGIN
    IF p_Perfil = 'NO' THEN
      l_Dbg_Mensaje := 'Obtener informacion de la trama BR';
      l_Trama_Br := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Br(p_Transaccion.Cuerpo_Tx);
      l_Trama_Rp(1).Id_Receta := 11566767;
      l_Trama_Rp(1).Local_Origen := p_Transaccion.Trama_Pos.Local;
      l_Trama_Rp(1).Fecha_Emision := 20151221;
      l_Trama_Rp(1).Estado_Receta := 'VIG';
      l_Trama_Rp(1).Serie := 'S';
      l_Trama_Rp(1).Folio := 4589;
      l_Trama_Rp(1).Despacho_Anticipado := 'NO';
      l_Trama_Rp(1).Fecha_Ingreso := 20151212175232;
      l_Trama_Rp(1).Rut_Vendedor := 15465368;
      l_Trama_Rp(1).Dv_Vendedor := '2';
      l_Trama_Rp(1).Rut_Cliente := Nvl(l_Trama_Br.Rut_Paciente
                                      ,12856887);
      l_Trama_Rp(1).Dv_Cliente := Nvl(l_Trama_Br.Dv_Paciente
                                     ,'5');
      l_Trama_Rp(1).Nombre_Cliente := 'AAAAAAAAAAAAAAAAAAAA';
      l_Trama_Rp(1).Rut_Paciente := Nvl(l_Trama_Br.Rut_Paciente
                                       ,12856887);
      l_Trama_Rp(1).Dv_Paciente := Nvl(l_Trama_Br.Dv_Paciente
                                      ,'5');
      l_Trama_Rp(1).Nombre_Paciente := 'BBBBBBBBBBBBBBBBBBB';
      l_Trama_Rp(1).Telefono := '225667787';
      l_Trama_Rp(1).Rut_Medico := 13987564;
      l_Trama_Rp(1).Dv_Medico := 'K';
      l_Trama_Rp(1).Nombre_Medico := 'CCCCCCCCCCCCCCCCC';
      l_Itm := 0;
      FOR l_Itm IN 1 .. 3
      LOOP
        BEGIN
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Producto := (5666 + l_Itm);
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Cantidad := 180;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Dosis := 1;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Veces := 2;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Dias := 90;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Estado_Producto := 'VIG';
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Permanente := 'SI';
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Indicaciones := 'Segun las indicaciones del medico';
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Retiro_Anticipado := 'NO';
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Retiro_Actual := 2;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Total_Retiros := 3;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Fecha_Proximo_Retiro := 20150103;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Fecha_Termino_Tratamiento := 20150228;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Cantidad_Despacho_Anterior := 60;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Cantidad_Despacho_Total := 60;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Cantidad_Pendiente := 120;
        EXCEPTION
          WHEN OTHERS THEN
            x_Cod_Error := SQLCODE;
            x_Msg_Error := SQLERRM;
        END;
      END LOOP;
      l_Trama_Rp(1).Lista_Productos := l_Trama_Rp(1).Subtrama_Rp1.Count;
      /* Historial */
      l_Itm := 0;
      FOR l_Itm IN 1 .. 1
      LOOP
        BEGIN
          l_Trama_Rp(1).Subtrama_Rp2(l_Itm).Producto := (5666 + l_Itm);
          l_Trama_Rp(1).Subtrama_Rp2(l_Itm).Numero_Retiro := l_Itm;
          l_Trama_Rp(1).Subtrama_Rp2(l_Itm).Total_Retiros := 3;
          l_Trama_Rp(1).Subtrama_Rp2(l_Itm).Folio_Documento := 8562288;
          l_Trama_Rp(1).Subtrama_Rp2(l_Itm).Fecha_Documento := 20151201;
          l_Trama_Rp(1).Subtrama_Rp2(l_Itm).Cantidad := 60;
        EXCEPTION
          WHEN OTHERS THEN
            x_Cod_Error := SQLCODE;
            x_Msg_Error := SQLERRM;
        END;
      END LOOP;
      l_Trama_Rp(1).Historial_Productos := l_Trama_Rp(1).Subtrama_Rp2.Count;
      /*    ELSE
      */
    END IF;
    IF p_Perfil = 'SI' THEN
      l_Trama_Rp(1).Id_Receta := 11566767;
      l_Trama_Rp(1).Local_Origen := p_Transaccion.Trama_Pos.Local;
      l_Trama_Rp(1).Fecha_Emision := 20151221;
      l_Trama_Rp(1).Estado_Receta := 'VIG';
      l_Trama_Rp(1).Serie := 'S';
      l_Trama_Rp(1).Folio := 4589;
      l_Trama_Rp(1).Despacho_Anticipado := 'NO';
      l_Trama_Rp(1).Fecha_Ingreso := 20151212175232;
      l_Trama_Rp(1).Rut_Vendedor := 15465368;
      l_Trama_Rp(1).Dv_Vendedor := '2';
      l_Trama_Rp(1).Rut_Cliente := 12856887;
      l_Trama_Rp(1).Dv_Cliente := '5';
      l_Trama_Rp(1).Nombre_Cliente := 'AAAAAAAAAAAAAAAAAAAA';
      l_Trama_Rp(1).Rut_Paciente := 12856887;
      l_Trama_Rp(1).Dv_Paciente := '5';
      l_Trama_Rp(1).Nombre_Paciente := 'BBBBBBBBBBBBBBBBBBB';
      l_Trama_Rp(1).Telefono := '225667787';
      l_Trama_Rp(1).Rut_Medico := 13987564;
      l_Trama_Rp(1).Dv_Medico := 'K';
      l_Trama_Rp(1).Nombre_Medico := 'CCCCCCCCCCCCCCCCC';
      l_Itm := 0;
      FOR l_Itm IN 1 .. 3
      LOOP
        BEGIN
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Producto := (5666 + l_Itm);
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Cantidad := 180;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Dosis := 1;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Veces := 2;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Dias := 90;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Estado_Producto := 'VIG';
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Permanente := 'SI';
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Indicaciones := 'Segun las indicaciones del medico';
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Retiro_Anticipado := 'NO';
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Retiro_Actual := 2;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Total_Retiros := 3;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Fecha_Proximo_Retiro := 20150103;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Fecha_Termino_Tratamiento := 20150228;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Cantidad_Despacho_Anterior := 60;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Cantidad_Despacho_Total := 60;
          l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Cantidad_Pendiente := 120;
        EXCEPTION
          WHEN OTHERS THEN
            x_Cod_Error := SQLCODE;
            x_Msg_Error := SQLERRM;
        END;
      END LOOP;
      l_Trama_Rp(1).Lista_Productos := l_Trama_Rp(1).Subtrama_Rp1.Count;
      /* Historial */
      l_Itm := 0;
      FOR l_Itm IN 1 .. 3
      LOOP
        BEGIN
          l_Trama_Rp(1).Subtrama_Rp2(l_Itm).Producto := (5666 + l_Itm);
          l_Trama_Rp(1).Subtrama_Rp2(l_Itm).Numero_Retiro := l_Itm;
          l_Trama_Rp(1).Subtrama_Rp2(l_Itm).Total_Retiros := 3;
          l_Trama_Rp(1).Subtrama_Rp2(l_Itm).Folio_Documento := 8562288;
          l_Trama_Rp(1).Subtrama_Rp2(l_Itm).Fecha_Documento := 20151201;
          l_Trama_Rp(1).Subtrama_Rp2(l_Itm).Cantidad := 60;
        EXCEPTION
          WHEN OTHERS THEN
            x_Cod_Error := SQLCODE;
            x_Msg_Error := SQLERRM;
        END;
      END LOOP;
      l_Trama_Rp(1).Historial_Productos := l_Trama_Rp(1).Subtrama_Rp2.Count;
    END IF;
    RETURN l_Trama_Rp;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
      RETURN l_Trama_Rp;
  END Trama_Rp_Prepara_New;

  FUNCTION Trama_Fm_Prepara(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,p_Rut         IN NUMBER
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Fm IS
    CURSOR Datos_Mov(p_Rut_Tit IN NUMBER) IS
      SELECT Movimiento_Padre
            ,Fecha_Movimiento
            ,Local_Movimiento
            ,Codigo_Movimiento
            ,Rut_Cliente
            ,Empresa
            ,Codigo_Item
        FROM Scfr_Recauda_Movimientos
       WHERE Rut_Cliente = p_Rut_Tit
         AND Estado = 'VIG';
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.trama_fm_prepara()';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    l_Trama_Fm         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Fm;
    l_Itm              NUMBER;
    l_Itm1             NUMBER;
    l_Rut              NUMBER;
  BEGIN
    l_Itm         := 1;
    l_Dbg_Mensaje := 'Obtener data de SCFR_RECAUD_MOVIMIENTOS';
    l_Itm         := 1;
    FOR Rec IN Datos_Mov(p_Rut)
    LOOP
      BEGIN
        l_Trama_Fm(l_Itm).Codigo_Movimiento := Rec.Codigo_Movimiento;
        l_Trama_Fm(l_Itm).Fecha_Transaccion := To_Number(To_Char(Rec.Fecha_Movimiento
                                                                ,'yyyymmdd'));
        l_Trama_Fm(l_Itm).Movimiento_Padre := Rec.Movimiento_Padre;
        l_Trama_Fm(l_Itm).Codigo_Item := Rec.Codigo_Item;
      EXCEPTION
        WHEN OTHERS THEN
          Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                    ,p_Msg     => 'No se pudo cargar las Fechas de Movimientos=>' || p_Rut);
      END;
    END LOOP;
    RETURN l_Trama_Fm;
  EXCEPTION
    WHEN No_Data_Found THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'No se encontraron las Fechas de Movimientos ' || p_Rut);
      x_Cod_Error := 0;
      x_Msg_Error := NULL;
      RETURN l_Trama_Fm;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
      RETURN l_Trama_Fm;
  END Trama_Fm_Prepara;

  PROCEDURE Gncc05(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Rp    Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.GNCC05';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Cuerpo_Tx   BLOB;
    l_Largo_Ctx   NUMBER;
    l_Largo_Tot   NUMBER;
  BEGIN
    l_Dbg_Mensaje := 'Preparar datos para armar trama RP';
    IF p_Transaccion.Trama_Pos.Origen_Transaccion IN ('CCR'
                                                     ,'ISP'
                                                     ,'BOX'
                                                     ,'GLO'
                                                     ,'FEL'
                                                     ,'FAT'
                                                     ,'CIA'
                                                     ,'DEC') THEN
      l_Trama_Rp := Registro_Recetas_Pkg.Trama_Rp_Prepara(p_Transaccion
                                                         ,x_Cod_Error
                                                         ,x_Msg_Error);
    ELSE
      l_Trama_Rp := Trama_Rp_Prepara(p_Transaccion
                                    ,'TOT'
                                    ,x_Cod_Error
                                    ,x_Msg_Error);
    END IF;
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      l_Largo_Tot                                := Scfr_Trx_Dyn_Pk.Obtiene_Largo_Trama(Scfr_Trx_Dyn_Pk.k_Trama_Header_Boc);
      x_Respuesta                                := NULL;
      p_Transaccion.Trama_Pos.Largo_Total_Buffer := l_Largo_Tot;
      x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                  ,Scfr_Trx_Dyn_Pk.Arma_Trama_Pos(p_Transaccion));
      p_Transaccion.Trama_Boc.Codigo_Respuesta   := Nvl(x_Cod_Error
                                                       ,0);
      p_Transaccion.Trama_Boc.Largo_Total_Buffer := 0;
      x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                  ,Scfr_Trx_Dyn_Pk.Arma_Trama_Boc(p_Transaccion));
      x_Cod_Error                                := 0;
    ELSE
      l_Dbg_Mensaje                              := 'Armar cuerpo TX (trama RP)';
      l_Cuerpo_Tx                                := NULL;
      l_Cuerpo_Tx                                := Utl_Raw.Concat(l_Cuerpo_Tx
                                                                  ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Rp(l_Trama_Rp
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
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      IF Nvl(x_Cod_Error
            ,0) = 0 THEN
        x_Cod_Error := SQLCODE;
        x_Msg_Error := SQLERRM;
      END IF;
  END Gncc05;

  PROCEDURE Gncc06(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.gncc06()';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Trama_Tm         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Tm;
    l_Cuerpo_Tx        BLOB;
    l_Largo_Ctx        NUMBER;
    l_Largo_Tot        NUMBER;
    l_Error_Controlado EXCEPTION;
  BEGIN
    l_Dbg_Mensaje := 'Preparar datos para armar trama TR';
    l_Trama_Tm    := Trama_Tm_Prepara(p_Transaccion
                                     ,x_Cod_Error
                                     ,x_Msg_Error);
    IF Nvl(x_Cod_Error
          ,0) != 0 THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => l_Dbg_Mensaje || '.' || x_Cod_Error || '-' || x_Msg_Error);
    END IF;
    l_Dbg_Mensaje := 'Armar Respuesta (trama BOC)';
    IF l_Trama_Tm.Count > 0 THEN
      p_Transaccion.Trama_Boc.Codigo_Respuesta := 0;
      l_Dbg_Mensaje                            := 'Armar cuerpo TX (trama TM)';
      l_Cuerpo_Tx                              := NULL;
      l_Cuerpo_Tx                              := Utl_Raw.Concat(l_Cuerpo_Tx
                                                                ,Scfr_Trx_Dyn_Raw_Pk.Arma_Trama_Tm(l_Trama_Tm
                                                                                                  ,p_Transaccion.Trama_Pos.Origen_Transaccion));
      l_Largo_Ctx                              := Dbms_Lob.Getlength(l_Cuerpo_Tx);
    ELSE
      p_Transaccion.Trama_Boc.Codigo_Respuesta := 1;
      l_Cuerpo_Tx                              := NULL;
      l_Largo_Ctx                              := 0;
    END IF;
    l_Dbg_Mensaje                              := 'Determinar Largo de la trama';
    l_Largo_Tot                                := l_Largo_Ctx + Scfr_Trx_Dyn_Pk.Obtiene_Largo_Trama(Scfr_Trx_Dyn_Pk.k_Trama_Header_Boc);
    l_Dbg_Mensaje                              := 'Armar Respuesta (trama POS)';
    x_Respuesta                                := NULL;
    p_Transaccion.Trama_Pos.Largo_Total_Buffer := l_Largo_Tot;
    x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                ,Scfr_Trx_Dyn_Pk.Arma_Trama_Pos(p_Transaccion));
    p_Transaccion.Trama_Boc.Largo_Total_Buffer := l_Largo_Ctx;
    x_Respuesta                                := Utl_Raw.Concat(x_Respuesta
                                                                ,Scfr_Trx_Dyn_Pk.Arma_Trama_Boc(p_Transaccion));
    l_Dbg_Mensaje                              := 'Armar Respuesta (cuerpo TX)';
    IF p_Transaccion.Trama_Boc.Codigo_Respuesta = 0 THEN
      x_Respuesta := Utl_Raw.Concat(x_Respuesta
                                   ,l_Cuerpo_Tx);
    END IF;
    x_Cod_Error := 0; -- nunca devuelve un error oracle
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
  END Gncc06;

  -- function : devuelve_receta_central
  --    in :
  --       p_receta : ID de receta proveniente del POS
  --    Desc :
  --       Devuelve el ID central para la receta
  FUNCTION Devuelve_Receta_Central(p_Id_Receta_Pos IN NUMBER) RETURN NUMBER IS
    l_Receta NUMBER;
  BEGIN
    SELECT Id_Receta INTO l_Receta FROM Scfr_Rec_Recetas WHERE Secuencia_Receta = p_Id_Receta_Pos;
    RETURN l_Receta;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN p_Id_Receta_Pos;
  END Devuelve_Receta_Central;

  FUNCTION Producto_En_Receta(p_Receta   IN NUMBER
                             ,p_Producto IN NUMBER) RETURN BOOLEAN IS
    l_Aux NUMBER;
  BEGIN
    SELECT 1
      INTO l_Aux
      FROM Scfr_Rec_Productos
     WHERE Rec_Id_Receta = p_Receta
       AND Producto = p_Producto;
    IF l_Aux = 1 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END Producto_En_Receta;

  -- procedure : activa_producto
  --    in :
  --       p_receta_actual : ID de receta que se esta anulando
  --       p_rut_paciente  : Rut del paciente asociado a la receta
  --       p_producto      : codigo de producto
  --    out :
  --       --
  --    Desc :
  --       Deja en estado ACTivo un producto
  PROCEDURE Activa_Producto(p_Receta_Actual IN NUMBER
                           ,p_Producto      IN NUMBER) IS
    l_Dbg_Proceso  VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.activa_producto()';
    l_Dbg_Mensaje  VARCHAR2(250) := 'Error General';
    l_Rut_Paciente Scfr_Rec_Recetas.Rut_Paciente%TYPE;
  BEGIN
    l_Dbg_Mensaje := 'Determinar Rut del Paciente';
    BEGIN
      SELECT Rut_Paciente INTO l_Rut_Paciente FROM Scfr_Rec_Recetas WHERE Id_Receta = p_Receta_Actual;
    EXCEPTION
      WHEN OTHERS THEN
        l_Rut_Paciente := NULL;
    END;
    l_Dbg_Mensaje := 'Actualizar estado de Productos dejarlo ACTIVO';
    UPDATE Scfr_Rec_Productos
       SET Estado_Producto = 'ACT'
     WHERE Rec_Id_Receta <> p_Receta_Actual
       AND Producto = p_Producto
       AND Rec_Id_Receta IN (SELECT Id_Receta
                               FROM Scfr_Rec_Recetas
                              WHERE Rut_Paciente = l_Rut_Paciente
                                AND Estado_Receta = 'ABI')
       AND Estado_Producto = 'INA';
    IF SQL%NOTFOUND THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'No se pudo ' || l_Dbg_Mensaje);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
  END Activa_Producto;

  -- function : obtiene_numero_boleta
  --    in :
  --       p_trama_dv : Trama de Documentos de Venta de la reversa (gncu02)
  --    out :
  --       --
  --    Desc :
  --       Devuelve el numero de la boleta que se esta anulando
  FUNCTION Obtiene_Numero_Boleta(p_Trama_Dv IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv) RETURN NUMBER IS
    l_Boleta NUMBER;
  BEGIN
    FOR l_Itm IN 1 .. p_Trama_Dv.Subtrama_Dv1.Count
    LOOP
      IF p_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Movimiento_Hijo = 'ANUBOL' THEN
        l_Boleta := p_Trama_Dv.Subtrama_Dv1(l_Itm).Folio;
        EXIT;
      END IF;
    END LOOP;
    RETURN l_Boleta;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END Obtiene_Numero_Boleta;

  -- procedure : registra_en_cta_cte_recetas
  --    in :
  --       p_transaccion : ID de receta proveniente del POS
  --       p_tipo        : Indicador de accion (REGistro / RETiro / REVersa )
  --    out :
  --       x_cod_error : Codigo de retorno (0 sin error)
  --       x_msg_error : Mensaje de error si corresponde
  --    Desc :
  --       Realiza un registro en la Cartola de Cuenta Cte. de Recetas
  PROCEDURE Registra_En_Cta_Cte_Recetas(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                       ,p_Tipo        IN VARCHAR2
                                       ,x_Cod_Error   OUT NUMBER
                                       ,x_Msg_Error   OUT VARCHAR2) IS
    CURSOR c_Prods(p_Movimiento IN NUMBER
                  ,p_Boleta     IN NUMBER) IS
      SELECT Producto
            ,Cant_Uni_Venta
            ,Cant_Pills
            ,Boleta
        FROM Scfr_Rec_Mov_Productos
       WHERE Cce_Id_Movimiento = p_Movimiento
         AND Boleta = p_Boleta;
    l_Trama_Rp        Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp;
    l_Id_Movimiento   Scfr_Rec_Movimientos.Id_Movimiento%TYPE;
    l_Tipo            Scfr_Rec_Movimientos.Tipo_Movimiento%TYPE;
    l_Trama_Pm        Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm;
    l_Movimientos     Tab_Movimientos;
    l_Itm             NUMBER;
    l_Receta          NUMBER;
    l_Cant_Uni_Vta    NUMBER;
    l_Cant_Pills      NUMBER;
    l_Boleta          NUMBER;
    l_Mov             NUMBER;
    l_Itm             NUMBER;
    l_Receta_Aux      NUMBER;
    l_Movimiento      Reg_Movimiento;
    l_Mov_Producto    Reg_Mov_Producto;
    l_Dbg_Proceso     VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.registra_en_cta_cte_recetas()';
    l_Dbg_Mensaje     VARCHAR2(250) := 'Error General';
    l_Error           NUMBER;
    l_Msg             VARCHAR2(1000);
    l_Id_Detalle      NUMBER;
    l_Trama_Dv        Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv;
    l_Codigo_Tx_Venta NUMBER;
    l_Local           NUMBER;
    l_Fecha           DATE;
    l_Txo_Codigo_Tx   NUMBER;
    l_Rec_Id_Receta   NUMBER;
    l_Id_Mov_Original NUMBER;
    l_Cod_Error       NUMBER;
    l_Msg_Error       VARCHAR2(1000);
  BEGIN
    IF p_Transaccion.Trama_Pos.Origen_Transaccion NOT IN ('DTE'
                                                         ,'BNM'
                                                         ,'PRM'
                                                         ,'FEC'
                                                         ,'FJC'
                                                         ,'PRE'
                                                         ,'MAG') THEN
      -- cambia CCR por REC
      x_Cod_Error := 0;
      x_Msg_Error := NULL;
      RETURN;
    END IF;
    IF p_Tipo = k_Registro_Receta THEN
      -- Obtiene informacion de la trama RP
      l_Dbg_Mensaje := 'Obtener informacion de la trama RP para un Registro';
      l_Trama_Rp    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Rp9(p_Transaccion.Cuerpo_Tx);
      l_Dbg_Mensaje := 'Obtener el correlativo de la receta desde scfr_rec_recetas para un registro';
      BEGIN
        SELECT Id_Receta INTO l_Receta FROM Scfr_Rec_Recetas WHERE Secuencia_Receta = l_Trama_Rp(1).Secuencia_Receta;
      EXCEPTION
        WHEN OTHERS THEN
          l_Receta := NULL;
          RETURN;
      END;
      l_Dbg_Mensaje := 'Prepara la data para insertar el movimiento de Registro';
      Prepara_Datos_Movimiento(l_Movimiento
                              ,l_Receta
                              ,p_Tipo
                              ,p_Transaccion);
      l_Dbg_Mensaje   := 'Insertar en la tabla scfr_rec_movimientos un Registro';
      l_Id_Movimiento := Inserta_Movimiento(l_Movimiento
                                           ,l_Error
                                           ,l_Msg);
      IF l_Error <> 0 THEN
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - ' || l_Msg);
      END IF;
      l_Dbg_Mensaje := 'Recorrer productos receta (RP1) para un Registro';
      FOR l_Itm IN 1 .. l_Trama_Rp(1).Subtrama_Rp1.Count
      LOOP
        BEGIN
          l_Dbg_Mensaje := 'Obtener la cant. de "envases" para un Registro';
          BEGIN
            IF Nvl(l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Cantidad
                  ,0) = 0 THEN
              l_Cant_Uni_Vta := Devuelve_Cantidad(l_Trama_Rp
                                                 ,l_Itm);
            ELSE
              l_Cant_Uni_Vta := l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Cantidad;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              l_Cant_Uni_Vta := NULL;
          END;
          l_Dbg_Mensaje := 'Obtener la cantidad de pills para un Registro';
          BEGIN
            IF Nvl(l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Cantidad
                  ,0) = 0 THEN
              l_Cant_Pills := Devuelve_Cantidad(l_Trama_Rp
                                               ,l_Itm);
            ELSE
              l_Cant_Pills := l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Cantidad;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              l_Cant_Pills := NULL;
          END;
          l_Dbg_Mensaje := 'Obtener el numero de boleta para un Registro';
          l_Boleta      := Obtiene_Numero_Boleta(p_Transaccion.Codigo_Tx
                                                ,l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Producto);
          l_Dbg_Mensaje := 'Preparar la data para insertar el producto del movimiento para un Registro';
          Prepara_Datos_Mov_Producto(l_Mov_Producto
                                    ,l_Id_Movimiento
                                    ,l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Producto
                                    ,l_Cant_Uni_Vta
                                    ,l_Cant_Pills
                                    ,l_Boleta);
          l_Dbg_Mensaje := 'Insertar en la tabla scfr_rec_mov_productos para un Registro';
          Inserta_Mov_Producto(l_Mov_Producto
                              ,l_Error
                              ,l_Msg);
          IF l_Error <> 0 THEN
            Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                      ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - ' || l_Msg);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                      ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
        END;
      END LOOP;
    ELSIF p_Tipo = k_Retiro_Receta THEN
      -- el POS debe informar la referencia a la receta a nivel de productos
      -- Cargar trama PM
      l_Dbg_Mensaje := 'Cargar la trama PM para un Retiro';
      l_Trama_Pm    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Pm(p_Transaccion.Trama_Pos
                                                         ,p_Transaccion.Cuerpo_Tx);
      -- Llenar arreglo con Secuencias de Recetas informadas en trama PM
      l_Dbg_Mensaje := 'Llenar el arreglo de secuencias indicadas en la trama PM para un Retiro';
      /*
      l_mov := 1;
      for l_itm in 1..l_trama_pm.count loop
        if l_trama_pm(l_itm).secuencia_receta_relacionada is not null then
          if l_trama_pm(l_itm).secuencia_receta_relacionada <> nvl( l_receta_aux , 0 ) then
            l_movimientos(l_mov).secuencia_receta := l_trama_pm(l_itm).secuencia_receta_relacionada;
            l_mov := l_mov + 1;
          end if;
        end if;
        l_receta_aux := l_trama_pm(l_itm).secuencia_receta_relacionada;
      end loop;
      */
      l_Movimientos := Devuelve_Recetas_Pm(l_Trama_Pm);
      /* SJC: Se recorren solo si l_movimientos es mayor a cero                      */
      IF l_Movimientos.Count > 0 THEN
        -- Recorrer Recetas informadas
        l_Dbg_Mensaje := 'Recorrer las secuencias de recetas informadas para un Retiro';
        FOR l_Mov IN 1 .. l_Movimientos.Count
        LOOP
          l_Receta      := Devuelve_Receta_Central(l_Movimientos(l_Mov).Secuencia_Receta);
          l_Dbg_Mensaje := 'Preparar datos del movimiento para un Retiro';
          Prepara_Datos_Movimiento(l_Movimiento
                                  ,l_Receta
                                  ,p_Tipo
                                  ,p_Transaccion);
          l_Dbg_Mensaje   := 'Insertar el movimiento en scfr_rec_movimientos para un Retiro';
          l_Id_Movimiento := Inserta_Movimiento(l_Movimiento
                                               ,l_Error
                                               ,l_Msg);
          IF l_Error <> 0 THEN
            Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                      ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - ' || l_Msg);
          END IF;
          l_Dbg_Mensaje := 'Recorrer productos receta referenciada en cierre de venta para un Retiro';
          FOR l_Itm IN 1 .. l_Trama_Pm.Count
          LOOP
            BEGIN
              IF l_Trama_Pm(l_Itm).Secuencia_Receta_Relacionada = l_Movimientos(l_Mov).Secuencia_Receta AND
                  Producto_En_Receta(l_Receta
                                    ,l_Trama_Pm(l_Itm).Producto) THEN
                l_Dbg_Mensaje := 'Obtener la cant. de "envases" para un Retiro';
                BEGIN
                  l_Cant_Uni_Vta := l_Trama_Pm(l_Itm).Cantidad;
                EXCEPTION
                  WHEN OTHERS THEN
                    l_Cant_Uni_Vta := NULL;
                END;
                l_Dbg_Mensaje := 'Obtener la cantidad de pills para un Retiro';
                BEGIN
                  l_Cant_Pills := l_Trama_Pm(l_Itm).Cantidad;
                EXCEPTION
                  WHEN OTHERS THEN
                    l_Cant_Pills := NULL;
                END;
                l_Dbg_Mensaje := 'Obtener el numero de boleta para un Retiro';
                l_Boleta      := Obtiene_Numero_Boleta(p_Transaccion.Codigo_Tx
                                                      ,l_Trama_Pm(l_Itm).Producto);
                l_Dbg_Mensaje := 'Preperar la data para registrar el producto del movimiento para un Retiro';
                Prepara_Datos_Mov_Producto(l_Mov_Producto
                                          ,l_Id_Movimiento
                                          ,l_Trama_Pm(l_Itm).Producto
                                          ,l_Cant_Uni_Vta
                                          ,l_Cant_Pills
                                          ,l_Boleta);
                l_Dbg_Mensaje := 'Insertar en la tabla scfr_rec_mov_productos el producto ' || l_Trama_Pm(l_Itm).Producto || ' para un Retiro';
                Inserta_Mov_Producto(l_Mov_Producto
                                    ,l_Error
                                    ,l_Msg);
                IF l_Error <> 0 THEN
                  Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                            ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - ' || l_Msg);
                END IF;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                          ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
            END;
          END LOOP;
        END LOOP;
      END IF;
      -- Setea estado receta
      l_Dbg_Mensaje := 'Setear el estado de la receta';
      Setea_Estado_Receta(l_Receta
                         ,l_Cod_Error
                         ,l_Msg_Error);
      IF l_Cod_Error <> 0 THEN
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - ' || l_Msg);
      END IF;
    ELSIF p_Tipo = k_Reversa_Receta THEN
      l_Dbg_Mensaje := 'Obtener el codigo_tx de la venta a reversar';
      BEGIN
        SELECT Txo_Codigo_Tx_Relacionado INTO l_Codigo_Tx_Venta FROM Scfr_Mov_Transacciones WHERE Codigo_Tx = p_Transaccion.Codigo_Tx;
      EXCEPTION
        WHEN OTHERS THEN
          l_Codigo_Tx_Venta := NULL;
      END;
      l_Dbg_Mensaje := 'Obtener Movimiento asociado a la venta a reversar ' || p_Transaccion.Codigo_Tx;
      BEGIN
        SELECT LOCAL
              ,Fecha
              ,Txo_Codigo_Tx
              ,Rec_Id_Receta
              ,Id_Movimiento
          INTO l_Local
              ,l_Fecha
              ,l_Txo_Codigo_Tx
              ,l_Rec_Id_Receta
              ,l_Id_Mov_Original
          FROM Scfr_Rec_Movimientos
         WHERE Txo_Codigo_Tx = l_Codigo_Tx_Venta
           AND Tipo_Movimiento = 'RET';
      EXCEPTION
        WHEN OTHERS THEN
          l_Local           := NULL;
          l_Fecha           := NULL;
          l_Txo_Codigo_Tx   := NULL;
          l_Rec_Id_Receta   := NULL;
          l_Id_Mov_Original := NULL;
      END;
      l_Dbg_Mensaje                := 'Preparar la data del movimiento para una Reversa ' || l_Codigo_Tx_Venta;
      l_Movimiento.Rec_Id_Receta   := l_Rec_Id_Receta;
      l_Movimiento.Fecha           := l_Fecha;
      l_Movimiento.Tipo_Movimiento := p_Tipo;
      l_Movimiento.Local           := l_Local;
      l_Movimiento.Txo_Codigo_Tx   := l_Txo_Codigo_Tx;
      l_Dbg_Mensaje                := 'Insertar en la tabla scfr_rec_movimientos para una Reversa ' || l_Codigo_Tx_Venta;
      l_Id_Movimiento              := Inserta_Movimiento(l_Movimiento
                                                        ,l_Error
                                                        ,l_Msg);
      IF l_Error <> 0 THEN
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - ' || l_Msg);
      END IF;
      -- Obtiene informacion de la trama DV
      l_Dbg_Mensaje := 'Obtener informacion de la trama DV para una Reversa';
      l_Trama_Dv    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Dv(p_Transaccion.Trama_Pos
                                                         ,p_Transaccion.Cuerpo_Tx);
      l_Dbg_Mensaje := 'Obtener el datos del numero de boleta para una Reversa';
      --l_Boleta := Obtiene_Numero_Boleta(l_Trama_Dv);
      -- Cambiado por ESG 05/08/2014
      l_Boleta := Obtiene_Numero_Boleta(l_Codigo_Tx_Venta);
      FOR Prods IN c_Prods(l_Id_Mov_Original
                          ,l_Boleta)
      LOOP
        l_Dbg_Mensaje                    := 'Preparar la data del producto del movimiento para una Reversa';
        l_Mov_Producto.Cce_Id_Movimiento := l_Id_Movimiento;
        l_Mov_Producto.Producto          := Prods.Producto;
        l_Mov_Producto.Cant_Uni_Venta    := Prods.Cant_Uni_Venta;
        l_Mov_Producto.Cant_Pills        := Prods.Cant_Pills;
        l_Mov_Producto.Boleta            := Prods.Boleta;
        l_Dbg_Mensaje                    := 'Insertar en la tabla scfr_rec_mov_productos el producto ' || Prods.Producto || '  para una Reversa';
        Inserta_Mov_Producto(l_Mov_Producto
                            ,l_Error
                            ,l_Msg);
        IF l_Error <> 0 THEN
          Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                    ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - ' || l_Msg);
        END IF;
        Activa_Producto(p_Receta_Actual => l_Rec_Id_Receta
                       ,p_Producto      => Prods.Producto);
      END LOOP;
      -- Setea estado receta
      l_Dbg_Mensaje := 'Setear el estado de la receta';
      Setea_Estado_Receta(l_Rec_Id_Receta
                         ,l_Cod_Error
                         ,l_Msg_Error);
      IF l_Cod_Error <> 0 THEN
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - ' || l_Msg);
      END IF;
    END IF;
    x_Cod_Error := 0;
    x_Msg_Error := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := 0;
      x_Msg_Error := NULL;
  END Registra_En_Cta_Cte_Recetas;

  PROCEDURE Arma_Trama_Dv_Desde_Dr(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                  ,x_Trama_Dv    OUT Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                                  ,x_Cod_Error   OUT NUMBER
                                  ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Dr    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dr;
    l_Trama_Dv    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_GNC_PK.arma_trama_dv_desde_dr';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
  BEGIN
    x_Cod_Error                        := 0;
    x_Msg_Error                        := NULL;
    l_Dbg_Mensaje                      := 'Cargar trama DR';
    l_Trama_Dr                         := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Dr(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje                      := 'Cargar trama DV a partir de la trama DR';
    x_Trama_Dv.Correlativo_Tx          := l_Trama_Dr.Correlativo_Tx;
    x_Trama_Dv.Correlativo_Tx_Asociado := l_Trama_Dr.Secuencia_b;
    x_Trama_Dv.Tipo_Movimiento_Padre   := l_Trama_Dr.Tipo_Movimiento_Padre;
    x_Trama_Dv.Fecha                   := l_Trama_Dr.Fecha;
    x_Trama_Dv.Hora_Venta              := l_Trama_Dr.Hora_Recaudacion;
    x_Trama_Dv.Local                   := l_Trama_Dr.Local;
    x_Trama_Dv.Ot                      := l_Trama_Dr.Ot;
    x_Trama_Dv.Documentos_Emitidos     := l_Trama_Dr.Subtrama_Dr1.Count;
    l_Dbg_Mensaje                      := 'Carga Docs. emitidos trama DV a partir de la trama DR ';
    FOR l_Itm IN 1 .. l_Trama_Dr.Subtrama_Dr1.Count
    LOOP
      x_Trama_Dv.Subtrama_Dv1(l_Itm).Secuencia_b := l_Trama_Dr.Subtrama_Dr1(l_Itm).Secuencia_b;
      x_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Movimiento_Hijo := l_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Movimiento_Hijo;
      x_Trama_Dv.Subtrama_Dv1(l_Itm).Numero_Asignacion := l_Trama_Dr.Subtrama_Dr1(l_Itm).Numero_Asignacion;
      x_Trama_Dv.Subtrama_Dv1(l_Itm).Anulado := l_Trama_Dr.Subtrama_Dr1(l_Itm).Anulado;
      x_Trama_Dv.Subtrama_Dv1(l_Itm).Folio := l_Trama_Dr.Subtrama_Dr1(l_Itm).Folio;
      x_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Dicc := l_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Dicc;
      x_Trama_Dv.Subtrama_Dv1(l_Itm).Folio_Dicc := l_Trama_Dr.Subtrama_Dr1(l_Itm).Folio_Dicc;
      x_Trama_Dv.Subtrama_Dv1(l_Itm).Total_Iva_Incluido := l_Trama_Dr.Subtrama_Dr1(l_Itm).Total_Iva_Incluido;
      x_Trama_Dv.Subtrama_Dv1(l_Itm).Iva := l_Trama_Dr.Subtrama_Dr1(l_Itm).Iva;
      x_Trama_Dv.Subtrama_Dv1(l_Itm).Puntos_Asignados := l_Trama_Dr.Subtrama_Dr1(l_Itm).Puntos_Asignados;
      x_Trama_Dv.Subtrama_Dv1(l_Itm).Tipo_Distribucion := l_Trama_Dr.Subtrama_Dr1(l_Itm).Tipo_Distribucion;
      x_Trama_Dv.Subtrama_Dv1(l_Itm).Campana := l_Trama_Dr.Subtrama_Dr1(l_Itm).Campana;
      x_Trama_Dv.Subtrama_Dv1(l_Itm).Secuencia_Financiamiento := l_Trama_Dr.Subtrama_Dr1(l_Itm).Secuencia_Financiamiento;
      x_Trama_Dv.Subtrama_Dv1(l_Itm).Documento_Fiscal := l_Trama_Dr.Subtrama_Dr1(l_Itm).Documento_Fiscal;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
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

  FUNCTION Complementa_Trama_Ca(l_Trama_Ca  IN OUT Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ca
                               ,p_Party_Id  IN NUMBER
                               ,x_Cod_Error OUT NUMBER
                               ,x_Msg_Error OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ca IS
    CURSOR c_Campanas_Control IS
      SELECT Cam_Campana
        FROM Scfr_Control_Frecuencia
       WHERE Pt_Party_Id = p_Party_Id
         AND Scfr_Trx_Gnc_Utl_Pk.Esta_Vigente(Cam_Campana) = 'ACT';
    --and tiene_control_frecuencia( p_campana ) = 'SI';
    l_Periodo         NUMBER;
    l_Restric_Min     NUMBER;
    l_Resultado       NUMBER;
    l_Eventos         NUMBER;
    l_Eventos_Suman   NUMBER;
    l_Eventos_Restan  NUMBER;
    l_Restric_Eventos NUMBER;
    l_Aplica          VARCHAR2(2);
    l_Dbg_Proceso     VARCHAR2(100) := 'SCFR_TRX_GNC_PK.complementa_trama_ca';
    l_Dbg_Mensaje     VARCHAR2(250) := 'Error General';
  BEGIN
    x_Cod_Error   := 0;
    x_Msg_Error   := NULL;
    l_Dbg_Mensaje := 'Recorrer las campanas posibles';
    FOR Campanas IN c_Campanas_Control
    LOOP
      BEGIN
        l_Dbg_Mensaje := 'Obtener el periodo (en dias) a evaluar';
        BEGIN
          SELECT Nvl(Restriccion_Minima
                    ,0) -- - 1
            INTO l_Periodo
            FROM Scfr_Condiciones
           WHERE Cam_Campana = Campanas.Cam_Campana
             AND Tipo_Condicion = 'DEV';
        EXCEPTION
          WHEN No_Data_Found THEN
            l_Periodo := 0;
            Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                      ,p_Msg     => l_Dbg_Mensaje || '. No hay datos para Campana ' || Campanas.Cam_Campana || '/DEV');
          WHEN OTHERS THEN
            l_Periodo := 0;
            Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                      ,p_Msg     => l_Dbg_Mensaje || '. ' || SQLERRM);
        END;
        IF l_Periodo > 0 THEN
          l_Dbg_Mensaje := 'Obtener la cantidad de eventos definidos para el periodo';
          BEGIN
            SELECT Nvl(Restriccion_Minima
                      ,0)
              INTO l_Restric_Eventos
              FROM Scfr_Condiciones
             WHERE Cam_Campana = Campanas.Cam_Campana
               AND Tipo_Condicion = 'EVE';
          EXCEPTION
            WHEN No_Data_Found THEN
              l_Restric_Eventos := 0;
              Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                        ,p_Msg     => l_Dbg_Mensaje || '. No hay datos para Campana ' || Campanas.Cam_Campana || '/EVE');
            WHEN OTHERS THEN
              l_Restric_Eventos := 0;
              Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                        ,p_Msg     => l_Dbg_Mensaje || '. ' || SQLERRM);
          END;
          l_Dbg_Mensaje := 'Obtener la cantidad de eventos que suman';
          BEGIN
            SELECT COUNT(*)
              INTO l_Eventos_Suman
              FROM Scfr_Control_Frecuencia
             WHERE Cam_Campana = Campanas.Cam_Campana
               AND Pt_Party_Id = p_Party_Id
               AND Tipo_Movimiento_Frecuencia IN ('COM'
                                                 ,'AJP')
               AND Trunc(Fecha_Venta) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) - (l_Periodo - 1)
               AND Trunc(Fecha_Venta) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate());
          EXCEPTION
            WHEN OTHERS THEN
              l_Eventos_Suman := 0;
          END;
          l_Dbg_Mensaje := 'Obtener la cantidad de eventos que restan';
          BEGIN
            SELECT COUNT(*)
              INTO l_Eventos_Restan
              FROM Scfr_Control_Frecuencia
             WHERE Cam_Campana = Campanas.Cam_Campana
               AND Pt_Party_Id = p_Party_Id
               AND Tipo_Movimiento_Frecuencia IN ('REV'
                                                 ,'AJN')
               AND Trunc(Fecha_Venta) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate()) - (l_Periodo - 1)
               AND Trunc(Fecha_Venta) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate());
          EXCEPTION
            WHEN OTHERS THEN
              l_Eventos_Restan := 0;
          END;
          l_Dbg_Mensaje := 'Obtener la cantidad de eventos efectivos a evaluar';
          l_Eventos     := l_Eventos_Suman - l_Eventos_Restan;
          l_Aplica      := 'NO';
          IF l_Eventos < l_Restric_Eventos THEN
            l_Aplica := 'SI';
          END IF;
          l_Dbg_Mensaje := 'Actualizar la trama CA';
          l_Resultado   := Actualiza_Trama_Ca(l_Trama_Ca
                                             ,Campanas.Cam_Campana
                                             ,l_Aplica);
          IF l_Resultado != 0 THEN
            Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                      ,p_Msg     => l_Dbg_Mensaje || '. Problemas al ejecutar actualiza_trama_ca');
          END IF;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                    ,p_Msg     => l_Dbg_Mensaje);
      END;
    END LOOP;
    RETURN l_Trama_Ca;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_Trama_Ca;
  END;

  FUNCTION Devuelve_Party_Beneficiario(p_Rut_Beneficiario IN NUMBER
                                      ,p_Party_Id         IN NUMBER) RETURN NUMBER IS
    l_Party NUMBER;
  BEGIN
    SELECT Party_Id INTO l_Party FROM Hz_Parties WHERE Jgzz_Fiscal_Code = Rtrim(Ltrim(To_Char(p_Rut_Beneficiario)));
    RETURN l_Party;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN p_Party_Id;
  END Devuelve_Party_Beneficiario;

  PROCEDURE Trama_De_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_De         Scfr_Trx_Dyn_Types_Pk.Rec_Trama_De;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.trama_de_resuelve';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    x_Cod_Error := 0;
    -- Obtiene informacion de la trama RP
    l_Dbg_Mensaje := 'Obtener informacion de la trama DE';
    l_Trama_De    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_De(p_Transaccion.Cuerpo_Tx);
    -- No se genera error desde este punto
    x_Cod_Error := 0;
    x_Msg_Error := NULL;
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := 0;
      x_Msg_Error := NULL;
  END;

  FUNCTION Dueno_Local(p_Empresa IN NUMBER
                      ,p_Cadena  IN NUMBER
                      ,p_Local   IN NUMBER) RETURN NUMBER IS
    l_Party_Id NUMBER;
  BEGIN
    SELECT Party_Id_Dueno
      INTO l_Party_Id
      FROM Scfr_Locales_v
     WHERE Org_Id = p_Empresa
       AND Numero_Cadena = p_Cadena
       AND Numero = p_Local;
    RETURN l_Party_Id;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION Obtiene_Campana_Puntos(p_Empresa IN NUMBER
                                 ,p_Cadena  IN NUMBER) RETURN NUMBER IS
    l_Campana NUMBER;
  BEGIN
    SELECT /*+index(scfr_campanas scfr_campanas_n2) */
     Campana
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
                            ,p_Party_Vendedor IN NUMBER) RETURN VARCHAR2 IS
    l_String         VARCHAR2(1000);
    l_Ptos_Ganados   NUMBER;
    l_Ptos_Canjeados NUMBER;
  BEGIN
    l_Ptos_Ganados   := 0;
    l_Ptos_Canjeados := 0;
    IF p_Accion_Puntos = 'CAN' THEN
      l_Ptos_Canjeados := p_Total_Puntos;
    ELSE
      l_Ptos_Ganados := p_Total_Puntos;
    END IF;
    l_String := p_Accion_Puntos || Ltrim(Rtrim(To_Char(p_Party_Id
                                                      ,'0000000009'))) ||
                Ltrim(Rtrim(To_Char(p_Monto_Original
                                   ,'0000000009'))) || Ltrim(Rtrim(To_Char(l_Ptos_Ganados
                                                                          ,'0000000009'))) ||
                Ltrim(Rtrim(To_Char(p_Codigo_Tx
                                   ,'00000000000000000009'))) || Ltrim(Rtrim(To_Char(p_Campana
                                                                                    ,'0000000009'))) ||
                Ltrim(Rtrim(To_Char(l_Ptos_Canjeados
                                   ,'0000000009'))) || Ltrim(Rtrim(To_Char(p_Folio_Docto
                                                                          ,'00000000000000000009'))) ||
                Ltrim(Rtrim(To_Char(p_Empresa
                                   ,'00009'))) || Ltrim(Rtrim(To_Char(p_Cadena
                                                                     ,'00009'))) ||
                Ltrim(Rtrim(To_Char(p_Local
                                   ,'00009'))) || Ltrim(Rtrim(To_Char(p_Party_Vendedor
                                                                     ,'0000000009')));
    RETURN l_String;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION Determina_Accion_Puntos(p_Party_Id IN NUMBER) RETURN VARCHAR2 IS
    l_Accion_Puntos VARCHAR2(3);
  BEGIN
    -- determino aqui si este cliente dona puntos o no, lo cual sera util mas adelante
    SELECT 'DON'
      INTO l_Accion_Puntos
      FROM Scfr_Red_Puntos
     WHERE Pt_Party_Id = p_Party_Id
       AND Pt_Party_Donante IS NOT NULL
       AND Trunc(Nvl(Fecha_Activacion_Donacion
                    ,Scfr_Trx_Util_Pk.Get_Sysdate())) <= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate())
       AND Trunc(Nvl(Fecha_Termino_Donacion
                    ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(Scfr_Trx_Util_Pk.Get_Sysdate());
    RETURN l_Accion_Puntos;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'APG';
  END;

  FUNCTION Obtiene_Id_Productos_Doctos(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                      ,p_Trama_Pm    IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pm) RETURN NUMBER IS
    l_Mov_Prod_Doctos  NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.obtiene_id_productos_doctos';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    -- Se debe buscar el primer documento referenciado (menos VENDIC)
    -- al producto y asignarle los puntos.
    l_Dbg_Mensaje := 'Busca el primer documento referenciado al producto (menos VENDIC)';
    SELECT /*+ index (mpd mov_productos_documentos_N1) */
     Mpd.Mov_Productos_Documentos
      INTO l_Mov_Prod_Doctos
      FROM Scfr_Mov_Productos_Documentos Mpd
          ,Scfr_Mov_Documentos_Txs       Mdo
     WHERE Mpd.Txo_Codigo_Tx = p_Transaccion.Codigo_Tx
       AND Mpd.Pro_Codigo_Interno = p_Trama_Pm.Producto
       AND Mpd.Dte_Mov_Documentos = Mdo.Mov_Documentos
       AND Mdo.Puntos_Asignados = 'S' -- Solo los documentos que SI asignen puntos
       AND Mdo.Tmo_Movimiento != 'VENDIC' -- Excluye el documento VENDIC de la lista de documentos
       AND Rownum = 1 -- Obtiene SOLO el primer documento referenciado al producto
     ORDER BY Mpd.Mov_Productos_Documentos; -- Ordena los documentos para poder obtener el primero
    RETURN l_Mov_Prod_Doctos;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  FUNCTION Obtiene_Folio_Docto(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                              ,p_Trama_Pm    IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pm) RETURN NUMBER IS
    l_Folio_Docto      NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.obtiene_id_mov_doctos';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
  BEGIN
    SELECT /*+index (mpd scfr_mov_productos_documentos SCFR_PRODUCTOS_DOCUMENTOS_N1)*/
     Mdo.Folio
      INTO l_Folio_Docto
      FROM Scfr_Mov_Productos_Documentos Mpd
          ,Scfr_Mov_Documentos_Txs       Mdo
     WHERE Mpd.Txo_Codigo_Tx = p_Transaccion.Codigo_Tx
       AND Mpd.Pro_Codigo_Interno = p_Trama_Pm.Producto
       AND Mpd.Dte_Mov_Documentos = Mdo.Mov_Documentos
       AND Mdo.Tmo_Movimiento != 'VENDIC' -- Excluye el documento VENDIC de la lista de documentos
       AND Rownum = 1 -- Obtiene SOLO el primer documento referenciado al producto
     ORDER BY Mpd.Mov_Productos_Documentos;
    RETURN l_Folio_Docto;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  FUNCTION Ordena_Productos(p_Trama_Pm IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm) RETURN Scfr_Trx_Gnc_Pk.Tab_Productos IS
    l_Itm             NUMBER;
    l_Itm2            NUMBER;
    l_Itm3            NUMBER;
    l_Itm4            NUMBER;
    l_Prod_Sin_Desc   Scfr_Trx_Gnc_Pk.Tab_Productos;
    l_Prod_Con_Desc   Scfr_Trx_Gnc_Pk.Tab_Productos;
    l_Prod_Ordenados  Scfr_Trx_Gnc_Pk.Tab_Productos;
    l_Prod_Tiene_Desc BOOLEAN;
  BEGIN
    l_Itm3 := 1;
    l_Itm4 := 1;
    -- recorre detalle de productos
    FOR l_Itm IN 1 .. p_Trama_Pm.Count
    LOOP
      -- recorre detalle de descuentos por producto
      l_Prod_Tiene_Desc := FALSE;
      FOR l_Itm2 IN 1 .. p_Trama_Pm(l_Itm).Subtrama_Pm2.Count
      LOOP
        -- cheque si el descuento contiene detalle de ciclos.
        IF Length(Ltrim(Rtrim(p_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Detalle_Descuento_Producto))) > 2 THEN
          l_Prod_Tiene_Desc := TRUE;
          EXIT;
        END IF;
      END LOOP;
      IF l_Prod_Tiene_Desc THEN
        -- guarda el indice de la trama PM en arreglo de productos con descuento
        l_Prod_Con_Desc(l_Itm3) := l_Itm;
        l_Itm3 := l_Itm3 + 1;
      ELSE
        -- guarda el indice de la trama PM en arreglo de productos sin descuento
        l_Prod_Sin_Desc(l_Itm4) := l_Itm;
        l_Itm4 := l_Itm4 + 1;
      END IF;
    END LOOP;
    -- prepara arreglo con indices de la trama PM, dejando los productos sin descuento primero
    l_Itm2 := 1;
    FOR l_Itm IN 1 .. l_Prod_Sin_Desc.Count
    LOOP
      l_Prod_Ordenados(l_Itm2) := l_Prod_Sin_Desc(l_Itm);
      l_Itm2 := l_Itm2 + 1;
    END LOOP;
    -- luego agrega al arreglo los indices de la trama PM con los productos con descuento.
    FOR l_Itm IN 1 .. l_Prod_Con_Desc.Count
    LOOP
      l_Prod_Ordenados(l_Itm2) := l_Prod_Con_Desc(l_Itm);
      l_Itm2 := l_Itm2 + 1;
    END LOOP;
    RETURN l_Prod_Ordenados;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_Prod_Ordenados;
  END;

  FUNCTION Tiene_Control_Frecuencia(p_Campana IN NUMBER) RETURN VARCHAR2 IS
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_GNC_PK.tiene_control_frecuencia';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Condicion   VARCHAR2(2);
  BEGIN
    SELECT 'SI'
      INTO l_Condicion
      FROM Scfr_Condiciones
     WHERE Cam_Campana = p_Campana
       AND Tipo_Condicion = 'EVE';
    RETURN l_Condicion;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'NO';
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => l_Dbg_Mensaje);
  END;

  FUNCTION Campanas_Frecuencias(p_Campana       IN NUMBER
                               ,p_Party_Id      IN NUMBER
                               ,p_Rut_Cliente   IN NUMBER
                               ,p_Codigo_Tx     IN NUMBER
                               ,p_Fecha_Venta   IN DATE
                               ,p_Tipo_Mov_Frec IN VARCHAR2) RETURN NUMBER IS
    l_Activa      VARCHAR2(3) := 'NAC';
    l_Condicion   VARCHAR2(2);
    l_Existe      NUMBER;
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_GNC_PK.campanas_frecuencias';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
  BEGIN
    l_Dbg_Mensaje := 'Determinar vigencia de la campana ' || p_Campana;
    l_Activa      := Esta_Vigente(p_Campana);
    IF l_Activa = 'ACT' THEN
      l_Dbg_Mensaje := 'Determinar si hay control de frecuencia para la campana ' || p_Campana;
      l_Condicion   := Tiene_Control_Frecuencia(p_Campana);
      IF l_Condicion = 'SI' THEN
        BEGIN
          l_Dbg_Mensaje := 'Determinar si ya existe la ocurrencia de la campana/party/transaccion';
          SELECT 1
            INTO l_Existe
            FROM Scfr_Control_Frecuencia
           WHERE Cam_Campana = p_Campana
             AND Pt_Party_Id = p_Party_Id
             AND Txo_Codigo_Tx = p_Codigo_Tx
             AND Rownum = 1;
        EXCEPTION
          WHEN No_Data_Found THEN
            l_Existe := 0;
          WHEN OTHERS THEN
            l_Existe := -1;
            Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                      ,p_Msg     => l_Dbg_Mensaje);
        END;
        IF l_Existe = 0 THEN
          BEGIN
            l_Dbg_Mensaje := 'Insertar en SCFR_CONTROL_FRECUENCIA';
            INSERT INTO Scfr_Control_Frecuencia
              (Control_Frecuencia
              ,Cam_Campana
              ,Pt_Party_Id
              ,Tipo_Movimiento_Frecuencia
              ,Rut_Cliente
              ,Txo_Codigo_Tx
              ,Fecha_Venta
              ,Fecha_Grabacion
              ,Glosa_Ajuste)
            VALUES
              (Scfr_Control_Frecuencia_s.Nextval
              ,p_Campana
              ,p_Party_Id
              ,p_Tipo_Mov_Frec
              ,p_Rut_Cliente
              ,p_Codigo_Tx
              ,p_Fecha_Venta
              ,Scfr_Trx_Util_Pk.Get_Sysdate
              ,NULL);
          EXCEPTION
            WHEN OTHERS THEN
              Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                        ,p_Msg     => l_Dbg_Mensaje || '.' || SQLERRM);
          END;
        END IF;
      END IF;
    END IF;
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 1;
  END;

  -- si existen varios descuentos con la misma campa?a, solo se considera el que tenga
  -- detalle de ciclo (los demas no se incluyen). y en el caso que ninguno tengo detalle,
  -- se deja siempre el primero de ellos. ejemplo:
  --
  -- parametro entrada P_SUBTRAMA_PM2   => parametro salida L_PTO_DESCUENTOS (arreglo de punteros)
  -- itm campa?a detalle ciclo             puntero al arreglo P_SUBTRAMA_PM2
  -- [1] [ 100 ] [00 ]                     [2]
  -- [2] [ 100 ] [010010000019065601001]   [3]
  -- [3] [ 200 ] [00]
  -- [4] [ 200 ] [00]
  FUNCTION Quita_Desc_Repetidos(p_Subtrama_Pm2 IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm2) RETURN Scfr_Trx_Gnc_Utl_Pk.Tab_Descuentos IS
    l_Pto_Descuentos Scfr_Trx_Gnc_Utl_Pk.Tab_Descuentos;
    l_Empty_Puntero  Scfr_Trx_Gnc_Utl_Pk.Tab_Descuentos;
    l_Campanas_Desc  Scfr_Trx_Gnc_Utl_Pk.Tab_Descuentos;
    l_Itm            NUMBER;
    l_Itm2           NUMBER;
    l_Pos            NUMBER;
  BEGIN
    -- recorre detalle de descuentos
    FOR l_Itm IN 1 .. p_Subtrama_Pm2.Count
    LOOP
      -- revisa si la campa?a ya fue incluida en el arreglo
      l_Pos := 0;
      FOR l_Itm2 IN 1 .. l_Campanas_Desc.Count
      LOOP
        IF p_Subtrama_Pm2(l_Itm).Campana_o_Convenio = l_Campanas_Desc(l_Itm2) THEN
          -- si la encuentra, guarda la posicion dentro del arreglo de punteros
          l_Pos := l_Itm2;
          EXIT;
        END IF;
      END LOOP;
      IF l_Pos > 0 THEN
        IF Length(Ltrim(Rtrim(p_Subtrama_Pm2(l_Itm).Detalle_Descuento_Producto))) < 3 THEN
          -- si el descto actual no tiene detalle, se anula la posicion del arreglo en donde
          -- fue encontrado para que no actualice el puntero de la subtrama_pm2
          l_Pos := -1;
        END IF;
      ELSIF l_Pos = 0 THEN
        -- si la campa?a no fue encontrada, se toma una posicion nueva para agregar la campa?a
        l_Pos := l_Campanas_Desc.Count + 1;
      END IF;
      IF l_Pos > 0 THEN
        -- si la campa?a se encontraba y el nuevo descuento tiene detalle de ciclos, se
        -- actualiza el puntero del descuento
        l_Pto_Descuentos(l_Pos) := l_Itm;
        l_Campanas_Desc(l_Pos) := p_Subtrama_Pm2(l_Itm).Campana_o_Convenio;
      END IF;
    END LOOP;
    RETURN l_Pto_Descuentos;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN l_Empty_Puntero;
  END;

  /*MOMENTANEO*/
  /*
    function determinar_party_id(
      p_forma_identificacion  varchar2
    , p_string_identificacion varchar2
    , p_empresa               scfr_programas.emp_empresa%type
    , p_cadena                scfr_programas.cad_cadena%type
    , x_party_id              out hz_parties.party_id%type
    ) return number is
      l_rut_cliente       hz_parties.jgzz_fiscal_code%type;
      l_aux               number;
      l_rut_sin_espacios  varchar2(20);
      l_resultado         number;
      l_CodError          varchar2(100);
      l_MsgError          varchar2(100);
      l_tipo_tarjeta      varchar2(100);
      l_desc_tarjeta      varchar2(100);
      l_forma_identifica  varchar2(100);
      l_string_identifica varchar2(150);
    begin
      l_resultado        := 0;
      x_party_id         := 0;
      dbms_output.put_line( 'ENTRE A DETERMINAR_PARTY_ID...');
      dbms_output.put_line( 'FORMA=>'||l_forma_identifica);

      -- Validacion previa en caso que la forma de identificacion sea BANDA MAGNETICA
      if p_forma_identificacion = scfr_util_fid_pk.K_POR_BANDA_MAGNETICA then

        -- Obtiene tipo de identificacion desde track original.
        l_forma_identifica  := p_forma_identificacion;
        l_string_identifica := p_string_identificacion;
        scfr_track_tarjetas_pk.valida_banda_magnetica( ltrim(rtrim(p_string_identificacion))
                                                     , l_tipo_tarjeta
                                                     , l_desc_tarjeta
                                                     , l_coderror
                                                     , l_msgerror );
        if nvl(l_coderror,0) != 0 then
          return -5;
        end if;

        -- Determina el tipo de identificacion obtenido
        if l_tipo_tarjeta = 'C' then
          -- Informa al POS el error
          return -6;
        else
          -- cambia tipo de identificacion a RUT
          l_forma_identifica  := l_tipo_tarjeta;
          l_string_identifica := l_desc_tarjeta;
        end if;
      else
        l_forma_identifica  := p_forma_identificacion;
        l_string_identifica := p_string_identificacion;
      end if;

      if l_forma_identifica in ( scfr_util_fid_pk.K_POR_RUT, scfr_util_fid_pk.K_POR_CODIGO_CONVENIO ) then
        dbms_output.put_line( 'FORMA=>'||l_forma_identifica);
        dbms_output.put_line( 'STRING=>'||l_string_identifica);
        begin
          if l_forma_identifica = scfr_util_fid_pk.K_POR_CODIGO_CONVENIO then
            l_rut_sin_espacios := ltrim(rtrim(replace(substr(l_string_identifica,16),'  ')));
          else
            l_rut_sin_espacios := ltrim(rtrim(replace(l_string_identifica,' ')));
          end if;
          l_rut_cliente := substr(l_rut_sin_espacios,1,length(l_rut_sin_espacios)-1);
          dbms_output.put_line( 'l_rut_cliente=>'||l_rut_cliente);
          -- Obtiene party ID desde AR segun un rut.
          select party_id
            into x_party_id
            from hz_parties
           where jgzz_fiscal_code = l_rut_cliente;
        exception
          when no_data_found then
            l_resultado := -1;
            x_party_id  := 0;
          when others then
            l_resultado := -4;
            x_party_id  := 0;
        end;

      elsif l_forma_identifica = scfr_util_fid_pk.K_POR_BANDA_MAGNETICA then

        -- Obtiene party ID desde convenios segun una banda magnetica.
        scfr_conv_pk.entrega_party_id_credencial(ltrim(rtrim(l_string_identifica)), x_party_id, l_MsgError, l_CodError );
        if x_party_id < 1 then
           -- No encontro Party ID. Asigna codigo de error relacionado.
           if x_party_id = 0 then
              x_party_id := -9;
           end if;
           l_resultado := x_party_id;
           x_party_id  := 0;
        end if;

      elsif l_forma_identifica = scfr_util_fid_pk.K_POR_CODIGO_BARRA then -- por CODIGO DE BARRA.
        begin
          select pt_party_id
            into x_party_id
            from scfr_programas
           where folio       = ltrim(rtrim(l_string_identifica))
             and emp_empresa = p_empresa
             and cad_cadena  = p_cadena
             and estado_tarjeta = 'ACT';
        exception
          when others then
            l_resultado := -3;
            x_party_id  := 0;
        end;
      end if;
      return(l_resultado);
    end;
  */
  /*FIN MOMENTANEO*/
  FUNCTION Esta_Vigente(p_Campana IN NUMBER) RETURN VARCHAR2 IS
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_GNC_PK.esta_vigente';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
    l_Activa      VARCHAR2(3);
  BEGIN
    SELECT 'ACT'
      INTO l_Activa
      FROM Scfr_Campanas
     WHERE Campana = p_Campana
       AND Fecha_Inicio <= Scfr_Trx_Util_Pk.Get_Sysdate()
       AND Fecha_Termino >= Scfr_Trx_Util_Pk.Get_Sysdate();
    RETURN l_Activa;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'NAC';
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => l_Dbg_Mensaje);
  END;

  PROCEDURE Documento_Recaudacion(p_Correlativo_Tx   IN OUT NUMBER
                                 ,p_Pin_Ot_Recetario IN OUT VARCHAR2
                                 ,p_Local            IN NUMBER
                                 ,x_Largo_Reg        OUT NUMBER
                                 ,x_Salida           OUT Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dr
                                 ,x_Cod_Error        OUT NUMBER
                                 ,x_Msg_Error        OUT VARCHAR2) IS
    l_Codigo_Tx      NUMBER;
    l_Correlativo_Tx NUMBER;
    l_Local          NUMBER;
    l_Trama_Dr       Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dr;
    CURSOR c_Doctos_Trx(l_Codigo_Tx NUMBER) IS
      SELECT Secuencia Secuencia
            ,Tmo_Movimiento Tipo_Mov_Hijo
            ,Anulado Anulado
            ,Nvl(Monto
                ,0) + Nvl(Iva
                         ,0) Total
            ,Nvl(Pin_Ot_Recetario
                ,' ') Pin_Ot_Recetario
        FROM Scfr_Mov_Documentos_Txs
       WHERE Txo_Codigo_Tx = l_Codigo_Tx;
    --     documento_recaudacion;
    i                  NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.DOCUMENTO_RECAUDACION';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Contralado EXCEPTION;
    l_Codigo_Resp      NUMBER;
  BEGIN
    l_Dbg_Mensaje    := 'Chequea que forma de ident.la recaudacion se envio. CODIGO_TX o N? OT.';
    l_Correlativo_Tx := p_Correlativo_Tx;
    l_Local          := p_Local;
    IF Nvl(l_Correlativo_Tx
          ,0) = 0 THEN
      IF p_Pin_Ot_Recetario IS NULL THEN
        x_Cod_Error := -2000;
        x_Msg_Error := 'No existen Correlativo y pin recetario';
        RAISE l_Error_Contralado;
      END IF;
      l_Dbg_Mensaje := 'Busca CORRELATIVO_TX por el N? de OT. Padre DR';
      BEGIN
        SELECT Txo_Correlativo_Tx
          INTO l_Correlativo_Tx
          FROM Scfr_Mov_Documentos_Txs
         WHERE Pin_Ot_Recetario = p_Pin_Ot_Recetario
           AND Tmo_Movimiento = 'RECRMA';
      EXCEPTION
        WHEN OTHERS THEN
          x_Cod_Error := -2000;
          x_Msg_Error := 'No existen Correlativo para este Pin recetario';
          RAISE l_Error_Contralado;
      END;
    END IF;
    IF Nvl(l_Local
          ,0) = 0 THEN
      --LOCAL2014
      --l_Local := To_Number(Substr(p_Pin_Ot_Recetario, 6, 3));
      l_Local := To_Number(Substr(p_Pin_Ot_Recetario
                                 ,6
                                 ,5));
    END IF;
    l_Dbg_Mensaje := 'Obtiene Mov. Transaccion  Padre DR' || l_Correlativo_Tx || ' ' || l_Local;
    --    dbms_output.put_line(l_dbg_mensaje);
    BEGIN
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
            ,Nvl(Sec_Recaudacion
                ,0) Secuencia_Num
            ,Nvl(Estx_Srv_Codigo
                ,' ') Cod_Serv
            ,Loc_Local LOCAL
            ,Estx_Numero_Pos Pos
            ,' ' Destino
            ,' ' Sistema
            ,' ' Funcion
            ,'00' Secuencia_Char
            ,0 Fecha_Trx
            ,0 Correlativo
            ,0 Numero_Trama
            ,' ' Cod_Trx
            ,l_Correlativo_Tx l_Correlativo_Tx
            ,Codigo_Tx Codigo_Tx
        INTO l_Trama_Dr.Tipo_Movimiento_Padre
            ,l_Trama_Dr.Fecha
            ,l_Trama_Dr.Hora_Recaudacion
            ,l_Trama_Dr.Secuencia_b
            ,l_Trama_Dr.Numero_Cuenta
            ,l_Trama_Dr.Codigo_Autorizacion
            ,l_Trama_Dr.Ot
            ,l_Trama_Dr.Venta_Relacionada
            ,l_Trama_Dr.Codigo_Servicio
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
        FROM Scfr_Mov_Transacciones
       WHERE (Correlativo_Tx = l_Correlativo_Tx OR Codigo_Autorizacion_Tx = p_Pin_Ot_Recetario)
         AND Loc_Local = l_Local;
      l_Codigo_Resp := 0;
    EXCEPTION
      WHEN OTHERS THEN
        l_Codigo_Resp := 8;
        x_Cod_Error   := SQLCODE;
        x_Msg_Error   := SQLERRM;
        RAISE l_Error_Contralado;
    END;
    x_Salida := NULL;
    IF l_Codigo_Resp = 0 THEN
      i             := 0;
      l_Dbg_Mensaje := 'Obtiene Mov. Transaccion  Hijo DR1';
      FOR r IN c_Doctos_Trx(l_Codigo_Tx)
      LOOP
        i := i + 1;
        l_Trama_Dr.Subtrama_Dr1(i).Secuencia_b := r.Secuencia;
        l_Trama_Dr.Subtrama_Dr1(i).Tipo_Movimiento_Hijo := r.Tipo_Mov_Hijo;
        l_Trama_Dr.Subtrama_Dr1(i).Anulado := r.Anulado;
        l_Trama_Dr.Subtrama_Dr1(i).Total_Iva_Incluido := r.Total;
        IF p_Pin_Ot_Recetario IS NULL THEN
          p_Pin_Ot_Recetario := r.Pin_Ot_Recetario;
        END IF;
      END LOOP;
      l_Trama_Dr.Documentos_Emitidos := i;
    END IF;
    Dbms_Output.Put_Line(l_Dbg_Mensaje || ' ' || p_Pin_Ot_Recetario || ' ' || l_Trama_Dr.Tipo_Movimiento_Padre);
    x_Salida := NULL;
    x_Salida := l_Trama_Dr;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(l_Dbg_Proceso
                                ,l_Dbg_Mensaje);
      x_Cod_Error := SQLCODE;
      x_Msg_Error := SQLERRM;
  END;

  PROCEDURE Registra_Datos_Ult_Compra(p_Rut_Titular IN NUMBER
                                     ,p_Fecha_Venta IN DATE
                                     ,p_Local_Venta IN NUMBER) IS
    l_Fecha_Ultima_Venta DATE;
    l_Rowid              ROWID;
  BEGIN
    IF p_Rut_Titular IS NOT NULL THEN
      SELECT ROWID
            ,Fecha_Hora_Ultima_Venta
        INTO l_Rowid
            ,l_Fecha_Ultima_Venta
        FROM Scfr_Clientes
       WHERE Rut_Cliente = p_Rut_Titular;
      IF p_Fecha_Venta > l_Fecha_Ultima_Venta THEN
        UPDATE Scfr_Clientes
           SET Fecha_Hora_Ultima_Venta = p_Fecha_Venta
              ,Local_Ultima_Venta      = p_Local_Venta
         WHERE ROWID = l_Rowid;
      END IF;
    END IF;
  EXCEPTION
    WHEN No_Data_Found THEN
      INSERT INTO Scfr_Clientes
        (Rut_Cliente
        ,Fecha_Hora_Ultima_Venta
        ,Local_Ultima_Venta)
      VALUES
        (p_Rut_Titular
        ,p_Fecha_Venta
        ,p_Local_Venta);
    WHEN OTHERS THEN
      NULL;
  END;

  PROCEDURE Obtiene_Datos_Ult_Compra(p_Rut_Titular IN NUMBER
                                    ,x_Trama_Dp    IN OUT Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp) IS
  BEGIN
    Dbms_Output.Put_Line('rut=>' || p_Rut_Titular);
    SELECT To_Number(To_Char(Fecha_Hora_Ultima_Venta
                            ,'yyyymmddhh24miss'))
          ,Local_Ultima_Venta
      INTO x_Trama_Dp.Fecha_Hora_Ultima_Venta
          ,x_Trama_Dp.Local_Ultima_Venta
      FROM Scfr_Clientes
     WHERE Rut_Cliente = p_Rut_Titular;
  EXCEPTION
    WHEN OTHERS THEN
      x_Trama_Dp.Fecha_Hora_Ultima_Venta := 0;
      x_Trama_Dp.Local_Ultima_Venta      := 0;
      NULL;
  END;

  PROCEDURE Obtener_Fechas(p_Empresa       IN NUMBER
                          ,p_Convenio      IN NUMBER
                          ,p_Plan          IN NUMBER
                          ,p_Party_Id      IN NUMBER
                          ,p_Periodicidad  IN VARCHAR2
                          ,p_Fecha_Consumo IN DATE
                          ,p_Lista_Unica   IN VARCHAR2
                          ,x_Fecha_Ini     OUT VARCHAR2) IS
    l_Inicio_Cobertura_Descuento Scfr_Beneficiarios.Fecha_Inicio%TYPE;
    l_Dia_Inicio                 NUMBER;
    l_Mes_Inicio                 NUMBER;
    l_Ano_Inicio                 NUMBER;
    l_Dia_Consumo                NUMBER;
    l_Mes_Consumo                NUMBER;
    l_Ano_Consumo                NUMBER;
    l_Plan                       NUMBER;
    l_Mes_Final                  VARCHAR2(30);
    l_Ano_Final                  VARCHAR2(30);
    l_Dbg_Proceso                VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.obtener_fechas()';
    l_Dbg_Mensaje                VARCHAR2(250) := 'Error general';
    l_Fecha                      DATE;
    l_Ult_Dia                    NUMBER;
    l_Ult_Dia_Mes                NUMBER;
  BEGIN
    l_Dbg_Mensaje := 'Validar lista unica';
    IF p_Lista_Unica = 'SI' THEN
      l_Plan := 0;
    ELSE
      l_Plan := p_Plan;
    END IF;
    l_Dbg_Mensaje := 'Obtiene Fecha de Inicio de la Cobertura a partir del Plan';
    BEGIN
      SELECT Fecha_Vigencia_Descuento
        INTO l_Inicio_Cobertura_Descuento
        FROM Scfr_Planes
       WHERE Emp_Codigo = p_Empresa
         AND Con_Numero_Convenio = p_Convenio
         AND Numero_Plan = p_Plan;
    EXCEPTION
      WHEN OTHERS THEN
        l_Inicio_Cobertura_Descuento := NULL;
    END;
    IF l_Inicio_Cobertura_Descuento IS NULL THEN
      BEGIN
        l_Dbg_Mensaje := 'Obtiene Fecha de Inicio de la Cobertura a partir del Beneficiario';
        SELECT Fecha_Inicio
          INTO l_Inicio_Cobertura_Descuento
          FROM Scfr_Beneficiarios
         WHERE Emp_Codigo = p_Empresa
           AND Con_Numero_Convenio = p_Convenio
           AND Pla_Numero_Plan = l_Plan
           AND Pt_Party_Id = p_Party_Id
           AND Estado_Vigencia <> 'ELI';
      EXCEPTION
        WHEN OTHERS THEN
          l_Inicio_Cobertura_Descuento := NULL;
      END;
    END IF;
    IF l_Inicio_Cobertura_Descuento IS NOT NULL THEN
      l_Dbg_Mensaje := 'Obtener Fecha de Inicio de la vigencia del descuento';
      l_Dia_Inicio  := To_Number(To_Char(l_Inicio_Cobertura_Descuento
                                        ,'dd'));
      l_Mes_Inicio  := To_Number(To_Char(l_Inicio_Cobertura_Descuento
                                        ,'mm'));
      l_Ano_Inicio  := To_Number(To_Char(l_Inicio_Cobertura_Descuento
                                        ,'yyyy'));
      l_Dia_Consumo := To_Number(To_Char(p_Fecha_Consumo
                                        ,'dd'));
      l_Mes_Consumo := To_Number(To_Char(p_Fecha_Consumo
                                        ,'mm'));
      l_Ano_Consumo := To_Number(To_Char(p_Fecha_Consumo
                                        ,'yyyy'));
      IF p_Periodicidad = 'MES' THEN
        IF l_Dia_Inicio <= l_Dia_Consumo THEN
          l_Mes_Final := To_Char(p_Fecha_Consumo
                                ,'mm');
          l_Ano_Final := To_Char(p_Fecha_Consumo
                                ,'yyyy');
        ELSE
          l_Ult_Dia_Mes := To_Number(To_Char(Last_Day(To_Date(To_Char(p_Fecha_Consumo
                                                                     ,'mm') || To_Char(p_Fecha_Consumo
                                                                                      ,'yyyy')
                                                             ,'mmyyyy'))
                                            ,'dd'));
          IF l_Dia_Inicio > l_Ult_Dia_Mes THEN
            l_Fecha := To_Date(To_Char(l_Ult_Dia_Mes) || To_Char(p_Fecha_Consumo
                                                                ,'mm') || To_Char(p_Fecha_Consumo
                                                                                 ,'yyyy')
                              ,'ddmmyyyy');
          ELSE
            l_Fecha := To_Date(To_Char(l_Inicio_Cobertura_Descuento
                                      ,'dd') || To_Char(p_Fecha_Consumo
                                                       ,'mm') || To_Char(p_Fecha_Consumo
                                                                        ,'yyyy')
                              ,'ddmmyyyy');
          END IF;
          l_Mes_Final := To_Char(Add_Months(l_Fecha
                                           ,-1)
                                ,'mm');
          l_Ano_Final := To_Char(Add_Months(l_Fecha
                                           ,-1)
                                ,'yyyy');
        END IF;
        l_Ult_Dia := To_Number(To_Char(Last_Day(To_Date(l_Mes_Final || l_Ano_Final
                                                       ,'mmyyyy'))
                                      ,'dd'));
        IF l_Dia_Inicio > l_Ult_Dia THEN
          l_Dia_Inicio := l_Ult_Dia;
        END IF;
        x_Fecha_Ini := Ltrim(To_Char(l_Dia_Inicio
                                    ,'00')) || l_Mes_Final || l_Ano_Final || '000000';
      ELSIF p_Periodicidad = 'ANU' THEN
        l_Fecha     := To_Date(To_Char(l_Inicio_Cobertura_Descuento
                                      ,'dd') || To_Char(l_Inicio_Cobertura_Descuento
                                                       ,'mm') || To_Char(p_Fecha_Consumo
                                                                        ,'yyyy')
                              ,'ddmmyyyy');
        l_Mes_Final := To_Char(l_Inicio_Cobertura_Descuento
                              ,'mm');
        IF l_Fecha > p_Fecha_Consumo THEN
          l_Ano_Final := Lpad(l_Ano_Consumo - 1
                             ,4
                             ,'0000');
        ELSE
          l_Ano_Final := Lpad(l_Ano_Consumo
                             ,4
                             ,'0000');
        END IF;
        x_Fecha_Ini := Ltrim(To_Char(l_Dia_Inicio
                                    ,'00')) || l_Mes_Final || l_Ano_Final || '000000';
      ELSIF p_Periodicidad = 'DIA' THEN
        x_Fecha_Ini := To_Char(SYSDATE
                              ,'ddmmyyyy') || '000000';
      ELSE
        x_Fecha_Ini := To_Char(SYSDATE + 1
                              ,'ddmmyyyy') || '000000';
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - ' ||
                                              Substr(SQLERRM
                                                    ,1
                                                    ,50));
      x_Fecha_Ini := NULL;
  END Obtener_Fechas;

  PROCEDURE Registra_En_Cta_Cte_Descuento1(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                          ,p_Tipo        IN VARCHAR2
                                          ,p_Offline     IN VARCHAR2 DEFAULT 'NO'
                                          ,p_Observacion IN VARCHAR2
                                          ,p_Incluido    IN VARCHAR2 DEFAULT 'SI'
                                          ,x_Cod_Error   OUT NUMBER
                                          ,x_Msg_Error   OUT VARCHAR2) IS
    /*  CURSOR c_boletas( p_codigo_tx in NUMBER ) is
    select c.folio , a.tipo_descuento , a.campana_convenio , abs( sum( a.monto ) ) monto
      from SCFR_MOV_DESCUENTOS_PRODUCTOS a
         , SCFR_MOV_PRODUCTOS_DOCUMENTOS b
         , SCFR_MOV_DOCUMENTOS_TXS       c
     where a.txo_codigo_tx      = p_codigo_tx
       and a.pro_codigo_interno = b.pro_codigo_interno
       and b.txo_codigo_tx      = a.txo_codigo_tx
       and b.dte_mov_documentos = c.mov_documentos
       and c.txo_codigo_tx      = b.txo_codigo_tx
       and c.tmo_movimiento     in ( 'VENBOL' , 'ANUBOL' )
       and b.impreso_en_boleta  = 'SI'
     group by c.folio , a.tipo_descuento , a.campana_convenio;    */
    -- Definici?n de cursor para leer desde modelo online o batc
    TYPE Refcursor_Boleta IS REF CURSOR;
    c_Boletas    Refcursor_Boleta;
    c_Sql_Cursor VARCHAR2(1000);
    l_Sql_Cursor VARCHAR2(1000);
    Fila_Boletas Reg_Boletas;
    -- Fin definici?n
    l_Emp_Codigo               Scfr_Detalle_Consumos.Emp_Codigo%TYPE;
    l_Convenio                 Scfr_Detalle_Consumos.Con_Numero_Convenio%TYPE;
    l_Plan                     Scfr_Detalle_Consumos.Numero_Plan_Utilizado%TYPE;
    l_Secuencia                Scfr_Detalle_Consumos.Secuencia%TYPE;
    l_Pt_Party_Id_Benef        Scfr_Detalle_Consumos.Pt_Party_Id_Benef%TYPE;
    l_Fecha_Consumo            Scfr_Detalle_Consumos.Fecha_Consumo%TYPE;
    l_Codigo_Tx_Reversado      Scfr_Mov_Transacciones.Codigo_Tx%TYPE;
    l_Rut                      Scfr_Cuenta_Cte_Descuentos.Rut%TYPE;
    l_Campana                  NUMBER;
    l_Saldo_Consumido          Scfr_Cuenta_Cte_Descuentos.Saldo_Consumido%TYPE;
    l_Saldo_Disponible         Scfr_Cuenta_Cte_Descuentos.Saldo_Disponible%TYPE;
    l_Tope_Descuento           Scfr_Planes.Tope_Descuento%TYPE;
    l_Tope_Descuento_Benef     Scfr_Planes.Tope_Descuento%TYPE;
    l_Periodicidad_Descuento   Scfr_Planes.Periodicidad_Descuento%TYPE;
    l_Fecha_Vigencia_Descuento Scfr_Planes.Fecha_Vigencia_Descuento%TYPE;
    l_Tope_Descuento_Offline   Scfr_Planes.Tope_Descuento_Offline%TYPE;
    l_Tipo_Descuento           Scfr_Planes.Tipo_Descuento%TYPE;
    l_Dias_Totales             NUMBER;
    l_Fecha_Ini                VARCHAR2(30);
    l_Fecha_Fin                VARCHAR2(30);
    l_Dbg_Proceso              VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.Registra_En_Cta_Cte_Descuentos';
    l_Dbg_Mensaje              VARCHAR2(250) := 'Error General';
    l_Codigo_Tx                NUMBER;
    l_Error                    VARCHAR2(1000);
    l_Periodicidad             NUMBER;
    l_Incluir_En_Cartola       VARCHAR2(2) := 'NO';
    l_Lista_Unica              VARCHAR2(2);
    l_Plan_Benef               NUMBER;
    l_Unidades_Descuentos      NUMBER;
  BEGIN
    -- crea cursor de boletas desde modelo online
    l_Sql_Cursor := 'select c.folio' || '     , a.tipo_descuento' || '     , a.campana_convenio' || '     , abs( sum( a.monto ) ) monto' ||
                    '     , abs( sum( a.unidades_descuento ) ) unidades ' || '  from MODELO_MOV_DESCUENTOS_PRODUCTOS a' ||
                    '     , MODELO_MOV_PRODUCTOS_DOCUMENTOS b' || '     , MODELO_MOV_DOCUMENTOS_TXS       c' ||
                    ' where a.txo_codigo_tx      = P_CODIGO_TX' || '   and a.pro_codigo_interno = b.pro_codigo_interno' ||
                    '   and b.txo_codigo_tx      = a.txo_codigo_tx' || '   and b.dte_mov_documentos = c.mov_documentos' ||
                    '   and c.txo_codigo_tx      = b.txo_codigo_tx' || '   and c.tmo_movimiento     in ( ''VENBOL'' , ''ANUBOL'' )' ||
                    '   and b.impreso_en_boleta  = ''SI''' || ' group by c.folio, a.tipo_descuento, a.campana_convenio';
    /* c_sql_cursor := 'select c.folio'
    || '     , a.tipo_descuento'
    || '     , a.campana_convenio'
    || '     , abs( sum( a.monto ) ) monto'
    || '  from MODELO_MOV_DESCUENTOS_PRODUCTOS a'
    || '     , MODELO_MOV_PRODUCTOS_DOCUMENTOS b'
    || '     , MODELO_MOV_DOCUMENTOS_TXS       c'
    || ' where a.txo_codigo_tx      = P_CODIGO_TX'
    || '   and a.pro_codigo_interno = b.pro_codigo_interno'
    || '   and b.txo_codigo_tx      = a.txo_codigo_tx'
    || '   and b.dte_mov_documentos = c.mov_documentos'
    || '   and c.txo_codigo_tx      = b.txo_codigo_tx'
    || '   and c.tmo_movimiento     in ( ''VENBOL'' , ''ANUBOL'' )'
    || '   and b.impreso_en_boleta  = ''SI'''
    || ' group by c.folio, a.tipo_descuento, a.campana_convenio';*/
    l_Codigo_Tx   := p_Transaccion.Codigo_Tx;
    l_Dbg_Proceso := 'Determinar el Codigo TX de la transaccion que se esta reversando';
    IF p_Tipo = 'REV' THEN
      BEGIN
        SELECT a.Codigo_Tx
          INTO l_Codigo_Tx_Reversado
          FROM Scfr_Mov_Transacciones a
              ,Scfr_Mov_Transacciones b
         WHERE a.Correlativo_Tx = b.Txo_Correlativo_Tx_Relacionado
           AND b.Codigo_Tx = l_Codigo_Tx
           AND a.Loc_Local = p_Transaccion.Trama_Pos.Local;
        l_Codigo_Tx := l_Codigo_Tx_Reversado;
        -- indica que la informaci?n de las boletas se obtebdr? del modelo online
        l_Sql_Cursor := REPLACE(l_Sql_Cursor
                               ,'MODELO'
                               ,'SCFR');
      EXCEPTION
        WHEN No_Data_Found THEN
          BEGIN
            SELECT a.Codigo_Tx
              INTO l_Codigo_Tx_Reversado
              FROM Batc_Mov_Transacciones a
                  ,Batc_Mov_Transacciones b
             WHERE a.Correlativo_Tx = b.Txo_Correlativo_Tx_Relacionado
               AND b.Codigo_Tx = l_Codigo_Tx
               AND a.Loc_Local = p_Transaccion.Trama_Pos.Local;
            l_Codigo_Tx := l_Codigo_Tx_Reversado;
            -- indica que la informaci?n de las boletas se obtebdr? del modelo online
            l_Sql_Cursor := REPLACE(l_Sql_Cursor
                                   ,'MODELO'
                                   ,'BATC');
          EXCEPTION
            WHEN OTHERS THEN
              l_Codigo_Tx_Reversado := 0;
          END;
        WHEN OTHERS THEN
          l_Codigo_Tx_Reversado := 0;
      END;
    ELSE
      IF Trunc(p_Transaccion.Fecha_Tx) = Trunc(SYSDATE) THEN
        l_Sql_Cursor := REPLACE(l_Sql_Cursor
                               ,'MODELO'
                               ,'SCFR');
      ELSE
        l_Sql_Cursor := REPLACE(l_Sql_Cursor
                               ,'MODELO'
                               ,'BATC');
      END IF;
    END IF;
    l_Dbg_Proceso := 'Recorerr las Boletas asociadas';
    --    for fila_boletas in c_boletas( l_codigo_tx ) LOOP
    l_Sql_Cursor := REPLACE(l_Sql_Cursor
                           ,'P_CODIGO_TX'
                           ,p_Transaccion.Codigo_Tx);
    OPEN c_Boletas FOR l_Sql_Cursor;
    LOOP
      FETCH c_Boletas
        INTO Fila_Boletas;
      EXIT WHEN c_Boletas%NOTFOUND;
      BEGIN
        l_Convenio  := 0;
        l_Plan      := 0;
        l_Secuencia := 0;
        l_Campana   := 0;
        IF Fila_Boletas.Tipo_Descuento = 'CNV' THEN
          l_Incluir_En_Cartola := 'SI';
          -- Obtiene datos desde SCFR_DETALLE_CONSUMOS
          l_Dbg_Proceso := 'Determinar datos de Empresa, Convenio, Plan, Secuencia, Party-Benef, Fecha Consumo';
          BEGIN
            SELECT DISTINCT a.Emp_Codigo
                           ,a.Con_Numero_Convenio
                           ,a.Numero_Plan_Utilizado
                           ,a.Secuencia
                           ,a.Pt_Party_Id_Benef
                           ,a.Fecha_Consumo
              INTO l_Emp_Codigo
                  ,l_Convenio
                  ,l_Plan
                  ,l_Secuencia
                  ,l_Pt_Party_Id_Benef
                  ,l_Fecha_Consumo
              FROM Scfr_Detalle_Consumos a
             WHERE a.Emp_Codigo = Scfr_Conv_Pk.Entrega_Codigo_Empresa(p_Transaccion.Trama_Pos.Empresa)
               AND a.Cad_Codigo = p_Transaccion.Trama_Pos.Cadena
               AND a.Loc_Codigo = p_Transaccion.Trama_Pos.Local
               AND a.Numero_Linea <> 0
               AND a.Txo_Codigo_Tx = l_Codigo_Tx;
            IF p_Tipo = 'REV' THEN
              BEGIN
                l_Fecha_Consumo := p_Transaccion.Fecha_Tx;
              EXCEPTION
                WHEN OTHERS THEN
                  l_Error := SQLERRM;
                  Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                            ,p_Msg     => 'Al cambiar la fecha ' || l_Error);
              END;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              l_Emp_Codigo        := 0;
              l_Convenio          := 0;
              l_Plan              := 0;
              l_Secuencia         := 0;
              l_Pt_Party_Id_Benef := 0;
              l_Fecha_Consumo     := NULL;
              l_Rut               := NULL;
          END;
          l_Dbg_Proceso := 'Determinar si el convenio maneja Lista Unica de Beneficiarios';
          BEGIN
            SELECT Lista_Unica_Beneficiarios INTO l_Lista_Unica FROM Scfr_Convenios WHERE Numero_Convenio = l_Convenio;
          EXCEPTION
            WHEN OTHERS THEN
              l_Lista_Unica := 'NO';
          END;
          -- Si se maneja Lista Unica entonces el plan es 0 para efectos de la tabla de beneficiarios';
          IF l_Lista_Unica = 'SI' THEN
            l_Plan_Benef := 0;
          ELSE
            l_Plan_Benef := l_Plan;
          END IF;
          l_Dbg_Proceso := 'Determinar Rut del Beneficiario';
          BEGIN
            SELECT Rut_Beneficiario
              INTO l_Rut
              FROM Scfr_Beneficiarios
             WHERE Pt_Party_Id = l_Pt_Party_Id_Benef
               AND Emp_Codigo = l_Emp_Codigo
               AND Con_Numero_Convenio = l_Convenio
               AND Pla_Numero_Plan = l_Plan_Benef
               AND Estado_Vigencia <> 'ELI';
          EXCEPTION
            WHEN OTHERS THEN
              l_Rut := NULL;
          END;
          l_Dbg_Proceso := 'Obtener configuracion del descuento a partir del plan';
          BEGIN
            -- Se busca a nivel de plan
            SELECT Tope_Descuento
                  ,Periodicidad_Descuento
                  ,Fecha_Vigencia_Descuento
                  ,Tope_Descuento_Offline
                  ,Tipo_Descuento
                  ,Controla_Tope_Descuento
              INTO l_Tope_Descuento
                  ,l_Periodicidad_Descuento
                  ,l_Fecha_Vigencia_Descuento
                  ,l_Tope_Descuento_Offline
                  ,l_Tipo_Descuento
                  ,l_Incluir_En_Cartola
              FROM Scfr_Planes
             WHERE Con_Numero_Convenio = l_Convenio
               AND Numero_Plan = l_Plan;
          EXCEPTION
            WHEN No_Data_Found THEN
              BEGIN
                l_Dbg_Proceso := 'Obtener configuracion del descuento a partir del convenio (plan 0)';
                SELECT Tope_Descuento
                      ,Periodicidad_Descuento
                      ,Fecha_Vigencia_Descuento
                      ,Tope_Descuento_Offline
                      ,Tipo_Descuento
                      ,Nvl(Controla_Tope_Descuento
                          ,'NO')
                  INTO l_Tope_Descuento
                      ,l_Periodicidad_Descuento
                      ,l_Fecha_Vigencia_Descuento
                      ,l_Tope_Descuento_Offline
                      ,l_Tipo_Descuento
                      ,l_Incluir_En_Cartola
                  FROM Scfr_Planes
                 WHERE Con_Numero_Convenio = l_Convenio
                   AND Numero_Plan = 0;
              EXCEPTION
                WHEN OTHERS THEN
                  l_Tope_Descuento           := NULL;
                  l_Periodicidad_Descuento   := NULL;
                  l_Fecha_Vigencia_Descuento := NULL;
                  l_Tope_Descuento_Offline   := NULL;
                  l_Tipo_Descuento           := NULL;
                  l_Incluir_En_Cartola       := 'NO';
              END;
          END;
          l_Dbg_Proceso := 'Obtener configuracion del descuento si se debe o no registrar en la CTA CTE Descuento';
          Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                    ,p_Msg     => 'Incluir en cartola ' || l_Incluir_En_Cartola);
          IF l_Incluir_En_Cartola = 'SI' THEN
            l_Dbg_Proceso := 'Obtener el Tope Descuento a nivel de beneficiario si existe';
            BEGIN
              SELECT Nvl(Tope_Descuento
                        ,-1)
                INTO l_Tope_Descuento_Benef
                FROM Scfr_Beneficiarios
               WHERE Emp_Codigo = l_Emp_Codigo
                 AND Con_Numero_Convenio = l_Convenio
                 AND Pla_Numero_Plan = l_Plan_Benef
                 AND Pt_Party_Id = l_Pt_Party_Id_Benef
                 AND Estado_Vigencia <> 'ELI';
              IF l_Tope_Descuento_Benef <> -1 THEN
                l_Tope_Descuento := l_Tope_Descuento_Benef;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                -- Se conserva el tope obtenido a nivel del plan / convenio
                NULL;
            END;
            l_Dbg_Proceso := 'Determinar las fechas inicial y final del periodo a evaluar';
            Obtener_Fechas(p_Empresa       => l_Emp_Codigo
                          ,p_Convenio      => l_Convenio
                          ,p_Plan          => l_Plan
                          ,p_Party_Id      => l_Pt_Party_Id_Benef
                          ,p_Periodicidad  => l_Periodicidad_Descuento
                          ,p_Fecha_Consumo => l_Fecha_Consumo
                          ,p_Lista_Unica   => l_Lista_Unica
                          ,x_Fecha_Ini     => l_Fecha_Ini);
            l_Fecha_Fin   := To_Char(l_Fecha_Consumo
                                    ,'ddmmyyyyhh24miss');
            l_Dbg_Proceso := 'Obtener el Saldo Consumido dependiendo del Tipo de Descuento';
            IF l_Tipo_Descuento = 'IND' THEN
              -- Determinar Saldo Consumido ( suma de descuentos entre fecha_ini y fecha_fin )
              BEGIN
                l_Dbg_Proceso := 'Obtener Saldo Descuento de tipo Individual';
                SELECT SUM(Decode(Tipo_Movimiento
                                 ,'DES'
                                 ,1
                                 ,'REV'
                                 ,-1) * Monto)
                  INTO l_Saldo_Consumido
                  FROM Scfr_Cuenta_Cte_Descuentos
                 WHERE Origen_Movimiento = 'CNV'
                   AND Convenio = l_Convenio
                   AND Plan = l_Plan
                   AND Rut = l_Rut
                   AND Secuencia = l_Secuencia
                   AND Incluido_En_Calculo = 'SI'
                   AND Fecha_Hora_Movimiento >= To_Date(l_Fecha_Ini
                                                       ,'ddmmyyyyhh24miss')
                   AND Fecha_Hora_Movimiento <= To_Date(l_Fecha_Fin
                                                       ,'ddmmyyyyhh24miss');
              EXCEPTION
                WHEN OTHERS THEN
                  l_Saldo_Consumido := 0;
              END;
            ELSIF l_Tipo_Descuento = 'GRU' THEN
              BEGIN
                l_Dbg_Proceso := 'Obtener Saldo Descuento de tipo Grupal';
                SELECT SUM(Decode(T0.Tipo_Movimiento
                                 ,'DES'
                                 ,1
                                 ,'REV'
                                 ,-1) * T0.Monto)
                  INTO l_Saldo_Consumido
                  FROM Scfr_Cuenta_Cte_Descuentos T0
                      ,Scfr_Beneficiarios         T1
                      ,Scfr_Beneficiarios         T2
                 WHERE T0.Origen_Movimiento = Fila_Boletas.Tipo_Descuento
                   AND T0.Convenio = l_Convenio
                   AND T0.Plan = l_Plan
                   AND T0.Incluido_En_Calculo = 'SI'
                   AND T0.Fecha_Hora_Movimiento >= To_Date(l_Fecha_Ini
                                                          ,'ddmmyyyyhh24miss')
                   AND T0.Fecha_Hora_Movimiento <= To_Date(l_Fecha_Fin
                                                          ,'ddmmyyyyhh24miss')
                   AND T0.Rut = T1.Rut_Beneficiario
                   AND T1.Con_Numero_Convenio = T0.Convenio
                   AND T1.Pla_Numero_Plan = l_Plan_Benef --t0.plan
                   AND T1.Rut_Titular = T2.Rut_Titular
                   AND T2.Con_Numero_Convenio = T1.Con_Numero_Convenio
                   AND T2.Pla_Numero_Plan = T1.Pla_Numero_Plan
                   AND T2.Rut_Beneficiario = l_Rut
                   AND T2.Estado_Vigencia <> 'ELI';
              EXCEPTION
                WHEN OTHERS THEN
                  l_Saldo_Consumido := 0;
              END;
            ELSE
              l_Saldo_Consumido := 0;
            END IF;
          END IF;
        ELSIF Fila_Boletas.Tipo_Descuento = 'CAM' THEN
          -- Obtener el numero de campa?a
          l_Dbg_Proceso := 'Determinar el numero de Campa?a';
          l_Campana     := Fila_Boletas.Campana_Convenio;
          -- Obtener el tope de la campa?a para el cliente
          l_Dbg_Proceso := 'Determinar el Tope de Descuento para la campa?a';
          BEGIN
            SELECT Restriccion_Minima
                  ,Restriccion_Maxima
              INTO l_Tope_Descuento
                  ,l_Periodicidad
              FROM Scfr_Condiciones
             WHERE Cam_Campana = Fila_Boletas.Campana_Convenio
               AND Tipo_Condicion = 'CCD';
            l_Incluir_En_Cartola := 'SI';
          EXCEPTION
            WHEN No_Data_Found THEN
              l_Incluir_En_Cartola := 'NO';
              l_Tope_Descuento     := 0;
              l_Periodicidad       := 0;
            WHEN OTHERS THEN
              l_Incluir_En_Cartola := 'NO';
              l_Tope_Descuento     := 0;
              l_Periodicidad       := 0;
          END;
          IF l_Incluir_En_Cartola = 'SI' THEN
            -- Obtener el rut
            l_Rut         := p_Transaccion.Rut_Titular;
            l_Dbg_Proceso := 'Determinar las fechas inicial y final del periodo a evaluar';
            Scfr_Trx_Fid_Pk.Obtener_Fechas_Cam(p_Campana       => Fila_Boletas.Campana_Convenio
                                              ,p_Rut           => l_Rut
                                              ,p_Periodicidad  => l_Periodicidad
                                              ,p_Fecha_Consumo => p_Transaccion.Fecha_Tx
                                              ,x_Fecha_Ini     => l_Fecha_Ini);
            -- Determinar Saldo Consumido ( suma de descuentos entre fecha_ini y fecha_fin )
            BEGIN
              l_Dbg_Proceso := 'Obtener Saldo Consumido';
              SELECT SUM(Decode(Tipo_Movimiento
                               ,'DES'
                               ,1
                               ,'REV'
                               ,-1) * Monto)
                INTO l_Saldo_Consumido
                FROM Scfr_Cuenta_Cte_Descuentos
               WHERE Origen_Movimiento = 'CAM'
                 AND Campana = Fila_Boletas.Campana_Convenio
                 AND Rut = l_Rut
                 AND Incluido_En_Calculo = 'SI'
                 AND Fecha_Hora_Movimiento >= l_Fecha_Ini
                 AND Fecha_Hora_Movimiento <= p_Transaccion.Fecha_Tx;
            EXCEPTION
              WHEN OTHERS THEN
                l_Saldo_Consumido := 0;
            END;
          END IF;
        ELSE
          -- Otros movimientos de tipo AJU (en la tabla scfr_mov_descuentos_productos)
          l_Incluir_En_Cartola := 'NO';
          NULL;
        END IF;
        IF l_Incluir_En_Cartola = 'SI' THEN
          l_Dbg_Proceso         := 'Determinar el Saldo Disponible';
          l_Unidades_Descuentos := Abs(Fila_Boletas.Unidades);
          IF l_Saldo_Consumido IS NULL THEN
            l_Saldo_Consumido := Fila_Boletas.Monto;
          ELSE
            IF p_Tipo = 'DES' THEN
              l_Saldo_Consumido := l_Saldo_Consumido + Fila_Boletas.Monto;
            ELSE
              l_Saldo_Consumido := l_Saldo_Consumido - Fila_Boletas.Monto;
            END IF;
          END IF;
          l_Saldo_Disponible := Nvl(l_Tope_Descuento
                                   ,0) - l_Saldo_Consumido;
          INSERT INTO Scfr_Cuenta_Cte_Descuentos
            (Cta_Cte
            ,Rut
            ,Fecha_Hora_Movimiento
            ,Origen_Movimiento
            ,Tipo_Movimiento
            ,Codigo_Tx
            ,Convenio
            ,Plan
            ,Secuencia
            ,Campana
            ,Boleta
            ,Monto
            ,Saldo_Consumido
            ,Saldo_Disponible
            ,Movimiento_Offline
            ,Codigo_Tx_Reversado
            ,Observacion
            ,Incluido_En_Calculo
            ,Unidades_Descuento)
          VALUES
            (Scfr_Cuenta_Cte_Descuentos_s.Nextval -- cta_cte
            ,l_Rut -- rut
            ,p_Transaccion.Fecha_Tx -- fecha_hora_movimiento
            ,Fila_Boletas.Tipo_Descuento -- origen_movimiento
            ,p_Tipo -- tipo_movimiento
            ,p_Transaccion.Codigo_Tx -- codigo_tx
            ,l_Convenio -- convenio
            ,l_Plan -- plan
            ,l_Secuencia -- secuencia
            ,l_Campana -- campana
            ,Fila_Boletas.Folio -- boleta
            ,Fila_Boletas.Monto -- monto
            ,l_Saldo_Consumido -- saldo_consumido
            ,l_Saldo_Disponible -- saldo_disponible
            ,p_Offline -- movimiento_offline
            ,l_Codigo_Tx_Reversado -- codigo_tx_reversado
            ,p_Observacion -- observacion
            ,p_Incluido -- incluido_en_calculo
            ,l_Unidades_Descuentos -- Unidades Descuentos
             );
        END IF;
      EXCEPTION
        WHEN Dup_Val_On_Index THEN
          Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                    ,p_Msg     => 'Movimiento Duplicado en scfr_cuenta_cte_descuentos. ' || 'Rut Benef => ' || l_Rut || 'Cod.TX => ' ||
                                                  p_Transaccion.Codigo_Tx || 'Origen => ' || Fila_Boletas.Tipo_Descuento || 'Tipo => ' || p_Tipo ||
                                                  'Cam/Cnv => ' || l_Convenio || '/' || l_Campana);
        WHEN OTHERS THEN
          Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                    ,p_Msg     => 'Error al insertar en scfr_cuenta_cte_descuentos. Error => ' || SQLERRM);
      END;
    END LOOP;
    /*
        l_DBG_MENSAJE := 'Registrar configuracion descuento en scfr_mov_transacciones';
        begin
          update scfr_mov_transacciones
             set tipo_descuento         =
               , monto_descuento        =
               , periodicidad_descuento =
               , tope_descuento_offline =
            where codigo_tx = p_transaccion.codigo_tx
          if sql%notfound then
            scfr_trx_util_pk.debug_msg( p_proceso => l_DBG_PROCESO
                                      , p_msg     => 'No se pudo actualizar scfr_mov_transacciones para codigo_tx=>'||p_transaccion.codigo_tx);
          end if;
        end;
    */
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - Error=>' || SQLERRM);
  END Registra_En_Cta_Cte_Descuento1;

  PROCEDURE Registra_Cartola_Desde_Batch(p_Fecha IN DATE
                                        ,p_Local IN NUMBER) IS
    CURSOR c_Txs IS
      SELECT Codigo_Tx
            ,Emp_Empresa
            ,Cad_Cadena
            ,Loc_Local
            ,Fecha_Tx
            ,Txo_Codigo_Tx_Relacionado
            ,Rut_Titular
        FROM Scfr_Mov_Transacciones
       WHERE Trunc(Fecha_Tx) = Trunc(p_Fecha)
         AND Loc_Local = p_Local
         AND Inyectado = 'SI'
       ORDER BY Fecha_Tx;
    l_Transaccion Scfr_Trx_Dyn_Pk.Rec_Transaccion;
    l_Cod_Error   NUMBER;
    l_Msg_Error   VARCHAR2(1000);
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.registra_cartola_desde_batch()';
    l_Dbg_Mensaje VARCHAR2(1000);
    l_Tipo        Scfr_Cuenta_Cte_Descuentos.Tipo_Movimiento%TYPE;
    l_Offline     Scfr_Cuenta_Cte_Descuentos.Movimiento_Offline%TYPE;
  BEGIN
    l_Dbg_Mensaje := 'Recorrer TXS Inyectadas del ' || To_Char(p_Fecha
                                                              ,'dd/mm/yyyy') || ' del Local ' || p_Local;
    FOR Fila_Txs IN c_Txs
    LOOP
      BEGIN
        l_Dbg_Mensaje                   := 'Llenar arreglo l_transaccion';
        l_Transaccion.Fecha_Tx          := Fila_Txs.Fecha_Tx;
        l_Transaccion.Codigo_Tx         := Fila_Txs.Codigo_Tx;
        l_Transaccion.Trama_Pos.Empresa := Fila_Txs.Emp_Empresa;
        l_Transaccion.Trama_Pos.Cadena  := Fila_Txs.Cad_Cadena;
        l_Transaccion.Trama_Pos.Local   := Fila_Txs.Loc_Local;
        l_Transaccion.Rut_Titular       := Fila_Txs.Rut_Titular;
        l_Dbg_Mensaje                   := 'Determinar el tipo de registro: DEScuento o REVersa';
        IF Fila_Txs.Txo_Codigo_Tx_Relacionado IS NULL THEN
          l_Tipo := 'DES';
        ELSE
          l_Tipo := 'REV';
        END IF;
        l_Dbg_Mensaje := 'Determinar si el registro es Fuera de Linea';
        l_Offline     := 'NO';
        l_Dbg_Mensaje := 'Llamar a Registra_En_Cta_Cte_Descuento1';
        Registra_En_Cta_Cte_Descuento1(p_Transaccion => l_Transaccion
                                      ,p_Tipo        => l_Tipo
                                      ,p_Offline     => l_Offline
                                      ,p_Observacion => 'Insertado desde BATCH'
                                      ,p_Incluido    => 'SI'
                                      ,x_Cod_Error   => l_Cod_Error
                                      ,x_Msg_Error   => l_Msg_Error);
        IF l_Cod_Error <> 0 THEN
          Dbms_Output.Put_Line(l_Dbg_Proceso || '. ' || 'Error al intentar ' || l_Dbg_Mensaje || ' - Error => ' || l_Msg_Error);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          Dbms_Output.Put_Line(l_Dbg_Proceso || '. ' || 'Error al intentar ' || l_Dbg_Mensaje || ' - Error => ' || l_Msg_Error);
      END;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - Error => ' || l_Msg_Error);
  END Registra_Cartola_Desde_Batch;

  /*
    Cheques si la transaccion de recaudacion (GNCU05) ya fue commiteada en el sistema.
    y actualiza el CODIGO_TX de la venta.
    Esto ocurre luego de haber commiteado la venta (GNCU01).
  */
  PROCEDURE Actualiza_Relacion_Venta(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion) IS
    l_Trama_Dv         Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv;
    l_Trama_Cv         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv;
    l_Data_Com         Scfr_Trx_Dyn_Types_Pk.Rec_Data_Com;
    l_Itm              NUMBER;
    l_Codigo_Tx_Recaud NUMBER;
    l_Fecha_Tx         NUMBER;
    l_Cod_Error        NUMBER;
    l_Msg_Error        VARCHAR2(250);
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.actualiza_relacion_venta';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Doc_Relacionados NUMBER;
    l_Lleva_Doc_Rel    VARCHAR2(2);
    l_Offline          VARCHAR2(2);
    l_Codaut_Cnv       NUMBER;
    l_Agrupa_Perfil    VARCHAR2(3);
    l_Flag_Ban         VARCHAR2(3);
    l_Flag_Geo         VARCHAR2(3);
    x_Respuesta        NUMBER;
    x_Estado           VARCHAR2(300);
    x_Cod_Error        NUMBER;
    x_Msg_Error        VARCHAR2(300);
  BEGIN
    l_Dbg_Mensaje      := 'Obtener informacion del Header';
    l_Data_Com         := Scfr_Trx_Dyn_Utl_Pk.Carga_Datos_Com(p_Transaccion);
    l_Trama_Dv         := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Dv(p_Transaccion.Trama_Pos
                                                            ,p_Transaccion.Cuerpo_Tx);
    l_Doc_Relacionados := l_Trama_Dv.Subtrama_Dv2.Count;
    l_Trama_Cv         := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Cv(p_Transaccion.Cuerpo_Tx);

    -- Registra Venta SRI.

    --   BEGIN
    --    Pkg_Sri.Proc_Procesa(p_Transaccion.Trama_Pos.Empresa
    --                        ,p_Transaccion.Trama_Pos.Local
    --                        ,p_Transaccion.Trama_Pos.Numero_Pos
    --                        ,p_Transaccion.Fecha_Tx
    --                        ,p_Transaccion.Codigo_Tx
    --                        ,TRIM(L_Trama_Dv.Subtrama_Dv1(1).Folio)
    --                        ,x_Respuesta
    --                        ,x_Estado
    --                        ,x_Cod_Error
    --                        ,x_Msg_Error);
    --     EXCEPTION WHEN OTHERS THEN
    --       x_Cod_Error := 0;
    --       x_Msg_Error := NULL;
    --    END;

    IF p_Transaccion.Trama_Pos.Plataforma = 'U' THEN
      l_Flag_Geo := 'GEO';
    ELSE
      l_Flag_Geo := 'POS';
    END IF;
    -- Determinar modalidad BAN-FCV
    BEGIN
      SELECT Nvl(Agrupacion_Perfil
                ,'')
        INTO l_Agrupa_Perfil
        FROM Scfr_Convenios c
       WHERE c.Numero_Convenio = l_Trama_Cv(1).Convenio;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Agrupa_Perfil := NULL;
    END;
    IF l_Agrupa_Perfil NOT IN ('BAN'
                              ,'VDT') THEN
      l_Flag_Ban := 'OLD';
    ELSE
      l_Flag_Ban := 'NEW';
    END IF;
    FOR l_Itm IN 1 .. l_Trama_Dv.Subtrama_Dv2.Count
    LOOP
      --  busca recaudacion asociada
      l_Dbg_Mensaje := 'Buscar CODIGO_TX de recaudacion en SCFR_MOV_TRANSACCIONES - Corr.Recaud= ' || l_Trama_Dv.Subtrama_Dv2(l_Itm).Correlativo_Tx;
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => l_Dbg_Mensaje);
      BEGIN
        SELECT Mtr.Codigo_Tx
          INTO l_Codigo_Tx_Recaud
          FROM Scfr_Mov_Transacciones Mtr
         WHERE Mtr.Emp_Empresa = p_Transaccion.Trama_Pos.Empresa
           AND Mtr.Cad_Cadena = p_Transaccion.Trama_Pos.Cadena
           AND Mtr.Loc_Local = p_Transaccion.Trama_Pos.Local
           AND Mtr.Tmo_Movimiento_Padre IN ('RECAUD'
                                           ,'AVANCE')
           AND Mtr.Correlativo_Tx = l_Trama_Dv.Subtrama_Dv2(l_Itm).Correlativo_Tx;
      EXCEPTION
        WHEN No_Data_Found THEN
          l_Codigo_Tx_Recaud := 0;
      END;
      IF l_Codigo_Tx_Recaud > 0 THEN
        l_Dbg_Mensaje := 'Actualizar CODIGO_TX de recaudacion en SCFR_MOV_TX_RELACIONADAS - Corr.Recaud= ' || l_Trama_Dv.Subtrama_Dv2(l_Itm).Correlativo_Tx ||
                         ' CodTX=' || l_Codigo_Tx_Recaud;
        UPDATE Scfr_Mov_Tx_Relacionadas
           SET Txo_Codigo_Tx_Relacionado = l_Codigo_Tx_Recaud
              ,Procesado                 = Nvl2(Procesado
                                               ,2
                                               ,Procesado)
         WHERE Txo_Codigo_Tx = p_Transaccion.Codigo_Tx;
      END IF;
    END LOOP;
    -- Realiza cierre de convenio
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'CV') THEN
      BEGIN
        IF Nvl(Ltrim(Rtrim(l_Trama_Dv.Ot))
              ,'0') = '0' THEN
          IF l_Doc_Relacionados > 0 THEN
            l_Lleva_Doc_Rel := 'SI';
          ELSE
            l_Lleva_Doc_Rel := 'NO';
          END IF;
          -- realiza cierre solo cuando la venta y la recaudacion han llegado (venta con pago periodos)
          -- o cuando esta la venta (sin pago de periodos)
          IF l_Lleva_Doc_Rel = 'NO' OR
             l_Codigo_Tx_Recaud > 0 THEN
            l_Dbg_Mensaje := 'LLamar a scfr_conv_pk.cierre_transacion - CODIGO_TX=' || p_Transaccion.Codigo_Tx;
            Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                      ,p_Msg     => l_Dbg_Mensaje);
            Scfr_Conv_Pk.Cierre_Transacciones(p_Transaccion.Codigo_Tx
                                             ,p_Transaccion.Trama_Pos.Local
                                             ,l_Lleva_Doc_Rel
                                             ,l_Flag_Ban
                                             ,l_Data_Com
                                             ,l_Flag_Geo
                                             ,l_Cod_Error
                                             ,l_Msg_Error);
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
    Scfr_Trx_Util_Pk.Debug_Commit(x_Coderror => l_Cod_Error
                                 ,x_Msgerror => l_Msg_Error);
    COMMIT;
    -- Aqui deberia ir el registra_cta...
    l_Dbg_Mensaje := 'Determinar si la transaccion es Fuera de Linea';
    BEGIN
      SELECT To_Number(Autorizacion_Cnv_Tx) INTO l_Codaut_Cnv FROM Scfr_Mov_Transacciones WHERE Codigo_Tx = p_Transaccion.Codigo_Tx;
      l_Offline := 'NO';
    EXCEPTION
      WHEN OTHERS THEN
        l_Offline := 'SI';
    END;
    -- Genera un movimiento en la Cuenta Cte. de Descuentos si corresponde
    l_Dbg_Mensaje := 'Registrar Movimiento en Cta. Cte. Descuentos';
    Registra_En_Cta_Cte_Descuento1(p_Transaccion => p_Transaccion
                                  ,p_Tipo        => 'DES'
                                  ,p_Offline     => l_Offline
                                  ,p_Incluido    => 'SI'
                                  ,p_Observacion => NULL
                                  ,x_Cod_Error   => l_Cod_Error
                                  ,x_Msg_Error   => l_Msg_Error);
    IF l_Cod_Error <> 0 THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - Cod_tx=>' || p_Transaccion.Codigo_Tx || ', Local=>' ||
                                              p_Transaccion.Trama_Pos.Local);
    END IF;
    COMMIT;
    l_Dbg_Mensaje := 'Actualizar registro en SCFR_REG_OPCION_SOLICITUD';
    UPDATE Scfr_Reg_Opcion_Solicitud
       SET Txo_Codigo_Tx = p_Transaccion.Codigo_Tx
     WHERE Loc_Local = p_Transaccion.Trama_Pos.Local
       AND Numero_Preventa = l_Trama_Dv.Numero_Preventa;
    IF SQL%NOTFOUND THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - Cod_tx=>' || p_Transaccion.Codigo_Tx || ', Local=>' ||
                                              p_Transaccion.Trama_Pos.Local || ', PreVta=>' || l_Trama_Dv.Numero_Preventa);
    END IF;
    COMMIT;
    -- Fin
    -- genera un movimiento en la cuenta cte. de recetas si corresponde
    l_Dbg_Mensaje := 'Registrar movimiento de Retiro en cta. cte. recetas';
    /* SJC: Se elimina restriccion de que venga la trama RP puesto que esta solo viene cuando se inscribe una receta, */
    /* por lo tanto no se registraban los retiros posteriores                                                         */
    --   IF Scfr_Trx_Dyn_Pk.contiene_trama( p_transaccion.cuerpo_tx, 'RP' ) THEN
    Registra_En_Cta_Cte_Recetas(p_Transaccion => p_Transaccion
                               ,p_Tipo        => k_Retiro_Receta
                               ,x_Cod_Error   => l_Cod_Error
                               ,x_Msg_Error   => l_Msg_Error);
    --    END IF;
  END;

  /*
    Chequea si la transaccion de venta ( GNCU01) ya fue commiteada en el sistema.
    y actualiza el CODIGO_TX de la recaudacion
    Esto ocurre luego de haber commiteado la recaudacion (GNCU05).
  */
  PROCEDURE Actualiza_Relacion_Recaud(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion) IS
    l_Trama_Dv      Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv;
    l_Trama_Cv      Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cv;
    l_Data_Com      Scfr_Trx_Dyn_Types_Pk.Rec_Data_Com;
    l_Itm           NUMBER;
    l_Codigo_Tx     NUMBER;
    l_Fecha_Tx      NUMBER;
    l_Cod_Error     NUMBER;
    l_Rowid         ROWID;
    l_Msg_Error     VARCHAR2(250);
    l_Dbg_Proceso   VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.actualiza_relacion_recaud';
    l_Dbg_Mensaje   VARCHAR2(250) := 'Error General';
    l_Lleva_Doc_Rel VARCHAR2(2) := 'NO';
    l_Agrupa_Perfil VARCHAR2(3);
    l_Flag_Ban      VARCHAR2(3);
    l_Flag_Geo      VARCHAR2(3);
  BEGIN
    l_Dbg_Mensaje := 'Obtener informacion del Header';
    l_Data_Com    := Scfr_Trx_Dyn_Utl_Pk.Carga_Datos_Com(p_Transaccion);
    l_Trama_Cv    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Cv(p_Transaccion.Cuerpo_Tx);
    l_Dbg_Mensaje := 'Actualizar CODIGO_TX de recaudacion en SCFR_MOV_TX_RELACIONADAS - Corr.Recaud= ' || p_Transaccion.Correlativo_Tx || ' CodTX=' ||
                     p_Transaccion.Codigo_Tx;
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => l_Dbg_Mensaje);
    IF p_Transaccion.Trama_Pos.Plataforma = 'U' THEN
      l_Flag_Geo := 'GEO';
    ELSE
      l_Flag_Geo := 'POS';
    END IF;
    -- Determinar modalidad BAN-FCV
    SELECT Nvl(Agrupacion_Perfil
              ,'')
      INTO l_Agrupa_Perfil
      FROM Scfr_Convenios c
     WHERE c.Numero_Convenio = l_Trama_Cv(1).Convenio;
    IF l_Agrupa_Perfil NOT IN ('BAN'
                              ,'VDT') THEN
      l_Flag_Ban := 'OLD';
    ELSE
      l_Flag_Ban := 'NEW';
    END IF;
    -- chequea si reccaudacion fue generada por recetario magistral o por banmedica
    -- si es por recetario SIEMPRE trae trama de productos. en el otro caso, NUNCA trae trama.
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'PM') THEN
      BEGIN
        l_Dbg_Mensaje := 'LLamar a scfr_conv_pk.cierre_transacion - CODIGO_TX=' || p_Transaccion.Codigo_Tx;
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => l_Dbg_Mensaje);
        Scfr_Conv_Pk.Cierre_Transacciones(p_Transaccion.Codigo_Tx
                                         ,p_Transaccion.Trama_Pos.Local
                                         ,l_Lleva_Doc_Rel
                                         ,l_Flag_Ban
                                         ,l_Data_Com
                                         ,l_Flag_Geo
                                         ,l_Cod_Error
                                         ,l_Msg_Error);
      EXCEPTION
        WHEN OTHERS THEN
          -- No registra como error, solo como log. Transaccion termina correctamente.
          Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                    ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - codigo_tx=' || p_Transaccion.Codigo_Tx || ',LOCAL=' ||
                                                  p_Transaccion.Trama_Pos.Local);
      END;
    ELSE
      -- obtiene CODIGO_TX de la venta relacionada a la Recaudacion (en el caso que exista copago)
      BEGIN
        SELECT ROWID
              ,Txo_Codigo_Tx
          INTO l_Rowid
              ,l_Codigo_Tx
          FROM Scfr_Mov_Tx_Relacionadas
         WHERE Correlativo_Tx_Relacionado = p_Transaccion.Correlativo_Tx
           AND LOCAL = p_Transaccion.Trama_Pos.Local
           AND Trunc(Fecha_Tx) = Trunc(p_Transaccion.Fecha_Tx)
           AND Numero_Maquina = p_Transaccion.Trama_Pos.Numero_Pos;
        l_Lleva_Doc_Rel := 'SI';
      EXCEPTION
        WHEN No_Data_Found THEN
          l_Codigo_Tx     := NULL;
          l_Rowid         := NULL;
          l_Lleva_Doc_Rel := 'NO';
      END;
      IF l_Rowid IS NOT NULL THEN
        -- actualiza el CODIGO_TX de la recaudacion en la tabla de relacion
        UPDATE Scfr_Mov_Tx_Relacionadas
           SET Txo_Codigo_Tx_Relacionado = p_Transaccion.Codigo_Tx
              ,Procesado                 = Nvl2(Procesado
                                               ,2
                                               ,Procesado)
         WHERE ROWID = l_Rowid;
      END IF;
      -- Realiza cierre de convenio
      IF l_Codigo_Tx IS NOT NULL AND
         Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                       ,'CV') THEN
        BEGIN
          l_Dbg_Mensaje := 'LLamar a scfr_conv_pk.cierre_transacion - CODIGO_TX=' || l_Codigo_Tx;
          Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                    ,p_Msg     => l_Dbg_Mensaje);
          Scfr_Conv_Pk.Cierre_Transacciones(l_Codigo_Tx
                                           ,p_Transaccion.Trama_Pos.Local
                                           ,l_Lleva_Doc_Rel
                                           ,l_Flag_Ban
                                           ,l_Data_Com
                                           ,l_Flag_Geo
                                           ,l_Cod_Error
                                           ,l_Msg_Error);
        EXCEPTION
          WHEN OTHERS THEN
            -- No registra como error, solo como log. Transaccion termina correctamente.
            Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                      ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje || ' - codigo_tx=' || p_Transaccion.Codigo_Tx || ',LOCAL=' ||
                                                    p_Transaccion.Trama_Pos.Local);
            l_Cod_Error := 0;
        END;
      END IF;
    END IF;
    Scfr_Trx_Util_Pk.Debug_Commit(x_Coderror => l_Cod_Error
                                 ,x_Msgerror => l_Msg_Error);
    COMMIT;
  END;

  /*
    Cheques si la transaccion de recaudacion (GNCU07) ya fue commiteada en el sistema.
    y actualiza el CODIGO_TX de la venta.
    Esto ocurre luego de haber commiteado la venta (GNCU01).
  */
  PROCEDURE Actualiza_Relacion_Avance(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion) IS
    l_Codigo_Tx      NUMBER;
    l_Cod_Error      NUMBER;
    l_Rowid          ROWID;
    l_Msg_Error      VARCHAR2(250);
    l_Dbg_Proceso    VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.actualiza_relacion_avance';
    l_Dbg_Mensaje    VARCHAR2(250) := 'Error General';
    l_Codigo_Trx     VARCHAR2(6);
    x_Codigo_Tx      Scfr_Mov_Transacciones.Codigo_Tx%TYPE;
    x_Correlativo_Tx Scfr_Mov_Transacciones.Correlativo_Tx%TYPE;
  BEGIN
    l_Dbg_Mensaje := 'Actualizar CODIGO_TX de avance en SCFR_MOV_TX_RELACIONADAS - Corr.avance= ' || p_Transaccion.Correlativo_Tx || ' CodTX=' ||
                     p_Transaccion.Codigo_Tx;
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => l_Dbg_Mensaje);
    l_Codigo_Trx := p_Transaccion.Trama_Pos.Sistema || p_Transaccion.Trama_Pos.Funcion || p_Transaccion.Trama_Pos.Secuencia_c;
    -- obtiene CODIGO_TX de la venta relacionada al avance
    IF l_Codigo_Trx = 'GNCU01' THEN
      BEGIN
        SELECT Correlativo_Tx_Relacionado INTO x_Correlativo_Tx FROM Scfr_Mov_Tx_Relacionadas WHERE Txo_Codigo_Tx = p_Transaccion.Codigo_Tx;
      EXCEPTION
        WHEN No_Data_Found THEN
          x_Correlativo_Tx := 0;
      END;
      BEGIN
        SELECT Codigo_Tx
          INTO x_Codigo_Tx
          FROM Scfr_Mov_Transacciones
         WHERE Loc_Local = p_Transaccion.Trama_Pos.Local
           AND Correlativo_Tx = x_Correlativo_Tx;
      EXCEPTION
        WHEN No_Data_Found THEN
          x_Codigo_Tx := 0;
      END;
      IF x_Codigo_Tx > 0 AND
         x_Correlativo_Tx > 0 THEN
        BEGIN
          SELECT ROWID
                ,Txo_Codigo_Tx
            INTO l_Rowid
                ,l_Codigo_Tx
            FROM Scfr_Mov_Tx_Relacionadas
           WHERE Correlativo_Tx_Relacionado = x_Correlativo_Tx
             AND LOCAL = p_Transaccion.Trama_Pos.Local
             AND Trunc(Fecha_Tx) = Trunc(p_Transaccion.Fecha_Tx)
             AND Numero_Maquina = p_Transaccion.Trama_Pos.Numero_Pos;
        EXCEPTION
          WHEN No_Data_Found THEN
            l_Codigo_Tx := NULL;
            l_Rowid     := NULL;
        END;
        IF l_Rowid IS NOT NULL THEN
          -- actualiza el CODIGO_TX del avance en la tabla de relacion
          UPDATE Scfr_Mov_Tx_Relacionadas
             SET Txo_Codigo_Tx_Relacionado = x_Codigo_Tx
                ,Procesado                 = Nvl2(Procesado
                                                 ,2
                                                 ,Procesado)
           WHERE ROWID = l_Rowid;
          l_Dbg_Mensaje := 'Se Actualizo CODIGO_TX_RELACIONADO de avance en SCFR_MOV_TX_RELACIONADAS - Corr.avance= ' || x_Correlativo_Tx ||
                           ' CodTX=' || x_Codigo_Tx;
          Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                    ,p_Msg     => l_Dbg_Mensaje);
        END IF;
      END IF;
    END IF;
    IF l_Codigo_Trx = 'GNCU07' THEN
      BEGIN
        SELECT ROWID
              ,Txo_Codigo_Tx
          INTO l_Rowid
              ,l_Codigo_Tx
          FROM Scfr_Mov_Tx_Relacionadas
         WHERE Correlativo_Tx_Relacionado = p_Transaccion.Correlativo_Tx
           AND LOCAL = p_Transaccion.Trama_Pos.Local
           AND Trunc(Fecha_Tx) = Trunc(p_Transaccion.Fecha_Tx)
           AND Numero_Maquina = p_Transaccion.Trama_Pos.Numero_Pos;
      EXCEPTION
        WHEN No_Data_Found THEN
          l_Codigo_Tx := NULL;
          l_Rowid     := NULL;
      END;
      IF l_Rowid IS NOT NULL THEN
        -- actualiza el CODIGO_TX del avance en la tabla de relacion
        UPDATE Scfr_Mov_Tx_Relacionadas
           SET Txo_Codigo_Tx_Relacionado = p_Transaccion.Codigo_Tx
              ,Procesado                 = Nvl2(Procesado
                                               ,2
                                               ,Procesado)
         WHERE ROWID = l_Rowid;
        l_Dbg_Mensaje := 'Se Actualizo CODIGO_TX_RELACIONADO de avance en SCFR_MOV_TX_RELACIONADAS - Corr.avance= ' || p_Transaccion.Correlativo_Tx ||
                         ' CodTX=' || p_Transaccion.Codigo_Tx;
        Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => l_Dbg_Mensaje);
      END IF;
    END IF;
    Scfr_Trx_Util_Pk.Debug_Commit(x_Coderror => l_Cod_Error
                                 ,x_Msgerror => l_Msg_Error);
    COMMIT;
  END Actualiza_Relacion_Avance;

  /*
    Cheques si existe transaccisn de pagos pendiente (GNCU03) para re-inyectar.
    Esto ocurre luego de haber commiteado la venta (GNCU01).
  */
  PROCEDURE Actualiza_Relacion_Pagos(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion) IS
    l_Salida         BLOB;
    l_Cod_Error      NUMBER;
    l_Msg_Error      VARCHAR2(250);
    l_Dbg_Proceso    VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.actualiza_relacion_pagos';
    l_Dbg_Mensaje    VARCHAR2(250) := 'Revisando GNCU03 Pendiente';
    l_Correlativo_Tx NUMBER;
    l_Estado         VARCHAR2(3) := 'N';
    CURSOR c_Pendientes IS
      SELECT Correlativo
            ,String_Entrada
            ,Numero_Envios Envios
        FROM Scfr_Trx_Rec_Act
       WHERE Numero_Boleta = To_Char(l_Correlativo_Tx)
         AND Numero_Empresa = p_Transaccion.Trama_Pos.Empresa
         AND Numero_Cadena = p_Transaccion.Trama_Pos.Cadena
         AND Numero_Local = p_Transaccion.Trama_Pos.Local
         AND Estado = l_Estado;
  BEGIN
    IF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                     ,'DV') THEN
      l_Correlativo_Tx := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Transaccion.Cuerpo_Tx
                                                            ,'DV'
                                                            ,'CORRELATIVO_TX');
    ELSIF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                        ,'DR') THEN
      l_Correlativo_Tx := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Transaccion.Cuerpo_Tx
                                                            ,'DR'
                                                            ,'CORRELATIVO_TX');
    ELSIF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                        ,'VD') THEN
      l_Correlativo_Tx := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Transaccion.Cuerpo_Tx
                                                            ,'VD'
                                                            ,'CORRELATIVO_TX');
    ELSIF Scfr_Trx_Dyn_Pk.Contiene_Trama(p_Transaccion.Cuerpo_Tx
                                        ,'MC') THEN
      l_Correlativo_Tx := Scfr_Trx_Dyn_Pk.Obtiene_Nvalor_Trx(p_Transaccion.Cuerpo_Tx
                                                            ,'MC'
                                                            ,'CORRELATIVO');
    END IF;
    Scfr_Trx_Util_Pk.Debug_On();
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => l_Dbg_Mensaje);
    l_Dbg_Mensaje := 'Obtener GNCU03 en estado NO_PROCESADA';
    BEGIN
      FOR r_Pendientes IN c_Pendientes
      LOOP
        IF r_Pendientes.Envios >= 5 THEN
          l_Dbg_Mensaje := 'Reinyectar GNCU03 correlativo ' || r_Pendientes.Correlativo;
          -- Reinyectar transaccion GNCU03 para regularizar datos de pagos (Impacto en GNCC02)
          Scfr_Ejec_Desde_Conc_Pk.Ejecutar_Transaccion(Pentrada   => r_Pendientes.String_Entrada
                                                      ,Psalida    => l_Salida
                                                      ,Pcod_Error => l_Cod_Error
                                                      ,Pmsg_Error => l_Msg_Error);
          IF l_Cod_Error = 0 THEN
            Dbms_Output.Put_Line('Transaccion GNCU03 correlativo ' || r_Pendientes.Correlativo || ' reinyectada satisfactoriamente');
            Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                      ,p_Msg     => 'Transaccion GNCU03 correlativo ' || r_Pendientes.Correlativo ||
                                                    ' reinyectada satisfactoriamente');
          ELSE
            Dbms_Output.Put_Line('Transaccion GNCU03 correlativo ' || r_Pendientes.Correlativo || ' no pudo ser reinyectada');
            Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                      ,p_Msg     => 'Transaccion GNCU03 correlativo ' || r_Pendientes.Correlativo || ' no pudo ser reinyectada');
          END IF;
        END IF;
      END LOOP;
      Scfr_Trx_Util_Pk.Debug_Off();
    EXCEPTION
      WHEN OTHERS THEN
        Dbms_Output.Put_Line('Error al intentar ' || l_Dbg_Mensaje);
        Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                  ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
        Scfr_Trx_Util_Pk.Debug_Off();
    END;
  END Actualiza_Relacion_Pagos;

  -- function : inserta_receta
  --    in :
  --       p_receta : Arreglo con informacion de la receta a registrar
  --    out :
  --       x_error : Codigo de retorno (0 sin error)
  --       x_error : Mensaje de error si corresponde
  --    Desc :
  --       Inserta en la tabla de Recetas retornando el ID de la receta registrada
  FUNCTION Inserta_Receta(p_Receta Reg_Receta
                         ,x_Error  OUT NUMBER
                         ,x_Msg    OUT VARCHAR2) RETURN NUMBER IS
    l_Id_Receta NUMBER;
  BEGIN
    BEGIN
      SELECT Scfr_Rec_Recetas_s.Nextval INTO l_Id_Receta FROM Dual;
    EXCEPTION
      WHEN OTHERS THEN
        l_Id_Receta := NULL;
    END;
    -- Inserta Encabezado de la Receta
    INSERT INTO Scfr_Rec_Recetas
      (Id_Receta
      ,Serie
      ,Secuencia_Receta
      ,Rut_Medico
      ,Dv_Medico
      ,Nombre_Medico
      ,Fecha_Emision
      ,Diagnostico
      ,Tipo_Receta
      ,Con_Copia
      ,Folio_Receta
      ,Tipo_Medicamento
      ,Rut_Paciente
      ,Dv_Paciente
      ,Nombre_Paciente
      ,Fecha_Ingreso
      ,Fono_Paciente
      ,Convenio
      ,Plan
      ,Rut_Cliente
      ,Dv_Cliente
      ,Rut_Institucion
      ,Dv_Institucion)
    VALUES
      (l_Id_Receta
      ,p_Receta.Serie
      ,p_Receta.Secuencia_Receta
      ,p_Receta.Rut_Medico
      ,p_Receta.Dv_Medico
      ,p_Receta.Nombre_Medico
      ,p_Receta.Fecha_Emision
      ,p_Receta.Diagnostico
      ,p_Receta.Tipo_Receta
      ,p_Receta.Con_Copia
      ,p_Receta.Folio_Receta
      ,p_Receta.Tipo_Medicamento
      ,p_Receta.Rut_Paciente
      ,p_Receta.Dv_Paciente
      ,p_Receta.Nombre_Paciente
      ,p_Receta.Fecha_Ingreso
      ,p_Receta.Fono_Paciente
      ,p_Receta.Convenio
      ,p_Receta.Plan
      ,p_Receta.Rut_Cliente
      ,p_Receta.Dv_Cliente
      ,p_Receta.Rut_Institucion
      ,p_Receta.Dv_Institucion);
    x_Error := 0;
    x_Msg   := NULL;
    RETURN l_Id_Receta;
  EXCEPTION
    WHEN Dup_Val_On_Index THEN
      x_Error := -1;
      x_Msg   := 'Se duplica llave en SCFR_REC_RECETAS';
      RETURN 0;
    WHEN OTHERS THEN
      x_Error := -2;
      x_Msg   := SQLERRM;
      RETURN 0;
  END Inserta_Receta;

  -- procedure : inserta_producto
  --    in :
  --       p_producto : Arreglo con informacion del producto asociado a una receta
  --    out :
  --       x_error : Codigo de retorno (0 sin error)
  --       x_error : Mensaje de error si corresponde
  --    Desc :
  --       Inserta en la tabla de Productos asociados a una receta
  PROCEDURE Inserta_Producto(p_Producto IN Reg_Producto
                            ,x_Error    OUT NUMBER
                            ,x_Msg      OUT VARCHAR2) IS
    l_Id_Detalle NUMBER;
  BEGIN
    BEGIN
      SELECT Scfr_Rec_Productos_s.Nextval INTO l_Id_Detalle FROM Dual;
    EXCEPTION
      WHEN OTHERS THEN
        l_Id_Detalle := NULL;
    END;
    INSERT INTO Scfr_Rec_Productos
      (Id_Detalle
      ,Rec_Id_Receta
      ,Producto
      ,Cantidad
      ,Dosis
      ,Veces
      ,Dias
      ,Inscribir_Refill
      ,Texto
      ,Forma_Farmaceutica
      ,Estado_Producto)
    VALUES
      (l_Id_Detalle
      ,p_Producto.Rec_Id_Receta
      ,p_Producto.Producto
      ,p_Producto.Cantidad
      ,p_Producto.Dosis
      ,p_Producto.Veces
      ,p_Producto.Dias
      ,p_Producto.Inscribir_Refill
      ,p_Producto.Texto
      ,p_Producto.Forma_Farmaceutica
      ,'ACT');
    x_Error := 0;
    x_Msg   := NULL;
  EXCEPTION
    WHEN Dup_Val_On_Index THEN
      x_Error := -1;
      x_Msg   := 'Se duplica llave en SCFR_REC_PRODUCTOS';
    WHEN OTHERS THEN
      x_Error := -2;
      x_Msg   := SQLERRM;
  END Inserta_Producto;

  -- procedure : prepara_datos_receta
  --    in :
  --       p_receta : Registro de datos de la Receta
  --       p_trama_rp : Arreglo en la transaccion con datos de la receta
  --    Desc :
  --       Prepara el registro para insertar datos de la receta
  PROCEDURE Prepara_Datos_Receta(p_Receta      IN OUT Reg_Receta
                                ,p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                ,p_Trama_Rp    IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp) IS
    l_Rut          NUMBER;
    l_Dv           VARCHAR2(1);
    l_Rut_Completo VARCHAR2(20);
  BEGIN
    l_Rut                     := p_Transaccion.Rut_Titular;
    l_Dv                      := Scfr_Trx_Util_Pk.Dv_Rut(p_Transaccion.Rut_Titular);
    p_Receta.Serie            := p_Trama_Rp(1).Serie;
    p_Receta.Secuencia_Receta := p_Trama_Rp(1).Secuencia_Receta;
    p_Receta.Rut_Medico       := p_Trama_Rp(1).Rut_Medico;
    p_Receta.Dv_Medico        := p_Trama_Rp(1).Dv_Rut_Medico;
    p_Receta.Nombre_Medico    := p_Trama_Rp(1).Nombre_Medico;
    p_Receta.Fecha_Emision    := To_Date(p_Trama_Rp(1).Emision
                                        ,'yyyymmdd');
    p_Receta.Diagnostico      := p_Trama_Rp(1).Diagnostico;
    p_Receta.Tipo_Receta      := p_Trama_Rp(1).Tipo_Receta;
    p_Receta.Con_Copia        := p_Trama_Rp(1).Con_Copia;
    p_Receta.Folio_Receta     := p_Trama_Rp(1).Folio_Receta;
    p_Receta.Tipo_Medicamento := p_Trama_Rp(1).Tipo_Medicamento;
    p_Receta.Rut_Paciente     := p_Trama_Rp(1).Rut_Paciente;
    p_Receta.Dv_Paciente      := p_Trama_Rp(1).Dv_Paciente;
    p_Receta.Nombre_Paciente  := p_Trama_Rp(1).Nombre_Paciente;
    p_Receta.Fecha_Ingreso    := To_Date(p_Trama_Rp(1).Fecha_Ingreso_Paciente
                                        ,'yyyymmdd');
    p_Receta.Fono_Paciente    := p_Trama_Rp(1).Fono_Paciente;
    p_Receta.Convenio         := Nvl(p_Trama_Rp(1).Convenio
                                    ,0);
    p_Receta.Plan             := Nvl(p_Trama_Rp(1).Plan
                                    ,0);
    p_Receta.Rut_Cliente      := l_Rut; --p_trama_rp(1).rut_paciente;
    p_Receta.Dv_Cliente       := l_Dv; --p_trama_rp(1).dv_paciente;
    p_Receta.Rut_Institucion  := p_Trama_Rp(1).Rut_Institucion;
    p_Receta.Dv_Institucion   := p_Trama_Rp(1).Dv_Institucion;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END Prepara_Datos_Receta;

  -- procedure : prepara_datos_producto
  --    in :
  --       p_receta    : Registro de datos del Producto
  --       p_id_receta : Id de la receta (central)
  --       p_itm       : Identificador para el producto
  --       p_trama_rp  : Arreglo contenedor de la receta
  --    Desc :
  --       Prepara el registro para insertar datos del producto
  PROCEDURE Prepara_Datos_Producto(p_Producto  IN OUT Reg_Producto
                                  ,p_Id_Receta IN NUMBER
                                  ,p_Itm       IN NUMBER
                                  ,p_Trama_Rp  IN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp) IS
  BEGIN
    p_Producto.Rec_Id_Receta      := p_Id_Receta;
    p_Producto.Producto           := p_Trama_Rp(1).Subtrama_Rp1(p_Itm).Producto;
    p_Producto.Cantidad           := p_Trama_Rp(1).Subtrama_Rp1(p_Itm).Cantidad;
    p_Producto.Dosis              := p_Trama_Rp(1).Subtrama_Rp1(p_Itm).Dosis;
    p_Producto.Veces              := p_Trama_Rp(1).Subtrama_Rp1(p_Itm).Veces;
    p_Producto.Dias               := p_Trama_Rp(1).Subtrama_Rp1(p_Itm).Dias;
    p_Producto.Inscribir_Refill   := p_Trama_Rp(1).Subtrama_Rp1(p_Itm).Inscribir_En_Refill;
    p_Producto.Texto              := p_Trama_Rp(1).Subtrama_Rp1(p_Itm).Texto;
    p_Producto.Forma_Farmaceutica := p_Trama_Rp(1).Subtrama_Rp1(p_Itm).Forma_Farmaceutica;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END Prepara_Datos_Producto;

  PROCEDURE Inactiva_Producto(p_Receta_Actual IN NUMBER
                             ,p_Rut_Paciente  IN NUMBER
                             ,p_Producto      IN NUMBER) IS
    l_Dbg_Proceso VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.inactiva_producto()';
    l_Dbg_Mensaje VARCHAR2(250) := 'Error General';
  BEGIN
    l_Dbg_Mensaje := 'Actualizar estado de Productos a INACTIVO';
    UPDATE Scfr_Rec_Productos
       SET Estado_Producto = 'INA'
    --procesado       = nvl2(procesado,2,procesado)
     WHERE Rec_Id_Receta <> p_Receta_Actual
       AND Rec_Id_Receta IN (SELECT Id_Receta FROM Scfr_Rec_Recetas WHERE Rut_Paciente = p_Rut_Paciente)
       AND Producto = p_Producto;
    IF SQL%NOTFOUND THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'No se pudo ' || l_Dbg_Mensaje);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
  END Inactiva_Producto;

  -- procedure : registra_receta
  --    in :
  --       p_transaccion : Registro de toda la transaccion
  --    out :
  --       x_cod_error   : Codigo de retorno (0 sin error)
  --       x_msg_error   : Mensaje de error si corresponde
  --    Desc :
  --       Registra una nueva receta
  PROCEDURE Registra_Receta(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Rp         Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp;
    l_Id_Receta        NUMBER;
    l_Receta           Reg_Receta;
    l_Producto         Reg_Producto;
    l_Error            NUMBER;
    l_Msg              VARCHAR2(1000);
    l_Cantidad         NUMBER;
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.registra_receta';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Error_Controlado EXCEPTION;
    --
    l_Compra_Max_Tto Scfr_Planes.Compra_Max_Tto%TYPE;
  BEGIN
    -- Obtiene informacion de la trama RP
    l_Dbg_Mensaje := 'Obtener informacion de la trama RP';
    IF p_Transaccion.Trama_Pos.Origen_Transaccion IN ('DTE'
                                                     ,'BNM'
                                                     ,'PRM'
                                                     ,'FEC'
                                                     ,'FJC'
                                                     ,'PRE'
                                                     ,'MAG'
                                                     ,'FFR') THEN
      -- cambia CCR por REC
      l_Trama_Rp := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Rp9(p_Transaccion.Cuerpo_Tx);
    ELSE
      l_Trama_Rp := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Rp(p_Transaccion.Cuerpo_Tx);
    END IF;
    l_Dbg_Mensaje := 'Preparar informacion para grabar Receta';
    --prepara_datos_receta( l_receta , p_transaccion.trama_boc.forma_identificacion , p_transaccion.trama_boc.string_identificacion , l_trama_rp );
    Prepara_Datos_Receta(l_Receta
                        ,p_Transaccion
                        ,l_Trama_Rp);
    l_Dbg_Mensaje := 'Llamar a inserta_receta()';
    l_Id_Receta   := Inserta_Receta(l_Receta
                                   ,l_Error
                                   ,l_Msg);
    IF l_Error <> 0 THEN
      Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
    ELSE
      -- recorre lista de productos
      l_Dbg_Mensaje := 'Recorrer Productos Receta (RP1)';
      FOR l_Itm IN 1 .. l_Trama_Rp(1).Subtrama_Rp1.Count
      LOOP
        l_Dbg_Mensaje := 'Preparar informacion para grabar Producto';
        Prepara_Datos_Producto(l_Producto
                              ,l_Id_Receta
                              ,l_Itm
                              ,l_Trama_Rp);
        l_Dbg_Mensaje := 'Llamar a inserta_producto()';
        Inserta_Producto(l_Producto
                        ,l_Error
                        ,l_Msg);
        IF l_Error <> 0 THEN
          Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                                    ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
        END IF;
        -- Inhabilita el producto en otras recetas previas Activas
        Inactiva_Producto(l_Id_Receta
                         ,l_Receta.Rut_Paciente
                         ,l_Producto.Producto);
      END LOOP;
      Establece_Fecha_Termino(l_Id_Receta);
    END IF;
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := 0;
      x_Msg_Error := NULL;
  END Registra_Receta;

  -- procedure : trama_rp_resuelve
  --    in :
  --       p_transaccion : Registro de toda la transaccion
  --    out :
  --       x_cod_error   : Codigo de retorno (0 sin error)
  --       x_msg_error   : Mensaje de error si corresponde
  --    Desc :
  --       Resuelve la trama RP (recetas) proveniente en una venta
  --       guardando en el modelo de recetas y en la cartola de ccr
  PROCEDURE Trama_Rp_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2) IS
    l_Trama_Rp           Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Rp;
    l_Itm                NUMBER;
    l_Corr_Tx            NUMBER;
    l_Pt_Party_Medico    NUMBER;
    l_Receta             NUMBER;
    l_Receta_Pos         NUMBER;
    l_Prt_Codigo_Detalle NUMBER;
    l_Dbg_Proceso        VARCHAR2(100) := 'SCFR_TRX_GNC_UTL_PK.trama_rp_resuelve';
    l_Dbg_Mensaje        VARCHAR2(250) := 'Error General';
    l_Error_Controlado   EXCEPTION;
    l_Cod_Error          NUMBER;
    l_Msg_Error          VARCHAR2(1000);
  BEGIN
    x_Cod_Error := 0;
    -- Obtiene informacion de la trama RP
    l_Dbg_Mensaje := 'Obtener informacion de la trama RP';
    IF p_Transaccion.Trama_Pos.Origen_Transaccion IN ('DTE'
                                                     ,'BNM'
                                                     ,'PRM'
                                                     ,'FEC'
                                                     ,'FJC'
                                                     ,'PRE'
                                                     ,'MAG'
                                                     ,'FFR') THEN
      -- cambia CCR por REC
      l_Trama_Rp := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Rp9(p_Transaccion.Cuerpo_Tx);
    ELSE
      l_Trama_Rp := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Rp(p_Transaccion.Cuerpo_Tx);
    END IF;
    -- Obtiene el Correlativo_TX
    l_Dbg_Mensaje := 'Obtener Correlativo TX asociado';
    BEGIN
      SELECT Correlativo_Tx INTO l_Corr_Tx FROM Scfr_Mov_Transacciones WHERE Codigo_Tx = p_Transaccion.Codigo_Tx;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Corr_Tx := NULL;
      WHEN OTHERS THEN
        l_Corr_Tx := NULL;
    END;
    -- Obtiene el Party_Id del Medico
    l_Dbg_Mensaje := 'Obtener Party_Id del Medico';
    BEGIN
      SELECT Party_Id INTO l_Pt_Party_Medico FROM Hz_Parties WHERE Jgzz_Fiscal_Code = Ltrim(To_Char(l_Trama_Rp(1).Rut_Medico));
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Pt_Party_Medico := NULL;
      WHEN OTHERS THEN
        l_Pt_Party_Medico := NULL;
    END;
    -- Obtiene la secuencia para la receta
    l_Dbg_Mensaje := 'Obtener secuencia de la Receta';
    BEGIN
      SELECT Scfr_Recetas_s.Nextval INTO l_Receta FROM Dual;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Receta := NULL;
      WHEN OTHERS THEN
        l_Receta := NULL;
    END;
    IF p_Transaccion.Trama_Pos.Origen_Transaccion IN ('DTE'
                                                     ,'BNM'
                                                     ,'PRM'
                                                     ,'FEC'
                                                     ,'FJC'
                                                     ,'PRE'
                                                     ,'MAG'
                                                     ,'FFR') THEN
      -- cambia CCR por REC
      l_Receta_Pos := l_Trama_Rp(1).Secuencia_Receta;
    ELSE
      l_Receta_Pos := l_Trama_Rp(1).Secuencia_b;
    END IF;
    -- inserta receta
    l_Dbg_Mensaje := 'Insertar en tabla SCFR_RECETAS';
    INSERT INTO Scfr_Recetas
      (Receta
      ,Id_Receta_Pos
      ,Pt_Party_Id
      ,Pt_Party_Comprador
      ,Pt_Party_Medico
      ,Fecha_Emision
      ,Tipo_Receta
      ,Folio
      ,Serie
      ,Con_Copia
      ,Diagnostico
      ,Firma
      ,Canal
      ,Tipo_Medicamento
      ,En_Refill
      ,Rut_Paciente
      ,Dv_Paciente
      ,Nombre_Paciente
      ,Fecha_Ingreso_Paciente
      ,Fono_Paciente
      ,Convenio
      ,Plan)
    VALUES
      (l_Receta -- receta
      ,l_Receta_Pos -- id_receta_pos
      ,p_Transaccion.Trama_Boc.Party_Id -- pt_party_id
      ,p_Transaccion.Trama_Boc.Party_Id -- pt_party_comprador
      ,l_Pt_Party_Medico -- pt_party_medico
      ,Nvl(To_Date(l_Trama_Rp(1).Emision
                  ,'yyyymmdd')
          ,To_Date(19000101
                  ,'yyyymmdd')) -- fecha_emision
      ,l_Trama_Rp(1).Tipo_Receta -- tipo_receta
      ,l_Trama_Rp(1).Folio_Receta -- folio
      ,l_Trama_Rp(1).Serie -- serie
      ,Nvl(l_Trama_Rp(1).Con_Copia
          ,'N') -- con_copia
      ,Nvl(l_Trama_Rp(1).Diagnostico
          ,'N/A') -- diagnostico
      ,l_Trama_Rp(1).Firma -- firma
      ,'POS' -- canal
      ,'NN' -- tipo_medicamento
      ,'NO' -- en_refill
      ,l_Trama_Rp(1).Rut_Paciente --rut_paciente
      ,l_Trama_Rp(1).Dv_Paciente --dv_paciente
      ,l_Trama_Rp(1).Nombre_Paciente --nombre_paciente
      ,To_Date(l_Trama_Rp(1).Fecha_Ingreso_Paciente
              ,'yyyymmdd') --fecha_ingreso_paciente
      ,l_Trama_Rp(1).Fono_Paciente --fono_paciente
      ,l_Trama_Rp(1).Convenio --convenio
      ,l_Trama_Rp(1).Plan --plan
       );
    l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_RECETAS_TRANSACCIONES';
    INSERT INTO Scfr_Mov_Recetas_Transacciones
      (Txo_Codigo_Tx
      ,Rec_Receta
      ,Trx_Correlativo_Tx
      ,Empresa
      ,Cadena
      ,Loc_Local)
    VALUES
      (p_Transaccion.Codigo_Tx
      ,l_Receta
      ,l_Corr_Tx
      ,p_Transaccion.Trama_Pos.Empresa
      ,p_Transaccion.Trama_Pos.Cadena
      ,p_Transaccion.Trama_Pos.Local);
    -- recorre lista de productos
    l_Dbg_Mensaje := 'Recorrer Productos Receta (RP1)';
    FOR l_Itm IN 1 .. l_Trama_Rp(1).Subtrama_Rp1.Count
    LOOP
      -- Obtiene el detalle del producto
      l_Dbg_Mensaje := 'Obtener Correlativo TX asociado';
      BEGIN
        SELECT Codigo_Detalle
          INTO l_Prt_Codigo_Detalle
          FROM Scfr_Mov_Productos_Txs
         WHERE Txo_Codigo_Tx = p_Transaccion.Codigo_Tx
           AND Pro_Codigo_Interno = l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Producto;
      EXCEPTION
        WHEN OTHERS THEN
          l_Prt_Codigo_Detalle := NULL;
      END;
      -- inserta productos receta
      l_Dbg_Mensaje := 'Insertar en tabla SCFR_MOV_RECETAS_PRODUCTOS';
      INSERT INTO Scfr_Mov_Recetas_Productos
        (Txo_Codigo_Tx
        ,Rec_Receta
        ,Pro_Codigo_Interno
        ,Trx_Correlativo_Tx
        ,Prt_Codigo_Detalle
        ,Cantidad
        ,Cantidad_Pendiente
        ,Dosis
        ,Veces
        ,Dias
        ,Inscribir_En_Refill
        ,Texto
        ,Forma_Farmaceutica
        ,Empresa
        ,Cadena
        ,Loc_Local)
      VALUES
        (p_Transaccion.Codigo_Tx
        ,l_Receta
        ,l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Producto
        ,l_Corr_Tx
        ,l_Prt_Codigo_Detalle
        ,l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Cantidad
        ,l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Cantidad_Pendiente
        ,l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Dosis
        ,l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Veces
        ,l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Dias
        ,l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Inscribir_En_Refill
        ,l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Texto
        ,l_Trama_Rp(1).Subtrama_Rp1(l_Itm).Forma_Farmaceutica
        ,p_Transaccion.Trama_Pos.Empresa
        ,p_Transaccion.Trama_Pos.Cadena
        ,p_Transaccion.Trama_Pos.Local);
    END LOOP;
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Trama RP resuelta correctamente');
    -- No se genera error desde este punto
    x_Cod_Error := 0;
    x_Msg_Error := NULL;
    IF Scfr_Conv_Pk.Valida_Ccr(Scfr_Conv_Pk.Entrega_Codigo_Empresa(p_Transaccion.Trama_Pos.Empresa)
                              ,l_Trama_Rp(1).Convenio
                              ,l_Trama_Rp(1).Plan) THEN
      -- genera un movimiento en la cuenta cte. de recetas si corresponde
      IF l_Trama_Rp(1).Tipo_Receta <> 'RMA' THEN
        l_Dbg_Mensaje := 'Registrar Receta';
        Registra_Receta(p_Transaccion => p_Transaccion
                       ,x_Cod_Error   => l_Cod_Error
                       ,x_Msg_Error   => l_Msg_Error);
        l_Dbg_Mensaje := 'Registrar movimiento en cta. cte. recetas';
        Registra_En_Cta_Cte_Recetas(p_Transaccion => p_Transaccion
                                   ,p_Tipo        => k_Registro_Receta
                                   ,x_Cod_Error   => l_Cod_Error
                                   ,x_Msg_Error   => l_Msg_Error);
      END IF;
    END IF;
  EXCEPTION
    WHEN l_Error_Controlado THEN
      NULL;
    WHEN OTHERS THEN
      Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => l_Dbg_Proceso
                                ,p_Msg     => 'Error al intentar ' || l_Dbg_Mensaje);
      x_Cod_Error := 0;
      x_Msg_Error := NULL;
  END;

  PROCEDURE Trama_Pm_Resuelve_Seg(p_Transaccion  IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                 ,p_Doc_Emitidos IN Scfr_Trx_Gnc_Pk.Tab_Doc_Emitidos
                                 ,p_Trama_Dv     IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                                 ,p_Tipo_Tx      IN VARCHAR2
                                 ,p_Tipo_Mvto    IN Scfr_Recauda_Movimientos.Codigo_Movimiento%TYPE
                                 ,x_Cod_Error    OUT NUMBER
                                 ,x_Msg_Error    OUT VARCHAR2) IS
    l_Productos_Ordenados Scfr_Trx_Gnc_Pk.Tab_Productos;
    l_Trama_Pm            Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm;
    l_Trama_Dr            Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dr;
    l_Codigo_Personal     Scfr_Mov_Productos_Txs.Per_Codigo_Personal%TYPE;
    l_Codigo_Detalle      Scfr_Mov_Productos_Txs.Codigo_Detalle%TYPE;
    l_Codigo_Interno      Scfr_Mov_Productos_Txs.Pro_Codigo_Interno%TYPE;
    l_Categoria           Scfr_Mov_Productos_Txs.Cat_Categoria%TYPE;
    l_Id_Relacion         NUMBER;
    l_Itm                 NUMBER;
    l_Pos                 NUMBER;
    l_Puntos_Canjeados    Scfr_Trx_Gnc_Pk.Tab_Puntos_Canjeados;
    l_Dbg_Proceso         VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_pm_resuelve_seg';
    l_Dbg_Mensaje         VARCHAR2(250) := 'Error General';
    l_Error_Controlado    EXCEPTION;
    l_Cantidad            Scfr_Mov_Productos_Txs.Cantidad%TYPE;
    l_Precio_Final        Scfr_Mov_Productos_Txs.Precio_Final%TYPE;
    l_Party_Id_Rel        NUMBER;
    l_Datos_Inventario    Scfr_Trx_Exc_Pk.t_Datos_Inventario;
    l_Auxiliar            BLOB;
    l_Signo               NUMBER;
  BEGIN
    x_Cod_Error := 0;
    -- Obtiene informacion de la trama DR
    l_Dbg_Mensaje := 'Obtener informacion de la trama DR';
    l_Trama_Dr    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Dr(p_Transaccion.Cuerpo_Tx);
    -- Obtiene informacion de la trama PM
    l_Dbg_Mensaje := 'Obtener informacion de la trama PM';
    l_Trama_Pm    := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Pm(p_Transaccion.Trama_Pos
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
    l_Productos_Ordenados := Ordena_Productos(l_Trama_Pm);
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
        ,autorizacion_cnv_pro     
        ,Producto_Demandado)
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
        ,SUBSTR(trim(l_Trama_Pm(l_Itm).Codigo_Autorizacion), 1, 10)
        ,l_Trama_Pm(l_Itm).Producto_Original_Demandado);
                                                               
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
                                  
      --INI APARTADO DE RECARGAS / SERVICIOS - OBE - JAGC 20261022
      -- Recorre Recargas y Telepeajes
      --Scfr_Trx_Gnc_Pk.Trama_Pm_Recargas_Telepeajes(p_Transaccion
      --                            ,l_Trama_Pm(l_Itm) -- envio solo los datos de un producto y no todo el detalle
      --                            ,p_Trama_Dv --l_trama_dv
      --                            ,l_Codigo_Detalle
      --                            ,p_Tipo_Tx
      --                            ,x_Cod_Error
      --                            ,x_Msg_Error);   
      --FIN APARTADO DE RECARGAS / SERVICIOS - OBE - JAGC 20261022  
        
      -- inserta en tabla SCFR_RECAUDA_MOVIMIENTOS
      l_Dbg_Mensaje := 'Insertar en tabla SCFR_RECAUDA_MOVIMIENTOS';
      BEGIN
        INSERT INTO Scfr_Recauda_Movimientos
          (Movimiento_Padre
          ,Fecha_Movimiento
          ,Local_Movimiento
          ,Codigo_Movimiento
          ,Rut_Cliente
          ,Empresa
          ,Codigo_Item
          ,Estado)
        VALUES
          (l_Trama_Dr.Tipo_Movimiento_Padre
          ,To_Date(l_Trama_Dr.Fecha
                  ,'yyyymmddhh24miss')
          ,p_Transaccion.Trama_Pos.Local
          ,p_Tipo_Mvto
          ,'-'--p_Transaccion.Rut_Titular
          ,l_Trama_Dr.Id_Empresa
          ,l_Trama_Pm(l_Itm).Producto
          ,'VIG');
      EXCEPTION
        WHEN Dup_Val_On_Index THEN
          UPDATE Scfr_Recauda_Movimientos
             SET Fecha_Movimiento = To_Date(l_Trama_Dr.Fecha
                                           ,'yyyymmddhh24miss')
                ,Local_Movimiento = p_Transaccion.Trama_Pos.Local
                ,Estado           = 'VIG'
           WHERE Movimiento_Padre = l_Trama_Dr.Tipo_Movimiento_Padre
             AND Codigo_Movimiento = p_Tipo_Mvto
             AND Rut_Cliente = p_Transaccion.Rut_Titular
             AND Empresa = l_Trama_Dr.Id_Empresa
             AND Codigo_Item = l_Trama_Pm(l_Itm).Producto;
      END;
    END LOOP;
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'party id cliente=>' || Nvl(p_Transaccion.Trama_Boc.Party_Id
                                                                       ,0));
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

  PROCEDURE Trama_Pm_Doctos_Referencia(p_Transaccion    IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                      ,p_Trama_Pm       IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Pm
                                      ,p_Trama_Dv       IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                                      ,p_Doc_Emitidos   IN Scfr_Trx_Gnc_Pk.Tab_Doc_Emitidos
                                      ,p_Codigo_Detalle IN NUMBER
                                      ,p_Tipo_Tx        IN VARCHAR2
                                      ,x_Cod_Error      OUT NUMBER
                                      ,x_Msg_Error      OUT VARCHAR2) IS
    l_Pto_Descuentos   Tab_Descuentos;
    l_Mov_Prod_Doctos  NUMBER;
    l_Mov_Prod_Doc_Aux NUMBER;
    l_Itm              NUMBER;
    l_Itm2             NUMBER;
    l_Itm3             NUMBER;
    l_Pos              NUMBER;
    l_Mov_Hijo         VARCHAR2(100);
    l_Tipo_Tx          VARCHAR2(3);
    l_Valor            NUMBER;
    l_Signo_Acumula    NUMBER;
    l_Folio_Doc        Scfr_Mov_Documentos_Txs.Folio%TYPE; --NUMBER; ctm 29-01-2021
    l_Acumulo_Psalud   BOOLEAN;
    l_Actualiza_Puf    BOOLEAN;
    l_Punto_Registrado BOOLEAN := FALSE;
    l_Tipo_Acum_Psalud VARCHAR2(3);
    l_Dbg_Proceso      VARCHAR2(100) := 'SCFR_TRX_GNC_PK.trama_pm_doctos_referencia';
    l_Dbg_Mensaje      VARCHAR2(250) := 'Error General';
    l_Movdoc           NUMBER := 1;
    l_Error_Controlado EXCEPTION;
  BEGIN
    x_Cod_Error     := 0;
    l_Actualiza_Puf := FALSE;
    l_Dbg_Mensaje   := 'Recorrer detalle de la subtrama PM1 (Documentos de Referencia)';
    FOR l_Itm IN 1 .. p_Trama_Pm.Subtrama_Pm1.Count
    LOOP
      -- Busca documento relacionado al producto (SIEMPRE DEBE ENCONTRAR AL MENOS UNO)
      l_Dbg_Mensaje := 'Buscar documento relacionado al producto ';
      Dbms_Output.Put_Line('producto=>' || p_Trama_Pm.Producto || ' secuencia=>' || p_Trama_Pm.Subtrama_Pm1(l_Itm).Secuencia_b);
      -- *
      -- INSERT INTO TMP_DEBUG VALUES(SYSDATE,'producto=>'||p_trama_pm.producto||' secuencia=>'||p_trama_pm.subtrama_pm1(l_itm).secuencia_b);
      -- *
      FOR l_Itm2 IN 1 .. p_Trama_Dv.Subtrama_Dv1.Count
      LOOP
        IF p_Trama_Pm.Subtrama_Pm1(l_Itm).Secuencia_b = p_Trama_Dv.Subtrama_Dv1(l_Itm2).Secuencia_b THEN
          l_Pos       := l_Itm2;
          l_Mov_Hijo  := p_Trama_Dv.Subtrama_Dv1(l_Itm2).Tipo_Movimiento_Hijo;
          l_Folio_Doc := p_Trama_Dv.Subtrama_Dv1(l_Itm2).Folio;
          EXIT;
        END IF;
      END LOOP;
      Dbms_Output.Put_Line('producto=>' || p_Trama_Pm.Producto || ' mov_hijo=>' || l_Mov_Hijo || ' folio=>' || p_Doc_Emitidos(l_Pos));
      IF l_Pos > p_Trama_Dv.Subtrama_Dv1.Count THEN
        -- Esto NUNCA puede ocurrir. se genera un error
        Raise_Application_Error(-20000
                               ,'No se encontro documento relacionado a producto ' || p_Trama_Pm.Producto);
      END IF;
      -- Obtiene ID de la tabla
      l_Dbg_Mensaje := 'Obtener folio desde scfr_mov_productos_doctos_s';
      SELECT Scfr_Mov_Productos_Doctos_s.Nextval INTO l_Mov_Prod_Doctos FROM Dual;
      IF p_Tipo_Tx = 'GNCU02' THEN
        l_Movdoc := -1;
      END IF;
      l_Dbg_Mensaje := 'Insertar en tabla scfr_mov_productos_documentos';
      INSERT INTO Scfr_Mov_Productos_Documentos
        (Mov_Productos_Documentos
        ,Txo_Codigo_Tx
        ,Dte_Mov_Documentos
        ,Tdo_Codigo_Detalle
        ,Pro_Codigo_Interno
        ,Precio_Final
        ,Impreso_En_Boleta
        ,Empresa
        ,Cadena
        ,Loc_Local)
      VALUES
        (l_Mov_Prod_Doctos
        ,p_Transaccion.Codigo_Tx
        ,p_Doc_Emitidos(l_Pos)
        ,p_Codigo_Detalle
        ,Scfr_Trx_Util_Pk.Parche_Producto(p_Transaccion.Trama_Pos.Empresa
                                         ,p_Trama_Pm.Producto)
        ,p_Trama_Pm.Subtrama_Pm1(l_Itm).Total_Item_Por_Documento * l_Movdoc
        ,'NO'
        ,p_Transaccion.Trama_Pos.Empresa
        ,p_Transaccion.Trama_Pos.Cadena
        ,p_Transaccion.Trama_Pos.Local);
      l_Dbg_Mensaje := 'Chequear si se deben regisrar puntos para programa salud';
      IF NOT l_Punto_Registrado AND
         Ltrim(Rtrim(l_Mov_Hijo)) != 'VENDIC' THEN
        l_Acumulo_Psalud := FALSE;
        IF Nvl(p_Trama_Pm.Uso_Frecuente
              ,0) > 0 AND
           p_Transaccion.Trama_Boc.Party_Id > 0 THEN
          l_Signo_Acumula := 1;
          IF p_Trama_Pm.Aplicacion_Item = 'I' AND
             Substr(Ltrim(Rtrim(l_Mov_Hijo))
                   ,1
                   ,3) = 'VEN' THEN
            l_Signo_Acumula := -1;
          END IF;
          l_Dbg_Mensaje := 'Recorrer detalle de la trama PM2 (descuentos aplicados) para registrar Ptos. Prog. Salud';
          -- *
          -- INSERT INTO TMP_DEBUG VALUES(SYSDATE,l_DBG_MENSAJE);
          -- *
          IF p_Trama_Pm.Subtrama_Pm2.Count > 0 THEN
            -- genera arreglo con puntero a trama_pm2 dejanto solo un descuento por campa?a
            l_Pto_Descuentos := Quita_Desc_Repetidos(p_Trama_Pm.Subtrama_Pm2);
            FOR l_Pos IN 1 .. l_Pto_Descuentos.Count
            LOOP
              l_Itm3 := l_Pto_Descuentos(l_Pos);
              IF Scfr_Pprog_Salud_Pk.Es_Cam_Progsalud(p_Trama_Pm.Subtrama_Pm2(l_Itm3).Campana_o_Convenio
                                                     ,p_Transaccion.Trama_Pos.Empresa) THEN
                -- Registra puntos de programa salud, SOLO para el primer documento referenciado por cada producto
                -- y por cada descuento encontrado (por default, solo viene un descuento)
                IF Substr(Ltrim(Rtrim(l_Mov_Hijo))
                         ,1
                         ,3) = 'VEN' THEN
                  l_Tipo_Tx          := 'VEN';
                  l_Mov_Prod_Doc_Aux := l_Mov_Prod_Doctos;
                ELSIF Substr(Ltrim(Rtrim(l_Mov_Hijo))
                            ,1
                            ,3) = 'ANU' THEN
                  l_Tipo_Tx     := 'REV';
                  l_Dbg_Mensaje := 'Obtiene folio asociado al programa de salud';
                  l_Folio_Doc   := Scfr_Trx_Gnc_Utl2_Pk.Obtiene_Folio_Psalud(p_Trama_Dv
                                                                            ,p_Transaccion.Trama_Pos.Local
                                                                            ,p_Trama_Pm.Uso_Frecuente);
                  l_Dbg_Mensaje := 'Obtener Correlativo anterior';
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
                    -- *
                    -- INSERT INTO TMP_DEBUG VALUES(SYSDATE,'Entrada SCFR_MOV_PRODUCTOS_DOCUMENTOS');
                    -- *
                  EXCEPTION
                    WHEN No_Data_Found THEN
                      /*    BEGIN
                                 -- se asume que transaccion es de hace varios dias por lo tanto se debe buscar en el
                                 -- modelo BATC.
                                 SELECT pd.mov_productos_documentos
                                   INTO l_mov_prod_doc_aux
                                   FROM BATC_MOV_PRODUCTOS_DOCUMENTOS pd,
                                        BATC_MOV_TRANSACCIONES        mt
                                  WHERE pd.txo_codigo_tx        = mt.codigo_tx
                                    AND mt.correlativo_tx       = p_trama_dv.correlativo_tx_asociado
                                    AND mt.loc_local            = p_trama_dv.LOCAL
                                    AND mt.tmo_movimiento_padre = p_trama_dv.tipo_movimiento_padre
                                    AND pd.pro_codigo_interno   = p_trama_pm.producto
                                    AND pd.impreso_en_boleta    = 'SI';
                      l_mov_prod_doc_aux := 0;
                               EXCEPTION
                                 WHEN OTHERS THEN
                                   l_mov_prod_doc_aux := -1; -- le indica a programa de salud que id de mov_productos_documentos no fue encontrado.
                               END;*/
                      l_Mov_Prod_Doc_Aux := 0;
                      -- *
                    -- INSERT INTO TMP_DEBUG VALUES(SYSDATE,'l_mov_prod_doc_aux := 0');
                    -- *
                    WHEN OTHERS THEN
                      l_Mov_Prod_Doc_Aux := -1; -- le indica a programa de salud que id de mov_productos_documentos no fue encontrado.
                  END;
                END IF;
                IF l_Signo_Acumula = -1 THEN
                  l_Tipo_Tx     := 'REV';
                  l_Dbg_Mensaje := 'Obtiene folio asociado al programa de salud';
                  l_Folio_Doc   := Scfr_Trx_Gnc_Utl2_Pk.Obtiene_Folio_Psalud(p_Trama_Dv
                                                                            ,p_Transaccion.Trama_Pos.Local
                                                                            ,p_Trama_Pm.Uso_Frecuente);
                END IF;
                IF p_Trama_Dv.Movimiento_Enlinea = 'SI' THEN
                  l_Tipo_Acum_Psalud := 'AOL';
                ELSE
                  l_Tipo_Acum_Psalud := 'OLB';
                END IF;
                -- *
                /* INSERT INTO TMP_DEBUG VALUES(SYSDATE,' Entrada 1 ' || to_char(l_mov_prod_doc_aux) || ' ,' ||
                     to_char(p_transaccion.trama_boc.party_id) || ' ,' ||
                     to_char(p_trama_pm.uso_frecuente) || ' ,' ||
                     to_char(p_trama_pm.cantidad) || ' ,' ||
                     to_char(p_trama_pm.cantidad_acumulada_psalud * l_signo_acumula) || ' ,' ||
                     to_char(p_transaccion.rut_titular) || ' ,' ||
                      p_transaccion.dv_rut_titular || ' ,' ||
                      l_tipo_tx || ' ,' ||
                      p_trama_dv.fecha || ' ,' ||
                      'POS' || ' ,' ||
                      p_trama_pm.subtrama_pm2(l_itm3).detalle_descuento_producto || ' ,' ||
                     to_char(l_folio_doc) || ' ,' ||
                to_char(p_transaccion.trama_pos.LOCAL) || ' ,' ||
                to_char(p_trama_pm.producto) || ' ,' ||
                'AOL' || ' ,' ||
                p_transaccion.fecha_tx_origen || ' ,' ||
                p_transaccion.local_origen);*/
                -- *
                --
                -- Transaccion de origen local GeoPos
                --IF p_transaccion.trama_pos.plataforma = 'U' THEN
                l_Dbg_Mensaje := 'Ejecutar scfr_pprog_salud_pk.puntos_ps_GeoCom';
                Scfr_Pprog_Salud_Pk.Puntos_Ps_Geocom(Pmov_Movimientos   => l_Mov_Prod_Doc_Aux
                                                    ,Pparty_Id          => p_Transaccion.Trama_Boc.Party_Id
                                                    ,Puso_Frecuente     => p_Trama_Pm.Uso_Frecuente
                                                    ,Pcantidad          => p_Trama_Pm.Cantidad
                                                    ,Pcant_Prog_Salud   => p_Trama_Pm.Cantidad_Acumulada_Psalud * l_Signo_Acumula
                                                    ,Prut_Cliente       => p_Transaccion.Rut_Titular
                                                    ,Pdv_Rut_Cliente    => p_Transaccion.Dv_Rut_Titular
                                                    ,Ptipo_Tx           => l_Tipo_Tx
                                                    ,Pfecha_Tx          => To_Date(p_Trama_Dv.Fecha
                                                                                  ,'yyyymmdd')
                                                    ,Pcanal             => 'POS'
                                                    ,Pdetalle_Descuento => p_Trama_Pm.Subtrama_Pm2(l_Itm3).Detalle_Descuento_Producto
                                                    ,Pfolio             => l_Folio_Doc
                                                    ,Plocal             => p_Transaccion.Trama_Pos.Local
                                                    ,Ppro_Codigo_Tx     => p_Trama_Pm.Producto
                                                    ,Ptipo_Acum_Psalud  => 'AOL'
                                                    ,Pfecha_Venta       => p_Transaccion.Fecha_Tx_Origen
                                                    ,Plocal_Venta       => p_Transaccion.Local_Origen
                                                    ,Pcod_Error         => x_Cod_Error
                                                    ,Pmsg_Error         => x_Msg_Error);
                l_Acumulo_Psalud := TRUE;
                /*   ELSE
                  l_dbg_mensaje := 'Ejecutar scfr_pprog_salud_pk.puntos_ps';
                  scfr_pprog_salud_pk.puntos_ps(pmov_movimientos   => l_mov_prod_doc_aux,
                                                pparty_id          => p_transaccion.trama_boc.party_id,
                                                puso_frecuente     => p_trama_pm.uso_frecuente,
                                                pcantidad          => p_trama_pm.cantidad,
                                                pcant_prog_salud   => p_trama_pm.cantidad_acumulada_psalud *
                                                                      l_signo_acumula,
                                                prut_cliente       => p_transaccion.rut_titular,
                                                pdv_rut_cliente    => p_transaccion.dv_rut_titular,
                                                ptipo_tx           => l_tipo_tx,
                                                pfecha_tx          => to_date(p_trama_dv.fecha,
                                                                              'yyyymmdd'),
                                                pcanal             => 'POS',
                                                pdetalle_descuento => p_trama_pm.subtrama_pm2(l_itm3)
                                                                     .detalle_descuento_producto,
                                                pfolio             => l_folio_doc,
                                                plocal             => p_transaccion.trama_pos.LOCAL,
                                                ppro_codigo_tx     => p_trama_pm.producto,
                                                ptipo_acum_psalud  => 'AOL',
                                                pfecha_venta       => p_transaccion.fecha_tx_origen,
                                                plocal_venta       => p_transaccion.local_origen,
                                                pcod_error         => x_cod_error,
                                                pmsg_error         => x_msg_error);
                  l_acumulo_psalud := TRUE;
                END IF; --IF p_Transaccion.Trama_Pos.Plataforma = 'U' THEN */
              END IF;
            END LOOP;
          END IF;
          IF NOT l_Acumulo_Psalud THEN
            -- *
            -- INSERT INTO TMP_DEBUG VALUES(SYSDATE,'No Acumulo Psalud');
            -- *
            -- llama solo por acumulacion (no hubo descuentos)
            l_Dbg_Mensaje := 'Ejecutar scfr_pprog_salud_pk.puntos_ps';
            IF Substr(Ltrim(Rtrim(l_Mov_Hijo))
                     ,1
                     ,3) = 'VEN' THEN
              l_Tipo_Tx          := 'VEN';
              l_Mov_Prod_Doc_Aux := l_Mov_Prod_Doctos;
            ELSIF Substr(Ltrim(Rtrim(l_Mov_Hijo))
                        ,1
                        ,3) = 'ANU' THEN
              l_Tipo_Tx     := 'REV';
              l_Dbg_Mensaje := 'Obtiene folio asociado al programa de salud';
              l_Folio_Doc   := Scfr_Trx_Gnc_Utl2_Pk.Obtiene_Folio_Psalud(p_Trama_Dv
                                                                        ,p_Transaccion.Trama_Pos.Local
                                                                        ,p_Trama_Pm.Uso_Frecuente);
              l_Dbg_Mensaje := 'Obtener Correlativo anterior';
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
                  /* BEGIN
                    SELECT pd.mov_productos_documentos
                      INTO l_mov_prod_doc_aux
                      FROM BATC_MOV_PRODUCTOS_DOCUMENTOS pd,
                           BATC_MOV_TRANSACCIONES        mt
                     WHERE pd.txo_codigo_tx        = mt.codigo_tx
                       AND mt.correlativo_tx       = p_trama_dv.correlativo_tx_asociado
                       AND mt.loc_local            = p_trama_dv.LOCAL
                       AND mt.tmo_movimiento_padre = p_trama_dv.tipo_movimiento_padre
                       AND pd.pro_codigo_interno   = p_trama_pm.producto
                       AND pd.impreso_en_boleta    = 'SI';
                  EXCEPTION
                    WHEN OTHERS THEN
                      l_mov_prod_doc_aux := -1; -- le indica a programa de salud que id de mov_productos_documentos no fue encontrado.
                  END;*/
                  l_Mov_Prod_Doc_Aux := 0;
                WHEN OTHERS THEN
                  l_Mov_Prod_Doc_Aux := -1; -- le indica a programa de salud que id de mov_productos_documentos no fue encontrado.
              END;
            END IF;
            IF l_Signo_Acumula = -1 THEN
              l_Tipo_Tx     := 'REV';
              l_Dbg_Mensaje := 'Obtiene folio asociado al programa de salud';
              l_Folio_Doc   := Scfr_Trx_Gnc_Utl2_Pk.Obtiene_Folio_Psalud(p_Trama_Dv
                                                                        ,p_Transaccion.Trama_Pos.Local
                                                                        ,p_Trama_Pm.Uso_Frecuente);
            END IF;
            IF p_Trama_Dv.Movimiento_Enlinea = 'SI' THEN
              l_Tipo_Acum_Psalud := 'AOL';
            ELSE
              l_Tipo_Acum_Psalud := 'OLB';
            END IF;
            -- *
            /* INSERT INTO TMP_DEBUG VALUES(SYSDATE,' Entrada 1 ' || to_char(l_mov_prod_doc_aux) || ' ,' ||
                 to_char(p_transaccion.trama_boc.party_id) || ' ,' ||
                 to_char(p_trama_pm.uso_frecuente) || ' ,' ||
                 to_char(p_trama_pm.cantidad) || ' ,' ||
                 to_char(p_trama_pm.cantidad_acumulada_psalud * l_signo_acumula) || ' ,' ||
                 to_char(p_transaccion.rut_titular) || ' ,' ||
                  p_transaccion.dv_rut_titular || ' ,' ||
                  l_tipo_tx || ' ,' ||
                  p_trama_dv.fecha || ' ,' ||
                  'POS' || ' ,' ||
                  p_trama_pm.subtrama_pm2(l_itm3).detalle_descuento_producto || ' ,' ||
                 to_char(l_folio_doc) || ' ,' ||
            to_char(p_transaccion.trama_pos.LOCAL) || ' ,' ||
            to_char(p_trama_pm.producto) || ' ,' ||
            'AOL' || ' ,' ||
            p_transaccion.fecha_tx_origen || ' ,' ||
            p_transaccion.local_origen);*/
            -- *
            -- Transaccion de origen local GeoPos
            -- IF p_transaccion.trama_pos.plataforma = 'U' THEN
            l_Dbg_Mensaje := 'Ejecutar scfr_pprog_salud_pk.puntos_ps_GeoCom';
            Scfr_Pprog_Salud_Pk.Puntos_Ps_Geocom(Pmov_Movimientos   => l_Mov_Prod_Doc_Aux
                                                ,Pparty_Id          => p_Transaccion.Trama_Boc.Party_Id
                                                ,Puso_Frecuente     => p_Trama_Pm.Uso_Frecuente
                                                ,Pcantidad          => p_Trama_Pm.Cantidad
                                                ,Pcant_Prog_Salud   => p_Trama_Pm.Cantidad_Acumulada_Psalud * l_Signo_Acumula
                                                ,Prut_Cliente       => p_Transaccion.Rut_Titular
                                                ,Pdv_Rut_Cliente    => p_Transaccion.Dv_Rut_Titular
                                                ,Ptipo_Tx           => l_Tipo_Tx
                                                ,Pfecha_Tx          => To_Date(p_Trama_Dv.Fecha
                                                                              ,'yyyymmdd')
                                                ,Pcanal             => 'POS'
                                                ,Pdetalle_Descuento => '00' -- indica que no hubo descuentos
                                                ,Pfolio             => l_Folio_Doc
                                                ,Plocal             => p_Transaccion.Trama_Pos.Local
                                                ,Ppro_Codigo_Tx     => p_Trama_Pm.Producto
                                                ,Ptipo_Acum_Psalud  => l_Tipo_Acum_Psalud
                                                ,Pfecha_Venta       => p_Transaccion.Fecha_Tx_Origen
                                                ,Plocal_Venta       => p_Transaccion.Local_Origen
                                                ,Pcod_Error         => x_Cod_Error
                                                ,Pmsg_Error         => x_Msg_Error);
            /*   ELSE
              l_dbg_mensaje := 'Ejecutar scfr_pprog_salud_pk.puntos_ps';
              scfr_pprog_salud_pk.puntos_ps(pmov_movimientos   => l_mov_prod_doc_aux,
                                            pparty_id          => p_transaccion.trama_boc.party_id,
                                            puso_frecuente     => p_trama_pm.uso_frecuente,
                                            pcantidad          => p_trama_pm.cantidad,
                                            pcant_prog_salud   => p_trama_pm.cantidad_acumulada_psalud *
                                                                  l_signo_acumula,
                                            prut_cliente       => p_transaccion.rut_titular,
                                            pdv_rut_cliente    => p_transaccion.dv_rut_titular,
                                            ptipo_tx           => l_tipo_tx,
                                            pfecha_tx          => to_date(p_trama_dv.fecha,
                                                                          'yyyymmdd'),
                                            pcanal             => 'POS',
                                            pdetalle_descuento => '00' -- indica que no hubo descuentos
                                           ,
                                            pfolio             => l_folio_doc,
                                            plocal             => p_transaccion.trama_pos.LOCAL,
                                            ppro_codigo_tx     => p_trama_pm.producto,
                                            ptipo_acum_psalud  => l_tipo_acum_psalud,
                                            pfecha_venta       => p_transaccion.fecha_tx_origen,
                                            plocal_venta       => p_transaccion.local_origen,
                                            pcod_error         => x_cod_error,
                                            pmsg_error         => x_msg_error);
            END IF; --if (p_transaccion.trama_pos.origen_transaccion='PRM') then */
          END IF;
        END IF;
        -- Actualiza la relacion producto-documento para dejar identificado el documento en donde
        -- fue impreso el producto (para los casos en que un producto tenga mas de un documento de referencia)
        l_Dbg_Mensaje := 'Actualizar tabla SCFR_MOV_PRODUCTOS_DOCUMENTOS';
        UPDATE Scfr_Mov_Productos_Documentos
           SET Impreso_En_Boleta = 'SI'
              ,Procesado         = Nvl2(Procesado
                                       ,2
                                       ,Procesado)
         WHERE Mov_Productos_Documentos = l_Mov_Prod_Doctos;
        l_Punto_Registrado := TRUE;
      END IF;
      IF NOT l_Actualiza_Puf AND
         p_Transaccion.Trama_Boc.Party_Id > 0 THEN
        -- Chequea si producto fue inscrito en este documento
        -- de ser asi, actualiza el folio fiscal del documento en el uso frecuente
        IF p_Trama_Pm.Uso_Frecuente > 0 AND
           p_Trama_Pm.Inscrito_Programa_Salud = 'SI' THEN
          UPDATE Scfr_Clientes_Uso_Frecuente
             SET Documento_Venta = l_Folio_Doc
           WHERE Pt_Party_Id = p_Transaccion.Trama_Boc.Party_Id
             AND Puf_Uso_Frecuente = p_Trama_Pm.Uso_Frecuente;
        END IF;
        l_Actualiza_Puf := TRUE;
      END IF;
    END LOOP;
    Scfr_Trx_Util_Pk.Debug_Msg(p_Proceso => l_Dbg_Proceso
                              ,p_Msg     => 'Trama PM1 (documentos de referencia) resuelta correctamente');
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

  FUNCTION Obtiene_Estado(p_Cam_Campana IN NUMBER
                         ,p_Fecha_Tx    IN DATE
                         ,p_Rut         IN NUMBER) RETURN BOOLEAN IS
    l_Estado  VARCHAR2(10);
    l_Retorno BOOLEAN;
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    BEGIN
      SELECT Estado_Benef
        INTO l_Estado
        FROM Scfr_Camp_Ctrl_Beneficios
       WHERE Cam_Campana = p_Cam_Campana
         AND Trunc(Fecha_Entrega) = Trunc(p_Fecha_Tx)
         AND Rownum = 1;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Estado := 'DISP';
    END;
    IF l_Estado = 'DISP' THEN
      l_Retorno := TRUE;
      UPDATE Scfr_Camp_Ctrl_Beneficios
         SET Estado_Benef    = 'PEND'
            ,Rut_Benef       = Nvl(p_Rut
                                  ,0)
            ,Fecha_Ult_Benef = SYSDATE
       WHERE Cam_Campana = p_Cam_Campana
         AND Trunc(Fecha_Entrega) = Trunc(p_Fecha_Tx);
    ELSE
      l_Retorno := FALSE;
    END IF;
    COMMIT;
    RETURN l_Retorno;
  END;

  FUNCTION Retorna_Benef_Cam(p_Cam_Campana IN NUMBER
                            ,p_Fecha_Tx    IN DATE
                            ,p_Rut         IN NUMBER
                            ,p_Local       IN NUMBER
                            ,p_Datos       OUT VARCHAR2) RETURN BOOLEAN IS
    l_Max_Benef       NUMBER;
    l_Cant_Benef      NUMBER := 0;
    Agrega_Camp       BOOLEAN;
    l_Param_Tmpo      NUMBER;
    l_Ult_Benef       DATE;
    l_Estado          VARCHAR2(10);
    l_t_Espera        NUMBER;
    l_Tiempo          NUMBER;
    l_Sql             VARCHAR2(3000);
    l_Loc_Premio_Cam  NUMBER;
    l_Loc_Premio_Cam2 NUMBER;
    l_Loc_Premio_Cam3 NUMBER;
    l_Loc_Premio_Cam4 NUMBER;
    l_Loc_Premio_Cam5 NUMBER;
    l_Loc_Premio_Cam6 NUMBER;
    l_Loc_Premio_Cam7 NUMBER;
    l_Tipo_Entrega    VARCHAR2(4);
    l_Ind_Divisor     VARCHAR2(3);
    l_Vta_Tot         NUMBER;
    l_Ent_Local       NUMBER := 0;
    CURSOR c_Agenda(p_Campana IN NUMBER) IS
      SELECT Ent_Fecha
            ,Ent_Local
        FROM Scfr_Camp_Agenda_Entrega
       WHERE Cam_Campana = p_Campana
         AND Ent_Estado = 'SI';
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    -- obtiene la cantidad de beneficios diarios a otorgar por campa?a mas los locales
    BEGIN
      SELECT Total_Benef_Dia
            ,Total_Venta_Dia
            ,Local_Benef_Inm
            ,Local_Benef_Inm2
            ,Local_Benef_Inm3
            ,Local_Benef_Inm4
            ,Local_Benef_Inm5
            ,Local_Benef_Inm6
            ,Local_Benef_Inm7
        INTO l_Max_Benef
            ,l_Vta_Tot
            ,l_Loc_Premio_Cam
            ,l_Loc_Premio_Cam2
            ,l_Loc_Premio_Cam3
            ,l_Loc_Premio_Cam4
            ,l_Loc_Premio_Cam5
            ,l_Loc_Premio_Cam6
            ,l_Loc_Premio_Cam7
        FROM Scfr_Camp_Param_Benef
       WHERE Cam_Campana = p_Cam_Campana;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Max_Benef       := 0;
        l_Loc_Premio_Cam  := 0;
        l_Loc_Premio_Cam2 := 0;
        l_Loc_Premio_Cam3 := 0;
        l_Loc_Premio_Cam4 := 0;
        l_Loc_Premio_Cam5 := 0;
        l_Loc_Premio_Cam6 := 0;
        l_Loc_Premio_Cam7 := 0;
    END;
    -- obtiene el tiempo maximo de espera para otorgar beneficio
    BEGIN
      SELECT Rv_High_Value
            ,Rv_Abbreviation
        INTO l_Param_Tmpo
            ,l_Ind_Divisor
        FROM Cg_Ref_Codes
       WHERE Rv_Domain = 'PARAMETROS'
         AND Rv_Low_Value = 'TIEMPO_MAX_BENEF';
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Param_Tmpo := 0;
    END;
    BEGIN
      SELECT Total_Entregado
            ,Estado_Benef
            ,Fecha_Ult_Benef
        INTO l_Cant_Benef
            ,l_Estado
            ,l_Ult_Benef
        FROM Scfr_Camp_Ctrl_Beneficios
       WHERE Cam_Campana = p_Cam_Campana
         AND Trunc(Fecha_Entrega) = Trunc(p_Fecha_Tx)
         AND Rownum = 1;
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Cant_Benef := 0;
        l_Estado     := 'DISP';
    END;
    IF l_Cant_Benef < l_Max_Benef THEN
      /* Revisa por agendamiento */
      FOR r_Agenda IN c_Agenda(p_Cam_Campana)
      LOOP
        --   Scfr_Trx_Util_Pk.error_msg( p_proceso=>'Retorna Benef Campa?a', p_msg=>'fechacursor'||to_date(r_agenda.ent_fecha,'yyyymmddhh24mi') ||'fechatx'||to_date( p_fecha_tx, 'yyyymmddhh24mi'));
        --  dbms_output.put_line ('fechacursor'||to_char(r_agenda.ent_fecha,'yyyymmddhh24mi') ||'fechatx'||to_char( p_fecha_tx, 'yyyymmddhh24mi'));
        IF (To_Char(r_Agenda.Ent_Fecha
                   ,'yyyymmddhh24mi') <= To_Char(p_Fecha_Tx
                                                 ,'yyyymmddhh24mi') AND r_Agenda.Ent_Local = p_Local) THEN
          l_Tipo_Entrega := 'AGE';
          Agrega_Camp    := TRUE;
          UPDATE Scfr_Camp_Agenda_Entrega
             SET Ent_Estado = 'NO'
           WHERE Cam_Campana = p_Cam_Campana
             AND Ent_Local = p_Local
             AND Ent_Fecha <= p_Fecha_Tx
             AND Ent_Estado = 'SI';
          Dbms_Output.Put_Line('fechacursor' || To_Char(r_Agenda.Ent_Fecha
                                                       ,'yyyymmddhh24mi') || 'fechatx' ||
                               To_Char(SYSDATE
                                      ,'yyyymmddhh24mi'));
          l_Ent_Local := 1;
        END IF;
      END LOOP;
      IF l_Ent_Local = 0 THEN
        /*agrega validacion del local premio inmediato*/
        IF (p_Local = l_Loc_Premio_Cam OR p_Local = l_Loc_Premio_Cam2 OR p_Local = l_Loc_Premio_Cam3 OR p_Local = l_Loc_Premio_Cam4 OR
           p_Local = l_Loc_Premio_Cam5 OR p_Local = l_Loc_Premio_Cam6 OR p_Local = l_Loc_Premio_Cam7) THEN
          l_Tipo_Entrega := 'LOC';
          Agrega_Camp    := TRUE;
          /*  update scfr_camp_ctrl_beneficios
                  set estado_benef         = 'PEND',
                      rut_benef            = nvl(p_rut,0),
          fecha_ult_benef        = sysdate
                where cam_campana          = p_cam_campana
                  and trunc(fecha_entrega) = trunc(p_fecha_tx);*/
          CASE p_Local
            WHEN l_Loc_Premio_Cam THEN
              UPDATE Scfr_Camp_Param_Benef SET Local_Benef_Inm = 0 WHERE Cam_Campana = p_Cam_Campana;
            WHEN l_Loc_Premio_Cam2 THEN
              UPDATE Scfr_Camp_Param_Benef SET Local_Benef_Inm2 = 0 WHERE Cam_Campana = p_Cam_Campana;
            WHEN l_Loc_Premio_Cam3 THEN
              UPDATE Scfr_Camp_Param_Benef SET Local_Benef_Inm3 = 0 WHERE Cam_Campana = p_Cam_Campana;
            WHEN l_Loc_Premio_Cam4 THEN
              UPDATE Scfr_Camp_Param_Benef SET Local_Benef_Inm4 = 0 WHERE Cam_Campana = p_Cam_Campana;
            WHEN l_Loc_Premio_Cam5 THEN
              UPDATE Scfr_Camp_Param_Benef SET Local_Benef_Inm5 = 0 WHERE Cam_Campana = p_Cam_Campana;
            WHEN l_Loc_Premio_Cam6 THEN
              UPDATE Scfr_Camp_Param_Benef SET Local_Benef_Inm6 = 0 WHERE Cam_Campana = p_Cam_Campana;
            WHEN l_Loc_Premio_Cam7 THEN
              UPDATE Scfr_Camp_Param_Benef SET Local_Benef_Inm7 = 0 WHERE Cam_Campana = p_Cam_Campana;
          END CASE;
          /* update scfr_camp_param_benef
            set LOCAL_BENEF_INM    = 0
          where cam_campana = p_cam_campana;*/
        ELSIF l_Estado = 'PEND' AND
              l_Ind_Divisor = 'SI' THEN
          l_Tipo_Entrega := 'PEND';
          SELECT (l_Ult_Benef + Numtodsinterval(l_Param_Tmpo
                                               ,'SECOND')) - SYSDATE
            INTO l_Tiempo
            FROM Dual;
          IF l_Tiempo > 0 THEN
            Agrega_Camp := FALSE;
          ELSE
            Agrega_Camp := TRUE;
            BEGIN
              UPDATE Scfr_Camp_Ctrl_Beneficios
                 SET Total_Entregado = l_Cant_Benef
                    ,Fecha_Ult_Benef = SYSDATE
                    ,Rut_Benef       = Nvl(p_Rut
                                          ,0)
               WHERE Cam_Campana = p_Cam_Campana
                 AND Trunc(Fecha_Entrega) = Trunc(p_Fecha_Tx);
            EXCEPTION
              WHEN OTHERS THEN
                Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => 'Retorna Benef Campa?a'
                                          ,p_Msg     => 'No se pudo actualizar');
            END;
            Scfr_Trx_Util_Pk.Error_Msg(p_Proceso => 'Retorna Benef Campa?a'
                                      ,p_Msg     => 'update scfr_camp_ctrl_beneficios  set total_entregado =' || l_Cant_Benef ||
                                                    ',	  fecha_ult_benef = ' || SYSDATE || '	  where cam_campana     =' || p_Cam_Campana ||
                                                    '	and trunc(fecha_entrega) = trunc(' || p_Fecha_Tx || ') agrega campa?a:true');
            Dbms_Output.Put_Line('update scfr_camp_ctrl_beneficios  set total_entregado =' || l_Cant_Benef || ',	  fecha_ult_benef = ' || SYSDATE ||
                                 '	  where cam_campana     =' || p_Cam_Campana || '	and trunc(fecha_entrega) = trunc(' || p_Fecha_Tx || ')');
          END IF; -- l_tiempo > 0
        ELSE
          l_Tipo_Entrega := 'DISP';
          Agrega_Camp    := Obtiene_Estado(p_Cam_Campana
                                          ,p_Fecha_Tx
                                          ,p_Rut);
          /*se corre esta logica a la Venta*/
          /*
           select to_char(p_fecha_tx, 'D')
             into l_dia_semana
             from dual;
             BEGIN
                   l_sql:= 'select media_venta_dia'||l_dia_semana||', total_venta_dia
                              from scfr_camp_param_benef
                             where cam_campana  = '||p_cam_campana;

                EXECUTE IMMEDIATE l_sql INTO l_vta_max, l_vta_tot;
             EXCEPTION
                 WHEN NO_DATA_FOUND then
                    l_vta_max:=0;
                    l_vta_tot:=1;
             END;
             IF l_vta_tot = 0 then
                  agrega_camp:= FALSE;
             else
                l_vta_prom := trunc(l_vta_max / (l_max_benef + l_divisor));
                l_obt_benef := mod (l_vta_tot , l_vta_prom);
                IF l_obt_benef = 0 then
                     agrega_camp:= TRUE;
                     update scfr_camp_ctrl_beneficios
                        set estado_benef         = 'PEND',
                        rut_benef            = nvl(p_rut,0),
          fecha_ult_benef        = sysdate
                      where cam_campana          = p_cam_campana
                        and trunc(fecha_entrega) = trunc(p_fecha_tx);
                else
                    agrega_camp:= FALSE;
                END IF; -- l_obt_benef = 0
             END IF; -- l_vta_tot = 0*/
        END IF; -- l_estado = 'PEND'
      END IF; --  l_ent_local = 0
    ELSE
      --  l_cant_benef < l_max_benef then
      Agrega_Camp := FALSE;
    END IF; -- l_cant_benef < l_max_benef then
    p_Datos := l_Vta_Tot || '; total_entregado:' || l_Cant_Benef || ' parametro t max: ' || l_Param_Tmpo || ' tipo entrega:' || l_Tipo_Entrega;
    COMMIT;
    RETURN Agrega_Camp;
  END;

  PROCEDURE Registra_Datos_Ventas_Sri(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                     ,x_Trama_Dp    IN OUT Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp
                                     ,x_Trama_Dv    IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv
                                     ,x_Cod_Error   OUT NUMBER
                                     ,x_Msg_Error   OUT VARCHAR2) IS

    v_Codigo_Tx             NUMBER(15);
    v_Correlativo_Tx        NUMBER(15);
    v_Tmo_Movimiento_Padre  VARCHAR2(6);
    v_Fecha_Tx              DATE;
    v_Razonsocialcomprador  VARCHAR2(90);
    v_Rut_Titular           NUMBER(10);
    v_Dv_Titular            VARCHAR2(1);
    v_Ruc_Comprador         VARCHAR2(15);
    v_Direstablecimiento    VARCHAR2(240);
    v_Contribuyenteespecial VARCHAR2(1);
    v_Obligadocontabilidad  VARCHAR2(1);
    v_Nombresucursal        VARCHAR2(360);
    v_Emp_Empresa           NUMBER(4);
    v_Cad_Cadena            NUMBER(4);
    v_Loc_Local             NUMBER(5);
    v_Tipo_Cliente_Venta    VARCHAR2(2);
    x_Respuesta             NUMBER;
    x_Estado                VARCHAR2(300);
    
    v_Nombre_Cliente_Factura VARCHAR2(100); --JAGC 20250427 CAMBIOS INMEDICAL

  BEGIN
    
    DBMS_OUTPUT.PUT_LINE('Registra_Datos_Ventas_Sri');

    SELECT Lo_Address1
          ,Contribuyenteespecial
          ,Obligadocontabilidad
          ,Nombre_Local
      INTO v_Direstablecimiento
          ,v_Contribuyenteespecial
          ,v_Obligadocontabilidad
          ,v_Nombresucursal
      FROM Scfr_Locales_v
     WHERE Org_Id = p_Transaccion.Trama_Pos.Empresa
       AND Numero_Cadena = p_Transaccion.Trama_Pos.Cadena
       AND Numero = p_Transaccion.Trama_Pos.Local;

    IF p_Transaccion.Trama_Boc.Forma_Identificacion = 'R' THEN
      v_Tipo_Cliente_Venta := '04'; -- RUC
    ELSIF p_Transaccion.Trama_Boc.Forma_Identificacion = 'I' THEN
      v_Tipo_Cliente_Venta := '05'; -- CEDULA
    ELSIF p_Transaccion.Trama_Boc.Forma_Identificacion = 'F' THEN
      v_Tipo_Cliente_Venta := '06'; -- PASAPORTE
    ELSIF p_Transaccion.Trama_Boc.Forma_Identificacion = 'S' THEN
      v_Tipo_Cliente_Venta := '07'; -- CONSUMIDOR FINAL
    ELSE
      v_Tipo_Cliente_Venta := '00'; -- Identificacion DESCONOCIDA
    END IF;
    
    --INI JAGC 20250427 CAMBIOS INMEDICAL        
    BEGIN

      IF TRIM(x_Trama_Dp.Nombres) = '-' THEN
        x_Trama_Dp.Nombres := TRIM(x_Trama_Dv.Nombre_Cliente_Factura);
      END IF;
      
      DBMS_OUTPUT.PUT_LINE('x_Trama_Dv.Nombre_Cliente_Factura: ' || TRIM(Limpiar_String(SUBSTR(TRIM(x_Trama_Dv.Nombre_Cliente_Factura), 1, 100))));
      v_Nombre_Cliente_Factura := TRIM(Limpiar_String(SUBSTR(TRIM(x_Trama_Dv.Nombre_Cliente_Factura), 1, 100)));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_Nombre_Cliente_Factura := x_Trama_Dp.Nombres;
        DBMS_OUTPUT.PUT_LINE('No se encontr� informaci�n para Nombre_Cliente_Factura.');
      WHEN OTHERS THEN
        v_Nombre_Cliente_Factura := x_Trama_Dp.Nombres;
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
    END;
    
    DBMS_OUTPUT.PUT_LINE('v_Nombre_Cliente_Factura: ' || v_Nombre_Cliente_Factura);
    --FIN JAGC 20250427 CAMBIOS INMEDICAL

    
    v_Razonsocialcomprador:= SUBSTR(TRIM(x_Trama_Dp.Nombres) || ' ' || TRIM(x_Trama_Dp.Apellido_Paterno) || ' ' || TRIM(x_Trama_Dp.Apellido_Materno),1,90);

    INSERT INTO Scfr_Mov_Datos_Ventas
      (Txo_Codigo_Tx
      ,Txo_Correlativo_Tx
      ,Tmo_Movimiento_Padre
      ,Fecha_Tx
      ,Razonsocialcomprador
      ,Rut_Titular
      ,Dv_Titular
      ,Ruc_Comprador
      ,Tipo_Identi_Titular
      ,Identi_Titular
      ,Direstablecimiento
      ,Contribuyenteespecial
      ,Obligadocontabilidad
      ,Nombresucursal
      ,Emp_Empresa
      ,Cad_Cadena
      ,Loc_Local
      ,Tipo_Facturacion
      ,Cliente_Factura
      ,Nombre_Cliente_Factura
      ,Direccion_Cliente_Factura
      ,Correo_Electronico
      ,Clave_Acceso
      ,Numero_Comprobante
      ,Serie_Sri
      ,Numero_Resolucion
      ,Agente_Retencion
      ,Microempresa
      ,Tipo_Cliente_Venta
      ,Motivo
      ,Id_Supervisor_Externo
      ,gran_contribuyente) -- IDHC  D99
    VALUES
      (p_Transaccion.Codigo_Tx
      ,p_Transaccion.Correlativo_Tx
      ,x_Trama_Dv.Tipo_Movimiento_Padre
      ,p_Transaccion.Fecha_Tx
      ,v_Razonsocialcomprador
      --,TRIM(x_Trama_Dp.Nombres) || ' ' || TRIM(x_Trama_Dp.Apellido_Paterno) || ' ' || TRIM(x_Trama_Dp.Apellido_Materno)
      ,p_Transaccion.Rut_Titular
      ,p_Transaccion.Dv_Rut_Titular
      ,NULL -- v_Ruc_Comprador   (FALTA)
      ,Substr(p_Transaccion.Trama_Boc.Forma_Identificacion
             ,1
             ,1)
      ,TRIM(p_Transaccion.Trama_Boc.String_Identificacion)
      ,v_Direstablecimiento
      ,v_Contribuyenteespecial
      ,v_Obligadocontabilidad
      ,v_Nombresucursal
      ,p_Transaccion.Trama_Pos.Empresa
      ,p_Transaccion.Trama_Pos.Cadena
      ,p_Transaccion.Trama_Pos.Local
      ,x_Trama_Dv.Tipo_Facturacion
      ,x_Trama_Dv.Cliente_Factura
      ,v_Nombre_Cliente_Factura -- JAGC 20250427 CAMBIOS INMEDICAL --TRIM(x_Trama_Dv.Nombre_Cliente_Factura);
      ,SUBSTR(TRIM(x_Trama_Dv.Direccion_Cliente_Factura),1,97)
      ,TRIM(x_Trama_Dv.Correo_Electronico)
      ,TRIM(x_Trama_Dv.Clave_Acceso)
      ,x_Trama_Dv.Numero_Comprobante
      ,x_Trama_Dv.Serie_Sri
      ,x_Trama_Dv.Numero_Resolucion
      ,TRIM(x_Trama_Dv.Agente_Retencion)
      ,TRIM(x_Trama_Dv.Microempresa)
      ,v_Tipo_Cliente_Venta
      ,TRIM(x_Trama_Dv.Motivo)
      ,x_Trama_Dv.Id_Supervisor_Externo
      ,x_Trama_Dv.Tax_Payer); -- IDHC D99 04/06/2024
    /*

    se cambia a procedimiento Actualiza_Relacion_Venta


      Pkg_Sri.Proc_Procesa(p_Transaccion.Trama_Pos.Empresa
                          ,p_Transaccion.Trama_Pos.Local
                          ,p_Transaccion.Trama_Pos.Numero_Pos
                          ,p_Transaccion.Fecha_Tx
                          ,p_Transaccion.Codigo_Tx
                          ,TRIM(x_Trama_Dv.Subtrama_Dv1(1).Folio)
                          ,x_Respuesta
                          ,x_Estado
                          ,x_Cod_Error
                          ,x_Msg_Error); */

    x_Cod_Error := 0;
    x_Msg_Error := NULL;
  END;

  PROCEDURE Registra_Datos_Ventas_Recaud(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                         ,x_Trama_Dp    IN OUT Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp
                                         ,x_Trama_Dr    IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dr
                                         ,x_Cod_Error   OUT NUMBER
                                         ,x_Msg_Error   OUT VARCHAR2) IS

    v_Codigo_Tx             NUMBER(15);
    v_Correlativo_Tx        NUMBER(15);
    v_Tmo_Movimiento_Padre  VARCHAR2(6);
    v_Fecha_Tx              DATE;
    v_Razonsocialcomprador  VARCHAR2(90);
    v_Rut_Titular           NUMBER(10);
    v_Dv_Titular            VARCHAR2(1);
    v_Ruc_Comprador         VARCHAR2(15);
    v_Direstablecimiento    VARCHAR2(240);
    v_Contribuyenteespecial VARCHAR2(1);
    v_Obligadocontabilidad  VARCHAR2(1);
    v_Nombresucursal        VARCHAR2(360);
    v_Emp_Empresa           NUMBER(4);
    v_Cad_Cadena            NUMBER(4);
    v_Loc_Local             NUMBER(5);
    v_Tipo_Cliente_Venta    VARCHAR2(2);
    x_Respuesta             NUMBER;
    x_Estado                VARCHAR2(300);
    
    v_Nombre_Cliente_Factura VARCHAR2(100); --JAGC 20250427 CAMBIOS INMEDICAL

  BEGIN
    
    DBMS_OUTPUT.PUT_LINE('Registra_Datos_Ventas_Recaud');

    SELECT Lo_Address1
          ,Contribuyenteespecial
          ,Obligadocontabilidad
          ,Nombre_Local
      INTO v_Direstablecimiento
          ,v_Contribuyenteespecial
          ,v_Obligadocontabilidad
          ,v_Nombresucursal
      FROM Scfr_Locales_v
     WHERE Org_Id = p_Transaccion.Trama_Pos.Empresa
       AND Numero_Cadena = p_Transaccion.Trama_Pos.Cadena
       AND Numero = p_Transaccion.Trama_Pos.Local;

    IF p_Transaccion.Trama_Boc.Forma_Identificacion = 'R' THEN
      v_Tipo_Cliente_Venta := '04'; -- RUC
    ELSIF p_Transaccion.Trama_Boc.Forma_Identificacion = 'I' THEN
      v_Tipo_Cliente_Venta := '05'; -- CEDULA
    ELSIF p_Transaccion.Trama_Boc.Forma_Identificacion = 'F' THEN
      v_Tipo_Cliente_Venta := '06'; -- PASAPORTE
    ELSIF p_Transaccion.Trama_Boc.Forma_Identificacion = 'S' THEN
      v_Tipo_Cliente_Venta := '07'; -- CONSUMIDOR FINAL
    ELSE
      v_Tipo_Cliente_Venta := '00'; -- Identificacion DESCONOCIDA
    END IF;
    
    v_Nombre_Cliente_Factura := SUBSTR(TRIM(x_Trama_Dp.Nombres) || ' ' || TRIM(x_Trama_Dp.Apellido_Paterno) || ' ' || TRIM(x_Trama_Dp.Apellido_Materno),1,90);
    
    v_Razonsocialcomprador:= SUBSTR(TRIM(x_Trama_Dp.Nombres) || ' ' || TRIM(x_Trama_Dp.Apellido_Paterno) || ' ' || TRIM(x_Trama_Dp.Apellido_Materno),1,90);

    INSERT INTO Scfr_Mov_Datos_Ventas
      (Txo_Codigo_Tx
      ,Txo_Correlativo_Tx
      ,Tmo_Movimiento_Padre
      ,Fecha_Tx
      ,Razonsocialcomprador
      ,Rut_Titular
      ,Dv_Titular
      ,Ruc_Comprador
      ,Tipo_Identi_Titular
      ,Identi_Titular
      ,Direstablecimiento
      ,Contribuyenteespecial
      ,Obligadocontabilidad
      ,Nombresucursal
      ,Emp_Empresa
      ,Cad_Cadena
      ,Loc_Local
      ,Tipo_Facturacion
      ,Cliente_Factura
      ,Nombre_Cliente_Factura
      ,Direccion_Cliente_Factura
      ,Correo_Electronico
      ,Clave_Acceso
      ,Numero_Comprobante
      ,Serie_Sri
      ,Numero_Resolucion
      ,Agente_Retencion
      ,Microempresa
      ,Tipo_Cliente_Venta
      ,Motivo
      ,Id_Supervisor_Externo
      ,gran_contribuyente) 
    VALUES
      (p_Transaccion.Codigo_Tx
      ,p_Transaccion.Correlativo_Tx
      ,x_Trama_Dr.Tipo_Movimiento_Padre
      ,p_Transaccion.Fecha_Tx
      ,v_Razonsocialcomprador
      ,NULL --p_Transaccion.Rut_Titular
      ,NULL --p_Transaccion.Dv_Rut_Titular
      ,NULL 
      ,Substr(p_Transaccion.Trama_Boc.Forma_Identificacion,1,1)
      ,TRIM(p_Transaccion.Trama_Boc.String_Identificacion)
      ,v_Direstablecimiento
      ,v_Contribuyenteespecial
      ,v_Obligadocontabilidad
      ,v_Nombresucursal
      ,p_Transaccion.Trama_Pos.Empresa
      ,p_Transaccion.Trama_Pos.Cadena
      ,p_Transaccion.Trama_Pos.Local
      ,NULL
      ,TRIM(p_Transaccion.Trama_Boc.String_Identificacion)
      ,v_Nombre_Cliente_Factura 
      ,SUBSTR(TRIM(x_Trama_Dp.Direccion),1,97)
      ,TRIM(x_Trama_Dp.Email)
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,v_Tipo_Cliente_Venta
      ,NULL
      ,NULL
      ,NULL);

    x_Cod_Error := 0;
    x_Msg_Error := NULL;
  END;

  PROCEDURE Registra_Vta(p_Fecha_Tx    IN DATE
                        ,p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                        ,p_Rut         IN NUMBER) IS
    l_Dia_Semana  NUMBER;
    l_Vta_Max     NUMBER;
    l_Vta_Tot     NUMBER := 1;
    l_Vta_Prom    NUMBER;
    l_Obt_Benef   NUMBER;
    l_Max_Benef   NUMBER := 0;
    l_Divisor     NUMBER;
    l_Num_Vta     NUMBER := 0;
    l_Num_Vta_Cam NUMBER := 0;
    l_Trama_Pm    Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pm;
    l_Trama_Dv    Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dv;
    l_Itm         NUMBER;
    l_Itm2        NUMBER;
    l_Codigo_Cam  NUMBER;
    l_Tipo_Cam    VARCHAR2(10);
    l_Tot_Benef   NUMBER;
    l_Campana     NUMBER;
    l_Campana_Vig NUMBER := 0;
    l_Existe      NUMBER := 0;
    l_Rut_Benef   NUMBER;
    l_Sql         VARCHAR2(2000);
    l_Tot_Vta     NUMBER := 0;
    l_Fecha       DATE;
    l_Datos       VARCHAR2(2000);
    CURSOR c_Campanas_Cds IS
      SELECT Campana
        FROM Scfr_Campanas
       WHERE Tipo_Campana = 'CDS'
         AND Trunc(Fecha_Inicio) <= Trunc(p_Fecha_Tx)
         AND Trunc(Nvl(Fecha_Termino
                      ,Scfr_Trx_Util_Pk.Get_Sysdate())) >= Trunc(p_Fecha_Tx);
  BEGIN
    l_Trama_Dv   := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Dv(p_Transaccion.Trama_Pos
                                                      ,p_Transaccion.Cuerpo_Tx);
    l_Trama_Pm   := Scfr_Trx_Dyn_Utl_Pk.Carga_Trama_Pm(p_Transaccion.Trama_Pos
                                                      ,p_Transaccion.Cuerpo_Tx);
    l_Dia_Semana := Obtiene_Dia_Num(p_Fecha_Tx);
    /*   select to_char(p_fecha_tx, 'D')
    into l_dia_semana
    from dual;*/
    -- obtiene divisor para otorgar beneficio
    BEGIN
      SELECT Rv_High_Value
        INTO l_Divisor
        FROM Cg_Ref_Codes
       WHERE Rv_Domain = 'PARAMETROS'
         AND Rv_Low_Value = 'DIV_OTORGA_BENEF';
    EXCEPTION
      WHEN No_Data_Found THEN
        l_Divisor := 1;
    END;
    -- recorro las campa?as vigentes
    FOR r_Campanas IN c_Campanas_Cds
    LOOP
      IF Scfr_Trx_Fid_Pk.Esta_En_Tramo_Horario(r_Campanas.Campana) THEN
        l_Campana_Vig := r_Campanas.Campana;
      END IF;
    END LOOP;
    IF l_Campana_Vig != 0 THEN
      BEGIN
        SELECT Total_Venta_Dia
              ,Fecha_Venta_Dia
              ,Total_Benef_Dia
          INTO l_Tot_Vta
              ,l_Fecha
              ,l_Max_Benef
          FROM Scfr_Camp_Param_Benef
         WHERE Cam_Campana = l_Campana_Vig;
      EXCEPTION
        WHEN OTHERS THEN
          l_Tot_Vta   := 0;
          l_Fecha     := SYSDATE;
          l_Max_Benef := 0;
      END;
      IF Trunc(p_Fecha_Tx) > Trunc(l_Fecha) THEN
        UPDATE Scfr_Camp_Param_Benef
           SET Total_Venta_Dia = 0
              ,Fecha_Venta_Dia = p_Fecha_Tx
         WHERE Cam_Campana = l_Campana_Vig;
      ELSE
        l_Tot_Vta := l_Tot_Vta + 1;
        UPDATE Scfr_Camp_Param_Benef SET Total_Venta_Dia = l_Tot_Vta WHERE Cam_Campana = l_Campana_Vig;
      END IF;
      /*Esta es la logica que permite entregar al prox perfil o no un beneficio*/
      BEGIN
        l_Sql := 'select media_venta_dia' || l_Dia_Semana || ', total_venta_dia
										 FROM scfr_camp_param_benef
										WHERE cam_campana  = ' || l_Campana_Vig;
        EXECUTE IMMEDIATE l_Sql
          INTO l_Vta_Max, l_Vta_Tot;
      EXCEPTION
        WHEN No_Data_Found THEN
          l_Vta_Max := 0;
          l_Vta_Tot := 1;
        WHEN OTHERS THEN
          l_Vta_Max := 0;
          l_Vta_Tot := 1;
      END;
      IF l_Vta_Tot != 0 THEN
        IF (l_Max_Benef + l_Divisor) != 0 THEN
          l_Vta_Prom  := Trunc(l_Vta_Max / (l_Max_Benef + l_Divisor));
          l_Obt_Benef := MOD(l_Vta_Tot
                            ,l_Vta_Prom);
          IF l_Obt_Benef = 0 THEN
            UPDATE Scfr_Camp_Ctrl_Beneficios
               SET Estado_Benef    = 'DISP'
                  ,Rut_Benef       = Nvl(p_Rut
                                        ,0)
                  ,Fecha_Ult_Benef = SYSDATE
             WHERE Cam_Campana = l_Campana_Vig
               AND Trunc(Fecha_Entrega) = Trunc(p_Fecha_Tx);
            l_Datos := l_Tot_Vta || '; total_entregado:' || l_Tot_Benef || ' Lo deja disponible';
            Registra_Log_Benef(p_Fecha_Tx
                              ,p_Rut
                              ,p_Transaccion.Trama_Pos.Local
                              ,p_Transaccion.Trama_Pos.Numero_Pos
                              ,p_Transaccion.Trama_Pos.Usuario_Responsable
                              ,l_Trama_Dv.Correlativo_Tx
                              ,''
                              ,l_Datos);
          END IF; -- l_obt_benef = 0
        END IF; --(l_max_benef + l_divisor) != 0
      END IF; -- l_vta_tot = 0
      /* fin de */
      /* recorre productos para obtener campa?as */
      FOR l_Itm IN 1 .. l_Trama_Pm.Count
      LOOP
        FOR l_Itm2 IN 1 .. l_Trama_Pm(l_Itm).Subtrama_Pm2.Count
        LOOP
          IF l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Tipo_Descuento = 'CAM' THEN
            BEGIN
              SELECT Tipo_Campana INTO l_Tipo_Cam FROM Scfr_Campanas WHERE Campana = l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Campana_o_Convenio;
            EXCEPTION
              WHEN No_Data_Found THEN
                l_Tipo_Cam := 'NO';
            END;
            IF l_Tipo_Cam = 'CDS' AND
               Scfr_Trx_Fid_Pk.Esta_En_Tramo_Horario(l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Campana_o_Convenio) THEN
              BEGIN
                INSERT INTO Scfr_Camp_Ctrl_Beneficios
                  (Cam_Campana
                  ,Fecha_Entrega
                  ,Total_Entregado
                  ,Estado_Benef
                  ,Fecha_Ult_Benef
                  ,Rut_Benef)
                VALUES
                  (l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Campana_o_Convenio
                  ,Trunc(p_Fecha_Tx)
                  ,1
                  ,'DISP'
                  ,SYSDATE
                  ,p_Rut);
                l_Existe := 1;
              EXCEPTION
                WHEN Dup_Val_On_Index THEN
                  IF l_Existe != 1 THEN
                    BEGIN
                      SELECT Total_Entregado
                        INTO l_Tot_Benef
                        FROM Scfr_Camp_Ctrl_Beneficios
                       WHERE Cam_Campana = l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Campana_o_Convenio
                         AND Trunc(Fecha_Entrega) = Trunc(p_Fecha_Tx);
                      l_Campana := l_Trama_Pm(l_Itm).Subtrama_Pm2(l_Itm2).Campana_o_Convenio;
                      l_Existe  := 1;
                    EXCEPTION
                      WHEN OTHERS THEN
                        l_Tot_Benef := 1;
                    END;
                  END IF;
              END;
              /*       ELSE
              BEGIN
                select rut_benef into l_rut_benef
                  from scfr_camp_ctrl_beneficios
                 where rut_benef = p_rut
                   and trunc(fecha_entrega) = trunc(p_fecha_tx);
              EXCEPTION
                 WHEN OTHERS then
                   l_rut_benef := 0;
              END;
              IF l_rut_benef = p_rut then
                 update  scfr_camp_ctrl_beneficios
                    set  estado_benef = 'DISP'
                  where trunc(fecha_entrega) = trunc(p_fecha_tx);
              END IF;*/
            END IF;
          END IF;
        END LOOP;
      END LOOP;
      IF l_Existe = 1 THEN
        l_Datos     := l_Tot_Vta || '; total_entregado:' || l_Tot_Benef;
        l_Tot_Benef := l_Tot_Benef + 1;
        UPDATE Scfr_Camp_Ctrl_Beneficios
           SET Total_Entregado = l_Tot_Benef --,
        --      estado_benef = 'DISP',
        --    fecha_ult_benef = sysdate
         WHERE Cam_Campana = l_Campana
           AND Trunc(Fecha_Entrega) = Trunc(p_Fecha_Tx);
        Registra_Log_Benef(p_Fecha_Tx
                          ,p_Rut
                          ,p_Transaccion.Trama_Pos.Local
                          ,p_Transaccion.Trama_Pos.Numero_Pos
                          ,p_Transaccion.Trama_Pos.Usuario_Responsable
                          ,l_Trama_Dv.Correlativo_Tx
                          ,'OTORGA'
                          ,l_Datos);
      END IF;
    END IF;
  END;

  PROCEDURE Registra_Log_Benef(p_Fecha          IN DATE DEFAULT SYSDATE
                              ,p_Rut            IN NUMBER DEFAULT NULL
                              ,p_Local          IN NUMBER DEFAULT NULL
                              ,p_Pos            IN NUMBER DEFAULT NULL
                              ,p_Correlativo_Tx IN NUMBER DEFAULT NULL
                              ,p_Rut_Vend       IN NUMBER DEFAULT NULL
                              ,p_Tipo           IN VARCHAR2 DEFAULT NULL
                              ,p_Otros_Datos    IN VARCHAR2 DEFAULT NULL) IS
    l_Log          Utl_File.File_Type;
    l_Log2         Utl_File.File_Type;
    l_File         VARCHAR2(100);
    l_Int          NUMBER;
    l_Dir          VARCHAR2(500);
    l_Ret          NUMBER;
    l_Nombre_Log   VARCHAR2(100) := 'LOG_BENEF_' || To_Char(SYSDATE
                                                           ,'YYYYMMDD') || '.csv';
    l_Nombre_Log2  VARCHAR2(100) := 'LOG_BENEF_OTORGA' || To_Char(SYSDATE
                                                                 ,'YYYYMMDD') || '.csv';
    l_Folio        NUMBER;
    l_String       VARCHAR2(2000);
    p_Sqlerrorcode NUMBER;
    p_Sqlerrormsg  VARCHAR2(2000);
  BEGIN
    -- obtiene directorio en donde escribir el archivo log.
    l_Ret := Dbms_Utility.Get_Parameter_Value('utl_file_dir'
                                             ,l_Int
                                             ,l_Dir
                                             ,2);
    -- intenta abrir el archivo log, de existir, lo abre para seguir insertando
    IF (p_Tipo = 'OTORGA') THEN
      l_String := p_Tipo || ';' || To_Char(p_Fecha
                                          ,'dd/mm/yyyy hh24:mi:ss') || ';' || p_Rut || ';' || p_Local || ';' || p_Pos || ';' || p_Correlativo_Tx;
      SELECT Scfr_Bitacora_s.Nextval INTO l_Folio FROM Dual;
      BEGIN
        INSERT INTO Scfr_Bitacora
          (Folio
          ,Proceso
          ,Fecha
          ,Usuario
          ,Descripcion)
        VALUES
          (l_Folio
          ,'PROM_BENEF_OTOR'
          ,SYSDATE
          ,'A'
          ,Substr(p_Rut_Vend || ';' || p_Correlativo_Tx || ';' || p_Local || ';' || p_Tipo || ';' ||
                  To_Char(p_Fecha
                         ,'dd/mm/yyyy hh24:mi:ss') || ';' || p_Rut || ';' || p_Pos || ';' || p_Otros_Datos || ';'
                 ,1
                 ,250));
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
    BEGIN
      IF Length(l_Dir) > 0 THEN
        l_Log  := Utl_File.Fopen(l_Dir
                                ,l_Nombre_Log
                                ,'a');
        l_Log2 := Utl_File.Fopen(l_Dir
                                ,l_Nombre_Log2
                                ,'a');
      END IF;
      IF l_String IS NOT NULL THEN
        Utl_File.Put_Line(l_Log2
                         ,l_String);
        Utl_File.Fclose(l_Log2);
      END IF;
      Utl_File.Put_Line(l_Log
                       ,p_Tipo || ';' || To_Char(p_Fecha
                                                ,'dd/mm/yyyy hh24:mi:ss') || ';' || p_Rut || ';' || p_Local || ';' || p_Pos || ';' ||
                        p_Correlativo_Tx || ';' || p_Otros_Datos || ';');
      Utl_File.Fclose(l_Log);
    EXCEPTION
      WHEN Utl_File.Invalid_Path THEN
        p_Sqlerrorcode := SQLCODE;
        p_Sqlerrormsg  := Substr('Invalid Path= >' || SQLERRM
                                ,1
                                ,200);
        Dbms_Output.Put_Line(p_Sqlerrormsg);
        Dbms_Output.Put_Line('num error9:' || p_Sqlerrorcode);
        Dbms_Output.Put_Line('mensaje:' || p_Sqlerrormsg);
        -- -------------------------------------------------------------------------------
      WHEN Utl_File.Invalid_Mode THEN
        p_Sqlerrorcode := SQLCODE;
        p_Sqlerrormsg  := Substr('Invalid Mode= >' || SQLERRM
                                ,1
                                ,200);
        Dbms_Output.Put_Line(p_Sqlerrormsg);
        Dbms_Output.Put_Line('num error10:' || p_Sqlerrorcode);
        Dbms_Output.Put_Line('mensaje:' || p_Sqlerrormsg);
        -- -------------------------------------------------------------------------------
      WHEN Utl_File.Invalid_Filehandle THEN
        p_Sqlerrorcode := SQLCODE;
        p_Sqlerrormsg  := Substr('Invalid Filehandle= >' || SQLERRM
                                ,1
                                ,200);
        Dbms_Output.Put_Line(p_Sqlerrormsg);
        Dbms_Output.Put_Line('num error11:' || p_Sqlerrorcode);
        Dbms_Output.Put_Line('mensaje:' || p_Sqlerrormsg);
        -- -------------------------------------------------------------------------------
      WHEN Utl_File.Read_Error THEN
        p_Sqlerrorcode := SQLCODE;
        p_Sqlerrormsg  := Substr('Read Error= >' || SQLERRM
                                ,1
                                ,200);
        Dbms_Output.Put_Line(p_Sqlerrormsg);
        Dbms_Output.Put_Line('num error12:' || p_Sqlerrorcode);
        Dbms_Output.Put_Line('mensaje:' || p_Sqlerrormsg);
        -- -------------------------------------------------------------------------------
      WHEN Utl_File.Write_Error THEN
        p_Sqlerrorcode := SQLCODE;
        p_Sqlerrormsg  := Substr('Write Error= >' || SQLERRM
                                ,1
                                ,200);
        Dbms_Output.Put_Line(p_Sqlerrormsg);
        Dbms_Output.Put_Line('num error13:' || p_Sqlerrorcode);
        Dbms_Output.Put_Line('mensaje:' || p_Sqlerrormsg);
        -- -------------------------------------------------------------------------------
      WHEN Utl_File.Internal_Error THEN
        p_Sqlerrorcode := SQLCODE;
        p_Sqlerrormsg  := Substr('Internal Error= >' || SQLERRM
                                ,1
                                ,200);
        Dbms_Output.Put_Line(p_Sqlerrormsg);
        Dbms_Output.Put_Line('num error14:' || p_Sqlerrorcode);
        Dbms_Output.Put_Line('mensaje:' || p_Sqlerrormsg);
        -- -------------------------------------------------------------------------------
      WHEN No_Data_Found THEN
        p_Sqlerrorcode := SQLCODE;
        p_Sqlerrormsg  := Substr('No Data Found= >' || SQLERRM
                                ,1
                                ,200);
        Dbms_Output.Put_Line(p_Sqlerrormsg);
        Dbms_Output.Put_Line('num error15:' || p_Sqlerrorcode);
        Dbms_Output.Put_Line('mensaje:' || p_Sqlerrormsg);
        -- -------------------------------------------------------------------------------
      WHEN Value_Error THEN
        p_Sqlerrorcode := SQLCODE;
        p_Sqlerrormsg  := Substr('Value Error= >' || SQLERRM
                                ,1
                                ,200);
        Dbms_Output.Put_Line(p_Sqlerrormsg);
        Dbms_Output.Put_Line('num error16:' || p_Sqlerrorcode);
        Dbms_Output.Put_Line('mensaje:' || p_Sqlerrormsg);
        -- -------------------------------------------------------------------------------
      WHEN OTHERS THEN
        p_Sqlerrorcode := SQLCODE;
        Dbms_Output.Put_Line(p_Sqlerrormsg);
        Dbms_Output.Put_Line('num error17:' || p_Sqlerrorcode);
        Dbms_Output.Put_Line('mensaje:' || p_Sqlerrormsg);
        -- -------------------------------------------------------------------------------
    END;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  FUNCTION Obtiene_Dia_Num(p_Fecha IN DATE DEFAULT SYSDATE) RETURN NUMBER IS
    l_Dia     NUMBER;
    l_Dia_Car VARCHAR2(100);
  BEGIN
    l_Dia_Car := Upper(Substr(To_Char(p_Fecha
                                     ,'DAY')
                             ,1
                             ,3));
    IF l_Dia_Car = 'MON' OR
       l_Dia_Car = 'LUN' THEN
      l_Dia := 1;
    ELSIF l_Dia_Car = 'TUE' OR
          l_Dia_Car = 'MAR' THEN
      l_Dia := 2;
    ELSIF l_Dia_Car = 'MI' || Chr(50057) OR
          l_Dia_Car = 'WED' OR
          l_Dia_Car = 'MIE' THEN
      l_Dia := 3;
    ELSIF l_Dia_Car = 'THU' OR
          l_Dia_Car = 'JUE' THEN
      l_Dia := 4;
    ELSIF l_Dia_Car = 'FRI' OR
          l_Dia_Car = 'VIE' THEN
      l_Dia := 5;
    ELSIF l_Dia_Car = 'S' || Chr(50049) || 'B' OR
          l_Dia_Car = 'SAT' OR
          l_Dia_Car = 'SAB' THEN
      l_Dia := 6;
    ELSIF l_Dia_Car = 'SUN' OR
          l_Dia_Car = 'DOM' THEN
      l_Dia := 7;
    END IF;
    RETURN l_Dia;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 1;
  END;

  FUNCTION Obtiene_Digito_Verificador(p_Rut_Sin_Digito IN NUMBER) RETURN VARCHAR2 IS
    Dig        CHAR(1) := '0';
    Suma       NUMBER(10) := 0;
    Factor     NUMBER(2) := 2;
    Largo      NUMBER(2);
    Digito     NUMBER(1) := 0;
    Caracteres VARCHAR(12) := '123456789K0';
  BEGIN
    Largo := Length(p_Rut_Sin_Digito);
    FOR Contador IN REVERSE 1 .. Largo
    LOOP
      Digito := Substr(p_Rut_Sin_Digito
                      ,Contador
                      ,1);
      Suma   := Suma + Digito * Factor;
      Factor := Factor + 1;
      IF Factor > 7 THEN
        Factor := 2;
      END IF;
    END LOOP;
    Suma := 11 - MOD(Suma
                    ,11);
    Dig  := Substr(Caracteres
                  ,Suma
                  ,1);
    RETURN Dig;
  END;

  PROCEDURE Set_Nls(Param IN VARCHAR2) IS
    l_Valor VARCHAR2(500);
  BEGIN
    SELECT Rv_Low_Value
      INTO l_Valor
      FROM Cg_Ref_Codes t
     WHERE Rv_Domain = 'PARAMETROS'
       AND TRIM(Upper(Rv_Abbreviation)) = TRIM(Upper(Param))
       AND Rownum = 1;
    Dbms_Session.Set_Nls(Param
                        ,l_Valor);
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
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

 --------------------------------------------------------------------------------------
  -- JAGC 2024 GPF Ecuador 
  --------------------------------------------------------------------------------------
  --Limpia JSON de tíldes y ñ previo a consumir Request de cierre factura
  --------------------------------------------------------------------------------------  
  FUNCTION Limpiar_String(input_string VARCHAR2)
  RETURN VARCHAR2
  IS
      cleaned_string VARCHAR2(4000);
  BEGIN
      --cleaned_string := TRANSLATE(input_string,
      --                            'áéíóúñÁÉÍÓÚÑ',
      --                            'aeiounAEIOUN');

      cleaned_string := TRANSLATE(input_string,
                                  'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÄËÏÖÜÃÑÕÇÝÞÐØáéíóúàèìòùâêîôûäëïöüãñõçýþðø',
                                  'AEIOUAEIOUAEIOUAEIOUANOCYPDOaeiouaeiouaeiouaeiouanocypdo');

      -- Luego, utilizamos REPLACE para los caracteres que se traducen a m?ltiples caracteres
      cleaned_string := REPLACE(cleaned_string, 'Æ', 'AE');
      cleaned_string := REPLACE(cleaned_string, 'æ', 'ae');
      cleaned_string := REPLACE(cleaned_string, 'ß', 'ss');
      
      RETURN REGEXP_REPLACE(cleaned_string, '');
  END;  
END Scfr_Trx_Gnc_Utl_Pk;
/
