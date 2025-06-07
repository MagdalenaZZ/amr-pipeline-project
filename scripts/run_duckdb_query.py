import duckdb

con = duckdb.connect()

results = con.execute("""
    SELECT
      organism,
      resistance_gene,
      platform,
      COUNT(*) AS gene_count
    FROM 'lakehouse/amr_results.parquet'
    GROUP BY organism, resistance_gene, platform
    ORDER BY gene_count DESC
    LIMIT 10
""").fetchall()

for row in results:
    print(row)

