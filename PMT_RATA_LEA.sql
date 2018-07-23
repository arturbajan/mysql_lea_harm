CREATE DEFINER=`root`@`%` FUNCTION `PMT_RATA_LEA`(
	`CenaPojazdu` DECIMAL(18,2),
	`OprocentowanieRoczneProcent` DECIMAL(7,6),
	`WartoscWykupuProcent` DECIMAL(7,6),
	`OplataWstepnaProcent` DECIMAL(7,6),
	`IleRatwRoku` INT,
	`IloscRat` INT

) RETURNS decimal(18,2)
    DETERMINISTIC
BEGIN
declare WartoscPL_zl decimal(18,2);
declare WarotscWykupu_zl decimal(18,2);
declare OprocentowanieOkresowe decimal(7,6);
declare Wynik decimal(18,2);
declare OplataWstepna_zl decimal(18,2);

set @OplataWstepna_zl=cast((CenaPojazdu*OplataWstepnaProcent) as decimal(18,2));
set @WarotscWykupu_zl=cast(CenaPojazdu*WartoscWykupuProcent as decimal(18,2));
set @WartoscPL_zl=cast(CenaPojazdu-@OplataWstepna_zl as decimal(18,2));
set @OprocentowanieOkresowe=cast((OprocentowanieRoczneProcent/(IleRatwRoku/100))/100 as decimal(18,6));


set @wynik=(@WartoscPL_zl-(@WarotscWykupu_zl/pow((1+@OprocentowanieOkresowe),IloscRat)))/((1-(1/(pow((1+@OprocentowanieOkresowe),IloscRat))))/@OprocentowanieOkresowe);

return @wynik ;
END
