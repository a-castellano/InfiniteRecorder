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
#       CREATED: 28/07/2024 20:48
#      REVISION:  ---
#===============================================================================

# create_recording_folder
#
# creates recording_folder
# returns 1 if operation failed

function create_recording_folders {
	found_errors=false
	for webcam_instance in "${WEBCAM_INSTANCES[@]}"; do
		cam_folder=$(define_cam_foder "${webcam_instance}")
folder_name="${cam_folder}"
		write_log "Creating folder ${folder_name}"
		if mkdir -p "${folder_name}"; then
			write_log "Folder ${folder_name} created"
		else
			found_errors=true
			write_log "Cannot create folder ${folder_name}"
		fi
		if mkdir -p "${folder_name}/merged"; then
			write_log "Folder ${folder_name} created"
		else
			found_errors=true
			write_log "Cannot create folder ${folder_name}/merged"
		fi

		if [ "${WEBCAM_INSTANCES_INFO[${webcam_instance}_REDUCED_ONLY]}" = false ]; then
			if mkdir -p "${folder_name}/raw"; then
				write_log "Folder ${folder_name}/raw created"
			else
				found_errors=true
				write_log "Cannot create folder ${folder_name}/raw"
			fi
			if mkdir -p "${folder_name}/merged/raw"; then
				write_log "Folder ${folder_name}/merged/raw created"
			else
				found_errors=true
				write_log "Cannot create folder ${folder_name}/merged/raw"
			fi
		fi
		if mkdir -p "${folder_name}/raw_reduced"; then
			write_log "Folder ${folder_name}/raw_reduced created"
		else
			found_errors=true
			write_log "Cannot create folder ${folder_name}/raw_reduced"
		fi
		if mkdir -p "${folder_name}/merged/raw_reduced"; then
			write_log "Folder ${folder_name}/merged/raw_reduced created"
		else
			found_errors=true
			write_log "Cannot create folder ${folder_name}/merged/raw_reduced"
		fi
		if chown -R "${OWNER_USER}":"${OWNER_USER}" "${folder_name}"; then
			write_log "Folder ${folder_name} owner changed"
		else
			found_errors=true
			write_log "Cannot change ${folder_name} ownwer"
		fi
	done
	if [ "${found_errors}" = false ]; then
		return 1
	else
		write_log "Cannot create all folders"
		return 0
	fi
}
