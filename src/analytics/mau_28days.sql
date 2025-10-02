WITH 
    tb_daily AS (
        SELECT DISTINCT
            DATE(SUBSTR(DtCriacao, 0, 11)) AS DtDay,
            IdCliente
        
        FROM transacoes
        ORDER BY DtDay
    ),

    tb_distinct_days AS (
        SELECT
            DISTINCT DtDay AS DtRef
        FROM tb_daily
    )

SELECT
    t1.DtRef,
    COUNT(DISTINCT t2.IdCliente) AS MAU,
    COUNT(DISTINCT t2.DtDay) AS DaysCount
FROM tb_distinct_days AS t1
LEFT JOIN tb_daily AS t2
    ON t2.DtDay <= t1.DtRef
    AND julianday(t1.DtRef) - julianday(t2.DtDay) < 28
GROUP BY t1.DtRef
ORDER BY DtRef ASC
