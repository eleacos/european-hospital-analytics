-- CREATE DATABASE

-- Rebuild the local development database.
-- Warning: this deletes the database and all its tables if it already exists.

DROP DATABASE IF EXISTS european_hospital_analytics;

CREATE DATABASE european_hospital_analytics
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE european_hospital_analytics;

SELECT DATABASE() AS active_database;