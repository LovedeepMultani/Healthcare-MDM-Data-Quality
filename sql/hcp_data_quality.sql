```sql
/*
===============================================================================
Healthcare MDM & Data Quality Portfolio
HCP Data Quality Assessment
===============================================================================

Purpose:
    Assess the quality of Healthcare Professional (HCP) master data across
    key Data Quality dimensions.

Data Source:
    MySQL - HCP master data

DQ Dimensions:
    1. Profiling
    2. Completeness
    3. Validity
    4. Conformity
    5. Uniqueness
    6. Consistency
    7. Timeliness
    8. Accuracy
    9. Entity Resolution
   10. Referential Integrity

===============================================================================
*/


/*
===============================================================================
1. DATA PROFILING
===============================================================================
Business Purpose:
    Understand the population and distribution of HCP master data.
===============================================================================
*/

-- Total HCP records
SELECT COUNT(*) AS total_hcp_records
FROM hcp;


-- HCP distribution by status
SELECT
    status,
    COUNT(*) AS record_count
FROM hcp
GROUP BY status
ORDER BY record_count DESC;


-- HCP distribution by source system
SELECT
    source_system,
    COUNT(*) AS record_count
FROM hcp
GROUP BY source_system
ORDER BY record_count DESC;


/*
===============================================================================
2. COMPLETENESS
===============================================================================
Business Rule:
    Required attributes should be populated.

Example:
    NPI should not be NULL, empty, or whitespace.
===============================================================================
*/

SELECT
    COUNT(*) AS total_hcp,
    SUM(
        CASE
            WHEN npi IS NULL OR TRIM(npi) = ''
            THEN 1 ELSE 0
        END
    ) AS missing_npi,
    SUM(
        CASE
            WHEN npi IS NOT NULL AND TRIM(npi) <> ''
            THEN 1 ELSE 0
        END
    ) AS populated_npi,
    ROUND(
        SUM(
            CASE
                WHEN npi IS NULL OR TRIM(npi) = ''
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS missing_npi_pct,
    ROUND(
        SUM(
            CASE
                WHEN npi IS NOT NULL AND TRIM(npi) <> ''
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS npi_completeness_pct
FROM hcp;


/*
===============================================================================
3. VALIDITY
===============================================================================
Business Rules:
    - NPI should contain exactly 10 numeric digits.
    - Status should be ACTIVE or INACTIVE.
===============================================================================
*/

-- NPI validity
SELECT
    CASE
        WHEN npi REGEXP '^[0-9]{10}$'
            THEN 'Valid NPI'
        WHEN npi IS NULL OR TRIM(npi) = ''
            THEN 'Missing NPI'
        ELSE 'Invalid NPI'
    END AS npi_status,
    COUNT(*) AS record_count
FROM hcp
GROUP BY npi_status
ORDER BY record_count DESC;


-- Status validity
SELECT
    CASE
        WHEN UPPER(TRIM(status)) IN ('ACTIVE', 'INACTIVE')
            THEN 'Valid'
        ELSE 'Invalid'
    END AS status_validity,
    COUNT(*) AS record_count
FROM hcp
GROUP BY status_validity;


/*
===============================================================================
4. CONFORMITY
===============================================================================
Business Purpose:
    Identify attributes that do not follow the expected structural format.

Example:
    Phone numbers may arrive in multiple formats.
===============================================================================
*/

SELECT
    CASE
        WHEN phone REGEXP '^[0-9]{10}$'
            THEN '10 digits'

        WHEN phone REGEXP '^[0-9]{3}-[0-9]{3}-[0-9]{4}$'
            THEN 'XXX-XXX-XXXX'

        WHEN phone REGEXP '^\\([0-9]{3}\\) [0-9]{3}-[0-9]{4}$'
            THEN '(XXX) XXX-XXXX'

        WHEN phone REGEXP '^\\+[0-9]{1,3}[ -][0-9]{3}[ -][0-9]{3}[ -][0-9]{4}$'
            THEN 'International'

        ELSE 'Other/Invalid'
    END AS phone_format,
    COUNT(*) AS record_count
FROM hcp
WHERE TRIM(phone) <> ''
GROUP BY phone_format
ORDER BY record_count DESC;


/*
===============================================================================
5. UNIQUENESS
===============================================================================
Business Rule:
    NPI should uniquely identify an HCP.

Purpose:
    Identify shared NPIs and potential duplicate/identifier conflicts.
===============================================================================
*/

-- Duplicate/shared NPI summary
SELECT
    npi,
    COUNT(*) AS hcp_count
FROM hcp
WHERE TRIM(npi) <> ''
GROUP BY npi
HAVING COUNT(*) > 1
ORDER BY hcp_count DESC;


-- Detailed records associated with shared NPIs
SELECT *
FROM hcp
WHERE npi IN (
    SELECT npi
    FROM hcp
    WHERE TRIM(npi) <> ''
    GROUP BY npi
    HAVING COUNT(*) > 1
)
ORDER BY npi;


/*
===============================================================================
6. CONSISTENCY
===============================================================================
Business Purpose:
    Identify records where related attributes or values are inconsistent.

Example:
    Created date should not occur after updated date.
===============================================================================
*/

SELECT
    hcp_id,
    created_date,
    updated_date
FROM hcp
WHERE created_date > updated_date;


/*
===============================================================================
7. TIMELINESS
===============================================================================
Business Rule:
    HCP records that have not been updated within the previous 12 months
    are considered potentially stale.
===============================================================================
*/

SELECT
    COUNT(*) AS total_hcp,
    SUM(
        CASE
            WHEN updated_date < DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
            THEN 1 ELSE 0
        END
    ) AS stale_records,
    ROUND(
        SUM(
            CASE
                WHEN updated_date < DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS stale_rate_pct
FROM hcp;


/*
===============================================================================
8. ACCURACY
===============================================================================
Business Concept:
    Accuracy requires a trusted reference or golden record.

    hcp_reference represents the trusted HCP reference dataset used for
    comparison against the operational HCP dataset.

===============================================================================
*/

-- Example: Specialty accuracy
SELECT
    COUNT(*) AS records_compared,

    SUM(
        CASE
            WHEN h.specialty = r.specialty
            THEN 1 ELSE 0
        END
    ) AS accurate_records,

    SUM(
        CASE
            WHEN h.specialty <> r.specialty
            THEN 1 ELSE 0
        END
    ) AS inaccurate_records,

    ROUND(
        SUM(
            CASE
                WHEN h.specialty = r.specialty
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS specialty_accuracy_pct

FROM hcp h
JOIN hcp_reference r
    ON h.hcp_id = r.hcp_id;


/*
===============================================================================
9. ENTITY RESOLUTION / MATCHING
===============================================================================
Business Purpose:
    Assess whether records sharing an identifier represent potential
    duplicates or identifier conflicts.

Weighted attributes:
    First Name  = 1
    Last Name   = 1
    Email       = 3
    Phone       = 2
    Specialty   = 1
    Address     = 2

Higher scores indicate stronger similarity.
===============================================================================
*/

WITH hcp_pairs AS (

    SELECT
        h1.hcp_id AS hcp_1,
        h2.hcp_id AS hcp_2,
        h1.npi,

        (
            CASE
                WHEN LOWER(TRIM(h1.first_name)) =
                     LOWER(TRIM(h2.first_name))
                THEN 1 ELSE 0
            END

            +

            CASE
                WHEN LOWER(TRIM(h1.last_name)) =
                     LOWER(TRIM(h2.last_name))
                THEN 1 ELSE 0
            END

            +

            CASE
                WHEN LOWER(TRIM(h1.email)) =
                     LOWER(TRIM(h2.email))
                THEN 3 ELSE 0
            END

            +

            CASE
                WHEN LOWER(TRIM(h1.phone)) =
                     LOWER(TRIM(h2.phone))
                THEN 2 ELSE 0
            END

            +

            CASE
                WHEN LOWER(TRIM(h1.specialty)) =
                     LOWER(TRIM(h2.specialty))
                THEN 1 ELSE 0
            END

            +

            CASE
                WHEN LOWER(TRIM(h1.address)) =
                     LOWER(TRIM(h2.address))
                THEN 2 ELSE 0
            END

        ) AS match_score

    FROM hcp h1

    JOIN hcp h2
        ON h1.npi = h2.npi

    WHERE h1.hcp_id < h2.hcp_id
      AND TRIM(h1.npi) <> ''
)

SELECT
    CASE
        WHEN match_score BETWEEN 8 AND 10
            THEN 'High-confidence duplicate'

        WHEN match_score BETWEEN 5 AND 7
            THEN 'Possible duplicate'

        ELSE 'Identifier conflict'
    END AS classification,

    COUNT(*) AS pair_count

FROM hcp_pairs

GROUP BY classification

ORDER BY pair_count DESC;


/*
===============================================================================
10. REFERENTIAL INTEGRITY
===============================================================================
Business Rule:
    Every orders.hcp_id should reference an existing hcp.hcp_id.

Purpose:
    Identify transactional records referencing missing master records.
===============================================================================
*/

SELECT
    o.order_id,
    o.hcp_id
FROM orders o

LEFT JOIN hcp h
    ON h.hcp_id = o.hcp_id

WHERE h.hcp_id IS NULL;


/*
===============================================================================
Referential Integrity Rate
===============================================================================
*/

SELECT
    COUNT(*) AS total_orders,

    SUM(
        CASE
            WHEN h.hcp_id IS NULL
            THEN 1 ELSE 0
        END
    ) AS invalid_hcp_references,

    ROUND(
        SUM(
            CASE
                WHEN h.hcp_id IS NULL
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS invalid_hcp_reference_pct

FROM orders o

LEFT JOIN hcp h
    ON h.hcp_id = o.hcp_id;


/*
===============================================================================
END OF HCP DATA QUALITY ASSESSMENT
===============================================================================
*/
```
