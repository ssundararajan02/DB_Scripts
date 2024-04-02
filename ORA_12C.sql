set pages 0 lin 200 feed off ver off head off echo off;
SET TRIMOUT ON;
SET TRIMSPOOL ON;
col HOST for a60
col sid for a10
-- select username,account_status, created,profile from dba_users 
-- where oracle_maintained='Y' 
-- and account_status ='OPEN' 
-- and username not in ('SYS','SYSTEM','DBSNMP') 
-- order by username
-- /

SELECT host_name||'|'||instance_name||'|'||version||'|'||T1||'|'||T2||'|'||T3||'|'||T4||'|'||T5 FROM
(
select username T1,account_status T2, created as T3,profile as T4, '\n' as T5 from dba_users where oracle_maintained='Y' and account_status ='OPEN' and username not in ('SYS','SYSTEM','DBSNMP') order by username
) Privs,v$instance
/
