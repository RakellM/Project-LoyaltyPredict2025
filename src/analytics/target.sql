CREATE TABLE abt_sorcerer AS 

WITH
    tb_join AS (

        SELECT
            t1.DtRef,
            t1.IdCliente,
            t1.descLifeCycle,
            t2.descLifeCycle AS descLifeCycleD28,
            (CASE WHEN t2.descLifeCycle = '02-Sorcerer' THEN 1 ELSE 0 END) AS flSorcerer,
            row_number() OVER (PARTITION BY t1.IdCliente ORDER BY random()) AS randomCol

        FROM life_cycle AS t1 

        LEFT JOIN life_cycle AS t2
            ON t1.IdCliente = t2.IdCliente
            AND DATE(t1.DtRef, '+28 day') = DATE(t2.DtRef)

        WHERE (( t1.DtRef >= '2024-03-01' AND t1.DtRef <= '2025-08-01' ) 
            OR t1.DtRef = '2025-09-01')
            AND t1.descLifeCycle != '05-Petrified'
    ),

    tb_cohort AS (

        SELECT
            DtRef,
            IdCliente,
            flSorcerer

        FROM tb_join

        WHERE randomCol <= 2

        ORDER BY IdCliente, DtRef

    )

SELECT
    t1.*,
    t2.AgeDays, 
    t2.QtyActivationFullLife, 
    t2.QtyActivationD7, 
    t2.QtyActivationD14, 
    t2.QtyActivationD28, 
    t2.QtyActivationD56, 
    t2.QtyTransactionFullLife, 
    t2.QtyTransactionD7, 
    t2.QtyTransactionD14, 
    t2.QtyTransactionD28, 
    t2.QtyTransactionD56, 
    t2.BalanceFullLife, 
    t2.BalanceD7, 
    t2.BalanceD14, 
    t2.BalanceD28, 
    t2.BalanceD56, 
    t2.QtyPointsPositiveFullLife, 
    t2.QtyPointsPositiveD7, 
    t2.QtyPointsPositiveD14, 
    t2.QtyPointsPositiveD28, 
    t2.QtyPointsPositiveD56, 
    t2.QtyPointsNegativeFullLife, 
    t2.QtyPointsNegativeD7, 
    t2.QtyPointsNegativeD14, 
    t2.QtyPointsNegativeD28, 
    t2.QtyPointsNegativeD56, 
    t2.QtyTransactionMorning, 
    t2.QtyTransactionAfternoon, 
    t2.QtyTransactionEvening, 
    t2.pctTransactionMorning, 
    t2.pctTransactionAfternoon, 
    t2.pctTransactionEvening, 
    t2.QtyTransactionDayFullLife, 
    t2.QtyTransactionDayD7, 
    t2.QtyTransactionDayD14, 
    t2.QtyTransactionDayD28, 
    t2.QtyTransactionDayD56, 
    t2.pctActivationMAU, 
    t2.QtyHoursFullLife, 
    t2.QtyHoursD7, 
    t2.QtyHoursD14, 
    t2.QtyHoursD28, 
    t2.QtyHoursD56, 
    t2.AvgIntervalDaysFullLife, 
    t2.AvgIntervalDaysD28, 
    t2.pctChatMessage, 
    t2.pctAirflowLover, 
    t2.pctRLover, 
    t2.pctResgatarPonei, 
    t2.pctListadePresenca, 
    t2.pctPresencaStreak, 
    t2.pctTrocadePontosStreamElements, 
    t2.pctReembolsoStreamElements, 
    t2.pctRPG, 
    t2.pctChurnModel,
    t3.DtRef, 
    t3.IdCliente, 
    t3.Frequency, 
    t3.descLifeCycleCurrent, 
    t3.descLifeCycleD28, 
    t3.pctApprendice, 
    t3.pctSorcerer, 
    t3.pctWondered, 
    t3.pctFading, 
    t3.pctPetrified, 
    t3.pctReawakened, 
    t3.pctResurrected, 
    t3.avgFreqGroup, 
    t3.ratioFreqGroup,
    t4.QtyCoursesCompleted, 
    t4.QtyCoursesIncompleted, 
    t4.carreira,
    t4.coletaDados2024, 
    t4.dsDatabricks2024, 
    t4.dsPontos2024, 
    t4.estatistica2024,
    t4.estatistica2025,
    t4.github2024,
    t4.github2025,
    t4.iaCanal2025, 
    t4.lagoMago2024, 
    t4.machineLearning2025, 
    t4.matchmakingTramparDeCasa2024, 
    t4.ml2024,
    t4.mlflow2025,
    t4.pandas2024,
    t4.pandas2025,
    t4.python2024,
    t4.python2025,
    t4.sql2020,
    t4.sql2025,
    t4.streamlit2025,
    t4.tramparLakehouse2024, 
    t4.tseAnalytics2024, 
    t4.QtyDaysLastActivity

FROM tb_cohort AS t1 

LEFT JOIN fs_transactional AS t2
    ON t1.IdCliente = t2.IdCliente
    AND t1.DtRef = t2.DtRef

LEFT JOIN fs_lifecycle AS t3
    ON t1.IdCliente = t3.IdCliente
    AND t1.DtRef = t3.DtRef

LEFT JOIN fs_educational AS t4
    ON t1.IdCliente = t4.IdCliente
    AND t1.DtRef = t4.DtRef

