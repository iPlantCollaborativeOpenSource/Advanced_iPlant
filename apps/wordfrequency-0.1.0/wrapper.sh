# Set configuration variables for docker-common.sh
#
# Base image for the execution environment
# Basically, Python 2:latest, with matplotlib
DOCKER_APP_IMAGE='mwvaughn/python-demo:dib-0923'
# Optional data volume
DOCKER_DATA_IMAGE=''
# Only change if you need to and know what you're doing
HOST_SCRATCH='/scratch'

# **MANDATORY**
# Creates the following variables:
#
#   DOCKER_APP_RUN - exec a command inside the running app container
#   DOCKER_APP_CONTAINER - name of the running app container
#   DOCKER_DATA_CONTAINER - name of the optional data container
#
source docker-common.sh

## Script logic begins here

# Construct ARG string
ARGS=
ARGS="${filename} ${max_length} ${ignore_list}"
if [[ "${allow_digits}" -eq 1 ]];
then
    ARGS="$ARGS --allow-digits true"
fi

$DOCKER_APP_RUN python lib/main.py ${ARGS}
${AGAVE_JOB_CALLBACK_NOTIFICATION}

## Script logic ends here

## -> NO USER-SERVICABLE PARTS INSIDE
if [[ -n "${DOCKER_DATA_CONTAINER}" ]];
then
    docker rm -f ${DOCKER_DATA_CONTAINER} &
fi
## <- NO USER-SERVICABLE PARTS INSIDE
