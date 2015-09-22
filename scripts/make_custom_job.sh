#!/bin/bash

APP_ID=$1
EXEC_TEMPLATE=$2

if [ ! -f $EXEC_TEMPLATE ];
then
    echo -e "\x1B[3;41mError: $EXEC_TEMPLATE not a valid template.\x1B[0m"
fi

if [[ -z "${APP_ID}" ]];
then
    echo -e "\x1B[3;41mError: Please provide a Agave application ID.\x1B[0m"
    exit 1
fi

echo -e "Creating job description... \x1B[0m" >&2

cat "$EXEC_TEMPLATE" | sed -e "s/%AGAVE_USERNAME/${AGAVE_USERNAME}/g" \
  -e "s/%AGAVE_EXEC_SYSTEM/${AGAVE_EXEC_SYSTEM}/g" \
  -e "s/%APP_ID/${APP_ID}/g"

exit 0
