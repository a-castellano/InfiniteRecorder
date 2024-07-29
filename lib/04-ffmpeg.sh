#!/bin/bash -
#===============================================================================
#
#          FILE: 07-ffmpeg.sh
#
#   DESCRIPTION: ffmpeg related functions
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Álvaro Castellano Vela (alvaro.castellano.vela@gmail.com),
#       CREATED: 02/07/2022 22:17
#      REVISION:  ---
#===============================================================================

source lib/01-log.sh

# take_snapshots
#
# checks cameras connectivity taking snapshots

function take_snapshots {
	failed_snapshots=false
	for webcam_instance in ${WEBCAM_INSTANCES[@]}; do
		# create snapshot location
		snapshot_location=$(mktemp)
		# Now we have a name, delete it
		rm -f ${snapshot_location}
		# Take Snapshot
		RTSP_URL="rtsp://${WEBCAM_INSTANCES_INFO[${webcam_instance}_USER]}:${WEBCAM_INSTANCES_INFO[${webcam_instance}_PASSWORD]}@${WEBCAM_INSTANCES_INFO[${webcam_instance}_IP]}:${WEBCAM_INSTANCES_INFO[${webcam_instance}_PORT]}${WEBCAM_INSTANCES_INFO[${webcam_instance}_URL]}"
		WEBCAM_INSTANCES_INFO[${webcam_instance}_RTSP_URL]="${RTSP_URL}"
		write_log "Taking snapshot test from ${webcam_instance}"
		/usr/bin/ffmpeg -y -i ${RTSP_URL} -vframes 1 "${snapshot_location}.jpg" >/dev/null 2>/dev/null
		ffmpeg_result=$?
		test -f "${snapshot_location}.jpg"
		snapshot_result=$?
		rm -f ${snapshot_location}
		if [[ "X${ffmpeg_result}${snapshot_result}X" != "X00X" ]]; then
			write_log "Snapshot test for webcam ${webcam_instance} has failed."
			failed_snapshots=true
		fi
	done
	if [ "${failed_snapshots}" = true ]; then
		write_log "Some snapshot tests have failed."
		return 0
	else
		return 1
	fi
}

# record_video
#
# records cam streaming in chunks
# Video is recoring in two simultaneous outputs
#
# Args
# $1 -> rtsp url
# $2 -> recording folder
# $3 -> reduced recording folder
# $4 -> webcam name
# $5 and beyond -> ffmpeg options
#

function record_video {
	record_video_command="
ffmpeg -y -i '$1' ${@:5} -map 0 -f segment -segment_time ${VIDEO_LENGTH} -segment_format mp4 -strftime 1 -reset_timestamps 1 \"$2/record-%Y-%m-%d_%H-%M-%S.mp4\" -vcodec libx264 -metadata title=\"$4\" -f segment -segment_time ${VIDEO_LENGTH} -segment_format mp4 -preset ultrafast -crf 40 -tune fastdecode -strftime 1 -reset_timestamps 1  \"$3/record-%Y-%m-%d_%H-%M-%S.mp4\" -vcodec libx264 -metadata title=\"$4\""
	su - "${OWNER_USER}" -s /bin/bash -c "${record_video_command}" 2>/dev/null >/dev/null
}

# record_reduced_video
#
# records cam streaming in chunks with reduced settings
# Video is recoring in only one output, reduced one
#
# Args
# $1 -> rtsp url
# $2 -> recording folder
# $3 -> webcam name
# $4 and beyond -> ffmpeg options
#

function record_reduced_video {
	record_video_command="
ffmpeg -y -i '$1' ${@:4} -map 0 -f segment -segment_time ${VIDEO_LENGTH} -segment_format mp4 -preset ultrafast -crf 40 -tune fastdecode -strftime 1 -reset_timestamps 1  \"$2/record-%Y-%m-%d_%H-%M-%S.mp4\" -vcodec libx264 -metadata title=\"$3\""
	su - "${OWNER_USER}" -s /bin/bash -c "${record_video_command}" 2>/dev/null >/dev/null
}


# combine_and_reduce_videos
#
# combines videos and reduce combined copy size
#
# Args
# $1 -> instance folder location
#

function combine_and_reduce_videos {
	instance="$1"
	START_FILE=""
	if [ -f "${instance}/last_merge" ]; then
		START_FILE=" -newer ${instance}/last_merge"
	fi
	available_files=$(find ${instance}/raw/ ${START_FILE} -iname "*.mp4" -type f -printf "%T@  %p\n" | sort -n | awk '{print $2}' | head -n ${FILE_LIST_LIMIT} | wc -l)
	if [[ "X${available_files}X" == "X${FILE_LIST_LIMIT}X" ]]; then
		readarray -t files_to_merge < <(find ${instance}/raw/ ${START_FILE} -iname "*.mp4" -type f -printf "%T@  %p\n" | sort -n | awk '{print $2}' | head -n ${MERGE_VIDEO_FILES})
		merged_file_name=$(basename "${files_to_merge[0]}")
		last_video_date=$(stat -c %Y "${files_to_merge[-1]}")
		video_year=$(date -d @${last_video_date} +'%Y')
		video_month=$(date -d @${last_video_date} +'%m')
		video_day=$(date -d @${last_video_date} +'%d')
		video_hour=$(date -d @${last_video_date} +'%H')
		write_log "Setting last video merget time"
		touch "${instance}/last_merge" -r "${files_to_merge[-1]}"
		mkdir -p ${instance}/merged/${video_year}/${video_month}/${video_day}/${video_hour}
		mkdir -p ${instance}/reduced/${video_year}/${video_month}/${video_day}/${video_hour}
		write_log "Merging video selection to ${instance}/merged/${video_year}/${video_month}/${video_day}/${video_hour}/${merged_file_name}"
		videos_to_merge_file=$(mktemp)
		printf "file %s\n" "${files_to_merge[@]}" >${videos_to_merge_file}
		ffmpeg -f concat -safe 0 -i ${videos_to_merge_file} -c copy "${instance}/merged/${video_year}/${video_month}/${video_day}/${video_hour}/${merged_file_name}" >/dev/null 2>/dev/null
		rm -f ${videos_to_merge_file}
		write_log "Reducing merged video to ${instance}/reduced/${video_year}/${video_month}/${video_day}/${video_hour}/${merged_file_name}"
		ffmpeg -hwaccel vaapi -vaapi_device /dev/dri/renderD128 -i "${instance}/merged/${video_year}/${video_month}/${video_day}/${video_hour}/${merged_file_name}" -vcodec libx264 -crf 40 -preset ultrafast -tune fastdecode "${instance}/reduced/${video_year}/${video_month}/${video_day}/${video_hour}/${merged_file_name}" >/dev/null 2>/dev/null
		write_log "Video combination for file ${instance}/merged/${video_year}/${video_month}/${video_day}/${video_hour}/${merged_file_name} ended"
		chown ${OWNER_USER}:${OWNER_USER} -R "${instance}/merged"
		chown ${OWNER_USER}:${OWNER_USER} -R "${instance}/reduced"
	else
		write_log "Not enough files to combine"
	fi
}
