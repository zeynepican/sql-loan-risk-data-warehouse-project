/*
====================================================
BRONZE LAYER - DATA PROFILING & QUALITY VALIDATION SCRIPT
====================================================

Purpose:
This script performs comprehensive data profiling and data quality validation
on the bronze layer before applying transformations to the silver layer.

Scope:
- Identifies missing, null, or malformed values
- Detects duplicates and inconsistent records
- Validates business rules (e.g., LTV calculation consistency)
- Performs statistical profiling (min, max, avg, distributions)
- Verifies categorical value consistency and standardization rules
- Provides transformation logic preview for silver layer modeling

Outcome:
The results of this script are used to design and validate the silver layer
transformation rules and ensure data integrity before loading into downstream layers.

Note:
This is a non-destructive analysis script and does not modify source data.
====================================================
*/

--test for silver layer transformation
--for id
SELECT * FROM bronze.loan_default
SELECT COUNT (*) id FROM bronze.loan_default -- ID value check for each row

SELECT id                               --Is there a null or empty value
FROM bronze.loan_default
WHERE id IS NULL OR id = '';


SELECT id                 --Is there an ID value in a non-numeric value
FROM bronze.loan_default
WHERE id !~ '^[0-9]+$';

--duplicate check
SELECT id, COUNT(*)
FROM bronze.loan_default
GROUP BY id
HAVING  COUNT(*)>1
--transformation to be performed
SELECT id::BIGINT AS id         --Change data type to int
FROM bronze.loan_default;

--for year
SELECT COUNT(year) FROM bronze.loan_default;   

SELECT year                               --Is there a null or empty value
FROM bronze.loan_default
WHERE year IS NULL OR year = '';

SELECT year                 --Is there an year value in a non-numeric value
FROM bronze.loan_default
WHERE year !~ '^[0-9]+$';

SELECT DISTINCT year FROM bronze.loan_default      --We saw that the year data consists of a single year, which means it is not a feature column.

--transformation to be performed
SELECT year:: smallint AS year
FROM bronze.loan_default

--for loan_limit
SELECT COUNT(loan_limit) FROM bronze.loan_default           

SELECT loan_limit FROM bronze.loan_default           --There are null values in loan_limit
WHERE loan_limit IS NULL OR loan_limit = ''

SELECT DISTINCT loan_limit FROM bronze.loan_default
--transformation to be performed
SELECT CASE 
	WHEN LOWER(TRIM(loan_limit)) = 'cf' THEN 'conforming'
	WHEN LOWER(TRIM(loan_limit)) = 'ncf' THEN 'nonconforming'
	ELSE 'n/a'
END AS loan_limit
FROM bronze.loan_default


--for gender
SELECT DISTINCT gender FROM bronze.loan_default

SELECT DISTINCT gender
FROM bronze.loan_default
WHERE LOWER(TRIM(gender)) NOT IN (
    'female',
    'male',
    'joint',
    'sex not available'
);
--transformation to be performed
SELECT CASE
	WHEN LOWER(TRIM(gender)) = 'female' THEN 'female'
	WHEN LOWER(TRIM(gender)) = 'male' THEN 'male'
	WHEN LOWER(TRIM(gender)) = 'joint' THEN 'joint'
	WHEN LOWER(TRIM(gender)) = 'sex not available' THEN 'n/a'
	ELSE 'n/a'
END AS gender
FROM bronze.loan_default

--for approv in adv 
--duplicate check
SELECT DISTINCT approv_in_adv FROM bronze.loan_default

--hidden dirty value
SELECT DISTINCT approv_in_adv
FROM bronze.loan_default
WHERE LOWER(TRIM(approv_in_adv)) NOT IN ('pre','nopre')
AND approv_in_adv IS NOT NULL;

--transformation to be performed
SELECT CASE
	WHEN LOWER(TRIM(approv_in_adv)) = 'pre' THEN 'pre_approved'
	WHEN LOWER(TRIM(approv_in_adv)) = 'nopre' THEN 'not_pre_approved'
	ELSE 'n/a'
END AS approval_in_advance
FROM bronze.loan_default

--for loan_type
SELECT DISTINCT loan_type FROM bronze.loan_default

--hidden dirty value
SELECT DISTINCT LOWER(TRIM(loan_type))
FROM bronze.loan_default;

--transformation to be performed
SELECT CASE 
	WHEN LOWER(TRIM(loan_type)) = 'type1' THEN 'type1'
	WHEN LOWER(TRIM(loan_type)) = 'type2' THEN 'type2'
	WHEN LOWER(TRIM(loan_type)) = 'type3' THEN 'type3'
	ELSE 'n/a'
END AS loan_type
FROM bronze.loan_default

--for loan_purpose
SELECT DISTINCT loan_purpose FROM bronze.loan_default

-- hidden dirty value 
SELECT loan_purpose FROM bronze.loan_default
WHERE LOWER(TRIM(loan_purpose)) NOT IN ('p1','p2','p3','p4') 
AND loan_purpose IS NOT NULL

--transformation to be performed
SELECT CASE 
	WHEN LOWER(TRIM(loan_purpose)) = 'p1' THEN 'p1'
	WHEN LOWER(TRIM(loan_purpose)) = 'p2' THEN 'p2'
	WHEN LOWER(TRIM(loan_purpose)) = 'p3' THEN 'p3'
	WHEN LOWER(TRIM(loan_purpose)) = 'p4' THEN 'p4'
	ELSE 'n/a'
END AS loan_purpose
FROM bronze.loan_default

--for credit_worthiness
SELECT DISTINCT credit_worthiness FROM bronze.loan_default

--hidden dirty value control
SELECT credit_worthiness FROM bronze.loan_default
WHERE LOWER(TRIM(credit_worthiness)) NOT IN ('l1','l2') 
AND loan_purpose IS NOT NULL

--transformation to be performed
SELECT CASE 
	WHEN LOWER(TRIM(credit_worthiness)) = 'l1' THEN 'l1'
	WHEN LOWER(TRIM(credit_worthiness)) = 'l2' THEN 'l2'
	ELSE 'n/a'
END AS credit_worthiness
FROM bronze.loan_default

--for open_credit
SELECT DISTINCT open_credit FROM bronze.loan_default

--hidden dirty value check
SELECT open_credit FROM bronze.loan_default
WHERE LOWER(TRIM(open_credit)) NOT IN ('nopc','opc')

--transformation to be performed
SELECT CASE 
	WHEN LOWER(TRIM(open_credit)) = 'nopc' THEN 'no_open_credit'
	WHEN LOWER(TRIM(open_credit)) = 'opc' THEN 'open_credit'
	ELSE 'n/a'
END AS open_credit
FROM bronze.loan_default

--for business_or_commercial
SELECT DISTINCT business_or_commercial FROM bronze.loan_default

--hidden dirty value 
SELECT business_or_commercial FROM bronze.loan_default
WHERE LOWER(TRIM(business_or_commercial)) NOT IN ('b/c','nob/c')

--transformation to be performed
SELECT CASE 
	WHEN LOWER(TRIM(business_or_commercial)) = 'b/c' THEN 'business_commercial'
	WHEN LOWER(TRIM(business_or_commercial)) = 'nob/c' THEN 'non_business_commercial'
	ELSE 'n/a'
END AS business_or_commercial
FROM bronze.loan_default

--for loan_amount
SELECT loan_amount FROM bronze.loan_default
WHERE loan_amount IS NULL OR loan_amount= ''

SELECT DISTINCT loan_amount FROM bronze.loan_default

SELECT loan_amount                 --Is there a loan_amount value in a non-numeric value
WHERE loan_amount !~ '^[0-9]+(\.[0-9]+)?$';

--negative or zero value check
SELECT loan_amount FROM bronze.loan_default
WHERE CAST(loan_amount AS NUMERIC) <=0

--checking of distribution
SELECT 
	MIN(CAST(loan_amount AS NUMERIC)) AS min_value,
	MAX(CAST(loan_amount AS NUMERIC)) AS max_value,
	AVG(CAST(loan_amount AS NUMERIC)) AS avg_value
FROM bronze.loan_default

--checking of outlier
SELECT loan_amount FROM bronze.loan_default
ORDER BY CAST(loan_amount AS NUMERIC) DESC
LIMIT 10

--Transformation to be performed
SELECT (CASE
	WHEN loan_amount IS NULL THEN NULL
	WHEN CAST(loan_amount AS NUMERIC)< 0 THEN 0
	ELSE CAST (loan_amount AS NUMERIC) 
END 
)::BIGINT AS loan_amount FROM bronze.loan_default

--for rate_of_interest
SELECT DISTINCT rate_of_interest FROM bronze.loan_default

SELECT rate_of_interest
FROM bronze.loan_default
WHERE rate_of_interest !~ '^[0-9]+(\.[0-9]+)?$';

--checking of distribution
SELECT 
	MIN(CAST(rate_of_interest AS NUMERIC)) AS min_value,
	MAX(CAST(rate_of_interest AS NUMERIC)) AS max_value,
	AVG(CAST(rate_of_interest AS NUMERIC)) AS avg_value
FROM bronze.loan_default

--checking of outlier
SELECT loan_amount FROM bronze.loan_default
ORDER BY CAST(loan_amount AS NUMERIC) DESC
LIMIT 10


--transformation to be performed
SELECT (CASE
	WHEN rate_of_interest IS NULL THEN 'n/a'
	WHEN CAST(rate_of_interest AS NUMERIC)< 0 THEN 'n/a'
	ELSE CAST (rate_of_interest AS NUMERIC) 
END 
)::NUMERIC(5,2) AS rate_of_interest FROM bronze.loan_default

--for interest_rate_spread
SELECT DISTINCT interest_rate_spread FROM bronze.loan_default

SELECT interest_rate_spread
FROM bronze.loan_default
WHERE interest_rate_spread !~ '^[0-9]+(\.[0-9]+)?$';

SELECT 
	MIN(CAST(interest_rate_spread AS NUMERIC)) AS min_value,
	MAX(CAST(interest_rate_spread AS NUMERIC)) AS max_value,
	AVG(CAST(interest_rate_spread AS NUMERIC)) AS avg_value
FROM bronze.loan_default

SELECT interest_rate_spread FROM bronze.loan_default
ORDER BY CAST(interest_rate_spread AS NUMERIC) DESC
LIMIT 10

--transformation to be performed

SELECT interest_rate_spread::NUMERIC(10,3) AS interest_rate_spread
FROM bronze.loan_default

--for upfront_charges
SELECT DISTINCT upfront_charges FROM bronze.loan_default

SELECT upfront_charges
FROM bronze.loan_default
WHERE upfront_charges !~ '^[0-9]+(\.[0-9]+)?$';

SELECT 
	MIN(CAST(upfront_charges AS NUMERIC)) AS min_value,
	MAX(CAST(upfront_charges AS NUMERIC)) AS max_value,
	AVG(CAST(upfront_charges AS NUMERIC)) AS avg_value
FROM bronze.loan_default

SELECT upfront_charges FROM bronze.loan_default
ORDER BY CAST(upfront_charges AS NUMERIC) DESC
LIMIT 10

--transformation to be performed
SELECT CAST(upfront_charges AS NUMERIC(10,2)) AS upfront_charges
FROM bronze.loan_default

--for term
SELECT * FROM bronze.loan_default
SELECT DISTINCT term FROM bronze.loan_default

SELECT term
FROM bronze.loan_default
WHERE term !~ '^[0-9]+(\.[0-9]+)?$';

SELECT 
	MIN(CAST(term AS NUMERIC)) AS min_value,
	MAX(CAST(term AS NUMERIC)) AS max_value,
	AVG(CAST(term AS NUMERIC)) AS avg_value
FROM bronze.loan_default

--transformation to be performed
CASE 
    WHEN term IS NULL THEN NULL
    WHEN term::NUMERIC <= 0 THEN NULL
    ELSE term::NUMERIC
END::INTEGER AS term

--for neg_ammortization
SELECT DISTINCT neg_ammortization FROM bronze.loan_default

--transformation to be performed
SELECT (CASE 
	WHEN LOWER(TRIM(neg_ammortization)) = 'neg_amm' THEN true
	WHEN LOWER(TRIM(neg_ammortization)) = 'not_neg' THEN false
	ELSE NULL
END
)::boolean AS neg_ammortization FROM bronze.loan_default

--for interest_only
SELECT DISTINCT interest_only FROM bronze.loan_default

SELECT interest_only, COUNT(*)
FROM bronze.loan_default
GROUP BY interest_only;
--transformation to be performed
SELECT CASE 
	WHEN LOWER(TRIM(interest_only)) = 'int_only' THEN true
	WHEN LOWER(TRIM(interest_only)) = 'not_int' THEN false
	ELSE NULL
END::BOOLEAN AS is_interest_only
from bronze.loan_default

--for lump_sum_payment
SELECT DISTINCT lump_sum_payment FROM bronze.loan_default

SELECT lump_sum_payment, COUNT(*) 
FROM bronze.loan_default
GROUP BY lump_sum_payment

--transformation to be performed
SELECT CASE 
	WHEN LOWER(TRIM(lump_sum_payment)) = 'lpsm' THEN true
	WHEN LOWER(TRIM(lump_sum_payment)) = 'not_lpsm' THEN false
	ELSE NULL
END::BOOLEAN AS is_lump_sum_payment
from bronze.loan_default

--for property_value
SELECT DISTINCT property_value FROM bronze.loan_default

SELECT property_value
FROM bronze.loan_default
WHERE property_value !~ '^[0-9]+(\.[0-9]+)?$';

SELECT 
	MIN(CAST(property_value AS NUMERIC)) AS min_value,
	MAX(CAST(property_value AS NUMERIC)) AS max_value,
	AVG(CAST(property_value AS NUMERIC)) AS avg_value
FROM bronze.loan_default

SELECT property_value, COUNT(*)
FROM bronze.loan_default
WHERE property_value IS NULL
GROUP BY property_value

--transformation to be performed
SELECT CASE 
    WHEN property_value IS NULL THEN NULL
    WHEN property_value::NUMERIC <= 0 THEN NULL
    ELSE property_value::NUMERIC
END::NUMERIC(18,2) AS property_value
FROM bronze.loan_default;

--for construction_type
SELECT DISTINCT construction_type FROM bronze.loan_default
SELECT construction_type, COUNT(*) FROM bronze.loan_default
GROUP BY construction_type

--transformation to be performed
SELECT 
CASE 
    WHEN LOWER(TRIM(construction_type)) = 'mh' THEN 'manufactured_home'
    WHEN LOWER(TRIM(construction_type)) = 'sb' THEN 'site_built'
	ELSE 'n/a'
END AS construction_type
FROM bronze.loan_default;

--for occupancy_type
SELECT DISTINCT occupancy_type FROM bronze.loan_default
SELECT occupancy_type, COUNT(*) FROM bronze.loan_default
GROUP BY occupancy_type

--transformation to be performed
SELECT 
CASE 
    WHEN LOWER(TRIM(occupancy_type)) = 'pr' THEN 'primary_residence'
    WHEN LOWER(TRIM(occupancy_type)) = 'ir' THEN 'investment_residence'
    WHEN LOWER(TRIM(occupancy_type)) = 'sr' THEN 'secondary_residence'
	ELSE 'n/a'
END AS occupancy_type
FROM bronze.loan_default;

--for secured_by
SELECT DISTINCT secured_by FROM bronze.loan_default
	
SELECT secured_by, COUNT(*) FROM bronze.loan_default
GROUP BY secured_by

--transformation to be performed
SELECT 
CASE 
    WHEN LOWER(TRIM(secured_by)) = 'home' THEN 'home'
    WHEN LOWER(TRIM(secured_by)) = 'land' THEN 'land'
	ELSE 'n/a'
END AS secured_by
FROM bronze.loan_default;

--for total_units
SELECT DISTINCT total_units FROM bronze.loan_default

SELECT total_units, COUNT(*) FROM bronze.loan_default
GROUP BY total_units

--transformation to be performed
SELECT 
CASE 
    WHEN LOWER(TRIM(total_units)) = '1u' THEN '1u'
    WHEN LOWER(TRIM(total_units)) = '2u' THEN '2u'
    WHEN LOWER(TRIM(total_units)) = '3u' THEN '3u'
    WHEN LOWER(TRIM(total_units)) = '4u' THEN '4u'
	ELSE 'n/a'
END AS total_units
FROM bronze.loan_default;

--for income
SELECT DISTINCT income FROM bronze.loan_default;

SELECT income
FROM bronze.loan_default
WHERE income !~ '^[0-9]+(\.[0-9]+)?$';

SELECT 
	MIN(CAST(income AS NUMERIC)) AS min_value,
	MAX(CAST(income AS NUMERIC)) AS max_value,
	AVG(CAST(income AS NUMERIC)) AS avg_value
FROM bronze.loan_default

SELECT income
FROM bronze.loan_default
WHERE income IS NULL
--transformation to be performed
SELECT CASE 
    WHEN income IS NULL THEN NULL
    WHEN income::NUMERIC <= 0 THEN NULL
    ELSE income::NUMERIC
END::NUMERIC(18,2) AS income
FROM bronze.loan_default;

--for credit_type
SELECT DISTINCT credit_type FROM bronze.loan_default
SELECT credit_type, COUNT(*)FROM bronze.loan_default
GROUP BY credit_type

--transformation to be performed
SELECT 
CASE 
    WHEN UPPER(TRIM(credit_type)) = 'CIB' THEN 'credit_information_bureau'
    WHEN UPPER(TRIM(credit_type)) = 'CRIF' THEN 'crif_credit_bureau'
    WHEN UPPER(TRIM(credit_type)) = 'EQUI' THEN 'equifax'
    WHEN UPPER(TRIM(credit_type)) = 'EXP' THEN 'experian'
	ELSE 'n/a'
END AS credit_type
FROM bronze.loan_default;

--for credit_score
SELECT DISTINCT credit_score FROM bronze.loan_default

SELECT credit_score
FROM bronze.loan_default
WHERE credit_score !~ '^[0-9]+(\.[0-9]+)?$';

SELECT 
	MIN(CAST(credit_score AS NUMERIC)) AS min_value,
	MAX(CAST(credit_score AS NUMERIC)) AS max_value,
	AVG(CAST(credit_score AS NUMERIC)) AS avg_value
FROM bronze.loan_default

SELECT DISTINCT credit_score FROM bronze.loan_default
WHERE credit_score IS NULL

SELECT credit_score FROM bronze.loan_default
ORDER BY CAST(credit_score AS NUMERIC) DESC
LIMIT 10
--transformation to be performed
SELECT CASE 
    WHEN credit_score IS NULL THEN NULL
    WHEN credit_score::INTEGER <= 0 THEN NULL
    ELSE credit_score::INTEGER
END::INTEGER AS credit_score
FROM bronze.loan_default;

--FOR co_applicant_credit_type
SELECT DISTINCT co_applicant_credit_type FROM bronze.loan_default
SELECT co_applicant_credit_type, COUNT(*) FROM bronze.loan_default
GROUP BY co_applicant_credit_type

--transformation to be performed
SELECT 
CASE 
    WHEN UPPER(TRIM(co_applicant_credit_type)) = 'CIB' THEN 'credit_information_bureau'
    WHEN UPPER(TRIM(co_applicant_credit_type)) = 'EXP' THEN 'experian'
	ELSE 'n/a'
END AS co_applicant_credit_type
FROM bronze.loan_default;

--for age
SELECT DISTINCT age FROM bronze.loan_default
ORDER BY age ASC

SELECT age, COUNT(*) FROM bronze.loan_default
GROUP BY age

--transformation to be performed
SELECT CASE 
    WHEN age = '<25' THEN '<25'
    WHEN age = '25-34' THEN '25-34'
    WHEN age = '35-44' THEN '35-44'
    WHEN age = '45-54' THEN '45-54'
    WHEN age = '55-64' THEN '55-64'
    WHEN age = '65-74' THEN '65-74'
    WHEN age = '>74' THEN '>74'
    ELSE 'n/a'
END AS age FROM bronze.loan_default

--FOR submission_of_application
SELECT DISTINCT submission_of_application FROM bronze.loan_default
SELECT submission_of_application, COUNT(*) FROM bronze.loan_default
GROUP BY submission_of_application

--transformation to be performed
SELECT 
CASE 
    WHEN LOWER(TRIM(submission_of_application)) = 'to_inst' THEN 'through_institution'
    WHEN LOWER(TRIM(submission_of_application)) = 'not_inst' THEN 'not_through_institution'
    ELSE 'n/a'
END AS submission_of_application
FROM bronze.loan_default;

--for ltv
SELECT DISTINCT ltv FROM bronze.loan_default;

SELECT ltv
FROM bronze.loan_default
WHERE ltv !~ '^[0-9]+(\.[0-9]+)?$';

SELECT 
	MIN(CAST(ltv AS NUMERIC)) AS min_value,
	MAX(CAST(ltv AS NUMERIC)) AS max_value,
	AVG(CAST(ltv AS NUMERIC)) AS avg_value
FROM bronze.loan_default

SELECT ltv FROM bronze.loan_default
WHERE ltv IS NOT NULL
ORDER BY ltv DESC

SELECT * FROM bronze.loan_default
WHERE ltv IS NULL AND loan_amount IS NOT NULL AND property_value IS NOT NULL

SELECT * FROM bronze.loan_default
WHERE ltv IS NOT NULL AND loan_amount IS NULL AND property_value IS NOT NULL

SELECT * FROM bronze.loan_default
WHERE ltv IS NOT NULL AND loan_amount IS NOT NULL AND property_value IS NULL

--ltv business rule check
SELECT *
FROM bronze.loan_default
WHERE ltv IS NOT NULL
  AND loan_amount IS NOT NULL
  AND property_value IS NOT NULL
  AND property_value::NUMERIC != 0
  AND ABS(
        ltv::NUMERIC - 
        ((loan_amount::NUMERIC / property_value::NUMERIC) * 100)
      ) > 0.01;

SELECT 
COUNT(*) AS inconsistent_rows
FROM bronze.loan_default
WHERE ltv IS NOT NULL
  AND loan_amount IS NOT NULL
  AND property_value IS NOT NULL
  AND property_value::NUMERIC != 0
  AND ABS(
        ltv::NUMERIC - 
        ((loan_amount::NUMERIC / property_value::NUMERIC) * 100)
      ) > 0.01;

SELECT loan_amount,property_value,ltv FROM bronze.loan_default
WHERE ltv IS NULL

--transformation to be performed
SELECT CASE 
    WHEN ltv IS NULL THEN NULL
    WHEN ltv::NUMERIC <= 0 THEN NULL
    ELSE ltv::NUMERIC
END::NUMERIC(10,2) AS loan_to_value_ratio
FROM bronze.loan_default;

--for region
SELECT DISTINCT region FROM bronze.loan_default
SELECT region, COUNT(*) FROM bronze.loan_default
GROUP BY region
--transformation to be performed
SELECT 
CASE 
    WHEN LOWER(TRIM(region)) = 'north' THEN 'north'
    WHEN LOWER(TRIM(region)) = 'south' THEN 'south'
    WHEN LOWER(TRIM(region)) = 'central' THEN 'central'
    WHEN LOWER(TRIM(region)) = 'north-east' THEN 'north_east'
    ELSE 'n/a'
END AS region
FROM bronze.loan_default;

--for security_type
SELECT DISTINCT security_type FROM bronze.loan_default
SELECT security_type, COUNT(*) FROM bronze.loan_default
GROUP BY security_type
--transformation to be performed
SELECT 
CASE 
    WHEN LOWER(TRIM(security_type)) = 'direct' THEN 'direct'
    WHEN LOWER(TRIM(security_type)) IN ('indriect', 'indirect') THEN 'indirect'
    ELSE 'n/a'
END AS security_type
FROM bronze.loan_default;

--for status
SELECT DISTINCT status FROM bronze.loan_default

SELECT status, COUNT(*) FROM bronze.loan_default
GROUP BY status

SELECT status
FROM bronze.loan_default
WHERE status !~ '^[0-9]+(\.[0-9]+)?$';

--transformation to be performed
SELECT CASE 
	WHEN status::INTEGER = 1 THEN true 
	WHEN status::INTEGER = 0 THEN false 
	ELSE NULL 
END::BOOLEAN AS is_default
FROM bronze.loan_default;

--FOR dtir1
SELECT DISTINCT dtir1 FROM bronze.loan_default;

SELECT dtir1
FROM bronze.loan_default
WHERE dtir1 IS NOT NULL
AND dtir1 !~ '^[0-9]+(\.[0-9]+)?$';

SELECT 
	MIN(CAST(dtir1 AS NUMERIC)) AS min_value,
	MAX(CAST(dtir1 AS NUMERIC)) AS max_value,
	AVG(CAST(dtir1 AS NUMERIC)) AS avg_value
FROM bronze.loan_default

SELECT dtir1 FROM bronze.loan_default
WHERE dtir1 IS NOT NULL
ORDER BY dtir1::NUMERIC DESC

SELECT dtir1, COUNT(*) FROM bronze.loan_default
WHERE dtir1 IS NULL
GROUP BY dtir1

--transformation to be performed
SELECT 
CASE 
    WHEN dtir1 IS NULL THEN NULL
    WHEN dtir1::NUMERIC <= 0 THEN NULL
    ELSE dtir1::NUMERIC
END AS debt_to_income_ratio
FROM bronze.loan_default;

--for load_timestamp
SELECT load_timestamp FROM bronze.loan_default
WHERE load_timestamp IS NULL
--transformation to be performed
--no transformation were made

--for source_file
SELECT DISTINCT source_file FROM bronze.loan_default

SELECT source_file FROM bronze.loan_default
WHERE source_file IS NOT NULL

--transformation to be performed
SELECT *,
       'loan_default.csv' AS source_file
FROM bronze.loan_default;




