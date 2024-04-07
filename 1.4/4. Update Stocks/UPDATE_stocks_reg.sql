-- UPDATE stocks:
-- After insertion to anonym_lines or client_lines, check the stop of that product in the table references
-- IF the current stock is greater than the order quantity, UPDATE the stock to stock-order_quantity.

-- IF the current stock is less than the minimum stock, UPDATE the stock to 0 AND the order quantity to the stock.
-- Cehck there is no supply line with the same product AND status = 'D'.
-- Create a replacement order with:
     -- orderdate as sysdate, 
     -- reference FROM the one that has the minimum cost AND the same product FROM the supply_lines,
     -- units = minimum stock FROM the references table,
     -- payment = '1234567890.12'

CREATE OR REPLACE TRIGGER UPDATE_stocks_reg
AFTER INSERT ON Client_Lines
FOR each ROW
DECLARE
    v_stock references.cur_stock % TYPE;
    v_min_stock references.min_stock % TYPE;
    v_max_stock references.max_stock % TYPE;
    v_replacement_order_count NUMBER;
    v_supplier providers.taxID % TYPE;
    v_supplier_cost supply_lines.cost % TYPE;
BEGIN
    SELECT cur_stock, min_stock
    INTO v_stock, v_min_stock
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
        UPDATE Client_Lines 
            SET quantity = v_stock 
            WHERE barCode = :new.barcode AND
                  username = :new.username AND
                  orderdate = :new.orderdate;
        DBMS_OUTPUT.PUT_LINE('Stock is less than the order quantity');
        SELECT count('x') 
            INTO v_replacement_order_count
        FROM replacements 
            WHERE barCode = :new.barCode AND status = 'D';
        IF v_replacement_order_count = 0 THEN
            SELECT taxID, min(cost) 
                INTO v_supplier, v_supplier_cost 
            FROM supply_lines 
                WHERE barcode = :new.barcode 
                GROUP BY taxID 
                HAVING cost=min(cost);
            INSERT INTO replacements (orderdate, barCode, taxID, status, units, payment) 
            VALUES (SYSDATE, :new.barcode, v_supplier, 'D', v_max_stock/2, v_max_stock/2 * v_supplier_cost);
		END IF;
    END IF;
END;
/
