-- VALIDATE DATA LOADING

USE european_hospital_analytics;

SELECT 'dim_country' AS table_name, COUNT(*) AS row_count
FROM dim_country

UNION ALL

SELECT 'dim_year', COUNT(*)
FROM dim_year

UNION ALL

SELECT 'dim_diagnosis', COUNT(*)
FROM dim_diagnosis

UNION ALL

SELECT 'fact_beds', COUNT(*)
FROM fact_beds

UNION ALL

SELECT 'fact_discharges', COUNT(*)
FROM fact_discharges

UNION ALL

SELECT 'fact_length_stay', COUNT(*)
FROM fact_length_stay;



-- CHECK 1: DUPLICATE ANALYTICAL KEYS

SELECT country_id, year_id, COUNT(*) AS duplicate_count
FROM fact_beds
GROUP BY country_id, year_id
HAVING COUNT(*) >1;

SELECT country_id, year_id, diagnosis_id, COUNT(*) AS duplicate_count
FROM fact_discharges
GROUP BY country_id, year_id, diagnosis_id
HAVING COUNT(*) >1;

SELECT country_id, year_id, diagnosis_id, COUNT(*) AS duplicate_count
FROM fact_length_stay
GROUP BY country_id, year_id, diagnosis_id
HAVING COUNT(*) >1;



-- CHECK 2: ORPHAN FOREING KEYS


SELECT
    SUM(c.country_id IS NULL) AS orphan_country_keys,
    SUM(y.year_id IS NULL) AS orphan_year_keys
FROM fact_beds AS f
LEFT JOIN dim_country AS c ON f.country_id = c.country_id
LEFT JOIN dim_year AS y ON f.year_id = y.year_id;


SELECT
    SUM(c.country_id IS NULL) AS orphan_country_keys,
    SUM(y.year_id IS NULL) AS orphan_year_keys,
    SUM(d.diagnosis_id IS NULL) AS orphan_diagnosis_keys
FROM fact_discharges AS f
LEFT JOIN dim_country AS c ON f.country_id = c.country_id
LEFT JOIN dim_year AS y ON f.year_id = y.year_id
LEFT JOIN dim_diagnosis AS d ON f.diagnosis_id = d.diagnosis_id;

SELECT
    SUM(c.country_id IS NULL) AS orphan_country_keys,
    SUM(y.year_id IS NULL) AS orphan_year_keys,
    SUM(d.diagnosis_id IS NULL) AS orphan_diagnosis_keys
FROM fact_length_stay AS f
LEFT JOIN dim_country AS c ON f.country_id = c.country_id
LEFT JOIN dim_year AS y ON f.year_id = y.year_id
LEFT JOIN dim_diagnosis AS d ON f.diagnosis_id = d.diagnosis_id;



-- CHECK 3: NULL VALUES IN FACT TABLES

SELECT 
    COUNT(*) AS total_rows,
    SUM(country_id IS NULL) AS null_country_id,
    SUM(year_id IS NULL) AS null_year_id,
    SUM(value IS NULL) AS null_value,
    SUM(unit_code IS NULL) AS null_unit_code,
    SUM(status_flag IS NULL) AS null_status_flag
FROM fact_beds;

SELECT 
    COUNT(*) AS total_rows,
    SUM(country_id IS NULL) AS null_country_id,
    SUM(year_id IS NULL) AS null_year_id,
    SUM(diagnosis_id IS NULL) AS null_diagnosis_id,
    SUM(value IS NULL) AS null_value,
    SUM(unit_code IS NULL) AS null_unit_code,
    SUM(status_flag IS NULL) AS null_status_flag
FROM fact_discharges;

SELECT 
    COUNT(*) AS total_rows,
    SUM(country_id IS NULL) AS null_country_id,
    SUM(year_id IS NULL) AS null_year_id,
    SUM(diagnosis_id IS NULL) AS null_diagnosis_id,
    SUM(value IS NULL) AS null_value,
    SUM(unit_code IS NULL) AS null_unit_code,
    SUM(status_flag IS NULL) AS null_status_flag
FROM fact_length_stay;



-- CHECK 4: INVALID VALUES

SELECT *
FROM fact_beds
WHERE value <= 0;

SELECT *
FROM fact_discharges
WHERE value <= 0;

SELECT *
FROM fact_length_stay
WHERE value <= 0;

SELECT *
FROM dim_year
WHERE year < 2014 OR year > 2019;



-- CHECK 5: EXPECTED DATA COVERAGE
-- Check for missing rows

SELECT
    COUNT(*) AS actual_rows,
    30 AS expected_rows,
    30 - COUNT(*) AS missing_rows
FROM fact_beds;

SELECT
    COUNT(*) AS actual_rows,
    150 AS expected_rows,
    150 - COUNT(*) AS missing_rows
FROM fact_discharges;

SELECT
    COUNT(*) AS actual_rows,
    150 AS expected_rows,
    150 - COUNT(*) AS missing_rows
FROM fact_length_stay;


-- Find which combinations are missing

SELECT c.country_code, y.year
FROM dim_country AS c
CROSS JOIN dim_year AS y
LEFT JOIN fact_beds AS f
    ON c.country_id = f.country_id
    AND y.year_id = f.year_id
WHERE f.country_id IS NULL
ORDER BY c.country_code;


SELECT c.country_code, y.year, d.diagnosis_code
FROM dim_country as c
CROSS JOIN dim_year AS y
CROSS JOIN dim_diagnosis AS d
LEFT JOIN fact_discharges AS f
    ON c.country_id = f.country_id
    AND y.year_id = f.year_id
    AND d.diagnosis_id = f.diagnosis_id
WHERE f.country_id IS NULL
ORDER BY c.country_code, y.year, d.diagnosis_code;


SELECT c.country_code, y.year, d.diagnosis_code
FROM dim_country as c
CROSS JOIN dim_year AS y
CROSS JOIN dim_diagnosis AS d
LEFT JOIN fact_length_stay AS f
    ON c.country_id = f.country_id
    AND y.year_id = f.year_id
    AND d.diagnosis_id = f.diagnosis_id
WHERE f.country_id IS NULL
ORDER BY c.country_code, y.year, d.diagnosis_code;



-- CHECK 6: EUROSTAT STATUS FLAG

SELECT 
    CASE 
        WHEN status_flag IS NULL THEN 'No flag'
        ELSE status_flag
    END AS status_flag,
    COUNT(*) AS number_of_observations
FROM fact_beds
GROUP BY
    CASE
        WHEN status_flag IS NULL THEN 'No flag'
        ELSE status_flag
    END;


SELECT
    CASE
        WHEN status_flag IS NULL THEN 'No flag'
        ELSE status_flag
    END AS status_flag,
    COUNT(*) AS number_of_observations
FROM fact_discharges
GROUP BY
    CASE
        WHEN status_flag IS NULL THEN 'No flag'
        ELSE status_flag
    END;


SELECT
    CASE
        WHEN status_flag IS NULL THEN 'No flag'
        ELSE status_flag
    END AS status_flag,
    COUNT(*) AS number_of_observations
FROM fact_length_stay
GROUP BY
    CASE
        WHEN status_flag IS NULL THEN 'No flag'
        ELSE status_flag
    END;