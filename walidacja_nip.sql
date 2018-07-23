CREATE DEFINER=`root`@`localhost` FUNCTION `walid_nip`(
	`str_nip` VARCHAR(50)
)
RETURNS varchar(50) CHARSET utf8 COLLATE utf8_polish_ci
LANGUAGE SQL
DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
BEGIN
declare spr_nip varchar(50);
declare ileznakow integer;
declare i integer;
declare walid integer;
declare sumowanie decimal(18,2);
declare wynik integer;

set spr_nip=replace(str_nip,'-','');
set ileznakow=length(spr_nip);
 
set sumowanie=0;
set i=1;
while i<10 do 
set walid= substr(spr_nip,i,1) * substr('657234567',i,1);
set sumowanie=sumowanie+walid;
set i=i+1;
end while;
set wynik=MOD(sumowanie,11);

return (case when substr(spr_nip,10,1)=wynik and ileznakow=10 then   spr_nip else concat(spr_nip,'_falsz') end);
END
