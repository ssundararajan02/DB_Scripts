# DBA Shell scripts
##### For Oracle DBA
Shell script **db_users_nonprod.sh** created to perform below L1/L2 tasks by DBAs in Argus Non-PROD Databases
- Check user accounts status
- Unlock user account
- Reset user password
- Create a Read-only user
- Check User Privilege
- List database users
- Gerenerate SYSTEM user passsword

## Input Parameters
Following optional parameter can be provided while running the script

Instructions on how to use them when executing

| Option | Desctiption | Syntax |
| ------ | ----------- |------- |
| -a | Disable tracking of unlock,create,reset activity ||
| -c | Validate user DDL script for any DDL/DML GRANTS||
| -l LENGTH | Specify the password length (default 21) |-l 12|
| -f FILENAME.sql | Specify the user DDL script name |USER_DDL.sql|


## Syntax

Execute this script as oracle OS user after setting environment variables

```sh
/oradba/ssuresh/scripts/db_users_nonprod.sh
/oradba/ssuresh/scripts/db_users_nonprod.sh -ac -l 12
/oradba/ssuresh/scripts/db_users_nonprod.sh -ac -l 12 -f FILENAME.sql
```

## Pre-requsites when running the script

**Following steps should be password to execute the script**

- The script should be execute as OS user *oracle*
- User creation script template should be exists in /home/oracle/.create_user_ddl.sql 
- ORACLE_SID should be set [ To verify echo $ORACLE_SID ]
- DB instance should be running
- Script should be executed in non-prod DBs only

```sh
 ~]$ /oradba/ssuresh/scripts/db_users_nonprod.sh
2023-06-13.15:51:37 :-                  -------------
2023-06-13.15:51:37 :-                  List All User
2023-06-13.15:51:37 :-                  -------------
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
USERNAME                       | ACCOUNT_STATUS       |     PROFILE                    |CREATED_DATE |             |             | LAST_LOIN
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
AMYNOTT2                       | OPEN                 | DEFAULT                        | 26-OCT-2021 |             | 24-APR-2022 | 02-NOV-21 07.57.04.000000000 AM -07:00
.
.
.

The script is indented to use only in Non-PROD Environment by DBAs
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Choose from the below options
        1. Check account status                 2. Account Unlock
        3. Reset user password                  4. Create read-only user
        5. Check user privilege                 6. List Non-default DB users account status
        7. Generate SYSTEM password
        8. Press 8 or Q for quit

hostname@DBNAME >
Enter your choice : 1

```