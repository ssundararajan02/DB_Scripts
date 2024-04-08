#!/bin/bash
REDENTION=7
PURGE_DIR='/Git/DB_Scripts'
usage() {
  # Display the usage and exit.
  echo "Usage: ${0} [-d DIRECTORY] [-r days]" >&2
  echo "Usage: ${0} -d /home/oracle/log -r 30" >&2
  exit 1
}

#Validate custom input
# Parse the options.
while getopts d:r: OPTION
do
  case ${OPTION} in
    d) PURGE_DIR="${OPTARG}" ;;
    r) REDENTION="${OPTARG}" ;;
    ?) usage ;;
  esac
done

# Check if the directory exists and use has write permission

if [ -d  "${PURGE_DIR}" ] && [ -w "${PURGE_DIR}" ]
then
   echo "Directory exists and writeable"
   echo "Purgfiles files in Directory: ${PURGE_DIR} Older then  ${REDENTION} Days "
   find ${PURGE_DIR} -type f -name "*.trc" -mtime +${REDENTION} -exec rm -f {} \; > /dev/null
else
   echo "Directory not exists or no write permission "
fi
