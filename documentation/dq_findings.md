# HCP Data Quality Findings

## 1. Executive Summary

The HCP master data was assessed across multiple Data Quality dimensions using SQL and Power BI.

The assessment focused on completeness, validity, conformity, uniqueness, consistency, timeliness, accuracy, entity resolution, and referential integrity.

The initial analysis identified several data-quality issues requiring remediation or further investigation.

---

## 2. Data Volume

| Metric               | Result |
| -------------------- | -----: |
| HCP records analyzed |  1,000 |

---

## 3. Completeness

### NPI Completeness

**Finding:** 95.40% of HCP records have a populated NPI.

**DQ Concern:** 4.60% of records have a missing or blank NPI.

**Business Impact:** Missing identifiers can affect HCP matching, downstream integrations, reporting, and master-data survivorship.

---

## 4. Validity

### NPI Validity

The NPI validation rule requires a populated NPI to follow the expected 10-digit format.

The initial dataset showed **100% NPI validity** based on the current Power BI validation rule.

This should be interpreted separately from completeness: a record can have a valid-format NPI while another record has no NPI at all.

### Status Validity

The expected status values are:

* ACTIVE
* INACTIVE

Records outside the approved value set are considered invalid.

---

## 5. Conformity

### Phone Number Format

Multiple phone-number formats were identified in the HCP data.

The analysis categorized phone numbers into:

* 10 digits
* XXX-XXX-XXXX
* (XXX) XXX-XXXX
* International
* Other/Invalid

This demonstrates a conformity issue where the same business attribute can be represented using different structural formats.

---

## 6. Uniqueness / Identifier Conflicts

Multiple HCP records were identified sharing the same NPI.

The analysis showed that shared NPIs do not automatically mean that the records are duplicates. Additional attributes including:

* First name
* Last name
* Email
* Phone
* Specialty
* Address

were compared to distinguish potential duplicates from identifier conflicts.

A weighted matching approach was also implemented to classify potential duplicate relationships.

---

## 7. Timeliness

### Stale HCP Records

40.50% of HCP records were identified as potentially stale based on the rule that records not updated within 12 months require review.

**Business Impact:** Stale master data may reduce confidence in downstream analytics and operational processes.

---

## 8. Accuracy

A separate HCP reference dataset was created to support accuracy testing.

Selected HCP attributes were compared against the trusted reference dataset.

The accuracy framework demonstrates that accuracy requires comparison against an established reference or trusted source rather than simply checking whether a field is populated or correctly formatted.

---

## 9. Entity Resolution

A weighted matching model was developed for HCP records sharing the same NPI.

The matching model considered:

| Attribute  | Weight |
| ---------- | -----: |
| First Name |      1 |
| Last Name  |      1 |
| Email      |      3 |
| Phone      |      2 |
| Specialty  |      1 |
| Address    |      2 |

Records were classified into:

* High-confidence duplicate
* Possible duplicate
* Identifier conflict

This approach demonstrates an MDM-oriented approach to duplicate detection rather than relying only on exact identifier matching.

---

## 10. Referential Integrity

Orders were tested against the HCP master to determine whether every `orders.hcp_id` references an existing `hcp.hcp_id`.

**Finding:** 145 orders were identified with an invalid HCP reference.

**DQ Dimension:** Referential Integrity

**Business Impact:** Invalid master-data references can result in orphan transactions, incomplete reporting, failed integrations, and inaccurate downstream analytics.

---

## 11. Power BI Implementation

The raw HCP dataset was imported into Power BI.

Power BI/DAX is being used to calculate DQ metrics independently from the SQL analysis.

Current Power BI components include:

* Total HCP Records KPI
* NPI Completeness KPI
* NPI Validity KPI
* Overall DQ Status
* Record-level DQ issue table
* NPI issue identification

The dashboard will be expanded to include DQ dimensions, issue distribution, trends, and interactive record-level analysis.

---

## 12. Key Portfolio Takeaways

This project demonstrates an end-to-end approach to healthcare master data quality:

**Profile → Define Rules → Detect Issues → Measure Quality → Investigate → Visualize → Recommend Remediation**

The project combines SQL-based data-quality engineering with MDM concepts and Power BI visualization.
