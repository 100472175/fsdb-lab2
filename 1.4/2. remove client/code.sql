CREATE OR REPLACE TRIGGER remove_client
BEFORE DELETE ON Clients
FOR EACH ROW
DECLARE
-- We declare some variables for ease of use during the trigger
    v_username clients.username % TYPE := :OLD.username;
    v_contact clients.email % TYPE;
    v_contact_2 clients.mobile % TYPE := NULL;
    v_surn1 clients.surn1 % TYPE := :OLD.surn1; 
    v_surn2 clients.surn2 % TYPE := :OLD.surn2;
    v_name clients.name % TYPE := :OLD.name; 
BEGIN
    -- Selecting the main contact as the one that is not null and assigning the second one, if it exists to the secondary contact
    v_contact := NVL(:OLD.email, TO_CHAR(:OLD.mobile));
    IF v_contact = :OLD.email THEN
        v_contact_2 := :OLD.mobile;
    ELSE 
        v_contact_2 := NULL;
    END IF;

    -- Inserting to the Anonimized orders the orders clients 
    INSERT INTO Orders_Anonym 
    (
        orderdate,
        contact,
        contact2,
        dliv_datetime,
        name,
        surn1,
        surn2,
        bill_waytype,
        bill_wayname,
        bill_gate,
        bill_block,
        bill_stairw,
        bill_floor,
        bill_door,
        bill_ZIP,
        bill_town,
        bill_country,
        dliv_waytype,
        dliv_wayname,
        dliv_gate,
        dliv_block,
        dliv_stairw,
        dliv_floor,
        dliv_door,
        dliv_ZIP,
        dliv_town,
        dliv_country 
    )(
        SELECT 
            orderdate,
            v_contact,
            v_contact_2,
            oc.dliv_datetime,
            v_name,
            v_surn1,
            v_surn2,
            ca.waytype,
            ca.wayname,
            ca.gate,
            ca.block,
            ca.stairw,
            ca.floor,
            ca.door,
            ca.ZIP,
            oc.bill_town,
            oc.bill_country,
            ca.wayname,
            ca.wayname,
            ca.gate,
            ca.block,
            ca.stairw,
            ca.floor,
            ca.door,
            ca.ZIP,
            ca.town,
            ca.country
        FROM Orders_Clients oc 
        JOIN Client_Addresses ca ON 
            ((oc.username = ca.username) AND
            (oc.town = ca.town) AND
            (oc.country = ca.country))
		WHERE oc.username = v_username);

    -- Inserting each of the clients lines wihtout the username and mixing the card-number if pressent
    INSERT INTO Lines_Anonym (
        orderdate,
        contact,
        dliv_town,
        dliv_country,
        barcode,
        price,
        quantity,
        pay_type,
        pay_datetime,
        card_comp,
        card_num,
        card_holder,
        card_expir
    )
    (SELECT 
        cl.orderdate,
        v_contact,
        cl.town,
        cl.country,
        cl.barCode,
        cl.barCode,
        cl.quantity,
        cl.pay_type,
        cl.pay_datetime,
        cc.card_comp,
        cc.cardnum,
        cc.card_holder,
        cc.card_expir 
    FROM Client_Lines cl
    JOIN Client_Cards cc ON
        (cl.cardnum = cc.cardnum AND
        cl.username = v_username));

    -- Removeing the username from the posts and inserting them into the anonyPosts
    INSERT INTO AnonyPosts (
        postdate,
        barCode, 
        product, 
        score,   
        title,   
        text,    
        likes,   
        endorsed
    )
    (SELECT 
        postdate,
        barcode,
        product,
        score,
        title,
        text,
        likes,
        endorsed
    FROM Posts 
    WHERE username = v_username);

    -- Deleting all the rows that contain the username we deleted, from which we copies the information.
    DELETE FROM Orders_Clients WHERE username = v_username; 
    DELETE FROM Client_Lines WHERE username = v_username;
    DELETE FROM Client_Addresses WHERE username = v_username;
    DELETE FROM Posts WHERE username = v_username;
    DELETE FROM Clients WHERE username = v_username;

END remove_client;
/

-- We now need to add a trigger for when an insertion in the AnonymPosts so the date dos not collide.
