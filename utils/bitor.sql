CREATE OR REPLACE function bitor(rr line_type) RETURN INTEGER AS
    res INTEGER:=0;
BEGIN
    FOR i in rr.first .. rr.last LOOP
        res := res + nvl(rr(i), 0) - bitand(res, nvl(rr(i), 0));
    END LOOP;
    RETURN res;
END;
/
