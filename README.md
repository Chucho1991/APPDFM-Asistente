# Oracle Package Sync

Utilidad CLI en Java 17 y Spring Boot para comparar paquetes Oracle de **test** contra
**producción** y preparar únicamente los archivos que deben actualizarse.

La herramienta:

- acepta en test paquetes completos `.pck` o `.spc`, y partes separadas `.pks`/`.pkb`;
- espera en producción especificaciones `.pks` y bodies `.pkb` separados;
- identifica los paquetes desde `CREATE [OR REPLACE] PACKAGE`, no desde nombres fijos;
- hace el match sin distinguir mayúsculas/minúsculas ni el esquema Oracle;
- conserva el nombre, extensión, subdirectorio, codificación, BOM y tipo de salto de línea
  del archivo equivalente de producción;
- genera solo las partes que cambiaron y crea un reporte Markdown genérico.

## Requisitos

- JDK 17
- Maven 3.8+

## Uso

Con la estructura predeterminada:

```text
fuente/
├── test/
└── produccion/
```

ejecutar:

```bash
mvn spring-boot:run
```

Los archivos modificados y `REPORTE.md` quedan en `resultado/`.
La utilidad mantiene allí un manifiesto oculto para retirar exclusivamente los archivos
que ella misma generó en la ejecución anterior; nunca limpia archivos ajenos.

Para usar otros directorios:

```bash
mvn spring-boot:run -Dspring-boot.run.arguments="--oracle-sync.test-directory=C:/entrada/test --oracle-sync.production-directory=C:/entrada/prod --oracle-sync.result-directory=C:/salida"
```

También se puede construir y ejecutar el JAR:

```bash
mvn clean package
java -jar target/oracle-package-sync-1.0.0-SNAPSHOT.jar
```

## Reglas de seguridad de contenido

Sin BOM, se valida primero UTF-8 y, si no es válido, se usa Windows-1252 (configurable
con `--oracle-sync.fallback-charset=...`). Si algún carácter de test no puede
representarse en la codificación de producción, el proceso falla en vez de reemplazarlo
silenciosamente. Los archivos sin equivalente se detallan como advertencias y no se
inventan ni se eliminan.
