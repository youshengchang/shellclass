#/bin/bash

# Display the usage and exit.
usage(){
        echo "Usage: ./disable-local-user.sh [-dra] USER [USERN]"
        echo "Disable a local Linux account."
        echo "  -d      Deletes accounts instead of disabling thme."
        echo "  -r      Removes the home directory associated with the account(s)."
        echo "  -a      Creates and archive of the home directory associated with the account(s)." >&2
        exit 1
}

log(){
	local MESSAGE="${@}"
	echo "${MESSAGE}"
}

# Make sure the script is being executed with superuser privileges.
if [[ "${UID}" -ne 0 ]]
then
        echo "Please run with sudo or as root." >&2
        exit 1
fi

# Parse the options
if [[ "${#}" -eq 0 ]]
then
	usage
fi

while getopts dra OPTION
do
	case ${OPTION} in
	d)
		DELETE_USER='true'
		log 'Delete account on'
		;;
	r)
		REMOVE_HOME='true'
		log 'Remove Home Directory on'
		;;
	a)
		ARCHIVING='true'
		log 'Archiving the account home directory on'
		;;
	?)
		usage
		;;
	esac
done



# Remove the options while leaving the remaining arguments.
shift "$(( OPTIND - 1 ))"
echo "number of args ${#}"


# If the user doesn't supply t least one argument, give them help.

if [[ "${#}" -eq 0 ]]
then
	usage
fi

ARCHIVE_DIR="./archive"

# Loop through all the usernames supplied as arguments
while [ "${#}" -ne 0 ]
do

	ACCOUNT="${1}"
	echo "${ACCOUNT}"
	ACCOUNT_ID=$( id -u ${1} )
	echo "${ACCOUNT} ID:  ${ACCOUNT_ID}"
	shift
	# Make sure the UID of the account is at least 1000.
	if [[ ${ACCOUNT_ID} -lt 1000 ]]
	then
		echo "Processing user: ${ACCOUNT}"
		echo "Refusing to remove the ${ACCOUNT} account with UID ${ACCOUNT_ID}." >&2
		DELETE_USER='false'
		
	fi
	# Create an archive if requested to do so
	if [[ "${ARCHIVING}" -eq 'true' ]]
	then 	
		# Make sure the ARCHIVE_DIR directory exists.
		if [[ -d ${ARCHIVE_DIR} ]]
		then
		# Archive the user's home directory and move it into the ARCHIVE_DIR
			echo "The directory ${ARCHIVE_DIR} exists."
		else
			mkdir ${ARCHIVE_DIR}
		fi
		tar -cf ./${ARCHIVE_DIR}/${ACCOUNT}.tar /home/${ACCOUNT}
	fi

	#Delete the user
	if [[ "${DELETE_USER}" == 'true' ]]
	then
		if [[ "${REMOVE_HOME}" -eq 'true' ]]
		then
			userdel -r ${ACCOUNT}
		else
			userdel ${ACCOUNT}
		fi
	else
		chage -E 0 ${ACCOUNT}
	fi
 

	# Check to see if the userdel command succeeded
	if [[ "${?}" -ne 0 ]]
	then
		echo "delete ${ACCOUNT}: is failed" >&2
		exit 1
	fi

done
 
