WITH SalesData AS (
    SELECT 
        l.contact AS username, 
        r.product AS product_name, 
        r.price, 
        p.varietal,
        l.orderdate, 
        TRIM(l.dliv_country) AS country, 
        l.dliv_town AS town,
        CAST(l.quantity AS INTEGER) AS quantity,
        l.barCode 
    FROM 
        Lines_Anonym l
    JOIN
        References r ON l.barCode = r.barCode
    JOIN
        Products p ON r.product = p.product
    WHERE 
        EXTRACT(YEAR FROM orderdate) = 2023 
    UNION ALL 
    SELECT DISTINCT 
        l.username, 
        r.product AS product_name, 
        r.price, 
        p.varietal,
        l.orderdate, 
        TRIM(l.country) AS country, 
        l.town,
        CAST(l.quantity AS INTEGER) AS quantity,
        l.barCode as barCode
    FROM 
        Client_Lines l
    JOIN
        References r ON l.barCode = r.barCode
    JOIN
        Products p ON r.product = p.product
    WHERE 
        EXTRACT(YEAR FROM orderdate) = 2023
),
TotalAmountPerVarietal AS (
    Select 
        varietal,
        SUM(quantity) AS total_units_sold
    FROM
        SalesData
    GROUP BY
        varietal
),
RankedVarietals AS (
    SELECT 
        country,
        varietal,
        COUNT(DISTINCT username) AS num_buyers,
        SUM(quantity) AS total_units_sold,
        COUNT(DISTINCT product_name) AS num_references,
        SUM(quantity) / COUNT(DISTINCT product_name) AS avg_units_per_reference,
        ROW_NUMBER() OVER (PARTITION BY country ORDER BY SUM(quantity) DESC) AS rank,
        CONCAT(SUM(price * quantity), ' €') AS total_revenue
    FROM 
        SalesData
    GROUP BY 
        country, varietal
)
SELECT 
    rv.country,
    rv.varietal,
    CASE 
        WHEN rv.total_units_sold > 0.01 * tav.total_units_sold THEN 'Yes'
        ELSE 'No'
    END AS Candidate,
    rv.num_buyers,
    rv.total_units_sold,
    rv.avg_units_per_reference,
    TRIM(rv.total_revenue) AS total_revenue
FROM 
    RankedVarietals rv
JOIN
    TotalAmountPerVarietal tav ON rv.varietal = tav.varietal
WHERE 
    rank = 1 
ORDER BY 
    country;
