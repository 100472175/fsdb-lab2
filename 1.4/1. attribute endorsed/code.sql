CREATE OR REPLACE TRIGGER endorsed
AFTER INSERT ON Posts
FOR EACH ROW
DECLARE
	purchased NUMBER;
BEGIN
	SELECT count(*) INTO purchased FROM Orders_Clients a
	JOIN Client_Lines b ON a.username = b.username
	AND a.orderdate = b.orderdate
	WHERE a.username = :new.username;
	IF purchased > 0 THEN
		UPDATE Posts 
		SET endorsed = 'Y'
		WHERE postdate = :new.postdate;
	ELSE
		UPDATE Posts 
		SET endorsed = 'N'
		WHERE postdate = :new.postdate;
	END IF;
END;

