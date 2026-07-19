# iris-data-challenge

Prueba técnica para el rol de **Líder de Datos**.

Este repositorio es una **plantilla**. Para empezar:

1. Haz clic en **"Use this template" → "Create a new repository"** y crea **tu propio repositorio público** a partir de esta plantilla.
2. Trabaja en **tu** repositorio con buenas prácticas (commits claros y frecuentes) y deja los **cambios finales** en la rama `master`.

## Contenido

- `aws-Resrcs/` — Infraestructura como código (CloudFormation).
- `sql/` — Scripts SQL (SQL Server).
- `spark/` — Job de PySpark y sus fuentes de datos (`spark/datos/`).

## Instrucciones completas

Qué hacer en cada módulo, cómo ejecutarlo, qué entregar y el plazo están en el
**documento de Word que te envió el reclutador**. Guíate por ese documento de principio a fin.

## Entrega

El **enlace de tu repositorio público** (con los cambios finales en `master`) y el **video**, tal
como lo indica el documento.



## Punto 6

## Anti-patrones y Optimización (100M+ de filas)
El código original tenía bucles while y for que ejecutaban operaciones .count() y .collect() por cada mes y segmento. En Spark, esto rompe y fuerza al Driver (nodo maestro) a lanzar 16 Jobs separados.
Con 100M+ de filas, el clúster colapsaría por sobrecarga de red y falta de memoria (OOM), ya que relee el mismo archivo muchas veces.

Eliminar los bucles por completo. Usando groupBy junto con funciones de agregación nativas (month, _sum), Spark procesa todo en un solo Plan de Ejecución Físico, leyendo el archivo una sola vez y 
distribuyendo la carga de forma eficiente en los workers.



## Arquitectura en la nube (S3 + Glue + Athena)
Si este proceso viviera en producción dentro de AWS, cambiaría lo siguiente:

Formato: Movería los datos de CSV a Apache Parquet (comprimido con Snappy). Al ser un formato columnar, permite leer solo las columnas necesarias.

Particionado: Estructuraría el almacenamiento en S3 por fecha (ej: year=2024/month=01/).

Lectura/Pushdown: Esto habilita Predicate Pushdown y Partition Projection. Cuando consultemos con Athena o Glue, el motor omitirá las carpetas de los meses que no nos interesan y no escaneará filas completas.
El gasto de Athena baja más de un 90% porque cobra por Terabyte escaneado.



## Monitoreo y Control de Gasto
AWS Glue: Activaría los Job Bookmarks para procesar solo los datos nuevos de forma incremental (sin recalcular la historia todos los días). Configuraría un Timeout estricto y alertas en CloudWatch para matar el Job si se queda colgado, avisando.

Amazon Athena: Crearía límites de consumo en los Workgroups (ejemplo: máximo 50 GB por consulta). Si alguien lanza un query sin filtros, Athena lo aborta automáticamente antes de que genere un cobro costoso.
