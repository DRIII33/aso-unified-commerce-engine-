# Dashboard Design & Specification Document

**Document Purpose:** Provide the exact visual and functional specifications for the 3-page Looker Studio dashboard to ensure reproducibility and governance.
**Owner:** Daniel Rodriguez III

## Page 1: Revenue & Monetization Intelligence
* **Primary Audience:** Finance Controller, ASO Operations VP
* **Key Visuals:**
    * **Scorecard:** `net_revenue` (Format: Currency, Title: "Total Net Revenue (Deduplicated)").
    * **Scorecard:** `redownload_ratio` (Format: Decimal, Title: "Redownload Ratio (Target: 2.0)").
    * **Donut Chart:** Dimension: `platform`, Metric: `total_revenue` (Format: Percentage, highlighting the 88.1% vs 11.9% split).
    * **Time-Series Line Chart:** Dimension: `transaction_date`, Metrics: `revenue_apple`, `revenue_external`. Must clearly show the parallel drop on April 26.

## Page 2: Labor Optimization & Peak Hour Scheduling
* **Primary Audience:** Workforce Planning Director
* **Key Visuals:**
    * **Comparison Scorecards:** `peak_hour_splh` ($387.28) vs `non_peak_hour_splh` ($287.14).
    * **Heatmap Table:** Dimension 1: `day_of_week`, Dimension 2: `hour_of_day`. Metric: `hourly_revenue`. Apply conditional formatting (Dark Blue = High Revenue) to isolate the 5 PM–9 PM peak.
    * **Combo Chart:** X-Axis: `hour_of_day`. Bar Metric: `hourly_revenue`. Line Metric: `avg_austin_headcount`. This exposes the "Flat Allocation Problem" by showing static headcount against variable revenue.

## Page 3: Algorithmic Health & Agentic Commerce Readiness
* **Primary Audience:** Product AI/Search Lead
* **Key Visuals:**
    * **Time-Series Area Chart:** Dimension: `hour_timestamp`, Metric: `agentic_search_volume`. Apply a reference line at the pre-earthquake average (3,728).
    * **Bar Chart (Pre vs Post):** Dimension: `algorithmic_period`, Metric: `agentic_search_volume` (Comparing 3,990.20 vs 2,418.81).
    * **Gauge Chart:** Metric: `aeo_readiness_score`. Range: 0 to 10. Current value hardcoded to 4 via SQL logic to indicate early-stage recovery.
