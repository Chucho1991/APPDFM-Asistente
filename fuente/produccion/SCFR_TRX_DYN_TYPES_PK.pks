CREATE OR REPLACE PACKAGE TRX3.Scfr_Trx_Dyn_Types_Pk AS

  -- Author      : USER_PIVOT2
  -- Modified by : JESUS GUERRA CEDEÑO 
  -- Modified    : 12/05/2026
  -- Purpose     : inclusión campo RUC_INSTITUCION en trama DR  

  --Vversion VARCHAR2(25) := 'GEO.11.09.2023';
  Vversion VARCHAR2(25) := 'GEO.23.04.2024';

  TYPE Rec_Trama_Gg IS RECORD(
     Separador_Registro    VARCHAR2(10)
    ,Separador_Campo       VARCHAR2(10)
    ,Cantidad_De_Registros NUMBER
    ,Campos_Por_Registro   NUMBER
    ,Data                  VARCHAR2(32767));

  TYPE Tab_Trama_Gg IS TABLE OF Rec_Trama_Gg INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Ab1 IS RECORD(
     Producto                NUMBER
    ,Tipo_Movimiento         VARCHAR2(1)
    ,Accion_Sobre_Existencia VARCHAR2(1)
    ,Cantidad                NUMBER
    ,Motivo                  VARCHAR2(6)
    ,Costo                   NUMBER(15, 4)
    ,Decimal_Costo           VARCHAR2(4)
    ,Precio_Lista            NUMBER(15, 4)
    ,Decimal_Plista          VARCHAR2(4)
    ,Codigo_Reclamo          VARCHAR2(6));

  TYPE Tab_Trama_Ab1 IS TABLE OF Rec_Trama_Ab1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Ab IS RECORD(
     Tipo_Movimiento_Padre VARCHAR2(6)
    ,Tipo_Movimiento_Hijo  VARCHAR2(6)
    ,Folio                 VARCHAR2(20)
    ,Monto                 NUMBER(15, 4)
    ,Decimal_Monto         VARCHAR2(4)
    ,Precio_Final          NUMBER(15, 4)
    ,Decimal_Pfinal        VARCHAR2(4)
    ,Folio_Ajuste          NUMBER --JAGC 20250414 ORIGEN FGI
    ,Cantidad_Productos    NUMBER
    ,Subtrama_Ab1          Tab_Trama_Ab1);

  TYPE Rec_Trama_Ac1 IS RECORD(
     Diagnostico VARCHAR2(20));

  TYPE Tab_Trama_Ac1 IS TABLE OF Rec_Trama_Ac1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Ac IS RECORD(
     Convenio                 NUMBER
    ,Plan                     NUMBER
    ,Rut                      NUMBER
    ,Digito_Verificador_Rut   VARCHAR2(1)
    ,Secuencia_b              NUMBER
    ,Rut_Medico               NUMBER
    ,Dv_Rut_Medico            VARCHAR2(1)
    ,Codigo_Receta            VARCHAR2(15)
    ,Rut_Institucion          NUMBER
    ,Dv_Rut_Institucion       VARCHAR2(1)
    ,Fecha_Receta             NUMBER
    ,Rut_Comprador            NUMBER
    ,Dv_Rut_Comprador         VARCHAR2(1)
    ,Cantidad_Periodos        NUMBER
    ,Rut_Perfil               NUMBER
    ,Secuencia_Receta         NUMBER
    ,Receta_Nueva             VARCHAR2(2)
    ,Ges_Uso_Receta           VARCHAR2(2)
    ,Uso_Excedente            VARCHAR2(2)
    ,Plan_Con_Guia            VARCHAR2(2)
    ,Codigo_Medico            NUMBER
    ,Identificador_Titular    VARCHAR2(30)
    ,Identificacion_Comprador VARCHAR2(30)
    ,Identificacion_Perfil    VARCHAR2(30)
    ,Party_Id_Cliente_c       VARCHAR2(30) --  JRG CIA 04/06/219
    ,Lista_Diagnosticos       NUMBER --  LMP GPF 29/06/2023
    ,Subtrama_Ac1             Tab_Trama_Ac1);
  /*
    type rec_trama_ac9 is record (
      convenio                                 number
    , plan                                     number
    , rut                                      number
    , digito_verificador_rut                   varchar2(1)
    , secuencia_b                              number
    , rut_medico                               number
    , dv_rut_medico                            varchar2(1)
    , codigo_receta                            varchar2(15)
    , rut_institucion                          number
    , dv_rut_institucion                       varchar2(1)
    , fecha_receta                             number
    , rut_comprador                            number
    , dv_rut_comprador                         varchar2(1)
    , cantidad_periodos                        number
    , rut_perfil                               number
    , secuencia_receta                         number
    , receta_nueva                             varchar2(2)
    );
  */
  TYPE Rec_Trama_Ae IS RECORD(
     Hora_Presentacion_Pop_Up VARCHAR2(6)
    ,Hora_Seleccion_Opcion    VARCHAR2(6)
    ,Campana                  NUMBER(8)
    ,Opcion_Seleccionada      NUMBER
    ,Numero_Preventa          NUMBER(15)
    ,Reintento_Vendedor       NUMBER
    ,Motivo_Rechazo           VARCHAR2(5));

  TYPE Rec_Trama_Ar1 IS RECORD(
     Codigo_Lista_Productos       NUMBER
    ,Bonificacion                 NUMBER
    ,Descuento                    NUMBER
    ,Tipo_Lista                   VARCHAR2(3)
    ,Asociacion_Lista             VARCHAR2(3)
    ,Prioridad                    NUMBER
    ,Permite_Levantar_Restriccion VARCHAR2(2)
    ,Maxima_Compra_Producto       VARCHAR2(2)
    ,Derecho_Segundo_Credito      VARCHAR2(2)
    ,Saldo_Contador               NUMBER
    ,Descuento_Adicional          NUMBER
    ,Aplicar_Siempre              VARCHAR2(2)
    ,Base_Descuento               VARCHAR2(3));

  TYPE Tab_Trama_Ar1 IS TABLE OF Rec_Trama_Ar1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Ar2 IS RECORD(
     Numero_Cuotas NUMBER
    ,Saldo         NUMBER);

  TYPE Tab_Trama_Ar2 IS TABLE OF Rec_Trama_Ar2 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Ar IS RECORD(
     Codigo_Autorizacion           VARCHAR2(20)
    ,Permite_Autorizacion_Producto VARCHAR2(2)
    ,Convenio_Cuota                VARCHAR2(2)
    ,Afecto_Segundo_Credito        VARCHAR2(2)
    ,Saldo                         NUMBER
    ,Saldo_Segundo_Credito         NUMBER
    ,Deducible_Periodo             NUMBER -- original
    ,Deducible_Compra              NUMBER -- original
    ,Deducible_Franquicia          NUMBER -- original
    ,Tipo_Deducible                VARCHAR2(3)
    ,Monto_Deducible               NUMBER
    ,Valor_Moneda                  NUMBER
    ,Tipo_Moneda                   VARCHAR2(3)
    ,Saldo_Descuento               NUMBER
    ,Cuadra_Transaccion            VARCHAR2(2)
    ,Documento_Liquidacion_Pago    VARCHAR2(3)
    ,Documento_Liquidacion_Empresa VARCHAR2(3)
    ,Folio_Bono                    NUMBER
    ,Folio_Copago                  NUMBER
    ,Id_Solicitud                  VARCHAR2(20)
    ,Numero_Tarjeta                VARCHAR2(15)
    ,Codigo_Autorizacion_Ext       VARCHAR2(20)
    ,Lista_Productos               NUMBER
    ,Lista_Cuotas                  NUMBER
    ,Saldo_Decimal                 VARCHAR2(4)
    ,Subtrama_Ar1                  Tab_Trama_Ar1
    ,Subtrama_Ar2                  Tab_Trama_Ar2);

  TYPE Rec_Trama_As IS RECORD(
     Numero_Pedido          NUMBER
    ,Estado_Service_Request VARCHAR2(3)
    ,Estado                 VARCHAR2(3)
    ,Fecha                  NUMBER
    ,Motivo                 VARCHAR2(20));

  TYPE Rec_Trama_Av IS RECORD(
     Codigo_Autorizacion VARCHAR2(20));

  TYPE Rec_Trama_Ad IS RECORD(
     Comuna           NUMBER
    ,Ciudad           NUMBER
    ,Numero_Direccion VARCHAR2(6)
    ,Calle_Direccion  VARCHAR2(30)
    ,Numero_Depto     VARCHAR2(6)
    ,BLOCK            VARCHAR2(6)
    ,Poblacion        VARCHAR2(30));

  TYPE Rec_Trama_Ca IS RECORD(
     Campana                 NUMBER
    ,Control_Eventos         VARCHAR2(2)
    ,Saldo_Descuento         NUMBER
    ,Controla_Tope_Descuento VARCHAR2(2)
    ,Saldo_Primera_Compra    NUMBER
    ,Numero_Cuenta           VARCHAR2(20)
    ,Numero_Rechazos         NUMBER
    ,Puntos_Disponibles      NUMBER
    ,Vigencia                NUMBER
    ,Mensajes_No_Ofrecidos   NUMBER
    ,Signo                   VARCHAR2(1)
    ,Cupo_Preaprobado        NUMBER);

  TYPE Tab_Trama_Ca IS TABLE OF Rec_Trama_Ca INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Cc IS RECORD(
     Codigo_Consejo NUMBER);

  TYPE Rec_Trama_Cd IS RECORD(
     Uso_Frecuente NUMBER);

  TYPE Rec_Trama_Ce IS RECORD(
     Codigo_Enfermedad NUMBER);

  TYPE Rec_Trama_Cf IS RECORD(
     Uso_Frecuente       NUMBER
    ,Evento_Actual       NUMBER
    ,Saldo_Evento_Actual NUMBER
    ,Signo               VARCHAR2(1)
    ,Eventos_Cumplidos   NUMBER
    ,Campana             NUMBER
    ,Fecha_Vencimiento   NUMBER);

  TYPE Tab_Trama_Cf IS TABLE OF Rec_Trama_Cf INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Cg IS RECORD(
     Codigo_Cupon           VARCHAR2(15)
    ,Estado                 VARCHAR2(3)
    ,Campana                NUMBER
    ,Fecha                  NUMBER
    ,Rut                    NUMBER
    ,Digito_Verificador_Rut VARCHAR2(1)
    ,Apellido_Paterno       VARCHAR2(20)
    ,Apellido_Materno       VARCHAR2(20)
    ,Nombre                 VARCHAR2(20)
    ,LOCAL                  NUMBER
    ,Folio                  NUMBER);

  TYPE Tab_Trama_Cg IS TABLE OF Rec_Trama_Cg INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Ci IS RECORD(
     Codigo_Cupon VARCHAR2(15));

  TYPE Tab_Trama_Ci IS TABLE OF Rec_Trama_Ci INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Ck1 IS RECORD(
     LOCAL NUMBER);

  TYPE Tab_Trama_Ck1 IS TABLE OF Rec_Trama_Ck1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Ck2 IS RECORD(
     Producto NUMBER);

  TYPE Tab_Trama_Ck2 IS TABLE OF Rec_Trama_Ck2 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Ck IS RECORD(
     Cantidad_Locales   NUMBER
    ,Cantidad_Productos NUMBER
    ,Subtrama_Ck1       Tab_Trama_Ck1
    ,Subtrama_Ck2       Tab_Trama_Ck2);

  TYPE Tab_Trama_Ck IS TABLE OF Rec_Trama_Ck INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Cl IS RECORD(
     Autorizacion VARCHAR2(2)
    ,Valida_Lista VARCHAR2(2));

  TYPE Tab_Trama_Cl IS TABLE OF Rec_Trama_Cl INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Cm IS RECORD(
     Codigo_Interno_Cupon NUMBER
    ,Mes                  NUMBER
    ,Limite               NUMBER
    ,Tipo_Cupon           VARCHAR2(3)
    ,Producto             NUMBER
    ,Familia_Comercial    NUMBER
    ,Descuento            NUMBER
    ,Campana              NUMBER
    ,Tipo_Beneficio       VARCHAR2(3));

  TYPE Tab_Trama_Cm IS TABLE OF Rec_Trama_Cm INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Cn IS RECORD(
     Numero_Opcion_Concurso NUMBER
    ,Campana                NUMBER);

  TYPE Tab_Trama_Cn IS TABLE OF Rec_Trama_Cn INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Co1 IS RECORD(
     Identi_Titular_Benefic         VARCHAR2(30)
    ,Rut_Titular_Beneficiario       NUMBER
    ,Digito_Verificador_Rut         VARCHAR2(1000)
    ,Party_Id_Cliente               NUMBER
    ,Party_Id_Cliente_c             VARCHAR2(30)
    ,Secuencia_Titular_Beneficiario NUMBER
    ,Apellido_Paterno               VARCHAR2(1000)
    ,Apellido_Materno               VARCHAR2(1000)
    ,Nombres                        VARCHAR2(1000)
    ,Estado_Beneficiario            VARCHAR2(1000)
    ,Saldo                          NUMBER
    ,Saldo_Segundo_Credito          NUMBER
    ,Biometria                      VARCHAR2(2)
    ,Clave_Qf_Biometria             VARCHAR2(2)
    ,Huella_Qf_Biometria            VARCHAR2(2)
    ,Firma_Electronica              VARCHAR2(2)
    ,Mensaje_Beneficiario           VARCHAR2(200)
    ,Saldo_Decimal                  VARCHAR2(4));

  TYPE Tab_Trama_Co1 IS TABLE OF Rec_Trama_Co1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Co2 IS RECORD(
     Identi_Titular_Benefic VARCHAR2(30)
    ,Codigo_Preexistencia   VARCHAR2(20)
    ,Mensaje_Preexistencia  VARCHAR2(200));

  TYPE Tab_Trama_Co2 IS TABLE OF Rec_Trama_Co2 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Co IS RECORD(
     Convenio                   NUMBER
    ,Plan                       NUMBER
    ,Estado_Convenio            VARCHAR2(1000)
    ,Retencion                  VARCHAR2(1000)
    ,Aplica_Dcto_Posologia      VARCHAR2(2)
    ,Agrupacion_Perfil          VARCHAR2(3)
    ,Prioridad_Ges              VARCHAR2(3)
    ,Dias_Tto_Defecto           NUMBER
    ,Receta_Retenida            VARCHAR2(2)
    ,Requiere_Indicaciones      VARCHAR2(2)
    ,Imprime_Indicaciones       VARCHAR2(2)
    ,Solicitar_Clave_Qf         VARCHAR2(2)
    ,Despliegue_Rechazo         VARCHAR2(2)
    ,Glosa_Descuento            VARCHAR2(35)
    ,Convenio_Club              VARCHAR2(3)
    ,Digitalizacion             VARCHAR2(2)
    ,Plan_Con_Guia              VARCHAR2(3) --  JRG CIA 04/06/219
    ,Despliega_Previsualizacion VARCHAR2(2)
    ,Plan_Alternativo           VARCHAR2(30)
    -----------------------------------------------
    -- 4/2023 LMP Origen TRX SAL
    -----------------------------------------------
    ,Tipo_Plan VARCHAR2(1)
    ,Item_Fee  VARCHAR2(25)
    ,Marca_Fee VARCHAR2(2)
    ----------------------------------------------
    ,Lista_Beneficiarios NUMBER
    ,Lista_Preexistencia NUMBER
    ,Subtrama_Co1        Tab_Trama_Co1
    ,Subtrama_Co2        Tab_Trama_Co2);

  TYPE Tab_Trama_Co IS TABLE OF Rec_Trama_Co INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Cp IS RECORD(
     Codigo_Interno_Cupon NUMBER
    ,Codigo_Cupon         VARCHAR2(15)
    ,Producto             NUMBER
    ,Familia_Comercial    NUMBER
    ,Descuento            NUMBER
    ,Tipo_Descuento       VARCHAR2(3)
    ,Vencimiento          NUMBER
    ,Campana              NUMBER
    ,Tipo_Cupon           VARCHAR2(3));

  TYPE Tab_Trama_Cp IS TABLE OF Rec_Trama_Cp INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Cr IS RECORD(
     Rut_Quien_Retira    NUMBER
    ,Dv_Rut_Quien_Retira VARCHAR2(1)
    ,Nombre_Quien_Retiro VARCHAR2(20));

  TYPE Rec_Trama_Cs IS RECORD(
     Codigo_Cupon VARCHAR2(15));

  TYPE Rec_Trama_Ct1 IS RECORD(
     Tipo_Transaccion VARCHAR2(3)
    ,LOCAL            NUMBER
    ,Folio            NUMBER
    ,Fecha            NUMBER
    ,Signo            VARCHAR2(1)
    ,Puntos           NUMBER);

  TYPE Tab_Trama_Ct1 IS TABLE OF Rec_Trama_Ct1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Ct IS RECORD(
     Signo               VARCHAR2(1)
    ,Puntos              NUMBER
    ,Rut_Beneficiario    NUMBER
    ,Dv_Rut_Beneficiario VARCHAR2(1)
    ,Nombre              VARCHAR2(20)
    ,Cantidad_Tx_Puntos  NUMBER
    ,Subtrama_Ct1        Tab_Trama_Ct1);

  TYPE Rec_Trama_Ct2 IS RECORD(
     LOCAL  NUMBER
    ,Folio  NUMBER
    ,Fecha  NUMBER
    ,Signo  VARCHAR2(1)
    ,Puntos NUMBER);

  TYPE Tab_Trama_Ct2 IS TABLE OF Rec_Trama_Ct2 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Ct3 IS RECORD(
     LOCAL  NUMBER
    ,Folio  NUMBER
    ,Fecha  NUMBER
    ,Signo  VARCHAR2(1)
    ,Puntos NUMBER);

  TYPE Tab_Trama_Ct3 IS TABLE OF Rec_Trama_Ct3 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Cu IS RECORD(
     Codigo_Cupon VARCHAR2(15)
    ,Estado       VARCHAR2(3)
    ,Campana      NUMBER
    ,Fecha        NUMBER
    ,LOCAL        NUMBER
    ,Folio        NUMBER);

  TYPE Tab_Trama_Cu IS TABLE OF Rec_Trama_Cu INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Cx IS RECORD(
     Campana                 NUMBER
    ,Control_Eventos         VARCHAR2(2)
    ,Saldo_Descuento         NUMBER
    ,Controla_Tope_Descuento VARCHAR2(2));

  TYPE Tab_Trama_Cx IS TABLE OF Rec_Trama_Cx INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Cv1 IS RECORD(
     Diagnostico VARCHAR2(20));

  TYPE Tab_Trama_Cv1 IS TABLE OF Rec_Trama_Cv1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Cv IS RECORD(
     Convenio                    NUMBER
    ,Plan                        NUMBER
    ,Codigo_Autorizacion         VARCHAR2(20)
    ,Identi_Titular              VARCHAR2(30)
    ,Rut_Titular                 NUMBER
    ,Dv_Titular                  VARCHAR2(1)
    ,Party_Id                    NUMBER
    ,Party_Id_c                  VARCHAR2(30)
    ,Identificacion_Comprador    VARCHAR2(30)
    ,Codigo_Autorizacion_Externo VARCHAR2(20)
    ,Lista_Diagnosticos          NUMBER
    ,Subtrama_Cv1                Tab_Trama_Cv1);

  TYPE Tab_Trama_Cv IS TABLE OF Rec_Trama_Cv INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Cz IS RECORD(
     Uso_Frecuente      NUMBER
    ,Rut_Medico         NUMBER
    ,Dv_Rut_Medico      VARCHAR2(1)
    ,Folio              NUMBER
    ,Rut_Vendedor       NUMBER
    ,Dv_Rut_Vendedor    VARCHAR2(1)
    ,Numero_Inscripcion NUMBER
    ,Fecha_Expiracion   NUMBER);

  TYPE Rec_Trama_Db IS RECORD(
     Identi_Beneficiario VARCHAR2(30)
    ,Rut_Beneficiario    NUMBER
    ,Dv_Rut_Beneficiario VARCHAR2(1000)
    ,Party_Id            NUMBER
    ,Party_Id_c          VARCHAR2(30)
    ,Secuencia_b         NUMBER
    ,Apellido_Paterno    VARCHAR2(1000)
    ,Apellido_Materno    VARCHAR2(1000)
    ,Nombre              VARCHAR2(1000));

  TYPE Tab_Trama_Db IS TABLE OF Rec_Trama_Db INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Dc IS RECORD(
     Rut_Facturacion              NUMBER
    ,Dv_Rut_Facturacion           VARCHAR2(1000)
    ,Party_Id                     NUMBER
    ,Razon_Social                 VARCHAR2(1000)
    ,Nombre_Fantasia              VARCHAR2(1000)
    ,Giro                         VARCHAR2(1000)
    ,Direccion_Facturacion        VARCHAR2(1000)
    ,Comuna_Facturacion           NUMBER
    ,Ciudad_Facturacion           NUMBER
    ,Direccion_Envio_Correo       VARCHAR2(1000)
    ,Comuna_Envio_Correspondencia NUMBER
    ,Ciudad_Envio_Correspondencia NUMBER
    ,Telefono                     NUMBER
    ,Fax                          NUMBER
    ,Numero_Rfc                   VARCHAR2(15)
    ,Domicilio_Fiscal             NUMBER(10)
    ,Regimen_Fiscal               NUMBER(10)
    ,Uso_Cfdi                     VARCHAR2(3)
    ,Email                        VARCHAR2(1000));

  TYPE Rec_Trama_De IS RECORD(
     Campana      NUMBER
    ,Dato_Campana VARCHAR2(3)
    ,Valor        VARCHAR2(20));

  TYPE Rec_Trama_Dh IS RECORD(
     Correlativo_Tx NUMBER
    ,Ot             VARCHAR2(14)
    ,LOCAL          NUMBER);

  TYPE Rec_Trama_Dj1 IS RECORD(
     Producto        NUMBER
    ,Cantidad        NUMBER
    ,Motivo          VARCHAR2(6)
    ,Precio_Final    NUMBER(15, 4)
    ,Decimal_Pfinal  VARCHAR2(4)
    ,Costo           NUMBER(15, 4)
    ,Decimal_Costo   VARCHAR2(4)
    ,Codigo_Personal NUMBER
    ,Identi_Vendedor VARCHAR2(30)
    ,Rut_Vendedor    NUMBER
    ,Dv_Rut_Vendedor VARCHAR2(1)
    ,Precio_Lista    NUMBER
    ,Decimal_Plista  VARCHAR2(4));

  TYPE Tab_Trama_Dj1 IS TABLE OF Rec_Trama_Dj1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Dj IS RECORD(
     Tipo_Movimiento_Padre   VARCHAR2(6)
    ,Tipo_Movimiento_Hijo    VARCHAR2(6)
    ,Folio                   VARCHAR2(20)
    ,Guia_Despacho           VARCHAR2(30)
    ,Tipo_Guia_Despacho      VARCHAR2(1)
    ,Accion_Sobre_Existencia VARCHAR2(1)
    ,Numero_Folio_Original   VARCHAR2(20)
    ,Fecha_Folio_Original    NUMBER
    ,Codigo_Local_Socofar    NUMBER
    ,Numero_Reclamo          NUMBER
    ,Fecha_Reclamo           NUMBER
    ,Dfi_Numero_Asignacion   NUMBER
    ,Matricula_Bulto         NUMBER
    ,Monto                   NUMBER(15, 4)
    ,Decimal_Monto           VARCHAR2(4)
    ,Identi_Proveedor        VARCHAR2(30)
    ,Rut_Proveedor           NUMBER
    ,Sucursal_Proveedor      NUMBER
    ,Sello_Seguro_Uno        NUMBER
    ,Sello_Seguro_Dos        NUMBER
    ,Cantidad_Productos      NUMBER
    ,Subtrama_Dj1            Tab_Trama_Dj1);

  TYPE Rec_Trama_Dl1 IS RECORD(
     Producto        NUMBER
    ,Cantidad        NUMBER
    ,Motivo          VARCHAR2(6)
    ,Precio_Final    NUMBER(15, 4)
    ,Decimal_Pfinal  VARCHAR2(4)
    ,Costo           NUMBER(15, 4)
    ,Decimal_Costo   VARCHAR2(4)
    ,Codigo_Personal NUMBER
    ,Identi_Vendedor VARCHAR2(30)
    ,Rut_Vendedor    NUMBER
    ,Dv_Rut_Vendedor VARCHAR2(1)
    ,Precio_Lista    NUMBER(15, 4)
    ,Decimal_Plista  VARCHAR2(4)
    ,Numero_Item     NUMBER); -- IDHC origen NLG

  TYPE Tab_Trama_Dl1 IS TABLE OF Rec_Trama_Dl1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Dl IS RECORD(
     Tipo_Movimiento_Padre   VARCHAR2(6)
    ,Tipo_Movimiento_Hijo    VARCHAR2(6)
    ,Folio                   VARCHAR2(20)
    ,Numero_Pedido           VARCHAR2(30)
    ,Guia_Electronica        VARCHAR2(30)
    ,Guia_Despacho           VARCHAR2(30)
    ,Tipo_Guia_Despacho      VARCHAR2(1)
    ,Accion_Sobre_Existencia VARCHAR2(1)
    ,Numero_Folio_Original   VARCHAR2(20)
    ,Fecha_Folio_Original    NUMBER
    ,Codigo_Local_Socofar    NUMBER
    ,Numero_Reclamo          NUMBER
    ,Fecha_Reclamo           NUMBER
    ,Dfi_Numero_Asignacion   NUMBER
    ,Matricula_Bulto         NUMBER
    ,Monto                   NUMBER(15, 4)
    ,Decimal_Monto           VARCHAR2(4)
    ,Identi_Proveedor        VARCHAR2(30)
    ,Rut_Proveedor           NUMBER
    ,Sucursal_Proveedor      NUMBER
    ,Sello_Seguro_Uno        NUMBER
    ,Sello_Seguro_Dos        NUMBER
    ,Registro_Electronico    VARCHAR2(2)
    ,FOLIO_INGRESO           NUMBER --JAGC 20250414 ORIGEN FGI
    ,Cantidad_Productos      NUMBER
    ,Subtrama_Dl1            Tab_Trama_Dl1);

  TYPE Rec_Trama_Dp1 IS RECORD(
     Atributo VARCHAR2(3));

  TYPE Tab_Trama_Dp1 IS TABLE OF Rec_Trama_Dp1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Dp2 IS RECORD(
     Id                  NUMBER
    ,Id_Grupo            NUMBER
    ,Nombre_Grupo        VARCHAR2(100)
    ,Valor_Grupo         VARCHAR2(100)
    ,Fecha_Creacion      VARCHAR2(100)
    ,Fecha_Actualizacion VARCHAR2(100)
    ,Habilitado          VARCHAR2(20)
    ,Eliminado           VARCHAR2(20));

  TYPE Tab_Trama_Dp2 IS TABLE OF Rec_Trama_Dp2 INDEX BY BINARY_INTEGER;

  --//--------------------------------------------------------------------------\\
  --// CBR 01/22/2018 5:04PM                                                    \\
  --//                                                                          \\
  --//-----------------------------------------------------------------Inicio---\\
  -- SubTrama Programas
  TYPE Rec_Trama_Dp3 IS RECORD(
     Id_Pro                  NUMBER(15)
    ,Nombre_Pro              VARCHAR2(100)
    ,Descripcion_Pro         VARCHAR2(100)
    ,Fecha_Creacion          VARCHAR2(100)
    ,Fecha_Actualizacion     VARCHAR2(100)
    ,Habilitado              VARCHAR2(20)
    ,Eliminado               VARCHAR2(20)
    ,Sistema                 VARCHAR2(20)
    ,Id_Currency             NUMBER(15)
    ,Nombre_Currency         VARCHAR2(100)
    ,Nombre_Corto_Currency   VARCHAR2(50)
    ,Descripcion_Currency    VARCHAR2(100)
    ,Fecha_Creacion_Currency VARCHAR2(100)
    ,Eliminado_Currency      VARCHAR2(20)
    ,Estado_Currency         VARCHAR2(20));

  TYPE Tab_Trama_Dp3 IS TABLE OF Rec_Trama_Dp3 INDEX BY BINARY_INTEGER;
  --//-----------------------------------------------------------------Termino--\\

  TYPE Rec_Trama_Dp IS RECORD(
     Rut                      NUMBER(10)
    ,Dv_Rut                   VARCHAR2(1)
    ,Apellido_Paterno         VARCHAR2(1000)
    ,Apellido_Materno         VARCHAR2(1000)
    ,Nombres                  VARCHAR2(1000)
    ,Segundo_Nombre           VARCHAR2(1000)
    ,Sexo                     VARCHAR2(1000)
    ,Fecha_Nacimiento         NUMBER
    ,Direccion                VARCHAR2(1000)
    ,Comuna                   NUMBER
    ,Ciudad                   NUMBER
    ,Telefono_Particular      NUMBER
    ,Telefono_Celular         NUMBER
    ,Telefono_Particularc     VARCHAR2(50)
    ,Telefono_Celularc        VARCHAR2(50)
    ,Inscrito_Mas_Cruz_Verde  VARCHAR2(1000)
    ,Folio_Tarjeta_Mcv        VARCHAR2(1000)
    ,Email                    VARCHAR2(1000)
    ,Fecha_Hora_Actualizacion NUMBER
    ,Tipo_Creacion            VARCHAR2(1000)
    ,Fecha_Hora_Ultima_Venta  NUMBER
    ,Local_Ultima_Venta       NUMBER
    ,Codigo_Pais              NUMBER
    ,Codigo_Region            NUMBER
    ,Institucion_Salud        VARCHAR2(5)
    ,Monto_Acumulado_Club     NUMBER(15, 4)
    ,Decimal_Acum_Club        VARCHAR2(4)
    
    --INI JAGC 20240909 NECESIDADES 'NEC'
    ,Estado_Civil             VARCHAR2(3)      
    ,Nro_Depto_Casa           VARCHAR2(10)      
    ,Medios_Notificacion      VARCHAR2(30)
    ,Estado                   VARCHAR2(10)
    ,Fecha_Inscripcion        NUMBER
    ,Canal                    VARCHAR2(3)
    ,Nombre_Vendedor          VARCHAR2(1000)--VARCHAR2(30) --JAGC 20250818
    --FIN JAGC 20240909 NECESIDADES 'NEC'
    
    ,Lista_Atributos          NUMBER
    ,Lista_Grupos             NUMBER
    --,Lista_Programas          NUMBER
    ,Subtrama_Dp1 Tab_Trama_Dp1
    ,Subtrama_Dp2 Tab_Trama_Dp2
    --,Subtrama_Dp3             Tab_Trama_Dp3
    );

  /*
    TYPE Rec_Trama_Dp9 IS RECORD(
       Apellido_Paterno         VARCHAR2(1000)
      ,Apellido_Materno         VARCHAR2(1000)
      ,Nombres                  VARCHAR2(1000)
      ,Sexo                     VARCHAR2(1000)
      ,Fecha_Nacimiento         NUMBER
      ,Direccion                VARCHAR2(1000)
      ,Comuna                   NUMBER
      ,Ciudad                   NUMBER
      ,Telefono_Particular      NUMBER
      ,Telefono_Celular         NUMBER
      ,Inscrito_Mas_Cruz_Verde  VARCHAR2(1000)
      ,Folio_Tarjeta_Mcv        VARCHAR2(1000)
      ,Email                    VARCHAR2(1000)
      ,Fecha_Hora_Actualizacion NUMBER
      ,Tipo_Creacion            VARCHAR2(1000)
      ,Fecha_Hora_Ultima_Venta  NUMBER
      ,Local_Ultima_Venta       NUMBER);
  */

  TYPE Rec_Trama_Dpu IS RECORD(
     Rut_Beneficiario    NUMBER
    ,Dv_Rut_Beneficiario VARCHAR2(1)
    ,Fecha_Inicio        NUMBER
    ,Fecha_Termino       NUMBER);

  TYPE Rec_Trama_Dr1 IS RECORD(
     Secuencia_b              NUMBER
    ,Tipo_Movimiento_Hijo     VARCHAR2(6)
    ,Institucion              VARCHAR2(50)
    ,Ruc_Institucion          VARCHAR2(13)
    ,Numero_Asignacion        NUMBER
    ,Anulado                  VARCHAR2(1)
    ,Folio                    VARCHAR2(15)
    ,Tipo_Dicc                VARCHAR2(3)
    ,Folio_Dicc               NUMBER
    ,Total_Iva_Incluido       NUMBER(15, 4)
    ,Decimal_Total            VARCHAR2(4)
    ,Iva                      NUMBER(15, 4)
    ,Decimal_Iva              VARCHAR2(4)
    ,Signo                    VARCHAR2(1)
    ,Puntos_Asignados         VARCHAR2(1)
    ,Tipo_Distribucion        VARCHAR2(3)
    ,Campana                  NUMBER
    ,Secuencia_Financiamiento NUMBER
    ,Documento_Fiscal         VARCHAR2(2));

  TYPE Tab_Trama_Dr1 IS TABLE OF Rec_Trama_Dr1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Dr IS RECORD(
     Correlativo_Tx                NUMBER
    ,Tipo_Movimiento_Padre         VARCHAR2(6)
    ,Fecha                         NUMBER
    ,Hora_Recaudacion              NUMBER
    ,Secuencia_b                   NUMBER
    ,Numero_Cuenta                 VARCHAR2(19)
    ,Codigo_Autorizacion           VARCHAR2(20)
    ,Ot                            VARCHAR2(14)
    ,Venta_Relacionada             NUMBER
    ,Local_Relacionado             NUMBER
    ,Codigo_Servicio               VARCHAR2(3)
    ,LOCAL                         NUMBER
    ,Numero_Pos                    NUMBER
    ,Destino                       VARCHAR2(3)
    ,Sistema                       VARCHAR2(3)
    ,Funcion                       VARCHAR2(1)
    ,Secuencia_c                   VARCHAR2(2)
    ,Fecha_Transaccion             NUMBER
    ,Correlativo                   NUMBER
    ,Numero_Trama                  NUMBER
    ,Codigo_Transaccion            VARCHAR2(6)
    ,Cuadra_Transaccion            VARCHAR2(2)
    ,Documento_Liquidacion_Pago    VARCHAR2(3)
    ,Documento_Liquidacion_Empresa VARCHAR2(3)
    ,Codigo_Autorizacion_Externo   VARCHAR2(20)
    ,Transaccion_Manual            VARCHAR2(2)
    ,Id_Empresa                    NUMBER
    ,Fecha_Inicio_Tx               NUMBER
    ,Fecha_Cierre_Tx               NUMBER
    ,Numero_Tx_Comercio            NUMBER
    ,Registro_Recepcion_1          VARCHAR2(100)
    ,Documentos_Emitidos           NUMBER
    ,Subtrama_Dr1                  Tab_Trama_Dr1);

  TYPE Rec_Trama_Ds1 IS RECORD(
     Guia_Electronica NUMBER
    ,Producto         NUMBER
    ,Cantidad         NUMBER);

  TYPE Tab_Trama_Ds1 IS TABLE OF Rec_Trama_Ds1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Ds IS RECORD(
     Tipo_Movimiento_Padre   VARCHAR2(6)
    ,Tipo_Movimiento_Hijo    VARCHAR2(6)
    ,Folio                   NUMBER
    ,Numero_Pedido           NUMBER
    ,Guia_Despacho           NUMBER
    ,Tipo_Guia_Despacho      VARCHAR2(1)
    ,Accion_Sobre_Existencia VARCHAR2(1)
    ,Cantidad_Productos      NUMBER
    ,Subtrama_Ds1            Tab_Trama_Ds1);

  TYPE Rec_Trama_Dv1 IS RECORD(
     Secuencia_b              NUMBER
    ,Tipo_Movimiento_Hijo     VARCHAR2(6)
    ,Numero_Asignacion        NUMBER
    ,Anulado                  VARCHAR2(1)
    ,Folio                    VARCHAR2(15)
    ,Tipo_Dicc                VARCHAR2(3)
    ,Folio_Dicc               NUMBER
    ,Total_Iva_Incluido       NUMBER(15, 4)
    ,Decimal_Total            VARCHAR2(4)
    ,Iva                      NUMBER(15, 4)
    ,Decimal_Iva              VARCHAR2(4)
    ,Puntos_Asignados         VARCHAR2(1)
    ,Tipo_Distribucion        VARCHAR2(3)
    ,Campana                  NUMBER
    ,Secuencia_Financiamiento NUMBER
    ,Documento_Fiscal         VARCHAR2(2)
    ,Afecto                   NUMBER(15, 4)
    ,Decimal_Afecto           VARCHAR2(4)
    ,Exento                   NUMBER(15, 4)
    ,Decimal_Exento           VARCHAR2(4)
    ,Periodo_Facturacion      NUMBER
    ,Tipo_Guia_Emitida        VARCHAR2(3)); --  JRG CIA 04/06/219

  TYPE Tab_Trama_Dv1 IS TABLE OF Rec_Trama_Dv1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Dv2 IS RECORD(
     Correlativo_Tx NUMBER
    ,Motivo         VARCHAR2(3));

  TYPE Tab_Trama_Dv2 IS TABLE OF Rec_Trama_Dv2 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Dv IS RECORD(
     Correlativo_Tx                NUMBER
    ,Tipo_Tx                       VARCHAR2(3)
    ,Tipo_Movimiento_Padre         VARCHAR2(6)
    ,Fecha                         NUMBER
    ,Hora_Venta                    NUMBER
    ,Numero_Cotizacion             NUMBER
    ,Pin_Transaccion               VARCHAR2(10)
    ,Numero_Preventa               NUMBER
    ,Correlativo_Tx_Asociado       NUMBER
    ,LOCAL                         NUMBER
    ,Codigo_Agente_Desp_Domicilio  NUMBER
    ,Identi_Agente_Despacho        VARCHAR2(30)
    ,Rut_Agente_Despacho_Domicilio NUMBER
    ,Dv_Rut_Agente_Desp_Domicilio  VARCHAR2(1)
    ,Numero_Service_Request_Ddo    NUMBER
    ,Ot                            VARCHAR2(15) -- Cambio 20230915 LMP estaba en 14
    ,Recaudacion_Relacionada       NUMBER
    ,Cuadra_Transaccion            VARCHAR2(2)
    ,Documento_Liquidacion_Pago    VARCHAR2(3)
    ,Documento_Liquidacion_Empresa VARCHAR2(3)
    ,Codigo_Autorizacion_Externo   VARCHAR2(20)
    ,Identi_Empresa                VARCHAR2(30)
    ,Rut_Empresa                   NUMBER
    ,Transaccion_Manual            VARCHAR2(2)
    ,Movimiento_Enlinea            VARCHAR2(2)
    ,Identi_Supervisor             VARCHAR2(30)
    ,Supervisor                    NUMBER
    ,Rut_Supervisor                NUMBER
    ,Tipo_Deducible                VARCHAR2(3)
    ,Monto_Deducible               NUMBER(15, 4)
    ,Decimal_Monto_Deducible       VARCHAR2(4)
    ,Valor_Moneda                  NUMBER
    ,Tipo_Moneda                   VARCHAR2(3)
    ,Numero_Liquidacion            NUMBER
    ,Indicadores_Tx                VARCHAR2(50)
    ,Documento_Electronico         VARCHAR2(2)
    ,Fecha_Inicio_Tx               NUMBER
    ,Fecha_Cierre_Tx               NUMBER
    ,Factura_Turista               NUMBER
    ,Tipo_Documento_Id             NUMBER
    ,Numero_Documento_Id           VARCHAR2(20)
    ,Clave_Acceso                  VARCHAR2(50)
    ,Numero_Comprobante            NUMBER
    ,Tipo_Facturacion              VARCHAR2(1)
    ,Cliente_Factura               VARCHAR2(30)
    ,Nombre_Cliente_Factura        VARCHAR2(120)
    ,Direccion_Cliente_Factura     VARCHAR2(120)
    ,Correo_Electronico            VARCHAR2(60)
    ,Serie_Sri                     NUMBER
    ,Numero_Resolucion             VARCHAR2(15)
    ,Agente_Retencion              VARCHAR2(50)
    ,Microempresa                  VARCHAR2(50)
    ,Motivo                        VARCHAR2(280)
    ,Id_Supervisor_Externo         NUMBER
    ,Canal_Transaccion             VARCHAR2(2)
    ,Tiene_Donacion                 VARCHAR2(1)--INI JAGC 20240909 NECESIDADES 'NEC' 
    ,Url_Factura         VARCHAR2(255) --FCG 21082023  origen OMS
    ,Url_Xml             VARCHAR2(255) --FCG 21082023  origen OMS
    ,Tax_Payer           VARCHAR2(255) --JAGC 20240529 origen CON
    
    --INI JAGC 20240909 NECESIDADES 'NEC'  
    ,Folio_venta_Anulada            VARCHAR2(15)--NUMBER
    ,Canal                          VARCHAR2(3)
    --FIN JAGC 20240909 NECESIDADES 'NEC'
    
    ,Documentos_Emitidos NUMBER
    ,Tx_Relacionadas     NUMBER    
    ,Subtrama_Dv1        Tab_Trama_Dv1
    ,Subtrama_Dv2        Tab_Trama_Dv2);

  TYPE Rec_Trama_Dvr IS RECORD(
     Tipo_Movimiento_Hijo VARCHAR2(6)
    ,Folio                NUMBER);

  TYPE Rec_Trama_Ea IS RECORD(
     Numero_Reclamo NUMBER
    ,Fecha_Reclamo  NUMBER);

  TYPE Rec_Trama_Eb IS RECORD(
     Codigo_Respuesta NUMBER
    ,Glosa_Respuesta  VARCHAR2(80));

  TYPE Rec_Trama_Ec1 IS RECORD(
     Guia_Electronica     VARCHAR2(30)
    ,Producto             NUMBER
    ,Cantidad             NUMBER(15, 4)
    ,Decimal_Cantidad     VARCHAR2(4)
    ,Motivo               VARCHAR2(6)
    ,Costo                NUMBER(15, 4)
    ,Decimal_Costo        VARCHAR2(4)
    ,Codigo_Personal      NUMBER
    ,Ident_Vendedor       VARCHAR2(30)
    ,Rut_Vendedor         NUMBER
    ,Dv_Rut_Vendedor      VARCHAR2(1)
    ,Precio_Lista         NUMBER(15, 4)
    ,Decimal_Precio_Lista VARCHAR2(4));

  TYPE Tab_Trama_Ec1 IS TABLE OF Rec_Trama_Ec1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Ec IS RECORD(
     Tipo_Movimiento_Padre   VARCHAR2(6)
    ,Tipo_Movimiento_Hijo    VARCHAR2(6)
    ,Folio                   VARCHAR2(20)
    ,Numero_Pedido           VARCHAR2(30)
    ,Codigo_Local_Socofar    NUMBER
    ,Numero_Reclamo          NUMBER
    ,Fecha_Reclamo           NUMBER
    ,Accion_Sobre_Existencia VARCHAR2(1)
    ,Numero_Folio_Original   NUMBER
    ,Fecha_Folio_Original    NUMBER
    ,Monto                   NUMBER(15, 4)
    ,Decimal_Monto           VARCHAR2(4)
    ,Ident_Proveedor         VARCHAR2(30)
    ,Rut_Proveedor           NUMBER
    ,Sucursal_Proveedor      NUMBER
    ,Cantidad_Productos      NUMBER
    ,Subtrama_Ec1            Tab_Trama_Ec1);

  TYPE Rec_Trama_Ed1 IS RECORD(
     Guia_Electronica NUMBER
    ,Producto         NUMBER
    ,Cantidad         NUMBER
    ,Motivo           VARCHAR2(6));

  TYPE Tab_Trama_Ed1 IS TABLE OF Rec_Trama_Ed1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Ed IS RECORD(
     Tipo_Movimiento_Padre   VARCHAR2(6)
    ,Tipo_Movimiento_Hijo    VARCHAR2(6)
    ,Folio                   NUMBER
    ,Numero_Pedido           NUMBER
    ,Codigo_Local_Socofar    NUMBER
    ,Numero_Reclamo          NUMBER
    ,Fecha_Reclamo           NUMBER
    ,Accion_Sobre_Existencia VARCHAR2(1)
    ,Numero_Folio_Original   NUMBER
    ,Fecha_Folio_Original    NUMBER
    ,Cantidad_Productos      NUMBER
    ,Subtrama_Ed1            Tab_Trama_Ed1);

  TYPE Rec_Trama_Ep IS RECORD(
     Orden_Pedido           NUMBER
    ,Estado_Service_Request VARCHAR2(3)
    ,Estado_Pos             VARCHAR2(3)
    ,Fecha_Inicio           NUMBER
    ,Fecha_Termino          NUMBER);

  TYPE Rec_Trama_Er IS RECORD(
     LOCAL                    NUMBER
    ,Orden_Pedido             NUMBER
    ,Fecha_Hora_Envio         NUMBER
    ,Fecha_Hora_Actualizacion NUMBER
    ,Estado_Service_Request   VARCHAR2(3)
    ,Estado_Pos               VARCHAR2(3));

  TYPE Rec_Trama_Fe IS RECORD(
     Uso_Frecuente NUMBER);

  TYPE Rec_Trama_Fm IS RECORD(
     Codigo_Movimiento VARCHAR2(6)
    ,Fecha_Transaccion NUMBER
    ,Movimiento_Padre  VARCHAR2(6)
    ,Codigo_Item       NUMBER);

  TYPE Tab_Trama_Fm IS TABLE OF Rec_Trama_Fm INDEX BY BINARY_INTEGER;

  --//--------------------------------------------------------------------------\\
  --// CBR 05/13/2019 5:22PM                                                    \\
  --// TURNOMATICO                                                              \\
  --//-----------------------------------------------------------------Inicio---\\
  TYPE Rec_Trama_Na1 IS RECORD(
     Inicio_Atencion        NUMBER
    ,Secuencia_Atencion     NUMBER
    ,Rut_Cliente            NUMBER
    ,Opcion_Atencion        VARCHAR2(30)
    ,Id_Transaccion         NUMBER
    ,Fin_Atencion           NUMBER
    ,Inicio_Consulta_Perfil NUMBER);

  TYPE Tab_Trama_Na1 IS TABLE OF Rec_Trama_Na1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Na IS RECORD(
     Tipo_Llamado        NUMBER
    ,Llamado             NUMBER
    ,Numero_De_Turno     VARCHAR2(10)
    ,Rut_Atencion        NUMBER
    ,Tiempo_Espera       VARCHAR2(10)
    ,Inicio_Servicio     NUMBER
    ,LOCAL               NUMBER
    ,Caja                NUMBER
    ,Codigo_Vendedor     NUMBER
    ,Autorizacion        NUMBER
    ,Fin_Servicio        NUMBER
    ,Cantidad_Atenciones NUMBER
    ,Subtrama_Na1        Tab_Trama_Na1);
  --//-----------------------------------------------------------------Termino--\\

  --//--------------------------------------------------------------------------\\
  --// CBR 13/09/2019 11:55                                                     \\
  --// GNCU13 PICKIN Y PACKING                                                  \\
  --//-----------------------------------------------------------------Inicio---\\
  TYPE Rec_Trama_Sk1 IS RECORD(
     Pro_Codigo_Interno NUMBER
    ,Pro_Vendidos       NUMBER
    ,Pro_Picking        NUMBER
    ,Pro_Packing        NUMBER
    ,Rut_Vendedor       NUMBER);

  TYPE Tab_Trama_Sk1 IS TABLE OF Rec_Trama_Sk1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Sk IS RECORD(
     Correlativo_Tx     NUMBER
    ,Cantidad_Productos NUMBER
    ,Subtrama_Sk1       Tab_Trama_Sk1);
  --//-----------------------------------------------------------------Termino--\\

  TYPE Rec_Trama_Fp1 IS RECORD(
     Correlativo_Tx NUMBER
    ,Tipo_Tx        VARCHAR2(6));

  TYPE Tab_Trama_Fp1 IS TABLE OF Rec_Trama_Fp1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Fp IS RECORD(
     Codigo_Personal     NUMBER
    ,Identi_Cajero       VARCHAR2(30)
    ,Rut                 NUMBER
    ,Dv                  VARCHAR2(1)
    ,Id_Maquina          NUMBER
    ,Identi_Titular      VARCHAR2(30)
    ,Rut_Titular         NUMBER
    ,Dv_Titular          VARCHAR2(1)
    ,Forma_Pago          VARCHAR2(6)
    ,Medio_Pago          VARCHAR2(3)
    ,Codigo_Autorizacion VARCHAR2(20)
    ,Numero_Documento    VARCHAR2(20)
    ,Numero_Cuenta       VARCHAR2(30)
    ,Banco               NUMBER
    ,Fecha_Vencimiento   NUMBER
    ,Monto_Documento     NUMBER(15, 4)
    ,Decimal_Mdocumento  VARCHAR2(4)
    ,Monto_Forma_Pago    NUMBER(15, 4)
    ,Decimal_Fpago       VARCHAR2(4)
    ,Movimiento_Caja     VARCHAR2(1)
    ,Tipo_Autorizacion   VARCHAR2(3)
    ,Cantidad_Cuotas     NUMBER
    --  ,Decimal_CCuotas       VARCHAR2(4)
    ,Interes                  NUMBER(15, 4)
    ,Decimal_Interes          VARCHAR2(4)
    ,Banda_Magnetica          BLOB
    ,Codigo_Servicio          VARCHAR2(3)
    ,LOCAL                    NUMBER
    ,Numero_Pos               NUMBER
    ,Destino                  VARCHAR2(3)
    ,Sistema                  VARCHAR2(3)
    ,Funcion                  VARCHAR2(1)
    ,Secuencia_c              VARCHAR2(2)
    ,Fecha_Transaccion        NUMBER
    ,Correlativo              NUMBER
    ,Numero_Trama             NUMBER
    ,Codigo_Transaccion       VARCHAR2(6)
    ,Secuencia_Pago           NUMBER
    ,Meses_Diferido           NUMBER
    ,Tipo_Cuotas              NUMBER
    ,Numero_Tx_Comercio       NUMBER
    ,Id_Transaccion           VARCHAR2(26)
    ,Valor_Cuota              NUMBER(15, 4)
    ,Decimal_Vcuota           VARCHAR2(4)
    ,Modo_Ingreso_Tarjeta     VARCHAR2(3)
    ,Flujo_Caja               VARCHAR2(2)
    ,Cliente_Tarjeta          VARCHAR2(100)
    ,Telefono_Cliente         VARCHAR2(15)
    ,Celular_Cliente          VARCHAR2(15)
    ,Direccion_Cliente        VARCHAR2(100)
    ,Genero                   VARCHAR2(3)
    ,Nacimiento               VARCHAR2(4)
    ,Importe_Pago             NUMBER(15, 4)
    ,Decimal_Importe_Pago     VARCHAR2(4)
    ,Importe_Cambio           NUMBER(15, 4)
    ,Decimal_Importe_Cambio   VARCHAR2(4)
    ,Importe_Pago_Usd         NUMBER(15, 4)
    ,Decimal_Importe_Pago_Usd VARCHAR2(4)
    ,Tipo_Cambio              NUMBER(15, 4)
    ,Decimal_Tipo_Cambio      VARCHAR2(4)
    ,Autorizacion_Online      VARCHAR2(30)
    ,Documentos_a_Cancelar    NUMBER
    ,Subtrama_Fp1             Tab_Trama_Fp1);

  TYPE Tab_Trama_Fp IS TABLE OF Rec_Trama_Fp INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Fs IS RECORD(
     Producto NUMBER);

  TYPE Rec_Trama_Gf1 IS RECORD(
     Guia_Electronica     VARCHAR2(30)
    ,Producto             NUMBER
    ,Cantidad             NUMBER(15, 4)
    ,Decimal_Cantidad     VARCHAR2(4)
    ,Tipo_Falta_Producto  VARCHAR2(1)
    ,Motivo               VARCHAR2(6)
    ,Guia_Facturable      VARCHAR2(2)
    ,Costo                NUMBER(15, 4)
    ,Decimal_Costo        VARCHAR2(4)
    ,Codigo_Personal      NUMBER
    ,Ident_Vendedor       VARCHAR2(30)
    ,Rut_Vendedor         NUMBER
    ,Dv_Rut_Vendedor      VARCHAR2(1)
    ,Precio_Lista         NUMBER(15, 4)
    ,Decimal_Precio_Lista VARCHAR2(4)
    ,Numero_Item          NUMBER);  -- IDHC origen NLG

  TYPE Tab_Trama_Gf1 IS TABLE OF Rec_Trama_Gf1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Gf IS RECORD(
     Tipo_Movimiento_Padre   VARCHAR2(6)
    ,Tipo_Movimiento_Hijo    VARCHAR2(6)
    ,Folio                   VARCHAR2(30)
    ,Numero_Pedido           VARCHAR2(30)
    ,Fecha                   NUMBER
    ,Codigo_Local_Socofar    NUMBER
    ,Numero_Reclamo          NUMBER
    ,Fecha_Reclamo           NUMBER
    ,Accion_Sobre_Existencia VARCHAR2(1)
    ,Numero_Folio_Original   VARCHAR2(20)
    ,Fecha_Folio_Original    NUMBER
    ,Monto                   NUMBER(15, 4)
    ,Decimal_Monto           VARCHAR2(4)
    ,Ident_Proveedor         VARCHAR2(30)
    ,Rut_Proveedor           NUMBER
    ,Sucursal_Proveedor      NUMBER
    ,Numero_Factura          VARCHAR2(30) --JRC 30/08/2023 Unificando EXCU17 desde Yza a Ecuador
    ,Cantidad_Productos      NUMBER
    ,FOLIO_INGRESO           NUMBER --JAGC 20250414 ORIGEN FGI
    ,Subtrama_Gf1            Tab_Trama_Gf1);

  TYPE Rec_Trama_Gs1 IS RECORD(
     Folio         NUMBER
    ,Producto      NUMBER
    ,Uso_Frecuente NUMBER
    ,Cantidad      NUMBER);

  TYPE Tab_Trama_Gs1 IS TABLE OF Rec_Trama_Gs1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Gs IS RECORD(
     Correlativo_Tx     NUMBER
    ,Cantidad_Productos NUMBER
    ,Subtrama_Gs1       Tab_Trama_Gs1);

  TYPE Rec_Trama_Gu IS RECORD(
     Numero_Guia VARCHAR2(30));

  TYPE Rec_Trama_Hbo IS RECORD(
     Forma_Identificacion  VARCHAR2(1)
    ,String_Identificacion VARCHAR2(150)
    ,Party_Id              NUMBER
    ,Codigo_Respuesta      NUMBER
    ,Largo_Total_Buffer    NUMBER);

  TYPE Rec_Trama_Hc IS RECORD(
     Codigo_Producto_Interno NUMBER
    ,Fecha                   NUMBER
    ,Cantidad                NUMBER(15, 4)
    ,Decimal_Cantidad        VARCHAR2(4)
    ,Numero_Consejo          NUMBER
    ,Id_Grupo                NUMBER
    ,Saldo_Grupo             NUMBER
    ,Nombre_Grupo            VARCHAR2(60));

  TYPE Tab_Trama_Hc IS TABLE OF Rec_Trama_Hc INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Hpo IS RECORD(
     Version_Primaria     NUMBER
    ,Version_Secundaria   NUMBER
    ,Encriptado           VARCHAR2(1)
    ,Largo_Tx_Encriptada  NUMBER
    ,Certificado          NUMBER
    ,Empresa              NUMBER
    ,Cadena               NUMBER
    ,LOCAL                NUMBER
    ,Numero_Pos           NUMBER
    ,Id_Maquina           NUMBER
    ,Usuario_Responsable  VARCHAR2(10)
    ,Destino              VARCHAR2(3)
    ,Tipo_Transmision     VARCHAR2(1)
    ,Sistema              VARCHAR2(3)
    ,Funcion              VARCHAR2(1)
    ,Secuencia_c          VARCHAR2(2)
    ,Fecha_Hora_Contable  NUMBER
    ,Fecha_Hora_Proceso   NUMBER
    ,Fecha_Hora_Tx        NUMBER
    ,Fecha_Hora_Rx        NUMBER
    ,Correlativo          NUMBER
    ,Codigo_Respuesta     NUMBER
    ,Tipo_Requerimiento   VARCHAR2(1)
    ,Identificador_Global VARCHAR2(16)
    ,Empresa_Destino      NUMBER
    ,Cadena_Destino       NUMBER
    ,Local_Destino        NUMBER
    ,Prioridad            NUMBER
    ,Ttl                  NUMBER
    ,Resolver_Localmente  VARCHAR2(1)
    ,Cliente_Destino      VARCHAR2(20)
    ,Plataforma           VARCHAR2(1)
    ,Procesar_Central     VARCHAR2(1)
    ,Reservados           VARCHAR2(4)
    ,Origen_Transaccion   VARCHAR2(3)
    ,Tramas_Fragmentadas  VARCHAR2(1)
    ,Headers_Presente     NUMBER
    ,Numero_Trama         NUMBER
    ,Cantidad_Tramas      NUMBER
    ,Largo_Total_Buffer   NUMBER);

  TYPE Rec_Trama_Htx IS RECORD(
     Tipo_Informacion   VARCHAR2(2)
    ,Modo_Largo_Campos  VARCHAR2(1)
    ,Largo_Buffer_Datos NUMBER
    ,Cantidad_Registros NUMBER);

  TYPE Rec_Trama_Lc IS RECORD(
     Convenio            NUMBER
    ,Plan                NUMBER
    ,Secuencia_b         NUMBER
    ,Codigo_Autorizacion VARCHAR2(20));

  TYPE Rec_Trama_Lf IS RECORD(
     Codigo_Autorizacion         VARCHAR2(20)
    ,Codigo_Autorizacion_Externo VARCHAR2(20)
    ,Tipo_Reversa                VARCHAR2(3)
    ,Monto_Reversa               NUMBER);

  TYPE Rec_Trama_Lo IS RECORD(
     Fecha_Inicio            NUMBER
    ,Hora_Inicio             NUMBER
    ,Version_Primaria_Adlc   VARCHAR2(15)
    ,Version_Secundaria_Adlc VARCHAR2(15));

  TYPE Rec_Trama_Lr IS RECORD(
     Codigo_Autorizacion VARCHAR2(20));

  TYPE Rec_Trama_Md2 IS RECORD(
     Producto           NUMBER
    ,Numero_Contenedor  VARCHAR2(15)
    ,Cantidad_Productos NUMBER);

  TYPE Tab_Trama_Md2 IS TABLE OF Rec_Trama_Md2 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Md1 IS RECORD(
     Guia_Electronica  VARCHAR2(30)
    ,Producto          NUMBER
    ,Cantidad          NUMBER(15, 4)
    ,Decimal_Cantidad  VARCHAR2(4) --JAGC 20250414 ORIGEN FGI
    ,Costo_Unitario    NUMBER(15, 4)
    ,Decimal_Cunitario VARCHAR2(4) --JAGC 20250414 ORIGEN FGI
    ,Numero_Item       NUMBER --JRC 25/07/2023 OJO es de largo 4 para origen TRA, sino largo 2
    ,Lote              VARCHAR2(150)
    ,Guia_Facturable   VARCHAR2(2)
    ,Precio_Final      NUMBER(15, 4)
    ,Decimal_Pfinal    VARCHAR2(4) --JAGC 20250414 ORIGEN FGI
    ,Codigo_Personal   NUMBER
    ,Identi_Vendedor   VARCHAR2(30)
    ,Rut_Vendedor      NUMBER
    ,Dv_Rut_Vendedor   VARCHAR2(1)
    ,Precio_Lista      NUMBER(15, 4)
    ,Decimal_Plista    VARCHAR2(4) --JAGC 20250414 ORIGEN FGI
    ,Codigo_Reclamo    VARCHAR2(6)
    ,Iva               NUMBER --RMC 11-07 Impuesto al Producto Origen IVA
    ,Ieps              NUMBER); --RMC 11-07 Impuesto al Producto Origen IVA

  TYPE Tab_Trama_Md1 IS TABLE OF Rec_Trama_Md1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Md IS RECORD(
     Tipo_Movimiento_Padre   VARCHAR2(6)
    ,Tipo_Movimiento_Hijo    VARCHAR2(6)
    ,Folio                   NUMBER
    ,FOLIO_INGRESO           NUMBER --JAGC 20250414 ORIGEN FGI
    ,DISPATCH_QR             VARCHAR2(20)--JAGC 20250414 ORIGEN FGI
    ,Numero_Pedido           VARCHAR2(30)
    ,Tipo_Guia_Despacho      VARCHAR2(1)
    ,Accion_Sobre_Existencia VARCHAR2(1)
    ,Numero_Folio_Original   NUMBER
    ,Fecha_Folio_Original    NUMBER
    ,Tipo_Recepcion          VARCHAR2(1)
    ,Numero_Reclamo          NUMBER
    ,Fecha_Reclamo           NUMBER
    ,Dfi_Numero_Asignacion   NUMBER
    ,Matricula_Bulto         NUMBER
    ,Monto                   NUMBER(15, 4)
    ,Decimal_Monto           VARCHAR2(4)
    ,Identi_Proveedor        VARCHAR2(30)
    ,Rut_Proveedor           NUMBER
    ,Sucursal_Proveedor      NUMBER
    ,Sello_Seguro_Uno        NUMBER
    ,Sello_Seguro_Dos        NUMBER
    ,Motivo                  VARCHAR2(300) --JRC 17/08/2023 de 250 a 300 por caracteres compuestos
    ,Numero_Factura          VARCHAR2(30) --JRC 27/09/2023 Origen FTR(Factura Transacciones Relacionadas)
    ,Cantidad_Productos      NUMBER
    ,Cantidad_Contenedores   NUMBER
    ,Subtrama_Md1            Tab_Trama_Md1
    ,Subtrama_Md2            Tab_Trama_Md2);

  -- Md4 <> solo por el campo Motivo
  TYPE Rec_Trama_Md4 IS RECORD(
     Tipo_Movimiento_Padre   VARCHAR2(6)
    ,Tipo_Movimiento_Hijo    VARCHAR2(6)
    ,Folio                   NUMBER
    ,Numero_Pedido           NUMBER
    ,Tipo_Guia_Despacho      VARCHAR2(1)
    ,Accion_Sobre_Existencia VARCHAR2(1)
    ,Numero_Folio_Original   NUMBER
    ,Fecha_Folio_Original    NUMBER
    ,Tipo_Recepcion          VARCHAR2(1)
    ,Numero_Reclamo          NUMBER
    ,Fecha_Reclamo           NUMBER
    ,Dfi_Numero_Asignacion   NUMBER
    ,Matricula_Bulto         NUMBER
    ,Monto                   NUMBER
    ,Rut_Proveedor           NUMBER
    ,Sucursal_Proveedor      NUMBER
    ,Sello_Seguro_Uno        NUMBER
    ,Sello_Seguro_Dos        NUMBER
    ,Motivo                  VARCHAR2(25) --JRC
    ,Cantidad_Productos      NUMBER
    ,Subtrama_Md1            Tab_Trama_Md1);
  --

  TYPE Rec_Trama_Md8 IS RECORD(
     Tipo_Movimiento_Padre   VARCHAR2(6)
    ,Tipo_Movimiento_Hijo    VARCHAR2(6)
    ,Folio                   NUMBER
    ,Numero_Pedido           NUMBER
    ,Tipo_Guia_Despacho      VARCHAR2(1)
    ,Accion_Sobre_Existencia VARCHAR2(1)
    ,Numero_Folio_Original   NUMBER
    ,Fecha_Folio_Original    NUMBER
    ,Tipo_Recepcion          VARCHAR2(1)
    ,Numero_Reclamo          NUMBER
    ,Fecha_Reclamo           NUMBER
    ,Cantidad_Productos      NUMBER
    ,Subtrama_Md2            Tab_Trama_Md2);

  TYPE Rec_Trama_Mf IS RECORD(
     Mensaje  VARCHAR2(1000)
    ,Dirigido VARCHAR2(1000));

  TYPE Rec_Trama_Ms IS RECORD(
     Mensaje            VARCHAR2(1000)
    ,Dirigido           VARCHAR2(1000)
    ,Medio_Comunicacion VARCHAR2(1000));

  TYPE Tab_Trama_Ms IS TABLE OF Rec_Trama_Ms INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Mp IS RECORD(
     Correlativo_Tx              NUMBER
    ,Codigo_Interno              NUMBER
    ,Codigo_Autorizacion         VARCHAR2(20)
    ,Numero_Id                   VARCHAR2(20)
    ,Monto                       NUMBER(15, 4)
    ,Decimal_Monto               VARCHAR2(4)
    ,Codigo_Autorizacion_Empresa VARCHAR2(20)
    ,Numero_Folio                VARCHAR2(20)
    ,Fecha_Vencimiento           NUMBER
    ,Empresa                     NUMBER
    ,Cadena                      NUMBER
    ,Numero_Local                NUMBER
    ,Numero_Pos                  NUMBER
    ,Destino                     VARCHAR2(3)
    ,Sistema                     VARCHAR2(3)
    ,Funcion                     VARCHAR2(1)
    ,Secuencia                   VARCHAR2(2)
    ,Fecha_Transaccion           NUMBER
    ,Correlativo                 NUMBER
    ,Numero_Trama                NUMBER
    ,Telefono                    VARCHAR2(10)
    ,Bono_Adicional              NUMBER(15, 4)
    ,Decimal_Badicional          VARCHAR2(4)
    ,Nuevo_Saldo                 NUMBER(15, 4)
    ,Decimal_Nsaldo              VARCHAR2(4)
    ,Dias_Vigencia               NUMBER
    ,Id_Unico                    VARCHAR2(23)
    ,Incluido_En_Journal         VARCHAR2(2)
    ,Forma_Pago                  NUMBER
    ,Descuento                   NUMBER);

  TYPE Tab_Trama_Mp IS TABLE OF Rec_Trama_Mp INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Nc IS RECORD(
     Convenio               NUMBER
    ,Plan                   NUMBER
    ,Rut                    NUMBER
    ,Digito_Verificador_Rut VARCHAR2(1)
    ,Secuencia_b            NUMBER
    ,Rut_Medico             NUMBER
    ,Dv_Rut_Medico          VARCHAR2(1)
    ,Monto                  NUMBER
    ,Cantidad_Cuotas        NUMBER);

  TYPE Rec_Trama_Nr IS RECORD(
     Codigo_Autorizacion         VARCHAR2(20)
    ,Codigo_Autorizacion_Externo VARCHAR2(20)
    ,Interes                     NUMBER);

  TYPE Rec_Trama_Nv1 IS RECORD(
     Producto        NUMBER
    ,Cantidad        NUMBER
    ,Precio_Final    NUMBER
    ,Costo           NUMBER
    ,Codigo_Personal NUMBER
    ,Rut_Vendedor    NUMBER
    ,Dv_Rut_Vendedor VARCHAR2(1)
    ,Precio_Lista    NUMBER
    ,Codigo_Reclamo  NUMBER
    ,Motivo          VARCHAR2(6));

  TYPE Tab_Trama_Nv1 IS TABLE OF Rec_Trama_Nv1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Nv IS RECORD(
     Tipo_Movimiento_Padre   VARCHAR2(6)
    ,Tipo_Movimiento_Hijo    VARCHAR2(6)
    ,Folio                   NUMBER
    ,Numero_Folio_Original   NUMBER
    ,Fecha_Folio_Original    NUMBER
    ,Motivo                  VARCHAR2(2)
    ,Accion_Sobre_Existencia VARCHAR2(1)
    ,Monto                   NUMBER
    ,Cantidad_Productos      NUMBER
    ,Subtrama_Nv1            Tab_Trama_Nv1);

  TYPE Rec_Trama_Vo IS RECORD(
     Hora_Presentacion_Pop_Up VARCHAR2(6)
    ,Hora_Seleccion_Opcion    VARCHAR2(6)
    ,Convenio                 NUMBER
    ,Opcion_Seleccionada      VARCHAR2(2)
    ,Rut_Cliente              NUMBER
    ,Rut_Vendedor             NUMBER);

  TYPE Rec_Trama_Pa IS RECORD(
     Uso_Frecuente NUMBER
    ,Ofrecido      VARCHAR2(1)
    ,Estado_Crm    VARCHAR2(3));

  TYPE Tab_Trama_Pa IS TABLE OF Rec_Trama_Pa INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Pb IS RECORD(
     Uso_Frecuente      NUMBER
    ,Rut_Medico         NUMBER
    ,Dv_Rut_Medico      VARCHAR2(1)
    ,Folio              NUMBER
    ,Rut_Vendedor       NUMBER
    ,Dv_Rut_Vendedor    VARCHAR2(1)
    ,Numero_Inscripcion NUMBER
    ,Fecha_Expiracion   NUMBER);

  TYPE Rec_Trama_Pc IS RECORD(
     Producto           NUMBER
    ,Producto_Premio    NUMBER
    ,Meta_Compra        NUMBER
    ,Cantidad_a_Regalar NUMBER
    ,Campana            NUMBER
    ,Uso_Frecuente      NUMBER
    ,Tipo_Descuento     VARCHAR2(3)
    ,Descuento          NUMBER);

  TYPE Rec_Trama_Pd IS RECORD(
     Rut_Beneficiario       NUMBER
    ,Digito_Verificador_Rut VARCHAR2(1)
    ,Fecha_Inicio           NUMBER
    ,Fecha_Termino          NUMBER);

  TYPE Rec_Trama_Pe IS RECORD(
     Id_Periodo          NUMBER
    ,Fecha_Inicio        NUMBER
    ,Fecha_Termino       NUMBER
    ,Monto_Copago        NUMBER(15, 4)
    ,Decimal_Copago      VARCHAR2(4)
    ,Folio_Bono          NUMBER
    ,Folio_Copago        NUMBER
    ,Periodo_Desmarcable VARCHAR2(2));

  TYPE Tab_Trama_Pe IS TABLE OF Rec_Trama_Pe INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Pf IS RECORD(
     Uso_Frecuente     NUMBER
    ,Evento_Actual     NUMBER
    ,Campana           NUMBER
    ,Eventos_Cumplidos NUMBER
    ,Fecha_Vencimiento NUMBER);

  TYPE Tab_Trama_Pf IS TABLE OF Rec_Trama_Pf INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Pg1 IS RECORD(
     Folio                      NUMBER
    ,Producto                   NUMBER
    ,Uso_Frecuente              NUMBER
    ,Cantidad_Acumulada_Psalud  NUMBER
    ,Cantidad                   NUMBER
    ,Porcentaje_Descuento       VARCHAR2(6)
    ,Detalle_Descuento_Producto VARCHAR2(250));

  TYPE Tab_Trama_Pg1 IS TABLE OF Rec_Trama_Pg1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Pg IS RECORD(
     Correlativo_Tx     NUMBER
    ,Cantidad_Productos NUMBER
    ,Subtrama_Pg1       Tab_Trama_Pg1);

  TYPE Rec_Trama_Pi1 IS RECORD(
     Producto          NUMBER
    ,Cantidad          NUMBER
    ,Costo_Unitario    NUMBER(15, 4)
    ,Decimal_Cunitario VARCHAR2(4)
    ,Lote              VARCHAR2(150)
    ,Fecha_Vencimiento NUMBER);

  TYPE Tab_Trama_Pi1 IS TABLE OF Rec_Trama_Pi1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Pi IS RECORD(
     Tipo_Movimiento_Padre       VARCHAR2(6)
    ,Tipo_Movimiento_Hijo        VARCHAR2(6)
    ,Folio                       VARCHAR2(20)
    ,Guia_Despacho               VARCHAR2(30)
    ,Tipo_Guia_Despacho          VARCHAR2(1)
    ,Accion_Sobre_Existencia     VARCHAR2(1)
    ,Numero_Folio_Original       VARCHAR2(20)
    ,Fecha_Folio_Original        NUMBER
    ,Ot                          VARCHAR2(14)
    ,Valor_Recetario             NUMBER(15, 4)
    ,Decimal_Valor_Recetario     VARCHAR2(4)
    ,Motivo                      VARCHAR2(250)
    ,Tipo_Negocio                VARCHAR2(1)
    ,Tipo_Transferencia          VARCHAR2(1)
    ,Idtransportista             VARCHAR2(16)
    ,Nombre_Transportista        VARCHAR2(150)
    ,Placa_Transportista         VARCHAR2(16)
    ,Clave_Acceso                VARCHAR2(50)
    ,Serie                       NUMBER
    ,Comprobante                 NUMBER
    ,Codigo_Numerico             NUMBER
    ,Numero_Resolucion           VARCHAR2(15)
    ,Agente_Retencion            VARCHAR2(50)
    ,Microempresa                VARCHAR2(50)
    ,Local_Origen                NUMBER
    ,Local_Destino               NUMBER
    ,Cantidad_Productos_Traspaso NUMBER --JRC 27/04/2023 Solo menciona cantidad, sin detalle de prod
    ,Cantidad_Productos          NUMBER
    ,DISPATCH_QR                 VARCHAR2(20)--JAGC 20250414 ORIGEN FGI
    ,CODIGO_DESPLAZAMIENTO       VARCHAR2(30)--JAGC 20250414 ORIGEN FGI
    ,USUARIO_EMISOR              VARCHAR2(20)--JAGC 20250414 ORIGEN FGI
    ,OBSERVACION                 VARCHAR2(250)--IDHC 20260623 ORIGEN SLV
    ,Subtrama_Pi1                Tab_Trama_Pi1);

  TYPE Tab_Trama_Pi IS TABLE OF Rec_Trama_Pi INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Pl IS RECORD(
     Codigo_Producto      NUMBER
    ,Dosis                NUMBER
    ,Veces                NUMBER
    ,Dias                 NUMBER
    ,Cantidad             NUMBER
    ,Precio_Lista         NUMBER
    ,Precio               NUMBER
    ,Codigo_Barra         NUMBER
    ,Enviar_Sustituto     VARCHAR2(2)
    ,Descuento_Financiado NUMBER
    ,Numero_Retiro        NUMBER
    ,Decimal_Precio_Lista VARCHAR2(4)
    ,Decimal_Precio_Final VARCHAR2(4)
    ,Monto_Iva            NUMBER
    ,Decimal_Iva          VARCHAR2(4));

  TYPE Tab_Trama_Pl IS TABLE OF Rec_Trama_Pl INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Pl9 IS RECORD(
     Codigo_Producto  NUMBER
    ,Dosis            NUMBER
    ,Veces            NUMBER
    ,Dias             NUMBER
    ,Cantidad         NUMBER
    ,Enviar_Sustituto VARCHAR2(2));

  TYPE Tab_Trama_Pl9 IS TABLE OF Rec_Trama_Pl9 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Pm1 IS RECORD(
     Secuencia_b              NUMBER
    ,Total_Item_Por_Documento NUMBER(15, 4)
    ,Decimal_Total_Item       VARCHAR2(4));

  TYPE Tab_Trama_Pm1 IS TABLE OF Rec_Trama_Pm1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Pm2 IS RECORD(
     Secuencia_b                  NUMBER
    ,Tipo_Descuento               VARCHAR2(3)
    ,Campana_o_Convenio           NUMBER
    ,Codigo_Cupon                 VARCHAR2(15)
    ,Monto_Documento              NUMBER(15, 4)
    ,Decimal_Monto_Docto          VARCHAR2(4)
    ,Puntos_Canjeados             NUMBER
    ,Convertibilidad_Pesos_Puntos NUMBER
    ,Tipo_Aplicacion_Descuento    VARCHAR2(2)
    ,Id_Descuento_Complementario  VARCHAR2(3)
    --,Detalle_Descuento_Producto   VARCHAR2(250) --JAGC 20240909 NECESIDADES 'NEC'
    ,Detalle_Descuento_Producto   VARCHAR2(1000) --JAGC 20240909 NECESIDADES 'NEC'
    ,Descuento_Financiado         VARCHAR2(2)
    ,Secuencia_Financiamiento     NUMBER
    ,Unidades_Beneficio           NUMBER
    ,Descuento_Referencial        VARCHAR2(2)
    ,Signo                        VARCHAR2(1)
    ,Pertenece_Club               VARCHAR2(1)
    ,Promotion_web                VARCHAR2(6) -- IDHC 04/06/2024
    
    --INI JAGC 20240909 NECESIDADES 'NEC'  
    --,Det_Descto_Producto                  VARCHAR2(1000)
    --FIN JAGC 20240909 NECESIDADES 'NEC'
    
    );

  TYPE Tab_Trama_Pm2 IS TABLE OF Rec_Trama_Pm2 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Pm3 IS RECORD(
     Campana  NUMBER
    ,Puntos   NUMBER
    ,Signo    VARCHAR2(1)
    ,Vigencia NUMBER);

  TYPE Tab_Trama_Pm3 IS TABLE OF Rec_Trama_Pm3 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Pm4 IS RECORD(
     Tipo_Distribucion     VARCHAR2(3)
    ,Monto_Distribucion    NUMBER(15, 4)
    ,Decimal_Monto_Distrib VARCHAR2(4));

  TYPE Tab_Trama_Pm4 IS TABLE OF Rec_Trama_Pm4 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Pm5 IS RECORD(
     Codigo_Impuesto       NUMBER
    ,Porcentaje_Impuesto   NUMBER(15, 4)
    ,Decimal_Porc_Impuesto VARCHAR2(4)
    ,Monto_Impuesto        NUMBER(15, 4)
    ,Decimal_Mto_Impuesto  VARCHAR2(4));

  TYPE Tab_Trama_Pm5 IS TABLE OF Rec_Trama_Pm5 INDEX BY BINARY_INTEGER;

  --//--------------------------------------------------------------------------\\
  --// CBR 26/11/2021 11:26                                                     \\
  --// Desarrollos de nuevas subtramas en trama PM con Origen_transaccion 'RYT' \\
  --//-----------------------------------------------------------------Inicio---\\
  TYPE Rec_Trama_Pm6 IS RECORD(
     Secuencia      NUMBER
    ,Identificacdor VARCHAR2(30)
    ,Nombre         VARCHAR2(100)
    ,Monto          NUMBER(15, 4)
    ,Decimal_Monto  VARCHAR2(4)
    ,Autorizacion   VARCHAR2(20)
    ,Auditoria      VARCHAR2(6)
    ,Tipo_Servicio  VARCHAR2(1));

  TYPE Tab_Trama_Pm6 IS TABLE OF Rec_Trama_Pm6 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Pm7 IS RECORD(
     Sku_Original     NUMBER
    ,Regla_Calculo    VARCHAR2(50)
    ,Sku_Sugerido     NUMBER
    ,Id_Combinacion   VARCHAR2(20)
    ,Decision_Cliente VARCHAR2(2));

  TYPE Tab_Trama_Pm7 IS TABLE OF Rec_Trama_Pm7 INDEX BY BINARY_INTEGER;
  --//-----------------------------------------------------------------Termino--\\

  --//--------------------------------------------------------------------------\\
  --// CBR 05-05-2022 4:15                                                      \\
  --// Desarrollos para Mexico subtrama Productos Controlados Origen   'VCO'    \\
  --//                                                                          \\
  --//-----------------------------------------------------------------Inicio---\\
  TYPE Rec_Trama_Pm8 IS RECORD(
     Folio_Receta      VARCHAR2(14)
    ,Ced_Prof          VARCHAR2(30)
    ,Nombre_Medico     VARCHAR2(100)
    ,Calle             VARCHAR2(100)
    ,Colonia           VARCHAR2(50)
    ,Cod_Postal        NUMBER(10)
    ,Ciudad            VARCHAR2(50)
    ,Municipio         VARCHAR2(50)
    ,Folio_Correlativo VARCHAR2(15));

  TYPE Tab_Trama_Pm8 IS TABLE OF Rec_Trama_Pm8 INDEX BY BINARY_INTEGER;
  --//-----------------------------------------------------------------Termino--\\
  
  --INI JAGC 20240909 NECESIDADES 'NEC'  
  -------------------------------------------------------------------------
  --SubTrama PM9 2024 JAGC Descuentos Aplicados Perdidoso Necesidades
  -------------------------------------------------------------------------  
  TYPE Rec_Trama_Pm9 IS RECORD(
    Id_descuento_perdido                       VARCHAR2(3)
    ,Evento_Perdido                             VARCHAR2(3)          
    ,Monto_descuento                            NUMBER
    ,Decimal_Monto_Docto                        VARCHAR2(4)
    ,Descuento_relacionado                      VARCHAR2(10)
    ,Tipo_descuento_aplicado_perdido            VARCHAR2(2)
    ,Unidad_Compra                              VARCHAR2(8) --JAGC 20250414 NECESIDADES 'NEU'
    ,Unidad_Beneficio                           VARCHAR2(8) --JAGC 20250414 NECESIDADES 'NEU'
    );

  TYPE Tab_Trama_Pm9 IS TABLE OF Rec_Trama_Pm9 INDEX BY BINARY_INTEGER;
  --FIN JAGC 20240909 NECESIDADES 'NEC'

  TYPE Rec_Trama_Pm IS RECORD(
     Producto                     NUMBER
    ,Codigo_Barra                 NUMBER
    ,Uso_Frecuente                NUMBER
    ,Precio_Lista                 NUMBER(15, 4)
    ,Decimal_Plista               VARCHAR2(4)
    ,Precio_Final                 NUMBER(15, 4)
    ,Decimal_Pfinal               VARCHAR2(4)
    ,Costo_Unitario               NUMBER(15, 4)
    ,Decimal_Cunitario            VARCHAR2(4)
    ,Cantidad                     NUMBER(15, 4)
    ,Decimal_Cantidad             VARCHAR2(4)
    ,Cantidad_Acumulada_Psalud    NUMBER
    ,Identi_Vendedor              VARCHAR2(30)
    ,Rut_Vendedor                 NUMBER
    ,Dv_Rut_Vendedor              VARCHAR2(1)
    ,Codigo_Autorizacion          VARCHAR2(20)
    ,Aplicacion_Item              VARCHAR2(1)
    ,Accion_Sobre_Existencia      VARCHAR2(1)
    ,Saldo_Compra_Frecuente       NUMBER
    ,Acumulador_Entrega           NUMBER
    ,Numero_Consejo               NUMBER
    ,Porcentaje_Bonificacion      NUMBER
    ,Cantidad_Canjeada            NUMBER
    ,Canje_Transaccion_Origen     NUMBER
    ,Canje_Local_Origen           NUMBER
    ,Inscrito_Programa_Salud      VARCHAR2(2)
    ,Permitido_Por_Convenio       VARCHAR2(2)
    ,Campana_Promocion            NUMBER
    ,Campana_Aditiva              VARCHAR2(3)
    ,Beneficio_Pendiente_Ps       NUMBER
    ,Exento_Iva                   VARCHAR2(2)
    ,Controla_Stock               VARCHAR2(2)
    ,Permite_Devolucion           VARCHAR2(2)
    ,Producto_Original_Demandado  NUMBER
    ,Secuencia_Receta_Relacionada NUMBER
    ,Porcentaje_Bonif_Informado   NUMBER
    ,Monto_Bonif_Informado        NUMBER
    ,Deducible_Aplicado_En_Pesos  NUMBER
    ,Tope_Aplicado_En_Pesos       NUMBER
    ,Identi_Supervisor            VARCHAR2(30)
    ,Rut_Supervisor               NUMBER
    ,Dv_Rut_Supervisor            VARCHAR2(1)
    ,Deduccion_Producto           VARCHAR2(5)
    ,Documentos_Referencia        NUMBER
    ,Descuentos_Aplicados         NUMBER
    ,Puntos_Generados             NUMBER
    ,Distribucion_Convenio        NUMBER
    ,Impuestos_Aplicados          NUMBER
    ,Recargas_y_Telepeaje         NUMBER
    ,Mejor_Opcion                 NUMBER
    ,Productos_Controlados        NUMBER    
    ,Subtrama_Pm1                 Tab_Trama_Pm1
    ,Subtrama_Pm2                 Tab_Trama_Pm2
    ,Subtrama_Pm3                 Tab_Trama_Pm3
    ,Subtrama_Pm4                 Tab_Trama_Pm4
    ,Subtrama_Pm5                 Tab_Trama_Pm5
    ,Subtrama_Pm6                 Tab_Trama_Pm6
    ,Subtrama_Pm7                 Tab_Trama_Pm7
    ,Subtrama_Pm8                 Tab_Trama_Pm8
    
    --INI JAGC 20240909 NECESIDADES 'NEC'  
    ,Nombre_Vendedor                      VARCHAR2(30)
    ,Descuentos_Aplicados_Perdidos        NUMBER
    ,Subtrama_Pm9                         Tab_Trama_Pm9
    --FIN JAGC 20240909 NECESIDADES 'NEC'
    
    );

  TYPE Tab_Trama_Pm IS TABLE OF Rec_Trama_Pm INDEX BY BINARY_INTEGER;

  /*
    TYPE Rec_Trama_Pm9 IS RECORD(
       Producto                    NUMBER
      ,Codigo_Barra                NUMBER
      ,Uso_Frecuente               NUMBER
      ,Precio_Lista                NUMBER
      ,Precio_Final                NUMBER
      ,Costo_Unitario              NUMBER
      ,Cantidad                    NUMBER
      ,Cantidad_Acumulada_Psalud   NUMBER
      ,Rut_Vendedor                NUMBER
      ,Dv_Rut_Vendedor             VARCHAR2(1)
      ,Codigo_Autorizacion         VARCHAR2(10)
      ,Aplicacion_Item             VARCHAR2(1)
      ,Accion_Sobre_Existencia     VARCHAR2(1)
      ,Saldo_Compra_Frecuente      NUMBER
      ,Acumulador_Entrega          NUMBER
      ,Numero_Consejo              NUMBER
      ,Porcentaje_Bonificacion     NUMBER
      ,Cantidad_Canjeada           NUMBER
      ,Canje_Transaccion_Origen    NUMBER
      ,Canje_Local_Origen          NUMBER
      ,Inscrito_Programa_Salud     VARCHAR2(2)
      ,Permitido_Por_Convenio      VARCHAR2(2)
      ,Campana_Promocion           NUMBER
      ,Campana_Aditiva             VARCHAR2(3)
      ,Beneficio_Pendiente_Ps      NUMBER
      ,Exento_Iva                  VARCHAR2(2)
      ,Controla_Stock              VARCHAR2(2)
      ,Permite_Devolucion          VARCHAR2(2)
      ,Producto_Original_Demandado NUMBER
      ,Documentos_Referencia       NUMBER
      ,Descuentos_Aplicados        NUMBER
      ,Puntos_Generados            NUMBER
      ,Distribucion_Convenio       NUMBER);

    TYPE Tab_Trama_Pm9 IS TABLE OF Rec_Trama_Pm9 INDEX BY BINARY_INTEGER;
  */

  -- ============================================================
  -- DESARROLLO DISPENSACI?N (JAGC 2024-03-20)
  -- ORIGEN DE TRANSACCI?N PARA DISPENSACI?N 'MSP'
  -- ============================================================
  TYPE Rec_Trama_Po IS RECORD(
     Codigo_Producto     NUMBER
    ,Dosis               NUMBER
    ,Veces               NUMBER
    ,Dias                NUMBER
    ,Cantidad            NUMBER
    ,Codigo_De_Respuesta VARCHAR2(4)
    ,Dias_Tratamiento    NUMBER
    ,Precio              NUMBER
    ,Decimal_Precio      VARCHAR2(4) --CAMBIO TRAMA POR ORIGEN MSP
    ,Bonificacion        NUMBER
    ,Descuento           NUMBER);

  TYPE Tab_Trama_Po IS TABLE OF Rec_Trama_Po INDEX BY BINARY_INTEGER;
  -- ============================================================

  TYPE Rec_Trama_Po1 IS RECORD(
     Codigo_Sustituto NUMBER
    ,En_Lista         VARCHAR2(2));

  TYPE Tab_Trama_Po1 IS TABLE OF Rec_Trama_Po1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Po9 IS RECORD(
     Codigo_Producto             NUMBER
    ,Dosis                       NUMBER
    ,Veces                       NUMBER
    ,Dias                        NUMBER
    ,Cantidad                    NUMBER
    ,Cantidad_Original           NUMBER
    ,Codigo_De_Respuesta         VARCHAR2(4)
    ,Mensaje_Producto            VARCHAR2(50)
    ,Dias_Tratamiento            NUMBER
    ,Precio                      NUMBER
    ,Tipo_Bonificacion           VARCHAR2(3)
    ,Bonificacion                NUMBER
    ,Descuento                   NUMBER
    ,Afecto_Sgdo_Credito         VARCHAR2(2)
    ,Porcentaje_Bonif_Informado  NUMBER
    ,Monto_Bonif_Informado       NUMBER
    ,Deducible_Aplicado_En_Pesos NUMBER
    ,Tope_Aplicado_En_Pesos      NUMBER
    ,Cantidad_Sustitutos         NUMBER
    ,Subtrama_Po1                Tab_Trama_Po1);

  TYPE Tab_Trama_Po9 IS TABLE OF Rec_Trama_Po9 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Po8 IS RECORD(
     Codigo_Producto             NUMBER
    ,Dosis                       NUMBER
    ,Veces                       NUMBER
    ,Dias                        NUMBER
    ,Cantidad                    NUMBER
    ,Cantidad_Original           NUMBER
    ,Codigo_De_Respuesta         VARCHAR2(4)
    ,Mensaje_Producto            VARCHAR2(50)
    ,Dias_Tratamiento            NUMBER
    ,Precio                      NUMBER
--    ,Decimal_Precio              VARCHAR2(4) --CAMBIO TRAMA POR ORIGEN MSP
    ,Tipo_Bonificacion           VARCHAR(3)
    ,Bonificacion                NUMBER
    ,Descuento                   NUMBER
    ,Afecto_Sgdo_Credito         VARCHAR2(2)
    ,Porcentaje_Bonif_Informado  NUMBER
    ,Monto_Bonif_Informado       NUMBER
    ,Deducible_Aplicado_En_Pesos NUMBER
    ,Tope_Aplicado_En_Pesos      NUMBER
    ,Numero_Plan                 NUMBER
    ,Codigo_Ges                  VARCHAR2(3)
    ,Folio_Bono                  NUMBER
    ,Cantidad_Sustitutos         NUMBER
    ,Subtrama_Po1                Tab_Trama_Po1);

  TYPE Tab_Trama_Po8 IS TABLE OF Rec_Trama_Po8 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Po7 IS RECORD(
     Codigo_Producto             NUMBER
    ,Dosis                       NUMBER
    ,Veces                       NUMBER
    ,Dias                        NUMBER
    ,Cantidad                    NUMBER
    ,Cantidad_Original           NUMBER
    ,Codigo_De_Respuesta         VARCHAR2(4)
    ,Mensaje_Producto            VARCHAR2(50)
    ,Dias_Tratamiento            NUMBER
    ,Precio                      NUMBER
--    ,Decimal_Precio              VARCHAR2(4) --CAMBIO TRAMA POR ORIGEN MSP
    ,Tipo_Bonificacion           VARCHAR(3)
    ,Bonificacion                NUMBER
    ,Descuento                   NUMBER
    ,Afecto_Sgdo_Credito         VARCHAR2(2)
    ,Porcentaje_Bonif_Informado  NUMBER
    ,Monto_Bonif_Informado       NUMBER
    ,Deducible_Aplicado_En_Pesos NUMBER
    ,Tope_Aplicado_En_Pesos      NUMBER
    ,Numero_Plan                 NUMBER
    ,Codigo_Ges                  VARCHAR2(3)
    ,Folio_Bono                  NUMBER
    ,Cantidad_Sustitutos         NUMBER
    ,Subtrama_Po1                Tab_Trama_Po1);

  TYPE Tab_Trama_Po7 IS TABLE OF Rec_Trama_Po7 INDEX BY BINARY_INTEGER;

  -- ============================================================
  -- DESARROLLO DISPENSACI?N (JAGC 2024-03-20)
  -- ORIGEN DE TRANSACCI?N PARA DISPENSACI?N 'MSP'
  -- ============================================================
  TYPE Rec_Trama_Po6 IS RECORD(
     Codigo_Producto             NUMBER
    ,Dosis                       NUMBER
    ,Veces                       NUMBER
    ,Dias                        NUMBER
    ,Cantidad                    NUMBER
    ,Cantidad_Original           NUMBER
    ,Codigo_De_Respuesta         VARCHAR2(4)
    ,Mensaje_Producto            VARCHAR2(50)
    ,Dias_Tratamiento            NUMBER
    ,Precio                      NUMBER
    ,Decimal_Precio              VARCHAR2(4) --CAMBIO TRAMA POR ORIGEN MSP
    ,Tipo_Bonificacion           VARCHAR(3)
    ,Bonificacion                NUMBER
    ,Descuento                   NUMBER
    ,Afecto_Sgdo_Credito         VARCHAR2(2)
    ,Porcentaje_Bonif_Informado  NUMBER
    ,Monto_Bonif_Informado       NUMBER
    ,Deducible_Aplicado_En_Pesos NUMBER
    ,Tope_Aplicado_En_Pesos      NUMBER
    ,Numero_Plan                 NUMBER
    ,Codigo_Ges                  VARCHAR2(3)
    ,Folio_Bono                  NUMBER
    ,Cantidad_Sustitutos         NUMBER
    ,Subtrama_Po1                Tab_Trama_Po1);

  TYPE Tab_Trama_Po6 IS TABLE OF Rec_Trama_Po6 INDEX BY BINARY_INTEGER;
  -- ============================================================

  TYPE Rec_Trama_Pp IS RECORD(
     Fecha  NUMBER
    ,Puntos NUMBER);

  TYPE Rec_Trama_Pq IS RECORD(
     Codigo_Producto             NUMBER
    ,Cantidad                    NUMBER
    ,Precio_Con_Descuento        NUMBER(15, 4)
    ,Decimal_Precio_Descuento    VARCHAR2(4)
    ,Bonificacion                NUMBER(15, 4)
    ,Decimal_Bonificacion        VARCHAR2(4)
    ,Codigo_Barra                NUMBER
    ,Porcentaje_Bonif_Informado  NUMBER
    ,Monto_Bonif_Informado       NUMBER(15, 4)
    ,Decimal_Bonif_Informado     VARCHAR2(4)
    ,Deducible_Aplicado_En_Pesos NUMBER(15, 4)
    ,Decimal_Deducible_Aplicado  VARCHAR2(4)
    ,Tope_Aplicado_En_Pesos      NUMBER(15, 4)
    ,Decimal_Tope_Aplicado       VARCHAR2(4));

  TYPE Tab_Trama_Pq IS TABLE OF Rec_Trama_Pq INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Pr IS RECORD(
     Uso_Frecuente NUMBER
    ,Ofrecido      VARCHAR2(1)
    ,Estado_Crm    VARCHAR2(3));

  TYPE Tab_Trama_Pr IS TABLE OF Rec_Trama_Pr INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Ps IS RECORD(
     Producto NUMBER);

  TYPE Rec_Trama_Pt IS RECORD(
     LOCAL           NUMBER
    ,Rut_Vendedor    NUMBER
    ,Dv_Rut_Vendedor VARCHAR2(1)
    ,Correlativo_Tx  NUMBER);

  TYPE Rec_Trama_Pu IS RECORD(
     Signo               VARCHAR2(1)
    ,Puntos              NUMBER
    ,Donacion_Vigente    VARCHAR2(1)
    ,Identi_Beneficiario VARCHAR2(30)
    ,Rut_Beneficiario    NUMBER
    ,Dv_Rut_Beneficiario VARCHAR2(1)
    ,Nombre              VARCHAR2(20)
    ,Fecha_Inicio        NUMBER
    ,Fecha_Termino       NUMBER
    ,Vigencia            NUMBER);

  TYPE Tab_Trama_Pu IS TABLE OF Rec_Trama_Pu INDEX BY BINARY_INTEGER;

  /*TYPE rec_trama_pv IS RECORD(
    id_periodo     NUMBER,
    fecha_inicio   NUMBER,
    fecha_termino  NUMBER,
    monto_copago   NUMBER,
    folio_copago   NUMBER,
    periodo_pagado VARCHAR2(1));

  TYPE tab_trama_pv IS TABLE OF rec_trama_pv INDEX BY BINARY_INTEGER;*/
  TYPE Rec_Trama_Pz IS RECORD(
     Producto          NUMBER
    ,Familia_Comercial NUMBER
    ,Tipo_Descuento    VARCHAR2(3)
    ,Descuento         NUMBER
    ,Campana           NUMBER
    ,Uso_Frecuente     NUMBER);

  TYPE Rec_Trama_Qf IS RECORD(
     Autorizacion_Qf VARCHAR2(2)
    ,Rut_Qf          NUMBER
    ,Numero_Preventa NUMBER);

  TYPE Rec_Trama_Ra IS RECORD(
     Tarjeta_Invitado VARCHAR2(20));

  TYPE Rec_Trama_Rb1 IS RECORD(
     Numero_Pedido           NUMBER
    ,Codigo_Bulto            NUMBER
    ,Matricula_Bulto         NUMBER
    ,Tipo_Bulto              VARCHAR2(3)
    ,Recepcionado            VARCHAR2(2)
    ,Fecha_Recepcion         NUMBER
    ,Devuelto                VARCHAR2(2)
    ,Fecha_Devolucion        NUMBER
    ,Guia_Devolucion         NUMBER
    ,Fecha_Ingreso           NUMBER
    ,Fecha_Revision_Ini      NUMBER
    ,Fecha_Revision_Fin      NUMBER
    ,Tipo_Recepcion_Bulto    VARCHAR2(3)
    ,Numero_Pedido_Proveedor NUMBER
    ,Folio_Guia_Reclamo      NUMBER
    ,Numero_Reclamo          NUMBER);

  TYPE Tab_Trama_Rb1 IS TABLE OF Rec_Trama_Rb1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Rb IS RECORD(
     Numero_Manifiesto           NUMBER
    ,Fecha_Manifiesto            NUMBER
    ,Numero_Despacho             NUMBER
    ,Fecha_Despacho              NUMBER
    ,Patente_Transporte          VARCHAR2(7)
    ,Fecha_Hora_Recepcion        NUMBER
    ,Fecha_Hora_Ingreso_Vendible NUMBER
    ,Tipo_Recepcion_Manifiesto   VARCHAR2(3)
    ,Cantidad_Bultos             NUMBER
    ,Subtrama_Rb1                Tab_Trama_Rb1);

  TYPE Tab_Trama_Rb IS TABLE OF Rec_Trama_Rb INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Rc IS RECORD(
     Producto         NUMBER
    ,Tipo_Inscripcion VARCHAR2(3));

  TYPE Rec_Trama_Rcv IS RECORD(
     Producto         NUMBER
    ,Tipo_Inscripcion VARCHAR2(3)
    ,Ofrecido         VARCHAR2(3)
    ,Estado_Crm       VARCHAR2(3));

  TYPE Tab_Trama_Rcv IS TABLE OF Rec_Trama_Rcv INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Re IS RECORD(
     Timespan        NUMBER
    ,Rx_Ack          VARCHAR2(1000)
    ,Rx_Nack         VARCHAR2(1000)
    ,Rx_Con_Servicio VARCHAR2(1000)
    ,Rx_Sin_Servicio VARCHAR2(1000)
    ,Rx_Timeout      VARCHAR2(1000)
    ,Rx_Erronea      VARCHAR2(1000));

  TYPE Rec_Trama_Rf IS RECORD(
     Producto          NUMBER
    ,Fecha_Vencimiento NUMBER);

  TYPE Tab_Trama_Rf IS TABLE OF Rec_Trama_Rf INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Rfv IS RECORD(
     Producto       NUMBER
    ,Consumo        VARCHAR2(3)
    ,Estado_Consumo VARCHAR2(3));

  TYPE Tab_Trama_Rfv IS TABLE OF Rec_Trama_Rfv INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Rg1 IS RECORD(
     Guia_Electronica NUMBER
    ,Producto         NUMBER
    ,Cantidad         NUMBER);

  TYPE Tab_Trama_Rg1 IS TABLE OF Rec_Trama_Rg1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Rg IS RECORD(
     Tipo_Movimiento_Padre VARCHAR2(6)
    ,Tipo_Movimiento_Hijo  VARCHAR2(6)
    ,Folio                 NUMBER
    ,Numero_Pedido         NUMBER
    ,Fecha                 NUMBER
    ,Cantidad_Productos    NUMBER
    ,Subtrama_Rg1          Tab_Trama_Rg1);

  TYPE Tab_Trama_Rg IS TABLE OF Rec_Trama_Rg INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Rj1 IS RECORD(
     Producto NUMBER
    ,Cantidad NUMBER);

  TYPE Tab_Trama_Rj1 IS TABLE OF Rec_Trama_Rj1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Rj IS RECORD(
     Tipo_Movimiento_Padre   VARCHAR2(6)
    ,Tipo_Movimiento_Hijo    VARCHAR2(6)
    ,Folio                   NUMBER
    ,Guia_Despacho           NUMBER
    ,Tipo_Guia_Despacho      VARCHAR2(1)
    ,Accion_Sobre_Existencia VARCHAR2(1)
    ,Cantidad_Productos      NUMBER
    ,Subtrama_Rj1            Tab_Trama_Rj1);

  TYPE Rec_Trama_Rk1 IS RECORD(
     Producto NUMBER
    ,Signo    VARCHAR2(1)
    ,Cantidad NUMBER);

  TYPE Tab_Trama_Rk1 IS TABLE OF Rec_Trama_Rk1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Rk IS RECORD(
     LOCAL              NUMBER
    ,Cantidad_Productos NUMBER
    ,Subtrama_Rk1       Tab_Trama_Rk1);

  TYPE Tab_Trama_Rk IS TABLE OF Rec_Trama_Rk INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Rl1 IS RECORD(
     Producto NUMBER
    ,Cantidad NUMBER);

  TYPE Tab_Trama_Rl1 IS TABLE OF Rec_Trama_Rl1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Rl IS RECORD(
     Tipo_Movimiento_Padre   VARCHAR2(6)
    ,Tipo_Movimiento_Hijo    VARCHAR2(6)
    ,Folio                   NUMBER
    ,Numero_Pedido           NUMBER
    ,Guia_Electronica        NUMBER
    ,Guia_Despacho           NUMBER
    ,Tipo_Guia_Despacho      VARCHAR2(1)
    ,Accion_Sobre_Existencia VARCHAR2(1)
    ,Cantidad_Productos      NUMBER
    ,Subtrama_Rl1            Tab_Trama_Rl1);

  TYPE Rec_Trama_Rm1 IS RECORD(
     Producto                NUMBER
    ,Tipo_Movimiento         VARCHAR2(1)
    ,Accion_Sobre_Existencia VARCHAR2(1)
    ,Cantidad                NUMBER
    ,Cantidad_Decimal        NUMBER
    ,Ot                      VARCHAR2(13)
    ,Lote                    VARCHAR2(150)
    ,Fecha_Expiracion        NUMBER
    ,Valorizacion_Entero     NUMBER
    ,Valorizacion_Decimal    NUMBER
    ,Unidad_Medida           NUMBER
    ,Motivo                  VARCHAR2(6)
    ,Id_Envio                NUMBER
    ,Numero_Ingreso          NUMBER
    ,Linea_Compra            NUMBER);

  TYPE Tab_Trama_Rm1 IS TABLE OF Rec_Trama_Rm1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Rm IS RECORD(
     Tipo_Movimiento_Padre VARCHAR2(6)
    ,Tipo_Movimiento_Hijo  VARCHAR2(6)
    ,Folio                 NUMBER
    ,Fecha_Expiracion      NUMBER
    ,Certificados_Origen   VARCHAR2(300)
    ,Cantidad_Productos    NUMBER
    ,Subtrama_Rm1          Tab_Trama_Rm1);

  /* ============================================================
   DESARROLLO CUENTA CORRIENTE RECETA (CGC 16-12-2015)
  ============================================================*/
  TYPE Rec_Trama_Rp1 IS RECORD(
     Producto                   NUMBER
    ,Cantidad                   NUMBER
    ,Dosis                      NUMBER
    ,Veces                      NUMBER
    ,Dias                       NUMBER
    ,Estado_Producto            VARCHAR2(3)
    ,Permanente                 VARCHAR2(2)
    ,Indicaciones               VARCHAR2(200)
    ,Retiro_Anticipado          VARCHAR2(2)
    ,Retiro_Actual              NUMBER
    ,Total_Retiros              NUMBER
    ,Fecha_Proximo_Retiro       NUMBER
    ,Fecha_Termino_Tratamiento  NUMBER
    ,Cantidad_Despacho_Anterior NUMBER
    ,Cantidad_Despacho_Total    NUMBER
    ,Cantidad_Pendiente         NUMBER
    ,Tipo_Medicamento           VARCHAR2(3)
    ,Inscribir_En_Refill        VARCHAR2(2)
    ,Tipo_Inscripcion_Refill    VARCHAR2(3)
    ,Texto                      VARCHAR2(100)
    ,Forma_Farmaceutica         VARCHAR2(3));

  TYPE Tab_Trama_Rp1 IS TABLE OF Rec_Trama_Rp1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Rp2 IS RECORD(
     Producto        NUMBER
    ,Numero_Retiro   NUMBER
    ,Total_Retiros   NUMBER
    ,Folio_Documento NUMBER
    ,Fecha_Documento NUMBER
    ,Cantidad        NUMBER);

  TYPE Tab_Trama_Rp2 IS TABLE OF Rec_Trama_Rp2 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Rp IS RECORD(
     Id_Receta              NUMBER
    ,Local_Origen           NUMBER
    ,Fecha_Emision          NUMBER
    ,Convenio               NUMBER
    ,Plan                   NUMBER
    ,Estado_Receta          VARCHAR2(3)
    ,Serie                  VARCHAR2(4)
    ,Folio                  NUMBER
    ,Despacho_Anticipado    VARCHAR2(2)
    ,Fecha_Ingreso          NUMBER
    ,Identi_Vendedor        VARCHAR2(30)
    ,Rut_Vendedor           NUMBER
    ,Dv_Vendedor            VARCHAR2(1)
    ,Identi_Cliente         VARCHAR2(30)
    ,Rut_Cliente            NUMBER
    ,Dv_Cliente             VARCHAR2(1)
    ,Nombre_Cliente         VARCHAR2(60)
    ,Identi_Paciente        VARCHAR2(30)
    ,Rut_Paciente           NUMBER
    ,Dv_Paciente            VARCHAR2(1)
    ,Nombre_Paciente        VARCHAR2(60)
    ,Telefono               VARCHAR2(30)
    ,Identi_Medico          VARCHAR2(30)
    ,Rut_Medico             NUMBER
    ,Dv_Medico              VARCHAR2(1)
    ,Nombre_Medico          VARCHAR2(60)
    ,Secuencia_b            NUMBER
    ,Secuencia_Receta       NUMBER
    ,Dv_Rut_Medico          VARCHAR2(1)
    ,Emision                NUMBER
    ,Diagnostico            VARCHAR2(15)
    ,Firma                  VARCHAR2(15)
    ,Tipo_Receta            VARCHAR2(3)
    ,Con_Copia              VARCHAR2(2)
    ,Folio_Receta           NUMBER
    ,Tipo_Medicamento       VARCHAR2(3)
    ,Fecha_Ingreso_Paciente NUMBER
    ,Fono_Paciente          VARCHAR2(15)
    ,Rut_Institucion        NUMBER
    ,Dv_Institucion         VARCHAR2(1)
    ,Lista_Productos        NUMBER
    ,Historial_Productos    NUMBER
    ,Subtrama_Rp1           Tab_Trama_Rp1
    ,Subtrama_Rp2           Tab_Trama_Rp2);

  TYPE Tab_Trama_Rp IS TABLE OF Rec_Trama_Rp INDEX BY BINARY_INTEGER;

  -- ============================================================
  -- DESARROLLO CUENTA CORRIENTE RECETA ( FIN )
  -- ============================================================
  TYPE Rec_Trama_Rpu IS RECORD(
     LOCAL           NUMBER
    ,Rut_Vendedor    NUMBER
    ,Dv_Rut_Vendedor VARCHAR2(1)
    ,Correlativo_Tx  NUMBER);

  TYPE Rec_Trama_Rr IS RECORD(
     Codigo_Autorizacion VARCHAR2(20)
    ,Tipo_Documento      VARCHAR2(6) --JRC
    ,Folio               NUMBER); --JRC

  --JRC 11/03/2020 Origen_Trx 'EMP' Excendemte al medio de pago
  --Se agregan a la trama RR campos Tipo de Documento y Folio
  TYPE Rec_Trama_Rr1 IS RECORD(
     Codigo_Autorizacion VARCHAR2(20)
    ,Tipo_Documento      VARCHAR2(6)
    ,Folio               NUMBER);

  TYPE Rec_Trama_Rs IS RECORD(
     Producto NUMBER);

  TYPE Rec_Trama_Rx IS RECORD(
     Codigo_Servicio VARCHAR2(1000)
    ,Rx              NUMBER
    ,Timespan        NUMBER
    ,Rx_Ack          VARCHAR2(1000)
    ,Rx_Nack         VARCHAR2(1000)
    ,Rx_Con_Servicio VARCHAR2(1000)
    ,Rx_Sin_Servicio VARCHAR2(1000)
    ,Rx_Timeout      VARCHAR2(1000)
    ,Rx_Erronea      VARCHAR2(1000));

  TYPE Tab_Trama_Rx IS TABLE OF Rec_Trama_Rx INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Rz IS RECORD(
     Secuencia_Receta NUMBER);

  TYPE Rec_Trama_Sc1 IS RECORD(
     Codigo_Producto_Interno    NUMBER
    ,Familia_Comercial          NUMBER
    ,Tope                       NUMBER
    ,Cantidad                   NUMBER
    ,Fecha_Transaccion          NUMBER
    ,Convenio_Compra_Frecuente  NUMBER
    ,Fecha_Expiracion           NUMBER
    ,Glosa_Reclamo              VARCHAR2(30)
    ,Porcentaje_Descuento       VARCHAR2(6)
    ,Signo                      VARCHAR2(1)
    ,Cantidad_Eventos_Beneficio NUMBER);

  TYPE Tab_Trama_Sc1 IS TABLE OF Rec_Trama_Sc1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Sc2 IS RECORD(
     Rut_Beneficiario      NUMBER
    ,Dv_Rut_Beneficiario   VARCHAR2(1)
    ,Titular               VARCHAR2(1)
    ,Copago                NUMBER
    ,Deducible_Evento      NUMBER
    ,Fecha_Nacimiento      NUMBER
    ,Convenio_Relacionado  NUMBER
    ,Convenio              NUMBER
    ,Sexo                  VARCHAR2(1)
    ,Accede_Dicc           VARCHAR2(1)
    ,Dv_Numero_Inscripcion VARCHAR2(1)
    ,Cupo_Total            NUMBER
    ,Numero_Cuenta         VARCHAR2(20));

  TYPE Tab_Trama_Sc2 IS TABLE OF Rec_Trama_Sc2 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Sc3 IS RECORD(
     Numero_Cuenta VARCHAR2(20));

  TYPE Tab_Trama_Sc3 IS TABLE OF Rec_Trama_Sc3 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Sc IS RECORD(
     Puntos                   NUMBER
    ,Minimo_Canje_Puntos      NUMBER
    ,Operaciones_Fidelizacion VARCHAR2(30)
    ,Cantidad_Productos       NUMBER
    ,Lista_Beneficiarios      NUMBER
    ,Cantidad_Cuotas          NUMBER
    ,Subtrama_Sc1             Tab_Trama_Sc1
    ,Subtrama_Sc2             Tab_Trama_Sc2
    ,Subtrama_Sc3             Tab_Trama_Sc3);

  TYPE Rec_Trama_Sp IS RECORD(
     LOCAL           NUMBER
    ,Tipo_Movimiento VARCHAR2(6)
    ,Folio           NUMBER);

  TYPE Rec_Trama_St IS RECORD(
     Tipo_Consulta VARCHAR2(3));

  TYPE Rec_Trama_Ta IS RECORD(
     Correlativo_Tx          NUMBER
    ,Puntos                  NUMBER
    ,Destino                 VARCHAR2(3)
    ,Correlativo_Tx_Asociado NUMBER);

  TYPE Rec_Trama_Te IS RECORD(
     Timespan       NUMBER
    ,Tx_Respuesta   VARCHAR2(1000)
    ,Tx_No_Enrutada VARCHAR2(1000)
    ,Tx_No_Existe   VARCHAR2(1000)
    ,Tx_Timeout     VARCHAR2(1000)
    ,Tx_Erronea     VARCHAR2(1000)
    ,Tx_Expirada    VARCHAR2(1000)
    ,Tx_Online      VARCHAR2(1000)
    ,Tx_Confirmada  VARCHAR2(1000)
    ,Tx_Nack        VARCHAR2(1000));

  TYPE Rec_Trama_Tm1 IS RECORD(
     Codigo_Producto  NUMBER
    ,Dias_Autorizados NUMBER
    ,Fecha_Inicio     NUMBER
    ,Fecha_Termino    NUMBER
    ,LOCAL            NUMBER
    ,Fecha_Compra     NUMBER);

  TYPE Tab_Trama_Tm1 IS TABLE OF Rec_Trama_Tm1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Tm IS RECORD(
     Convenio        NUMBER
    ,Plan            NUMBER
    ,Lista_Productos NUMBER
    ,Subtrama_Tm1    Tab_Trama_Tm1);

  TYPE Tab_Trama_Tm IS TABLE OF Rec_Trama_Tm INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Tp IS RECORD(
     Correlativo_Tx NUMBER
    ,Puntos         NUMBER
    ,Destino        VARCHAR2(3));

  TYPE Rec_Trama_Tx IS RECORD(
     Codigo_Servicio VARCHAR2(1000)
    ,Tx              NUMBER
    ,Timespan        NUMBER
    ,Tx_Respuesta    VARCHAR2(1000)
    ,Tx_No_Enrutada  VARCHAR2(1000)
    ,Tx_No_Existe    VARCHAR2(1000)
    ,Tx_Timeout      VARCHAR2(1000)
    ,Tx_Erronea      VARCHAR2(1000)
    ,Tx_Expirada     VARCHAR2(1000)
    ,Tx_Online       VARCHAR2(1000)
    ,Tx_Confirmada   VARCHAR2(1000)
    ,Tx_Nack         VARCHAR2(1000));

  TYPE Tab_Trama_Tx IS TABLE OF Rec_Trama_Tx INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Va1 IS RECORD(
     Diagnostico VARCHAR2(20));

  TYPE Tab_Trama_Va1 IS TABLE OF Rec_Trama_Va1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Va IS RECORD(
     Convenio                 NUMBER
    ,Plan                     NUMBER
    ,Rut_Titular              NUMBER
    ,Dv_Titular               VARCHAR2(1)
    ,Secuencia_b              NUMBER
    ,Codigo_Autorizacion      VARCHAR2(20)
    ,Precio_Lista             NUMBER(15, 4)
    ,Decimal_Plista           VARCHAR2(4)
    ,Bonificacion             NUMBER(15, 4)
    ,Decimal_Bonif_1          VARCHAR2(4)
    ,Bonificacion_2           NUMBER(15, 4)
    ,Decimal_Bonif_2          VARCHAR2(4)
    ,Copago                   NUMBER(15, 4)
    ,Decimal_Copago           VARCHAR2(4)
    ,Cantidad_Cuotas          NUMBER
    ,Monto_Copago_Ges         NUMBER(15, 4)
    ,Decimal_Copago_Ges       VARCHAR2(4)
    ,Numero_Boleta            VARCHAR2(15)
    ,Requiere_Id_Receta       VARCHAR2(2)
    ,Plan_Con_Guia            VARCHAR2(2)
    ,Identificador_Titular    VARCHAR2(30)
    ,Identificacion_Comprador VARCHAR2(30)
    ,Serie_Factura            VARCHAR2(50) -- LMP GPF Ecuador 2023
    ,Clave_Acceso             VARCHAR2(50) -- LMP GPF Ecuador 2023
    ,Id_Prestador             VARCHAR2(50) -- LMP GPF Ecuador 2023
    ,De_Mail                  VARCHAR2(50) -- LMP GPF Ecuador 2023
    ,Lista_Diagnosticos       NUMBER
    ,Subtrama_Va1             Tab_Trama_Va1);

  TYPE Rec_Trama_Vc IS RECORD(
     Correlativo_Tx NUMBER
    ,LOCAL          NUMBER);

  TYPE Rec_Trama_Vd1 IS RECORD(
     Secuencia_b          NUMBER
    ,Tipo_Movimiento_Hijo VARCHAR2(6)
    ,Anulado              VARCHAR2(2)
    ,Total_Iva_Incluido   NUMBER);

  TYPE Tab_Trama_Vd1 IS TABLE OF Rec_Trama_Vd1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Vd IS RECORD(
     Correlativo_Tx        NUMBER
    ,Tipo_Movimiento_Padre VARCHAR2(6)
    ,Fecha                 NUMBER
    ,Hora_Venta            NUMBER
    ,Secuencia_b           NUMBER
    ,Numero_Cuenta         VARCHAR2(19)
    ,Codigo_Autorizacion   VARCHAR2(20)
    ,Local_Relacionado     NUMBER
    ,Codigo_Servicio       VARCHAR2(3)
    ,LOCAL                 NUMBER
    ,Numero_Pos            NUMBER
    ,Destino               VARCHAR2(3)
    ,Sistema               VARCHAR2(3)
    ,Funcion               VARCHAR2(1)
    ,Secuencia_c           VARCHAR2(2)
    ,Fecha_Transaccion     NUMBER
    ,Correlativo           NUMBER
    ,Numero_Trama          NUMBER
    ,Codigo_Transaccion    VARCHAR2(6)
    ,Numero_Cuotas         NUMBER
    ,Fecha_Inicio_Tx       NUMBER
    ,Fecha_Cierre_Tx       NUMBER
    ,Documentos_Emitidos   NUMBER
    ,Subtrama_Vd1          Tab_Trama_Vd1);

  TYPE Rec_Trama_Ve IS RECORD(
     Tipo_Consulta VARCHAR2(50)
    ,String_01     VARCHAR2(1000)
    ,String_02     VARCHAR2(1000)
    ,String_03     VARCHAR2(1000)
    ,String_04     VARCHAR2(1000)
    ,String_05     VARCHAR2(1000));

  TYPE Rec_Trama_Vm IS RECORD(
     Codigo_Producto      NUMBER
    ,Descripcion_Producto VARCHAR2(50)
    ,Principio_Activo     VARCHAR2(50));

  TYPE Rec_Trama_Vn1 IS RECORD(
     Producto        NUMBER
    ,Cantidad        NUMBER
    ,Precio_Final    NUMBER
    ,Costo           NUMBER
    ,Codigo_Personal NUMBER
    ,Rut_Vendedor    NUMBER
    ,Dv_Rut_Vendedor VARCHAR2(1)
    ,Precio_Lista    NUMBER
    ,Codigo_Reclamo  NUMBER
    ,Motivo          VARCHAR2(6));

  TYPE Tab_Trama_Vn1 IS TABLE OF Rec_Trama_Vn1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Vn IS RECORD(
     Tipo_Movimiento_Padre   VARCHAR2(6)
    ,Tipo_Movimiento_Hijo    VARCHAR2(6)
    ,Folio                   VARCHAR2(20)
    ,Numero_Folio_Original   VARCHAR2(20)
    ,Fecha_Folio_Original    NUMBER
    ,Motivo                  VARCHAR2(2)
    ,Accion_Sobre_Existencia VARCHAR2(1)
    ,Fecha_Limite            NUMBER
    ,Hora_Limite             NUMBER
    ,Monto                   NUMBER(15, 4)
    ,Decimal_Monto           VARCHAR2(4)
    ,Cantidad_Productos      NUMBER
    ,Subtrama_Vn1            Tab_Trama_Vn1);

  TYPE Rec_Trama_Vr1 IS RECORD(
     Codigo_Producto NUMBER
    ,Aceptado        VARCHAR2(2));

  TYPE Tab_Trama_Vr1 IS TABLE OF Rec_Trama_Vr1 INDEX BY BINARY_INTEGER;

  -- ============================================================
  -- DESARROLLO DISPENSACI?N (JAGC 2024-03-20)
  -- ORIGEN DE TRANSACCI?N PARA DISPENSACI?N 'MSP'
  -- ============================================================
  TYPE Rec_Trama_Vr IS RECORD(
     Codigo_Autorizacion         VARCHAR2(20)
    ,Disponible                  NUMBER(15, 4)
    ,Decimal_Disponible          VARCHAR2(4)
    ,Disponible_Copago           NUMBER(15, 4)
    ,Decimal_Disp_Copago         VARCHAR2(4)
    ,Codigo_Autorizacion_Externo VARCHAR2(20)
    ,Interes                     NUMBER
    ,Vencimiento_Primera_Cuota   NUMBER
    ,Valor_Primera_Cuota         NUMBER(15, 4)
    ,Decimal_Primera_Cuota       VARCHAR2(4)
    ,Numero_Liquidacion          NUMBER
    ,Id_Receta                   VARCHAR2(128) --CAMBIO TRAMA POR ORIGEN MSP; ORIGINAL: NUMBER
    ,Cantidad_Producto           NUMBER
    --,Cod_Respuesta               NUMBER               -- LMP GPF Ecuador 2023
    --,Mensaje_Respuesta           VARCHAR2(250)        -- LMP GPF Ecuador 2023
    ,Subtrama_Vr1 Tab_Trama_Vr1);
  -- ============================================================

  TYPE Rec_Trama_Vs1 IS RECORD(
     Guia_Electronica     VARCHAR2(30)
    ,Producto             NUMBER
    ,Cantidad             NUMBER
    ,Motivo               VARCHAR2(6)
    ,Precio_Final         NUMBER
    ,DECIMAL_PRECIO_FINAL VARCHAR2(4) --JAGC 20250414 ORIGEN FGI
    ,Numero_Item          NUMBER --JAGC 20250414 ORIGEN FGI   
    );

  TYPE Tab_Trama_Vs1 IS TABLE OF Rec_Trama_Vs1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Vs IS RECORD(
     Tipo_Movimiento_Padre   VARCHAR2(6)
    ,Tipo_Movimiento_Hijo    VARCHAR2(6)
    ,Folio                   NUMBER
    ,Numero_Pedido           VARCHAR2(30)
    ,Guia_Despacho           VARCHAR2(30)
    ,Tipo_Guia_Despacho      VARCHAR2(1)
    ,Accion_Sobre_Existencia VARCHAR2(1)
    ,Codigo_Local_Socofar    NUMBER
    ,Numero_Reclamo          NUMBER
    ,Fecha_Reclamo           NUMBER
    ,Dfi_Numero_Asignacion   NUMBER
    ,Matricula_Bulto         NUMBER
    ,Monto                   NUMBER
    ,DECIMAL_MONTO           VARCHAR2(4) --JAGC 20250414 ORIGEN FGI
    ,Rut_Proveedor           NUMBER
    ,Sello_Seguro_Uno        NUMBER
    ,Sello_Seguro_Dos        NUMBER
    ,NUMERO_FACTURA          VARCHAR2(30) --JAGC 20250414 ORIGEN FGI
    ,FOLIO_INGRESO           NUMBER --JAGC 20250414 ORIGEN FGI 
    ,Cantidad_Productos      NUMBER
    ,Subtrama_Vs1            Tab_Trama_Vs1);

  TYPE Rec_Trama_Vt IS RECORD(
     Tipo_Movimiento_Hijo VARCHAR2(6)
    ,Folio                NUMBER
    ,LOCAL                NUMBER);

  TYPE Rec_Trama_Za IS RECORD(
     Convenio                    NUMBER
    ,Plan                        NUMBER
    ,Secuencia_b                 NUMBER
    ,Codigo_Autorizacion         VARCHAR2(20)
    ,Monto                       NUMBER
    ,Cantidad_Cuotas             NUMBER
    ,Interes                     NUMBER
    ,Codigo_Autorizacion_Externo VARCHAR2(20));

  TYPE Rec_Trama_Zc IS RECORD(
     Correlativo_Tx          NUMBER
    ,Puntos                  NUMBER
    ,Correlativo_Tx_Asociado NUMBER);

  TYPE Rec_Trama_Zj IS RECORD(
     Correlativo_Tx NUMBER
    ,Puntos         NUMBER);

  TYPE Rec_Trama_Zp IS RECORD(
     Correlativo_Tx NUMBER
    ,Puntos         NUMBER);

  TYPE Rec_Trama_Zr IS RECORD(
     Convenio                       NUMBER
    ,Plan                           NUMBER
    ,Secuencia_Titular_Beneficiario NUMBER
    ,Codigo_Autorizacion            VARCHAR2(20)
    ,Monto                          NUMBER
    ,Cantidad_Cuotas                NUMBER
    ,Codigo_Autorizacion_Origen     VARCHAR2(20));

  TYPE Rec_Data_Com IS RECORD(
     Version_Header_Primaria       NUMBER
    ,Version_Header_Secundaria     NUMBER
    ,Version_Pos                   VARCHAR2(15) := 'nil'
    ,Version_Mensajeria_Primaria   NUMBER := 0
    ,Version_Mensajeria_Secundaria NUMBER := 0
    ,Empresa                       NUMBER
    ,Cadena                        NUMBER
    ,Numero_Local                  NUMBER
    ,Numero_Pos                    NUMBER
    ,Destino                       VARCHAR2(3)
    ,Tipo_Transmision              VARCHAR2(1)
    ,Sistema                       VARCHAR2(3)
    ,Funcion                       VARCHAR2(1)
    ,Secuencia                     VARCHAR2(2)
    ,Fecha_Contable                NUMBER
    ,Fecha_Hora_Proceso            NUMBER
    ,Fecha_Hora_Tx                 NUMBER
    ,Fecha_Hora_Rx                 NUMBER
    ,Correlativo                   NUMBER
    ,Tipo_Envio                    VARCHAR2(1)
    ,Empresa_Destino               NUMBER
    ,Cadena_Destino                NUMBER
    ,Local_Destino                 NUMBER
    ,Ttl                           NUMBER
    ,Origen_Transaccion            VARCHAR2(3));

  TYPE Rec_Trama_Gc IS RECORD(
     Accion           VARCHAR2(1)
    ,Numero_Guia      NUMBER
    ,Numero_Matricula NUMBER);

  TYPE Tab_Trama_Gc IS TABLE OF Rec_Trama_Gc INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Gr IS RECORD(
     Tipo_Cubeta      VARCHAR2(3)
    ,Fecha_Recepcion  NUMBER
    ,Fecha_Disponible NUMBER
    ,Numero_Matricula NUMBER
    ,Numero_Guia      NUMBER);

  TYPE Tab_Trama_Gr IS TABLE OF Rec_Trama_Gr INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Ic IS RECORD(
     Numero_Guia      NUMBER
    ,Numero_Matricula NUMBER
    ,Tipo_Cubeta      VARCHAR2(3)
    ,Fecha_Generacion NUMBER);

  TYPE Tab_Trama_Ic IS TABLE OF Rec_Trama_Ic INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Bt IS RECORD(
     Numero_Matricula NUMBER);

  TYPE Rec_Trama_Mb IS RECORD(
     Numero_Matricula NUMBER
    ,Tipo_Movimiento  VARCHAR2(6)
    ,Local_Origen     NUMBER
    ,Local_Destino    NUMBER
    ,Rut              NUMBER
    ,Nombre_Servidor  VARCHAR2(10)
    ,Fecha_Generacion NUMBER);

  TYPE Tab_Trama_Mb IS TABLE OF Rec_Trama_Mb INDEX BY BINARY_INTEGER;

  /* CGC 20/07/2011 */
  TYPE Rec_Trama_Mc1 IS RECORD(
     Secuencia            NUMBER
    ,Tipo_Movimiento      VARCHAR2(6)
    ,Anulado              VARCHAR2(2)
    ,Monto                NUMBER(15, 4)
    ,Decimal_Monto        VARCHAR2(4)
    ,Folio                NUMBER
    ,Estado               VARCHAR2(2)
    ,Fecha_Regularizacion NUMBER);

  TYPE Tab_Trama_Mc1 IS TABLE OF Rec_Trama_Mc1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Mc IS RECORD(
     Correlativo             NUMBER
    ,Tipo_Movimiento_Padre   VARCHAR2(6)
    ,Fecha                   NUMBER
    ,Hora                    NUMBER
    ,Identi_Titular          VARCHAR2(30)
    ,Rut_Titular             NUMBER
    ,Dv_Titular              VARCHAR2(1)
    ,Fecha_Generacion        NUMBER
    ,Registro_Electronico    VARCHAR2(2)
    ,Correlativo_Tx          NUMBER
    ,Cant_Remesas_Depo       NUMBER(15, 4)
    ,Decimal_Cant_Remesas    VARCHAR2(4)
    ,Monto_No_Depositado     NUMBER(15, 4)
    ,Decimal_Mto_No_Depo     VARCHAR2(4)
    ,Cant_Remesas_No_Depo    NUMBER(15, 4)
    ,Decimal_Remesas_No_Depo VARCHAR2(4)
    ,Cantidad_Documentos     NUMBER
    ,Subtrama_Mc1            Tab_Trama_Mc1);

  TYPE Rec_Trama_Gd1 IS RECORD(
     Correlativo         NUMBER
    ,Tipo_Remesa         VARCHAR2(6)
    ,Cant_Doctos_Remesa  NUMBER
    ,Monto_Remesa        NUMBER(15, 4)
    ,Decimal_Mto_Remesa  VARCHAR2(4)
    ,Validada            VARCHAR2(2)
    ,Tipo_Validacion     VARCHAR2(3)
    ,Codigo_Barra_Remesa VARCHAR2(20));

  TYPE Tab_Trama_Gd1 IS TABLE OF Rec_Trama_Gd1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Gd IS RECORD(
     Codigo_Deposito      VARCHAR2(6)
    ,Monto_Deposito       NUMBER(15, 4)
    ,Decimal_Mto_Deposito VARCHAR2(4)
    ,Numero_Colilla       NUMBER
    ,Registro_Recepcion_1 VARCHAR2(100)
    ,Registro_Recepcion_2 VARCHAR2(100)
    ,Registro_Devolucion  VARCHAR2(100)
    ,Cantidad_Documentos  NUMBER
    ,Subtrama_Gd1         Tab_Trama_Gd1);

  TYPE Tab_Trama_Gd IS TABLE OF Rec_Trama_Gd INDEX BY BINARY_INTEGER;
  -----------------------------
  TYPE Rec_Trama_Gp1 IS RECORD(
     Codigo_Producto NUMBER
    ,Cantidad        NUMBER);

  TYPE Tab_Trama_Gp1 IS TABLE OF Rec_Trama_Gp1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Gp IS RECORD(
     Fecha_Hora_Emision          NUMBER
    ,Local_Origen                NUMBER
    ,Nombre_Origen               VARCHAR2(100)
    ,Local_Destino               NUMBER
    ,Nombre_Destino              VARCHAR2(100)
    ,Folio                       VARCHAR2(20)
    ,Guia_Despacho               VARCHAR2(30)
    ,Fecha_Hora_Traspaso         NUMBER
    ,Cantidad_Productos_Traspaso NUMBER --JRC 27/04/2023 Solo menciona cantidad, sin detalle de prod
    ,Cantidad_Productos          NUMBER
    ,Subtrama_Gp1                Tab_Trama_Gp1);

  TYPE Tab_Trama_Gp IS TABLE OF Rec_Trama_Gp INDEX BY BINARY_INTEGER;
  -------------------------------
  TYPE Rec_Trama_Id IS RECORD(
     Fecha           NUMBER
    ,Codigo_Producto NUMBER
    ,Descriptor      VARCHAR2(150)
    ,Kardex          NUMBER
    ,Signo           VARCHAR2(1)
    ,Cuenta          NUMBER
    ,Costo           NUMBER);

  TYPE Tab_Trama_Id IS TABLE OF Rec_Trama_Id INDEX BY BINARY_INTEGER;

  -------------------------------------------------------------------------
  --Trama IN 2023 LMP Ecuador para nuevos campos en reporte IRD
  -------------------------------------------------------------------------
  TYPE Rec_Trama_In_Res IS RECORD(
     Numero_Conteo      NUMBER
    ,Tipo_Ird           VARCHAR2(3)
    ,Grupo              VARCHAR2(1)
    ,Fecha_Finalizacion NUMBER
    ,Cant_Discrepancias NUMBER
    ,Stock_0            NUMBER
    );

  TYPE Tab_Trama_In_Res IS TABLE OF Rec_Trama_In_Res INDEX BY BINARY_INTEGER;
  
  --INI JAGC 20240909 NECESIDADES 'NEC'  
  -------------------------------------------------------------------------
  --Trama IN 2024 JAGC Producto Inscrito a Necesidad
  -------------------------------------------------------------------------  
  TYPE Rec_Trama_In IS RECORD(
    Codigo_Producto                    VARCHAR2(20)
    ,unidadesAcumuladasCtaCte           NUMBER
    ,montoProximoDescuento              NUMBER
    ,tipoProximoDescuento               VARCHAR2(1)
    ,unidadesAcumuladasMensuales        NUMBER
    ,fechaInscripcion                   NUMBER
    ,limiteUnidadesTx                   NUMBER
    ,limiteUnidadesMensuales            NUMBER
    ,fechaExpiracionProducto            NUMBER
    ,estado                             VARCHAR2(3)
    ,idNecesidad                        NUMBER
    ,descripcionNecesidad               VARCHAR2(50)
    ,nombreNecesidad                    VARCHAR2(30)
    );
  
  TYPE Tab_Trama_In IS TABLE OF Rec_Trama_In INDEX BY BINARY_INTEGER;
  
  -------------------------------------------------------------------------
  --Trama IB 2024 JAGC Inscripci?n Producto a Beneficio Necesidad
  -------------------------------------------------------------------------  
  TYPE Rec_Trama_Ib IS RECORD(
    idNecesidad                        NUMBER
    ,Codigo_Producto                    VARCHAR2(20)
    ,FechaHoraInscripcion              NUMBER                      
    ,IdVendedor                        VARCHAR2(10)
    ,NombreVendedor                    VARCHAR2(30)
    ,Canal                             VARCHAR2(3)
    );
    
  TYPE Tab_Trama_Ib IS TABLE OF Rec_Trama_Ib INDEX BY BINARY_INTEGER;  
  --FIN JAGC 20240909 NECESIDADES 'NEC'


  TYPE Rec_Trama_Ir IS RECORD(
     Fecha           NUMBER
    ,Codigo_Producto NUMBER
    ,Descriptor      VARCHAR2(150)); --JRC 14/08/2023 de 100 a 150 por caracteres compuestos

  TYPE Tab_Trama_Ir IS TABLE OF Rec_Trama_Ir INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Is IS RECORD(
     Institucion_Isapre VARCHAR2(3)
    ,Numero_Preventa    NUMBER
    ,Numero_Campana     NUMBER);

  TYPE Tab_Trama_Is IS TABLE OF Rec_Trama_Is INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Lp IS RECORD(
     Tipo_Guia       NUMBER
    ,Numero_Pedido   NUMBER
    ,Codigo_Producto NUMBER
    ,Cantidad        NUMBER
    ,Cantidad_Nueva  NUMBER
    ,Bulto_Destino   NUMBER
    ,Bulto_Origen    NUMBER
    ,Fecha           NUMBER
    ,Descriptor      VARCHAR2(50)
    ,Codigo_Personal NUMBER
    ,Rut_Responsable NUMBER);

  TYPE Tab_Trama_Lp IS TABLE OF Rec_Trama_Lp INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Iv IS RECORD(
     Tipo_Propiedad             VARCHAR2(03)
    ,Numero_Manifiesto          NUMBER
    ,Numero_Pedido              NUMBER
    ,Rut_Personal               NUMBER
    ,Total_Pedido               NUMBER
    ,Total_Bultos               NUMBER
    ,Total_Bultos_Opticon       NUMBER
    ,Total_Bultos_Aplicacion    NUMBER
    ,Total_Bultos_Digitados     NUMBER
    ,Tiempo_1                   NUMBER
    ,Tiempo_2                   NUMBER
    ,Total_Unidades             NUMBER
    ,Total_Sku                  NUMBER
    ,Unidades_Scf               NUMBER
    ,Unidades_Fcv               NUMBER
    ,Unidades_Recepcionadas_Scf NUMBER
    ,Unidades_Recepcionadas_Fcv NUMBER
    ,Fecha_Inicio_Revision      NUMBER
    ,Fecha_Fin_Revision         NUMBER
    ,Tipo_Cargo                 VARCHAR2(03));

  TYPE Tab_Trama_Iv IS TABLE OF Rec_Trama_Iv INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Tg IS RECORD(
     Numero_Guia   NUMBER
    ,Numero_Pedido NUMBER
    ,Total         NUMBER
    ,Fecha         NUMBER);

  TYPE Tab_Trama_Tg IS TABLE OF Rec_Trama_Tg INDEX BY BINARY_INTEGER;
  --FCG 191022 Totales Locales
  TYPE Rec_Trama_Tl IS RECORD(
     Clave_Poliza         VARCHAR2(3)
    ,Moneda               VARCHAR2(3)
    ,Forma_Pago           VARCHAR2(1)
    ,Monto                NUMBER(15, 4)
    ,Monto_Decimal        VARCHAR2(4)
    ,Monto_Conversion     NUMBER(15, 4)
    ,Signo                VARCHAR2(1)
    ,Monto_Dec_Conversion VARCHAR2(4));

  TYPE Tab_Trama_Tl IS TABLE OF Rec_Trama_Tl INDEX BY BINARY_INTEGER;

  --FCG 191022 Totales Generales
  TYPE Rec_Trama_Tf IS RECORD(
     Tipo_Total              VARCHAR2(2)
    ,Monto_Total             NUMBER(15, 4)
    ,Monto_Total_Decimal     VARCHAR2(4)
    ,Signo                   VARCHAR2(1)
    ,Identificacion_Vendedor VARCHAR2(30));

  TYPE Tab_Trama_Tf IS TABLE OF Rec_Trama_Tf INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Nd1 IS RECORD(
     Num_Item   NUMBER
    ,Folio_Dicc NUMBER
    ,Monto_Dicc NUMBER);

  TYPE Tab_Trama_Nd1 IS TABLE OF Rec_Trama_Nd1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Tt IS RECORD(
     Numero_Tarjeta VARCHAR2(15)
    ,Patente        VARCHAR2(10)
    ,Estado         VARCHAR2(6));

  TYPE Tab_Trama_Tt IS TABLE OF Rec_Trama_Tt INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Nd IS RECORD(
     Folio          NUMBER
    ,Tipo_Nomina    VARCHAR2(3)
    ,Fecha_Nomina   NUMBER
    ,Rut_Supervisor NUMBER
    ,Dv_Supervisor  VARCHAR2(1)
    ,Estado_Nomina  VARCHAR2(3)
    ,Fecha_Estado   NUMBER
    ,Monto_Nomina   NUMBER
    ,Cantidad_Items NUMBER
    ,Subtrama_Nd1   Tab_Trama_Nd1);

  TYPE Tab_Trama_Nd IS TABLE OF Rec_Trama_Nd INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Ap IS RECORD(
     Correlativo  NUMBER
    ,Codigo_Parte VARCHAR2(15)
    ,Fecha        NUMBER
    ,Estado       VARCHAR2(3)
    ,Glosa        VARCHAR2(250));

  TYPE Tab_Trama_Ap IS TABLE OF Rec_Trama_Ap INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Mg1 IS RECORD(
     Codigo_Insumo          NUMBER
    ,Cantidad_Parte_Entera  NUMBER
    ,Cantidad_Parte_Decimal NUMBER
    ,Unidad_Medida          NUMBER
    ,Excipiente             VARCHAR2(1));

  TYPE Tab_Trama_Mg1 IS TABLE OF Rec_Trama_Mg1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Mg IS RECORD(
     Secuencia_Receta      NUMBER
    ,Tipo_Preparado        VARCHAR2(3)
    ,Unidad_Medida         NUMBER
    ,Cantidad              NUMBER
    ,Volumen_Parte_Entera  NUMBER
    ,Volumen_Parte_Decimal NUMBER
    ,Cantidad_Insumos      NUMBER
    ,Subtrama_Mg1          Tab_Trama_Mg1);

  TYPE Rec_Trama_Oc IS RECORD(
     Numero_Orden_Trabajo VARCHAR2(14)
    ,Fecha_Hasta          NUMBER
    ,Valor_Total          NUMBER
    ,Local_Recetario      NUMBER
    ,Fecha_Compromiso     NUMBER);

  TYPE Rec_Trama_Or IS RECORD(
     Numero_Orden_Trabajo          VARCHAR2(14)
    ,Secuencia_Receta              NUMBER
    ,Fecha_Receta                  NUMBER
    ,Serie_Cheque                  VARCHAR2(4)
    ,Numero_Cheque                 NUMBER
    ,Rut_Medico                    NUMBER
    ,Digito_Verificador_Medico     VARCHAR2(1)
    ,Nombre_Medico                 VARCHAR2(30)
    ,Rut_Paciente                  NUMBER
    ,Digito_Verificador_Paciente   VARCHAR2(1)
    ,Nombre_Paciente               VARCHAR2(30)
    ,Direccion_Paciente            VARCHAR2(40)
    ,Telefono                      VARCHAR2(10)
    ,Rut_Adquirente                NUMBER
    ,Digito_Verificador_Adquirente VARCHAR2(1)
    ,Nombre_Adquirente             VARCHAR2(30)
    ,Monto_Abono                   NUMBER
    ,Fecha_Abono                   NUMBER
    ,Descuento                     VARCHAR2(2)
    ,Retiro                        VARCHAR2(3)
    ,LOCAL                         NUMBER
    ,Observacion                   VARCHAR2(200)
    ,Codigo_Vendedor               NUMBER
    ,Nombre_Vendedor               VARCHAR2(100)
    ,Codigo_Qf                     NUMBER
    ,Nombre_Qf                     VARCHAR2(100));

  TYPE Rec_Trama_Ro1 IS RECORD(
     Numero_Orden_Trabajo VARCHAR2(14)
    ,Total_Envases        NUMBER);

  TYPE Tab_Trama_Ro1 IS TABLE OF Rec_Trama_Ro1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Ro IS RECORD(
     Cantidad_Ordenes_Trabajo NUMBER
    ,Subtrama_Ro1             Tab_Trama_Ro1);

  TYPE Rec_Trama_Do IS RECORD(
     Numero_Orden_Trabajo VARCHAR2(14)
    ,Codigo_Respuesta     NUMBER
    ,Glosa_Respuesta      VARCHAR2(80)
    ,Secuencia_Receta     NUMBER
    ,Fecha_Hora_Estado    NUMBER
    ,Estado               VARCHAR2(6)
    ,Numero_Rp            NUMBER
    ,Fecha_Vencimiento    NUMBER
    ,Monto_Abono          NUMBER
    ,Valor_Total          NUMBER
    ,Costo_Total          NUMBER
    ,Retiro               VARCHAR2(3)
    ,LOCAL                NUMBER
    ,Tipo_Recepcion       VARCHAR2(3)
    ,Total_Envases        NUMBER);

  TYPE Tab_Trama_Do IS TABLE OF Rec_Trama_Do INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Ot1 IS RECORD(
     Numero_Orden_Trabajo VARCHAR2(14));

  TYPE Tab_Trama_Ot1 IS TABLE OF Rec_Trama_Ot1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Ot IS RECORD(
     Cantidad_Ordenes_Trabajo NUMBER
    ,Subtrama_Ot1             Tab_Trama_Ot1);

  ---------------------------------------------------
  TYPE Rec_Trama_Aa IS RECORD(
     Tipo_Auditoria VARCHAR2(6)
    ,Rut_Supervisor NUMBER
    ,Dv_Supervisor  VARCHAR2(1)
    ,Rut_Vendedor   NUMBER
    ,Dv_Vendedor    VARCHAR2(1)
    ,Ip_Origen      VARCHAR2(15));

  TYPE Rec_Trama_Al IS RECORD(
     Tipo_Auditoria     VARCHAR2(6)
    ,Rut_Supervisor     NUMBER
    ,Dv_Supervisor      VARCHAR2(1)
    ,Rut_Vendedor       NUMBER
    ,Dv_Vendedor        VARCHAR2(1)
    ,Rut_Cliente        NUMBER
    ,Dv_Cliente         VARCHAR2(1)
    ,Alerta             VARCHAR2(50)
    ,Motivo             VARCHAR2(50)
    ,Nro_Veces          NUMBER
    ,Nro_Documento      NUMBER
    ,Producto           NUMBER
    ,Fecha_Captura      NUMBER
    ,Fecha_Autorizacion NUMBER
    ,Resultado          VARCHAR2(20));

  TYPE Rec_Trama_Pv IS RECORD(
     Tipo_Auditoria  VARCHAR2(6)
    ,Numero_Preventa NUMBER
    ,Rut_Vendedor    NUMBER
    ,Dv_Vendedor     VARCHAR2(1)
    ,Producto        NUMBER);

  TYPE Tab_Trama_Pv IS TABLE OF Rec_Trama_Pv INDEX BY BINARY_INTEGER;

  ---------------------------------------------------
  TYPE Rec_Trama_Sl IS RECORD(
     Codigo_Producto         NUMBER
    ,Precio_Lista            NUMBER
    ,Fecha_Act_Precio_Lista  NUMBER
    ,Precio_Oferta           NUMBER
    ,Fecha_Act_Precio_Oferta NUMBER
    ,Cam_Precio_Oferta       NUMBER
    ,Cantidad                NUMBER
    ,Precio_Costo            NUMBER);

  TYPE Tab_Trama_Sl IS TABLE OF Rec_Trama_Sl INDEX BY BINARY_INTEGER;

  ---------------------------------------------------
  TYPE Rec_Trama_Sf1 IS RECORD(
     Pro_Codigo_Interno   NUMBER(10)
    ,Signo                VARCHAR2(1)
    ,Unidades             NUMBER(10)
    ,Precio_Costo         NUMBER(15, 4)
    ,Decimal_Precio_Costo VARCHAR2(4)
    ,Unidad_Empaque       NUMBER(5));

  TYPE Tab_Trama_Sf1 IS TABLE OF Rec_Trama_Sf1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Sf IS RECORD(
     Folio_Actualizacion NUMBER(15)
    ,Fecha_Actualizacion NUMBER(15)
    ,Cantidad_Productos  NUMBER
    ,Subtrama_Sf1        Tab_Trama_Sf1);

  --  TYPE Tab_Trama_Sf IS TABLE OF Rec_Trama_Sf INDEX BY BINARY_INTEGER;
  ---------------------------------------------------

  TYPE Rec_Trama_Px1 IS RECORD(
     Codigo_Producto NUMBER
    ,Cantidad        NUMBER
    ,Excedente       VARCHAR2(2)
    ,Monto           NUMBER);

  TYPE Tab_Trama_Px1 IS TABLE OF Rec_Trama_Px1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Px IS RECORD(
     Rut_Cliente_Perfil NUMBER
    ,Cantidad_Productos NUMBER
    ,Subtrama_Px1       Tab_Trama_Px1);

  ---------------------------------------------------
  TYPE Rec_Trama_Ex1 IS RECORD(
     Codigo_Producto NUMBER
    ,Excedente       VARCHAR2(2));

  TYPE Tab_Trama_Ex1 IS TABLE OF Rec_Trama_Ex1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Ex IS RECORD(
     Error_Codigo         NUMBER
    ,Error_Descripcion    VARCHAR2(100)
    ,Saldo                NUMBER
    ,Saldo_Exceso         NUMBER
    ,Cod_Autorizacion_Fcv VARCHAR2(20)
    ,Cod_Autorizacion_Ext VARCHAR2(20)
    ,Cantidad_Productos   NUMBER
    ,Subtrama_Ex1         Tab_Trama_Ex1);

  /* ============================================================
   DESARROLLO CUENTA CORRIENTE RECETA (CGC 16-12-2015)
  ============================================================*/
  TYPE Rec_Trama_Rv1 IS RECORD(
     Producto         NUMBER
    ,Cantidad         NUMBER(15, 4)
    ,Decimal_Cantidad VARCHAR2(4));

  TYPE Tab_Trama_Rv1 IS TABLE OF Rec_Trama_Rv1 INDEX BY BINARY_INTEGER;

  -- ============================================================
  -- DESARROLLO DISPENSACI?N (JAGC 2024-03-20)
  -- ORIGEN DE TRANSACCI?N PARA DISPENSACI?N 'MSP'
  -- ============================================================
  TYPE Rec_Trama_Rv IS RECORD(
     Id_Receta       VARCHAR2(128) --CAMBIO TRAMA POR ORIGEN MSP; ORIGINAL: NUMBER
    ,Convenio        NUMBER
    ,Plan            NUMBER
    ,Folio           VARCHAR2(50)
    ,Lista_Productos NUMBER
    ,Subtrama_Rv1    Tab_Trama_Rv1);

  TYPE Tab_Trama_Rv IS TABLE OF Rec_Trama_Rv INDEX BY BINARY_INTEGER;
  -- ============================================================

  TYPE Rec_Trama_Br IS RECORD(
     Id_Receta    NUMBER
    ,Rut_Paciente NUMBER
    ,Dv_Paciente  VARCHAR2(1)
    ,Convenio     NUMBER
    ,Plan         NUMBER);

  TYPE Rec_Trama_Ri1 IS RECORD(
     Producto     NUMBER
    ,Cantidad     NUMBER
    ,Dosis        NUMBER
    ,Veces        NUMBER
    ,Dias         NUMBER
    ,Permanente   VARCHAR2(2)
    ,Indicaciones VARCHAR2(200)
    ,Retiro       NUMBER);

  TYPE Tab_Trama_Ri1 IS TABLE OF Rec_Trama_Ri1 INDEX BY BINARY_INTEGER;

  -- ============================================================
  -- DESARROLLO DISPENSACI?N (JAGC 2024-03-20)
  -- ORIGEN DE TRANSACCI?N PARA DISPENSACI?N 'MSP'
  -- ============================================================
  TYPE Rec_Trama_Ri IS RECORD(
     Id_Receta          VARCHAR2(128) --CAMBIO TRAMA POR ORIGEN MSP; ORIGINAL: NUMBER
    ,Copia_Verde        VARCHAR2(2)
    ,Secuencia_Receta   VARCHAR2(128) --CAMBIO TRAMA POR ORIGEN MSP; ORIGINAL: NUMBER
    ,Serie              VARCHAR2(4)
    ,Folio              NUMBER
    ,Fecha_Emision      NUMBER
    ,Identi_Cliente     VARCHAR2(30)
    ,Rut_Cliente        NUMBER
    ,Dv_Cliente         VARCHAR2(1)
    ,Nombre_Cliente     VARCHAR2(60)
    ,Identi_Paciente    VARCHAR2(30)
    ,Rut_Paciente       NUMBER
    ,Dv_Paciente        VARCHAR2(1)
    ,Nombre_Paciente    VARCHAR2(60)
    ,Telefono           VARCHAR2(30)
    ,Identi_Medico      VARCHAR2(30)
    ,Rut_Medico         NUMBER
    ,Dv_Medico          VARCHAR2(1)
    ,Nombre_Medico      VARCHAR2(60)
    ,Identi_Institucion VARCHAR2(30)
    ,Rut_Institucion    NUMBER
    ,Dv_Institucion     VARCHAR2(1)
    ,Nombre_Institucion VARCHAR2(30)
    ,Lista_Productos    NUMBER
    ,Subtrama_Ri1       Tab_Trama_Ri1);
  -- ============================================================

  -- ============================================================
  -- DESARROLLO CUENTA CORRIENTE RECETA ( FIN )
  -- ============================================================

  --//--------------------------------------------------------------------------\\
  --// CBR 04/13/2020 12:03PM                                                   \\
  --// Validacion numero de serie en Biometria                                  \\
  --//-----------------------------------------------------------------Inicio---\\
  TYPE Rec_Trama_Ns IS RECORD(
     Trace                          NUMBER
    ,Correlativo_Tx                 NUMBER
    ,Tipo_Tx                        VARCHAR2(3)
    ,Fecha_Hora_Validacion          NUMBER
    ,Rut_Cliente                    NUMBER
    ,Dv_Rut_Cliente                 VARCHAR2(1)
    ,Validacion_Biometria           VARCHAR2(2)
    ,Codigo_Validacion_Biometria    VARCHAR2(20)
    ,Descrip_Validacion_Biometria   VARCHAR2(50)
    ,Validacion_Nro_Serie_Cedula    VARCHAR2(2)
    ,Serie_Dcto_Ingresado           VARCHAR2(15)
    ,Codigo_Validacion_Serie_Cedula VARCHAR2(20)
    ,Descrip_Validacion_Cedula      VARCHAR2(50)
    ,Resultado_Firma_Electronica    VARCHAR2(20)
    ,Mensaje_Firma_Electronica      VARCHAR2(50)
    ,Json_Utilizado                 VARCHAR2(800)
    ,Codigo_Dec                     VARCHAR2(20)
    ,Resultado_Digitalizacion       VARCHAR2(20)
    ,Documentos_Postergados         VARCHAR2(20)
    ,Ticket_Postergacion_Digital    NUMBER);

  TYPE Tab_Trama_Ns IS TABLE OF Rec_Trama_Ns INDEX BY BINARY_INTEGER;
  --//-----------------------------------------------------------------Termino--\\

  -- Consulta Estado retencion GNCC15
  TYPE Rec_Trama_Vv IS RECORD(
     Tipo_Retencion VARCHAR2(3)
    ,Numero_Factura NUMBER
    ,Fecha_Factura  NUMBER);

  TYPE Tab_Trama_Vv IS TABLE OF Rec_Trama_Vv INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Vz IS RECORD(
     Tipo_Retencion   VARCHAR2(3)
    ,Numero_Factura   NUMBER
    ,Fecha_Factura    NUMBER
    ,Numero_Retencion NUMBER
    ,Monto            NUMBER(15, 4)
    ,Decimal_Monto    VARCHAR2(4)
    ,Fecha_Retencion  NUMBER
    ,Retencion_Pagada VARCHAR2(2));

  TYPE Tab_Trama_Vz IS TABLE OF Rec_Trama_Vz INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Vx1 IS RECORD(
     Secuencia            NUMBER
    ,Tipo_Movimiento_Hijo VARCHAR2(6)
    ,Tipo_Retencion       VARCHAR2(3)
    ,Numero_Factura       VARCHAR2(20) -- NUMBER -- VARCHAR2(15)
    ,Numero_Retencion     NUMBER
    ,Monto                NUMBER(15, 4)
    ,Decimal_Monto        VARCHAR2(4));

  TYPE Tab_Trama_Vx1 IS TABLE OF Rec_Trama_Vx1 INDEX BY BINARY_INTEGER;

  TYPE Rec_Trama_Vx IS RECORD(
     Correlativo_Tx        NUMBER
    ,Tipo_Movimiento_Padre VARCHAR2(6)
    ,Fecha                 NUMBER
    ,Hora_Retencion        NUMBER
    ,LOCAL                 NUMBER
    ,Numero_Pos            NUMBER
    ,Documentos_Emitidos   NUMBER
    ,Subtrama_Vx1          Tab_Trama_Vx1);

  TYPE Tab_Trama_Vx IS TABLE OF Rec_Trama_Vx INDEX BY BINARY_INTEGER;

END Scfr_Trx_Dyn_Types_Pk;
/
