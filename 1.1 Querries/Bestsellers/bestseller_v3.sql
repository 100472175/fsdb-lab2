
WITH Client_Purchases AS (
    Select 
    country, 
    SUM(cl.quantity) as quantity, 
    username, 
    cl.barcode,
    p.varietal
    FROM Client_Lines cl, References r, PRODUCTS p 
        WHERE r.barcode = cl.barcode AND 
                p.product = r.product
    GROUP BY country, username, cl.barcode, p.varietal
), DATA AS (
    select
        TRIM(country) as country, 
        SUM(quantity) as sum_quantity,
        varietal
        FROM Client_Purchases
        GROUP BY country, varietal
),
P_DATA AS (
    Select max(sum_quantity) as sum_quant, TRIM(country) as country
    from DATA
    GROUP BY country
),
varietals_registered as (
    Select d.country, varietal, sum_quant from 
        DATA d
        JOIN P_DATA p ON d.country = p.country
        WHERE sum_quantity = sum_quant
        ORDER BY d.country
),
Anonym_Purchases AS (
    Select 
    dliv_country as country, 
    SUM(la.quantity) as quantity, 
    contact, 
    la.barcode,
    p.varietal
    FROM Lines_Anonym la, References r, PRODUCTS p 
        WHERE r.barcode = la.barcode AND 
                p.product = r.product
    GROUP BY dliv_country, contact, la.barcode, p.varietal
),
DATA_A AS (
    select
        TRIM(country) as country, 
        SUM(quantity) as sum_quantity,
        varietal
        FROM Anonym_Purchases cl 
        GROUP BY country, varietal
),
P_DATA_A AS (
    Select max(sum_quantity) as sum_quant, TRIM(country) as country
    from DATA_A
    GROUP BY country
),
varietals_anonym as (
    Select d.country, varietal, sum_quant from 
        DATA_A d
        JOIN P_DATA_A p ON d.country = p.country
        WHERE sum_quantity = sum_quant
        ORDER BY d.country
),
joined_users as (
    select * from Client_Purchases 
    UNION ALL
    select * from Anonym_Purchases
),
varietal_country_max as (
SELECT country, varietal, max(sum_quant) as sum_quant
from (SELECT * FROM varietals_registered
    UNION ALL
    SELECT * FROM varietals_anonym)
GROUP BY country, varietal
)
Select vcm.country, vcm.varietal, vcm.sum_quant, COUNT(*)
from varietal_country_max vcm, joined_users ju
WHERE vcm.country = ju.country AND vcm.varietal = ju.varietal
GROUP BY vcm.country, vcm.varietal, vcm.sum_quant;

