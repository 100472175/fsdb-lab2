WITH DATA AS (
    SELECT orderdate, barcode, cast(quantity as NUMBER(12,2)) as quantity
    FROM Client_Lines
    WHERE orderdate >= SYSDATE - INTERVAL '12' month
    UNION ALL
    SELECT orderdate, barcode, quantity
    FROM Lines_Anonym
    WHERE orderdate >= SYSDATE - INTERVAL '12' month
)
SELECT barcode, EXTRACT(MONTH FROM orderdate) as month, sum(quantity) AS frequency
FROM DATA
WHERE EXTRACT(MONTH FROM orderdate)='1'
GROUP BY barcode, EXTRACT(MONTH FROM orderdate)
ORDER BY month, frequency DESC
fetch first 1 row only;


INSERT INTO replacements (taxID, barCode, orderdate, units, deldate, payment) 
VALUES('A22475697M', 'IIQ67472I907468', TO_DATE('2023-05-05', 'YYYY-MM-DD'), 100, NULL, 100.25);

