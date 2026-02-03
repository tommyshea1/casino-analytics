/*
    Promotions & Marketing Analysis
    -------------------------------
    Measuring promotional effectiveness, reinvestment rates,
    and player response to marketing offers.
*/

USE CasinoAnalytics;
GO

-- Promotion distribution by type
SELECT 
    promotion_name,
    COUNT(*) AS times_issued,
    COUNT(DISTINCT player_name) AS unique_recipients,
    SUM(CAST(promotion_value AS DECIMAL(12,2))) AS total_face_value,
    SUM(CAST(promotion_cost AS DECIMAL(12,2))) AS total_cost,
    AVG(CAST(promotion_value AS DECIMAL(12,2))) AS avg_promo_value
FROM promotions
GROUP BY promotion_name
ORDER BY total_face_value DESC;


-- Promotion distribution by player tier
-- Are we targeting the right players?
SELECT 
    player_card_level,
    COUNT(*) AS promos_issued,
    COUNT(DISTINCT player_name) AS players_receiving,
    SUM(CAST(promotion_value AS DECIMAL(12,2))) AS total_promo_value,
    AVG(CAST(promotion_value AS DECIMAL(12,2))) AS avg_promo_per_issue,
    SUM(CAST(promotion_value AS DECIMAL(12,2))) / 
        NULLIF(COUNT(DISTINCT player_name), 0) AS avg_promo_per_player
FROM promotions
GROUP BY player_card_level
ORDER BY total_promo_value DESC;


-- Monthly promotional spend trend
SELECT 
    YEAR(TRY_CAST(promotion_issued_date AS DATETIME)) AS promo_year,
    MONTH(TRY_CAST(promotion_issued_date AS DATETIME)) AS promo_month,
    COUNT(*) AS promos_issued,
    SUM(CAST(promotion_value AS DECIMAL(12,2))) AS total_value,
    COUNT(DISTINCT player_name) AS unique_players
FROM promotions
WHERE TRY_CAST(promotion_issued_date AS DATETIME) IS NOT NULL
GROUP BY 
    YEAR(TRY_CAST(promotion_issued_date AS DATETIME)),
    MONTH(TRY_CAST(promotion_issued_date AS DATETIME))
ORDER BY promo_year, promo_month;


-- Reinvestment analysis: promo value vs player theo
-- Are we reinvesting appropriately based on player value?
WITH player_promos AS (
    SELECT 
        player_name,
        SUM(CAST(promotion_value AS DECIMAL(12,2))) AS total_promo_received
    FROM promotions
    GROUP BY player_name
),
player_theo AS (
    SELECT 
        player_name,
        SUM(CAST(dollar_theory_lost AS DECIMAL(18,2))) AS total_theo
    FROM slot_play
    GROUP BY player_name
)
SELECT 
    pt.player_name,
    pt.total_theo,
    ISNULL(pp.total_promo_received, 0) AS promo_received,
    CASE 
        WHEN pt.total_theo > 0 
        THEN (ISNULL(pp.total_promo_received, 0) / pt.total_theo) * 100 
        ELSE 0 
    END AS reinvestment_pct
FROM player_theo pt
LEFT JOIN player_promos pp ON pt.player_name = pp.player_name
WHERE pt.total_theo > 100  -- players with meaningful theo
ORDER BY pt.total_theo DESC;


-- Raffle analysis
SELECT 
    raffle_name,
    drawing_result,
    COUNT(*) AS entries,
    SUM(CAST(cordobas_won AS DECIMAL(12,2))) AS total_prizes,
    AVG(CAST(cordobas_won AS DECIMAL(12,2))) AS avg_prize
FROM raffles
GROUP BY raffle_name, drawing_result
ORDER BY raffle_name, drawing_result;


-- Raffle winners by player tier
SELECT 
    player_card_level,
    COUNT(*) AS wins,
    SUM(CAST(cordobas_won AS DECIMAL(12,2))) AS total_won
FROM raffles
WHERE drawing_result = 'WON'
GROUP BY player_card_level
ORDER BY total_won DESC;
