"""
ASO Unified Commerce Engine: Synthetic Data Generator (Phase 2)
DRI: Daniel Rodriguez III (@DRIII33)
Description: Generates synthetic transaction and labor data for April 2026 to model
Apple Store Online operations, external payment bifurcation, and algorithmic shifts.

Objective: Generate synthetic transaction and labor data reflecting the 2:1 redownload ratio,
the 15% duplicate attribution rate, and the Austin hub labor parameters.

"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random
import os

# --- Configuration ---
START_DATE = datetime(2026, 4, 1)
END_DATE = datetime(2026, 4, 30, 23, 59, 59)
OUTPUT_DIR = "../data"
NUM_USERS = 50000
DUPLICATION_RATE = 0.15 # 15% external payment leakage
REDOWNLOAD_RATE = 0.667 # 2:1 ratio
EARTHQUAKE_DATE = datetime(2026, 4, 26)

# Ensure output directory exists
os.makedirs(OUTPUT_DIR, exist_ok=True)

def generate_transaction_data():
    """Generates synthetic ASO transaction data with engineered duplicates."""
    print("Generating synthetic transaction data...")
    records = []
    current_date = START_DATE
    transaction_id = 1000000

    while current_date <= END_DATE:
        # Simulate peak hours (5 PM - 9 PM)
        is_peak = 17 <= current_date.hour <= 21
        base_volume = random.randint(150, 300) if is_peak else random.randint(50, 100)
        
        # Apply Keyword Earthquake impact
        if current_date >= EARTHQUAKE_DATE:
            base_volume = int(base_volume * 0.6) # 40% drop

        for _ in range(base_volume):
            user_id = random.randint(10000, 10000 + NUM_USERS)
            amount = round(random.uniform(0.99, 149.99), 2)
            is_redownload = random.random() < REDOWNLOAD_RATE
            
            # Base Apple IAP Transaction
            records.append({
                "transaction_id": f"TXN_{transaction_id}",
                "user_id": user_id,
                "timestamp": current_date + timedelta(seconds=random.randint(0, 3599)),
                "amount": amount,
                "platform": "Apple_IAP",
                "is_redownload": is_redownload
            })
            transaction_id += 1

            # Simulate External Link Leakage (15% duplication)
            if random.random() < DUPLICATION_RATE:
                records.append({
                    "transaction_id": f"TXN_{transaction_id}",
                    "user_id": user_id,
                    "timestamp": current_date + timedelta(seconds=random.randint(2, 10)), # Within 10 seconds
                    "amount": amount,
                    "platform": "External_Link",
                    "is_redownload": is_redownload
                })
                transaction_id += 1
                
        current_date += timedelta(hours=1)

    df = pd.DataFrame(records)
    # Shuffle dataset
    df = df.sample(frac=1).reset_index(drop=True)
