-- =====================================================================
-- PROJECT : Banking Loan Applications
-- FILE    : 02_exploratory_data_analysis.sql
-- PURPOSE : Row counts, data checks, distributions, and numeric summaries
-- DATABASE: MySQL 8.0+
-- =====================================================================

USE banking_loan_db;

-- 1. How many rows were loaded into each table?
SELECT 'dim_loan_application' AS table_name, COUNT(*) AS row_count
FROM dim_loan_application
UNION ALL
SELECT 'fact_loan_application', COUNT(*)
FROM fact_loan_application;

-- 2. Do all applications have a matching fact row?
SELECT COUNT(*) AS applications_without_fact
FROM dim_loan_application AS d
LEFT JOIN fact_loan_application AS f
    ON f.application_key = d.application_key
WHERE f.application_key IS NULL;

-- 3. Do all fact rows have a matching application?
SELECT COUNT(*) AS facts_without_application
FROM fact_loan_application AS f
LEFT JOIN dim_loan_application AS d
    ON d.application_key = f.application_key
WHERE d.application_key IS NULL;

-- 4. Preview a few applications with their loan values.
SELECT
    d.application_id, d.applicant_age, d.gender, d.loan_purpose,
    d.loan_status, f.loan_amount_inr, f.monthly_income_inr, f.credit_score
FROM dim_loan_application AS d
JOIN fact_loan_application AS f
    ON f.application_key = d.application_key
ORDER BY d.application_id
LIMIT 10;

-- 5. Check the application ID range and uniqueness.
SELECT
    COUNT(*) AS total_applications,
    COUNT(DISTINCT application_id) AS unique_application_ids
FROM dim_loan_application;

-- 6. Check for NULL values in required dimension columns.
SELECT
    SUM(application_id IS NULL) AS null_application_id,
    SUM(applicant_age IS NULL) AS null_applicant_age,
    SUM(gender IS NULL) AS null_gender,
    SUM(married IS NULL) AS null_married,
    SUM(dependents IS NULL) AS null_dependents,
    SUM(education IS NULL) AS null_education,
    SUM(employment_type IS NULL) AS null_employment_type,
    SUM(property_area IS NULL) AS null_property_area,
    SUM(loan_purpose IS NULL) AS null_loan_purpose,
    SUM(loan_status IS NULL) AS null_loan_status
FROM dim_loan_application;

-- 7. Check for NULL values in required fact columns.
SELECT
    SUM(monthly_income_inr IS NULL) AS null_monthly_income,
    SUM(coapplicant_income_inr IS NULL) AS null_coapplicant_income,
    SUM(loan_amount_inr IS NULL) AS null_loan_amount,
    SUM(loan_term_months IS NULL) AS null_loan_term,
    SUM(credit_score IS NULL) AS null_credit_score,
    SUM(existing_loans_count IS NULL) AS null_existing_loans
FROM fact_loan_application;

-- 8. What are the minimum, average, and maximum values for key measures?
SELECT
    MIN(monthly_income_inr) AS min_monthly_income,
    ROUND(AVG(monthly_income_inr), 2) AS avg_monthly_income,
    MAX(monthly_income_inr) AS max_monthly_income,
    MIN(loan_amount_inr) AS min_loan_amount,
    ROUND(AVG(loan_amount_inr), 2) AS avg_loan_amount,
    MAX(loan_amount_inr) AS max_loan_amount,
    ROUND(AVG(credit_score), 2) AS avg_credit_score
FROM fact_loan_application;

-- 9. What loan terms are present?
SELECT loan_term_months, COUNT(*) AS applications
FROM fact_loan_application
GROUP BY loan_term_months
ORDER BY loan_term_months;

-- 10. How are applications split by status?
SELECT loan_status, COUNT(*) AS applications
FROM dim_loan_application
GROUP BY loan_status
ORDER BY applications DESC;

-- 11. What are the distinct categories in the main descriptive columns?
SELECT DISTINCT gender FROM dim_loan_application ORDER BY gender;
SELECT DISTINCT married FROM dim_loan_application ORDER BY married;
SELECT DISTINCT dependents FROM dim_loan_application ORDER BY dependents;
SELECT DISTINCT education FROM dim_loan_application ORDER BY education;
SELECT DISTINCT employment_type FROM dim_loan_application ORDER BY employment_type;
SELECT DISTINCT property_area FROM dim_loan_application ORDER BY property_area;
SELECT DISTINCT loan_purpose FROM dim_loan_application ORDER BY loan_purpose;

-- 12. What is the age range of applicants?
SELECT
    MIN(applicant_age) AS youngest_applicant,
    ROUND(AVG(applicant_age), 1) AS average_age,
    MAX(applicant_age) AS oldest_applicant
FROM dim_loan_application;

-- 13. Are there values outside the expected ranges?
SELECT
    SUM(applicant_age < 18 OR applicant_age > 100) AS invalid_ages,
    SUM(dependents < 0) AS invalid_dependents
FROM dim_loan_application;

SELECT
    SUM(monthly_income_inr < 0) AS negative_monthly_incomes,
    SUM(loan_amount_inr <= 0) AS invalid_loan_amounts,
    SUM(credit_score < 300 OR credit_score > 900) AS invalid_credit_scores,
    SUM(loan_term_months <= 0) AS invalid_loan_terms
FROM fact_loan_application;
