CREATE OR REPLACE function exclval(ind INTEGER, rr line_type) RETURN INTEGER AS
    res INTEGER:= rr(ind);
BEGIN
    FOR i IN rr.first .. rr.last LOOP
        IF rr(i) IN (1, 2, 4, 8, 16, 32, 64, 128, 256) AND rr(ind) NOT IN (1, 2, 4, 8, 16, 32, 64, 128, 256) 
            THEN res := bitand(res, 511 - rr(i));
        END IF;
    END LOOP;
    RETURN res;
END;
/
