[README.md](https://github.com/user-attachments/files/26912895/README.md)
# healthcare-sql-claims-analysis# Healthcare SQL Portfolio Project – Claims & Cost Analysis

## Overview
This project simulates a healthcare claims analytics environment using realistic sample datasets.
The objective is to analyze claims, payments, provider performance, and patient cost patterns using SQL.

This project is designed as an intermediate-level SQL portfolio project and is written in Oracle SQL style.

## Business Problem
Healthcare organizations process a large number of claims across patients, providers, and specialties.
Key business questions include:

- Which patients generate the highest healthcare costs?
- Which providers submit the largest claim amounts?
- What percentage of claims are approved, denied, or pending?
- Which claims remain unpaid or partially paid?
- Which specialties or states drive the highest healthcare costs?

## Dataset Structure

### 1. patients
Stores patient demographic details.

Columns:
- patient_id
- patient_name
- age
- gender
- state

### 2. providers
Stores healthcare provider information.

Columns:
- provider_id
- provider_name
- specialty
- state

### 3. claims
Stores claim-level transaction data.

Columns:
- claim_id
- patient_id
- provider_id
- claim_amount
- claim_date
- status
- diagnosis_category

### 4. payments
Stores payment details against claims.

Columns:
- payment_id
- claim_id
- paid_amount
- payment_date
- payment_method

## Project Structure

```text
healthcare_sql_portfolio_project/
│
├── README.md
├── schema.sql
├── queries.sql
└── data/
    ├── patients.csv
    ├── providers.csv
    ├── claims.csv
    └── payments.csv
```

## SQL Concepts Demonstrated
- Joins (INNER JOIN, LEFT JOIN)
- Aggregations (COUNT, SUM, AVG)
- Grouping and filtering
- CASE expressions
- Null handling with NVL
- Window functions:
  - ROW_NUMBER()
  - DENSE_RANK()
  - SUM() OVER for running totals
- Subqueries
- Percentage calculations
- Ranking and top-N analysis

## Key Analysis Covered

### Claims Analysis
- Total claims count
- Monthly claim trend
- Claim status distribution
- Claim amount bucket analysis

### Patient Analysis
- Top highest-cost patients
- Average claim amount per patient
- Patients with repeated claims
- Patient-level outstanding balance summary

### Provider Analysis
- Top providers by claim amount
- Provider denial rate
- Provider performance summary
- Specialty-wise cost analysis

### Payment Analysis
- Outstanding unpaid or partially paid claims
- Payment vs claim variance
- Claims with no payment record
- Patients with high paid amounts

### Advanced SQL
- Top 3 claims by state using ROW_NUMBER()
- Rank providers using DENSE_RANK()
- Running monthly claim totals
- Highest claim per diagnosis category

## How to Run
1. Create tables using schema.sql
2. Load CSV files from the data/ folder
3. Run queries from queries.sql

## Sample Portfolio Value
This project demonstrates how SQL can be used to solve real-world healthcare analytics problems such as:
- cost analysis
- claims tracking
- provider performance evaluation
- outstanding payment monitoring

It is suitable for showcasing skills relevant to:
- SQL Developer roles
- Data Analyst roles
- Business Intelligence roles
- Data Engineering transition portfolios

## Author
**Sai Naren Burgula**
