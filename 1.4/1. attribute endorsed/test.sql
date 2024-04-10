-- Get all data
WITH Anonym_Data AS (
    SELECT
        l.contact AS username,
        r.product AS PRODUCT,
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
),
Client_Data AS (
    SELECT  
        l.username,
        r.product AS PRODUCT,
        r.price,
        p.varietal,
        l.orderdate,
        TRIM(l.country) AS country,
        l.town,
        CAST(l.quantity AS INTEGER) AS quantity,
        l.barCode AS barCode
    FROM
        Client_Lines l
    JOIN
        References r ON l.barCode = r.barCode
    JOIN
        Products p ON r.product = p.product
),
SalesData AS (
    --SELECT * FROM Anonym_Data
    --UNION ALL
    SELECT * FROM Client_Data
)
SELECT 'UPDATE POSTS SET TITLE='||''''||B.TITLE||''''||' WHERE username='||''''||b.username||''''||' AND PRODUCT='||''''||b.PRODUCT||''''||' AND POSTDATE='||'TO_DATE('||''''||to_char(b.POSTDATE,'yyyy/mm/dd hh24:mi:ss')||''''||','||''''||'yyyy/mm/dd hh24:mi:ss'||''''||');'
from SalesData a, posts b where a.username=b.username and a.PRODUCT=b.PRODUCT and rownum < 51
union
SELECT 'INSERT INTO POSTS (USERNAME,POSTDATE,BARCODE,PRODUCT,SCORE,TITLE,TEXT,LIKES,ENDORSED) VALUES ('||''''||a.username||''''||','
||'TO_DATE('||''''||to_char(sysdate,'yyyy/mm/dd hh24:mi:ss')||''''||','||''''||'yyyy/mm/dd hh24:mi:ss'||''''||'),'||chr(10)
||''''||a.BARCODE||''''||','||''''||a.PRODUCT||''''||','||0||','||''''||'Titulo'||''''||','||''''||'Texto'||''''||','||0||','||'TO_DATE('||''''||to_char(a.orderdate,'yyyy/mm/dd hh24:mi:ss')||''''||','||''''||'yyyy/mm/dd hh24:mi:ss'||''''||'));'
from SalesData a
where not exists (select * from posts b where a.username=b.username and a.PRODUCT=b.PRODUCT)
and rownum < 51;
-- 98 filas seleccionadas.  


-- Check insert
INSERT INTO POSTS (USERNAME,POSTDATE,BARCODE,PRODUCT,SCORE,TITLE,TEXT,LIKES,ENDORSED)
VALUES ('juani',TO_DATE('2024/04/10 21:39:00','yyyy/mm/dd hh24:mi:ss'), 'OII04455O419282','Amiga',0,'Titulo','Texto',0,TO_DATE('2023/07/09 01:32:09','yyyy/mm/dd hh24:mi:ss'));

-- Check update
UPDATE POSTS SET TITLE='KiLKZ eoBKWZyr' WHERE username='antezana' AND PRODUCT='Cabra jazz' AND POSTDATE=TO_DATE('2014/07/15 08:17:21','yyyy/mm/dd hh24:mi:ss');

-- Check if dates are correct
select USERNAME,POSTDATE,BARCODE, ENDORSED from posts where USERNAME='&1' and BARCODE='&2';
select USERNAME,POSTDATE,BARCODE, ENDORSED from posts where USERNAME='&1' and POSTDATE='&2';

SELECT max(a.ORDERDATE) 
		FROM Orders_Clients a, Client_Lines b
		WHERE a.username = b.username AND a.orderdate = b.orderdate
		AND  a.username = '&1' and b.barcode = '&2';
		
		
