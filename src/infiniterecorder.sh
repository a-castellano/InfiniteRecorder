#!/bin/bash -
#===============================================================================
#
#          FILE: infiniterecorder.sh
#
#         USAGE: It runs  a service called windmaker-infiniterecorder
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Álvaro Castellano Veal (alvaro.castellano.vela@gmail.com),
#       CREATED: 25/06/2022 01:48
#      REVISION:  ---
#===============================================================================

source lib/01-log.sh
source lib/02-variable-management.sh
source lib/03-file-management.sh

###################
###     Main    ###
###################

SCRIPT_NAME="InfiniteRecorder"

# Check Variables
declare -a required_variables
required_variables=(
	'cam-ip'
	'cam-port'
	'cam-user'
	'cam-password'
	'cam-url'
	'cam-name'
	'video-length'
	'owner-user'
	'recording-folder'
)

abort_script=false
for var in ${required_variables[@]}; do
	variable=$(echo ${var} | tr '[:lower:]' '[:upper:]' | tr '-' '_')
	check_required_variable ${variable}
	defined_variable=$?
	if [[ "X${defined_variable}X" == "X0X" ]]; then
		abort_script=true
	fi
done
if [[ "${abort_script}" = true ]]; then
	write_log "Aborting execucion"
	exit 1
fi

# Prepare recording
create_recording_folder
folder_created=$?
if [[ "X${folder_created}X" != "X0X" ]]; then
	write_log "Cannot create recording folder ${RECORDING_FOLDER} as user ${OWNER_USER}"
	exit 1

fi
