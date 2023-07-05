USE oandl;


-- Q1
SELECT address1, address2, suburb, postcode, COUNT(o.ID) AS count
FROM Orders o INNER JOIN Clients c INNER JOIN address a
ON o.ClientID = c.ClientID
AND c.ClientID = a.clientID
WHERE firstname = 'Carl'
AND lastname = 'Bach'
GROUP BY a.addressID;



-- Q2
SELECT CONCAT(firstname, ' ', lastname) AS name, LENGTH(CONCAT(firstname, ' ', lastname)) AS length
FROM Clients
ORDER BY length;

-- Q3
SELECT clientID, qty*price AS charge
FROM Orders o INNER JOIN LineItem l INNER JOIN FandV f
ON o.ID = l.OrderID
AND l.FruitVegID = f.ID
WHERE shipped = 'N'
ORDER BY clientID;

-- Q4
SELECT DISTINCT(name)
FROM FandV
WHERE priceend IS NOT NULL
AND name NOT IN
	(SELECT name
     FROM FandV
     WHERE priceend IS NULL)
ORDER BY name;


-- Q5
SELECT name
FROM FandV f
GROUP BY name
HAVING COUNT(*) = 4
AND name NOT IN
	(SELECT name
     FROM LineItem l INNER JOIN FandV f
     ON l.FruitVegID = f.ID);

-- Q6
SELECT c.tradingname, SUM(qty*price) cost
FROM Clients c INNER JOIN Orders o INNER JOIN LineItem l INNER JOIN FandV f
ON c.ClientID = o.ClientID
AND o.ID = l.OrderID
AND l.FruitVegID = f.ID
WHERE MONTHNAME(orderdate) = 'September'
AND c.type = 'trade'
GROUP BY c.clientID
HAVING cost < 6000
ORDER BY tradingname;

-- Q7
SELECT c.tradingname, CONCAT(c.firstname, ' ', c.lastname) name, SUM(qty*price) cost, MONTHNAME(orderdate) monthly
FROM Clients c INNER JOIN Orders o INNER JOIN LineItem l INNER JOIN FandV f
ON c.ClientID = o.ClientID
AND o.ID = l.OrderID
AND l.FruitVegID = f.ID
GROUP BY c.clientID, monthly
ORDER BY tradingname, name;


-- Q8
(SELECT CONCAT(firstname, ' ', lastname, ' ', tradingname) AS name, SUM(qty) AS quantity
FROM Clients c INNER JOIN Orders o INNER JOIN LineItem l INNER JOIN FandV f
ON c.ClientID = o.ClientID
AND o.ID = l.OrderID
AND l.FruitVegID = f.ID
WHERE f.name LIKE '%lemon%'
GROUP BY c.clientID
ORDER BY quantity DESC
LIMIT 1)
UNION
(SELECT CONCAT(firstname, ' ', lastname, ' ', tradingname) AS name, SUM(qty) AS quantity
FROM Clients c INNER JOIN Orders o INNER JOIN LineItem l INNER JOIN FandV f
ON c.ClientID = o.ClientID
AND o.ID = l.OrderID
AND l.FruitVegID = f.ID
WHERE f.name LIKE '%lime%'
GROUP BY c.clientID
ORDER BY quantity DESC
LIMIT 1);

