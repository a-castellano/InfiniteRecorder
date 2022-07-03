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
	if [[ -z ${!required_variable} ]]; then
		write_log "${variable} is not defined."
		return 0
	else
		return 1
	fi
}

# define_cam_foder
#
# Defines folder where videos will be sotored

function define_cam_foder {
	CAM_FOLDER=$(echo "${RECORDING_FOLDER}/${CAM_NAME}" | perl -pe "s/\/\//\//g")
}
