CREATE OR REPLACE PACKAGE TRX3.Scfr_Trx_Fid_Pk IS

  -- Author      : USER_PIVOT2
  -- Modified by : JESUS GUERRA CEDEÑO 
  -- Modified    : 12/05/2026
  -- Purpose     : inclusión origen transaccion ONS

  Vversion VARCHAR2(25) := 'GEO.09.09.2024';

  FUNCTION Version_Pkg RETURN VARCHAR2;

  g_Party_Id_Ebso NUMBER;

  k_Error_Ebso CONSTANT VARCHAR2(50) := 'APIS EBSO NO ENCONTRADAS';

  -- Formas de Identificacion
  k_Por_Rut CONSTANT VARCHAR2(1) := 'R';

  k_Por_Banda_Magnetica CONSTANT VARCHAR2(1) := 'B';

  k_Por_Codigo_Barra CONSTANT VARCHAR2(1) := 'P';

  k_Por_Codigo_Convenio CONSTANT VARCHAR2(1) := 'C';

  k_Por_Tcv_Solventa CONSTANT VARCHAR2(1) := 'T';

  k_Sin_Identificacion CONSTANT VARCHAR2(1) := 'S';

  -- Tipos de Direccion
  k_Dir_Particular CONSTANT VARCHAR2(100) := 'HOME';

  k_Dir_Laboral CONSTANT VARCHAR2(100) := 'BILL_TO';

  -- Datos de direccion
  TYPE Rec_Datos_Direccion IS RECORD(
     Tipo_Direccion Hz_Party_Site_Uses.Site_Use_Type%TYPE
    ,Direccion      VARCHAR2(1000)
    ,Comuna         NUMBER
    ,Ciudad         NUMBER);

  -- Lista de direcciones
  TYPE Tab_Datos_Direccion IS TABLE OF Rec_Datos_Direccion INDEX BY BINARY_INTEGER;

  Empty_Datos_Direccion Tab_Datos_Direccion; -- se define como valor nulo
  -- datos de contacto
  TYPE Rec_Datos_Contacto IS RECORD(
     Tipo_Contacto      Hz_Contact_Points.Contact_Point_Type%TYPE
    ,Tipo_Fono          Hz_Contact_Points.Phone_Line_Type%TYPE
    ,Numero             Hz_Contact_Points.Phone_Number%TYPE
    ,Email              Hz_Contact_Points.Email_Address%TYPE
    ,Primary_By_Purpose Hz_Contact_Points.Primary_By_Purpose%TYPE);

  -- Lista de contactos
  TYPE Tab_Datos_Contacto IS TABLE OF Rec_Datos_Contacto INDEX BY BINARY_INTEGER;

  Empty_Datos_Contacto Tab_Datos_Contacto; -- se define como valor nulo
  -- Datos del Cliente (Personales y Comerciales)
  TYPE Rec_Datos_Cliente IS RECORD
  -- DATOS PERSONALES
  (
     Party_Id              Hz_Parties.Party_Id%TYPE
    ,Rut                   NUMBER(10) --  Hz_Parties.Jgzz_Fiscal_Code%TYPE
    ,Dv_Rut                VARCHAR2(1)
    ,Forma_Identificacion  VARCHAR2(1)
    ,String_Identificacion VARCHAR2(100)
    ,Apellido_Paterno      Hz_Parties.Person_Last_Name%TYPE
    ,Apellido_Materno      Hz_Parties.Person_Middle_Name%TYPE
    ,Nombres               Hz_Parties.Person_First_Name%TYPE
    ,Segundo_Nombre        VARCHAR2(1000)
    ,Fecha_Nacimiento      Hz_Person_Profiles.Date_Of_Birth%TYPE
    ,Sexo                  Hz_Person_Profiles.Gender%TYPE
    --  , direccion          varchar2(1000)
    --  , comuna             number
    --  , ciudad             number
    --  , telefono           hz_contact_points.PHONE_NUMBER%type
    --  , email              hz_contact_points.EMAIL_ADDRESS%type
    --  , celular            hz_contact_points.PHONE_NUMBER%type
    ,Inscrito_Mcv     VARCHAR2(100)
    ,Tipo_Creacion    VARCHAR2(3)
    ,Folio_Tmcv       Scfr_Programas.Folio%TYPE
    ,Fecha_Ultima_Act Hz_Parties.Last_Update_Date%TYPE
    -- DATOS COMERCIALES
    ,Rut_Facturacion    Hz_Parties.Jgzz_Fiscal_Code%TYPE
    ,Dv_Rut_Facturacion VARCHAR2(1)
    ,Razon_Social       Hz_Organization_Profiles.Organization_Name%TYPE
    ,Nombre_Fantasia    Hz_Organization_Profiles.Principal_Name%TYPE
    ,Giro               Hz_Organization_Profiles.Line_Of_Business%TYPE
    --  , direccion_factura  varchar2(1000)
    --  , comuna_factura     number
    --  , ciudad_factura     number
    --  , direccion_correo   varchar2(1000)
    --  , comuna_correo      number
    --  , ciudad_correo      number
    --  , telefono_comercial hz_contact_points.PHONE_NUMBER%type
    ,Fax Hz_Contact_Points.Phone_Number%TYPE
    --  , email_comercial    hz_contact_points.EMAIL_ADDRESS%type
    ,Direcciones          Tab_Datos_Direccion
    ,Contactos            Tab_Datos_Contacto
    ,Empresa              Scfr_Programas.Emp_Empresa%TYPE
    ,Institucion_Salud    VARCHAR2(5)
    ,Monto_Acumulado_Club NUMBER);

  PROCEDURE Inserta_Inscripcion_Gestion(p_Rut_Cliente       IN NUMBER
                                       ,p_Rut_Vendedor      IN NUMBER
                                       ,p_Local_Inscripcion IN NUMBER
                                       ,p_Fecha_Carga       IN DATE
                                       ,p_Folio_Inscripcion IN VARCHAR2
                                       ,p_Empresa           IN NUMBER
                                       ,p_Cadena            IN NUMBER
                                       ,x_Cod_Error         OUT NUMBER
                                       ,x_Msg_Error         OUT VARCHAR2);

  FUNCTION Determinar_Party_Id(x_Forma_Identificacion  IN VARCHAR2
                              ,p_String_Identificacion IN OUT VARCHAR2
                              ,p_Empresa               IN Scfr_Programas.Emp_Empresa%TYPE
                              ,p_Cadena                IN Scfr_Programas.Cad_Cadena%TYPE
                              ,x_Party_Id              OUT Hz_Parties.Party_Id%TYPE) RETURN NUMBER;

  PROCEDURE Determina_Cliente(p_Forma_Identificacion  IN VARCHAR2
                             ,p_String_Identificacion IN OUT VARCHAR2
                             ,p_Empresa               IN Scfr_Programas.Emp_Empresa%TYPE
                             ,p_Cadena                IN Scfr_Programas.Cad_Cadena%TYPE
                             ,x_Cliente               OUT Rec_Datos_Cliente
                             ,x_Cod_Error             OUT NUMBER
                             ,x_Msg_Error             OUT VARCHAR2);

  PROCEDURE Determina_Cliente(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cliente     OUT Rec_Datos_Cliente
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Registra_Pmc(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                        ,x_Cod_Error   OUT NUMBER
                        ,x_Msg_Error   OUT VARCHAR2);
  -- ----------------------------------------------------------------------------------------
  -- procedure Crea_beneficia_lista_seg
  -- ----------------------------------------------------------------------------------------
  PROCEDURE Crea_Beneficiario_Lista_Seg(p_Rut_Titular IN NUMBER
                                       ,p_Empresa     IN NUMBER
                                       ,x_Cod_Error   OUT NUMBER
                                       ,x_Msg_Error   OUT VARCHAR2);

  /*
  * OBJETIVO
  *   Actualiza los datos personales de un cliente
  * PARAMETROS
  *   p_transaccion  : Estructura de la transaccion con los datos personales del cliente
  */
  PROCEDURE Act_Datos_Perso(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion);

  /*
  * OBJETIVO
  *   Actualiza los datos comerciales de un cliente
  * PARAMETROS
  *   p_transaccion  : Estructura de la transaccion con los datos comerciales del cliente
  */
  PROCEDURE Act_Datos_Comer(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion);

  /*
  * OBJETIVO
  *   Actualiza los datos de un beneficiario
  * PARAMETROS
  *   p_transaccion  : Estructura de la transaccion con los datos del beneficiario
  */
  PROCEDURE Act_Datos_Benef(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion);

  /*
  * OBJETIVO
  *   Actualiza los datos comerciales de un cliente
  * PARAMETROS
  *   p_transaccion  : Estructura de la transaccion con los datos comerciales del cliente
  */
  PROCEDURE Ins_Produ_Fide_Crm(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion);

  PROCEDURE Ins_Comp_Frec_Crm(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion);

  PROCEDURE Act_Cupon_Impreso(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion);

  PROCEDURE Obtiene_Rut(p_Party_Id IN Scfr_Mov_Transacciones.Pt_Party_Id_Titular%TYPE
                       ,x_Rut      OUT Scfr_Mov_Transacciones.Rut_Titular%TYPE
                       ,x_Dv_Rut   OUT Scfr_Mov_Transacciones.Dv_Titular%TYPE);

  PROCEDURE Obtiene_Rut(p_Forma_Identificacion  IN OUT VARCHAR2
                       ,p_String_Identificacion IN OUT VARCHAR2
                       ,p_Empresa               IN NUMBER
                       ,p_Cadena                IN NUMBER
                       ,x_Rut                   OUT Scfr_Mov_Transacciones.Rut_Titular%TYPE
                       ,x_Dv_Rut                OUT Scfr_Mov_Transacciones.Dv_Titular%TYPE);

  FUNCTION Obtiene_Rut_Solventa(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion) RETURN VARCHAR2;

  FUNCTION Obtiene_Dcto_Solventa(p_Transaccion   IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                ,p_Folio_Tarjeta IN Scfr_Clientes_Tarjetas_Vm.Folio_Tarjeta%TYPE
                                ,l_Rut           IN Scfr_Mov_Transacciones.Rut_Titular%TYPE
                                ,l_Dv_Rut        IN Scfr_Mov_Transacciones.Dv_Titular%TYPE) RETURN NUMBER;

  FUNCTION Levanta_Campana(p_Party_Id IN NUMBER
                          ,p_Campana  IN NUMBER
                          ,p_Fecha_Tx IN NUMBER) RETURN VARCHAR2;

  FUNCTION Levanta_Campana_Tcv(p_Rut     IN NUMBER
                              ,p_Campana IN NUMBER) RETURN VARCHAR2;

  FUNCTION Obtiene_Direccion_Cliente(p_Party_Id       IN NUMBER
                                    ,p_Tipo_Direccion IN VARCHAR2
                                    ,x_Cod_Error      OUT NUMBER
                                    ,x_Msg_Error      OUT VARCHAR2) RETURN Rec_Datos_Direccion;

  FUNCTION Obtiene_Direccion_Cliente(p_Party_Id  IN NUMBER
                                    ,x_Cod_Error OUT NUMBER
                                    ,x_Msg_Error OUT VARCHAR2) RETURN Tab_Datos_Direccion;

  FUNCTION Obtiene_Contacto_Cliente(p_Party_Id      IN NUMBER
                                   ,p_Tipo_Contacto IN VARCHAR2
                                   ,p_Tipo_Fono     IN VARCHAR2 DEFAULT NULL
                                   ,x_Cod_Error     OUT NUMBER
                                   ,x_Msg_Error     OUT VARCHAR2) RETURN Rec_Datos_Contacto;

  FUNCTION Obtiene_Contacto_Cliente(p_Party_Id  IN NUMBER
                                   ,x_Cod_Error OUT NUMBER
                                   ,x_Msg_Error OUT VARCHAR2) RETURN Tab_Datos_Contacto;

  FUNCTION Obtiene_Datos_Personales(p_Party_Id  IN NUMBER
                                   ,p_Folio     IN VARCHAR2 DEFAULT NULL
                                   ,p_Empresa   IN NUMBER
                                   ,x_Cod_Error OUT NUMBER
                                   ,x_Msg_Error OUT VARCHAR2) RETURN Rec_Datos_Cliente;

  --//--------------------------------------------------------------------------\\
  --// CBR 13/08/2018 10:28                                                     \\
  --// BIFURCAR EMPRESA MAICAO EN GNCC01                                        \\
  --//-----------------------------------------------------------------Inicio---\\
  FUNCTION Obtiene_Datos_Loyalty(l_Transaccion    IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                ,x_Id_Sec_Lotalty OUT NUMBER
                                ,x_Cod_Error      OUT NUMBER
                                ,x_Msg_Error      OUT VARCHAR2) RETURN Rec_Datos_Cliente;
  --//-----------------------------------------------------------------Termino--\\

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
                        ,x_Msg_Data          OUT VARCHAR2);

  PROCEDURE Actualiza_Persona(p_Party_Id      IN NUMBER
                             ,p_Rut_Cliente   IN NUMBER
                             ,p_Dvr_Cliente   IN VARCHAR2
                             ,p_Datos_Dp      IN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp
                             ,p_Empresa       IN NUMBER
                             ,p_Nombre_Respo  IN VARCHAR2
                             ,p_En_Linea      IN VARCHAR2 DEFAULT 'SI'
                             ,x_Return_Status OUT VARCHAR2
                             ,x_Msg_Data      OUT VARCHAR2);

  PROCEDURE Crea_Relacion(p_Party_Id_Nuevo IN NUMBER
                         ,p_Empresa        IN NUMBER DEFAULT 86
                         ,x_Party_Id_Rel   OUT NUMBER
                         ,x_Return_Status  OUT VARCHAR2
                         ,x_Msg_Data       OUT VARCHAR2);

  PROCEDURE Crea_Relacion(p_Party_Id_Nuevo IN NUMBER
                         ,p_Empresa        IN NUMBER DEFAULT 86
                         ,p_Tipo_Relacion  IN VARCHAR2
                         ,x_Party_Id_Rel   OUT NUMBER
                         ,x_Return_Status  OUT VARCHAR2
                         ,x_Msg_Data       OUT VARCHAR2);

  PROCEDURE Actualiza_Relacion(p_Party_Id_Rel  IN NUMBER
                              ,p_Estado        IN VARCHAR2
                              ,p_Fecha_Hasta   IN DATE
                              ,x_Return_Status OUT VARCHAR2
                              ,x_Msg_Data      OUT VARCHAR2);

  PROCEDURE Actualiza_Relacion(p_Party_Id_Rel  IN NUMBER
                              ,x_Return_Status OUT VARCHAR2
                              ,x_Msg_Data      OUT VARCHAR2);

  PROCEDURE Crea_Direccion(p_Party_Id_Rel  IN NUMBER
                          ,p_Direccion     IN VARCHAR2
                          ,p_Comuna        IN VARCHAR2
                          ,p_Ciudad        IN VARCHAR2
                          ,p_Nombre_Respo  IN VARCHAR2
                          ,x_Return_Status OUT VARCHAR2
                          ,x_Msg_Data      OUT VARCHAR2);

  PROCEDURE Actualiza_Direccion(p_Location_Id   IN NUMBER
                               ,p_Direccion     IN VARCHAR2
                               ,p_Comuna        IN VARCHAR2
                               ,p_Ciudad        IN VARCHAR2
                               ,p_Nombre_Respo  IN VARCHAR2
                               ,x_Return_Status OUT VARCHAR2
                               ,x_Msg_Data      OUT VARCHAR2);

  PROCEDURE Crea_Punto_Contacto(p_Party_Id_Rel  IN NUMBER
                               ,p_Fono_Partic   IN VARCHAR2
                               ,p_Tipo_Pc       IN VARCHAR2
                               ,p_Tipo_Fono     IN VARCHAR2
                               ,p_Nombre_Respo  IN VARCHAR2
                               ,x_Return_Status OUT VARCHAR2
                               ,x_Msg_Data      OUT VARCHAR2);

  PROCEDURE Actualiza_Punto_Contacto(p_Contact_Id    IN NUMBER
                                    ,p_Fono_Partic   IN VARCHAR2
                                    ,x_Return_Status OUT VARCHAR2
                                    ,x_Msg_Data      OUT VARCHAR2);

  FUNCTION Busca_Contact_Id_Phone(p_Party_Id_Cliente IN NUMBER
                                 ,p_Tipo_Fono        IN VARCHAR2) RETURN NUMBER;

  FUNCTION Obtiene_Campana(p_Empresa IN NUMBER
                          ,p_Cadena  IN NUMBER) RETURN NUMBER;

  FUNCTION Puntos_Disponibles(p_Party_Id    IN NUMBER DEFAULT NULL
                             ,p_Rut_Titular IN NUMBER DEFAULT NULL
                             ,p_Tipo_Puntos IN VARCHAR2
                             ,p_Emp_Alianza IN VARCHAR2 DEFAULT 'JBM') RETURN NUMBER;

  FUNCTION Trama_Dp_Prepara(p_Transaccion      IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Id_Consulta_Json OUT NUMBER
                           ,x_Id_Consulta_Json_Nec OUT NUMBER -- JAGC NEC 09/09/2024
                           ,x_Id_Sec_Lotalty   OUT NUMBER
                           ,x_Cod_Error        OUT NUMBER
                           ,x_Msg_Error        OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Rec_Trama_Dp;

  FUNCTION Trama_Pu_Prepara(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pu;

  FUNCTION Esta_En_Tramo_Horario(p_Campana IN NUMBER) RETURN BOOLEAN;

  PROCEDURE Obtener_Fechas_Cam(p_Campana       IN NUMBER
                              ,p_Rut           IN NUMBER
                              ,p_Periodicidad  IN NUMBER
                              ,p_Fecha_Consumo IN DATE
                              ,x_Fecha_Ini     OUT DATE);

  FUNCTION Devuelve_Saldo_Descuento(p_Campana  IN NUMBER
                                   ,p_Party_Id IN NUMBER
                                   ,p_Fecha_Tx IN DATE) RETURN NUMBER;

  FUNCTION Trama_Ca_Prepara(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ca;

  FUNCTION Trama_Cx_Prepara(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cx;

  PROCEDURE Trama_Vo_Resuelve(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                             ,x_Cod_Error   OUT NUMBER
                             ,x_Msg_Error   OUT VARCHAR2);

  FUNCTION Trama_Pf_Prepara(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Pf;

  FUNCTION Trama_Cf_Prepara(p_Transaccion IN Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cf;

  FUNCTION Trama_Ms_Prepara(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Ms;

  FUNCTION Trama_Cu_Prepara(p_Transaccion  IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,p_Codigo_Cupon IN VARCHAR2 DEFAULT NULL
                           ,x_Cod_Error    OUT NUMBER
                           ,x_Msg_Error    OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cu;

  FUNCTION Trama_Cm_Prepara(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                           ,x_Cod_Error   OUT NUMBER
                           ,x_Msg_Error   OUT VARCHAR2) RETURN Scfr_Trx_Dyn_Types_Pk.Tab_Trama_Cm;

  PROCEDURE Reprocesa_Clientes;

  -- Consulta cartola de puntos
  PROCEDURE Fidi01(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,p_En_Linea    IN VARCHAR2 DEFAULT 'SI'
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidi02(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidi03(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidi06(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidc01(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidc02(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidc03(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidc04(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidc05(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidc06(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidc08(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidc09(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidu01(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidu02(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidu03(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidu05(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidu07(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidu08(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidu09(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidu10(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidu51(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidu52(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidu53(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidu55(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  PROCEDURE Fidu56(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                  ,x_Respuesta   OUT BLOB
                  ,x_Cod_Error   OUT NUMBER
                  ,x_Msg_Error   OUT VARCHAR2);

  FUNCTION Ms_Esta_En_Zona(p_Empresa IN NUMBER
                          ,p_Cadena  IN NUMBER
                          ,p_Local   IN NUMBER
                          ,p_Campana IN NUMBER) RETURN NUMBER;

  PROCEDURE Refresca_Cliente_Dat;

  PROCEDURE Refresca_Cliente_Dir;

  PROCEDURE Refresca_Cliente_Con;

  PROCEDURE Refresca_Cliente_Rel;

  --//--------------------------------------------------------------------------\\
  --// CBR 05/02/2015 18:57 Mensajes / Eventos / Descuentos                     \\
  --//-----------------------------------------------------------------Inicio---\\
  --// Procedimiento sobrecargado para inscripcion automatica para Descuentos   \\
  --//--------------------------------------------------------------------------\\
  PROCEDURE Dto_x_Evento_Mensajeria(p_Transaccion IN OUT Scfr_Trx_Dyn_Pk.Rec_Transaccion
                                   ,x_Cod_Error   OUT NUMBER
                                   ,x_Msg_Error   OUT VARCHAR2);

  --//--------------------------------------------------------------------------\\
  --// CBR 05/02/2015 18:57 Mensajes / Eventos / Descuentos                     \\
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
                                    ,x_Msg_Error        OUT VARCHAR2);

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
                                  ,x_Msg_Error          OUT VARCHAR2) RETURN VARCHAR2;

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
                                ,x_Msg_Error          OUT VARCHAR2);

END Scfr_Trx_Fid_Pk;
/
