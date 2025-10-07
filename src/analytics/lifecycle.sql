WITH
    tb_daily AS (
        SELECT DISTINCT
            IdCliente,
            SUBSTR(DtCriacao, 0, 11) AS DtDay
        FROM transacoes
        WHERE DtCriacao < '{date}'
    ) ,

    tb_age AS (
        SELECT
            IdCliente,
            -- MIN(DtDay) AS DtFirstTransaction,
            CAST(MAX( julianday('{date}') - julianday(DtDay) ) AS INT) AS DaysSinceFirstTransaction,

            -- MAX(DtDay) AS DtLastTransaction,
            CAST(MIN( julianday('{date}') - julianday(DtDay) ) AS INT) AS DaysSinceLastTransaction
        FROM tb_daily
        GROUP BY 1
    ),

    tb_rn AS (
        SELECT
            *,
            row_number() OVER (PARTITION BY IdCliente ORDER BY DtDay DESC) AS rnDay
        FROM tb_daily
    ),

    tb_penultimate_activation AS (
        SELECT
            *,
            CAST(julianday('{date}') - julianday(DtDay) AS INT) AS DaysSincePenultimateTransaction
        FROM tb_rn
        WHERE rnDay = 2 
    ),

    tb_lifecycle AS (
        SELECT 
            t1.*,
            t2.DaysSincePenultimateTransaction,
            (CASE
                WHEN t1.DaysSinceFirstTransaction <= 7 THEN "01-Apprendice"
                WHEN t1.DaysSinceLastTransaction <= 7  AND (t2.DaysSincePenultimateTransaction - t1.DaysSinceLastTransaction) <= 14 THEN "02-Sorcerer"
                WHEN t1.DaysSinceLastTransaction > 7   AND t1.DaysSinceLastTransaction <= 14 THEN "03-Wondered"
                WHEN t1.DaysSinceLastTransaction > 14  AND t1.DaysSinceLastTransaction <= 28  THEN "04-Fading"
                WHEN t1.DaysSinceLastTransaction >= 28  THEN "05-Petrified"
                WHEN t1.DaysSinceLastTransaction <= 7 AND ((t2.DaysSincePenultimateTransaction - t1.DaysSinceLastTransaction) > 14 AND (t2.DaysSincePenultimateTransaction - t1.DaysSinceLastTransaction) <= 28) THEN "02-Reawakened"
                WHEN t1.DaysSinceLastTransaction <= 7 AND (t2.DaysSincePenultimateTransaction - t1.DaysSinceLastTransaction) >= 28 THEN "02-Resurrected"
            END) AS descLifeCycle
        FROM tb_age AS t1
        LEFT JOIN tb_penultimate_activation AS t2
            ON t1.IdCliente = t2.IdCliente
    ),

    tb_freq_value AS (
        SELECT
        IdCliente,
        COUNT(DISTINCT SUBSTR(DtCriacao, 0, 11)) AS Frequency,
        SUM(QtdePontos) AS QtyPoints,
        SUM(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS QtyPointsPositive,
        SUM(CASE WHEN QtdePontos < 0 THEN QtdePontos ELSE 0 END) AS QtyPointsNegative,
        SUM(ABS(QtdePontos)) AS QtyPointsAbsolute

        FROM transacoes

        WHERE DtCriacao < '{date}' 
        AND DtCriacao > DATE('{date}', '-28 day')

        GROUP BY 1

        ORDER BY Frequency DESC
    ) ,

    tb_cluster AS (
        SELECT
            *,
            (CASE 
                WHEN Frequency <= 10 AND QtyPointsPositive >= 1500 THEN '12-Hyper'
                WHEN Frequency > 10 AND QtyPointsPositive >= 1500 THEN '22-Efficient'
                WHEN Frequency <= 10 AND QtyPointsPositive >= 750 THEN '11-Undecided'
                WHEN Frequency > 10 AND QtyPointsPositive >= 750 THEN '21-Hardworking'
                WHEN Frequency < 5 THEN '00-Lurker'
                WHEN Frequency <= 10 THEN '01-Lazy'
                WHEN Frequency > 10 THEN '20-Potential'
            END) AS Segment

        FROM tb_freq_value
    )

SELECT
    t1.*,
    t2.Frequency,
    t2.QtyPointsPositive,
    t2.Segment

FROM tb_lifecycle AS t1

LEFT JOIN tb_cluster AS t2
    ON t1.IdCliente = t2.IdCliente








