CREATE OR REPLACE TRIGGER UPDATE_stocks_reg
BEFORE INSERT ON Client_Lines
FOR each ROW
DECLARE
    v_stock references.cur_stock % TYPE;
    v_min_stock references.min_stock % TYPE;
    v_max_stock references.max_stock % TYPE;
    v_replacement_order_count NUMBER;
    v_supplier providers.taxID % TYPE;
    v_supplier_cost supply_lines.cost % TYPE;
BEGIN
    SELECT cur_stock, min_stock, max_stock
    INTO v_stock, v_min_stock, v_max_stock
    FROM references
    WHERE barcode = :new.barcode; 
    IF v_stock - :new.quantity > v_min_stock then
        UPDATE references
            SET cur_stock = v_stock - :new.quantity 
            WHERE barcode = :new.barcode;
    ELSIF v_stock < :new.quantity then
        UPDATE references 
            SET cur_stock = 0 
            WHERE barcode = :new.barCode;
        :new.quantity := v_stock;
        SELECT count('x') 
            INTO v_replacement_order_count
        FROM replacements 
            WHERE barCode = :new.barCode AND status = 'D';

        IF v_replacement_order_count = 0 THEN
            WITH min_costs AS (
                SELECT taxID, MIN(cost) AS min_cost
                FROM supply_lines 
                    WHERE barcode = :new.barcode 
                    GROUP BY taxID 
            )
            SELECT taxID, min_cost INTO v_supplier, v_supplier_cost 
            FROM min_costs;

            INSERT INTO replacements (orderdate, barCode, taxID, status, units, payment) 
            VALUES (SYSDATE, :new.barcode, NULL, 'D', v_max_stock/2, v_max_stock/2 * v_supplier_cost);
		END IF;

        /*
        SELECT count('x') 
            INTO v_supply_lines_count
            FROM supply_lines
            WHERE barCode = :new.barCode;

        IF v_supply_lines_count = 0 THEN
            INSERT INTO supply_lines (barCode) VALUES (:new.barcode);
        END IF;
        */
    END IF;
END;
/
