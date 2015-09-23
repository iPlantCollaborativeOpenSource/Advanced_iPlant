#/bin/bash

# Author: Matthew Vaughn
#         vaughn@iplantcollaborative.org
#
# Adapted heavily from code by Rion Dooley
# https://github.com/agaveapi/docker-provisioning-demo

# Name of the Agave storageSystem to be created
SYSTEM_NAME=$1
AGAVE_USERNAME=$(auth-check | grep username | awk '{print $2}')

if [[ -z "${DEMO_S3_BUCKET}" ]] || [[ -z "${IAM_KEY}" ]] || [[ -z "${IAM_SECRET}" ]];
then
    echo -e "\x1B[3;41mError: Please set the DEMO_S3_BUCKET, IAM_KEY, and IAM_SECRET environment variables.\x1B[0m"
    exit 1
fi

# Defaults to AGAVE_USERNAME-s3-storage
# but can be over-ridden
if [[ -z "${SYSTEM_NAME}" ]];
then
    SYSTEM_NAME="${AGAVE_USERNAME}-s3-storage"
else
    if [[ ! "${SYSTEM_NAME}" =~ ^[0-9a-zA-Z._\-]+$ ]];
    then
        echo -e "\x1B[3;41mError: Please provide a valid name ([0-9a-zA-Z._-]+) for the storageSystem.\x1B[0m"
        exit 1
    fi
fi

S3_TEMPLATE="$(dirname $0)/templates/systems/s3-storage.tpl"

echo -e "Created the system description for \x1B[32m${SYSTEM_NAME}\x1B[0m" >&2

cat "${S3_TEMPLATE}" | sed -e "s/%AWS_BUCKET_NAME/$DEMO_S3_BUCKET/g" \
    -e "s=%AWS_ACCESS_KEY=${IAM_KEY}=g" \
    -e "s=%AWS_SECRET_KEY=${IAM_SECRET}=g" \
    -e "s/%AGAVE_SYSTEM_NAME/${SYSTEM_NAME}/g" \
    -e "s/%AGAVE_USERNAME/${AGAVE_USERNAME}/g"

exit 0
