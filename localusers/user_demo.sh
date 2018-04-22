#!/bin/bash
USER="${1}"
userdel ${USER}
if [[ "${?}" -ne 0 ]]
then
	echo "Not deleted" >&2
fi
exit 0

