
WITH Client_Purchases AS (
    Select 
    country, 
    SUM(quantity) as quantity, 
    username, 
    barcode
    FROM Client_Lines 
    GROUP BY country, username, barcode
), DATA AS (
    select
        TRIM(cl.country) as country, 
        SUM(cl.quantity) as sum_quantity,
        p.varietal
        FROM Client_Purchases cl, References r, PRODUCTS p 
        WHERE r.barcode = cl.barcode AND 
                p.product = r.product
        GROUP BY country, varietal
),
P_DATA AS (
    Select max(sum_quantity) as sum_quant, TRIM(country) as country
    from DATA
    GROUP BY country
)
Select d.country, varietal, sum_quant from 
    DATA d
    JOIN P_DATA p ON d.country = p.country
    WHERE sum_quantity = sum_quant
    ORDER BY d.country;

-------------------------------------------

WITH Anonym_Purchases AS (
    Select 
    dliv_country as country, 
    SUM(quantity) as quantity, 
    contact, 
    barcode
    FROM Lines_Anonym 
    GROUP BY dliv_country, contact, barcode
),
DATA AS (
    select
        TRIM(cl.country) as country, 
        SUM(cl.quantity) as sum_quantity,
        p.varietal
        FROM Anonym_Purchases cl, References r, PRODUCTS p 
        WHERE r.barcode = cl.barcode AND 
                p.product = r.product
        GROUP BY country, varietal
),
P_DATA AS (
    Select max(sum_quantity) as sum_quant, TRIM(country) as country
    from DATA
    GROUP BY country
)
Select d.country, varietal, sum_quant from 
    DATA d
    JOIN P_DATA p ON d.country = p.country
    WHERE sum_quantity = sum_quant
    ORDER BY d.country;