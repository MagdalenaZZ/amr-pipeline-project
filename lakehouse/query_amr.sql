-- Query AMR results from a Parquet file
SELECT
  organism,
  resistance_gene,
  platform,
  COUNT(*) as gene_count
FROM 'lakehouse/amr_results.parquet'
GROUP BY organism, resistance_gene, platform
ORDER BY gene_count DESC
LIMIT 10;

