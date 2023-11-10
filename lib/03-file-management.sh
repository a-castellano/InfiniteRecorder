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
		define_cam_foder ${webcam_instance}
		folder_name=${cam_folder}
		write_log "Creating folder ${folder_name}"
		mkdir -p ${folder_name}
		error_code=$?
		if [[ "X${error_code}X" == "X0X" ]]; then
			write_log "Folder ${folder_name} created"
		else
			found_errors=true
			write_log "Cannot create folder ${folder_name}"
		fi
		mkdir -p ${folder_name}_reduced
		error_code=$?
		if [[ "X${error_code}X" == "X0X" ]]; then
			write_log "Folder ${folder_name}_reduced created"
		else
			found_errors=true
			write_log "Cannot create folder ${folder_name}_reduced"
		fi

		chown -R ${OWNER_USER}:${OWNER_USER} ${folder_name}
		error_code=$?
		if [[ "X${error_code}X" == "X0X" ]]; then
			write_log "Folder ${folder_name} owner changed"
		else
			found_errors=true
			write_log "Cannot change ${folder_name} ownwer"
		fi
		chown -R ${OWNER_USER}:${OWNER_USER} ${folder_name}_reduced
		error_code=$?
		if [[ "X${error_code}X" == "X0X" ]]; then
			write_log "Folder ${folder_name}_reduced owner changed"
		else
			found_errors=true
			write_log "Cannot change ${folder_name}_reduced ownwer"
		fi
	done
	if [ "$found_errors" = false ]; then
		return 1
	else
		write_log "Cannot create all folders"
		return 0
	fi
}
