#!/bin/bash -
#===============================================================================
#
#          FILE: 03-file-management.sh
#
#   DESCRIPTION: File Management functions
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Álvaro Castellano Vela (alvaro.castellano.vela@gmail.com),
#       CREATED: 29/06/2022 23:37
#      REVISION:  ---
#===============================================================================

# create_recording_folder
#
# creates recording_folder
# returns 1 if operation failed

function create_recording_folder {
#	CAM_FOLDER=$(echo "${RECORDING_FOLDER}/${CAM_NAME}" | perl -pe "s/\/\//\//g")
	create_folder_command="mkdir -p ${CAM_FOLDER}"
	su - "${OWNER_USER}" -s /bin/bash -c "${create_folder_command}" 2>/dev/null
	return $?
}
