# Data Catalog for Gold Layer

## Overview

The Gold Layer represents the final business-ready data model of the data warehouse. It is designed to support reporting, dashboarding, ad-hoc analysis, and downstream analytics workloads. The layer follows a star schema design consisting of dimension tables and a central fact table. Business rules, derived attributes, and analytical classifications are integrated during the ETL process to provide a consistent and trusted source of data for end users.

---

### 1. gold.dim_customer

* **Purpose:** Stores customer demographic information and income segmentation used for loan risk and customer analysis.
* **Columns:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| customer_id | BIGSERIAL | Surrogate primary key |
| gender | TEXT | Customer gender |
| age | TEXT | Customer age group |
| co_applicant_credit_type | TEXT | Co-applicant credit type |
| income_segment | TEXT | Derived income classification |
| load_timestamp | TIMESTAMP | ETL load timestamp |
| source_file | TEXT | Source file name |

---

### 2. gold.dim_loan

* **Purpose:** Stores loan-related attributes and classifications used for loan portfolio analysis.
* **Columns:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| loan_id | BIGSERIAL | Surrogate primary key |
| loan_limit | TEXT | Loan limit category |
| loan_type | TEXT | Type of loan |
| loan_purpose | TEXT | Purpose of the loan |
| business_or_commercial | TEXT | Business or commercial loan indicator |
| credit_worthiness | TEXT | Borrower creditworthiness category |
| open_credit | TEXT | Open credit indicator |
| security_type | TEXT | Type of loan security |
| load_timestamp | TIMESTAMP | ETL load timestamp |
| source_file | TEXT | Source file name |

---

### 3. gold.dim_property

* **Purpose:** Stores property characteristics associated with loan applications.
* **Columns:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| property_id | BIGSERIAL | Surrogate primary key |
| construction_type | TEXT | Property construction type |
| occupancy_type | TEXT | Occupancy classification |
| secured_by | TEXT | Security ownership type |
| total_units | TEXT | Number of units |
| region | TEXT | Geographic region |
| load_timestamp | TIMESTAMP | ETL load timestamp |
| source_file | TEXT | Source file name |

---

### 4. gold.dim_credit_profile

* **Purpose:** Stores customer credit profile attributes and derived credit risk segments.
* **Columns:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| credit_profile_id | BIGSERIAL | Surrogate primary key |
| credit_type | TEXT | Credit type |
| approval_in_advance | TEXT | Advance approval indicator |
| submission_of_application | TEXT | Application submission method |
| credit_score_segment | TEXT | Derived credit risk segment |
| load_timestamp | TIMESTAMP | ETL load timestamp |
| source_file | TEXT | Source file name |

---

### 5. gold.dim_application

* **Purpose:** Stores application-level loan structure characteristics.
* **Columns:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| application_id | BIGSERIAL | Surrogate primary key |
| neg_amortization | TEXT | Negative amortization indicator |
| is_interest_only | TEXT | Interest-only payment indicator |
| is_lump_sum_payment | TEXT | Lump-sum payment indicator |
| load_timestamp | TIMESTAMP | ETL load timestamp |
| source_file | TEXT | Source file name |

---

### 6. gold.fact_loan_application

* **Purpose:** Central fact table containing loan application measures, performance indicators, and foreign key references to all analytical dimensions.
* **Columns:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| fact_loan_id | BIGSERIAL | Fact table primary key |
| source_id | BIGINT | Original source record identifier |
| loan_amount | BIGINT | Requested loan amount |
| income | NUMERIC(18,2) | Applicant income |
| rate_of_interest | NUMERIC(6,3) | Interest rate |
| term | INT | Loan term |
| debt_to_income_ratio | NUMERIC(10,4) | Debt-to-income ratio |
| loan_to_value_ratio | NUMERIC(10,2) | Loan-to-value ratio |
| credit_score | INT | Applicant credit score |
| property_value | NUMERIC(18,2) | Property value |
| is_default | BOOLEAN | Loan default indicator |
| debt_burden_segment | TEXT | Derived debt burden classification |
| customer_id | BIGINT | Foreign key to dim_customer |
| loan_id | BIGINT | Foreign key to dim_loan |
| property_id | BIGINT | Foreign key to dim_property |
| credit_profile_id | BIGINT | Foreign key to dim_credit_profile |
| application_id | BIGINT | Foreign key to dim_application |
| load_timestamp | TIMESTAMP | ETL load timestamp |
| source_file | TEXT | Source file name |

---

## Relationships

The Gold Layer follows a star schema model where `fact_loan_application` connects directly to all dimension tables:
* `fact_loan_application.customer_id` -> `dim_customer.customer_id`
* `fact_loan_application.loan_id` -> `dim_loan.loan_id`
* `fact_loan_application.property_id` -> `dim_property.property_id`
* `fact_loan_application.credit_profile_id` -> `dim_credit_profile.credit_profile_id`
* `fact_loan_application.application_id` -> `dim_application.application_id`

This structure enables efficient analytical querying, reporting, and dashboard development while maintaining dimensional consistency across the warehouse.
