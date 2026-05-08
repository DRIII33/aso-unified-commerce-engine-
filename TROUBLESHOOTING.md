# Troubleshooting Guide: ASO Unified Commerce Engine

**Document Purpose:** Provide solutions for common errors, issues, and blockers encountered during project execution (Phases 1-4).

**Version:** 1.0  
**Last Updated:** May 7, 2026  
**Owner:** Daniel Rodriguez III (@DRIII33)

---

## 1. Phase 1 Troubleshooting: Planning & Alignment

### Issue 1.1: Stakeholders Unable to Align on KPI Definitions

**Symptom:** Finance and Operations disagree on revenue deduplication threshold (e.g., 10-second vs. 5-second window)

**Root Cause:** Competing business priorities and lack of shared context

**Solution:**
1. Refer to `docs/aso_business_assumptions.md` — external payment duplication assumption is 15% with 10-second window
2. Explain rationale: 10-second window aligns with typical payment gateway latency
3. If business context differs, document the difference and update assumption
4. DRI (Daniel Rodriguez III) makes final decision and documents in CHANGELOG.md

**Prevention:** Provide business context upfront in Phase 1 kick-off meeting

---

### Issue 1.2: Metric Glossary Terminology Conflicts

**Symptom:** Different teams use "revenue" differently (gross vs. net)

**Root Cause:** Lack of centralized KPI definitions

**Solution:**
1. Reference `docs/aso_metric_glossary.md` Section 1.1 (Net Revenue definition)
2. Clarify: "Net Revenue" = `SUM(amount) WHERE duplicate_rank = 1`
3. Update glossary if terminology needs adjustment
4. Distribute updated glossary to all stakeholders

**Prevention:** Establish metric glossary as Single Source of Truth (SSOT) before Phase 2

---

### Issue 1.3: GitHub Repository Access Issues

**Symptom:** Error: "404 Not Found" when accessing repo

**Root Cause:** Repository URL incorrect or user lacks permissions

**Solution:**
1. Verify repository exists: `https://github.com/DRIII33/aso-unified-commerce-engine`
2. Check user permissions: Repo should be public or user added as collaborator
3. If using SSH, verify SSH key is configured: `ssh -T git@github.com`
4. If using HTTPS, use personal access token (PAT) instead of password

**Prevention:** Confirm repository access during Phase 1 pre-flight checklist

---

## 2. Phase 2 Troubleshooting: Data Engineering

### Issue 2.1: Python Script Fails to Generate Data

**Symptom:** Error: `ModuleNotFoundError: No module named 'pandas'`

**Root Cause:** Python libraries not installed in Colab environment

**Solution:**
```python
# In Google Colab cell, install dependencies:
!pip install pandas numpy google-cloud-bigquery
```

**Prevention:** Include installation cell at top of Colab notebook

---

### Issue 2.2: BigQuery Table Creation Fails

**Symptom:** Error: `404 Not Found: Dataset driiiportfolio:aso_operations_2026 not found`

**Root Cause:** Dataset does not exist or project ID is incorrect

**Solution:**
1. Verify project ID: `driiiportfolio` in BigQuery console
2. Create dataset if missing:
   ```sql
   CREATE SCHEMA IF NOT EXISTS `driiiportfolio.aso_operations_2026`
   OPTIONS(
     location='US'
   );
   ```
3. Run table creation DDL from `sql/03_bigquery_table_creation_ddl.sql`

**Prevention:** Create dataset in Phase 2 pre-flight setup

---

### Issue 2.3: CSV Upload to BigQuery Fails

**Symptom:** Error: `Invalid value in column 'timestamp': '2026-04-01 00:00:00'`

**Root Cause:** BigQuery expects timestamp format: `YYYY-MM-DD HH:MM:SS` or ISO 8601

**Solution:**
1. In Python, format timestamp correctly:
   ```python
   df['timestamp'] = pd.to_datetime(df['timestamp']).dt.strftime('%Y-%m-%d %H:%M:%S')
   ```
2. In BigQuery web console, specify schema with TIMESTAMP type
3. During CSV upload, check "Auto-detect schema" is enabled

**Prevention:** Test CSV import on small sample first

---

### Issue 2.4: Data Quality Validation Fails

**Symptom:** Error: "Duplicate transactions detected: 15.2% of records (expected ~15%)"

**Root Cause:** Duplicate rate outside acceptable tolerance (±0.5%)

**Solution:**
1. Check synthetic data generation parameters in `src/data_generator.py`
2. Verify external payment duplication probability: should be 0.15 (15%)
3. Re-run data generation if parameters modified
4. If duplicates consistently high, update assumption in `docs/aso_business_assumptions.md`

**Prevention:** Document expected ranges in `sql/04_data_quality_checks.sql`

---

## 3. Phase 3 Troubleshooting: Analytical Development

### Issue 3.1: SQL Query Fails with Syntax Error

**Symptom:** Error: `Syntax error: Expected ")" but got "," at [1:45]`

**Root Cause:** BigQuery SQL syntax differs from Snowflake

**Solution:**
1. Verify you're using BigQuery dialect (not Snowflake)
2. Check common differences:
   - BigQuery: `TIMESTAMP_TRUNC()` not `DATE_TRUNC()`
   - BigQuery: `SAFE_DIVIDE(numerator, denominator)` 
   - BigQuery: `||` for string concatenation not supported; use `CONCAT()`
3. Reference `sql/01_revenue_deduplication.sql` for correct syntax

**Prevention:** Include SQL dialect comments at top of each query file

---

### Issue 3.2: Query Timeout (Query Killed After 10 Minutes)

**Symptom:** Error: `Query exceeded timeout of 600 seconds`

**Root Cause:** Query scans entire dataset without partitioning filter

**Solution:**
1. Add date range filter:
   ```sql
   WHERE DATE(timestamp) BETWEEN '2026-04-01' AND '2026-04-30'
   ```
2. Verify clustering is used efficiently
3. Check for full table scans; ensure WHERE clause indexes on clustered columns
4. If query still slow, break into smaller CTEs

**Prevention:** Include WHERE clause with date partition in all queries

---

### Issue 3.3: SQL Result Shows Unexpected Values

**Symptom:** "SPLH is negative; revenue deduplication producing negative totals"

**Root Cause:** Data quality issue or calculation error

**Solution:**
1. Run data quality checks: `sql/04_data_quality_checks.sql`
2. Verify deduplication logic:
   ```sql
   SELECT COUNT(*) as total_transactions,
          COUNTIF(duplicate_rank = 1) as kept_transactions,
          COUNTIF(duplicate_rank > 1) as removed_duplicates
   FROM `driiiportfolio.aso_operations_2026.aso_transactions_raw`;
   ```
3. If revenue is negative, check for data import issue (null amounts)
4. Verify SPLH calculation uses positive headcount values

**Prevention:** Include validation checks in all analytical queries

---

### Issue 3.4: Snowflake Equivalent Syntax Doesn't Match

**Symptom:** BigQuery query works but Snowflake equivalent fails

**Root Cause:** Platform-specific SQL dialect differences

**Solution:**
1. BigQuery vs. Snowflake function mappings:
   - `TIMESTAMP_TRUNC()` → `DATE_TRUNC()`
   - `SAFE_DIVIDE()` → `DIV0NULL()` or `CASE WHEN... THEN...`
   - `CONCAT()` → `||` (string concatenation)
   - `ROW_NUMBER()` → Same in both
2. Reference Snowflake documentation for equivalents
3. Test both versions in separate environments

**Prevention:** Document dialect differences in SQL file headers

---

## 4. Phase 4 Troubleshooting: Visualization & Reporting

### Issue 4.1: Looker Studio Cannot Connect to BigQuery

**Symptom:** Error: "Authentication failed. Invalid credentials."

**Root Cause:** OAuth connection not authorized or project not accessible

**Solution:**
1. In Looker Studio, go to "Data Sources" → Add new data source → Google BigQuery
2. Follow OAuth consent screen (may need to authorize)
3. Ensure you have access to `driiiportfolio` project
4. If still failing, check BigQuery project permissions:
   - Verify user has `BigQuery Data Viewer` role
   - Verify user has `BigQuery Job User` role
5. Grant permissions in Google Cloud Console

**Prevention:** Test Looker Studio connection before Phase 4 work begins

---

### Issue 4.2: Dashboard Shows No Data

**Symptom:** Charts appear blank; no error message

**Root Cause:** Data source query returning zero rows or incorrect table reference

**Solution:**
1. Verify table name in data source:
   - Should be: `driiiportfolio.aso_operations_2026.aso_transactions_raw`
   - NOT: `driiiportfolio.aso_transactions_raw` (missing dataset)
2. Run test query in BigQuery console to verify data exists:
   ```sql
   SELECT COUNT(*) FROM `driiiportfolio.aso_operations_2026.aso_transactions_raw`;
   ```
3. If test query returns 0, check that data was uploaded to BigQuery
4. Verify date range filter in dashboard is not excluding all records

**Prevention:** Validate data in BigQuery before creating Looker Studio charts

---

### Issue 4.3: Dashboard Filters Not Working

**Symptom:** Clicking filter dropdown shows no options

**Root Cause:** Filter field not properly linked to data source

**Solution:**
1. In Looker Studio, select filter → check data source is correct
2. Verify filter field matches a column in the table (e.g., `platform` column)
3. Ensure filter is of correct type (text filter for strings, date filter for dates)
4. Click "Apply" to activate filter
5. If still not working, delete and recreate filter

**Prevention:** Test each filter individually before finalizing dashboard

---

### Issue 4.4: Dashboard Refresh Slow

**Symptom:** Dashboard takes >30 seconds to load data

**Root Cause:** Query scans large amount of data or dashboard has too many charts

**Solution:**
1. Reduce number of charts on single page (max 8-10)
2. Add date range filter to restrict query scope
3. Verify BigQuery query performance:
   - Run query in BigQuery console, note execution time
   - Target: <5 seconds for analytical queries
4. If query slow in BigQuery, apply optimization from Issue 3.2
5. Split dashboard into multiple pages if necessary

**Prevention:** Test dashboard performance with full dataset before sharing with stakeholders

---

## 5. Cross-Phase Troubleshooting

### Issue 5.1: Project Timeline Slips

**Symptom:** Phase not completing by target date

**Root Cause:** Blockers, dependencies, or underestimated complexity

**Solution:**
1. Identify blocking issue from troubleshooting guide above
2. Escalate to stakeholder if issue requires business decision
3. Document blockers in CHANGELOG.md with resolution status
4. Adjust timeline if necessary (update PROJECT_CHARTER.md)
5. Communicate delay to stakeholders with new target date

**Prevention:** Build 20% buffer into timeline estimates

---

### Issue 5.2: Stakeholder Misalignment on Deliverable Quality

**Symptom:** "This dashboard doesn't show what I need"

**Root Cause:** Requirements not clearly captured in Phase 1

**Solution:**
1. Reference Phase 1 documentation (README, business assumptions)
2. Clarify what stakeholder needs vs. what was committed
3. If gap exists, document as change request
4. Update PROJECT_CHARTER.md scope if needed
5. Revise deliverable to meet new requirements

**Prevention:** Conduct detailed Phase 1 alignment with stakeholders

---

### Issue 5.3: Documentation Gaps

**Symptom:** "I don't know how to run the Python script"

**Root Cause:** Missing or unclear documentation

**Solution:**
1. Reference Phase 2 documentation (`phase_deliverables/phase_02_data_engineering.md`)
2. If gap exists, add documentation to GitHub
3. Include code comments explaining each step
4. Provide example Colab notebook link
5. Update README.md with quick-start guide

**Prevention:** Review documentation completeness checklist before phase gate

---

## 6. Support Escalation

### When to Escalate

| Issue Type | Escalation Path | Response Time |
|-----------|-----------------|----------------|
| Technical error (SQL, Python) | DRI research + troubleshoot | <2 hours |
| Data quality issue | DRI + Data Engineering | <4 hours |
| Stakeholder misalignment | DRI + Stakeholder meeting | <1 business day |
| Project timeline slip | DRI + Project Sponsor | <1 business day |
| Critical data loss | DRI + All stakeholders | Immediate |

### Contact Information

**Project Owner (DRI):** Daniel Rodriguez III (@DRIII33)  
**Repository:** https://github.com/DRIII33/aso-unified-commerce-engine  
**Issue Tracking:** GitHub Issues (aso-unified-commerce-engine repository)

---

**Document Owner:** Daniel Rodriguez III (@DRIII33)  
**Last Updated:** May 7, 2026  
**Status:** 🟢 Complete
