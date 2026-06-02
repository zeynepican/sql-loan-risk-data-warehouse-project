/*
================================================================================
GOLD LAYER - LOAN DATA TRANSFORMATION PROCEDURE
================================================================================

Purpose:
This stored procedure is responsible for transforming and loading data from the
staging layer (gold.stg_loan_default) into the Gold layer of the data warehouse.

It performs the following operations:
- Clears and reloads all Gold dimension tables (Customer, Loan, Property,
  Credit Profile, Application)
- Performs data standardization and business rule-based transformations
  (e.g., income segmentation, credit risk segmentation)
- Enriches raw loan application data by joining dimension tables
- Calculates derived analytical fields such as debt-to-income ratio and
  debt burden segmentation
- Builds the final fact table (fact_loan_application) for analytical reporting

Key Design Features:
- Fully automated ETL pipeline for Gold layer refresh
- Surrogate key-based star schema integration
- Consistent business rule logic across dimensions and fact table
- Traceability through source_id and source_file fields

Business Outcome:
This procedure prepares analytics-ready loan data optimized for reporting,
risk analysis, and machine learning use cases.

================================================================================
*/

CREATE OR REPLACE PROCEDURE gold.load_loan_default_gold()
LANGUAGE plpgsql
AS $$

DECLARE
	v_start_time TIMESTAMP;
	v_end_time TIMESTAMP;
	v_duration INTERVAL;

BEGIN

	v_start_time:=clock_timestamp();

	RAISE NOTICE '==============================================================';
	RAISE NOTICE 'Loading Gold Layer Started';
	RAISE NOTICE '==============================================================';

	RAISE NOTICE '>>Truncating Table: gold.dim_customer';
	TRUNCATE TABLE gold.dim_customer RESTART IDENTITY CASCADE;
	RAISE NOTICE '>> Inserting Data Into: gold.dim_customer';

	WITH base_customer AS (
		SELECT DISTINCT
		s.gender,
		s.age,
		s.co_applicant_credit_type,
		CASE
			WHEN s.income < 3000 THEN 'low_income'
			WHEN s.income BETWEEN 3000 AND 70000 THEN 'middle_income'
			ELSE 'high_income'
		END AS income_segment,
		s.source_file
		FROM gold.stg_loan_default s
	)
	
	INSERT INTO gold.dim_customer (
		gender,
		age,
		co_applicant_credit_type,
		income_segment,
		source_file,
		load_timestamp
	)
	SELECT
		gender,
		age,
		co_applicant_credit_type,
		income_segment,
		source_file,
		CURRENT_TIMESTAMP
		FROM base_customer;

    RAISE NOTICE '>>Truncating Table: gold.dim_loan';
	TRUNCATE TABLE gold.dim_loan RESTART IDENTITY CASCADE;
	RAISE NOTICE '>> Inserting Data Into: gold.dim_loan';

	WITH base_loan AS (
		SELECT DISTINCT
		s.loan_limit,
		s.loan_type,
		s.loan_purpose,
		s.business_or_commercial,
		s.credit_worthiness,
		s.open_credit,
		s.security_type,
		s.source_file
		FROM gold.stg_loan_default s
	)
	
	INSERT INTO gold.dim_loan (
		loan_limit,
		loan_type,
		loan_purpose,
		business_or_commercial,
		credit_worthiness,
		open_credit,
		security_type,
		load_timestamp,
		source_file
	)
	SELECT
		loan_limit,
		loan_type,
		loan_purpose,
		business_or_commercial,
		credit_worthiness,
		open_credit,
		security_type,
		CURRENT_TIMESTAMP,
		source_file
		FROM base_loan;

	
    RAISE NOTICE '>>Truncating Table: gold.dim_property';
	TRUNCATE TABLE gold.dim_property RESTART IDENTITY CASCADE;
	RAISE NOTICE '>> Inserting Data Into: gold.dim_property';

		WITH base_property AS (
			SELECT DISTINCT 
			s.construction_type,
			s.occupancy_type,
			s.secured_by,
			s.total_units,
			s.region,
			s.source_file
			FROM gold.stg_loan_default s
		)
	
	INSERT INTO gold.dim_property (
		construction_type,
		occupancy_type,
		secured_by,
		total_units,
		region,
		source_file,
		load_timestamp
	)
	SELECT
		construction_type,
		occupancy_type,
		secured_by,
		total_units,
		region,
		source_file,
		CURRENT_TIMESTAMP
	FROM base_property;
	
    RAISE NOTICE '>>Truncating Table: gold.dim_credit_profile';
	TRUNCATE TABLE gold.dim_credit_profile RESTART IDENTITY CASCADE;
	RAISE NOTICE '>> Inserting Data Into: gold.dim_credit_profile';

	WITH base_credit AS (
		SELECT DISTINCT
		s.credit_type,
		s.approval_in_advance,
		s.submission_of_application,
		CASE
			WHEN s.credit_score >= 750 THEN 'low_risk'
			WHEN s.credit_score >= 600 THEN 'medium_risk'
			ELSE 'high_risk'
		END AS credit_score_segment,
		s.source_file
		FROM gold.stg_loan_default s
	)
	
	INSERT INTO gold.dim_credit_profile (
		credit_type,
		approval_in_advance,
		submission_of_application,
		credit_score_segment,
		load_timestamp,
		source_file
	)
	SELECT
		credit_type,
		approval_in_advance,
		submission_of_application,
		credit_score_segment,
		CURRENT_TIMESTAMP,
		source_file
	FROM base_credit;

	RAISE NOTICE '>>Truncating Table: gold.dim_application';
	TRUNCATE TABLE gold.dim_application RESTART IDENTITY CASCADE;
	RAISE NOTICE '>> Inserting Data Into: gold.dim_application';

	INSERT INTO gold.dim_application (
    neg_amortization,
    is_interest_only,
    is_lump_sum_payment,
    load_timestamp,
    source_file
)
SELECT DISTINCT
    CASE 
        WHEN s.neg_amortization IS NULL THEN 'UNKNOWN'
        WHEN s.neg_amortization = true THEN 'TRUE'
        ELSE 'FALSE'
    END AS neg_amortization,

    CASE 
        WHEN s.is_interest_only IS NULL THEN 'UNKNOWN'
        WHEN s.is_interest_only = true THEN 'TRUE'
        ELSE 'FALSE'
    END AS is_interest_only,

    CASE 
        WHEN s.is_lump_sum_payment IS NULL THEN 'UNKNOWN'
        WHEN s.is_lump_sum_payment = true THEN 'TRUE'
        ELSE 'FALSE'
    END AS is_lump_sum_payment,

    CURRENT_TIMESTAMP,
    s.source_file
FROM gold.stg_loan_default s;
	
    RAISE NOTICE '>>Truncating Table: gold.fact_loan_application';
	TRUNCATE TABLE gold.fact_loan_application RESTART IDENTITY CASCADE;
	RAISE NOTICE '>> Inserting Data Into: gold.fact_loan_application';

	WITH enriched AS (
        SELECT
            s.id,
		    s.loan_limit,
		    s.gender,
		    s.approval_in_advance,
		    s.loan_type,
		    s.loan_purpose,
		    s.credit_worthiness,
		    s.open_credit,
		    s.business_or_commercial,
		    s.loan_amount,
		
		    s.rate_of_interest,
		    s.term,
		    s.neg_amortization,
		    s.is_interest_only,
		    s.is_lump_sum_payment,
		
		    s.property_value,
		    s.construction_type,
		    s.occupancy_type,
		    s.secured_by,
		    s.total_units,
		    s.region,
		
		    s.income,
		    s.credit_type,
		    s.credit_score,
		    s.co_applicant_credit_type,
		    s.age,
		    s.submission_of_application,
		    s.loan_to_value_ratio,
		    s.security_type,
		
		    s.is_default,
		    s.debt_to_income_ratio,
		
		    s.load_timestamp,
		    s.source_file,


            dc.customer_id,
            dl.loan_id,
            dp.property_id,
            dcp.credit_profile_id,
            da.application_id

        FROM gold.stg_loan_default s
		
	LEFT JOIN gold.dim_customer dc
            ON s.gender = dc.gender
           AND s.age = dc.age
           AND s.co_applicant_credit_type = dc.co_applicant_credit_type
           AND CASE
                WHEN s.income < 3000 THEN 'low_income'
                WHEN s.income BETWEEN 3000 AND 70000 THEN 'middle_income'
                ELSE 'high_income'
               END = dc.income_segment

        LEFT JOIN gold.dim_loan dl
            ON s.loan_limit = dl.loan_limit
           AND s.loan_type = dl.loan_type
           AND s.loan_purpose = dl.loan_purpose
		   AND s.business_or_commercial = dl.business_or_commercial 
		   AND s.credit_worthiness = dl.credit_worthiness
		   AND s.open_credit = dl.open_credit
		   AND s.security_type = dl.security_type

        LEFT JOIN gold.dim_property dp
            ON s.construction_type = dp.construction_type
           AND s.occupancy_type = dp.occupancy_type
		   AND s.secured_by = dp.secured_by
		   AND s.total_units = dp.total_units
           AND s.region = dp.region	
		   
		LEFT JOIN gold.dim_credit_profile dcp
	        ON s.credit_type = dcp.credit_type
		   AND s.approval_in_advance = dcp.approval_in_advance
		   AND s.submission_of_application = dcp.submission_of_application
	        AND CASE
	            WHEN s.credit_score >= 750 THEN 'low_risk'
	            WHEN s.credit_score >= 600 THEN 'medium_risk'
	            ELSE 'high_risk'
	            END = dcp.credit_score_segment

        LEFT JOIN gold.dim_application da
    ON CASE 
        WHEN s.neg_amortization IS NULL THEN 'UNKNOWN'
        WHEN s.neg_amortization = true THEN 'TRUE'
        ELSE 'FALSE'
       END = da.neg_amortization

AND CASE 
        WHEN s.is_interest_only IS NULL THEN 'UNKNOWN'
        WHEN s.is_interest_only = true THEN 'TRUE'
        ELSE 'FALSE'
    END = da.is_interest_only

AND CASE 
        WHEN s.is_lump_sum_payment IS NULL THEN 'UNKNOWN'
        WHEN s.is_lump_sum_payment = true THEN 'TRUE'
        ELSE 'FALSE'
    END = da.is_lump_sum_payment
    )

	 INSERT INTO gold.fact_loan_application (
        loan_amount,
        income,
        rate_of_interest,
        term,
        debt_to_income_ratio,
        loan_to_value_ratio,
        credit_score,
        property_value,
        is_default,
        debt_burden_segment,
		source_id,

        customer_id,
        loan_id,
        property_id,
        credit_profile_id,
        application_id,

        source_file,
        load_timestamp
    )

	SELECT
        loan_amount,
        income,
        rate_of_interest,
        term,
        debt_to_income_ratio,
        loan_to_value_ratio,
        credit_score,
        property_value,
        is_default,

        CASE
            WHEN debt_to_income_ratio < 3.63 THEN 'low'
            WHEN debt_to_income_ratio < 4.27 THEN 'medium'
            ELSE 'high'
        END AS debt_burden_segment,
		 id AS source_id,

        customer_id,
        loan_id,
        property_id,
        credit_profile_id,
        application_id,

        source_file,
        CURRENT_TIMESTAMP
    FROM enriched;

	
	v_end_time:= clock_timestamp();
	v_duration:= v_end_time - v_start_time;

	RAISE NOTICE '=================================================';
	RAISE NOTICE 'Loading Completed';
	RAISE NOTICE 'Start Time: %', v_start_time;
	RAISE NOTICE 'End Time: %', v_end_time;
	RAISE NOTICE 'Duration: %', v_duration;
	RAISE NOTICE '=================================================';
	RAISE NOTICE 'Rows Loaded: %', (SELECT COUNT(*) FROM gold.stg_loan_default);
EXCEPTION
	WHEN OTHERS THEN
		RAISE NOTICE 'Error occured: %', SQLERRM;
		RAISE;
END;
$$;

 CALL gold.load_loan_default_gold();


	
