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

source lib/01-log.sh

# kill_threads
#
# kills created threads

function kill_threads {
	write_log "Killing recording processes"
	kill -9 "$(ps -efj --no-headers | awk -v pid=$$ '$3==pid {print $2}' | xargs)"
}

# Trap SIGTERM signal for killing threads
trap 'kill_threads' SIGTERM
