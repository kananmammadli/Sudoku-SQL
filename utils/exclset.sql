CREATE OR REPLACE function exclset(ind INTEGER, rr line_type) RETURN INTEGER 
IS
	res INTEGER:= rr(ind);
BEGIN
	FOR c in (
		WITH s AS 
			(SELECT level lvl FROM dual CONNECT BY level<=10),
		subsets as 
			(/*gets all posible combinations FROM 9 elements by 2,3,4,5,6*/
			SELECT a.lvl aa, b.lvl bb, c.lvl cc, d.lvl dd, e.lvl ee, f.lvl ff,
					case WHEN c.lvl=10 THEN 2 
						WHEN d.lvl=10 THEN 3 
						WHEN e.lvl=10 THEN 4 
						WHEN f.lvl=10 THEN 5 
						WHEN f.lvl<10 THEN 6 
					END type_ /* number of engaged elements, 2,3,4,5,6*/
			FROM s a, s b, s c, s d, s e, s f
			WHERE a.lvl < 10 
			AND b.lvl < 10
			AND a.lvl < b.lvl 
			AND b.lvl < c.lvl
			AND c.lvl < d.lvl(+)
			AND d.lvl < e.lvl(+)
			AND e.lvl < f.lvl(+)
		),
		arr as (SELECT rownum pos, column_value val, dec_to_bin(column_value, 9) bin_val FROM table(rr))
		SELECT u.*,
				a.bin_val aaa,
				b.bin_val bbb,
				c.bin_val ccc,
				d.bin_val ddd,
				e.bin_val eee,
				f.bin_val fff,
				bitor(line_type(a.val, b.val, c.val, d.val, e.val, f.val)) bit_or
		FROM  subsets u
			JOIN arr a on a.pos = u.aa
			JOIN arr b on b.pos = u.bb
		LEFT JOIN arr c on c.pos = u.cc AND u.type_>=3
		LEFT JOIN arr d on d.pos = u.dd AND u.type_>=4
		LEFT JOIN arr e on e.pos = u.ee AND u.type_>=5
		LEFT JOIN arr f on f.pos = u.ff AND u.type_>=6
		WHERE type_ > 1
		AND length(replace(nvl(a.bin_val, '99'), '0')) BETWEEN 2 AND u.type_
		AND length(replace(nvl(b.bin_val, '99'), '0')) BETWEEN 2 AND u.type_
		AND length(replace(nvl(c.bin_val, '99'), '0')) BETWEEN 2 AND u.type_
		AND length(replace(nvl(d.bin_val, '99'), '0')) BETWEEN 2 AND u.type_
		AND length(replace(nvl(e.bin_val, '99'), '0')) BETWEEN 2 AND u.type_
		AND length(replace(nvl(f.bin_val, '99'), '0')) BETWEEN 2 AND u.type_
		AND length(replace(dec_to_bin(bitor(line_type(a.val, b.val, c.val, d.val, e.val, f.val)), 9), '0')) = u.type_
		order by u.type_, u.aa, u.bb, u.cc, u.dd, u.ee, u.ff
	) LOOP
		IF bitand(rr(ind), 511 - c.bit_or)>0 
			THEN res := bitand(res, 511 - c.bit_or); 
		END IF;
	END LOOP;
	RETURN res;
END;
/

