create or replace view my_purchases as (
    select 
      NVL(TO_CHAR(cl.orderdate, 'DD-MM-YYYY') , 'NaN') as orderdate,
      NVL(cl.username, 'NaN') as username,
      NVL(cl.town, 'NaN') as town,
      NVL(cl.country, 'NaN') as country,
      LTRIM(NVL(TO_CHAR(cl.price), 'NaN')) as price,
      RPAD(NVL(cl.quantity, 'NaN'), 2) as quantity,
      NVL(cl.pay_type, 'NaN') as pay_type,
      NVL(TO_CHAR(cl.pay_datetime, 'DD-MM-YYYY'), 'NaN') as pay_date,
      NVL(r.product, 'NaN') as product,
      RPAD(NVL(r.format, 'NaN'), 2) as format,
      NVL(r.pack_type, 'NaN') as pack_type
    from References r
    join Client_Lines cl on r.barCode = cl.barcode   
    where username = current_user
);
select * from my_purchases;

   
-- The problem is that there is no data with the user fsdb279 in the Orders_Clients table,
-- thus we use a package to change the user to check if the view is working
-- Using a pckage to create the view
CREATE OR REPLACE PACKAGE USER_INFO__PKG AS
  current_user VARCHAR2(50); -- Define the variable in the package specification
END USER_INFO__PKG;
/
CREATE OR REPLACE PACKAGE BODY USER_INFO__PKG AS
BEGIN
  current_user := user; -- <-- Here is where the user is changed to check  if the view is working
END USER_INFO__PKG;
/

-- Function to get the current_user from the package
CREATE OR REPLACE FUNCTION current_user RETURN VARCHAR2 IS
BEGIN
  RETURN USER_INFO__PKG.current_user;
END current_user;





