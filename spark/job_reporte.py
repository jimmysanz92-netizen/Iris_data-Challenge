from pyspark.sql import SparkSession
from pyspark.sql.functions import col, when, sum as _sum, month, to_date, upper, trim, regexp_replace, explode, coalesce, lit

RUTA_CSV = "Datos/transacciones.csv"
RUTA_TRM = "Datos/trm.json"
RUTA_ANULADAS = "Datos/anuladas.txt"


spark = SparkSession.builder.appName("reporte_transacciones").getOrCreate()

df = (spark.read
        .option("header", True)
        .option("inferSchema", True)
        .csv(RUTA_CSV))



df_anuladas = (spark.read
        .option("header", True)
        .option("sep", "|")
        .option("comment", "#")
        .csv(RUTA_ANULADAS))

df = df.join(df_anuladas, on="id_transaccion", how="left_anti")


mes = 1
while mes <= 12:
    n = df.filter(month(to_date(col("fecha"))) == mes).count()
    print("Mes", mes, "->", n, "transacciones")
    mes = mes + 1

df = df.withColumn("segmento", upper(trim(col("segmento"))))     

df = df.withColumn("monto_limpio", regexp_replace(col("monto"), "[$,.]", ""))
df = df.withColumn("monto_num", col("monto_limpio").cast("double"))



df_trm_raw = spark.read.option("multiline", True).json(RUTA_TRM)

df_trm = df_trm_raw.select(explode(col("tasas")).alias("tasa"))
df_trm = df_trm.select(col("tasa.fecha").alias("fecha_trm"), col("tasa.trm").alias("valor_trm"))

df = df.join(df_trm, df["fecha"] == df_trm["fecha_trm"], how="left")

df = df.withColumn("trm_final", coalesce(col("valor_trm"), lit(4000.0)))

df = df.withColumn("monto_cop",
        when(col("moneda") == "USD", col("monto_num") * col("trm_final"))
        .otherwise(col("monto_num")))

segmentos = ["PREMIUM", "PERSONAL", "PYME", "EMPRESARIAL"]
print("=== Total transado en COP por segmento ===")
for seg in segmentos:
    total = (df.filter(col("segmento") == seg)
               .agg(_sum("monto_cop").alias("total_cop"))
               .collect()[0]["total_cop"])
    
    total = total if total is not None else 0
    print(seg, "->", total)

spark.stop()
