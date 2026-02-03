/*
    Slot Machine Performance Analysis
    ---------------------------------
    Analyzing machine-level metrics to identify top/bottom performers
    and understand revenue drivers on the slot floor.
*/

USE CasinoAnalytics;
GO

-- Which manufacturers are generating the most coin-in?
-- Breaking down by make to see where players are spending time
SELECT 
    make_name,
    COUNT(DISTINCT slot_name) AS machine_count,
    SUM(CAST(dollars_player_bet AS DECIMAL(18,2))) AS total_coin_in,
    SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) AS total_win,
    SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) / 
        NULLIF(SUM(CAST(dollars_player_bet AS DECIMAL(18,2))), 0) * 100 AS actual_hold_pct,
    AVG(CAST(slot_ideal_payback_pct AS DECIMAL(8,4))) * 100 AS avg_theoretical_hold
FROM slot_meters
WHERE dollars_player_bet > 0
GROUP BY make_name
ORDER BY total_coin_in DESC;


-- Top 20 individual machines by revenue (actual win)
-- Good for identifying which specific units are driving floor performance
SELECT TOP 20
    sm.slot_name,
    sm.model_name,
    sm.make_name,
    SUM(CAST(sm.dollars_player_bet AS DECIMAL(18,2))) AS total_coin_in,
    SUM(CAST(sm.dollars_player_lost AS DECIMAL(18,2))) AS actual_win,
    SUM(CAST(sm.theory_player_lost AS DECIMAL(18,2))) AS theoretical_win,
    SUM(CAST(sm.dollars_player_lost AS DECIMAL(18,2))) - 
        SUM(CAST(sm.theory_player_lost AS DECIMAL(18,2))) AS win_vs_theo,
    COUNT(*) AS hours_active
FROM slot_meters sm
GROUP BY sm.slot_name, sm.model_name, sm.make_name
HAVING SUM(CAST(sm.dollars_player_bet AS DECIMAL(18,2))) > 5000  -- filter out low activity
ORDER BY actual_win DESC;


-- Underperforming machines (actual hold significantly below theoretical)
-- These might need attention - could indicate issues or just variance
SELECT 
    slot_name,
    model_name,
    make_name,
    SUM(CAST(dollars_player_bet AS DECIMAL(18,2))) AS coin_in,
    SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) AS actual_win,
    SUM(CAST(theory_player_lost AS DECIMAL(18,2))) AS theo_win,
    (SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) - 
        SUM(CAST(theory_player_lost AS DECIMAL(18,2)))) AS variance,
    CASE 
        WHEN SUM(CAST(theory_player_lost AS DECIMAL(18,2))) > 0 
        THEN (SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) / 
              SUM(CAST(theory_player_lost AS DECIMAL(18,2)))) * 100 
        ELSE 0 
    END AS pct_of_theo
FROM slot_meters
GROUP BY slot_name, model_name, make_name
HAVING SUM(CAST(dollars_player_bet AS DECIMAL(18,2))) > 10000
    AND SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) < SUM(CAST(theory_player_lost AS DECIMAL(18,2))) * 0.8
ORDER BY variance ASC;


-- Hourly slot floor activity patterns
-- Useful for staffing decisions and understanding peak times
SELECT 
    DATEPART(HOUR, CAST(slot_reading_hour AS DATETIME)) AS hour_of_day,
    COUNT(*) AS readings,
    SUM(CAST(games_played_this_hour AS INT)) AS total_games,
    SUM(CAST(dollars_player_bet AS DECIMAL(18,2))) AS total_coin_in,
    AVG(CAST(dollars_player_bet AS DECIMAL(18,2))) AS avg_coin_in_per_machine
FROM slot_meters
WHERE slot_reading_hour IS NOT NULL
    AND TRY_CAST(slot_reading_hour AS DATETIME) IS NOT NULL
GROUP BY DATEPART(HOUR, CAST(slot_reading_hour AS DATETIME))
ORDER BY hour_of_day;


-- Day of week analysis
SELECT 
    DATENAME(WEEKDAY, CAST(slot_reading_hour AS DATETIME)) AS day_of_week,
    DATEPART(WEEKDAY, CAST(slot_reading_hour AS DATETIME)) AS day_num,
    SUM(CAST(dollars_player_bet AS DECIMAL(18,2))) AS total_coin_in,
    SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) AS total_win,
    COUNT(DISTINCT slot_name) AS active_machines
FROM slot_meters
WHERE TRY_CAST(slot_reading_hour AS DATETIME) IS NOT NULL
GROUP BY 
    DATENAME(WEEKDAY, CAST(slot_reading_hour AS DATETIME)),
    DATEPART(WEEKDAY, CAST(slot_reading_hour AS DATETIME))
ORDER BY day_num;
