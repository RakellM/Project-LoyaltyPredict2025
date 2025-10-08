WITH
    tb_transaction AS (

        SELECT 
            *,
            SUBSTR(DtCriacao, 0,11) AS DtDay,
            CAST(SUBSTR(DtCriacao, 12, 2) AS INT) AS DtHour
        FROM transacoes
        WHERE DtCriacao < '2025-10-01'

    ),

    tb_agg_transaction AS (

        SELECT
            IdCliente,

            MAX(julianday('2025-10-01') - julianday(DtCriacao)) AS AgeDays,

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
            SUM(CASE WHEN DtDay >= DATE('2025-10-01', '-56 day') AND QtdePontos < 0 THEN QtdePontos ELSE 0 END) AS QtyPointsNegativeD56,

            -- remember this dates are UTC time and Teo is in UTC-3
            COUNT(CASE WHEN DtHour BETWEEN 10 AND 14 THEN IdTransacao END) AS QtyTransactionMorning,
            COUNT(CASE WHEN DtHour BETWEEN 15 AND 21 THEN IdTransacao END) AS QtyTransactionAfternoon,
            COUNT(CASE WHEN DtHour > 21 OR DtHour < 10 THEN IdTransacao END) AS QtyTransactionEvening,

            1.0 * COUNT(CASE WHEN DtHour BETWEEN 10 AND 14 THEN IdTransacao END) / COUNT(IdTransacao) AS pctTransactionMorning,
            1.0 * COUNT(CASE WHEN DtHour BETWEEN 15 AND 21 THEN IdTransacao END) / COUNT(IdTransacao) AS pctTransactionAfternoon,
            1.0 * COUNT(CASE WHEN DtHour > 21 OR DtHour < 10 THEN IdTransacao END) / COUNT(IdTransacao) AS pctTransactionEvening

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

    ),

    tb_share_product AS (

        SELECT
            t1.IdCliente,
            1.0 * COUNT(CASE WHEN t3.DescNomeProduto = 'ChatMessage' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS pctChatMessage,
            1.0 * COUNT(CASE WHEN t3.DescNomeProduto = 'Airflow Lover' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS pctAirflowLover,
            1.0 * COUNT(CASE WHEN t3.DescNomeProduto = 'R Lover' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS pctRLover,
            1.0 * COUNT(CASE WHEN t3.DescNomeProduto = 'Resgatar Ponei' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS pctResgatarPonei,
            1.0 * COUNT(CASE WHEN t3.DescNomeProduto = 'Lista de presença' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS pctListadePresenca,
            1.0 * COUNT(CASE WHEN t3.DescNomeProduto = 'Presença Streak' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS pctPresencaStreak,
            1.0 * COUNT(CASE WHEN t3.DescNomeProduto = 'Troca de Pontos StreamElements' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS pctTrocadePontosStreamElements,
            1.0 * COUNT(CASE WHEN t3.DescNomeProduto = 'Reembolso: Troca de Pontos StreamElements' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS pctReembolsoStreamElements,

            1.0 * COUNT(CASE WHEN t3.DescCategoriaProduto = 'rpg' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS pctRPG,
            1.0 * COUNT(CASE WHEN t3.DescCategoriaProduto = 'chrun_model' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS pctChurnModel

        FROM tb_transaction AS t1

        LEFT JOIN transacao_produto AS t2
            ON t1.IdTransacao = t2.IdTransacao

        LEFT JOIN produtos AS t3
            ON t2.IdProduto = t3.IdProduto

        GROUP BY 1
    ),

    tb_join AS (

        SELECT
            t1.*,
            t2.QtyHoursFullLife,
            t2.QtyHoursD7,
            t2.QtyHoursD14,
            t2.QtyHoursD28,
            t2.QtyHoursD56,
            t3.AvgIntervalDaysFullLife,
            t3.AvgIntervalDaysD28,
            t4.pctChatMessage,
            t4.pctAirflowLover,
            t4.pctRLover,
            t4.pctResgatarPonei,
            t4.pctListadePresenca,
            t4.pctPresencaStreak,
            t4.pctTrocadePontosStreamElements,
            t4.pctReembolsoStreamElements,
            t4.pctRPG,
            t4.pctChurnModel

        FROM tb_agg_calc AS t1
        LEFT JOIN tb_hour_client AS t2 
            ON t1.IdCliente = t2.IdCliente

        LEFT JOIN tb_interval_days AS t3
            ON t1.IdCliente = t3.IdCliente

        LEFT JOIN tb_share_product AS t4
            ON t1.IdCliente = t4.IdCliente

    ) 

SELECT
    DATE('2025-10-01') AS DtRef,
    *
FROM tb_join

