create or replace view my_purchases as (
    select * from Orders_Clients
    where username = current_user
)
   
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





