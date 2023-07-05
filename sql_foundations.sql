SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'spatial' AND TABLE_NAME =  'us_cities';

SELECT us_cities.city
FROM spatial.us_cities
WHERE us_cities.pop90 > 700000 AND us_cities.pop90 < 1000000
ORDER BY us_cities.city;

SELECT AVG(us_cities.pop90)
FROM spatial.us_cities
WHERE us_cities.state_abrv = 'NY';

SELECT us_states.state, age65_up, age0_17
FROM spatial.us_states
WHERE us_states.age65_up > us_states.age0_17 * 0.75;

SELECT us_cities.city, us_states.state
FROM spatial.us_cities JOIN spatial.us_states
ON us_cities.state_abrv = us_states.state_abrv
WHERE us_cities.city LIKE '%land'
ORDER BY us_states.state DESC;

SELECT us_states.state, MIN(us_cities.rank90), MAX(us_cities.rank90)
FROM spatial.us_cities JOIN spatial.us_states
ON us_cities.state_abrv = us_states.state_abrv
GROUP BY us_states.state
ORDER BY us_states.state;

SELECT us_cities.city
FROM spatial.us_cities
WHERE us_cities.rank90 > 0 AND us_cities.rank90 <11 
AND us_cities.state_abrv NOT IN
	(SELECT us_states.state_abrv 
	FROM spatial.us_states
	ORDER BY totpop DESC
	LIMIT 10);

CREATE TABLE mycities (
	city VARCHAR(32),
	pop90 INT
);

INSERT INTO cmatsumoto.mycities (city, pop90)
SELECT us_cities.city, us_cities.pop90 
FROM spatial.us_cities
ORDER BY us_cities.pop90 DESC
LIMIT 20;

DROP TABLE cmatsumoto.mycities;





