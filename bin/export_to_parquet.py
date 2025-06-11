import pandas as pd
from pathlib import Path

csv_file = Path("lakehouse/amr_results.csv")
parquet_file = Path("lakehouse/amr_results.parquet")

if not csv_file.exists():
    raise FileNotFoundError(f"Missing input: {csv_file}")

# Read CSV
df = pd.read_csv(csv_file)

# Ensure lakehouse directory exists
parquet_file.parent.mkdir(parents=True, exist_ok=True)

# Save to Parquet (this time for real)
df.to_parquet(parquet_file, index=False)

print(f"Successfully wrote: {parquet_file}")

