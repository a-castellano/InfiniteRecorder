#!/bin/bash -
#===============================================================================
#
#          FILE: 04-vault.sh
#
#   DESCRIPTION: Manage vault connections and info retireval
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Álvaro Castellano Vela (alvaro.castellano.vela@gmail.com),
#       CREATED: 29/08/2022 20:32
#      REVISION:  ---
#===============================================================================

# choose_vault_server
#
# Chooses consul server from cluster
# returns 1 (true) or 0 (false) if it host has been found

function choose_vault_server {
write_log "Retrive active vault server"
# Filter vault server, get active
ACTIVE_VAULT_SERVICE_FILE=$(mktemp)
curl -s --header "X-Consul-Token: ${VAULT_CONSUL_TOKEN}" http://${consul_server}:${CONSUL_PORT}/v1/catalog/service/vault | jq '.[] | select(.ServiceTags[] | contains("active") )' > ${ACTIVE_VAULT_SERVICE_FILE}
vault_ip=$(jq '.ServiceAddress' ${ACTIVE_VAULT_SERVICE_FILE} | sed 's/"//g')
vault_port=$(jq '.ServicePort' ${ACTIVE_VAULT_SERVICE_FILE})
VAULT_SERVER="${vault_ip}:${vault_port}"
rm -f ${ACTIVE_VAULT_SERVICE_FILE}
if [[ "X${VAULT_SERVER}X" == "X:X" ]];then
	write_log "No vault server found"
	return 0
fi
write_log "Vault server ${VAULT_SERVER} will be used"
}
