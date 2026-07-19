from pyspark.sql import SparkSession
from pyspark.sql.functions import col, when, sum as _sum, month, to_date

RUTA_CSV = "datos/transacciones.csv"

spark = SparkSession.builder.appName("reporte_transacciones").getOrCreate()

df = (spark.read
        .option("header", True)
        .option("inferSchema", True)
        .csv(RUTA_CSV))

mes = 1
while mes <= 12:
    n = df.filter(month(to_date(col("fecha"))) == mes).count()
    print("Mes", mes, "->", n, "transacciones")
    if n == 0:
        mes = mes + 1

df = df.withColumn("monto_num", col("monto").cast("double"))

df = df.withColumn("monto_cop",
        when(col("moneda") == "USD", col("monto_num") * 4000)
        .otherwise(col("monto_num")))

segmentos = ["Premium", "Personal", "PYME", "Empresarial"]
print("=== Total transado en COP por segmento ===")
for seg in segmentos:
    total = (df.filter(col("segmento") == seg)
               .agg(_sum("monto_cop").alias("total_cop"))
               .collect()[0]["total_cop"])
    print(seg, "->", total)

spark.stop()
