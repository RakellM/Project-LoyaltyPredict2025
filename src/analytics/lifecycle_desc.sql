SELECT
    DtRef,
    descLifeCycle,
    COUNT(*) AS QtyUsers

FROM life_cycle
WHERE descLifeCycle != '05-Petrified'
GROUP BY 1, 2
ORDER BY 1, 2