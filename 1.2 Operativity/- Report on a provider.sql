CREATE OR REPLACE PROCEDURE my_report IS
DECLARE
	v_TAXID varchar(20) := '&id';
	v_total number(10);
	aux_avg number(10);
	aux_total number(10);
	v_average number(10);


BEGIN
	-- number of orders placed/fulfilled in the last year
	SELECT count(*) INTO v_total FROM Replacements
	WHERE status in ('P','F')
	AND EXTRACT(YEAR FROM orderdate) = EXTRACT(YEAR FROM SYSDATE)-1
	AND TAXID = v_TAXID;
	DBMS_OUTPUT.PUT_LINE('Number of orders P/F in the last year ' || v_total);

	-- average delivery period for already fulfilled offers
	SELECT SUM(deldate - orderdate), count(*) INTO aux_avg, aux_total FROM Replacements
	WHERE status in ('F')
	AND EXTRACT(YEAR FROM orderdate) = EXTRACT(YEAR FROM SYSDATE)-1
	AND TAXID = v_TAXID;
	IF aux_total = 0 THEN 
		v_average := NULL;
		DBMS_OUTPUT.PUT_LINE('No orders done');
	ELSE
		v_average := aux_avg/aux_total;
	END IF;
	DBMS_OUTPUT.PUT_LINE('Average delivery period ' || v_average);

 END;


