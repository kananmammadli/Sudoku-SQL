# Sudoku-SQL
SQL solution for 9x9 Sudoku

Here I will describe how to solve the most common soduku (9*9 with 3*3 regions) via Oracle SQL. The main algorithm is pretty simple:

1. every empty cell is represented by 2^9-1=511,
2. go through every cell and exclude single digits appearing in the same column, row, region
3. detect subset of digits sharing the same cells in the current column/row/region and exclude these digits from the rest cells of the current column/row/region

511 in binary value is 1 1111 1111, where every bit identifies if appropriate digit can appear in this cell or not. To simplify the code there were implemented the following type and functions:

- type line_type is varray(9) of integer;
- function dec_to_bin (decin integer, length_ integer default 9) return varchar2;
- function bitor (rr line_type) return integer;
- function exclval (ind integer, rr line_type) return integer;
- function exclset (ind integer, rr line_type) return integer;

**dec_to_bin** just converts integer value into its binary presentation and replaces 1 by its position number, i.e. dec_to_bin(292, 9)=9 0060 0300. So if the cell contains 292, it means that possible values for this cell is 3, 6 or 9.

**bitor** just applies OR operation bit-wise to all elements of the array

**exclval** returns ind-th element of the array after excluding all single (power of 2) digits in the array. This function is used to exclude digital values appearing in the array. Assume that initially only 2 values in a row are defined: {null,null,3,null,null,5,null,null,null}. On the first step it is turned to {511,511,4,511,511,16,511,511,511}. After applying of exclval to each element we would get {491,491,4,491,491,16,491,491}, dec_to_bin(491, 9)=987604021. This function is applied to each cell 3 times: 1) with current row; 2) with current column; 3) with current 3*3 region. And afterwords all 3 results are bitand-ed.

**exclset** detects all pairs, groups by 3, 4, 5 and 6 which are mutually complete. Assume you have an array {60002,4,5,7,1,98060002,60002,9006003,90060002} (trailing and leading zero excluded). exclset will detect the following pair (6002, 6002) and will eliminate 2 and 6 from the rest elements of the array. The result array will be {60002,4,5,7,1,98,60002,9000003,9} and after applying exclval twise it will be {60002,4,5,7,1,8,60002,3,9}. exclset is applied to each cell 3 times: 1) with current row; 2) with current column; 3) with current 3*3 region. And afterwords all 3 results are bitand-ed.
