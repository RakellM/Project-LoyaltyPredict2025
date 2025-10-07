SELECT
    DtRef,
    descLifecycle,
    Segment,
    count(1) AS QtyFollowers

FROM life_cycle

WHERE descLifecycle != '05-Petrified'

GROUP BY 1,2,3
ORDER BY 1,2,3