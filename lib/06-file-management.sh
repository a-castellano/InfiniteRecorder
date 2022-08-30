#!/bin/bash -
#===============================================================================
#
#          FILE: 06-file-management.sh
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

function create_recording_folders {
	found_errors=false
	for webcam_instance in ${WEBCAM_INSTANCES[@]}; do
		folder_name="${WEBCAM_INSTANCES_INFO[${webcam_instance}_FOLDER]}"
		write_log "Creating folder ${folder_name}"
			create_folder_command="mkdir -p ${folder_name}"
	su - "${OWNER_USER}" -s /bin/bash -c "${create_folder_command}" 2>/dev/null
	error_code=$?
	if [[ "X${error_code}X" == "X0X" ]]; then
		write_log "Folder ${folder_name} created"
	else
		found_errors=true
		write_log "Caanot create folder ${folder_name}"
	fi

	done
	if [ "$found_errors" = false ]; then
return 1
else
	write_log "Cannot create all folders"
	return 0
	fi
}
