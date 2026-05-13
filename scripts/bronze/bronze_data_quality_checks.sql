/*
====================================================
BRONZE LAYER - DATA VALIDATION CHECKS
====================================================

Purpose:
This script validates data quality after ingestion.

Checks performed:
- Row count validation
- Null value detection
- Sample data inspection
- Column sanity checks
====================================================
*/

SELECT * FROM bronze.loan_default

SELECT COUNT(*) FROM bronze.loan_default

SELECT * FROM bronze.loan_default
LIMIT 5

SELECT
	COUNT(*) AS total_rows,
	COUNT(*) FILTER (WHERE id IS NULL) AS id_nulls,
	COUNT(*) FILTER (WHERE loan_amount IS NULL) AS loan_amount_nulls,
	COUNT(*) FILTER (WHERE income IS NULL) AS income_nulls,
	COUNT(*) FILTER (WHERE LTV IS NULL) AS ltv_nulls
FROM bronze.loan_default 

SELECT loan_amount FROM bronze.loan_default
LIMIT 10

