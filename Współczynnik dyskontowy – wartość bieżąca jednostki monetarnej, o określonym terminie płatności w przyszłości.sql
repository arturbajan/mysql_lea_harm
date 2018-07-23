CREATE DEFINER=`abajan`@`%` FUNCTION `fx_MWO`(
	`kwota` DECIMAL(18,2),
	`opr_0_0000` DECIMAL(6,4),
	`okres_lata` INT
) RETURNS decimal(18,5)
    COMMENT 'Wspó³czynnik dyskontowy – wartoœæ bie¿¹ca jednostki monetarnej, o okreœlonym terminie p³atnoœci w przysz³oœci'
BEGIN
declare obl double;

set obl=1/pow((1+opr_0_0000),okres_lata)* kwota;
return obl;
END
