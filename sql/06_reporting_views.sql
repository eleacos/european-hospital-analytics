-- REPORTING VIEWS FOR POWER BI


USE european_hospital_analytics;


-- View 1: Hospital bed availability by country and year

DROP VIEW IF EXISTS vw_capacity_trends;

CREATE VIEW vw_capacity_trends AS
SELECT
    c.country_code,
    c.country_name,
    y.year,
    f.value AS hospital_beds_per_100k,
    f.unit_code,
    f.status_flag
FROM fact_beds AS f
JOIN dim_country AS c ON f.country_id = c.country_id
JOIN dim_year AS y ON f.year_id = y.year_id;



-- View 2: Hospital activity by country, year and diagnosis

DROP VIEW IF EXISTS vw_activity_by_diagnosis;

CREATE VIEW vw_activity_by_diagnosis AS
SELECT
    c.country_code,
    c.country_name,
    y.year,
    d.diagnosis_code,
    d.diagnosis_name,
    d.diagnosis_group,
    fd.value AS discharges_per_100k,
    fd.unit_code AS discharges_unit_code,
    fd.status_flag AS discharges_status_flag,
    fls.value AS average_length_of_stay_days,
    fls.unit_code AS length_stay_unit_code,
    fls.status_flag AS length_stay_status_flag
FROM dim_country AS c
CROSS JOIN dim_year AS y
CROSS JOIN dim_diagnosis AS d
LEFT JOIN fact_discharges AS fd
    ON c.country_id = fd.country_id
    AND y.year_id = fd.year_id
    AND d.diagnosis_id = fd.diagnosis_id
LEFT JOIN fact_length_stay AS fls
    ON c.country_id = fls.country_id
    AND y.year_id = fls.year_id
    AND d.diagnosis_id = fls.diagnosis_id;



-- View 3: Country-year summary

DROP VIEW IF EXISTS vw_country_summary;

CREATE VIEW vw_country_summary AS
WITH total_discharges AS (
    SELECT
        f.country_id,
        f.year_id,
        f.value AS total_discharges_per_100k
    FROM fact_discharges AS f
    JOIN dim_diagnosis AS d ON f.diagnosis_id = d.diagnosis_id
    WHERE d.diagnosis_code = 'A-T_Z'
),

total_length_stay AS (
    SELECT
        f.country_id,
        f.year_id,
        f.value AS average_length_of_stay_days
    FROM fact_length_stay AS f
    JOIN dim_diagnosis AS d ON f.diagnosis_id = d.diagnosis_id
    WHERE d.diagnosis_code = 'A-T_Z'
)

SELECT
    c.country_code, 
    c.country_name,
    y.year,
    b.value AS hospital_beds_per_100k,
    td.total_discharges_per_100k,
    tls.average_length_of_stay_days
FROM dim_country AS c 
CROSS JOIN dim_year AS y
LEFT JOIN fact_beds AS b 
    ON c.country_id = b.country_id
    AND y.year_id = b.year_id
LEFT JOIN total_discharges AS td
    ON c.country_id = td.country_id
    AND y.year_id = td.year_id
LEFT JOIN total_length_stay AS tls
    ON c.country_id = tls.country_id
    AND y.year_id = tls.year_id;
