# ASO Business Assumptions & Constraints

**Document Purpose:** Formalize the business scenario and all assumptions underpinning this analytics project.

**Version:** 1.0  
**Last Updated:** May 7, 2026  
**Owner:** Daniel Rodriguez III (@DRIII33)  
**Status:** 🟢 Approved

---

## 1. Regulatory & Market Context (2026)

### 1.1 External Payment Bifurcation

**Assumption:** Following a May 2025 contempt ruling, Apple was forced to eliminate restrictions on external payment options for the U.S. App Store.

**For This Project:**
- Revenue flows through two channels: Apple IAP (15-30% commission) and external payment links (lower commission)
- Attribution data can appear as duplicate transactions (same user, same amount, within 1-10 seconds)
- Deduplication logic is critical to establish Single Source of Truth (SSOT)
- Redownloads outpace new downloads by 2:1 ratio industry-wide

**Constraint:** This project assumes random 15% duplication rate; actual rate may vary by developer behavior.

---

### 1.2 Algorithmic Recalibration ("Keyword Earthquake")

**Assumption:** On April 26, 2026, the App Store search algorithm underwent a significant update resulting in 16,170+ keyword ranking losses.

**For This Project:**
- Synthetic traffic data includes a 40% decline multiplier (0.6x) post-April 26 to simulate impact
- Recovery trajectory unknown; modeled as static decline
- This creates urgency for workforce optimization during lower traffic periods

**Constraint:** This project does NOT model algorithm recovery timelines.

---

### 1.3 Agentic AI & Autonomous Commerce

**Assumption:** Agentic AI platforms are becoming the primary discovery mechanism for digital products.

**For This Project:**
- Synthetic labor data includes "agentic_search_volume" as proxy for AI agent traffic
- Data structured to support agentic discovery; dashboards include agent-specific KPIs

**Constraint:** This project does NOT model individual agent behavior or multi-agent dynamics.

---

## 2. Operational Context (ASO Austin Hub)

### 2.1 Sales Distribution

**Assumption:** 50% of total weekly sales occur in just 20 hours of the week.

**Calculation:**
- 168 hours in a week ÷ 7 days = 24 hours per day
- Top 20 revenue hours ÷ 168 total hours = 11.9% of hours
- These 20 hours generate ~50% of revenue
- Remaining 148 hours generate ~50% of revenue

**Implication:** SPLH during peak hours is approximately 4.2x higher than non-peak hours.

**Constraint:** Peak hours assumed stable and predictable; in reality they vary by seasonality and promotions.

---

### 2.2 Redownload Ratio

**Assumption:** Redownloads outpace new downloads by 2:1 ratio.

**For This Project:**
- Synthetic data generated with 66.7% probability of being redownload (2:1 ratio)
- Redownloads signal user retention and lifetime value
- Financial impact: Redownloads = zero incremental CAC; new downloads = ~30% margin after CAC

**Constraint:** Does NOT differentiate between redownload types (forced reinstall vs. voluntary re-engagement).

---

### 2.3 External Payment Attribution

**Assumption:** 15% of Apple IAP transactions have corresponding duplicate in external payment systems within 1-10 seconds.

**For This Project:**
- SQL deduplication logic uses ROW_NUMBER() OVER PARTITION to keep first (Apple IAP) transaction
- This creates deduplication challenge that demonstrates analytical mastery

**Constraint:** In reality, external payments are alternative pathways; duplicates would be rare with proper architecture.

---

## 3. Technical & Data Assumptions

### 3.1 Data Volume & Scope

**Assumption:** Synthetic dataset represents 30 days (April 1-30, 2026) at ASO scale.

**Dataset Specifications:**
- **Transaction Dataset:** 100-300 transactions per hour × 24 hours × 30 days = 72K-216K records
- **Labor Dataset:** 24-hour hourly records × 30 days = 720 records
- **Storage Estimate:** <100 MB total
- **Query Costs:** <$1 (BigQuery charges per TB scanned)

**Rationale:** 30 days sufficient to demonstrate trending (pre/post-earthquake), weekly patterns, and labor optimization.

**Constraint:** Does NOT represent full-year seasonality or holiday impacts.

---

### 3.2 Synthetic Data Generation

**Assumption:** Python script generates realistic data simulating ASO operations.

**Parameters:**
- User IDs: 10,000-99,999 range (30-day cohort)
- Transaction amounts: $0.99-$149.99 (app/IAP price distribution)
- Timestamps: Uniformly distributed; peaks concentrated in evening hours (5 PM-9 PM)
- Headcount: 20-50 active staff per hour (Austin hub scale)
- Traffic volume: 1,000-10,000 agents per hour

**Quality Assumptions:**
- No NULL values in key fields
- Transaction IDs globally unique
- Timestamps monotonically increasing
- Platform field exactly two values: 'Apple_IAP' or 'External_Link'

---

### 3.3 BigQuery Data Warehouse

**Assumption:** Google Cloud Project "driiiportfolio" is accessible with sufficient quota.

**Configuration:**
- **Dataset Name:** `aso_operations_2026`
- **Table 1:** `aso_transactions_raw` (72K-216K rows)
- **Table 2:** `austin_labor_metrics` (720 rows)
- **Storage:** <100 MB

**Constraint:** Assumes no existing tables named `aso_operations_2026.*`; creation proceeds without conflict.

---

### 3.4 SQL & Query Assumptions

**Assumption:** All queries written in BigQuery dialect with Snowflake equivalents provided.

**Key Differences Modeled:**
- BigQuery: `TIMESTAMP_TRUNC()` vs. Snowflake: `DATE_TRUNC()`
- BigQuery: `SAFE_DIVIDE()` vs. Snowflake: `DIV0NULL()`
- BigQuery: `CONCAT()` vs. Snowflake: `||`

**Performance Assumptions:**
- Queries <5 seconds on 72K-216K transaction records
- No indexes required; BigQuery columnar storage sufficient

---

## 4. Business Objective Assumptions

### 4.1 Revenue Deduplication Objective

**Primary Objective:** Establish Single Source of Truth (SSOT) for revenue eliminating double-counting between Apple IAP and external payment systems.

**Success Metric:**
- Duplicate transactions removed (~15% of total)
- Net revenue accurate within 0.1%
- Revenue split by platform clear
- Redownload ratio tracked separately

---

### 4.2 Labor Optimization Objective

**Secondary Objective:** Connect demand signals (traffic) to staffing decisions to maximize Sales Per Labor Hour (SPLH).

**Success Metric:**
- Peak hours identified (20 hours generating 50% revenue)
- Current flat vs. optimized staffing modeled
- Sales impact of staffing change estimated
- Estimated annual revenue lift: $21M+ (conservative)

---

### 4.3 Algorithmic Resilience Objective

**Tertiary Objective:** Forecast and monitor impacts of algorithmic changes ("Keyword Earthquake").

**Success Metric:**
- Revenue impact quantified (40% traffic decline post-April 26)
- Recovery signals identified
- Answer Engine Optimization (AEO) readiness modeled

---

## 5. Constraints & Out-of-Scope

### 5.1 Data Privacy & Compliance

**Assumption:** Synthetic data does NOT contain actual Apple customer information.

- All data randomly generated to realistic distributions
- Complies with data generation standards

---

### 5.2 Scope Limitations

**Out of Scope:**
- Individual app developer decision logic (IAP vs. external choice)
- Real-time inventory management
- Customer satisfaction metrics
- Competitive analysis
- International markets (Austin hub focus only)

---

### 5.3 Temporal Scope

**Out of Scope:**
- Holiday seasonality
- Year-over-year comparisons
- Long-term trend forecasting beyond 30 days
- Multi-year cohort analysis

---

## 6. Stakeholder Alignment Requirements

**Assumptions Requiring Sign-Off:**

- [ ] ASO Operations Leadership — Confirm peak hour patterns and redownload ratio
- [ ] Finance Team — Confirm revenue deduplication logic and financial treatment
- [ ] Data Engineering — Confirm BigQuery model supports performance SLAs

---

**Assumptions Owner:** Daniel Rodriguez III (@DRIII33)  
**Last Updated:** May 7, 2026  
**Status:** 🟢 Approved
