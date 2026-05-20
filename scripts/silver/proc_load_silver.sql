/*
===============================================================================
PROCEDURE : silver.load_loan_default_silver

PURPOSE
- Loads and transforms data from bronze.loan_default into silver.loan_default

PROCESS
- Truncates target silver table
- Reads raw data from bronze layer
- Cleans and standardizes fields (trim, null handling, case normalization)
- Converts categorical codes to business-readable values
- Applies numeric and boolean type casting with basic validation
- Loads transformed dataset into silver layer

RULES APPLIED
- Empty strings converted to NULL
- Negative or invalid numeric values handled per field rules
- Invalid categorical values mapped to 'n/a'
- Data types enforced according to silver schema

USAGE
- Executed via: CALL silver.load_loan_default_silver();

LOAD TYPE
- Full refresh (TRUNCATE + INSERT)
===============================================================================
*/


CREATE OR REPLACE PROCEDURE silver.load_loan_default_silver() 
LANGUAGE plpgsql
AS $$

DECLARE 
	v_start_time TIMESTAMP;
	v_end_time   TIMESTAMP;
	v_duration   INTERVAL;
	
 BEGIN 

	 v_start_time:=clock_timestamp();
	 
        RAISE NOTICE '================================================';
        RAISE NOTICE 'Loading Silver Layer Started';
        RAISE NOTICE '================================================';


		RAISE NOTICE '>> Truncating Table: silver.loan_default';
		TRUNCATE TABLE silver.loan_default;
		
		RAISE NOTICE '>> Inserting Data Into: silver.loan_default';
		
    INSERT INTO silver.loan_default (
        id,
	    year,
	    loan_limit,
	    gender,
	    approval_in_advance,
	    loan_type,
	    loan_purpose,
	    credit_worthiness,
	    open_credit,
	    business_or_commercial,
	    loan_amount,
	    rate_of_interest,
	    interest_rate_spread,
	    upfront_charges,
	    term,
	    neg_amortization,
	    is_interest_only,
	    is_lump_sum_payment,
	    property_value,
	    construction_type,
	    occupancy_type,
	    secured_by,
	    total_units,
	    income,
	    credit_type,
	    credit_score,
	    co_applicant_credit_type,
	    age,
	    submission_of_application,
	    loan_to_value_ratio,
	    region,
	    security_type,
	    is_default,
	    debt_to_income_ratio,
	  	load_timestamp,
	  	source_file 
    )

    SELECT
       NULLIF(TRIM(id), '')::BIGINT,

       NULLIF(TRIM(year), '')::SMALLINT,

        CASE 
            WHEN LOWER(TRIM(loan_limit)) = 'cf' THEN 'conforming'
            WHEN LOWER(TRIM(loan_limit)) = 'ncf' THEN 'nonconforming'
            ELSE 'n/a'
        END,

        CASE 
            WHEN LOWER(TRIM(gender)) = 'female' THEN 'female'
            WHEN LOWER(TRIM(gender)) = 'male' THEN 'male'
            WHEN LOWER(TRIM(gender)) = 'joint' THEN 'joint'
            ELSE 'n/a'
        END,

        CASE 
            WHEN LOWER(TRIM(approv_in_adv)) = 'pre' THEN 'pre_approved'
            WHEN LOWER(TRIM(approv_in_adv)) = 'nopre' THEN 'not_pre_approved'
            ELSE 'n/a'
        END AS approval_in_advance,

        CASE 
            WHEN LOWER(TRIM(loan_type)) = 'type1' THEN 'type1'
            WHEN LOWER(TRIM(loan_type)) = 'type2' THEN 'type2'
            WHEN LOWER(TRIM(loan_type)) = 'type3' THEN 'type3'
            ELSE 'n/a'
        END,

        CASE 
            WHEN LOWER(TRIM(loan_purpose)) = 'p1' THEN 'p1'
            WHEN LOWER(TRIM(loan_purpose)) = 'p2' THEN 'p2'
            WHEN LOWER(TRIM(loan_purpose)) = 'p3' THEN 'p3'
            WHEN LOWER(TRIM(loan_purpose)) = 'p4' THEN 'p4'
            ELSE 'n/a'
        END,

        CASE 
            WHEN LOWER(TRIM(credit_worthiness)) = 'l1' THEN 'l1'
            WHEN LOWER(TRIM(credit_worthiness)) = 'l2' THEN 'l2'
            ELSE 'n/a'
        END,

        CASE 
            WHEN LOWER(TRIM(open_credit)) = 'opc' THEN 'open_credit'
            WHEN LOWER(TRIM(open_credit)) = 'nopc' THEN 'no_open_credit'
            ELSE 'n/a'
        END,

        CASE 
            WHEN LOWER(TRIM(business_or_commercial)) = 'b/c' THEN 'business_commercial'
            WHEN LOWER(TRIM(business_or_commercial)) = 'nob/c' THEN 'non_business_commercial'
            ELSE 'n/a'
        END AS business_or_commercial,

        CASE 
            WHEN NULLIF(TRIM(loan_amount), '') IS NULL THEN NULL
            WHEN NULLIF(TRIM(loan_amount), '')::NUMERIC < 0 THEN 0
            ELSE NULLIF(TRIM(loan_amount), '')::NUMERIC
        END ::BIGINT,

        CASE 
            WHEN NULLIF(TRIM(rate_of_interest), '') IS NULL THEN NULL
            WHEN NULLIF(TRIM(rate_of_interest), '')::NUMERIC < 0 THEN NULL
            ELSE NULLIF(TRIM(rate_of_interest), '')::NUMERIC
        END::NUMERIC(5,2),

		NULLIF(TRIM(interest_rate_spread), '')::NUMERIC(10,3),

		NULLIF(TRIM(upfront_charges), '')::NUMERIC(10,2),

        CASE 
            WHEN NULLIF(TRIM(term), '') IS NULL THEN NULL
            WHEN NULLIF(TRIM(term), '')::NUMERIC <= 0 THEN NULL
            ELSE NULLIF(TRIM(term), '')::NUMERIC
        END::INTEGER,

        CASE 
            WHEN LOWER(TRIM(neg_ammortization)) = 'neg_amm' THEN true
            WHEN LOWER(TRIM(neg_ammortization)) = 'not_neg' THEN false
            ELSE NULL
        END::BOOLEAN,

        CASE 
            WHEN LOWER(TRIM(interest_only)) = 'int_only' THEN true
            WHEN LOWER(TRIM(interest_only)) = 'not_int' THEN false
			ELSE NULL
        END::BOOLEAN,

        CASE 
            WHEN LOWER(TRIM(lump_sum_payment)) = 'lpsm' THEN true
            WHEN LOWER(TRIM(lump_sum_payment)) = 'not_lpsm' THEN false
			ELSE NULL
        END::BOOLEAN,

        CASE 
            WHEN NULLIF(TRIM(property_value), '') IS NULL THEN NULL
            WHEN NULLIF(TRIM(property_value), '')::NUMERIC <= 0 THEN NULL
            ELSE NULLIF(TRIM(property_value), '')::NUMERIC
		END::NUMERIC(18,2),

        CASE 
            WHEN LOWER(TRIM(construction_type)) = 'mh' THEN 'manufactured_home'
            WHEN LOWER(TRIM(construction_type)) = 'sb' THEN 'site_built'
            ELSE 'n/a'
        END,

        CASE 
            WHEN LOWER(TRIM(occupancy_type)) = 'pr' THEN 'primary_residence'
            WHEN LOWER(TRIM(occupancy_type)) = 'ir' THEN 'investment_residence'
            WHEN LOWER(TRIM(occupancy_type)) = 'sr' THEN 'secondary_residence'
            ELSE 'n/a'
        END,

        CASE 
            WHEN LOWER(TRIM(secured_by)) = 'home' THEN 'home'
            WHEN LOWER(TRIM(secured_by)) = 'land' THEN 'land'
            ELSE 'n/a'
        END,

       CASE 
           WHEN LOWER(TRIM(total_units)) IN ('1u','2u','3u','4u') 
           THEN LOWER(TRIM(total_units))
           ELSE 'n/a'
        END,

        CASE 
            WHEN NULLIF(TRIM(income), '') IS NULL THEN NULL
            WHEN NULLIF(TRIM(income), '')::NUMERIC <= 0 THEN NULL
            ELSE NULLIF(TRIM(income), '')::NUMERIC
         END::NUMERIC(18,2),

        CASE 
            WHEN UPPER(TRIM(credit_type)) = 'CIB' THEN 'credit_information_bureau'
            WHEN UPPER(TRIM(credit_type)) = 'CRIF' THEN 'crif_credit_bureau'
            WHEN UPPER(TRIM(credit_type)) = 'EQUI' THEN 'equifax'
            WHEN UPPER(TRIM(credit_type)) = 'EXP' THEN 'experian'
            ELSE 'n/a'
        END,

        CASE 
            WHEN NULLIF(TRIM(credit_score), '') IS NULL THEN NULL
            WHEN NULLIF(TRIM(credit_score), '')::INTEGER <= 0 THEN NULL
            ELSE NULLIF(TRIM(credit_score), '')::INTEGER
         END::INTEGER,

        CASE 
            WHEN UPPER(TRIM(co_applicant_credit_type)) = 'CIB' THEN 'credit_information_bureau'
            WHEN UPPER(TRIM(co_applicant_credit_type)) = 'EXP' THEN 'experian'
			ELSE 'n/a'
        END,

        CASE 
            WHEN age = '<25' THEN '<25'
            WHEN age = '25-34' THEN '25-34'
            WHEN age = '35-44' THEN '35-44'
            WHEN age = '45-54' THEN '45-54'
            WHEN age = '55-64' THEN '55-64'
            WHEN age = '65-74' THEN '65-74'
            WHEN age = '>74' THEN '>74'
            ELSE 'n/a'
        END,

        CASE 
            WHEN LOWER(TRIM(submission_of_application)) = 'to_inst' THEN 'through_institution'
            WHEN LOWER(TRIM(submission_of_application)) = 'not_inst' THEN 'not_through_institution'
            ELSE 'n/a'
        END,

		CASE 
            WHEN NULLIF(TRIM(ltv), '') IS NULL THEN NULL
            WHEN NULLIF(TRIM(ltv), '')::NUMERIC <= 0 THEN NULL
            ELSE NULLIF(TRIM(ltv), '')::NUMERIC
         END::NUMERIC(10,2) AS loan_to_value_ratio,

        CASE 
            WHEN LOWER(TRIM(region)) = 'north' THEN 'north'
            WHEN LOWER(TRIM(region)) = 'south' THEN 'south'
            WHEN LOWER(TRIM(region)) = 'central' THEN 'central'
            WHEN LOWER(TRIM(region)) = 'north-east' THEN 'north_east'
            ELSE 'n/a'
        END,

        CASE 
            WHEN LOWER(TRIM(security_type)) = 'direct' THEN 'direct'
            WHEN LOWER(TRIM(security_type)) IN ('indriect','indirect') THEN 'indirect'
            ELSE 'n/a'
        END,

        CASE 
			WHEN NULLIF(TRIM(status), '') IS NULL THEN NULL
            WHEN NULLIF(TRIM(status), '')::INTEGER = 1 THEN true
            WHEN NULLIF(TRIM(status), '')::INTEGER = 0 THEN false
			ELSE NULL
        END::BOOLEAN AS is_default,

        CASE 
            WHEN NULLIF(TRIM(dtir1), '')::NUMERIC IS NULL THEN NULL
			WHEN NULLIF(TRIM(dtir1), '')::NUMERIC <= 0 THEN NULL
            ELSE NULLIF(TRIM(dtir1), '')::NUMERIC
			END::NUMERIC AS debt_to_income_ratio,
       

		clock_timestamp(),
       'loan_default.csv'

    FROM bronze.loan_default;
	
   v_end_time:= clock_timestamp();
   v_duration:= v_end_time - v_start_time;

	RAISE NOTICE '================================================';
	RAISE NOTICE 'Loading Completed';
	RAISE NOTICE 'Start Time: %', v_start_time;
	RAISE NOTICE 'End Time: %', v_end_time;
	RAISE NOTICE 'Duration: %', v_duration;
	RAISE NOTICE '================================================';
	RAISE NOTICE 'Rows Loaded: %', (SELECT COUNT(*) FROM silver.loan_default);
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error occurred: %', SQLERRM;
        RAISE;
END;
$$;


