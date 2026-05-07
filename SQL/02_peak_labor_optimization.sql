/*
ASO Unified Commerce Engine: Peak Labor Optimization (Phase 3)
Dialect: Google BigQuery
DRI: Daniel Rodriguez III (@DRIII33)

Objective: Identify the 20 peak hours driving 50% of revenue and calculate Sales Per Labor Hour (SPLH).

Outputs/Reference: 
Produces the logic for: driiiportfolio.aso_operations_2026.vw_hourly_labor_transactions_joined
Produces the logic for: driiiportfolio.aso_operations_2026.vw_splh_analysis
Produces the logic for: driiiportfolio.aso_operations_2026.vw_peak_hours_identified
*/

-- 1. Create Hourly Joined Baseline
CREATE OR REPLACE VIEW `driiiportfolio.aso_operations_2026.vw_hourly_labor_transactions_joined` AS
WITH HourlyRevenue AS (
    SELECT 
        TIMESTAMP_TRUNC(timestamp, HOUR) as hour_timestamp,
        SUM(amount) as total_hourly_revenue,
        COUNT(transaction_id) as transaction_volume
    FROM 
        `driiiportfolio.aso_operations_2026.vw_transactions_deduplicated`
    WHERE 
        is_valid_revenue = TRUE
    GROUP BY 
        hour_timestamp
)
SELECT 
    hr.hour_timestamp,
    EXTRACT(DAYOFWEEK FROM hr.hour_timestamp) as day_of_week,
    EXTRACT(HOUR FROM hr.hour_timestamp) as hour_of_day,
    hr.total_hourly_revenue,
    hr.transaction_volume,
    lm.active_headcount,
    lm.agentic_search_volume
FROM 
    HourlyRevenue hr
LEFT JOIN 
    `driiiportfolio.aso_operations_2026.austin_labor_metrics` lm 
ON 
    hr.hour_timestamp = lm.labor_hour_timestamp;

-- 2. Create SPLH Analysis View
CREATE OR REPLACE VIEW `driiiportfolio.aso_operations_2026.vw_splh_analysis` AS
SELECT 
    hour_timestamp,
    day_of_week,
    hour_of_day,
    total_hourly_revenue,
    active_headcount,
    agentic_search_volume,
    SAFE_DIVIDE(total_hourly_revenue, active_headcount) as splh_actual,
    -- Model post-earthquake flag
    CASE WHEN hour_timestamp >= '2026-04-26 00:00:00' THEN TRUE ELSE FALSE END as is_post_earthquake
FROM 
    `driiiportfolio.aso_operations_2026.vw_hourly_labor_transactions_joined`;

-- 3. Identify Peak Hours (The 20 Hours driving 50% of revenue)
CREATE OR REPLACE VIEW `driiiportfolio.aso_operations_2026.vw_peak_hours_identified` AS
WITH RankedHours AS (
    SELECT 
        hour_of_day,
        AVG(total_hourly_revenue) as avg_revenue_per_hour,
        PERCENT_RANK() OVER(ORDER BY AVG(total_hourly_revenue) ASC) as revenue_percentile
    FROM 
        `driiiportfolio.aso_operations_2026.vw_splh_analysis`
    GROUP BY 
        hour_of_day
)
SELECT 
    hour_of_day,
    avg_revenue_per_hour,
    revenue_percentile,
    CASE WHEN revenue_percentile >= 0.88 THEN 'Peak (Optimize Labor)' ELSE 'Standard' END as hour_classification
FROM 
    RankedHours
ORDER BY 
    avg_revenue_per_hour DESC;
