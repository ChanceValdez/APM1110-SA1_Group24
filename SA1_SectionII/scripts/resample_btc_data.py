import os
import pandas as pd
import numpy as np
 
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(SCRIPT_DIR)
 
btc_path = os.path.join(ROOT_DIR, 'data', 'raw', 'btcusd_1-min_data.csv')
out_dir = os.path.join(ROOT_DIR, 'data', 'processed')
os.makedirs(out_dir, exist_ok=True)

START = '2012-01-01'
END = '2026-09-15'
 
# === Process the Bitcoin Historical Data ===

# Read csv and convert columns lowercase
df = pd.read_csv(btc_path)
df.columns = df.columns.str.lower()

# Convert Unix timestamp to UTC datetime
df['timestamp'] = pd.to_datetime(df['timestamp'], unit='s')
df = df.set_index('timestamp')

# Drop padded rows without trading
df = df[df['volume'] > 0]

# Filter target date range (January 1, 2012 to September 15, 2026)
df = df.loc[START:END]

# Full 1-minute grid: missing bars become NaN, so a return only exists
# when the previous bar is exactly 1 minute earlier
df = df.asfreq('1min')
n_slots = len(df)

# Calculate 1-minute log returns
df['log_return'] = np.log(df['close'] / df['close'].shift(1))

# Keep valid returns only and report what was lost
df = df.dropna(subset=['log_return'])
print(f"Valid Returns: {len(df):,} of {n_slots:,} one minute slots")

# === Export Clean Data ===
df.to_csv(os.path.join(out_dir, 'btc_1min_returns_2012_2026.csv'), float_format='%.10g')
print("Successfully processed and saved 1 minute Bitcoin returns dataset.")

print(f"Observations: {len(df):,}")
print(f"First Bar: {df.index.min()}")
print(f"Last Bar: {df.index.max()}")