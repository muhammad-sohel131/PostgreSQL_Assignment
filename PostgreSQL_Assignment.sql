-- Active: 1747721616011@@127.0.0.1@5433@conservation_db

-- create Database
CREATE DATABASE conservation_db

-- create tables
CREATE TABLE rangers (
    ranger_id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    region VARCHAR(255)
);

CREATE TABLE species (
    species_id SERIAl PRIMARY KEY,
    common_name VARCHAR(255),
    scientific_name VARCHAR(255),
    discovery_date DATE DEFAULT CURRENT_DATE,
    conservation_status VARCHAR(255)
);

CREATE TABLE sightings (
    sighting_id SERIAL PRIMARY KEY,
    ranger_id INTEGER REFERENCES rangers(ranger_id),
    species_id INTEGER REFERENCES species(species_id),
    sighting_time TIMESTAMP DEFAULT date_trunc('second', now()),
    location VARCHAR(255),
    notes TEXT
);

-- inserting sample data

INSERT INTO rangers (name, region) VALUES
('Alice Green', 'Northern Hills'),
('Bob White', 'River Delta'),
('Carol King', 'Mountain Range')
;

INSERT INTO species (common_name, scientific_name, discovery_date, conservation_status) VALUES
('Snow Leopard', 'Panthera uncia', '1775-01-01', 'Endangered'),
('Bengal Tiger', 'Panthera tigris', '1758-01-01', 'Endangered'),
('Red Panda', 'Ailurus fulgens', '1825-01-01', 'Vulnerable'),
('Asiatic Elephant', 'Elephas maximus indicus', '1758-01-01', 'Endangered');

INSERT INTO sightings (species_id, ranger_id, location, sighting_time, notes) VALUES
(1, 1, 'Peak Ridge', '2024-05-10 07:45:00', 'Camera trap image captured'),
(2, 2, 'Bankwood Area', '2024-05-12 16:20:00', 'Juvenile seen'),
(3, 3, 'Bamboo Grove East', '2024-05-15 09:10:00', 'Feeding observed')
;

INSERT INTO sightings (species_id, ranger_id, location) VALUES
(1, 2, 'Snowfall Pass')



-- Problem 1
INSERT INTO rangers (name, region) VALUES 
('Derek Fox', 'Coastal Plains')
;

-- Problem 2
SELECT count(DISTINCT species_id) as unique_species_count FROM sightings
;

-- Problem 3
SELECT * FROM sightings
WHERE location like '%Pass%'
;

-- Problem 4
SELECT name, count(*) as total_sightings FROM rangers
JOIN sightings USING(ranger_id)
GROUP BY name
;

-- Problem 5
SELECT common_name FROM species
LEFT JOIN sightings USING(species_id)
WHERE sighting_id is NULL
;

-- Problem 6
SELECT common_name, sighting_time, name  FROM species
JOIN sightings USING(species_id)
JOIN rangers USING(ranger_id) ORDER BY sighting_time DESC LIMIT 2
;

-- Problem 7
UPDATE species
SET conservation_status = 'Historic'
WHERE extract(YEAR FROM discovery_date) < 1800
;

-- Problem 8
CREATE OR REPLACE FUNCTION timeToLabel(ts TIMESTAMP)
RETURNS text
LANGUAGE plpgsql
AS $$
BEGIN
    IF ts::TIME BETWEEN TIME '00:00:00' AND TIME '11:59:59' THEN
        RETURN 'Morning';
    ELSIF ts::TIME BETWEEN TIME '12:00:00' AND TIME '17:59:59' THEN
        RETURN 'Afternoon';
    ELSE
        RETURN 'Evening';
    END IF;
END;
$$;

SELECT sighting_id, timeToLabel(sighting_time) as time_of_day FROM sightings;

-- Problem 9
DELETE FROM rangers
where ranger_id in (
    SELECT ranger_id FROM rangers
    LEFT JOIN sightings USING (ranger_id)
    WHERE species_id is NULL
)