# Casino Operations Analytics Dashboard

A comprehensive analytics project demonstrating SQL, Tableau, and Python skills using real casino operations data. Built as a portfolio project for casino analyst positions.

## Project Overview

This project analyzes casino operations data to provide actionable insights across:
- **Slot Machine Performance** - Machine-level metrics, hold percentages, revenue analysis
- **Player Analytics** - Segmentation, lifetime value, behavior patterns
- **Table Games** - Session analysis, hold rates, player ratings
- **Promotions & Marketing** - Campaign ROI, redemption analysis
- **Ancillary Revenue** - Bar/restaurant performance tied to gaming activity

## Tech Stack

| Tool | Purpose |
|------|---------|
| SQL Server | Data warehouse, complex queries |
| Tableau | Interactive dashboards |
| Python | Data processing, statistical analysis |

## Project Structure

```
casino-analytics/
├── sql/
│   ├── schema/          # Table definitions, indexes
│   ├── queries/         # Analytical queries
│   └── views/           # Reusable views for reporting
├── python/
│   ├── data_loader.py   # CSV to SQL import scripts
│   └── analysis/        # Statistical analysis notebooks
├── tableau/
│   └── casino_dashboard.twbx
├── docs/
│   └── data_dictionary.md
├── data-raw/            # Raw CSV data (gitignored)
└── README.md
```

## Data Sources

Data sourced from [phpn00b/big-casino-data](https://github.com/phpn00b/big-casino-data) - a comprehensive casino dataset including:

| Dataset | Records | Description |
|---------|---------|-------------|
| slot_play | ~580,000+ | Player slot machine sessions |
| slot_meters | ~1.2M+ | Hourly machine performance metrics |
| table_play | ~50,000+ | Player table game sessions |
| bar_orders | ~240,000+ | F&B transactions linked to players |
| promotions | ~60,000+ | Promotional offers issued |
| raffles | ~500+ | Raffle drawings and winners |

## Key Metrics & KPIs

### Slot Operations
- **Coin-In** - Total amount wagered
- **Win/Hold** - Casino revenue (Coin-In × Hold %)
- **Theoretical Win** - Expected win based on game math
- **Actual vs. Theo** - Variance analysis

### Player Analytics
- **ADT (Average Daily Theo)** - Player's expected daily value
- **Trip Frequency** - Visits per time period
- **Game Preference** - Slots vs. tables, denomination preference
- **Tier Distribution** - Player card level breakdown

### Marketing
- **Promo Cost Ratio** - Promo spend / Theoretical win
- **Reinvestment Rate** - % of theo returned to player
- **Campaign ROI** - Incremental revenue vs. promo cost

## Setup Instructions

### Prerequisites
- SQL Server 2019+ (or SQL Server Express)
- Tableau Desktop
- Python 3.9+
- Git

### Installation

1. Clone this repository
2. Download the raw data (see data-raw instructions)
3. Run the SQL schema scripts
4. Load data using Python scripts
5. Open Tableau and connect to your SQL Server (database: CasinoAnalytics)

Detailed setup instructions in `/docs/setup_guide.md`

## Sample Queries

```sql
-- Top 10 slot machines by hold percentage
SELECT TOP 10
    Slot_Name,
    Model_Name,
    Make_Name,
    SUM(Dollars_Player_Bet) AS Total_Coin_In,
    SUM(Dollars_Player_Lost) AS Total_Win,
    SUM(Dollars_Player_Lost) / NULLIF(SUM(Dollars_Player_Bet), 0) * 100 AS Actual_Hold_Pct
FROM slot_meters
GROUP BY Slot_Name, Model_Name, Make_Name
HAVING SUM(Dollars_Player_Bet) > 10000
ORDER BY Actual_Hold_Pct DESC;
```

## Dashboard Preview

*Screenshots coming soon*

## Skills Demonstrated

- [x] Complex SQL queries (CTEs, window functions, aggregations)
- [x] Database design and optimization
- [x] Tableau dashboard development
- [x] Data visualization best practices
- [x] Python data processing
- [x] Gaming industry domain knowledge

## Author

[Your Name]

## License

This project is for educational/portfolio purposes. Data sourced from publicly available datasets.
