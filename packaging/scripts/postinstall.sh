#!/bin/bash

# Prepare an array with regular users with /bin/bash as shell

readarray allowed_users <<<$(awk -F ':' '$3>=1000 && $3 < 65534 && $7 == "/bin/bash"  {print $1}' </etc/passwd)

declare -a dialog_options

declare -i array_index
array_index=1
for allowed_user in "${allowed_users[@]}"; do
	#
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

	selected_user="${allowed_users[${selected}]}"

	echo "selected_user ${selected_user}"

fi
