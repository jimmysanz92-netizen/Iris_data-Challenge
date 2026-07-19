SELECT c.segmento,
       SUM(cr.monto_desembolsado) AS cartera_desembolsada,
       COUNT(*)                   AS num_creditos
FROM creditos cr
JOIN clientes c ON c.id_cliente = cr.id_cliente
JOIN pagos    p ON p.id_credito = cr.id_credito
GROUP BY c.segmento
ORDER BY cartera_desembolsada DESC;
