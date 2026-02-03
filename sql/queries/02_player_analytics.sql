/*
    Player Analytics & Segmentation
    --------------------------------
    Understanding player behavior, value tiers, and gaming patterns.
    Key for marketing and player development strategies.
*/

USE CasinoAnalytics;
GO

-- Player value summary by card tier
-- Shows the distribution of play across loyalty levels
SELECT 
    player_card_level,
    COUNT(DISTINCT player_name) AS unique_players,
    COUNT(*) AS total_sessions,
    SUM(CAST(total_dollars_bet AS DECIMAL(18,2))) AS total_wagered,
    SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) AS total_player_loss,
    AVG(CAST(total_dollars_bet AS DECIMAL(18,2))) AS avg_session_bet,
    AVG(CAST(total_minutes_played AS INT)) AS avg_session_minutes
FROM slot_play
WHERE player_card_level IS NOT NULL
GROUP BY player_card_level
ORDER BY total_wagered DESC;


-- Top 50 players by theoretical value (ADT proxy)
-- Theo is more reliable than actual win for measuring player worth
SELECT TOP 50
    player_name,
    player_card_level,
    COUNT(*) AS visit_count,
    SUM(CAST(total_dollars_bet AS DECIMAL(18,2))) AS lifetime_coin_in,
    SUM(CAST(dollar_theory_lost AS DECIMAL(18,2))) AS lifetime_theo,
    SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) AS lifetime_actual_loss,
    AVG(CAST(total_dollars_bet AS DECIMAL(18,2))) AS avg_bet_per_session,
    SUM(CAST(total_minutes_played AS INT)) AS total_minutes
FROM slot_play
GROUP BY player_name, player_card_level
HAVING COUNT(*) >= 3  -- at least 3 visits
ORDER BY lifetime_theo DESC;


-- Player trip frequency analysis
-- How often are players coming back?
WITH player_visits AS (
    SELECT 
        player_name,
        player_card_level,
        CAST(LEFT(play_start_date, CHARINDEX(' ', play_start_date + ' ') - 1) AS DATE) AS visit_date
    FROM slot_play
    WHERE play_start_date IS NOT NULL
),
visit_counts AS (
    SELECT 
        player_name,
        player_card_level,
        COUNT(DISTINCT visit_date) AS distinct_visit_days
    FROM player_visits
    GROUP BY player_name, player_card_level
)
SELECT 
    CASE 
        WHEN distinct_visit_days = 1 THEN '1 visit'
        WHEN distinct_visit_days BETWEEN 2 AND 5 THEN '2-5 visits'
        WHEN distinct_visit_days BETWEEN 6 AND 10 THEN '6-10 visits'
        WHEN distinct_visit_days BETWEEN 11 AND 20 THEN '11-20 visits'
        ELSE '20+ visits'
    END AS visit_frequency_bucket,
    COUNT(*) AS player_count,
    AVG(distinct_visit_days) AS avg_visits_in_bucket
FROM visit_counts
GROUP BY 
    CASE 
        WHEN distinct_visit_days = 1 THEN '1 visit'
        WHEN distinct_visit_days BETWEEN 2 AND 5 THEN '2-5 visits'
        WHEN distinct_visit_days BETWEEN 6 AND 10 THEN '6-10 visits'
        WHEN distinct_visit_days BETWEEN 11 AND 20 THEN '11-20 visits'
        ELSE '20+ visits'
    END
ORDER BY MIN(distinct_visit_days);


-- Game preference by player tier
-- Do higher tier players prefer different machines?
SELECT 
    sp.player_card_level,
    sp.make_name,
    COUNT(*) AS sessions,
    SUM(CAST(sp.total_dollars_bet AS DECIMAL(18,2))) AS total_bet,
    AVG(CAST(sp.player_average_bet AS DECIMAL(12,2))) AS avg_bet_size
FROM slot_play sp
WHERE sp.player_card_level IS NOT NULL 
    AND sp.make_name IS NOT NULL
GROUP BY sp.player_card_level, sp.make_name
HAVING COUNT(*) > 100
ORDER BY sp.player_card_level, total_bet DESC;


-- Session duration analysis
-- Understanding how long players stay on machines
SELECT 
    CASE 
        WHEN total_minutes_played < 5 THEN 'Under 5 min'
        WHEN total_minutes_played BETWEEN 5 AND 15 THEN '5-15 min'
        WHEN total_minutes_played BETWEEN 16 AND 30 THEN '16-30 min'
        WHEN total_minutes_played BETWEEN 31 AND 60 THEN '31-60 min'
        WHEN total_minutes_played BETWEEN 61 AND 120 THEN '1-2 hours'
        ELSE 'Over 2 hours'
    END AS session_length,
    COUNT(*) AS session_count,
    AVG(CAST(total_dollars_bet AS DECIMAL(18,2))) AS avg_bet,
    SUM(CAST(total_dollars_bet AS DECIMAL(18,2))) AS total_coin_in
FROM slot_play
WHERE total_minutes_played IS NOT NULL
GROUP BY 
    CASE 
        WHEN total_minutes_played < 5 THEN 'Under 5 min'
        WHEN total_minutes_played BETWEEN 5 AND 15 THEN '5-15 min'
        WHEN total_minutes_played BETWEEN 16 AND 30 THEN '16-30 min'
        WHEN total_minutes_played BETWEEN 31 AND 60 THEN '31-60 min'
        WHEN total_minutes_played BETWEEN 61 AND 120 THEN '1-2 hours'
        ELSE 'Over 2 hours'
    END
ORDER BY MIN(ISNULL(total_minutes_played, 0));


-- Player demographic breakdown (age groups)
SELECT 
    CASE 
        WHEN TRY_CAST(player_years_old AS INT) BETWEEN 21 AND 30 THEN '21-30'
        WHEN TRY_CAST(player_years_old AS INT) BETWEEN 31 AND 40 THEN '31-40'
        WHEN TRY_CAST(player_years_old AS INT) BETWEEN 41 AND 50 THEN '41-50'
        WHEN TRY_CAST(player_years_old AS INT) BETWEEN 51 AND 60 THEN '51-60'
        WHEN TRY_CAST(player_years_old AS INT) BETWEEN 61 AND 70 THEN '61-70'
        WHEN TRY_CAST(player_years_old AS INT) > 70 THEN '70+'
        ELSE 'Unknown'
    END AS age_group,
    player_gender,
    COUNT(DISTINCT player_name) AS unique_players,
    SUM(CAST(total_dollars_bet AS DECIMAL(18,2))) AS total_wagered,
    AVG(CAST(total_dollars_bet AS DECIMAL(18,2))) AS avg_session_bet
FROM slot_play
GROUP BY 
    CASE 
        WHEN TRY_CAST(player_years_old AS INT) BETWEEN 21 AND 30 THEN '21-30'
        WHEN TRY_CAST(player_years_old AS INT) BETWEEN 31 AND 40 THEN '31-40'
        WHEN TRY_CAST(player_years_old AS INT) BETWEEN 41 AND 50 THEN '41-50'
        WHEN TRY_CAST(player_years_old AS INT) BETWEEN 51 AND 60 THEN '51-60'
        WHEN TRY_CAST(player_years_old AS INT) BETWEEN 61 AND 70 THEN '61-70'
        WHEN TRY_CAST(player_years_old AS INT) > 70 THEN '70+'
        ELSE 'Unknown'
    END,
    player_gender
ORDER BY age_group, player_gender;
