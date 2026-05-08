# System Architecture: ASO Unified Commerce Engine

**Document Purpose:** Provide a technical blueprint of the data pipeline architecture, system design, and data flow for the ASO Unified Commerce & Workforce Optimization Engine.

**Version:** 1.0  
**Last Updated:** May 7, 2026  
**Owner:** Daniel Rodriguez III (@DRIII33)

---

## 1. System Architecture Overview

### Data Pipeline Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        DATA SOURCES                              │
├─────────────────────────────────────────────────────────────────┤
│ • POS Systems (Transaction Data)                                │
│ • External Marketing Feeds (Attribution)                        │
│ • Labor Management System (Scheduling & Headcount)             │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│              DATA INGESTION LAYER (Phase 2)                    │
├─────────────────────────────────────────────────────────────────┤
│ Python Script (Google Colab)                                    │
│ • Synthetic Data Generation                                     │
│ • Data Quality Validation                                       │
│ • CSV Export                                                    │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│              WAREHOUSE LAYER (Google BigQuery)                 │
├─────────────────────────────────────────────────────────────────┤
│ Project: driiiportfolio                                         │
│ Dataset: aso_operations_2026                                    │
│                                                                 │
│ Tables:                                                         │
│ • aso_transactions_raw (72K-216K rows)                        │
│ • austin_labor_metrics (720 rows)                             │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│           ANALYTICAL LAYER (Phase 3 - SQL Models)              │
├─────────────────────────────────────────────────────────────────┤
│ BigQuery SQL Queries                                            │
│ • Revenue Deduplication Logic                                   │
│ • Labor Peak Hour Identification                               │
│ • KPI Aggregations                                             │
│ • Dimensional Analysis                                         │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ↓
┌──────────────────────────────────────────────────────────���──────┐
│         VISUALIZATION LAYER (Phase 4 - Looker Studio)          │
├─────────────────────────────────────────────────────────────────┤
│ Looker Studio Dashboards                                        │
│ • Page 1: Global Revenue Health                                │
│ • Page 2: Labor Optimization Analysis                          │
│ • Page 3: Traffic & Algorithmic Health                        │
│ • Self-Serve Filters & Interactivity                          │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│              STAKEHOLDER ACCESS LAYER                           │
├─────────────────────────────────────────────────────────────────┤
│ • ASO Operations Leadership (Dashboard Access)                 │
│ • Finance Revenue Operations (Revenue Reports)                 │
│ • Data Engineering Team (SQL Query Access)                    │
│ • Apple Hiring Manager (Portfolio Review)                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Data Flow Specification

### Phase 1: Planning & Strategic Alignment
**Data Movement:** None (documentation only)  
**Key Outputs:** KPI definitions, business assumptions, governance framework

### Phase 2: Data Engineering & Infrastructure
**Data Movement:** Python → CSV → BigQuery  
**Data Volume:** 
- Transactions: 100-300 per hour × 24 hours × 30 days = ~72K-216K records
- Labor Metrics: 24 hourly records × 30 days = 720 records

**Process:**
1. Python script (`src/data_generator.py`) generates synthetic data
2. Data validated by `src/data_validation.py`
3. CSV files exported: `aso_transactions_raw.csv`, `austin_labor_metrics.csv`
4. CSVs manually uploaded to BigQuery via web console
5. BigQuery tables created: `aso_transactions_raw`, `austin_labor_metrics`

### Phase 3: Analytical Development
**Data Movement:** BigQuery Query Results → BigQuery Views  
**Key Queries:**
- Revenue deduplication (SQL: `sql/01_revenue_deduplication.sql`)
- Labor optimization (SQL: `sql/02_peak_labor_optimization.sql`)
- Data quality checks (SQL: `sql/04_data_quality_checks.sql`)

### Phase 4: Visualization & Executive Reporting
**Data Movement:** BigQuery → Looker Studio → Dashboard  
**Data Source:** BigQuery tables and derived views  
**Refresh Cadence:** Real-time (Looker Studio queries BigQuery on demand)

---

## 3. Technology Stack Components

### Data Warehouse (Storage & Compute)
**Technology:** Google BigQuery  
**Why:** Cloud-native elasticity, native SQL support, seamless Looker Studio integration, sub-second query performance on analytical workloads

**Configuration:**
- Project ID: `driiiportfolio`
- Dataset: `aso_operations_2026`
- Tables: 2 (transactions, labor metrics)
- Estimated Storage: <100 MB
- Estimated Query Cost: <$1 (BigQuery charges $6.25 per TB scanned)

### Data Engineering (ETL/ELT)
**Technology:** Python (Google Colab)  
**Why:** Accessible, no local setup required, supports data generation and transformation, direct CSV export

**Libraries:**
- `pandas` — Data manipulation and aggregation
- `numpy` — Numerical operations (random distribution generation)
- `datetime` — Timestamp generation
- `google.cloud.bigquery` — BigQuery client (optional for automated upload)

### Query & Analysis
**Technology:** Advanced SQL (BigQuery Dialect)  
**Why:** Gold standard for analytics; supports window functions, CTEs, and complex aggregations required for financial and operational analysis

**SQL Features Used:**
- Window Functions: `ROW_NUMBER() OVER(PARTITION BY...)`
- CTEs (Common Table Expressions): `WITH ... AS`
- Aggregations: `SUM()`, `COUNT()`, `AVG()`, `PERCENT_RANK()`
- Date Functions: `TIMESTAMP_TRUNC()`, `DATE()`
- Safe Division: `SAFE_DIVIDE()`

### Business Intelligence (Visualization)
**Technology:** Looker Studio (formerly Google Data Studio)  
**Why:** Native BigQuery integration, self-serve dashboard capabilities, free/low-cost, enables business users to explore data independently

**Dashboard Features:**
- 3+ pages addressing business challenges
- Multiple chart types (scorecards, line charts, heatmaps)
- Self-serve filters (date range, platform, metrics)
- Real-time data refresh

### Reference Materials (Cross-Platform Knowledge)
**Technology:** Snowflake SQL Equivalents  
**Why:** Demonstrates polyglot data engineering expertise; shows understanding of multiple cloud data platforms

**Snowflake Equivalents:** Provided alongside BigQuery SQL for each analytical query

---

## 4. Database Schema Design

### Table 1: aso_transactions_raw

```sql
CREATE TABLE `driiiportfolio.aso_operations_2026.aso_transactions_raw` (
  transaction_id STRING NOT NULL,
  user_id STRING NOT NULL,
  timestamp TIMESTAMP NOT NULL,
  platform STRING NOT NULL,  -- 'Apple_IAP' or 'External_Link'
  amount NUMERIC(10, 2) NOT NULL,
  is_redownload BOOLEAN NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
PARTITION BY DATE(timestamp)
CLUSTER BY user_id, platform;
```

**Schema Rationale:**
- `transaction_id`: Globally unique identifier for deduplication logic
- `user_id`: Links transactions to users; used for redownload analysis
- `timestamp`: Required for time-series analysis and peak hour identification
- `platform`: Distinguishes Apple IAP vs. external payment channels
- `amount`: Transaction value; used for revenue calculations
- `is_redownload`: Boolean flag indicating user retention signal
- **Partitioning by DATE:** Optimizes queries filtering by date range
- **Clustering by user_id, platform:** Optimizes deduplication and platform analysis queries

### Table 2: austin_labor_metrics

```sql
CREATE TABLE `driiiportfolio.aso_operations_2026.austin_labor_metrics` (
  timestamp TIMESTAMP NOT NULL,
  location STRING NOT NULL,  -- 'Austin_Hub'
  active_headcount INTEGER NOT NULL,
  agentic_search_volume INTEGER NOT NULL,
  is_peak_flag BOOLEAN NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
PARTITION BY DATE(timestamp)
CLUSTER BY is_peak_flag;
```

**Schema Rationale:**
- `timestamp`: Hourly granularity for labor scheduling analysis
- `location`: Filters to Austin hub operations
- `active_headcount`: FTE count; used for SPLH calculation
- `agentic_search_volume`: Proxy for traffic demand
- `is_peak_flag`: Pre-calculated peak hour indicator
- **Partitioning by DATE:** Enables efficient date-range queries
- **Clustering by is_peak_flag:** Optimizes peak vs. non-peak comparisons

---

## 5. Analytical Model Architecture

### Model 1: Revenue Deduplication (Phase 3)

**Objective:** Establish Single Source of Truth (SSOT) for revenue by removing duplicates between Apple IAP and external payment systems

**Logic:**
1. Rank transactions by user_id, amount within 10-second windows
2. Keep only first occurrence (Apple IAP)
3. Sum deduplicated amounts by platform and date
4. Calculate redownload ratio

**Input:** `aso_transactions_raw`  
**Output:** Deduplicated revenue by platform, date, and redownload status  
**File:** `sql/01_revenue_deduplication.sql`

### Model 2: Labor Optimization (Phase 3)

**Objective:** Identify 20 peak hours and calculate Sales Per Labor Hour (SPLH) efficiency

**Logic:**
1. Aggregate transactions and labor metrics by hour
2. Rank hours by revenue using PERCENT_RANK()
3. Flag hours in top 12% (approximately 20 out of 168 hours per week)
4. Calculate SPLH by dividing hourly revenue by active headcount
5. Compare peak vs. non-peak SPLH efficiency

**Input:** `aso_transactions_raw` + `austin_labor_metrics`  
**Output:** Peak hours identified, SPLH by hour, optimization recommendations  
**File:** `sql/02_peak_labor_optimization.sql`

---

## 6. Query Performance Optimization

### Optimization Strategy

**1. Partitioning**
- Both tables partitioned by `DATE(timestamp)`
- Enables BigQuery to prune partitions not needed for query
- Expected query performance: <5 seconds

**2. Clustering**
- `aso_transactions_raw` clustered by `user_id, platform`
  - Deduplication queries benefit from co-location of same-user, same-platform transactions
- `austin_labor_metrics` clustered by `is_peak_flag`
  - Peak vs. non-peak analysis optimized

**3. Index Strategy**
- BigQuery uses columnar storage; explicit indexes not needed
- Partitioning and clustering provide implicit indexing

**4. Query Patterns**
- Use CTEs to break complex queries into logical steps
- Window functions evaluated efficiently on BigQuery's columnar engine
- SAFE_DIVIDE prevents division-by-zero errors without performance penalty

---

## 7. Data Integration Points

### Integration 1: Python → BigQuery (Phase 2)
**Method:** Manual CSV upload via BigQuery web console  
**Alternative:** Automated upload via `google.cloud.bigquery` Python client (commented in script)

**Steps:**
1. Run `src/data_generator.py` in Google Colab
2. Download generated CSVs
3. Navigate to BigQuery console → `aso_operations_2026` dataset
4. Click "Create Table" → Upload CSV → Map columns → Create
5. Repeat for both transaction and labor metrics tables

### Integration 2: BigQuery → Looker Studio (Phase 4)
**Method:** Native connector (Looker Studio natively connects to BigQuery)

**Steps:**
1. In Looker Studio, create new report
2. Add data source → Google BigQuery
3. Select project: `driiiportfolio`
4. Select dataset: `aso_operations_2026`
5. Select table: `aso_transactions_raw` or `austin_labor_metrics`
6. Grant access via OAuth consent screen
7. Configure charts and filters

---

## 8. Monitoring & Quality Assurance

### Data Quality Checks (Phase 2 & 6)
**File:** `sql/04_data_quality_checks.sql`

**Checks Performed:**
- Row count validation (expected ~72K-216K transactions, 720 labor records)
- NULL value detection (should be zero)
- Duplicate transaction detection (deduplication validation)
- Date range validation (April 1-30, 2026)
- Platform distribution (Apple_IAP ~85%, External_Link ~15%)
- Redownload ratio validation (target 2:1)
- SPLH range validation (peak hours 3-5x non-peak)

**Alerting:**
- Manual checks in Phase 2
- Automated checks in Phase 6 (monitoring setup)

### Pipeline Monitoring (Phase 6)
**Monitoring Points:**
- BigQuery query execution time (alert if >10 seconds)
- Looker Studio dashboard refresh status
- Data freshness (timestamp of latest transaction)
- Query cost tracking (cumulative spend vs. budget)

---

## 9. Disaster Recovery & Backup

### Backup Strategy
- BigQuery tables automatically backed up (7-day retention)
- CSV exports stored in repository `/data` directory
- Project documentation in GitHub (version controlled)

### Recovery Procedure
- If BigQuery tables corrupted: Re-run Python script, re-upload CSVs
- If Looker Studio dashboard corrupted: Export dashboard JSON, recreate from backup
- If documentation lost: Recover from GitHub history

---

## 10. Scalability Considerations

### Current Architecture (Phase 1-4)
- Data volume: <100 MB
- Query latency: <5 seconds
- Dashboard refresh: Real-time
- Cost: <$1/month

### Scaling Path (Post-Phase 4)
**To Scale to Production ASO Scale:**
1. **Data Volume:** Increase from 30 days to 12 months
   - Storage: ~1.2 GB (negligible in BigQuery)
   - Query cost: ~$10-50/month

2. **Frequency:** Shift from synthetic to real data pipeline
   - Add data ingestion scheduler (Cloud Scheduler + Pub/Sub)
   - Implement incremental updates (not full re-load)
   - Data freshness: Daily → Hourly → Real-time

3. **Complexity:** Add advanced analytics
   - Predictive modeling (ML Engine integration)
   - Automated anomaly detection
   - Cohort analysis and retention curves

4. **Governance:** Implement enterprise standards
   - Row-level security (RLS) for multi-tenant access
   - Audit logging (all queries tracked)
   - Data lineage tracking (showing data provenance)

---

**Document Owner:** Daniel Rodriguez III (@DRIII33)  
**Last Updated:** May 7, 2026  
**Status:** 🟢 Complete
