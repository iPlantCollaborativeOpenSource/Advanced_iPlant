if [ -z "${DOCKER_DATA_IMAGE}" ];
then
    echo "Notice: no DOCKER_DATA_IMAGE was defined"
fi

if [ -z "${DOCKER_APP_IMAGE}" ];
then
    echo "Error: DOCKER_APP_IMAGE was not defined"
fi
if [ -z "$HOST_SCRATCH" ];
then
    echo "Warning: HOST_SCRATCH was not defined"
fi

TTY=""
MYUID=$(id -u $USER)
STAMP=$(date +%s)
HOST_OPTS="-m=1g"
# Run as user
# HOST_OPTS="$HOST_OPTS -u=$MYUID"
# Restruct network
HOST_OPTS="$HOST_OPTS --net=none"
# Maximum life for your app container
MAXLIFE=14400

# Optional data volume (created but inactive)
DOCKER_DATAC_MOUNT=
if [[ -n "${DOCKER_DATA_IMAGE}" ]];
then
    DOCKER_DATA_CONTAINER="db-$STAMP"
    # Data container (paused)
    DOCKER_DATA_CREATE="docker create ${HOST_OPTS} --name ${DOCKER_DATA_CONTAINER} $DOCKER_DATA_IMAGE"
    DOCKER_DATA_CONTAINER=$( ${DOCKER_DATA_CREATE} | cut -c1-12 )
    DOCKER_DATAC_MOUNT="--volumes-from ${DOCKER_DATA_CONTAINER}"
fi

# App container (running)
DOCKER_APP_CONTAINER="app-$STAMP"
DOCKER_APP_CREATE="docker run ${HOST_OPTS} -d ${DOCKER_DATAC_MOUNT} -v `pwd`:${HOST_SCRATCH}:rw -w ${HOST_SCRATCH} --name ${DOCKER_APP_CONTAINER} ${DOCKER_APP_IMAGE} sleep ${MAXLIFE}"
DOCKER_APP_CONTAINER=$( ${DOCKER_APP_CREATE} | cut -c1-12)
export DOCKER_APP_RUN="docker exec -i ${TTY} $DOCKER_APP_CONTAINER"
