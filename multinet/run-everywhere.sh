#!/usr/bin/env bash

# Display the usage and exit
Usage(){
  echo "Usage: ./run_everywhere.sh [-nsv] [-f FILE] COMMAND" >&2
  echo "Executes COMMANF as a single command on every server." >&2
  echo "  -f file Use FILE for the list of servers, Default: /vagrant/servers." >&2
  echo "  -n    Dry run mode. Display the COMMAND that would have been executed and exit." >&2
  echo "  -s    Execute the COMMAND using sudo on the remote server." >&2
  echo "  -v    Verbose mode. Displays the server name before executing COMMAND." >&2
  exit 1
}
SERVER_LIST="servers"
# Make sure the script is not being executed with superuser privileges
if [[ "${UID}" -eq 0 ]]
then
  echo "Do not execute this script as root. Use the -s option instead."
  Usage
fi

if [[ "${#}" -eq 0 ]]
then
  Usage
fi

# Parse the options
while  getopts f:nsv OPTION
do
  case ${OPTION} in
    f)
      FILE_ON='true'
      SERVER_LIST="${OPTARG}"
      #echo "providing SERVER_LIST. ${SERVER_LIST}"
      ;;
    n)
      DRY_RUN='true'
      #echo "Dry run: ${DRY_RUN}"
      ;;
    s)
      SUPER='true'
      #echo "Run as superuser: ${SUPER}"
      ;;
    v)
      VERBOSE_ON='true'
      #echo "Verbose: ${VERBOSE}"
      ;;
    ?)
      Usage
      ;;
  esac
done

# Remove the options while leaving the remaining arguments.
shift $(( OPTIND - 1 ))
#echo "number of arguments: ${#}"

# If the user doesn't supply at least one argument, give them help.
if [[ "${#}" -eq 0 ]]
then
  Usage
fi

# Anything that remains on the command line is to be treated as a single command.
COMMAND="${@}"
#echo "command: ${COMMAND}"

# Make sure the SERVER_LIST file exists.

if [[ ! -e ${SERVER_LIST} ]]
then
  echo "Server List File not exists" >&2
  exit 1
#else
#  echo "${SERVER_LIST}"
#  echo "$(cat ${SERVER_LIST})"
fi
server_list=$(cat ${SERVER_LIST})
#echo "${server_list}"

# Loop through the SERVER_LIST
for server in ${server_list}
do
  # If it's a dry run, don't execute anything, just echo it
  if [[ "${DRY_RUN}" == 'true' ]]
  then
    if [[ "${SUPER}" == 'true' ]]
    then
      echo "DRY RUN: ssh -o ConnectTimeout=2 ${server} sudo ${COMMAND}"
    else
      echo "DRY RUN: ssh -o ConnectTimeout=2 ${server} ${COMMAND}"
   fi
  else
    if [[ "${SUPER}" == 'true' ]]
    then
        COMMAND="sudo ${COMMAND}"
    fi
    if [[ "${VERBOSE_ON}" == 'true' ]]
    then
      echo "${server}"
    fi
    ssh -o ConnectTimeout=2 ${server} ${COMMAND}
    #echo "${response} ${?}"
    if [[ "${?}" -ne 0 ]]
    then
      #exit_code=${?}
      #echo "${exit_code}"
      echo "Execution on ${server} failed." >&2
    fi
  fi

    # Capture any non-zero exit status from the SSH_COMMAND and report to the user.

done
