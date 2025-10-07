WITH
    tb_transaction AS (

        SELECT 
            *,
            SUBSTR(DtCriacao, 0,11) AS DtDay
        FROM transacoes
        WHERE DtCriacao < '2025-10-01'

    ),

    tb_agg_transaction AS (

        SELECT
            IdCliente,
            COUNT(DISTINCT DtDay) AS QtyActivationFullLife,
            COUNT(DISTINCT CASE WHEN DtDay > DATE('2025-10-01', '-7 day') THEN DtDay END) AS QtyActivationD7,
            COUNT(DISTINCT CASE WHEN DtDay > DATE('2025-10-01', '-14 day') THEN DtDay END) AS QtyActivationD14,
            COUNT(DISTINCT CASE WHEN DtDay > DATE('2025-10-01', '-28 day') THEN DtDay END) AS QtyActivationD28,
            COUNT(DISTINCT CASE WHEN DtDay > DATE('2025-10-01', '-56 day') THEN DtDay END) AS QtyActivationD56,

            COUNT(DISTINCT IdTransacao) AS QtyTransactionFullLife,
            COUNT(DISTINCT CASE WHEN DtDay > DATE('2025-10-01', '-7 day') THEN IdTransacao END) AS QtyTransactionD7,
            COUNT(DISTINCT CASE WHEN DtDay > DATE('2025-10-01', '-14 day') THEN IdTransacao END) AS QtyTransactionD14,
            COUNT(DISTINCT CASE WHEN DtDay > DATE('2025-10-01', '-28 day') THEN IdTransacao END) AS QtyTransactionD28,
            COUNT(DISTINCT CASE WHEN DtDay > DATE('2025-10-01', '-56 day') THEN IdTransacao END) AS QtyTransactionD56,

            SUM(QtdePontos) AS BalanceFullLife,
            SUM(CASE WHEN DtDay >= DATE('2025-10-01', '-7 day') THEN QtdePontos ELSE 0 END) AS BalanceD7,
            SUM(CASE WHEN DtDay >= DATE('2025-10-01', '-14 day') THEN QtdePontos ELSE 0 END) AS BalanceD14,
            SUM(CASE WHEN DtDay >= DATE('2025-10-01', '-28 day') THEN QtdePontos ELSE 0 END) AS BalanceD28,
            SUM(CASE WHEN DtDay >= DATE('2025-10-01', '-56 day') THEN QtdePontos ELSE 0 END) AS BalanceD56,

            SUM(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS QtyPointsPositiveFullLife,
            SUM(CASE WHEN DtDay >= DATE('2025-10-01', '-7 day') AND QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS QtyPointsPositiveD7,
            SUM(CASE WHEN DtDay >= DATE('2025-10-01', '-14 day') AND QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS QtyPointsPositiveD14,
            SUM(CASE WHEN DtDay >= DATE('2025-10-01', '-28 day') AND QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS QtyPointsPositiveD28,
            SUM(CASE WHEN DtDay >= DATE('2025-10-01', '-56 day') AND QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS QtyPointsPositiveD56,

            SUM(CASE WHEN QtdePontos < 0 THEN QtdePontos ELSE 0 END) AS QtyPointsNegativeFullLife,
            SUM(CASE WHEN DtDay >= DATE('2025-10-01', '-7 day') AND QtdePontos < 0 THEN QtdePontos ELSE 0 END) AS QtyPointsNegativeD7,
            SUM(CASE WHEN DtDay >= DATE('2025-10-01', '-14 day') AND QtdePontos < 0 THEN QtdePontos ELSE 0 END) AS QtyPointsNegativeD14,
            SUM(CASE WHEN DtDay >= DATE('2025-10-01', '-28 day') AND QtdePontos < 0 THEN QtdePontos ELSE 0 END) AS QtyPointsNegativeD28,
            SUM(CASE WHEN DtDay >= DATE('2025-10-01', '-56 day') AND QtdePontos < 0 THEN QtdePontos ELSE 0 END) AS QtyPointsNegativeD56

        FROM tb_transaction
        GROUP BY 1
    ),

    tb_agg_calc AS (

        SELECT * ,
            COALESCE(1.0 * QtyTransactionFullLife / QtyActivationFullLife , 0) AS QtyTransactionDayFullLife,
            COALESCE(1.0 * QtyTransactionD7 / QtyActivationD7 , 0) AS QtyTransactionDayD7,
            COALESCE(1.0 * QtyTransactionD14 / QtyActivationD14 , 0) AS QtyTransactionDayD14,
            COALESCE(1.0 * QtyTransactionD28 / QtyActivationD28 , 0) AS QtyTransactionDayD28,
            COALESCE(1.0 * QtyTransactionD56 / QtyActivationD56 , 0) AS QtyTransactionDayD56 ,

            COALESCE(1.0 * QtyActivationD28 / 28 , 0) AS pctActivationMAU 

        FROM tb_agg_transaction

    ),

    tb_hours_day AS (

        SELECT 
            IdCliente,
            DtDay,
            -- MAX(julianday(DtCriacao)) AS dtEnd,
            -- MIN(julianday(DtCriacao)) AS dtStart,
            (MAX(julianday(DtCriacao)) - MIN(julianday(DtCriacao))) * 24 AS Duration

        FROM tb_transaction
        GROUP BY 1, 2

    ),

    tb_hour_client AS (

        SELECT
            IdCliente,
            SUM(Duration) AS QtyHoursFullLife,
            SUM(CASE WHEN DtDay >= DATE('2025-10-01', '-7 day') THEN Duration ELSE 0 END) AS QtyHoursD7,
            SUM(CASE WHEN DtDay >= DATE('2025-10-01', '-14 day') THEN Duration ELSE 0 END) AS QtyHoursD14,
            SUM(CASE WHEN DtDay >= DATE('2025-10-01', '-28 day') THEN Duration ELSE 0 END) AS QtyHoursD28,
            SUM(CASE WHEN DtDay >= DATE('2025-10-01', '-56 day') THEN Duration ELSE 0 END) AS QtyHoursD56

        FROM tb_hours_day
        GROUP BY 1

    ),

    tb_lag_day AS (

        SELECT
            IdCliente,
            DtDay,
            LAG(DtDay) OVER (PARTITION BY IdCliente ORDER BY DtDay) AS LagDay

        FROM tb_hours_day

    ),

    tb_interval_days AS (

        SELECT
            IdCliente,
            AVG(julianday(DtDay) - julianday(LagDay)) AS AvgIntervalDaysFullLife,
            AVG(CASE WHEN DtDay >= DATE('2025-10-01', '-28 day') THEN julianday(DtDay) - julianday(LagDay) ELSE NULL END) AS AvgIntervalDaysD28

        FROM tb_lag_day
        GROUP BY 1

    ) 

SELECT
    t1.*,
    t2.QtyHoursFullLife,
    t2.QtyHoursD7,
    t2.QtyHoursD14,
    t2.QtyHoursD28,
    t2.QtyHoursD56,
    t3.AvgIntervalDaysFullLife,
    t3.AvgIntervalDaysD28

FROM tb_agg_calc AS t1
LEFT JOIN tb_hour_client AS t2 
    ON t1.IdCliente = t2.IdCliente

LEFT JOIN tb_interval_days AS t3
    ON t1.IdCliente = t3.IdCliente








