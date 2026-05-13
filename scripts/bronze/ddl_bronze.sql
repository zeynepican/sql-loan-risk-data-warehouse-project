/*
====================================================
BRONZE LAYER - LOAN DEFAULT TABLE
====================================================

Purpose:
This script creates the Bronze layer table for loan default data ingestion.
All columns are stored as TEXT to ensure raw data is captured without loss.

Design Principles:
- No data transformation at ingestion stage
- Preserve raw data exactly as received
- All columns are stored as TEXT (schema-on-read approach)
- Metadata columns included for traceability

Metadata Columns:
- load_timestamp: records ingestion time
- source_file: tracks origin of the dataset

Warning:
This table is truncated and reloaded during each ETL run.
Do not store business logic or transformed data here.
====================================================
*/

DROP TABLE IF EXISTS bronze.loan_default;
CREATE TABLE bronze.loan_default (
	ID TEXT,
    year TEXT,
    loan_limit TEXT,
    Gender TEXT,
    approv_in_adv TEXT,
    loan_type TEXT,
    loan_purpose TEXT,
    Credit_Worthiness TEXT,
    open_credit TEXT,
    business_or_commercial TEXT,
    loan_amount TEXT,
    rate_of_interest TEXT,
    Interest_rate_spread TEXT,
    Upfront_charges TEXT,
    term TEXT,
    Neg_ammortization TEXT,
    interest_only TEXT,
    lump_sum_payment TEXT,
    property_value TEXT,
    construction_type TEXT,
    occupancy_type TEXT,
    Secured_by TEXT,
    total_units TEXT,
    income TEXT,
    credit_type TEXT,
    Credit_Score TEXT,
    co_applicant_credit_type TEXT,
    age TEXT,
    submission_of_application TEXT,
    LTV TEXT,
    Region TEXT,
    Security_Type TEXT,
    Status TEXT,
    dtir1 TEXT,

	load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  source_file TEXT
);
