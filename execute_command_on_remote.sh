#!/bin/bash
#Need sshpass to share the password during runtime
# A list of servers, one per line.
SERVER_LIST='servers.lst'
DT="$(date +%Y%m%d.%H%M%S)"
LOG_FILE='remote_exec.log'
ERROR_FILE='remote_exec.err'
OUTPUT_FILE='remote_exec.out'
JOB_STATUS='servers.log'

# Options for the ssh command.
SSH_OPTIONS='-o ConnectTimeout=2  -o PreferredAuthentications=keyboard-interactive -o PubkeyAuthentication=no -o StrictHostKeyChecking=no'

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

# Make sure the script is not being executed with superuser privileges.
if [[ "${UID}" -eq 0 ]]
then
  echo 'Do not execute this script as root. Use the -s option instead.' >&2
  usage
fi

#Check if sshpass is installed
type sshpass > /dev/null

if [[ ${?} -ne 0 ]]
then
  echo -e'Install sshpass before proceeding\n To install sudo yum install sshpass -y' >&2
fi

archive_file()
{
  local FILE="${1}"
  local ARCHIVE_FILE="${FILE}.${DT}"
  if [[ -a "${FILE}" ]]
  then 
    if [[ -w "${FILE}" ]]
    then
      mv "${FILE}" "${FILE}.${DT}"
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

#Write jobs status
job_status()
{
  DT="$(date +%Y%m%d.%H%M%S.%N)"
  local MESSAGE="${*}"
  echo -e "${DT}.${MESSAGE}" >> "${JOB_STATUS}"
}

# Parse the options.
while getopts u:f:dsv OPTION
do
  case ${OPTION} in
    f) SERVER_LIST="${OPTARG}" ;;
    d) 
      log 'DRY-RUN is on'
      DRY_RUN='true'
      ;;
    s) SUDO='sudo' ;;
    u) SSHUSER="${OPTARG}" ;;
    v) 
      log 'DRY-RUN is on'
      VERBOSE='true'
      ;;
    ?) usage ;;
  esac
done

# Remove the options while leaving the remaining arguments.
shift "$(( OPTIND - 1 ))"
log 'Staring the ssh job'
log 'Get ssh user name'
#Get the ssh user name
if [[ -z "${SSHUSER}" ]]
then
  echo 'Use -u USERNAME to pass the SSH USERNAME' >&2
  log 'Use -u USERNAME to pass the SSH USERNAME'
  usage

fi
log "The script will be exected as ${SSHUSER}"

log 'Verifying the COMMAND input'
# If the user doesn't supply at least one argument, give them help.
if [[ "${#}" -lt 1 ]]
then
  usage
  log 'COMMAND input not passed'
fi

# Anything that remains on the command line is to be treated as a single command.
COMMAND="${@}"
log "Followig COMMAND ${COMMAND} will be executed in all the servers"

log 'Verifying server list'
# Make sure the SERVER_LIST file exists.
if [[ ! -r "${SERVER_LIST}" ]]
then
  echo "Cannot open server list file ${SERVER_LIST}." >&2
  log "Cannot open server list file ${SERVER_LIST}."
  exit 1
fi



#Read user password once the pre-req are successfully
log "Read input of ${SSHUSER} password"

read -s -p "Enter the ${SSHUSER} password: " SSHPASS
export SSHPASS
echo ''

#Ping server status
ping_status ()
{

  log "Verify server status ${SERVER}"
  ping -c 1 "${SERVER}" &> /dev/null
  if [[ "${?}" -eq 0 ]]
  then
    echo -e "${SERVER} Up."
    log "Server ${SERVER} is online"
    job_status "Server ${SERVER} is online"
    return 0
  else
    echo -e "${SERVER} Down."
    log "Server ${SERVER} is offline"
    job_status "Server ${SERVER} is offline"
    return 1
  fi
}
  

# Expect the best, prepare for the worst.
EXIT_STATUS='0'

# Loop through the SERVER_LIST
for SERVER in $(cat ${SERVER_LIST})
do
  if [[ "${VERBOSE}" = 'true' ]]
  then
    
    echo "${SERVER}"
    log "Executing the commands on server ${SERVER}"
  fi
  ping_status "${SERVER}"
  if [[ "${?}" -eq 0 ]]
  then
    SSH_COMMAND="sshpass -e ssh -q -tt ${SSH_OPTIONS} ${SSHUSER}@${SERVER} ${SUDO} ${COMMAND}"
  
    # If it's a dry run, don't execute anything, just echo it.
    if [[ "${DRY_RUN}" = 'true' ]]
    then
      log 'Running on DRY RUN Mode, scripts not executed on server'
      echo "DRY RUN: ${SSH_COMMAND}"
      log "DRY RUN: ${SSH_COMMAND}"
    
    else
    
      log "On server ${SERVER} executing the commands  ${SSH_COMMAND}"
      ${SSH_COMMAND}  >> "${OUTPUT_FILE}" 
      SSH_EXIT_STATUS="${?}"

      # Capture any non-zero exit status from the SSH_COMMAND and report to the user.
      if [[ "${SSH_EXIT_STATUS}" -ne 0 ]]
      then
        EXIT_STATUS=${SSH_EXIT_STATUS}
        echo "Execution on ${SERVER} failed." >&2
        log "Execution on ${SERVER} failed."
        job_status "Execution on ${SERVER} failed."
      else
        log "On server ${SERVER} executed sccessfully"
        job_status "On server ${SERVER} executed sccessfully"
      fi

    fi
  fi
done

exit ${EXIT_STATUS}
log 'Finishe the ssh job'