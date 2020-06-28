with sudoku as (
--select 1 rr,rownum cc, column_value val from table(line_type(null,8,		null, null,	null,	null,	2,		null,	null)) union all
--select 2,		rownum cc, column_value val from table(line_type(null,null,	null, null,	8,		4,		null,	9,		null)) union all
--select 3, 	rownum cc, column_value val from table(line_type(null,null,	6,		3,		2,		null,	null,	1,		null)) union all
--select 4, 	rownum cc, column_value val from table(line_type(null,9,		7,		null,	null,	null,	null,	8,		null)) union all
--select 5, 	rownum cc, column_value val from table(line_type(8,		null,	null,	9,		null,	3,		null,	null,	2		)) union all
--select 6, 	rownum cc, column_value val from table(line_type(null,1,		null,	null,	null,	null,	9,		5,		null)) union all
--select 7, 	rownum cc, column_value val from table(line_type(null,7,		null,	null,	4,		5,		8,		null,	null)) union all
--select 8, 	rownum cc, column_value val from table(line_type(null,3,		null,	7,		1,		null,	null,	null,	null)) union all
--select 9, 	rownum cc, column_value val from table(line_type(null,null,	8,		null,	null,	null,	null,	4,		null))),
select 1 rr,rownum cc, column_value val from table(line_type(null,null,null,5,6,null,null,3,4)) union all
select 2 rr,rownum cc, column_value val from table(line_type(null,null,null,7,8,null,null,5,6)) union all
select 3 rr,rownum cc, column_value val from table(line_type(null,null,null,null,null,null,null,null,null)) union all
select 4 rr,rownum cc, column_value val from table(line_type(1,2,null,null,null,null,null,null,null)) union all
select 5 rr,rownum cc, column_value val from table(line_type(3,4,null,null,null,null,null,6,7)) union all
select 6 rr,rownum cc, column_value val from table(line_type(null,null,null,null,null,null,null,8,9)) union all
select 7 rr,rownum cc, column_value val from table(line_type(null,null,null,null,null,null,null,null,null)) union all
select 8 rr,rownum cc, column_value val from table(line_type(4,5,null,null,2,3,null,null,null)) union all
select 9 rr,rownum cc, column_value val from table(line_type(6,7,null,null,4,5,null,null,null))),
tmp as (
select rr, cc, nvl(val, (power(2,9)-1)/*fill empty cells with 2^9-1*/) val, sec, pos from sudoku 
model
	dimension by (rr, cc)
	measures (val as val, val as sec, val as pos)
	rules upsert all (
	val[any, any]= power(2,val[cv(rr), cv(cc)]-1)/*, 
	sec[any, any] = (ceil(cv(rr)/3)-1)*3+ceil(cv(cc)/3), -- enumerate 3*3 sections
	pos[any, any] = mod(cv(rr)-1,3)*3+mod(cv(cc)-1,3)+1 /* enumerate within section*/)),
res as (
select * from tmp
model
	dimension by (rr, cc)
	measures (val as val, val as bin_val)
	rules AUTOMATIC ORDER ( 
	val[any,any] = case when val[cv(rr), cv(cc)] in (1,2,4,8,16,32,64,128,256) then val[cv(rr), cv(cc)]
											else bitand(
													  bitand(bitand(
														exclval(cv(cc), line_type(val[cv(rr),1],val[cv(rr),2],val[cv(rr),3],val[cv(rr),4],val[cv(rr),5],val[cv(rr),6],val[cv(rr),7],val[cv(rr),8],val[cv(rr),9])),
														exclval(cv(rr), line_type(val[1,cv(cc)],val[2,cv(cc)],val[3,cv(cc)],val[4,cv(cc)],val[5,cv(cc)],val[6,cv(cc)],val[7,cv(cc)],val[8,cv(cc)],val[9,cv(cc)]))),
														exclval(mod(cv(rr)-1,3)*3+mod(cv(cc)-1,3)+1 /* position number in 3*3 section*/, line_type(
																		val[ceil(cv(rr)/3)*3-2, ceil(cv(cc)/3)*3-2], val[ceil(cv(rr)/3)*3-2, ceil(cv(cc)/3)*3-1], val[ceil(cv(rr)/3)*3-2, ceil(cv(cc)/3)*3-0],
																		val[ceil(cv(rr)/3)*3-1, ceil(cv(cc)/3)*3-2], val[ceil(cv(rr)/3)*3-1, ceil(cv(cc)/3)*3-1], val[ceil(cv(rr)/3)*3-1, ceil(cv(cc)/3)*3-0],
																		val[ceil(cv(rr)/3)*3-0, ceil(cv(cc)/3)*3-2], val[ceil(cv(rr)/3)*3-0, ceil(cv(cc)/3)*3-1], val[ceil(cv(rr)/3)*3-0, ceil(cv(cc)/3)*3-0]))),
														bitand(bitand(
														exclset(cv(cc), line_type(val[cv(rr),1],val[cv(rr),2],val[cv(rr),3],val[cv(rr),4],val[cv(rr),5],val[cv(rr),6],val[cv(rr),7],val[cv(rr),8],val[cv(rr),9])),
														exclset(cv(rr), line_type(val[1,cv(cc)],val[2,cv(cc)],val[3,cv(cc)],val[4,cv(cc)],val[5,cv(cc)],val[6,cv(cc)],val[7,cv(cc)],val[8,cv(cc)],val[9,cv(cc)]))),
														exclset(mod(cv(rr)-1,3)*3+mod(cv(cc)-1,3)+1 /* position number in 3*3 section*/, line_type(
																		val[ceil(cv(rr)/3)*3-2, ceil(cv(cc)/3)*3-2], val[ceil(cv(rr)/3)*3-2, ceil(cv(cc)/3)*3-1], val[ceil(cv(rr)/3)*3-2, ceil(cv(cc)/3)*3-0],
																		val[ceil(cv(rr)/3)*3-1, ceil(cv(cc)/3)*3-2], val[ceil(cv(rr)/3)*3-1, ceil(cv(cc)/3)*3-1], val[ceil(cv(rr)/3)*3-1, ceil(cv(cc)/3)*3-0],
																		val[ceil(cv(rr)/3)*3-0, ceil(cv(cc)/3)*3-2], val[ceil(cv(rr)/3)*3-0, ceil(cv(cc)/3)*3-1], val[ceil(cv(rr)/3)*3-0, ceil(cv(cc)/3)*3-0]))))
											end,
	bin_val[any,any] = replace(dec_to_bin(val[cv(rr), cv(cc)],9),'0')+0
	)
)
select 1, rr, A,B,C,D,E,F,G,H,I from res 
PIVOT (max(bin_val), max(val) as v FOR (cc) IN (1 AS A, 2 AS B, 3 AS C, 4 AS D, 5 AS E, 6 AS F, 7 AS G, 8 AS H, 9 AS I))
--union all
--select 2, rr, A,B,C,D,E,F,G,H,I from sudoku  -- initial data
--PIVOT (max(val) FOR (cc) IN (1 AS A, 2 AS B, 3 AS C, 4 AS D, 5 AS E, 6 AS F, 7 AS G, 8 AS H, 9 AS I))
order by 1, 2
;
