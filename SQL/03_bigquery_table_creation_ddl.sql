/*
ASO Unified Commerce Engine: BigQuery Table Creation (DDL)
DRI: Daniel Rodriguez III (@DRIII33)
Project ID: driiiportfolio
Dataset: aso_operations_2026

Objective: Define the structure in Google BigQuery.
*/

-- Create Dataset
CREATE SCHEMA IF NOT EXISTS `driiiportfolio.aso_operations_2026`
  OPTIONS(
    location="us",
    description="ASO Operations Data Warehouse - April 2026"
  );

-- Create Transaction Table
CREATE OR REPLACE TABLE `driiiportfolio.aso_operations_2026.aso_transactions_raw` (
    transaction_id STRING NOT NULL OPTIONS(description="Unique transaction identifier"),
    user_id INT64 NOT NULL OPTIONS(description="Unique customer identifier"),
    timestamp TIMESTAMP NOT NULL OPTIONS(description="Exact timestamp of transaction"),
    amount FLOAT64 NOT NULL OPTIONS(description="Net transaction value in USD"),
    platform STRING NOT NULL OPTIONS(description="Apple_IAP or External_Link"),
    is_redownload BOOL NOT NULL OPTIONS(description="TRUE if transaction is a redownload")
)
PARTITION BY DATE(timestamp)
OPTIONS(
  description="Raw ASO transaction data simulating dual-track monetization and redownload behavior."
);

-- Create Labor Metrics Table
CREATE OR REPLACE TABLE `driiiportfolio.aso_operations_2026.austin_labor_metrics` (
    labor_hour_timestamp TIMESTAMP NOT NULL OPTIONS(description="Hour block start time"),
    location STRING NOT NULL OPTIONS(description="Operations Hub Location"),
    active_headcount INT64 NOT NULL OPTIONS(description="Number of FTE active during hour"),
    agentic_search_volume INT64 NOT NULL OPTIONS(description="AI Agent queries processed")
)
PARTITION BY DATE(labor_hour_timestamp)
OPTIONS(
  description="Hourly labor and traffic data for Austin Hub."
);
