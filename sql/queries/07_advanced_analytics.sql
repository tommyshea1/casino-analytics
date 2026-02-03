/*
    Advanced Analytics Queries
    --------------------------
    More complex analysis using window functions,
    ranking, and multi-step CTEs. Good for showing
    deeper SQL proficiency.
*/

USE CasinoAnalytics;
GO

-- Machine performance ranking within each manufacturer
-- Useful for comparing apples to apples
SELECT 
    make_name,
    slot_name,
    model_name,
    total_coin_in,
    actual_win,
    RANK() OVER (PARTITION BY make_name ORDER BY actual_win DESC) AS rank_within_make,
    PERCENT_RANK() OVER (PARTITION BY make_name ORDER BY actual_win) AS percentile
FROM (
    SELECT 
        make_name,
        slot_name,
        model_name,
        SUM(CAST(dollars_player_bet AS DECIMAL(18,2))) AS total_coin_in,
        SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) AS actual_win
    FROM slot_meters
    GROUP BY make_name, slot_name, model_name
    HAVING SUM(CAST(dollars_player_bet AS DECIMAL(18,2))) > 1000
) sub
ORDER BY make_name, rank_within_make;


-- Player value quartiles
-- Segmenting players into value buckets
WITH player_values AS (
    SELECT 
        player_name,
        player_card_level,
        SUM(CAST(dollar_theory_lost AS DECIMAL(18,2))) AS lifetime_theo,
        COUNT(*) AS visit_count,
        NTILE(4) OVER (ORDER BY SUM(CAST(dollar_theory_lost AS DECIMAL(18,2)))) AS value_quartile
    FROM slot_play
    GROUP BY player_name, player_card_level
    HAVING SUM(CAST(dollar_theory_lost AS DECIMAL(18,2))) > 0
)
SELECT 
    value_quartile,
    COUNT(*) AS player_count,
    MIN(lifetime_theo) AS min_theo,
    MAX(lifetime_theo) AS max_theo,
    AVG(lifetime_theo) AS avg_theo,
    SUM(lifetime_theo) AS total_theo
FROM player_values
GROUP BY value_quartile
ORDER BY value_quartile;


-- Running total of daily slot revenue
WITH daily_revenue AS (
    SELECT 
        CAST(TRY_CAST(slot_reading_hour AS DATETIME) AS DATE) AS gaming_date,
        SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) AS daily_win
    FROM slot_meters
    WHERE TRY_CAST(slot_reading_hour AS DATETIME) IS NOT NULL
    GROUP BY CAST(TRY_CAST(slot_reading_hour AS DATETIME) AS DATE)
)
SELECT 
    gaming_date,
    daily_win,
    SUM(daily_win) OVER (ORDER BY gaming_date ROWS UNBOUNDED PRECEDING) AS ytd_win,
    AVG(daily_win) OVER (ORDER BY gaming_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_7day_avg
FROM daily_revenue
ORDER BY gaming_date;


-- Player visit gaps - identifying players who may be churning
WITH player_visits AS (
    SELECT 
        player_name,
        TRY_CAST(LEFT(play_start_date, 10) AS DATE) AS visit_date,
        ROW_NUMBER() OVER (PARTITION BY player_name ORDER BY TRY_CAST(LEFT(play_start_date, 10) AS DATE)) AS visit_num
    FROM slot_play
    WHERE TRY_CAST(LEFT(play_start_date, 10) AS DATE) IS NOT NULL
),
visit_gaps AS (
    SELECT 
        pv1.player_name,
        pv1.visit_date AS current_visit,
        pv2.visit_date AS previous_visit,
        DATEDIFF(DAY, pv2.visit_date, pv1.visit_date) AS days_between
    FROM player_visits pv1
    LEFT JOIN player_visits pv2 
        ON pv1.player_name = pv2.player_name 
        AND pv1.visit_num = pv2.visit_num + 1
)
SELECT 
    CASE 
        WHEN days_between IS NULL THEN 'First Visit'
        WHEN days_between <= 7 THEN 'Within 1 week'
        WHEN days_between <= 30 THEN '1-4 weeks'
        WHEN days_between <= 90 THEN '1-3 months'
        ELSE 'Over 3 months'
    END AS return_timeframe,
    COUNT(*) AS visit_count
FROM visit_gaps
GROUP BY 
    CASE 
        WHEN days_between IS NULL THEN 'First Visit'
        WHEN days_between <= 7 THEN 'Within 1 week'
        WHEN days_between <= 30 THEN '1-4 weeks'
        WHEN days_between <= 90 THEN '1-3 months'
        ELSE 'Over 3 months'
    END
ORDER BY MIN(ISNULL(days_between, 0));


-- Machine model comparison - same model across different units
-- Helps identify if performance differences are machine-specific or model-wide
SELECT 
    model_name,
    make_name,
    COUNT(DISTINCT slot_name) AS unit_count,
    AVG(coin_in) AS avg_coin_in,
    STDEV(coin_in) AS stdev_coin_in,  -- high variance might indicate inconsistent performance
    MIN(coin_in) AS min_coin_in,
    MAX(coin_in) AS max_coin_in
FROM (
    SELECT 
        slot_name,
        model_name,
        make_name,
        SUM(CAST(dollars_player_bet AS DECIMAL(18,2))) AS coin_in
    FROM slot_meters
    GROUP BY slot_name, model_name, make_name
) machine_totals
GROUP BY model_name, make_name
HAVING COUNT(DISTINCT slot_name) > 1  -- only models with multiple units
ORDER BY avg_coin_in DESC;


-- Cross-gaming player analysis
-- Players who play both slots and tables - their relative value in each
WITH slot_value AS (
    SELECT 
        player_name,
        SUM(CAST(dollar_theory_lost AS DECIMAL(18,2))) AS slot_theo,
        SUM(CAST(total_minutes_played AS INT)) AS slot_time
    FROM slot_play
    GROUP BY player_name
),
table_value AS (
    SELECT 
        player_name,
        SUM(CAST(player_lost AS DECIMAL(18,2))) AS table_win,
        SUM(CAST(total_minutes_played AS INT)) AS table_time
    FROM table_play
    GROUP BY player_name
)
SELECT TOP 50
    COALESCE(s.player_name, t.player_name) AS player_name,
    ISNULL(s.slot_theo, 0) AS slot_theo,
    ISNULL(t.table_win, 0) AS table_value,
    ISNULL(s.slot_theo, 0) + ISNULL(t.table_win, 0) AS combined_value,
    CASE 
        WHEN ISNULL(s.slot_theo, 0) > ISNULL(t.table_win, 0) THEN 'Slots-Dominant'
        WHEN ISNULL(t.table_win, 0) > ISNULL(s.slot_theo, 0) THEN 'Tables-Dominant'
        ELSE 'Balanced'
    END AS player_type,
    ISNULL(s.slot_time, 0) + ISNULL(t.table_time, 0) AS total_gaming_minutes
FROM slot_value s
FULL OUTER JOIN table_value t ON s.player_name = t.player_name
WHERE ISNULL(s.slot_theo, 0) + ISNULL(t.table_win, 0) > 100
ORDER BY combined_value DESC;
