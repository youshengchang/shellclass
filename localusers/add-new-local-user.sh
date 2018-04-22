#!/bin/bash

UID_TO_TEST_FOR='0'

# Make sure the script is being executed with superuser privilege
if [[ "${UID}" -ne "${UID_TO_TEST_FOR}" ]]
then
    echo "To use this script you mast be a supersuer."
    exit 1
fi


# If the user doesn't supply at least one argument, then give them help
NUMBER_OF_ARGUMENTS="${#}"
SPACE=" "

if [[ "${NUMBER_OF_ARGUMENTS}" -lt 1 ]]
then
    echo "Usage: ./add-new-local-user.sh USER_NAME [USER NAME]..."
    exit 1
fi

# The first parameter is the username
USER_NAME=${1}
shift
# The rest of the parameters are for the account commants
COMMENTS="${@}"

echo "user: ${USER_NAME}, comments: ${COMMENTS}"

# Generate a password
S='!@#$%^&*(_+'
APPEND=$(echo ${S} | fold -w1 | shuf | head -c1)
PASSWORD=$(date +%s%N |sha256sum|head -c8)
PASSWORD=${PASSWORD}${APPEND}

# Create the user with the password

useradd -c "${COMMENTS}" -m ${USER_NAME}

# Check to see if the useradd command succeeded.

if [[ "${?}" -ne 0 ]]
then
    echo "useradd command is failed."
    exit 1
fi

# Set the password

echo ${PASSWORD} | passwd --stdin ${USER_NAME}

# Check to see if the passwd command succeeded.

if [[ "${?}" -ne 0 ]]
then
    echo "passwd command is failed."
    exit 1
fi

# Force password change on first login.
passwd -e ${USER_NAME}

# Display the username, password, and the host where the user was createed.

HOST_NAME=$(echo $HOSTNAME)

echo "username: ${USER_NAME}, password: ${PASSWORD}, host: ${HOST_NAME}"

exit 0
