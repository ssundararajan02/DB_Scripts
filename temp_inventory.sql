set pages 0 lin 200 feed off ver off head off echo off;
SET TRIMOUT ON;
SET TRIMSPOOL ON;
col HOST for a60
col sid for a10
select HOST,sid,'1521' from DB_INVENTORY.DB_INVENTORY where 
host in ('SJDBAODBPRDN02.NA.GILEAD.COM','SJHRISODBPRDN01.NA.GILEAD.COM')
order by 1,2
/