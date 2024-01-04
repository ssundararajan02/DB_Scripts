set pages 0 lin 200 feed off ver off head off echo off;
SET TRIMOUT ON;
SET TRIMSPOOL ON;
col HOST for a60
col sid for a10
select HOST,sid,'1521' from DB_INVENTORY.DB_INVENTORY where 
environment in ('PROD', 'PROD (retention)') 
and  upper(SID) not like 'ERP%' and upper(sid) not like 'PLN%' 
and upper(host) not in ('SAMMAN-SD1','W2OEMAPPPRDN01.GAWS.LOCAL','FCDRTODBPRDN01.NA.GILEAD.COM','SJACGAPPPRDN02.NA.GILEAD.COM','W2EMPCODBPRDG02.NA.GILEAD.COM')
and SID not in ('GOAPRD','RDMS3PRD','MDSPRD')
and rac='N'                    
union all
-- RAC Node1 connection string
select substr(host,0,INSTR(host,' ')-1) as host ,substr(sid,0,INSTR(sid,' ')-1)  as sid,'1521' from DB_INVENTORY.DB_INVENTORY where
environment in ('PROD', 'PROD (retention)') 
and  upper (SID) not like 'ERP%' and sid not like 'PLN%'
and rac='Y' 
union all
-- HA/FSFO Primary DB Connection string
select substr(host,0,INSTR(host,' ')-1) as host,sid, '1521'  from DB_INVENTORY.DB_INVENTORY where 
SID in ('GOAPRD','RDMS3PRD','MDSPRD')
union all
--GRC DB
select 'SJACGAPPPRDN02','GRCPRD','1631' from dual 
union all                      
select 'W2EMPCODBPRDG02.na.gilead.com','emppdb1','1521' from dual -- For PDB
order by 1,2
/