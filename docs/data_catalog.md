# Data Catalog for Gold Layer

## Overview

[cite_start]The Gold Layer represents the final business-ready data model of the data warehouse[cite: 3]. [cite_start]It is designed to support reporting, dashboarding, ad-hoc analysis, and downstream analytics workloads[cite: 4]. [cite_start]The layer follows a star schema design consisting of dimension tables and a central fact table[cite: 5]. [cite_start]Business rules, derived attributes, and analytical classifications are integrated during the ETL process to provide a consistent and trusted source of data for end users[cite: 6].

---

### 1. gold.dim_customer

* [cite_start]**Purpose:** Stores customer demographic information and income segmentation used for loan risk and customer analysis[cite: 9].
* **Columns:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| customer_id | BIGSERIAL | [cite_start]Surrogate primary key [cite: 11] |
| gender | TEXT | [cite_start]Customer gender [cite: 11] |
| age | TEXT | [cite_start]Customer age group [cite: 11] |
| co_applicant_credit_type | TEXT | [cite_start]Co-applicant credit type [cite: 11] |
| income_segment | TEXT | [cite_start]Derived income classification [cite: 11] |
| load_timestamp | TIMESTAMP | [cite_start]ETL load timestamp [cite: 11] |
| source_file | TEXT | [cite_start]Source file name [cite: 11] |

---

### 2. gold.dim_loan

* [cite_start]**Purpose:** Stores loan-related attributes and classifications used for loan portfolio analysis[cite: 14].
* **Columns:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| loan_id | BIGSERIAL | [cite_start]Surrogate primary key [cite: 17] |
| loan_limit | TEXT | [cite_start]Loan limit category [cite: 17] |
| loan_type | TEXT | [cite_start]Type of loan [cite: 17] |
| loan_purpose | TEXT | [cite_start]Purpose of the loan [cite: 17] |
| business_or_commercial | TEXT | [cite_start]Business or commercial loan indicator [cite: 17] |
| credit_worthiness | TEXT | [cite_start]Borrower creditworthiness category [cite: 17] |
| open_credit | TEXT | [cite_start]Open credit indicator [cite: 17] |
| security_type | TEXT | [cite_start]Type of loan security [cite: 17] |
| load_timestamp | TIMESTAMP | [cite_start]ETL load timestamp [cite: 17] |
| source_file | TEXT | [cite_start]Source file name [cite: 17] |

---

### 3. gold.dim_property

* [cite_start]**Purpose:** Stores property characteristics associated with loan applications[cite: 20].
* **Columns:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| property_id | BIGSERIAL | [cite_start]Surrogate primary key  |
| construction_type | TEXT | [cite_start]Property construction type  |
| occupancy_type | TEXT | [cite_start]Occupancy classification  |
| secured_by | TEXT | [cite_start]Security ownership type  |
| total_units | TEXT | [cite_start]Number of units  |
| region | TEXT | [cite_start]Geographic region  |
| load_timestamp | TIMESTAMP | [cite_start]ETL load timestamp  |
| source_file | TEXT | [cite_start]Source file name  |

---

### 4. gold.dim_credit_profile

* [cite_start]**Purpose:** Stores customer credit profile attributes and derived credit risk segments[cite: 26].
* **Columns:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| credit_profile_id | BIGSERIAL | [cite_start]Surrogate primary key [cite: 28] |
| credit_type | TEXT | [cite_start]Credit type [cite: 28] |
| approval_in_advance | TEXT | [cite_start]Advance approval indicator [cite: 28] |
| submission_of_application | TEXT | [cite_start]Application submission method [cite: 28] |
| credit_score_segment | TEXT | [cite_start]Derived credit risk segment [cite: 28] |
| load_timestamp | TIMESTAMP | [cite_start]ETL load timestamp [cite: 28] |
| source_file | TEXT | [cite_start]Source file name [cite: 28] |

---

### 5. gold.dim_application

* [cite_start]**Purpose:** Stores application-level loan structure characteristics[cite: 31].
* **Columns:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| application_id | BIGSERIAL | [cite_start]Surrogate primary key [cite: 33] |
| neg_amortization | TEXT | [cite_start]Negative amortization indicator [cite: 33] |
| is_interest_only | TEXT | [cite_start]Interest-only payment indicator [cite: 33] |
| is_lump_sum_payment | TEXT | [cite_start]Lump-sum payment indicator [cite: 33] |
| load_timestamp | TIMESTAMP | [cite_start]ETL load timestamp [cite: 33] |
| source_file | TEXT | [cite_start]Source file name [cite: 33] |

---

### 6. gold.fact_loan_application

* [cite_start]**Purpose:** Central fact table containing loan application measures, performance indicators, and foreign key references to all analytical dimensions[cite: 37].
* **Columns:**

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| fact_loan_id | BIGSERIAL | [cite_start]Fact table primary key [cite: 39] |
| source_id | BIGINT | [cite_start]Original source record identifier [cite: 39] |
| loan_amount | BIGINT | [cite_start]Requested loan amount [cite: 39] |
| income | NUMERIC(18,2) | [cite_start]Applicant income [cite: 39] |
| rate_of_interest | NUMERIC(6,3) | [cite_start]Interest rate [cite: 39] |
| term | INT | [cite_start]Loan term [cite: 39] |
| debt_to_income_ratio | NUMERIC(10,4) | [cite_start]Debt-to-income ratio [cite: 39] |
| loan_to_value_ratio | NUMERIC(10,2) | [cite_start]Loan-to-value ratio [cite: 39] |
| credit_score | INT | [cite_start]Applicant credit score [cite: 39] |
| property_value | NUMERIC(18,2) | [cite_start]Property value [cite: 39] |
| is_default | BOOLEAN | [cite_start]Loan default indicator [cite: 39] |
| debt_burden_segment | TEXT | [cite_start]Derived debt burden classification [cite: 39] |
| customer_id | BIGINT | [cite_start]Foreign key to dim_customer [cite: 39] |
| loan_id | BIGINT | [cite_start]Foreign key to dim_loan [cite: 39] |
| property_id | BIGINT | [cite_start]Foreign key to dim_property [cite: 39] |
| credit_profile_id | BIGINT | [cite_start]Foreign key to dim_credit_profile [cite: 39] |
| application_id | BIGINT | [cite_start]Foreign key to dim_application [cite: 39] |
| load_timestamp | TIMESTAMP | [cite_start]ETL load timestamp [cite: 39] |
| source_file | TEXT | [cite_start]Source file name [cite: 39] |

---

## Relationships

[cite_start]The Gold Layer follows a star schema model where `fact_loan_application` connects directly to all dimension tables[cite: 42]:
* [cite_start]`fact_loan_application.customer_id` -> `dim_customer.customer_id` [cite: 39, 43, 44]
* [cite_start]`fact_loan_application.loan_id` -> `dim_loan.loan_id` [cite: 39, 45]
* [cite_start]`fact_loan_application.property_id` -> `dim_property.property_id` [cite: 39, 46, 47]
* [cite_start]`fact_loan_application.credit_profile_id` -> `dim_credit_profile.credit_profile_id` [cite: 39, 48, 49]
* [cite_start]`fact_loan_application.application_id` -> `dim_application.application_id` [cite: 39, 50, 51]

[cite_start]This structure enables efficient analytical querying, reporting, and dashboard development while maintaining dimensional consistency across the warehouse[cite: 52].
