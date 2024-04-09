
-- Package Description
CREATE OR REPLACE PACKAGE caffeine AS
    PROCEDURE update_status;
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
END caffeine;
