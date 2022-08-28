#!/bin/bash -
#===============================================================================
#
#          FILE: 06-ffmpeg.sh
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

# take_snapshot
#
# checks camera connectivity taking 
# a snapshot

function take_snapshot {
	# create snapshot location
	snapshot_location=$(mktemp)
  # Now we have a name, delete it
	rm -f ${snapshot_location}
	# Take Snapshot
/usr/bin/ffmpeg -y -i rtsp://${CAM_USER}:${CAM_PASSWORD}@${CAM_IP}:${CAM_PORT}${CAM_URL} -vframes 1 "${snapshot_location}.jpg" > /dev/null 2> /dev/null
ffmpeg_result=$?
test -f "${snapshot_location}.jpg"
snapshot_result=$?
# Make sure that temp file is removed
rm -f "${snapshot_location}.jpg"
if [[ "X${ffmpeg_result}${snapshot_result}X" != "X00X" ]]; then
	write_log "Snapshot test has failed."
	return 1
else
	return 0
fi
}


# record_video
#
# records cam streaming in chunks

function record_video {
	record_vide_command="
ffmpeg -y -i rtsp://${CAM_USER}:${CAM_PASSWORD}@${CAM_IP}:${CAM_PORT}${CAM_URL} -c copy  -map 0 -f segment -segment_time ${VIDEO_LENGTH} -segment_format mp4 -strftime 1 \"${CAM_FOLDER}/record-%Y-%m-%d_%H-%M-%S.mp4\" -use_wallclock_as_timestamps 1 -reset_timestamps 1 -vcodec libx264 -metadata title=\"${CAM_NAME}\""

	su - "${OWNER_USER}" -s /bin/bash -c "${record_vide_command}" 2>/dev/null > /dev/null
}
