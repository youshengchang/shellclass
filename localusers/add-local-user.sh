#!/bin/bash

UID_TO_TEST_FOR='0'

# Make sure the script is being executed with superuser privileges

if [[ "${UID}" -ne "${UID_TO_TEST_FOR}" ]]
then
    echo 'You have to have superuser privilege to run this script.'
    exit 1
fi


# Get the username (login)

read -p "Enter the username to create: " USER_NAME

# Get the real name (contents for the description fields)

read -p "Enter the name of the person or application that will be using this account: " COMMENT

# Get the password

read -p "Enter the password to use for the account: " PASSWORD

# Create the user with the password

useradd -c "${COMMENT}" -m ${USER_NAME}

# Check to see if the useradd command succeeded
if [[ "${?}" -ne 0 ]]
then
    echo "useradd command is failed."
    exit 1
fi

# Set the password.

echo ${PASSWORD} | passwd --stdin ${USER_NAME}

# Check to see if the passwd command succeeded.

if [[ "${?}" -ne 0 ]]
then
    echo "passwd command is failed."
    exit 1
fi

# Force password change on the first login.

passwd -e ${USER_NAME}

# Display the username, password, and the host where the user was created.

HOST_NAME=$(echo $HOSTNAME)

echo "username: ${USER_NAME}, password: ${PASSWORD}, host: ${HOST_NAME}"

exit 0


