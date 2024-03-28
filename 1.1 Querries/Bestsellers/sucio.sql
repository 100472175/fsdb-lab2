-- Para seleccionar las orders del año pasado de los no registrados:
SELECT
    contact AS username,
    barCode,
    orderdate,
    dliv_country as country,
    dliv_town as town 
FROM
    Lines_Anonym 
WHERE
    EXTRACT(YEAR FROM orderdate) = 2023;

-- Para seleccionar las orders del año pasado de los registrados:
Select distinct username, barcode, orderdate, country, town from Client_Lines where EXTRACT(YEAR FROM orderdate)= 2023;

-- Selecciona todos los pedidos del año pasado:
SELECT 
    l.contact AS username, 
    r.product as product_name, 
    p.varietal,
    l.orderdate, 
    l.dliv_country as country, 
    l.dliv_town as town 
FROM 
    Lines_Anonym l
JOIN
    References R ON l.barCode = r.barCode
JOIN
    Products P ON r.product = p.product
WHERE 
    EXTRACT(YEAR FROM orderdate) = 2023 

UNION ALL 

SELECT DISTINCT 
    l.username, 
    R.product as product_name, 
    p.varietal,
    l.orderdate, 
    l.country as country, 
    l.town 
from 
    Client_Lines L
JOIN
    References R ON L.barCode = R.barCode
JOIN
    Products P ON r.product = p.product
where 
    country like 'Spain' AND EXTRACT(YEAR FROM orderdate)= 2023;
--5290


-- Para seleccionar los productos más vendidos por país:


With SalesData AS (SELECT 
    l.contact AS username, 
    r.product as product_name, 
    p.varietal,
    l.orderdate, 
    l.dliv_country as country, 
    l.dliv_town as town,
    CAST(l.quantity AS INTEGER) AS quantity
FROM 
    Lines_Anonym l
JOIN
    References R ON l.barCode = r.barCode
JOIN
    Products P ON r.product = p.product
WHERE 
    EXTRACT(YEAR FROM orderdate) = 2023 
UNION ALL 
SELECT DISTINCT 
    l.username, 
    R.product as product_name, 
    p.varietal,
    l.orderdate, 
    l.country, 
    l.town,
    CAST(l.quantity AS INTEGER) AS quantity
from 
    Client_Lines L
JOIN
    References R ON L.barCode = R.barCode
JOIN
    Products P ON r.product = p.product
where 
    EXTRACT(YEAR FROM orderdate)= 2023)
WITH RankedVarietals AS (
    SELECT 
        country,
        varietal,
        ROW_NUMBER() OVER (PARTITION BY country ORDER BY SUM(quantity) DESC) AS rank
    FROM 
        SalesData
    GROUP BY 
        country, varietal
)
SELECT 
    country,
    varietal
FROM 
    RankedVarietals
WHERE 
    rank = 1;


