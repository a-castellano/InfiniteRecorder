#!/bin/bash -
#===============================================================================
#
#          FILE: 02-variable-management.sh
#
#   DESCRIPTION: Variable Management functions
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Álvaro Castellano Vela (alvaro.castellano.vela@gmail.com),
#       CREATED: 29/06/2022 22:57
#      REVISION:  ---
#===============================================================================

# check_required_variable
#
# checks if required varible is defined
# returns 1 (true) or 0 (false) if it exists

function check_required_variable {
	required_variable=$1
	if [[ "$(declare -p ${required_variable})" =~ "declare " ]]; then
		return 1
	else
		write_log "${variable} is not defined."
		return 0
	fi
}

# check_webcam_info
#
# checks if required WEBCAM_INSTANCES_INFO keys are defined
# returns 1 (true) or 0 (false) if it exists

function check_webcam_info {
	webcam_instance=$1
	error_code=1
	for required_property in "IP" "PORT" "RTSP_URL" "FFMPEG_OPTIONS" "USER" "PASSWORD" "REDUCED_ONLY"; do
		if [[ ! -v "WEBCAM_INSTANCES_INFO[${webcam_instance}_${required_property}]" ]]; then
			write_log "WEBCAM_INSTANCES_INFO[${webcam_instance}_${required_property}] is not set."
			error_code=0
		fi
	done
	return ${error_code}
}

# define_cam_foder
#
# Defines folder where videos will be sotored

function define_cam_foder {
	cam_name=$1
	cam_folder=$(echo "${RECORDING_FOLDER}/${cam_name}" | perl -pe "s/\/\//\//g")
}
