CREATE OR REPLACE TRIGGER endorsed  
BEFORE INSERT or UPDATE ON Posts
FOR EACH ROW
BEGIN
	DECLARE purchased DATE := NULL;
	BEGIN
		SELECT max(a.ORDERDATE) INTO purchased 
		FROM Orders_Clients a, Client_Lines b
		WHERE a.username = b.username AND a.orderdate = b.orderdate
		AND b.barcode = :new.barcode AND a.username = :new.username;
		IF purchased IS NOT NULL THEN
		   :new.endorsed := purchased;
		ELSE
		   :new.endorsed := NULL;
		END IF;
	END;
END endorsed;
