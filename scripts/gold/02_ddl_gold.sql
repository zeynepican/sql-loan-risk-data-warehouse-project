/*
================================================================================
GOLD LAYER - DIMENSION & FACT TABLE SCHEMA
================================================================================

Purpose:
This script defines the schema for the Gold layer of the data warehouse.

The Gold layer represents the final analytics-ready data model and consists of:
- Dimension tables (dim_customer, dim_loan, dim_property, etc.)
- A central fact table (fact_loan_application)

Design Principles:
- Star schema modeling approach
- Surrogate keys (BIGSERIAL) for all dimension tables
- Fully normalized dimensions for analytical flexibility
- Referential integrity enforced via foreign keys
- Optimized for BI reporting and analytical queries

Tables Included:
1. dim_customer          -> Customer demographic and income segmentation
2. dim_loan              -> Loan characteristics and classification
3. dim_property          -> Property-related attributes
4. dim_credit_profile    -> Credit behavior segmentation
5. dim_application       -> Loan application structure attributes
6. fact_loan_application -> Central fact table for loan performance analysis

Notes:
- All tables are truncated (with identity restart) and fully reloaded during ETL pipeline execution
- Foreign key relationships ensure data consistency across dimensions

================================================================================
*/

DROP TABLE IF EXISTS gold.dim_customer CASCADE;
CREATE TABLE gold.dim_customer(
	customer_id BIGSERIAL PRIMARY KEY,
	gender TEXT,
	age TEXT,
	co_applicant_credit_type TEXT,
	income_segment TEXT,
	load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	source_file TEXT
);
DROP TABLE IF EXISTS gold.dim_loan CASCADE;
CREATE TABLE gold.dim_loan(
	loan_id BIGSERIAL PRIMARY KEY,
	loan_limit TEXT,
	loan_type TEXT,
	loan_purpose TEXT,
	business_or_commercial TEXT,
	credit_worthiness TEXT,
	open_credit TEXT,
	security_type TEXT,
	load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	source_file TEXT
);
DROP TABLE IF EXISTS gold.dim_property CASCADE;
CREATE TABLE gold.dim_property(
	property_id BIGSERIAL PRIMARY KEY,
	construction_type TEXT,
	occupancy_type TEXT,
	secured_by TEXT,
	total_units TEXT,
	region TEXT,
	load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	source_file TEXT	
);
DROP TABLE IF EXISTS gold.dim_credit_profile CASCADE;
CREATE TABLE gold.dim_credit_profile(
	credit_profile_id BIGSERIAL PRIMARY KEY,
	credit_type TEXT,
	approval_in_advance TEXT,
	submission_of_application TEXT,
	credit_score_segment TEXT,
	load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	source_file TEXT
);
DROP TABLE IF EXISTS gold.dim_application CASCADE;
CREATE TABLE gold.dim_application(
	application_id BIGSERIAL PRIMARY KEY,
	neg_amortization BOOLEAN,
	is_interest_only BOOLEAN,
	is_lump_sum_payment BOOLEAN,
	load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	source_file TEXT
);
DROP TABLE IF EXISTS gold.fact_loan_application CASCADE;
CREATE TABLE gold.fact_loan_application(
	fact_loan_id BIGSERIAL PRIMARY KEY,
	
	loan_amount BIGINT,
	income NUMERIC(18,2),
	rate_of_interest NUMERIC(6,3),
	term INT,
	debt_to_income_ratio NUMERIC(10,4),
	loan_to_value_ratio NUMERIC(10,2),
	credit_score INT,
	property_value NUMERIC(18,2),
	is_default BOOLEAN,
	debt_burden_segment TEXT,
	source_id BIGINT NOT NULL,

	customer_id BIGINT NOT NULL,
	loan_id BIGINT NOT NULL,
	property_id BIGINT NOT NULL,
	credit_profile_id BIGINT NOT NULL,
	application_id BIGINT NOT NULL,
	
	load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	source_file TEXT,

	-- FK constraints
    CONSTRAINT fk_customer
        FOREIGN KEY (customer_id)
        REFERENCES gold.dim_customer(customer_id),

    CONSTRAINT fk_loan
        FOREIGN KEY (loan_id)
        REFERENCES gold.dim_loan(loan_id),

    CONSTRAINT fk_property
        FOREIGN KEY (property_id)
        REFERENCES gold.dim_property(property_id),

    CONSTRAINT fk_credit_profile
        FOREIGN KEY (credit_profile_id)
        REFERENCES gold.dim_credit_profile(credit_profile_id),

    CONSTRAINT fk_application
        FOREIGN KEY (application_id)
        REFERENCES gold.dim_application(application_id)
);
CREATE INDEX idx_fact_loan_customer ON gold.fact_loan_application(customer_id);
CREATE INDEX idx_fact_loan_loan ON gold.fact_loan_application(loan_id);
CREATE INDEX idx_fact_loan_property ON gold.fact_loan_application(property_id);
CREATE INDEX idx_fact_loan_credit ON gold.fact_loan_application(credit_profile_id);
CREATE INDEX idx_fact_loan_application ON gold.fact_loan_application(application_id);
