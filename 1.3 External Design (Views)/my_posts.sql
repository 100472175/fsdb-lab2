create or replace view my_posts as (
    select
        CAST(ROWNUM AS NUMBER(2)) as id,
        TO_CHAR(postdate, 'DD-MM-YYYY') as postDate,
        product,
        barCode,
        score,
        likes,
        title,
        text,
        CASE 
            WHEN endorsed IS NULL THEN 'Not endorsed'
            ELSE 'Endorses'
        END as endorsed
    from posts
    where username = current_user
);

CREATE OR REPLACE TRIGGER my_posts_add
    INSTEAD OF INSERT ON my_posts
    FOR EACH ROW
    BEGIN
        INSERT INTO posts (username, postdate, barCode, product, score, title, text, likes, endorsed)
        VALUES 
        (current_user,
         SYSDATE,
        :NEW.barCode, 
        :NEW.product, 
        :NEW.score, 
        :NEW.title, 
        :NEW.text, 
        0,
        CASE 
            WHEN :NEW.endorsed = '0' OR :NEW.endorsed is NULL OR :NEW.endorsed = 0 THEN NULL
            ELSE (
                    select max(orderdate) 
                    from Client_Lines 
                    where username = current_user 
                        and barcode = :NEW.barCode)
        END);
    END;
/

CREATE OR REPLACE TRIGGER my_posts_del
    INSTEAD OF DELETE ON my_posts
    FOR EACH ROW
    BEGIN
        IF :OLD.likes > 0 THEN
            RAISE_APPLICATION_ERROR(-20000, 'You cannot delete a post with likes');
        ELSE
            DELETE FROM posts
            WHERE username = current_user
                AND TO_CHAR(postdate, 'DD-MM-YYYY') = (select postdate from my_posts where id = :OLD.id);
        END IF;
    END;
/

-- Only if the likes of the post are 0, then you can change the text and only the text.
CREATE OR REPLACE TRIGGER my_posts_upd
    INSTEAD OF UPDATE ON my_posts 
    FOR EACH ROW
    BEGIN
        IF :OLD.likes != 0 THEN
            RAISE_APPLICATION_ERROR(-20000, 'You can only change the text of a post if the likes are 0');
        ELSE
            UPDATE posts
            SET text = :NEW.text
            WHERE username = current_user
                AND TO_CHAR(postdate, 'DD-MM-YYYY') = (select postdate from my_posts where id = :OLD.id);
        END IF;
    END;
/ 
