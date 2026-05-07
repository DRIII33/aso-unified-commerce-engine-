# ASO Metric Glossary: Single Source of Truth

**Document Purpose:** Define all KPIs and metrics used in the ASO Unified Commerce Engine. This is the authoritative reference for metric calculation, ownership, and interpretation.

**Version:** 1.0  
**Last Updated:** May 7, 2026  
**Owner:** Daniel Rodriguez III (@DRIII33)  
**Status:** 🟢 Approved

---

## 1. Revenue Metrics

### 1.1 Net Revenue

**Definition:** Total monetary amount received from transaction activity, net of duplicates, returns, and adjustments.

**Calculation:**
```sql
SELECT 
  DATE(timestamp) as transaction_date,
  platform,
  SUM(amount) as net_revenue
FROM `driiiportfolio.aso_operations_2026.aso_transactions_raw`
WHERE duplicate_rank = 1
  AND platform IN ('Apple_IAP', 'External_Link')
GROUP BY 1, 2
ORDER BY transaction_date DESC;
```

**Data Source:** `aso_transactions_raw`  
**Grain:** Day, Platform  
**Owner:** Finance - Revenue Recognition Team  
**SLA:** Data freshness <24 hours  
**Interpretation:** Primary P&L metric for ASO Operations. Excludes refunds and adjustments.

---

### 1.2 Revenue by Platform

**Definition:** Net revenue split between Apple's in-app purchase (IAP) system and external payment gateways.

**Calculation:**
```sql
WITH revenue_by_platform AS (
  SELECT 
    DATE(timestamp) as transaction_date,
    platform,
    SUM(amount) as revenue
  FROM `driiiportfolio.aso_operations_2026.aso_transactions_raw`
  WHERE duplicate_rank = 1
  GROUP BY 1, 2
)
SELECT 
  transaction_date,
  SUM(CASE WHEN platform = 'Apple_IAP' THEN revenue ELSE 0 END) as revenue_apple,
  SUM(CASE WHEN platform = 'External_Link' THEN revenue ELSE 0 END) as revenue_external,
  SUM(revenue) as total_revenue
FROM revenue_by_platform
GROUP BY 1
ORDER BY transaction_date DESC;
```

**Data Source:** `aso_transactions_raw`  
**Grain:** Day, Platform  
**Owner:** Finance - Revenue Ops  
**Target Platform Mix:** Apple_IAP 85-90%, External_Link 10-15%  
**Interpretation:** Tracks regulatory impact of external payment option enablement. Platform mix informs product strategy.

---

### 1.3 Redownload Ratio

**Definition:** Proportion of transactions driven by redownloads (user re-engagement) vs. new downloads.

**Calculation:**
```sql
SELECT 
  DATE(timestamp) as transaction_date,
  COUNTIF(is_redownload = TRUE) as redownload_count,
  COUNTIF(is_redownload = FALSE) as new_download_count,
  ROUND(SAFE_DIVIDE(COUNTIF(is_redownload = TRUE), 
                    COUNTIF(is_redownload = FALSE)), 2) as redownload_ratio,
  ROUND(100 * SAFE_DIVIDE(COUNTIF(is_redownload = TRUE), 
                          COUNT(*)), 2) as redownload_percentage
FROM `driiiportfolio.aso_operations_2026.aso_transactions_raw`
WHERE duplicate_rank = 1
GROUP BY 1
ORDER BY transaction_date DESC;
```

**Data Source:** `aso_transactions_raw`  
**Grain:** Day, Platform  
**Owner:** Product Analytics - User Engagement  
**Target:** 2.0 minimum (66.7% redownload rate)  
**Interpretation:** Primary signal of user retention and lifetime value. Redownloads have zero incremental CAC.

---

## 2. Labor Optimization Metrics

### 2.1 Active Headcount

**Definition:** Number of full-time equivalent (FTE) employees actively engaged in ASO operations during a specific hour.

**Calculation:**
```sql
SELECT 
  timestamp,
  location,
  active_headcount
FROM `driiiportfolio.aso_operations_2026.austin_labor_metrics`
WHERE location = 'Austin_Hub'
ORDER BY timestamp DESC;
```

**Data Source:** `austin_labor_metrics`  
**Grain:** Hour, Location  
**Owner:** Workforce Planning  
**SLA:** Data freshness <1 hour  
**Interpretation:** Current state is flat allocation (20-50 FTE per hour). Optimization shifts to demand-driven scheduling.

---

### 2.2 Sales Per Labor Hour (SPLH)

**Definition:** Revenue generated per FTE per hour, measuring labor productivity and efficiency.

**Calculation:**
```sql
SELECT 
  DATETIME_TRUNC(t.timestamp, HOUR) as hour_timestamp,
  ROUND(SAFE_DIVIDE(SUM(t.amount), AVG(l.active_headcount)), 2) as splh,
  AVG(l.active_headcount) as avg_headcount,
  SUM(t.amount) as hourly_revenue
FROM `driiiportfolio.aso_operations_2026.aso_transactions_raw` t
JOIN `driiiportfolio.aso_operations_2026.austin_labor_metrics` l
  ON DATETIME_TRUNC(t.timestamp, HOUR) = DATETIME_TRUNC(l.timestamp, HOUR)
WHERE t.duplicate_rank = 1
GROUP BY 1
ORDER BY hour_timestamp DESC;
```

**Data Source:** `aso_transactions_raw` + `austin_labor_metrics`  
**Grain:** Hour  
**Owner:** Operations Analytics  
**Target SPLH by Hour Type:**
- Peak hours (5 PM-9 PM): $1,200-1,600 per FTE-hour
- Standard hours (10 AM-5 PM): $600-900 per FTE-hour
- Off-peak hours (midnight-4 AM): $400-600 per FTE-hour

**Interpretation:** Peak hours show 3-5x higher SPLH than non-peak hours. Current flat staffing is inefficient.

---

### 2.3 Peak Hour Identification

**Definition:** Hours that generate ≥88th percentile of daily revenue, collectively accounting for ~50% of weekly sales.

**Calculation:**
```sql
WITH hourly_revenue AS (
  SELECT 
    DATETIME_TRUNC(timestamp, HOUR) as hour_timestamp,
    SUM(amount) as hourly_revenue
  FROM `driiiportfolio.aso_operations_2026.aso_transactions_raw`
  WHERE duplicate_rank = 1
  GROUP BY 1
),
ranked_hours AS (
  SELECT 
    hour_timestamp,
    hourly_revenue,
    PERCENT_RANK() OVER(ORDER BY hourly_revenue DESC) as revenue_percentile
  FROM hourly_revenue
)
SELECT 
  hour_timestamp,
  hourly_revenue,
  CASE WHEN revenue_percentile >= 0.88 THEN 'Peak' ELSE 'Standard' END as hour_classification
FROM ranked_hours
ORDER BY hourly_revenue DESC;
```

**Data Source:** `aso_transactions_raw`  
**Grain:** Hour, Day of Week  
**Owner:** Workforce Planning  
**Expected Peak Hours:** ~20 hours out of 168 weekly hours  
**Interpretation:** Identifies consistent high-revenue periods (e.g., 5 PM-9 PM). Enables targeted staffing model.

---

## 3. Traffic & Algorithmic Metrics

### 3.1 Agentic Search Volume

**Definition:** Estimated number of AI agent requests routed to ASO systems, measured as proxy for traffic demand.

**Calculation:**
```sql
SELECT 
  DATETIME_TRUNC(timestamp, HOUR) as hour_timestamp,
  SUM(agentic_search_volume) as hourly_agent_traffic
FROM `driiiportfolio.aso_operations_2026.austin_labor_metrics`
GROUP BY 1
ORDER BY hour_timestamp DESC;
```

**Data Source:** `austin_labor_metrics`  
**Grain:** Hour  
**Owner:** Product - AI/Search  
**Interpretation:** Tracks impact of Answer Engine Optimization (AEO) strategy and algorithmic shifts.

---

### 3.2 Post-Earthquake Traffic Impact

**Definition:** Traffic multiplier comparing post-April 26 to pre-April 26 baseline (simulating "Keyword Earthquake" event).

**Calculation:**
```sql
SELECT 
  CASE WHEN timestamp > '2026-04-26' THEN 0.6 ELSE 1.0 END as traffic_multiplier,
  COUNT(*) as affected_hours
FROM `driiiportfolio.aso_operations_2026.austin_labor_metrics`
GROUP BY 1;
```

**Data Source:** `austin_labor_metrics`  
**Grain:** Date  
**Owner:** Product - AI/Search  
**Impact:** 40% decline in traffic post-April 26 (0.6x multiplier)  
**Interpretation:** Quantifies algorithmic disruption and need for AEO strategy shift.

---

## 4. Data Quality & Governance Metrics

### 4.1 Duplicate Transaction Rate

**Definition:** Percentage of transactions identified as duplicates between Apple IAP and external payment systems.

**Calculation:**
```sql
SELECT 
  DATE(timestamp) as transaction_date,
  ROUND(100 * SAFE_DIVIDE(
    COUNTIF(duplicate_rank > 1),
    COUNT(*)
  ), 2) as duplicate_rate_percent
FROM `driiiportfolio.aso_operations_2026.aso_transactions_raw`
GROUP BY 1
ORDER BY transaction_date DESC;
```

**Data Source:** `aso_transactions_raw`  
**Grain:** Day  
**Owner:** Finance Revenue Ops  
**Target:** 15% (±0.5% tolerance)  
**Interpretation:** Validates deduplication logic accuracy. High variance indicates data quality issue.

---

### 4.2 Data Freshness

**Definition:** Time elapsed between data event and availability in BigQuery.

**Calculation:**
```sql
SELECT 
  TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), MAX(timestamp), HOUR) as freshness_hours
FROM `driiiportfolio.aso_operations_2026.aso_transactions_raw`;
```

**Target SLAs:**
- Transaction data: <24 hours
- Labor data: <1 hour
- Dashboard: <2 hours behind real-time

**Owner:** Data Engineering  
**Monitoring:** Daily dashboard check

---

## 5. Metric Ownership & Governance

### 5.1 Metric Ownership Matrix

| Metric Category | Owner | Stakeholder | Frequency | SLA |
|-----------------|-------|-------------|-----------|-----|
| Revenue Metrics | Finance Revenue Ops | CFO, ASO Ops | Daily | <24 hrs |
| Labor Metrics | Workforce Planning | COO, HR | Hourly | <1 hr |
| Traffic Metrics | Product AI/Search | Chief Product | Daily | <4 hrs |
| Data Quality | Data Engineering | CTO | Daily | <1 hr |

---

## 6. Metric Calculation Methodology

**Requirements for Each Metric:**
1. SQL or Python logic documented in code comments
2. Grain specified (hour, day, user, product)
3. Filter criteria explained
4. Benchmark or target range provided
5. Known limitations noted
6. Owner contact information listed

---

**Metric Glossary Owner:** Daniel Rodriguez III (@DRIII33)  
**Last Updated:** May 7, 2026  
**Status:** 🟢 Approved
