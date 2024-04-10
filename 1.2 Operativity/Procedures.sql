DROP PACKAGE caffeine

------------------------------------------------

-- Package Description
CREATE OR REPLACE PACKAGE caffeine AS
    PROCEDURE update_status;
    PROCEDURE my_report (v_TAXID Replacements.TAXID%TYPE);
END caffeine;

-- Implementation (package body)
CREATE OR REPLACE PACKAGE BODY caffeine AS
    PROCEDURE update_status IS
	BEGIN
        FOR orde IN (SELECT DISTINCT barCode FROM Replacements WHERE status = 'D') 
            LOOP
			 BEGIN
                UPDATE Replacements
                SET status = 'P'
                WHERE barCode = orde.barCode;
			  END;
            END LOOP;
    END update_status;

    PROCEDURE my_report (v_TAXID  IN Replacements.TAXID%TYPE) IS
        v_total number(10);
        aux_avg number(10);
        aux_total number(10);
        v_average number(10);
		v_avgcost number(10);
		v_cost number(10);
		v_mincost number(10);
		v_maxcost number(10);
		v_diffcost number(10);
		aux_diffoffer number(10);
		v_diffoffer number(10);
		orde char(15);
		  
    BEGIN
        -- number of orders placed/fulfilled in the last year
        SELECT count(*) INTO v_total FROM Replacements
        WHERE status in ('P','F')
        AND EXTRACT(YEAR FROM orderdate) = EXTRACT(YEAR FROM SYSDATE) - 1
        AND TAXID = v_TAXID;
        DBMS_OUTPUT.PUT_LINE('Number of orders P/F in the last year ' || v_total);

        -- average delivery period for already fulfilled offers
        SELECT SUM(deldate - orderdate), count(*) INTO aux_avg, aux_total FROM Replacements
        WHERE status in ('F')
        AND EXTRACT(YEAR FROM orderdate) = EXTRACT(YEAR FROM SYSDATE) - 1
        AND TAXID = v_TAXID;
        IF aux_total = 0 THEN 
            v_average := 0;
            DBMS_OUTPUT.PUT_LINE('No orders done');
        ELSE
            v_average := aux_avg/aux_total;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Average delivery period ' || v_average);

        -- Orders info
        FOR orde IN (SELECT DISTINCT a.barcode FROM Supply_Lines a, Replacements b 
		WHERE a.TAXID = v_TAXID AND a.TAXID = b.TAXID AND a.barcode = b.barcode)
        LOOP
            BEGIN
                -- current cost
                SELECT cost INTO v_cost FROM Supply_Lines 
                WHERE  TAXID = v_TAXID
                AND barcode = orde.barcode;
                DBMS_OUTPUT.PUT_LINE('---  Barcode ----- ' || orde.barcode);
		DBMS_OUTPUT.PUT_LINE('Current cost ' || v_cost);

		-- min cost
		SELECT MIN(payment/units) INTO v_mincost FROM Replacements
		WHERE  TAXID = v_TAXID
		AND barcode = orde.barcode
		AND EXTRACT(YEAR FROM orderdate) = EXTRACT(YEAR FROM SYSDATE)-1;
		DBMS_OUTPUT.PUT_LINE('Minimum cost ' || v_mincost);

		-- max cost
		SELECT MAX(payment/units) INTO v_maxcost FROM Replacements
		WHERE  TAXID = v_TAXID
		AND barcode = orde.barcode
		AND EXTRACT(YEAR FROM orderdate) = EXTRACT(YEAR FROM SYSDATE)-1;
		DBMS_OUTPUT.PUT_LINE('Maximum cost ' || v_maxcost);

		-- difference regarding the best offer for the product
		SELECT MIN(payment/units) INTO aux_diffoffer FROM Replacements
		WHERE  TAXID = v_TAXID
		AND barcode = orde.barcode
		AND EXTRACT(YEAR FROM orderdate) = EXTRACT(YEAR FROM SYSDATE)-1;
		
		v_diffoffer := v_cost - aux_diffoffer;
		DBMS_OUTPUT.PUT_LINE('Difference of offer ' || v_diffoffer);
	
		-- average cost (payment/units)
		SELECT AVG(payment/units) INTO v_avgcost FROM Replacements
		WHERE  TAXID = v_TAXID
		AND barcode = orde.barcode
		AND EXTRACT(YEAR FROM orderdate) = EXTRACT(YEAR FROM SYSDATE)-1;
		
		-- difference of current cost minus the average of costs of all offers
		v_diffcost := v_cost - v_avgcost;
		DBMS_OUTPUT.PUT_LINE('Difference of costs ' || v_diffcost);
            END;
        END LOOP;
    END my_report;
END caffeine;
/
