SELECT CONVERT(char(7), cr.fecha_desembolso, 126)   AS cosecha,
       COUNT(DISTINCT cr.id_credito)                AS creditos,
       COUNT(DISTINCT CASE WHEN cu.fecha_pago_real IS NULL
                 AND cu.fecha_vencimiento <= '2024-12-31'
                THEN cr.id_credito
                ELSE NULL END)                  AS creditos_en_mora,

       100.0 * COUNT(DISTINCT CASE WHEN cu.fecha_pago_real IS NULL
                       AND cu.fecha_vencimiento <= '2024-12-31'
                      THEN cr.id_credito
                      ELSE NULL END)
             / COUNT(DISTINCT cr.id_credito)        AS pct_en_mora

FROM creditos cr
JOIN cuotas cu ON cu.id_credito = cr.id_credito
GROUP BY CONVERT(char(7), cr.fecha_desembolso, 126)
ORDER BY cosecha;
