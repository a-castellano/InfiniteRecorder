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
	VAULT_INFO=$(mktemp)
write_log "Retrieving webcam '${webcam_instance}' info."
	curl -s --header "X-Consul-Token: ${WEBCAM_CONSUL_TOKEN}"  http://${consul_server}:${CONSUL_PORT}/v1/catalog/service/${webcam_instance} > ${JSON_INFO}
	WEBCAM_INSTANCES_INFO[${webcam_instance}_IP]=$(jq -r '.[] | .ServiceAddress' ${JSON_INFO}) 
	WEBCAM_INSTANCES_INFO[${webcam_instance}_PORT]=$(jq -r '.[] | .ServiceMeta.streamPort' ${JSON_INFO}) 
	WEBCAM_INSTANCES_INFO[${webcam_instance}_URL]=$(jq -r '.[] | .ServiceMeta.stramURL' ${JSON_INFO}) 
	rm -f ${JSON_INFO}
write_log "Retrieving webcam '${webcam_instance}' credentials."
WEBCAM_INSTANCES_INFO[${webcam_instance}_USER]=$(curl -s -X GET -H 'Content-Type: application/json' -H "X-Vault-Token: ${VAULT_ACESS_TOKEN}" https://${VAULT_SERVER}/v1/kv/data/webcam/${webcam_instance} -k | jq -r '.data.data.user')
WEBCAM_INSTANCES_INFO[${webcam_instance}_PASSWORD]=$(curl -s -X GET -H 'Content-Type: application/json' -H "X-Vault-Token: ${VAULT_ACESS_TOKEN}" https://${VAULT_SERVER}/v1/kv/data/webcam/${webcam_instance} -k | jq -r '.data.data.password')
	rm -f ${VAULT_INFO}
	WEBCAM_INSTANCES_INFO[${webcam_instance}_FOLDER]=$(echo "${RECORDING_FOLDER}/${webcam_instance}/raw" | perl -pe "s/\/\//\//g")
done
}
