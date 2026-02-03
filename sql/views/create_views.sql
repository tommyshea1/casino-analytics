/*
    Tableau-Ready Views
    -------------------
    These views pre-aggregate the data so Tableau can 
    connect to them like regular tables. Much cleaner workflow.
*/

USE CasinoAnalytics;
GO

-- ============================================
-- VIEW 1: Slot Performance by Manufacturer
-- ============================================
IF OBJECT_ID('dbo.vw_slot_by_manufacturer', 'V') IS NOT NULL
    DROP VIEW dbo.vw_slot_by_manufacturer;
GO

CREATE VIEW dbo.vw_slot_by_manufacturer AS
SELECT 
    make_name,
    COUNT(DISTINCT slot_name) AS machine_count,
    SUM(CAST(dollars_player_bet AS DECIMAL(18,2))) AS total_coin_in,
    SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) AS total_win,
    SUM(CAST(theory_player_lost AS DECIMAL(18,2))) AS total_theo,
    AVG(CAST(slot_ideal_payback_pct AS DECIMAL(8,4))) * 100 AS avg_hold_pct
FROM slot_meters
WHERE dollars_player_bet > 0
GROUP BY make_name;
GO

PRINT 'View vw_slot_by_manufacturer created.';
GO

-- ============================================
-- VIEW 2: Individual Machine Performance
-- ============================================
IF OBJECT_ID('dbo.vw_machine_performance', 'V') IS NOT NULL
    DROP VIEW dbo.vw_machine_performance;
GO

CREATE VIEW dbo.vw_machine_performance AS
SELECT 
    slot_name,
    model_name,
    make_name,
    SUM(CAST(dollars_player_bet AS DECIMAL(18,2))) AS total_coin_in,
    SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) AS actual_win,
    SUM(CAST(theory_player_lost AS DECIMAL(18,2))) AS theo_win,
    SUM(CAST(games_played_this_hour AS INT)) AS total_games,
    COUNT(*) AS hours_active
FROM slot_meters
GROUP BY slot_name, model_name, make_name;
GO

PRINT 'View vw_machine_performance created.';
GO

-- ============================================
-- VIEW 3: Player Value by Tier
-- ============================================
IF OBJECT_ID('dbo.vw_player_by_tier', 'V') IS NOT NULL
    DROP VIEW dbo.vw_player_by_tier;
GO

CREATE VIEW dbo.vw_player_by_tier AS
SELECT 
    player_card_level,
    COUNT(DISTINCT player_name) AS unique_players,
    COUNT(*) AS total_sessions,
    SUM(CAST(total_dollars_bet AS DECIMAL(18,2))) AS total_wagered,
    SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) AS total_player_loss,
    SUM(CAST(dollar_theory_lost AS DECIMAL(18,2))) AS total_theo,
    AVG(CAST(total_dollars_bet AS DECIMAL(18,2))) AS avg_session_bet,
    AVG(CAST(total_minutes_played AS INT)) AS avg_session_minutes
FROM slot_play
WHERE player_card_level IS NOT NULL
GROUP BY player_card_level;
GO

PRINT 'View vw_player_by_tier created.';
GO

-- ============================================
-- VIEW 4: Hourly Activity Pattern
-- ============================================
IF OBJECT_ID('dbo.vw_hourly_activity', 'V') IS NOT NULL
    DROP VIEW dbo.vw_hourly_activity;
GO

CREATE VIEW dbo.vw_hourly_activity AS
SELECT 
    DATEPART(HOUR, CAST(slot_reading_hour AS DATETIME)) AS hour_of_day,
    COUNT(*) AS readings,
    SUM(CAST(games_played_this_hour AS INT)) AS total_games,
    SUM(CAST(dollars_player_bet AS DECIMAL(18,2))) AS total_coin_in,
    SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) AS total_win
FROM slot_meters
WHERE TRY_CAST(slot_reading_hour AS DATETIME) IS NOT NULL
GROUP BY DATEPART(HOUR, CAST(slot_reading_hour AS DATETIME));
GO

PRINT 'View vw_hourly_activity created.';
GO

-- ============================================
-- VIEW 5: Day of Week Pattern
-- ============================================
IF OBJECT_ID('dbo.vw_daily_pattern', 'V') IS NOT NULL
    DROP VIEW dbo.vw_daily_pattern;
GO

CREATE VIEW dbo.vw_daily_pattern AS
SELECT 
    DATENAME(WEEKDAY, CAST(slot_reading_hour AS DATETIME)) AS day_name,
    DATEPART(WEEKDAY, CAST(slot_reading_hour AS DATETIME)) AS day_num,
    SUM(CAST(dollars_player_bet AS DECIMAL(18,2))) AS total_coin_in,
    SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) AS total_win,
    COUNT(DISTINCT slot_name) AS active_machines
FROM slot_meters
WHERE TRY_CAST(slot_reading_hour AS DATETIME) IS NOT NULL
GROUP BY 
    DATENAME(WEEKDAY, CAST(slot_reading_hour AS DATETIME)),
    DATEPART(WEEKDAY, CAST(slot_reading_hour AS DATETIME));
GO

PRINT 'View vw_daily_pattern created.';
GO

-- ============================================
-- VIEW 6: Monthly Revenue Trend
-- ============================================
IF OBJECT_ID('dbo.vw_monthly_trend', 'V') IS NOT NULL
    DROP VIEW dbo.vw_monthly_trend;
GO

CREATE VIEW dbo.vw_monthly_trend AS
SELECT 
    YEAR(TRY_CAST(slot_reading_hour AS DATETIME)) AS revenue_year,
    MONTH(TRY_CAST(slot_reading_hour AS DATETIME)) AS revenue_month,
    SUM(CAST(dollars_player_bet AS DECIMAL(18,2))) AS coin_in,
    SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) AS actual_win,
    SUM(CAST(theory_player_lost AS DECIMAL(18,2))) AS theo_win
FROM slot_meters
WHERE TRY_CAST(slot_reading_hour AS DATETIME) IS NOT NULL
GROUP BY 
    YEAR(TRY_CAST(slot_reading_hour AS DATETIME)),
    MONTH(TRY_CAST(slot_reading_hour AS DATETIME));
GO

PRINT 'View vw_monthly_trend created.';
GO

-- ============================================
-- VIEW 7: Table Games Summary
-- ============================================
IF OBJECT_ID('dbo.vw_table_games', 'V') IS NOT NULL
    DROP VIEW dbo.vw_table_games;
GO

CREATE VIEW dbo.vw_table_games AS
SELECT 
    CASE 
        WHEN table_name LIKE 'BJ%' THEN 'Blackjack'
        WHEN table_name LIKE 'AR%' THEN 'Roulette'
        WHEN table_name LIKE 'PK%' THEN 'Poker'
        ELSE 'Other'
    END AS game_type,
    COUNT(*) AS total_sessions,
    COUNT(DISTINCT player_name) AS unique_players,
    SUM(CAST(cash_buy_in AS DECIMAL(18,2))) AS total_drop,
    SUM(CAST(player_lost AS DECIMAL(18,2))) AS total_win,
    AVG(CAST(total_minutes_played AS INT)) AS avg_session_length
FROM table_play
GROUP BY 
    CASE 
        WHEN table_name LIKE 'BJ%' THEN 'Blackjack'
        WHEN table_name LIKE 'AR%' THEN 'Roulette'
        WHEN table_name LIKE 'PK%' THEN 'Poker'
        ELSE 'Other'
    END;
GO

PRINT 'View vw_table_games created.';
GO

-- ============================================
-- VIEW 8: F&B by Category
-- ============================================
IF OBJECT_ID('dbo.vw_fb_revenue', 'V') IS NOT NULL
    DROP VIEW dbo.vw_fb_revenue;
GO

CREATE VIEW dbo.vw_fb_revenue AS
SELECT 
    item_category,
    COUNT(*) AS order_count,
    SUM(number_ordered) AS items_sold,
    SUM(CAST(order_total_dollars AS DECIMAL(12,2))) AS total_revenue,
    COUNT(DISTINCT player_name) AS unique_customers
FROM bar_orders
GROUP BY item_category;
GO

PRINT 'View vw_fb_revenue created.';
GO

-- ============================================
-- VIEW 9: Player Demographics
-- ============================================
IF OBJECT_ID('dbo.vw_player_demographics', 'V') IS NOT NULL
    DROP VIEW dbo.vw_player_demographics;
GO

CREATE VIEW dbo.vw_player_demographics AS
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
    SUM(CAST(dollar_theory_lost AS DECIMAL(18,2))) AS total_theo
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
    player_gender;
GO

PRINT 'View vw_player_demographics created.';
GO

-- ============================================
-- VIEW 10: Promotions Summary
-- ============================================
IF OBJECT_ID('dbo.vw_promotions', 'V') IS NOT NULL
    DROP VIEW dbo.vw_promotions;
GO

CREATE VIEW dbo.vw_promotions AS
SELECT 
    promotion_name,
    player_card_level,
    COUNT(*) AS times_issued,
    COUNT(DISTINCT player_name) AS unique_recipients,
    SUM(CAST(promotion_value AS DECIMAL(12,2))) AS total_value,
    SUM(CAST(promotion_cost AS DECIMAL(12,2))) AS total_cost
FROM promotions
GROUP BY promotion_name, player_card_level;
GO

PRINT 'View vw_promotions created.';
GO

PRINT '==========================================';
PRINT 'All 10 views created successfully!';
PRINT '==========================================';
GO
