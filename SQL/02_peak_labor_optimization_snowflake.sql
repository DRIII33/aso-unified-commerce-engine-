/*
ASO Unified Commerce Engine: Peak Labor Optimization (Phase 3)
Dialect: Snowflake (Reference Only)
*/
CREATE OR REPLACE VIEW aso_operations_2026.vw_splh_analysis AS
SELECT 
    hour_timestamp,
    DAYOFWEEK(hour_timestamp) as day_of_week,
    HOUR(hour_timestamp) as hour_of_day,
    total_hourly_revenue,
    active_headcount,
    agentic_search_volume,
    -- Snowflake uses IFF and division directly (handling 0s via NULLIF)
    total_hourly_revenue / NULLIF(active_headcount, 0) as splh_actual,
    IFF(hour_timestamp >= '2026-04-26 00:00:00', TRUE, FALSE) as is_post_earthquake
FROM 
    aso_operations_2026.vw_hourly_labor_transactions_joined;
