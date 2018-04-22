#!/bin/bash

# Make sure the script is being executed with the superuser privilege
UID_TO_TEST_FOR='0'
if [[ "${UID}" -ne "${UID_TO_TEST_FOR}" ]]
then
    echo "To use this script, you mast be a superuser." >&2
    exit 1
fi

# If the user doesn't supply at least one argument, then give them help
NUMBER_OF_ARGUMENTS="${#}"
if [[ "${NUMBER_OF_ARGUMENTS}" -eq 0 ]]
then
    echo "Usage: ./add-newer-local-user.sh USER_NAME [USER NAME]..." >&2
    exit 1
fi

# The first parameter is the user name
USER_NAME=${1}
shift


# The rest of the parameters are for the account comments
COMMENTS=${@}

# Generate a password
S='!@#$%^&*(_+='
APPEND=$(echo ${S} | fold -w1 | shuf | head -c1)
PASSWORD=$(date +%s%N | sha256sum | head -c8)${APPEND}

#create a user with the password
useradd -c "${COMMENTS}" -m ${USER_NAME} | &>  /dev/null

# Check to see if the useradd command succeeded.
if [[ "${?}" -ne 0 ]]
then
    echo "useradd command is failed." >&2
    exit 1
fi

# Set the password

echo ${PASSWORD} | passwd --stdin ${USER_NAME} | &> /dev/null

# Check to see if the password command succeeded

if [[ "${?}" -ne 0 ]]
then
    echo "passwd command failed." >&2
    exit 1
fi

# Force password change on the first login
passwd -e ${USER_NAME} | &>/dev/null

# Displat the username, password, and the host where the user was created.
HOST_NAME=$(echo $HOSTNAME)
echo "username:"
echo "${USER_NAME}"
echo
echo "password:"
echo "${PASSWORD}"
echo
echo "host:"
echo "${HOST_NAME}"
echo
exit 0
