WITH SalesData AS (
    SELECT 
        TO_CHAR(l.orderdate,'Month') AS MONTH,
        l.contact AS username, 
        r.product AS product_name, 
        r.price, 
        CAST(l.quantity AS INTEGER) AS quantity,
        l.barCode 
    FROM 
        Lines_Anonym l
    JOIN
        References r ON l.barCode = r.barCode
    WHERE 
        l.orderdate >= SYSDATE - INTERVAL '12' month 
    UNION ALL 
    SELECT DISTINCT 
        TO_CHAR(l.orderdate,'Month') AS MONTH,
        l.username as username, 
        r.product AS product_name, 
        r.price,
        CAST(l.quantity AS INTEGER) AS quantity,
        l.barCode as barCode
    FROM 
        Client_Lines l
    JOIN
        References r ON l.barCode = r.barCode
    WHERE 
        EXTRACT(YEAR FROM orderdate) = 2023
),
AverageCostPerBarcode AS (
    SELECT 
        barCode,
        AVG(cost) AS avg_cost
    FROM
        Supply_Lines
    GROUP BY
        barCode
)
Select
    MONTH, 
    ranked_data.barCode AS best_sold_reference,
    0 as units_purchased, --Number of purchases es las que se han pedido a los proveedores
    total_quantity AS units_sold,
    total_income,
    total_income-(avg_cost*total_quantity) as benefit
FROM (
    Select
        MONTH,
        product_name,
        price,
        SUM(quantity) as total_quantity,
        SalesData.barCode,
        SUM(price * quantity) AS total_income,
        ROW_NUMBER() OVER (PARTITION BY MONTH ORDER BY SUM(quantity) DESC) AS rank 
    FROM
        SalesData
    GROUP BY
        MONTH, product_name, price, SalesData.barCode
) ranked_data 
JOIN
    AverageCostPerBarcode ON ranked_data.barCode = AverageCostPerBarcode.barCode
WHERE
    rank = 1
ORDER BY
    TO_DATE(MONTH,'Month') DESC;  