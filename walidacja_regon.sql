CREATE DEFINER=`root`@`localhost` FUNCTION `walid_regon`(
	`spr_regon` varchar(255)
)
RETURNS varchar(19) CHARSET utf8 COLLATE utf8_polish_ci
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
BEGIN
DECLARE a integer; -- petla
DECLARE tst_zn varchar(255); -- test znakow specjalnych
DECLARE tst_dl integer; -- test dlugosci znakow
declare tst_d integer;  -- test czy liczba
DECLARE wynik decimal(18,2);
DECLARE a_sum decimal(18,2);
DECLARE wynik_spr integer;


set tst_zn=replace(spr_regon,'-','');
set tst_dl=length(tst_zn);
set tst_d= tst_dl=length(tst_zn*1); -- test liczby
set a =1;
set a_sum=0;

if tst_dl=9  then
while a < 9 do 
set wynik= substr(spr_regon,i,1) * substr('89234567',i,1);
set a_sum=a_sum+wynik;
set a=a+1;
end while;
set wynik_spr=MOD(a_sum,11);
end if;

if tst_dl=14  then
while a < 14 do 
set wynik= substr(spr_regon,i,1) * substr('2485097361248',i,1);
set a_sum=a_sum+wynik;
set a=a+1;
end while;
set wynik_spr=MOD(a_sum,11);
end if;


-- if tst_dl=9  then
  -- regon 9 cyfr
--  while a < 9 do 
-- set wynik= substr(spr_regon,i,1) * substr('89234567',i,1);
-- set a_sum=a_sum+wynik;
-- set a=a+1;
-- end while dla9;
-- set wynik_spr=MOD(a_sum,11);
-- end if;
-- regon 14 '2485097361248'
-- dla14:while a < 14 do 
-- set wynik= substr(spr_regon,i,1) * substr('2485097361248',i,1);
-- set a_sum=a_sum+wynik;
-- set a=a+1;
-- end while dla14;
-- set wynik_spr=MOD(a_sum,11);


RETURN wynik_spr;
END
