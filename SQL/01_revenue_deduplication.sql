/*
ASO Unified Commerce Engine: Revenue Deduplication Logic (Phase 3)
Dialect: Google BigQuery
DRI: Daniel Rodriguez III (@DRIII33)

Objective: Identify and deduplicate transactions originating from both Apple IAP 
and External_Link gateways within a 10-second window.

Outputs/Reference: 
Produces the logic for: driiiportfolio.aso_operations_2026.vw_transactions_deduplicated - vw.csv
Produces the logic for: driiiportfolio.aso_operations_2026.vw_daily_revenue_metrics - vw.csv
*/

-- 1. Create Deduplicated Transactions View
CREATE OR REPLACE VIEW `driiiportfolio.aso_operations_2026.vw_transactions_deduplicated` AS
WITH RankedTransactions AS (
    SELECT 
        transaction_id,
        user_id,
        timestamp,
        amount,
        platform,
        is_redownload,
        -- Rank transactions by same user, same amount, within close proximity.
        -- Apple_IAP is prioritized (ORDER BY platform ASC puts 'Apple_IAP' before 'External_Link')
        ROW_NUMBER() OVER(
            PARTITION BY user_id, amount, TIMESTAMP_TRUNC(timestamp, MINUTE)
            ORDER BY platform ASC, timestamp ASC
        ) as duplicate_rank
    FROM 
        `driiiportfolio.aso_operations_2026.aso_transactions_raw`
)
SELECT 
    transaction_id,
    user_id,
    timestamp,
    amount,
    platform,
    is_redownload,
    duplicate_rank,
    CASE WHEN duplicate_rank = 1 THEN TRUE ELSE FALSE END as is_valid_revenue
FROM 
    RankedTransactions;

-- 2. Create Daily Revenue Metrics View (Aggregated SSOT)
-- ============================================================================
-- VIEW: vw_daily_revenue_metrics (CORRECTED)
-- ============================================================================
-- PURPOSE: 
--   Generate daily revenue metrics split by platform (Apple_IAP + External_Link)
--   with deduplication that preserves legitimate external transactions
--
-- LOGIC:
--   1. Identify duplicate candidates (same user_id + amount within 60 sec)
--   2. For duplicates: Keep Apple_IAP (preferred), mark External_Link as dupe
--   3. For non-duplicates: Keep all transactions regardless of platform
--   4. Aggregate by date + platform
--
-- DRI: Daniel Rodriguez III (@DRIII33)
-- ============================================================================

CREATE OR REPLACE VIEW `driiiportfolio.aso_operations_2026.vw_daily_revenue_metrics`
AS
WITH
  ranked_transactions AS (
    -- Step 1: Identify potential duplicates (same user + amount within 60 seconds)
    SELECT
      transaction_id,
      user_id,
      timestamp,
      platform,
      amount,
      is_redownload,

      -- Rank by timestamp within each (user_id, amount) group
      -- Prefer Apple_IAP (rank 1) over External_Link (rank 2+)
      ROW_NUMBER()
