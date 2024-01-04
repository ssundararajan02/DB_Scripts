set pages 0 lin 200 feed off ver off head off echo off;
SET TRIMOUT ON;
SET TRIMSPOOL ON;
col HOST for a60
col sid for a10
select username,account_status, created,profile from dba_users 
where oracle_maintained='Y' 
and account_status ='OPEN' 
and username not in ('SYS','SYSTEM','DBSNMP') 
order by username
/