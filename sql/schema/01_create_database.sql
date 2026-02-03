-- =============================================
-- Casino Analytics Database Setup
-- Step 1: Create Database
-- =============================================

-- Create the database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'CasinoAnalytics')
BEGIN
    CREATE DATABASE CasinoAnalytics;
    PRINT 'Database CasinoAnalytics created successfully.';
END
ELSE
BEGIN
    PRINT 'Database CasinoAnalytics already exists.';
END
GO

-- Switch to the new database
USE CasinoAnalytics;
GO

PRINT 'Now using CasinoAnalytics database.';
GO
