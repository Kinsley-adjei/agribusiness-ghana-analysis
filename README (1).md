# Agribusiness Analysis in Ghana

**Author:** Kinsley Delanyo Adjei  
**Affiliation:** Department of Agricultural Economics, University of Ghana  
**Contact:** kinsley.dadjei@gmail.com

---

## Overview

This repository contains Stata code for a structural and performance analysis of Ghana's agribusiness sector. The analysis was conducted for Dr. Abigail A. Adaku and covers business distribution, ownership patterns, revenue, costs, profit, and labour productivity across agribusiness value chains in Ghana.

The script integrates three nationally representative datasets to produce a comprehensive picture of agribusiness activity — from farm production through to retail — classified by the International Standard Industrial Classification (ISIC Rev. 4).

---

## Datasets

| Dataset | Source | Year | Coverage |
|---|---|---|---|
| Integrated Business Establishment Survey (IBES) | Ghana Statistical Service | 2024 | ~650,000 businesses nationally |
| Integrated Business Establishment Survey (IBES) | Ghana Statistical Service | 2014 | ~141,000 businesses nationally |
| Ghana Socioeconomic Panel Survey (GSEPS) Wave 3 | University of Ghana / World Bank | 2018/19 | Household and enterprise panel |

> **Note:** The datasets are not included in this repository as they are proprietary to the Ghana Statistical Service and the University of Ghana. Access can be requested through the respective institutions.

---

## What the Script Does

The analysis is organised into six sections:

**Section 0 — Setup**  
Defines ISIC labels and a reusable classification program (`assign_categories`) that assigns each business to a value chain stage and sub-sector. This eliminates repetition across all three datasets.

**Section 1 — IBES 2024 Structure & Performance**  
- Distribution of agribusinesses by region, district, ownership type, and business size  
- Revenue brackets and employment statistics by sub-sector  
- Revenue-per-employee ratios across value chain stages  
- Export participation, digital finance adoption, and regulatory compliance patterns

**Section 2 — IBES 2014 Trend Comparison**  
Mirrors Section 1 using the 2014 survey wave to enable trend analysis. Includes a district-to-region recoding to harmonise the 2014 10-region structure with Ghana's current 16-region administrative boundaries.

**Section 3A — GSEPS: Employment Income by ISIC**  
Mean paid employment income for farm owners and business owners by ISIC code.

**Section 3B–3C — GSEPS: Business Revenue, Cost & Profit**  
Annualised profit, revenue, and cost from the GSEPS enterprise module. Computes revenue-per-employee by business size and sub-sector.

**Section 3D — GSEPS: Agricultural Revenue, Cost & Profit**  
Constructs crop-level revenue from nine buyer channels (traders, cooperatives, aggregators, etc.), merges with labour and input costs (land, ploughing, seed), and computes plot-level profit. Converts in-kind plough payments to cash equivalents using market prices.

**Section 3E–3F — Combined Dataset & Final Tables**  
Appends business and agricultural datasets into a unified file and produces summary tables of key metrics (profit, revenue, cost, employees, revenue per employee) by ISIC code and sub-sector.

---

## Methods

- **Data cleaning:** Missing data identified with `mdesc`; observations with missing values on key variables dropped (< 0.5% of data in each wave)
- **Classification:** ISIC Rev. 4 codes mapped to six value chain stages and eleven sub-sectors
- **Annualisation:** Profit reported over varying periods (daily to annual) converted to annual equivalents using a multiplier variable
- **Revenue construction:** Crop revenue computed as quantity × price across nine market channels; in-kind payments valued at prevailing market prices
- **Summary statistics:** `tabstat`, `collapse`, and `table` used to produce mean, median, SD, min, max, and count by ISIC and sub-sector

---

## Repository Structure

```
agribusiness-ghana-analysis/
│
├── README.md
└── Kinsley_Adjei_Coding_Sample.do   # Main analysis script
```

---

## How to Run

1. Clone or download this repository
2. Obtain access to the IBES 2024, IBES 2014, and GSEPS Wave 3 datasets from the Ghana Statistical Service and University of Ghana respectively
3. Update the working directory paths at the top of each section in the `.do` file to match your local folder structure
4. Run the script in Stata 14 or later
5. Uncomment `ssc install mdesc` on the first run if `mdesc` is not already installed

---

## Skills Demonstrated

- Large-scale survey data cleaning and management (650,000+ observations)
- Multi-dataset merging and appending across survey waves
- ISIC industry classification and value chain mapping
- Annualisation of financial variables across reporting periods
- In-kind payment valuation
- Reusable Stata programs to eliminate code repetition
- Summary statistics and tabulation for policy-oriented reporting

