delete from client_lines where orderdate=TO_DATE('2014-03-09 07:17:49', 'YYYY-MM-DD HH24:MI:SS') AND barcode='QIQ43968I541183';
INSERT INTO CLIENT_LINES VALUES(
    TO_DATE('2014-03-09 07:17:49', 'YYYY-MM-DD HH24:MI:SS'),
    'narvaez',
    'Valverde de la Alameda',
    'Spain',
    'QIQ43968I541183',
    2.8,
    9999,
    'CREDIT CARD',
    TO_DATE('06/09/23', 'DD/MM/YY'),
    904411953814
);


select town, country, username, TO_CHAR(orderdate, 'YYYY-MM-DD HH24:MI:SS')
from CLIENT_LINES fetch first 10 rows only;