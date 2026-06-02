/*
================================================================================
GOLD LAYER - DATA QUALITY & CONSISTENCY TEST SCRIPT
================================================================================

Purpose:
This script is designed to validate the integrity, consistency, and correctness
of the Gold layer data model after ETL execution.

It performs the following checks:

1. Row Count Validation
   - Compares record counts between staging, fact, and view layers
   - Ensures no unexpected data loss during transformation

2. Referential Integrity Checks (Left Join Validation)
   - Verifies that all foreign keys in fact table correctly match dimension tables
   - Identifies orphan records (missing dimension mappings)

3. Duplicate Key Detection
   - Ensures that source_id values in fact table are unique
   - Prevents duplicate ingestion of staging records

4. Missing Dimension Coverage
   - Checks whether fact records are fully mapped to all dimension tables
   - Reports missing relationships per dimension

Business Value:
This script ensures data reliability for analytics, reporting, and machine learning
use cases by validating that the star schema is correctly built and consistent.

Usage:
Run this script after each ETL execution to verify data integrity of the Gold layer.

================================================================================
*/

--row number check
SELECT COUNT(*) 
FROM gold.stg_loan_default;

SELECT COUNT(*) 
FROM gold.fact_loan_application;

SELECT COUNT(*) 
FROM gold.view_loan_default;

--left join null check for IDs

SELECT COUNT(*) 
FROM gold.fact_loan_application f
LEFT JOIN gold.dim_customer dc
    ON f.customer_id = dc.customer_id
WHERE dc.customer_id IS NULL;

SELECT COUNT(*) 
FROM gold.fact_loan_application f
LEFT JOIN gold.dim_loan dl
    ON f.loan_id = dl.loan_id
WHERE dl.loan_id IS NULL;

SELECT COUNT(*) 
FROM gold.fact_loan_application f
LEFT JOIN gold.dim_property dp
    ON f.property_id = dp.property_id
WHERE dp.property_id IS NULL;

SELECT COUNT(*) 
FROM gold.fact_loan_application f
LEFT JOIN gold.dim_credit_profile dcp
    ON f.credit_profile_id = dcp.credit_profile_id
WHERE dcp.credit_profile_id IS NULL;

SELECT COUNT(*) 
FROM gold.fact_loan_application f
LEFT JOIN gold.dim_application da
    ON f.application_id = da.application_id
WHERE da.application_id IS NULL;

--duplicate check

SELECT source_id, COUNT(*)
FROM gold.fact_loan_application
GROUP BY source_id
HAVING COUNT(*) > 1;

--missing value check

SELECT 'customer' AS dim, COUNT(*) FILTER (WHERE dc.customer_id IS NULL) AS missing
FROM gold.fact_loan_application f
LEFT JOIN gold.dim_customer dc ON f.customer_id = dc.customer_id

UNION ALL

SELECT 'loan' AS dim, COUNT(*) FILTER (WHERE dl.loan_id IS NULL) AS missing
FROM gold.fact_loan_application f
LEFT JOIN gold.dim_loan dl ON f.loan_id = dl.loan_id

UNION ALL

SELECT 'property' AS dim, COUNT(*) FILTER (WHERE dp.property_id IS NULL) AS missing
FROM gold.fact_loan_application f
LEFT JOIN gold.dim_property dp ON f.property_id = dp.property_id

UNION ALL

SELECT 'credit_profile' AS dim, COUNT(*) FILTER (WHERE dcp.credit_profile_id IS NULL) AS missing
FROM gold.fact_loan_application f
LEFT JOIN gold.dim_credit_profile dcp ON f.credit_profile_id = dcp.credit_profile_id

UNION ALL

SELECT 'application' AS dim, COUNT(*) FILTER (WHERE da.application_id IS NULL) AS missing
FROM gold.fact_loan_application f
LEFT JOIN gold.dim_application da ON f.application_id = da.application_id;



   





