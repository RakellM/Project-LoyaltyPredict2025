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
                WHEN t1.DaysSinceLastTransaction > 14  AND t1.DaysSinceLastTransaction <= 27  THEN "04-Fading"
                WHEN t1.DaysSinceLastTransaction >= 28  THEN "05-Petrified"
                WHEN t1.DaysSinceLastTransaction <= 7 AND ((t2.DaysSincePenultimateTransaction - t1.DaysSinceLastTransaction) > 14 AND (t2.DaysSincePenultimateTransaction - t1.DaysSinceLastTransaction) <= 28) THEN "02-Reawakened"
                WHEN t1.DaysSinceLastTransaction <= 7 AND (t2.DaysSincePenultimateTransaction - t1.DaysSinceLastTransaction) >= 28 THEN "02-Resurrected"
            END) AS descLifeCycle
        FROM tb_age AS t1
        LEFT JOIN tb_penultimate_activation AS t2
            ON t1.IdCliente = t2.IdCliente
    )

SELECT 
    DATE('{date}', '-1 day') AS DtRef,
    *
FROM tb_lifecycle






