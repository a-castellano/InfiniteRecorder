#!/bin/bash -
#===============================================================================
#
#          FILE: 01-log.sh
#
#   DESCRIPTION: Log functions
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Álvaro Castellano Vela (alvaro.castellano.vela@gmail.com),
#       CREATED: 29/06/2022 22:45
#      REVISION:  ---
#===============================================================================

# write_log
#
# writes log using logger

function write_log {
	logger -t "${SCRIPT_NAME}" $@
}
