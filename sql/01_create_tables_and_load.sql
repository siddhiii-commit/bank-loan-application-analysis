-- =====================================================================
-- PROJECT : Banking Loan Applications
-- FILE    : 01_create_tables_and_load.sql
-- PURPOSE : Create the dimension and fact tables, then load the cleaned CSV
-- DATABASE: MySQL 8.0+
-- =====================================================================
-- Run this file in MySQL Workbench.
-- The CSV path below is the cleaned file created for this project.
-- If LOCAL INFILE is disabled, enable it in MySQL Workbench / MySQL Server
-- settings, reconnect, and run this file again.

CREATE DATABASE IF NOT EXISTS banking_loan_db;
USE banking_loan_db;

-- The dimension stores application and applicant descriptions.
CREATE TABLE IF NOT EXISTS dim_loan_application (
    application_key INT NOT NULL AUTO_INCREMENT,
    application_id VARCHAR(20) NOT NULL,
    applicant_age INT NOT NULL,
    gender VARCHAR(20) NOT NULL,
    married VARCHAR(5) NOT NULL,
    dependents INT NOT NULL,
    education VARCHAR(30) NOT NULL,
    employment_type VARCHAR(30) NOT NULL,
    property_area VARCHAR(20) NOT NULL,
    loan_purpose VARCHAR(30) NOT NULL,
    loan_status VARCHAR(20) NOT NULL,
    PRIMARY KEY (application_key),
    UNIQUE KEY uq_application_id (application_id),
    CHECK (applicant_age BETWEEN 18 AND 100),
    CHECK (dependents >= 0),
    CHECK (loan_status IN ('Approved', 'Rejected'))
);

-- The fact table stores the measurable loan and income values.
CREATE TABLE IF NOT EXISTS fact_loan_application (
    loan_fact_key BIGINT NOT NULL AUTO_INCREMENT,
    application_key INT NOT NULL,
    monthly_income_inr DECIMAL(15,2) NOT NULL,
    coapplicant_income_inr DECIMAL(15,2) NOT NULL,
    loan_amount_inr DECIMAL(15,2) NOT NULL,
    loan_term_months INT NOT NULL,
    credit_score INT NOT NULL,
    existing_loans_count INT NOT NULL,
    PRIMARY KEY (loan_fact_key),
    UNIQUE KEY uq_fact_application (application_key),
    CONSTRAINT fk_fact_application
        FOREIGN KEY (application_key)
        REFERENCES dim_loan_application (application_key),
    CHECK (monthly_income_inr >= 0),
    CHECK (coapplicant_income_inr >= 0),
    CHECK (loan_amount_inr > 0),
    CHECK (loan_term_months > 0),
    CHECK (credit_score BETWEEN 300 AND 900),
    CHECK (existing_loans_count >= 0)
);

-- A temporary import table is used only to transfer the CSV into the
-- two project tables. It is dropped automatically when the session ends.
DROP TEMPORARY TABLE IF EXISTS loan_applications_import;
CREATE TEMPORARY TABLE loan_applications_import (
    application_id VARCHAR(20) NOT NULL,
    applicant_age INT NOT NULL,
    gender VARCHAR(20) NOT NULL,
    married VARCHAR(5) NOT NULL,
    dependents INT NOT NULL,
    education VARCHAR(30) NOT NULL,
    employment_type VARCHAR(30) NOT NULL,
    monthly_income_inr DECIMAL(15,2) NOT NULL,
    coapplicant_income_inr DECIMAL(15,2) NOT NULL,
    loan_amount_inr DECIMAL(15,2) NOT NULL,
    loan_term_months INT NOT NULL,
    credit_score INT NOT NULL,
    existing_loans_count INT NOT NULL,
    property_area VARCHAR(20) NOT NULL,
    loan_purpose VARCHAR(30) NOT NULL,
    loan_status VARCHAR(20) NOT NULL
);

LOAD DATA LOCAL INFILE
'/REPLACE_WITH_ABSOLUTE_PATH_TO_PRIVATE_DATA/banking_loan_applications_cleaned.csv'
INTO TABLE loan_applications_import
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Insert descriptions first so the fact table can reference them.
INSERT INTO dim_loan_application (
    application_id, applicant_age, gender, married, dependents,
    education, employment_type, property_area, loan_purpose, loan_status
)
SELECT
    i.application_id, i.applicant_age, i.gender, i.married, i.dependents,
    i.education, i.employment_type, i.property_area, i.loan_purpose, i.loan_status
FROM loan_applications_import AS i
WHERE NOT EXISTS (
    SELECT 1
    FROM dim_loan_application AS d
    WHERE d.application_id = i.application_id
);

INSERT INTO fact_loan_application (
    application_key, monthly_income_inr, coapplicant_income_inr,
    loan_amount_inr, loan_term_months, credit_score, existing_loans_count
)
SELECT
    d.application_key, i.monthly_income_inr, i.coapplicant_income_inr,
    i.loan_amount_inr, i.loan_term_months, i.credit_score, i.existing_loans_count
FROM loan_applications_import AS i
JOIN dim_loan_application AS d
    ON d.application_id = i.application_id
WHERE NOT EXISTS (
    SELECT 1
    FROM fact_loan_application AS f
    WHERE f.application_key = d.application_key
);

-- Quick load check: the dimension and fact counts should match.
SELECT
    (SELECT COUNT(*) FROM dim_loan_application) AS dimension_rows,
    (SELECT COUNT(*) FROM fact_loan_application) AS fact_rows;
