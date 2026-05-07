# ASO Unified Commerce & Workforce Optimization Engine

## Executive Summary
This repository contains an end-to-end data pipeline demonstrating the **Analytics Development Lifecycle (ADLC)** applied to Apple Store Online (ASO) Operations. The project addresses three critical business challenges and culminates in a production-ready Looker Studio dashboard that enables leadership to ensure revenue accuracy, optimize workforce allocation, and respond strategically to algorithmic disruptions.

**DRI (Directly Responsible Individual):** Daniel Rodriguez III (@DRIII33)  
**Target Stakeholders:** Apple Hiring Manager, ASO Operations Leadership, Workforce Strategy & Analytics Team  
**Tech Stack:** Google BigQuery, Python (Google Colab), Advanced SQL, Looker Studio, Snowflake (Reference)
**Status:** 🟢 Complete

---

## Business Challenges & Executive Dashboard Mapping

### 1. Regulatory Shifts & Payment Bifurcation
* **The Challenge:** Following a May 2025 contempt ruling, Apple eliminated restrictions on external payment options, creating a "dual-track" monetization approach. Analytics complexity increased as attribution spanned Apple's in-app purchase system and multiple external gateways.
* **The Solution:** Implemented SQL window functions to deduplicate attribution data, retaining the Apple IAP transaction as the Single Source of Truth (SSOT).
* **Dashboard Mapping (Page 1):** Visualizes the total net revenue of $7.31M (April 2026) and the deduplicated 88.1% (Apple_IAP) vs. 11.9% (External_Link) revenue split. 

### 2. Workforce Stability & Labor Optimization
* **The Challenge:** In the Austin hub, 50% of total sales occur in just 20 hours of the week, yet staffing remains evenly distributed across all hours.
* **The Solution:** Mapped transaction timestamps to labor schedules to calculate Sales Per Labor Hour (SPLH), identifying the optimal 5 PM–9 PM peak windows.
* **Dashboard Mapping (Page 2):** Highlights the disparity between Peak Hour SPLH ($387) and Non-Peak Hour SPLH ($287), surfacing an opportunity for a $20-25M annual revenue lift and a reduction of 58,400 FTE-hours of burnout.

### 3. The "Keyword Earthquake" & Agentic Commerce
* **The Challenge:** An April 26, 2026 algorithm update caused 16,170+ keyword ranking losses and a 40% drop in discovery traffic, signaling a shift toward Answer Engine Optimization (AEO).
* **The Solution:** Modeled the traffic decline and developed tracking for Agentic Search Volume.
* **Dashboard Mapping (Page 3):** Visualizes the drop from 4,000 to 2,400 AI agent requests per hour, tracking an AEO Readiness Score (currently 4/10) to drive executive urgency.

---

## Repository Structure

    aso-unified-commerce-engine/
├── README.md 
├── CHANGELOG.md 
├── ARCHITECTURE.md 
├── TROUBLESHOOTING.md 
├── PROJECT_CHARTER.md 
│
├── docs/ 
│   ├── aso_business_assumptions.md 
│   ├── aso_metric_glossary.md 
│   ├── stakeholder_alignment_doc.md 
│   ├── ADLC_framework_mapping.md 
│
├── src/ 
│   ├── data_generator.py 
│   └── data_validation.py 
│
├── sql/ 
│   ├── 01_revenue_deduplication.sql 
│   ├── 01_revenue_deduplication_snowflake.sql 
│   ├── 02_peak_labor_optimization.sql 
│   ├── 02_peak_labor_optimization_snowflake.sql 
│   ├── 03_bigquery_table_creation_ddl.sql 
│   └── 04_data_quality_checks.sql 
│
├── dashboards/ 
│   ├── looker_studio_setup_guide.md 
│   ├── dashboard_specification.md 
│   └── looker_studio_dashboard_export.json 
│
└── data/ 
    ├── aso_transactions_raw.csv 
    ├── austin_labor_metrics.csv 
    └── data_quality_report.csv 

---

## Quick Start Guide

1. **Review Business Context:** Read `docs/aso_business_assumptions.md` and `docs/aso_metric_glossary.md`.
2. **Data Generation:** Execute `src/data_generator.py` in Google Colab to generate the 30-day synthetic cohort.
3. **Warehouse Setup:** Execute `sql/03_bigquery_table_creation_ddl.sql` in Google BigQuery to establish the schema. Upload the generated CSVs.
4. **Analytical Processing:** Run SQL models 01 through 04 to process the SSOT.
5. **Visualization:** Follow `dashboards/looker_studio_setup_guide.md` to connect the BigQuery output to the Looker Studio JSON schema.
