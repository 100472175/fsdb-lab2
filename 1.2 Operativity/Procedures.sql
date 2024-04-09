
-- Package Description
CREATE OR REPLACE PACKAGE caffeine AS
    PROCEDURE update_status;
    PROCEDURE my_report;
END caffeine;

-- Implementation (package body)
CREATE OR REPLACE PACKAGE BODY caffeine AS
    PROCEDURE update_status IS
    BEGIN
        FOR ord IN (SELECT barCode, status FROM Replacements WHERE status = 'D') 
            LOOP
                UPDATE Replacements
                SET status = REPLACE(ord.status, 'D', 'P')
                WHERE barCode = ord.barCode;
            END LOOP;
    END update_status;

    PROCEDURE my_report IS
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
        AND EXTRACT(YEAR FROM orderdate) = EXTRACT(YEAR FROM SYSDATE) - 1
        AND TAXID = v_TAXID;
        DBMS_OUTPUT.PUT_LINE('Number of orders P/F in the last year ' || v_total);

        -- average delivery period for already fulfilled offers
        SELECT SUM(deldate - orderdate), count(*) INTO aux_avg, aux_total FROM Replacements
        WHERE status in ('F')
        AND EXTRACT(YEAR FROM orderdate) = EXTRACT(YEAR FROM SYSDATE) - 1
        AND TAXID = v_TAXID;
        IF aux_total = 0 THEN 
            v_average := NULL;
            DBMS_OUTPUT.PUT_LINE('No orders done');
        ELSE
            v_average := aux_avg/aux_total;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Average delivery period ' || v_average);

        -- Orders info
        FOR off IN (SELECT DISTINCT barcode FROM Replacements WHERE TAXID = v_TAXID)
        LOOP
            DECLARE
                v_avgcost number(10);
                v_cost number(10);
                v_mincost number(10);
                v_maxcost number(10);
                v_diffcost number(10);
                aux_diffoff number(10);
                v_diffoffer number(10);
            
            BEGIN
                -- current cost
                SELECT cost INTO v_cost FROM Supply_Lines 
                WHERE  TAXID = v_TAXID
                AND barcode = off.barcode;
                DBMS_OUTPUT.PUT_LINE('Current cost ' || v_cost);

                -- min cost
                SELECT MIN(cost) INTO v_mincost FROM Supply_Lines a
                JOIN Replacements b ON a.barcode = b.barcode
                WHERE  a.TAXID = v_TAXID
                AND EXTRACT(YEAR FROM b.orderdate) = EXTRACT(YEAR FROM SYSDATE)-1
                AND a.barcode = off.barcode;
                DBMS_OUTPUT.PUT_LINE('Minimum cost ' || v_mincost);

                -- max cost
                SELECT MAX(cost) INTO v_maxcost FROM Supply_Lines a
                JOIN Replacements b ON a.barcode = b.barcode
                WHERE  a.TAXID = v_TAXID
                AND EXTRACT(YEAR FROM b.orderdate) = EXTRACT(YEAR FROM SYSDATE)-1
                AND a.barcode = off.barcode;
                DBMS_OUTPUT.PUT_LINE('Maximum cost ' || v_maxcost);

                -- average cost
                SELECT AVG(cost) INTO v_avgcost FROM Supply_Lines
                WHERE barcode = off.barcode;
                
                -- difference of current cost minus the average of costs of all offers
                v_diffcost := v_cost - v_avgcost;
                DBMS_OUTPUT.PUT_LINE('Difference of costs ' || v_diffcost);
                
                -- difference regarding the best offer for the product
                SELECT MIN(cost) INTO v_diffoffer FROM(
                    SELECT cost FROM Supply_Lines
                    WHERE barcode = off.barcode
                    AND TAXID != V_TAXID
                    ORDER BY cost
                ) WHERE rownum = 1;
                DBMS_OUTPUT.PUT_LINE('Difference of offer ' || v_diffoffer);
            END;
        END LOOP;
    END my_report;
END caffeine;
