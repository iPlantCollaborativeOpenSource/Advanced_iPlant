# Set configuration variables for docker-common.sh
#
# Base image for the execution environment
DOCKER_APP_IMAGE='%DOCKER_APP_IMAGE'
# Optional data volume
DOCKER_DATA_IMAGE='%DOCKER_DATA_IMAGE'
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
# "--filename INPUTFILE --max MAX_LENGTH --ignore IGNORE_LIST --allow-digits ALLOW_DIGITS"
#
# Dynamically create a string containing arguments to pass
# If you have simple --opt value pairs, you can use Agave's
# showArgument and argument attributes to make easy work of this
# If you need to implement a special case, such as passing a non-standard
# value for true, you can implement that with a bit of Bash logic
#
# The variables you choose in this template will be what you use in making
# an Agave application description so keep 'em short, descriptive, and UNIX-safe
#
# You control option order just by how you construct the ARGS string. No
# black magic involved...
#

ARGS=
ARGS="${agave-input} ${agave-param} ${agave-param}"
if [ -n "${agave-param}" ];
then
    ARGS="$ARGS --special-case special-value"
fi

# PATH-TO-CODE can point to an asset that is staged with
# the application to the remote system, or you can point to
# an asset that comes with the Docker image
# It's the same story for EXECUTABLE
#
$DOCKER_APP_RUN %EXECUTABLE %PATH-TO-CODE ${ARGS}
${AGAVE_JOB_CALLBACK_NOTIFICATION}

## Script logic ends here

## -> NO USER-SERVICABLE PARTS INSIDE
if [[ -n "${DOCKER_DATA_CONTAINER}" ]];
then
    docker rm -f ${DOCKER_DATA_CONTAINER} &
fi
## <- NO USER-SERVICABLE PARTS INSIDE
