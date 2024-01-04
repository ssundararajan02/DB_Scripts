set pages 0 lin 200 feed off ver off head off echo off;
SET TRIMOUT ON;
SET TRIMSPOOL ON;
col HOST for a60
col sid for a10
select username,account_status, created, profile from dba_users where account_status ='OPEN' 
and 
username not in ('SYS', 'SYSTEM', 'DBSNMP') 
and username in ('ANONYMOUS','APEX_PUBLIC_USER','APEX_030200','APPQOSSYS',
'BI',
'CTXSYS',
'DBSNMP','DIP','DMSYS',
'EXFSYS',
'FLOWS_0300','FLOWS_FILES',
'HR',
'IX',
'LBACSYS',
'MDDATA','MDSYS','MGMT_VIEW',
'ODM','ODM_MTR','ODM_ADM','OE','OLAPSYS','ORACLE_OCM','ORDPLUGINS','ORDSYS','OUTLN','OWBSYS','ORDDATA',
'PM',
'QS','QS_ADM','QS_CB','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS',
'SCOTT','SH','SI_INFORMATN_SCHEMA','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','SYSMAN','SYS','SYSTEM',
'WK_TEST','WKPROXY','WKSYS','WMSYS',
'XDB','XS$NULL')
and username like 'APEX%'
/