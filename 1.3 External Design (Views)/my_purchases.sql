create or replace view my_purchases as (
    select 
      TO_CHAR(cl.orderdate, 'DD-MM-YYYY') as orderdate,
      cl.username as username,
      cl.town as town,
      cl.country as country,
      LTRIM(TO_CHAR(cl.price)) as price,
      RPAD(cl.quantity, 2) as quantity,
      cl.pay_type as pay_type,
      TO_CHAR(cl.pay_datetime, 'DD-MM-YYYY') as pay_date,
      r.product as product,
      RPAD(r.format, 2) as format,
      r.pack_type as pack_type
    from Client_Lines cl 
    join References r on r.barCode = cl.barcode   
    where username = current_user
) with read only;
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
  current_user := 'ethel'; -- <-- Here is where the user is changed to check  if the view is working
END USER_INFO__PKG;
/

-- Function to get the current_user from the package
CREATE OR REPLACE FUNCTION current_user RETURN VARCHAR2 IS
BEGIN
  RETURN USER_INFO__PKG.current_user;
END current_user;


