/*
    KPI Summary View
    ----------------
    Single-row view with all key metrics for dashboard KPI cards
*/

USE CasinoAnalytics;
GO

IF OBJECT_ID('dbo.vw_kpi_summary', 'V') IS NOT NULL
    DROP VIEW dbo.vw_kpi_summary;
GO

CREATE VIEW dbo.vw_kpi_summary AS
SELECT 
    -- Revenue Metrics
    (SELECT SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) FROM slot_meters) AS total_slot_revenue,
    (SELECT SUM(CAST(player_lost AS DECIMAL(18,2))) FROM table_play) AS total_table_revenue,
    (SELECT SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) FROM slot_meters) + 
        ISNULL((SELECT SUM(CAST(player_lost AS DECIMAL(18,2))) FROM table_play), 0) AS total_gaming_revenue,
    
    -- Volume Metrics
    (SELECT SUM(CAST(dollars_player_bet AS DECIMAL(18,2))) FROM slot_meters) AS total_coin_in,
    (SELECT SUM(CAST(games_played_this_hour AS BIGINT)) FROM slot_meters) AS total_games_played,
    
    -- Player Counts
    (SELECT COUNT(DISTINCT player_name) FROM slot_play) AS unique_slot_players,
    (SELECT COUNT(DISTINCT player_name) FROM table_play) AS unique_table_players,
    
    -- Performance Metrics
    (SELECT SUM(CAST(dollars_player_lost AS DECIMAL(18,2))) / 
            NULLIF(SUM(CAST(dollars_player_bet AS DECIMAL(18,2))), 0) * 100 
     FROM slot_meters) AS slot_hold_pct,
    
    -- Session Metrics
    (SELECT AVG(CAST(total_dollars_bet AS DECIMAL(18,2))) FROM slot_play WHERE total_dollars_bet > 0) AS avg_bet_per_session,
    (SELECT AVG(CAST(total_minutes_played AS DECIMAL(10,2))) FROM slot_play WHERE total_minutes_played > 0) AS avg_session_minutes,
    
    -- Marketing
    (SELECT SUM(CAST(promotion_value AS DECIMAL(12,2))) FROM promotions) AS total_promo_issued,
    (SELECT COUNT(*) FROM promotions) AS promo_count,
    
    -- F&B
    (SELECT SUM(CAST(order_total_dollars AS DECIMAL(12,2))) FROM bar_orders) AS total_fb_revenue,
    (SELECT COUNT(*) FROM bar_orders) AS fb_orders;
GO

PRINT 'View vw_kpi_summary created successfully.';
GO

-- Verify it works
SELECT * FROM vw_kpi_summary;
GO
