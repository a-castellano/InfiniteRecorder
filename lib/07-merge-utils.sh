#!/bin/bash -
#===============================================================================
#
#          FILE: 07-merge-utils.sh
#
#   DESCRIPTION: Video merge funtions
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Álvaro Castellano Vela (alvaro.castellano.vela@gmail.com),
#       CREATED: 19/09/2024 22:22
#      REVISION:  ---
#===============================================================================

source lib/01-log.sh

# merge_videos_from_folder_by_date
#
# Merge videos of required cam and video quality folder for required date

function merge_videos_from_folder_by_date {
cam_folder="$1"
quality="$2"
date_to_check="${3}"

local folder_to_check="${cam_folder}/${quality}"
local folder_to_create_base="${cam_folder}/merged/${quality}"
local start_date=$(date -d "${date_to_check} 00:00:00" +"%Y-%m-%d %H:%M:%S")
local end_date=$(date -d "${date_to_check} 23:59:59" +"%Y-%m-%d %H:%M:%S")

local arrived_to_end_date=false

local current_period="${start_date}"
while [ "${arrived_to_end_date}" = false ]; do
	next_period=$(date -d "${current_period} ${MERGED_VIDEO_PERIOD_SECONDS} seconds" +"%Y-%m-%d %H:%M:%S" )
	next_period_date=$(date -d "${next_period}" +"%Y-%m-%d")
	if [ "${next_period_date}" != "${date_to_check}" ]; then
		next_period="${end_date}"
		arrived_to_end_date=true
	fi

echo "current_period ${current_period}"
echo "next_period ${next_period}"

readarray -t videos_to_merge < <(find "${folder_to_check}" -type f -iname "*.mp4" -newerBt "${current_period}" ! -newerBt "${next_period}")

# First video defines merged video name 

read -r merged_video_year merged_video_month merged_video_day merged_video_hour merged_video_minute merged_video_sencond <<<$(echo "${videos_to_merge[0]}" | perl -pe "s/^.*\/record-([0-9]+)-([0-9]+)-([0-9]+)_([0-9]+)-([0-9]+)-([0-9]+)\.mp4$/\1 \2 \3 \4 \5 \6/")

# This can be run once

merged_video_folder_container="${folder_to_create_base}/${merged_video_year}/${merged_video_month}"

echo "_______________________"
echo "_______________________"

	current_period="${next_period}"
done
}

# merge_videos_from_folder
#
# Merge videos of required cam and video quality folder

function merge_videos_from_folder {
cam_folder="$1"
quality="$2"

folder_to_check="${cam_folder}/${quality}"
		earlier_video_timestamp=$(find "${folder_to_check}" -type f -printf "%T@\n" | sort -n | head -1 | perl -pe 's/\..*$//')
		earlier_video_date=$(date -d "@${earlier_video_timestamp}" +"%Y-%m-%d")

		readarray -t dates_to_check < <(get_between_dates "${earlier_video_date}" "${yesterday_date}")

		for date_to_check in "${dates_to_check[@]}"; do
merge_videos_from_folder_by_date "${cam_folder}" "${quality}" "${date_to_check}"  
		done


}
