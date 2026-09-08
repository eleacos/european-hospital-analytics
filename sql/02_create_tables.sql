-- CREATE DIMENSION TABLES

USE european_hospital_analytics;

CREATE TABLE dim_country (
    country_id INT PRIMARY KEY,
    country_code VARCHAR(2) NOT NULL UNIQUE,
    country_name VARCHAR(50) NOT NULL
);

CREATE TABLE dim_year (
    year_id INT PRIMARY KEY,
    year INT UNSIGNED NOT NULL UNIQUE
);

CREATE TABLE dim_diagnosis (
    diagnosis_id INT PRIMARY KEY,
    diagnosis_code VARCHAR(10) NOT NULL UNIQUE,
    diagnosis_name VARCHAR(100) NOT NULL,
    diagnosis_group VARCHAR (50) NOT NULL
);


-- CREATE FACT TABLES

CREATE TABLE fact_beds (
    country_id INT NOT NULL,
    year_id INT NOT NULL,
    value DECIMAL (12,2) NOT NULL,
    unit_code VARCHAR(20) NOT NULL,
    status_flag VARCHAR(10),

    PRIMARY KEY (country_id, year_id),
    
    FOREIGN KEY (country_id) REFERENCES dim_country(country_id),
    FOREIGN KEY (year_id) REFERENCES dim_year(year_id)

);

CREATE TABLE fact_discharges (
    country_id INT NOT NULL,
    year_id INT NOT NULL,
    diagnosis_id INT NOT NULL,
    value DECIMAL (12,2) NOT NULL,
    unit_code VARCHAR (20) NOT NULL,
    status_flag VARCHAR (10),

    PRIMARY KEY (country_id, year_id, diagnosis_id),

    FOREIGN KEY (country_id) REFERENCES dim_country(country_id),
    FOREIGN KEY (year_id) REFERENCES dim_year(year_id),
    FOREIGN KEY (diagnosis_id) REFERENCES dim_diagnosis(diagnosis_id)
);

CREATE TABLE fact_length_stay (
    country_id INT NOT NULL,
    year_id INT NOT NULL,
    diagnosis_id INT NOT NULL,
    value DECIMAL (12,2) NOT NULL,
    unit_code VARCHAR (20) NOT NULL,
    status_flag VARCHAR (10),

    PRIMARY KEY (country_id, year_id, diagnosis_id),

    FOREIGN KEY (country_id) REFERENCES dim_country(country_id),
    FOREIGN KEY (year_id) REFERENCES dim_year(year_id),
    FOREIGN KEY (diagnosis_id) REFERENCES dim_diagnosis(diagnosis_id)
);