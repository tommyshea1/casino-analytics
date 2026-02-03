-- =============================================
-- Casino Analytics Database Setup
-- Step 2: Create Tables
-- =============================================

USE CasinoAnalytics;
GO

-- =============================================
-- Table: slot_play
-- Description: Player-level slot machine sessions
-- =============================================
IF OBJECT_ID('dbo.slot_play', 'U') IS NOT NULL
    DROP TABLE dbo.slot_play;
GO

CREATE TABLE dbo.slot_play (
    id INT IDENTITY(1,1) PRIMARY KEY,
    slot_name VARCHAR(50),
    player_name VARCHAR(50),
    player_gender VARCHAR(10),
    player_years_old INT,
    model_name VARCHAR(100),
    make_name VARCHAR(50),
    slot_currency VARCHAR(10),
    play_start_date DATETIME,
    play_end_date DATETIME,
    total_minutes_played INT,
    slot_play_hour DATETIME,
    games_played INT,
    total_dollars_bet DECIMAL(12,2),
    player_average_bet DECIMAL(12,4),
    dollars_player_lost DECIMAL(12,2),
    dollar_theory_lost DECIMAL(12,6),
    currency_bills_accepted DECIMAL(12,2),
    currency_electronic_in DECIMAL(12,2),
    currency_electronic_out DECIMAL(12,2),
    currency_ticket_in DECIMAL(12,2),
    currency_ticket_out DECIMAL(12,2),
    slot_ideal_payback_pct DECIMAL(6,4),
    player_card_level VARCHAR(50)
);
GO

PRINT 'Table slot_play created.';
GO

-- =============================================
-- Table: slot_meters
-- Description: Hourly machine-level performance
-- =============================================
IF OBJECT_ID('dbo.slot_meters', 'U') IS NOT NULL
    DROP TABLE dbo.slot_meters;
GO

CREATE TABLE dbo.slot_meters (
    id INT IDENTITY(1,1) PRIMARY KEY,
    slot_name VARCHAR(50),
    model_name VARCHAR(100),
    make_name VARCHAR(50),
    slot_currency VARCHAR(10),
    slot_reading_hour DATETIME,
    games_played_this_hour INT,
    dollars_player_bet DECIMAL(12,2),
    dollars_player_lost DECIMAL(12,2),
    theory_player_lost DECIMAL(12,6),
    slot_ideal_payback_pct DECIMAL(6,4)
);
GO

PRINT 'Table slot_meters created.';
GO

-- =============================================
-- Table: table_play
-- Description: Player-level table game sessions
-- =============================================
IF OBJECT_ID('dbo.table_play', 'U') IS NOT NULL
    DROP TABLE dbo.table_play;
GO

CREATE TABLE dbo.table_play (
    id INT IDENTITY(1,1) PRIMARY KEY,
    table_name VARCHAR(50),
    player_name VARCHAR(50),
    player_gender VARCHAR(10),
    player_years_old VARCHAR(20),  -- Can be "Unknown"
    play_start_date DATETIME,
    play_end_date DATETIME,
    total_minutes_played INT,
    play_start_hour DATETIME,
    play_end_hour DATETIME,
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

PRINT 'Table table_play created.';
GO

-- =============================================
-- Table: bar_orders
-- Description: F&B transactions linked to players
-- =============================================
IF OBJECT_ID('dbo.bar_orders', 'U') IS NOT NULL
    DROP TABLE dbo.bar_orders;
GO

CREATE TABLE dbo.bar_orders (
    id INT IDENTITY(1,1) PRIMARY KEY,
    player_name VARCHAR(50),
    player_gender VARCHAR(10),
    player_years_old INT,
    player_card_level VARCHAR(50),
    item_ordered VARCHAR(100),
    number_ordered INT,
    item_category VARCHAR(50),
    bar_order_hour DATETIME,
    bar_order_date_exact DATETIME,
    order_total_dollars DECIMAL(10,2)
);
GO

PRINT 'Table bar_orders created.';
GO

-- =============================================
-- Table: promotions
-- Description: Promotional offers issued to players
-- =============================================
IF OBJECT_ID('dbo.promotions', 'U') IS NOT NULL
    DROP TABLE dbo.promotions;
GO

CREATE TABLE dbo.promotions (
    id INT IDENTITY(1,1) PRIMARY KEY,
    player_name VARCHAR(50),
    player_gender VARCHAR(10),
    player_years_old INT,
    currency VARCHAR(10),
    player_card_level VARCHAR(50),
    promotion_name VARCHAR(100),
    promotion_value DECIMAL(10,2),
    promotion_cost DECIMAL(10,2),
    promotion_issued_date DATETIME,
    promotion_issued_hour DATETIME
);
GO

PRINT 'Table promotions created.';
GO

-- =============================================
-- Table: raffles
-- Description: Raffle/drawing results
-- =============================================
IF OBJECT_ID('dbo.raffles', 'U') IS NOT NULL
    DROP TABLE dbo.raffles;
GO

CREATE TABLE dbo.raffles (
    id INT IDENTITY(1,1) PRIMARY KEY,
    player_name VARCHAR(50),
    player_gender VARCHAR(10),
    player_years_old INT,
    player_card_level VARCHAR(50),
    raffle_name VARCHAR(100),
    cordobas_won DECIMAL(12,2),
    drawing_result VARCHAR(20),
    drawing_date DATETIME,
    drawing_hour DATETIME
);
GO

PRINT 'Table raffles created.';
GO

-- =============================================
-- Summary
-- =============================================
PRINT '========================================';
PRINT 'All tables created successfully!';
PRINT '========================================';
PRINT 'Tables: slot_play, slot_meters, table_play,';
PRINT '        bar_orders, promotions, raffles';
GO
