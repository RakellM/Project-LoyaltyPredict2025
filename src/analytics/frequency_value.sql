WITH
    tb_freq_value AS (
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
    ) ,

    tb_cluster AS (
        SELECT
            *,
            (CASE 
                WHEN Frequency <= 10 AND QtyPointsPositive >= 1500 THEN 'Hyper'
                WHEN Frequency > 10 AND QtyPointsPositive >= 1500 THEN 'Efficient'
                WHEN Frequency <= 10 AND QtyPointsPositive >= 750 THEN 'Undecided'
                WHEN Frequency > 10 AND QtyPointsPositive >= 750 THEN 'Hardworking'
                WHEN Frequency < 5 THEN 'Lurker'
                WHEN Frequency <= 10 THEN 'Lazy'
                WHEN Frequency > 10 THEN 'Potential'
            END) AS Segment

        FROM tb_freq_value
    )

SELECT *

FROM tb_cluster




