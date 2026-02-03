/*
    Table Games Analysis
    --------------------
    Evaluating table game performance, player ratings, 
    and comparing to slot floor metrics.
*/

USE CasinoAnalytics;
GO

-- Table game summary by game type
-- Extracting game type from table name prefix
SELECT 
    CASE 
        WHEN table_name LIKE 'BJ%' THEN 'Blackjack'
        WHEN table_name LIKE 'AR%' THEN 'Roulette'
        WHEN table_name LIKE 'PK%' THEN 'Poker'
        WHEN table_name LIKE 'CR%' THEN 'Craps'
        ELSE 'Other'
    END AS game_type,
    COUNT(*) AS total_sessions,
    COUNT(DISTINCT player_name) AS unique_players,
    SUM(CAST(cash_buy_in AS DECIMAL(18,2))) AS total_buy_ins,
    SUM(CAST(player_lost AS DECIMAL(18,2))) AS total_player_loss,
    AVG(CAST(total_minutes_played AS INT)) AS avg_session_length,
    AVG(CAST(hold_percentage AS DECIMAL(8,5))) * 100 AS avg_hold_pct
FROM table_play
GROUP BY 
    CASE 
        WHEN table_name LIKE 'BJ%' THEN 'Blackjack'
        WHEN table_name LIKE 'AR%' THEN 'Roulette'
        WHEN table_name LIKE 'PK%' THEN 'Poker'
        WHEN table_name LIKE 'CR%' THEN 'Craps'
        ELSE 'Other'
    END
ORDER BY total_buy_ins DESC;


-- Individual table performance
SELECT 
    table_name,
    COUNT(*) AS sessions,
    SUM(CAST(cash_buy_in AS DECIMAL(18,2))) AS total_drop,
    SUM(CAST(player_lost AS DECIMAL(18,2))) AS table_win,
    AVG(CAST(average_bet AS DECIMAL(10,2))) AS avg_bet,
    AVG(CAST(bets_per_hour AS INT)) AS avg_hands_per_hour
FROM table_play
GROUP BY table_name
ORDER BY table_win DESC;


-- High value table players
-- Players with significant buy-in amounts
SELECT TOP 30
    player_name,
    player_card_level,
    COUNT(*) AS sessions,
    SUM(CAST(cash_buy_in AS DECIMAL(18,2))) AS total_buy_in,
    SUM(CAST(player_lost AS DECIMAL(18,2))) AS total_loss,
    SUM(CAST(cash_out AS DECIMAL(18,2))) AS total_cash_out,
    AVG(CAST(average_bet AS DECIMAL(10,2))) AS avg_bet_size,
    SUM(CAST(total_minutes_played AS INT)) AS total_time_played
FROM table_play
GROUP BY player_name, player_card_level
HAVING SUM(CAST(cash_buy_in AS DECIMAL(18,2))) > 500
ORDER BY total_buy_in DESC;


-- Table game hourly patterns
SELECT 
    DATEPART(HOUR, TRY_CAST(play_start_date AS DATETIME)) AS hour_of_day,
    COUNT(*) AS sessions_started,
    SUM(CAST(cash_buy_in AS DECIMAL(18,2))) AS total_drop,
    AVG(CAST(total_minutes_played AS INT)) AS avg_duration
FROM table_play
WHERE TRY_CAST(play_start_date AS DATETIME) IS NOT NULL
GROUP BY DATEPART(HOUR, TRY_CAST(play_start_date AS DATETIME))
ORDER BY hour_of_day;


-- Comparing slots vs tables player value
-- Which channel generates more from shared players?
WITH slot_players AS (
    SELECT 
        player_name,
        SUM(CAST(dollar_theory_lost AS DECIMAL(18,2))) AS slot_theo
    FROM slot_play
    GROUP BY player_name
),
table_players AS (
    SELECT 
        player_name,
        SUM(CAST(player_lost AS DECIMAL(18,2))) AS table_loss
    FROM table_play
    GROUP BY player_name
)
SELECT 
    CASE 
        WHEN sp.player_name IS NOT NULL AND tp.player_name IS NOT NULL THEN 'Both'
        WHEN sp.player_name IS NOT NULL THEN 'Slots Only'
        ELSE 'Tables Only'
    END AS player_type,
    COUNT(*) AS player_count,
    SUM(ISNULL(sp.slot_theo, 0)) AS total_slot_theo,
    SUM(ISNULL(tp.table_loss, 0)) AS total_table_loss
FROM slot_players sp
FULL OUTER JOIN table_players tp ON sp.player_name = tp.player_name
GROUP BY 
    CASE 
        WHEN sp.player_name IS NOT NULL AND tp.player_name IS NOT NULL THEN 'Both'
        WHEN sp.player_name IS NOT NULL THEN 'Slots Only'
        ELSE 'Tables Only'
    END;
