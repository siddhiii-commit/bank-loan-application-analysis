-- =====================================================================
-- PROJECT : Banking Loan Applications
-- FILE    : 03_business_insights.sql
-- PURPOSE : Business questions about approval, risk, and loan portfolio
-- DATABASE: MySQL 8.0+
-- =====================================================================

USE banking_loan_db;

-- 1. What is the overall approval rate?
SELECT
    COUNT(*) AS total_applications,
    SUM(d.loan_status = 'Approved') AS approved_applications,
    ROUND(100.0 * SUM(d.loan_status = 'Approved') / COUNT(*), 2) AS approval_rate_pct
FROM dim_loan_application AS d;

-- 2. How many applications and approvals are there by loan purpose?
SELECT
    d.loan_purpose,
    COUNT(*) AS applications,
    SUM(d.loan_status = 'Approved') AS approved,
    ROUND(100.0 * SUM(d.loan_status = 'Approved') / COUNT(*), 2) AS approval_rate_pct
FROM dim_loan_application AS d
GROUP BY d.loan_purpose
ORDER BY approval_rate_pct DESC;

-- 3. Which property area has the highest approval rate?
SELECT
    d.property_area,
    COUNT(*) AS applications,
    ROUND(100.0 * SUM(d.loan_status = 'Approved') / COUNT(*), 2) AS approval_rate_pct
FROM dim_loan_application AS d
GROUP BY d.property_area
ORDER BY approval_rate_pct DESC;

-- 4. Does approval rate differ by employment type?
SELECT
    d.employment_type,
    COUNT(*) AS applications,
    ROUND(100.0 * SUM(d.loan_status = 'Approved') / COUNT(*), 2) AS approval_rate_pct
FROM dim_loan_application AS d
GROUP BY d.employment_type
ORDER BY approval_rate_pct DESC;

-- 5. How does education relate to application outcomes?
SELECT
    d.education,
    COUNT(*) AS applications,
    SUM(d.loan_status = 'Approved') AS approved,
    ROUND(100.0 * SUM(d.loan_status = 'Approved') / COUNT(*), 2) AS approval_rate_pct
FROM dim_loan_application AS d
GROUP BY d.education
ORDER BY approval_rate_pct DESC;

-- 6. How does the approval rate differ by gender?
SELECT
    d.gender,
    COUNT(*) AS applications,
    ROUND(100.0 * SUM(d.loan_status = 'Approved') / COUNT(*), 2) AS approval_rate_pct
FROM dim_loan_application AS d
GROUP BY d.gender
ORDER BY d.gender;

-- 7. How does marital status relate to approval outcomes?
SELECT
    d.married,
    COUNT(*) AS applications,
    ROUND(100.0 * SUM(d.loan_status = 'Approved') / COUNT(*), 2) AS approval_rate_pct
FROM dim_loan_application AS d
GROUP BY d.married
ORDER BY d.married;

-- 8. What is the approval rate for each number of dependents?
SELECT
    d.dependents,
    COUNT(*) AS applications,
    ROUND(100.0 * SUM(d.loan_status = 'Approved') / COUNT(*), 2) AS approval_rate_pct
FROM dim_loan_application AS d
GROUP BY d.dependents
ORDER BY d.dependents;

-- 9. How does approval vary across applicant age groups?
SELECT
    CASE
        WHEN d.applicant_age < 30 THEN 'Under 30'
        WHEN d.applicant_age < 45 THEN '30 to 44'
        WHEN d.applicant_age < 60 THEN '45 to 59'
        ELSE '60 and above'
    END AS age_group,
    COUNT(*) AS applications,
    ROUND(100.0 * SUM(d.loan_status = 'Approved') / COUNT(*), 2) AS approval_rate_pct
FROM dim_loan_application AS d
GROUP BY age_group
ORDER BY MIN(d.applicant_age);

-- 10. What is the average requested loan amount by application status?
SELECT
    d.loan_status,
    COUNT(*) AS applications,
    ROUND(AVG(f.loan_amount_inr), 2) AS average_loan_amount_inr
FROM dim_loan_application AS d
JOIN fact_loan_application AS f ON f.application_key = d.application_key
GROUP BY d.loan_status;

-- 11. What requested loan value is associated with approved and rejected applications?
SELECT
    ROUND(SUM(f.loan_amount_inr), 2) AS total_requested_inr,
    ROUND(SUM(CASE WHEN d.loan_status = 'Approved' THEN f.loan_amount_inr ELSE 0 END), 2)
        AS approved_requested_loan_value_inr,
    ROUND(SUM(CASE WHEN d.loan_status = 'Rejected' THEN f.loan_amount_inr ELSE 0 END), 2)
        AS rejected_requested_loan_value_inr
FROM dim_loan_application AS d
JOIN fact_loan_application AS f ON f.application_key = d.application_key;

-- 12. What is the average loan amount by loan purpose?
SELECT
    d.loan_purpose,
    COUNT(*) AS applications,
    ROUND(AVG(f.loan_amount_inr), 2) AS average_loan_amount_inr
FROM dim_loan_application AS d
JOIN fact_loan_application AS f ON f.application_key = d.application_key
GROUP BY d.loan_purpose
ORDER BY average_loan_amount_inr DESC;

-- 13. What is the average loan-to-monthly-income ratio by outcome?
-- This is a simple comparison, not a full affordability assessment.
SELECT
    d.loan_status,
    ROUND(AVG(f.loan_amount_inr / NULLIF(f.monthly_income_inr, 0)), 2)
        AS average_loan_to_monthly_income_ratio
FROM dim_loan_application AS d
JOIN fact_loan_application AS f ON f.application_key = d.application_key
GROUP BY d.loan_status;

-- 14. Does a co-applicant relate to the approval rate?
SELECT
    CASE WHEN f.coapplicant_income_inr > 0 THEN 'Has co-applicant income'
         ELSE 'No co-applicant income' END AS coapplicant_group,
    COUNT(*) AS applications,
    ROUND(100.0 * SUM(d.loan_status = 'Approved') / COUNT(*), 2) AS approval_rate_pct
FROM dim_loan_application AS d
JOIN fact_loan_application AS f ON f.application_key = d.application_key
GROUP BY coapplicant_group;

-- 15. How does credit score band relate to the approval rate?
SELECT
    CASE
        WHEN f.credit_score < 600 THEN 'Below 600'
        WHEN f.credit_score < 700 THEN '600 to 699'
        WHEN f.credit_score < 750 THEN '700 to 749'
        ELSE '750 and above'
    END AS credit_score_band,
    COUNT(*) AS applications,
    ROUND(100.0 * SUM(d.loan_status = 'Approved') / COUNT(*), 2) AS approval_rate_pct
FROM dim_loan_application AS d
JOIN fact_loan_application AS f ON f.application_key = d.application_key
GROUP BY credit_score_band
ORDER BY MIN(f.credit_score);

-- 16. What are the approval rates by existing loan count?
SELECT
    f.existing_loans_count,
    COUNT(*) AS applications,
    ROUND(100.0 * SUM(d.loan_status = 'Approved') / COUNT(*), 2) AS approval_rate_pct
FROM dim_loan_application AS d
JOIN fact_loan_application AS f ON f.application_key = d.application_key
GROUP BY f.existing_loans_count
ORDER BY f.existing_loans_count;

-- 17. Which loan terms are most commonly requested?
SELECT
    f.loan_term_months,
    COUNT(*) AS applications,
    ROUND(AVG(f.loan_amount_inr), 2) AS average_loan_amount_inr
FROM fact_loan_application AS f
GROUP BY f.loan_term_months
ORDER BY applications DESC, f.loan_term_months;

-- 18. What is the approval rate by requested loan term?
SELECT
    f.loan_term_months,
    COUNT(*) AS applications,
    ROUND(100.0 * SUM(d.loan_status = 'Approved') / COUNT(*), 2) AS approval_rate_pct
FROM dim_loan_application AS d
JOIN fact_loan_application AS f ON f.application_key = d.application_key
GROUP BY f.loan_term_months
ORDER BY f.loan_term_months;

-- 19. How do average applicant and co-applicant incomes compare by outcome?
SELECT
    d.loan_status,
    ROUND(AVG(f.monthly_income_inr), 2) AS average_applicant_income_inr,
    ROUND(AVG(f.coapplicant_income_inr), 2) AS average_coapplicant_income_inr
FROM dim_loan_application AS d
JOIN fact_loan_application AS f ON f.application_key = d.application_key
GROUP BY d.loan_status;

-- 20. What percentage of applications request a loan above INR 500,000?
SELECT
    COUNT(*) AS applications,
    SUM(f.loan_amount_inr > 500000) AS applications_above_500k,
    ROUND(100.0 * SUM(f.loan_amount_inr > 500000) / COUNT(*), 2) AS above_500k_pct
FROM fact_loan_application AS f;

-- 21. Which applicant segments have the most rejected applications?
SELECT
    d.employment_type,
    d.property_area,
    COUNT(*) AS rejected_applications
FROM dim_loan_application AS d
WHERE d.loan_status = 'Rejected'
GROUP BY d.employment_type, d.property_area
ORDER BY rejected_applications DESC
LIMIT 10;

-- 22. What is the approval rate for applicants with and without existing loans?
SELECT
    CASE WHEN f.existing_loans_count > 0 THEN 'Has existing loans'
         ELSE 'No existing loans' END AS existing_loan_group,
    COUNT(*) AS applications,
    ROUND(100.0 * SUM(d.loan_status = 'Approved') / COUNT(*), 2) AS approval_rate_pct
FROM dim_loan_application AS d
JOIN fact_loan_application AS f ON f.application_key = d.application_key
GROUP BY existing_loan_group;

-- 23. Which loan purposes have the largest requested amount among approved applications?
SELECT
    d.loan_purpose,
    COUNT(*) AS approved_applications,
    ROUND(SUM(f.loan_amount_inr), 2) AS approved_requested_loan_value_inr
FROM dim_loan_application AS d
JOIN fact_loan_application AS f ON f.application_key = d.application_key
WHERE d.loan_status = 'Approved'
GROUP BY d.loan_purpose
ORDER BY approved_requested_loan_value_inr DESC;

-- 24. What is the rejection rate in each credit score band?
SELECT
    CASE
        WHEN f.credit_score < 600 THEN 'Below 600'
        WHEN f.credit_score < 700 THEN '600 to 699'
        WHEN f.credit_score < 750 THEN '700 to 749'
        ELSE '750 and above'
    END AS credit_score_band,
    COUNT(*) AS applications,
    ROUND(100.0 * SUM(d.loan_status = 'Rejected') / COUNT(*), 2) AS rejection_rate_pct
FROM dim_loan_application AS d
JOIN fact_loan_application AS f ON f.application_key = d.application_key
GROUP BY credit_score_band
ORDER BY MIN(f.credit_score);

-- 25. What is the average existing-loan count by application status?
SELECT
    d.loan_status,
    ROUND(AVG(f.existing_loans_count), 2) AS average_existing_loans
FROM dim_loan_application AS d
JOIN fact_loan_application AS f ON f.application_key = d.application_key
GROUP BY d.loan_status;
