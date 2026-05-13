/*
====================================================
INIT SCHEMAS
====================================================

Purpose:
Creates Medallion Architecture schemas:
- bronze (raw ingestion layer)
- silver (cleaned data layer)
- gold (analytics layer)
====================================================
*/

CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
