/*
ASO Unified Commerce Engine: Revenue Deduplication Logic (Phase 3)
Dialect: Snowflake (Reference Only)
DRI: Daniel Rodriguez III (@DRIII33)

Objective: Provide Snowflake equivalent syntax for hiring manager visibility.
*/

CREATE OR REPLACE VIEW aso_operations_2026.vw_transactions_deduplicated AS
WITH RankedTransactions AS (
    SELECT 
        transaction_id,
        user_id,
        timestamp,
        amount,
        platform,
        is_redownload,
        -- Snowflake uses DATE_TRUNC syntax
        ROW_NUMBER() OVER(
            PARTITION BY user_id, amount, DATE_TRUNC('MINUTE', timestamp)
            ORDER BY platform ASC, timestamp ASC
        ) as duplicate_rank
    FROM 
        aso_operations_2026.aso_transactions_raw
)
SELECT 
    transaction_id,
    user_id,
    timestamp,
    amount,
    platform,
    is_redownload,
    duplicate_rank,
    IFF(duplicate_rank = 1, TRUE, FALSE) as is_valid_revenue
FROM 
    RankedTransactions;
