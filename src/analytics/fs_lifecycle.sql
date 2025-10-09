WITH
    tb_lifecycle_current AS (

        SELECT
            IdCliente,
            Frequency,
            descLifeCycle AS descLifeCycleCurrent
        FROM life_cycle
        WHERE DtRef = DATE('2025-10-01', '-1 day')
    ),

    tb_lifecycle_D28 AS (

        SELECT
            IdCliente,
            descLifeCycle AS descLifeCycleD28
        FROM life_cycle
        WHERE DtRef = date('2025-10-01', '-28 day')

    ),

    tb_avg_cycle AS (

        SELECT 
            descLifeCycleCurrent,
            AVG(Frequency) AS avgFreqGroup

        FROM tb_lifecycle_current

        GROUP BY 1


    ),

    tb_share_cycles AS (

        SELECT 
            IdCliente,
            1.0 * SUM(CASE WHEN descLifeCycle = '01-Apprendice' THEN 1 ELSE 0 END) / COUNT(1) AS pctApprendice,
            1.0 * SUM(CASE WHEN descLifeCycle = '02-Sorcerer' THEN 1 ELSE 0 END) / COUNT(1) AS pctSorcerer,
            1.0 * SUM(CASE WHEN descLifeCycle = '03-Wondered' THEN 1 ELSE 0 END) / COUNT(1) AS pctWondered,
            1.0 * SUM(CASE WHEN descLifeCycle = '04-Fading' THEN 1 ELSE 0 END) / COUNT(1) AS pctFading,
            1.0 * SUM(CASE WHEN descLifeCycle = '05-Petrified' THEN 1 ELSE 0 END) / COUNT(1) AS pctPetrified,
            1.0 * SUM(CASE WHEN descLifeCycle = '02-Reawakened' THEN 1 ELSE 0 END) / COUNT(1) AS pctReawakened,
            1.0 * SUM(CASE WHEN descLifeCycle = '02-Resurrected' THEN 1 ELSE 0 END) / COUNT(1) AS pctResurrected

        FROM life_cycle
        WHERE DtRef < '2025-10-01'
        GROUP BY 1

    ),

    tb_join AS (

        SELECT 
            t1.*,
            t2.descLifeCycleD28,
            t3.pctApprendice,
            t3.pctSorcerer,
            t3.pctWondered,
            t3.pctFading,
            t3.pctPetrified,
            t3.pctReawakened,
            t3.pctResurrected,
            t4.avgFreqGroup,
            1.0 * t1.Frequency / t4.avgFreqGroup AS ratioFreqGroup

        FROM tb_lifecycle_current AS t1

        LEFT JOIN tb_lifecycle_D28 AS t2
            ON t1.IdCliente = t2.IdCliente

        LEFT JOIN tb_share_cycles AS t3
            ON t1.IdCliente = t3.IdCliente

        LEFT JOIN tb_avg_cycle AS t4
            ON t1.descLifeCycleCurrent = t4.descLifeCycleCurrent

    )

SELECT 
    DATE('2025-10-01', '-1 day') AS DtRef,
    *
FROM tb_join

