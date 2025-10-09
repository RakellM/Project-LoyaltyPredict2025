WITH
    tb_follower_course AS (

        SELECT
            idUsuario,
            descSlugCurso,
            COUNT(descSlugCursoEpisodio) AS QtyEps

        FROM cursos_episodios_completos
        WHERE DtCriacao < '{date}'
        GROUP BY 1, 2

    ),

    tb_course_total_eps AS (

        SELECT
            descSlugCurso,
            COUNT(descEpisodio) AS QtyTotalEps

        FROM cursos_episodios

        GROUP BY 1
    ),

    tb_pct_course_completed AS (

        SELECT
            t1.idUsuario,
            t1.descSlugCurso,
            1.0 * t1.QtyEps / t2.QtyTotalEps AS PctCourseCompleted

        FROM tb_follower_course AS t1

        LEFT JOIN tb_course_total_eps AS t2
            ON t1.descSlugCurso = t2.descSlugCurso 

    ),

    tb_pct_course_pivot AS (

        SELECT 
            idUsuario,

            SUM(CASE WHEN PctCourseCompleted = 1 THEN 1 ELSE 0 END) AS QtyCoursesCompleted,
            SUM(CASE WHEN PctCourseCompleted > 0 AND PctCourseCompleted < 1 THEN 1 ELSE 0 END) AS QtyCoursesIncompleted,

            SUM(CASE WHEN descSlugCurso = 'carreira' THEN pctCourseCompleted ELSE 0 END) AS carreira,
            SUM(CASE WHEN descSlugCurso = 'coleta-dados-2024' THEN pctCourseCompleted ELSE 0 END) AS coletaDados2024,
            SUM(CASE WHEN descSlugCurso = 'ds-databricks-2024' THEN pctCourseCompleted ELSE 0 END) AS dsDatabricks2024,
            SUM(CASE WHEN descSlugCurso = 'ds-pontos-2024' THEN pctCourseCompleted ELSE 0 END) AS dsPontos2024,
            SUM(CASE WHEN descSlugCurso = 'estatistica-2024' THEN pctCourseCompleted ELSE 0 END) AS estatistica2024,
            SUM(CASE WHEN descSlugCurso = 'estatistica-2025' THEN pctCourseCompleted ELSE 0 END) AS estatistica2025,
            SUM(CASE WHEN descSlugCurso = 'github-2024' THEN pctCourseCompleted ELSE 0 END) AS github2024,
            SUM(CASE WHEN descSlugCurso = 'github-2025' THEN pctCourseCompleted ELSE 0 END) AS github2025,
            SUM(CASE WHEN descSlugCurso = 'ia-canal-2025' THEN pctCourseCompleted ELSE 0 END) AS iaCanal2025,
            SUM(CASE WHEN descSlugCurso = 'lago-mago-2024' THEN pctCourseCompleted ELSE 0 END) AS lagoMago2024,
            SUM(CASE WHEN descSlugCurso = 'machine-learning-2025' THEN pctCourseCompleted ELSE 0 END) AS machineLearning2025,
            SUM(CASE WHEN descSlugCurso = 'matchmaking-trampar-de-casa-2024' THEN pctCourseCompleted ELSE 0 END) AS matchmakingTramparDeCasa2024,
            SUM(CASE WHEN descSlugCurso = 'ml-2024' THEN pctCourseCompleted ELSE 0 END) AS ml2024,
            SUM(CASE WHEN descSlugCurso = 'mlflow-2025' THEN pctCourseCompleted ELSE 0 END) AS mlflow2025,
            SUM(CASE WHEN descSlugCurso = 'pandas-2024' THEN pctCourseCompleted ELSE 0 END) AS pandas2024,
            SUM(CASE WHEN descSlugCurso = 'pandas-2025' THEN pctCourseCompleted ELSE 0 END) AS pandas2025,
            SUM(CASE WHEN descSlugCurso = 'python-2024' THEN pctCourseCompleted ELSE 0 END) AS python2024,
            SUM(CASE WHEN descSlugCurso = 'python-2025' THEN pctCourseCompleted ELSE 0 END) AS python2025,
            SUM(CASE WHEN descSlugCurso = 'sql-2020' THEN pctCourseCompleted ELSE 0 END) AS sql2020,
            SUM(CASE WHEN descSlugCurso = 'sql-2025' THEN pctCourseCompleted ELSE 0 END) AS sql2025,
            SUM(CASE WHEN descSlugCurso = 'streamlit-2025' THEN pctCourseCompleted ELSE 0 END) AS streamlit2025,
            SUM(CASE WHEN descSlugCurso = 'trampar-lakehouse-2024' THEN pctCourseCompleted ELSE 0 END) AS tramparLakehouse2024,
            SUM(CASE WHEN descSlugCurso = 'tse-analytics-2024' THEN pctCourseCompleted ELSE 0 END) AS tseAnalytics2024

        FROM tb_pct_course_completed

        GROUP BY 1

    ),

    tb_atividade AS (

        SELECT
            idUsuario,
            -- idRecompensa AS descActivity,
            MAX(dtRecompensa) AS dtCriacao
        FROM recompensas_usuarios
        WHERE dtRecompensa < '{date}'
        GROUP BY 1

    UNION ALL

        SELECT
            idUsuario,
            -- descNomeHabilidade AS descActivity,
            MAX(dtCriacao) AS dtCriacao
        FROM habilidades_usuarios
        WHERE DtCriacao < '{date}'
        GROUP BY 1

    UNION ALL

        SELECT
            idUsuario,
            -- descSlugCurso AS descActivity,
            MAX(dtCriacao) AS dtCriacao
        FROM cursos_episodios_completos
        WHERE DtCriacao < '{date}'
        GROUP BY 1

    ),

    tb_last_activity AS (

        SELECT 
            idUsuario,
            MIN( julianday('{date}') - julianday(dtCriacao)) AS QtyDaysLastActivity

        FROM tb_atividade
        GROUP BY 1

    ),

    tb_join AS (

        SELECT
            t3.idTMWCliente AS IdCliente,
            t1.QtyCoursesCompleted,
            t1.QtyCoursesIncompleted,
            t1.carreira,
            t1.coletaDados2024,
            t1.dsDatabricks2024,
            t1.dsPontos2024,
            t1.estatistica2024,
            t1.estatistica2025,
            t1.github2024,
            t1.github2025,
            t1.iaCanal2025,
            t1.lagoMago2024,
            t1.machineLearning2025,
            t1.matchmakingTramparDeCasa2024,
            t1.ml2024,
            t1.mlflow2025,
            t1.pandas2024,
            t1.pandas2025,
            t1.python2024,
            t1.python2025,
            t1.sql2020,
            t1.sql2025,
            t1.streamlit2025,
            t1.tramparLakehouse2024,
            t1.tseAnalytics2024,
            t2.QtyDaysLastActivity

        FROM tb_pct_course_pivot AS t1

        LEFT JOIN tb_last_activity AS t2
            ON t1.idUsuario = t2.idUsuario

        INNER JOIN usuarios_tmw AS t3
            ON t1.idUsuario = t3.idUsuario

    )

SELECT
    DATE('{date}', '-1 day') AS DtRef,
    *
FROM tb_join