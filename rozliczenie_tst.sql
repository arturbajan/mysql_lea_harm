SET @O_DT=(
SELECT DATE(MAX(`um_lea_hk`.`data_AK`))
FROM `sekurytyzacja_gl`.`um_lea_hk`); SET @P_DT=(CASE WHEN DAYNAME(@O_DT)='Monday' THEN DATE_FORMAT((@O_DT - INTERVAL 3 DAY),'%Y-%m-%d') WHEN DAYNAME(@O_DT)!='Monday' THEN DATE_FORMAT((@O_DT - INTERVAL 1 DAY),'%Y-%m-%d') ELSE NULL END); SET @DT_uzup=@O_DT;
CREATE TEMPORARY TABLE st_ob (INDEX (NRB)) AS
(
SELECT 
 `data_AK`,
 `S_WIENZP`,
 `S_ODSNZP`,
 `S_KAPNZP`,
 `S_WPRZET`,
 `S_KPRZET`,
 `S_ODSZAP`,
 `S_ODSDYS`,
 `S_KARNE`,
 `S_RACHP`,
 `WPLATY`,
 `DATA_OP`,
 `NRB`
FROM
 `sekurytyzacja_gl`.`um_lea_hk`
WHERE data_ak=@O_DT);
CREATE TEMPORARY TABLE st_po (INDEX (NRB)) AS
(
SELECT 
 `data_AK`,
 `S_WIENZP`,
 `S_ODSNZP`,
 `S_KAPNZP`,
 `S_WPRZET`,
 `S_KPRZET`,
 `S_ODSZAP`,
 `S_ODSDYS`,
 `S_KARNE`,
 `S_RACHP`,
 `WPLATY`,
 `DATA_OP`,
 `NRB`
FROM
 `sekurytyzacja_gl`.`um_lea_hk`
WHERE data_ak=@P_DT);
UPDATE `sekurytyzacja_gl`.`um_lea_hk`
        RIGHT JOIN
    (SELECT 
        st_ob.`data_AK` AS data_akt,
            CAST(st_ob.`S_WIENZP` - st_po.`S_WIENZP` AS DECIMAL (18 , 2 )) AS `R_WIENZP`,
            CAST(st_ob.`S_ODSNZP` - st_po.`S_ODSNZP` AS DECIMAL (18 , 2 )) AS `R_ODSNZP`,
            CAST(st_ob.`S_KAPNZP` - st_po.`S_KAPNZP` AS DECIMAL (18 , 2 )) AS `R_KAPNZP`,
            CAST(st_ob.`S_WPRZET` - st_po.`S_WPRZET` AS DECIMAL (18 , 2 )) AS `R_WPRZET`,
            CAST(st_ob.`S_KPRZET` - st_po.`S_KPRZET` AS DECIMAL (18 , 2 )) AS `R_KPRZET`,
            CAST(st_ob.`S_ODSZAP` - st_po.`S_ODSZAP` AS DECIMAL (18 , 2 )) AS `R_ODSZAP`,
            CAST(st_ob.`S_ODSDYS` - st_po.`S_ODSDYS` AS DECIMAL (18 , 2 )) AS `R_ODSDYS`,
            CAST(st_ob.`S_KARNE` - st_po.`S_KARNE` AS DECIMAL (18 , 2 )) AS `R_KARNE`,
            CAST(st_ob.`S_RACHP` - st_po.`S_RACHP` AS DECIMAL (18 , 2 )) AS `R_RACHP`,
            DATE(st_ob.`DATA_OP`) AS `DATA_OP`,
            CAST(st_ob.`WPLATY` AS DECIMAL (18 , 2 )) AS `WPLATY`,
            st_ob.`NRB`
    FROM
        st_ob
    LEFT JOIN st_po ON st_ob.NRB = st_po.NRB) AS upd ON upd.nrb = `sekurytyzacja_gl`.`um_lea_hk`.`NRB`
        AND upd.`data_akt` = `sekurytyzacja_gl`.`um_lea_hk`.`data_ak` 
SET 
    `sekurytyzacja_gl`.`um_lea_hk`.`R_WIENZP` = upd.R_WIENZP,
    `sekurytyzacja_gl`.`um_lea_hk`.`R_ODSNZP` = upd.R_ODSNZP,
    `sekurytyzacja_gl`.`um_lea_hk`.`R_KAPNZP` = upd.R_KAPNZP,
    `sekurytyzacja_gl`.`um_lea_hk`.`R_WPRZET` = upd.R_WPRZET,
    `sekurytyzacja_gl`.`um_lea_hk`.`R_KPRZET` = upd.R_KPRZET,
    `sekurytyzacja_gl`.`um_lea_hk`.`R_ODSZAP` = upd.R_ODSZAP,
    `sekurytyzacja_gl`.`um_lea_hk`.`R_ODSDYS` = upd.R_ODSDYS,
    `sekurytyzacja_gl`.`um_lea_hk`.`R_KARNE` = upd.R_KARNE,
    `sekurytyzacja_gl`.`um_lea_hk`.`R_RACHP` = upd.R_RACHP
WHERE
    `sekurytyzacja_gl`.`um_lea_hk`.`data_AK` = @O_DT;
DROP TEMPORARY TABLE st_ob;
DROP TEMPORARY TABLE st_po;
CREATE TEMPORARY TABLE mem_narast (INDEX(`NRB`)) AS
SELECT DATE_FORMAT(@DT_uzup,'%Y-%m-%d') AS DATA_AK,`sekurytyzacja_gl`.`um_lea_hk`.`NRB`, CAST(SUM(`sekurytyzacja_gl`.`um_lea_hk`.`R_ODSKAR_D`) AS DECIMAL(18,2)) AS MEM_NAR
FROM `sekurytyzacja_gl`.`um_lea_hk`
WHERE `sekurytyzacja_gl`.`um_lea_hk`.`data_AK` BETWEEN DATE_FORMAT(@DT_uzup,'%Y-%m-01') AND DATE_FORMAT(@DT_uzup,'%Y-%m-%d')
GROUP BY `sekurytyzacja_gl`.`um_lea_hk`.`NRB`;
UPDATE `sekurytyzacja_gl`.`um_lea_hk`
        LEFT JOIN
    mem_narast ON `sekurytyzacja_gl`.`um_lea_hk`.`NRB` = mem_narast.NRB 
SET 
    `sekurytyzacja_gl`.`um_lea_hk`.`R_ODSKAR_N` = mem_narast.MEM_NAR
WHERE
    `sekurytyzacja_gl`.`um_lea_hk`.`data_AK` = @DT_uzup;
DROP TEMPORARY TABLE mem_narast;
CREATE TEMPORARY TABLE st_obecny (INDEX(nrb,data_ak)) AS
SELECT 
 `um_lea_hk`.`data_AK`,
 `um_lea_hk`.`ODD`,
 `um_lea_hk`.`NUMER_UL`,
 `um_lea_hk`.`NR_KLIENTA`,
 `um_lea_hk`.`NR_UMOWY`,
 `um_lea_hk`.`ROK`,
 `um_lea_hk`.`S_WIENZP`,
 `um_lea_hk`.`S_KAPNZP`,
 `um_lea_hk`.`S_ODSNZP`,
 `um_lea_hk`.`S_WPRZET`,
 `um_lea_hk`.`S_KPRZET`,
 `um_lea_hk`.`S_ODSZAP`,
 `um_lea_hk`.`S_ODSDYS`,
 `um_lea_hk`.`S_KARNE`,
 `um_lea_hk`.`S_RACHP`,
 `um_lea_hk`.`WPLATY`,
 `um_lea_hk`.`DATA_OP`,
 `um_lea_hk`.`GCG_PRZEL`,
 `um_lea_hk`.`GCG_POBR`,
 `um_lea_hk`.`NR_RATY`,
 `um_lea_hk`.`DATA_RATY`,
 `um_lea_hk`.`KW_BRRATY`,
 `um_lea_hk`.`KW_RATY`,
 `um_lea_hk`.`U_P`,
 `um_lea_hk`.`DT_URUCH`,
 `um_lea_hk`.`KW_URUCH`,
 `um_lea_hk`.`PROWIZJA`,
 `um_lea_hk`.`KW_PROW`,
 `um_lea_hk`.`KW_ZABGWA`,
 `um_lea_hk`.`STOPA`,
 `um_lea_hk`.`WIBOR`,
 `um_lea_hk`.`MARZA`,
 `um_lea_hk`.`ST_KARNE`,
 `um_lea_hk`.`SYT`,
 `um_lea_hk`.`WALUTA`,
 `um_lea_hk`.`NRRACH_L`,
 `um_lea_hk`.`NRB`,
 `um_lea_hk`.`ZBYWCA`,
 `um_lea_hk`.`ID_UL`,
 `um_lea_hk`.`KW_RAT_K_O`,
 `um_lea_hk`.`KW_RAT_K_K`,
 `um_lea_hk`.`KW_RATY_L`,
 `um_lea_hk`.`DT_RATY_L`,
 `um_lea_hk`.`NR_RATY_P`,
 `um_lea_hk`.`DT_RATY_P`,
 `um_lea_hk`.`ILRATPRZ`,
 `um_lea_hk`.`S_ESP`,
 `um_lea_hk`.`KWO_MEMO`,
 `um_lea_hk`.`DPD_K`,
 `um_lea_hk`.`DPD_DRK`,
 `um_lea_hk`.`DPD_360`,
 `um_lea_hk`.`DPD_K_PRZEDZIAL`,
 `um_lea_hk`.`DPD_DRK_PRZEDZIAL`,
 `um_lea_hk`.`CZY_POZYCZKA`,
 `um_lea_hk`.`R_WIENZP`,
 `um_lea_hk`.`R_ODSNZP`,
 `um_lea_hk`.`R_KAPNZP`,
 `um_lea_hk`.`R_WPRZET`,
 `um_lea_hk`.`R_KPRZET`,
 `um_lea_hk`.`R_ODSZAP`,
 `um_lea_hk`.`R_ODSDYS`,
 `um_lea_hk`.`R_KARNE`,
 `um_lea_hk`.`R_RACHP`,
 `um_lea_hk`.`R_ODSKAR_N`,
 `db_gl_autosekur`.`ZNACZNIK`,
 `db_gl_autosekur`.`data_dodania`
FROM
 `sekurytyzacja_gl`.`um_lea_hk`
RIGHT JOIN
 `sekurytyzacja_gl`.`db_gl_autosekur` ON `db_gl_autosekur`.`NRB` = `um_lea_hk`.`NRB` AND `db_gl_autosekur`.`DT_wycofania` IS NULL AND @O_DT = `um_lea_hk`.`data_AK`;
CREATE TEMPORARY TABLE st_poprzedni (INDEX(nrb,data_ak)) AS
SELECT 
 `um_lea_hk`.`data_AK`,
 `um_lea_hk`.`ODD`,
 `um_lea_hk`.`NUMER_UL`,
 `um_lea_hk`.`NR_KLIENTA`,
 `um_lea_hk`.`NR_UMOWY`,
 `um_lea_hk`.`ROK`,
 `um_lea_hk`.`S_WIENZP`,
 `um_lea_hk`.`S_KAPNZP`,
 `um_lea_hk`.`S_ODSNZP`,
 `um_lea_hk`.`S_WPRZET`,
 `um_lea_hk`.`S_KPRZET`,
 `um_lea_hk`.`S_ODSZAP`,
 `um_lea_hk`.`S_ODSDYS`,
 `um_lea_hk`.`S_KARNE`,
 `um_lea_hk`.`S_RACHP`,
 `um_lea_hk`.`WPLATY`,
 `um_lea_hk`.`DATA_OP`,
 `um_lea_hk`.`GCG_PRZEL`,
 `um_lea_hk`.`GCG_POBR`,
 `um_lea_hk`.`NR_RATY`,
 `um_lea_hk`.`DATA_RATY`,
 `um_lea_hk`.`KW_BRRATY`,
 `um_lea_hk`.`KW_RATY`,
 `um_lea_hk`.`U_P`,
 `um_lea_hk`.`DT_URUCH`,
 `um_lea_hk`.`KW_URUCH`,
 `um_lea_hk`.`PROWIZJA`,
 `um_lea_hk`.`KW_PROW`,
 `um_lea_hk`.`KW_ZABGWA`,
 `um_lea_hk`.`STOPA`,
 `um_lea_hk`.`WIBOR`,
 `um_lea_hk`.`MARZA`,
 `um_lea_hk`.`ST_KARNE`,
 `um_lea_hk`.`SYT`,
 `um_lea_hk`.`WALUTA`,
 `um_lea_hk`.`NRRACH_L`,
 `um_lea_hk`.`NRB`,
 `um_lea_hk`.`ZBYWCA`,
 `um_lea_hk`.`ID_UL`,
 `um_lea_hk`.`KW_RAT_K_O`,
 `um_lea_hk`.`KW_RAT_K_K`,
 `um_lea_hk`.`KW_RATY_L`,
 `um_lea_hk`.`DT_RATY_L`,
 `um_lea_hk`.`NR_RATY_P`,
 `um_lea_hk`.`DT_RATY_P`,
 `um_lea_hk`.`ILRATPRZ`,
 `um_lea_hk`.`S_ESP`,
 `um_lea_hk`.`DPD_K`,
 `um_lea_hk`.`DPD_DRK`,
 `um_lea_hk`.`DPD_360`,
 `um_lea_hk`.`DPD_K_PRZEDZIAL`,
 `um_lea_hk`.`DPD_DRK_PRZEDZIAL`,
 `um_lea_hk`.`CZY_POZYCZKA`,
 `um_lea_hk`.`R_WIENZP`,
 `um_lea_hk`.`R_ODSNZP`,
 `um_lea_hk`.`R_KAPNZP`,
 `um_lea_hk`.`R_WPRZET`,
 `um_lea_hk`.`R_KPRZET`,
 `um_lea_hk`.`R_ODSZAP`,
 `um_lea_hk`.`R_ODSDYS`,
 `um_lea_hk`.`R_KARNE`,
 `um_lea_hk`.`R_RACHP`
FROM
 `sekurytyzacja_gl`.`um_lea_hk`
RIGHT JOIN
 `sekurytyzacja_gl`.`db_gl_autosekur` ON `db_gl_autosekur`.`NRB` = `um_lea_hk`.`NRB` AND @P_DT = `um_lea_hk`.`data_AK`;
DELETE FROM `sekurytyzacja_gl`.`db_gl_st_do_op` 
WHERE
    `data_AK` = @O_DT;
INSERT INTO `sekurytyzacja_gl`.`db_gl_st_do_op`
(`data_AK`,
`NUMER_UL`,
`INSTALACJA`,
`NR_KLIENTA`,
`NR_UMOWY`,
`NRB`,
`RodzSeku`,
`data_flag`,
`pocz_S_WIENZP`,
`Ruch_R_WIENZP`,
`OPER_WIERZ_NZP`,
`koncowy_S_WIENZP`,
`pocz_WPRZET`,
`Ruch_WPRZET`,
`OPER_WIERZ_ZAP`,
`koncowy_WPRZET`,
`ROZNICE_WIERZ`,
`pocz_KAPNZP`,
`Ruch_KAPNZP`,
`koncowy_S_KAPNZP`,
`pocz_KPRZET`,
`O_SumSpl_Kapital`,
`Ruch_KPRZET`,
`koncowy_KPRZET`,
`ROZNICE_KAPITAL`,
`pocz_ODSNZP`,
`Ruch_ODSNZP`,
`koncowy_ODSNZP`,
`pocz_ODSZAP`,
`Ruch_ODSZAP`,
`koncowy_ODSZAP`,
`O_SumSpl_ods`,
`ROZNICE_ODS`,
`ROZNICE_ODS_DYSK`,
`pocz_ODSDYS`,
`Ruch_ODSDYS`,
`koncowy_ODSDYS`,
`pocz_S_KARNE`,
`O_SumSpl_ods_KAR`,
`IzaO_ODS_KAR_NAR`,
`Ruch_S_KARNE`,
`koncowy_S_KARNE`,
`IzaO_ODS_KAR`,
`DATA_RATY`,
`KW_BRRATY`,
`KW_RATY`,
`KapRatNast`,
`OdsRatNast`,
`DT_wykupu`,
`Kw_wykup`,
`KWO_MEMO`,
`MEM_DO_DNIA_RAPORTU`,
`MEM_DAN_MCE_ODKUP`,
`MEM_W_S_ODSNZP`,
`S_WPL_RAP_HK`,
`S_GCG_PRZEL_HK`,
`TST_WPL_gcgprzel_HK`,
`TST_WPL_OPAC_WIERZ`,
`data_dodania`,
`DPD_K`,
`DPD_K_PRZEDZIAL`)
SELECT 
 st_obecny.data_AK,
 st_obecny.NUMER_UL,
 `v_dor_oper_gl`.`INSTALACJA`,
 st_obecny.NR_KLIENTA,
 st_obecny.NR_UMOWY,
 st_obecny.NRB,
 (CASE WHEN `ZNACZNIK` = 1 THEN 'sekurytyzacja p³atna z odsetkami' WHEN `ZNACZNIK` = 3 THEN 'wycofana z sekurytyzacji' ELSE 'zdefiniuj' END) AS RodzSeku, DATE(st_obecny.data_dodania) AS data_flag, IFNULL(st_poprzedni.S_WIENZP, 0) AS pocz_S_WIENZP, IFNULL(st_obecny.R_WIENZP, 0) AS Ruch_R_WIENZP, IFNULL(`v_dor_oper_gl`.`SumSpl_WierzNiezap`, 0) AS OPER_WIERZ_NZP, IFNULL(st_obecny.S_WIENZP, 0) AS koncowy_S_WIENZP, IFNULL(st_poprzedni.`S_WPRZET`, 0) AS pocz_WPRZET, IFNULL(st_obecny.R_WPRZET, 0) AS Ruch_WPRZET, IFNULL(`v_dor_oper_gl`.`SumSpl_WierzZap`, 0) AS OPER_WIERZ_ZAP, IFNULL(st_obecny.`S_WPRZET`, 0) AS koncowy_WPRZET, CAST((IFNULL(st_poprzedni.S_WIENZP, 0) + IFNULL(st_poprzedni.`S_WPRZET`, 0)) - IFNULL(SUM(`v_dor_oper_gl`.`SumSpl_WierzNiezap`+`v_dor_oper_gl`.`SumSpl_WierzZap`), 0) - (IFNULL(st_obecny.S_WIENZP, 0) + IFNULL(st_obecny.`S_WPRZET`, 0)) AS DECIMAL(18,2)) AS ROZNICE_WIERZ, IFNULL(st_poprzedni.`S_KAPNZP`, 0) AS pocz_KAPNZP, IFNULL(st_obecny.R_KAPNZP, 0) AS Ruch_KAPNZP, IFNULL(st_obecny.`S_KAPNZP`, 0) AS koncowy_S_KAPNZP, IFNULL(st_poprzedni.`S_KPRZET`, 0) AS pocz_KPRZET, IFNULL(`v_dor_oper_gl`.`SumSpl_Kapital`, 0) AS O_SumSpl_Kapital, IFNULL(st_obecny.R_KPRZET, 0) AS Ruch_KPRZET, IFNULL(st_obecny.`S_KPRZET`, 0) AS koncowy_KPRZET, CAST((IFNULL(st_poprzedni.`S_KAPNZP`, 0) + IFNULL(st_poprzedni.`S_KPRZET`, 0)) - IFNULL(`v_dor_oper_gl`.`SumSpl_Kapital`, 0) - (IFNULL(st_obecny.`S_KPRZET`, 0) + IFNULL(st_obecny.`S_KAPNZP`, 0)) AS DECIMAL(18,2)) AS ROZNICE_KAPITAL, IFNULL(st_poprzedni.`S_ODSNZP`, 0) AS pocz_ODSNZP, IFNULL(st_obecny.R_ODSNZP, 0) AS Ruch_ODSNZP, IFNULL(st_obecny.`S_ODSNZP`, 0) AS koncowy_ODSNZP, IFNULL(st_poprzedni.`S_ODSZAP`, 0) AS pocz_ODSZAP, IFNULL(st_obecny.R_ODSZAP, 0) AS Ruch_ODSZAP, IFNULL(st_obecny.`S_ODSZAP`, 0) AS koncowy_ODSZAP, IFNULL(`v_dor_oper_gl`.`SumSpl_ods`, 0) AS O_SumSpl_ods, CAST((IFNULL(st_poprzedni.`S_ODSNZP`, 0) + IFNULL(st_poprzedni.`S_ODSZAP`, 0)) - IFNULL(`v_dor_oper_gl`.`SumSpl_ods`, 0) - (IFNULL(st_obecny.`S_ODSNZP`, 0) + IFNULL(st_obecny.`S_ODSZAP`, 0)) AS DECIMAL(18,2)) AS ROZNICE_ODS, CAST(IFNULL(st_poprzedni.`S_ODSZAP`, 0)+ IFNULL(st_obecny.R_ODSNZP*-1, 0)- IFNULL(`v_dor_oper_gl`.`SumSpl_ods`, 0)- IFNULL(st_obecny.`S_ODSZAP`, 0) AS DECIMAL(18,2)) AS ROZNICE_ODS_DYSK, IFNULL(st_poprzedni.`S_ODSDYS`, 0) AS pocz_ODSDYS, IFNULL(st_obecny.R_ODSDYS, 0) AS Ruch_ODSDYS, IFNULL(st_obecny.`S_ODSDYS`, 0) AS koncowy_ODSDYS, IFNULL(st_poprzedni.`S_KARNE`, 0) AS pocz_S_KARNE, IFNULL(`v_dor_oper_gl`.`SumSpl_ODS_karne`, 0) AS O_SumSpl_ods_KAR, IFNULL(st_obecny.`KW_ZABGWA`, 0) AS IzaO_ODS_KAR_NAR, IFNULL(st_obecny.R_KARNE, 0) AS Ruch_S_KARNE, IFNULL(st_obecny.`S_KARNE`, 0) AS koncowy_S_KARNE, CAST((st_obecny.`S_WPRZET` / 360) * (CASE WHEN
 st_obecny.DATA_AK = DATE_FORMAT((st_obecny.`DATA_RATY` - INTERVAL 1 MONTH),
 '%Y-%m-%d') THEN CAST(1 AS DECIMAL (18, 2)) ELSE CAST((TO_DAYS(DATE_FORMAT(st_obecny.DATA_AK, '%Y-%m-%d')) - TO_DAYS(DATE_FORMAT(st_obecny.DATA_AK, '%Y-%m-01'))) + 1 AS DECIMAL (18, 2)) END) * (st_obecny.`ST_KARNE` / 100) AS DECIMAL (18, 2)) AS IzaO_ODS_KAR, DATE(st_obecny.`DATA_RATY`) AS DATA_RATY, IFNULL(st_obecny.`KW_BRRATY`, 0) AS KW_BRRATY, IFNULL(st_obecny.`KW_RATY`, 0) AS KW_RATY, IFNULL(st_obecny.KW_RAT_K_K, 0) AS KapRatNast, IFNULL(st_obecny.KW_RAT_K_O, 0) AS OdsRatNast, DATE(`st_poprzedni`.`DT_RATY_L`) AS DT_wykupu, IFNULL(`st_poprzedni`.`KW_RATY_L`, 0) AS Kw_wykup, CAST(IFNULL(st_obecny.`KWO_MEMO`,0) AS DECIMAL(18,2)) AS KWO_MEMO,
 (CASE WHEN DATE_FORMAT((st_obecny.`DATA_RATY` - INTERVAL 1 MONTH),
 '%Y-%m-%d')<st_obecny.data_AK AND DATE_FORMAT((st_obecny.`DATA_RATY` - INTERVAL 1 MONTH),
 '%Y%m')!= DATE_FORMAT(st_obecny.data_AK,
 '%Y%m') THEN IFNULL((CASE WHEN
 st_obecny.S_WIENZP != 0 THEN CAST(IFNULL(st_obecny.KW_RAT_K_O / 30, 0) * (TO_DAYS(st_obecny.data_AK + INTERVAL 1 DAY) - TO_DAYS(DATE_FORMAT(st_obecny.data_AK, '%Y-%m-01'))) AS DECIMAL (18, 2)) ELSE NULL END),
 0) ELSE IFNULL((CASE WHEN
 st_obecny.S_WIENZP != 0 THEN CAST(IFNULL(st_obecny.KW_RAT_K_O / 30, 0) * (TO_DAYS(DATE_FORMAT(st_obecny.DATA_AK, '%Y-%m-%d')+ INTERVAL 1 DAY) - TO_DAYS(DATE_FORMAT((st_obecny.`DATA_RATY` - INTERVAL 1 MONTH),
 '%Y-%m-%d')+ INTERVAL 0 DAY)) AS DECIMAL (18, 2)) ELSE NULL END),
 0) END) AS MEM_DO_DNIA_RAPORTU,
 (CASE WHEN
 st_obecny.data_AK < DATE_FORMAT((st_obecny.`DATA_RATY` - INTERVAL 1 MONTH),
 '%Y-%m-%d') THEN IFNULL((CASE WHEN
 st_obecny.S_WIENZP != 0 THEN CAST(IFNULL(st_obecny.KW_RAT_K_O / 30, 0) * (TO_DAYS(DATE_FORMAT(st_obecny.DATA_AK, '%Y-%m-%d')) - TO_DAYS(DATE_FORMAT((st_obecny.DATA_AK - INTERVAL 0 DAY),
 '%Y-%m-01'))) AS DECIMAL (18, 2)) ELSE NULL END),
 0) ELSE IFNULL((CASE WHEN
 st_obecny.S_WIENZP != 0 THEN CAST(IFNULL(st_obecny.KW_RAT_K_O / 30, 0) * (TO_DAYS(DATE_FORMAT(st_obecny.DATA_AK, '%Y-%m-%d')) - TO_DAYS(DATE_FORMAT((st_obecny.`DATA_RATY` - INTERVAL 1 MONTH),
 '%Y-%m-%d')+ INTERVAL 1 DAY)) AS DECIMAL (18, 2)) ELSE NULL END),
 0) END) AS MEM_DAN_MCE_ODKUP, IFNULL((CASE WHEN
 st_obecny.S_WIENZP != 0 THEN CAST(IFNULL(st_obecny.KW_RAT_K_O / 30, 0) * (TO_DAYS(DATE_FORMAT(LAST_DAY(st_obecny.`DATA_RATY`),
 '%Y-%m-%d')) - TO_DAYS(DATE_FORMAT((st_obecny.`DATA_RATY` - INTERVAL 1 DAY),
 '%Y-%m-%d'))) AS DECIMAL (18, 2)) ELSE NULL END),
 0) AS MEM_W_S_ODSNZP, -- odsetki na koniec mca od przysz³ej raty odsetkowej
CAST(st_obecny.WPLATY AS DECIMAL(18,2)) AS S_WPL_RAP_HK, -- raport HK wp³aty przesz³y przez RACH_POM
CAST(st_obecny.`GCG_PRZEL` AS DECIMAL(18,2)) AS S_GCG_PRZEL_HK, -- raport HK wp³aty przesz³y przez RACH_POM
CAST(st_obecny.WPLATY-st_obecny.`GCG_PRZEL` AS DECIMAL(18,2)) AS TST_WPL_gcgprzel_HK, CAST((st_obecny.WPLATY-st_obecny.`GCG_PRZEL`)-(IFNULL(`v_dor_oper_gl`.`SumSpl_WierzNiezap`, 0)+ IFNULL(`v_dor_oper_gl`.`SumSpl_WierzZap`, 0)) AS DECIMAL(18,2)) AS TST_WPL_OPAC_WIERZ, -- test wp³aty z HK do wierz sl_operac
DATE(`data_dodania`) AS `data_dodania`,
 st_obecny.DPD_K,st_obecny.DPD_K_PRZEDZIAL
FROM
 st_obecny
LEFT JOIN
 st_poprzedni ON st_obecny.NRB = st_poprzedni.NRB
LEFT JOIN
 `sekurytyzacja_gl`.`v_dor_oper_gl` ON st_obecny.NRB = `v_dor_oper_gl`.`NRB` AND st_obecny.data_ak = `v_dor_oper_gl`.`DATA_KS`
WHERE
 st_obecny.NRB IS NOT NULL
GROUP BY st_obecny.NRB ;
DROP TEMPORARY TABLE st_obecny;
DROP TEMPORARY TABLE st_poprzedni;
UPDATE `sekurytyzacja_gl`.`db_gl_st_do_op` 
SET 
    `Kw_wykup` = 0
WHERE
    `sekurytyzacja_gl`.`db_gl_st_do_op`.data_ak = @O_DT
        AND `db_gl_st_do_op`.`koncowy_S_WIENZP` = 0
        AND `db_gl_st_do_op`.koncowy_WPRZET = 0;
DELETE FROM `sekurytyzacja_gl`.`db_gl_p_stany` 
WHERE
    `data_AK` = @O_DT;
INSERT INTO `sekurytyzacja_gl`.`db_gl_p_stany`
(`data_AK`,
`il_umow`,
`SumWierz`,
`SumKapBezRezyd`,
`WartRezyd`,
`SumKapRezyd`,
`SumOdsDys`,
`SumOdsKarne`)
(
SELECT 
 `sekurytyzacja_gl`.`db_gl_st_do_op`.data_AK, COUNT(`db_gl_st_do_op`.`NRB`) AS il_umow, CAST(SUM(koncowy_S_WIENZP+koncowy_WPRZET) AS DECIMAL(18,2)) AS SumWierz, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IF(IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)<0,0, IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0) END)) AS DECIMAL(18,2)) AS SumKapBezRezyd
, CAST(SUM((CASE WHEN (CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0) END)<0 THEN 
 (CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0) END)+(CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN 
 0 END) ELSE CAST((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN 
 0 END) AS DECIMAL(18,2)) END)) AS DECIMAL(18,2)) AS WartRezyd, CAST(SUM(IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,
 0) + IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,
 0)) AS DECIMAL (18, 2)) AS SumKapRezyd, CAST(SUM(`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) AS SumOdsDys, CAST(SUM(`db_gl_st_do_op`.`koncowy_S_KARNE`) AS DECIMAL (18, 2)) AS SumOdsKarne
FROM
 `sekurytyzacja_gl`.`db_gl_st_do_op`
WHERE `sekurytyzacja_gl`.`db_gl_st_do_op`.data_AK>(
SELECT MAX(data_ak)
FROM `sekurytyzacja_gl`.`db_gl_p_stany`
LIMIT 1)
GROUP BY `sekurytyzacja_gl`.`db_gl_st_do_op`.data_AK);
DELETE FROM `sekurytyzacja_gl`.`db_gl_p_wplaty` 
WHERE
    `sekurytyzacja_gl`.`db_gl_p_wplaty`.`DATA_KS` = (SELECT 
        `DATA_KS`
    FROM
        `sekurytyzacja_gl`.`v_dor_oper_gl`
    LIMIT 1);
INSERT INTO `sekurytyzacja_gl`.`db_gl_p_wplaty`
(`DATA_KS`,
`SumSpl_WierzNieZap`,
`SumSpl_WierzZap`,
`SumSpl_Kapital`,
`SumSpl_ods`,
`SumSpl_ODS_karne`,
`TST_wierz_kp_ods`,
`TST_wys_w_drog`,
`TST_aneks`,
`tst_praw_ODS`,
`INSTALACJA`)
SELECT DATE(`DATA_KS`) AS DATA_KS, SUM(`SumSpl_WierzNieZap`) AS SumSpl_WierzNieZap, SUM(`SumSpl_WierzZap`) AS SumSpl_WierzZap, SUM(`SumSpl_Kapital`) AS SumSpl_Kapital, SUM(`SumSpl_ods`) AS SumSpl_ods, SUM(`SumSpl_ODS_karne`) AS SumSpl_ODS_karne, SUM(`TST_wierz_kp_ods`) AS TST_wierz_kp_ods, SUM(`TST_wys_w_drog`) AS TST_wys_w_drog, SUM(`TST_aneks`) AS TST_aneks, SUM(`tst_praw_ODS`) AS tst_praw_ODS,
 `INSTALACJA`
FROM
 `sekurytyzacja_gl`.`v_dor_oper_gl`;
DELETE FROM `sekurytyzacja_gl`.`db_gl_rap_ser_opoz_sp` 
WHERE
    `data_AK` = @O_DT;
INSERT INTO `sekurytyzacja_gl`.`db_gl_rap_ser_opoz_sp`
(`data_AK`,
`ileBezZal`,
`BezZalSumWierz`,
`BezZalKapBezRezyd`,
`IleBezZalWartRezyd`,
`BezZalWartRezyd`,
`IleBezZalOdsDys`,
`BezZalOdsDys`,
`ile1do30`,
`SumWierz1do30`,
`KapBezRezyd1do30`,
`ZalWartRezyd1do30`,
`WartRezyd1do30`,
`ZalOdsDys1do30`,
`OdsDys1do30`,
`ile31do60`,
`SumWierz31do60`,
`KapBezRezyd31do60`,
`ZalWartRezyd31do60`,
`WartRezyd31do60`,
`ZalOdsDys31do60`,
`OdsDys31do60`,
`ile61do90`,
`SumWierz61do90`,
`KapBezRezyd61do90`,
`ZalWartRezyd61do90`,
`WartRezyd61do90`,
`ZalOdsDys61do90`,
`OdsDys61do90`,
`ile91do120`,
`SumWierz91do120`,
`KapBezRezyd91do120`,
`ZalWartRezyd91do120`,
`WartRezyd91do120`,
`ZalOdsDys91do120`,
`OdsDys91do120`,
`ile121do150`,
`SumWierz121do150`,
`KapBezRezyd121do150`,
`ZalWartRezyd121do150`,
`WartRezyd121do150`,
`ZalOdsDys121do150`,
`OdsDys121do150`,
`ile151do180`,
`SumWierz151do180`,
`KapBezRezyd151do180`,
`ZalWartRezyd151do180`,
`WartRezyd151do180`,
`ZalOdsDys151do180`,
`OdsDys151do180`,
`ile181do210`,
`SumWierz181do210`,
`KapBezRezyd181do210`,
`ZalWartRezyd181do210`,
`WartRezyd181do210`,
`ZalOdsDys181do210`,
`OdsDys181do210`,
`ile211do240`,
`SumWierz211do240`,
`KapBezRezyd211do240`,
`ZalWartRezyd211do240`,
`WartRezyd211do240`,
`ZalOdsDys211do240`,
`OdsDys211do240`,
`ile241do270`,
`SumWierz241do270`,
`KapBezRezyd241do270`,
`ZalWartRezyd241do270`,
`WartRezyd241do270`,
`ZalOdsDys241do270`,
`OdsDys241do270`,
`ile271do300`,
`SumWierz271do300`,
`KapBezRezyd271do300`,
`ZalWartRezyd271do300`,
`WartRezyd271do300`,
`ZalOdsDys271do300`,
`OdsDys271do300`,
`ile301do330`,
`SumWierz301do330`,
`KapBezRezyd301do330`,
`ZalWartRezyd301do330`,
`WartRezyd301do330`,
`ZalOdsDys301do330`,
`OdsDys301do330`,
`ile331do360`,
`SumWierz331do360`,
`KapBezRezyd331do360`,
`ZalWartRezyd331do360`,
`WartRezyd331do360`,
`ZalOdsDys331do360`,
`OdsDys331do360`,
`ilepow360`,
`SumWierzpow360`,
`KapBezRezydpow360`,
`ZalWartRezydpow360`,
`WartRezydpow360`,
`ZalOdsDyspow360`,
`OdsDyspow360`,
`il_umow`,
`SumWierz`,
`SumKapBezRezyd`,
`WartRezyd`,
`SumKapRezyd`,
`SumOdsDys`,
`SumOdsKarne`)
SELECT 
 `sekurytyzacja_gl`.`db_gl_st_do_op`.data_AK,
 -- bezzaleglosci
CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K`=0 THEN `db_gl_st_do_op`.`DATA_AK` ELSE NULL END)) AS DECIMAL(18,2)) AS ileBezZal, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K`=0 THEN koncowy_S_WIENZP+koncowy_WPRZET ELSE NULL END)) AS DECIMAL(18,2)) AS BezZalSumWierz, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K`=0 THEN ((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IF(IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)<0,0, IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0) END)) ELSE NULL END)) AS DECIMAL(18,2)) AS BezZalKapBezRezyd, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K`=0 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN NULL END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS IleBezZalWartRezyd, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K`=0 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN 
 0 END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS BezZalWartRezyd, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K`=0 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS IleBezZalOdsDys, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K`=0 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS BezZalOdsDys,
 -- przedzial 1do30
CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 1 AND 30 THEN `db_gl_st_do_op`.`DATA_AK` ELSE NULL END)) AS DECIMAL(18,2)) AS ile1do30, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 1 AND 30 THEN koncowy_S_WIENZP+koncowy_WPRZET ELSE NULL END)) AS DECIMAL(18,2)) AS SumWierz1do30, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 1 AND 30 THEN ((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IF(IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)<0,0, IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0) END)) ELSE NULL END)) AS DECIMAL(18,2)) AS KapBezRezyd1do30, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 1 AND 30 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN NULL END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalWartRezyd1do30, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 1 AND 30 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN 
 0 END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS WartRezyd1do30, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 1 AND 30 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalOdsDys1do30, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 1 AND 30 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS OdsDys1do30,
 
 -- przedzia³ 31do60
CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 31 AND 60 THEN `db_gl_st_do_op`.`DATA_AK` ELSE NULL END)) AS DECIMAL(18,2)) AS ile31do60, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 31 AND 60 THEN koncowy_S_WIENZP+koncowy_WPRZET ELSE NULL END)) AS DECIMAL(18,2)) AS SumWierz31do60, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 31 AND 60 THEN ((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IF(IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)<0,0, IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0) END)) ELSE NULL END)) AS DECIMAL(18,2)) AS KapBezRezyd31do60, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 31 AND 60 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN NULL END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalWartRezyd31do60, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 31 AND 60 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN 
 0 END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS WartRezyd31do60, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 31 AND 60 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalOdsDys31do60, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 31 AND 60 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS OdsDys31do60,
 
-- przedzia³ 61do90
CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 61 AND 90 THEN `db_gl_st_do_op`.`DATA_AK` ELSE NULL END)) AS DECIMAL(18,2)) AS ile61do90, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 61 AND 90 THEN koncowy_S_WIENZP+koncowy_WPRZET ELSE NULL END)) AS DECIMAL(18,2)) AS SumWierz61do90, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 61 AND 90 THEN ((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IF(IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)<0,0, IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0) END)) ELSE NULL END)) AS DECIMAL(18,2)) AS KapBezRezyd61do90, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 61 AND 90 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN NULL END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalWartRezyd61do90, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 61 AND 90 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN 
 0 END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS WartRezyd61do90, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 61 AND 90 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalOdsDys61do90, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 61 AND 90 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS OdsDys61do90,
 
-- przedzia³ 91do120
CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 91 AND 120 THEN `db_gl_st_do_op`.`DATA_AK` ELSE NULL END)) AS DECIMAL(18,2)) AS ile91do120, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 91 AND 120 THEN koncowy_S_WIENZP+koncowy_WPRZET ELSE NULL END)) AS DECIMAL(18,2)) AS SumWierz91do120, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 91 AND 120 THEN ((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IF(IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)<0,0, IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0) END)) ELSE NULL END)) AS DECIMAL(18,2)) AS KapBezRezyd91do120, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 91 AND 120 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN NULL END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalWartRezyd91do120, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 91 AND 120 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN 
 0 END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS WartRezyd91do120, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 91 AND 120 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalOdsDys91do120, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 91 AND 120 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS OdsDys91do120, 

-- przedzia³ 121do150
CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 91 AND 120 THEN `db_gl_st_do_op`.`DATA_AK` ELSE NULL END)) AS DECIMAL(18,2)) AS ile121do150, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 91 AND 120 THEN koncowy_S_WIENZP+koncowy_WPRZET ELSE NULL END)) AS DECIMAL(18,2)) AS SumWierz121do150, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 121 AND 150 THEN ((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IF(IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)<0,0, IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0) END)) ELSE NULL END)) AS DECIMAL(18,2)) AS KapBezRezyd121do150, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 121 AND 150 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN NULL END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalWartRezyd121do150, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 121 AND 150 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN 
 0 END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS WartRezyd121do150, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 121 AND 150 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalOdsDys121do150, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 121 AND 150 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS OdsDys121do150,

-- przedzia³ 151do180
CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 151 AND 180 THEN `db_gl_st_do_op`.`DATA_AK` ELSE NULL END)) AS DECIMAL(18,2)) AS ile151do180, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 151 AND 180 THEN koncowy_S_WIENZP+koncowy_WPRZET ELSE NULL END)) AS DECIMAL(18,2)) AS SumWierz151do180, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 151 AND 180 THEN ((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IF(IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)<0,0, IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0) END)) ELSE NULL END)) AS DECIMAL(18,2)) AS KapBezRezyd151do180, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 151 AND 180 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN NULL END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalWartRezyd151do180, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 151 AND 180 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN 
 0 END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS WartRezyd151do180, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 151 AND 180 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalOdsDys151do180, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 151 AND 180 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS OdsDys151do180,

-- przedzia³ 181do210
CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 181 AND 210 THEN `db_gl_st_do_op`.`DATA_AK` ELSE NULL END)) AS DECIMAL(18,2)) AS ile181do210, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 181 AND 210 THEN koncowy_S_WIENZP+koncowy_WPRZET ELSE NULL END)) AS DECIMAL(18,2)) AS SumWierz181do210, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 181 AND 210 THEN ((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IF(IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)<0,0, IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0) END)) ELSE NULL END)) AS DECIMAL(18,2)) AS KapBezRezyd181do210, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 181 AND 210 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN NULL END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalWartRezyd181do210, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 181 AND 210 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN 
 0 END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS WartRezyd181do210, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 181 AND 210 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalOdsDys181do210, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 181 AND 210 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS OdsDys181do210,

-- przedzia³ 211do240
CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 211 AND 240 THEN `db_gl_st_do_op`.`DATA_AK` ELSE NULL END)) AS DECIMAL(18,2)) AS ile211do240, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 211 AND 240 THEN koncowy_S_WIENZP+koncowy_WPRZET ELSE NULL END)) AS DECIMAL(18,2)) AS SumWierz211do240, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 211 AND 240 THEN ((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IF(IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)<0,0, IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0) END)) ELSE NULL END)) AS DECIMAL(18,2)) AS KapBezRezyd211do240, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 211 AND 240 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN NULL END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalWartRezyd211do240, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 211 AND 240 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN 
 0 END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS WartRezyd211do240, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 211 AND 240 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalOdsDys211do240, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 211 AND 240 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS OdsDys211do240,

-- przedzia³ 241do270
CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 241 AND 270 THEN `db_gl_st_do_op`.`DATA_AK` ELSE NULL END)) AS DECIMAL(18,2)) AS ile241do270, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 241 AND 270 THEN koncowy_S_WIENZP+koncowy_WPRZET ELSE NULL END)) AS DECIMAL(18,2)) AS SumWierz241do270, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 241 AND 270 THEN ((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IF(IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)<0,0, IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0) END)) ELSE NULL END)) AS DECIMAL(18,2)) AS KapBezRezyd241do270, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 241 AND 270 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN NULL END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalWartRezyd241do270, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 241 AND 270 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN 
 0 END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS WartRezyd241do270, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 241 AND 270 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalOdsDys241do270, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 241 AND 270 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS OdsDys241do270,
 
 -- przedzia³ 271do300
CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 271 AND 300 THEN `db_gl_st_do_op`.`DATA_AK` ELSE NULL END)) AS DECIMAL(18,2)) AS ile271do300, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 271 AND 300 THEN koncowy_S_WIENZP+koncowy_WPRZET ELSE NULL END)) AS DECIMAL(18,2)) AS SumWierz271do300, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 271 AND 300 THEN ((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IF(IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)<0,0, IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0) END)) ELSE NULL END)) AS DECIMAL(18,2)) AS KapBezRezyd271do300, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 271 AND 300 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN NULL END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalWartRezyd271do300, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 271 AND 300 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN 
 0 END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS WartRezyd271do300, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 271 AND 300 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalOdsDys271do300, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 271 AND 300 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS OdsDys271do300, 
 
 
 -- przedzia³ 301do330
CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 301 AND 330 THEN `db_gl_st_do_op`.`DATA_AK` ELSE NULL END)) AS DECIMAL(18,2)) AS ile301do330, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 301 AND 330 THEN koncowy_S_WIENZP+koncowy_WPRZET ELSE NULL END)) AS DECIMAL(18,2)) AS SumWierz301do330, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 301 AND 330 THEN ((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IF(IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)<0,0, IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0) END)) ELSE NULL END)) AS DECIMAL(18,2)) AS KapBezRezyd301do330, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 301 AND 330 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN NULL END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalWartRezyd301do330, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 301 AND 330 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN 
 0 END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS WartRezyd301do330, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 301 AND 330 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalOdsDys301do330, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 301 AND 330 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS OdsDys301do330,

-- przedzia³ 331do360
CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 331 AND 360 THEN `db_gl_st_do_op`.`DATA_AK` ELSE NULL END)) AS DECIMAL(18,2)) AS ile331do360, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 331 AND 360 THEN koncowy_S_WIENZP+koncowy_WPRZET ELSE NULL END)) AS DECIMAL(18,2)) AS SumWierz331do360, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 331 AND 360 THEN ((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IF(IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)<0,0, IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0) END)) ELSE NULL END)) AS DECIMAL(18,2)) AS KapBezRezyd331do360, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 331 AND 360 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN NULL END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalWartRezyd331do360, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 331 AND 360 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN 
 0 END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS WartRezyd331do360, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 331 AND 360 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalOdsDys331do360, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` BETWEEN 331 AND 360 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS OdsDys331do360,
-- przedzia³ pow360
CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` >360 THEN `db_gl_st_do_op`.`DATA_AK` ELSE NULL END)) AS DECIMAL(18,2)) AS ilepow360, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` >360 THEN koncowy_S_WIENZP+koncowy_WPRZET ELSE NULL END)) AS DECIMAL(18,2)) AS SumWierzpow360, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` >360 THEN ((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IF(IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)<0,0, IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0) END)) ELSE NULL END)) AS DECIMAL(18,2)) AS KapBezRezydpow360, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` >360 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN NULL END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalWartRezydpow360, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` >360 THEN CAST(((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN 
 0 END)) AS DECIMAL(18,2)) ELSE NULL END)) AS DECIMAL(18,2)) AS WartRezydpow360, CAST(COUNT((CASE WHEN `db_gl_st_do_op`.`DPD_K` >360 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS ZalOdsDyspow360, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`DPD_K` >360 THEN CAST((`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) ELSE NULL END)) AS DECIMAL(18,2)) AS OdsDyspow360,




-- podsumowanie
COUNT(`db_gl_st_do_op`.`DATA_AK`) AS il_umow, CAST(SUM(koncowy_S_WIENZP+koncowy_WPRZET) AS DECIMAL(18,2)) AS SumWierz, CAST(SUM((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IF(IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)<0,0, IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0)) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0) END)) AS DECIMAL(18,2)) AS SumKapBezRezyd
,(CASE WHEN CAST(SUM((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0) END)) AS DECIMAL(18,2))>0 THEN CAST(SUM((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN 
 0 END)) AS DECIMAL(18,2)) ELSE CAST(SUM((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN 
 0 END)) AS DECIMAL(18,2))+ CAST(SUM((CASE WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP '/P/' THEN 0 WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'OPER' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0)- IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`Kw_wykup`,0) WHEN `db_gl_st_do_op`.`NUMER_UL` REGEXP 'FINA' THEN IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,0)+ IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,0) END)) AS DECIMAL(18,2)) END) AS WartRezyd, CAST(SUM(IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_S_KAPNZP`,
 0) + IFNULL(`sekurytyzacja_gl`.`db_gl_st_do_op`.`koncowy_KPRZET`,
 0)) AS DECIMAL (18, 2)) AS SumKapRezyd, CAST(SUM(`db_gl_st_do_op`.koncowy_ODSNZP+`db_gl_st_do_op`.koncowy_ODSZAP) AS DECIMAL (18, 2)) AS SumOdsDys, CAST(SUM(`db_gl_st_do_op`.`koncowy_S_KARNE`) AS DECIMAL (18, 2)) AS SumOdsKarne
FROM
 `sekurytyzacja_gl`.`db_gl_st_do_op`
WHERE `sekurytyzacja_gl`.`db_gl_st_do_op`.data_AK =@O_DT
GROUP BY `sekurytyzacja_gl`.`db_gl_st_do_op`.data_AK;
