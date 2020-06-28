CREATE OR REPLACE function dec_to_bin (decin INTEGER, length_ INTEGER DEFAULT 9) RETURN VARCHAR2
IS
   l_decin        NUMBER;
   l_next_digit   NUMBER;
   l_result       VARCHAR (2000);
BEGIN
   l_decin := decin;
   WHILE l_decin > 0
   LOOP
      l_next_digit := MOD (l_decin, 2);
      l_result := TO_CHAR (l_next_digit * (nvl(length(l_result), 0) + 1)) || l_result;
      l_decin := FLOOR (l_decin / 2);
   END LOOP;
   RETURN lpad(nvl(l_result, '0'), length_, '0');
END dec_to_bin;
/
   
