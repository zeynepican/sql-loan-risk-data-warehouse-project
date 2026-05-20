/*
====================================================
SILVER LAYER - LOAN DEFAULT TABLE
====================================================

Purpose:
This script creates the silver layer tables needed to store the transformed data from the bronze layer, 
where the raw data is stored, in the silver layer.
====================================================
*/
DROP TABLE IF EXISTS silver.loan_default;

CREATE TABLE silver.loan_default (
    id BIGINT,
    year SMALLINT,
    loan_limit TEXT,
    gender TEXT,
    approval_in_advance TEXT,
    loan_type TEXT,
    loan_purpose TEXT,
    credit_worthiness TEXT,
    open_credit TEXT,
    business_or_commercial TEXT,
    loan_amount BIGINT,
    rate_of_interest NUMERIC(5,2),
    interest_rate_spread NUMERIC(10,3),
    upfront_charges NUMERIC(10,2),
    term INTEGER,
    neg_ammortization BOOLEAN,
    is_interest_only BOOLEAN,
    is_lump_sum_payment BOOLEAN,
    property_value NUMERIC(18,2),
    construction_type TEXT,
    occupancy_type TEXT,
    secured_by TEXT,
    total_units TEXT,
    income NUMERIC(18,2),
    credit_type TEXT,
    credit_score INTEGER,
    co_applicant_credit_type TEXT,
    age TEXT,
    submission_of_application TEXT,
    loan_to_value_ratio NUMERIC(10,2),
    region TEXT,
    security_type TEXT,
    is_default BOOLEAN,
    debt_to_income_ratio NUMERIC,

  	load_timestamp TIMESTAMP DEFAULT clock_timestamp(),
  	source_file TEXT
);
