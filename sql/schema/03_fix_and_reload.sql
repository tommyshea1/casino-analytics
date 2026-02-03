-- =============================================
-- Fix Tables for Data Type Issues
-- Change player_years_old to VARCHAR to handle 'Unknown' values
-- =============================================

USE CasinoAnalytics;
GO

-- Truncate and alter tables to fix data type issues

-- Fix bar_orders
IF OBJECT_ID('dbo.bar_orders', 'U') IS NOT NULL
    DROP TABLE dbo.bar_orders;
GO

CREATE TABLE dbo.bar_orders (
    id INT IDENTITY(1,1) PRIMARY KEY,
    player_name VARCHAR(50),
    player_gender VARCHAR(10),
    player_years_old VARCHAR(20),  -- Changed to VARCHAR
    player_card_level VARCHAR(50),
    item_ordered VARCHAR(100),
    number_ordered INT,
    item_category VARCHAR(50),
    bar_order_hour VARCHAR(50),    -- Changed to VARCHAR for flexible parsing
    bar_order_date_exact VARCHAR(50),  -- Changed to VARCHAR
    order_total_dollars DECIMAL(10,2)
);
GO
PRINT 'Table bar_orders recreated with VARCHAR columns.';
GO

-- Fix promotions
IF OBJECT_ID('dbo.promotions', 'U') IS NOT NULL
    DROP TABLE dbo.promotions;
GO

CREATE TABLE dbo.promotions (
    id INT IDENTITY(1,1) PRIMARY KEY,
    player_name VARCHAR(50),
    player_gender VARCHAR(10),
    player_years_old VARCHAR(20),  -- Changed to VARCHAR
    currency VARCHAR(10),
    player_card_level VARCHAR(50),
    promotion_name VARCHAR(100),
    promotion_value DECIMAL(10,2),
    promotion_cost DECIMAL(10,2),
    promotion_issued_date VARCHAR(50),  -- Changed to VARCHAR
    promotion_issued_hour VARCHAR(50)   -- Changed to VARCHAR
);
GO
PRINT 'Table promotions recreated with VARCHAR columns.';
GO

-- Fix raffles
IF OBJECT_ID('dbo.raffles', 'U') IS NOT NULL
    DROP TABLE dbo.raffles;
GO

CREATE TABLE dbo.raffles (
    id INT IDENTITY(1,1) PRIMARY KEY,
    player_name VARCHAR(50),
    player_gender VARCHAR(10),
    player_years_old VARCHAR(20),  -- Changed to VARCHAR
    player_card_level VARCHAR(50),
    raffle_name VARCHAR(100),
    cordobas_won DECIMAL(12,2),
    drawing_result VARCHAR(20),
    drawing_date VARCHAR(50),      -- Changed to VARCHAR
    drawing_hour VARCHAR(50)       -- Changed to VARCHAR
);
GO
PRINT 'Table raffles recreated with VARCHAR columns.';
GO

-- Fix table_play
IF OBJECT_ID('dbo.table_play', 'U') IS NOT NULL
    DROP TABLE dbo.table_play;
GO

CREATE TABLE dbo.table_play (
    id INT IDENTITY(1,1) PRIMARY KEY,
    table_name VARCHAR(50),
    player_name VARCHAR(50),
    player_gender VARCHAR(10),
    player_years_old VARCHAR(20),  -- Already VARCHAR, keep it
    play_start_date VARCHAR(50),   -- Changed to VARCHAR
    play_end_date VARCHAR(50),     -- Changed to VARCHAR
    total_minutes_played INT,
    play_start_hour VARCHAR(50),   -- Changed to VARCHAR
    play_end_hour VARCHAR(50),     -- Changed to VARCHAR
    table_currency VARCHAR(10),
    player_card_level VARCHAR(50),
    cash_buy_in DECIMAL(12,2),
    chips_buy_in DECIMAL(12,2),
    cash_out DECIMAL(12,2),
    player_lost DECIMAL(12,2),
    average_bet DECIMAL(10,2),
    bets_per_hour INT,
    hold_percentage DECIMAL(8,5)
);
GO
PRINT 'Table table_play recreated with VARCHAR columns.';
GO

-- Fix slot_play
IF OBJECT_ID('dbo.slot_play', 'U') IS NOT NULL
    DROP TABLE dbo.slot_play;
GO

CREATE TABLE dbo.slot_play (
    id INT IDENTITY(1,1) PRIMARY KEY,
    slot_name VARCHAR(50),
    player_name VARCHAR(50),
    player_gender VARCHAR(10),
    player_years_old VARCHAR(20),  -- Changed to VARCHAR
    model_name VARCHAR(100),
    make_name VARCHAR(50),
    slot_currency VARCHAR(10),
    play_start_date VARCHAR(50),   -- Changed to VARCHAR
    play_end_date VARCHAR(50),     -- Changed to VARCHAR
    total_minutes_played INT,
    slot_play_hour VARCHAR(50),    -- Changed to VARCHAR
    games_played INT,
    total_dollars_bet DECIMAL(12,4),
    player_average_bet DECIMAL(15,10),
    dollars_player_lost DECIMAL(12,4),
    dollar_theory_lost DECIMAL(12,6),
    currency_bills_accepted DECIMAL(12,2),
    currency_electronic_in DECIMAL(12,2),
    currency_electronic_out DECIMAL(12,2),
    currency_ticket_in DECIMAL(12,2),
    currency_ticket_out DECIMAL(12,2),
    slot_ideal_payback_pct DECIMAL(8,4),
    player_card_level VARCHAR(50)
);
GO
PRINT 'Table slot_play recreated with VARCHAR columns.';
GO

PRINT '========================================';
PRINT 'All tables recreated successfully!';
PRINT 'Ready for data reload.';
PRINT '========================================';
GO
