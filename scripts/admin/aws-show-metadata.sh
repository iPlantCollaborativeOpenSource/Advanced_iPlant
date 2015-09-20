#!/bin/bash

# Automated AWS account provisioning
# for Agave platform users

# agave
UNAME=$1
GROUP=$2

FDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${FDIR}/config.sh"
source "${FDIR}/lib/functions.sh"

confirm_user_provided "{$UNAME}" "${AGAVE_TENANTID}"
validate_agave_user "${UNAME}"
validate_aws_group "${GROUP}" "${UNAME}"

MQ="%7B%22name%22%3A%22${AGAVE_META_ID}%22%7D"
META_SEARCH=$(metadata-list -v -Q $MQ)

echo "${META_SEARCH}"

