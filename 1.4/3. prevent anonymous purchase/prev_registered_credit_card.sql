CREATE OR REPLACE TRIGGER prev_registered_credit_card
BEFORE INSERT ON Lines_Anonym
FOR EACH ROW
DECLARE
    v_count_orders NUMBER;
BEGIN
    SELECT count('x') INTO v_count_orders FROM Client_Cards WHERE cardnum = :new.card_num;
    IF v_count_orders > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'You can not add a credit card to an anonymous purchase that is already registered');
    ELSE
        NULL;
    END IF;
END;
/
show errors;
