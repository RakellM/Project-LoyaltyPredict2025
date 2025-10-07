SELECT
    DtRef,
    descLifecycle,
    -- Segment,
    count(1) AS QtyFollowers,
    ROUND(1.0 * count(1) / ( 
        SUM(CASE WHEN descLifecycle = '05-Petrified' THEN 0 ELSE count(1) END) OVER (PARTITION BY DtRef ) 
        ) * 100, 2) AS PercFollowers

FROM life_cycle

WHERE 1 = 1
    AND descLifecycle != '05-Petrified'
    AND DtRef = '2025-08-31'

GROUP BY 1, 2
ORDER BY 1, QtyFollowers DESC



| DtRef | descLifeCycle | QtyFollowers | PercFollowers |
| ----- | ------------- | ------------ | ------------- |
| 2025-08-31 | 01-Apprendice | 391 | 53.93 |
| 2025-08-31 | 02-Sorcerer | 170 | 23.45 |
| 2025-08-31 | 02-Resurrected | 57 | 7.86 |
| 2025-08-31 | 04-Fading | 56 | 7.72 |
| 2025-08-31 | 03-Wondered | 39 | 5.38 |
| 2025-08-31 | 02-Reawakened | 12 | 1.66 |