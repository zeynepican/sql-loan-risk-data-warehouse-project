/*
====================================================
SILVER LAYER - DATA QUALITY CHECK
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

--SILVER LAYER DATA QUALITY CHECK

--Row Count Validation
SELECT COUNT(*) FROM bronze.loan_default
SELECT COUNT(*) FROM silver.loan_default

--NULL Analysis
SELECT COUNT(*) FROM silver.loan_default
WHERE id IS NULL
--Duplicate Check
SELECT id, COUNT(*) FROM silver.loan_default
GROUP BY id
HAVING COUNT(*)>1

SELECT COUNT(*) FROM silver.loan_default
WHERE year IS NULL

SELECT DISTINCT loan_limit FROM silver.loan_default

SELECT DISTINCT gender FROM silver.loan_default

SELECT DISTINCT approval_in_advance FROM silver.loan_default

SELECT DISTINCT loan_type FROM silver.loan_default

SELECT DISTINCT loan_purpose FROM silver.loan_default

SELECT DISTINCT credit_worthiness FROM silver.loan_default

SELECT DISTINCT open_credit FROM silver.loan_default

SELECT DISTINCT business_or_commercial FROM silver.loan_default

SELECT COUNT(*) FROM silver.loan_default
WHERE loan_amount IS NULL

SELECT DISTINCT loan_amount FROM silver.loan_default

SELECT *
FROM silver.loan_default
WHERE is_default = true
AND loan_amount IS NULL;

SELECT COUNT(*) FROM silver.loan_default
WHERE rate_of_interest IS NULL

SELECT DISTINCT rate_of_interest FROM silver.loan_default

SELECT COUNT(*) FROM silver.loan_default
WHERE interest_rate_spread IS NULL

SELECT COUNT(*) FROM silver.loan_default
WHERE upfront_charges IS NULL

SELECT COUNT(*) FROM silver.loan_default
WHERE term IS NULL

SELECT COUNT(*) FROM silver.loan_default
WHERE neg_amortization IS NULL

SELECT DISTINCT neg_amortization FROM silver.loan_default

SELECT COUNT(*) FROM silver.loan_default
WHERE is_interest_only IS NULL

SELECT DISTINCT is_interest_only FROM silver.loan_default

SELECT COUNT(*) FROM silver.loan_default
WHERE is_lump_sum_payment IS NULL

SELECT DISTINCT is_lump_sum_payment FROM silver.loan_default

SELECT COUNT(*) FROM silver.loan_default
WHERE property_value IS NULL

SELECT COUNT(*) FROM silver.loan_default
WHERE construction_type IS NULL

SELECT DISTINCT construction_type FROM silver.loan_default

SELECT COUNT(*) FROM silver.loan_default
WHERE occupancy_type IS NULL

SELECT DISTINCT occupancy_type FROM silver.loan_default

SELECT COUNT(*) FROM silver.loan_default
WHERE secured_by IS NULL

SELECT DISTINCT secured_by FROM silver.loan_default

SELECT COUNT(*) FROM silver.loan_default
WHERE total_units IS NULL

SELECT DISTINCT total_units FROM silver.loan_default

SELECT COUNT(*) FROM silver.loan_default
WHERE income IS NULL

SELECT DISTINCT income FROM silver.loan_default

SELECT COUNT(*) FROM silver.loan_default
WHERE credit_type IS NULL

SELECT DISTINCT credit_type FROM silver.loan_default

SELECT COUNT(*) FROM silver.loan_default
WHERE credit_score IS NULL

SELECT DISTINCT credit_score FROM silver.loan_default

SELECT COUNT(*) FROM silver.loan_default
WHERE co_applicant_credit_type IS NULL

SELECT DISTINCT co_applicant_credit_type FROM silver.loan_default

SELECT COUNT(*) FROM silver.loan_default
WHERE age = 'n/a'

SELECT DISTINCT age FROM silver.loan_default

SELECT COUNT(*) FROM silver.loan_default
WHERE submission_of_application = 'n/a'

SELECT DISTINCT submission_of_application FROM silver.loan_default

SELECT COUNT(*) FROM silver.loan_default
WHERE loan_to_value_ratio IS NULL

SELECT DISTINCT loan_to_value_ratio FROM silver.loan_default

SELECT COUNT(*) FROM silver.loan_default
WHERE region IS NULL

SELECT DISTINCT region FROM silver.loan_default

SELECT COUNT(*) FROM silver.loan_default
WHERE security_type IS NULL

SELECT DISTINCT security_type FROM silver.loan_default

SELECT COUNT(*) FROM silver.loan_default
WHERE is_default IS NULL

SELECT DISTINCT is_default FROM silver.loan_default

SELECT COUNT(*) FROM silver.loan_default
WHERE debt_to_income_ratio IS NULL

SELECT DISTINCT debt_to_income_ratio FROM silver.loan_default

SELECT COUNT(*) FROM silver.loan_default
WHERE load_timestamp IS NULL

SELECT DISTINCT load_timestamp FROM silver.loan_default

SELECT COUNT(*) FROM silver.loan_default
WHERE source_file IS NULL

SELECT DISTINCT source_file FROM silver.loan_default









