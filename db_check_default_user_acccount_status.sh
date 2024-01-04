#!/bin/bash
#Need sshpass to share the password during runtime
# A list of servers, one per line.
SERVER_LIST='servers.lst'
INV_SCRIPT='db_get_inventory.sql'
DT="$(date +%Y%m%d.%H%M%S)"
LOG_FILE='remote_exec.log'
ERROR_FILE='remote_exec.err'
OUTPUT_FILE='remote_exec.out'
JOB_STATUS='servers.log'
INV_DB_TNS='sjdbaodbprdn02.na.gilead.com:1521/APEXPRD'
INV_DB_USER='GSCTCCS_SVC'
#INV_DB_PASS='' # Password set it Unix env vairable based on script .pass.sh
source .pass.sh

usage() {
  # Display the usage and exit.
  echo "Usage: ${0} [-dsv]  [-f FILE] -u username COMMAND" >&2
  echo 'Executes COMMAND as a single command on every server.' >&2
  echo "  -f FILE     Use FILE for the list of servers. Default: ${SERVER_LIST}." >&2
  echo '  -d          Dry run mode. Display the COMMAND that would have been executed and exit.' >&2
  echo '  -s          Execute the COMMAND using sudo on the remote server.' >&2
  echo '  -v          Verbose mode. Displays the server name before executing COMMAND.' >&2
  echo '  -u username Username for ssh' >&2
  echo "Usage: ${0} -nv -u adm_dbuser -f new_host.lst uptime" >&2
  echo "Usage: ${0} -nv -u adm_dbuser -f new_host.lst uptime;date" >&2
  exit 1
}


archive_file()
{
  local FILE="${1}"
  local ARCHIVE_FILE="${FILE}.${DT}"
  if [[ -a "${FILE}" ]]
  then 
    if [[ -w "${FILE}" ]]
    then
    #   mv "${FILE}" "${FILE}.${DT}"
      rm "${FILE}"
    fi
  else
    touch "${FILE}"
  fi
    
  if [[ ${?} -ne 0 ]]
  then
    echo "Error in in creating or renaming file ${FILE} to ${ARCHIVE_FILE}" >&2
    exit 1
  fi
}
#Archive existing logifle
archive_file "${LOG_FILE}"
archive_file "${ERROR_FILE}"
archive_file "${OUTPUT_FILE}"
archive_file "${JOB_STATUS}"

#Write message to logfile
log()
{
  DT="$(date +%Y%m%d.%H%M%S.%N)"
  local MESSAGE="${*}"
  echo -e "${DT}.${MESSAGE}" >> "${LOG_FILE}"
}

#Write message to Error file
erorr_mesg()
{
  DT="$(date +%Y%m%d.%H%M%S.%N)"
  local MESSAGE="${*}"
  echo -e "${DT}.${MESSAGE}" >> "${ERROR_FILE}"
}

INV_DB_CONN="$INV_DB_USER/$INV_DB_PASS@$INV_DB_TNS"
echo $INV_DB_CONN
# Get Inventory
get_inventory()
{
DBSTAT=$($ORACLE_HOME/bin/sqlplus  -s "$INV_DB_CONN" << EOF
spool $SERVER_LIST
@$INV_SCRIPT
exit;
EOF
)
# if [[ $? != 0 ]] ; then
#     echo "Error in Getting DB Inventory" >> $log_file
#    echo "---`date '+%Y%m%d_%H%M%S'`">> $log_file
#    echo "---END">> $log_file
#    echo "Error"
# fi

}


#Main
#Get the PROD DB inventory
get_inventory
