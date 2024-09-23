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

	local year=$(date -d "${date_to_check}" +"%Y")
	local month=$(date -d "${date_to_check}" +"%m")
	local day=$(date -d "${date_to_check}" +"%d")

	merged_video_folder_container="${folder_to_create_base}/${year}/${month}/${day}"

	write_log "Create folder ${merged_video_folder_container}"

	mkdir -p "${merged_video_folder_container}"

	local arrived_to_end_date=false

	local current_period="${start_date}"
	while [ "${arrived_to_end_date}" = false ]; do
		next_period=$(date -d "${current_period} ${MERGED_VIDEO_PERIOD_SECONDS} seconds" +"%Y-%m-%d %H:%M:%S")
		next_period_date=$(date -d "${next_period}" +"%Y-%m-%d")
		if [ "${next_period_date}" != "${date_to_check}" ]; then
			next_period="${end_date}"
			arrived_to_end_date=true
		fi

		readarray -t videos_to_merge < <(find "${folder_to_check}" -type f -iname "*.mp4" -newermt "${current_period}" ! -newermt "${next_period}" | sort -n)

		number_of_videos_to_merge="${#videos_to_merge[@]}"

		# First video defines merged video name

		if [ "${number_of_videos_to_merge}" -ne 0 ]; then

			write_log "Merging videos from ${current_period} to ${next_period}"
			video_list=$(mktemp)

			for video_to_merge in "${videos_to_merge[@]}"; do
				echo "file '${video_to_merge}'" >>"${video_list}"
			done

			first_video_file_array=(${videos_to_merge[0]//\// })
			first_video_file_name="${first_video_file_array[-1]}"

			ffmpeg -safe 0 -f concat -i "${video_list}" -c copy "${merged_video_folder_container}/${first_video_file_name}" 2>/dev/null >/dev/null

			touch -r "${videos_to_merge[0]}" "${merged_video_folder_container}/${first_video_file_name}"

			rm -f "${video_list}"
			write_log "Removing former videos from ${current_period} to ${next_period}"
			rm -f "${videos_to_merge[@]}"
		fi

		current_period="${next_period}"
	done
}

# merge_videos_from_folder
#
# Merge videos of required cam and video quality folder

function merge_videos_from_folder {
	cam_folder="$1"
	quality="$2"

	write_log "Cheking videos to merge from '${cam_folder}'"

	folder_to_check="${cam_folder}/${quality}"
	earlier_video_timestamp=$(find "${folder_to_check}" -type f -printf "%T@\n" | sort -n | head -1 | perl -pe 's/\..*$//')
	earlier_video_date=$(date -d "@${earlier_video_timestamp}" +"%Y-%m-%d")

	readarray -t dates_to_check < <(get_between_dates "${earlier_video_date}" "${yesterday_date}")

	for date_to_check in "${dates_to_check[@]}"; do
		write_log "Cheking videos to merge from '${cam_folder}' for date ${date_to_check}"
		merge_videos_from_folder_by_date "${cam_folder}" "${quality}" "${date_to_check}"
	done
}
