SELECT 
    SUBSTR(DtCriacao, 0, 11) AS DtDay,
    COUNT(DISTINCT IdCliente) AS DAU
FROM transacoes
GROUP BY 1
ORDER BY DtDay ;


