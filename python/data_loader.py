"""
Casino Analytics - Data Loader
Loads CSV files from data-raw into SQL Server CasinoAnalytics database
"""

import os
import sys
import glob
import pandas as pd
import pyodbc
from sqlalchemy import create_engine, text
from tqdm import tqdm

# Fix Windows console encoding
sys.stdout.reconfigure(encoding='utf-8', errors='replace')

# =============================================================================
# Configuration
# =============================================================================

# SQL Server connection string
# Adjust if your instance name is different
SERVER = r'localhost\SQLEXPRESS'
DATABASE = 'CasinoAnalytics'
DRIVER = 'ODBC Driver 17 for SQL Server'

# Path to raw data
DATA_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'data-raw')

# =============================================================================
# Database Connection
# =============================================================================

def get_connection_string():
    """Return SQLAlchemy connection string for SQL Server"""
    return f"mssql+pyodbc://{SERVER}/{DATABASE}?driver={DRIVER.replace(' ', '+')}&trusted_connection=yes"

def get_engine():
    """Create SQLAlchemy engine"""
    conn_str = get_connection_string()
    return create_engine(conn_str, fast_executemany=True)

def test_connection():
    """Test database connection"""
    try:
        engine = get_engine()
        with engine.connect() as conn:
            result = conn.execute(text("SELECT 1"))
            print("[OK] Database connection successful!")
            return True
    except Exception as e:
        print(f"[ERROR] Connection failed: {e}")
        return False

# =============================================================================
# Data Loading Functions
# =============================================================================

def get_csv_files(folder_name, pattern="*.csv"):
    """Get all CSV files from a folder, handling chunked files"""
    folder_path = os.path.join(DATA_PATH, folder_name)
    files = glob.glob(os.path.join(folder_path, pattern))
    # Sort to ensure consistent ordering (000_, 001_, etc.)
    return sorted(files)

def load_csv_to_table(folder_name, table_name, column_mapping, dtype_mapping=None):
    """
    Load all CSVs from a folder into a SQL table
    
    Args:
        folder_name: Subfolder in data-raw
        table_name: Target SQL table name
        column_mapping: Dict mapping CSV columns to SQL columns
        dtype_mapping: Optional pandas dtype specification
    """
    files = get_csv_files(folder_name)
    
    if not files:
        print(f"  No CSV files found in {folder_name}")
        return 0
    
    engine = get_engine()
    total_rows = 0
    
    print(f"\n{'='*50}")
    print(f"Loading {folder_name} -> {table_name}")
    print(f"{'='*50}")
    print(f"Found {len(files)} file(s)")
    
    for file_path in tqdm(files, desc=f"  Processing"):
        try:
            # Read CSV - treat all columns as strings to avoid type issues
            df = pd.read_csv(file_path, dtype=str, low_memory=False)
            
            if df.empty:
                continue
            
            # Rename columns to match SQL table
            df = df.rename(columns=column_mapping)
            
            # Keep only mapped columns that exist
            cols_to_keep = [col for col in column_mapping.values() if col in df.columns]
            df = df[cols_to_keep]
            
            # Convert numeric columns where possible (leave strings as strings)
            for col in df.columns:
                if col in ['number_ordered', 'total_minutes_played', 'games_played', 
                           'games_played_this_hour', 'bets_per_hour']:
                    df[col] = pd.to_numeric(df[col], errors='coerce').fillna(0).astype(int)
                elif col in ['order_total_dollars', 'total_dollars_bet', 'player_average_bet',
                             'dollars_player_lost', 'dollar_theory_lost', 'dollars_player_bet',
                             'theory_player_lost', 'currency_bills_accepted', 'currency_electronic_in',
                             'currency_electronic_out', 'currency_ticket_in', 'currency_ticket_out',
                             'slot_ideal_payback_pct', 'promotion_value', 'promotion_cost',
                             'cordobas_won', 'cash_buy_in', 'chips_buy_in', 'cash_out',
                             'player_lost', 'average_bet', 'hold_percentage']:
                    df[col] = pd.to_numeric(df[col], errors='coerce').fillna(0)
            
            # Load to SQL (append mode)
            df.to_sql(table_name, engine, if_exists='append', index=False, chunksize=5000)
            
            total_rows += len(df)
            
        except Exception as e:
            print(f"\n  Error loading {os.path.basename(file_path)}: {e}")
    
    print(f"  [OK] Loaded {total_rows:,} rows into {table_name}")
    return total_rows

# =============================================================================
# Column Mappings (CSV → SQL)
# =============================================================================

SLOT_PLAY_MAPPING = {
    'Slot Name': 'slot_name',
    'Player Name': 'player_name',
    'Player Gender': 'player_gender',
    'Player Years Old': 'player_years_old',
    'Model Name': 'model_name',
    'Make Name': 'make_name',
    'Slot Currency': 'slot_currency',
    'Play Start Date': 'play_start_date',
    'Play End Date': 'play_end_date',
    'Total Minutes Played This Session': 'total_minutes_played',
    'Slot Play Hour': 'slot_play_hour',
    'Games Played This Session': 'games_played',
    'Total Dollars Player Bet This Session': 'total_dollars_bet',
    'Player Average Bet': 'player_average_bet',
    'Dollars Player Lost': 'dollars_player_lost',
    'Dollar Theory Player Lost Amount': 'dollar_theory_lost',
    'Currency Bills Accepted': 'currency_bills_accepted',
    'Currency Electronic Money Accepted': 'currency_electronic_in',
    'Currency Electronic Mony Paid': 'currency_electronic_out',
    'Currency Ticket Accepted': 'currency_ticket_in',
    'Currency Ticket Paid': 'currency_ticket_out',
    'Slot Ideal Payback Percentage': 'slot_ideal_payback_pct',
    'Player Card Level': 'player_card_level'
}

SLOT_METERS_MAPPING = {
    'Slot Name': 'slot_name',
    'Model Name': 'model_name',
    'Make Name': 'make_name',
    'Slot Currency': 'slot_currency',
    'Slot Reading Hour': 'slot_reading_hour',
    'Games Played This Hour': 'games_played_this_hour',
    'Dollars Player Bet': 'dollars_player_bet',
    'Dollars Player Lost': 'dollars_player_lost',
    'Theory Player Lost Amount': 'theory_player_lost',
    'Slot Ideal Payback Percentage': 'slot_ideal_payback_pct'
}

TABLE_PLAY_MAPPING = {
    'Table Name': 'table_name',
    'Player Name': 'player_name',
    'Player Gender': 'player_gender',
    'Player Years Old': 'player_years_old',
    'Play Start Date Exact': 'play_start_date',
    'Play End Date Exact': 'play_end_date',
    'Total Minutes Played This Session': 'total_minutes_played',
    'Play Start Date Hour': 'play_start_hour',
    'Play End Date Hour': 'play_end_hour',
    'Table Currency': 'table_currency',
    'Player Card Level': 'player_card_level',
    'Session Cash Buy In Dollars': 'cash_buy_in',
    'Session Chips Buy In Dollars': 'chips_buy_in',
    'Session Cash Out Amount Dollars': 'cash_out',
    'Session Player Lost Dollars': 'player_lost',
    'Session Player Average Bet': 'average_bet',
    'Number of Bets Per Hour': 'bets_per_hour',
    'Hold Percentage': 'hold_percentage'
}

BAR_ORDERS_MAPPING = {
    'Player Name': 'player_name',
    'Player Gender': 'player_gender',
    'Player Years Old': 'player_years_old',
    'Player Card Level': 'player_card_level',
    'Item Ordered': 'item_ordered',
    'Number Ordered': 'number_ordered',
    'Item Cateogry': 'item_category',  # Note: typo in original data
    'Bar Order Hour': 'bar_order_hour',
    'Bar Order Date Exact': 'bar_order_date_exact',
    'Order Total Dollars': 'order_total_dollars'
}

PROMOTIONS_MAPPING = {
    'Player Name': 'player_name',
    'Player Gender': 'player_gender',
    'Player Years Old': 'player_years_old',
    'Table Currency': 'currency',
    'Player Card Level': 'player_card_level',
    'Promotion Name': 'promotion_name',
    'Total Promotion Value': 'promotion_value',
    'Promotion Cost In Dollars': 'promotion_cost',
    'Promotion Issued Date Exact': 'promotion_issued_date',
    'Promotion Issued Hour': 'promotion_issued_hour'
}

RAFFLES_MAPPING = {
    'Player Name': 'player_name',
    'Player Gender': 'player_gender',
    'Player Years Old': 'player_years_old',
    'Player Card Level': 'player_card_level',
    'Name': 'raffle_name',
    'Cordobas Won In Raffle': 'cordobas_won',
    'Raffle Drawing Result': 'drawing_result',
    'Promotion Issued Date Exact': 'drawing_date',
    'Promotion Issued Hour': 'drawing_hour'
}

# =============================================================================
# Main Execution
# =============================================================================

def main():
    print("\n" + "="*60)
    print("  CASINO ANALYTICS - DATA LOADER")
    print("="*60)
    
    # Test connection first
    if not test_connection():
        print("\nPlease check your SQL Server connection settings.")
        return
    
    total_loaded = 0
    
    # Load each dataset
    # Note: slot_play and slot_meters are large, will take a few minutes
    
    print("\n[1/6] Loading Bar Orders...")
    total_loaded += load_csv_to_table('bar-orders', 'bar_orders', BAR_ORDERS_MAPPING)
    
    print("\n[2/6] Loading Promotions...")
    total_loaded += load_csv_to_table('promo', 'promotions', PROMOTIONS_MAPPING)
    
    print("\n[3/6] Loading Raffles...")
    total_loaded += load_csv_to_table('raffles', 'raffles', RAFFLES_MAPPING)
    
    print("\n[4/6] Loading Table Play...")
    total_loaded += load_csv_to_table('table-play', 'table_play', TABLE_PLAY_MAPPING)
    
    print("\n[5/6] Loading Slot Play (this may take a few minutes)...")
    total_loaded += load_csv_to_table('slot-play', 'slot_play', SLOT_PLAY_MAPPING)
    
    print("\n[6/6] Loading Slot Meters (this may take a few minutes)...")
    total_loaded += load_csv_to_table('slot-meters', 'slot_meters', SLOT_METERS_MAPPING)
    
    print("\n" + "="*60)
    print(f"  COMPLETE! Total rows loaded: {total_loaded:,}")
    print("="*60)

if __name__ == "__main__":
    main()
