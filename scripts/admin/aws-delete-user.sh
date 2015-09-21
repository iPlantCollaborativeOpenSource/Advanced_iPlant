# Automated AWS
# For login to https://iplant-aws.signin.aws.amazon.com/console
#
# http://docs.aws.amazon.com/cli/latest/userguide/cli-iam-new-user-group.html

# agave
UNAME=$1
GROUP=${2:=training}

FDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${FDIR}/config.sh"
source "${FDIR}/lib/functions.sh"

delete_keypair "${IAM_KEYNAME}"
delete_user "${IAM_USER}"

if [[ -n "${AGAVE_META_ID}" ]];
then
    delete_metadata "${AGAVE_META_ID}"
fi

delete_s3_bucket "${S3_BUCKET_NAME}"
