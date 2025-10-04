SELECT
    IdCliente,
    COUNT(DISTINCT SUBSTR(DtCriacao, 0, 11)) AS Frequency,
    SUM(QtdePontos) AS QtyPoints,
    SUM(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS QtyPointsPositive,
    SUM(CASE WHEN QtdePontos < 0 THEN QtdePontos ELSE 0 END) AS QtyPointsNegative,
    SUM(ABS(QtdePontos)) AS QtyPointsAbsolute

FROM transacoes

WHERE DtCriacao < '2025-09-01' 
    AND DtCriacao > DATE('2025-09-01', '-28 day')

GROUP BY 1

ORDER BY Frequency DESC
