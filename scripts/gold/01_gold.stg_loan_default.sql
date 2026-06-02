/*
================================================================================
STAGING TABLE: gold.stg_loan_default
================================================================================

Purpose:
This table serves as the staging layer for the Loan Default data pipeline.

It is designed to:
- Store raw data ingested from the Silver layer (silver.loan_default)
- Act as an intermediate transformation layer before Gold-level modeling
- Provide a structured dataset for feature engineering and data cleaning
- Ensure data consistency before loading into dimensional and fact tables

Characteristics:
- Contains raw + lightly standardized loan application data
- Includes identifiers, financial metrics, credit attributes, and target labels
- Supports imputation and feature engineering in downstream procedures

Note:
This table is truncated and fully refreshed during each transformation cycle.
================================================================================
*/
CREATE TABLE gold.stg_loan_default (
    id BIGINT,
    loan_limit TEXT,
    gender TEXT,
    approval_in_advance TEXT,
    loan_type TEXT,
    loan_purpose TEXT,
    credit_worthiness TEXT,
    open_credit TEXT,
    business_or_commercial TEXT,
    loan_amount BIGINT,

    rate_of_interest NUMERIC,
    term INT,
    neg_amortization BOOLEAN,
    is_interest_only BOOLEAN,
    is_lump_sum_payment BOOLEAN,

    property_value NUMERIC(18,2),
    construction_type TEXT,
    occupancy_type TEXT,
    secured_by TEXT,
    total_units TEXT,
    region TEXT,

    income NUMERIC(18,2),
    credit_type TEXT,
    credit_score INT,
    co_applicant_credit_type TEXT,
    age TEXT,
    submission_of_application TEXT,
    loan_to_value_ratio NUMERIC(10,2),
    security_type TEXT,

    is_default BOOLEAN,
    debt_to_income_ratio NUMERIC,

    load_timestamp TIMESTAMP,
    source_file TEXT
);



/*
================================================================================
PROCEDURE: gold.transform_loan_default
================================================================================

Purpose:
This stored procedure performs the transformation of raw loan data from the
Silver layer into a cleaned and feature-engineered staging dataset.

Main Responsibilities:
- Cleans and reloads the staging table (gold.stg_loan_default)
- Performs missing value imputation (income, interest rate)
- Applies statistical transformations and feature engineering
- Computes derived financial metrics such as:
    - Debt-to-income ratio (log-transformed)
- Prepares data for dimensional modeling in the Gold layer

Transformation Logic:
1. Base data extraction from silver.loan_default
2. Interest rate imputation using window functions
3. Income imputation using median aggregation
4. Feature derivation and normalization
5. Final structured dataset insertion into staging layer

Design Principles:
- Fully deterministic transformation
- No use of SELECT *
- Reproducible feature engineering pipeline
- Designed for analytics-ready Gold layer consumption

Output:
- Fully cleaned and enriched staging table: gold.stg_loan_default

Execution:
CALL gold.transform_loan_default();

================================================================================
*/
CREATE OR REPLACE PROCEDURE gold.transform_loan_default()
LANGUAGE plpgsql
AS $$

DECLARE
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_duration INTERVAL;

BEGIN

    v_start_time := clock_timestamp();

    RAISE NOTICE '===========================================';
    RAISE NOTICE 'GOLD TRANSFORMATION STARTED';
    RAISE NOTICE '===========================================';

    ------------------------------------------------------------------
    -- 1. CLEAN STAGING TABLE
    ------------------------------------------------------------------
    TRUNCATE TABLE gold.stg_loan_default;

    ------------------------------------------------------------------
    -- 2. TRANSFORMATION PIPELINE (WITH IMPUTATION & FEATURE ENGINEERING)
    ------------------------------------------------------------------
    WITH rate_impute AS (
        SELECT
            id,
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
            term,
            neg_amortization,
            is_interest_only,
            is_lump_sum_payment,
            property_value,
            construction_type,
            occupancy_type,
            secured_by,
            total_units,
            region,
            income,
            credit_type,
            credit_score,
            co_applicant_credit_type,
            age,
            submission_of_application,
            loan_to_value_ratio,
            security_type,
            is_default,
            debt_to_income_ratio,
            load_timestamp,
            source_file,

            AVG(rate_of_interest) OVER (
                PARTITION BY loan_type, credit_type
            ) AS imputed_rate

        FROM silver.loan_default
    ),

    ------------------------------------------------------------------
    -- STEP 2: INCOME IMPUTATION
    ------------------------------------------------------------------
    income_impute AS (
        SELECT
            loan_type,
            occupancy_type,
            PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY income) AS median_income
        FROM silver.loan_default
        WHERE income IS NOT NULL
        GROUP BY loan_type, occupancy_type
    ),

    ------------------------------------------------------------------
    -- STEP 3: FINAL BASE WITH FINAL INCOME
    ------------------------------------------------------------------
    base AS (
        SELECT
            r.id,
            r.loan_limit,
            r.gender,
            r.approval_in_advance,
            r.loan_type,
            r.loan_purpose,
            r.credit_worthiness,
            r.open_credit,
            r.business_or_commercial,
            r.loan_amount,
            r.rate_of_interest,
            r.imputed_rate,
            r.term,
            r.neg_amortization,
            r.is_interest_only,
            r.is_lump_sum_payment,
            r.property_value,
            r.construction_type,
            r.occupancy_type,
            r.secured_by,
            r.total_units,
            r.region,
            r.income,
            r.credit_type,
            r.credit_score,
            r.co_applicant_credit_type,
            r.age,
            r.submission_of_application,
            r.loan_to_value_ratio,
            r.security_type,
            r.is_default,
            r.debt_to_income_ratio,
            r.load_timestamp,
            r.source_file,
            i.median_income,
            COALESCE(r.income, i.median_income) AS final_income
        FROM rate_impute r
        LEFT JOIN income_impute i
            ON r.loan_type = i.loan_type
           AND r.occupancy_type = i.occupancy_type
    )

    ------------------------------------------------------------------
    -- STEP 4: INSERT INTO STAGING LAYERS WITH DERIVED FEATURES
    ------------------------------------------------------------------
    INSERT INTO gold.stg_loan_default
    (
        id, loan_limit, gender, approval_in_advance, loan_type, loan_purpose,
        credit_worthiness, open_credit, business_or_commercial, loan_amount,
        rate_of_interest, term, neg_amortization, is_interest_only, is_lump_sum_payment,
        property_value, construction_type, occupancy_type, secured_by, total_units, region,
        income, credit_type, credit_score, co_applicant_credit_type, age,
        submission_of_application, loan_to_value_ratio, security_type, is_default,
        debt_to_income_ratio, load_timestamp, source_file
    )
    SELECT
        id,
        loan_limit,
        gender,
        approval_in_advance,
        loan_type,
        loan_purpose,
        credit_worthiness,
        open_credit,
        business_or_commercial,
        loan_amount,
        COALESCE(rate_of_interest, imputed_rate) AS rate_of_interest,
        term,
        neg_amortization,
        is_interest_only,
        is_lump_sum_payment,
        property_value,
        construction_type,
        occupancy_type,
        secured_by,
        total_units,
        region,
        final_income AS income,
        credit_type,
        credit_score,
        co_applicant_credit_type,
        age,
        submission_of_application,
        loan_to_value_ratio,
        security_type,
        is_default,
        CASE
            WHEN final_income = 0 THEN NULL
            ELSE LN(loan_amount::numeric / final_income)
        END AS debt_to_income_ratio,
        load_timestamp,
        source_file
    FROM base;

    ------------------------------------------------------------------
    -- 3. END LOGGING
    ------------------------------------------------------------------
    v_end_time := clock_timestamp();
    v_duration := v_end_time - v_start_time;

    RAISE NOTICE '===========================================';
    RAISE NOTICE 'TRANSFORMATION COMPLETED';
    RAISE NOTICE 'Start: %', v_start_time;
    RAISE NOTICE 'End: %', v_end_time;
    RAISE NOTICE 'Duration: %', v_duration;
    RAISE NOTICE 'Rows: %', (SELECT COUNT(*) FROM gold.stg_loan_default);
    RAISE NOTICE '===========================================';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'ERROR: %', SQLERRM;
        RAISE;

END;
$$;

--for call the procedure:
CALL gold.transform_loan_default()



