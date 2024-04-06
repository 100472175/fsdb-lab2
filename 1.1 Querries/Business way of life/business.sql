-- Data FROM each sale FROM both registered and anonymous clients.
WITH Anonymous AS (
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
        l.orderdate BETWEEN add_months(sysdate, -12) and add_months(sysdate, -1)
),
Registered AS ( 
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
        l.orderdate BETWEEN add_months(sysdate, -12) and add_months(sysdate, -1)
),
SalesData AS (
    SELECT * FROM Registered
    UNION ALL (select * FROM Anonymous)
),
-- Average cost per barcode.
AverageCostPerBarcode AS (
    SELECT 
        barCode,
        AVG(cost) AS avg_cost
    FROM
        Supply_Lines
    GROUP BY
        barCode
),
Ranked_Data AS (
    SELECT
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
)
-- Rettrieve the data FROM the sales and the average cost per barcode, selecting only the first one for each month.
SELECT
    MONTH, 
    ranked_data.barCode AS best_sold_reference,
    NVL(r.units, 0) as units_bought, --Number of purchases es las que se han pedido a los proveedores
    total_quantity AS units_sold,
    total_income,
    total_income-(avg_cost*total_quantity) as benefit
FROM Ranked_Data 
JOIN
    AverageCostPerBarcode ON ranked_data.barCode = AverageCostPerBarcode.barCode
LEFT OUTER JOIN
    Replacements r ON ranked_data.barCode = r.barCode
WHERE
    rank = 1
ORDER BY
    TO_DATE(MONTH,'Month') DESC;  
