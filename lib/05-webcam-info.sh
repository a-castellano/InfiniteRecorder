#!/bin/bash -
#===============================================================================
#
#          FILE: 05-webcam-info.sh
#
#   DESCRIPTION: Retrieve WebCam info from consul
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Álvaro Castellano Vela (alvaro.castellano.vela@gmail.com),
#       CREATED: 29/08/2022 19:32
#      REVISION:  ---
#===============================================================================

# list_webcams
#
# List webcams and populate WEBCAM_INSTANCES array
# returns 1 (true) or 0 (false) if there were errors

function list_webcams {
	write_log "Listing webcams"
	mapfile -t WEBCAM_INSTANCES < <( curl -s --header "X-Consul-Token: ${WEBCAM_CONSUL_TOKEN}"  http://${consul_server}:${CONSUL_PORT}/v1/catalog/services | jq -r 'keys[]')
	array_size="${#WEBCAM_INSTANCES[@]}"
	write_log "Found ${array_size} webcams"
	if [[ "X${array_size}X" == "X0X" ]]; then
		write_log "No consul servers defined."
		return 0
	fi
	return 1
}

# get_webcams_info
#
# Obtain webcams info from Consult and store it in
# WEBCAM_INSTANCES_INFO associative array

function get_webcams_info {
	for webcam_instance in ${WEBCAM_INSTANCES[@]}; do
	JSON_INFO=$(mktemp)
write_log "Retrieving webcam '${webcam_instance}' info."
	curl -s --header "X-Consul-Token: ${WEBCAM_CONSUL_TOKEN}"  http://${consul_server}:${CONSUL_PORT}/v1/catalog/service/${webcam_instance} > ${JSON_INFO}
	WEBCAM_INSTANCES_INFO[${webcam_instance}_IP]=$(jq '.[] | .ServiceAddress' ${JSON_INFO}) 
	WEBCAM_INSTANCES_INFO[${webcam_instance}_PORT]=$(jq '.[] | .ServiceMeta.streamPort' ${JSON_INFO}) 
	WEBCAM_INSTANCES_INFO[${webcam_instance}_URL]=$(jq '.[] | .ServiceMeta.stramURL' ${JSON_INFO}) 
	rm -f ${JSON_INFO}
done
}
