SELECT CONVERT(char(7), cr.fecha_desembolso, 126)   AS cosecha,
       COUNT(DISTINCT cr.id_credito)                AS creditos,
       SUM(CASE WHEN cu.fecha_pago_real IS NULL
                 AND cu.fecha_vencimiento <= '2024-12-31'
                THEN 1 ELSE 0 END)                  AS creditos_en_mora,
       1.0 * SUM(CASE WHEN cu.fecha_pago_real IS NULL
                       AND cu.fecha_vencimiento <= '2024-12-31'
                      THEN 1 ELSE 0 END)
             / COUNT(DISTINCT cr.id_credito)        AS pct_en_mora
FROM creditos cr
JOIN cuotas cu ON cu.id_credito = cr.id_credito
GROUP BY CONVERT(char(7), cr.fecha_desembolso, 126)
ORDER BY cosecha;
