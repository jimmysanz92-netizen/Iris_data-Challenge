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



## Modulo 3 - punto 6

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

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Punto 6.

## ¿Qué herramientas de IA usaste?
- Herramienta: Gemini (en la nube).
- Modelo: Gemini 1.5 Pro.

## ¿En qué partes usaste IA y para qué?
- Diagnóstico de errores: Para analizar las trazas de error de Spark (como el fallo del CAST por separadores de miles regionales).
- Revisión y optimización: Para identificar los anti-patrones de rendimiento (bucles while/for e interrupciones de Lazy Evaluation con .collect()) y traducirlos a operaciones puramente distribuidas (groupBy y agg).
- Diseño de Arquitectura: Como contraparte técnica para estructurar la propuesta de producción en AWS (S3 + Glue + Athena).

## ¿Por qué la usaste ahí y qué te aportó?
- Por qué: Para acelerar el proceso de depuración (debugging) y validar que mi enfoque arquitectónico cumpliera con las mejores prácticas de Big Data y optimización de costos en la nube.
- Qué aportó: Velocidad de desarrollo y claridad estructural. Me permitió enfocarme en la lógica del negocio (el manejo de la TRM y las exclusiones) mientras delegaba la generación de la documentación base de escalabilidad.

## Ejemplo de algo que la IA dio y se tuvo que corregir/verificar
- El caso: Al pedirle soporte para limpiar la columna de segmentos, la IA sugirió inicialmente un formateo estándar usando initcap().
- Cómo me di cuenta: Al revisar críticamente los requerimientos y la lista de segmentos del problema, noté que uno de ellos era "PYME" (completamente en mayúsculas). Aplicar initcap() lo habría transformado en "Pyme", rompiendo la coincidencia exacta de los datos originales.
- La corrección: Modifiqué la estrategia para aplicar upper() de forma dinámica a ambos lados de la comparación (columna y filtro literal), asegurando que ninguna categoría se quedara por fuera sin importar cómo viniera escrita en el CSV. Asimismo, inicialmente la IA propuso limpiar montos usando solo [$,], pero al correr el código el clúster arrojó un error debido a que los datos traían puntos como separadores de miles (1.200.000), por lo que tuve que corregir la expresión regular a [$,.] para removerlos.





