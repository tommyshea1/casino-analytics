/*
    Month-Aware Views for Interactive Filter
    ----------------------------------------
    These views include year/month so one dashboard filter
    can drive multiple visualizations.
*/

USE CasinoAnalytics;
GO

-- ============================================
-- VIEW: Slot Revenue by Manufacturer BY MONTH
-- Use this for "Revenue by Manufacturer" chart
-- Filter by Month → chart updates
-- ============================================
IF OBJECT_ID('dbo.vw_slot_by_make_by_month', 'V') IS NOT NULL
    DROP VIEW dbo.vw_slot_by_make_by_month;
GO

CREATE VIEW dbo.vw_slot_by_make_by_month AS
SELECT 
    YEAR(TRY_CAST(slot_reading_hour AS DATETIME)) AS revenue_year,
    MONTH(TRY_CAST(slot_reading_hour AS DATETIME)) AS revenue_month,
    DATENAME(MONTH, TRY_CAST(slot_reading_hour AS DATETIME)) AS month_name,
    make_name,
    COUNT(DISTINCT slot_name) AS machine_count,
    SUM(CAST(dollars_player_bet AS DECIMAL(18,2))) AS total_coin_in,
    SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) AS total_win,
    SUM(CAST(theory_player_lost AS DECIMAL(18,2))) AS total_theo
FROM slot_meters
WHERE TRY_CAST(slot_reading_hour AS DATETIME) IS NOT NULL
GROUP BY 
    YEAR(TRY_CAST(slot_reading_hour AS DATETIME)),
    MONTH(TRY_CAST(slot_reading_hour AS DATETIME)),
    DATENAME(MONTH, TRY_CAST(slot_reading_hour AS DATETIME)),
    make_name;
GO

PRINT 'View vw_slot_by_make_by_month created.';
GO

-- ============================================
-- VIEW: Hourly Activity BY MONTH
-- Use for "Peak Hours" chart
-- Filter by Month → see that month's hourly pattern
-- ============================================
IF OBJECT_ID('dbo.vw_hourly_by_month', 'V') IS NOT NULL
    DROP VIEW dbo.vw_hourly_by_month;
GO

CREATE VIEW dbo.vw_hourly_by_month AS
SELECT 
    YEAR(TRY_CAST(slot_reading_hour AS DATETIME)) AS revenue_year,
    MONTH(TRY_CAST(slot_reading_hour AS DATETIME)) AS revenue_month,
    DATENAME(MONTH, TRY_CAST(slot_reading_hour AS DATETIME)) AS month_name,
    DATEPART(HOUR, CAST(slot_reading_hour AS DATETIME)) AS hour_of_day,
    SUM(CAST(games_played_this_hour AS BIGINT)) AS total_games,
    SUM(CAST(dollars_player_bet AS DECIMAL(18,2))) AS total_coin_in,
    SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) AS total_win
FROM slot_meters
WHERE TRY_CAST(slot_reading_hour AS DATETIME) IS NOT NULL
GROUP BY 
    YEAR(TRY_CAST(slot_reading_hour AS DATETIME)),
    MONTH(TRY_CAST(slot_reading_hour AS DATETIME)),
    DATENAME(MONTH, TRY_CAST(slot_reading_hour AS DATETIME)),
    DATEPART(HOUR, CAST(slot_reading_hour AS DATETIME));
GO

PRINT 'View vw_hourly_by_month created.';
GO

-- ============================================
-- VIEW: Day of Week BY MONTH
-- Filter by Month → see that month's day pattern
-- ============================================
IF OBJECT_ID('dbo.vw_daily_by_month', 'V') IS NOT NULL
    DROP VIEW dbo.vw_daily_by_month;
GO

CREATE VIEW dbo.vw_daily_by_month AS
SELECT 
    YEAR(TRY_CAST(slot_reading_hour AS DATETIME)) AS revenue_year,
    MONTH(TRY_CAST(slot_reading_hour AS DATETIME)) AS revenue_month,
    DATENAME(MONTH, TRY_CAST(slot_reading_hour AS DATETIME)) AS month_name,
    DATENAME(WEEKDAY, CAST(slot_reading_hour AS DATETIME)) AS day_name,
    DATEPART(WEEKDAY, CAST(slot_reading_hour AS DATETIME)) AS day_num,
    SUM(CAST(dollars_player_bet AS DECIMAL(18,2))) AS total_coin_in,
    SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) AS total_win
FROM slot_meters
WHERE TRY_CAST(slot_reading_hour AS DATETIME) IS NOT NULL
GROUP BY 
    YEAR(TRY_CAST(slot_reading_hour AS DATETIME)),
    MONTH(TRY_CAST(slot_reading_hour AS DATETIME)),
    DATENAME(MONTH, TRY_CAST(slot_reading_hour AS DATETIME)),
    DATENAME(WEEKDAY, CAST(slot_reading_hour AS DATETIME)),
    DATEPART(WEEKDAY, CAST(slot_reading_hour AS DATETIME));
GO

PRINT 'View vw_daily_by_month created.';
GO

-- ============================================
-- VIEW: Player Tier BY MONTH
-- Filter by Month → see that month's tier mix
-- ============================================
IF OBJECT_ID('dbo.vw_player_tier_by_month', 'V') IS NOT NULL
    DROP VIEW dbo.vw_player_tier_by_month;
GO

CREATE VIEW dbo.vw_player_tier_by_month AS
SELECT 
    YEAR(TRY_CAST(slot_play_hour AS DATETIME)) AS revenue_year,
    MONTH(TRY_CAST(slot_play_hour AS DATETIME)) AS revenue_month,
    DATENAME(MONTH, TRY_CAST(slot_play_hour AS DATETIME)) AS month_name,
    player_card_level,
    COUNT(DISTINCT player_name) AS unique_players,
    COUNT(*) AS total_sessions,
    SUM(CAST(total_dollars_bet AS DECIMAL(18,2))) AS total_wagered,
    SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) AS total_player_loss,
    SUM(CAST(dollar_theory_lost AS DECIMAL(18,2))) AS total_theo
FROM slot_play
WHERE player_card_level IS NOT NULL
  AND TRY_CAST(slot_play_hour AS DATETIME) IS NOT NULL
GROUP BY 
    YEAR(TRY_CAST(slot_play_hour AS DATETIME)),
    MONTH(TRY_CAST(slot_play_hour AS DATETIME)),
    DATENAME(MONTH, TRY_CAST(slot_play_hour AS DATETIME)),
    player_card_level;
GO

PRINT 'View vw_player_tier_by_month created.';
GO

PRINT '==========================================';
PRINT 'Month-filter views created.';
PRINT 'Use Month filter on dashboard → all these vizs update.';
PRINT '==========================================';
GO
