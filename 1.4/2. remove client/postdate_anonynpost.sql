CREATE OR REPLACE TRIGGER postdate_anonym_order
BEFORE INSERT ON AnonyPosts
FOR EACH ROW
DECLARE
    count_time NUMBER := 0;
    v_time AnonyPosts.postdate % TYPE;
BEGIN
    v_time := :NEW.postdate;
    -- Check if the postdate already exists in the table
    SELECT count(postdate) into count_time FROM AnonyPosts where postdate = v_time;
    WHILE count_time > 0 LOOP
        -- Add 0.1 seconds to the postdate until it becomes unique
        v_time := v_time + INTERVAL '1' SECOND;
        SELECT count(postdate) into count_time FROM AnonyPosts where postdate = v_time;
    END LOOP;
    -- Update the postdate with the unique timestamp
    :NEW.postdate := v_time;
    -- Display the updated timestamp (optional)
    DBMS_OUTPUT.PUT_LINE('Updated timestamp: ' || TO_CHAR(v_time, 'YYYY-MM-DD HH24:MI:SS'));
END;
/
show errors;

-- Testing
insert into AnonyPosts (
    postdate,
    barCode, 
    product, 
    score,   
    title,   
    text,    
    likes,   
    endorsed
) VALUES (
    TO_DATE('01-01-2020', 'DD-MM-YYYY'),
    'OQI92757O715165',
    'Radio',
    3,
    'Titulo',
    'Texto',
    0,
    Null
);