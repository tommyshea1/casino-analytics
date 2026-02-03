# Data Dictionary

This document describes the schema and fields for each dataset in the casino analytics project.

---

## 1. Slot Play (`slot_play`)

Player-level slot machine session data.

| Column | Data Type | Description |
|--------|-----------|-------------|
| Slot_Name | VARCHAR(50) | Machine identifier (e.g., "Slot 239") |
| Player_Name | VARCHAR(50) | Anonymized player ID (e.g., "Player 14583") |
| Player_Gender | VARCHAR(10) | Male/Female |
| Player_Years_Old | INT | Player age |
| Model_Name | VARCHAR(100) | Slot machine model (e.g., "GK10 Slant") |
| Make_Name | VARCHAR(50) | Manufacturer (IGT, Aristocrat, etc.) |
| Slot_Currency | VARCHAR(10) | Currency code (C$, $) |
| Play_Start_Date | DATETIME | Session start timestamp |
| Play_End_Date | DATETIME | Session end timestamp |
| Total_Minutes_Played | INT | Session duration in minutes |
| Slot_Play_Hour | DATETIME | Hour bucket for aggregation |
| Games_Played | INT | Number of spins/games in session |
| Total_Dollars_Bet | DECIMAL(12,2) | Total amount wagered (coin-in) |
| Player_Average_Bet | DECIMAL(10,2) | Average bet per spin |
| Dollars_Player_Lost | DECIMAL(12,2) | Actual player loss (negative = player won) |
| Dollar_Theory_Lost | DECIMAL(12,6) | Theoretical loss based on hold % |
| Currency_Bills_Accepted | DECIMAL(12,2) | Cash inserted |
| Currency_Electronic_In | DECIMAL(12,2) | Electronic funds in |
| Currency_Electronic_Out | DECIMAL(12,2) | Electronic funds out |
| Currency_Ticket_In | DECIMAL(12,2) | TITO tickets inserted |
| Currency_Ticket_Out | DECIMAL(12,2) | TITO tickets printed |
| Slot_Ideal_Payback_Pct | DECIMAL(6,4) | Theoretical hold percentage |
| Player_Card_Level | VARCHAR(50) | Loyalty tier (Card Type 1, 101, 102, etc.) |

**Notes:**
- Negative `Dollars_Player_Lost` indicates the player won that session
- `Dollar_Theory_Lost` = `Total_Dollars_Bet` × `Slot_Ideal_Payback_Pct`

---

## 2. Slot Meters (`slot_meters`)

Hourly machine-level performance metrics (aggregate, not player-specific).

| Column | Data Type | Description |
|--------|-----------|-------------|
| Slot_Name | VARCHAR(50) | Machine identifier |
| Model_Name | VARCHAR(100) | Slot machine model |
| Make_Name | VARCHAR(50) | Manufacturer |
| Slot_Currency | VARCHAR(10) | Currency code |
| Slot_Reading_Hour | DATETIME | Hour of the reading |
| Games_Played_This_Hour | INT | Total spins across all players |
| Dollars_Player_Bet | DECIMAL(12,2) | Total coin-in for the hour |
| Dollars_Player_Lost | DECIMAL(12,2) | Actual win for the hour |
| Theory_Player_Lost | DECIMAL(12,6) | Expected win based on math |
| Slot_Ideal_Payback_Pct | DECIMAL(6,4) | Theoretical hold percentage |

---

## 3. Table Play (`table_play`)

Player-level table game session data.

| Column | Data Type | Description |
|--------|-----------|-------------|
| Table_Name | VARCHAR(50) | Table identifier (e.g., "BJ-3" for Blackjack 3) |
| Player_Name | VARCHAR(50) | Anonymized player ID |
| Player_Gender | VARCHAR(10) | Male/Female/Unknown |
| Player_Years_Old | VARCHAR(20) | Player age (may be "Unknown") |
| Play_Start_Date | DATETIME | Session start timestamp |
| Play_End_Date | DATETIME | Session end timestamp |
| Total_Minutes_Played | INT | Session duration |
| Play_Start_Hour | DATETIME | Hour bucket (start) |
| Play_End_Hour | DATETIME | Hour bucket (end) |
| Table_Currency | VARCHAR(10) | Currency code |
| Player_Card_Level | VARCHAR(50) | Loyalty tier |
| Cash_Buy_In | DECIMAL(12,2) | Cash exchanged for chips |
| Chips_Buy_In | DECIMAL(12,2) | Chips brought to table |
| Cash_Out | DECIMAL(12,2) | Chips cashed out |
| Player_Lost | DECIMAL(12,2) | Net player loss |
| Average_Bet | DECIMAL(10,2) | Estimated average bet |
| Bets_Per_Hour | INT | Hands/decisions per hour |
| Hold_Percentage | DECIMAL(6,5) | Theoretical hold for game type |

**Table Name Prefixes:**
- `BJ-` = Blackjack
- `AR-` = American Roulette (likely)
- Other prefixes may indicate other games

---

## 4. Bar Orders (`bar_orders`)

Food & beverage transactions linked to player cards.

| Column | Data Type | Description |
|--------|-----------|-------------|
| Player_Name | VARCHAR(50) | Anonymized player ID |
| Player_Gender | VARCHAR(10) | Male/Female |
| Player_Years_Old | INT | Player age |
| Player_Card_Level | VARCHAR(50) | Loyalty tier |
| Item_Ordered | VARCHAR(100) | Menu item name |
| Number_Ordered | INT | Quantity |
| Item_Category | VARCHAR(50) | Category (Platos Fuertes, Tabaco, etc.) |
| Bar_Order_Hour | DATETIME | Hour bucket |
| Bar_Order_Date_Exact | DATETIME | Exact order timestamp |
| Order_Total_Dollars | DECIMAL(10,2) | Transaction total |

---

## 5. Promotions (`promotions`)

Promotional offers issued to players.

| Column | Data Type | Description |
|--------|-----------|-------------|
| Player_Name | VARCHAR(50) | Anonymized player ID |
| Player_Gender | VARCHAR(10) | Male/Female |
| Player_Years_Old | INT | Player age |
| Table_Currency | VARCHAR(10) | Currency code |
| Player_Card_Level | VARCHAR(50) | Loyalty tier |
| Promotion_Name | VARCHAR(100) | Promotion identifier |
| Total_Promotion_Value | DECIMAL(10,2) | Face value of promotion |
| Promotion_Cost | DECIMAL(10,2) | Actual cost to casino |
| Promotion_Issued_Date | DATETIME | Exact issue timestamp |
| Promotion_Issued_Hour | DATETIME | Hour bucket |

---

## 6. Raffles (`raffles`)

Raffle/drawing results.

| Column | Data Type | Description |
|--------|-----------|-------------|
| Player_Name | VARCHAR(50) | Anonymized player ID |
| Player_Gender | VARCHAR(10) | Male/Female |
| Player_Years_Old | INT | Player age |
| Player_Card_Level | VARCHAR(50) | Loyalty tier |
| Raffle_Name | VARCHAR(100) | Drawing name |
| Cordobas_Won | DECIMAL(12,2) | Prize amount (local currency) |
| Drawing_Result | VARCHAR(20) | "WON" or "Eliminated" |
| Drawing_Date | DATETIME | Drawing timestamp |
| Drawing_Hour | DATETIME | Hour bucket |

---

## Player Card Levels

The loyalty program appears to have multiple tiers:

| Card Type | Likely Tier |
|-----------|-------------|
| Card Type 1 | Base tier |
| Card Type 101 | Silver/Mid tier |
| Card Type 102 | Gold/Upper tier |
| Card Type 103 | Platinum/High tier |
| Card Type 105 | VIP/Top tier |

*Note: Tier names are inferred from data patterns*

---

## Currency Notes

- `$` = US Dollars (or equivalent)
- `C$` = Local currency (possibly Córdobas - Nicaraguan currency based on raffle data)

---

## Data Quality Notes

1. Some player ages show as "Unknown" in table play data
2. Session times may span multiple hours (data split by hour)
3. Large files are split into chunks (000_, 001_, etc.)
4. Theoretical values calculated using `Slot_Ideal_Payback_Pct`
