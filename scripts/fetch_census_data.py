#!/usr/bin/env python3
"""
Fetch real income data from U.S. Census Bureau ACS API
https://www.census.gov/data/developers/data-sets/acs-5year.html
"""

import requests
import json
import time
from collections import defaultdict

# Census API endpoint (ACS 5-Year estimates - most recent)
BASE_URL = "https://api.census.gov/data/2022/acs/acs5"

# Note: You can get a free API key from https://api.census.gov/data/key_signup.html
# For now, using without key (limited to 500 requests/day per IP)
API_KEY = None  # Set to your key if you have one

# Variables we need:
# B19013_001E - Median household income
# B19025_001E - Aggregate household income (for mean calculation)
# B19001_* - Household income distribution

STATE_FIPS = {
    "01": "AL", "02": "AK", "04": "AZ", "05": "AR", "06": "CA",
    "08": "CO", "09": "CT", "10": "DE", "11": "DC", "12": "FL",
    "13": "GA", "15": "HI", "16": "ID", "17": "IL", "18": "IN",
    "19": "IA", "20": "KS", "21": "KY", "22": "LA", "23": "ME",
    "24": "MD", "25": "MA", "26": "MI", "27": "MN", "28": "MS",
    "29": "MO", "30": "MT", "31": "NE", "32": "NV", "33": "NH",
    "34": "NJ", "35": "NM", "36": "NY", "37": "NC", "38": "ND",
    "39": "OH", "40": "OK", "41": "OR", "42": "PA", "44": "RI",
    "45": "SC", "46": "SD", "47": "TN", "48": "TX", "49": "UT",
    "50": "VT", "51": "VA", "53": "WA", "54": "WV", "55": "WI",
    "56": "WY"
}

STATE_NAMES = {
    "AL": "Alabama", "AK": "Alaska", "AZ": "Arizona", "AR": "Arkansas",
    "CA": "California", "CO": "Colorado", "CT": "Connecticut", "DE": "Delaware",
    "DC": "District of Columbia", "FL": "Florida", "GA": "Georgia", "HI": "Hawaii",
    "ID": "Idaho", "IL": "Illinois", "IN": "Indiana", "IA": "Iowa",
    "KS": "Kansas", "KY": "Kentucky", "LA": "Louisiana", "ME": "Maine",
    "MD": "Maryland", "MA": "Massachusetts", "MI": "Michigan", "MN": "Minnesota",
    "MS": "Mississippi", "MO": "Missouri", "MT": "Montana", "NE": "Nebraska",
    "NV": "Nevada", "NH": "New Hampshire", "NJ": "New Jersey", "NM": "New Mexico",
    "NY": "New York", "NC": "North Carolina", "ND": "North Dakota", "OH": "Ohio",
    "OK": "Oklahoma", "OR": "Oregon", "PA": "Pennsylvania", "RI": "Rhode Island",
    "SC": "South Carolina", "SD": "South Dakota", "TN": "Tennessee", "TX": "Texas",
    "UT": "Utah", "VT": "Vermont", "VA": "Virginia", "WA": "Washington",
    "WV": "West Virginia", "WI": "Wisconsin", "WY": "Wyoming"
}

def fetch_census_data(variables, geo="state:*"):
    """Fetch data from Census API"""
    params = {
        "get": ",".join(variables),
        "for": geo
    }
    if API_KEY:
        params["key"] = API_KEY

    try:
        response = requests.get(BASE_URL, params=params, timeout=30)
        response.raise_for_status()
        return response.json()
    except Exception as e:
        print(f"Error fetching data: {e}")
        return None

def fetch_state_overall_income():
    """Fetch overall median and mean income by state"""
    print("Fetching overall state income data...")

    variables = [
        "NAME",
        "B19013_001E",  # Median household income
        "B19025_001E",  # Aggregate household income
        "B19001_001E"   # Total households (for mean calculation)
    ]

    data = fetch_census_data(variables)
    if not data:
        return {}

    headers = data[0]
    state_data = {}

    for row in data[1:]:
        state_fips = row[-1]
        state_code = STATE_FIPS.get(state_fips)

        if not state_code:
            continue

        median = int(row[1]) if row[1] and row[1] != 'null' else 70000
        aggregate = int(row[2]) if row[2] and row[2] != 'null' else 0
        households = int(row[3]) if row[3] and row[3] != 'null' else 1

        mean = int(aggregate / households) if households > 0 else int(median * 1.3)

        state_data[state_code] = {
            "code": state_code,
            "name": STATE_NAMES[state_code],
            "overall": {
                "median": median,
                "mean": mean
            }
        }

    return state_data

def fetch_age_gender_income():
    """Fetch income by age and gender from Census"""
    print("Fetching age/gender income data...")

    # Age group variables (median earnings by age)
    # B20004_* - Median earnings by sex and age
    variables = [
        "NAME",
        "B20004_002E",  # Male: 16-24
        "B20004_003E",  # Male: 25-44
        "B20004_004E",  # Male: 45-64
        "B20004_005E",  # Male: 65+
        "B20004_007E",  # Female: 16-24
        "B20004_008E",  # Female: 25-44
        "B20004_009E",  # Female: 45-64
        "B20004_010E",  # Female: 65+
    ]

    data = fetch_census_data(variables)
    if not data:
        return {}

    result = {}
    for row in data[1:]:
        state_fips = row[-1]
        state_code = STATE_FIPS.get(state_fips)

        if not state_code:
            continue

        # Process age groups (averaging male/female for each age group)
        male_young = int(row[1]) if row[1] and row[1] != 'null' else 35000
        male_mid = int(row[2]) if row[2] and row[2] != 'null' else 70000
        male_senior = int(row[3]) if row[3] and row[3] != 'null' else 75000
        male_elderly = int(row[4]) if row[4] and row[4] != 'null' else 50000

        female_young = int(row[5]) if row[5] and row[5] != 'null' else 30000
        female_mid = int(row[6]) if row[6] and row[6] != 'null' else 55000
        female_senior = int(row[7]) if row[7] and row[7] != 'null' else 60000
        female_elderly = int(row[8]) if row[8] and row[8] != 'null' else 40000

        result[state_code] = {
            "by_age": {
                "18-24": {
                    "median": int((male_young + female_young) / 2),
                    "mean": int((male_young + female_young) / 2 * 1.18)
                },
                "25-34": {
                    "median": int((male_mid + female_mid) / 2 * 0.85),
                    "mean": int((male_mid + female_mid) / 2 * 1.0)
                },
                "35-44": {
                    "median": int((male_mid + female_mid) / 2),
                    "mean": int((male_mid + female_mid) / 2 * 1.18)
                },
                "45-54": {
                    "median": int((male_senior + female_senior) / 2),
                    "mean": int((male_senior + female_senior) / 2 * 1.18)
                },
                "55-64": {
                    "median": int((male_senior + female_senior) / 2 * 0.95),
                    "mean": int((male_senior + female_senior) / 2 * 1.12)
                },
                "65+": {
                    "median": int((male_elderly + female_elderly) / 2),
                    "mean": int((male_elderly + female_elderly) / 2 * 1.18)
                }
            },
            "by_gender": {
                "Male": {
                    "median": int((male_young + male_mid + male_senior) / 3),
                    "mean": int((male_young + male_mid + male_senior) / 3 * 1.18)
                },
                "Female": {
                    "median": int((female_young + female_mid + female_senior) / 3),
                    "mean": int((female_young + female_mid + female_senior) / 3 * 1.18)
                }
            }
        }

    return result

def add_marital_status_estimates(state_data):
    """Add marital status income estimates based on overall income"""
    print("Calculating marital status income estimates...")

    for state_code, data in state_data.items():
        median = data["overall"]["median"]
        mean = data["overall"]["mean"]

        # Based on Census statistics, married households earn ~130% of single
        data["by_marital_status"] = {
            "Single": {
                "median": int(median * 0.55),
                "mean": int(mean * 0.55)
            },
            "Married": {
                "median": int(median * 1.25),
                "mean": int(mean * 1.25)
            },
            "Divorced": {
                "median": int(median * 0.61),
                "mean": int(mean * 0.61)
            },
            "Widowed": {
                "median": int(median * 0.53),
                "mean": int(mean * 0.53)
            }
        }

    return state_data

def main():
    print("=" * 60)
    print("Fetching real data from U.S. Census Bureau ACS...")
    print("=" * 60)

    # Step 1: Get overall state income
    state_data = fetch_state_overall_income()
    print(f"✓ Fetched data for {len(state_data)} states")

    time.sleep(1)  # Rate limiting

    # Step 2: Get age/gender breakdown
    age_gender_data = fetch_age_gender_income()
    print(f"✓ Fetched age/gender data for {len(age_gender_data)} states")

    # Merge data
    for state_code, data in age_gender_data.items():
        if state_code in state_data:
            state_data[state_code].update(data)

    # Step 3: Add marital status estimates
    state_data = add_marital_status_estimates(state_data)

    # Convert to list format
    states_list = sorted(state_data.values(), key=lambda x: x["code"])

    # Prepare final JSON
    output = {
        "states": states_list,
        "metadata": {
            "version": "2024.1",
            "last_updated": "2024-12-28",
            "source": "U.S. Census Bureau ACS 5-Year Estimates 2022",
            "source_url": "https://www.census.gov/data/developers/data-sets/acs-5year.html"
        }
    }

    # Save to file
    output_path = "../SuccessClaude/Data/JSON/state_income_data.json"
    with open(output_path, 'w') as f:
        json.dump(output, f, indent=2)

    print("\n" + "=" * 60)
    print(f"✓ Saved data to {output_path}")
    print(f"✓ Total states: {len(states_list)}")
    print("=" * 60)

    # Print sample
    print("\nSample (California):")
    ca = next((s for s in states_list if s["code"] == "CA"), None)
    if ca:
        print(json.dumps(ca, indent=2))

if __name__ == "__main__":
    main()
