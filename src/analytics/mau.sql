SELECT DISTINCT
    SUBSTR(DtCriacao, 0, 8) AS DtMonth,
    COUNT(DISTINCT IdCliente) AS MAU
FROM transacoes
GROUP BY 1
ORDER BY DtMonth ;

