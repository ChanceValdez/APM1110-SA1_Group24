import os
import pandas as pd
import numpy as np

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(SCRIPT_DIR)
 
kraken_path = os.path.join(ROOT_DIR, 'data', 'raw', 'XETHZUSD.csv')
ohlc_path = os.path.join(ROOT_DIR, 'data', 'raw', 'ethusd_1min_ohlc.csv')
out_dir = os.path.join(ROOT_DIR, 'data', 'processed')
os.makedirs(out_dir, exist_ok=True)

START = '2015-08-07'
END = '2026-09-15'

# === Process the Kraken Ethereum Tick Data ===

# Read the .csv file ('XETHZUSD.csv')
df_trades = pd.read_csv(kraken_path, usecols=['price', 'quantity', 'timestamp'])

# Convert Unix timestamp to UTC datetime
df_trades['timestamp'] = pd.to_datetime(df_trades['timestamp'], unit='s')

# Keep real trades only and sort so first/last inside each bin are correct
df_trades = df_trades[df_trades['quantity'] > 0].sort_values('timestamp', kind='stable')

# Downsample tick intervals to 5-minute intervals
df_trades_5m = df_trades.resample('5min', on='timestamp').agg(
    open=('price', 'first'),
    high=('price', 'max'),
    low=('price', 'min'),
    close=('price', 'last'),
    volume=('quantity', 'sum')
).dropna(subset=['close'])

# === Process the Ethereum Historical Data ===

# Read the .csv file ('ethusd_1min_ohlc.csv')
df_ohlc = pd.read_csv(ohlc_path)

# Convert Unix timestamp to UTC datetime
df_ohlc['timestamp'] = pd.to_datetime(df_ohlc['timestamp'], unit='s')

# Drop padded rows with no trading
df_ohlc = df_ohlc[df_ohlc['volume'] > 0]

# Downsample 1-minute intervals to 5-minute intervals
df_ohlc_5m = df_ohlc.resample('5min', on='timestamp').agg(
    open=('open', 'first'),
    high=('high', 'max'),
    low=('low', 'min'),
    close=('close', 'last'),
    volume=('volume', 'sum')
).dropna(subset=['close'])

# === Merge the Two 5-Minute Datasets ===

# Cutover: trades before it, 1-minute bars from it onward, so no timestamp comes from both
cutover = df_ohlc['timestamp'].min().ceil('5min')

combined_df = pd.concat([df_trades_5m[df_trades_5m.index < cutover],
                         df_ohlc_5m[df_ohlc_5m.index >= cutover]]).sort_index()

# Filter target date range (August 7, 2015 to September 15, 2026)
combined_df = combined_df.loc[START:END]

# === Calculate Returns ===
 
# Full 5-minute grid: missing bars become NaN, so a return only exists
# when the previous bar is exactly 5 minutes earlier
combined_df = combined_df.asfreq('5min')
n_slots = len(combined_df)
 
# Calculate 5-minute log returns
combined_df['log_return'] = np.log(combined_df['close'] / combined_df['close'].shift(1))
 
# The return at the cutover mixes two sources, so drop it
combined_df.loc[cutover, 'log_return'] = np.nan
 
# Keep valid returns only and report what was lost
combined_df = combined_df.dropna(subset=['log_return'])
print(f"Cutover (UTC): {cutover}")
print(f"Valid Returns: {len(combined_df):,} of {n_slots:,} five-minute slots")
 
# === Export Clean Data ===
combined_df.to_csv(os.path.join(out_dir, 'eth_5min_returns_2015_2026.csv'))
print("Successfully processed, merged, and saved 5-minute Ethereum returns dataset.")

