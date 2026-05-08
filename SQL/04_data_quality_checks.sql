-- ============================================================================
-- PROJECT: ASO Unified Commerce & Workforce Optimization Engine
-- PHASE: 3 (Analytical Development)
-- STEP: 5 - Data Quality Checks in BigQuery
-- ============================================================================
-- PURPOSE:
--   Final validation of data in BigQuery tables before analytical development.
--   Checks for null values, duplicates, data ranges, and business logic.
--
-- EXECUTION:
--   1. Run entire script in BigQuery Console
--   2. Review results for any FAIL status or unexpected values
--   3. If all results show PASS or expected values, proceed to Phase 3 SQL models
--
-- DRI: Daniel Rodriguez III (@DRIII33)
-- CREATED: May 7, 2026
-- ============================================================================

-- ============================================================================
-- CHECK 1: Transaction Data Completeness
-- ============================================================================
SELECT 
  'TRANSACTION TABLE' AS check_category,
  'Null Count - transaction_id' AS check_name,
  COUNT(*) AS total_rows,
  COUNTIF(transaction_id IS NULL) AS null_count,
  CASE WHEN COUNTIF(transaction_id IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM `driiiportfolio.aso_operations_2026.aso_transactions_raw`

UNION ALL

SELECT 
  'TRANSACTION TABLE',
  'Null Count - user_id',
  COUNT(*),
  COUNTIF(user_id IS NULL),
  CASE WHEN COUNTIF(user_id IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM `driiiportfolio.aso_operations_2026.aso_transactions_raw`

UNION ALL

SELECT 
  'TRANSACTION TABLE',
  'Null Count - timestamp',
  COUNT(*),
  COUNTIF(timestamp IS NULL),
  CASE WHEN COUNTIF(timestamp IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM `driiiportfolio.aso_operations_2026.aso_transactions_raw`

UNION ALL

SELECT 
  'TRANSACTION TABLE',
  'Null Count - platform',
  COUNT(*),
  COUNTIF(platform IS NULL),
  CASE WHEN COUNTIF(platform IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM `driiiportfolio.aso_operations_2026.aso_transactions_raw`

UNION ALL

SELECT 
  'TRANSACTION TABLE',
  'Null Count - amount',
  COUNT(*),
  COUNTIF(amount IS NULL),
  CASE WHEN COUNTIF(amount IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM `driiiportfolio.aso_operations_2026.aso_transactions_raw`

UNION ALL

SELECT 
  'TRANSACTION TABLE',
  'Null Count - is_redownload',
  COUNT(*),
  COUNTIF(is_redownload IS NULL),
  CASE WHEN COUNTIF(is_redownload IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM `driiiportfolio.aso_operations_2026.aso_transactions_raw`

-- ============================================================================
-- CHECK 2: Transaction ID Uniqueness
-- ============================================================================

UNION ALL

SELECT 
  'TRANSACTION TABLE',
  'Uniqueness - transaction_id',
  COUNT(*) AS total_rows,
  COUNT(DISTINCT transaction_id) AS unique_ids,
  CASE WHEN COUNT(*) = COUNT(DISTINCT transaction_id) THEN 'PASS' ELSE 'FAIL' END
FROM `driiiportfolio.aso_operations_2026.aso_transactions_raw`

-- ============================================================================
-- CHECK 3: Platform Value Validation
-- ============================================================================

UNION ALL

SELECT 
  'TRANSACTION TABLE',
  'Value Validation - platform',
  COUNT(*),
  COUNTIF(platform IN ('Apple_IAP', 'External_Link')) AS valid_count,
  CASE WHEN COUNTIF(platform IN ('Apple_IAP', 'External_Link')) = COUNT(*) THEN 'PASS' ELSE 'FAIL' END
FROM `driiiportfolio.aso_operations_2026.aso_transactions_raw`

-- ============================================================================
-- CHECK 4: Amount Range Validation
-- ============================================================================

UNION ALL

SELECT 
  'TRANSACTION TABLE',
  'Range Validation - amount (0.99-149.99)',
  COUNT(*),
  COUNTIF(amount >= 0.99 AND amount <= 149.99) AS valid_count,
  CASE WHEN COUNTIF(amount >= 0.99 AND amount <= 149.99) = COUNT(*) THEN 'PASS' ELSE 'FAIL' END
FROM `driiiportfolio.aso_operations_2026.aso_transactions_raw`

-- ============================================================================
-- CHECK 5: Transaction Date Range
-- ============================================================================

UNION ALL

SELECT 
  'TRANSACTION TABLE',
  'Date Range - April 1-30, 2026',
  COUNT(*),
  COUNTIF(DATE(timestamp) >= '2026-04-01' AND DATE(timestamp) <= '2026-04-30') AS valid_count,
  CASE WHEN COUNTIF(DATE(timestamp) >= '2026-04-01' AND DATE(timestamp) <= '2026-04-30') = COUNT(*) THEN 'PASS' ELSE 'FAIL' END
FROM `driiiportfolio.aso_operations_2026.aso_transactions_raw`

-- ============================================================================
-- CHECK 6: Redownload Ratio Distribution
-- ============================================================================

UNION ALL

SELECT 
  'TRANSACTION TABLE',
  'Redownload Ratio (2:1 expected)',
  COUNT(*),
  COUNTIF(is_redownload = TRUE) AS redownload_count,
  'INFO' -- Not a strict PASS/FAIL; informational
FROM `driiiportfolio.aso_operations_2026.aso_transactions_raw`

-- ============================================================================
-- CHECK 7: External Payment Duplication Rate
-- ============================================================================

UNION ALL

SELECT 
  'TRANSACTION TABLE',
  'External Payment Duplication Rate (~15%)',
  (SELECT COUNT(*) FROM `driiiportfolio.aso_operations_2026.aso_transactions_raw` WHERE platform = 'Apple_IAP'),
  (SELECT COUNT(*) FROM `driiiportfolio.aso_operations_2026.aso_transactions_raw` WHERE platform = 'External_Link'),
  'INFO'
FROM (SELECT 1 LIMIT 1)

-- ============================================================================
-- CHECK 8: Labor Table Completeness
-- ============================================================================

UNION ALL

SELECT 
  'LABOR TABLE',
  'Null Count - timestamp',
  COUNT(*),
  COUNTIF(timestamp IS NULL),
  CASE WHEN COUNTIF(timestamp IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM `driiiportfolio.aso_operations_2026.austin_labor_metrics`

UNION ALL

SELECT 
  'LABOR TABLE',
  'Null Count - location',
  COUNT(*),
  COUNTIF(location IS NULL),
  CASE WHEN COUNTIF(location IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM `driiiportfolio.aso_operations_2026.austin_labor_metrics`

UNION ALL

SELECT 
  'LABOR TABLE',
  'Null Count - active_headcount',
  COUNT(*),
  COUNTIF(active_headcount IS NULL),
  CASE WHEN COUNTIF(active_headcount IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM `driiiportfolio.aso_operations_2026.austin_labor_metrics`

UNION ALL

SELECT 
  'LABOR TABLE',
  'Null Count - agentic_search_volume',
  COUNT(*),
  COUNTIF(agentic_search_volume IS NULL),
  CASE WHEN COUNTIF(agentic_search_volume IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM `driiiportfolio.aso_operations_2026.austin_labor_metrics`

UNION ALL

SELECT 
  'LABOR TABLE',
  'Null Count - is_peak_flag',
  COUNT(*),
  COUNTIF(is_peak_flag IS NULL),
  CASE WHEN COUNTIF(is_peak_flag IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM `driiiportfolio.aso_operations_2026.austin_labor_metrics`

-- ============================================================================
-- CHECK 9: Labor Table Timestamp Uniqueness
-- ============================================================================

UNION ALL

SELECT 
  'LABOR TABLE',
  'Uniqueness - timestamp (hourly)',
  COUNT(*),
  COUNT(DISTINCT timestamp),
  CASE WHEN COUNT(*) = COUNT(DISTINCT timestamp) THEN 'PASS' ELSE 'FAIL' END
FROM `driiiportfolio.aso_operations_2026.austin_labor_metrics`

-- ============================================================================
-- CHECK 10: Labor Location Validation
-- ============================================================================

UNION ALL

SELECT 
  'LABOR TABLE',
  'Value Validation - location (Austin_Hub)',
  COUNT(*),
  COUNTIF(location = 'Austin_Hub'),
  CASE WHEN COUNTIF(location = 'Austin_Hub') = COUNT(*) THEN 'PASS' ELSE 'FAIL' END
FROM `driiiportfolio.aso_operations_2026.austin_labor_metrics`

-- ============================================================================
-- CHECK 11: Labor Headcount Range
-- ============================================================================

UNION ALL

SELECT 
  'LABOR TABLE',
  'Range Validation - active_headcount (15-55)',
  COUNT(*),
  COUNTIF(active_headcount >= 15 AND active_headcount <= 55),
  CASE WHEN COUNTIF(active_headcount >= 15 AND active_headcount <= 55) = COUNT(*) THEN 'PASS' ELSE 'FAIL' END
FROM `driiiportfolio.aso_operations_2026.austin_labor_metrics`

-- ============================================================================
-- CHECK 12: Peak Flag Validation
-- ============================================================================

UNION ALL

SELECT 
  'LABOR TABLE',
  'Value Validation - is_peak_flag (0 or 1)',
  COUNT(*),
  COUNTIF(is_peak_flag IN (0, 1)),
  CASE WHEN COUNTIF(is_peak_flag IN (0, 1)) = COUNT(*) THEN 'PASS' ELSE 'FAIL' END
FROM `driiiportfolio.aso_operations_2026.austin_labor_metrics`

-- ============================================================================
-- CHECK 13: Labor Date Range
-- ============================================================================

UNION ALL

SELECT 
  'LABOR TABLE',
  'Date Range - April 1-30, 2026',
  COUNT(*),
  COUNTIF(DATE(timestamp) >= '2026-04-01' AND DATE(timestamp) <= '2026-04-30'),
  CASE WHEN COUNTIF(DATE(timestamp) >= '2026-04-01' AND DATE(timestamp) <= '2026-04-30') = COUNT(*) THEN 'PASS' ELSE 'FAIL' END
FROM `driiiportfolio.aso_operations_2026.austin_labor_metrics`

-- ============================================================================
-- CHECK 14: Traffic Volume Range
-- ============================================================================

UNION ALL

SELECT 
  'LABOR TABLE',
  'Range Validation - agentic_search_volume (500-10000)',
  COUNT(*),
  COUNTIF(agentic_search_volume >= 500 AND agentic_search_volume <= 10000),
  CASE WHEN COUNTIF(agentic_search_volume >= 500 AND agentic_search_volume <= 10000) = COUNT(*) THEN 'PASS' ELSE 'FAIL' END
FROM `driiiportfolio.aso_operations_2026.austin_labor_metrics`

ORDER BY check_category, check_name;
