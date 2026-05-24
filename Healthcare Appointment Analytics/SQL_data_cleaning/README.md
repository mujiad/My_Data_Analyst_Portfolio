# Clinic Appointments Data Cleaning Project

## Overview
This project focuses on cleaning and standardizing a messy clinic appointments dataset using SQL.  
The goal is to transform raw, inconsistent data into a structured format suitable for analysis and reporting.

The work includes handling duplicate records, inconsistent text values, multiple date formats, and unstructured financial data.

---

## Objectives
- Remove duplicate or unreliable records
- Standardize inconsistent categorical values
- Clean and unify multiple date formats
- Reconstruct unreliable patient identifiers
- Extract and normalize currency and billing data
- Prepare a clean dataset for analysis

---

## Dataset
- **Source Table:** `messy_clinic_appointments`
- **Cleaned Table:** `appointments_cleaning`

---

## Data Quality Issues Identified

The original dataset contained several issues:

- Inconsistent gender values (`male`, `female`, `0`, `1`, empty strings)
- Multiple date formats across columns
- Unreliable `patient_id` values (same ID mapped to different patients)
- Mixed currency symbols in billing data
- Follow-up status stored in inconsistent formats (`Y/N`, `1/0`)
- Potential duplicate records

---

## Data Cleaning Process

### 1. Creating a Working Copy
A duplicate table was created to preserve the raw dataset.

---

### 2. Duplicate Detection
Used `ROW_NUMBER()` to identify potential duplicate records based on all key fields.

---

### 3. Standardizing Gender Values
Mapped inconsistent values into a consistent format:

- `male` → `M`
- `female` → `F`
- `0`, `1`, empty values → `N/A`

---

### 4. Cleaning Date Fields
Converted multiple date formats into standard SQL `DATE` format using `STR_TO_DATE()`.

Handled formats such as:
- `YYYY/MM/DD`
- `MM/DD/YYYY`
- `Month DD, YY`
- `DD-Mon-YYYY`

Created:
- `appointment_date_cleaned`
- `booking_date_cleaned`

---

### 5. Rebuilding Patient Identifier
Since `patient_id` was inconsistent, a new surrogate key was created using:

- `patient_name`
- `age`
- `gender`

Generated using `DENSE_RANK()` as `ID_clean`.

---

### 6. Standardizing Follow-Up Status
Converted values into a consistent binary format:

- `Y`, `1` → Yes
- `N`, `0` → No

---

### 7. Cleaning Billing Data
Split billing information into two structured fields:

- `billing_amount_cleaned` (numeric value)
- `currency` (USD, GBP, EUR, INR)

Used regex to remove non-numeric characters and detect currency symbols.

---

## Final Output Schema

The cleaned dataset includes:

- ID_clean
- patient_name
- age
- gender
- doctor
- department
- appointment_date_cleaned
- booking_date_cleaned
- follow_up_required
- billing_amount_cleaned
- currency

---

## Key Results

- Standardized inconsistent categorical fields
- Converted multiple date formats into a unified structure
- Built a reliable surrogate key for patients
- Extracted structured financial data from mixed text fields
- Improved dataset readiness for analysis and visualization

---

## Skills Demonstrated

- SQL Data Cleaning
- Window Functions (`ROW_NUMBER`, `DENSE_RANK`)
- CTEs (Common Table Expressions)
- Regex-based data extraction
- Date parsing with `STR_TO_DATE`
- Data standardization techniques

---

## Outcome

The dataset is now clean, structured, and suitable for:
- Data analysis
- Dashboard creation (Power BI / Tableau)
- Reporting and insights generation

---

