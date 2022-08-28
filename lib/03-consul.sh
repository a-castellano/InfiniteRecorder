#!/bin/bash -
#===============================================================================
#
#          FILE: 03-consul.sh
#
#   DESCRIPTION: Manage consul connections and info retireval
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Álvaro Castellano Vela (alvaro.castellano.vela@gmail.com),
#       CREATED: 28/08/2022 22:36
#      REVISION:  ---
#===============================================================================

# choose_consul_server
#
# Chooses consul server from cluster
# returns 1 (true) or 0 (false) if it host has been found

function choose_consul_server {
	CONSUL_SERVER=""
  for consul_server in ${CONSUL_CLUSTER_ARRAY[@]}; do
			write_log "Testing connection witch consul server ${server}"
			consul_http_status_code=$(curl -s -o /dev/null -w "%{http_code}" --header "X-Consul-Token: ${WEBCAM_CONSUL_TOKEN}"  http://${consul_server}:${CONSUL_PORT}/v1/catalog/services)
			if [[ "X${consul_http_status_code}X" = "X200X" ]]; then
				found_server=true
	      CONSUL_SERVER="${consul_server}"
				write_log "Consul server ${CONSUL_SERVER} will be used."
				break
			fi
	done

}
