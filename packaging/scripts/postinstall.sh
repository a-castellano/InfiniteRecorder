#!/bin/bash

# Prepare an array with regular users with /bin/bash as shell

declare selected_user

if [ -z "${TARGET_USER}" ]; then

	readarray allowed_users <<<$(awk -F ':' '$3>=1000 && $3 < 65534 && $7 == "/bin/bash"  {print $1}' </etc/passwd)

	declare -a dialog_options

	declare -i array_index
	array_index=1
	for allowed_user in "${allowed_users[@]}"; do
		dialog_options+=("${array_index}" "${allowed_user}" off)
		array_index=$((array_index + 1))
	done

	dialog_properties=(
		--title "User selection"
		--stdout
		--radiolist "Select user where infinite recorder services will be installed:" 0 0 2
	)

	selected_option=$(dialog "${dialog_properties[@]}" "${dialog_options[@]}")

	if [ -z "${selected_option}" ]; then
		echo "No user was set, aborting."
		exit 1
	else

		echo "selected_option ${selected_option}"

		selected_user=$(echo "${allowed_users[${selected}]}" | xargs echo -n)

		echo "selected_user #${selected_user}#"

	fi
else # Target user is defined
	selected_user="${TARGET_USER}"
fi

if getent passwd "${selected_user}" >/dev/null; then

	# Enable linger for required user

	loginctl enable-linger "${selected_user}"

	echo "Configuring windmaker-infiniterecorder service for ${selected_user}"

	user_home=$(getent passwd "${selected_user}" | cut -d: -f6)

	su -u "${selected_user}" -c "mkdir -p  ${user_home}/.config/systemd/user" 2>/dev/null

	cat <<EOF >"${user_home}/.config/windmaker-infiniterecorder-env-example"
#!/bin/bash

VIDEO_LENGTH="0:15"
RECORDING_FOLDER="/home/alvaro/recordings"
RAW_VIDEO_DELETE_TIME=480
REDUCED_VIDEO_DELETE_TIME=480
WEBCAM_INSTANCES=("WebCamOne" "WebCamTwo")

declare -A WEBCAM_INSTANCES_INFO

WEBCAM_INSTANCES_INFO["WebCamOne_IP"]="10.10.10.10"
WEBCAM_INSTANCES_INFO["WebCamOne_PORT"]="554"
WEBCAM_INSTANCES_INFO["WebCamOne_RTSP_URL"]="/h264Preview_01_main"
WEBCAM_INSTANCES_INFO["WebCamOne_FFMPEG_OPTIONS"]="-c copy"
WEBCAM_INSTANCES_INFO["WebCamOne_USER"]="admin"
WEBCAM_INSTANCES_INFO["WebCamOne_PASSWORD"]="pass"
WEBCAM_INSTANCES_INFO["WebCamOne_REDUCED_ONLY"]=true

WEBCAM_INSTANCES_INFO["WebCamTwo_IP"]="10.10.10.11"
WEBCAM_INSTANCES_INFO["WebCamTwo_PORT"]="554"
WEBCAM_INSTANCES_INFO["WebCamTwo_RTSP_URL"]="/h264Preview_01_main"
WEBCAM_INSTANCES_INFO["WebCamTwo_FFMPEG_OPTIONS"]="-c copy"
WEBCAM_INSTANCES_INFO["WebCamTwo_USER"]="admin"
WEBCAM_INSTANCES_INFO["WebCamTwo_PASSWORD"]="pass"
WEBCAM_INSTANCES_INFO["WebCamOne_REDUCED_ONLY"]=false
EOF

	cat <<EOF >"${user_home}/.config/systemd/user/windmaker-infiniterecorder.service"
[Unit]
Description=Windmaker Infiniterecorder
Wants=network-online.target
After=nss-lookup.target
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/windmaker-infiniterecorder
Restart=always
EnvironmentFile=${user_home}/.config/windmaker-infiniterecorder-env

[Install]
WantedBy=default.target
EOF

	echo "As user '${selected_user}', run the following command:"
	echo ""
	echo "systemctl --user daemon-reload"
	echo ""
	echo "Leave environment file in ${user_home}/.config/windmaker-infiniterecorder-env"
	echo ""
	echo "Example env file has been placed in ${user_home}/.config/windmaker-infiniterecorder-env-example"
	echo ""
	echo "Run the folloign command for enabling windmaker-infiniterecorder service"
	echo "systemctl --user enable windmaker-infiniterecorder.service"
	echo ""
	echo "Run the following command for starting windmaker-infiniterecorder service:"
	echo "systemctl --user start windmaker-infiniterecorder.service"
	echo ""
	echo "Visit https://github.com/a-castellano/InfiniteRecorder for more info and docs"

else

	echo "Selected user '${selected_user}' does not exist."
	exit 1
fi
