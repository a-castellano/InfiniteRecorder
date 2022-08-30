#!/bin/bash -
#===============================================================================
#
#          FILE: 08-threads.sh
#
#   DESCRIPTION: thread management functions
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Álvaro Castellano Vela (alvaro.castellano.vela@gmail.com),
#       CREATED: 30/08/2022 21:00
#      REVISION:  ---
#===============================================================================

source lib/08-log.sh

# kill_threads
#
# kills created threads

function kill_threads {
	for webcam_instance in ${WEBCAM_INSTANCES[@]}; do
	write_log "Killing recording process of webcam ${webcam_instance}  ${WEBCAM_INSTANCES_INFO[${webcam_instance}_THREAD]}"
	kill -9 ${WEBCAM_INSTANCES_INFO[${webcam_instance}_THREAD]}
done

}

# Trap SIGTERM signal for killing threads
trap 'kill_threads' SIGTERM
