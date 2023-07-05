SELECT b.cntry_name AS Name, ST_Length(ST_Intersection(a.geom::geography, b.geom::geography), TRUE)/1000 AS Length_km
FROM spatial.world_countries a, spatial.world_countries b
WHERE a.cntry_name = 'Italy' AND ST_Touches(a.geom, b.geom)
ORDER BY ST_Perimeter(b.geom, TRUE) DESC;

SELECT a.cntry_name
FROM spatial.world_countries a, spatial.world_countries b
WHERE ST_Touches(a.geom, b.geom)
GROUP BY a.id
HAVING COUNT(b.id) = 5
ORDER BY a.cntry_name;

SELECT i.interstate
FROM spatial.us_states s1, spatial.us_states s2, spatial.us_interstates i
WHERE s1.state = 'Utah' AND s2.state = 'Illinois' AND ST_Crosses(s1.geom, i.geom) AND ST_Crosses(s2.geom, i.geom)
ORDER BY i.interstate;

SELECT b.state 
FROM spatial.us_interstates a, spatial.us_states b
WHERE a.interstate = 'I90' AND ST_Crosses(a.geom, b.geom)
ORDER BY b.state;

SELECT s1.state AS State_1, s2.state AS State_2, ST_Length(ST_Intersection(s1.geom::geography, s2.geom::geography))/1000 AS Border_Length_km, river.name AS River
FROM spatial.us_states s1, spatial.us_states s2, spatial.us_rivers river
WHERE ST_Touches(s1.geom, s2.geom) AND ST_Crosses(s1.geom, river.geom) AND ST_Crosses(s2.geom, river.geom) AND s1.state > s2.state
ORDER BY Border_Length_km DESC
LIMIT 5;

SELECT b.cntry_name AS Name, b.pop_cntry/(ST_Area(b.geom, TRUE)/1000000) AS Density
FROM spatial.world_countries a, spatial.world_countries b
WHERE a.cntry_name = 'Brazil' AND ST_Touches(a.geom, b.geom)
ORDER BY ST_Length(ST_Intersection(a.geom::geography, b.geom::geography), TRUE) DESC;

SELECT states.state
FROM spatial.us_states states, (
	SELECT ST_Union(a.geom) AS geom
	FROM spatial.world_countries a) world
WHERE ST_Intersects(ST_Boundary(world.geom), states.geom)
ORDER BY states.state; 

SELECT state1, state2, state3, CAST(x AS VARCHAR), CAST(y AS VARCHAR)
FROM(
	SELECT state1, state2, state3, x, y
	FROM(
		SELECT ROW_NUMBER() OVER(
		PARTITION BY ST_X(ST_Intersection(ST_Intersection(a.geom, b.geom), c.geom))
		ORDER BY a.geom
		) row_id,
	a.state AS state1, b.state AS state2, c.state AS state3,
	ST_X(ST_Intersection(ST_Intersection(a.geom, b.geom), c.geom)) AS x, ST_Y(ST_Intersection(ST_Intersection(a.geom, b.geom), c.geom)) AS y
	FROM spatial.us_states a, spatial.us_states b, spatial.us_states c
	WHERE a.state < b.state AND b.state < c.state 
	AND ST_Touches(ST_Intersection(a.geom, b.geom), ST_Intersection(b.geom, c.geom))
	AND GeometryType(ST_Intersection(ST_Intersection(a.geom, b.geom), c.geom)) = 'POINT') AS rows
	WHERE rows.row_id = 1
UNION
	SELECT multip.state1 AS state1, multip.state2 AS state2, multip.state3 AS state3, ST_X((ST_Dump(multip.geom)).geom) AS x, ST_y((ST_Dump(multip.geom)).geom) AS y
	FROM (
		SELECT a.state AS state1, b.state AS state2, c.state AS state3, ST_Intersection(ST_Intersection(a.geom, b.geom), c.geom) AS geom
		FROM spatial.us_states a, spatial.us_states b, spatial.us_states c
		WHERE a.state < b.state AND b.state < c.state 
		AND ST_Touches(ST_Intersection(a.geom, b.geom), ST_Intersection(b.geom, c.geom))
		AND GeometryType(ST_Intersection(ST_Intersection(a.geom, b.geom), c.geom)) = 'MULTIPOINT') AS multip
	) RESULTS
ORDER BY state1, state2, state3;
