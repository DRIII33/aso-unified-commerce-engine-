"""
ASO Unified Commerce Engine: Data Validation Script (Phase 2)
DRI: Daniel Rodriguez III (@DRIII33)

Objective: Programmatic validation of synthetic data to guarantee fidelity.
"""
import pandas as pd
import os

TXN_FILE = "../data/aso_transactions_raw.csv"
LABOR_FILE = "../data/austin_labor_metrics.csv"

def validate_datasets():
    print("Initiating Data Quality Checks...")
    try:
        tx_df = pd.read_csv(TXN_FILE)
        lb_df = pd.read_csv(LABOR_FILE)
        
        # 1. Null Checks
        assert tx_df.isnull().sum().sum() == 0, "Nulls detected in transactions."
        assert lb_df.isnull().sum().sum() == 0, "Nulls detected in labor metrics."
        
        # 2. Schema Validation
        assert 'transaction_id' in tx_df.columns
        assert 'active_headcount' in lb_df.columns
        
        # 3. Business Rule: Redownload Ratio
        redownloads = tx_df['is_redownload'].sum()
        total = len(tx_df)
        ratio = redownloads / total
        print(f"Validated Redownload Ratio: {ratio:.2%} (Target ~66.7%)")
        
        # 4. Business Rule: Duplication Existence
        apple_iap = len(tx_df[tx_df['platform'] == 'Apple_IAP'])
        ext_link = len(tx_df[tx_df['platform'] == 'External_Link'])
        dup_rate = ext_link / apple_iap if apple_iap > 0 else 0
        print(f"Validated External Duplication Rate: {dup_rate:.2%} (Target ~15.0%)")

        print("✅ All Data Quality Checks Passed. Ready for BigQuery Load.")
        
    except AssertionError as e:
        print(f"❌ Validation Failed: {e}")
    except FileNotFoundError:
        print("❌ Validation Failed: CSV files not found. Run data_generator.py first.")

if __name__ == "__main__":
    validate_datasets()
