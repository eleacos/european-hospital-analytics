-- ANALYTICAL QUERIES

-- European Hospital Capacity and Activity
-- Source: Eurostat
-- Countries: Germany, Spain, France, Italy and Portugal
-- Period: 2014-2019



-- 1. HOSPITAL BEDS BY COUNTRY AND YEAR
-- How did hospital bed availability per 100,000 inhabitants change across the selected countries between 2014 and 2019?

USE european_hospital_analytics;

SELECT
    c.country_name,
    y.year,
    f.value AS hospital_beds_per_100k,
    f.unit_code,
    f.status_flag
FROM fact_beds AS f
JOIN dim_country AS c ON f.country_id = c.country_id
JOIN dim_year AS y ON f.year_id = y.year_id
ORDER BY y.year, c.country_name;



-- 2. HOSPITAL DISCHARGES BY DIAGNOSIS
-- How did hospital discharge rates per 100,000 inhabitants vary by country, year and diagnosis group?

SELECT 
    c.country_name,
    y.year,
    d.diagnosis_name,
    f.value AS discharges_per_100k,
    f.unit_code
FROM fact_discharges AS f 
JOIN dim_country AS c ON f.country_id = c.country_id
JOIN dim_year AS y ON f.year_id = y.year_id
JOIN dim_diagnosis AS d ON f.diagnosis_id = d.diagnosis_id
ORDER BY d.diagnosis_name, y.year, c.country_name;



-- 3. AVERAGE LENGTH OF STAY BY DIAGNOSIS
-- How did average length of stay vary by country, year and diagnosis group?

SELECT 
    c.country_name, 
    y.year,
    d.diagnosis_name,
    f.value AS average_length_of_stay_days,
    f.unit_code
FROM fact_length_stay AS f
JOIN dim_country AS c ON f.country_id = c.country_id
JOIN dim_year AS y ON f.year_id = y.year_id
JOIN dim_diagnosis AS d ON f.diagnosis_id = d.diagnosis_id
ORDER BY d.diagnosis_name, y.year, c.country_name;



-- 4. HOSPITAL BED AVAILABILITY IN 2019
-- How did hospital bed availability per 100,000 inhabitants compare across the selected countries in 2019?

SELECT 
    c.country_name, 
    f.value AS hospital_beds_per_100K,
    f.unit_code,
    f.status_flag
FROM fact_beds AS f
JOIN dim_country AS c ON f.country_id = c.country_id
JOIN dim_year AS y ON f.year_id = y.year_id
WHERE y.year = 2019
ORDER BY f.value DESC;



-- 5. AVERAGE HOSPITAL BED AVAILABILITY ACROSS SELECTED COUNTRIES
-- How did the average hospital bed availability across the selected countries change between 2014 and 2019?
-- "selected-country average"

SELECT
    y.year,
    ROUND(AVG(f.value), 2) AS selected_country_average_beds_per_100K,
    COUNT(DISTINCT f.country_id) AS number_of_countries
FROM fact_beds AS f
JOIN dim_year as y ON f.year_id = y.year_id
GROUP BY y.year
ORDER BY y.year;



-- 6. SPAIN COMPARED TO THE OTHER SELECTED COUNTRIES
-- How did hospital bed availability in Spain compare to the average of the other countries between 2014-2019?
-- "Spain vs average of other selected countries"

SELECT
    y.year,
    MAX(
        CASE
            WHEN c.country_code = 'ES' THEN f.value
        END
    ) AS spain_beds_per_100K,
    ROUND(
        AVG(
            CASE
                WHEN c.country_code <> 'ES' THEN f.value
            END
        ), 2
    ) AS other_selected_countries_average,
    ROUND(
        MAX(
            CASE
                WHEN c.country_code = 'ES' THEN f.value
            END
        )
        -
        AVG(
            CASE
                WHEN c.country_code <> 'ES' THEN f.value
            END
        ),2
    ) AS spain_difference
FROM fact_beds AS f
JOIN dim_country AS c ON f.country_id = c.country_id
JOIN dim_year AS y ON f.year_id = y.year_id
GROUP BY y.year
ORDER BY y.year;



-- 7. CHANGE IN HOSPITAL BED AVAILABILITY, 2014-19
-- What was the absolute change in hospital bed availability per 100K inhabitants in each selected country between 2014-2019?

SELECT
    c.country_name,
    MAX(
        CASE
            WHEN y.year = 2014 THEN f.value
        END
    ) AS beds_per_100k_2014,
    MAX(
        CASE
            WHEN y.year = 2019 THEN f.value
        END
    ) AS beds_per_100k_2019,
    ROUND(
        MAX(
            CASE
                WHEN y.year = 2019 THEN f.value
            END
        )
        -
        MAX(
            CASE
                WHEN y.year = 2014 THEN f.value
            END
        ), 2
    ) AS absolute_change
FROM fact_beds AS f
JOIN dim_country AS c on f.country_id = c.country_id
JOIN dim_year AS y ON f.year_id = y.year_id
GROUP BY c.country_name
ORDER BY absolute_change;



-- 8. PERCENTAGE CHANGE IN HOSPITAL BED AVAILABILITY, 2014-2019
-- What was the percentage change in hospital bed availability per 100K inhabitants in each selected country between 2014-2019?

SELECT
    c.country_name,
    MAX(
        CASE
            WHEN y.year = 2014 THEN f.value
        END
    ) AS beds_per_100k_2014,
    MAX(
        CASE
            WHEN y.year = 2019 THEN f.value
        END
    ) AS beds_per_100K_2019,
    ROUND(
        (
            MAX(
                CASE
                    WHEN y.year = 2019 THEN f.value
                END
            )
            -
            MAX(
                CASE 
                    WHEN y.year = 2014 THEN f.value
                END
            )
        )
        /
        MAX(
            CASE
                WHEN y.year = 2014 THEN f.value
            END
        ) *100, 2
    ) AS percentage_change
FROM fact_beds AS f
JOIN dim_country AS c ON f.country_id = c.country_id
JOIN dim_year AS y ON f.year_id = y.year_id
GROUP BY country_name
ORDER BY percentage_change;



-- 9. HOSPITAL DISCHARGES BY DIAGNOSIS IN 2019
-- How did hospital discharge rates per 100k inhabitants compare across selected countries and diagnosis grouops in 2019?

SELECT
    d.diagnosis_name,
    c.country_name,
    f.value AS discharges_per_100k,
    f.unit_code
FROM fact_discharges AS f
JOIN dim_country AS c ON f.country_id = c.country_id
JOIN dim_year AS y ON f.year_id = y.year_id
JOIN dim_diagnosis AS d ON f.diagnosis_id = d.diagnosis_id
WHERE y.year = 2019 AND d.diagnosis_code <> 'A-T_Z'
ORDER BY d.diagnosis_name, f.value DESC;



-- 10. AVERAGE LENGTH OF STAY BY DIAGNOSIS IN 2019
-- How did the average length of stay compare across selected countries and diagnosis groups in 2019?

SELECT 
    d.diagnosis_name,
    c.country_name,
    f.value AS average_length_of_stay_days,
    f.unit_code
FROM fact_length_stay AS f
JOIN dim_country AS c ON f.country_id = c.country_id
JOIN dim_year AS y ON f.year_id = y.year_id
JOIN dim_diagnosis AS d ON f.diagnosis_id = d.diagnosis_id
WHERE y.year = 2019 AND d.diagnosis_code <> 'A-T_Z'
ORDER BY d.diagnosis_name, f.value DESC;



-- 11. ANNUAL RANKING OF HOSPITAL BED AVAILABILITY
-- What was each selected country's annual ranking in hospital bed availability per 100k inhabitants?

SELECT
    y.year,
    c.country_name,
    f.value AS hospital_beds_per_100k,
    RANK() OVER (
        PARTITION BY y.year
        ORDER BY f.value DESC
    ) AS bed_availability_rank
FROM fact_beds AS f
JOIN dim_country AS c ON f.country_id = c.country_id
JOIN dim_year AS y ON f.year_id = y.year_id
ORDER BY y.year, bed_availability_rank, c.country_name;



-- 12. YEAR-ON-YEAR CHANGE IN HOSPITAL BED AVAILABILITY
-- How did hospital bed availability per 100k inhabitants change from one year to the next in each selected country?

SELECT
    c.country_name,
    y.year,
    f.value AS hospital_beds_per_100k,
    LAG(f.value) OVER (
        PARTITION BY f.country_id
        ORDER BY y.year
    ) AS previous_year_beds_per_100k,
    ROUND(
        f.value
        -
        LAG(f.value) OVER (
            PARTITION BY f.country_id
            ORDER BY y.year
        ), 2
    ) AS year_on_year_change
FROM fact_beds AS f
JOIN dim_country AS c ON f.country_id = c.country_id
JOIN dim_year AS y ON f.year_id = y.year_id
ORDER BY c.country_name, y.year;



-- 13. HOSPITAL BEDS AND TOTAL DISCHARGES
-- How did hospital bed availability and total hospital discharge rates compare by country and year?

WITH beds_by_country_year AS (
    SELECT
        country_id,
        year_id,
        value AS hospital_beds_per_100k
    FROM fact_beds
),

total_discharges_by_country_year AS (
    SELECT
        f.country_id,
        f.year_id,
        f.value AS total_discharges_per_100k
    FROM fact_discharges AS f
    JOIN dim_diagnosis AS d ON f.diagnosis_id = d.diagnosis_id
    WHERE d.diagnosis_code = 'A-T_Z'
)

SELECT 
    c.country_name,
    y.year,
    b.hospital_beds_per_100K,
    d.total_discharges_per_100k
FROM beds_by_country_year AS b
JOIN total_discharges_by_country_year AS d 
    ON b.country_id = d.country_id
    AND b.year_id = d.year_id
JOIN dim_country AS c ON b.country_id = c.country_id
JOIN dim_year AS y ON b.year_id = y.year_id
ORDER BY c.country_name, y.year;