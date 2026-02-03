/*
    Food & Beverage / Ancillary Revenue
    ------------------------------------
    Analyzing bar/restaurant performance and its relationship
    to gaming activity. F&B is often a loss leader but 
    understanding patterns helps optimize operations.
*/

USE CasinoAnalytics;
GO

-- Top selling items
SELECT TOP 25
    item_ordered,
    item_category,
    SUM(number_ordered) AS total_quantity,
    SUM(CAST(order_total_dollars AS DECIMAL(12,2))) AS total_revenue,
    COUNT(DISTINCT player_name) AS unique_customers
FROM bar_orders
GROUP BY item_ordered, item_category
ORDER BY total_revenue DESC;


-- Revenue by category
SELECT 
    item_category,
    COUNT(*) AS order_count,
    SUM(number_ordered) AS items_sold,
    SUM(CAST(order_total_dollars AS DECIMAL(12,2))) AS total_revenue,
    AVG(CAST(order_total_dollars AS DECIMAL(12,2))) AS avg_ticket
FROM bar_orders
GROUP BY item_category
ORDER BY total_revenue DESC;


-- F&B spending by player tier
-- Higher tier players should be getting more comped items
SELECT 
    player_card_level,
    COUNT(DISTINCT player_name) AS unique_customers,
    COUNT(*) AS total_orders,
    SUM(CAST(order_total_dollars AS DECIMAL(12,2))) AS total_spend,
    AVG(CAST(order_total_dollars AS DECIMAL(12,2))) AS avg_order_value,
    SUM(CAST(order_total_dollars AS DECIMAL(12,2))) / 
        NULLIF(COUNT(DISTINCT player_name), 0) AS spend_per_customer
FROM bar_orders
WHERE player_card_level IS NOT NULL
GROUP BY player_card_level
ORDER BY total_spend DESC;


-- Hourly F&B demand
SELECT 
    DATEPART(HOUR, TRY_CAST(bar_order_date_exact AS DATETIME)) AS order_hour,
    COUNT(*) AS order_count,
    SUM(CAST(order_total_dollars AS DECIMAL(12,2))) AS revenue
FROM bar_orders
WHERE TRY_CAST(bar_order_date_exact AS DATETIME) IS NOT NULL
GROUP BY DATEPART(HOUR, TRY_CAST(bar_order_date_exact AS DATETIME))
ORDER BY order_hour;


-- F&B customers who also gamble
-- Correlation between F&B spend and gaming value
WITH fb_spend AS (
    SELECT 
        player_name,
        SUM(CAST(order_total_dollars AS DECIMAL(12,2))) AS total_fb_spend
    FROM bar_orders
    GROUP BY player_name
),
gaming_value AS (
    SELECT 
        player_name,
        SUM(CAST(dollar_theory_lost AS DECIMAL(18,2))) AS total_theo
    FROM slot_play
    GROUP BY player_name
)
SELECT TOP 100
    gv.player_name,
    gv.total_theo AS gaming_theo,
    ISNULL(fb.total_fb_spend, 0) AS fb_spend,
    CASE 
        WHEN gv.total_theo > 0 
        THEN (ISNULL(fb.total_fb_spend, 0) / gv.total_theo) * 100 
        ELSE 0 
    END AS fb_as_pct_of_theo
FROM gaming_value gv
LEFT JOIN fb_spend fb ON gv.player_name = fb.player_name
WHERE gv.total_theo > 50
ORDER BY gv.total_theo DESC;


-- Day of week F&B patterns
SELECT 
    DATENAME(WEEKDAY, TRY_CAST(bar_order_date_exact AS DATETIME)) AS day_name,
    DATEPART(WEEKDAY, TRY_CAST(bar_order_date_exact AS DATETIME)) AS day_num,
    COUNT(*) AS orders,
    SUM(CAST(order_total_dollars AS DECIMAL(12,2))) AS revenue
FROM bar_orders
WHERE TRY_CAST(bar_order_date_exact AS DATETIME) IS NOT NULL
GROUP BY 
    DATENAME(WEEKDAY, TRY_CAST(bar_order_date_exact AS DATETIME)),
    DATEPART(WEEKDAY, TRY_CAST(bar_order_date_exact AS DATETIME))
ORDER BY day_num;
