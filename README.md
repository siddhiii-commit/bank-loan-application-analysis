# Bank Loan Application Analysis

**Python (Pandas) · MySQL 8 · Jupyter Notebook**  
**Status:** Cleaning and analytical scripts prepared; dashboard planned.

## Overview and business problem

This educational analysis explores loan application outcomes, applicant attributes, requested loan amounts, and credit indicators. The focus is descriptive analysis and transparent data cleaning, **not** building an approval system or predictive model.

## Dataset and privacy

The project uses a loan application CSV supplied during data analytics coursework. The original publisher, whether records are synthetic, and redistribution permissions are unverified. Therefore **the raw and cleaned applicant-level datasets are not published here**. Obtain an authorized copy from the course provider before reproducing the work. This repository is for educational analysis and must not be used to make lending decisions.

## Objectives and business questions

- Inspect data quality and standardize categorical and numeric fields.
- Measure application counts and approval/rejection rates.
- Compare application outcomes by purpose, employment, property area, education, and demographics.
- Examine requested loan values, income, credit-score bands, and existing loans.
- Identify descriptive segment patterns without assuming causation or fairness.

## Files

```text
notebooks/bank_loan_data_cleaning.ipynb
sql/01_create_tables_and_load.sql
sql/02_exploratory_data_analysis.sql
sql/03_business_insights.sql
requirements.txt
```

## Cleaning and data modeling

The notebook checks missing data, descriptive distributions, and duplicate application identifiers. It removes duplicates, strips text whitespace, standardizes selected categories, flags invalid age/income/credit scores as missing, applies median imputation to selected numeric fields and mode imputation to selected categorical fields, and converts dependents to integers.

The SQL models application descriptions in `dim_loan_application` and quantitative amounts in `fact_loan_application`, joined through an application key. It includes primary, unique, foreign-key, and range checks. The EDA script checks integrity, missingness, ranges, and distributions. The business script contains 25 comparative queries.

## KPI definitions

The scripts define total applications, approved/rejected counts, approval percentage, requested loan amount, average applicant income, average credit score, and segment-level approval rates. These metrics are available as SQL queries; **no independently validated outcome numbers are asserted here**.

## Reproduction

1. Obtain a permitted copy of `banking_loan_applications_messy.csv` from the course provider. Keep it privately at `data/private/`.
2. Install Python packages with `pip install -r requirements.txt`, then run `notebooks/bank_loan_data_cleaning.ipynb` from the notebooks directory.
3. Replace `/REPLACE_WITH_ABSOLUTE_PATH_TO_PRIVATE_DATA/` in `sql/01_create_tables_and_load.sql` with the absolute folder containing the cleaned CSV. Ensure MySQL 8 supports `LOCAL INFILE` for your environment.
4. Run the SQL files in numbered order in MySQL Workbench. Inspect the dimension/fact row counts and query results.

The notebook is supplied without saved execution outputs, and SQL results were not independently verified here. Do not treat imputed values as observed facts; consider sensitivity analyses for imputation choices.

## Status and next steps

- Completed in supplied files: Python cleaning notebook, MySQL model, EDA checks, and 25 business-question queries.
- To validate: End-to-end rerun with authorized data, documented results, and checks for potentially misleading demographic comparisons.
- Planned: Power BI dashboard, verified findings and actionable recommendations, and screenshots.

No dashboard, credit-risk model, or automated loan approval service is claimed.
