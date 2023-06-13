# Argus read-only user tasks 
##### For Oracle DBA

Shell script db_users_nonprod.sh created to perform below L1/L2 tasks by DBAs in Argus Non-PROD Databases
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
