# Automated AWS
# For login to https://iplant-aws.signin.aws.amazon.com/console
#
# http://docs.aws.amazon.com/cli/latest/userguide/cli-iam-new-user-group.html

# agave
UNAME=$1
GROUP=${2:=training}

source ./config.sh
source lib/functions.sh

delete_keypair "${IAM_KEYNAME}"
delete_user "${IAM_USER}"

if [[ -n "${AGAVE_META_ID}" ]];
then
    delete_metadata "${AGAVE_META_ID}"
fi
