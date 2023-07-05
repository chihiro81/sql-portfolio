SELECT a.city, a.state_abrv, b.state_abrv, ST_Distance(a.location, b.location, true)/1000 AS distance
FROM spatial.us_cities a, spatial.us_cities b
WHERE a.city = b.city
ORDER BY distance DESC
LIMIT 1;

SELECT name, system, ST_Length(geom, true)/1000 AS length
FROM spatial.us_rivers
WHERE ST_Length(geom, true)/1000 IN
	(SELECT MAX(ST_Length(geom, true)/1000)
	FROM spatial.us_rivers
	WHERE LENGTH(system) > 0
	GROUP BY system)
ORDER BY length DESC;

SELECT cntry_name
FROM spatial.world_countries
ORDER BY LENGTH(ST_asText(geom))-LENGTH(REPLACE(ST_asText(geom), '(', '')) DESC
LIMIT 5;

SELECT direction, area
FROM(
	SELECT 'North' direction, SUM(n.landsqmi) area
	FROM spatial.us_states o, spatial.us_states n
	WHERE o.state = 'Ohio' AND n.state != 'Ohio' 
		AND degrees(ST_Azimuth(ST_Centroid(o.geom, true), ST_Centroid(n.geom, true))) >= -45 
		AND degrees(ST_Azimuth(ST_Centroid(o.geom, true), ST_Centroid(n.geom, true))) < 45
	UNION
	SELECT 'East' direction, SUM(n.landsqmi) area
	FROM spatial.us_states o, spatial.us_states n
	WHERE o.state = 'Ohio' AND n.state != 'Ohio' 
		AND degrees(ST_Azimuth(ST_Centroid(o.geom, true), ST_Centroid(n.geom, true))) >= 45 
		AND degrees(ST_Azimuth(ST_Centroid(o.geom, true), ST_Centroid(n.geom, true))) < 135
	UNION
	SELECT 'South' direction, SUM(n.landsqmi) area
	FROM spatial.us_states o, spatial.us_states n
	WHERE o.state = 'Ohio' AND n.state != 'Ohio' 
		AND (degrees(ST_Azimuth(ST_Centroid(o.geom, true), ST_Centroid(n.geom, true))) >= 135
		OR degrees(ST_Azimuth(ST_Centroid(o.geom, true), ST_Centroid(n.geom, true))) < -135)
	UNION
	SELECT 'West' direction, SUM(n.landsqmi) area
	FROM spatial.us_states o, spatial.us_states n
	WHERE o.state = 'Ohio' AND n.state != 'Ohio' 
		AND degrees(ST_Azimuth(ST_Centroid(o.geom, true), ST_Centroid(n.geom, true))) >= -135
		AND degrees(ST_Azimuth(ST_Centroid(o.geom, true), ST_Centroid(n.geom, true))) < -45
) RESULTS
ORDER BY direction;

SELECT (ST_Distance(ST_GeomFromText('POINT(144.8433 -37.6709)', 4326), ST_GeomFromText('POINT(103.9915 1.3644)', 4326), true)
			+ST_Distance(ST_GeomFromText('POINT(103.9915 1.3644)', 4326), ST_GeomFromText('POINT(-0.4543 51.4700)', 4326), true))
		/ST_Distance(ST_GeomFromText('POINT(144.8433 -37.6709)', 4326), ST_GeomFromText('POINT(-0.4543 51.4700)', 4326), true)*100 AS percent,
	(ST_Distance(ST_GeomFromText('POINT(144.8433 -37.6709)', 4326), ST_GeomFromText('POINT(103.9915 1.3644)', 4326), true)
	 +ST_Distance(ST_GeomFromText('POINT(103.9915 1.3644)', 4326), ST_GeomFromText('POINT(-0.4543 51.4700)', 4326), true)
	 -ST_Distance(ST_GeomFromText('POINT(144.8433 -37.6709)', 4326), ST_GeomFromText('POINT(-0.4543 51.4700)', 4326), true))
	 /1000 AS kilometres;
	 
SELECT cntry_name, ST_Area(geom, False)/1000000 AS shpere, ST_Area(geom, True)/1000000 AS spheroid, ST_Area(geom, True)/ST_Area(geom, False)*100 AS ration
FROM spatial.world_countries
WHERE cntry_name = 'Ecuador'
UNION
SELECT cntry_name, ST_Area(geom, False)/1000000 AS shpere, ST_Area(geom, True)/1000000 AS spheroid, ST_Area(geom, True)/ST_Area(geom, False)*100 AS ration
FROM spatial.world_countries
WHERE cntry_name = 'Norway';

SELECT us_cities.city, us_states.state
FROM spatial.us_cities JOIN spatial.us_states
ON us_cities.state_abrv = us_states.state_abrv
WHERE us_cities.id IN
	(SELECT c.id
	FROM spatial.us_cities c, spatial.us_interstates i
	WHERE i.interstate = 'I10' AND ST_Distance(c.location, i.geom, True)/1000 >= 5 AND ST_Distance(c.location, i.geom, True)/1000 <= 30)
ORDER BY us_cities.city;

SELECT (ST_Area(a.geom, true)-ST_Area(ST_Buffer(a.geom::geography, -20), true))/1000000 AS lost, b.cntry_name
FROM spatial.world_countries a, spatial.world_countries b
WHERE a.cntry_name = 'Australia' 
ORDER BY ABS(ST_Area(b.geom, true)-(ST_Area(a.geom, true)-ST_Area(ST_Buffer(a.geom::geography, -20), true)))
LIMIT 1;