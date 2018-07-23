CREATE DEFINER=`root`@`%` PROCEDURE `prc_harm_leasingowy`(
	IN `CenaPojazdu` DECIMAL(18,2),
	IN `OprocentowanieRoczneProcent` DECIMAL(7,6),
	IN `WartoscWykupuProcent` DECIMAL(7,6),
	IN `OplataWstepnaProcent` DECIMAL(7,6),
	IN `IleRatwRoku` INT,
	IN `IloscRat` INT,
	IN `Data_oplaty_wstepnej` DATE
,
	IN `ID_UL` VARCHAR(50)
)
    COMMENT 'harmonogram sp³at leasing kalkulator Artur Bajan'
BEGIN
declare WartoscPL_zl decimal(18,2);
declare WarotscWykupu_zl decimal(18,2);
declare OprocentowanieOkresowe decimal(7,6);
declare Wynik decimal(18,2);
declare OplataWstepna_zl decimal(18,2);
declare i integer;

set @OplataWstepna_zl=cast((CenaPojazdu*OplataWstepnaProcent) as decimal(18,2)); -- wartosc op³aty wstepnej z³otych.
set @WarotscWykupu_zl=cast(CenaPojazdu*WartoscWykupuProcent as decimal(18,2)); -- wartosc wykupu w z³otych.
set @WartoscPL_zl=cast(CenaPojazdu-@OplataWstepna_zl as decimal(18,2)); -- wartosc przedniotu leasingo.
set @OprocentowanieOkresowe=cast((OprocentowanieRoczneProcent/(IleRatwRoku/100))/100 as decimal(18,6)); -- oprorocentowanie miesieczne. 


set @wynik=(@WartoscPL_zl-(@WarotscWykupu_zl/pow((1+@OprocentowanieOkresowe),IloscRat)))/((1-(1/(pow((1+@OprocentowanieOkresowe),IloscRat))))/@OprocentowanieOkresowe); -- wartosc raty.

set @IleRatwRokuSkokRaty=12/IleRatwRoku; -- interwal czestotliwosci daty raty
set @i=1.0; -- zerowa traktowana jako op³ata wstepna
set @dt=Data_oplaty_wstepnej; -- data poczatku harmonogramu
set @dt_ko=Data_oplaty_wstepnej+ interval iloscRat*@IleRatwRokuSkokRaty month; -- data konca harmonogramu,
set @ods_rata=@WartoscPL_zl*@OprocentowanieOkresowe; -- odsetki rata pierwsza
set @Kap_splarty=@WartoscPL_zl-(@wynik-@ods_rata); -- kapital do splaty rata 2


-- op³ata za wykup
INSERT INTO `db_harm_gl`.`db_symulacja_lea`(`Opis`,`Data_raty`,`NrRaty`,`rata`,`kapital`,`odsetki`,`KapitalDoSplaty`,`SplataKapitaluLeasingu`,`id_ul`)
VALUES ('Op³ata Wstêpna',@dt,0.0,@OplataWstepna_zl,@OplataWstepna_zl,0.0,@WartoscPL_zl,0.00000,ID_UL);
					
while @i<=IloscRat and @dt<=@dt_ko  and @Kap_splarty>=0 do 


					INSERT INTO `db_harm_gl`.`db_symulacja_lea`(`Opis`,`Data_raty`,`NrRaty`,`rata`,`kapital`,`odsetki`,`KapitalDoSplaty`,`SplataKapitaluLeasingu`,`id_ul`)
					VALUES ('Rata',@dt,@i,@wynik,@wynik-@ods_rata,@ods_rata,@Kap_splarty,(@wynik-@ods_rata)/@WartoscPL_zl,ID_UL);

-- odsetki od kolejnych rat.
set @ods_rata=@Kap_splarty*@OprocentowanieOkresowe; 
set @Kap_splarty=@Kap_splarty-@wynik+@ods_rata; -- kaptal do splaty w racie 1

set @dt=@dt+interval @IleRatwRokuSkokRaty month; -- data nastêpnej raty
set @i=@i+1; -- nr kolejnej raty
end while;

INSERT INTO `db_harm_gl`.`db_symulacja_lea`(`Opis`,`Data_raty`,`NrRaty`,`rata`,`kapital`,`odsetki`,`KapitalDoSplaty`,`SplataKapitaluLeasingu`,`id_ul`)
VALUES ('Wykup',@dt-interval 1 month,`IloscRat`,@WarotscWykupu_zl,@WarotscWykupu_zl,0.0,@WarotscWykupu_zl,@WarotscWykupu_zl/@WartoscPL_zl,ID_UL);

END
