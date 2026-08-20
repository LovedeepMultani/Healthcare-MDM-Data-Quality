# Healthcare Master Data Management & Data Quality

## Project Overview

This project demonstrates an end-to-end **Master Data Management (MDM) and Data Quality framework** for healthcare data using SQL, MySQL, Power BI, and DAX.

The project simulates healthcare master and transactional data across multiple domains and applies practical data quality rules commonly used in enterprise MDM programs.

The initial focus is on the **Healthcare Professional (HCP)** domain, with additional domains planned as the project evolves.

## Business Objective

## Business Value

This project demonstrates how healthcare organizations can establish a measurable Data Quality framework around critical master data.

The solution is designed to help data stewards and MDM teams:

* Identify critical data-quality issues at record and attribute level
* Quantify the impact of poor data quality
* Prioritize remediation based on business impact
* Identify potential duplicate and conflicting master records
* Detect broken relationships between transactional and master data
* Monitor stale and incomplete master records
* Provide business users with an interactive Data Quality dashboard
* Establish repeatable data-quality rules that can be operationalized within an MDM program

The approach combines technical validation with an MDM perspective, moving beyond simple profiling toward **issue identification, investigation, measurement, and remediation prioritization**.


## Data Domains

The simulated healthcare dataset contains:

* Healthcare Professional (HCP)
* Healthcare Organization (HCO)
* Orders
* Location
* Supplier

The initial portfolio release focuses on **HCP** data.

## Data Quality Dimensions

The HCP assessment covers:

| Dimension             | Examples                                           |
| --------------------- | -------------------------------------------------- |
| Completeness          | Missing NPI, email and other required attributes   |
| Validity              | NPI, email and status validation                   |
| Conformity            | Phone and specialty format/value checks            |
| Uniqueness            | Duplicate/shared NPI analysis                      |
| Consistency           | Attribute and date consistency checks              |
| Timeliness            | Stale records based on update date                 |
| Accuracy              | Comparison against a trusted HCP reference dataset |
| Entity Resolution     | Weighted matching and duplicate classification     |
| Referential Integrity | Orders referencing valid HCP master records        |

## Technology Stack

* **MySQL** — Data storage and SQL-based profiling/DQ analysis
* **SQL** — Data quality rules, profiling, duplicate analysis and integrity checks
* **Power BI Desktop** — Interactive data quality dashboard
* **DAX** — Data quality metrics and calculations within Power BI
* **GitHub** — Version control and project documentation

## Solution Architecture

```text
Healthcare Source Data
        |
        v
      MySQL
        |
        +----------------------+
        |                      |
        v                      v
   SQL DQ Rules          Raw HCP Data
        |                      |
        v                      v
   DQ Findings            Power BI
                               |
                               v
                    Interactive DQ Dashboard
```

## HCP Data Quality Analysis

The HCP analysis includes:

* NPI completeness
* NPI format validity
* Email completeness and validity
* Status validity
* Specialty conformity
* Phone format consistency
* Duplicate NPI identification
* Identifier conflict analysis
* Weighted duplicate/matching analysis
* Source-system conflict analysis
* Record timeliness
* Created/updated date consistency
* Accuracy against a trusted HCP reference
* Orders-to-HCP referential integrity

## Power BI Dashboard

The Power BI dashboard is being developed as a Data Quality Command Center.

Planned views include:

### Executive Data Quality Overview

* Total HCP records
* Completeness %
* Validity %
* Accuracy %
* Timeliness %
* Uniqueness %
* Overall DQ status
* DQ issue distribution

### Data Quality Details

* Record-level DQ exceptions
* DQ issue type
* HCP attributes
* Source system
* Interactive filtering

### Duplicate & Matching Analysis

* Potential duplicates
* Match confidence
* Identifier conflicts
* Source-system analysis

### SQL Validation

Selected SQL rules and results will be documented separately to demonstrate the underlying data-quality engineering.

## Project Status

### Version 1 — HCP Data Quality

* [x] Healthcare dataset created
* [x] MySQL database configured
* [x] HCP data loaded
* [x] Completeness analysis
* [x] Validity analysis
* [x] Conformity analysis
* [x] Uniqueness analysis
* [x] Consistency analysis
* [x] Timeliness analysis
* [x] Accuracy framework
* [x] Entity-resolution analysis
* [x] Referential-integrity analysis
* [x] Raw HCP data imported into Power BI
* [x] Initial Power BI KPI cards
* [x] Record-level DQ issue visualization
* [ ] Complete Power BI Executive Dashboard
* [ ] Complete Duplicate & Matching Dashboard
* [ ] Finalize documentation

### Future Versions

* HCO Data Quality
* Location Data Quality
* Supplier Data Quality
* Orders and cross-domain validation
* Enterprise-level DQ scorecard
* Cross-domain MDM analysis
* Data governance recommendations

## Key MDM Concepts Demonstrated

This project demonstrates practical application of:

* Master Data Management
* Data Quality Management
* Data Profiling
* Business Rule Validation
* Duplicate Detection
* Entity Resolution
* Golden Record / Reference Data
* Referential Integrity
* Data Governance
* Data Quality Measurement
* Operational Data Stewardship

## Author

This project is part of a professional portfolio demonstrating practical experience in **Master Data Management, Data Quality, Data Governance, SQL, and Power BI**.
