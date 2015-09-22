#!/bin/bash

#/bin/bash

# Author: Matthew Vaughn
#         vaughn@iplantcollaborative.org
#
# Adapted heavily from code by Rion Dooley
# https://github.com/agaveapi/docker-provisioning-demo

MACHINE_NAME=$1
AGAVE_USERNAME=$2
AGAVE_SYSTEM_NAME=$3

if [[ -z "${MACHINE_NAME}" ]] || [[ ! -d "$HOME/.docker/machine/machines/$MACHINE_NAME" ]];
then
    echo -e "\x1B[3;41mError: Please provide a valid Docker Machine name.\x1B[0m"
    exit 1
fi

if [[ -z "${AGAVE_USERNAME}" ]];
then
    echo -e "\x1B[3;41mError: Please provide a valid Agave username.\x1B[0m"
    exit 1
fi

# Defaults to AGAVE_USERNAME-docker-compute
# but can be over-ridden
if [[ -z "${AGAVE_SYSTEM_NAME}" ]];
then
    AGAVE_SYSTEM_NAME="${AGAVE_USERNAME}-docker-compute"
else
    if [[ ! "${AGAVE_SYSTEM_NAME}" =~ ^[0-9a-zA-Z._\-]+$ ]];
    then
        echo -e "\x1B[3;41mError: Please provide a valid name ([0-9a-zA-Z._-]+) for the executionSystem.\x1B[0m"
        exit 1
    fi
fi

# Check for existence of docker-machine
if [[ -z "$(which docker-machine)" ]];
then
    echo -e "\x1B[3;41mError: Can't find docker-machine.\x1B[0m"
    exit 1
fi

function config_value() {
  echo $(docker-machine inspect $MACHINE_NAME | grep -i "\"$1\"" | awk '{print $2}' | sed  -e 's/,$//g' -e 's/"//g')
}

DOCKER_HOST_IP=$(docker-machine ip $MACHINE_NAME)
DOCKER_HOST_PORT=22
DOCKER_HOST_USERNAME=$(docker-machine ssh $MACHINE_NAME whoami)
DOCKER_HOST_PRIVATEKEY=$(cat ~/.docker/machine/machines/$MACHINE_NAME/id_rsa | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\\\n/g' -e 's/\//\\\//g')
DOCKER_HOST_PUBLICKEY=$(cat ~/.docker/machine/machines/$MACHINE_NAME/id_rsa.pub | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')
DOCKER_HOST_PROVIDER=$(config_value DriverName)
DOCKER_HOST_INSTANCE_ID=$(config_value Id)
DOCKER_HOST_WORKD=""

# Add DOCKER_HOST_USERNAME to docker group
DOCKER_GADD=$(docker-machine ssh $MACHINE_NAME "sudo gpasswd -a ${DOCKER_HOST_USERNAME} docker; sudo service docker restart")

# Create a date stamp to ensure the system name is fairly unique
DATESTAMP=$(date +%m%d%Y-%k%M)

EXEC_TEMPLATE="$(dirname $0)/templates/systems/execution.tpl"

echo -e "Created the system description for \x1B[32m${AGAVE_SYSTEM_NAME}\x1B[0m" >&2

cat "$EXEC_TEMPLATE" | sed -e "s/%DEMO_MACHINE_NAME/$MACHINE_NAME/g" \
  -e "s/%DOCKER_HOST_IP/$DOCKER_HOST_IP/g" \
  -e "s/%DOCKER_HOST_PORT/${DOCKER_HOST_PORT}/g" \
  -e "s/%DOCKER_HOST_USERNAME/$DOCKER_HOST_USERNAME/g" \
  -e "s/%DOCKER_HOST_PRIVATEKEY/${DOCKER_HOST_PRIVATEKEY}/g" \
  -e "s/%DOCKER_HOST_PUBLICKEY/${DOCKER_HOST_PUBLICKEY}/g" \
  -e "s/%DOCKER_HOST_PROVIDER/${DOCKER_HOST_PROVIDER}/g" \
  -e "s/%DOCKER_HOST_INSTANCE_ID/${DOCKER_HOST_INSTANCE_ID}/g" \
  -e "s/%DOCKER_HOST_WORKD/${DOCKER_HOST_WORKD}/g" \
  -e "s/%AGAVE_USERNAME/${AGAVE_USERNAME}/g" \
  -e "s/%AGAVE_SYSTEM_NAME/${AGAVE_SYSTEM_NAME}/g"

exit 0
