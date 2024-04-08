#!/bin/bash
############################################################################################
#  Check default Oracle database users account status
#  Using oracle client from Linux server
#       2024-04-01   Suresh Sundararajan        Initial script
#                                               -force in enable to pass the warning message
############################################################################################
# A list of servers, one per line.
file=$( echo ${0##*/} ); # echo ${file}
base=${file%.*}; # echo ${base}
SCRIPT_DIR='/home/oracle/scripts'
SERVER_LIST='servers.lst'
INV_SCRIPT='db_get_inventory.sql'
TEMP_INV_SCRIPT='temp_inventory.sql'
DT="$(date +%Y%m%d.%H%M%S)"
LOG_FILE="${SCRIPT_DIR}/out_${base}.log"
RESULT_FILE="${SCRIPT_DIR}/result_${base}.log"
DB_LIST="${SCRIPT_DIR}/dblist_${base}.log"
GET_INV='Y'
INV_DB_TNS='sjdbaodbprdn02.na.gilead.com:1521/APEXPRD'
INV_DB_USER='GSCTCCS_SVC'
ORA_11G_SCRIPT='ORA_11G.sql'
ORA_12C_SCRIPT='ORA_12C.sql'
#INV_DB_PASS='' # Password set it Unix env vairable based on script .pass.sh
source .pass.sh
# source /root/.ora12 # Using oracle instant client
usage() {
  # Display the usage and exit.
  echo "Usage: ${0}  [-f FILE] [-u username] [-p password] [-t TNS_STRING]" >&2
  echo 'Executes COMMAND as a single command on every server.' >&2
  echo "  -f FILE     Use FILE for the list of DBs in format of HOST:PORT/SID
                      Example: sjdbaodbprdn02:1521/APEXPRD.
                      Default: ${SERVER_LIST}." >&2
  echo '  -u username Username to connect DB' >&2
  echo '  -p password Passowrd to connect DB' >&2
  echo '  -t tns      TNS Connection string for Inventory DB' >&2
  echo "Usage: ${0} -u scott -p welcome123 -f tns_entries.lst" >&2
  echo "Usage: Script to generate Inventory list ${INV_SCRIPT}" >&2
  echo "Usage: Script to Verify the 11G and below DB open users ${ORA_11G_SCRIPT}" >&2
  echo "Usage: Script to Verify the 12C and above DB open users ${ORA_11G_SCRIPT}" >&2
  exit 1
}


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
  echo -e "${DT}.${MESSAGE}" >> "${LOG_FILE}"
}


log '---Start'
#Validate custom input
# Parse the options.
while getopts f:u:p:t: OPTION
do
  case ${OPTION} in
    f)
      log 'User provided DB Inventory file processed' 
      SERVER_LIST="${OPTARG}"
      GET_INV='N' ;;
    u) 
      log 'User provided DB Username in use'
      INV_DB_USER="${OPTARG}" ;;
    p)
      log 'User provided DB password in use'
      INV_DB_PASS="${OPTARG}" ;;
    t) 
      log 'User provided DB TNS for inventory in use'
      INV_DB_TNS="${OPTARG}" ;;
    ?) usage ;;
  esac
done

# Remove the options while leaving the remaining arguments.
shift "$(( OPTIND - 1 ))"


archive_file()
{
  local FILE="${1}"
  local ARCHIVE_FILE="${SCRIPT_DIR}/${FILE}.${DT}"
  if [[ -a "${FILE}" ]]
  then 
    if [[ -w "${FILE}" ]]
    then
      mv "${FILE}" "${FILE}.${DT}"
      # rm "${FILE}"
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
archive_file "${RESULT_FILE}"
archive_file "${DB_LIST}"


INV_DB_CONN="$INV_DB_USER/$INV_DB_PASS@$INV_DB_TNS"
echo $INV_DB_CONN
# Get Inventory
get_inventory()
{
DB_INV=$($ORA_BIN/sqlplus -s  "$INV_DB_CONN" << EOF
spool $SERVER_LIST
@$INV_SCRIPT
--@$TEMP_INV_SCRIPT

exit;
EOF
)
if [[ $? != 0 ]] ; then
  log "---Error in Getting DB Inventory" 
  log "---`date '+%Y%m%d_%H%M%S'`"
  log "---END"
  echo "Error"
fi

}

get_db_version()
{
# TEMP_DB_CONN="$INV_DB_USER/$INV_DB_PASS@$TEMP_DB_TNS"
DB_VERSION=$($ORA_BIN/sqlplus  -s "$TEMP_DB_CONN" << EOF
set pages 0 lin 200 feed off ver off head off echo off;
SET TRIMOUT ON;
SET TRIMSPOOL ON;
select version from v\$instance;
exit;
EOF
)
if [[ $? != 0 ]] ; then
  log "---Error in Getting DB Version" 
  log "$DB_VERSION" 
  log "---`date '+%Y%m%d_%H%M%S'`"
  log "---END"
  echo "Error"
else
  echo $DB_VERSION
fi
}

11g_open_users()
{
# TEMP_DB_CONN="$INV_DB_USER/$INV_DB_PASS@$TEMP_DB_TNS"
OPEN_USERS=$($ORA_BIN/sqlplus  -s "$TEMP_DB_CONN" << EOF
@$ORA_11G_SCRIPT
exit;
EOF
)
if [[ $? != 0 ]] ; then
  log "---Error in Getting Open users" 
  log "$OPEN_USERS" 
  log "---`date '+%Y%m%d_%H%M%S'`"
  log "---END"
  echo "Error"
else
  echo $OPEN_USERS
fi

}

12c_open_users()
{
# TEMP_DB_CONN="$INV_DB_USER/$INV_DB_PASS@$TEMP_DB_TNS"
OPEN_USERS=$($ORA_BIN/sqlplus  -s "$TEMP_DB_CONN" << EOF
@$ORA_12C_SCRIPT
exit;
EOF
)
if [[ $? != 0 ]] ; then
  log "---Error in Getting Open Users"
  log "$OPEN_USERS"
  log "---`date '+%Y%m%d_%H%M%S'`"
  log "---END"
  echo "Error"
else
  echo $OPEN_USERS
fi

}


#Main
#Get the PROD DB inventory
#Setting sqlplu location
# ORA_BIN=${ORACLE_HOME}
ORA_BIN="${ORACLE_HOME}/bin"
if [[ "$GET_INV"  == 'Y' ]]; then
  log '---Getting Inventory'
  get_inventory
  log '---Inventory collected'
fi

cat $SERVER_LIST | while read HOST; do
    TEMP_DB_TNS=$(echo $HOST|awk '{print $1":"$3"/"$2}')
    TEMP_DB_CONN="$INV_DB_USER/$INV_DB_PASS@$TEMP_DB_TNS"
    DB_VERSION=$(get_db_version)
    echo "$(echo $HOST|awk '{print $1" | "$2}') | $DB_VERSION" >> ${DB_LIST}
    if [[ "$DB_VERSION"  != 'Error' ]]; then 
      log "---$(echo $HOST|awk '{print $1" | "$2}') | $DB_VERSION"
      if [[ $(echo  "$DB_VERSION"|awk -F. '{print $1}') > 11 ]]; then
        log '---Oracle 12C and Above' 
        OPEN_USERS=$(12c_open_users)
      else
        log '---Oracle 11G and below'
        OPEN_USERS=$(11g_open_users)
      fi
      #Write open users to logfile
      #echo -e "$(echo $HOST|awk '{print $1" | "$2}') | $DB_VERSION | $OPEN_USERS" >> ${LOG_FILE}
      # log "\n${OPEN_USERS}" 
      if [[ ! -z "${OPEN_USERS}" ]]; then
        #echo -e "$(echo $HOST|awk '{print $1" | "$2}') | $DB_VERSION | $OPEN_USERS" >> ${RESULT_FILE}
        echo -e "${OPEN_USERS}"|tr -d ' ' >> ${RESULT_FILE}
        log "--List of Open users\n"
        log "${OPEN_USERS}"
      else
        log "--No Open users"
      fi
    else
      #Error in Getting result
      log "$(echo $HOST|awk '{print $1" | "$2}') | $DB_VERSION"
    fi
done
log 'End'