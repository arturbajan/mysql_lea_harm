CREATE DEFINER=`abajan`@`%` FUNCTION `fx_MWO`(
	`kwota` DECIMAL(18,2),
	`opr_0_0000` DECIMAL(6,4),
	`okres_lata` INT
) RETURNS decimal(18,5)
    COMMENT 'Wsp�czynnik dyskontowy � warto�� bie��ca jednostki monetarnej, o okre�lonym terminie p�atno�ci w przysz�o�ci'
BEGIN
declare obl double;

set obl=1/pow((1+opr_0_0000),okres_lata)* kwota;
return obl;
END
