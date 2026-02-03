/*
    Executive KPI Dashboard Queries
    --------------------------------
    High-level metrics for management reporting.
    These would typically feed into a summary dashboard.
*/

USE CasinoAnalytics;
GO

-- Overall gaming floor summary
SELECT 
    'Slot Machines' AS gaming_type,
    COUNT(DISTINCT slot_name) AS units,
    SUM(CAST(dollars_player_bet AS DECIMAL(18,2))) AS total_handle,
    SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) AS gaming_revenue,
    SUM(CAST(theory_player_lost AS DECIMAL(18,2))) AS theoretical_revenue
FROM slot_meters
UNION ALL
SELECT 
    'Table Games',
    COUNT(DISTINCT table_name),
    SUM(CAST(cash_buy_in AS DECIMAL(18,2))),  -- drop as proxy for handle
    SUM(CAST(player_lost AS DECIMAL(18,2))),
    NULL  -- no theo captured in this data
FROM table_play;


-- Monthly revenue trend
WITH monthly_slots AS (
    SELECT 
        YEAR(TRY_CAST(slot_reading_hour AS DATETIME)) AS yr,
        MONTH(TRY_CAST(slot_reading_hour AS DATETIME)) AS mo,
        SUM(CAST(dollars_player_bet AS DECIMAL(18,2))) AS slot_coin_in,
        SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) AS slot_win
    FROM slot_meters
    WHERE TRY_CAST(slot_reading_hour AS DATETIME) IS NOT NULL
    GROUP BY 
        YEAR(TRY_CAST(slot_reading_hour AS DATETIME)),
        MONTH(TRY_CAST(slot_reading_hour AS DATETIME))
)
SELECT 
    yr AS year,
    mo AS month,
    slot_coin_in,
    slot_win,
    LAG(slot_win) OVER (ORDER BY yr, mo) AS prev_month_win,
    slot_win - LAG(slot_win) OVER (ORDER BY yr, mo) AS mom_change
FROM monthly_slots
ORDER BY yr, mo;


-- Player acquisition and retention snapshot
WITH first_visits AS (
    SELECT 
        player_name,
        MIN(TRY_CAST(LEFT(play_start_date, 10) AS DATE)) AS first_visit
    FROM slot_play
    WHERE TRY_CAST(LEFT(play_start_date, 10) AS DATE) IS NOT NULL
    GROUP BY player_name
)
SELECT 
    YEAR(first_visit) AS cohort_year,
    MONTH(first_visit) AS cohort_month,
    COUNT(*) AS new_players
FROM first_visits
WHERE first_visit IS NOT NULL
GROUP BY YEAR(first_visit), MONTH(first_visit)
ORDER BY cohort_year, cohort_month;


-- Active player count by month
WITH monthly_players AS (
    SELECT DISTINCT
        player_name,
        YEAR(TRY_CAST(slot_play_hour AS DATETIME)) AS yr,
        MONTH(TRY_CAST(slot_play_hour AS DATETIME)) AS mo
    FROM slot_play
    WHERE TRY_CAST(slot_play_hour AS DATETIME) IS NOT NULL
)
SELECT 
    yr,
    mo,
    COUNT(DISTINCT player_name) AS active_players
FROM monthly_players
GROUP BY yr, mo
ORDER BY yr, mo;


-- Slot hold percentage trend
SELECT 
    YEAR(TRY_CAST(slot_reading_hour AS DATETIME)) AS yr,
    MONTH(TRY_CAST(slot_reading_hour AS DATETIME)) AS mo,
    SUM(CAST(dollars_player_bet AS DECIMAL(18,2))) AS coin_in,
    SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) AS win,
    CASE 
        WHEN SUM(CAST(dollars_player_bet AS DECIMAL(18,2))) > 0
        THEN SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) / 
             SUM(CAST(dollars_player_bet AS DECIMAL(18,2))) * 100
        ELSE 0
    END AS actual_hold_pct
FROM slot_meters
WHERE TRY_CAST(slot_reading_hour AS DATETIME) IS NOT NULL
GROUP BY 
    YEAR(TRY_CAST(slot_reading_hour AS DATETIME)),
    MONTH(TRY_CAST(slot_reading_hour AS DATETIME))
ORDER BY yr, mo;


-- Quick revenue snapshot for dashboards
SELECT 
    (SELECT SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) FROM slot_meters) AS total_slot_win,
    (SELECT SUM(CAST(player_lost AS DECIMAL(18,2))) FROM table_play) AS total_table_win,
    (SELECT SUM(CAST(order_total_dollars AS DECIMAL(12,2))) FROM bar_orders) AS total_fb_revenue,
    (SELECT SUM(CAST(promotion_value AS DECIMAL(12,2))) FROM promotions) AS total_promo_issued,
    (SELECT COUNT(DISTINCT player_name) FROM slot_play) AS unique_slot_players,
    (SELECT COUNT(DISTINCT player_name) FROM table_play) AS unique_table_players;
