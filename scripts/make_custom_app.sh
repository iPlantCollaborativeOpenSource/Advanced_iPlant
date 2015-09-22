#!/bin/bash

EXEC_TEMPLATE=$1
AGAVE_USERNAME=$IPLANT_USERNAME
AGAVE_EXEC_SYSTEM=$AGAVE_EXEC_SYSTEM

if [ ! -f "$EXEC_TEMPLATE" ];
then
    echo -e "\x1B[3;41mError: $EXEC_TEMPLATE not a valid template.\x1B[0m"
fi

if [[ -z "${AGAVE_USERNAME}" ]];
then
    echo -e "\x1B[3;41mError: Please provide a valid Agave username.\x1B[0m"
    exit 1
fi

if [[ -z "${AGAVE_EXEC_SYSTEM}" ]];
then
    echo -e "\x1B[3;41mError: Please provide a valid name ([0-9a-zA-Z._-]+) for the executionSystem.\x1B[0m"
fi

echo -e "Creating app description... \x1B[0m" >&2

cat "$EXEC_TEMPLATE" | sed -e "s/%AGAVE_USERNAME/${AGAVE_USERNAME}/g" \
  -e "s/%AGAVE_EXEC_SYSTEM/${AGAVE_EXEC_SYSTEM}/g"

exit 0
