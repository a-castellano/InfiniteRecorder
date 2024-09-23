#!/bin/bash -
#===============================================================================
#
#          FILE: 06-time-management.sh
#
#   DESCRIPTION: Time management functions
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Álvaro Castellano Vela (alvaro.castellano.vela@gmail.com),
#       CREATED: 11/09/2024 08:26
#      REVISION:  ---
#===============================================================================

# timestring_to_seconds
#
# calculates time in seconds from timestrings with MM:SS format

function timestring_to_seconds {
	timestring="$1"
	IFS=':' read -r -a time_array <<<"${timestring}"
	seconds=$((time_array[0] * 60 + time_array[1]))
	echo "${seconds}"
}

# calculate_yesterday_timestamp
#
# calculates timestamp for yesterday at 23:59 (local time)

function calculate_yesterday_timestamp {
	seconds=$(date -d "yesterday 23:59" '+%s')
	echo "${seconds}"
}

# get_between_dates
#
# calculates dates between start date and end date

function get_between_dates {
	start_date="$1"
	end_date="$2"

	date_to_check="${start_date}"

	while (($(date -d "${date_to_check}" '+%s') < $(date -d "${end_date}" '+%s'))); do
		echo "${date_to_check}"
		date_to_check=$(date -d "${date_to_check} + 1 day" +"%Y-%m-%d")
	done
}
